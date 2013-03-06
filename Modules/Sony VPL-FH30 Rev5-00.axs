MODULE_NAME='Sony VPL-FH30 Rev5-00'(DEV vdvTP, DEV vdvProj, DEV dvProj)
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
	Set baud to 38400,E,8,1,485 DISABLE
	define_module 'Sony VPL-FH30 Rev5-00' proj1(vdvTP_DISP1,vdvDISP1,dvProj)
*)

#INCLUDE 'HoppSNAPI Rev5-08.axi'

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
integer PollLamp	= 3

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

integer		x

LONG lPollArray[]	= {3100,3100,3100}
LONG lCmdArray[]  =	{510,510}

INTEGER nPollType

CHAR cResp[100]
CHAR cCmdStr[80][20]	
CHAR cPollStr[4][20]
CHAR cRespStr[80][20]

INTEGER nPwrVerify = 0

INTEGER nCmd = 0

integer nLamp

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

([vdvTP,VD_PWR_ON],[vdvTP,VD_PWR_OFF])
([vdvTP,VD_SRC_HDMI1],[vdvTP,VD_SRC_AUX1],[vdvTP,VD_SRC_AUX2],[vdvTP,VD_SRC_AUX3],[vdvTP,VD_SRC_VID1],[vdvTP,VD_SRC_SVID])

([dvProj,VD_PWR_ON],[dvProj,VD_WARMING],[dvProj,VD_COOLING],[dvProj,VD_PWR_OFF])
([dvProj,VD_SRC_HDMI1],[dvProj,VD_SRC_AUX1],[dvProj,VD_SRC_AUX2],[dvProj,VD_SRC_AUX3],[dvProj,VD_SRC_VID1],[dvProj,VD_SRC_SVID])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function integer calcchecksumor(char cMsg[])
{
	stack_var integer nLoop
	stack_var char cCheckSum
	
	off[cCheckSum]
	for (nLoop=1;nLoop<=length_string(cMsg);nLoop++)
	{
		cCheckSum=cCheckSum|cMsg[nLoop]
	}
	return cCheckSum
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

define_function char[8] build_string(char cMsg[])
{
	if(length_string(cMsg)) cMsg="$A9,cMsg,calcchecksumor(cMsg),$9A"
	return cMsg
}

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER x 
	STACK_VAR INTEGER nLamp
	
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
		{			
			ON[vdvTP,VD_PWR_ON]
			ON[dvProj,VD_PWR_ON]
			IF(nCmd = VD_PWR_ON) CmdExecuted()
		}
		ACTIVE( FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1) or
				FIND_STRING(cCompStr,build_string("$01,$02,$02,$00,$08"),1)):
		{	
			ON[dvProj,VD_PWR_OFF]
			ON[vdvTP,VD_PWR_OFF]
			IF(nCmd = VD_PWR_OFF) CmdExecuted()
		}
		ACTIVE( FIND_STRING(cCompStr,build_string("$01,$02,$02,$00,$01"),1) or
				FIND_STRING(cCompStr,build_string("$01,$02,$02,$00,$02"),1)):	//Warming Up
		{
			ON[dvProj,VD_WARMING]
			ON[vdvTP,VD_PWR_ON]
			IF(ncmd = VD_PWR_ON) CmdExecuted()
		}
		ACTIVE( FIND_STRING(cCompStr,build_string("$01,$02,$02,$00,$04"),1) or
				FIND_STRING(cCompStr,build_string("$01,$02,$02,$00,$05"),1) or
				FIND_STRING(cCompStr,build_string("$01,$02,$02,$00,$06"),1) or
				FIND_STRING(cCompStr,build_string("$01,$02,$02,$00,$07"),1)):	//Cooling Down
		{
			ON[dvProj,VD_COOLING]
			ON[vdvTP,VD_PWR_OFF]
			IF(ncmd = VD_PWR_OFF) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_HDMI1],1)):
		{
			ON[dvProj,VD_SRC_HDMI1]
			ON[vdvTP,VD_SRC_HDMI1]
			IF(ncmd = VD_SRC_HDMI1) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_AUX1],1)):
		{
			ON[dvProj,VD_SRC_AUX1]
			ON[vdvTP,VD_SRC_AUX1]
			IF(ncmd = VD_SRC_AUX1) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_AUX2],1)):
		{
			ON[dvProj,VD_SRC_AUX2]
			ON[vdvTP,VD_SRC_AUX2]
			IF(nCmd = VD_SRC_AUX2) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_AUX3],1)):
		{
			ON[dvProj,VD_SRC_AUX3]
			ON[vdvTP,VD_SRC_AUX3]
			IF(nCmd = VD_SRC_AUX3) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VID1],1)):
		{
			ON[dvProj,VD_SRC_VID1]
			ON[vdvTP,VD_SRC_VID1]
			IF(nCmd = VD_SRC_VID1) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VID1],1)):
		{
			ON[dvProj,VD_SRC_SVID]
			ON[vdvTP,VD_SRC_SVID]
			IF(nCmd = VD_SRC_SVID) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,"$A9,$01,$13,$02",1)):
		{
			nLamp=(cCompStr[5] * 256) + cCompStr[6];
			send_command vdvTP,"'^TXT-1,0,Lamp Hours: ',itoa(nLamp)"
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "$17,$2E,$00,$00,$00"	//on
cCmdStr[VD_PWR_OFF]			= "$17,$2F,$00,$00,$00"	//off
cCmdStr[VD_SRC_VID1] 		= "$00,$01,$00,$00,$00"		//video
cCmdStr[VD_SRC_SVID]		= "$00,$01,$00,$00,$01"		//svideo
cCmdStr[VD_SRC_AUX1]		= "$00,$01,$00,$00,$02"		//input A
cCmdStr[VD_SRC_AUX2]		= "$00,$01,$00,$00,$03"		//input B
cCmdStr[VD_SRC_AUX3]		= "$00,$01,$00,$00,$04"		//input C
cCmdStr[VD_SRC_HDMI1]		= "$00,$01,$00,$00,$05"		//input D

for(x=1;x<=max_length_array(cCmdStr);x++) cCmdStr[x]=build_string(cCmdStr[x])



cPollStr[PollPower]		= "$01,$02,$01,$00,$00"	//pwr
cPollStr[PollInput] 	= "$00,$01,$01,$00,$00"	//input
cPollStr[PollLamp]		= "$01,$13,$01,$00,$00" //lamp hours

for(x=1;x<=max_length_array(cPollStr);x++) cPollStr[x]=build_string(cPollStr[x])

cRespStr[VD_PWR_ON] 		= "$01,$02,$02,$00,$03"
cRespStr[VD_PWR_OFF]		= "$01,$02,$02,$00,$00"
cRespStr[VD_SRC_VID1] 		= "$00,$01,$02,$00,$00"
cRespStr[VD_SRC_SVID]		= "$00,$01,$02,$00,$01"
cRespStr[VD_SRC_AUX1]		= "$00,$01,$02,$00,$02"
cRespStr[VD_SRC_AUX2]		= "$00,$01,$02,$00,$03"
cRespStr[VD_SRC_AUX3]		= "$00,$01,$02,$00,$04"
cRespStr[VD_SRC_HDMI1]		= "$00,$01,$02,$00,$05"

for(x=1;x<=max_length_array(cRespStr);x++) cRespStr[x]=build_string(cRespStr[x])


WAIT 200
{
	IF(!TIMELINE_ACTIVE(lTLPoll))
	{
		TIMELINE_CREATE(lTLPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
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
	SEND_STRING dvProj,"cPollStr[TIMELINE.SEQUENCE]"
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
					SEND_STRING dvProj,cCmdStr[nCmd]
					nPollType = PollPower
				}
				CASE VD_SRC_HDMI1:
				CASE VD_SRC_AUX1:
				CASE VD_SRC_AUX2:
				CASE VD_SRC_AUX3:
				CASE VD_SRC_VID1:
				CASE VD_SRC_SVID:
				{
					IF([dvProj,VD_PWR_ON])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollInput
					}
					else IF([dvProj,VD_PWR_OFF] || [dvProj, VD_COOLING])
					{
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						nPollType = PollPower
					}
					else
					{
						nPollType=PollPower
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

//CHANNEL_EVENT[vdvProj,0]
//{
//	ON:
//	{
//		IF(channel.channel<200)
//		{
//			nCmd = channel.channel
//			StartCommand()
//		}
//	}
//}

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
				TIMELINE_CREATE(lTLPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}

BUTTON_EVENT[vdvTP,0]
{
	PUSH:
	{
		to[button.input]
		nCmd = button.input.channel
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


