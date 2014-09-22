MODULE_NAME='Denon DN-700R Rev5-00'(DEV vdvTP[], DEV vdvDevice, DEV dvDevice)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/19/2008  AT: 14:50:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*

define_module 'Denon DN-700R Rev5-00' DVR1(dvTP_DEV[1],vdvDEV1,dvDVR)

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
long lTLPanel	=	2001

DVR_COUNTER_TTE_TXT = 11
DVR_COUNTER_EE_TXT  = 12
DVR_COUNTER_ER_TXT  = 13
DVR_TRACK_NAME_TXT	= 14

tpStop		=	1
tpPlay		=	2
tpReady		=	3
tpRecord	=	4
tpMonitor	=	5
tpPause		=	6

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

char cCounterTTEText[20]
char cCounterEEText[20]
char cCounterERText[20]
char cTrackNameText[20]

integer nFeedback[NumTPs]

integer nRecording

integer x

LONG lArray[]={333,333,334}
long lPanel[]={1000}
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
	stack_var char cTemp2[30]
	STACK_VAR CHAR cHour[3]
	STACK_VAR CHAR cMins[2]
	STACK_VAR CHAR cSecs[2]
	
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,"'@0Tr'",1)):
		{
			REMOVE_STRING(cCompStr,"'@0Tr'",1)
			nPos=FIND_STRING(cCompStr,"$0D",1)
			cTemp=GET_BUFFER_STRING(cCompStr,nPos-1)
			//SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_TRACK_TXT),',1&2,',cTemp"
			send_string dvDevice,"'@0?tn',cTemp,$0D"
			send_to_panel(DVR_TRACK_TXT,cTemp)
		}	
		ACTIVE(FIND_STRING(cCompStr,"'@0tn/'",1)):
		{
			REMOVE_STRING(cCompStr,"'@0tn/'",1)
			nPos=FIND_STRING(cCompStr,"$0D",1)
			cTemp=GET_BUFFER_STRING(cCompStr,nPos-1)
			//SEND_COMMAND vdvTP,"'^TXT-',ITOA(DVR_TRACK_NAME_TXT),',1&2,',cTemp"
			send_to_panel(DVR_TRACK_NAME_TXT,cTemp)
		}			
		ACTIVE(FIND_STRING(cCompStr,'@0ET',1)):
		{
			REMOVE_STRING(cCompStr,'@0ET',1)
			nPos=FIND_STRING(cCompStr,"$0D",1)
			cTemp=GET_BUFFER_STRING(cCompStr,nPos-1)
			while(length_string(cTemp)>0)
			{
				if(length_string(cTemp2)=0) 
				{
					cTemp2=right_string(cTemp,2)
					set_length_string(cTemp,length_string(cTemp)-2)
				}
				else if(length_string(cTemp)>=2)
				{
					cTemp2="right_string(cTemp,2),':',cTemp2"
					set_length_string(cTemp,length_string(cTemp)-2)
				}
				else 
				{
					cTemp2="cTemp,':',cTemp2"
					set_length_string(cTemp,0)
				}
			}
			cCounterEEText=cTemp2
		}
		ACTIVE(FIND_STRING(cCompStr,'@0RM',1)):
		{
			REMOVE_STRING(cCompStr,'@0RM',1)
			nPos=FIND_STRING(cCompStr,"$0D",1)
			cTemp=GET_BUFFER_STRING(cCompStr,nPos-1)
			while(length_string(cTemp)>0)
			{
				if(length_string(cTemp2)=0) 
				{
					cTemp2=right_string(cTemp,2)
					set_length_string(cTemp,length_string(cTemp)-2)
				}
				else if(length_string(cTemp)>=2)
				{
					cTemp2="right_string(cTemp,2),':',cTemp2"
					set_length_string(cTemp,length_string(cTemp)-2)
				}
				else 
				{
					cTemp2="cTemp,':',cTemp2"
					set_length_string(cTemp,0)
				}
			}
			cCounterERText=cTemp2
		}
		ACTIVE(FIND_STRING(cCompStr,"'@0STRE'",1)):
		{
			//ON[vdvDevice,DVR_REC_ON]
//			on[vdvTP,DVR_REC_ON]
			//send_command vdvTP,"'^TXT-',itoa(DVR_TRACK_TXT),',0,Recording'"
			nRecording=tpRecord
			send_string dvDevice,"'@0?Tr',$0D"
		}
		ACTIVE(FIND_STRING(cCompStr,"'@0STST'",1) or FIND_STRING(cCompStr,"'@0STCE'",1)): nRecording=tpStop
		ACTIVE(FIND_STRING(cCompStr,"'@0STRP'",1)): nRecording=tpReady
		ACTIVE(FIND_STRING(cCompStr,"'@0STPL'",1)): nRecording=tpPlay
		ACTIVE(FIND_STRING(cCompStr,"'@0STPP'",1)): nRecording=tpPause				
	
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
//		case DVR_REC:
//		case DVR_PLAY:
//		{
//			switch(nRecording)
//			{
//				case tpMonitor: SEND_STRING dvDevice,"cCmdStr[DVR_REC_ON]"
//				default: SEND_STRING dvDevice,"cCmdStr[nIndex]"
//			}
//		}
		default:
		{
			
			SEND_STRING dvDevice,"cCmdStr[nIndex]"
		}
	}
	//send_string dvDevice,"cPollStr[PollTrack]"
	//SEND_STRING dvDevice,"cPollStr[PollTransport]"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

TIMELINE_CREATE(lTLPoll,lArray,length_array(lArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
TIMELINE_CREATE(lTLPanel,lPanel,length_array(lPanel),TIMELINE_RELATIVE,TIMELINE_REPEAT)


cCmdStr[DVR_PLAY]		="'@02353',$0D"
cCmdStr[DVR_STOP]		="'@02354',$0D"
cCmdStr[DVR_PAUSE]		="'@02348',$0D"		//There is "Ready to play mode"
cCmdStr[DVR_REC_ON]		="'@02355',$0D"
cCmdStr[DVR_REC]		="'@02355',$0D"
cCmdStr[DVR_NEXT]		="'@02332',$0D"		//Track +
cCmdStr[DVR_BACK]		="'@02333',$0D"		//Track -
cCmdStr[DVR_FWD]		="'@02352',$0D"
cCmdStr[DVR_REW]		="'@02350',$0D"		
cCmdStr[DVR_RIGHT]		="'@023M+',$0D"		//Mark +
cCmdStr[DVR_LEFT]		="'@023M-',$0D"		//Mark -
//cCmdStr[DVR_DN]			="'Transport=Next Folder/Playlist',$0D"
//cCmdStr[DVR_UP]			="'Transport=Prev Folder/Playlist',$0D"
//cCmdStr[DVR_EXIT]		="'Transport=Last Folder/Playlist',$0D"
//cCmdStr[DVR_HOME]		="'Transport=First Folder/Playlist',$0D"

cPollStr[PollCounterTTE]	="'@0?TMOD',$0D"
cPollStr[PollCounterEE]		="'@0?ET',$0D"
cPollStr[PollCounterER]		="'@0?RM',$0D"
cPollStr[PollTrack]			="'@0?Tr',$0D"		//Track #		
cPollStr[PollTransport]		="'@0?ST',$0D"
cPollStr[PollTrackName]		="'Track Name?',$0D"

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
		switch(timeline.sequence)
		{
			case 1: SEND_STRING dvDevice,"cPollStr[PollCounterEE]"
			case 2: if(nRecording<>tpRecord) SEND_STRING dvDevice,"cPollStr[PollCounterER]"
		}
	}
}

timeline_event[lTLPanel]
{
	if(poll_enable()=1)
	{
		send_to_panel(DVR_COUNTER_EE_TXT,cCounterEEText)
		if(nRecording=tpRecord) send_to_panel(DVR_COUNTER_ER_TXT,'0:00:00:00')
		else send_to_panel(DVR_COUNTER_ER_TXT,cCounterERText)
	}
}

CHANNEL_EVENT[vdvDevice,0]
{
	ON:	
	{
		send_string 0,"'2'"
		IF(channel.channel<200) OnPush(channel.channel)
	}
}
BUTTON_EVENT [vdvTP,0]
{
	PUSH:	
	{
		TO[button.input]
		send_string 0,"'1'"
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
[vdvTP,DVR_PAUSE]	=	nRecording=tpReady or nRecording=tpMonitor or nRecording=tpPause
[vdvTP,DVR_REC]		=	nRecording=tpRecord or nRecording=tpReady
[vdvTP,DVR_STOP]	=	nRecording=tpStop

[dvDevice,DVR_PLAY]	=	nRecording=tpPlay or nRecording=tpRecord
[dvDevice,DVR_PAUSE]=	nRecording=tpReady or nRecording=tpMonitor or nRecording=tpPause
[dvDevice,DVR_REC]	=	nRecording=tpRecord or nRecording=tpReady
[dvDevice,DVR_STOP]	=	nRecording=tpStop
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
