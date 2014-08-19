MODULE_NAME='NEC LCD8205 Rev5-01'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:26:22        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*  


	define_module 'NEC LCD8205 Rev5-01' lcd1(vdvTP_DISP1,vdvDISP1,dvLCD)
	
	Set Baud to 9600,N,8,1,485 DISABLE

*)

#INCLUDE 'HoppSNAPI Rev5-00.axi'
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

char cCmdStr[60][60]	
char cPollStr[4][60]

char cCheck

INTEGER nCmd=0

volatile		integer		nActivePower
volatile		integer		nActiveInput

volatile		integer		nPower[]={VD_PWR_ON,VD_PWR_OFF,VD_WARMING,VD_COOLING}
volatile		integer		nInput[]={VD_SRC_DVI1,VD_SRC_DVI2,VD_SRC_DVI3,VD_SRC_VGA1,VD_SRC_CMPNT1,VD_SRC_CMPNT2,VD_SRC_RGB1,VD_SRC_VID1,VD_SRC_VID2,VD_SRC_SVID,VD_SRC_AUX1}




(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

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
				ACTIVE(FIND_STRING(cCompStr,"'C203D60001',$03",1)):
				{
					if(nActivePower<>VD_WARMING)
					{
						for(x=1;x<=length_array(nInput);x++) if(nInput[x]=nCmd) 
						{
							nActivePower=VD_WARMING
							cancel_wait 'Power'
							wait 100 'Power' nActivePower=VD_PWR_ON
						}
						else if(nCmd=VD_PWR_ON) 
						{
							nActivePower=VD_WARMING
							CmdExecuted()
							cancel_wait 'Power'
							wait 100 'Power' nActivePower=VD_PWR_ON
						}
					}
				}
				ACTIVE(FIND_STRING(cCompStr,"'D60000040001',$03",1)):
				{
					nActivePower=VD_PWR_ON
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'C203D60004',$03",1)):
				{
					if(nCmd=VD_PWR_OFF and nActivePower<>VD_COOLING) 
					{
						nActivePower=VD_COOLING
						CmdExecuted()
						cancel_wait 'Power'
						wait 40 'Power' nActivePower=VD_PWR_OFF
					}
				}
				ACTIVE(FIND_STRING(cCompStr,"'D60000040004',$03",1) || FIND_STRING(cCompStr,"'D60000040002',$03",1)):
				{
					nActivePower=VD_PWR_OFF
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}
			}	
		}
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'0600000110003',$03",1)):
				{
					nActiveInput=VD_SRC_DVI1
					IF(nCmd=VD_SRC_DVI1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'0600000110011',$03",1)):
				{
					nActiveInput=VD_SRC_DVI2
					IF(nCmd=VD_SRC_DVI2) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'060000011000F',$03",1)):
				{
					nActiveInput=VD_SRC_DVI3
					IF(nCmd=VD_SRC_DVI3) CmdExecuted()
				}				
				ACTIVE(FIND_STRING(cCompStr,"'0600000110001',$03",1)):
				{
					nActiveInput=VD_SRC_VGA1
					IF(nCmd=VD_SRC_VGA1) CmdExecuted()
				}	
				ACTIVE(FIND_STRING(cCompStr,"'060000011000C',$03",1)):
				{
					nActiveInput=VD_SRC_CMPNT1
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()
				}				
				ACTIVE(FIND_STRING(cCompStr,"'060000011000E',$03",1)):
				{
					nActiveInput=VD_SRC_CMPNT2
					IF(nCmd=VD_SRC_CMPNT2) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'0600000110002',$03",1)):
				{
					nActiveInput=VD_SRC_RGB1
					IF(nCmd=VD_SRC_RGB1) CmdExecuted()
				}	
				ACTIVE(FIND_STRING(cCompStr,"'0600000110005',$03",1)):
				{
					nActiveInput=VD_SRC_VID1
					IF(nCmd=VD_SRC_VID1) CmdExecuted()
				}		
				ACTIVE(FIND_STRING(cCompStr,"'0600000110006',$03",1)):
				{
					nActiveInput=VD_SRC_VID2
					IF(nCmd=VD_SRC_VID2) CmdExecuted()
				}					
				ACTIVE(FIND_STRING(cCompStr,"'0600000110007',$03",1)):
				{
					nActiveInput=VD_SRC_SVID
					IF(nCmd=VD_SRC_SVID) CmdExecuted()
				}	
				ACTIVE(FIND_STRING(cCompStr,"'060000011000A',$03",1)):
				{
					nActiveInput=VD_SRC_AUX1
					IF(nCmd=VD_SRC_AUX1) CmdExecuted()
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
cCmdStr[VD_SRC_DVI2]		= "$01,'0*0E0A',$02,'00600011',$03"				//Input HDMI
cCmdStr[VD_SRC_DVI3]		= "$01,'0*0E0A',$02,'0060000F',$03"				//Input Display Port
cCmdStr[VD_SRC_VGA1]		= "$01,'0*0E0A',$02,'00600001',$03"				//Input RGB2(D-Sub)
cCmdStr[VD_SRC_CMPNT1]	= "$01,'0*0E0A',$02,'0060000C',$03"				//Input DVD/HD1
cCmdStr[VD_SRC_CMPNT2]	= "$01,'0*0E0A',$02,'0060000E',$03"				//Input DVD/HD2
cCmdStr[VD_SRC_RGB1]		= "$01,'0*0E0A',$02,'00600002',$03"				//Input RGB3(BNC)
cCmdStr[VD_SRC_VID1]		= "$01,'0*0E0A',$02,'00600005',$03"				//Input Video1(Composite)
cCmdStr[VD_SRC_VID2]		= "$01,'0*0E0A',$02,'00600006',$03"				//Input Video2
cCmdStr[VD_SRC_SVID]		= "$01,'0*0E0A',$02,'00600007',$03"				//Input S-Video
cCmdStr[VD_SRC_AUX1]		= "$01,'0*0E0A',$02,'0060000A',$03"				//Input TV

cCmdStr[VD_PCADJ]				= "$01,'0*0E0A',$02,'001E0001',$03"			//Auto Setup

cPollStr[PollPwr]				=	"$01,'0*0C06',$02,'01D6',$03"				//Poll Power
cPollStr[PollSrc]				=	"$01,'0*0C06',$02,'0060',$03"		//Poll Source				


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
				CASE VD_SRC_DVI2:
				CASE VD_SRC_DVI3:
				CASE VD_SRC_RGB1:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_CMPNT1:
				CASE VD_SRC_CMPNT2:
				CASE VD_SRC_VID1:
				CASE VD_SRC_VID2:
				CASE VD_SRC_SVID:
				CASE VD_SRC_AUX1:
				{
					IF(nActivePower=VD_PWR_ON)
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
				CASE VD_PCADJ:
				{
					IF(nActivePower=VD_PWR_ON) SEND_STRING dvLCD,cCmdStr[VD_PCADJ]
					CmdExecuted()
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

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


