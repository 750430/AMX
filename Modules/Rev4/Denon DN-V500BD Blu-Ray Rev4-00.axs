MODULE_NAME='Denon DN-V500BD Blu-Ray Rev4-00'(DEV vdvTP[], DEV vdvDevice, DEV dvDevice)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/20/2008  AT: 16:42:25        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
define_module 'Denon DN-V500BD Blu-Ray Rev4-00' dvr1(dvTP_DEV[1],vdvDEV1,dvBluray)
SEND_COMMAND data.device,"'SET BAUD 9600,N,8,1'"

*)

#INCLUDE 'HoppSNAPI Rev4-00.axi'
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

INTEGER nPanelBtn[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
										21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,
										39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,
										57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,
										75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,
										93,94,95,96,97,98,99,100,101,102,203,104,105,106,107,
										108,109,110,111,112,113,114,115,116,117,118,119,120,121,
										122,123,124,125,126,127,128,129,130,131,132,133,134,135,
										136,137,138,139,140,141,142,143,144,145,146,147,148,149,
										150,151,152,153,154,155,156,157,158,159,160,161,162,163}

CHAR cCmdStr[200][16]

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


//DEFINE_FUNCTION OnPush(INTEGER nIndex)
//{
//	SWITCH(nIndex)
//	{
//		CASE DVR_DVD:
//		CASE DVR_VCR:
//		{
//			SEND_STRING dvDevice,"$F0"
//			WAIT 5 SEND_STRING dvDevice,"cCmdStr[nIndex]"
//		}
//		CASE DVR_REC:
//		{
//			SEND_STRING dvDevice,"$FA"
//			WAIT 5 SEND_STRING dvDevice,"cCmdStr[nIndex]"
//		}
//		DEFAULT: 	send_to_bluray(cCmdStr[nIndex])
//	}
//}


DEFINE_FUNCTION send_to_bluray(INTEGER nArgBtn)
{
    STACK_VAR CHAR sMyTemp[7]
    sMyTemp = "cCmdStr[nArgBtn],$03"
    send_string dvDevice,"$02,cCmdStr[nArgBtn],$03,fnDenon3800CheckSum(sMyTemp)"
}
DEFINE_FUNCTION CHAR[2] fnDenon3800CheckSum(CHAR sArgString[])
{
    STACK_VAR CHAR sMyFirst
    STACK_VAR CHAR sMySecond
    STACK_VAR CHAR sMyTotal
    STACK_VAR CHAR sMyReturn[2]
    sMyTotal = sArgString[1]+sArgString[2]+sArgString[3]+sArgString[4]+sArgString[5]+sArgString[6]+sArgString[7]
    IF(((sMyTotal BAND $F0) RSHIFT 4)<=$09)
    {
	sMyFirst = TYPE_CAST((sMyTotal BAND $F0) RSHIFT 4) + $30
    }
    ELSE
    {
	sMyFirst = TYPE_CAST((sMyTotal BAND $F0) RSHIFT 4) + $37
    }
    IF((sMyTotal BAND $0F)<=$09) // ASCII number
    {
	sMySecond = (sMyTotal BAND $0F) + $30
    }
    ELSE // ASCII letter
    {
	sMySecond = (sMyTotal BAND $0F) + $37
    }
    sMyReturn = "sMyFirst,sMySecond"
    RETURN sMyReturn;
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[DVR_PLAY]		="$40,$00,$00,$00,$00,$00"
cCmdStr[DVR_STOP]		="$41,$00,$00,$00,$00,$00"
cCmdStr[DVR_PAUSE]		="$42,$00,$00,$00,$00,$00"
cCmdStr[DVR_NEXT]		="$43,$2B,$00,$00,$00,$00"
cCmdStr[DVR_BACK]		="$43,$2D,$00,$00,$00,$00"
cCmdStr[DVR_FWD]		="$44,$2B,$00,$00,$00,$00"
cCmdStr[DVR_REW] 		="$44,$2D,$00,$00,$00,$00"
cCmdStr[DVR_PWR_ON]		="$20,$00,$00,$00,$00,$00"
cCmdStr[DVR_PWR_OFF]	="$21,$00,$00,$00,$00,$00"
cCmdStr[DVR_DISC_MENU]  ="$47,$00,$00,$00,$00,$00"
cCmdStr[DVR_UP]			="$4D,$32,$00,$00,$00,$00"
cCmdStr[DVR_DN]			="$4D,$34,$00,$00,$00,$00"
cCmdStr[DVR_RIGHT]		="$4D,$33,$00,$00,$00,$00"
cCmdStr[DVR_LEFT]  		="$4D,$31,$00,$00,$00,$00"
cCmdStr[DVR_OK]			="$4E,$00,$00,$00,$00,$00"

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

CHANNEL_EVENT[vdvDevice,0]
{
	ON:	IF(channel.channel<200) send_to_bluray(channel.channel)
}
BUTTON_EVENT [vdvTP,nPanelBtn]
{
	PUSH:	
	{
		TO[button.input.device,button.input.channel]
		ON[vdvDevice,button.input.channel]	
	}
	RELEASE: 
	{
		OFF[vdvDevice,button.input.channel]
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
