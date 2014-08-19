module_name='Fake Video Conference Rev6-00'(dev dvTP[], dev vdvVTC, dev vdvVTC_FB, dev dvVTC)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/06/2011  AT: 18:05:27        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                

*)
(***********************************************************)
#include 'HoppSNAPI Rev6-00.axi'

//define_module 'Fake Video Conference Rev6-00' vtc1(dvTP_VTC[1],vdvVTC1,vdvVTC1_FB,dvVTC) 

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

integer 	nActiveSource 
integer 	nPrivacyStatus
integer		nPresentationStatus
integer		nActiveCallStatus

char	 	cKeyPreview[50]

integer 	nButtonHeld



integer 	x

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function blink_button(nBtn)
{
	on[dvTP,nBtn]
	wait 5 off[dvTP,nBtn]
	wait 10 on[dvTP,nBtn]
	wait 15 off[dvTP,nBtn]
	wait 20 on[dvTP,nBtn]
	wait 25 off[dvTP,nBtn]
}

define_function key(char cKey[])
{
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
	
	[dvTP,VTC_CONTENT_TOG] = 	nPresentationStatus
	[dvTP,VTC_CONTENT_ON]	=	nPresentationStatus
	[dvTP,VTC_CONTENT_OFF]	=	!nPresentationStatus
	
	for(x=1;x<=max_length_array(VTC_NR_VID);x++) [dvTP,VTC_NR_VID[x]]=nActiveSource=x
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event



button_event [dvTP, 0]
{
	push:		
	{
		on[button.input]
		switch(button.input.channel)
		{
			case VTC_CAM_UP:
			case VTC_CAM_DOWN:
			case VTC_CAM_LEFT:
			case VTC_CAM_RIGHT:
			case VTC_BACKSPACE:
			{
				//Some buttons should be held
				on[nButtonHeld]
				to[vdvVTC,button.input.channel]
			}
			default:
			{
				//Other buttons only fire on release
			}
		}                    
	}
	hold[3,repeat]:
	{
		switch(button.input.channel)
		{
			case VTC_CAM_PRESET1:
			case VTC_CAM_PRESET2:
			case VTC_CAM_PRESET3:
			case VTC_CAM_PRESET4:
			case VTC_CAM_PRESET5:
			case VTC_CAM_PRESET6:
			{
				if(button.holdtime>=1500)
				{
					if(!nButtonHeld)
					{
						on[nButtonHeld]
						send_command dvTP,"'ABEEP'"
						//Set Camera Preset
					}
				}
			}
			case VTC_BACKSPACE:
			{
				if(button.holdtime>=500)
				{
					on[nButtonHeld]
					backspace()
				}
			}
			default:
			{
				if(button.holdtime>=1500) on[nButtonHeld]
			}
		}   
	}
	RELEASE:	
	{
		if(!nButtonHeld)
		{
			set_pulse_time(1)
			pulse[vdvVTC,button.input.channel]
		}
		off[nButtonHeld]
		off[button.input]
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
			case VTC_KEY_9:
			{
				key(itoa(channel.channel-10))
			}
			case VTC_KEY_0:   		key('0')
			case VTC_KEY_STAR:		key('*')
			case VTC_KEY_POUND:		key('#')
			case VTC_BACKSPACE:			backspace()
			
			case VTC_CONTENT_TOG: 	nPresentationStatus=!nPresentationStatus
			case VTC_CONTENT_ON:	on[nPresentationStatus]
			case VTC_CONTENT_OFF:	off[nPresentationStatus]
			
			case VTC_PRIVACY_TOG:	nPrivacyStatus=!nPrivacyStatus
			case VTC_PRIVACY_OFF:	off[nPrivacyStatus]
			case VTC_PRIVACY_ON:	on[nPrivacyStatus]

			case VTC_DIAL:			
			{
				on[nActiveCallStatus]
			}
			case VTC_HANGUP:		
			{
				off[nActiveCallStatus]
				cKeyPreview=''
				show_phone_number(cKeyPreview)
			}
			case VTC_PIP_TOG:			
			case VTC_SELFVIEW_TOG:		
			case VTC_ADDRESSBOOK:		
			case VTC_MENU:				
			case VTC_UP:				
			case VTC_DOWN:				
			case VTC_LEFT:				
			case VTC_RIGHT:				
			case VTC_CANCEL:			
			case VTC_OK:				
			case VTC_F1:				
			case VTC_F2:				
			case VTC_F3:				
			case VTC_F4:				
			case VTC_F5:				
			case VTC_WAKE:				
			case VTC_ZOOM_IN:			
			case VTC_ZOOM_OUT:			
			case VTC_CAM_UP:			
			case VTC_CAM_DOWN:			
			case VTC_CAM_LEFT: 			
			case VTC_CAM_RIGHT: 		
			{
				//Do Nothing
			}
	
			case VTC_NR_VID1:
			case VTC_NR_VID2:
			case VTC_NR_VID3:
			case VTC_NR_VID4:			
			case VTC_NR_VID5:	
			{
				//Do Nothing
			}
			case VTC_CAM_PRESET1:
			case VTC_CAM_PRESET2:
			case VTC_CAM_PRESET3:
			case VTC_CAM_PRESET4:
			case VTC_CAM_PRESET5:
			case VTC_CAM_PRESET6:
			{
				blink_button(channel.channel)
			}
			
			case VTC_PRES_1:
			case VTC_PRES_2:
			case VTC_PRES_3:
			case VTC_PRES_4:
			case VTC_PRES_5:
			{
				//Do Nothing
			}
		}	
	}	
}



(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

//[dvTP,VTC_PRIVACY_TOG] = 	nPrivacyStatus
//[dvTP,VTC_PRIVACY_ON]	=	nPrivacyStatus
//[dvTP,VTC_PRIVACY_OFF]	=	!nPrivacyStatus
//
//[dvTP,VTC_CONTENT_TOG] = 	nPresentationStatus
//[dvTP,VTC_CONTENT_ON]	=	nPresentationStatus
//[dvTP,VTC_CONTENT_OFF]	=	!nPresentationStatus
//
//for(x=1;x<=max_length_array(VTC_NR_VID);x++) [dvTP,VTC_NR_VID[x]]=nActiveSource=x

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
