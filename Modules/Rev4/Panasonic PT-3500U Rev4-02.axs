MODULE_NAME='Panasonic PT-3500U Rev4-02'(DEV vdvTP, DEV vdvProj, DEV dvProj)
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
	Set baud to 9600,N,8,1,485 DISABLE
	define_module 'Panasonic PT-3500U Rev4-02' proj1(vdvTP_DISP1,vdvDisp1,dvProj)
*)

#INCLUDE 'HoppSNAPI Rev4-01.axi'

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
CHAR cCmdStr[40][20]	
CHAR cPollStr[2][20]
CHAR cRespStr[35][20]

integer nProjOnFB
integer nProjOffFB

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
([vdvTP,VD_SRC_RGB1],[vdvTP,VD_SRC_VID1],[vdvTP,VD_SRC_VGA1])

([vdvProj,VD_PWR_ON_FB],[vdvProj,VD_WARMING_FB],[vdvProj,VD_COOLING_FB],[vdvProj,VD_PWR_OFF_FB])
([vdvProj,VD_MUTE_ON_FB],[vdvProj,VD_MUTE_OFF_FB])
([vdvProj,VD_SRC_RGB1_FB],[vdvProj,VD_SRC_VID1_FB],[vdvProj,VD_SRC_VGA1_FB])

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
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
		{			
			IF([vdvProj,VD_PWR_OFF_FB]) 
			{
				if(nCmd=VD_PWR_ON) CmdExecuted()
				ON[vdvProj,VD_WARMING_FB]
				ON[vdvTP,VD_PWR_ON]
				wait 200 
				{
					ON[vdvProj,VD_PWR_ON_FB]
					ON[vdvTP,VD_PWR_ON]
				}
			}
			else if (![vdvProj,VD_WARMING_FB])
			{	
				if(nCmd=VD_PWR_ON) CmdExecuted()
				ON[vdvTP,VD_PWR_ON]
				ON[vdvProj,VD_PWR_ON_FB]
			}
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1)):
		{	
			IF([vdvProj,VD_PWR_ON_FB]) 
			{
				if(nCmd=VD_PWR_OFF) CmdExecuted()
				on[vdvProj,VD_COOLING_FB]
				ON[vdvTP,VD_PWR_OFF]
				wait 600
				{
					on[vdvProj,VD_PWR_OFF_FB]
					ON[vdvTP,VD_PWR_OFF]
				}
			}
			else if (![vdvProj,VD_COOLING_FB])
			{
				if(nCmd=VD_PWR_OFF) CmdExecuted()
				ON[vdvProj,VD_PWR_OFF_FB]
				ON[vdvTP,VD_PWR_OFF]
			}
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_RGB1],1)):
		{
			ON[vdvProj,VD_SRC_RGB1_FB]
			ON[vdvTP,VD_SRC_RGB1]
			if (nCmd=VD_SRC_RGB1) 
			{
				CmdExecuted()
				pulse[vdvProj,VD_PCADJ]
			}
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VID1],1)):
		{
			ON[vdvProj,VD_SRC_VID1_FB]
			ON[vdvTP,VD_SRC_VID1]
			if (nCmd=VD_SRC_VID1) 
			{
				CmdExecuted()
			}
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VGA1],1)):
		{
			ON[vdvProj,VD_SRC_VGA1_FB]
			ON[vdvTP,VD_SRC_VGA1]
			if (nCmd=VD_SRC_VGA1) 
			{
				CmdExecuted()
				pulse[vdvProj,VD_PCADJ]
			}
		}
	}

	
	//SWITCH(nPollType)
//	{
//		CASE PollPower:
//		{
//			SELECT
//			{
//				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
//				{			
//					ON[vdvTP,VD_PWR_ON]
//					ON[vdvProj,VD_PWR_ON_FB]
//					IF(nCmd = VD_PWR_ON) CmdExecuted()
//				}
//				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1)):
//				{	
//					ON[vdvProj,VD_PWR_OFF_FB]
//					ON[vdvTP,VD_PWR_OFF]
//					IF(nCmd = VD_PWR_OFF) CmdExecuted()
//				}
//				ACTIVE(FIND_STRING(cCompStr,"'40',$0D",1)): 	//Warming Up
//				{
//					ON[vdvProj,VD_WARMING_FB]
//					ON[vdvTP,VD_PWR_ON]
//					IF(ncmd = VD_PWR_ON) CmdExecuted()
//				}
//				ACTIVE(FIND_STRING(cCompStr,"'20',$0D",1)):	//Cooling Down
//				{
//					ON[vdvProj,VD_COOLING_FB]
//					ON[vdvTP,VD_PWR_OFF]
//					IF(ncmd = VD_PWR_OFF) CmdExecuted()
//				}
//				ACTIVE(FIND_STRING(cResp,"'04',$0D",1) || FIND_STRING(cResp,"'10',$0D",1) || 
//							 FIND_STRING(cResp,"'28',$0D",1) || FIND_STRING(cResp,"'21',$0D",1) ||
//							 FIND_STRING(cResp,"'88',$0D",1) || FIND_STRING(cResp,"'24',$0D",1) ||
//							 FIND_STRING(cResp,"'81',$0D",1) || FIND_STRING(cResp,"'2C',$0D",1) || 
//							 FIND_STRING(cResp,"'8C',$0D",1)):		//Error Message
//				{
//					ON[vdvProj,VD_ERROR_FB]
//				}			
//			}	
//		}
//		CASE PollInput:
//		{
//
//					IF(nCmd = VD_SRC_RGB1)
//					{
//						ON[vdvProj,VD_SRC_RGB1_FB]
//						ON[vdvTP,VD_SRC_RGB1]
//						CmdExecuted()
//					}
//
//					IF(nCmd = VD_SRC_VID1)
//					{
//						ON[vdvProj,VD_SRC_VID1_FB]
//						ON[vdvTP,VD_SRC_VID1]
//						CmdExecuted()
//					}
//
//		}

}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "$02,'ADZZ;PON',$03"	//on
cCmdStr[VD_PWR_OFF]			= "$02,'ADZZ;POF',$03"	//off
cCmdStr[VD_SRC_RGB1]  		= "$02,'ADZZ;IIS:RG1',$03"	//input2 RGBHV
cCmdStr[VD_SRC_VGA1]  		= "$02,'ADZZ;IIS:RG2',$03"	//input2 VGA
cCmdStr[VD_SRC_VID1] 		= "$02,'ADZZ;IIS:VID',$03"	//input2 video\
cCmdStr[VD_PCADJ]			= "$02,'ADZZ;OAS',$03" //PC Adjust

cPollStr[PollPower]		= "$02,'ADZZ;QPW',$03"	//pwr
cPollStr[PollInput] 	= "$02,'ADZZ;QIN',$03"	//input

cRespStr[VD_PWR_ON] 		= "'001'"
cRespStr[VD_PWR_OFF]		= "'000'"
cRespStr[VD_SRC_RGB1]		= "'RG1'"
cRespStr[VD_SRC_VGA1]		= "'RG2'"
cRespStr[VD_SRC_VID1]		= "'VID'"

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
				ACTIVE(FIND_STRING(cBuff,"$03",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$03",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$03",1)):
				{
					nPos=FIND_STRING(cBuff,"$03",1)
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
	switch(timeline.sequence)
	{
		case PollPower: SEND_STRING dvProj,"cPollStr[TIMELINE.SEQUENCE]"
		case PollInput: if ([vdvProj,VD_PWR_ON_FB]) SEND_STRING dvProj,"cPollStr[TIMELINE.SEQUENCE]"
	}
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
				CASE VD_SRC_VGA1:
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollInput
					}
					ELSE IF(![vdvProj,VD_PWR_ON_FB])
					{
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						nPollType = PollPower
					}
				}
				case VD_PCADJ:
				{
					if([vdvProj,VD_PWR_ON_FB])SEND_STRING dvProj,cCmdStr[nCmd]
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
		send_string 0,"'Panasonic PT-3500U receiving channel ',itoa(channel.channel)"
		SELECT
		{
			ACTIVE(channel.channel<VD_POLL_BEGIN):
			{
				nCmd=channel.channel
				StartCommand()
			}
			ACTIVE(channel.channel=VD_POLL_BEGIN):
			{
				send_string 0,"'Panasonic PT-3500U creating lTLPoll'"
				TIMELINE_CREATE(lTLPoll,lPollArray,4,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}

BUTTON_EVENT[vdvTP,btn_PROJ]
{
	PUSH:
	{
		to[button.input]
		nCmd=get_last(btn_PROJ)
		StartCommand()
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

nProjOnFB=[vdvProj,VD_PWR_ON_FB]
nProjOffFB=[vdvProj,VD_PWR_OFF_FB]
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


