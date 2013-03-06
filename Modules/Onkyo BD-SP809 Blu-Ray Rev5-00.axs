MODULE_NAME='Onkyo BD-SP809 Blu-Ray Rev5-00'(DEV vdvTP[], DEV vdvDevice, DEV dvDevice)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/20/2008  AT: 16:42:25        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
define_module 'Onkyo BD-SP809 Blu-Ray Rev5-00' dvr1(dvTP_DEV[1],vdvDEV1,dvBluray)
SEND_COMMAND data.device,"'SET BAUD 9600,N,8,1'"

*)

#INCLUDE 'HoppSNAPI Rev5-08.axi'
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

volatile	integer		x
volatile	integer		nPlayStatus
(**********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

//([vdvTP,DVR_PLAY],[vdvTP,DVR_STOP],[vdvTP,DVR_PAUSE])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function parse(char cMsg[])
{
	remove_string(cMsg,"'!7'",1)
	select
	{
		active(left_string(cMsg,3)='SST'):
		{
			remove_string(cMsg,'SST',1)
			switch(left_string(cMsg,2))
			{
				case '00':
				case '03': nPlayStatus=DVR_STOP
				case '01': nPlayStatus=DVR_PLAY
				case '02': nPlayStatus=DVR_PAUSE
			}
		}
	}
}

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



(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[DVR_PLAY]		="'!7PLYUP',$0D,$0A"
cCmdStr[DVR_STOP]		="'!7STP',$0D,$0A"
cCmdStr[DVR_PAUSE]		="'!7PAS',$0D,$0A"
cCmdStr[DVR_NEXT]		="'!7SKPUP',$0D,$0A"
cCmdStr[DVR_BACK]		="'!7SKPDN',$0D,$0A"
cCmdStr[DVR_FWD]		="'!7SCNUP',$0D,$0A"
cCmdStr[DVR_REW] 		="'!7SCNDN',$0D,$0A"
cCmdStr[DVR_PWR_ON]		="'!7PWR01',$0D,$0A"
cCmdStr[DVR_PWR_OFF]	="'!7PWR00',$0D,$0A"
cCmdStr[DVR_DISC_MENU]  ="'!7MNU',$0D,$0A"
cCmdStr[DVR_UP]			="'!7OSDUP',$0D,$0A"
cCmdStr[DVR_DN]			="'!7OSDDN',$0D,$0A"
cCmdStr[DVR_LEFT]  		="'!7OSDLF',$0D,$0A"
cCmdStr[DVR_RIGHT]		="'!7OSDRH',$0D,$0A"
cCmdStr[DVR_OK]			="'!7ENT',$0D,$0A"
cCmdStr[DVR_EXIT]		="'!7RET',$0D,$0A"
cCmdStr[DVR_HOME]		="'!7HOM',$0D,$0A"


wait 200 send_string dvDevice,"'!7PMS01',$0D,$0A" //This registers to receive notices from the device when the play status changes
                       
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvDevice]
{
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cFullStr[100]
		LOCAL_VAR CHAR cBuff[255]
		STACK_VAR INTEGER nPos	
		
		cBuff = "cBuff,data.text"
		WHILE(LENGTH_STRING(cBuff))
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cBuff,"$1A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$1A",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$1A",1)):
				{
					nPos=FIND_STRING(cBuff,"$1A",1)
					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
					Parse(cFullStr)
				}
				ACTIVE(1):
				{
					cHold="cHold,cBuff"
					cBuff=''
				}
			}
		}	
	}
}

CHANNEL_EVENT[vdvDevice,0]
{
	ON:	
	{
		IF(channel.channel<200) send_string dvDevice,cCmdStr[channel.channel]
		if(channel.channel=DVR_PLAY) send_string dvDevice,"'!7PMS01',$0D,$0A" //Register to receive status updates
	}
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

[vdvTP,DVR_PLAY]=nPlayStatus=DVR_PLAY
[vdvTP,DVR_PAUSE]=nPlayStatus=DVR_PAUSE
[vdvTP,DVR_STOP]=nPlayStatus=DVR_STOP

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
