module_name='Polycom VSX Series Rev5-00'(dev dvTP,dev vdvVTC,dev dvVTC)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/22/2008  AT: 16:51:44        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//SET BAUD 9600,N,8,1
//define_module 'Polycom VSX Series Rev5-00' vtc1(vdvTP_VTC1,vdvVTC1,dvVTC)

#include 'HoppSNAPI Rev5-08.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant
long lFB	 		= 2000 		//Timeline for feedback

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

volatile char cRespStr[10][20]

volatile integer nPrivacy=0
volatile integer nContent=0
volatile char cBuff[255]
volatile	integer		nSetPreset

long lFBArray[] = {1500,1500,1500}						//1 seconds

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvVTC,VTC_PRIVACY_ON],[dvVTC,VTC_PRIVACY_OFF])
([dvTP,VTC_PRIVACY_ON],[dvTP,VTC_PRIVACY_OFF])
([dvTP,VTC_NR_VID1],[dvTP,VTC_NR_VID2])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
define_function SetPrivacy (integer nVal)
{
	if(nVal)
		send_string dvVTC,"'mute near off',$0D"
	else 
		send_string dvVTC,"'mute near on',$0D"
}

define_function OnPush (integer nIndex)
{
	switch(nIndex) 
	{
		case VTC_KEY_0: 			send_string dvVTC, "'button 0',$0D"
		case VTC_KEY_1: 			send_string dvVTC, "'button 1',$0D"
		case VTC_KEY_2: 			send_string dvVTC, "'button 2',$0D"
		case VTC_KEY_3: 			send_string dvVTC, "'button 3',$0D"
		case VTC_KEY_4:				send_string dvVTC, "'button 4',$0D"
		case VTC_KEY_5: 			send_string dvVTC, "'button 5',$0D"
		case VTC_KEY_6: 			send_string dvVTC, "'button 6',$0D"
		case VTC_KEY_7: 			send_string dvVTC, "'button 7',$0D"
		case VTC_KEY_8: 			send_string dvVTC, "'button 8',$0D"
		case VTC_KEY_9:				send_string dvVTC, "'button 9',$0D"
		case VTC_KEY_STAR:			send_string dvVTC,"'button *',$0D"
		case VTC_KEY_POUND:			send_string dvVTC,"'button #',$0D"
		case VTC_KEY_PERIOD: 		send_string dvVTC,"'button period',$0D"
		//case VTC_DELETE: 			send_string dvVTC,"'button delete',$0D"
		case VTC_KEY_KEYBRD: 		send_string dvVTC,"'button keyboard',$0D"
		case VTC_CALLHANGUP: 		send_string dvVTC,"'button callhangup',$0D"
		case VTC_CONNECT: 			send_string dvVTC,"'button call',$0D"
		case VTC_DISCONNECT: 		send_string dvVTC,"'hangup video',$0D"
		case VTC_UP: 				send_string dvVTC,"'button up',$0D"
		case VTC_DOWN: 				send_string dvVTC,"'button down',$0D"
		case VTC_LEFT: 				send_string dvVTC,"'button left',$0D"
		case VTC_RIGHT: 			send_string dvVTC,"'button right',$0D"
		case VTC_ZOOM_IN: 			send_string dvVTC,"'button zoom+',$0D"
		case VTC_ZOOM_OUT: 			send_string dvVTC,"'button zoom-',$0D"
		case VTC_MENU: 				send_string dvVTC,"'button home',$0D"
		case VTC_HOME: 				send_string dvVTC,"'button home',$0D"
		case VTC_ADDRESSBOOK: 		send_string dvVTC,"'button directory',$0D"
		case VTC_INFO: 				send_string dvVTC,"'button help',$0D"
		case VTC_CANCEL: 			send_string dvVTC,"'button back',$0D"
		case VTC_OK: 				send_string dvVTC,"'button select',$0D"
		case VTC_DISPLAY:			send_string dvVTC,"'button display',$0D"
		case VTC_OPTION:			send_string dvVTC,"'button option',$0D"
		case VTC_GRAPHICS: 			
		{
			switch(nContent)
			{
				case 1: send_string dvVTC,"'vcbutton stop',$0D"
				case 0: send_string dvVTC,"'vcbutton play',$0D"
			}
			send_string dvVTC, "'vcbutton get',$0D"
		}
		case VTC_NEAR: 				send_string dvVTC,"'button near',$0D"
		case VTC_FAR: 				send_string dvVTC,"'button far',$0D"
		case VTC_SEND_PC: 			send_string dvVTC,"'vcbutton play',$0D"
		case VTC_STOP_PC: 			send_string dvVTC,"'vcbutton stop',$0D"
		case VTC_NR_VID1:	 		send_string dvVTC,"'camera near 1',$0D"
		case VTC_NR_VID2:			send_string dvVTC,"'camera near 2',$0D"
		case VTC_CONTENT_ON:		send_string dvVTC,"'vcbutton play',$0D"
		case VTC_CONTENT_OFF:		send_string dvVTC,"'vcbutton stop',$0D"
		case VTC_PRIVACY_ON: 		SetPrivacy(0)
		case VTC_PRIVACY_OFF: 		SetPrivacy(1)
		case VTC_PRIVACY_TOG:		SetPrivacy(nPrivacy)
		case VTC_PIP_TOG:
		case VTC_PIP: 				send_string dvVTC,"'button pip',$0D"
		case VTC_PIP_ON: 			send_string dvVTC,"'pip on',$0D"
		case VTC_PIP_OFF: 			send_string dvVTC,"'pip off',$0D"
		case VTC_WAKE: 				send_string dvVTC,"'wake',$0D"
	}
}

define_function Parse(char cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,"'mute near on'",1)): 
		{
			ON[dvVTC,VTC_PRIVACY_ON]
			nPrivacy = 1
		}
		active(find_string(cCompStr,"'mute near off'",1)): 
		{
			ON[dvVTC,VTC_PRIVACY_OFF]
			nPrivacy = 0
		}
		active(find_string(cCompStr,"'vcbutton stop'",1)):
		{
			off[dvTP,VTC_GRAPHICS]
			off[nContent]
		}
		active(find_string(cCompStr,"'vcbutton play'",1)):
		{
			on[dvTP,VTC_GRAPHICS]
			on[nContent]
		}
		active(find_string(cCompStr,"'camera near 1'",1) or find_string(cCompStr,"'camera near source 1'",1)):
		{
			on[dvTP,VTC_NR_VID1]
		}
		active(find_string(cCompStr,"'camera near 2'",1) or find_string(cCompStr,"'camera near source 2'",1)):
		{
			on[dvTP,VTC_NR_VID2]
		}
		active(find_string(cCompStr,"'camera near 4',$0D,$0A",1)):
		{
			send_string dvVTC, "'vcbutton get',$0D"
		}
	}	
	[dvTP,VTC_PRIVACY_TOG]	=([dvVTC,VTC_PRIVACY_ON])
	[dvTP,VTC_PRIVACY_OFF]	=([dvVTC,VTC_PRIVACY_OFF])
	[dvTP,VTC_PRIVACY_ON]	=([dvVTC,VTC_PRIVACY_ON])
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

timeline_create(lFB,lFBArray,3,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvVTC]
{
	string:
	{
		local_var char cHold[100]
		local_var char cFullStr[100]
		stack_var integer nPos	
		//this accounts for multiple strings in XAP_BUFF
		//or receiving partial string(s) 
		cBuff="cBuff,data.text"
		while(length_string(cBuff))
		{
			select
			{
				active(find_string(cBuff,"$0A",1)&& length_string(cHold)):
				{
					nPos=find_string(cBuff,"$0A",1)
					cFullStr="cHold,get_buffer_string(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				active(find_string(cBuff,"$0A",1)):
				{
					nPos=find_string(cBuff,"$0A",1)
					cFullStr=get_buffer_string(cBuff,nPos)
					Parse(cFullStr)
				}
				active(1):
				{
					cHold="cHold,cBuff"
					cBuff=''
				}
			}
		}
	}	
}

channel_event[vdvVTC,0]
{
	on: if(channel.channel<200) OnPush(channel.channel)
}

button_event[dvTP,VTC_DELETE]
{
	push:
	{
		to[button.input]
		send_string dvVTC,"'button delete',$0D"
	}
	hold[2,repeat]:
	{
		if(button.holdtime>15)
		{
			send_string dvVTC,"'button delete',$0D"
		}
	}
}

button_event[dvTP,0]
{
	push:
	{
		stack_var integer nI
		send_string 0,"'push ',itoa(button.input.channel)"
		nI=button.input.channel
		if(nI<>VTC_PRIVACY_TOG && nI<>VTC_PRIVACY_OFF && nI<>VTC_PRIVACY_ON && VTC_GRAPHICS)
		{
			to[button.input.device,button.input.channel]
		}
		select
		{
			active(nI=VTC_CAM_UP): send_string dvVTC,"'camera near move up',$0D"
			active(nI=VTC_CAM_DOWN): send_string dvVTC,"'camera near move down',$0D"
			active(nI=VTC_CAM_LEFT): send_string dvVTC,"'camera near move left',$0D"
			active(nI=VTC_CAM_RIGHT): send_string dvVTC,"'camera near move right',$0D"
			active(nI=VTC_ZOOM_IN): send_string dvVTC,"'camera near move zoom+',$0D"
			active(nI=VTC_ZOOM_OUT): send_string dvVTC,"'camera near move zoom-',$0D"
			active(nI=VTC_CAM_PRESET1 or nI=VTC_CAM_PRESET2 or nI=VTC_CAM_PRESET3 or nI=VTC_CAM_PRESET4 or nI=VTC_CAM_PRESET5 or nI=VTC_CAM_PRESET6):{(*do nothing*)}
			active(1): OnPush(nI)   
		}
	}
	hold[20]:
	{
		send_string 0,"'hold ',itoa(button.input.channel)"
		switch(button.input.channel)
		{
			case VTC_CAM_PRESET1:
			case VTC_CAM_PRESET2:
			case VTC_CAM_PRESET3:
			case VTC_CAM_PRESET4:
			case VTC_CAM_PRESET5:
			case VTC_CAM_PRESET6:
			{
				on[nSetPreset]        
				send_command button.input.device,"'ADBEEP'"
				send_string dvVTC,"'preset near set ',itoa(button.input.channel-VTC_CAM_PRESET1+1),$0D"
			}
		}
	}
	release:
	{
		stack_var integer nI
		send_string 0,"'release ',itoa(button.input.channel)"
		nI=button.input.channel
		switch(nI)
		{
			case VTC_CAM_UP:
			case VTC_CAM_DOWN:
			case VTC_CAM_LEFT:
			case VTC_CAM_RIGHT:
			case VTC_ZOOM_IN:
			case VTC_ZOOM_OUT:send_string dvVTC,"'camera near move stop',$0D"
			case VTC_CAM_PRESET1:
			case VTC_CAM_PRESET2:
			case VTC_CAM_PRESET3:
			case VTC_CAM_PRESET4:
			case VTC_CAM_PRESET5:
			case VTC_CAM_PRESET6:
			{
				if(!nSetPreset) send_string dvVTC,"'preset near go ',itoa(button.input.channel-VTC_CAM_PRESET1+1),$0D"
				else off[nSetPreset]
			}
		}
	}
}

timeline_event[lFB]
{
	switch(timeline.sequence)
	{
		case 1: send_string dvVTC, "'mute near get',$0D"
		case 2: send_string dvVTC, "'vcbutton get',$0D"
		case 3: send_string dvVTC, "'camera near source',$0D"
	}
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program
[dvTP,VTC_GRAPHICS]=nContent
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

