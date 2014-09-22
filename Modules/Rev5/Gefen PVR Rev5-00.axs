MODULE_NAME='Gefen PVR Rev5-00'(DEV vdvTP[], DEV vdvDevice, DEV dvDevice)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/19/2008  AT: 14:50:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*

define_module 'Gefen PVR Rev5-00' DVR1(dvTP_DEV[1],vdvDEV1,dvDVR)


SET BAUD 115200,N,8,1,485 DISABLE'"


*)

#INCLUDE 'HoppSNAPI Rev5-09.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

PollTime 	= 1
PollStatus	=	2
LONG lTLPoll 	= 2000
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

CHAR cBuff[255]

CHAR cCmdStr[118][20]
CHAR cPollStr[4][10]

integer nRecording

LONG lArray[]={1000,1000}
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvDevice,DVR_REC_ON],[dvDevice,DVR_REC_OFF])
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,"'== Start record =='",1)):
		{
			send_text('Recording Started')
		}
		active(find_string(cCompStr,"'HMSG_WT61P7_IR_STOP'",1)):
		{
			send_text('Recording Stopped')
		}
	}
}

DEFINE_FUNCTION OnPush(INTEGER nIndex)
{
	SEND_STRING dvDevice,"cCmdStr[nIndex]"
}

define_function send_text(cMsg[100])
{
	send_string 0,"'cMsg=',cMsg"
	send_command vdvTP,"'^TXT-1,0,',cMsg"
	wait 100 send_command vdvTP,"'^TXT-1,0,'"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

TIMELINE_CREATE(lTLPoll,lArray,length_array(lArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)

cCmdStr[DVR_PLAY]		="'t app 0x61771011',$0D,$0A"
cCmdStr[DVR_STOP]		="'t app 0x61771010',$0D,$0A"
cCmdStr[DVR_REC]		="'t app 0xfffe000e',$0D,$0A"
cCmdStr[DVR_SETUP]		="'t app 0x61773000',$0D,$0A"
cCmdStr[DVR_UP]			="'t app 0xfffe0000',$0D,$0A"
cCmdStr[DVR_DN]			="'t app 0xfffe0001',$0D,$0A"
cCmdStr[DVR_LEFT]		="'t app 0xfffe0002',$0D,$0A"
cCmdStr[DVR_RIGHT]		="'t app 0xfffe0003',$0D,$0A"
cCmdStr[DVR_OK]			="'t app 0xfffe0011',$0D,$0A"

//cPollStr[PollTime]		="$61,$0C,$01,calcchecksum("$61,$0C,$01")"
//cPollStr[PollStatus]	="$61,$20,$03,calcchecksum("$61,$20,$03")"

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT [dvDevice] 
{ 
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cFullStr[100]
		STACK_VAR INTEGER nPos	
	
		//this accounts for multiple strings in cBuff
		//or receiving partial string(s) 
		cBuff = "cBuff,data.text"
		WHILE(LENGTH_STRING(cBuff))
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cBuff,"$0A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0A",1)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
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
TIMELINE_EVENT[lTLPoll]
{
	//SEND_STRING dvDevice,"cPollStr[timeline.sequence]"
}
CHANNEL_EVENT[vdvDevice,0]
{
	ON:	IF(channel.channel<200) OnPush(channel.channel)
}
BUTTON_EVENT [vdvTP,0]
{
	PUSH:	
	{
		TO[button.input]
		ON[vdvDevice,button.input.channel]	
	}
	RELEASE: OFF[vdvDevice,button.input.channel]
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM
[vdvTP,DVR_REC_ON]=nRecording
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
