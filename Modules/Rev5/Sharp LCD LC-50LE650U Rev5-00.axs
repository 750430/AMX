MODULE_NAME='Sharp LCD LC-50LE650U Rev5-00'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:26:22        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*  

	define_module 'Sharp LCD LC-50LE650U Rev5-00' LCD1(vdvTP_DISP1,vdvDISP1,dvLCD1)
	
	Set Baud to 9600,N,8,1,485 DISABLE

*)

#INCLUDE 'HoppSNAPI Rev5-06.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         		= 2002
long lTLRampUp				= 2003
long lTLRampDown			= 2004

PollPwr 	=	1
PollSrc		=	2
PollMute	=	3

MAX_VOL		=	60

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {4100,4100,4100}
LONG lCmdArray[]				=	{1510,1510}
long lRampTimes[]				=	{400}

INTEGER nPollType = 0
integer x
integer nNumPanels

CHAR cCmdStr[80][20]	
CHAR cPollStr[3][20]

persistent integer nVolume=20

volatile	integer	nMuteFeedback
volatile	integer	nCmdPwrOn

volatile		integer		nPolling
volatile		integer		nCommanding

INTEGER nCmd=0

integer		nActivePower
integer		nActiveInput
integer 	nActiveMute

define_variable //Channel Arrays

integer		nPower[]={VD_PWR_ON,VD_PWR_OFF,VD_WARMING,VD_COOLING}
integer		nInput[]={VD_SRC_VGA1,VD_SRC_VGA2,VD_SRC_VGA3,VD_SRC_DVI1,VD_SRC_DVI2,VD_SRC_DVI3,VD_SRC_RGB1,VD_SRC_RGB2,VD_SRC_RGB3,
						VD_SRC_HDMI1,VD_SRC_HDMI2,VD_SRC_HDMI3,VD_SRC_SVID,VD_SRC_AUX1,VD_SRC_AUX2,VD_SRC_AUX3,VD_SRC_AUX4}
integer		nMute[]={VD_MUTE_ON,VD_MUTE_OFF}

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvTP,VD_SRC_HDMI1],[dvTP,VD_SRC_HDMI2],[dvTP,VD_SRC_HDMI3],[dvTP,VD_SRC_AUX1],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_VID1],[dvTP,VD_SRC_VID2],[dvTP,VD_SRC_VGA1])
 
([dvLCD,VD_PWR_ON],[dvLCD,VD_PWR_OFF],[dvLCD,VD_COOLING],[dvLCD,VD_WARMING])
([dvLCD,VD_SRC_HDMI1],[dvLCD,VD_SRC_HDMI2],[dvLCD,VD_SRC_HDMI3],[dvLCD,VD_SRC_AUX1],[dvLCD,VD_SRC_CMPNT1],[dvLCD,VD_SRC_VID1],[dvLCD,VD_SRC_VID2],[dvLCD,VD_SRC_VGA1])
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION CmdExecuted()
{
	ncmd=0
	nCmdPwrOn=0
	if(timeline_active(lTLCmd)) TIMELINE_KILL(lTLCmd)
	TIMELINE_RESTART(lTLPoll)
}
DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nVar
	
//	if(find_string(cCompStr,"'ERR'",1) and timeline_active(lTLPoll)) SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE]"
//Dont uncomment this unless you can figure out how to stop error chaining from happening.
	
	SWITCH(nPollType)
	{
		CASE PollPwr:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)||FIND_STRING(cCompStr,"'2'",1)):
				{
					ON[dvLCD,VD_PWR_ON]
					ON[dvTP,VD_PWR_ON]
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'0'",1)):
				{
					ON[dvLCD,VD_PWR_OFF]
					ON[dvTP,VD_PWR_OFF]
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'OK'",1)):
				{
					if(nCmd=VD_PWR_OFF) on[dvLCD,VD_COOLING]
					if(nCmd=VD_PWR_ON or nCmdPwrOn) on[dvLCD,VD_WARMING]
				}
			}	
		}
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)):
				{
					ON[dvLCD,VD_SRC_HDMI1]
					ON[dvTP,VD_SRC_HDMI1]
					IF(nCmd=VD_SRC_HDMI1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					ON[dvLCD,VD_SRC_HDMI2]
					ON[dvTP,VD_SRC_HDMI2]
					IF(nCmd=VD_SRC_HDMI2) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'3'",1)):
				{
					ON[dvLCD,VD_SRC_HDMI3]
					ON[dvTP,VD_SRC_HDMI3]
					IF(nCmd=VD_SRC_HDMI3) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'4'",1)):
				{
					ON[dvLCD,VD_SRC_AUX1]
					ON[dvTP,VD_SRC_AUX1]
					IF(nCmd=VD_SRC_AUX1) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'5'",1)):
				{
					ON[dvLCD,VD_SRC_CMPNT1]
					ON[dvTP,VD_SRC_CMPNT1]
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()	
				}				
				ACTIVE(FIND_STRING(cCompStr,"'6'",1)):
				{
					ON[dvLCD,VD_SRC_VID1]
					ON[dvTP,VD_SRC_VID1]
					IF(nCmd=VD_SRC_VID1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'7'",1)):
				{
					ON[dvLCD,VD_SRC_VID2]
					ON[dvTP,VD_SRC_VID2]
					IF(nCmd=VD_SRC_VID2) CmdExecuted()	
				}		
				ACTIVE(FIND_STRING(cCompStr,"'8'",1)):
				{
					ON[dvLCD,VD_SRC_VGA1]
					ON[dvTP,VD_SRC_VGA1]
					IF(nCmd=VD_SRC_VGA1) CmdExecuted()	
				}	
			}
		}
		CASE PollMute: 
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)):
				{
					IF(nCmd=VD_VOL_MUTE_TOG and !nActiveMute) 
					{
						CmdExecuted()
					}
					on[nActiveMute]
					nMuteFeedback=nActiveMute
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					IF(nCmd=VD_VOL_MUTE_TOG and nActiveMute)
					{
						CmdExecuted()
					}
					off[nActiveMute]
					nMuteFeedback=nActiveMute
				}
				active(find_string(cCompStr,"'ERR'",1)):
				{
					CmdExecuted()
				}
			}
		}	
	}	
}

define_function RampUp()
{
	TIMELINE_PAUSE(lTLPoll)
	if(!timeline_active(lTLRampUp)) timeline_create(ltlRampUp,lRampTimes,length_array(lRampTimes),timeline_relative,timeline_repeat)
}

define_function RampDown()
{
	TIMELINE_PAUSE(lTLPoll)
	if(!timeline_active(lTLRampDown)) timeline_create(ltlRampDown,lRampTimes,length_array(lRampTimes),timeline_relative,timeline_repeat)
}

define_function StopRamp()
{
	if(timeline_active(lTLRampUp)) timeline_kill(lTLRampUp)
	if(timeline_active(lTLRampDown)) timeline_kill(lTLRampDown)
	TIMELINE_RESTART(lTLPoll)
}

define_function send_volume()
{
	if(nVolume>=10) send_string dvLCD,"'VOLM',itoa(nVolume),'  ',$0D"
	else send_string dvLCD,"'VOLM0',itoa(nVolume),'  ',$0D"
	send_level dvTP,1,(255*nVolume)/MAX_VOL
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		=	"'POWR1   ',$0D" 			
cCmdStr[VD_PWR_OFF]		=	"'POWR0   ',$0D"
cCmdStr[VD_SRC_HDMI1]	=	"'IAVD1   ',$0D"	//hdmi 1
cCmdStr[VD_SRC_HDMI2]	=	"'IAVD2   ',$0D"	//hdmi 2
cCmdStr[VD_SRC_HDMI3]	=	"'IAVD3   ',$0D"	//hdmi 3 
cCmdStr[VD_SRC_AUX1]	=	"'IAVD4   ',$0D"	//hdmi 4
cCmdStr[VD_SRC_CMPNT1]	=	"'IAVD5   ',$0D"	//component
cCmdStr[VD_SRC_VID1]	=	"'IAVD6   ',$0D"	//video
cCmdStr[VD_SRC_VID2]	=	"'IAVD7   ',$0D"	//video
cCmdStr[VD_SRC_VGA1]	=	"'IAVD8   ',$0D"	//pc in
cCmdStr[VD_ASPECT1]		=	"'WIDE1   ',$0D"	//wide (1,2,3,4)
cCmdStr[VD_ASPECT2]		=	"'WIDE2   ',$0D"	//normal (1,2)
cCmdStr[VD_VOL_MUTE_ON]	=	"'MUTE1   ',$0D"
cCmdStr[VD_VOL_MUTE_OFF]=	"'MUTE2   ',$0D"
        
cPollStr[PollPwr]		=	"'POWR????',$0D"		
cPollStr[PollSrc]		=	"'IAVD????',$0D"					
cPollStr[PollMute]		=	"'MUTE????',$0D"

nNumPanels=length_array(dvTP)

WAIT 200
{
	send_string dvLCD,"'RSPW1   ',$0D"
	IF(!TIMELINE_ACTIVE(lTLPoll))
		TIMELINE_CREATE(lTLPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvLCD]
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

data_event[dvTP]
{
	online:
	{
		send_volume()
	}
}

TIMELINE_EVENT[lTLPoll]
{
	nPollType=TIMELINE.SEQUENCE
	switch(nPollType)
	{
		case PollMute:
		case PollSrc: if(nActivePower=VD_PWR_ON) SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE]"
		case PollPwr: SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE]"
	}
}

TIMELINE_EVENT[lTLCmd]
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
					SEND_STRING dvLCD,cCmdStr[nCmd]
					nPollType=PollPwr
				}
				CASE VD_SRC_HDMI1:
				CASE VD_SRC_HDMI2:
				CASE VD_SRC_HDMI3:
				CASE VD_SRC_AUX1:
				CASE VD_SRC_VID1:
				CASE VD_SRC_VID2:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_CMPNT1:
				{
					IF([dvLCD,VD_PWR_ON])
					{
						SEND_STRING dvLCD,cCmdStr[nCmd]
						nPollType=PollSrc
					}
					ELSE
					{
						nPollType=PollPwr
						on[nCmdPwrOn]
						SEND_STRING dvLCD,cCmdStr[VD_PWR_ON]
					}
				}
				CASE VD_VOL_MUTE_TOG:
				{
					switch(nActiveMute)
					{
						case 1: send_string dvLCD,cCmdStr[VD_VOL_MUTE_OFF]
						case 0: send_string dvLCD,cCmdStr[VD_VOL_MUTE_ON]
					}
					nMuteFeedback=!nMuteFeedback
					nPollType=PollMute
				}					
			}
		}
		CASE 2:	//2nd time
		{
			IF(nPollType) SEND_STRING dvLCD,cPollStr[nPollType]
		}
	}
}

CHANNEL_EVENT[vdvLCD,0]
{
	ON:
	{
		SELECT
		{
			ACTIVE(channel.channel=VD_VOL_UP):
			{
				off[nActiveMute]
				off[nMuteFeedback]
				if(nVolume<MAX_VOL) nVolume++
				send_volume()
				RampUp()
			}
			ACTIVE(channel.channel=VD_VOL_DOWN):
			{
				off[nActiveMute]
				off[nMuteFeedback]
				if(nVolume>0) nVolume--
				send_volume()
				RampDown()
			}
			ACTIVE(channel.channel<200):
			{
				nCmd=channel.channel
				TIMELINE_PAUSE(lTLPoll)
				WAIT 1 
				{
					if(timeline_active(lTLCmd)) TIMELINE_KILL(lTLCmd)
					TIMELINE_CREATE(lTLCmd,lCmdArray,length_array(lCmdArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
				}
			}
			ACTIVE(channel.channel=200):
			{
				if(!timeline_active(lTLPoll)) TIMELINE_CREATE(lTLPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
	OFF:
	{
		switch(channel.channel)
		{
			case VD_VOL_UP:
			case VD_VOL_DOWN: StopRamp()
		}
	}
}

BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		to[button.input]
		to[vdvLCD,button.input.channel]
	}
}

timeline_event[lTLRampUp]
{
	if(timeline.repetition<5) nVolume=nVolume+5
	else nVolume=nVolume+10

	if (nVolume>MAX_VOL) nVolume=MAX_VOL
	
	send_volume()
}

timeline_event[lTLRampDown]
{
	if(timeline.repetition<5) 
	{
		if(nVolume>=5) nVolume=nVolume-5
		else nVolume=0
	}
	else
	{
		if(nVolume>=10) nVolume=nVolume-10
		else nVolume=0
	}
	
	send_volume()
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvLCD,VD_VOL_MUTE_ON]=nMuteFeedback
[dvLCD,VD_VOL_MUTE_OFF]=!nMuteFeedback
[dvTP,VD_VOL_MUTE_TOG]=nMuteFeedback

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

