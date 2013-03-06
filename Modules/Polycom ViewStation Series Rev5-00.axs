module_name='Polycom ViewStation Series Rev5-00'(dev dvTP,dev vdvVTC,dev dvVTC)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/18/2012  AT: 03:55:47        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//SET BAUD 9600,N,8,1
//define_module 'Polycom ViewStation Series Rev5-00' vtc1(vdvTP_VTC1,vdvVTC1,dvVTC)

#include 'HoppSNAPI Rev5-00.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant
long lFB	 		= 2000 		//Timeline for feedback
long lQueue			= 2001


VTC_PWR_ON	=	1
VTC_PWR_OFF	=	2

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

volatile char cRespStr[10][20]

volatile integer nPrivacy=0
volatile integer nContent=0
volatile char cBuff[255]
volatile	integer		nSetPreset

volatile char cQueue[30][30]
volatile integer nNumCmds

volatile	integer nButton

volatile integer x

long lFBArray[] = {1500,1500,1500}						//1 seconds
non_volatile	long		lQueueTimes[]={100}


//ON/OFF commands to look for:
//SEND_STRING dvVTC,"'listen sleep',$0D"


//SEND_STRING dvVTC,"'listen wake',$0D"


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
		add_to_queue("'mute near off',$0D")
	else 
		add_to_queue("'mute near on',$0D")
}

define_function OnPush (integer nIndex)
{
	switch(nIndex) 
	{
		case VTC_KEY_0: 			add_to_queue("'button 0',$0D")
		case VTC_KEY_1: 			add_to_queue("'button 1',$0D")
		case VTC_KEY_2: 			add_to_queue("'button 2',$0D")
		case VTC_KEY_3: 			add_to_queue("'button 3',$0D")
		case VTC_KEY_4:				add_to_queue("'button 4',$0D")
		case VTC_KEY_5: 			add_to_queue("'button 5',$0D")
		case VTC_KEY_6: 			add_to_queue("'button 6',$0D")
		case VTC_KEY_7: 			add_to_queue("'button 7',$0D")
		case VTC_KEY_8: 			add_to_queue("'button 8',$0D")
		case VTC_KEY_9:				add_to_queue("'button 9',$0D")
		case VTC_KEY_STAR:			add_to_queue("'button *',$0D")
		case VTC_KEY_POUND:			add_to_queue("'button #',$0D")
		case VTC_KEY_PERIOD: 		add_to_queue("'button period',$0D")
		//case VTC_DELETE: 			add_to_queue("'button delete',$0D")
		case VTC_KEY_KEYBRD: 		add_to_queue("'button keyboard',$0D")
		case VTC_CALLHANGUP: 		add_to_queue("'button callhangup',$0D")
		case VTC_CONNECT: 			add_to_queue("'button call',$0D")
		case VTC_DISCONNECT: 		add_to_queue("'hangup video',$0D")
		case VTC_UP: 				add_to_queue("'button up',$0D")
		case VTC_DOWN: 				add_to_queue("'button down',$0D")
		case VTC_LEFT: 				add_to_queue("'button left',$0D")
		case VTC_RIGHT: 			add_to_queue("'button right',$0D")
		case VTC_ZOOM_IN: 			add_to_queue("'button zoom+',$0D")
		case VTC_ZOOM_OUT: 			add_to_queue("'button zoom-',$0D")
		case VTC_MENU: 				add_to_queue("'button home',$0D")
		case VTC_HOME: 				add_to_queue("'button home',$0D")
		case VTC_ADDRESSBOOK: 		
		{
			add_to_queue("'button '")
			add_to_queue("'directory',$0D")
		}
		case VTC_INFO: 				add_to_queue("'button help',$0D")
		case VTC_CANCEL: 			add_to_queue("'button back',$0D")
		case VTC_OK: 				add_to_queue("'button select',$0D")
		case VTC_GRAPHICS: 			
		{
			switch(nContent)
			{
				case 1: add_to_queue("'displaygraphics off',$0D")
				case 0: add_to_queue("'displaygraphics on',$0D")
			}
		}
		case VTC_NEAR: 				add_to_queue("'button near',$0D")
		case VTC_FAR: 				add_to_queue("'button far',$0D")
		case VTC_SEND_PC: 			add_to_queue("'displaygraphics on',$0D")
		case VTC_STOP_PC: 			add_to_queue("'displaygraphics off',$0D")
		case VTC_NR_VID1:	 		
		{
			add_to_queue("'camera near'")
			add_to_queue("' 1',$0D")
		}
		case VTC_NR_VID2:
		{
			add_to_queue("'camera near'")
			add_to_queue("' 2',$0D")
		}
		case VTC_CONTENT_ON:		add_to_queue("'displaygraphics on',$0D")
		case VTC_CONTENT_OFF:		add_to_queue("'displaygraphics off',$0D")
		case VTC_PRIVACY_ON: 		SetPrivacy(1)
		case VTC_PRIVACY_OFF: 		SetPrivacy(0)
		case VTC_PRIVACY_TOG:		
		{
			add_to_queue("'mute near '")
			add_to_queue("'tog',$0D")
		}
		case VTC_PIP_TOG:
		case VTC_PIP: 				add_to_queue("'button pip',$0D")
		case VTC_PIP_ON: 			add_to_queue("'pip on',$0D")
		case VTC_PIP_OFF: 			add_to_queue("'pip off',$0D")
		case VTC_WAKE: 				add_to_queue("'wake',$0D")
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
		active(find_string(cCompStr,"'mute near on'",1)): 
		{
			ON[dvVTC,VTC_PRIVACY_ON]
			nPrivacy = 1
		}
		
		
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
	[dvTP,VTC_GRAPHICS]=nContent

}

define_function add_to_queue(char c[])
{
	nNumCmds++
	cQueue[nNumCmds]=c
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

timeline_create(lFB,lFBArray,3,TIMELINE_RELATIVE,TIMELINE_REPEAT)
timeline_create(lQueue,lQueueTimes,length_array(lQueueTimes),TIMELINE_RELATIVE,TIMELINE_REPEAT)
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
		add_to_queue("'button delete',$0D")
	}
	hold[2,repeat]:
	{
		if(button.holdtime>15)
		{
			add_to_queue("'button delete',$0D")
		}
	}
}

button_event[dvTP,VTC_CAM_PRESET1]
button_event[dvTP,VTC_CAM_PRESET2]
button_event[dvTP,VTC_CAM_PRESET3]
button_event[dvTP,VTC_CAM_PRESET4]
button_event[dvTP,VTC_CAM_PRESET5]
button_event[dvTP,VTC_CAM_PRESET6]
{
	push:
	{
		to[button.input]
		send_string 0,"'push ',itoa(button.input.channel)"
	}
	hold[20]:
	{
		send_string 0,"'hold ',itoa(button.input.channel)"
		switch(nButton)
		{
			case VTC_CAM_PRESET1:
			case VTC_CAM_PRESET2:
			case VTC_CAM_PRESET3:
			case VTC_CAM_PRESET4:
			case VTC_CAM_PRESET5:
			case VTC_CAM_PRESET6:
			{
				on[nSetPreset]        
				send_command dvTP,"'ADBEEP'"
				add_to_queue("'preset near '")
				add_to_queue("'set ',itoa(nButton-VTC_CAM_PRESET1+1),$0D")
			}
		}
	}	
	release:
	{
		send_string 0,"'release ',itoa(button.input.channel)"
		switch(button.input.channel)
		{
			case VTC_CAM_PRESET1:
			case VTC_CAM_PRESET2:
			case VTC_CAM_PRESET3:
			case VTC_CAM_PRESET4:
			case VTC_CAM_PRESET5:
			case VTC_CAM_PRESET6:
			{
				if(!nSetPreset) 
				{
					add_to_queue("'preset near '")
					add_to_queue("'go ',itoa(button.input.channel-VTC_CAM_PRESET1+1),$0D")
				}
				else off[nSetPreset]
			}
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
		nButton=nI
		to[button.input.device,button.input.channel]
		select
		{
			active(nI=VTC_CAM_UP): add_to_queue("'camera near '")
			active(nI=VTC_CAM_DOWN): add_to_queue("'camera near '")
			active(nI=VTC_CAM_LEFT): add_to_queue("'camera near '")
			active(nI=VTC_CAM_RIGHT):add_to_queue("'camera near '")
			active(nI=VTC_ZOOM_IN): add_to_queue("'camera near '")
			active(nI=VTC_ZOOM_OUT):add_to_queue("'camera near '")
			active(nI=VTC_CAM_PRESET1 or nI=VTC_CAM_PRESET2 or nI=VTC_CAM_PRESET3 or nI=VTC_CAM_PRESET4 or nI=VTC_CAM_PRESET5 or nI=VTC_CAM_PRESET6):{(*do nothing*)}
			active(1): OnPush(nI)   
		}
		select
		{
			active(nI=VTC_CAM_UP): add_to_queue("'move up',$0D")
			active(nI=VTC_CAM_DOWN): add_to_queue("'move down',$0D")
			active(nI=VTC_CAM_LEFT): add_to_queue("'move left',$0D")
			active(nI=VTC_CAM_RIGHT): add_to_queue("'move right',$0D")
			active(nI=VTC_ZOOM_IN): add_to_queue("'move zoom+',$0D")
			active(nI=VTC_ZOOM_OUT): add_to_queue("'move zoom-',$0D")
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
			case VTC_ZOOM_OUT:
			{
				add_to_queue("'camera near '")
				add_to_queue("'move stop',$0D")
			}
		}
	}
}

timeline_event[lQueue]
{
	if (nNumCmds)
	{
		send_string dvVTC,"cQueue[1]"
		for(x=1;x<=nNumCmds;x++) cQueue[x]=cQueue[x+1]
		cQueue[nNumCmds]=''
		nNumCmds--
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

