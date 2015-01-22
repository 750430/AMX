MODULE_NAME='Epson Powerlite 1925W Rev4-00'(dev dvTP, dev vdvProj, dev dvProj)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*   
	Notes: 

*)

#INCLUDE 'HoppSNAPI Rev4-01.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002

PollPwr 	= 1
PollSrc		= 2
PollAspct	= 3

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {5100,5100}
LONG lCmdArray[]				=	{510,510}

INTEGER nPollType = 0

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
([dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_RGB1],
 [dvTP,VD_SRC_AUX1],[dvTP,VD_SRC_AUX2],[dvTP,VD_SRC_AUX3])
 
([vdvProj,VD_PWR_ON_FB],[vdvProj,VD_WARMING_FB],[vdvProj,VD_COOLING_FB],[vdvProj,VD_PWR_OFF_FB])
([vdvProj,VD_ASPECT1_FB],[vdvProj,VD_ASPECT2_FB])
([vdvProj,VD_SRC_VID1_FB],[vdvProj,VD_SRC_SVID_FB],[vdvProj,VD_SRC_CMPNT1_FB],[vdvProj,VD_SRC_RGB1_FB],
 [vdvProj,VD_SRC_AUX1_FB],[vdvProj,VD_SRC_AUX2_FB],[vdvProj,VD_SRC_AUX3_FB])
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
				ACTIVE(FIND_STRING(cCompStr,"'PWR=01'",1)):
				{
					ON[vdvProj,VD_PWR_ON_FB]
					ON[dvTP,VD_PWR_ON]
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'PWR=02'",1)):
				{
					ON[vdvProj,VD_WARMING_FB]
					ON[dvTP,VD_PWR_ON]
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'PWR=03'",1)):
				{
					ON[vdvProj,VD_COOLING_FB]
					ON[dvTP,VD_PWR_OFF]
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'PWR=00'",1) || FIND_STRING(cCompStr,"'PWR=04'",1) ):
				{
					ON[vdvProj,VD_PWR_OFF_FB]
					ON[dvTP,VD_PWR_OFF]
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}
			}	
		}
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=41'",1)):
				{
					ON[vdvProj,VD_SRC_VID1_FB]
					ON[dvTP,VD_SRC_VID1]
					IF(nCmd=VD_SRC_VID1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=42'",1)):
				{
					ON[vdvProj,VD_SRC_SVID_FB]
					ON[dvTP,VD_SRC_SVID]
					IF(nCmd=VD_SRC_SVID) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=11'",1)):
				{
					ON[vdvProj,VD_SRC_RGB1_FB]
					ON[dvTP,VD_SRC_RGB1]
					IF(nCmd=VD_SRC_RGB1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=21'",1)):
				{
					ON[vdvProj,VD_SRC_RGB2_FB]
					ON[dvTP,VD_SRC_RGB2]
					IF(nCmd=VD_SRC_RGB2) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=14'",1)):
				{
					ON[vdvProj,VD_SRC_CMPNT1_FB]
					ON[dvTP,VD_SRC_CMPNT1]
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,"'SOURCE=24'",1)):
				{
					ON[vdvProj,VD_SRC_CMPNT2_FB]
					ON[dvTP,VD_SRC_CMPNT2]
					IF(nCmd=VD_SRC_CMPNT2) CmdExecuted()					
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
cCmdStr[VD_SRC_CMPNT1]= "'SOURCE 14',$0D" //Component on VGA1
cCmdStr[VD_SRC_CMPNT2]= "'SOURCE 24',$0D" //Component on VGA2
cCmdStr[VD_PCADJ]			= "'KEY 4A',$0D"
        
cPollStr[PollPwr]			=	"'PWR?',$0D"		
cPollStr[PollSrc]			=	"'SOURCE?',$0D"					

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
					ON[vdvProj,VD_WARMING_FB]					
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
				CASE VD_SRC_CMPNT2:
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:				
				CASE VD_SRC_AUX1:
				CASE VD_SRC_AUX2:
				CASE VD_SRC_AUX3:
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType=PollSrc
					}
					ELSE
					{
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						ON[vdvProj,VD_WARMING_FB]						
						nPollType=PollPwr
					}
				}
				CASE VD_ASPECT1:
				CASE VD_ASPECT2:
				{
					IF([vdvProj,VD_PWR_ON_FB]) 
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

