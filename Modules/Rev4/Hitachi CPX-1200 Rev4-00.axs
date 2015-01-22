MODULE_NAME='Hitachi CPX-1200 Rev4-00'(DEV vdvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)

(***********************************************************)
(*   
	Set baud to 19200,N,8,1,485 DISABLE
	define_module 'Hitachi CPX-1200 Rev4-00' proj1(vdvTP_DISP1,vdvDISP1,dvProj)
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

LONG lTLPoll		=	2001
LONG lTLCmd         =	2002

INTEGER PollPower 	=	1
INTEGER PollInput 	=	2
integer PollMute	=	3

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
CHAR cPollStr[4][20]
CHAR cRespStr[52][20]

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
([vdvTP,VD_SRC_RGB1],[vdvTP,VD_SRC_VGA1],[vdvTP,VD_SRC_VID1],[vdvTP,VD_SRC_SVID],[vdvTP,VD_SRC_CMPNT1])

([vdvProj,VD_PWR_ON_FB],[vdvProj,VD_WARMING_FB],[vdvProj,VD_COOLING_FB],[vdvProj,VD_PWR_OFF_FB])
([vdvProj,VD_SRC_RGB1_FB],[vdvProj,VD_SRC_VGA1_FB],[vdvProj,VD_SRC_VID1_FB],[vdvProj,VD_SRC_SVID_FB],[vdvProj,VD_SRC_CMPNT1_FB])

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
	send_string 0,"'Parsing: ',cCompStr,' Poll Type: ',nPollType"
	SWITCH(nPollType)
	{
		CASE PollPower:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"$06",1)):
				{
					send_string 0,"'Found $06, nCmd=',itoa(nCmd)"
					if(nCmd=VD_PWR_ON)
					{
						ON[vdvProj,VD_WARMING_FB]
						ON[vdvTP,VD_PWR_ON]
						CmdExecuted()
					}
					if(nCmd=VD_SRC_VGA1 or nCmd=VD_SRC_RGB1 or nCmd=VD_SRC_CMPNT1 or nCmd=VD_SRC_SVID or nCmd=VD_SRC_VID1) 
					{
						ON[vdvProj,VD_WARMING_FB]
						ON[vdvTP,VD_PWR_ON]
					}
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
				{			
					ON[vdvTP,VD_PWR_ON]
					ON[vdvProj,VD_PWR_ON_FB]
					IF(nCmd = VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1) and ![vdvProj,VD_WARMING_FB]):
				{	
					ON[vdvProj,VD_PWR_OFF_FB]
					ON[vdvTP,VD_PWR_OFF]
					IF(nCmd = VD_PWR_OFF) CmdExecuted()
				}
//				ACTIVE(FIND_STRING(cCompStr,"'40',$0D",1)): 	//Warming Up
//				{
//					ON[vdvProj,VD_WARMING_FB]
//					ON[vdvTP,VD_PWR_ON]
//					IF(ncmd = VD_PWR_ON) CmdExecuted()
//				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_COOLING],1)):	//Cooling Down
				{
					ON[vdvProj,VD_COOLING_FB]
					ON[vdvTP,VD_PWR_OFF]
					IF(ncmd = VD_PWR_OFF) CmdExecuted()
				}
			}	
		}
		CASE PollInput:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VGA1],1)):
				{
					ON[vdvProj,VD_SRC_VGA1_FB]
					ON[vdvTP,VD_SRC_VGA1]
					IF(nCmd = VD_SRC_VGA1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_RGB1],1)):
				{
					ON[vdvProj,VD_SRC_RGB1_FB]
					ON[vdvTP,VD_SRC_RGB1]
					IF(nCmd = VD_SRC_RGB1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_CMPNT1],1)):
				{
					ON[vdvProj,VD_SRC_CMPNT1_FB]
					ON[vdvTP,VD_SRC_CMPNT1]
					IF(nCmd = VD_SRC_CMPNT1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VID1],1)):
				{
					ON[vdvProj,VD_SRC_VID1_FB]
					ON[vdvTP,VD_SRC_VID1]
					IF(nCmd = VD_SRC_VID1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_SVID],1)):
				{
					ON[vdvProj,VD_SRC_SVID_FB]
					ON[vdvTP,VD_SRC_SVID]
					IF(nCmd = VD_SRC_SVID) CmdExecuted()
				}
			}	
		}	
		CASE PollMute:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_MUTE_ON],1)):
				{			
					ON[vdvTP,VD_MUTE_ON]
					ON[vdvProj,VD_MUTE_ON_FB]
					IF(nCmd = VD_MUTE_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_MUTE_OFF],1)):
				{	
					ON[vdvProj,VD_MUTE_OFF_FB]
					ON[vdvTP,VD_MUTE_OFF]
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

cCmdStr[VD_PWR_ON]			=	"$BE,$EF,$03,$06,$00,$BA,$D2,$01,$00,$00,$60,$01,$00"	//on
cCmdStr[VD_PWR_OFF]			=	"$BE,$EF,$03,$06,$00,$2A,$D3,$01,$00,$00,$60,$00,$00"	//off

cCmdStr[VD_SRC_VGA1]		=	"$BE,$EF,$03,$06,$00,$FE,$D2,$01,$00,$00,$20,$00,$00"   //VGA
cCmdStr[VD_SRC_RGB1]  		=	"$BE,$EF,$03,$06,$00,$3E,$D0,$01,$00,$00,$20,$04,$00"	//RGBHV
cCmdStr[VD_SRC_CMPNT1]		=	"$BE,$EF,$03,$06,$00,$AE,$D1,$01,$00,$00,$20,$05,$00"	//Y/Pb/Pr
cCmdStr[VD_SRC_VID1] 		=	"$BE,$EF,$03,$06,$00,$6E,$D3,$01,$00,$00,$20,$01,$00"	//video
cCmdStr[VD_SRC_SVID]		=	"$BE,$EF,$03,$06,$00,$9E,$D3,$01,$00,$00,$20,$02,$00"	//svideo

cCmdStr[VD_PCADJ]			=	"$BE,$EF,$03,$06,$00,$91,$D0,$06,$00,$0A,$20,$00,$00"	//pc adjust

cCmdStr[VD_MUTE_ON]			=	"$BE,$EF,$03,$06,$00,$6B,$D9,$01,$00,$20,$30,$01,$00"
cCmdStr[VD_MUTE_OFF]		=	"$BE,$EF,$03,$06,$00,$FB,$D8,$01,$00,$20,$30,$00,$00"

cPollStr[PollPower]			=	"$BE,$EF,$03,$06,$00,$19,$D3,$02,$00,$00,$60,$00,$00"	//pwr
cPollStr[PollInput] 		=	"$BE,$EF,$03,$06,$00,$CD,$D2,$02,$00,$00,$20,$00,$00"	//input
cPollStr[PollMute]			=	"$BE,$EF,$03,$06,$00,$C8,$D8,$02,$00,$20,$30,$00,$00"  //mute

cRespStr[VD_PWR_ON] 		=	"$1D,$01,$00"
cRespStr[VD_PWR_OFF]		=	"$1D,$00,$00"
cRespStr[VD_COOLING]		=	"$1D,$02,$00"

cRespStr[VD_MUTE_ON] 		=	"$1D,$01,$00"
cRespStr[VD_MUTE_OFF]		=	"$1D,$00,$00"


cRespStr[VD_SRC_VGA1]		=	"$1D,$00,$00" //VGA
cRespStr[VD_SRC_RGB1]  		=	"$1D,$04,$00"	//RGBHV
cRespStr[VD_SRC_CMPNT1]		=	"$1D,$05,$00"	//Y/Pb/Pr
cRespStr[VD_SRC_VID1] 		=	"$1D,$01,$00"	//video
cRespStr[VD_SRC_SVID]		=	"$1D,$02,$00"	//svideo


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
		LOCAL_VAR CHAR cFullStr[100]
		LOCAL_VAR CHAR cBuff[255]
		
		cBuff = "cBuff,data.text"
		send_string 0,"'cBuff: ',cBuff"
		WHILE(LENGTH_STRING(cBuff))
		{
			SELECT
			{
				active(find_string(cBuff,"$1D",1) and find_string(cBuff,"$1D",2)):
				{
					cFullStr=left_string(cBuff,find_string(cBuff,"$1D",2)-1)
					remove_string(cBuff,cFullStr,1)
					parse(cFullStr)
					send_string 0,"'Sent to Parse: ',cFullStr"
				}
				active(find_string(cBuff,"$1D",1)):
				{
					cFullStr=cBuff
					cBuff=''
					parse(cFullStr)
					send_string 0,"'Sent to Parse: ',cFullStr"
				}
				active(cBuff="$06"):
				{
					cFullStr=cBuff
					cBuff=''
					parse(cFullStr)
				}
				ACTIVE(1):
				{
					send_string 0,"'Cleared: ',cBuff"
					cBuff=''
				}
			}
		}	
	}
}

TIMELINE_EVENT[lTLPoll]				//Projector Polling
{
	nPollType = TIMELINE.SEQUENCE
	SEND_STRING dvProj,"cPollStr[TIMELINE.SEQUENCE]"
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
				CASE VD_SRC_VGA1:
				CASE VD_SRC_CMPNT1:
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollInput
					}
					IF([vdvProj,VD_WARMING_FB])
					{
						nPollType=PollPower
					}
					IF([vdvProj,VD_PWR_OFF_FB] || [vdvProj, VD_COOLING_FB])
					{
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
				CASE VD_PCADJ:
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
				TIMELINE_CREATE(lTLPoll,lPollArray,3,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}

BUTTON_EVENT[vdvTP,btn_PROJ]
{
	PUSH:
	{
		//to[button.input]
		nCmd = GET_LAST(btn_PROJ)
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


