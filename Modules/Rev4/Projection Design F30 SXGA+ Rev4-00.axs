MODULE_NAME='Projection Design F30 SXGA+ Rev4-00'(dev dvTP, dev vdvProj, dev dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:26:22        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
(*  


	define_module 'Projection Design F30 SXGA+ Rev4-00' proj1(vdvTP_DISP1,vdvDISP1,dvProj1)
	
	Set Baud to 19200,N,8,1,485 DISABLE

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
integer x
integer nNumPanels

CHAR cCmdStr[34][20]	
CHAR cPollStr[4][20]
char cRespStr[34][20]

INTEGER nCmd=0

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvTP,VD_SRC_VGA1],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_RGB1])
 
([vdvProj,VD_PWR_ON_FB],[vdvProj,VD_PWR_OFF_FB])
([vdvProj,VD_SRC_VGA1_FB],[vdvProj,VD_SRC_CMPNT1_FB],[vdvProj,VD_SRC_RGB1_FB])
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
	select
	{
		active(find_string(cCompStr,cRespStr[VD_PWR_ON],1)):
		{
			ON[vdvProj,VD_PWR_ON_FB]
			ON[dvTP,VD_PWR_ON]
			IF(nCmd=VD_PWR_ON) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_PWR_OFF],1)):
		{
			ON[vdvProj,VD_PWR_OFF_FB]
			ON[dvTP,VD_PWR_OFF]
			IF(nCmd=VD_PWR_OFF) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_VGA1],1)):
		{
			ON[vdvProj,VD_SRC_VGA1_FB]
			ON[dvTP,VD_SRC_VGA1]
			IF(nCmd=VD_SRC_VGA1) CmdExecuted()
		}   
		active(find_string(cCompStr,cRespStr[VD_SRC_CMPNT1],1)):
		{
			ON[vdvProj,VD_SRC_CMPNT1_FB]
			ON[dvTP,VD_SRC_CMPNT1]
			IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()	
		}
		active(find_string(cCompStr,"'%001 IABS'",1)):
		{
			remove_string(cCompStr,"'%001 IABS 00000'",1)
			switch(left_string(cCompStr,1))
			{
				case '0':
				{
					ON[vdvProj,VD_SRC_VGA1_FB]
					ON[dvTP,VD_SRC_VGA1]
					IF(nCmd=VD_SRC_VGA1) CmdExecuted()
				}   
				case '1':
				{
					on[vdvProj,VD_SRC_RGB1_FB]
					on[dvTP,VD_SRC_RGB1]
					if(nCmd=VD_SRC_RGB1) CmdExecuted()
				}
				case '6':
				{
					ON[vdvProj,VD_SRC_CMPNT1_FB]
					ON[dvTP,VD_SRC_CMPNT1]
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()	
				}   
			}
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		=	"':POWR1',$0D" 			
cCmdStr[VD_PWR_OFF]		=	"':POWR0',$0D"
cCmdStr[VD_SRC_VGA1]	=	"':IVGA',$0D"	//vga port
cCmdStr[VD_SRC_CMPNT1]	=	"':IYPP',$0D"	//component
cCmdStr[VD_SRC_RGB1]	=	"':IBNC',$0D"

cPollStr[PollPwr]		=	"':POWR?',$0D"		
cPollStr[PollSrc]		=	"':IABS?',$0D"					

cRespStr[VD_PWR_ON]		=	"'%001 POWR 000001',$0D,$0D,$0A"
cRespStr[VD_PWR_OFF]	=	"'%001 POWR 000000',$0D,$0D,$0A"
cRespStr[VD_SRC_VGA1]	=	"'%001 IVGA 000001',$0D,$0D,$0A"
cRespStr[VD_SRC_RGB1]	=	"'%001 IBNC 000001',$0D,$0D,$0A"
cRespStr[VD_SRC_CMPNT1]	=	"'%001 IYPP 000001',$0D,$0D,$0A"

WAIT 200
{
	IF(!TIMELINE_ACTIVE(lTLPoll))
		TIMELINE_CREATE(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvProj]
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
				ACTIVE(FIND_STRING(cBuff,"$0A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					send_string 0,"cFullStr"
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0A",1)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
					send_string 0,"cFullStr"
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
				CASE VD_PWR_OFF:
				{
					SEND_STRING dvProj,cCmdStr[nCmd]
					nPollType=1
				}
				CASE VD_SRC_CMPNT1:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_RGB1:
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType=PollSrc
					}
					ELSE
					{
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						nPollType=PollPwr
					}
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

