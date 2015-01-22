MODULE_NAME='Marantz DV7110 Rev4-00'(DEV vdvTP[], DEV vdvDevice, DEV dvDevice)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/22/2008  AT: 16:42:25        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
define_module 'Marantz DV7110 Rev4-00' DVR1(dvTP_DEV[1],vdvDEV1,dvDVR)
//SEND_COMMAND data.device,"'SET BAUD 9600,O,8,1'"

*)

#INCLUDE 'HoppSNAPI Rev4-01.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

CHAR cCmdStr[200][5]

(**********************************************************)
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

cCmdStr[DVR_PLAY]			="'@1C1',$0D"
cCmdStr[DVR_STOP]			="'@1C0',$0D"
cCmdStr[DVR_PAUSE]			="'@1C6',$0D"
cCmdStr[DVR_NEXT]			="'@1C2',$0D"
cCmdStr[DVR_BACK]			="'@1C3',$0D"
cCmdStr[DVR_REW]			="'@1C5',$0D"
cCmdStr[DVR_FWD] 			="'@1C4',$0D"
cCmdStr[DVR_PWR_ON]			="'@1A1',$0D"
cCmdStr[DVR_PWR_OFF]		="'@1A0',$0D"
cCmdStr[DVR_DISC_MENU]		="'@1G1',$0D"
cCmdStr[DVR_UP]				="'@1I3',$0D"
cCmdStr[DVR_DN]				="'@1I4',$0D"
cCmdStr[DVR_RIGHT]			="'@1I6',$0D"
cCmdStr[DVR_LEFT]  			="'@1I5',$0D"
cCmdStr[DVR_OK]			  	="'@1I7',$0D"

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT


CHANNEL_EVENT[vdvDevice,0]
{
	ON:	IF(channel.channel<200) SEND_STRING dvDevice,"cCmdStr[channel.channel]"
}
BUTTON_EVENT [vdvTP,0]
{
	PUSH:	
	{
		TO[button.input.device,button.input.channel]
		to[vdvDevice,button.input.channel]	
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
