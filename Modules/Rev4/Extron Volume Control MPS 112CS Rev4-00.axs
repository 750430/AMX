MODULE_NAME='Extron Volume Control MPS 112CS Rev4-00'(DEV vdvTP, DEV vdvSW, DEV dvSW)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/20/2009  AT: 12:20:49        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//SEND_COMMAND dvSW,"'SET BAUD 9600,N,8,1,485 DISABLE'"
//define_module 'Extron Volume Control Single Rev4-00' vol1(vdvTP_VOL,vdvMXR1,dvSwitcher)

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
define_function parse (CHAR cCompStr[100])
{
	stack_var char	cLevelDirection
	send_string 0,"'Beginning Parse: ',cCompStr"
	SELECT
	{
		ACTIVE(find_string(cCompStr,"'Vol'",1)):
		{
			remove_string(cCompStr,"'Vol'",1)
			send_string 0,"'Removed Vol: ',cCompStr"
			nLvlVal=atoi(left_string(cCompStr,find_string(cCompStr,"$0D,$0A",1)-1))
			send_string 0,"'nLvlVal: ',nLvlVal"
			nAMXLvl = ABS_VALUE(255*nLvlVal/92)
			send_string 0,"'nAMXLvl: ',nAMXLvl"
			SEND_LEVEL vdvTP,1,nAMXLvl	
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
			SEND_STRING dvSW,"'0Z'"		
			for(x=1;x<=24;x++)off[nMteVal]
		}		
	}
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cFullStr[100]
		LOCAL_VAR CHAR cBuff[255]
		STACK_VAR INTEGER nPos	
		
		cBuff = "cBuff,data.text"
		send_string 0,"'String Received: ',data.text"
		send_string 0,"'Current cBuff: ',cBuff"
		WHILE(LENGTH_STRING(cBuff))
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cBuff,"$0D,$0A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0D,$0A",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0D,$0A",1)):
				{
					nPos=FIND_STRING(cBuff,"$0D,$0A",1)
					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
					parse(cFullStr)
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

data_event[vdvTP]
{
	online:
	{
		stack_var integer x
		send_string dvSW,"'V'"
	}
}

BUTTON_EVENT [vdvTP, 1]  //Volume Up
{
  PUSH:
  {
	to[button.input]
    SEND_STRING dvSW, "'+V'"
		IF (nMteVal)
    {
      SEND_STRING dvSW, "'0Z'"
			OFF[vdvTP, 3]
    }
  }
  HOLD[3,REPEAT]:
  {
    SEND_STRING dvSW, "'+V'"
    SEND_STRING dvSW, "'+V'"			
		if (button.holdtime>2000)
		{
			SEND_STRING dvSW, "'+V'"
			SEND_STRING dvSW, "'+V'"			
			SEND_STRING dvSW, "'+V'"			
			SEND_STRING dvSW, "'+V'"			
		}
  }
}

BUTTON_EVENT [vdvTP, 2]  //Master Volume Down
{
  PUSH:
  {
	to[button.input]
    SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-V'"
		IF (nMteVal)
    {
      SEND_STRING dvSW, "'0Z'"
			OFF[vdvTP, 3]
    }
  }
  HOLD[3,REPEAT]:
  {
		SEND_STRING dvSW, "'-V'"
		SEND_STRING dvSW, "'-V'"
		if (button.holdtime>2000)
		{
			SEND_STRING dvSW, "'-V'"
			SEND_STRING dvSW, "'-V'"
			SEND_STRING dvSW, "'-V'"
			SEND_STRING dvSW, "'-V'"
		}
  }
}

BUTTON_EVENT [vdvTP,3]  //Master Volume Mute
{
  PUSH:
  {
    IF (nMteVal)
    {
      SEND_STRING dvSW, "'0Z'"
    }
    IF (!nMteVal) 
    {
      SEND_STRING dvSW, "'1Z'"
    }
  }
} 

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[vdvTP,3]=nMteVal

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
