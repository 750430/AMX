MODULE_NAME='Sharp LCD 60LE820UN Rev5-00'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:26:22        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*  

	define_module 'Sharp LCD 60LE820UN Rev5-00' LCD1(vdvTP_DISP1,vdvDISP1,dvLCD1)
	
	Set Baud to 9600,N,8,1,485 DISABLE

*)

#INCLUDE 'HoppSNAPI Rev5-10.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd        			= 2002

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

LONG lPollArray[]				= {4100,4100,4100}
LONG lCmdArray[]				=	{1010,1010}

INTEGER nPollType = 0
integer x
integer nNumPanels

volatile		integer		nActivePower
volatile		integer		nActiveInput
volatile		integer		nActiveMute

volatile		integer		nPower[]={VD_PWR_ON,VD_PWR_OFF,VD_WARMING,VD_COOLING}
volatile		integer		nInput[]={VD_SRC_VGA1,VD_SRC_CMPNT1,VD_SRC_VID1,VD_SRC_HDMI1,VD_SRC_HDMI2,VD_SRC_HDMI3,VD_SRC_HDMI4}
volatile		integer		nMute[]={VD_MUTE_ON,VD_MUTE_OFF}

CHAR cCmdStr[74][20]	
CHAR cPollStr[3][20]

integer nOnline

persistent integer nVolume

INTEGER nCmd=0

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
//([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
//([dvTP,VD_ASPECT1],[dvTP,VD_ASPECT2])
//([dvTP,VD_SRC_RGB1],[dvTP,VD_SRC_VGA1],[dvTP,VD_SRC_DVI1],[dvTP,VD_SRC_DVI2],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_VID1])
// 
//([dvLCD,VD_PWR_ON],[dvLCD,VD_PWR_OFF])
//([dvLCD,VD_ASPECT1],[dvLCD,VD_ASPECT2])
//([dvLCD,VD_VOL_MUTE_ON],[dvLCD,VD_VOL_MUTE_OFF])
//([dvLCD,VD_SRC_RGB1],[dvLCD,VD_SRC_VGA1],[dvLCD,VD_SRC_DVI1],[dvLCD,VD_SRC_DVI2],[dvLCD,VD_SRC_SVID],[dvLCD,VD_SRC_CMPNT1],[dvLCD,VD_SRC_VID1])
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION CmdExecuted()
{
	ncmd=0
	TIMELINE_KILL(lTLCmd)
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
					nActivePower=VD_PWR_ON
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'0'",1)):
				{
					nActivePower=VD_PWR_OFF
					off[nActiveMute]
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'OK'",1)):
				{
					switch(nCmd)
					{
						case VD_PWR_OFF: nActivePower=VD_COOLING
						default: nActivePower=VD_WARMING
					}
				}
			}	
		}
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'5'",1)):
				{
					nActiveInput=VD_SRC_HDMI1
					if(nCmd=VD_SRC_HDMI1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'6'",1)):
				{
					nActiveInput=VD_SRC_HDMI2
					if(nCmd=VD_SRC_HDMI2) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'7'",1)):
				{
					nActiveInput=VD_SRC_HDMI3
					if(nCmd=VD_SRC_HDMI3) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'8'",1)):
				{
					nActiveInput=VD_SRC_HDMI4
					if(nCmd=VD_SRC_HDMI4) CmdExecuted()
				}				
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)):
				{
					nActiveInput=VD_SRC_VID1
					IF(nCmd=VD_SRC_VID1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'4'",1)):
				{
					nActiveInput=VD_SRC_VGA1
					IF(nCmd=VD_SRC_VGA1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					nActiveInput=VD_SRC_CMPNT1
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()	
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
				}
				ACTIVE(FIND_STRING(cCompStr,"'0'",1)):
				{
					IF(nCmd=VD_VOL_MUTE_TOG and nActiveMute)
					{
						CmdExecuted()
					}
					off[nActiveMute]
				}
				active(find_string(cCompStr,"'ERR'",1)):
				{
					CmdExecuted()
				}
			}
		}		
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		=	"'POWR1   ',$0D" 			
cCmdStr[VD_PWR_OFF]		=	"'POWR0   ',$0D"
cCmdStr[VD_SRC_HDMI1]	=	"'IAVD5   ',$0D"	//hdmi 1
cCmdStr[VD_SRC_HDMI2]	=	"'IAVD6   ',$0D"	//hdmi 2
cCmdStr[VD_SRC_HDMI3]	=	"'IAVD7   ',$0D"	//hdmi 3 
cCmdStr[VD_SRC_HDMI4]	=	"'IAVD8   ',$0D"	//hdmi 4
cCmdStr[VD_SRC_CMPNT1]	=	"'IAVD2   ',$0D"	//component
cCmdStr[VD_SRC_VID1]	=	"'IAVD1   ',$0D"	//video
cCmdStr[VD_SRC_VGA1]	=	"'IAVD4   ',$0D"	//pc in
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

data_event[dvTP]
{
	online:
	{
		send_level dvTP,1,nVolume
	}
}

DATA_EVENT[dvLCD]
{
	online:
	{
		on[nOnline]
	}
	offline:
	{
		off[nOnline]
	}
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cFullStr[100]
		LOCAL_VAR CHAR cBuff[255]
		STACK_VAR INTEGER nPos	
		
		cBuff = "cBuff,data.text"
		if(find_string(cBuff,"'Login:'",1))
		{
			send_string data.device,"$0D,$0A"
			//send_string data.device,"'hav',$0D,$0A"
		}
		if(find_string(cBuff,"'Password:'",1))
		{
			send_string data.device,"$0D,$0A"
			//send_string data.device,"'hav',$0D,$0A"
		}
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
	if(nOnline) SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE]"
}

TIMELINE_EVENT[lTLCmd]
{
	if(nOnline) 
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
						nPollType=1
						SEND_STRING dvLCD,cCmdStr[nCmd]
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
						IF(nActivePower=VD_PWR_ON)
						{
							SEND_STRING dvLCD,cCmdStr[nCmd]
							nPollType=PollSrc
						}
						ELSE
						{
							nPollType=PollPwr
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
						nPollType=PollMute
					}				
					CASE VD_PCADJ:
					{
						IF(nActivePower=VD_PWR_ON) SEND_STRING dvLCD,cCmdStr[nCmd]
						CmdExecuted()
					}
				}
			}
			CASE 2:	//2nd time
			{
				IF(nPollType) SEND_STRING dvLCD,cPollStr[nPollType]
			}
		}
	}
}
CHANNEL_EVENT[vdvLCD,0]
{
	ON:
	{
		SELECT
		{
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
}

BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		SWITCH(button.input.channel)
		{
			CASE VD_PCADJ:
			CASE VD_VOL_MUTE_TOG: 
			{
				TO[button.input]
				PULSE[vdvLCD,button.input.channel]
			}
			default: 
			{
				pulse[vdvLCD,button.input.channel]
			}
		}	
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

for(x=1;x<=length_array(nPower);x++) 
{
	[dvLCD,nPower[x]]=nActivePower=nPower[x]
	[dvTP,nPower[x]]=nActivePower=nPower[x]
}

for(x=1;x<=length_array(nInput);x++)
{
	[dvLCD,nInput[x]]=nActiveInput=nInput[x]
	[dvTP,nInput[x]]=nActiveInput=nInput[x]
}

for(x=1;x<=length_array(nMute);x++)
{
	[dvLCD,nMute[x]]=nActiveMute=nMute[x]
	[dvTP,nMute[x]]=nActiveMute=nMute[x]
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

