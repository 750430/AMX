MODULE_NAME='Samsung 400CXN Rev5-00'(dev dvTP, dev vdvPlas, dev dvPlas)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/29/2011  AT: 17:09:04        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                   *)
(***********************************************************)

//define_module 'Samsung 400CXN Rev5-00' disp1(vdvTP_DISP1,vdvDISP1,dvPlasma)
//Set baud to 9600,N,8,1

#include 'HoppSNAPI Rev5-04.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]				= {5100}
LONG lCmdArray[]				=	{3010,3010}

CHAR cCmdStr[35][10]	
CHAR cPollStr[5]

INTEGER nCmd=0
//INTEGER nPlasBtns[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34}

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])

([dvPlas,VD_PWR_ON],[dvPlas,VD_PWR_OFF])
([dvPlas,VD_SRC_AUX1],[dvPlas,VD_SRC_RGB1],[dvPlas,VD_SRC_CMPNT1],[dvPlas,VD_SRC_VGA1],[dvPlas,VD_SRC_AUX2],[dvPlas,VD_SRC_DVI1])

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
DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	switch(mid_string(cCompStr,6,1))
	{
		case $00:
		{
			switch(mid_string(cCompStr,7,1))
			{
				case $01:
				{
					ON[dvPlas,VD_PWR_ON]
					ON[dvTP,VD_PWR_ON]
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}   
				case $00:
				{
					ON[dvPlas,VD_PWR_OFF]
				    ON[dvTP,VD_PWR_OFF]
				    IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}   
			}
			switch(mid_string(cCompStr,10,1))
			{
				case $1E:
				{
					ON[dvPlas,VD_SRC_RGB1]
					if(nCmd=VD_SRC_RGB1)
					{
						CmdExecuted()
						pulse[vdvPlas,VD_PCADJ]
					}
				}
				case $20:
				{
					ON[dvPlas,VD_SRC_AUX1]
					if(nCmd=VD_SRC_AUX1) CmdExecuted()
				}
				case $30:
				{
					ON[dvPlas,VD_SRC_AUX2]
					if(nCmd=VD_SRC_AUX2) CmdExecuted()
				}
				case $08:
				{
					on[dvPlas,VD_SRC_CMPNT1]
					if(nCmd=VD_SRC_CMPNT1) CmdExecuted()
				}
				case $14:
				{
					on[dvPlas,VD_SRC_VGA1]
					if(nCmd=VD_SRC_VGA1)
					{
						CmdExecuted()
						pulse[vdvPlas,VD_PCADJ]
					}
				}
				case $21:
				{
					on[dvPlas,VD_SRC_DVI1]
					if(nCmd=VD_SRC_DVI1)
					{
						CmdExecuted()
						pulse[vdvPlas,VD_PCADJ]
					}
				}				
			}
		}
		case $11:
		{
			switch(mid_string(cCompStr,7,1))
			{
				case $01:
				{
					ON[dvPlas,VD_PWR_ON]
					ON[dvTP,VD_PWR_ON]
					IF(nCmd=VD_PWR_ON) CmdExecuted()
				}   
				case $00:
				{
					ON[dvPlas,VD_PWR_OFF]
				    ON[dvTP,VD_PWR_OFF]
				    IF(nCmd=VD_PWR_OFF) CmdExecuted()
				}   
			}
		}
		case $14:
		{
			switch(mid_string(cCompStr,7,1))
			{
				case $1E:
				{
					ON[dvPlas,VD_SRC_RGB1]
					if(nCmd=VD_SRC_RGB1)
					{
						CmdExecuted()
						pulse[vdvPlas,VD_PCADJ]
					}
				}
				case $20:
				{
					ON[dvPlas,VD_SRC_AUX1]
					if(nCmd=VD_SRC_AUX1) CmdExecuted()
				}
				case $30:
				{
					ON[dvPlas,VD_SRC_AUX2]
					if(nCmd=VD_SRC_AUX2) CmdExecuted()
				}
				case $08:
				{
					on[dvPlas,VD_SRC_CMPNT1]
					if(nCmd=VD_SRC_CMPNT1) CmdExecuted()
				}
				case $14:
				{
					on[dvPlas,VD_SRC_VGA1]
					if(nCmd=VD_SRC_VGA1)
					{
						CmdExecuted()
						pulse[vdvPlas,VD_PCADJ]
					}
				}
			}
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		= "$AA,$11,$FF,$01,$01,calcchecksum("$11,$FF,$01,$01")" 			
cCmdStr[VD_PWR_OFF]		= "$AA,$11,$FF,$01,$00,calcchecksum("$11,$FF,$01,$00")"
cCmdStr[VD_SRC_RGB1]	= "$AA,$14,$FF,$01,$1E,calcchecksum("$14,$FF,$01,$1E")"
cCmdStr[VD_SRC_VGA1]	= "$AA,$14,$FF,$01,$14,calcchecksum("$14,$FF,$01,$14")"
cCmdStr[VD_SRC_CMPNT1]	= "$AA,$14,$FF,$01,$08,calcchecksum("$14,$FF,$01,$08")"
cCmdStr[VD_SRC_AUX1]	= "$AA,$14,$FF,$01,$20,calcchecksum("$14,$FF,$01,$20")"
cCmdStr[VD_SRC_AUX2]	= "$AA,$14,$FF,$01,$30,calcchecksum("$14,$FF,$01,$30")"
cCmdStr[VD_SRC_DVI1]	= "$AA,$14,$FF,$01,$21,calcchecksum("$14,$FF,$01,$21")"

cCmdStr[VD_PCADJ]		= "$AA,$3D,$FF,$01,$00,calcchecksum("$3D,$FF,$01,$00")"

cPollStr = "$AA,$00,$FF,$00,$FF"


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

DATA_EVENT[dvPlas]
{
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cFullStr[100]
		LOCAL_VAR CHAR cBuff[255]
		STACK_VAR INTEGER nPos	
		
		parse(data.text)
//		cBuff = "cBuff,data.text"
//		WHILE(LENGTH_STRING(cBuff))
//		{
//			SELECT
//			{
//				active(find_string(cBuff,"$AA",1))
//				{
//					mid_string(cBuff,find_string(cBuff,"$AA",1)+3,1)
//				
//			
//			
//				ACTIVE(FIND_STRING(cBuff,"$AA",1)&& LENGTH_STRING(cHold)):
//				{
//					nPos=FIND_STRING(cBuff,"$03",1)
//					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
//					Parse(cFullStr)
//					cHold=''
//				}
//				ACTIVE(FIND_STRING(cBuff,"$03",1)):
//				{
//					nPos=FIND_STRING(cBuff,"$03",1)
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
	}	
}

TIMELINE_EVENT[lTLPoll]
{
	SEND_STRING dvPlas,"cPollStr"
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
					SEND_STRING dvPlas,cCmdStr[nCmd]
				}
				CASE VD_SRC_RGB1:
				CASE VD_SRC_AUX1:
				CASE VD_SRC_AUX2:
				case VD_SRC_CMPNT1:
				case VD_SRC_VGA1:
				case VD_SRC_DVI1:
				{
					IF([dvPlas,VD_PWR_ON])
					{
						SEND_STRING dvPlas,cCmdStr[nCmd]
					}
					ELSE
					{
						SEND_STRING dvPlas,cCmdStr[VD_PWR_ON]
					}
				}
				case VD_PCADJ:
				{
					send_string dvPlas,cCmdStr[nCmd]
					CmdExecuted()
				}
			}
		}
		CASE 2:	//2nd time
		{
			SEND_STRING dvPlas,cPollStr
		}
	}
}
CHANNEL_EVENT[vdvPlas,0]
{
	ON:
	{
//		send_string 0,"'Samsung 400Dxn receiving channel ',itoa(channel.channel)"
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
				//send_string 0,"'Panasonic PT-3500U creating lTLPoll'"
				TIMELINE_CREATE(lTLPoll,lPollArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
			}
		}
	}
}
BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		//to[button.input]
		PULSE[vdvPlas,button.input.channel]
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

