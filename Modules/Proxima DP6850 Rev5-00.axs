MODULE_NAME='Proxima DP6850 Rev5-00'(DEV vdvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  
	 Written by: 		Ben Whitford
	 Date: 			 		5/3/07
	 First Project:	40043
	 *)
(***********************************************************)
(*   
	Set baud to 19200,N,8,1,485 DISABLE
	define_module 'Proxima DP6850 Rev5-00' proj1(vdvTP_DISP1,vdvDISP1,dvProj)
*)

#INCLUDE 'HoppSNAPI Rev5-03.axi'

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
LONG lCmdArray[]  =	{510,510}

INTEGER nPollType

integer x

CHAR cResp[100]
CHAR cCmdStr[40][20]	
CHAR cPollStr[3][20]
CHAR cRespStr[35][20]

INTEGER nPwrVerify = 0

INTEGER nCmd = 0
INTEGER btn_PROJ[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,
										 23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40}

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

([vdvTP,VD_PWR_ON],[vdvTP,VD_PWR_OFF])
([vdvTP,VD_MUTE_ON],[vdvTP,VD_MUTE_OFF])
([vdvTP,VD_SRC_VGA1],[vdvTP,VD_SRC_VGA2],[vdvTP,VD_SRC_RGB3],[vdvTP,VD_SRC_VID1],[vdvTP,VD_SRC_SVID],[vdvTP,VD_SRC_CMPNT1])

([dvProj,VD_PWR_ON],[dvProj,VD_WARMING],[dvProj,VD_COOLING],[dvProj,VD_PWR_OFF])
([dvProj,VD_MUTE_ON],[dvProj,VD_MUTE_OFF])
([dvProj,VD_SRC_VGA1],[dvProj,VD_SRC_VGA2],[dvProj,VD_SRC_RGB3],[dvProj,VD_SRC_VID1],[dvProj,VD_SRC_SVID],[dvProj,VD_SRC_CMPNT1])

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
		WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,length_array(lCmdArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,cRespStr[VD_PWR_ON],1)):
		{
			if((nCmd=VD_PWR_ON or nCmd=VD_SRC_VGA1 or nCmd=VD_SRC_VGA2 or nCmd=VD_SRC_VID1) and (![dvProj,VD_WARMING] and ![dvProj,VD_PWR_ON]))
			{
				if (nCmd=VD_PWR_ON) CmdExecuted()
				on[vdvTP,VD_PWR_ON]
				on[dvProj,VD_WARMING]
				wait 200 
				{
					on[dvProj,VD_PWR_ON]
				}
			}
			else if (![dvProj,VD_WARMING])
			{
				on[vdvTP,VD_PWR_ON]
				on[dvProj,VD_PWR_ON]
			}
		}
		active(find_string(cCompStr,cRespStr[VD_PWR_OFF],1)):
		{
			if(nCmd=VD_PWR_OFF)
			{
				CmdExecuted()
				on[vdvTP,VD_PWR_OFF]
				on[dvProj,VD_COOLING]
				wait 200 on[dvProj,VD_PWR_OFF]
			}
			else if (![dvProj,VD_COOLING])
			{
				on[vdvTP,VD_PWR_OFF]
				on[dvProj,VD_PWR_OFF]
			}
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_VID1],1)):
		{
			on[dvProj,VD_SRC_VID1]
			on[vdvTP,VD_SRC_VID1]
			if(nCmd = VD_SRC_VID1) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_VGA1],1)):
		{
			on[dvProj,VD_SRC_VGA1]
			on[vdvTP,VD_SRC_VGA1]
			if(nCmd = VD_SRC_VGA1) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_VGA2],1)):
		{
			on[dvProj,VD_SRC_VGA2]
			on[vdvTP,VD_SRC_VGA2]
			if(nCmd = VD_SRC_VGA2) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_MUTE_ON],1)):
		{
			on[dvProj,VD_MUTE_ON]
			on[vdvTP,VD_MUTE_ON]
			if(nCmd = VD_MUTE_ON) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_MUTE_OFF],1)):
		{
			on[dvProj,VD_MUTE_OFF]
			on[vdvTP,VD_MUTE_OFF]
			if(nCmd = VD_MUTE_OFF) CmdExecuted()
		}		
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "$31,$11,$3F"	//on
cCmdStr[VD_PWR_OFF]			= "$31,$11,$3E"	//off
cCmdStr[VD_SRC_VGA1]		= "$31,$21,$21" //RGB 1
cCmdStr[VD_SRC_VGA2]		= "$31,$21,$22"	//RGB 2
cCmdStr[VD_SRC_VID1] 		= "$31,$21,$11"	//Video
cCmdStr[VD_MUTE_ON]			= "$31,$41,$18"	//mute on
cCmdStr[VD_MUTE_OFF]		= "$31,$41,$08"	//mute off
cCmdStr[VD_PCADJ]			= "$31,$3C,$00"	//pc adjust

cPollStr[PollPower]		= "$20,$11"	//pwr
cPollStr[PollInput] 	= "$20,$21"	//input
cPollStr[PollMute] 		= "$20,$41"	//mute

cRespStr[VD_PWR_ON]			= "$11,$11,$3F"	//on
cRespStr[VD_PWR_OFF]		= "$11,$11,$3E"	//off
cRespStr[VD_SRC_VGA1]		= "$11,$21,$21" //RGB 1
cRespStr[VD_SRC_VGA2]		= "$11,$21,$22"	//RGB 2
cRespStr[VD_SRC_VID1] 		= "$11,$21,$11"	//Video
cRespStr[VD_MUTE_ON]		= "$11,$41,$18"	//mute on
cRespStr[VD_MUTE_OFF]		= "$11,$41,$08"	//mute off

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
//		LOCAL_VAR CHAR cHold[100]
//		LOCAL_VAR CHAR cFullStr[100]
//		LOCAL_VAR CHAR cBuff[255]
//		STACK_VAR INTEGER nPos	
//		
//		cBuff = "cBuff,data.text"
//		WHILE(LENGTH_STRING(cBuff))
//		{
//			SELECT
//			{
//				ACTIVE(FIND_STRING(cBuff,"$0D",1)&& LENGTH_STRING(cHold)):
//				{
//					nPos=FIND_STRING(cBuff,"$0D",1)
//					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
//					Parse(cFullStr)
//					cHold=''
//				}
//				ACTIVE(FIND_STRING(cBuff,"$0D",1)):
//				{
//					nPos=FIND_STRING(cBuff,"$0D",1)
//					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
//					Parse(cFullStr)
//				}
//				ACTIVE(1):
//				{
//					cHold="cHold,cBuff"
//					cBuff=''
//				}
//			}
//		}	
		parse(data.text)
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
				CASE VD_SRC_VGA1:
				CASE VD_SRC_VGA2:
				{
					IF([dvProj,VD_PWR_ON])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollInput
					}
					IF([dvProj,VD_WARMING])
					{
						nPollType=PollPower
					}
					IF([dvProj,VD_PWR_OFF] || [dvProj, VD_COOLING])
					{
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						nPollType = PollPower
					}
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
				CASE VD_PCADJ:
				{
					IF([dvProj,VD_PWR_ON]) SEND_STRING dvproj,cCmdStr[ncmd]
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

BUTTON_EVENT[vdvTP,btn_PROJ]
{
	PUSH:
	{
		to[button.input]
		nCmd = GET_LAST(btn_PROJ)
		StartCommand()
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM
[vdvTP,VD_MUTE_TOG] = ([vdvTP,VD_MUTE_ON])

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


