MODULE_NAME='Sharp LCD LC52E77U Rev4-00'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:26:22        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*  


	define_module 'Sharp LCD LC52E77U Rev4-00' lcd1(vdvTP_DISP1,vdvDISP1,dvLCD1)
	
	Set Baud to 9600,N,8,1,485 DISABLE

*)

#INCLUDE 'HoppSNAPI Rev4-01.axi'
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
LONG lCmdArray[]				=	{1110,1110}

INTEGER nPollType = 0
integer x
integer nNumPanels

CHAR cCmdStr[34][20]	
CHAR cPollStr[4][20]

INTEGER nCmd=0

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvTP,VD_SRC_VGA1],[dvTP,VD_SRC_CMPNT1],[vdvLCD,VD_SRC_AUX1],[vdvLCD,VD_SRC_AUX2])
 
([vdvLCD,VD_PWR_ON_FB],[vdvLCD,VD_PWR_OFF_FB])
([vdvLCD,VD_SRC_VGA1_FB],[vdvLCD,VD_SRC_CMPNT1_FB],[vdvLCD,VD_SRC_AUX1_FB],[vdvLCD,VD_SRC_AUX2_FB])
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
	
	SWITCH(nPollType)
	{
		CASE PollPwr:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)||FIND_STRING(cCompStr,"'2'",1)):
				{
					ON[vdvLCD,VD_PWR_ON_FB]
					ON[dvTP,VD_PWR_ON]
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'0'",1)):
				{
					ON[vdvLCD,VD_PWR_OFF_FB]
					ON[dvTP,VD_PWR_OFF]
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}
			}	
		}
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'4'",1)):
				{
					ON[vdvLCD,VD_SRC_VGA1_FB]
					ON[dvTP,VD_SRC_VGA1]
					IF(nCmd=VD_SRC_VGA1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					ON[vdvLCD,VD_SRC_CMPNT1_FB]
					ON[dvTP,VD_SRC_CMPNT1]
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'7'",1)):
				{
					ON[vdvLCD,VD_SRC_AUX1_FB]
					ON[dvTP,VD_SRC_AUX1]
					IF(nCmd=VD_SRC_AUX1) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'ERR'",1)):
				{
					if([vdvLCD,VD_PWR_ON_FB]) 
					{
						on[vdvLCD,VD_SRC_AUX2_FB]
						on[dvTP,VD_SRC_AUX2]
						if(nCmd=VD_SRC_AUX2) CmdExecuted()
					}
				}
			}
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		= "'POWR1   ',$0D" 			
cCmdStr[VD_PWR_OFF]		= "'POWR0   ',$0D"
cCmdStr[VD_SRC_VGA1]	= "'IAVD4   ',$0D"	//vga port
cCmdStr[VD_SRC_CMPNT1]	= "'IAVD2   ',$0D"	//component
cCmdStr[VD_SRC_AUX1]	= "'IAVD7   ',$0D"  //hdmi
cCmdStr[VD_SRC_AUX2]	= "'ITVD0   ',$0D"
        
cPollStr[PollPwr]			=	"'POWR????',$0D"		
cPollStr[PollSrc]			=	"'IAVD????',$0D"					

nNumPanels=length_array(dvTP)

WAIT 200
{
	send_string dvLCD,"'RSPW1   ',$0D"
	IF(!TIMELINE_ACTIVE(lTLPoll))
		TIMELINE_CREATE(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvLCD]
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
TIMELINE_EVENT[lTLPoll]
{
	nPollType=TIMELINE.SEQUENCE
	SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE]"
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
					SEND_STRING dvLCD,cCmdStr[nCmd]
					nPollType=1
				}
				CASE VD_SRC_CMPNT1:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_AUX1:
				CASE VD_SRC_AUX2:
				{
					IF([vdvLCD,VD_PWR_ON_FB])
					{
						SEND_STRING dvLCD,cCmdStr[nCmd]
						nPollType=PollSrc
					}
					ELSE
					{
						SEND_STRING dvLCD,cCmdStr[VD_PWR_ON]
						nPollType=PollPwr
					}
				}
			}
		}
		CASE 2:	//2nd time
		{
			IF(nPollType) SEND_STRING dvLCD,cPollStr[nPollType]
		}
	}
}
CHANNEL_EVENT[vdvLCD,0]
{
	ON:
	{
		SELECT
		{
			ACTIVE(channel.channel<200):
			{
				nCmd=channel.channel
				TIMELINE_PAUSE(lTLPoll)
				WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
			ACTIVE(channel.channel=200):
			{
				TIMELINE_CREATE(lTLPoll,lPollArray,4,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}
BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		to[button.input]
		PULSE[vdvLCD,button.input.channel]
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

