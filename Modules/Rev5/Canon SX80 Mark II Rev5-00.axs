MODULE_NAME='Canon SX80 Mark II Rev5-00'(DEV dvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   
SEND_COMMAND dvProj,"'SET BAUD 19200,N,8,2,485 DISABLE'" 
define_module 'Canon SX80 Mark II Rev5-00' disp1(vdvTP_DISP1,vdvDISP1,dvProj)
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

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002

INTEGER PollPower = 1
INTEGER PollInput = 2
INTEGER PollMute 	= 3

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]	= {3100,3100,3100}
LONG lCmdArray[]  =	{1100,1100}

INTEGER nPollType

CHAR cResp[100]
CHAR cCmdStr[40][20]	
CHAR cPollStr[3][20]
CHAR cRespStr[40][20]

INTEGER nPwrVerify = 0

INTEGER nCmd = 0

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvTP,VD_MUTE_ON],[dvTP,VD_MUTE_OFF])
([dvTP,VD_SRC_RGB1],[dvTP,VD_SRC_RGB2],[dvTP,VD_SRC_RGB3],[dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_AUX1])

([dvProj,VD_PWR_ON],[dvProj,VD_WARMING],[dvProj,VD_COOLING],[dvProj,VD_PWR_OFF])
([dvProj,VD_MUTE_ON],[dvProj,VD_MUTE_OFF])
([dvProj,VD_SRC_RGB1],[dvProj,VD_SRC_RGB2],[dvProj,VD_SRC_RGB3],[dvProj,VD_SRC_VID1],[dvProj,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_AUX1])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION CmdExecuted()
{
	ncmd=0
	TIMELINE_KILL(lTLCmd)
	TIMELINE_RESTART(lTLPoll)
}

DEFINE_FUNCTION StartCommand()
{
	TIMELINE_PAUSE(lTLPoll)
	IF(!TIMELINE_ACTIVE(lTLCmd))
		WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER x 
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,"'POWER=OFF2ON',$0D",1)): 	//Warming Up
		{
			ON[dvProj,VD_WARMING]
			ON[dvTP,VD_PWR_ON]
			IF(ncmd = VD_PWR_ON) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,"'POWER=ON2OFF',$0D",1)):	//Cooling Down
		{
			ON[dvProj,VD_COOLING]
			ON[dvTP,VD_PWR_OFF]
			IF(ncmd = VD_PWR_OFF) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
		{			
			ON[dvTP,VD_PWR_ON]
			ON[dvProj,VD_PWR_ON]
			IF(nCmd = VD_PWR_ON) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1)):
		{
			ON[dvProj,VD_PWR_OFF]
			ON[dvTP,VD_PWR_OFF]
			IF(nCmd = VD_PWR_OFF) CmdExecuted()
		}

		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_SRC_RGB1],1)):
		{
			ON[dvProj,VD_SRC_RGB1]
			ON[dvTP,VD_SRC_RGB1]
			IF(nCmd = VD_SRC_RGB1) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_SRC_RGB2],1)):
		{
			ON[dvProj,VD_SRC_RGB2]
			ON[dvTP,VD_SRC_RGB2]
			IF(nCmd = VD_SRC_RGB2) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_SRC_RGB3],1)):
		{
			ON[dvProj,VD_SRC_RGB3]
			ON[dvTP,VD_SRC_RGB3]
			IF(nCmd = VD_SRC_RGB3) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_SRC_CMPNT1],1)):
		{
			ON[dvProj,VD_SRC_CMPNT1]
			ON[dvTP,VD_SRC_CMPNT1]
			IF(nCmd = VD_SRC_CMPNT1) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_SRC_VID1],1)):
		{
			ON[dvProj,VD_SRC_VID1]
			ON[dvTP,VD_SRC_VID1]
			IF(nCmd = VD_SRC_VID1) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_SRC_SVID],1)):
		{
			ON[dvProj,VD_SRC_SVID]
			ON[dvTP,VD_SRC_SVID]
			IF(nCmd = VD_SRC_SVID) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_SRC_AUX1],1)):
		{
			ON[dvProj,VD_SRC_AUX1]
			ON[dvTP,VD_SRC_AUX1]
			IF(nCmd = VD_SRC_AUX1) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_MUTE_ON],1)):
		{
			ON[dvProj,VD_MUTE_ON]
			ON[dvTP,VD_MUTE_ON]
			IF(nCmd = VD_MUTE_ON) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cCmdStr[VD_MUTE_OFF],1)):
		{
			ON[dvProj,VD_MUTE_OFF]
			ON[dvTP,VD_MUTE_OFF]
			IF(nCmd = VD_MUTE_OFF) CmdExecuted()
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "'POWER ON',$0D"	//on
cCmdStr[VD_PWR_OFF]			= "'POWER OFF',$0D"	//off
cCmdStr[VD_SRC_RGB1]  		= "'INPUT=A-RGB1',$0D"	//RGB1
cCmdStr[VD_SRC_RGB2]		= "'INPUT=A-RGB2',$0D"	//RGB2
cCmdStr[VD_SRC_RGB3]		= "'INPUT=D-RGB',$0D"	//DVI
cCmdStr[VD_SRC_CMPNT1]		= "'INPUT=COMP',$0D"	//Component
cCmdStr[VD_SRC_VID1] 		= "'INPUT=VIDEO',$0D"	//Video
cCmdStr[VD_SRC_SVID]		= "'INPUT=S-VIDEO',$0D"	//S-Video
cCmdStr[VD_SRC_AUX1]		= "'INPUT=HDMI',$0D"	//HDMI
cCmdStr[VD_MUTE_ON]			= "'BLANK=ON',$0D"	//mute on
cCmdStr[VD_MUTE_OFF]		= "'BLANK=OFF',$0D"	//mute off

cPollStr[PollPower]		= "'GET POWER',$0D"	//pwr
cPollStr[PollInput] 	= "'GET INPUT',$0D"	//input
cPollStr[PollMute] 		= "'GET BLANK',$0D"	//extcmd mute

cRespStr[VD_PWR_ON] 		= "'POWER=ON',$0D"
cRespStr[VD_PWR_OFF]		= "'POWER=OFF',$0D"
cRespStr[VD_MUTE_OFF]		= "'BLANK=OFF',$0D"
cRespStr[VD_MUTE_ON]		= "'BLANK=ON',$0D"


TIMELINE_CREATE(lTLPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)


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

TIMELINE_EVENT[lTLPoll]				//Projector Polling
{
	SEND_STRING dvProj,"cPollStr[TIMELINE.SEQUENCE]"
	nPollType = TIMELINE.SEQUENCE
}

TIMELINE_EVENT[lTLCmd]		//Projector Commands
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
					SEND_STRING dvProj,cCmdStr[nCmd]
					nPollType = PollPower
				}
				CASE VD_SRC_VID1:
				CASE VD_SRC_SVID:
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:
				CASE VD_SRC_RGB3:
				CASE VD_SRC_CMPNT1:
				CASE VD_SRC_AUX1:
				{
					IF([dvProj,VD_PWR_ON])
					{
						IF(!nPwrVerify)
						{
							SEND_STRING dvProj,cCmdStr[nCmd]
							nPollType = PollInput
						}
					}
					else IF([dvProj,VD_WARMING])
					{
						nPwrVerify = 0
					}
					else IF([dvProj,VD_PWR_OFF] || [dvProj, VD_COOLING])
					{
						nPwrVerify = 1
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						nPollType = PollPower
					}
					else nPollType=PollPower
				}
				CASE VD_MUTE_OFF:
				CASE VD_MUTE_ON:	
				{
					IF([dvProj,VD_PWR_ON])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollMute
					}
					ELSE CmdExecuted()
				}
				CASE VD_MUTE_TOG:
				{
					IF([dvProj,VD_PWR_ON])
					{
						IF([dvProj,VD_MUTE_ON]) nCmd=VD_MUTE_OFF
						ELSE nCmd = VD_MUTE_ON
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollMute
					}	
					ELSE CmdExecuted()
				}
			}
		}
		CASE 2:	//2nd time
		{
			IF(nPollType) SEND_STRING dvProj,cPollStr[nPollType]
		}
	}
}

CHANNEL_EVENT[vdvProj,0]
{
	ON:
	{
		IF(channel.channel<200)
		{
			nCmd = channel.channel
			StartCommand()
		}
	}
}

BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		nCmd = button.input.channel
		StartCommand()
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvTP,VD_MUTE_TOG] = ([dvTP,VD_MUTE_ON])
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


