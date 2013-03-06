MODULE_NAME='Mitsubishi WL6700U Rev5-00'(dev dvTP, dev vdvProj, dev dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/06/2008  AT: 11:25:47        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY: Added relay control -BW                    *)
(***********************************************************)
//send_command data.device,"'SET BAUD 9600,N,8,1 485 DISABLE'"
//define_module 'Mitsubishi WL6700U Rev5-00' proj1(vdvTP_DISP1,vdvDISP1,dvProj)
#include 'HoppSNAPI Rev5-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002

PollPwr 	= 1
PollSrc		= 2
PollStatus	= 3
PollMute 	= 4
PollLamp	= 5
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {2500,2500,2500,2500,2500}
LONG lCmdArray[]				=	{900,900}

INTEGER nPollType = 0

CHAR cCmdStr[35][20]	
CHAR cPollStr[5][20]

persistent integer nVolume
persistent integer nMute

INTEGER nCmd=0

integer nLamp

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvTP,VD_MUTE_ON],[dvTP,VD_MUTE_OFF])
([dvTP,VD_SRC_RGB1],[dvTP,VD_SRC_RGB2],[dvTP,VD_SRC_RGB3],[dvTP,VD_SRC_DVI1],[dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID])

([dvProj,VD_PWR_ON],[dvProj,VD_PWR_OFF],[dvProj,VD_WARMING],[dvProj,VD_COOLING])
([dvProj,VD_MUTE_ON],[dvProj,VD_MUTE_OFF])
([dvProj,VD_SRC_RGB1],[dvProj,VD_SRC_RGB2],[dvProj,VD_SRC_RGB3],[dvProj,VD_SRC_DVI1],[dvProj,VD_SRC_VID1],[dvProj,VD_SRC_SVID])

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
	SELECT
	{
		//Power
		ACTIVE(FIND_STRING(cCompStr,"'vP1'",1) or find_string(cCOmpStr,"'vST2'",1)):
		{
			ON[dvProj,VD_PWR_ON]
			ON[dvTP,VD_PWR_ON]
			IF(nCmd=VD_PWR_ON) 
			{
				CmdExecuted()
				wait 30 pulse[vdvProj,VD_PCADJ]
			}
		}
		ACTIVE(FIND_STRING(cCompStr,"'vP0'",1) or find_string(cCOmpStr,"'vST0'",1)):
		{
			ON[dvProj,VD_PWR_OFF]
			ON[dvTP,VD_PWR_OFF]
			ON[dvProj,VD_VOL_MUTE_OFF]
			OFF[dvTP,VD_VOL_MUTE_TOG]
			off[nMute]			
			IF(nCmd=VD_PWR_OFF) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,"'vST1'",1)):
		{
			ON[dvProj,VD_WARMING]
			ON[dvTP,VD_PWR_ON]
			IF(nCmd=VD_PWR_ON) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,"'vST3'",1)):
		{
			ON[dvProj,VD_COOLING]
			ON[dvTP,VD_PWR_OFF]
			IF(nCmd=VD_PWR_OFF) CmdExecuted()
		}
		//Inputs
		ACTIVE(FIND_STRING(cCompStr,"'vIr1'",1)):
		{
			ON[dvProj,VD_SRC_RGB1]
			ON[dvTP,VD_SRC_RGB1]
			IF(nCmd=VD_SRC_RGB1) 
			{
				CmdExecuted()					
				wait 30 pulse[vdvProj,VD_PCADJ]
			}
		}
		ACTIVE(FIND_STRING(cCompStr,"'vIr2'",1)):
		{
			ON[dvProj,VD_SRC_RGB2]
			ON[dvTP,VD_SRC_RGB2]
			IF(nCmd=VD_SRC_RGB2) 
			{
				CmdExecuted()					
				wait 30 pulse[vdvProj,VD_PCADJ]
			}
		}
		ACTIVE(FIND_STRING(cCompStr,"'vIr3'",1)):
		{
			ON[dvProj,VD_SRC_RGB3]
			ON[dvTP,VD_SRC_RGB3]
			IF(nCmd=VD_SRC_RGB3) 
			{
				CmdExecuted()					
				wait 30 pulse[vdvProj,VD_PCADJ]
			}
		}
		ACTIVE(FIND_STRING(cCompStr,"'vId1'",1)):
		{
			ON[dvProj,VD_SRC_DVI1]
			ON[dvTP,VD_SRC_DVI1]
			IF(nCmd=VD_SRC_DVI1)
			{
				CmdExecuted()					
				wait 30 pulse[vdvProj,VD_PCADJ]
			}
		}
		ACTIVE(FIND_STRING(cCompStr,"'vIv1'",1)):
		{
			ON[dvProj,VD_SRC_VID1]
			ON[dvTP,VD_SRC_VID1]
			IF(nCmd=VD_SRC_VID1) CmdExecuted()					
		}
		ACTIVE(FIND_STRING(cCompStr,"'vIv2'",1)):
		{
			ON[dvProj,VD_SRC_SVID]
			ON[dvTP,VD_SRC_SVID]
			IF(nCmd=VD_SRC_SVID) CmdExecuted()					
		}
		ACTIVE(FIND_STRING(cCompStr,"'00MUTE1'",1)):
		{
			ON[dvProj,VD_MUTE_ON]
			ON[dvTP,VD_MUTE_ON]
			on[dvTP,VD_MUTE_TOG]
			IF(nCmd = VD_MUTE_ON) CmdExecuted()
		}
		ACTIVE(FIND_STRING(cCompStr,"'00MUTE0'",1)):
		{
			ON[dvProj,VD_MUTE_OFF]
			ON[dvTP,VD_MUTE_OFF]
			off[dvTP,VD_MUTE_TOG]
			IF(nCmd = VD_MUTE_OFF) CmdExecuted()
		}		
		ACTIVE(FIND_STRING(cCompStr,"'00vLE'",1)):
		{
			remove_string(cCompStr,"'00vLE'",1)
			nLamp = ATOI("LEFT_STRING(cCompStr,4)")	
			SEND_COMMAND dvTP,"'^TXT-1,0,Lamp Hours: ',ITOA(nLamp)"
		}		
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		= "'00!',$0D" 			
cCmdStr[VD_PWR_OFF]		= "'00"',$0D"
cCmdStr[VD_SRC_RGB1]	= "'00_r1',$0D"	//rgb
cCmdStr[VD_SRC_RGB2]	= "'00_r2',$0D"	//rgb2
cCmdStr[VD_SRC_RGB3]	= "'00_r3',$0D" //rgb3
cCmdStr[VD_SRC_DVI1]	= "'00_d1',$0D"	//dvi
cCmdStr[VD_SRC_VID1]	= "'00_v1',$0D"	//vid
cCmdStr[VD_SRC_SVID]	= "'00_v2',$0D"	//svid
cCmdStr[VD_PCADJ]		= "'00r09',$0D,'00r10',$0D"
cCmdStr[VD_MUTE_ON]		= "'00MUTE1',$0D"
cCmdStr[VD_MUTE_OFF]	= "'00MUTE0',$0D"

cPollStr[PollPwr] 	= "'00vP',$0D"
cPollStr[PollSrc] 	= "'00vI',$0D"
cPollStr[PollStatus]= "'00vST',$0D"
cPollStr[PollMute]	= "'00MUTE',$0D"
cPollStr[PollLamp]	= "'00vLE',$0D"

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
					nPollType=PollStatus
				}
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:
				CASE VD_SRC_RGB3:
				CASE VD_SRC_VID1:
				CASE VD_SRC_SVID:
				{
					IF([dvProj,VD_PWR_ON])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType=PollSrc
					}
					ELSE
					{
						SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
						nPollType=PollStatus
					}
				}
				CASE VD_ASPECT1:
				CASE VD_ASPECT2:
				CASE VD_PCADJ:
				{
					IF([dvProj,VD_PWR_ON]) 
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
					}
					CmdExecuted()
				}
				CASE VD_MUTE_OFF:
				CASE VD_MUTE_ON:	
				{
					IF([dvProj,VD_PWR_ON])
					{
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollMute
					}
					ELSE CmdExecuted()
				}
				CASE VD_MUTE_TOG:
				{
					IF([dvProj,VD_PWR_ON])
					{
						IF([dvProj,VD_MUTE_ON]) nCmd=VD_MUTE_OFF
						ELSE nCmd = VD_MUTE_ON
						SEND_STRING dvProj,cCmdStr[nCmd]
						nPollType = PollMute
					}	
					ELSE CmdExecuted()
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
		IF(channel.channel<200)
		{
			nCmd=channel.channel
			TIMELINE_PAUSE(lTLPoll)
			WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,length_array(lCmdArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
		}
		ELSE IF(channel.channel=VD_POLL_BEGIN)
		{
			TIMELINE_CREATE(lTLPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
		}
	}
}
BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		SWITCH(button.input.channel)
		{
			case VD_VOL_UP:
			{
				to[button.input]
				if(nVolume<21)nVolume++
				if(nVolume>=10) send_string dvProj,"'00VL',itoa(nVolume),$0D"
				else send_string dvProj,"'00VL0',itoa(nVolume),'',$0D"
				send_level dvTP,1,nVolume
			}
			case VD_VOL_DOWN:
			{
				to[button.input]
				if(nVolume>0) nVolume--
				if(nVolume>=10) send_string dvProj,"'00VL',itoa(nVolume),$0D"
				else send_string dvProj,"'00VL0',itoa(nVolume),'',$0D"
				send_level dvTP,1,nVolume
			}
			CASE VD_ASPECT1:
			CASE VD_ASPECT2:
			CASE VD_PCADJ:
			{
				TO[button.input]
				PULSE[vdvProj,button.input.channel]
			}
			default: pulse[vdvProj,button.input.channel]
		}	
	}
	hold[3,repeat]:
	{
		send_string 0,"'Hold Repeated, ',itoa(button.input.channel)"
		switch(button.input.channel)
		{
			case VD_VOL_UP:
			{
				if(nVolume<21)nVolume++
				if(nVolume>=10) send_string dvProj,"'00VL',itoa(nVolume),$0D"
				else send_string dvProj,"'00VL0',itoa(nVolume),'',$0D"
				send_level dvTP,1,nVolume
			}
			case VD_VOL_DOWN:
			{
				if(nVolume>0) nVolume--
				if(nVolume>=10) send_string dvProj,"'00VL',itoa(nVolume),$0D"
				else send_string dvProj,"'00VL0',itoa(nVolume),'',$0D"
				send_level dvTP,1,nVolume
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

