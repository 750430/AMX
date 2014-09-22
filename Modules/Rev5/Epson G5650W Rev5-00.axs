MODULE_NAME='Epson G5650W Rev5-00'(dev dvTP, dev vdvProj, dev dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/26/2012  AT: 03:24:26        *)
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
//define_module 'Epson G5650W Rev5-00' proj1(vdvTP_DISP1,vdvDISP1,dvProj)

#INCLUDE 'HoppSNAPI Rev5-01.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002
long lTLBlink		=	2003
long lTLTransition	=	2004

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
long lBlinkTimes[]				=	{700,700}
long lTransitionTimes[]			=	{30000}

INTEGER nPollType = 0

CHAR cCmdStr[100][20]	
CHAR cPollStr[3][20]

integer		nLampHours

integer nPower

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
([dvTP,VD_ASPECT1],[dvTP,VD_ASPECT2])
([dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_RGB1],
 [dvTP,VD_SRC_AUX1],[dvTP,VD_SRC_AUX2],[dvTP,VD_SRC_AUX3],[dvTP,VD_SRC_VGA1])
 
([dvProj,VD_ASPECT1],[dvProj,VD_ASPECT2])
([dvProj,VD_SRC_VID1],[dvProj,VD_SRC_SVID],[dvProj,VD_SRC_CMPNT1],[dvProj,VD_SRC_RGB1],[dvProj,VD_SRC_VGA1],[dvProj,VD_SRC_VGA2],
 [dvProj,VD_SRC_AUX1])
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION CmdExecuted()
{
	ncmd=0
	TIMELINE_KILL(lTLCmd)
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
				ACTIVE(FIND_STRING(cCompStr,"'PWR=01'",1) or FIND_STRING(cCompStr,"'PWR=02'",1)):
				{
					if(!timeline_active(lTLTransition)) nPower=VD_PWR_ON
					IF(nCmd=VD_PWR_ON) 
					{
						nPower=VD_WARMING
						timeline_create(lTLTransition,lTransitionTimes,length_array(lTransitionTimes),timeline_relative,timeline_once)
						CmdExecuted()
					}
				}
				ACTIVE(FIND_STRING(cCompStr,"'PWR=00'",1) or find_string (cCompStr,"'PWR=04'",1)):
				{
					if(!timeline_active(lTLTransition)) nPower=VD_PWR_OFF
					IF(nCmd=VD_PWR_OFF) 
					{
						nPower=VD_COOLING
						timeline_create(lTLTransition,lTransitionTimes,length_array(lTransitionTimes),timeline_relative,timeline_once)
						CmdExecuted()
					}
				}
			}	
		}
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=45'",1)):
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
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=B1'",1)):
				{
					ON[dvProj,VD_SRC_RGB1]
					ON[dvTP,VD_SRC_RGB1]
					IF(nCmd=VD_SRC_RGB1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=11'",1)):
				{
					ON[dvProj,VD_SRC_VGA1]
					ON[dvTP,VD_SRC_VGA1]
					IF(nCmd=VD_SRC_VGA1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=21'",1)):
				{
					ON[dvProj,VD_SRC_VGA2]
					ON[dvTP,VD_SRC_VGA2]
					IF(nCmd=VD_SRC_VGA2) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=24'",1)):
				{
					ON[dvProj,VD_SRC_CMPNT1]
					ON[dvTP,VD_SRC_CMPNT1]
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=30'",1)):
				{
					ON[dvProj,VD_SRC_AUX1]
					ON[dvTP,VD_SRC_AUX1]
					IF(nCmd=VD_SRC_AUX1) CmdExecuted()					
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
cCmdStr[VD_SRC_VID1]	= "'SOURCE 45',$0D"	//composite video
cCmdStr[VD_SRC_SVID]	= "'SOURCE 42',$0D"	//svid
cCmdStr[VD_SRC_VGA1]	= "'SOURCE 11',$0D"	//vga1
cCmdStr[VD_SRC_RGB1]	= "'SOURCE B1',$0D"	//rgb1
cCmdStr[VD_SRC_VGA2]  = "'SOURCE 21',$0D" //rgb2
cCmdStr[VD_SRC_CMPNT1]= "'SOURCE 24',$0D" //Component on VGA2
cCmdStr[VD_SRC_AUX1]	= "'SOURCE 30',$0D" //Aux1
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
					nPower=VD_WARMING
					nPollType=1				
				}
				CASE VD_PWR_OFF:
				{
					SEND_STRING dvProj,cCmdStr[nCmd]
					nPower=VD_COOLING
					nPollType=1
				}
				CASE VD_SRC_VID1:
				CASE VD_SRC_SVID:
				CASE VD_SRC_CMPNT1:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_RGB1:
				CASE VD_SRC_VGA2:				
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
						nPower=VD_WARMING
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

timeline_event[lTLBlink]
{
	switch(timeline.sequence)
	{
		case 1:
		{
			on[dvTP,VD_PWR_ON]
			off[dvTP,VD_PWR_OFF]
		}
		case 2:
		{
			off[dvTP,VD_PWR_ON]
			on[dvTP,VD_PWR_OFF]
		}
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvProj,VD_PWR_ON]=nPower=VD_PWR_ON
[dvProj,VD_PWR_OFF]=nPower=VD_PWR_OFF
[dvProj,VD_WARMING]=nPower=VD_WARMING
[dvProj,VD_COOLING]=nPower=VD_COOLING

[dvTP,VD_PWR_ON]=(nPower=VD_PWR_ON) or (nPower=VD_WARMING)
[dvTP,VD_PWR_OFF]=(nPower=VD_PWR_OFF) or (nPower=VD_COOLING)

//
//select
//{
//	active (nPower=VD_PWR_ON or nPower=VD_PWR_OFF): 
//	{
//		[dvTP,VD_PWR_ON]=nPower=VD_PWR_ON
//		[dvTP,VD_PWR_OFF]=nPower=VD_PWR_OFF
//		if(!timeline_active(lTLBlink)) timeline_kill(lTLBlink)
//	}
//	active (nPower=VD_WARMING or nPower=VD_COOLING): 
//	{
//		if(!timeline_active(lTLBlink)) timeline_create(lTLBlink,lBlinkTimes,length_array(lBlinkTimes),timeline_relative,timeline_repeat)
//	}
//}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

