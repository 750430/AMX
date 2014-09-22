MODULE_NAME='Wolfvision VZ8 Rev5-00'(DEV vdvTP[], DEV vdvDocCam, DEV dvDocCam)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/13/2008  AT: 09:29:16        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  		                                       *)
(*----------------MODULE INSTRUCTIONS----------------------*)
(*

	define_module 'Wolfvision VZ8 Rev5-00' dev1(dvTP_DEV[1],vdvDEV1,dvDocCam)
	SEND_COMMAND data.device, 'SET BAUD 19200,N,8,1'
	
	
	
	
	
	THIS MODULE IS NOT FULLY FUNCTIONAL
	
	I wrote the code to handle feedback, but on the model I had, feedback wasn't functional.
	Also, the lamp on command ($CC) seems to toggle, not just turn it on.  As a result,
	the Lamp button always toggles, the auto focus button always turns focus on, and focus and zoom controls work.
	Freeze controls don't work.  
	
	
*)
(***********************************************************)

#INCLUDE 'HoppSNAPI Rev5-02.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

tlPoll		=	1

PollFocus	=	1
PollFreeze	=	2
PollLamp	=	3

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

persistent		integer			nAutoFocus
persistent		integer			nFreeze
persistent		integer			nLamp

volatile		long			lPollTimes[]={20000,20000,20000}

volatile		char			cPollStr[4]

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cPollStr[PollFocus]		=	$AD
cPollStr[PollFreeze]	=	$A8
cPollStr[PollLamp]		=	$AC

timeline_create(tlPoll,lPollTimes,length_array(lPollTimes),timeline_relative,timeline_repeat)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvDocCam] 
{ 
	STRING:
	{
//		LOCAL_VAR CHAR cHold[100]
//		LOCAL_VAR CHAR cFullStr[100]
//		STACK_VAR INTEGER nPos	
//	
//		//this accounts for multiple strings in cBuff
//		//or receiving partial string(s) 
//		cBuff = "cBuff,data.text"
//		WHILE(LENGTH_STRING(cBuff))
//		{
//			SELECT
//			{
//				ACTIVE(FIND_STRING(cBuff,"$0A",1)&& LENGTH_STRING(cHold)):
//				{
//					nPos=FIND_STRING(cBuff,"$0A",1)
//					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
//					Parse(cFullStr)
//					cHold=''
//				}
//				ACTIVE(FIND_STRING(cBuff,"$0A",1)):
//				{
//					nPos=FIND_STRING(cBuff,"$0A",1)
//					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
//					Parse(cFullStr)
//				}
//				ACTIVE(1):
//				{
//					cHold="cHold,cBuff"
//					cBuff=''
//				}
//			}
//		}
	}
} 
CHANNEL_EVENT[vdvDocCam,0]
{
	ON:	
	{
		SWITCH(channel.channel)
		{
			case CAM_ZOOM_IN: send_string dvDocCam,"$82"
			case CAM_ZOOM_OUT:send_string dvDocCam,"$81"
			case CAM_FOCUS_IN:send_string dvDocCam,"$84"
			case CAM_FOCUS_OUT:send_string dvDocCam,"$83"
			case CAM_AUTO:
			{
				switch(nAutoFocus)
				{
					case 1: send_string dvDocCam,"$F0"
					case 0: send_string dvDocCam,"$EF"
				}
			}
			case CAM_FREEZE:
			{
				switch(nFreeze)
				{
					case 1: send_string dvDocCam,"$A7"
					case 0: send_string dvDocCam,"$A6"
				}
			}
			case CAM_LAMP:
			{
				switch(nLamp)
				{
					case 1: send_string dvDocCam,"$C8"
					case 0: send_string dvDocCam,"$CC"
				}
			}
		}
	}
	off:
	{
		switch(channel.channel)
		{
			case CAM_ZOOM_IN: 
			case CAM_ZOOM_OUT: send_string dvDocCam,"$80"
			case CAM_FOCUS_IN:
			case CAM_FOCUS_OUT: send_string dvDocCam,"$C3"
		}
	}
}
BUTTON_EVENT [vdvTP,0]
{
	PUSH:	
	{
		TO[button.input]
		to[vdvDocCam,button.input.channel]
		//SEND_STRING 0,"'my chan1 is ',itoa(button.input.channel)"
	}
}

timeline_event[tlPoll]
{
	send_string dvDocCam,"cPollStr[timeline.sequence]"
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

