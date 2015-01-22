MODULE_NAME='Sharp LCD LC52E77U Rev4-01'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:26:22        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*  


	define_module 'Sharp LCD LC52E77U Rev4-01' lcd1(vdvTP_DISP1,vdvDISP1,dvLCD)
	
	Set Baud to 9600,N,8,1,485 DISABLE

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
integer nNumPanels

CHAR cCmdStr[60][20]	
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
([dvTP,VD_SRC_VGA1],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_CMPNT2],[vdvLCD,VD_SRC_AUX1],[vdvLCD,VD_SRC_AUX2])
 
([vdvLCD,VD_PWR_ON_FB],[vdvLCD,VD_PWR_OFF_FB])
([vdvLCD,VD_SRC_VGA1_FB],[vdvLCD,VD_SRC_CMPNT1_FB],[vdvLCD,VD_SRC_CMPNT2_FB],[vdvLCD,VD_SRC_AUX1_FB],[vdvLCD,VD_SRC_AUX2_FB])
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
					ON[vdvLCD,VD_SRC_VGA1_FB]
					ON[dvTP,VD_SRC_VGA1]
					IF(nCmd=VD_SRC_VGA1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,"'2'",1)):
				{
					ON[vdvLCD,VD_SRC_CMPNT1_FB]
					ON[dvTP,VD_SRC_CMPNT1]
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'1'",1)):
				{
					ON[vdvLCD,VD_SRC_CMPNT2_FB]
					ON[dvTP,VD_SRC_CMPNT2]
					IF(nCmd=VD_SRC_CMPNT2) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'7'",1)):
				{
					ON[vdvLCD,VD_SRC_AUX1_FB]
					ON[dvTP,VD_SRC_AUX1]
					IF(nCmd=VD_SRC_AUX1) CmdExecuted()	
				}
				ACTIVE(FIND_STRING(cCompStr,"'ERR'",1)):
				{
					if([vdvLCD,VD_PWR_ON_FB]) 
					{
						on[vdvLCD,VD_SRC_AUX2_FB]
						on[dvTP,VD_SRC_AUX2]
						if(nCmd=VD_SRC_AUX2) CmdExecuted()
					}
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

cCmdStr[VD_PWR_ON]		= "'POWR1   ',$0D" 			
cCmdStr[VD_PWR_OFF]		= "'POWR0   ',$0D"
cCmdStr[VD_SRC_VGA1]	= "'IAVD4   ',$0D"	//vga port
cCmdStr[VD_SRC_CMPNT1]	= "'IAVD2   ',$0D"	//component
cCmdStr[VD_SRC_AUX1]	= "'IAVD7   ',$0D"  //hdmi
cCmdStr[VD_SRC_AUX2]	= "'ITVD0   ',$0D"
cCmdStr[VD_SRC_CMPNT2]	= "'IAVD1   ',$0D" //component 2
cCmdStr[VD_VOL_MUTE_ON]	=	"'MUTE1   ',$0D"
cCmdStr[VD_VOL_MUTE_OFF]=	"'MUTE0   ',$0D"
        
cPollStr[PollPwr]			=	"'POWR????',$0D"		
cPollStr[PollSrc]			=	"'IAVD????',$0D"
cPollStr[PollMute]			=	"'MUTE????',$0D"				

nNumPanels=length_array(dvTP)

WAIT 200
{
	send_string dvLCD,"'RSPW1   ',$0D"
	IF(!TIMELINE_ACTIVE(lTLPoll))
		TIMELINE_CREATE(lTLPoll,lPollArray,3,TIMELINE_RELATIVE,TIMELINE_REPEAT)
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
	nPollType=TIMELINE.SEQUENCE
	SEND_STRING dvLCD,"cPollStr[TIMELINE.SEQUENCE]"
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
				CASE VD_SRC_CMPNT1:
				CASE VD_SRC_CMPNT2:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_AUX1:
				CASE VD_SRC_AUX2:
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
				TIMELINE_CREATE(lTLPoll,lPollArray,3,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}
BUTTON_EVENT[dvTP,0]
{
	PUSH:
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
			default:
			{
				to[button.input]
				pulse[vdvLCD,button.input.channel]
			}
		}
	}
	hold[3,repeat]:
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
					send_level dvTP,1,nVolume*255/60
				}
				case VD_VOL_DOWN:
				{
					if(nVolume>0) nVolume--
					if(nVolume>=10) send_string dvLCD,"'VOLM',itoa(nVolume),'  ',$0D"
					else send_string dvLCD,"'VOLM0',itoa(nVolume),'  ',$0D"
					send_level dvTP,1,nVolume*255/60
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
					send_level dvTP,1,nVolume*255/60
				}
				case VD_VOL_DOWN:
				{
					if(nVolume>2) nVolume=nVolume-3
					else nVolume=0
					if(nVolume>=10) send_string dvLCD,"'VOLM',itoa(nVolume),'  ',$0D"
					else send_string dvLCD,"'VOLM0',itoa(nVolume),'  ',$0D"
					send_level dvTP,1,nVolume*255/60
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

