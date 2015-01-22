MODULE_NAME='Christie LX650 Rev4-01'(DEV vdvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/22/2008  AT: 13:46:26        *)
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
*)

#INCLUDE 'HoppSNAPI Rev4-03.axi'

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
INTEGER PollLamp	= 4

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

INTEGER nPollType

CHAR cResp[100]
CHAR cCmdStr[40][20]	
CHAR cPollStr[4][20]
CHAR cRespStr[255][8]

INTEGER nPwrVerify = 0

INTEGER nCmd = 0
INTEGER btn_PROJ[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,
										 23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40}

non_volatile integer nPollActive
non_volatile integer nCmdActive

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
([vdvTP,VD_SRC_RGB1],[vdvTP,VD_SRC_RGB2],[vdvTP,VD_SRC_RGB3],[vdvTP,VD_SRC_VID1],[vdvTP,VD_SRC_SVID],[vdvTP,VD_SRC_VID2])

([vdvProj,VD_PWR_ON_FB],[vdvProj,VD_WARMING_FB],[vdvProj,VD_COOLING_FB],[vdvProj,VD_PWR_OFF_FB])
([vdvProj,VD_MUTE_ON_FB],[vdvProj,VD_MUTE_OFF_FB])
([vdvProj,VD_SRC_RGB1_FB],[vdvProj,VD_SRC_RGB2_FB],[vdvProj,VD_SRC_RGB3_FB],[vdvProj,VD_SRC_VID1_FB],[vdvProj,VD_SRC_SVID_FB],[vdvProj,VD_SRC_VID2_FB])

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
	
	SWITCH(nPollType)
	{
		CASE PollPower:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
				{			
					ON[vdvTP,VD_PWR_ON]
					ON[vdvProj,VD_PWR_ON_FB]
					IF(nCmd = VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1) or find_string(cCompStr,"'04',$0D",1)):
				{	
					ON[vdvProj,VD_PWR_OFF_FB]
					ON[vdvTP,VD_PWR_OFF]
					IF(nCmd = VD_PWR_OFF) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'40',$0D",1)): 	//Warming Up
				{
					ON[vdvProj,VD_WARMING_FB]
					ON[vdvTP,VD_PWR_ON]
					IF(ncmd = VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'20',$0D",1)):	//Cooling Down
				{
					ON[vdvProj,VD_COOLING_FB]
					ON[vdvTP,VD_PWR_OFF]
					IF(ncmd = VD_PWR_OFF) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cResp,"'04',$0D",1) || FIND_STRING(cResp,"'10',$0D",1) || 
							 FIND_STRING(cResp,"'28',$0D",1) || FIND_STRING(cResp,"'21',$0D",1) ||
							 FIND_STRING(cResp,"'88',$0D",1) || FIND_STRING(cResp,"'24',$0D",1) ||
							 FIND_STRING(cResp,"'81',$0D",1) || FIND_STRING(cResp,"'2C',$0D",1) || 
							 FIND_STRING(cResp,"'8C',$0D",1)):		//Error Message
				{
					ON[vdvProj,VD_ERROR_FB]
				}			
			}	
		}
		CASE PollInput:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'1',$0D",1)):
				{
					IF(nCmd = VD_SRC_RGB1)
					{
						ON[vdvProj,VD_SRC_RGB1_FB]
						ON[vdvTP,VD_SRC_RGB1]
						CmdExecuted()
					}
					IF(nCmd = VD_SRC_RGB3)
					{
						ON[vdvProj,VD_SRC_RGB3_FB]
						ON[vdvTP,VD_SRC_RGB3]
						CmdExecuted()
					}					
				}
				ACTIVE(FIND_STRING(cCompStr,"'2',$0D",1)):
				{
					IF(nCmd = VD_SRC_RGB2)
					{
						ON[vdvProj,VD_SRC_RGB2_FB]
						ON[vdvTP,VD_SRC_RGB2]
						CmdExecuted()
					}
					IF(nCmd = VD_SRC_CMPNT1)
					{
						ON[vdvProj,VD_SRC_CMPNT1_FB]
						ON[vdvTP,VD_SRC_CMPNT1]
						CmdExecuted()
					}		
					IF(nCmd = VD_SRC_CMPNT2)
					{
						ON[vdvProj,VD_SRC_CMPNT2_FB]
						ON[vdvTP,VD_SRC_CMPNT2]
						CmdExecuted()
					}	
					IF(nCmd = VD_SRC_VID2)
					{
						ON[vdvProj,VD_SRC_VID2_FB]
						ON[vdvTP,VD_SRC_VID2]
						CmdExecuted()
					}	
				}
				ACTIVE(FIND_STRING(cCompStr,"'3',$0D",1)):
				{
					IF(nCmd = VD_SRC_VID1)
					{
						ON[vdvProj,VD_SRC_VID1_FB]
						ON[vdvTP,VD_SRC_VID1]
						CmdExecuted()
					}
					IF(nCmd = VD_SRC_SVID)
					{
						ON[vdvProj,VD_SRC_SVID_FB]
						ON[vdvTP,VD_SRC_SVID]
						CmdExecuted()
					}		
					IF(nCmd = VD_SRC_CMPNT1)
					{
						ON[vdvProj,VD_SRC_CMPNT1_FB]
						ON[vdvTP,VD_SRC_CMPNT1]
						CmdExecuted()
					}	
					IF(nCmd = VD_SRC_CMPNT2)
					{
						ON[vdvProj,VD_SRC_CMPNT2_FB]
						ON[vdvTP,VD_SRC_CMPNT2]
						CmdExecuted()
					}	
				}				
			}	
		}
		CASE PollMute:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_MUTE_ON],1)):
				{
					ON[vdvProj,VD_MUTE_ON_FB]
					ON[vdvTP,VD_MUTE_ON]
					IF(nCmd = VD_MUTE_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_MUTE_OFF],1)):
				{
					ON[vdvProj,VD_MUTE_OFF_FB]
					ON[vdvTP,VD_MUTE_OFF]
					IF(nCmd = VD_MUTE_OFF) CmdExecuted()
				}
			}
			[vdvTP,VD_MUTE_TOG] = ([vdvTP,VD_MUTE_ON])
		}
		CASE PollLamp:	//Lamp Hours
		{
			nLamp = ATOI("LEFT_STRING(cCompStr,5)")	
			SEND_COMMAND vdvTP,"'@TXT,1,',ITOA(nLamp)"
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "'C00',$0D"	//on
cCmdStr[VD_PWR_OFF]			= "'C01',$0D"	//off
cCmdStr[VD_SRC_RGB1]  		= "'C50',$0D"	//input1
cCmdStr[VD_SRC_RGB2]		= "'C25',$0D"	//input2
cCmdStr[VD_SRC_RGB3]		= "'C52',$0D"	//input1 DVI PC Digital
cCmdStr[VD_SRC_CMPNT1]		= "'C24',$0D"	//input2 Y/Pb/Pr
cCmdStr[VD_SRC_CMPNT2]		= "'C35',$0D"	//input3 Y/Pb/Pr
cCmdStr[VD_SRC_VID1] 		= "'C07',$0D"	//input3 video
cCmdStr[VD_SRC_VID2] 		= "'C23',$0D"	//input3 video
cCmdStr[VD_SRC_SVID]		= "'C34',$0D"	//input3 svideo
cCmdStr[VD_MUTE_ON]			= "'C0D',$0D"	//mute on
cCmdStr[VD_MUTE_OFF]		= "'C0E',$0D"	//mute off
cCmdStr[VD_PCADJ]			= "'C89',$0D"	//pc adjust
cCmdStr[VD_ASPECT2] 		= "'C0F',$0D"	//4:3 aspect
cCmdStr[VD_ASPECT1] 		= "'C10',$0D"	//16:9 aspect
cCmdStr[VD_ZOOM_IN]			= "'C47',$0D"	//mute off
cCmdStr[VD_ZOOM_OUT]		= "'C46',$0D"	//pc adjus
cCmdStr[VD_LENS_UP]			= "'C4B',$0D"	//mute off
cCmdStr[VD_LENS_DN]			= "'C4A',$0D"	//pc adjust

cPollStr[PollPower]		=	"$43,$52,$30,$0D"	//pwr
cPollStr[PollInput] 	= "$43,$52,$31,$0D"	//input
cPollStr[PollMute] 		= "$43,$52,$20,$56,$4D,$55,$54,$45,$0D"	//extcmd mute
cPollStr[PollLamp] 		= "$43,$52,$33,$0D"	//lamp hours

cRespStr[VD_PWR_ON] 		= "'00',$0D"
cRespStr[VD_PWR_OFF]		= "'80',$0D"
cRespStr[VD_MUTE_OFF]		= "'000 OFF',$0D"
cRespStr[VD_MUTE_ON]		= "'000 ON',$0D"


TIMELINE_CREATE(lTLPoll,lPollArray,4,TIMELINE_RELATIVE,TIMELINE_REPEAT)


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
				CASE VD_SRC_VID2:
				CASE VD_SRC_SVID:
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:
				CASE VD_SRC_RGB3:
				CASE VD_SRC_CMPNT1:
				CASE VD_SRC_CMPNT2:
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						IF(!nPwrVerify)
						{
							SEND_STRING dvProj,cCmdStr[nCmd]
							nPollType = PollInput
						}
					}
					IF([vdvProj,VD_WARMING_FB])
					{
						nPwrVerify = 0
						nPollType=PollPower
					}
					IF([vdvProj,VD_PWR_OFF_FB] || [vdvProj, VD_COOLING_FB])
					{
						nPwrVerify = 1
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						nPollType = PollPower
					}
				}
				CASE VD_MUTE_OFF:
				CASE VD_MUTE_ON:	
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollMute
					}
					ELSE CmdExecuted()
				}
				CASE VD_MUTE_TOG:
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						IF([vdvProj,VD_MUTE_ON_FB]) nCmd=VD_MUTE_OFF
						ELSE nCmd = VD_MUTE_ON
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollMute
					}	
					ELSE CmdExecuted()
				}
				CASE VD_PCADJ:
				CASE VD_ASPECT1:
				CASE VD_ASPECT2:
				CASE VD_ZOOM_IN:
				CASE VD_ZOOM_OUT:
				CASE VD_LENS_UP:
				CASE VD_LENS_DN:
				{
					IF([vdvProj,VD_PWR_ON_FB]) SEND_STRING dvproj,cCmdStr[ncmd]
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

BUTTON_EVENT[vdvTP,btn_PROJ]
{
	PUSH:
	{
		STACK_VAR INTEGER nI
		to[button.input]
		nI = GET_LAST(btn_PROJ)
		nCmd = GET_LAST(btn_PROJ)
		StartCommand()
	}
	HOLD[1,REPEAT]:
	{
		STACK_VAR INTEGER nI
		nI = GET_LAST(btn_PROJ)
		IF(nI = VD_LENS_UP || nI = VD_LENS_DN || nI = VD_ZOOM_IN || nI = VD_ZOOM_OUT)  
		{
			nCmd = GET_LAST(btn_PROJ)
			StartCommand()
		}
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM
nPollActive=timeline_active(lTLPoll)
nCmdActive=timeline_active(lTLCmd)

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


