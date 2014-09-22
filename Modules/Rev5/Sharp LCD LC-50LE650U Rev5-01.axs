MODULE_NAME='Sharp LCD LC-50LE650U Rev5-01'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:26:22        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*  

	define_module 'Sharp LCD LC-50LE650U Rev5-01' LCD1(vdvTP_DISP1,vdvDISP1,dvLCD1)
	
	Set Baud to 9600,N,8,1,485 DISABLE

*)

#INCLUDE 'HoppSNAPI Rev5-06.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant

tlPoll				= 2001
tlCmd         		= 2002
tlFeedback			= 2003

PollPwr 	=	1
PollSrc		=	2

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

long 		lPollArray[]				= {4100,4100}
long 		lCmdArray[]				=	{1510,1510}

integer 	nPollType = 0
integer 	nCmd=0
integer 	x

char 		cCmdStr[80][20]	
char 		cPollStr[2][20]

integer		nCmdPwrOn

integer		nActivePower
integer		nActiveInput

define_variable //Feedback Variables

non_volatile	long		lFeedbackTime[]={300}

define_variable //Channel Arrays

integer		nPower[]={VD_PWR_ON,VD_PWR_OFF,VD_WARMING,VD_COOLING}
integer		nInput[]={VD_SRC_VGA1,VD_SRC_VGA2,VD_SRC_VGA3,VD_SRC_DVI1,VD_SRC_DVI2,VD_SRC_DVI3,VD_SRC_RGB1,VD_SRC_RGB2,VD_SRC_RGB3,
						VD_SRC_HDMI1,VD_SRC_HDMI2,VD_SRC_HDMI3,VD_SRC_SVID,VD_SRC_AUX1,VD_SRC_AUX2,VD_SRC_AUX3,VD_SRC_AUX4,VD_SRC_CMPNT1,VD_SRC_VID1,VD_SRC_VID2}

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
define_function tp_fb()
{
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
}

DEFINE_FUNCTION CmdExecuted()
{
	ncmd=0
	nCmdPwrOn=0
	if(timeline_active(tlCmd)) TIMELINE_KILL(tlCmd)
	TIMELINE_RESTART(tlPoll)
}
DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nVar
	
//	if(find_string(cCompStr,"'ERR'",1) and timeline_active(tlPoll)) SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE]"
//Dont uncomment this unless you can figure out how to stop error chaining from happening.
	
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
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'OK'",1)):
				{
					if(nCmd=VD_PWR_OFF) nActivePower=VD_COOLING
					if(nCmd=VD_PWR_ON or nCmdPwrOn) nActivePower=VD_WARMING
				}
			}	
		}
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)):
				{
					nActiveInput=VD_SRC_HDMI1
					IF(nCmd=VD_SRC_HDMI1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					nActiveInput=VD_SRC_HDMI2
					IF(nCmd=VD_SRC_HDMI2) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'3'",1)):
				{
					nActiveInput=VD_SRC_HDMI3
					IF(nCmd=VD_SRC_HDMI3) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'4'",1)):
				{
					nActiveInput=VD_SRC_AUX1
					IF(nCmd=VD_SRC_AUX1) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'5'",1)):
				{
					nActiveInput=VD_SRC_CMPNT1
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()	
				}				
				ACTIVE(FIND_STRING(cCompStr,"'6'",1)):
				{
					nActiveInput=VD_SRC_VID1
					IF(nCmd=VD_SRC_VID1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'7'",1)):
				{
					nActiveInput=VD_SRC_VID2
					IF(nCmd=VD_SRC_VID2) CmdExecuted()	
				}		
				ACTIVE(FIND_STRING(cCompStr,"'8'",1)):
				{
					nActiveInput=VD_SRC_VGA1
					IF(nCmd=VD_SRC_VGA1) CmdExecuted()	
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
        
cPollStr[PollPwr]		=	"'POWR????',$0D"		
cPollStr[PollSrc]		=	"'IAVD????',$0D"					

WAIT 200
{
	send_string dvLCD,"'RSPW1   ',$0D"
	IF(!TIMELINE_ACTIVE(tlPoll))
		TIMELINE_CREATE(tlPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
}


timeline_create(tlFeedback,lFeedbackTime,1,timeline_relative,timeline_repeat)
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


TIMELINE_EVENT[tlPoll]
{
	nPollType=TIMELINE.SEQUENCE
	switch(nPollType)
	{
		case PollSrc: if(nActivePower=VD_PWR_ON) SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE]"
		case PollPwr: SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE]"
	}
}

TIMELINE_EVENT[tlCmd]
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
					IF(nActivePower=VD_PWR_ON)
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
			}
		}
		CASE 2:	//2nd time
		{
			IF(nPollType) SEND_STRING dvLCD,cPollStr[nPollType]
		}
	}
}

channel_event[vdvLCD,0]
{
	on:
	{
		nCmd=channel.channel
		timeline_pause(tlPoll)
		if(timeline_active(tlCmd)) timeline_kill(tlCmd)
		timeline_create(tlCmd,lCmdArray,length_array(lCmdArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
	}
}

button_event[dvTP,0]
{
	push:
	{
		to[button.input]
		to[vdvLCD,button.input.channel]
	}
}

define_event

timeline_event[tlFeedback]
{
	tp_fb()
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

