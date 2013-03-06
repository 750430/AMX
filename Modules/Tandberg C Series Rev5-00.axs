MODULE_NAME='Tandberg C Series Rev5-00'(DEV vdvTP, DEV vdvVTC, DEV dvVTC)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/06/2011  AT: 18:05:27        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-00.axi'

//define_module 'Tandberg C Series Rev5-00' vtc1(vdvTP_VTC1,vdvVTC1,dvVTC)
//Set Baud 38400,N,8,1
//Remember to set the Tandberg to not require authentication, and then reboot the tandberg
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lFB	 		=	2000 		//Timeline for feedback
long tlPoll			=	2001

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

INTEGER btn_VTC[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,
										33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,
										62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,
										91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,
										115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,
										137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,
										159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,
										181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,
										203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,
										225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,
										247,248,249,250,251,252,253,254,255}

INTEGER nSRC = 1
integer nLoggedIn	=	1

CHAR cPRIV[2][3] = {'On','Off'}
INTEGER nPRIV = 0

CHAR cCAM[6][6] = {'in','out','up','down','left','right'}
CHAR cVTCSrc[2][8] = {'Main','Duo'}

CHAR cVTC_Buff[255]
CHAR cVTC_Resp[255]

LONG lFBArray[] = {100}						//.1 seconds
long lPollTimes[]	=	{3000,3000,3000}

volatile		integer		nPresentationStatus

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

([dvVTC, VTC_PRIVACY_ON],[dvVTC, VTC_PRIVACY_OFF])
([dvVTC,VTC_NR_VID[1]]..[dvVTC,VTC_NR_VID[5]])


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
define_function parse(cMsg[100])
{
	select
	{
		active(find_string(cMsg,"'Audio Microphones Mute:'",1)): 
		{
			remove_string(cMsg,"'Audio Microphones Mute:'",1)
			if(find_string(cMsg,"'On'",1))  on[dvVTC, VTC_PRIVACY_OFF]
			if(find_string(cMsg,"'Off'",1))  on[dvVTC, VTC_PRIVACY_ON]
		}
		active(find_string(cMsg,"'xConfiguration Video MainVideoSource:'",1)):
		{
			remove_string(cMsg,"'xConfiguration Video MainVideoSource:'",1)
			nSrc=atoi(left_string(cMsg,find_string(cMsg,"$0D,$0A",1)))
			on[dvVTC,VTC_NR_VID[nSrc]]
		}
		active(find_string(cMsg,"'Conference Presentation Mode: Off'",1) or find_string(cMsg,"'Conference Presentation Mode: Receiving'",1) or find_string(cMsg,"'PresentationStopResult (status=OK)'",1)):
		{
			off[vdvTP,VTC_GRAPHICS]
			on[vdvTP,VTC_CONTENT_OFF]
			off[vdvTP,VTC_CONTENT_ON]
			off[nPresentationStatus]
		}
		active(find_string(cMsg,"'Conference Presentation Mode: Sending'",1) or find_string(cMsg,"'PresentationStartResult (status=OK)'",1)):
		{
			on[vdvTP,VTC_GRAPHICS]
			on[vdvTP,VTC_CONTENT_ON]
			off[vdvTP,VTC_CONTENT_OFF]
			on[nPresentationStatus]
		}
		active(find_string(cMsg,"'login:'",1)):
		{
			off[nLoggedIn]
			wait 90 send_string dvVTC,"'admin'"
			wait 100 send_string dvVTC,"$0D,$0A"
		}
		active(find_string(cMsg,"'Password:'",1)):
		{
			send_string dvVTC,"'TANDBERG',$0D,$0A"
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

define_function blink_button(nBtn)
{
	on[vdvTP,nBtn]
	wait 5 off[vdvTP,nBtn]
	wait 10 on[vdvTP,nBtn]
	wait 15 off[vdvTP,nBtn]
	wait 20 on[vdvTP,nBtn]
	wait 25 off[vdvTP,nBtn]
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

CREATE_BUFFER dvVTC, cVTC_Buff

TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
timeline_create(tlPoll,lPollTimes,length_array(lPollTimes),timeline_relative,timeline_repeat)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvVTC]
{
	STRING:
	{
		while(find_string(cVTC_Buff,"$0D,$0A",1) or find_string(cVTC_Buff,"'login:'",1))
		{
			if (find_string(cVTC_Buff,"$0D,$0A",1)) parse(remove_string(cVTC_Buff,"$0D,$0A",1))
			else parse(remove_string(cVTC_Buff,"'login:'",1))
		}
	}
}

BUTTON_EVENT [vdvTP, btn_VTC]
{
	PUSH:		
	{
		STACK_VAR INTEGER nBtn
		to[button.input.device,button.input.channel]
		nBtn = GET_LAST(btn_VTC)
		IF (!(nBtn = VTC_CAM_PRESET1 || nBtn = VTC_CAM_PRESET2 || nBtn = VTC_CAM_PRESET3 || 
					nBtn = VTC_CAM_PRESET4 || nBtn = VTC_CAM_PRESET5 || nBtn = VTC_CAM_PRESET6))
		{
			ON[vdvVTC,(GET_LAST(btn_VTC))]
		}
	}
	HOLD[30]:
	{
		STACK_VAR INTEGER nBtn
		nBtn = GET_LAST(btn_VTC)
		IF ((nBtn = VTC_CAM_PRESET1 || nBtn = VTC_CAM_PRESET2 || nBtn = VTC_CAM_PRESET3 || 
					nBtn = VTC_CAM_PRESET4 || nBtn = VTC_CAM_PRESET5 || nBtn = VTC_CAM_PRESET6))
		{
			ON[vdvVTC,(GET_LAST(btn_VTC))]
		}	
	}
	RELEASE:	
	{
		OFF[vdvVTC,(GET_LAST(btn_VTC))]
		SWITCH(GET_LAST(btn_VTC))
		{
			CASE VTC_CAM_PRESET1:
			CASE VTC_CAM_PRESET2:
			CASE VTC_CAM_PRESET3:
			CASE VTC_CAM_PRESET4:
			CASE VTC_CAM_PRESET5:
			CASE VTC_CAM_PRESET6:
			{
				send_string dvVTC,"'xCommand Preset Activate PresetId:',ITOA(get_last(btn_VTC) - (VTC_CAM_PRESET1-1)),$0D,$0A"
			}
		}
	}
}

CHANNEL_EVENT [vdvVTC, 0]
{
	ON:
	{
		STACK_VAR INTEGER nChnl
		nChnl = CHANNEL.CHANNEL
		SWITCH (nChnl)
		{
			CASE VTC_KEY_1:
			CASE VTC_KEY_2:
			CASE VTC_KEY_3:
			CASE VTC_KEY_4:
			CASE VTC_KEY_5:
			CASE VTC_KEY_6:
			CASE VTC_KEY_7:
			CASE VTC_KEY_8:
			CASE VTC_KEY_9:
			{
				SEND_STRING dvVTC, "'xCommand Key Click Key:',ITOA(nChnl-10),' Duration:1',$0D,$0A"
			}
			CASE VTC_KEY_0:   		SEND_STRING dvVTC, "'xCommand Key Click Key:0 Duration:1',$0D,$0A"
			CASE VTC_KEY_STAR:		SEND_STRING dvVTC, "'xCommand Key Click Key:Star Duration:1',$0D,$0A"
			CASE VTC_KEY_POUND:		SEND_STRING dvVTC, "'xCommand Key Click Key:Square Duration:1',$0D,$0A"
			CASE VTC_CONNECT:			SEND_STRING dvVTC, "'xCommand Key Click Key:Call Duration:1',$0D,$0A"
			CASE VTC_DISCONNECT:	SEND_STRING dvVTC, "'xCommand Call DisconnectAll',$0D,$0A"
			CASE VTC_PIP_TOG:			SEND_STRING dvVTC, "'xCommand Key Click Key:Layout Duration:1',$0D,$0A"
			CASE VTC_SELFVIEW_TOG:		SEND_STRING dvVTC, "'xCommand Key Click Key:Selfview Duration:1',$0D,$0A"
			CASE VTC_ADDRESSBOOK:	SEND_STRING dvVTC, "'xCommand Key Click Key:PhoneBook Duration:1',$0D,$0A"
			CASE VTC_PRIVACY_TOG:	
			{
				SEND_STRING dvVTC, "'xCommand Key Click Key:MuteMic Duration:1',$0D,$0A"
				nPriv = !nPriv
			}
			case VTC_PRIVACY_OFF:
			{
				SEND_STRING dvVTC, "'xCommand Audio Microphones UnMute',$0D,$0A"
				send_string dvVTC,"'xStatus Audio Microphones Mute',$0D,$0A"
			}
			case VTC_PRIVACY_ON:
			{
				SEND_STRING dvVTC, "'xCommand Audio Microphones Mute',$0D,$0A"
				send_string dvVTC,"'xStatus Audio Microphones Mute',$0D,$0A"
			}
			CASE VTC_MENU:				SEND_STRING dvVTC, "'xCommand Key Click Key:Ok Duration:1',$0D,$0A"
			CASE VTC_UP:					SEND_STRING dvVTC, "'xCommand Key Click Key:Up Duration:1',$0D,$0A"			
			CASE VTC_DOWN:				SEND_STRING dvVTC, "'xCommand Key Click Key:Down Duration:1',$0D,$0A"
			CASE VTC_LEFT:				SEND_STRING dvVTC, "'xCommand Key Click Key:Left Duration:1',$0D,$0A"
			CASE VTC_RIGHT:				SEND_STRING dvVTC, "'xCommand Key Click Key:Right Duration:1',$0D,$0A"
			CASE VTC_CANCEL:			SEND_STRING dvVTC, "'xCommand Key Click Key:Home Duration:1',$0D,$0A"
			CASE VTC_DELETE:			send_string dvVTC, "'xCommand Key Click Key:C Duration:1',$0D,$0A"
			CASE VTC_OK:				SEND_STRING dvVTC, "'xCommand Key Click Key:Ok Duration:1',$0D,$0A"
			CASE VTC_F1:				SEND_STRING dvVTC, "'xCommand Key Click Key:F1 Duration:1',$0D,$0A"
			CASE VTC_F2:				SEND_STRING dvVTC, "'xCommand Key Click Key:F2 Duration:1',$0D,$0A"
			CASE VTC_F3:				SEND_STRING dvVTC, "'xCommand Key Click Key:F3 Duration:1',$0D,$0A"
			CASE VTC_F4:				SEND_STRING dvVTC, "'xCommand Key Click Key:F4 Duration:1',$0D,$0A"
			CASE VTC_F5:				SEND_STRING dvVTC, "'xCommand Key Click Key:F5 Duration:1',$0D,$0A"
			CASE VTC_WAKE:			send_string dvVTC,"'xCommand Standby Deactivate',$0D,$0A"
			CASE VTC_ZOOM_IN:		SEND_STRING dvVTC,"'xCommand Camera Ramp CameraId:1 Zoom:in ZoomSpeed:14',$0D,$0A"
			CASE VTC_ZOOM_OUT:		SEND_STRING dvVTC,"'xCommand Camera Ramp CameraId:1 Zoom:out ZoomSpeed:14',$0D,$0A"
			CASE VTC_CAM_UP:		SEND_STRING dvVTC,"'xCommand Camera Ramp CameraId:1 Tilt:up TiltSpeed:2',$0D,$0A"
			CASE VTC_CAM_DOWN:		SEND_STRING dvVTC,"'xCommand Camera Ramp CameraId:1 Tilt:down TiltSpeed:2',$0D,$0A"
			CASE VTC_CAM_LEFT: 		SEND_STRING dvVTC,"'xCommand Camera Ramp CameraId:1 Pan:left PanSpeed:2',$0D,$0A"
			CASE VTC_CAM_RIGHT: 	SEND_STRING dvVTC,"'xCommand Camera Ramp CameraId:1 Pan:right PanSpeed:2',$0D,$0A"
			CASE VTC_NR_VID1:
			CASE VTC_NR_VID2:
			CASE VTC_NR_VID3:
			CASE VTC_NR_VID4:			
			CASE VTC_NR_VID5:	
			{
				SEND_STRING dvVTC, "'xConfiguration Video MainVideoSource:',ITOA(nChnl-VTC_NR_VID1+1),$0D"
			}
			CASE VTC_CAM_PRESET1:
			CASE VTC_CAM_PRESET2:
			CASE VTC_CAM_PRESET3:
			CASE VTC_CAM_PRESET4:
			CASE VTC_CAM_PRESET5:
			CASE VTC_CAM_PRESET6:
			{
				SEND_COMMAND vdvTP,'ADBEEP'			
				send_string dvVTC,"'xCommand Preset Store PresetId:',ITOA(nChnl - (VTC_CAM_PRESET1-1)),' Type:Camera Description:"Preset ',ITOA(nChnl - (VTC_CAM_PRESET1-1)),'"',$0D,$0A"
				blink_button(nChnl)
			}
			case VTC_GRAPHICS: 
			{
				switch(nPresentationStatus)
				{
					case 0:	send_string dvVTC,"'xCommand Presentation Start',$0D,$0A"
					case 1:	send_string dvVTC,"'xCommand Presentation Stop',$0D,$0A"
				}
			}
			case VTC_CONTENT_ON: send_string dvVTC,"'xCommand Presentation Start',$0D,$0A"
			case VTC_CONTENT_OFF: send_string dvVTC,"'xCommand Presentation Stop',$0D,$0A"
		}	
  }	
  OFF:
  {
		STACK_VAR INTEGER nChnl
		nChnl = CHANNEL.CHANNEL	
		SWITCH (nChnl)
		{	
			CASE VTC_ZOOM_IN:
			CASE VTC_ZOOM_OUT:		SEND_STRING dvVTC,"'xCommand Camera Ramp CameraId:1 Zoom:stop',$0D,$0A"
			CASE VTC_CAM_UP:
			CASE VTC_CAM_DOWN:		SEND_STRING dvVTC,"'xCommand Camera Ramp CameraId:1 Tilt:stop',$0D,$0A"
			CASE VTC_CAM_LEFT:
			CASE VTC_CAM_RIGHT:		SEND_STRING dvVTC,"'xCommand Camera Ramp CameraId:1 Pan:stop',$0D,$0A"
		}
	}
}

TIMELINE_EVENT[lFB]
{
	[vdvTP, VTC_PRIVACY_TOG] = [dvVTC,VTC_PRIVACY_ON]
	
	[vdvTP, VTC_NR_VID1]		= (nSRC = 1)
	[vdvTP, VTC_NR_VID2] 		= (nSRC = 2)
	[vdvTP, VTC_NR_VID3]		= (nSRC = 3)
	[vdvTP, VTC_NR_VID4] 		= (nSRC = 4)
	[vdvTP, VTC_NR_VID5] 		= (nSRC = 5)
}

timeline_event[tlPoll]
{
	if(nLoggedIn)
	{
		switch(timeline.sequence)
		{
			case 1: send_string dvVTC,"'xConfiguration Video MainVideoSource',$0D,$0A"
			case 2: send_string dvVTC,"'xStatus Audio Microphones Mute',$0D,$0A"
			case 3: send_string dvVTC,"'xStatus Conference Presentation Mode',$0D,$0A"
		}
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
