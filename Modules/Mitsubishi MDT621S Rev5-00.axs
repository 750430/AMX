MODULE_NAME='Mitsubishi MDT621S Rev5-00'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/06/2008  AT: 11:25:47        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
//send_command data.device,"'SET BAUD 9600,N,8,1 485 DISABLE'"
//define_module 'Mitsubishi MDT621S Rev5-00' LCD1(vdvTP_DISP1,vdvDISP1,dvLCD)
#include 'HoppSNAPI Rev5-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll		= 2001
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
LONG lCmdArray[]				=	{1500,1500}

INTEGER nPollType = 0

CHAR cCmdStr[35][20]	
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
([dvLCD,VD_PWR_ON],[dvLCD,VD_PWR_OFF])

([dvTP,VD_SRC_RGB1],[dvTP,VD_SRC_RGB2],[dvTP,VD_SRC_RGB3],[dvTP,VD_SRC_DVI1],[dvTP,VD_SRC_DVI2],[dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID])
([dvLCD,VD_SRC_RGB1],[dvLCD,VD_SRC_RGB2],[dvLCD,VD_SRC_RGB3],[dvLCD,VD_SRC_DVI1],[dvLCD,VD_SRC_DVI2],[dvLCD,VD_SRC_VID1],[dvLCD,VD_SRC_SVID])

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
				ACTIVE(FIND_STRING(cCompStr,"'vP1'",1)):
				{
					ON[dvLCD,VD_PWR_ON]
					ON[dvTP,VD_PWR_ON]
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'vP0'",1)):
				{
					ON[dvLCD,VD_PWR_OFF]
					ON[dvTP,VD_PWR_OFF]
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}
			}	
		}
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'vIr4'",1)):
				{
					ON[dvLCD,VD_SRC_RGB1]
					ON[dvTP,VD_SRC_RGB1]
					IF(nCmd=VD_SRC_RGB1) 
					{
						pulse[vdvLCD,VD_PCADJ]
						CmdExecuted()					
					}
				}
				ACTIVE(FIND_STRING(cCompStr,"'vIr5'",1)):
				{
					ON[dvLCD,VD_SRC_RGB2]
					ON[dvTP,VD_SRC_RGB2]
					IF(nCmd=VD_SRC_RGB2) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'vIr3'",1)):
				{
					ON[dvLCD,VD_SRC_RGB3]
					ON[dvTP,VD_SRC_RGB3]
					IF(nCmd=VD_SRC_RGB3) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'vIr2'",1)):
				{
					ON[dvLCD,VD_SRC_DVI1]
					ON[dvTP,VD_SRC_DVI1]
					IF(nCmd=VD_SRC_DVI1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'vIr1'",1)):
				{
					ON[dvLCD,VD_SRC_DVI2]
					ON[dvTP,VD_SRC_DVI2]
					IF(nCmd=VD_SRC_DVI2) CmdExecuted()					
				}				
				ACTIVE(FIND_STRING(cCompStr,"'vIv1'",1)):
				{
					ON[dvLCD,VD_SRC_VID1]
					ON[dvTP,VD_SRC_VID1]
					IF(nCmd=VD_SRC_VID1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'vIv2'",1)):
				{
					ON[dvLCD,VD_SRC_SVID]
					ON[dvTP,VD_SRC_SVID]
					IF(nCmd=VD_SRC_SVID) CmdExecuted()					
				}
			}
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		= "'00!',$0D" 			
cCmdStr[VD_PWR_OFF]		= "'00"',$0D"
cCmdStr[VD_SRC_RGB1]	= "'00_r4',$0D"	//rgb
cCmdStr[VD_SRC_RGB2]	= "'00_r2',$0D"	//rgb2
cCmdStr[VD_SRC_RGB3]	= "'00_r3',$0D" //rgb3
cCmdStr[VD_SRC_DVI1]	= "'00_r2',$0D"	//dvi
cCmdStr[VD_SRC_DVI2]	= "'00_r1',$0D" //hdmi
cCmdStr[VD_SRC_VID1]	= "'00_v1',$0D"	//vid
cCmdStr[VD_SRC_SVID]	= "'00_v2',$0D"	//svid
cCmdStr[VD_PCADJ]		= "'00r09',$0D"

cPollStr[PollPwr] = "'00vP',$0D"
cPollStr[PollSrc] = "'00vI',$0D"

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
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:
				CASE VD_SRC_RGB3:
				CASE VD_SRC_DVI1:
				CASE VD_SRC_DVI2:
				CASE VD_SRC_VID1:
				CASE VD_SRC_SVID:
				{
					IF([dvLCD,VD_PWR_ON])
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
				CASE VD_ASPECT1:
				CASE VD_ASPECT2:
				CASE VD_PCADJ:
				{
					SEND_STRING dvLCD,cCmdStr[nCmd]
					CmdExecuted()
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
		IF(channel.channel<200)
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

