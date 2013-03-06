MODULE_NAME='Panasonic PT-3500U Rev5-00'(DEV dvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(***********************************************************)
(*   
	Set baud to 9600,N,8,1,485 DISABLE
	define_module 'Panasonic PT-3500U Rev5-00' proj1(vdvTP_DISP1,vdvDisp1,dvProj)
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

LONG lPollArray[]	= {3100,3100,3100}
LONG lCmdArray[]  =	{510,510}

INTEGER nPollType

CHAR cResp[100]
CHAR cCmdStr[40][20]	
CHAR cPollStr[3][20]
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

([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvTP,VD_SRC_RGB1],[dvTP,VD_SRC_VID1],[dvTP,VD_SRC_VGA1],[dvTP,VD_SRC_SVID])

([dvProj,VD_PWR_ON],[dvProj,VD_WARMING],[dvProj,VD_COOLING],[dvProj,VD_PWR_OFF])
([dvProj,VD_MUTE_ON],[dvProj,VD_MUTE_OFF])
([dvProj,VD_SRC_RGB1],[dvProj,VD_SRC_VID1],[dvProj,VD_SRC_VGA1],[dvProj,VD_SRC_SVID])

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
	switch(nPollType)
	{
		case PollPower:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
				{			
					IF([dvProj,VD_PWR_OFF]) 
					{
						if(nCmd=VD_PWR_ON) CmdExecuted()
						ON[dvProj,VD_WARMING]
						ON[dvTP,VD_PWR_ON]
						wait 200 
						{
							ON[dvProj,VD_PWR_ON]
							ON[dvTP,VD_PWR_ON]
						}
					}
					else if (![dvProj,VD_WARMING])
					{	
						if(nCmd=VD_PWR_ON) CmdExecuted()
						ON[dvTP,VD_PWR_ON]
						ON[dvProj,VD_PWR_ON]
					}
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1)):
				{	
					IF([dvProj,VD_PWR_ON]) 
					{
						if(nCmd=VD_PWR_OFF) CmdExecuted()
						on[dvProj,VD_COOLING]
						ON[dvTP,VD_PWR_OFF]
						wait 600
						{
							on[dvProj,VD_PWR_OFF]
							ON[dvTP,VD_PWR_OFF]
						}
					}
					else if (![dvProj,VD_COOLING])
					{
						if(nCmd=VD_PWR_OFF) CmdExecuted()
						ON[dvProj,VD_PWR_OFF]
						ON[dvTP,VD_PWR_OFF]
					}
				}
			}
		}
		case PollInput:
		{
			select
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_RGB1],1)):
				{
					ON[dvProj,VD_SRC_RGB1]
					ON[dvTP,VD_SRC_RGB1]
					if (nCmd=VD_SRC_RGB1) 
					{
						CmdExecuted()
						pulse[dvProj,VD_PCADJ]
					}
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VID1],1)):
				{
					ON[dvProj,VD_SRC_VID1]
					ON[dvTP,VD_SRC_VID1]
					if (nCmd=VD_SRC_VID1) 
					{
						CmdExecuted()
					}
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VGA1],1)):
				{
					ON[dvProj,VD_SRC_VGA1]
					ON[dvTP,VD_SRC_VGA1]
					if (nCmd=VD_SRC_VGA1) 
					{
						CmdExecuted()
						pulse[vdvProj,VD_PCADJ]
					}
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_SVID],1)):
				{
					ON[dvProj,VD_SRC_SVID]
					ON[dvTP,VD_SRC_SVID]
					if (nCmd=VD_SRC_SVID) 
					{
						CmdExecuted()
						pulse[vdvProj,VD_PCADJ]
					}
				}	
			}
		}
		case PollMute:
		{
			select
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_MUTE_ON],1)):
				{
					ON[dvProj,VD_MUTE_ON]
					ON[dvTP,VD_MUTE_ON]
					ON[dvTP,VD_MUTE_TOG]
					IF(nCmd = VD_MUTE_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_MUTE_OFF],1)):
				{
					ON[dvProj,VD_MUTE_OFF]
					ON[dvTP,VD_MUTE_OFF]
					OFF[dvTP,VD_MUTE_TOG]
					IF(nCmd = VD_MUTE_OFF) CmdExecuted()
				}
			}
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "$02,'ADZZ;PON',$03"	//on
cCmdStr[VD_PWR_OFF]			= "$02,'ADZZ;POF',$03"	//off
cCmdStr[VD_SRC_RGB1]  		= "$02,'ADZZ;IIS:RG1',$03"	//input2 RGBHV
cCmdStr[VD_SRC_VGA1]  		= "$02,'ADZZ;IIS:RG2',$03"	//input2 VGA
cCmdStr[VD_SRC_SVID]  		= "$02,'ADZZ;IIS:SVD',$03"	//SVid
cCmdStr[VD_SRC_VID1] 		= "$02,'ADZZ;IIS:VID',$03"	//input2 video
cCmdStr[VD_MUTE_ON] 		= "$02,'ADZZ;OSH:1',$03"	//input2 video
cCmdStr[VD_MUTE_OFF] 		= "$02,'ADZZ;OSH:0',$03"	//input2 video
cCmdStr[VD_PCADJ]			= "$02,'ADZZ;OAS',$03" //PC Adjust

cPollStr[PollPower]		= "$02,'ADZZ;QPW',$03"	//pwr
cPollStr[PollInput] 	= "$02,'ADZZ;QIN',$03"	//input
cPollStr[PollMute]		= "$02,'ADZZ;QSH',$03"	//mute

cRespStr[VD_PWR_ON] 		= "'001'"
cRespStr[VD_PWR_OFF]		= "'000'"
cRespStr[VD_SRC_RGB1]		= "'RG1'"
cRespStr[VD_SRC_VGA1]		= "'RG2'"
cRespStr[VD_SRC_VID1]		= "'VID'"
cRespStr[VD_SRC_SVID]		= "'SVD'"
cRespStr[VD_MUTE_ON]		= "'1'"
cRespStr[VD_MUTE_OFF]		= "'0'"

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
		case PollMute:
		case PollInput: if ([dvProj,VD_PWR_ON]) SEND_STRING dvProj,"cPollStr[TIMELINE.SEQUENCE]"
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
				CASE VD_SRC_SVID:
				{
					IF([dvProj,VD_PWR_ON])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollInput
					}
					ELSE IF(![dvProj,VD_PWR_ON])
					{
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						nPollType = PollPower
					}
				}
				case VD_PCADJ:
				{
					if([dvProj,VD_PWR_ON])SEND_STRING dvProj,cCmdStr[nCmd]
					CmdExecuted()
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
				TIMELINE_CREATE(lTLPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}

BUTTON_EVENT[dvTP,btn_PROJ]
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

nProjOnFB=[dvProj,VD_PWR_ON]
nProjOffFB=[dvProj,VD_PWR_OFF]
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


