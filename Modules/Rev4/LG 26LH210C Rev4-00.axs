MODULE_NAME='LG 26LH210C Rev4-00'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE CREATED ON: 06/19/2008  AT: 09:13:07              *)
(***********************************************************)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/19/2008  AT: 14:51:29        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    //define_module 'LG 26LH210C Rev4-00' disp1(vdvTP_DISP1,vdvDISP1,dvPlasma)
//Set baud to 9600,N,8,1
*)
#INCLUDE 'HoppSNAPI Rev4-01.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant

lTLPoll		=	2001
lTLCmd		=	2002

PollPwr		=	1
PollSrc		=	2
PollAspct	=	3

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

non_volatile long lPollArray[]=
{
	5100,
	5100,
	5100
}
non_volatile long lCmdArray[]=
{
	510,
	510
}

non_volatile integer nPollType

non_volatile char cCmdStr[30][10]
non_volatile char cPollStr[3][10]
non_volatile char cRespStr[30][10]

non_volatile integer nCmd=0
non_volatile integer nPlasmaBtns[]=
{
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	12,
	13,
	14,
	15,
	16,
	17,
	18,
	19,
	20,
	21,
	22,
	23,
	24,
	25,
	26,
	27,
	28,
	29
}   

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvTP,VD_ASPECT1],[dvTP,VD_ASPECT2])
([dvTP,VD_SRC_VGA1],[dvTP,VD_SRC_VID1],[dvTP,VD_SRC_RGB2],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_RGB1])
 
([vdvLCD,VD_PWR_ON_FB],[vdvLCD,VD_PWR_OFF_FB])
([vdvLCD,VD_ASPECT1_FB],[vdvLCD,VD_ASPECT2_FB])
([vdvLCD,VD_SRC_VGA1_FB],[vdvLCD,VD_SRC_VID1_FB],[vdvLCD,VD_SRC_RGB2_FB],[vdvLCD,VD_SRC_SVID_FB],[vdvLCD,VD_SRC_CMPNT1_FB],[vdvLCD,VD_SRC_RGB1_FB])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

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
			on[vdvLCD,VD_PWR_ON_FB]
			on[dvTP,VD_PWR_ON]
			if(nCmd=VD_PWR_ON) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_PWR_OFF],1)):
		{
			on[vdvLCD,VD_PWR_OFF_FB]
			on[dvTP,VD_PWR_OFF]
			if(nCmd=VD_PWR_OFF) CmdExecuted()
		}
		
		active(find_string(cCompStr,cRespStr[VD_SRC_VGA1],1)):
		{
			on[vdvLCD,VD_SRC_VGA1_FB]
			on[dvTP,VD_SRC_VGA1]
			if(nCmd=VD_SRC_VGA1) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_RGB1],1)):
		{
			on[vdvLCD,VD_SRC_RGB1_FB]
			on[dvTP,VD_SRC_RGB1]
			if(nCmd=VD_SRC_RGB1) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_RGB2],1)):
		{
			on[vdvLCD,VD_SRC_RGB2_FB]
			on[dvTP,VD_SRC_RGB2]
			if(nCmd=VD_SRC_RGB2) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_VID1],1)):
		{
			on[vdvLCD,VD_SRC_VID1_FB]
			on[dvTP,VD_SRC_VID1]
			if(nCmd=VD_SRC_VID1) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_SVID],1)):
		{
			on[vdvLCD,VD_SRC_SVID_FB]
			on[dvTP,VD_SRC_SVID]
			if(nCmd=VD_SRC_SVID) CmdExecuted()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_CMPNT1],1)):
		{
			on[vdvLCD,VD_SRC_CMPNT1_FB]
			on[dvTP,VD_SRC_CMPNT1]
			if(nCmd=VD_SRC_CMPNT1) CmdExecuted()
		}
		
//		active(find_string(cCompStr,cRespStr[VD_ASPECT1],1)):
//		{
//			on[vdvLCD,VD_ASPECT1_FB]
//			on[dvTP,VD_ASPECT1]
//			if(nCmd=VD_ASPECT1) CmdExecuted()
//		}
//		active(find_string(cCompStr,cRespStr[VD_ASPECT2],1)):
//		{
//			on[vdvLCD,VD_ASPECT2_FB]
//			on[dvTP,VD_ASPECT2]
//			if(nCmd=VD_ASPECT2) CmdExecuted()
//		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

cCmdStr[VD_PWR_ON]		=	"'ka 1 1',$0D"
cCmdStr[VD_PWR_OFF]		=	"'ka 1 0',$0D"

cCmdStr[VD_SRC_VGA1]	=	"'kb 1 7',$0D"
cCmdStr[VD_SRC_RGB1]	=	"'kb 1 8',$0D"
cCmdStr[VD_SRC_RGB2]	=	"'kb 1 9',$0D"
cCmdStr[VD_SRC_VID1]	=	"'kb 1 2',$0D"
cCmdStr[VD_SRC_SVID]	=	"'kb 1 3',$0D"
cCmdStr[VD_SRC_CMPNT1]	=	"'kb 1 4',$0D" 

//cCmdStr[VD_ASPECT1]		=	"'kc 1 ',$00,$0D"
//cCmdStr[VD_ASPECT2]		=	"'kc 1 ',$02,$0D"

cRespStr[VD_PWR_ON]		=	"'a 01 OK01x'"
cRespStr[VD_PWR_OFF]	=	"'a 01 OK00x'"

cRespStr[VD_SRC_VGA1]	=	"'b 01 OK07x'"
cRespStr[VD_SRC_RGB1]	=	"'b 01 OK08x'"
cRespStr[VD_SRC_RGB2]	=	"'b 01 OK09x'"
cRespStr[VD_SRC_VID1]	=	"'b 01 OK02x'"
cRespStr[VD_SRC_SVID]	=	"'b 01 OK03x'"
cRespStr[VD_SRC_CMPNT1]	=	"'b 01 OK04x'" 

//cRespStr[VD_ASPECT1]	=	"'c 1 OK',$00,'x'"
//cRespStr[VD_ASPECT2]	=	"'c 1 OK',$02,'x'"


cPollStr[PollPwr]		=	"'ka 1 FF',$0D"
cPollStr[PollSrc]		=	"'kb 1 FF',$0D"
//cPollStr[PollAspct]		=	"'kc 1 ',$FF,$0D"



WAIT 200
{
	IF(!TIMELINE_ACTIVE(lTLPoll))
		TIMELINE_CREATE(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

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
				ACTIVE(FIND_STRING(cBuff,"'x'",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"'x'",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"'x'",1)):
				{
					nPos=FIND_STRING(cBuff,"'x'",1)
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
					SEND_STRING dvLCD,"cCmdStr[nCmd]"
					nPollType=1
				}
				CASE VD_SRC_VID1:
				CASE VD_SRC_SVID:
				CASE VD_SRC_CMPNT1:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:
				{
					IF([vdvLCD,VD_PWR_ON_FB])
					{
						SEND_STRING dvLCD,"cCmdStr[nCmd]"
						nPollType=PollSrc
					}
					ELSE
					{
						SEND_STRING dvLCD,"cCmdStr[VD_PWR_ON]"
						nPollType=PollPwr
					}
				}
//				CASE VD_ASPECT1:
//				CASE VD_ASPECT2:
//				{
//					IF([vdvLCD,VD_PWR_ON_FB]) 
//					{
//						SEND_STRING dvLCD,"cCmdStr[nCmd]"
//						nPollType=PollAspct
//					}
//					ELSE CmdExecuted()
//				}
//				CASE VD_PCADJ:
//				{
//					IF([vdvLCD,VD_PWR_ON_FB]) SEND_STRING dvLCD,"cCmdStr[nCmd]"
//					CmdExecuted()
//				}
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
BUTTON_EVENT[dvTP,nPlasmaBtns]
{
	PUSH:
	{
		TO[button.input.device,button.input.channel]
		PULSE[vdvLCD,button.input.channel]
	}
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************) 

