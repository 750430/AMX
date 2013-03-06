MODULE_NAME='ViewSonic Pro8400 Rev5-00'(dev dvTP, dev vdvProj, dev dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/14/2012  AT: 23:03:13        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                 						   *)
(***********************************************************)
(*   
	Notes: 

*)
//SET BAUD 19200,N,8,1
//define_module 'ViewSonic Pro8400 Rev5-00' proj1(vdvTP_DISP1,vdvDISP1,dvProj)

#INCLUDE 'HoppSNAPI Rev5-06.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll			= 2001
LONG lTLCmd         = 2002

PollPwr 	= 1
PollSrc		= 2

//WarmCoolDELAY variable states
Warming	= 1
Cooling	= 2	


WarmingON	= 1
WarmingOFF	= 0

CoolingON = 1
CoolingOFF = 0

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {3570,3570}
LONG lCmdArray[]				=	{510,510}
//LONG lCmdArray[]				=	{1020,1020}


INTEGER POWER_COMMAND = 0	//  0=off, 1=on
INTEGER WarmCoolDELAY = 0	//	0=none, 1=Warming, 2=Cooling

INTEGER StoreSOURCE = 0

INTEGER nPollType = 1

CHAR cCmdStr[100][30]	
CHAR cPollStr[4][30]

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
([dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_CMPNT2],[dvTP,VD_SRC_VGA1],[dvTP,VD_SRC_HDMI1])
 
([dvProj,VD_PWR_ON],[dvProj,VD_WARMING],[dvProj,VD_PWR_OFF],[dvProj,VD_COOLING])
([dvProj,VD_SRC_VID1],[dvProj,VD_SRC_SVID],[dvProj,VD_SRC_CMPNT1],[dvProj,VD_SRC_CMPNT2],[dvProj,VD_SRC_VGA1],[dvProj,VD_SRC_HDMI1])
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION CmdExecuted()
{
	IF(WarmCoolDELAY=0)	ncmd=0
	TIMELINE_KILL(lTLCmd)
	WAIT 1 TIMELINE_RESTART(lTLPoll)
}

//DEFINE_FUNCTION CmdExecuted()
//{
//	IF(WarmCoolDELAY=0)
//	{
//		ncmd=0
//		TIMELINE_KILL(lTLCmd)
//		TIMELINE_RESTART(lTLPoll)
//	}
//}

DEFINE_FUNCTION WarmingDELAY()
{
	TIMELINE_KILL(lTLCmd)
	WarmCoolDELAY = Warming  //  Tell the rest of the module the Projector is busy mid-WARMING
	POWER_COMMAND = 1	// Continue sending Power=On commands (via Polling)
	WAIT 1 TIMELINE_RESTART(lTLPoll)


	CANCEL_WAIT 'WAIT_COOLING'  // If cooling delay is active ==> Kill it!
	WAIT 200 'WAIT_WARMING'
	{
		//After Warming Delay:
		
		ON[dvProj,VD_PWR_ON]
		ON[dvTP,VD_PWR_ON]
		WarmCoolDELAY=0  //reset variable

		IF(StoreSOURCE) // if either HDMI or VGA source was pulsed
		{
			nCmd=StoreSOURCE
			TIMELINE_PAUSE(lTLPoll)
			WAIT 1 TIMELINE_RESTART(lTLCmd) // if original pulsed command was a Source, the Source command will now be sent
		}
	}
}

DEFINE_FUNCTION CoolingDELAY()
{
	TIMELINE_KILL(lTLCmd)
	WarmCoolDELAY = Cooling
	POWER_COMMAND = 0
	WAIT 1 TIMELINE_RESTART(lTLPoll)

	
	CANCEL_WAIT 'WAIT_WARMING'	
	WAIT 300 'WAIT_COOLING'
	{
		//After the Cooling Delay:
		
		ON[dvProj,VD_PWR_OFF]
		ON[dvTP,VD_PWR_OFF]
		WarmCoolDELAY=0  //reset variable
		
		//TIMELINE_RESTART(lTLPoll)
	}
}

DEFINE_FUNCTION Parse(CHAR cCompStr[255]) //try reducing the buffer length is having problems
{
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,"$15",1)):	// POWER = ON
		{
			IF(nCmd=VD_PWR_ON) // if power comes on
			{
				SELECT
				{
					ACTIVE([dvProj,VD_PWR_OFF]):  // If this is the first POWER=ON response ==> begin WARMING
					{
						ON[dvProj,VD_WARMING]
						WarmingDELAY()  
					}
					ACTIVE(1):	//Projector is either mid-WARMING or not Warming (POWER=ON)
					{
						SWITCH(WarmCoolDELAY)
						{
							case Warming:  CmdExecuted() // If WARMING ==> do nothing (continue polling)
							case 0: // If NOT Warming
							{
								ON[dvProj,VD_PWR_ON]
								ON[dvTP,VD_PWR_ON]
								CmdExecuted()
							}
						}
					}
				}
			}			
		}
		ACTIVE(FIND_STRING(cCompStr,"$06",1)):	// POWER = OFF
		{
			IF(nCmd=VD_PWR_OFF) // if power has turned off 
			{
				SELECT
				{
					ACTIVE([dvProj,VD_PWR_ON]):  // If this is the first POWER=OFF response ==> begin COOLING
					{
						ON[dvProj,VD_COOLING]
						CoolingDELAY()  
					}
					ACTIVE(1):	//Projector is either mid-COOLING or not COOLING (POWER=OFF)
					{
						SWITCH(WarmCoolDELAY)
						{
							case Cooling:  CmdExecuted() // If COOLING ==> do nothing (continue polling)
							case 0: // If NOT COOLING
							{
								ON[dvProj,VD_PWR_OFF]
								ON[dvTP,VD_PWR_OFF]
								CmdExecuted()
							}
						}
					}
				}
			}
			IF(nCmd=VD_SRC_HDMI1 || [dvProj,VD_PWR_ON]) 
			{
				ON[dvProj,VD_SRC_HDMI1]
				ON[dvTP,VD_SRC_HDMI1]					
				CmdExecuted()	
			}	
			IF(nCmd=VD_SRC_VGA1 || [dvProj,VD_PWR_ON]) 
			{
				ON[dvProj,VD_SRC_VGA1]
				ON[dvTP,VD_SRC_VGA1]
				CmdExecuted()					
			}				
		}
	}
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

ON[dvProj,VD_PWR_OFF]
ON[dvTP,VD_PWR_OFF]	

cCmdStr[VD_PWR_ON]		=   "$BE,$EF,$10,$05,$00,$C6,$FF,$11,$11,$01,$00,$01,$00" 			
cCmdStr[VD_PWR_OFF]		=   "$BE,$EF,$02,$06,$00,$6D,$D2,$34,$00,$00,$00,$00,$00"

cCmdStr[VD_SRC_VGA1]	= 	"$BE,$EF,$02,$06,$00,$BC,$D3,$35,$00,$00,$00,$00,$00"
cCmdStr[VD_SRC_HDMI1]  	= 	"$BE,$EF,$02,$06,$00,$43,$D3,$3A,$00,$00,$00,$00,$00"

cCmdStr[VD_PCADJ]		= 	"$BE,$EF,$02,$06,$00,$F2,$D5,$1B,$00,$00,$00,$00,$00"
cCmdStr[VD_ASPECT1]		=	"$BE,$EF,$02,$06,$00,$C7,$D2,$3E,$00,$00,$00,$00,$00"

cPollStr[PollPwr]		=	"$BE,$EF,$10,$05,$00,$C6,$FF,$11,$11,$01,$00,$01,$00"	//this is the POWER=ON command	
cPollStr[PollSrc]		=	"$BE,$EF,$10,$05,$00,$C6,$FF,$11,$11,$01,$00,$01,$00"	//this is the POWER=ON command		

TIMELINE_CREATE(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
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
	SWITCH(TIMELINE.SEQUENCE)
	{
		case 2:
		{
			SWITCH(POWER_COMMAND)
			{
				CASE 1:		SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
				CASE 0:		SEND_STRING dvProj,cCmdStr[VD_PWR_OFF]
			}
		}
	}
}


TIMELINE_EVENT[lTLCmd]
{
	nPollType=PollPwr
	SWITCH(TIMELINE.SEQUENCE)
	{
		CASE 1:	//first time
		{
			SWITCH(nCmd)
			{
				CASE VD_PWR_ON:
				{
					POWER_COMMAND=1
					SEND_STRING dvProj,cCmdStr[nCmd]
				}				
				CASE VD_PWR_OFF:
				{
					POWER_COMMAND=0
					SEND_STRING dvProj,cCmdStr[nCmd]
				}
				CASE VD_SRC_VGA1:
				CASE VD_SRC_HDMI1:		//if source is pushed but power is OFF, it turns ON projector, but doesn't pulse the source
				{
					StoreSOURCE=nCmd
					POWER_COMMAND=1
					SELECT
					{
						
						ACTIVE([dvProj,VD_PWR_ON] && WarmCoolDELAY=0): //if power=ON
						{
							SEND_STRING dvProj,cCmdStr[nCmd]
						}
						ACTIVE([dvProj,VD_PWR_OFF] && WarmCoolDELAY=0): //if power=OFF
						{
							nCmd=VD_PWR_ON
							SEND_STRING dvProj,cCmdStr[nCmd]
						}
					}
				}
			}
		}
		CASE 2:	//2nd time
		{
			IF(WarmCoolDELAY=0) 
			{
				SWITCH(POWER_COMMAND)
				{
					CASE 1:		SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
					CASE 0:		SEND_STRING dvProj,cCmdStr[VD_PWR_OFF]
				}				
			}
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
			
			SELECT
			{
//				ACTIVE(nCmd=VD_PWR_OFF):
//				{
//					POWER_COMMAND=0
//					TIMELINE_PAUSE(lTLPoll)
//					TIMELINE_CREATE(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
//				}
				ACTIVE(WarmCoolDELAY=0): //if not warming/cooling	--> execute command
				{
					TIMELINE_PAUSE(lTLPoll)
					TIMELINE_CREATE(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
				}
				ACTIVE(WarmCoolDELAY=Warming): 	//No commands will be executed during warming/cooling, but source channels pulsed during warming will
				{								//be stored (most recent selection only) and executed after warming is complete.
					SWITCH(channel.channel)
					{
						case VD_SRC_VGA1:
						case VD_SRC_HDMI1:
						{
							StoreSOURCE=channel.channel
						}
					}
				}
			}
		}
	}
}

BUTTON_EVENT[dvTP,btn_Proj]
{
	PUSH:
	{
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

