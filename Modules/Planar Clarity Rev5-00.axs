MODULE_NAME='Planar Clarity Rev5-00'(dev dvTP, dev vdvWall, dev dvWall)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/06/2008  AT: 11:25:47        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
//send_command data.device,"'SET BAUD 19200,N,8,1 485 DISABLE'"
//define_module 'Planar Clarity Rev5-00' proj1(vdvTP_DISP1,vdvDISP1,dvWall)
#include 'HoppSNAPI Rev5-03.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {5000}
LONG lCmdArray[]				=	{900,900}

CHAR cCmdStr[2][40]	
CHAR cPollStr[20]


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

([dvWall,VD_PWR_ON],[dvWall,VD_PWR_OFF])

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
		//Power
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_PWR_ON],1)):
		{
			ON[dvWall,VD_PWR_ON]
			ON[dvTP,VD_PWR_ON]
			IF(nCmd=VD_PWR_ON)  CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_PWR_OFF],1)):
		{
			ON[dvWall,VD_PWR_OFF]
			ON[dvTP,VD_PWR_OFF]
			IF(nCmd=VD_PWR_OFF)  CmdExecuted()
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START



cCmdStr[VD_PWR_ON]		=	"'OPA1DISPLAY.POWER=ON',$0D"
cCmdStr[VD_PWR_OFF]		=	"'OPA1DISPLAY.POWER=OFF',$0D"

cPollStr		 		= "'OPA1DISPLAY.POWER?',$0D"


WAIT 200
{
	IF(!TIMELINE_ACTIVE(lTLPoll))
	{
		TIMELINE_CREATE(lTLPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
	}
}
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvWall]
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
	SEND_STRING dvWall,"cPollStr"
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
					SEND_STRING dvWall,cCmdStr[nCmd]
				}
			}
		}
		CASE 2:	//2nd time
		{
			SEND_STRING dvWall,cPollStr
		}
	}
}
CHANNEL_EVENT[vdvWall,0]
{
	ON:
	{
		IF(channel.channel<VD_POLL_BEGIN)
		{
			nCmd=channel.channel
			TIMELINE_PAUSE(lTLPoll)
			WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,length_array(lCmdArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
		}
		ELSE IF(channel.channel=VD_POLL_BEGIN)
		{
			TIMELINE_CREATE(lTLPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
		}
	}
}
BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		pulse[vdvWall,button.input.channel]
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

