MODULE_NAME='Extron Volume Control Crosspoint Ultra 88 HVA Rev4-00'(DEV vdvTP[], DEV vdvSW, DEV dvSW)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/20/2009  AT: 12:20:49        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//SEND_COMMAND dvSW,"'SET BAUD 9600,N,8,1,485 DISABLE'"
//define_module 'Extron Volume Control Crosspoint Ultra 88 HVA Rev4-00' vol1(vdvTP_VOL,vdvMXR1,dvSwitcher)

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
persistent INTEGER nMteVal[24]
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
DEFINE_CALL 'Parse' (CHAR cCompStr[100])
{
	stack_var char	cLevelDirection
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,"'Out'",1) and find_string(cCompStr,"'Vol'",1)):
		{
			REMOVE_STRING(cCompStr,"'Out'",1)
			nActiveLvl=atoi(left_string(cCompStr,2))
			remove_string(cCompStr,"'Vol'",1)
			nLvlVal=atoi(left_string(cCompStr,2))
			nAMXLvl = ABS_VALUE(255*nLvlVal/64)
			SEND_LEVEL vdvTP[nActiveLvl],1,nAMXLvl	
		}
		ACTIVE(FIND_STRING(cCompStr,"'Amt'",1)):
		{
			REMOVE_STRING(cCompStr,"'Amt'",1)
			nActiveLvl=atoi(left_string(cCompStr,2))
			REMOVE_STRING(cCompStr,"'*'",1)
			nMteVal[nActiveLvl] = ATOI("LEFT_STRING(cCompStr,1)")
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
			SEND_STRING dvSW,"'0*Z'"		
			for(x=1;x<=24;x++)off[nMteVal[x]]
		}		
	}
	STRING:
	{
		CALL 'Parse' (DATA.TEXT)
	}
}

data_event[vdvTP[1]]
{
	online:
	{
		stack_var integer x
		for (x=1;x<=24;x++) send_string dvSW,"itoa(x),'V'"
	}
}

BUTTON_EVENT [vdvTP, 1]  //Volume Up
{
  PUSH:
  {
	to[button.input]
    SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+V'"
		IF (nMteVal)
    {
      SEND_STRING dvSW, "itoa(get_last(vdvTP)),'*0Z'"
			OFF[vdvTP, 3]
    }
  }
  HOLD[3,REPEAT]:
  {
    SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+V'"
    SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+V'"			
		if (button.holdtime>2000)
		{
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+V'"
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+V'"			
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+V'"
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'+V'"			
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
      SEND_STRING dvSW, "itoa(get_last(vdvTP)),'*0Z'"
			OFF[vdvTP, 3]
    }
  }
  HOLD[3,REPEAT]:
  {
		SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-V'"
		SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-V'"
		if (button.holdtime>2000)
		{
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-V'"
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-V'"
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-V'"
			SEND_STRING dvSW, "itoa(get_last(vdvTP)),'-V'"
		}
  }
}

BUTTON_EVENT [vdvTP,3]  //Master Volume Mute
{
  PUSH:
  {
    IF (nMteVal[get_last(vdvTP)])
    {
      SEND_STRING dvSW, "itoa(get_last(vdvTP)),'*0Z'"
    }
    IF (!nMteVal[get_last(vdvTP)]) 
    {
      SEND_STRING dvSW, "itoa(get_last(vdvTP)),'*1Z'"
    }
  }
} 

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

for(x=1;x<=24;x++) [vdvTP[x],3]=nMteVal[x]

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
