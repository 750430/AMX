module_name='Cisco Video Conference Rev6-00'(dev dvTP[], dev vdvVTC, dev vdvVTC_FB, dev dvVTC)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/06/2011  AT: 18:05:27        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                

	define_module 'Cisco Video Conference Rev6-00' vtc1(dvTP_VTC[1],vdvVTC1,vdvVTC1_FB,dvVTC) 
*)
(***********************************************************)
#include 'HoppSNAPI Rev6-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //Timeline

long	tlPoll		=	2001

define_constant //Button Types

tpMomentary			=	1	//Buttons that Send their command immediately
tpRepeat			=	2	//Buttons that Send their command once, then repeat it after 500ms
tpPressandHold		=	3	//Buttons that Send one command on being pressed and another on being released
tpSetOrPress		=	4	//Buttons that do one thing when Held for 1.5 seconds, and something different if they are only pressed briefly

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable  //Active Variables

integer 	nActiveSource 
integer 	nPrivacyStatus
integer		nPresentationStatus
integer		nActiveCallStatus
integer		nActiveCall

define_variable //Button Variables

integer		btnType[140]
integer		btnRelativeSet[140]

define_variable //Typing and Loop Variables

char	 	cKeyPreview[50]
integer 	nButtonHeld
integer 	x

define_variable //Communication Variables

char		cVTC_Buff[255]
integer 	nLoggedIn	=	1

define_variable //Timeline Variables
long 		lPollTimes[]	=	{3000,3000,3000,3000}

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function key(char cKey[])
{
	switch(cKey)
	{
		case '#': send_string dvVTC,"'xCommand Key Click Key:Square',$0D,$0A"
		case '*': send_string dvVTC,"'xCommand Key Click Key:Star',$0D,$0A"
		default: send_string dvVTC,"'xCommand Key Click Key:',cKey,$0D,$0A"
	}
	cKeyPreview="cKeyPreview,cKey"
	show_phone_number(cKeyPreview)
	cancel_wait 'New Key'
	wait 20 'New Key' 
	{
		cKeyPreview=''
		show_phone_number(cKeyPreview)
	}
}

define_function backspace()
{
	send_string dvVTC, "'xCommand Key Click Key:C',$0D,$0A"
	if(length_string(cKeyPreview)>0)
	{
		set_length_string(cKeyPreview,length_string(cKeyPreview)-1)
		show_phone_number(cKeyPreview)
		cancel_wait 'New Key'
		wait 20 'New Key' 
		{
			cKeyPreview=''
			show_phone_number(cKeyPreview)
		}		
	}
}

define_function show_phone_number(char cNumber[])
{
	if(length_string(cNumber)<12) send_command dvTP,"'!T',1,cNumber"	
	else if(length_string(cNumber)<24) send_command dvTP,"'!T',1,left_string(cNumber,12),$0D,$0A,mid_string(cNumber,13,12)"	
	else send_command dvTP,"'!T',1,mid_string(cNumber,length_string(cNumber)-23,12),$0D,$0A,right_string(cNumber,12)"
}

define_function tp_fb()
{
	[dvTP,VTC_PRIVACY_TOG] = 	nPrivacyStatus
	[dvTP,VTC_PRIVACY_ON]	=	nPrivacyStatus
	[dvTP,VTC_PRIVACY_OFF]	=	!nPrivacyStatus
	
	[vdvVTC_FB,VTC_PRIVACY_TOG] = 	nPrivacyStatus
	[vdvVTC_FB,VTC_PRIVACY_ON]	=	nPrivacyStatus
	[vdvVTC_FB,VTC_PRIVACY_OFF]	=	!nPrivacyStatus
	
	[dvTP,VTC_CONTENT_TOG] = 	nPresentationStatus
	[dvTP,VTC_CONTENT_ON]	=	nPresentationStatus
	[dvTP,VTC_CONTENT_OFF]	=	!nPresentationStatus
	
	[vdvVTC_FB,VTC_CONTENT_TOG] = 	nPresentationStatus
	[vdvVTC_FB,VTC_CONTENT_ON]	=	nPresentationStatus
	[vdvVTC_FB,VTC_CONTENT_OFF]	=	!nPresentationStatus
	
	for(x=1;x<=max_length_array(VTC_NR_VID);x++) 
	{
		[dvTP,VTC_NR_VID[x]]=nActiveSource=x
		[vdvVTC_FB,VTC_NR_VID[x]]=nActiveSource=x
	}
}

define_function parse(cMsg[100])
{
	select
	{
		active(find_string(cMsg,"'Audio Microphones Mute:'",1)): 
		{
			remove_string(cMsg,"'Audio Microphones Mute:'",1)
			if(find_string(cMsg,"'On'",1))  on[nPrivacyStatus]
			if(find_string(cMsg,"'Off'",1))  off[nPrivacyStatus]
		}
		active(find_string(cMsg,"'xConfiguration Video MainVideoSource:'",1)):
		{
			remove_string(cMsg,"'xConfiguration Video MainVideoSource:'",1)
			nActiveSource=atoi(left_string(cMsg,find_string(cMsg,"$0D,$0A",1)))
		}
		active(find_string(cMsg,"'Conference Presentation Mode: Off'",1) or find_string(cMsg,"'Conference Presentation Mode: Receiving'",1) or find_string(cMsg,"'PresentationStopResult (status=OK)'",1)):
		{
			off[nPresentationStatus]
		}
		active(find_string(cMsg,"'Conference Presentation Mode: Sending'",1) or find_string(cMsg,"'PresentationStartResult (status=OK)'",1)):
		{
			on[nPresentationStatus]
		}
		active(find_string(cMsg,"'*s Call '",1)):
		{
			remove_string(cMsg,"'*s Call '",1)
			nActiveCall=atoi(left_string(cMsg,find_string(cMsg,"' '",1)-1))
		}
		active(find_string(cMsg,"'login:'",1)):
		{
			off[nLoggedIn]
			wait 90 send_string dvVTC,"'admin'"
			wait 100 send_string dvVTC,"$0D,$0A"
		}
		active(find_string(cMsg,"'Password:'",1)):
		{
			send_string dvVTC,"$0D,$0A"
		}
		active(find_string(cMsg,"'Welcome to'",1)):
		{
			on[nLoggedIn]
			wait 30 send_string dvVTC,"'xConfiguration SerialPort LoginRequired: Off',$0D,$0A"
		}
		active(find_string(cMsg,"'Login incorrect'",1)):
		{
			off[nLoggedIn]
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start //Button Configuration

btnType[VTC_WAKE]			=	tpMomentary

btnType[VTC_PRIVACY_TOG]	=	tpMomentary
btnType[VTC_PRIVACY_ON]		=	tpMomentary
btnType[VTC_PRIVACY_OFF]	=	tpMomentary

btnType[VTC_KEY_0]			=	tpMomentary
btnType[VTC_KEY_1]			=	tpMomentary
btnType[VTC_KEY_2]			=	tpMomentary
btnType[VTC_KEY_3]			=	tpMomentary
btnType[VTC_KEY_4]			=	tpMomentary
btnType[VTC_KEY_5]			=	tpMomentary
btnType[VTC_KEY_6]			=	tpMomentary
btnType[VTC_KEY_7]			=	tpMomentary
btnType[VTC_KEY_8]			=	tpMomentary
btnType[VTC_KEY_9]			=	tpMomentary
btnType[VTC_KEY_STAR]		=	tpMomentary
btnType[VTC_KEY_POUND]		=	tpMomentary
btnType[VTC_BACKSPACE]		=	tpRepeat
btnType[VTC_DIAL]			=	tpMomentary
btnType[VTC_HANGUP]			=	tpMomentary

btnType[VTC_KEY_KEYBRD]		=	tpMomentary
btnType[VTC_KEY_PERIOD]		=	tpMomentary
btnType[VTC_CLEAR]			=	tpMomentary

btnType[VTC_F1]				=	tpMomentary
btnType[VTC_F2]				=	tpMomentary
btnType[VTC_F3]				=	tpMomentary
btnType[VTC_F4]				=	tpMomentary
btnType[VTC_F5]				=	tpMomentary

btnType[VTC_MENU]			=	tpMomentary
btnType[VTC_UP]				=	tpMomentary
btnType[VTC_DOWN]			=	tpMomentary
btnType[VTC_LEFT]			=	tpMomentary
btnType[VTC_RIGHT]			=	tpMomentary
btnType[VTC_OK]				=	tpMomentary
btnType[VTC_CANCEL]			=	tpMomentary

btnType[VTC_CAM_UP]			=	tpPressandHold
btnType[VTC_CAM_DOWN]		=	tpPressandHold
btnType[VTC_CAM_LEFT]		=	tpPressandHold
btnType[VTC_CAM_RIGHT]		=	tpPressandHold
btnType[VTC_ZOOM_IN]		=	tpPressandHold
btnType[VTC_ZOOM_OUT]		=	tpPressandHold
btnType[VTC_CAM_PRESET1]	=	tpSetOrPress
btnType[VTC_CAM_PRESET2]	=	tpSetOrPress
btnType[VTC_CAM_PRESET3]	=	tpSetOrPress
btnType[VTC_CAM_PRESET4]	=	tpSetOrPress
btnType[VTC_CAM_PRESET5]	=	tpSetOrPress
btnType[VTC_CAM_PRESET6]	=	tpSetOrPress

btnType[VTC_NR_VID1]		=	tpMomentary
btnType[VTC_NR_VID2]		=	tpMomentary
btnType[VTC_NR_VID3]		=	tpMomentary
btnType[VTC_NR_VID4]		=	tpMomentary
btnType[VTC_NR_VID5]		=	tpMomentary

btnType[VTC_PRES_1]			=	tpMomentary
btnType[VTC_PRES_2]			=	tpMomentary
btnType[VTC_PRES_3]			=	tpMomentary
btnType[VTC_PRES_4]			=	tpMomentary
btnType[VTC_PRES_5]			=	tpMomentary

btnType[VTC_CONTENT_TOG]	=	tpMomentary
btnType[VTC_CONTENT_ON]		=	tpMomentary
btnType[VTC_CONTENT_OFF]	=	tpMomentary
btnType[VTC_SELFVIEW_TOG]	=	tpMomentary
btnType[VTC_SELFVIEW_ON]	=	tpMomentary
btnType[VTC_SELFVIEW_OFF]	=	tpMomentary
btnType[VTC_PIP_TOG]		=	tpMomentary
btnType[VTC_PIP_ON]			=	tpMomentary
btnType[VTC_PIP_OFF]		=	tpMomentary

btnType[VTC_HOME]			=	tpMomentary
btnType[VTC_BACK]			=	tpMomentary
btnType[VTC_INFO]			=	tpMomentary
btnType[VTC_ADDRESSBOOK]	=	tpMomentary
btnType[VTC_NEAR]			=	tpMomentary
btnType[VTC_FAR]			=	tpMomentary
btnType[VTC_OPTION]			=	tpMomentary
btnType[VTC_LAYOUT]			=	tpMomentary

btnType[VTC_FAR_CAM_UP]			=	tpPressandHold
btnType[VTC_FAR_CAM_DOWN]		=	tpPressandHold
btnType[VTC_FAR_CAM_LEFT]		=	tpPressandHold
btnType[VTC_FAR_CAM_RIGHT]		=	tpPressandHold
btnType[VTC_FAR_CAM_ZOOM_IN]	=	tpPressandHold
btnType[VTC_FAR_CAM_ZOOM_OUT]	=	tpPressandHold

btnRelativeSet[VTC_CAM_PRESET1]	=	VTC_SET_PRESET1
btnRelativeSet[VTC_CAM_PRESET2]	=	VTC_SET_PRESET2
btnRelativeSet[VTC_CAM_PRESET3]	=	VTC_SET_PRESET3
btnRelativeSet[VTC_CAM_PRESET4]	=	VTC_SET_PRESET4
btnRelativeSet[VTC_CAM_PRESET5]	=	VTC_SET_PRESET5
btnRelativeSet[VTC_CAM_PRESET6]	=	VTC_SET_PRESET6

define_start //Actual Startup

create_buffer dvVTC, cVTC_Buff

timeline_create(tlPoll,lPollTimes,length_array(lPollTimes),timeline_relative,timeline_repeat)

#include 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event //Data Events

data_event[dvVTC]
{
	string:
	{
		while(find_string(cVTC_Buff,"$0D,$0A",1 or find_string(cVTC_Buff,"'login:'",1)))
		{
			if (find_string(cVTC_Buff,"$0D,$0A",1)) parse(remove_string(cVTC_Buff,"$0D,$0A",1))
			else parse(remove_string(cVTC_Buff,"'login:'",1))
		}
	}
}



define_event //Buttons

button_event[dvTP,0]
{
	push:
	{
		to[button.input]
		switch(btnType[button.input.channel])
		{
			case tpMomentary: 
			case tpPressandHold: to[vdvVTC,button.input.channel]
			case tpRepeat: 
			{
				set_pulse_time(1)
				pulse[vdvVTC,button.input.channel]
			}
			case tpSetOrPress: {} //Do Nothing
		}
	}
	hold[3,repeat]:
	{
		stack_var integer nSet
		switch(btnType[button.input.channel])
		{
			case tpRepeat:
			{
				if(button.holdtime>=500)
				{
					set_pulse_time(1)
					pulse[vdvVTC,button.input.channel]
				}
			}
			case tpSetOrPress:
			{
				if(button.holdtime>=1500 and !nSet)
				{
					send_command dvTP,"'ABEEP'"
					pulse[vdvVTC,btnRelativeSet[button.input.channel]]
					on[nSet]
				}
			}
		}
	}
	release:
	{
		switch(btnType[button.input.channel])
		{
			case tpMomentary: 
			case tpPressandHold:
			case tpRepeat: {} //Do Nothing				
			case tpSetOrPress:
			{
				if(button.holdtime<1500)
				{
					pulse[vdvVTC,button.input.channel]                                                                       
				}
			}
		}		
	}
}

channel_event [vdvVTC, 0]
{
	on:
	{
		switch(channel.channel)
		{
			case VTC_KEY_1:
			case VTC_KEY_2:
			case VTC_KEY_3:
			case VTC_KEY_4:
			case VTC_KEY_5:
			case VTC_KEY_6:
			case VTC_KEY_7:
			case VTC_KEY_8:
			case VTC_KEY_9:			key(itoa(channel.channel-10))
			case VTC_KEY_0:   		key('0')
			case VTC_KEY_STAR:		key('*')
			case VTC_KEY_POUND:		key('#')
			case VTC_BACKSPACE:		backspace()
	
			case VTC_CONTENT_TOG: 	
			{
				switch(nPresentationStatus)
				{
					case 0:	send_string dvVTC,"'xCommand Presentation Start',$0D,$0A"
					case 1:	send_string dvVTC,"'xCommand Presentation Stop',$0D,$0A"
				}
			}
			case VTC_CONTENT_ON:	send_string dvVTC,"'xCommand Presentation Start',$0D,$0A"
			case VTC_CONTENT_OFF:	send_string dvVTC,"'xCommand Presentation Stop',$0D,$0A"
			
			case VTC_PRIVACY_TOG:	send_string dvVTC, "'xCommand Key Click Key:MuteMic',$0D,$0A"
			case VTC_PRIVACY_OFF:	
			{
				send_string dvVTC, "'xCommand Audio Microphones UnMute',$0D,$0A"
				send_string dvVTC,"'xStatus Audio Microphones Mute',$0D,$0A"
			}
			case VTC_PRIVACY_ON:	
			{
				send_string dvVTC, "'xCommand Audio Microphones Mute',$0D,$0A"
				send_string dvVTC,"'xStatus Audio Microphones Mute',$0D,$0A"
			}

			case VTC_DIAL:	send_string dvVTC, "'xCommand Key Click Key:Call',$0D,$0A"		
			case VTC_HANGUP:		
			{
				send_string dvVTC, "'xCommand Call DisconnectAll',$0D,$0A"
				cKeyPreview=''
				show_phone_number(cKeyPreview)
			}
			case VTC_LAYOUT:
			case VTC_PIP_TOG:			send_string dvVTC, "'xCommand Key Click Key:Layout',$0D,$0A"	
			case VTC_SELFVIEW_TOG:		send_string dvVTC, "'xCommand Key Click Key:Selfview',$0D,$0A"
			case VTC_ADDRESSBOOK:		send_string dvVTC, "'xCommand Key Click Key:PhoneBook',$0D,$0A"
			case VTC_MENU:				send_string dvVTC, "'xCommand Key Click Key:Ok',$0D,$0A"
			case VTC_UP:				send_string dvVTC, "'xCommand Key Click Key:Up',$0D,$0A"		
			case VTC_DOWN:				send_string dvVTC, "'xCommand Key Click Key:Down',$0D,$0A"
			case VTC_LEFT:				send_string dvVTC, "'xCommand Key Click Key:Left',$0D,$0A"
			case VTC_RIGHT:				send_string dvVTC, "'xCommand Key Click Key:Right',$0D,$0A"
			case VTC_CANCEL:	        send_string dvVTC, "'xCommand Key Click Key:Home',$0D,$0A"
			case VTC_OK:				send_string dvVTC, "'xCommand Key Click Key:Ok',$0D,$0A"
			case VTC_F1:				send_string dvVTC, "'xCommand Key Click Key:F1',$0D,$0A"
			case VTC_F2:				send_string dvVTC, "'xCommand Key Click Key:F2',$0D,$0A"
			case VTC_F3:				send_string dvVTC, "'xCommand Key Click Key:F3',$0D,$0A"
			case VTC_F4:				send_string dvVTC, "'xCommand Key Click Key:F4',$0D,$0A"
			case VTC_F5:				send_string dvVTC, "'xCommand Key Click Key:F5',$0D,$0A"
			case VTC_WAKE:				send_string dvVTC, "'xCommand Standby Deactivate',$0D,$0A"				
			case VTC_ZOOM_IN:			send_string dvVTC, "'xCommand Camera Ramp CameraId:1 Zoom:in ZoomSpeed:10',$0D,$0A"
			case VTC_ZOOM_OUT:			send_string dvVTC, "'xCommand Camera Ramp CameraId:1 Zoom:out ZoomSpeed:10',$0D,$0A"
			case VTC_CAM_UP:			send_string dvVTC, "'xCommand Camera Ramp CameraId:1 Tilt:up TiltSpeed:1',$0D,$0A"
			case VTC_CAM_DOWN:			send_string dvVTC, "'xCommand Camera Ramp CameraId:1 Tilt:down TiltSpeed:1',$0D,$0A"
			case VTC_CAM_LEFT: 			send_string dvVTC, "'xCommand Camera Ramp CameraId:1 Pan:left PanSpeed:1',$0D,$0A"
			case VTC_CAM_RIGHT: 		send_string dvVTC, "'xCommand Camera Ramp CameraId:1 Pan:right PanSpeed:1',$0D,$0A" 
	
			case VTC_NR_VID1:
			case VTC_NR_VID2:
			case VTC_NR_VID3:
			case VTC_NR_VID4:			
			case VTC_NR_VID5:	
			{
				SEND_STRING dvVTC, "'xConfiguration Video MainVideoSource:',ITOA(channel.channel-VTC_NR_VID1+1),$0D"
			}
			case VTC_CAM_PRESET1:
			case VTC_CAM_PRESET2:
			case VTC_CAM_PRESET3:
			case VTC_CAM_PRESET4:
			case VTC_CAM_PRESET5:
			case VTC_CAM_PRESET6:
			{
				send_string dvVTC,"'xCommand Preset Activate PresetId:',ITOA(channel.channel - (VTC_CAM_PRESET1-1)),$0D,$0A"
			}
			
			case VTC_SET_PRESET1:
			case VTC_SET_PRESET2:
			case VTC_SET_PRESET3:
			case VTC_SET_PRESET4:
			case VTC_SET_PRESET5:
			case VTC_SET_PRESET6:
			{
				send_string dvVTC,"'xCommand Preset Store PresetId:',ITOA(channel.channel - (VTC_SET_PRESET1-1)),' Type:Camera Description:"Preset ',ITOA(channel.channel - (VTC_SET_PRESET1-1)),'"',$0D,$0A"
			}
		
			
			case VTC_PRES_1:
			case VTC_PRES_2:
			case VTC_PRES_3:
			case VTC_PRES_4:
			case VTC_PRES_5:
			{
				send_string dvVTC,"'xConfiguration Video DefaultPresentationSource: ',ITOA(channel.channel - (VTC_PRES_1-1)),$0D,$0A"
			}

			case VTC_FAR_CAM_ZOOM_IN:		send_string dvVTC,"'xCommand FarEndControl Camera Move CallId:',itoa(nActiveCall),' Value:ZoomIn',$0D,$0A"
			case VTC_FAR_CAM_ZOOM_OUT:		send_string dvVTC,"'xCommand FarEndControl Camera Move CallId:',itoa(nActiveCall),' Value:ZoomOut',$0D,$0A"
			case VTC_FAR_CAM_UP:			send_string dvVTC,"'xCommand FarEndControl Camera Move CallId:',itoa(nActiveCall),' Value:Up',$0D,$0A"
			case VTC_FAR_CAM_DOWN:			send_string dvVTC,"'xCommand FarEndControl Camera Move CallId:',itoa(nActiveCall),' Value:Down',$0D,$0A"
			case VTC_FAR_CAM_LEFT:			send_string dvVTC,"'xCommand FarEndControl Camera Move CallId:',itoa(nActiveCall),' Value:Left',$0D,$0A"
			case VTC_FAR_CAM_RIGHT: 		send_string dvVTC,"'xCommand FarEndControl Camera Move CallId:',itoa(nActiveCall),' Value:Right',$0D,$0A"
		}	
	}	
	off:
	{
		switch(channel.channel)
		{
			case VTC_ZOOM_IN:
			case VTC_ZOOM_OUT:		send_string dvVTC,"'xCommand Camera Ramp CameraId:1 Zoom:stop',$0D,$0A"
			case VTC_CAM_UP:
			case VTC_CAM_DOWN:		send_string dvVTC,"'xCommand Camera Ramp CameraId:1 Tilt:stop',$0D,$0A"
			case VTC_CAM_LEFT:
			case VTC_CAM_RIGHT:		send_string dvVTC,"'xCommand Camera Ramp CameraId:1 Pan:stop',$0D,$0A"

			case VTC_FAR_CAM_ZOOM_IN:
			case VTC_FAR_CAM_ZOOM_OUT:	
			case VTC_FAR_CAM_UP:
			case VTC_FAR_CAM_DOWN:	
			case VTC_FAR_CAM_LEFT:
			case VTC_FAR_CAM_RIGHT: send_string dvVTC,"'xCommand FarEndControl Camera Stop CallId:',itoa(nActiveCall),$0D,$0A"
		}   
	}
}

define_event //Timeline Events

timeline_event[tlPoll]
{
	if(nLoggedIn)
	{
		switch(timeline.sequence)
		{
			case 1: send_string dvVTC,"'xConfiguration Video MainVideoSource',$0D,$0A"
			case 2: send_string dvVTC,"'xStatus Audio Microphones Mute',$0D,$0A"
			case 3: send_string dvVTC,"'xStatus Conference Presentation Mode',$0D,$0A"
			case 4: send_string dvVTC,"'xStatus Call',$0D,$0A"
		}
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
