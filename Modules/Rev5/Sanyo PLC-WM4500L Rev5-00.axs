MODULE_NAME='Sanyo PLC-WM4500L Rev5-00'(DEV vdvTP, DEV vdvProj, DEV dvProj)
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
	Set baud to 19200,N,8,1,485 DISABLE
	define_module 'Sanyo PLC-WM4500L Rev5-00' proj1(vdvTP_DISP1,vdvDISP1,dvProj)
*)

#INCLUDE 'HoppSNAPI Rev5-04.axi'

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
INTEGER PollLamp	= 3

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]	= {3100,3100,3100}
LONG lCmdArray[]  =	{1100,1100}

INTEGER nPollType

CHAR cResp[100]
CHAR cCmdStr[58][20]	
CHAR cPollStr[3][20]
CHAR cRespStr[51][20]

INTEGER nPwrVerify = 0

persistent	integer		nVolMute

INTEGER nCmd = 0

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
([vdvTP,VD_VOL_MUTE_ON],[vdvTP,VD_VOL_MUTE_OFF])
([vdvTP,VD_SRC_RGB1],[vdvTP,VD_SRC_RGB2],[vdvTP,VD_SRC_RGB3],[vdvTP,VD_SRC_VID1],[vdvTP,VD_SRC_SVID],[vdvTP,VD_SRC_CMPNT1],[vdvTP,VD_SRC_DVI3])

([dvProj,VD_PWR_ON],[dvProj,VD_WARMING],[dvProj,VD_COOLING],[dvProj,VD_PWR_OFF])
([dvProj,VD_MUTE_ON],[dvProj,VD_MUTE_OFF])
([dvProj,VD_VOL_MUTE_ON],[dvProj,VD_VOL_MUTE_OFF])
([dvProj,VD_SRC_RGB1],[dvProj,VD_SRC_RGB2],[dvProj,VD_SRC_RGB3],[dvProj,VD_SRC_VID1],[dvProj,VD_SRC_SVID],[dvProj,VD_SRC_CMPNT1],[dvProj,VD_SRC_DVI3])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

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
	
	SWITCH(nPollType)
	{
		CASE PollPower:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
				{			
					ON[vdvTP,VD_PWR_ON]
					ON[dvProj,VD_PWR_ON]
					IF(nCmd = VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1)):
				{	
					ON[dvProj,VD_PWR_OFF]
					ON[vdvTP,VD_PWR_OFF]
					IF(nCmd = VD_PWR_OFF) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_WARMING],1)): 	//Warming Up
				{
					ON[dvProj,VD_WARMING]
					ON[vdvTP,VD_PWR_ON]
					IF(ncmd = VD_PWR_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_COOLING],1)):	//Cooling Down
				{
					ON[dvProj,VD_COOLING]
					ON[vdvTP,VD_PWR_OFF]
					IF(ncmd = VD_PWR_OFF) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cResp,"'04',$0D",1) || FIND_STRING(cResp,"'10',$0D",1) || 
							 FIND_STRING(cResp,"'28',$0D",1) || FIND_STRING(cResp,"'21',$0D",1) ||
							 FIND_STRING(cResp,"'88',$0D",1) || FIND_STRING(cResp,"'24',$0D",1) ||
							 FIND_STRING(cResp,"'81',$0D",1) || FIND_STRING(cResp,"'2C',$0D",1) || 
							 FIND_STRING(cResp,"'8C',$0D",1)):		//Error Message
				{
					ON[dvProj,VD_ERROR]
				}			
			}	
		}
		CASE PollInput:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,"'1',$0D",1)):
				{
					IF(nCmd = VD_SRC_VGA1)
					{
						ON[dvProj,VD_SRC_VGA1]
						ON[vdvTP,VD_SRC_VGA1]
						CmdExecuted()
					}
					IF(nCmd = VD_SRC_VGA2)
					{
						ON[dvProj,VD_SRC_VGA2]
						ON[vdvTP,VD_SRC_VGA2]
						CmdExecuted()
					}
					IF(nCmd = VD_SRC_DVI1)
					{
						ON[dvProj,VD_SRC_DVI1]
						ON[vdvTP,VD_SRC_DVI1]
						CmdExecuted()
					}		
					IF(nCmd = VD_SRC_DVI2)
					{
						ON[dvProj,VD_SRC_DVI2]
						ON[vdvTP,VD_SRC_DVI2]
						CmdExecuted()
					}				
					IF(nCmd = VD_SRC_DVI3)
					{
						ON[dvProj,VD_SRC_DVI3]
						ON[vdvTP,VD_SRC_DVI3]
						CmdExecuted()
					}							
				}
				ACTIVE(FIND_STRING(cCompStr,"'2',$0D",1)):
				{
					IF(nCmd = VD_SRC_RGB1)
					{
						ON[dvProj,VD_SRC_RGB1]
						ON[vdvTP,VD_SRC_RGB1]
						CmdExecuted()
						pulse[vdvProj,VD_PCADJ]
					}
					IF(nCmd = VD_SRC_CMPNT1)
					{
						ON[dvProj,VD_SRC_CMPNT1]
						ON[vdvTP,VD_SRC_CMPNT1]
						CmdExecuted()
					}		
					IF(nCmd = VD_SRC_VID1)
					{
						ON[dvProj,VD_SRC_VID1]
						ON[vdvTP,VD_SRC_VID1]
						CmdExecuted()
					}
				}
				ACTIVE(FIND_STRING(cCompStr,"'3',$0D",1)):
				{
					IF(nCmd = VD_SRC_VID2)
					{
						ON[dvProj,VD_SRC_VID2]
						ON[vdvTP,VD_SRC_VID2]
						CmdExecuted()
					}
					IF(nCmd = VD_SRC_SVID)
					{
						ON[dvProj,VD_SRC_SVID]
						ON[vdvTP,VD_SRC_SVID]
						CmdExecuted()
					}		
				}				
			}	
		}
		CASE PollLamp:	//Lamp Hours
		{
			nLamp = ATOI("LEFT_STRING(cCompStr,5)")	
			SEND_COMMAND vdvTP,"'@TXT,1,',ITOA(nLamp)"
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]			= "'C00',$0D"	//on
cCmdStr[VD_PWR_OFF]			= "'C01',$0D"	//off
cCmdStr[VD_SRC_VGA1]		= "'C50',$0D"   //input1 VGA
cCmdStr[VD_SRC_VGA2]		= "'C51',$0D"	//input1 SCART
cCmdStr[VD_SRC_DVI1]		= "'C52',$0D"	//input1 DVI PC Digital
cCmdStr[VD_SRC_DVI2]		= "'C53',$0D"	//input1 DVI (AV HDCP)
cCmdStr[VD_SRC_DVI3]		= "'C4F',$0D"   //HDMI
cCmdStr[VD_SRC_RGB1]  		= "'C25',$0D"	//input2 RGBHV
cCmdStr[VD_SRC_CMPNT1]		= "'C24',$0D"	//input2 Y/Pb/Pr
cCmdStr[VD_SRC_VID1] 		= "'C23',$0D"	//input2 video
cCmdStr[VD_SRC_VID2] 		= "'C33',$0D"	//input3 video
cCmdStr[VD_SRC_SVID]		= "'C34',$0D"	//input3 svideo
cCmdStr[VD_MUTE_ON]			= "'C0D',$0D"	//mute on
cCmdStr[VD_MUTE_OFF]		= "'C0E',$0D"	//mute off
cCmdStr[VD_PCADJ]			= "'C89',$0D"	//pc adjust
cCmdStr[VD_ASPECT2] 		= "'C0F',$0D"	//4:3 aspect
cCmdStr[VD_ASPECT1] 		= "'C10',$0D"	//16:9 aspect
cCmdStr[VD_ZOOM_IN]			= "'C47',$0D"	//mute off
cCmdStr[VD_ZOOM_OUT]		= "'C46',$0D"	//pc adjus
cCmdStr[VD_LENS_UP]			= "'C4B',$0D"	//mute off
cCmdStr[VD_LENS_DN]			= "'C4A',$0D"	//pc adjust
cCmdStr[VD_VOL_UP]			= "'C09',$0D"	//volume up
cCmdStr[VD_VOL_DOWN]		= "'C0A',$0D"	//volume down
cCmdStr[VD_VOL_MUTE_ON]		= "'C0B',$0D"	//volume mute on
cCmdStr[VD_VOL_MUTE_OFF]	= "'C0C',$0D"	//volume mute off

cPollStr[PollPower]		= "$43,$52,$30,$0D"	//pwr
cPollStr[PollInput] 	= "$43,$52,$31,$0D"	//input
cPollStr[PollLamp] 		= "$43,$52,$33,$0D"	//lamp hours

cRespStr[VD_PWR_ON] 		= "'00',$0D"
cRespStr[VD_PWR_OFF]		= "'80',$0D"
cRespStr[VD_WARMING] 		= "'40',$0D"
cRespStr[VD_COOLING] 		= "'20',$0D"


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
				CASE VD_SRC_VID1:
				CASE VD_SRC_VID2:
				CASE VD_SRC_SVID:
				CASE VD_SRC_RGB1:
				CASE VD_SRC_DVI1:
				CASE VD_SRC_DVI2:
				CASE VD_SRC_DVI3:
				CASE VD_SRC_VGA1:
				CASE VD_SRC_VGA2:
				CASE VD_SRC_CMPNT1:
				{
					IF([dvProj,VD_PWR_ON])
					{
						IF(!nPwrVerify)
						{
							SEND_STRING dvProj,cCmdStr[nCmd]
							nPollType = PollInput
						}
					}
					else IF([dvProj,VD_WARMING])
					{
						nPwrVerify = 0
						nPollType=PollPower
					}
					else IF([dvProj,VD_PWR_OFF] || [dvProj, VD_COOLING])
					{
						nPwrVerify = 1
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						nPollType = PollPower
					}
					else
					{
						nPollType=PollPower
					}
				}
				CASE VD_MUTE_OFF:
				CASE VD_MUTE_ON:	
				{
					IF([dvProj,VD_PWR_ON])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
					}
					ELSE CmdExecuted()
				}				
				CASE VD_PCADJ:
				CASE VD_ASPECT1:
				CASE VD_ASPECT2:
				CASE VD_ZOOM_IN:
				CASE VD_ZOOM_OUT:
				CASE VD_LENS_UP:
				CASE VD_LENS_DN:
				CASE VD_VOL_UP:
				case VD_VOL_DOWN:
				{
					IF([dvProj,VD_PWR_ON]) SEND_STRING dvProj,cCmdStr[ncmd]
					CmdExecuted()
				}
				case VD_VOL_MUTE_TOG:
				{
					switch(nVolMute)
					{
						case 1: send_string dvProj,cCmdStr[VD_VOL_MUTE_OFF]
						case 0: send_string dvProj,cCmdStr[VD_VOL_MUTE_ON]
					}
					nVolMute=!nVolMute
					CmdExecuted()
					[vdvTP,VD_VOL_MUTE_TOG]=nVolMute
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
		STACK_VAR INTEGER nI
		to[button.input]
		nI = button.input.channel
		nCmd = button.input.channel
		StartCommand()
	}
	HOLD[3,REPEAT]:
	{
		STACK_VAR INTEGER nI
		nI = button.input.channel
		send_string 0,"'hold ',itoa(nI),' repeat'"
		IF(nI = VD_LENS_UP || nI = VD_LENS_DN || nI = VD_ZOOM_IN || nI = VD_ZOOM_OUT || nI=VD_VOL_UP || nI=VD_VOL_DOWN)   
		{
			nCmd = button.input.channel
			SEND_STRING dvProj,cCmdStr[ncmd]
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


