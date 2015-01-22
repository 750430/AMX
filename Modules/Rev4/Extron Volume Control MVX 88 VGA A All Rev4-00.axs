MODULE_NAME='Extron Volume Control MVX 88 VGA A All Rev4-00'(DEV vdvTP[], DEV vdvSW[], DEV dvSW)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/20/2009  AT: 12:20:49        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//SEND_COMMAND dvSW,"'SET BAUD 9600,N,8,1,485 DISABLE'"
//define_module 'Extron Volume Control MVX 88 VGA A All Rev4-00' vol1(vdvTP_VOL,vdvMXR1,dvSwitcher)

#INCLUDE 'HoppSNAPI Rev4-01.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

persistent INTEGER nLvlVal
persistent INTEGER nAMXLvl
persistent INTEGER nMteVal
persistent integer nCurrentQuery
volatile	integer	nMuteQuery
non_volatile	integer	nActiveLvl

volatile integer x

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)
define_function parse(CHAR cCompStr[100])
{
	stack_var char	cLevelDirection
	stack_var char  nWait
	local_var char  cQueuedMatch[3]
	send_string 0,"'cCompStr: ',cCompStr"
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,"'In'",1) and find_string(cCompStr,"'Aud'",1)):
		{
			REMOVE_STRING(cCompStr,"'In'",1)
			if (nActiveLvl=atoi(left_string(cCompStr,2))) on[nWait]
			nActiveLvl=atoi(left_string(cCompStr,2))
			remove_string(cCompStr,"'Aud'",1)
			if (nWait)
			{
				off[nWait]
				send_string 0,"'Wait Handler Firing'"
				cQueuedMatch=left_string(cCompStr,3)
				cancel_wait 'Match Audio'
				wait 10 'Match Audio' match_audio(cQueuedMatch)
			}
			nLvlVal=gtoi(left_string(cCompStr,3))
			nAMXLvl = ABS_VALUE(255*nLvlVal/28)
			SEND_LEVEL vdvTP[nActiveLvl],1,nAMXLvl	
		}
		active(left_string(cCompStr,1)="'+'" or left_string(cCompStr,1)="'-'"):
		{
			nActiveLvl=nCurrentQuery
			nLvlVal=gtoi(left_string(cCompStr,3))
			nAMXLvl=abs_value(255*nLvlVal/28)
			send_level vdvTP[nActiveLvl],1,nAMXLvl
			send_string dvSW,"'1Z'"
			on[nMuteQuery]
		}
		active(nMuteQuery):
		{
			off[nMuteQuery]
			nMteVal=atoi(left_string(cCompStr,1))
		}
		ACTIVE(FIND_STRING(cCompStr,"'Amt'",1)):
		{
			REMOVE_STRING(cCompStr,"'Amt'",1)
			nActiveLvl=atoi(left_string(cCompStr,2))
			REMOVE_STRING(cCompStr,"'*'",1)
			nMteVal = ATOI("LEFT_STRING(cCompStr,1)")
		}
	}
}

define_function integer gtoi(char i[3])
{
	switch(left_string(i,1))
	{
		case '-':
		{
			remove_string(i,'-',1)
			return (18-atoi(i))
		}
		case '+':
		{
			remove_string(i,'+',1)
			return (18+atoi(i))
		}
	}
}

define_function char[3] itog(integer i)
{
	select
	{
		active (i<18):
		{
			return "'-',abs_value(itoa(i-17))"
		}
		active(i>=18 and i<28):
		{
			return "'+0',itoa(i-18)"
		}
		active(i>=28):
		{
			return "'+',itoa(i-18)"
		}
	}
}

define_function match_audio(char i[3])
{
	stack_var char value[3]
	send_string 0,"'Match Audio Firing: ',i"
	switch(left_string(i,1))
	{
		case '-':
		{
			remove_string(i,'-',1)
			for(x=1;x<=5;x++) if (nActiveLvl<>x) send_string dvSW,"itoa(x),'*',i,'g'"
		}
		case '+':
		{
			remove_string(i,'+',1)
			for(x=1;x<=5;x++) if (nActiveLvl<>x) send_string dvSW,"itoa(x),'*',i,'G'"
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvSW]														// Data Event For Extron Switcher
{
	ONLINE:
	{
		WAIT 5
		{
			//SEND_STRING dvSW,"'0*Z'"		
			//for(x=1;x<=24;x++)off[nMteVal[x]]
		}		
	}
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
				ACTIVE(FIND_STRING(cBuff,"$0D,$0A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0D,$0A",1)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
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
//
//data_event[vdvTP[1]]
//{
//	online:
//	{
//		stack_var integer x
//		for (x=1;x<=24;x++) send_string dvSW,"itoa(x),'G'"
//	}
//}

BUTTON_EVENT [vdvTP, 1]  //Volume Up
{
  PUSH:
  {
	to[button.input]
    SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+G'"
	IF (nMteVal)
    {
		SEND_STRING dvSW, "'0*Z'"
    }
  }
  HOLD[3,REPEAT]:
  {
    SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+G'"
    SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+G'"			
		if (button.holdtime>2000)
		{
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+G'"
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+G'"			
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+G'"
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+G'"			
		}
  }
}

BUTTON_EVENT [vdvTP, 2]  //Master Volume Down
{
  PUSH:
  {
	to[button.input]
    SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-G'"
	IF (nMteVal)
    {
		SEND_STRING dvSW, "'0*Z'"
    }
  }
  HOLD[3,REPEAT]:
  {
		SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-G'"
		SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-G'"
		if (button.holdtime>2000)
		{
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-G'"
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-G'"
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-G'"
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-G'"
		}
  }
}

BUTTON_EVENT [vdvTP,3]  //Master Volume Mute
{
  PUSH:
  {
    IF (nMteVal)
    {
      SEND_STRING dvSW, "'0*Z'"
    }
    IF (!nMteVal) 
    {
      SEND_STRING dvSW, "'1*Z'"
    }
  }
} 

channel_event[vdvSW,MIX_QUERY]
{
	on:
	{
		send_string dvSW,"itoa(get_last(vdvSW)),'G'"
		nCurrentQuery=get_last(vdvSW)
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

for(x=1;x<=24;x++) [vdvTP[x],3]=nMteVal

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
