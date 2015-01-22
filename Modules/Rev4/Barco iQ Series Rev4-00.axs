MODULE_NAME='Barco iQ Series Rev4-00'(DEV vdvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(***********************************************************)
(*   
	Baudrate is selectable within the projector.  Set the baudrate on the unit, then in mainline
	
	This projector does not have Input polling.  It does generate an "Acknowledge" command whenever any command is received,
	so feedback is faked based on "acknowledge" responses from the projector.  As I write this, the only job this has been 
	installed on is OPIC, and I cannot yet state how accurate the feedback is, although I expect it to be correct at all times.
*)

#include 'HoppSNAPI Rev4-00.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant



long lTLPoll		= 2001
long lTLCmd         = 2002

integer PollPower 	= 1
integer PollMute 	= 2

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

non_volatile	integer		nProjAddr=$01

non_volatile	long		lPollArray[]={3100,3100}
non_volatile	long 		lCmdArray[]={510,510}

non_volatile	integer		nPollType
non_volatile	integer		nRestart

non_volatile	integer		nPowerOn
non_volatile	integer		nPowerOff
non_volatile	integer		nCooling
non_volatile	integer		nWarming

CHAR cResp[100]
CHAR cCmdStr[40][20]	
CHAR cPollStr[2][20]
CHAR cRespStr[50][20]
char cAckStr[20]

char cJeff[20]

non_volatile	integer		nStartupInput

INTEGER nPwrVerify = 0

INTEGER nCmd = 0
INTEGER btn_PROJ[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,
										 23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40}

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
define_mutually_exclusive

([vdvTP,VD_PWR_ON],[vdvTP,VD_PWR_OFF])
([vdvTP,VD_MUTE_ON],[vdvTP,VD_MUTE_OFF])
([vdvTP,VD_SRC_RGB1],[vdvTP,VD_SRC_VGA1],[vdvTP,VD_SRC_DVI1],[vdvTP,VD_SRC_VID],[vdvTP,VD_SRC_SVID])

([vdvProj,VD_PWR_ON_FB],[vdvProj,VD_WARMING_FB],[vdvProj,VD_COOLING_FB],[vdvProj,VD_PWR_OFF_FB])
([vdvProj,VD_MUTE_ON_FB],[vdvProj,VD_MUTE_OFF_FB])
([vdvProj,VD_SRC_RGB1_FB],[vdvProj,VD_SRC_VGA1_FB],[vdvProj,VD_SRC_DVI1_FB],[vdvProj,VD_SRC_VID_FB],[vdvProj,VD_SRC_SVID_FB])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION CmdExecuted()
{
	nCmd=0
	TIMELINE_KILL(lTLCmd)
	TIMELINE_RESTART(lTLPoll)
}

DEFINE_FUNCTION StartCommand()
{
	TIMELINE_PAUSE(lTLPoll)
	IF(!TIMELINE_ACTIVE(lTLCmd))
		WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER x 
	STACK_VAR INTEGER nLamp
	remove_string(cCompStr,"$FE,nProjAddr",1)
	cCompStr=left_string(cCompStr,length_string(cCompStr)-2)
	cJeff=cCompStr
	select
	{
		active(find_string(cCompStr,cAckStr,1)):
		{
			switch(nCmd)
			{
				case VD_SRC_RGB1:
				{
					on[vdvTP,VD_SRC_RGB1]
					on[vdvProj,VD_SRC_RGB1_FB]
				}
				case VD_SRC_VGA1:
				{
					on[vdvTP,VD_SRC_VGA1]
					on[vdvProj,VD_SRC_VGA1_FB]
				}
				case VD_SRC_VID:	
				{
					on[vdvTP,VD_SRC_VID]
					on[vdvProj,VD_SRC_VID_FB]
				}
				case VD_SRC_SVID:
				{
					on[vdvTP,VD_SRC_SVID]
					on[vdvProj,VD_SRC_SVID_FB]
				}
				case VD_SRC_DVI1:
				{
					on[vdvTP,VD_SRC_DVI1]
					on[vdvProj,VD_SRC_DVI1_FB]
				}
				case VD_MUTE_ON:
				{
					on[vdvTP,VD_MUTE_ON]
					on[vdvTP,VD_MUTE_TOG]
					on[vdvProj,VD_MUTE_ON_FB]
				}
				case VD_MUTE_OFF:
				{
					on[vdvTP,VD_MUTE_OFF]
					off[vdvTP,VD_MUTE_TOG]
					on[vdvProj,VD_MUTE_OFF_FB]
				}
				case VD_MUTE_TOG:
				{
					if([vdvProj,VD_MUTE_ON_FB])
					{
						on[vdvTP,VD_MUTE_OFF]
						off[vdvTP,VD_MUTE_TOG]
						on[vdvProj,VD_MUTE_OFF_FB]
					}
					else
					{
						on[vdvTP,VD_MUTE_ON]
						on[vdvTP,VD_MUTE_TOG]
						on[vdvProj,VD_MUTE_ON_FB]
					}
				}
				case VD_PWR_ON:
				{
					on[vdvTP,VD_PWR_ON]
					on[vdvProj,VD_WARMING_FB]
				}
				case VD_PWR_OFF:
				{
					on[vdvTP,VD_PWR_OFF]
					on[vdvProj,VD_COOLING_FB]
				}
			}
			CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_PWR_ON],1)):
		{
			on[vdvTP,VD_PWR_ON]
			on[vdvProj,VD_PWR_ON_FB]
			if(nStartupInput)
			{
				nCmd=nStartupInput
				off[nStartupInput]
				StartCommand()
			}
		}
		active(find_string(cCompStr,cRespStr[VD_PWR_OFF],1)):
		{
			on[vdvTP,VD_PWR_OFF]
			on[vdvProj,VD_PWR_OFF_FB]
			if (nRestart)
			{
				off[nRestart]
				nCmd=VD_PWR_ON
				StartCommand()
			}
		}
		active(find_string(cCompStr,cRespStr[VD_COOLING],1)):
		{
			on[vdvProj,VD_COOLING_FB]
		}
		active(find_string(cCompStr,cRespStr[VD_MUTE_ON],1)):
		{
			on[vdvTP,VD_MUTE_ON]
			on[vdvTP,VD_MUTE_TOG]
			on[vdvProj,VD_MUTE_ON_FB]
		}
		active(find_string(cCompStr,cRespStr[VD_MUTE_OFF],1)):
		{
			on[vdvTP,VD_MUTE_OFF]
			off[vdvTP,VD_MUTE_TOG]
			on[vdvProj,VD_MUTE_OFF_FB]
		}
	}
}
	
define_function integer calcchecksum(char cMsg[])
{
	stack_var integer nLoop
	stack_var integer nCheckSum
	
	off[nCheckSum]
	for (nLoop=1;nLoop<=length_string(cMsg);nLoop++)
	{
		nCheckSum=((nCheckSum+cMsg[nLoop])& $FF)
	}
	return nCheckSum
}

define_function send_to_proj(char Cmd[20])
{
	send_string dvProj,"$FE,nProjAddr,Cmd,calcchecksum("nProjAddr,Cmd"),$FF"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			=	"$65"	//on
cCmdStr[VD_PWR_OFF]			=	"$66"	//off
cCmdStr[VD_SRC_RGB1]		=	"$38,$01" //BNCs
cCmdStr[VD_SRC_VGA1]		=	"$38,$02" //D15
cCmdStr[VD_SRC_VID]			=	"$38,$03" //Composite Video
cCmdStr[VD_SRC_SVID]		=	"$38,$04" //S-Video
cCmdStr[VD_SRC_DVI1]		=	"$38,$05" //DVI

cCmdStr[VD_MUTE_ON]			=	"$20,$42,$00"	//mute on
cCmdStr[VD_MUTE_OFF]		=	"$20,$42,$01"	//mute off



cPollStr[PollPower]			=	"$67"	//pwr
cPollStr[PollMute] 			=	"$21,$42"	//extcmd mute

cRespStr[VD_PWR_ON] 		=	"$67,$21"
cRespStr[VD_PWR_OFF]		=	"$67,$20"
cRespStr[VD_COOLING]		=	"$67,$00"
cRespStr[VD_MUTE_OFF]		=	"$21,$42,$01"
cRespStr[VD_MUTE_ON]		=	"$21,$42,$00"
cAckStr						=	"$00,$06"

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
				ACTIVE(FIND_STRING(cBuff,"$FF",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$FF",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$FF",1)):
				{
					nPos=FIND_STRING(cBuff,"$FF",1)
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
	send_to_proj(cPollStr[TIMELINE.SEQUENCE])
}

TIMELINE_EVENT[lTLCmd]		//Projector Commands
{
	SWITCH(nCmd)
	{
		CASE VD_PWR_ON:
		{
			if ([vdvProj,VD_COOLING_FB])
			{
				on[nRestart]
			}
			else send_to_proj(cCmdStr[nCmd])
		}
		CASE VD_PWR_OFF: 
		{
			send_to_proj(cCmdStr[nCmd])
		}
		CASE VD_SRC_VID:
		CASE VD_SRC_SVID:
		CASE VD_SRC_RGB1:
		CASE VD_SRC_DVI1:
		CASE VD_SRC_VGA1:
		{
			IF(![vdvProj,VD_PWR_ON_FB])
			{
				nStartupInput=nCmd
				nCmd=VD_PWR_ON
			}
			send_to_proj(cCmdStr[nCmd])
		}
		CASE VD_MUTE_OFF:
		CASE VD_MUTE_ON:	
		{
			IF([vdvProj,VD_PWR_ON_FB])
			{
				send_to_proj(cCmdStr[nCmd])
			}
			ELSE CmdExecuted()
		}
		CASE VD_MUTE_TOG:
		{
			IF([vdvProj,VD_PWR_ON_FB])
			{
				IF([vdvProj,VD_MUTE_ON_FB]) nCmd=VD_MUTE_OFF
				ELSE nCmd = VD_MUTE_ON
				send_to_proj(cCmdStr[nCmd])
			}	
			ELSE CmdExecuted()
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
				TIMELINE_CREATE(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}

BUTTON_EVENT[vdvTP,btn_PROJ]
{
	PUSH:
	{
		to[button.input]
		pulse[vdvProj,get_last(btn_PROJ)]
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM
nWarming=[vdvProj,VD_WARMING_FB]
nCooling=[vdvProj,VD_COOLING_FB]
nPowerOn=[vdvProj,VD_PWR_ON_FB]
nPowerOff=[vdvProj,VD_PWR_OFF_FB]

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


