MODULE_NAME='JVC SR-HD1500US Rev5-00'(DEV vdvTP[], DEV vdvDevice, DEV dvDevice)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/22/2008  AT: 16:42:25        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
DEFINE_MODULE 'JVC SR-HD1500US Rev5-00' DVR1(dvTP_DEV[1],vdvDEV1,dvDVR)
//SEND_COMMAND data.device,"'SET BAUD 9600,O,8,1'"
*)

#INCLUDE 'HoppSNAPI Rev5-06.axi'
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


DEFINE_FUNCTION OnPush(INTEGER nIndex)
{
	SWITCH(nIndex)
	{
		CASE DVR_DVD:
		CASE DVR_VCR:
		{
			SEND_STRING dvDevice,"$F0"
			WAIT 5 SEND_STRING dvDevice,"cCmdStr[nIndex]"
		}
		CASE DVR_REC:
		{
			SEND_STRING dvDevice,"$FA"
			WAIT 5 SEND_STRING dvDevice,"cCmdStr[nIndex]"
		}
		DEFAULT: 	SEND_STRING dvDevice,"cCmdStr[nIndex]"
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
cCmdStr[DVR_DVD]			="$38"
cCmdStr[DVR_VCR]			="$30"
cCmdStr[DVR_OK]			  ="$98"

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT [dvDevice] 
{ 
	STRING:
	{
		SELECT
		{
			ACTIVE(FIND_STRING(data.text,"$02",1)):
			{
				SEND_STRING dvDevice,"$56"
			}
		}
  }
}   
CHANNEL_EVENT[vdvDevice,0]
{
	ON:	IF(channel.channel<200) OnPush(channel.channel)
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
