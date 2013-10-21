MODULE_NAME='Digital Projection Titan 660 2D Rev5-00'(DEV vdvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)

(***********************************************************)
(*   
	This module is for IP based communication only.  The DP Titan series has a separate protocol for IP and for Serial communication.
	define_module 'Digital Projection Titan 660 2D Rev5-00' proj1(vdvTP_DISP1,vdvDISP1,dvProj)
*)

#INCLUDE 'HoppSNAPI Rev5-10.axi'

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
INTEGER PollLamp	= 4

AckPower		=	1
AckInput		=	2

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]	= {3100,3100,3100,3100}
LONG lCmdArray[]  =	{510,510}

char	cBuffer[20][100]
integer nBufferCounter

INTEGER nPollType

CHAR cResp[100]
CHAR cCmdStr[71][100]	
CHAR cPollStr[4][100]
CHAR cRespStr[71][100]
CHAR cAckStr[2][100]

INTEGER nPwrVerify = 0

INTEGER nCmd = 0

integer nTransition

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
([vdvTP,VD_SRC_VGA1],[vdvTP,VD_SRC_DVI1],[vdvTP,VD_SRC_HDMI1],[vdvTP,VD_SRC_AUX1])

([dvProj,VD_PWR_ON],[dvProj,VD_WARMING],[dvProj,VD_COOLING],[dvProj,VD_PWR_OFF])
([dvProj,VD_MUTE_ON],[dvProj,VD_MUTE_OFF])
([dvProj,VD_SRC_VGA1],[dvProj,VD_SRC_DVI1],[dvProj,VD_SRC_HDMI1],[dvProj,VD_SRC_AUX1])

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
	STACK_VAR INTEGER nLamp
	stack_var char cInput[1]
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,cAckStr[AckPower],1)):
		{
			switch(nCmd)
			{
				case VD_PWR_ON:
				case VD_SRC_VGA1:
				case VD_SRC_DVI1:
				case VD_SRC_HDMI1:
				case VD_SRC_AUX1:
				{
					ON[dvProj,VD_WARMING]
					ON[vdvTP,VD_PWR_ON]
					//IF(ncmd = VD_PWR_ON) CmdExecuted()					
				}
				case VD_PWR_OFF:
				{
					ON[dvProj,VD_COOLING]
					ON[vdvTP,VD_PWR_OFF]
					//IF(ncmd = VD_PWR_OFF) CmdExecuted()					
				}
			}
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
		{			
			if(![dvProj,VD_COOLING]) 
			{
				if([dvProj,VD_WARMING] and nTransition<10) nTransition ++
				else
				{
					nTransition=0
					ON[dvProj,VD_PWR_ON]
					IF(nCmd = VD_PWR_ON) CmdExecuted()
				}
				ON[vdvTP,VD_PWR_ON]
			}
			else if(nTransition>10)
			{
				ON[vdvTP,VD_PWR_ON]
				ON[dvProj,VD_PWR_ON]
				nTransition=0
			}			
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1)):
		{	
			if(![dvProj,VD_WARMING])
			{
				if([dvProj,VD_COOLING] and nTransition<10) nTransition++
				else
				{
					nTransition=0
					ON[dvProj,VD_PWR_OFF]
					IF(nCmd = VD_PWR_OFF) CmdExecuted()
				}
				ON[vdvTP,VD_PWR_OFF]
			}
			else if(nTransition>10)
			{
				ON[vdvTP,VD_PWR_OFF]
				ON[dvProj,VD_PWR_OFF]
				nTransition=0
			}
		}
		ACTIVE(FIND_STRING(cCompStr,"$74,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$11,$00,$00,$00,$00,$70,$46,$01,$40,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00",1)):
		{
			cInput=right_string(cCompStr,1)
			IF(cInput=$04)
			{
				ON[dvProj,VD_SRC_VGA1]
				ON[vdvTP,VD_SRC_VGA1]
				CmdExecuted()
			}
			IF(cInput=$05)
			{
				ON[dvProj,VD_SRC_AUX1]
				ON[vdvTP,VD_SRC_AUX1]
				CmdExecuted()
			}
			IF(cInput=$06)
			{
				ON[dvProj,VD_SRC_DVI1]
				ON[vdvTP,VD_SRC_DVI1]
				CmdExecuted()
			}		
			IF(cInput=$07)
			{
				ON[dvProj,VD_SRC_HDMI1]
				ON[vdvTP,VD_SRC_HDMI1]
				CmdExecuted()
			}						
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "$54,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$3D,$00,$00,$00,$00,$50,$46,$27,$07,$00,$00,$00,$00,$00,$00,$00,$31,$00,$00,$00,$2D,$23,$70,$6F,$77,$72,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$73,$79,$73,$74,$65,$6D,$2C,$70,$72,$6F,$6A,$65,$63,$74,$6F,$72,$2C,$77,$72,$69,$74,$65,$2C,$6F,$6E,$0D,$00"	//on
cCmdStr[VD_PWR_OFF]			= "$54,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$42,$00,$00,$00,$00,$50,$46,$27,$07,$00,$00,$00,$00,$00,$00,$00,$36,$00,$00,$00,$32,$23,$70,$6F,$77,$72,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$73,$79,$73,$74,$65,$6D,$2C,$70,$72,$6F,$6A,$65,$63,$74,$6F,$72,$2C,$77,$72,$69,$74,$65,$2C,$73,$74,$61,$6E,$64,$62,$79,$0D,$00"	//off
cCmdStr[VD_SRC_VGA1]		= "$54,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$00,$00,$50,$46,$01,$3E,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$04"	
cCmdStr[VD_SRC_DVI1]		= "$54,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$00,$00,$50,$46,$01,$3E,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$06"	
cCmdStr[VD_SRC_HDMI1] 		= "$54,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$00,$00,$50,$46,$01,$3E,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$07"	
cCmdStr[VD_SRC_AUX1]		= "$54,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$00,$00,$50,$46,$01,$3E,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$05"	
cCmdStr[VD_MUTE_ON]			= "$54,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$3D,$00,$00,$00,$00,$50,$46,$27,$07,$00,$00,$00,$00,$00,$00,$00,$31,$00,$00,$00,$2D,$23,$70,$69,$63,$6D,$75,$74,$65,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$69,$6D,$61,$67,$65,$2C,$70,$69,$63,$6D,$75,$74,$65,$2C,$77,$72,$69,$74,$65,$2C,$6F,$6E,$0D,$00"	//mute on
cCmdStr[VD_MUTE_OFF]		= "$54,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$3E,$00,$00,$00,$00,$50,$46,$27,$07,$00,$00,$00,$00,$00,$00,$00,$32,$00,$00,$00,$2E,$23,$70,$69,$63,$6D,$75,$74,$65,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$69,$6D,$61,$67,$65,$2C,$70,$69,$63,$6D,$75,$74,$65,$2C,$77,$72,$69,$74,$65,$2C,$6F,$66,$66,$0D,$00"	//mute off

cPollStr[PollPower]			= "$54,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$3B,$00,$00,$00,$00,$50,$46,$27,$07,$00,$00,$00,$00,$00,$00,$00,$2F,$00,$00,$00,$2B,$23,$70,$6F,$77,$72,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$30,$2C,$73,$79,$73,$74,$65,$6D,$2C,$70,$72,$6F,$6A,$65,$63,$74,$6F,$72,$2C,$72,$65,$61,$64,$2C,$31,$0D,$00"	//pwr
cPollStr[PollInput] 		= "$54,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$0D,$00,$00,$00,$00,$50,$46,$01,$40,$00,$00,$00,$00,$00,$00,$00,$01,$00"	//input
//cPollStr[PollMute] 			= "$43,$52,$20,$56,$4D,$55,$54,$45,$0D"	//extcmd mute
//cPollStr[PollLamp] 			= "$43,$52,$33,$0D"	//lamp hours

cRespStr[VD_PWR_ON] 		= "$74,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$1D,$00,$00,$00,$00,$70,$46,$27,$07,$00,$00,$00,$00,$00,$00,$00,$11,$00,$00,$00,$00,$0C,$70,$6F,$77,$72,$2C,$41,$43,$4B,$2C,$6F,$6E,$00"
cRespStr[VD_PWR_OFF]		= "$74,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$22,$00,$00,$00,$00,$70,$46,$27,$07,$00,$00,$00,$00,$00,$00,$00,$16,$00,$00,$00,$00,$11,$70,$6F,$77,$72,$2C,$41,$43,$4B,$2C,$73,$74,$61,$6E,$64,$62,$79,$00"
cRespStr[VD_WARMING] 		= "'40',$0D"
cRespStr[VD_COOLING] 		= "'20',$0D"
cRespStr[VD_MUTE_OFF]		= "$74,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$1D,$00,$00,$00,$00,$70,$46,$27,$07,$00,$00,$00,$00,$00,$00,$00,$11,$00,$00,$00,$00,$0C,$70,$69,$63,$6D,$75,$74,$65,$2C,$41,$43,$4B,$00"
cRespStr[VD_MUTE_ON]		= "$74,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$1D,$00,$00,$00,$00,$70,$46,$27,$07,$00,$00,$00,$00,$00,$00,$00,$11,$00,$00,$00,$00,$0C,$70,$69,$63,$6D,$75,$74,$65,$2C,$41,$43,$4B,$00"

cAckStr[AckPower]			= "$74,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$1A,$00,$00,$00,$00,$70,$46,$27,$07,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$00,$00,$00,$09,$70,$6F,$77,$72,$2C,$41,$43,$4B,$00"
//cAckStr[AckInput]			= "$74,$50,$01,$00,$00,$00,$00,$00,$00,$00,$00,$1A,$00,$00,$00,$00,$70,$46,$27,$07,$00,$00,$00,$00,$00,$00,$00,$0E,$00,$00,$00,$00,$09,$70,$6F,$77,$72,$2C,$41,$43,$4B,$00"

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
		nBufferCounter++
		if(nBufferCounter>20) nBufferCounter=1
		cBuffer[nBufferCounter+1]=''
		
		cBuffer[nBufferCounter]=data.text
		
		parse(data.text)
		
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
					send_string 0,"'dvProj Tx-',cCmdStr[nCmd]"
					nPollType = PollPower
				}
				CASE VD_SRC_VGA1:
				CASE VD_SRC_DVI1:
				CASE VD_SRC_HDMI1:
				CASE VD_SRC_AUX1:
				{
					IF([dvProj,VD_PWR_ON])
					{
						IF(!nPwrVerify)
						{
							SEND_STRING dvProj,cCmdStr[nCmd]
							send_string 0,"'dvProj Tx-',cCmdStr[nCmd]"
							nPollType = PollInput
						}
					}
					else IF([dvProj,VD_WARMING])
					{
						nPwrVerify = 0
						nPollType=PollPower
					}
					else IF([dvProj,VD_PWR_OFF] || [dvProj, VD_COOLING])
					{
						nPwrVerify = 1
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						send_string 0,"'dvProj Tx-',cCmdStr[nCmd]"
						nPollType = PollPower
					}
					else
					{
						nPollType=PollPower
					}
				}
				CASE VD_MUTE_OFF:
				CASE VD_MUTE_ON:	
				{
					IF([dvProj,VD_PWR_ON])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						send_string 0,"'dvProj Tx-',cCmdStr[nCmd]"
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
						send_string 0,"'dvProj Tx-',cCmdStr[nCmd]"
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
		to[button.input]
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


