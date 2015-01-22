MODULE_NAME='Mitsubishi WL6700U Rev4-00'(dev dvTP, dev vdvProj, dev dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/06/2008  AT: 11:25:47        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
//send_command data.device,"'SET BAUD 9600,N,8,1 485 DISABLE'"
#include 'HoppSNAPI Rev4-01.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002

PollPwr 	= 1
PollTrans	= 2
PollSrc		= 3

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {1600,1600,1600}
LONG lCmdArray[]				=	{500,500}

INTEGER nPollType = 0

CHAR cCmdStr[35][20]	
CHAR cPollStr[4][20]

integer nTransitionPossible

integer nPowerOn
integer nPowerOff
integer nWarming
integer nCooling

INTEGER nCmd=0
INTEGER nProjBtns[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
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
([vdvProj,VD_PWR_ON_FB],[vdvProj,VD_PWR_OFF_FB],[vdvProj,VD_WARMING_FB],[vdvProj,VD_COOLING_FB])

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
	
	select
	{
		active(find_string(cCompStr,"'vPK0'",1)):
		{
			off[nTransitionPossible]
		}
		active(find_string(cCompStr,"'vPK1'",1)):
		{
			on[nTransitionPossible]
		}

		active(find_string(cCompStr,"'00!'",1) and nTransitionPossible):
		{
			on[vdvProj,VD_WARMING_FB]
			nPollType=PollTrans
			if(nCmd=VD_PWR_ON) CmdExecuted()
		}
		active(find_string(cCompStr,"'00"'",1) and nTransitionPossible):
		{
			on[vdvProj,VD_COOLING_FB]
			nPollType=PollTrans
			if(nCmd=VD_PWR_OFF) CmdExecuted()
		}

		ACTIVE(FIND_STRING(cCompStr,"'vP1'",1) and nTransitionPossible):
		{
			ON[vdvProj,VD_PWR_ON_FB]
			ON[dvTP,VD_PWR_ON]
			IF(nCmd=VD_PWR_ON) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,"'vP0'",1) and nTransitionPossible):
		{
			ON[vdvProj,VD_PWR_OFF_FB]
			ON[dvTP,VD_PWR_OFF]
			IF(nCmd=VD_PWR_OFF) CmdExecuted()
		}

		active(find_string(cCompStr,"'vP1'",1) and !nTransitionPossible):
		{
			send_string dvProj,"cPollStr[PollTrans]"
		}
		active(find_string(cCompStr,"'vP0'",1) and !nTransitionPossible):
		{
			send_string dvProj,"cPollStr[PollTrans]"
		}

		ACTIVE(FIND_STRING(cCompStr,"'vIr1'",1)):
		{
			ON[vdvProj,VD_SRC_RGB1_FB]
			ON[dvTP,VD_SRC_RGB1]
			IF(nCmd=VD_SRC_RGB1) CmdExecuted()					
		}
		ACTIVE(FIND_STRING(cCompStr,"'vIr2'",1)):
		{
			ON[vdvProj,VD_SRC_RGB2_FB]
			ON[dvTP,VD_SRC_RGB2]
			IF(nCmd=VD_SRC_RGB2) CmdExecuted()					
		}
		ACTIVE(FIND_STRING(cCompStr,"'vId1'",1)):
		{
			ON[vdvProj,VD_SRC_RGB3_FB]
			ON[dvTP,VD_SRC_RGB3]
			IF(nCmd=VD_SRC_RGB3) CmdExecuted()					
		}
		ACTIVE(FIND_STRING(cCompStr,"'vIv1'",1)):
		{
			ON[vdvProj,VD_SRC_VID1_FB]
			ON[dvTP,VD_SRC_VID1]
			IF(nCmd=VD_SRC_VID1) CmdExecuted()					
		}
		ACTIVE(FIND_STRING(cCompStr,"'vIv2'",1)):
		{
			ON[vdvProj,VD_SRC_SVID_FB]
			ON[dvTP,VD_SRC_SVID]
			IF(nCmd=VD_SRC_SVID) CmdExecuted()					
		}							
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		= "'00!',$0D" 			
cCmdStr[VD_PWR_OFF]		= "'00"',$0D"
cCmdStr[VD_SRC_RGB1]	= "'00_r1',$0D"	//rgb
cCmdStr[VD_SRC_RGB2]	= "'00_r2',$0D"	//rgb2
cCmdStr[VD_SRC_DVI1]	= "'00_d1',$0D"	//dvi
cCmdStr[VD_SRC_VID1]		= "'00_v1',$0D"	//vid
cCmdStr[VD_SRC_SVID]	= "'00_v2',$0D"	//svid
cCmdStr[VD_PCADJ]		= "'00r09',$0D"

cPollStr[PollPwr] 	=	"'00vP',$0D"
cPollStr[PollTrans]	=	"'00vPK',$0D"
cPollStr[PollSrc] 	=	"'00vI',$0D"

WAIT 200
{
	IF(!TIMELINE_ACTIVE(lTLPoll))
	{
		TIMELINE_CREATE(lTLPoll,lPollArray,3,TIMELINE_RELATIVE,TIMELINE_REPEAT)
	}
}
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvProj]
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
	SEND_STRING dvProj,"cPollStr[nPollType]"
	nPollType++
	if(nPollType>3) nPollType=1
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
					if (nTransitionPossible) 
					{	
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType=PollPwr
					}
					else nPollType=PollTrans
				}
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:
				CASE VD_SRC_RGB3:
				CASE VD_SRC_DVI1:
				CASE VD_SRC_VID1:
				CASE VD_SRC_SVID:
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType=PollSrc
					}
					ELSE
					{
						if (nTransitionPossible) 
						{	
							SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
							nPollType=PollPwr
						}
						else nPollType=PollTrans
					}
				}
				CASE VD_ASPECT1:
				CASE VD_ASPECT2:
				CASE VD_PCADJ:
				{
					IF([vdvProj,VD_PWR_ON_FB]) 
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
					}
					CmdExecuted()
				}
			}
		}
		CASE 2:	//2nd time
		{
			IF(nPollType) SEND_STRING dvProj,cPollStr[nPollType]
		}
	}
}
CHANNEL_EVENT[vdvProj,nProjBtns]
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
			TIMELINE_CREATE(lTLPoll,lPollArray,3,TIMELINE_RELATIVE,TIMELINE_REPEAT)
		}
	}
}
BUTTON_EVENT[dvTP,nProjBtns]
{
	PUSH:
	{
		to[button.input]
		PULSE[vdvProj,button.input.channel]
	}
}


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

nPowerOn=[vdvProj,VD_PWR_ON_FB]
nPowerOff=[vdvProj,VD_PWR_OFF_FB]
nWarming=[vdvProj,VD_WARMING_FB]
nCooling=[vdvProj,VD_COOLING_FB]

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

