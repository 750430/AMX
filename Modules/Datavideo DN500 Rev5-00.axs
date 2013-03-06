MODULE_NAME='Datavideo DN500 Rev5-00'(DEV vdvTP[], DEV vdvDevice, DEV dvDevice)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/19/2008  AT: 14:50:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*

define_module 'Datavideo DN500 Rev5-00' DVR1(dvTP_DEV[1],vdvDEV1,dvDVR)


SET BAUD 38400,O,8,1,485 DISABLE'"
RS422

*)

#INCLUDE 'HoppSNAPI Rev5-00.axi'
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

CHAR cCmdStr[10][20]
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

define_function integer calcchecksum(char cMsg[])
{
	stack_var integer nLoop
	stack_var integer nCheckSum
	
	off[nCheckSum]
	for (nLoop=1;nLoop<=length_string(cMsg);nLoop++)
	{
		nCheckSum=((nCheckSum+cMsg[nLoop])& $FF)
	}
	return nCheckSum
}

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nPos
	STACK_VAR CHAR cTemp[10]
	STACK_VAR CHAR cHour[3]
	STACK_VAR CHAR cMins[2]
	STACK_VAR CHAR cSecs[2]
	
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,"'@0TR'",1)):
		{
			REMOVE_STRING(cCompStr,"'@0TR'",1)
			nPos=FIND_STRING(cCompStr,"$0D",1)
			cTemp=GET_BUFFER_STRING(cCompStr,nPos-1)
			SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_TRACK_TXT),',1&2,',cTemp"
		}	
		ACTIVE(FIND_STRING(cCompStr,'@0TI',1)):
		{
			REMOVE_STRING(cCompStr,'@0TI',1)
			nPos=FIND_STRING(cCompStr,"$0D",1)
			cTemp=GET_BUFFER_STRING(cCompStr,nPos-1)
			cHour=(GET_BUFFER_STRING(cTemp,3))
			cMins=(GET_BUFFER_STRING(cTemp,2))
			cSecs=(GET_BUFFER_STRING(cTemp,2))
			SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_COUNTER_TXT),',1&2,',cHour,':',cMins,':',cSecs"
		}
		ACTIVE(FIND_STRING(cCompStr,"'@0STRU'",1) or FIND_STRING(cCompStr,"'@0STRP'",1) or FIND_STRING(cCompStr,"'@0STRE'",1)):
		{
			ON[vdvDevice,DVR_REC_ON]
			on[vdvTP,DVR_REC_ON]
			//send_command vdvTP,"'^TXT-',itoa(DVR_TRACK_TXT),',0,Recording'"
			on[nRecording]
		}
		ACTIVE(FIND_STRING(cCompStr,"'@0ST'",1)):		
		{
			ON[vdvDevice,DVR_REC_OFF]
			//send_command vdvTP,"'^TXT-',itoa(DVR_TRACK_TXT),',0,Idle'"
			off[nRecording]
		}
	}
}

DEFINE_FUNCTION OnPush(INTEGER nIndex)
{
	SEND_STRING dvDevice,"cCmdStr[nIndex]"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

TIMELINE_CREATE(lTLPoll,lArray,length_array(lArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)

cCmdStr[DVR_PLAY]		="$20,$01,calcchecksum("$20,$01")"
cCmdStr[DVR_STOP]		="$20,$00,calcchecksum("$20,$00")"
cCmdStr[DVR_PAUSE]		="$21,$13,$00,calcchecksum("$21,$13,$00")"
cCmdStr[DVR_REC]		="$21,$02,calcchecksum("$20,$02")"
cCmdStr[DVR_NEXT]		="$40,$50,calcchecksum("$40,$50")"
cCmdStr[DVR_BACK]		="$40,$51,calcchecksum("$40,$51")"

cPollStr[PollTime]		="$61,$0C,$01,calcchecksum("$61,$0C,$01")"
cPollStr[PollStatus]	="$61,$20,$03,calcchecksum("$61,$20,$03")"

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
//		WHILE(LENGTH_STRING(cBuff))
//		{
//			SELECT
//			{
//				ACTIVE(FIND_STRING(cBuff,"$0D",1)&& LENGTH_STRING(cHold)):
//				{
//					nPos=FIND_STRING(cBuff,"$0D",1)
//					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
//					Parse(cFullStr)
//					cHold=''
//				}
//				ACTIVE(FIND_STRING(cBuff,"$0D",1)):
//				{
//					nPos=FIND_STRING(cBuff,"$0D",1)
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
TIMELINE_EVENT[lTLPoll]
{
	SEND_STRING dvDevice,"cPollStr[timeline.sequence]"
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
