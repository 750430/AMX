MODULE_NAME='Marantz DVR Rev5-00'(DEV vdvTP[], DEV vdvDevice, DEV dvDevice)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/19/2008  AT: 14:50:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*

define_module 'Marantz DVR Rev5-00' DVR1(dvTP_DEV[1],vdvDEV1,dvDVR)

data_event[dvMarantz]
{
	online:
	{
		send_command data.device,"'SET BAUD 9600,N,8,1,485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSON'"
	}
}

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

PollCounter 	=	1
PollTrack		=	2
PollStatus		=	3
LONG lTLPoll 	= 2000

stRecord		=	1
stRecordPause	=	2
stStop			=	3
stPlay			=	4
stPause			=	5
stOther			=	6
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

INTEGER nPanelBtn[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}
CHAR cBuff[255]

CHAR cCmdStr[10][20]
CHAR cPollStr[4][10]

integer nRecording
integer nDeckStatus

LONG lArray[]={500,500,500,500,500,500,500,500,500,500}
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
		ACTIVE(FIND_STRING(cCompStr,"'@0STRU'",1)): nDeckStatus=stRecord
		ACTIVE(FIND_STRING(cCompStr,"'@0STRP'",1)): nDeckStatus=stRecordPause
		ACTIVE(FIND_STRING(cCompStr,"'@0STRE'",1)): nDeckStatus=stRecord
		ACTIVE(FIND_STRING(cCompStr,"'@0STST'",1)): nDeckStatus=stStop
		ACTIVE(FIND_STRING(cCompStr,"'@0STTS'",1)): nDeckStatus=stStop
		ACTIVE(FIND_STRING(cCompStr,"'@0STPL'",1)): nDeckStatus=stPlay
		ACTIVE(FIND_STRING(cCompStr,"'@0STPP'",1)): nDeckStatus=stPause
		ACTIVE(FIND_STRING(cCompStr,"'@0STS+'",1)): nDeckStatus=stPlay
		ACTIVE(FIND_STRING(cCompStr,"'@0STS-'",1)): nDeckStatus=stPlay
		ACTIVE(FIND_STRING(cCompStr,"'@0STFF'",1)): nDeckStatus=stPlay
		ACTIVE(FIND_STRING(cCompStr,"'@0STRW'",1)): nDeckStatus=stPlay
		ACTIVE(FIND_STRING(cCompStr,"'@0STAB'",1)): nDeckStatus=stPlay
		ACTIVE(FIND_STRING(cCompStr,"'@0STEP'",1)): nDeckStatus=stPlay
		ACTIVE(FIND_STRING(cCompStr,"'@0STEA'",1)): nDeckStatus=stPlay
		ACTIVE(FIND_STRING(cCompStr,"'@0STED'",1)): nDeckStatus=stPlay
		ACTIVE(FIND_STRING(cCompStr,"'@0STER'",1)): nDeckStatus=stOther
		ACTIVE(FIND_STRING(cCompStr,"'@0ST'",1)): nDeckStatus=stOther
	}
	switch(nDeckStatus)
	{
		case stRecord: send_command vdvTP,"'^TXT-1,0,Recording in Progress'"
		case stRecordPause: send_command vdvTP,"'^TXT-1,0,Recording Paused - Press Record to Resume'"
		case stStop: send_command vdvTP,"'^TXT-1,0,Recorder Idle'"
		case stPlay: send_command vdvTP,"'^TXT-1,0,Playing . . .'"
		case stPause: send_command vdvTP,"'^TXT-1,0,Recorder Paused'"
		case stOther: send_command vdvTP,"'^TXT-1,0,'"
	}
}

DEFINE_FUNCTION OnPush(INTEGER nIndex)
{
	SEND_STRING dvDevice,"cCmdStr[nIndex]"
	SEND_STRING dvDevice,"cPollStr[PollStatus]"
	send_string dvDevice,"cPollStr[PollTrack]"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

TIMELINE_CREATE(lTLPoll,lArray,length_array(lArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)

cCmdStr[DVR_PLAY]		="'@02353',$0D"
cCmdStr[DVR_STOP]		="'@02354',$0D"
cCmdStr[DVR_PAUSE]		="'@02348',$0D"
cCmdStr[DVR_REC]		="'@02355',$0D"
cCmdStr[DVR_NEXT]		="'@02332',$0D"
cCmdStr[DVR_BACK]		= "'@02333',$0D"
cCmdStr[DVR_PWR_ON]		="'@023PW',$0D"

cPollStr[PollCounter]	="'@0?TI',$0D"
cPollStr[PollTrack]		="'@0?TR',$0D"
cPollStr[PollStatus]	="'@0?ST',$0D"

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
				ACTIVE(FIND_STRING(cBuff,"$0D",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0D",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0D",1)):
				{
					nPos=FIND_STRING(cBuff,"$0D",1)
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
	select
	{
		active(timeline.sequence=1):
		{
			SEND_STRING dvDevice,"cPollStr[PollTrack]"
			SEND_STRING dvDevice,"cPollStr[PollStatus]"
		}
		active(1):
		{
			SEND_STRING dvDevice,"cPollStr[PollCounter]"
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
		ON[vdvDevice,GET_LAST(nPanelBtn)]	
	}
	RELEASE: OFF[vdvDevice,GET_LAST(nPanelBtn)]
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM


[vdvTP,DVR_REC_ON]=nDeckStatus=stRecord
[vdvTP,DVR_REC]=(nDeckStatus=stRecord or nDeckStatus=stRecordPause)
[vdvTP,DVR_PLAY]=nDeckStatus=stPlay
[vdvTP,DVR_PAUSE]=(nDeckStatus=stPause or nDeckStatus=stRecordPause)
[vdvTP,DVR_STOP]=nDeckStatus=stStop
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
