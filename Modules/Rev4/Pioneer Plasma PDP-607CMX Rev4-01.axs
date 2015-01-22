MODULE_NAME='Pioneer Plasma PDP-607CMX Rev4-01'(dev dvTP, dev vdvPlas, dev dvPlas)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/24/2008  AT: 08:42:03        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//define_module 'Pioneer Plasma PDP-607CMX Rev4-01' disp1(vdvTP_DISP1,vdvDISP1,dvPlasma)
//Set baud to 9600,N,8,1
#INCLUDE 'HoppSNAPI Rev4-01.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll		= 2001
LONG lTLCmd         = 2002

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE


VOLATILE CHAR cBuff[255]
VOLATILE CHAR cCmdStr[50][20]	
VOLATILE CHAR cPollStr[20]
VOLATILE LONG lPollArray[]			= {3100}
VOLATILE LONG lCmdArray[]				=	{510,510}
VOLATILE INTEGER nCmd 					= 0
VOLATILE INTEGER nCmdBtn[]			={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
																  16,17,18,19,20,21,22,23,24,25}
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([vdvPlas,VD_PWR_ON_FB],[vdvPlas,VD_PWR_OFF_FB])
([vdvPlas,VD_SRC_RGB1_FB],[vdvPlas,VD_SRC_RGB2_FB],[vdvPlas,VD_SRC_VID1_FB],[vdvPlas,VD_SRC_SVID_FB],[vdvPlas,VD_SRC_RGB3_FB])

([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvTP,VD_SRC_RGB1],[dvTP,VD_SRC_RGB2],[dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_RGB3])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION CmdExecuted()
{
	nCmd=0
	IF(TIMELINE_ACTIVE(lTLCmd))TIMELINE_KILL(lTLCmd)
	TIMELINE_RESTART(lTLPoll)
}

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR CHAR cVar[1]
	
	IF(FIND_STRING(cCompStr,"'GST'",1))
	{
		//power
		REMOVE_STRING(cCompStr,"'M'",1)
		cVar=GET_BUFFER_STRING(cCompStr,1)
		SELECT
		{
			ACTIVE(cVar='P'): 
			{
				[vdvPlas,VD_PWR_ON_FB]=1
				[dvTP,VD_PWR_ON]=1
				IF(nCmd=VD_PWR_ON) CmdExecuted()
			}
			ACTIVE(cVar='S'): 
			{
				[vdvPlas,VD_PWR_OFF_FB]=1
				[dvTP,VD_PWR_OFF]=1
				IF(nCmd=VD_PWR_OFF) CmdExecuted()
			}
		}
		//input
		REMOVE_STRING(cCompStr,"'IN'",1)
		cVar=GET_BUFFER_STRING(cCompStr,1)
		SWITCH(ATOI(cVAR))
		{
			CASE 1: 
			{
				[vdvPlas,VD_SRC_RGB1_FB]=1
				[dvTP,VD_SRC_RGB1]=1
				IF(nCmd=VD_SRC_RGB1) 	CmdExecuted()
			}
			CASE 2: 
			{
				[vdvPlas,VD_SRC_RGB2_FB]=1
				[dvTP,VD_SRC_RGB2]=1
				IF(nCmd=VD_SRC_RGB2) 	CmdExecuted()
			}
			CASE 3: 			
			{
				[vdvPlas,VD_SRC_SVID_FB]=1
				[dvTP,VD_SRC_SVID]=1
				IF(nCmd=VD_SRC_SVID) 	CmdExecuted()
			}
			CASE 4: 			
			{
				[vdvPlas,VD_SRC_VID1_FB]=1
				[dvTP,VD_SRC_VID1]=1
				IF(nCmd=VD_SRC_VID1) 	CmdExecuted()
			}
			CASE 5: 			
			{
				[vdvPlas,VD_SRC_RGB3_FB]=1
				[dvTP,VD_SRC_RGB3]=1
				IF(nCmd=VD_SRC_RGB3) 	CmdExecuted()
			}
		}
	}
}

define_function power_on()
{
	on[vdvPlas,VD_PWR_ON_FB]
	on[dvTP,VD_PWR_ON]
}


define_function power_off()
{
	on[vdvPlas,VD_PWR_OFF_FB]
	on[dvTP,VD_PWR_OFF]
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
cCmdStr[VD_PWR_ON]		= "$02,'**PON',$03"		//power on
cCmdStr[VD_PWR_OFF]		= "$02,'**POF',$03"		//power off
cCmdStr[VD_SRC_RGB1]	= "$02,'**IN3',$03"		//hd15
cCmdStr[VD_SRC_VID1]		= "$02,'**IN1',$03"		//vid
cCmdStr[VD_PCADJ]			= "$02,'**AST',$03"		//pc adjust

cPollStr	=	"$02,'**GST',$03"								//query

TIMELINE_CREATE(lTLPoll,lPollArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvPlas]
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
				ACTIVE(FIND_STRING(cBuff,"$03",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$03",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$03",1)):
				{
					nPos=FIND_STRING(cBuff,"$03",1)
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
	//SEND_STRING dvPlas,"cPollStr"
}
TIMELINE_EVENT[lTLCmd]	
{
	SWITCH(TIMELINE.SEQUENCE)
	{
		CASE 1:
		{
			SWITCH(nCmd)
			{
				CASE VD_PWR_ON:
				{
					SEND_STRING dvPlas,"cCmdStr[nCmd]"
					CmdExecuted()
					power_on()
				}
				CASE VD_PWR_OFF:	
				{
					SEND_STRING dvPlas,"cCmdStr[nCmd]"
					CmdExecuted()
					power_off()
				}
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:
				CASE VD_SRC_SVID:
				CASE VD_SRC_VID1:
				CASE VD_SRC_RGB3:
				{
					SEND_STRING dvPlas,"cCmdStr[nCmd]"
					power_on()
					wait 10 SEND_STRING dvPlas,"cCmdStr[VD_PWR_ON]"
					wait 110 'Startup'
					{	
						SEND_STRING dvPlas,"cCmdStr[nCmd]"
						CmdExecuted()
					}
				}
				CASE VD_PWR_TOG:
				{
					IF(![vdvPlas,VD_PWR_ON_FB]) nCmd=VD_PWR_ON
					ELSE nCmd=VD_PWR_OFF
					SEND_STRING dvPlas,"cCmdStr[nCmd]"
					CmdExecuted()
				}
				CASE VD_PCADJ:
				{
					IF([vdvPlas,VD_PWR_ON_FB]) SEND_STRING dvPlas,"cCmdStr[nCmd]"
					CmdExecuted()
				}
			}	
		}	
		CASE 2:{}	//SEND_STRING dvPlas,"cPollStr"
	}
}
CHANNEL_EVENT[vdvPlas,0]
{
	ON:
	{
		IF(channel.channel<200)
		{
			nCmd=channel.channel
			//TIMELINE_PAUSE(lTLPoll)
//			WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			SWITCH(nCmd)
			{
				CASE VD_PWR_ON:
				{
					SEND_STRING dvPlas,"cCmdStr[nCmd]"
					CmdExecuted()
					power_on()
				}
				CASE VD_PWR_OFF:	
				{
					SEND_STRING dvPlas,"cCmdStr[nCmd]"
					CmdExecuted()
					power_off()
				}
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:
				CASE VD_SRC_SVID:
				CASE VD_SRC_VID1:
				CASE VD_SRC_RGB3:
				{
					cancel_wait 'Startup'
					SEND_STRING dvPlas,"cCmdStr[nCmd]"
					power_on()
					wait 10 SEND_STRING dvPlas,"cCmdStr[VD_PWR_ON]"
					wait 110 'Startup'
					{	
						SEND_STRING dvPlas,"cCmdStr[nCmd]"
						CmdExecuted()
					}
				}
				CASE VD_PWR_TOG:
				{
					IF(![vdvPlas,VD_PWR_ON_FB]) nCmd=VD_PWR_ON
					ELSE nCmd=VD_PWR_OFF
					SEND_STRING dvPlas,"cCmdStr[nCmd]"
					CmdExecuted()
				}
				CASE VD_PCADJ:
				{
					IF([vdvPlas,VD_PWR_ON_FB]) SEND_STRING dvPlas,"cCmdStr[nCmd]"
					CmdExecuted()
				}
			}	
		}
	}
}
BUTTON_EVENT[dvTP,nCmdBtn]
{
	PUSH:
	{
		TO[vdvPlas,button.input.channel]
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

