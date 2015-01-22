module_name='Polycom VSX Series Rev4-00'(dev vdvTP,dev vdvVTC,dev dvVTC)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/22/2008  AT: 16:51:44        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//SET BAUD 9600,N,8,1
//define_module 'Polycom VSX Series Rev4-00' vtc1(vdvTP_VTC1,vdvVTC1,dvVTC)

#include 'HoppSNAPI Rev4-01.axi'

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

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([vdvVTC,VTC_PRIVACY_ON_FB],[vdvVTC,VTC_PRIVACY_OFF_FB])
([vdvTP,VTC_PRIVACY_ON],[vdvTP,VTC_PRIVACY_OFF])
([vdvTP,VTC_NR_VID1],[vdvTP,VTC_NR_VID2])

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
		case VTC_GRAPHICS: 			
		{
			switch(nContent)
			{
				case 1: send_string dvVTC,"'vcbutton stop',$0D"
				case 0: send_string dvVTC,"'vcbutton play',$0D"
			}
		}
		case VTC_NEAR: 				send_string dvVTC,"'button near',$0D"
		case VTC_FAR: 				send_string dvVTC,"'button far',$0D"
		case VTC_SEND_PC: 			send_string dvVTC,"'vcbutton play',$0D"
		case VTC_STOP_PC: 			send_string dvVTC,"'vcbutton stop',$0D"
		case VTC_NR_VID1:	 		send_string dvVTC,"'camera near 1',$0D"
		case VTC_NR_VID2:			send_string dvVTC,"'camera near 2',$0D"
		case VTC_CONTENT_ON:		send_string dvVTC,"'vcbutton play',$0D"
		case VTC_CONTENT_OFF:		send_string dvVTC,"'vcbutton stop',$0D"
		case VTC_PRIVACY_ON: 		SetPrivacy(1)
		case VTC_PRIVACY_OFF: 		SetPrivacy(0)
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
			ON[vdvVTC,VTC_PRIVACY_ON_FB]
			nPrivacy = 1
		}
		active(find_string(cCompStr,"'mute near off'",1)): 
		{
			ON[vdvVTC,VTC_PRIVACY_OFF_FB]
			nPrivacy = 0
		}
		active(find_string(cCompStr,"'vcbutton stop'",1)):
		{
			off[vdvTP,VTC_GRAPHICS]
			off[nContent]
		}
		active(find_string(cCompStr,"'vcbutton play'",1)):
		{
			on[vdvTP,VTC_GRAPHICS]
			on[nContent]
		}
		active(find_string(cCompStr,"'camera near 1'",1) or find_string(cCompStr,"'camera near source 1'",1)):
		{
			on[vdvTP,VTC_NR_VID1]
		}
		active(find_string(cCompStr,"'camera near 2'",1) or find_string(cCompStr,"'camera near source 2'",1)):
		{
			on[vdvTP,VTC_NR_VID2]
		}
		active(find_string(cCompStr,"'camera near 4',$0D,$0A",1)):
		{
			send_string dvVTC, "'vcbutton get',$0D"
		}
	}	
	[vdvTP,VTC_GRAPHICS]=nContent
	[vdvTP,VTC_PRIVACY_TOG]	=([vdvVTC,VTC_PRIVACY_ON_FB])
	[vdvTP,VTC_PRIVACY_OFF]	=([vdvVTC,VTC_PRIVACY_OFF_FB])
	[vdvTP,VTC_PRIVACY_ON]	=([vdvVTC,VTC_PRIVACY_ON_FB])
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

button_event[vdvTP,VTC_DELETE]
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

button_event[vdvTP,btn_VTC]
{
	push:
	{
		stack_var integer nI
		send_string 0,"'push ',itoa(button.input.channel)"
		nI=button.input.channel
		if(nI<>VTC_PRIVACY_TOG && nI<>VTC_PRIVACY_OFF && nI<>VTC_PRIVACY_ON)
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
		switch(get_last(btn_VTC))
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

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

