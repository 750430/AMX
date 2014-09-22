MODULE_NAME='NEC PX-50XM4A Rev5-00'(dev dvTP, dev vdvPlas, dev dvPlas)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/26/2008  AT: 15:39:29        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//SEND_COMMAND data.device,"'SET BAUD 9600,O,8,1 485 DISABLE'"
//define_module 'NEC PX-50XM4A Rev5-00' plas1(vdvTP_DISP1,vdvDISP1,dvPlasma)
#INCLUDE 'HoppSNAPI Rev5-01.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002

PollPwr 	= 1
PollSrc		= 2

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {5100,5100}
LONG lCmdArray[]				=	{510,510}

INTEGER nPollType = 0

CHAR cCmdStr[35][10]
CHAR cRespStr[35][10]	
CHAR cPollStr[2][10]

char cPlasmaBuffer[255]

INTEGER nCmd=0
INTEGER nPlasBtn[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
										21,22,23,24,25,26,27,28,29,30,31,32,33,34,35}

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([dvPlas,VD_PWR_ON],[dvPlas,VD_PWR_OFF])

([dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_RGB1],[dvTP,VD_SRC_RGB2],
[dvTP,VD_SRC_RGB3],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_AUX1],[dvTP,VD_SRC_AUX1],
[dvTP,VD_SRC_AUX1])
([dvPlas,VD_SRC_VID1],[dvPlas,VD_SRC_SVID],[dvPlas,VD_SRC_RGB1],[dvPlas,VD_SRC_RGB2],
[dvPlas,VD_SRC_RGB3],[dvPlas,VD_SRC_CMPNT1],[dvPlas,VD_SRC_AUX1],[dvPlas,VD_SRC_AUX1],
[dvPlas,VD_SRC_AUX1])
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
	STACK_VAR CHAR cVal[1]
	LOCAL_VAR INTEGER nTempVal

	SWITCH(nPollType)
	{
		CASE PollPwr:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
				{
					//3rd bit shows pwr status, 1=off,0=on
					cVal=MID_STRING(cCompStr,6,1)
					nTempVal=(cval[1] & $04)
					IF(nTempVal)
					{
						ON[dvPlas,VD_PWR_OFF]
						ON[dvTP,VD_PWR_OFF]
						off[dvTP,VD_PWR_TOG]
						IF(nCmd=VD_PWR_OFF) CmdExecuted()
					}
					ELSE
					{
						ON[dvPlas,VD_PWR_ON]
						ON[dvTP,VD_PWR_ON]
						ON[dvTP,VD_PWR_TOG]
						IF(nCmd=VD_PWR_ON) CmdExecuted()
					}
				}
			}
		}		
		CASE PollSrc:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VID1],1)):
				{
					ON[dvPlas,VD_SRC_VID1]
					ON[dvTP,VD_SRC_VID1]
					IF(nCmd=VD_SRC_VID1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_SVID],1)):
				{
					ON[dvPlas,VD_SRC_SVID]
					ON[dvTP,VD_SRC_SVID]
					IF(nCmd=VD_SRC_SVID) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_RGB1],1)):
				{
					ON[dvPlas,VD_SRC_RGB1]
					ON[dvTP,VD_SRC_RGB1]
					IF(nCmd=VD_SRC_RGB1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_RGB2],1)):
				{
					ON[dvPlas,VD_SRC_RGB2]
					ON[dvTP,VD_SRC_RGB2]
					IF(nCmd=VD_SRC_RGB2) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_RGB3],1) or find_string(cCompStr,"$7F,$60,$80,$41,$01,$0C",1)):
				{
					ON[dvPlas,VD_SRC_RGB3]
					ON[dvTP,VD_SRC_RGB3]
					IF(nCmd=VD_SRC_RGB3) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_CMPNT1],1)):
				{
					ON[dvPlas,VD_SRC_CMPNT1]
					ON[dvTP,VD_SRC_CMPNT1]
					IF(nCmd=VD_SRC_CMPNT1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_AUX1],1)):
				{
					ON[dvPlas,VD_SRC_AUX1]
					ON[dvTP,VD_SRC_AUX1]
					IF(nCmd=VD_SRC_AUX1) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_AUX2],1)):
				{
					ON[dvPlas,VD_SRC_AUX2]
					ON[dvTP,VD_SRC_AUX2]
					IF(nCmd=VD_SRC_AUX2) CmdExecuted()					
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_AUX3],1)):
				{
					ON[dvPlas,VD_SRC_AUX3]
					ON[dvTP,VD_SRC_AUX3]
					IF(nCmd=VD_SRC_AUX3) CmdExecuted()					
				}					
			}
		}
	}	
}
DEFINE_FUNCTION Send_Str(CHAR cStr[10])
{
	STACK_VAR INTEGER nCS
	STACK_VAR INTEGER nCount
	
	FOR(nCount=1;nCount<=MAX_LENGTH_ARRAY(cStr);nCount++)
	{
		nCS = nCS + cStr[nCount] //add up the values
	}
	nCS=nCS BAND $FF	//get rid of bits beyond 8
	SEND_STRING dvPlas,"cStr,nCS"
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		="$9F,$80,$60,$4E,$00"
cCmdStr[VD_PWR_OFF]		="$9F,$80,$60,$4F,$00"
cCmdStr[VD_SRC_VID1]		="$DF,$80,$60,$47,$01,$01"	//vid1	(composite)
cCmdStr[VD_SRC_SVID]	="$DF,$80,$60,$47,$01,$03"	//vid3 	(svideo)
cCmdStr[VD_SRC_RGB1]	="$DF,$80,$60,$47,$01,$07"	//rgb1 	(vga port)
cCmdStr[VD_SRC_RGB2]	="$DF,$80,$60,$47,$01,$08"	//rgb2 	(rgbhv shared w/hd2)
cCmdStr[VD_SRC_RGB3]	="$DF,$80,$60,$47,$01,$0C"	//rgb3 	(dvi shared w/digital hd3)
cCmdStr[VD_SRC_CMPNT1]	="$DF,$80,$60,$47,$01,$05"	//hd1		(component)
cCmdStr[VD_SRC_AUX1]	="$DF,$80,$60,$47,$01,$02"	//vid2	(composite) 
cCmdStr[VD_SRC_AUX2]	="$DF,$80,$60,$47,$01,$0D"	//hd3 	(dvi shared w/analog rgb3)
cCmdStr[VD_SRC_AUX3]	="$DF,$80,$60,$47,$01,$06"	//hd2 	(rgbhv shared w/rgb2)


cRespstr[VD_PWR_ON]		="$7F,$60,$80,$88,$01"			//AND the last hex w/4 0=on,1=off
cRespStr[VD_SRC_VID1]	="$7F,$60,$80,$41,$01,$01"	
cRespStr[VD_SRC_SVID]	="$7F,$60,$80,$41,$01,$03"	
cRespStr[VD_SRC_RGB1]	="$7F,$60,$80,$41,$01,$07"		
cRespStr[VD_SRC_RGB2]	="$7F,$60,$80,$41,$01,$06"	
cRespStr[VD_SRC_RGB3]	="$7F,$60,$80,$41,$01,$0C"		
cRespStr[VD_SRC_CMPNT1]="$7F,$60,$80,$41,$01,$05"		
cRespStr[VD_SRC_AUX1]	="$7F,$60,$80,$41,$01,$02"		
cRespStr[VD_SRC_AUX2]	="$7F,$60,$80,$41,$01,$0D"		
cRespStr[VD_SRC_AUX3]	="$7F,$60,$80,$41,$01,$06"		

cPollStr[PollPwr] 		="$1F,$80,$60,$88,$00"			//running sense
cPollStr[PollSrc]			="$1F,$80,$60,$41,$00"			//input mode request

create_buffer dvPlas,cPlasmaBuffer

WAIT 200
{
	IF(!TIMELINE_ACTIVE(lTLPoll))
	{
		TIMELINE_CREATE(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
	}
}
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
DATA_EVENT[dvPlas]
{
	STRING:
	{
		STACK_VAR CHAR cBuff[255]
		cBuff="data.text"
		Parse(cBuff)
		cBuff=''
	}	
}
TIMELINE_EVENT[lTLPoll]
{
	nPollType=TIMELINE.SEQUENCE
	Send_Str(cPollStr[TIMELINE.SEQUENCE])
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
					Send_Str(cCmdStr[nCmd])
					nPollType=PollPwr
				}
				case VD_PWR_TOG:
				{
					if([dvPlas,VD_PWR_ON]) nCmd=VD_PWR_OFF
					else nCmd=VD_PWR_ON
					Send_Str(cCmdStr[nCmd])
					nPollType=PollPwr
				}
				CASE VD_SRC_VID1:
				CASE VD_SRC_SVID:
				CASE VD_SRC_RGB1:
				CASE VD_SRC_RGB2:
				CASE VD_SRC_RGB3:
				CASE VD_SRC_CMPNT1:
				CASE VD_SRC_AUX1:
				CASE VD_SRC_AUX2:
				CASE VD_SRC_AUX3:
				{
					IF([dvPlas,VD_PWR_ON])
					{
						Send_Str(cCmdStr[nCmd])
						nPollType=PollSrc
					}
					ELSE
					{
						Send_Str(cCmdStr[VD_PWR_ON])
						nPollType=PollPwr
					}
				}
			}
		}
		CASE 2:	IF(nPollType) Send_STr(cPollStr[nPollType])
	}
}
CHANNEL_EVENT[vdvPlas,0]
{
	ON:
	{
		SELECT
		{	
			ACTIVE(channel.channel<VD_POLL_BEGIN):
			{
				nCmd=channel.channel
				TIMELINE_PAUSE(lTLPoll)
				WAIT 1 TIMELINE_CREATE(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
			ACTIVE(channel.channel=VD_POLL_BEGIN):
			{
				TIMELINE_CREATE(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}	
	}
}
BUTTON_EVENT[dvTP,nPlasBtn]
{
	PUSH:
	{
		PULSE[vdvPlas,button.input.channel]
	}
}
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

