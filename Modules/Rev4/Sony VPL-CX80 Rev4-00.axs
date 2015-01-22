MODULE_NAME='Sony VPL-CX80 Rev4-00'(DEV vdvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  
	 Written by: 		Ben Whitford
	 Date: 			 		5/3/07
	 First Project:	40043
	 *)
(***********************************************************)
(*   
	SET BAUD 38400,E,8,1 485 DISABLE
	define_module 'Sony VPL-CX80 Rev4-00' proj1(vdvTP_DISP1,vdvDISP1,dvProj)
*)

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

INTEGER PollPower 	= 1
INTEGER PollInput 	= 2
INTEGER PollMute 	= 3
INTEGER PollLamp	= 4

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]	= {3100,3100,3100,3100}
LONG lCmdArray[]  =	{510,510}

INTEGER nPollType

CHAR cResp[100]
CHAR cCmdStr[40][20]	
CHAR cPollStr[4][20]
CHAR cRespStr[35][20]

INTEGER nPwrVerify = 0

INTEGER nCmd = 0
INTEGER btn_PROJ[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,
										 23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40}

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

([vdvTP,VD_PWR_ON],[vdvTP,VD_PWR_OFF])
([vdvTP,VD_MUTE_ON],[vdvTP,VD_MUTE_OFF])
([vdvTP,VD_SRC_VGA1],[vdvTP,VD_SRC_VGA2],[vdvTP,VD_SRC_VID1],[vdvTP,VD_SRC_SVID])

([vdvProj,VD_PWR_ON_FB],[vdvProj,VD_WARMING_FB],[vdvProj,VD_COOLING_FB],[vdvProj,VD_PWR_OFF_FB])
([vdvProj,VD_MUTE_ON_FB],[vdvProj,VD_MUTE_OFF_FB])
([vdvProj,VD_SRC_VGA1_FB],[vdvProj,VD_SRC_VGA2_FB],[vdvProj,VD_SRC_VID1_FB],[vdvProj,VD_SRC_SVID_FB])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
DEFINE_FUNCTION CHAR[8] BuildSonyPacket(CHAR cCmd[5])
{
  STACK_VAR CHAR cCheckSum;
  STACK_VAR INTEGER I;
  
  cCheckSum = 0;
  FOR (I = 1; I <= 5; I++)
  {
    cCheckSum = cCheckSum | cCmd[I];
  }
  
  RETURN "$A9,cCmd,cCheckSum,$9A";
}


DEFINE_FUNCTION CmdExecuted()
{
	ncmd=0
	TIMELINE_KILL(lTLCmd)
	TIMELINE_RESTART(lTLPoll)
}

DEFINE_FUNCTION StartCommand()
{
	TIMELINE_PAUSE(lTLPoll)
	IF(!TIMELINE_ACTIVE(lTLCmd))
		WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER x 
	STACK_VAR INTEGER nLamp
	send_string 0,"'Parsing: ',cCompStr"
	select
	{
		active(find_string(cCompStr,"$A9,$01,$02,$02,$00",1)):
		{
			switch(cCompStr[6])
			{
				case $00:
				{
					ON[vdvProj,VD_PWR_OFF_FB]
					ON[vdvTP,VD_PWR_OFF]
					IF(nCmd = VD_PWR_OFF) CmdExecuted()
				}
				case $03:
				{
					ON[vdvTP,VD_PWR_ON]
					ON[vdvProj,VD_PWR_ON_FB]
					IF(nCmd = VD_PWR_ON) CmdExecuted()
				}
				case $01:
				{
					ON[vdvProj,VD_WARMING_FB]
					ON[vdvTP,VD_PWR_ON]
					IF(ncmd = VD_PWR_ON) CmdExecuted()
				}
				case $02:
				{
					ON[vdvProj,VD_WARMING_FB]
					ON[vdvTP,VD_PWR_ON]
					IF(ncmd = VD_PWR_ON) CmdExecuted()
				}
				case $04:
				{
					ON[vdvProj,VD_COOLING_FB]
					ON[vdvTP,VD_PWR_OFF]
					IF(ncmd = VD_PWR_OFF) CmdExecuted()
				}
				case $05:
				{
					ON[vdvProj,VD_COOLING_FB]
					ON[vdvTP,VD_PWR_OFF]
					IF(ncmd = VD_PWR_OFF) CmdExecuted()
				}
			}
		}
		active(find_string(cCompStr,"$A9,$00,$01,$02,$00",1)):
		{
			switch(cCompStr[6])
			{
				case $00:
				{
					ON[vdvProj,VD_SRC_VID1_FB]
					ON[vdvTP,VD_SRC_VID1]
					if(nCmd=VD_SRC_VID1) CmdExecuted()
				}
				case $01:
				{
					ON[vdvProj,VD_SRC_SVID_FB]
					ON[vdvTP,VD_SRC_SVID]
					if(nCmd=VD_SRC_SVID) CmdExecuted()
				}
				case $02:
				{
					ON[vdvProj,VD_SRC_VGA1_FB]
					ON[vdvTP,VD_SRC_VGA1]
					if(nCmd=VD_SRC_VGA1) CmdExecuted()
				}
				case $03:
				{
					ON[vdvProj,VD_SRC_VGA2_FB]
					ON[vdvTP,VD_SRC_VGA2]
					if(nCmd=VD_SRC_VGA2) CmdExecuted()
				}
			}
		}
		active(find_string(cCompStr,"$A9,$00,$30,$02,$00",1)):
		{
			switch(cCompStr[6])
			{
				case $00:
				{
					ON[vdvProj,VD_MUTE_OFF_FB]
					ON[vdvTP,VD_MUTE_OFF]
					IF(nCmd = VD_MUTE_OFF) CmdExecuted()
				}
				case $01:
				{
					ON[vdvProj,VD_MUTE_ON_FB]
					ON[vdvTP,VD_MUTE_ON]
					IF(nCmd = VD_MUTE_ON) CmdExecuted()
				}
			}
		}
		active(find_string(cCompStr,"$A9,$01,$13,$02",1)):
		{
			nLamp=(cCompStr[5]*256)+cCompStr[6]
			SEND_COMMAND vdvTP,"'^TXT-1,0,',ITOA(nLamp)"
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "$17,$2E,$00,$00,$00"	//on
cCmdStr[VD_PWR_OFF]			= "$17,$2F, $00, $00,$00"	//off
cCmdStr[VD_SRC_VGA1]		= "$00,$01, $00, $00,$02"   //input A
cCmdStr[VD_SRC_VGA2]		= "$00,$01, $00, $00,$03"	//input B
cCmdStr[VD_SRC_VID1] 		= "$00,$01, $00, $00,$00"	//input2 video
cCmdStr[VD_SRC_SVID]		= "$00,$01, $00, $00,$01"	//input3 svideo

cCmdStr[VD_MUTE_ON]			= "$00,$30, $00, $00,$01"	//mute on
cCmdStr[VD_MUTE_OFF]		= "$00,$30, $00, $00,$00"	//mute off

cPollStr[PollPower]		= "$01,$02, $01, $00,$00"	//pwr
cPollStr[PollInput] 	= "$00,$01, $01, $00,$00"	//input
cPollStr[PollMute] 		= "$00,$30, $01, $00,$00"	//extcmd mute
cPollStr[PollLamp] 		= "$01,$13, $01, $00,$00"	//lamp hours

cRespStr[VD_PWR_ON] 		= "'00',$0D"
cRespStr[VD_PWR_OFF]		= "'80',$0D"
cRespStr[VD_MUTE_OFF]		= "'000 OFF',$0D"
cRespStr[VD_MUTE_ON]		= "'000 ON',$0D"


WAIT 200
{
	IF(!TIMELINE_ACTIVE(lTLPoll))
	{
		TIMELINE_CREATE(lTLPoll,lPollArray,4,TIMELINE_RELATIVE,TIMELINE_REPEAT)
	}
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
		send_string 0,"cBuff"
		WHILE(LENGTH_STRING(cBuff))
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cBuff,"$9A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$9A",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$9A",1)):
				{
					nPos=FIND_STRING(cBuff,"$9A",1)
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

TIMELINE_EVENT[lTLPoll]				//Projector Polling
{
	SEND_STRING dvProj,"BuildSonyPacket(cPollStr[TIMELINE.SEQUENCE])"
	nPollType = TIMELINE.SEQUENCE
}

TIMELINE_EVENT[lTLCmd]		//Projector Commands
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
					SEND_STRING dvProj,BuildSonyPacket(cCmdStr[nCmd])
					nPollType = PollPower
				}
				CASE VD_SRC_VID1:
				CASE VD_SRC_SVID:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_VGA2:
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						IF(!nPwrVerify)
						{
							SEND_STRING dvProj,BuildSonyPacket(cCmdStr[nCmd])
							nPollType = PollInput
						}
					}
					IF([vdvProj,VD_WARMING_FB])
					{
						nPwrVerify = 0
						nPollType=PollPower
					}
					IF([vdvProj,VD_PWR_OFF_FB] || [vdvProj, VD_COOLING_FB])
					{
						nPwrVerify = 1
						SEND_STRING dvProj,BuildSonyPacket(cCmdStr[VD_PWR_ON])
						nPollType = PollPower
					}
				}
				CASE VD_MUTE_OFF:
				CASE VD_MUTE_ON:	
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						SEND_STRING dvProj,BuildSonyPacket(cCmdStr[nCmd])
						nPollType = PollMute
					}
					ELSE CmdExecuted()
				}
				CASE VD_MUTE_TOG:
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						IF([vdvProj,VD_MUTE_ON_FB]) nCmd=VD_MUTE_OFF
						ELSE nCmd = VD_MUTE_ON
						SEND_STRING dvProj,BuildSonyPacket(cCmdStr[nCmd])
						nPollType = PollMute
					}	
					ELSE CmdExecuted()
				}
			}
		}
		CASE 2:	//2nd time
		{
			IF(nPollType) SEND_STRING dvProj,BuildSonyPacket(cPollStr[nPollType])
		}
	}
}

CHANNEL_EVENT[vdvProj,0]
{
	ON:
	{
		IF(channel.channel<200)
		{
			nCmd = channel.channel
			StartCommand()
		}
	}
}

CHANNEL_EVENT[vdvProj,0]
{
	ON:
	{
		SELECT
		{
			ACTIVE(channel.channel<VD_POLL_BEGIN):
			{
				nCmd=channel.channel
				StartCommand()
			}
			ACTIVE(channel.channel=VD_POLL_BEGIN):
			{
				TIMELINE_CREATE(lTLPoll,lPollArray,4,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}

BUTTON_EVENT[vdvTP,btn_PROJ]
{
	PUSH:
	{
		to[button.input]
		nCmd = GET_LAST(btn_PROJ)
		StartCommand()
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


