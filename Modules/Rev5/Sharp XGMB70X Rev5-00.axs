MODULE_NAME='Sharp XGMB70X Rev5-00'(DEV vdvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/24/2011  AT: 12:43:29        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  

	 *)
(***********************************************************)
(*   
	Set baud to 9600,N,8,1,485 DISABLE
	define_module 'Sharp XGMB70X Rev5-00' proj1(vdvTP_DISP1,vdvDISP1,dvProj)
*)

#INCLUDE 'HoppSNAPI Rev5-01.axi'

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll		= 2001
LONG lTLCmd         = 2002

INTEGER PollPower 	= 1
INTEGER PollInput 	= 2

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]	= {3100,3100}
LONG lCmdArray[]  =	{510,510}

INTEGER nPollType

CHAR cResp[100]
CHAR cCmdStr[51][20]	
CHAR cPollStr[2][20]
CHAR cRespStr[51][20]

INTEGER nCmd = 0

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

([vdvTP,VD_PWR_ON],[vdvTP,VD_PWR_OFF])
([vdvTP,VD_SRC_RGB1],[vdvTP,VD_SRC_RGB2],[vdvTP,VD_SRC_VID1])

([dvProj,VD_PWR_ON],[dvProj,VD_WARMING],[dvProj,VD_COOLING],[dvProj,VD_PWR_OFF])
([dvProj,VD_SRC_RGB1],[dvProj,VD_SRC_RGB2],[dvProj,VD_SRC_VID1])

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
	
	SWITCH(nPollType)
	{
		CASE PollPower:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)):
				{			
					ON[vdvTP,VD_PWR_ON]
					IF(nCmd = VD_PWR_ON) 
					{
						CmdExecuted()
						ON[dvProj,VD_WARMING]
						wait 50
						{
							ON[dvProj,VD_PWR_ON]
						}
					}
					else if (![dvProj,VD_WARMING])
					{
						ON[dvProj,VD_PWR_ON]
					}
				}
				ACTIVE(FIND_STRING(cCompStr,"'0'",1)):
				{	
					ON[vdvTP,VD_PWR_OFF]
					IF(nCmd = VD_PWR_OFF) 
					{
						CmdExecuted()
						ON[dvProj,VD_COOLING]
						wait 50
						{
							ON[dvProj,VD_PWR_OFF]
						}
					}
					else if (![dvProj,VD_COOLING])
					{
						ON[dvProj,VD_PWR_OFF]
					}
				}
//				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_WARMING],1)): 	//Warming Up
//				{
//					ON[dvProj,VD_WARMING]
//					ON[vdvTP,VD_PWR_ON]
//					IF(ncmd = VD_PWR_ON) CmdExecuted()
//				}
//				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_COOLING],1)):	//Cooling Down
//				{
//					ON[dvProj,VD_COOLING]
//					ON[vdvTP,VD_PWR_OFF]
//					IF(ncmd = VD_PWR_OFF) CmdExecuted()
//				}
			}	
		}
		CASE PollInput:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)):
				{
					IF(nCmd = VD_SRC_RGB2)
					{
						ON[dvProj,VD_SRC_RGB2]
						ON[vdvTP,VD_SRC_RGB2]
						CmdExecuted()
					}
					else IF(nCmd = VD_SRC_RGB1)
					{
						ON[dvProj,VD_SRC_RGB1]
						ON[vdvTP,VD_SRC_RGB1]
						CmdExecuted()
					}
					else
					{
						ON[dvProj,VD_SRC_RGB1]
						ON[vdvTP,VD_SRC_RGB1]
					}
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					IF(nCmd = VD_SRC_VID1)
					{
						ON[dvProj,VD_SRC_VID1]
						ON[vdvTP,VD_SRC_VID1]
						CmdExecuted()
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

cCmdStr[VD_PWR_ON]		= "'POWR   1',$0D" 			
cCmdStr[VD_PWR_OFF]		= "'POWR   0',$0D"
cCmdStr[VD_SRC_RGB1]	= "'IRGB   1',$0D"
cCmdStr[VD_SRC_RGB2]  	= "'IRGB   2',$0D"
cCmdStr[VD_SRC_VID1]	= "'IVED   1',$0D"	//vid/component1


cPollStr[PollPower]		= "'POWR????',$0D"	//pwr
cPollStr[PollInput] 	= "'IMOD????',$0D"	//input



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
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:
				{
					IF([dvProj,VD_PWR_ON])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollInput
					}
					else IF([dvProj,VD_WARMING])
					{
						nPollType=PollPower
					}
					else IF([dvProj,VD_PWR_OFF] || [dvProj, VD_COOLING])
					{
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						nPollType = PollPower
					}
					else
					{
						nPollType=PollPower
					}
				}
			}
		}
		CASE 2:	//2nd time
		{
			IF(nPollType) SEND_STRING dvProj,cPollStr[nPollType]
		}
	}
}

//CHANNEL_EVENT[vdvProj,0]
//{
//	ON:
//	{
//		IF(channel.channel<200)
//		{
//			nCmd = channel.channel
//			StartCommand()
//		}
//	}
//}

CHANNEL_EVENT[vdvProj,0]
{
	ON:
	{
		SELECT
		{
			ACTIVE(channel.channel<VD_POLL_BEGIN):
			{
				nCmd=channel.channel
				StartCommand()
			}
			ACTIVE(channel.channel=VD_POLL_BEGIN):
			{
				TIMELINE_CREATE(lTLPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}

BUTTON_EVENT[vdvTP,0]
{
	PUSH:
	{
		STACK_VAR INTEGER nI
		to[button.input]
		nI = button.input.channel
		nCmd = button.input.channel
		StartCommand()
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


