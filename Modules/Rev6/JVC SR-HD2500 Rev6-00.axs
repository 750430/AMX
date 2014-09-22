module_name='JVC SR-HD2500 Rev6-00'(dev dvTP[], dev vdvDeck, dev vdvDeck_FB, dev dvDeck)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/22/2008  AT: 16:42:25        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
define_module 'JVC SR-HD2500 Rev6-00' DVR1(dvTP_DEV[1],vdvDEV1,vdvDEV1_FB,dvDVR)
//SEND_COMMAND data.device,"'SET BAUD 9600,O,8,1'"
*)

#include 'HoppSNAPI Rev6-00.axi'
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

CHAR cCmdStr[60][5]



(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)


define_function OnPush(integer nIndex)
{
	switch(nIndex)
	{
		case DVR_REC:
		{
			send_string dvDeck,"$FA"
			wait 5 send_string dvDeck,"cCmdStr[nIndex]"
		}
		default: 	send_string dvDeck,"cCmdStr[nIndex]"
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[DVR_PLAY]			="$3A"
cCmdStr[DVR_STOP]			="$3F"
cCmdStr[DVR_PAUSE]		="$4F"
cCmdStr[DVR_REC]			="$CA"
cCmdStr[DVR_NEXT]			="$95"
cCmdStr[DVR_BACK]			="$96"
cCmdStr[DVR_REW]			="$AC"
cCmdStr[DVR_FWD] 			="$AB"
cCmdStr[DVR_PWR_ON]		="$A0"
cCmdStr[DVR_PWR_OFF]	="$A1"
cCmdStr[DVR_DISC_MENU]="$93"
cCmdStr[DVR_UP]				="$99"
cCmdStr[DVR_DN]				="$9A"
cCmdStr[DVR_RIGHT]		="$9B"
cCmdStr[DVR_LEFT]  		="$9C"
cCmdStr[DVR_OK]			  ="$98"

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event [dvDeck] 
{ 
	string:
	{
		select
		{
			active(find_string(data.text,"$02",1)):
			{
				send_string dvDeck,"$56"
			}
		}
  }
}   

channel_event[vdvDeck,0]
{
	on:	if(channel.channel<200) OnPush(channel.channel)
}

button_event[dvTP,0]
{
	push:	
	{
		to[button.input]
		on[vdvDeck,button.input.channel]	
	}
	release: 
	{
		off[vdvDeck,button.input.channel]
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
