MODULE_NAME='Tascam HD1 Rev5-00'(DEV vdvTP[], DEV vdvDevice, DEV dvDevice)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/19/2008  AT: 14:50:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*

define_module 'Tascam HD1 Rev5-00' DVR1(dvTP_DEV[1],vdvDEV1,dvDVR)

data_event[dvMarantz]
{
	online:
	{
		send_command data.device,"'SET BAUD 9600,N,8,1,485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSON'"
	}
}


In order to see feedback on the touchpanel, you must have the touchpanel push button 240 (DVR_FB_ON).  This prevents spamming with tons of data when nobody is looking.

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

NumTPs			=	10

PollCounterTTE 	= 1
PollCounterEE	= 2
PollCounterER	= 3
PollTrack		=	4
PollTransport	=	5
PollTrackName	=	6
LONG lTLPoll 	= 2000

DVR_COUNTER_TTE_TXT = 11
DVR_COUNTER_EE_TXT  = 12
DVR_COUNTER_ER_TXT  = 13
DVR_TRACK_NAME_TXT	= 14

tpStop		=	1
tpPlay		=	2
tpReady		=	3
tpRecord	=	4
tpMonitor	=	5

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

CHAR cCmdStr[51][35]
CHAR cPollStr[6][25]

integer nFeedback[NumTPs]

integer nRecording

integer x

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
	STACK_VAR CHAR cTemp[30]
	STACK_VAR CHAR cHour[3]
	STACK_VAR CHAR cMins[2]
	STACK_VAR CHAR cSecs[2]
	
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,"'Current Track Number='",1)):
		{
			REMOVE_STRING(cCompStr,"'Current Track Number='",1)
			nPos=FIND_STRING(cCompStr,"$0D",1)
			cTemp=GET_BUFFER_STRING(cCompStr,nPos-1)
			//SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_TRACK_TXT),',1&2,',cTemp"
			send_to_panel(DVR_TRACK_TXT,cTemp)
		}	
		ACTIVE(FIND_STRING(cCompStr,"'Track Name='",1)):
		{
			REMOVE_STRING(cCompStr,"'Track Name='",1)
			nPos=FIND_STRING(cCompStr,"$0D",1)
			cTemp=GET_BUFFER_STRING(cCompStr,nPos-1)
			//SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_TRACK_NAME_TXT),',1&2,',cTemp"
			send_to_panel(DVR_TRACK_NAME_TXT,cTemp)
		}			
		ACTIVE(FIND_STRING(cCompStr,'Total Time Elapsed=',1)):
		{
			REMOVE_STRING(cCompStr,'Total Time Elapsed=',1)
			nPos=FIND_STRING(cCompStr,"$0D",1)
			cTemp=GET_BUFFER_STRING(cCompStr,nPos-1)
//			cHour=(GET_BUFFER_STRING(cTemp,3))
//			cMins=(GET_BUFFER_STRING(cTemp,2))
//			cSecs=(GET_BUFFER_STRING(cTemp,2))
//			SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_COUNTER_TXT),',1&2,',cHour,':',cMins,':',cSecs"
			//SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_COUNTER_TTE_TXT),',1&2,',cTemp"
			send_to_panel(DVR_COUNTER_TTE_TXT,cTemp)
		}
		ACTIVE(FIND_STRING(cCompStr,'Event Elapsed=',1)):
		{
			REMOVE_STRING(cCompStr,'Event Elapsed=',1)
			nPos=FIND_STRING(cCompStr,"$0D",1)
			cTemp=GET_BUFFER_STRING(cCompStr,nPos-1)
//			cHour=(GET_BUFFER_STRING(cTemp,3))
//			cMins=(GET_BUFFER_STRING(cTemp,2))
//			cSecs=(GET_BUFFER_STRING(cTemp,2))
//			SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_COUNTER_TXT),',1&2,',cHour,':',cMins,':',cSecs"
			//SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_COUNTER_EE_TXT),',1&2,',cTemp"
			send_to_panel(DVR_COUNTER_EE_TXT,cTemp)
		}
		ACTIVE(FIND_STRING(cCompStr,'Event Remaining=',1)):
		{
			REMOVE_STRING(cCompStr,'Event Remaining=',1)
			nPos=FIND_STRING(cCompStr,"$0D",1)
			cTemp=GET_BUFFER_STRING(cCompStr,nPos-1)
//			cHour=(GET_BUFFER_STRING(cTemp,3))
//			cMins=(GET_BUFFER_STRING(cTemp,2))
//			cSecs=(GET_BUFFER_STRING(cTemp,2))
//			SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_COUNTER_TXT),',1&2,',cHour,':',cMins,':',cSecs"
			//SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_COUNTER_ER_TXT),',1&2,',cTemp"
			send_to_panel(DVR_COUNTER_ER_TXT,cTemp)
		}
		ACTIVE(FIND_STRING(cCompStr,"'Transport=Record'",1)):
		{
			//ON[vdvDevice,DVR_REC_ON]
//			on[vdvTP,DVR_REC_ON]
			//send_command vdvTP,"'^TXT-',itoa(DVR_TRACK_TXT),',0,Recording'"
			nRecording=tpRecord
		}
		ACTIVE(FIND_STRING(cCompStr,"'Transport=Stop'",1)): nRecording=tpStop
		ACTIVE(FIND_STRING(cCompStr,"'Transport=Ready'",1)): nRecording=tpReady
		ACTIVE(FIND_STRING(cCompStr,"'Transport=Play'",1)): nRecording=tpPlay
		ACTIVE(FIND_STRING(cCompStr,"'Transport=Monitor'",1)): nRecording=tpMonitor				
	
	}
}

define_function send_to_panel(integer nBtn, char cString[255])
{
	for(x=1;x<=NumTPs;x++) 
	{
		if(nFeedback[x]) SEND_COMMAND vdvTP[x],"'^TXT-',itoa(nBtn),',1&2,',cString"
	}
}

define_function integer poll_enable()
{
	stack_var integer NumPanelsOn
	NumPanelsOn=0
	for(x=1;x<=NumTPs;x++) if(nFeedback[x]) NumPanelsOn++
	if(NumPanelsOn>0) return 1
	else return 0
}

DEFINE_FUNCTION OnPush(INTEGER nIndex)
{
	switch(nIndex)
	{
		case DVR_REC:
		case DVR_PLAY:
		{
			switch(nRecording)
			{
				case tpMonitor: SEND_STRING dvDevice,"cCmdStr[DVR_REC_ON]"
				default: SEND_STRING dvDevice,"cCmdStr[nIndex]"
			}
		}
		default:
		{
			SEND_STRING dvDevice,"cCmdStr[nIndex]"
		}
	}
	send_string dvDevice,"cPollStr[PollTrack]"
	SEND_STRING dvDevice,"cPollStr[PollTransport]"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

TIMELINE_CREATE(lTLPoll,lArray,length_array(lArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)


cCmdStr[DVR_PLAY]		="'Transport=Play',$0D,$0A"
cCmdStr[DVR_STOP]		="'Transport=Stop',$0D,$0A"
cCmdStr[DVR_PAUSE]		="'Transport=Ready',$0D,$0A"		//There is "Ready to play mode"
cCmdStr[DVR_REC_ON]		="'Transport=Record',$0D,$0A"
cCmdStr[DVR_REC]		="'Transport=Monitor',$0D,$0A"
cCmdStr[DVR_NEXT]		="'Transport=Last Track',$0D,$0A"
cCmdStr[DVR_BACK]		="'Transport=First Track',$0D,$0A"
cCmdStr[DVR_FWD]		="'Transport=Next Track',$0D,$0A"
cCmdStr[DVR_REW]		="'Transport=Prev Track',$0D,$0A"
cCmdStr[DVR_RIGHT]		="'Transport=Next Track/Marker',$0D,$0A"
cCmdStr[DVR_LEFT]		="'Transport=Prev Track/Marker',$0D,$0A"
cCmdStr[DVR_DN]			="'Transport=Next Folder/Playlist',$0D,$0A"
cCmdStr[DVR_UP]			="'Transport=Prev Folder/Playlist',$0D,$0A"
cCmdStr[DVR_EXIT]		="'Transport=Last Folder/Playlist',$0D,$0A"
cCmdStr[DVR_HOME]		="'Transport=First Folder/Playlist',$0D,$0A"

cPollStr[PollCounterTTE]	="'Total Time Elapsed?',$0D,$0A"
cPollStr[PollCounterEE]		="'Event Elapsed?',$0D,$0A"
cPollStr[PollCounterER]		="'Event Remaining?',$0D,$0A"
cPollStr[PollTrack]			="'Current Track Number?',$0D,$0A"
cPollStr[PollTransport]		="'Transport?',$0D,$0A"
cPollStr[PollTrackName]		="'Track Name?',$0D,$0A"

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
	if(poll_enable()=1)
	{
		select
		{
			active(timeline.sequence=1):
			{
				SEND_STRING dvDevice,"'Login=hdr1',$0D,$0A"
				SEND_STRING dvDevice,"cPollStr[PollTrack]"
				SEND_STRING dvDevice,"cPollStr[PollTrackName]"
				SEND_STRING dvDevice,"cPollStr[PollTransport]"
			}
			active(1):
			{
				SEND_STRING dvDevice,"cPollStr[PollCounterTTE]"
				SEND_STRING dvDevice,"cPollStr[PollCounterEE]"
				SEND_STRING dvDevice,"cPollStr[PollCounterER]"
				if(nRecording=tpPlay) 
				{
					SEND_STRING dvDevice,"cPollStr[PollTrack]"
					SEND_STRING dvDevice,"cPollStr[PollTrackName]"
				}
			}
		}
	}
}
CHANNEL_EVENT[vdvDevice,0]
{
	ON:	
	{
		IF(channel.channel<200) OnPush(channel.channel)
	}
}
BUTTON_EVENT [vdvTP,0]
{
	PUSH:	
	{
		TO[button.input]
		switch(button.input.channel)
		{
			case DVR_FB_ON: on[nFeedback[get_last(vdvTP)]]
			case DVR_FB_OFF: off[nFeedback[get_last(vdvTP)]]
			default: ON[vdvDevice,button.input.channel]	
		}
		
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
[vdvTP,DVR_PLAY]	=	nRecording=tpPlay or nRecording=tpRecord
[vdvTP,DVR_PAUSE]	=	nRecording=tpReady or nRecording=tpMonitor
[vdvTP,DVR_REC]		=	nRecording=tpRecord or nRecording=tpMonitor
[vdvTP,DVR_STOP]	=	nRecording=tpStop

[dvDevice,DVR_PLAY]	=	nRecording=tpPlay or nRecording=tpRecord
[dvDevice,DVR_PAUSE]=	nRecording=tpReady or nRecording=tpMonitor
[dvDevice,DVR_REC]	=	nRecording=tpRecord or nRecording=tpMonitor
[dvDevice,DVR_STOP]	=	nRecording=tpStop
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
