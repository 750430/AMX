MODULE_NAME='AMX DVX2100 Volume Control Single Rev5-00'(DEV vdvTP, DEV vdvAMX, DEV dvAMX)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/20/2009  AT: 12:20:49        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//define_module 'AMX DVX2100 Volume Control Single Rev5-00' vol1(vdvTP_VOL1,vdvMXR1,dvAMXVol)

#INCLUDE 'HoppSNAPI Rev5-01.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

tlPoll		=	1

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

persistent sINTEGER nLvlVal
persistent INTEGER nAMXLvl
persistent INTEGER nMteVal
non_volatile	integer	nActiveLvl

volatile integer x

volatile		long		lPollTimes[]={30000}

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

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
timeline_create(tlPoll,lPollTimes,length_array(lPollTimes),timeline_relative,timeline_repeat)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvAMX]														// Data Event For Extron Switcher
{
	ONLINE:
	{
//		WAIT 5
//		{
//			SEND_STRING dvAMX,"'0Z'"		
//			for(x=1;x<=24;x++)off[nMteVal]
//		}		
	}
	COMMAND:
	{
		if(find_string(data.text,"'VOLUME-'",1))
		{
			remove_string(data.text,"'VOLUME-'",1)
			nLvlVal=atoi(data.text)
			nAMXLvl=nLvlVal*255/100
			send_level vdvTP,1,nAMXLvl
		}
		if(find_string(data.text,"'AUDIO_MUTE'",1))
		{
			remove_string(data.text,"'AUDIO_MUTE-'",1)
			if(find_string(data.text,"'ENABLED'",1)) on[nMteVal]
			else if(find_string(data.text,"'ENABLED'",1)) off[nMteVal]
		}
	}
}

data_event[vdvTP]
{
	online:
	{
		wait 100 
		{
			send_command dvAMX,"'?VOLUME'"
			send_command dvAMX,"'?AUDIO_MUTE'"
		}
	}
}

BUTTON_EVENT [vdvTP, 1]  //Volume Up
{
	PUSH:
	{
		to[button.input]
		if(nLvlVal<100)
		{
			nLvlVal=nLvlVal+2
			send_command dvAMX, "'VOLUME ',itoa(nLvlVal)"
		}
		send_level vdvTP,1,nLvlVal
//		IF (nMteVal)
//		{
//			SEND_STRING dvAMX, "'0Z'"
//			OFF[vdvTP, 3]
//		}
	}
	HOLD[3,REPEAT]:
	{
		if(nLvlVal<99)
		{
			nLvlVal=nLvlVal+2
			send_command dvAMX, "'VOLUME ',itoa(nLvlVal)"
			send_level vdvTP,1,nLvlVal
		}
	}
}

BUTTON_EVENT [vdvTP, 2]  //Master Volume Down
{
	PUSH:
	{
		to[button.input]
		if(nLvlVal>1)
		{
			nLvlVal=nLvlVal-2
			send_command dvAMX, "'VOLUME ',itoa(nLvlVal)"
		}
		send_level vdvTP,1,nLvlVal
	}
	HOLD[3,REPEAT]:
	{
		if(nLvlVal>1)
		{
			nLvlVal=nLvlVal-2
			send_command dvAMX, "'VOLUME ',itoa(nLvlVal)"
			send_level vdvTP,1,nLvlVal
		}
	}
}

BUTTON_EVENT [vdvTP,3]  //Master Volume Mute
{
  PUSH:
  {
    IF (nMteVal)
    {
      send_command dvAMX, "'AUDIO_MUTE DISABLED'"
    }
    IF (!nMteVal) 
    {
      send_command dvAMX, "'AUDIO_MUTE ENABLED'"
    }
	nMteVal=!nMteVal
	wait 10 send_command dvAMX,"'?AUDIO_MUTE'"
  }
} 

timeline_event[tlPoll]
{
	send_command dvAMX,"'?VOLUME'"
	send_command dvAMX,"'?AUDIO_MUTE'"
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
