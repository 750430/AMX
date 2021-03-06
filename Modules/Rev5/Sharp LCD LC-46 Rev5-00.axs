MODULE_NAME='Sharp LCD LC-46 Rev5-00'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:26:22        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*  

	define_module 'Sharp LCD LC-46 Rev5-00' LCD1(vdvTP_DISP1,vdvDISP1,dvLCD1)
	
	Set Baud to 9600,N,8,1,485 DISABLE

*)

#INCLUDE 'HoppSNAPI Rev5-09.axi'
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

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {6100,6100}
LONG lCmdArray[]				=	{2010,2010}
long lRampTimes[]				=	{200}

INTEGER nPollType = 0
integer x
integer nNumPanels

CHAR cCmdStr[80][20]	
CHAR cPollStr[3][20]

persistent integer nVolume
persistent integer nMute
volatile	integer	nCmdPwrOn

INTEGER nCmd=0

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvTP,VD_SRC_HDMI1],[dvTP,VD_SRC_HDMI2],[dvTP,VD_SRC_HDMI3],[dvTP,VD_SRC_HDMI4],[dvTP,VD_SRC_AUX1],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_VID1],[dvTP,VD_SRC_VID2],[dvTP,VD_SRC_VGA1])
 
([dvLCD,VD_PWR_ON],[dvLCD,VD_PWR_OFF])
([dvLCD,VD_SRC_HDMI1],[dvLCD,VD_SRC_HDMI2],[dvLCD,VD_SRC_HDMI3],[dvLCD,VD_SRC_HDMI4],[dvLCD,VD_SRC_AUX1],[dvLCD,VD_SRC_CMPNT1],[dvLCD,VD_SRC_VID1],[dvLCD,VD_SRC_VID2],[dvLCD,VD_SRC_VGA1])
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
					if(nCmd=VD_PWR_OFF) 
					{
						on[dvLCD,VD_COOLING]
						ON[dvTP,VD_PWR_OFF]
						CmdExecuted()
					}
					if(nCmd=VD_PWR_ON or nCmdPwrOn)
					{
						on[dvLCD,VD_WARMING]
						ON[dvTP,VD_PWR_ON]
						CmdExecuted()
					}
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
				ACTIVE(FIND_STRING(cCompStr,"'6'",1)):
				{
					ON[dvLCD,VD_SRC_HDMI2]
					ON[dvTP,VD_SRC_HDMI2]
					IF(nCmd=VD_SRC_HDMI2) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'7'",1)):
				{
					ON[dvLCD,VD_SRC_HDMI3]
					ON[dvTP,VD_SRC_HDMI3]
					IF(nCmd=VD_SRC_HDMI3) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'8'",1)):
				{
					ON[dvLCD,VD_SRC_HDMI4]
					ON[dvTP,VD_SRC_HDMI4]
					IF(nCmd=VD_SRC_HDMI4) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					ON[dvLCD,VD_SRC_CMPNT1]
					ON[dvTP,VD_SRC_CMPNT1]
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()	
				}				
				ACTIVE(FIND_STRING(cCompStr,"'5'",1)):
				{
					ON[dvLCD,VD_SRC_VID1]
					ON[dvTP,VD_SRC_VID1]
					IF(nCmd=VD_SRC_VID1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'3'",1)):
				{
					ON[dvLCD,VD_SRC_VID2]
					ON[dvTP,VD_SRC_VID2]
					IF(nCmd=VD_SRC_VID2) CmdExecuted()	
				}		
				ACTIVE(FIND_STRING(cCompStr,"'4'",1)):
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
					ON[dvLCD,VD_VOL_MUTE_ON]
					ON[dvTP,VD_VOL_MUTE_TOG]
					IF(nCmd=VD_VOL_MUTE_TOG and !nMute) 
					{
						CmdExecuted()
					}
					on[nMute]
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					ON[dvLCD,VD_VOL_MUTE_OFF]
					OFF[dvTP,VD_VOL_MUTE_TOG]
					IF(nCmd=VD_VOL_MUTE_TOG and nMute)
					{
						CmdExecuted()
					}
					off[nMute]
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
	timeline_create(ltlRampUp,lRampTimes,length_array(lRampTimes),timeline_relative,timeline_repeat)
}

define_function RampDown()
{
	timeline_create(ltlRampDown,lRampTimes,length_array(lRampTimes),timeline_relative,timeline_repeat)
}

define_function StopRamp()
{
	if(timeline_active(lTLRampUp)) timeline_kill(lTLRampUp)
	if(timeline_active(lTLRampDown)) timeline_kill(lTLRampDown)
}

define_function send_volume()
{
	if(nVolume>=10) send_string dvLCD,"'VOLM',itoa(nVolume),'  ',$0D"
	else send_string dvLCD,"'VOLM0',itoa(nVolume),'  ',$0D"
	send_level dvTP,1,nVolume
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		=	"'POWR1   ',$0D" 			
cCmdStr[VD_PWR_OFF]		=	"'POWR0   ',$0D"
cCmdStr[VD_SRC_HDMI1]	=	"'IAVD1   ',$0D"	//hdmi 1
cCmdStr[VD_SRC_HDMI2]	=	"'IAVD6   ',$0D"	//hdmi 2
cCmdStr[VD_SRC_HDMI3]	=	"'IAVD7   ',$0D"	//hdmi 3 
cCmdStr[VD_SRC_HDMI4]	=	"'IAVD8   ',$0D"	//hdmi 4
cCmdStr[VD_SRC_CMPNT1]	=	"'IAVD2   ',$0D"	//component
cCmdStr[VD_SRC_VID1]	=	"'IAVD5   ',$0D"	//video
cCmdStr[VD_SRC_VID2]	=	"'IAVD3   ',$0D"	//video
cCmdStr[VD_SRC_VGA1]	=	"'IAVD4   ',$0D"	//pc in
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
TIMELINE_EVENT[lTLPoll]
{
	nPollType=TIMELINE.SEQUENCE
	SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE]"
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
				CASE VD_SRC_HDMI4:
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
					switch(nMute)
					{
						case 1: send_string dvLCD,cCmdStr[VD_VOL_MUTE_OFF]
						case 0: send_string dvLCD,cCmdStr[VD_VOL_MUTE_ON]
					}
					nPollType=PollMute
				}					
			}
		}
		CASE 2:	//2nd time
		{
			send_string 0,"'4'"
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
				if(nVolume<60) nVolume++
				send_volume()
				RampUp()
			}
			ACTIVE(channel.channel=VD_VOL_DOWN):
			{
				if(nVolume>0) nVolume--
				send_volume()
				RampDown()
			}
			ACTIVE(channel.channel<200):
			{
				nCmd=channel.channel
				TIMELINE_PAUSE(lTLPoll)
				WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,length_array(lCmdArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
			ACTIVE(channel.channel=200):
			{
				TIMELINE_CREATE(lTLPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
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
	if(timeline.repetition<7) nVolume++
	else nVolume=nVolume+3

	if (nVolume>60) nVolume=60
	
	send_volume()
}

timeline_event[lTLRampDown]
{
	if(timeline.repetition<7) nVolume--
	else
	{
		if(nVolume>2) nVolume=nVolume-3
		else nVolume=0
	}
	
	send_volume()
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

