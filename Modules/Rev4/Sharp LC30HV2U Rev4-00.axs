MODULE_NAME='Sharp LC30HV2U Rev4-00'(dev dvTP, dev vdvLCD, dev dvLCD, dev dvLCDIR)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:26:22        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*  

	Rev1-02 added pc adjust
	
	Notes: 
	-Tested w/PN-455,installed at 40066 DHS USCIS
	-Please note that if you plug in both svideo and video you
	will only see svideo, code can not help you!

	DEFINE_MODULE 'Sharp LCD PN-455 Rev1-02' LCD1(vdvTP_DISP1,vdvDISP1,dvLCD1)
	
	Set Baud to 9600,N,8,1,485 DISABLE

*)

#INCLUDE 'HoppSNAPI Rev4-00.axi'
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

LONG lPollArray[]				= {5100}
LONG lCmdArray[]				=	{510,510}

INTEGER nPollType = 0
integer x
integer nNumPanels

CHAR cCmdStr[34][20]	
CHAR cPollStr[20]

INTEGER nCmd=0
INTEGER nPlasBtn[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34}

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
([dvTP,VD_SRC_RGB3],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT],[dvTP,VD_SRC_RGB2])
 
([vdvLCD,VD_PWR_ON_FB],[vdvLCD,VD_PWR_OFF_FB])
([vdvLCD,VD_ASPECT1_FB],[vdvLCD,VD_ASPECT2_FB])
([vdvLCD,VD_SRC_RGB3_FB],[vdvLCD,VD_SRC_SVID_FB],[vdvLCD,VD_SRC_CMPNT_FB],[vdvLCD,VD_SRC_RGB2_FB])
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
					ON[vdvLCD,VD_PWR_ON_FB]
					ON[dvTP,VD_PWR_ON]
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'0'",1)):
				{
					ON[vdvLCD,VD_PWR_OFF_FB]
					ON[dvTP,VD_PWR_OFF]
					IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}
			}	
		}
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'4'",1)):
				{
					IF(nCmd = VD_SRC_VID)
					{
						ON[vdvLCD,VD_SRC_VID_FB]
						ON[dvTP,VD_SRC_VID]
						CmdExecuted()
					}
					IF(nCmd = VD_SRC_SVID)
					{
						ON[vdvLCD,VD_SRC_SVID_FB]
						ON[dvTP,VD_SRC_SVID]
						CmdExecuted()
					}			
					cCmdStr[VD_ASPECT2]	= "'WIDE   4',$0D"					
				}
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)):
				{
					ON[vdvLCD,VD_SRC_DVI1_FB]
					ON[dvTP,VD_SRC_DVI1]
					IF(nCmd=VD_SRC_DVI1) CmdExecuted()					
					cCmdStr[VD_ASPECT2]	= "'WIDE   2',$0D"
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					ON[vdvLCD,VD_SRC_VGA1_FB]
					ON[dvTP,VD_SRC_VGA1]
					IF(nCmd=VD_SRC_VGA1) CmdExecuted()
					cCmdStr[VD_ASPECT2]	= "'WIDE   2',$0D"					
				}
				ACTIVE(FIND_STRING(cCompStr,"'3'",1)):
				{
					ON[vdvLCD,VD_SRC_CMPNT_FB]
					ON[dvTP,VD_SRC_CMPNT]
					IF(nCmd=VD_SRC_CMPNT) CmdExecuted()	
					cCmdStr[VD_ASPECT2]	= "'WIDE   4',$0D"					
				}
				ACTIVE(FIND_STRING(cCompStr,"'6'",1)):
				{
					ON[vdvLCD,VD_SRC_RGB1_FB]
					ON[dvTP,VD_SRC_RGB1]
					IF(nCmd=VD_SRC_RGB1) CmdExecuted()	
					cCmdStr[VD_ASPECT2]	= "'WIDE   2',$0D"					
				}
			}
		}
		CASE PollAspct: 
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)):
				{
					ON[vdvLCD,VD_ASPECT1_FB]
					ON[dvTP,VD_ASPECT1]
					IF(nCmd=VD_ASPECT1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)||FIND_STRING(cCompStr,"'4'",1)):
				{
					ON[vdvLCD,VD_ASPECT2_FB]
					ON[dvTP,VD_ASPECT2]
					IF(nCmd=VD_ASPECT2) CmdExecuted()
				}
			}
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		= "'POWR   1',$0D" 			
cCmdStr[VD_PWR_OFF]		= "'POWR   0',$0D"
cCmdStr[VD_SRC_DVI1]	= "'INPS   1',$0D"	//dvi
cCmdStr[VD_SRC_VGA1]	= "'INPS   2',$0D"	//vga port
cCmdStr[VD_SRC_RGB1]	= "'INPS   6',$0D"  //rgbhv ports
cCmdStr[VD_SRC_CMPNT]	= "'INPS   3',$0D"	//component
cCmdStr[VD_SRC_VID]		= "'INPS   4',$0D"  //video
cCmdStr[VD_SRC_SVID]	= "'INPS   4',$0D"  //svideo
cCmdStr[VD_ASPECT1]		= "'WIDE   1',$0D"	//wide (1,2,3,4)
cCmdStr[VD_ASPECT2]		= "'WIDE   2',$0D"	//normal (1,2)
cCmdStr[VD_PCADJ]		= "'ASNC   1',$0D"	//pc adjust
        
cPollStr				= "'INPS????',$0D"					

nNumPanels=length_array(dvTP)

WAIT 200
{
	IF(!TIMELINE_ACTIVE(lTLPoll))
		TIMELINE_CREATE(lTLPoll,lPollArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
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
	SEND_STRING dvLCD,"cPollStr"
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
					nPollType=1
				}
				CASE VD_SRC_VID:
				CASE VD_SRC_SVID:
				CASE VD_SRC_CMPNT:
				CASE VD_SRC_DVI1:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_RGB1:
				{
					IF([vdvLCD,VD_PWR_ON_FB])
					{
						SEND_STRING dvLCD,cCmdStr[nCmd]
						nPollType=PollSrc
					}
					ELSE
					{
						SEND_STRING dvLCD,cCmdStr[VD_PWR_ON]
						nPollType=PollPwr
					}
				}
				CASE VD_ASPECT1:
				CASE VD_ASPECT2:
				{
					IF([vdvLCD,VD_PWR_ON_FB]) 
					{
						SEND_STRING dvLCD,cCmdStr[nCmd]
						nPollType=PollAspct
					}
					ELSE CmdExecuted()
				}
				CASE VD_PCADJ:
				{
					IF([vdvLCD,VD_PWR_ON_FB]) SEND_STRING dvLCD,cCmdStr[nCmd]
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
				TIMELINE_CREATE(lTLPoll,lPollArray,4,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}
BUTTON_EVENT[dvTP,nPlasBtn]
{
	PUSH:
	{
		SWITCH(button.input.channel)
		{
			CASE VD_ASPECT1:
			CASE VD_ASPECT2:
			CASE VD_PCADJ:
			{
				TO[button.input.device,button.input.channel]
			}
		}	
		PULSE[vdvLCD,button.input.channel]
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

