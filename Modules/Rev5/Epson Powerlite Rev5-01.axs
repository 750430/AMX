MODULE_NAME='Epson Powerlite Rev5-01'(dev dvTP, dev vdvProj, dev dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 07/11/2012  AT: 10:49:41        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*   
	Notes: 

*)
//SET BAUD 9600,N,8,1
//define_module 'Epson Powerlite Rev5-01' proj1(vdvTP_DISP1,vdvDISP1,dvProj)

#INCLUDE 'HoppSNAPI Rev5-06.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002

PollPwr 	= 1
PollSrc		= 2
PollLamp	= 3
PollAspct	= 4 //This feature is here but dormant, the poll timeline is only 3 long at this point.

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {4100,4100,4100}
LONG lCmdArray[]				=	{510,510}

INTEGER nPollType = 0

integer		nLampHours

CHAR cCmdStr[100][20]	
CHAR cPollStr[4][20]

INTEGER nCmd=0
INTEGER btn_Proj[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29}

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvTP,VD_ASPECT1],[dvTP,VD_ASPECT2])
([dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_RGB1],[dvTP,VD_SRC_HDMI1],
 [dvTP,VD_SRC_AUX1],[dvTP,VD_SRC_AUX2],[dvTP,VD_SRC_AUX3])
 
([dvProj,VD_PWR_ON],[dvProj,VD_WARMING],[dvProj,VD_COOLING],[dvProj,VD_PWR_OFF])
([dvProj,VD_ASPECT1],[dvProj,VD_ASPECT2])
([dvProj,VD_SRC_VID1],[dvProj,VD_SRC_SVID],[dvProj,VD_SRC_CMPNT1],[dvProj,VD_SRC_RGB1],[dvProj,VD_SRC_HDMI1],
 [dvProj,VD_SRC_AUX1],[dvProj,VD_SRC_AUX2],[dvProj,VD_SRC_AUX3])
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION CmdExecuted()
{
	ncmd=0
	if(timeline_active(lTLCmd)) TIMELINE_KILL(lTLCmd)
	TIMELINE_RESTART(lTLPoll)
}

DEFINE_FUNCTION Parse(CHAR cCompStr[255])
{
	SWITCH(nPollType)
	{
		CASE PollPwr:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'PWR=01'",1)):
				{
					ON[dvTP,VD_PWR_ON]
					IF(nCmd=VD_PWR_ON) CmdExecuted()
					
					if([dvProj,VD_PWR_OFF])
					{
						
						on[dvProj,VD_WARMING]
						wait 5
						{
							off[dvProj,VD_WARMING]
							ON[dvProj,VD_PWR_ON]
						}
					}
					else
					{
						ON[dvProj,VD_PWR_ON]
					}
				}
				ACTIVE(FIND_STRING(cCompStr,"'PWR=00'",1) || FIND_STRING(cCompStr,"'PWR=04'",1)):  //added 'PWR=04" (Standby Mode) as a valid form of POWER OFF
				{
					ON[dvTP,VD_PWR_OFF]
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
					if([dvProj,VD_PWR_ON])
					{
						
						on[dvProj,VD_COOLING]
						wait 5
						{
							off[dvProj,VD_COOLING]
							ON[dvProj,VD_PWR_OFF]
						}
					}
					else
					{
						ON[dvProj,VD_PWR_OFF]
					}
				}
			}	
		}
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=41'",1)):
				{
					ON[dvProj,VD_SRC_VID1]
					ON[dvTP,VD_SRC_VID1]
					IF(nCmd=VD_SRC_VID1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=42'",1)):
				{
					ON[dvProj,VD_SRC_SVID]
					ON[dvTP,VD_SRC_SVID]
					IF(nCmd=VD_SRC_SVID) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=11'",1)):
				{
					ON[dvProj,VD_SRC_RGB1]
					ON[dvTP,VD_SRC_RGB1]
					IF(nCmd=VD_SRC_RGB1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=21'",1)):
				{
					ON[dvProj,VD_SRC_RGB2]
					ON[dvTP,VD_SRC_RGB2]
					IF(nCmd=VD_SRC_RGB2) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=24'",1)):
				{
					ON[dvProj,VD_SRC_CMPNT1]
					ON[dvTP,VD_SRC_CMPNT1]
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=30'",1)):
				{
					ON[dvProj,VD_SRC_HDMI1]
					ON[dvTP,VD_SRC_HDMI1]
					IF(nCmd=VD_SRC_HDMI1) CmdExecuted()					
				}
			}
		}
		case PollLamp:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'LAMP='",1)):
				{
					remove_string(cCompStr,"'LAMP='",1)
					nLampHours=atoi(left_string(cCompStr,find_string(cCompStr,"$0D",1)-1))
					send_command dvTP,"'^TXT-1,0,Lamp Hours: ',itoa(nLampHours)"
				}
			}
		}		
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		= "'PWR ON',$0D" 			
cCmdStr[VD_PWR_OFF]		= "'PWR OFF',$0D"
cCmdStr[VD_SRC_VID1]	= "'SOURCE 41',$0D"	//composite video
cCmdStr[VD_SRC_SVID]	= "'SOURCE 42',$0D"	//svid
cCmdStr[VD_SRC_RGB1]	= "'SOURCE 11',$0D"	//rgb1
cCmdStr[VD_SRC_RGB2]  = "'SOURCE 21',$0D" //rgb2
cCmdStr[VD_SRC_CMPNT1]= "'SOURCE 24',$0D" //Component on VGA2
cCmdStr[VD_SRC_HDMI1]  = "'SOURCE 30',$0D" //HDMI
cCmdStr[VD_PCADJ]			= "'KEY 4A',$0D"
        
cPollStr[PollPwr]			=	"'PWR?',$0D"		
cPollStr[PollSrc]			=	"'SOURCE?',$0D"					
cPollStr[PollLamp]			=	"'LAMP?',$0D"	

TIMELINE_CREATE(lTLPoll,lPollArray,3,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvProj]
{
	STRING:
	{
		STACK_VAR CHAR cBuff[255]
		
		cBuff = "cBuff,data.text"
		Parse(cBuff)
	}	
}

TIMELINE_EVENT[lTLPoll]
{
	nPollType=TIMELINE.SEQUENCE
	SEND_STRING dvProj,"cPollStr[TIMELINE.SEQUENCE]"
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
				{
					SEND_STRING dvProj,cCmdStr[nCmd]	
					ON[dvProj,VD_WARMING]					
					nPollType=1
				}				
				CASE VD_PWR_OFF:
				{
					SEND_STRING dvProj,cCmdStr[nCmd]					
					nPollType=1
				}
				CASE VD_SRC_VID1:
				CASE VD_SRC_SVID:
				CASE VD_SRC_CMPNT1:
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:
				CASE VD_SRC_HDMI1:
				CASE VD_SRC_AUX1:
				CASE VD_SRC_AUX2:
				CASE VD_SRC_AUX3:
				{
					IF([dvProj,VD_PWR_ON])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType=PollSrc
					}
					ELSE
					{
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						ON[dvProj,VD_WARMING]		
						nPollType=PollPwr
					}
				}
				CASE VD_ASPECT1:
				CASE VD_ASPECT2:
				{
					IF([dvProj,VD_PWR_ON]) 
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType=PollAspct
					}
					ELSE CmdExecuted()
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
			nCmd=channel.channel
			TIMELINE_PAUSE(lTLPoll)
			WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
		}
	}
}

BUTTON_EVENT[dvTP,btn_Proj]
{
	PUSH:
	{
		SWITCH(button.input.channel)
		{
			CASE VD_ASPECT1:
			CASE VD_ASPECT2:
			{
				TO[button.input.device,button.input.channel]
			}
		}	
		PULSE[vdvProj,button.input.channel]
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

