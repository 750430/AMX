MODULE_NAME='NEC 60XP10 Rev5-00'(dev dvTP, dev vdvPlasma, dev dvPlasma)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/27/2008  AT: 12:49:48        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//Set Baud 9600,N,8,1
//define_module 'NEC 60XP10 Rev5-00' plas1(vdvTP_DISP1,vdvDisp1,dvPlasma)
#INCLUDE 'HoppSNAPI Rev5-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

lTLPoll		= 2001
lTLCmd      = 2002

PollPwr 	= 1
PollSrc		= 2

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {5100,5100}
LONG lCmdArray[]				=	{1010,1010}

INTEGER nPollType = 0

CHAR cCmdStr[60][10]
CHAR cRespStr[35][10]	
CHAR cPollStr[2][10]

char cPlasmaBuffer[255]

INTEGER nCmd=0
INTEGER nPlasBtn[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
										21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36}

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvPlasma,VD_PWR_ON],[dvPlasma,VD_PWR_OFF])

([dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_RGB1],[dvTP,VD_SRC_RGB2],
[dvTP,VD_SRC_RGB3],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_AUX1],[dvTP,VD_SRC_AUX1],
[dvTP,VD_SRC_AUX1])
([dvPlasma,VD_SRC_VID1],[dvPlasma,VD_SRC_SVID],[dvPlasma,VD_SRC_RGB1],[dvPlasma,VD_SRC_RGB2],
[dvPlasma,VD_SRC_RGB3],[dvPlasma,VD_SRC_CMPNT1],[dvPlasma,VD_SRC_AUX1],[dvPlasma,VD_SRC_AUX1],
[dvPlasma,VD_SRC_AUX1])
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
	STACK_VAR CHAR cVal[1]
	LOCAL_VAR INTEGER nTempVal

	SWITCH(nPollType)
	{
		CASE PollPwr:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
				{
					ON[dvPlasma,VD_PWR_ON]
					ON[dvTP,VD_PWR_ON]
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1)):
				{
					ON[dvPlasma,VD_PWR_OFF]
					ON[dvTP,VD_PWR_OFF]
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}
			}
		}		
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VID1],1)):
				{
					ON[dvPlasma,VD_SRC_VID1]
					ON[dvTP,VD_SRC_VID1]
					IF(nCmd=VD_SRC_VID1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VID2],1)):
				{
					ON[dvPlasma,VD_SRC_VID2]
					ON[dvTP,VD_SRC_VID2]
					IF(nCmd=VD_SRC_VID2) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_SVID],1)):
				{
					ON[dvPlasma,VD_SRC_SVID]
					ON[dvTP,VD_SRC_SVID]
					IF(nCmd=VD_SRC_SVID) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_RGB1],1)):
				{
					ON[dvPlasma,VD_SRC_RGB1]
					ON[dvTP,VD_SRC_RGB1]
					IF(nCmd=VD_SRC_RGB1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VGA1],1)):
				{
					ON[dvPlasma,VD_SRC_VGA1]
					ON[dvTP,VD_SRC_VGA1]
					IF(nCmd=VD_SRC_VGA1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_DVI1],1)):
				{
					ON[dvPlasma,VD_SRC_DVI1]
					ON[dvTP,VD_SRC_DVI1]
					IF(nCmd=VD_SRC_DVI1) CmdExecuted()					
				}
			}
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		="'00!',$0D"
cCmdStr[VD_PWR_OFF]		="'00"',$0D"
cCmdStr[VD_SRC_VID1]		="'00_v1',$0D"
cCmdStr[VD_SRC_VID2]	="'00_v4',$0D"
cCmdStr[VD_SRC_SVID]	="'00_v3',$0D"
cCmdStr[VD_SRC_DVI1]	="'00_r1',$0D"
cCmdStr[VD_SRC_VGA1]	="'00_r2',$0D"
cCmdStr[VD_SRC_RGB1]	="'00_r3',$0D"

cRespStr[VD_PWR_ON]		="'00vP1',$0D"
cRespStr[VD_PWR_OFF]	="'00vP0',$0D"
cRespStr[VD_SRC_VID1]	="'00vIv1',$0D"
cRespStr[VD_SRC_VID2]	="'00vIv4',$0D"
cRespStr[VD_SRC_SVID]	="'00vIv3',$0D"
cRespStr[VD_SRC_DVI1]	="'00vIr1',$0D"
cRespStr[VD_SRC_VGA1]	="'00vIr2',$0D"
cRespStr[VD_SRC_RGB1]	="'00vIr3',$0D"

cPollStr[PollPwr] 		="'00vP',$0D"			//running sense
cPollStr[PollSrc]		="'00vI',$0D"			//input mode request

create_buffer dvPlasma,cPlasmaBuffer

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

DATA_EVENT[dvPlasma]
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
	send_string dvPlasma,"cPollStr[timeline.sequence]"
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
					send_string dvPlasma,"cCmdStr[nCmd]"
					nPollType=PollPwr
				}
				CASE VD_SRC_VID1:
				CASE VD_SRC_VID2:
				CASE VD_SRC_SVID:
				CASE VD_SRC_RGB1:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_DVI1:
				{
					IF([dvPlasma,VD_PWR_ON])
					{
						send_string dvPlasma,"cCmdStr[nCmd]"
						nPollType=PollSrc
					}
					ELSE
					{
						send_string dvPlasma,"cCmdStr[VD_PWR_ON]"
						nPollType=PollPwr
					}
				}
			}
		}
		CASE 2:	IF(nPollType) send_string dvPlasma,"cPollStr[nPollType]"
	}
}

CHANNEL_EVENT[vdvPlasma,0]
{
	ON:
	{
		SELECT
		{	
			ACTIVE(channel.channel<VD_POLL_BEGIN):
			{
				nCmd=channel.channel
				TIMELINE_PAUSE(lTLPoll)
				WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
			ACTIVE(channel.channel=VD_POLL_BEGIN):
			{
				TIMELINE_CREATE(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}	
	}
}
BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		PULSE[dvPlasma,button.input.channel]
	}
}
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

