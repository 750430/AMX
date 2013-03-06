MODULE_NAME='AMX DVX2150 Volume Control Single Rev5-00'(DEV vdvTP, DEV vdvAMX, DEV dvAMX)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/20/2009  AT: 12:20:49        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//define_module 'AMX DVX2150 Volume Control Single Rev5-00' vol1(vdvTP_VOL1,vdvMXR1,dvAMXVol)

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
persistent	sinteger	nMaxLvl=100
persistent	sinteger	nMinLvl=0
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
			nAMXLvl=type_cast(nLvlVal*255/nMaxLvl)
			send_level vdvTP,1,nAMXLvl
		}
		if(find_string(data.text,"'AUDOUT_MUTE'",1))
		{
			remove_string(data.text,"'AUDOUT_MUTE-'",1)
			if(find_string(data.text,"'ENABLE'",1)) on[nMteVal]
			else if(find_string(data.text,"'DISABLE'",1)) off[nMteVal]
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
			send_command dvAMX,"'?AUDOUT_MUTE'"
		}
	}
}

BUTTON_EVENT [vdvTP, 1]  //Volume Up
{
	PUSH:
	{
		to[button.input]
		if(nLvlVal<nMaxLvl)
		{
			nLvlVal=nLvlVal+2
			if(nLvlVal>nMaxLvl) nLvlVal=nMaxLvl
			nAMXLvl=type_cast(nLvlVal*255/nMaxLvl)
			send_command dvAMX, "'VOLUME ',itoa(nLvlVal)"
		}
		send_level vdvTP,1,nAMXLvl
//		IF (nMteVal)
//		{
//			SEND_STRING dvAMX, "'0Z'"
//			OFF[vdvTP, 3]
//		}
	}
	HOLD[3,REPEAT]:
	{
		select
		{
			active(button.holdtime<2000):
			{
				if(nLvlVal<nMaxLvl)
				{
					nLvlVal=nLvlVal+2
					if(nLvlVal>nMaxLvl) nLvlVal=nMaxLvl
					nAMXLvl=type_cast(nLvlVal*255/nMaxLvl)
					send_command dvAMX, "'VOLUME ',itoa(nLvlVal)"
					send_level vdvTP,1,nAMXLvl
				}
			}
			active(button.holdtime>=2000):
			{
				if(nLvlVal<nMaxLvl)
				{
					nLvlVal=nLvlVal+5
					if(nLvlVal>nMaxLvl) nLvlVal=nMaxLvl
					nAMXLvl=type_cast(nLvlVal*255/nMaxLvl)
					send_command dvAMX, "'VOLUME ',itoa(nLvlVal)"
					send_level vdvTP,1,nAMXLvl
				}
			}			
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
			nAMXLvl=type_cast(nLvlVal*255/nMaxLvl)
			send_command dvAMX, "'VOLUME ',itoa(nLvlVal)"
		}
		send_level vdvTP,1,nAMXLvl
	}
	HOLD[3,REPEAT]:
	{
		select
		{
			active(button.holdtime<2000):
			{
				if(nLvlVal>=nMinLvl)
				{
					if(nLvlVal>=nMinLvl+2) nLvlVal=nLvlVal-2
					else nLvlVal=nMinLvl
					nAMXLvl=type_cast(nLvlVal*255/nMaxLvl)
					send_command dvAMX, "'VOLUME ',itoa(nLvlVal)"
					send_level vdvTP,1,nAMXLvl
				}
			}
			active(button.holdtime>=2000):
			{
				if(nLvlVal<nMaxLvl)
				{
					if(nLvlVal>=nMinLvl+2) nLvlVal=nLvlVal-2
					else nLvlVal=nMinLvl
					nAMXLvl=type_cast(nLvlVal*255/nMaxLvl)
					send_command dvAMX, "'VOLUME ',itoa(nLvlVal)"
					send_level vdvTP,1,nAMXLvl
				}
			}			
		}
	}
}

BUTTON_EVENT [vdvTP,3]  //Master Volume Mute
{
  PUSH:
  {
    IF (nMteVal)
    {
      send_command dvAMX, "'AUDOUT_MUTE-DISABLE'"
    }
    IF (!nMteVal) 
    {
      send_command dvAMX, "'AUDOUT_MUTE-ENABLE'"
    }
	nMteVal=!nMteVal
	wait 10 send_command dvAMX,"'?AUDOUT_MUTE'"
  }
} 

timeline_event[tlPoll]
{
	send_command dvAMX,"'?VOLUME'"
	send_command dvAMX,"'?AUDOUT_MUTE'"
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
