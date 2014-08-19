module_name='Smartboard 8055i Rev5-00'(dev dvTP, dev vdvSmart, dev dvSmart)
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
	define_module 'Smartboard 8055i Rev5-00' smrt1(vdvTP_DISP1,vdvDisp1,dvSmartBoard)
	Set baud to 19200,N,8,1,485 DISABLE
*)

#include 'HoppSNAPI Rev5-11.axi'

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
volatile		char	cCmdStr[40][30]	
volatile		char	cPollStr[2][30]
volatile		char	cRespStr[51][30]

volatile		integer	nPollType

volatile		integer	nCmd

volatile		integer		x

volatile		integer		nActivePower
volatile		integer		nActiveInput

volatile		integer		nPower[]={VD_PWR_ON,VD_PWR_OFF,VD_WARMING,VD_COOLING}
volatile		integer		nInput[]={VD_SRC_VGA1,VD_SRC_AUX1}


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
			nActivePower=VD_PWR_ON
			IF(nCmd = VD_PWR_ON) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1) or find_string(cCompStr,"'owerstate=standby'",1) or find_string(cCompStr,"'owerstate=off'",1)):
		{	
			nActivePower=VD_PWR_OFF
			IF(nCmd = VD_PWR_OFF) CmdExecuted()
		}
		ACTIVE((FIND_STRING(cCompStr,cRespStr[VD_WARMING],1)) or (find_string(cCompStr,"'urning On'",1))): 	//Warming Up
		{
			nActivePower=VD_WARMING
			IF(ncmd = VD_PWR_ON) CmdExecuted()
		}
		ACTIVE((FIND_STRING(cCompStr,cRespStr[VD_COOLING],1)) or (find_string(cCompStr,"'Turning Off'",1))):	//Cooling Down
		{
			nActivePower=VD_COOLING
			IF(ncmd = VD_PWR_OFF) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_VGA1],1)):
		{
			nActiveInput=VD_SRC_VGA1
			if(nCmd=VD_SRC_VGA1) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_AUX1],1)):
		{
			nActiveInput=VD_SRC_AUX1
			if(nCmd=VD_SRC_AUX1) CmdExecuted()
		}		
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "'set powerstate=on',$0D"	//on
cCmdStr[VD_PWR_OFF]			= "'set powerstate=off',$0D"	//off

cCmdStr[VD_SRC_VGA1]		= "'set input=VGA',$0D"
cCmdStr[VD_SRC_AUX1]		= "'set input=HDMI1',$0D"

cPollStr[PollPower]			= "'get powerstate',$0D"
cPollStr[PollInput]			= "'get input',$0D"	

cRespStr[VD_PWR_ON] 		= "'owerstate=on'"
cRespStr[VD_PWR_OFF]		= "'owerstate=idle'"
cRespStr[VD_COOLING]		= "'owerstate=cooling'"
cRespStr[VD_WARMING]		= "'owerstate=powering'"

cRespStr[VD_SRC_VGA1]		= "'input=VGA'"
cRespStr[VD_SRC_AUX1]		= "'input=HDMI1'"


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

DATA_EVENT[dvSmart]
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
	SEND_STRING dvSmart,"cPollStr[nPollType]"
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
				CASE VD_PWR_OFF: 
				{
					SEND_STRING dvSmart,cCmdStr[nCmd]
				}
				CASE VD_SRC_VGA1:
				CASE VD_SRC_AUX1:
				{
					IF(nActivePower=VD_PWR_ON)
					{
						SEND_STRING dvSmart,cCmdStr[nCmd]
						nPollType=PollInput
					}
					ELSE
					{
						SEND_STRING dvSmart,cCmdStr[VD_PWR_ON]
						nPollType=PollPower
					}
				}
				
			}
		}
		CASE 2:	//2nd time
		{
			SEND_STRING dvSmart,cPollStr[nPollType]
		}
	}
}

CHANNEL_EVENT[vdvSmart,0]
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

CHANNEL_EVENT[vdvSmart,0]
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
				TIMELINE_CREATE(tlPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
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
	[dvSmart,nPower[x]]=nActivePower=nPower[x]
	[dvTP,nPower[x]]=nActivePower=nPower[x]
}

for(x=1;x<=length_array(nInput);x++)
{
	[dvSmart,nInput[x]]=nActiveInput=nInput[x]
	[dvTP,nInput[x]]=nActiveInput=nInput[x]
}


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


