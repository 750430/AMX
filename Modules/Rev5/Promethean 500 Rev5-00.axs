module_name='Promethean 500 Rev5-00'(dev dvTP, dev vdvBoard, dev dvBoard)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  
	 Written by: 		Jeff McAleer
	 Date: 			 	3/5/09
	 *)
(***********************************************************)
(*   
	define_module 'Promethean 500 Rev5-00' smrt1(vdvTP_DISP1,vdvDisp1,dvBoard)
	Set baud to 9600,N,8,1,485 DISABLE
*)

#include 'HoppSNAPI Rev5-08.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant

tlPoll		= 2001
tlCmd		= 2002

PollPower	=	1
PollInput	=	2



(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

volatile		long 	lPollArray[]	=	{3100,3100}
volatile		long	lCmdArray[]  	=	{510,510}

volatile		char	cResp[100]
volatile		char	cCmdStr[80][20]	
volatile		char	cPollStr[2][20]
volatile		char	cRespStr[80][20]

volatile		integer	nPollType

volatile		integer	nCmd

integer x


volatile		integer		nActivePower
volatile		integer		nActiveInput

volatile		integer		nPower[]={VD_PWR_ON,VD_PWR_OFF,VD_WARMING,VD_COOLING}
volatile		integer		nInput[]={VD_SRC_VGA1,VD_SRC_HDMI1}


(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
define_mutually_exclusive

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function CmdExecuted()
{
	nCmd=0
	timeline_kill(tlCmd)
	timeline_restart(tlPoll)
}

define_function StartCommand()
{
	timeline_pause(tlPoll)
	if(!timeline_active(tlCmd))
		wait 1 timeline_create(tlCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER x 
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
		{			
			if(nActivePower<>VD_COOLING)
			{
				nActivePower=VD_PWR_ON
				IF(nCmd = VD_PWR_ON) CmdExecuted()
			}
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1)):
		{	
			if(nActivePower<>VD_WARMING)
			{
				nActivePower=VD_PWR_OFF
				IF(nCmd = VD_PWR_OFF) CmdExecuted()
			}
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_VGA1],1)):
		{
			nActiveInput=VD_SRC_VGA1
			if(nCmd=VD_SRC_VGA1) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_HDMI1],1)):
		{
			nActiveInput=VD_SRC_HDMI1
			if(nCmd=VD_SRC_HDMI1) CmdExecuted()
		}		
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "'~PN',$0D"	//on
cCmdStr[VD_PWR_OFF]			= "'~PF',$0D"	//off

cCmdStr[VD_PCADJ]			= "'~AI',$0D"   //auto image

cCmdStr[VD_SRC_VGA1]		= "'~SR',$0D"
cCmdStr[VD_SRC_HDMI1]		= "'~SD',$0D"

cPollStr[PollPower]			= "'~qP',$0D"
cPollStr[PollInput]			= "'~qS',$0D"	

cRespStr[VD_PWR_ON] 		= "'On'"
cRespStr[VD_PWR_OFF]		= "'Off'"

cRespStr[VD_SRC_VGA1]		= "'RGB'"
cRespStr[VD_SRC_HDMI1]		= "'HDMI'"


WAIT 200
{
	IF(!TIMELINE_ACTIVE(tlPoll))
	{
		TIMELINE_CREATE(tlPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
	}
}
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvBoard]
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

TIMELINE_EVENT[tlPoll]				//Projector Polling
{
	nPollType=timeline.sequence
	SEND_STRING dvBoard,"cPollStr[nPollType]"
}

TIMELINE_EVENT[tlCmd]		//Projector Commands
{
	SWITCH(TIMELINE.SEQUENCE)
	{
		CASE 1:	//first time
		{
			SWITCH(nCmd)
			{
				CASE VD_PWR_ON:
				{
					SEND_STRING dvBoard,cCmdStr[nCmd]
					if(nActivePower<>VD_PWR_ON)	nActivePower=VD_WARMING
					nPollType=PollPower
				}
				CASE VD_PWR_OFF: 
				{
					SEND_STRING dvBoard,cCmdStr[nCmd]
					if(nActivePower<>VD_PWR_OFF) nActivePower=VD_COOLING
					nPollType=PollPower
				}
				CASE VD_SRC_VGA1:
				CASE VD_SRC_HDMI1:
				{
					IF(nActivePower=VD_PWR_ON)
					{
						SEND_STRING dvBoard,cCmdStr[nCmd]
						nPollType=PollInput
					}
					ELSE
					{
						SEND_STRING dvBoard,cCmdStr[VD_PWR_ON]
						nActivePower=VD_WARMING
						nPollType=PollPower
					}
				}
				
			}
		}
		CASE 2:	//2nd time
		{
			SEND_STRING dvBoard,cPollStr[nPollType]
		}
	}
}

CHANNEL_EVENT[vdvBoard,0]
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

CHANNEL_EVENT[vdvBoard,0]
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
				TIMELINE_CREATE(tlPoll,lPollArray,4,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}

BUTTON_EVENT[dvTP,0]
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
for(x=1;x<=length_array(nPower);x++) 
{
	[dvBoard,nPower[x]]=nActivePower=nPower[x]
	[dvTP,nPower[x]]=nActivePower=nPower[x]
}

for(x=1;x<=length_array(nInput);x++)
{
	[dvBoard,nInput[x]]=nActiveInput=nInput[x]
	[dvTP,nInput[x]]=nActiveInput=nInput[x]
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


