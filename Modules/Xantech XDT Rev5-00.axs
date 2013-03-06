MODULE_NAME='Xantech XDT Rev5-00'(DEV dvTP[], dev vdvXantech, DEV dvXantech, INTEGER nTuner)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
//SET BAUD 19200,N,8,1 485 DISABLE
//define_module 'Xantech XDT Rev5-00' radio1(vdvTP_DEV[1],vdvDEV1,dvXantech,nTuner)
#INCLUDE 'HoppSNAPI Rev5-01.axi'
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
LONG lFB	 		= 2000 		//Timeline for feedback
long lPoll			=	2001

integer nButtons[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50}
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
LONG lFBArray[] = {300}						//.3 seconds
long lPollArray[]={1000}					//1 seconds

volatile		integer		nActiveBand
volatile		char		cActiveFrequency[4]
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

define_function parse(char cCompStr[100])
{
	if(find_string(cCompStr,"'T',itoa(nTuner)",1))
	{	
		remove_string(cCompStr,"'T',itoa(nTuner)",1)
		remove_string(cCompStr,"'B'",1)
		nActiveBand=atoi(left_string(cCompStr,1))
		remove_string(cCompStr,"'F'",1)
		cActiveFrequency=left_string(cCompStr,4)
		switch(nActiveBand)
		{
			case 1: send_command dvTP,"'^TXT-1,0,',cActiveFrequency"
			case 2: send_command dvTP,"'^TXT-1,0,',left_string(cActiveFrequency,3),'.',right_string(cActiveFrequency,1)"
		}
	}
}

define_function tp_fb()
{
	[dvTP,RADIO_AM]=nActiveBand=1
	[dvTP,RADIO_FM]=nActiveBand=2
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
TIMELINE_CREATE(lPoll,lPollArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvXantech]
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

TIMELINE_EVENT[lFB]
{
	tp_fb()
}

timeline_event[lPoll]
{
	if(nTuner=1) send_string dvXantech,"'Q3',$0D"
}

channel_event[vdvXantech,0]
{
	on:
	{
		switch(channel.channel)
		{
			case RADIO_AM: send_string dvXantech,"'T',itoa(nTuner),'B1',$0D"
			case RADIO_FM: send_string dvXantech,"'T',itoa(nTuner),'B2',$0D"
			case RADIO_PRESET_1:
			case RADIO_PRESET_2:
			case RADIO_PRESET_3:
			case RADIO_PRESET_4:
			case RADIO_PRESET_5:
			case RADIO_PRESET_6: 
			{
				SEND_STRING dvXantech,"'T',itoa(nTuner),'L0',itoa(channel.channel-RADIO_PRESET_1+1),$0D"
				off[dvTP,channel.channel]
			}
			case RADIO_SEEK_UP: send_string dvXantech,"'T',itoa(nTuner),'A1',$0D"
			case RADIO_SEEK_DOWN: send_string dvXantech,"'T',itoa(nTuner),'A0',$0D"
			case RADIO_STEP_UP: send_string dvXantech,"'T',itoa(nTuner),'M1',$0D"
			case RADIO_STEP_DOWN: send_string dvXantech,"'T',itoa(nTuner),'M0',$0D"
		}
	}
}

button_event[dvTP,nButtons]
{
	PUSH:		
	{
		STACK_VAR INTEGER nBtn
		to[button.input]
		nBtn = get_last(nButtons)
		IF (!(nBtn = RADIO_PRESET_1 || nBtn = RADIO_PRESET_2 || nBtn = RADIO_PRESET_3 || 
					nBtn = RADIO_PRESET_4 || nBtn = RADIO_PRESET_5 || nBtn = RADIO_PRESET_6))
		{
			ON[vdvXantech,nBtn]
		}
	}
	HOLD[30]:
	{
		STACK_VAR INTEGER nBtn
		nBtn = get_last(nButtons)
		send_string 0,"'1',itoa(nBtn)"
		IF ((nBtn = RADIO_PRESET_1 || nBtn = RADIO_PRESET_2 || nBtn = RADIO_PRESET_3 || 
					nBtn = RADIO_PRESET_4 || nBtn = RADIO_PRESET_5 || nBtn = RADIO_PRESET_6))
		{
			ON[vdvXantech,nBtn]
		}	
	}
	RELEASE:	
	{
		OFF[vdvXantech,get_last(nButtons)]
		SWITCH(get_last(nButtons))
		{
			CASE RADIO_PRESET_1:
			CASE RADIO_PRESET_2:
			CASE RADIO_PRESET_3:
			CASE RADIO_PRESET_4:
			CASE RADIO_PRESET_5:
			CASE RADIO_PRESET_6:
			{                
				SEND_STRING dvXantech,"'T',itoa(nTuner),'P0',itoa(button.input.channel-RADIO_PRESET_1+1),$0D"
			}
		}
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


