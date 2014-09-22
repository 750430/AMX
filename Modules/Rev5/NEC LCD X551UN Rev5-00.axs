MODULE_NAME='NEC LCD X551UN Rev5-00'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:26:22        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*  


	define_module 'NEC LCD X551UN Rev5-00' lcd1(vdvTP_DISP1,vdvDISP1,dvLCD)
	
	Set Baud to 9600,N,8,1,485 DISABLE

*)

#INCLUDE 'HoppSNAPI Rev5-10.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002

PollPwr 	= 1
PollSrc		= 2
PollMute	= 3

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {5100,5100}
LONG lCmdArray[]				=	{1110,1110}

INTEGER nPollType = 0
integer x

char cCmdStr[71][60]	
char cPollStr[4][60]

char cCheck

INTEGER nCmd=0

INTEGER nLCDBtns[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
										21,22,23,24,25,26,27,28,29,30,31,32,33,34}
										
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvTP,VD_SRC_DVI1],[dvTP,VD_SRC_HDMI1])
 
([dvLCD,VD_PWR_ON],[dvLCD,VD_PWR_OFF])
([dvLCD,VD_SRC_DVI1],[dvLCD,VD_SRC_HDMI1])
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function CmdExecuted()
{
	ncmd=0
	TIMELINE_KILL(lTLCmd)
	TIMELINE_RESTART(lTLPoll)
}

define_function char calcBCC(char cCommStr[100])
{
	stack_var char cResult
	cResult = $00
	for(x=2;x<=(length_string(cCommStr));x++)
	{
		cResult=cResult bxor cCommStr[x]
	}
	return cResult
}

define_function Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nVar
	
	SWITCH(nPollType)
	{
		CASE PollPwr:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'C203D60001',$03,'v'",1) || FIND_STRING(cCompStr,"'D60000040001',$03,'t'",1)):
				{
					ON[dvLCD,VD_PWR_ON]
					ON[dvTP,VD_PWR_ON]
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'C203D60004',$03,'s'",1) || FIND_STRING(cCompStr,"'D60000040004',$03,'q'",1)):
				{
					ON[dvLCD,VD_PWR_OFF]
					ON[dvTP,VD_PWR_OFF]
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}
			}	
		}
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'0600000110003',$03,$00",1)):
				{
					ON[dvLCD,VD_SRC_DVI1]
					ON[dvTP,VD_SRC_DVI1]
					IF(nCmd=VD_SRC_DVI1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'0600000110011',$03,$03",1)):
				{
					ON[dvLCD,VD_SRC_HDMI1]
					ON[dvTP,VD_SRC_HDMI1]
					IF(nCmd=VD_SRC_HDMI1) CmdExecuted()
				}
			}
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "$01,'0*0A0C',$02,'C203D60001',$03" 			
cCmdStr[VD_PWR_OFF]			= "$01,'0*0A0C',$02,'C203D60004',$03"
cCmdStr[VD_SRC_DVI1]		= "$01,'0*0E0A',$02,'00600003',$03"				//Input RGB1(DVI-D)
cCmdStr[VD_SRC_HDMI1]		= "$01,'0*0E0A',$02,'00600011',$03"				//Input HDMI

cPollStr[PollPwr]			=	"$01,'0*0A06',$02,'01D6',$03,$1F"				//Poll Power
cPollStr[PollSrc]			=	"$01,'0*0C0A',$02,$60,$60,$66,$60,$03"		//Poll Source				

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
	cCheck = calcBCC(cPollStr[timeline.sequence])
	SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE],cCheck,$0D"
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
					cCheck = calcBCC(cCmdStr[nCmd])
					SEND_STRING dvLCD,"cCmdStr[nCmd],cCheck,$0D"
					nPollType=PollPwr
				}
				CASE VD_SRC_DVI1:
				CASE VD_SRC_HDMI1:
				{
					IF([dvLCD,VD_PWR_ON])
					{
						cCheck = calcBCC(cCmdStr[nCmd])
						SEND_STRING dvLCD,"cCmdStr[nCmd],cCheck,$0D"
						nPollType=PollSrc
					}
					ELSE
					{
						cCheck = calcBCC(cCmdStr[VD_PWR_ON])
						SEND_STRING dvLCD,"cCmdStr[VD_PWR_ON],cCheck,$0D"
						nPollType=PollPwr
					}
				}
			}
		}
		CASE 2:	//2nd time
		{
			IF(nPollType)
			{
				cCheck = calcBCC(cPollStr[nPollType])
				SEND_STRING dvLCD,"cPollStr[nPollType],cCheck,$0D"
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
				WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
			ACTIVE(channel.channel=200):
			{
				TIMELINE_CREATE(lTLPoll,lPollArray,3,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}

BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		to[button.input]
		pulse[vdvLCD,button.input.channel]
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


