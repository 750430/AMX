MODULE_NAME='Sharp LCD LC-40E67U Rev4-01'(dev dvTP, dev vdvLCD, dev dvLCD)
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

#INCLUDE 'HoppSNAPI Rev4-01.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002
long lTLWait		=	2003

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

LONG lPollArray[]				= {5100,5100,5100}
LONG lCmdArray[]				=	{1100,1100}
long lWaitArray[]				=	{10100}

INTEGER nPollType = 0
integer x
integer nNumPanels

CHAR cCmdStr[56][20]	
CHAR cPollStr[4][20]

INTEGER nCmd=0

persistent integer nVolume
persistent integer nMute


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
([dvTP,VD_SRC_RGB3],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_RGB2])
 
([vdvLCD,VD_PWR_ON_FB],[vdvLCD,VD_PWR_OFF_FB])
([vdvLCD,VD_ASPECT1_FB],[vdvLCD,VD_ASPECT2_FB])
([vdvLCD,VD_SRC_RGB3_FB],[vdvLCD,VD_SRC_SVID_FB],[vdvLCD,VD_SRC_CMPNT1_FB],[vdvLCD,VD_SRC_RGB2_FB])
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
	if(find_string(cCompStr,"'OK'",1) and nCmd=VD_PWR_ON)
	{
		timeline_create(lTLWait,lWaitArray,1,timeline_relative,timeline_once)
		ON[vdvLCD,VD_PWR_ON_FB]
		ON[dvTP,VD_PWR_ON]
		IF(nCmd=VD_PWR_ON) CmdExecuted()
	}
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
					IF(nCmd = VD_SRC_VID1)
					{
						ON[vdvLCD,VD_SRC_VID1_FB]
						ON[dvTP,VD_SRC_VID1]
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
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					ON[vdvLCD,VD_SRC_VGA1_FB]
					ON[dvTP,VD_SRC_VGA1]
					IF(nCmd=VD_SRC_VGA1) CmdExecuted()
					cCmdStr[VD_ASPECT2]	= "'WIDE   2',$0D"					
				}
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)):
				{
					ON[vdvLCD,VD_SRC_CMPNT1_FB]
					ON[dvTP,VD_SRC_CMPNT1]
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()	
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
		CASE PollMute: 
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)):
				{
					ON[vdvLCD,VD_VOL_MUTE_ON_FB]
					ON[dvTP,VD_VOL_MUTE_ON]
					IF(nCmd=VD_VOL_MUTE and !nMute) 
					{
						CmdExecuted()
					}
					on[nMute]
					on[dvTP,VD_VOL_MUTE]
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					ON[vdvLCD,VD_VOL_MUTE_OFF_FB]
					ON[dvTP,VD_VOL_MUTE_OFF]
					
					IF(nCmd=VD_VOL_MUTE and nMute)
					{
						CmdExecuted()
					}
					off[nMute]
					off[dvTP,VD_VOL_MUTE]
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

cCmdStr[VD_PWR_ON]		=	"'POWR   1',$0D" 			
cCmdStr[VD_PWR_OFF]		=	"'POWR   0',$0D"
cCmdStr[VD_SRC_DVI1]	=	"'INPS   1',$0D"	//dvi
cCmdStr[VD_SRC_VGA1]	=	"'INPS   2',$0D"	//vga port
cCmdStr[VD_SRC_RGB1]	=	"'INPS   6',$0D"  //rgbhv ports
cCmdStr[VD_SRC_CMPNT1]	=	"'IAVD   1',$0D"	//component
cCmdStr[VD_SRC_VID1]	=	"'INPS   4',$0D"  //video
cCmdStr[VD_SRC_SVID]	=	"'INPS   4',$0D"  //svideo
cCmdStr[VD_ASPECT1]		=	"'WIDE   1',$0D"	//wide (1,2,3,4)
cCmdStr[VD_ASPECT2]		=	"'WIDE   2',$0D"	//normal (1,2)
cCmdStr[VD_PCADJ]		=	"'ASNC   1',$0D"	//pc adjust
cCmdStr[VD_VOL_MUTE_ON]	=	"'MUTE1   ',$0D"
cCmdStr[VD_VOL_MUTE_OFF]=	"'MUTE0   ',$0D"

cPollStr[PollPwr]		=	"'POWR????',$0D"		
cPollStr[PollSrc]		=	"'IAVD????',$0D"					
cPollStr[PollMute]		="'MUTE????',$0D"

nNumPanels=length_array(dvTP)

WAIT 200
{
	IF(!TIMELINE_ACTIVE(lTLPoll))
		TIMELINE_CREATE(lTLPoll,lPollArray,4,TIMELINE_RELATIVE,TIMELINE_REPEAT)
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
	if(!timeline_active(lTLWait))
	{
		nPollType=TIMELINE.SEQUENCE
		SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE]"
	}
}

TIMELINE_EVENT[lTLCmd]
{
	if(!timeline_active(lTLWait))
	{
		SWITCH(TIMELINE.SEQUENCE)
		{
			CASE 1:	//first time
			{
				SWITCH(nCmd)
				{
					CASE VD_PWR_ON:
					{
						if (!timeline_active(lTLWait)) timeline_create(lTLWait,lWaitArray,1,timeline_relative,timeline_once)
						send_string dvLCD,cCmdStr[nCmd]
						nPollType=1
					}
					CASE VD_PWR_OFF:
					{
						SEND_STRING dvLCD,cCmdStr[nCmd]
						nPollType=1
					}
					CASE VD_SRC_VID1:
					CASE VD_SRC_SVID:
					CASE VD_SRC_CMPNT1:
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
					CASE VD_VOL_MUTE:
					{
						switch(nMute)
						{
							case 1: send_string dvLCD,cCmdStr[VD_VOL_MUTE_OFF]
							case 0: send_string dvLCD,cCmdStr[VD_VOL_MUTE_ON]
						}
						nPollType=PollMute
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
BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		if(button.input.channel=VD_VOL_UP or button.input.channel=VD_VOL_DOWN and !timeline_active(lTLWait))
		{
			switch(button.input.channel)
			{
				case VD_VOL_UP:
				{
					to[button.input]
					if(nVolume<60)nVolume++
					if(nVolume>=10) send_string dvLCD,"'VOLM',itoa(nVolume),'  ',$0D"
					else send_string dvLCD,"'VOLM0',itoa(nVolume),'  ',$0D"
				}
				case VD_VOL_DOWN:
				{
					to[button.input]
					if(nVolume>0) nVolume--
					if(nVolume>=10) send_string dvLCD,"'VOLM',itoa(nVolume),'  ',$0D"
					else send_string dvLCD,"'VOLM0',itoa(nVolume),'  ',$0D"
				}
			}
		}
		else
		{
			SWITCH(button.input.channel)
			{
				CASE VD_ASPECT1:
				CASE VD_ASPECT2:
				CASE VD_PCADJ:
				CASE VD_VOL_MUTE: 
				case VD_PWR_OFF:
				{
					to[button.input]
					PULSE[vdvLCD,button.input.channel]
				}
				case VD_PWR_ON:
				{
					to[button.input]
					nPollType=1
					if (!timeline_active(lTLWait)) send_string dvLCD,cCmdStr[VD_PWR_ON]
					timeline_create(lTLWait,lWaitArray,1,timeline_relative,timeline_once)
					PULSE[vdvLCD,button.input.channel]
				}
			}	
		}
	}
	hold[3,repeat]:
	{
		if(!timeline_active(lTLWait))
		{
			if(button.holdtime<1500)
			{
				switch(button.input.channel)
				{
					case VD_VOL_UP:
					{
						if(nVolume<60)nVolume++
						if(nVolume>=10) send_string dvLCD,"'VOLM',itoa(nVolume),'  ',$0D"
						else send_string dvLCD,"'VOLM0',itoa(nVolume),'  ',$0D"
						send_level dvTP,1,nVolume
					}
					case VD_VOL_DOWN:
					{
						if(nVolume>0) nVolume--
						if(nVolume>=10) send_string dvLCD,"'VOLM',itoa(nVolume),'  ',$0D"
						else send_string dvLCD,"'VOLM0',itoa(nVolume),'  ',$0D"
						send_level dvTP,1,nVolume
					}
				}
			}
			else
			{
				switch(button.input.channel)
				{
					case VD_VOL_UP:
					{
						nVolume=nVolume+3
						if(nVolume>60)nVolume=60
						if(nVolume>=10) send_string dvLCD,"'VOLM',itoa(nVolume),'  ',$0D"
						else send_string dvLCD,"'VOLM0',itoa(nVolume),'  ',$0D"
						send_level dvTP,1,nVolume
					}
					case VD_VOL_DOWN:
					{
						if(nVolume>2) nVolume=nVolume-3
						else nVolume=0
						if(nVolume>=10) send_string dvLCD,"'VOLM',itoa(nVolume),'  ',$0D"
						else send_string dvLCD,"'VOLM0',itoa(nVolume),'  ',$0D"
						send_level dvTP,1,nVolume
					}
				}
			}
		}
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

