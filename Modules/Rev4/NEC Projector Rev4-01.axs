MODULE_NAME='NEC Projector Rev4-01'(DEV vdvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  
	 Written by: 		Jeff McAleer
	 Date: 			 		3/23/09
*)
(***********************************************************)
(*   
	Set baud to 38400,N,8,1,485 DISABLE
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

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]	= {3100}
LONG lCmdArray[]  =	{510,510}

INTEGER nPollType

CHAR cResp[100]
CHAR cCmdStr[40][20]	
CHAR cPollStr[20]
CHAR cRespStr[51][20]

INTEGER nPwrVerify = 0
integer nPrevPower
integer	nWarmup

nCooling
nWarming
nPowerOn
nPowerOff

x

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
([vdvTP,VD_SRC_RGB1],[vdvTP,VD_SRC_VGA1],[vdvTP,VD_SRC_DVI1],[vdvTP,VD_SRC_VID1],[vdvTP,VD_SRC_SVID],[vdvTP,VD_SRC_CMPNT1])

([vdvProj,VD_PWR_ON_FB],[vdvProj,VD_WARMING_FB],[vdvProj,VD_COOLING_FB],[vdvProj,VD_PWR_OFF_FB])
([vdvProj,VD_MUTE_ON_FB],[vdvProj,VD_MUTE_OFF_FB])
([vdvProj,VD_SRC_RGB1_FB],[vdvProj,VD_SRC_VGA1_FB],[vdvProj,VD_SRC_DVI1_FB],[vdvProj,VD_SRC_VID1_FB],[vdvProj,VD_SRC_SVID_FB],[vdvTP,VD_SRC_CMPNT1_FB])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function integer calcchecksum(char cMsg[])
{
	stack_var integer nLoop
	stack_var integer nCheckSum
	
	off[nCheckSum]
	for (nLoop=1;nLoop<=length_string(cMsg);nLoop++)
	{
		nCheckSum=((nCheckSum+cMsg[nLoop])& $FF)
	}
	return nCheckSum
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
	SELECT
	{
//		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1) or find_string(cCompStr,"$20,$81,$01,$10,$01,$4A,$FD",1)):
//		{			
//			ON[vdvTP,VD_PWR_ON]
//			ON[vdvProj,VD_PWR_ON_FB]
//			IF(nCmd = VD_PWR_ON) CmdExecuted()
//		}
//		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1)):
//		{	
//			ON[vdvProj,VD_PWR_OFF_FB]
//			ON[vdvTP,VD_PWR_OFF]
//			IF(nCmd = VD_PWR_OFF) CmdExecuted()
//		}
//		ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_WARMING],1) or FIND_STRING(cCompStr,cRespStr[VD_COOLING],1) or find_string (cCompStr,"$20,$81,$01,$10,$01,$0A,$BD",1)):
//		{
//			switch(nCmd)
//			{
//				CASE VD_SRC_VID1:
//				CASE VD_SRC_SVID:
//				CASE VD_SRC_RGB1:
//				CASE VD_SRC_DVI1:
//				CASE VD_SRC_VGA1:
//				CASE VD_SRC_CMPNT1:
//				case VD_PWR_ON:
//				{
//					ON[vdvProj,VD_WARMING_FB]
//					ON[vdvTP,VD_PWR_ON]
//					IF(nCmd = VD_PWR_OFF) CmdExecuted()
//				}
//				case VD_PWR_OFF:
//				{
//					ON[vdvProj,VD_COOLING_FB]
//					ON[vdvTP,VD_PWR_OFF]
//					CmdExecuted()
//				}
//			}
//		}
//		active(find_string(cCompStr,"$22,$03,$01,$10,$01,$00,$37",1)):
//		{
//			switch(nCmd)
//			{
//				CASE VD_SRC_VID1:
//				CASE VD_SRC_SVID:
//				CASE VD_SRC_RGB1:
//				CASE VD_SRC_DVI1:
//				CASE VD_SRC_VGA1:
//				CASE VD_SRC_CMPNT1:	CmdExecuted()
//			}
//		}
		active(find_string(cCompStr,cRespStr[VD_WARMING],1)):
		{
			if(nPrevPower=VD_PWR_OFF and (nCmd=VD_PWR_ON or nCmd=VD_SRC_RGB1 or nCmd=VD_SRC_VGA1 or nCmd=VD_SRC_CMPNT1 or nCmd=VD_SRC_DVI1 or nCmd=VD_SRC_SVID or nCmd=VD_SRC_VID1))
			{
				ON[vdvProj,VD_WARMING_FB]
                ON[vdvTP,VD_PWR_ON]
				IF(nCmd = VD_PWR_ON) CmdExecuted()
				off[nPwrVerify]
				nPrevPower=VD_WARMING
			}
		}
		ACTIVE(FIND_STRING(cCompStr,"$20,$C0,$01,$10,$80",1)):
		{
			remove_string(cCompStr,"$20,$C0,$01,$10,$80",1)
			send_string 0,"'Common Data Request Returned'"
			select
			{
				active(mid_string(cCompStr,4,2)="$00,$00"):
				{
					if(nPrevPower=VD_WARMING){}
					else
					{
						ON[vdvProj,VD_PWR_OFF_FB]
						ON[vdvTP,VD_PWR_OFF]
						IF(nCmd = VD_PWR_OFF) CmdExecuted()
						nPrevPower=VD_PWR_OFF
					}
				}
				active(mid_string(cCompStr,4,2)="$01,$00"):
				{
					ON[vdvTP,VD_PWR_ON]
					ON[vdvProj,VD_PWR_ON_FB]
					IF(nCmd = VD_PWR_ON) CmdExecuted()
					nPrevPower=VD_PWR_ON
				}
				active(mid_string(cCompStr,4,2)="$00,$01"):
				{
					if (nPrevPower=VD_PWR_ON)
					{
						ON[vdvProj,VD_COOLING_FB]
						ON[vdvTP,VD_PWR_OFF]
						if(nCmd=VD_PWR_OFF) CmdExecuted()
						nPrevPower=VD_COOLING
					}
//					if (nPrevPower=VD_PWR_OFF)
//					{
//						ON[vdvProj,VD_WARMING_FB]
//                      ON[vdvTP,VD_PWR_ON]
//					    IF(nCmd = VD_PWR_ON) CmdExecuted()
//						nPrevPower=VD_WARMING
//					}   
				}
			}
			select
			{
				active(mid_string(cCompStr,7,2)=cRespStr[VD_SRC_VGA1]):
				{
					send_string 0,"'VGA1'"
					ON[vdvProj,VD_SRC_VGA1_FB]
					ON[vdvTP,VD_SRC_VGA1]
					if (nCmd=VD_SRC_VGA1) CmdExecuted()
				}   
				active(mid_string(cCompStr,7,2)=cRespStr[VD_SRC_VID1]):
				{
					send_string 0,"'VID1'"
					ON[vdvProj,VD_SRC_VID1_FB]
					ON[vdvTP,VD_SRC_VID1]
					if (nCmd=VD_SRC_VID1) CmdExecuted()
				}  
				active(mid_string(cCompStr,7,2)=cRespStr[VD_SRC_RGB1]):
				{
					ON[vdvProj,VD_SRC_RGB1_FB]
					ON[vdvTP,VD_SRC_RGB1]
					if (nCmd=VD_SRC_RGB1) CmdExecuted()
				}
				active(mid_string(cCompStr,7,2)=cRespStr[VD_SRC_DVI1]):
				{
					ON[vdvProj,VD_SRC_DVI1_FB]
					ON[vdvTP,VD_SRC_DVI1]
					if (nCmd=VD_SRC_DVI1) CmdExecuted()
				}
				active(mid_string(cCompStr,7,2)=cRespStr[VD_SRC_SVID]):
				{
					ON[vdvProj,VD_SRC_SVID_FB]
					ON[vdvTP,VD_SRC_SVID]
					if (nCmd=VD_SRC_SVID) CmdExecuted()
				}
				active(mid_string(cCompStr,7,2)=cRespStr[VD_SRC_CMPNT1]):
				{
					send_string 0,"'CMPNT 1'"
					ON[vdvProj,VD_SRC_CMPNT1_FB]
					ON[vdvTP,VD_SRC_CMPNT1]
					if (nCmd=VD_SRC_CMPNT1) CmdExecuted()
				}
			}
			select
			{
				active(mid_string(cCompStr,29,1)=cRespStr[VD_MUTE_ON]):
				{
					send_string 0,"'Mute On'"
					on[vdvProj,VD_MUTE_ON_FB]
					on[vdvTP,VD_MUTE_ON]
					if(nCmd=VD_MUTE_ON) CmdExecuted()
					[vdvTP,VD_MUTE_TOG] = ([vdvTP,VD_MUTE_ON])
				}
				active(mid_string(cCompStr,29,1)=cRespStr[VD_MUTE_OFF]):
				{
					send_string 0,"'Mute Off'"
					on[vdvProj,VD_MUTE_OFF_FB]
					on[vdvTP,VD_MUTE_OFF]
					if(nCmd=VD_MUTE_OFF) CmdExecuted()
					[vdvTP,VD_MUTE_TOG] = ([vdvTP,VD_MUTE_ON])
				}
			}
		}
	}
}




//		CASE PollMute:
//		{
//			SELECT
//			{
//				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_MUTE_ON],1)):
//				{
//					ON[vdvProj,VD_MUTE_ON_FB]
//					ON[vdvTP,VD_MUTE_ON]
//					IF(nCmd = VD_MUTE_ON) CmdExecuted()
//				}
//				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_MUTE_OFF],1)):
//				{
//					ON[vdvProj,VD_MUTE_OFF_FB]
//					ON[vdvTP,VD_MUTE_OFF]
//					IF(nCmd = VD_MUTE_OFF) CmdExecuted()
//				}
//			}
//			[vdvTP,VD_MUTE_TOG] = ([vdvTP,VD_MUTE_ON])
//		}
//		CASE PollLamp:	//Lamp Hours
//		{
//			nLamp = ATOI("LEFT_STRING(cCompStr,5)")	
//			SEND_COMMAND vdvTP,"'@TXT,1,',ITOA(nLamp)"
//		}
//	}	
//}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "$02,$00,$00,$00,$00,$02"
cCmdStr[VD_PWR_OFF]			= "$02,$01,$00,$00,$00,$03"
cCmdStr[VD_SRC_DVI1]		= "$02,$03,$00,$00,$02,$01,$1A"
cCmdStr[VD_SRC_VGA1]  		= "$02,$03,$00,$00,$02,$01,$01"
cCmdStr[VD_SRC_RGB1]  		= "$02,$03,$00,$00,$02,$01,$02"
cCmdStr[VD_SRC_VID1] 		= "$02,$03,$00,$00,$02,$01,$06"
cCmdStr[VD_SRC_SVID]		= "$02,$03,$00,$00,$02,$01,$0B"
cCmdStr[VD_SRC_CMPNT1]		= "$02,$03,$00,$00,$02,$01,$10"
cCmdStr[VD_MUTE_ON]			= "$02,$10,$00,$00,$00,$12"
cCmdStr[VD_MUTE_OFF]		= "$02,$11,$00,$00,$00,$13"
cCmdStr[VD_PCADJ]			= "$03,$BA,$00,$00,$01,$00,$BE"


cPollStr				 	= "$00,$C0,$00,$00,$00,$C0"


cRespStr[VD_PWR_ON] 		= "$20,$81,$01,$10,$01,$02,$B5"
cRespStr[VD_PWR_OFF] 		= "$20,$81,$01,$10,$01,$00,$B3"
cRespStr[VD_COOLING]		= "$20,$81,$01,$10,$01,$A0,$53"
cRespStr[VD_WARMING] 		= "$22,$00,$01,$10,$00,$33"
cRespStr[VD_MUTE_OFF]		= "$00"
cRespStr[VD_MUTE_ON]		= "$01"
cRespStr[VD_SRC_VGA1]		= "$01,$01"
cRespStr[VD_SRC_VID1]		= "$01,$02"
cRespStr[VD_SRC_RGB1]		= "$02,$01"
cRespStr[VD_SRC_DVI1]		= "$01,$06"
cRespStr[VD_SRC_SVID]		= "$01,$03"
cRespStr[VD_SRC_CMPNT1]		= "$03,$04"


WAIT 200
{
	IF(!TIMELINE_ACTIVE(lTLPoll))
	{
		TIMELINE_CREATE(lTLPoll,lPollArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
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
		parse(data.text)
//		LOCAL_VAR CHAR cHold[100]
//		LOCAL_VAR CHAR cFullStr[100]
//		LOCAL_VAR CHAR cBuff[255]
//		STACK_VAR INTEGER nPos	
//		
//		cBuff = "cBuff,data.text"
//		WHILE(LENGTH_STRING(cBuff))
//		{
//			for(x=1;x<=length_string(cBuff);x++)
//			{
//				if(x>1 and calcchecksum(left_string(cBuff,x-1))=mid_string(cBuff,x,1))
//				{
//					if(left_string(cBuff,2)="$20,$C0" and x<10){}
//					else
//					{
//						cFullStr=left_string(cBuff,x)
//						parse(cFullStr)
//						remove_string(cBuff,cFullStr,1)
//					}
//				}
//				if(x=length_string(cBuff)) cBuff=''
//			}
//		}
	}
}
//	
//			SELECT
//			{
//				ACTIVE(FIND_STRING(cBuff,"$0D",1)&& LENGTH_STRING(cHold)):
//				{
//					nPos=FIND_STRING(cBuff,"$0D",1)
//					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
//					Parse(cFullStr)
//					cHold=''
//				}
//				ACTIVE(FIND_STRING(cBuff,"$0D",1)):
//				{
//					nPos=FIND_STRING(cBuff,"$0D",1)
//					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
//					Parse(cFullStr)
//				}
//				ACTIVE(1):
//				{
//					cHold="cHold,cBuff"
//					cBuff=''
//				}
//			}
//		}	
//	}
//}

TIMELINE_EVENT[lTLPoll]				//Projector Polling
{
	SEND_STRING dvProj,"cPollStr"
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
				}
				CASE VD_SRC_VID1:
				CASE VD_SRC_SVID:
				CASE VD_SRC_RGB1:
				CASE VD_SRC_DVI1:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_CMPNT1:
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						IF(!nPwrVerify)
						{
							SEND_STRING dvProj,"cCmdStr[nCmd],calcchecksum(cCmdStr[nCmd])"
						}
					}
					IF([vdvProj,VD_WARMING_FB])
					{
						nPwrVerify = 0
						SEND_STRING dvProj,"cCmdStr[nCmd],calcchecksum(cCmdStr[nCmd])"
					}
					IF([vdvProj,VD_PWR_OFF_FB] || [vdvProj, VD_COOLING_FB])
					{
						nPwrVerify = 1
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
					}
					
				}
				CASE VD_MUTE_OFF:
				CASE VD_MUTE_ON:	
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
					}
					ELSE CmdExecuted()
				}
				CASE VD_MUTE_TOG:
				{
					IF([vdvProj,VD_PWR_ON_FB])
					{
						IF([vdvProj,VD_MUTE_ON_FB]) nCmd=VD_MUTE_OFF
						ELSE nCmd = VD_MUTE_ON
						SEND_STRING dvProj,cCmdStr[nCmd]
					}	
					ELSE CmdExecuted()
				}
				CASE VD_PCADJ:
				{
					IF([vdvProj,VD_PWR_ON_FB]) SEND_STRING dvproj,cCmdStr[ncmd]
					CmdExecuted()
				}
			}
		}
		CASE 2:	//2nd time
		{
			SEND_STRING dvProj,cPollStr
		}
	}
}

channel_event[vdvProj,0]
{
	on:
	{
		select
		{
			active(channel.channel<VD_POLL_BEGIN):
			{
				nCmd=channel.channel
				StartCommand()
			}
			active(channel.channel=VD_POLL_BEGIN):
			{
				timeline_create(lTLPoll,lPollArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}

button_event[vdvTP,btn_PROJ]
{
	push:
	{
		to[button.input]
		nCmd = get_last(btn_PROJ)
		StartCommand()
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program

nPowerOn=[vdvProj,VD_PWR_ON_FB]
nPowerOff=[vdvProj,VD_PWR_OFF_FB]
nWarming=[vdvProj,VD_WARMING_FB]
nCooling=[vdvProj,VD_COOLING_FB]

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


