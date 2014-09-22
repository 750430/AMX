MODULE_NAME='Panasonic TH-65PF11UK Rev5-00'(dev dvTP, dev vdvPlas, dev dvPlas)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 07/25/2008  AT: 10:46:24        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
//define_module 'Panasonic TH-65PF11UK Rev5-00' disp1(vdvTP_DISP1,vdvDISP1,dvPlasma)
//Set baud to 9600,N,8,1

(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002

PollPwr 	= 1
PollSrc		= 2

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {5100,5100}
LONG lCmdArray[]				=	{510,510}

INTEGER nPollType = 0

CHAR cCmdStr[35][20]	
CHAR cPollStr[4][20]

INTEGER nCmd=0
INTEGER nPlasBtns[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
										21,22,23,24,25,26,27,28,29,30}

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvPlas,VD_PWR_ON],[dvPlas,VD_PWR_OFF])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION CmdExecuted()
{
	ncmd=0
	TIMELINE_KILL(lTLCmd)
	TIMELINE_RESTART(lTLPoll)
}
DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nVar
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_PWR_ON],1)):
		{
			ON[dvPlas,VD_PWR_ON]
			ON[dvTP,VD_PWR_ON]
			IF(nCmd=VD_PWR_ON) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_PWR_OFF],1)):
		{
			ON[dvPlas,VD_PWR_OFF]
			ON[dvTP,VD_PWR_OFF]
			IF(nCmd=VD_PWR_OFF) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,"$02,'IMS',$03",1)):
		{
			IF(nCmd=VD_SRC_RGB1)
			{
				ON[dvPlas,VD_SRC_RGB1]
				ON[dvTP,VD_SRC_RGB1]
				CmdExecuted()					
			}
			IF(nCmd=VD_SRC_CMPNT1)
			{
				ON[dvPlas,VD_SRC_CMPNT1]
				ON[dvTP,VD_SRC_CMPNT1]
				CmdExecuted()					
			}
			IF(nCmd=VD_SRC_VID1)
			{
				ON[dvPlas,VD_SRC_VID1]
				ON[dvTP,VD_SRC_VID1]
				CmdExecuted()					
			}
			IF(nCmd=VD_SRC_VID2)
			{
				ON[dvPlas,VD_SRC_VID2]
				ON[dvTP,VD_SRC_VID2]
				CmdExecuted()
			}
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		= "$02,'PON',$03" 			
cCmdStr[VD_PWR_OFF]		= "$02,'POF',$03"
cCmdStr[VD_SRC_RGB1]	= "$02,'IMS:PC1',$03"
cCmdStr[VD_SRC_AUX1]	= "$02,'IMS:SL1',$03"
cCmdStr[VD_SRC_VID2]	= "$02,'IMS:SL1A',$03"
cCmdStr[VD_SRC_VID1]	= "$02,'IMS:SL2A',$03"
cCmdStr[VD_SRC_CMPNT1]	= "$02,'IMS:SL3',$03"
cCmdStr[VD_PCADJ] 		= "$02,'DAM:SELF',$03"

cPollStr[PollPwr] = ""
cPollStr[PollSrc] = ""

WAIT 200
{
	IF(!TIMELINE_ACTIVE(lTLPoll))
	{
		TIMELINE_CREATE(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
	}
}
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvPlas]
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
				ACTIVE(FIND_STRING(cBuff,"$03",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$03",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$03",1)):
				{
					nPos=FIND_STRING(cBuff,"$03",1)
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
	nPollType=TIMELINE.SEQUENCE
	SEND_STRING dvPlas,"cPollStr[TIMELINE.SEQUENCE]"
}

TIMELINE_EVENT[lTLCmd]
{
	SWITCH(TIMELINE.SEQUENCE)
	{
		CASE 1:	//first time
		{
			SWITCH(nCmd)
			{
				CASE VD_PWR_ON:
				CASE VD_PWR_OFF:
				{
					SEND_STRING dvPlas,cCmdStr[nCmd]
					nPollType=1
				}
				CASE VD_SRC_RGB1:
				CASE VD_SRC_CMPNT1:
				CASE VD_SRC_VID1:
				CASE VD_SRC_VID2:
				CASE VD_SRC_AUX1:
				CASE VD_SRC_AUX2:
				CASE VD_SRC_AUX3:
				{
					IF([dvPlas,VD_PWR_ON])
					{
						SEND_STRING dvPlas,cCmdStr[nCmd]
						nPollType=PollSrc
					}
					ELSE
					{
						SEND_STRING dvPlas,cCmdStr[VD_PWR_ON]
						nPollType=PollPwr
					}
				}
				CASE VD_ASPECT1:
				CASE VD_ASPECT2:
				CASE VD_PCADJ:
				{
					IF([dvPlas,VD_PWR_ON]) 
					{
						SEND_STRING dvPlas,cCmdStr[nCmd]
					}
					CmdExecuted()
				}
			}
		}
		CASE 2:	//2nd time
		{
			IF(nPollType) SEND_STRING dvPlas,cPollStr[nPollType]
		}
	}
}
CHANNEL_EVENT[vdvPlas,nPlasBtns]
{
	ON:
	{
		IF(channel.channel<200)
		{
			nCmd=channel.channel
			TIMELINE_PAUSE(lTLPoll)
			WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
		}
		ELSE IF(channel.channel=VD_POLL_BEGIN)
		{
			TIMELINE_CREATE(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
		}
	}
}
BUTTON_EVENT[dvTP,nPlasBtns]
{
	PUSH:
	{
		to[button.input]
		PULSE[vdvPlas,button.input.channel]
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

