MODULE_NAME='Fake DVD Rev5-00'(DEV dvTP[], DEV vdvDevice, DEV dvDevice)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/22/2008  AT: 16:42:25        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
define_module 'Fake DVD Rev5-00' DVR1(dvTP_DEV[1],vdvDEV1,dvDVR)


*)

#INCLUDE 'HoppSNAPI Rev5-00.axi'
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


(**********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP[1],DVR_PWR_ON],[dvTP[1],DVR_PWR_OFF])
([dvTP[1],DVR_PLAY],[dvTP[1],DVR_STOP],[dvTP[1],DVR_REW],[dvTP[1],DVR_FWD],[dvTP[1],DVR_PAUSE])

([dvDevice,DVR_PWR_ON],[dvDevice,DVR_PWR_OFF])
([dvDevice,DVR_PLAY],[dvDevice,DVR_STOP],[dvDevice,DVR_REW],[dvDevice,DVR_FWD],[dvDevice,DVR_PAUSE])
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

CHANNEL_EVENT[vdvDevice,0]
{
	ON:	
	{
		switch(channel.channel)
		{
			case DVR_PWR_ON:
			case DVR_PWR_OFF:
			{
				on[dvTP,channel.channel]
				on[dvDevice,channel.channel]
				pulse[vdvDevice,channel.channel+19]
			}
			case DVR_PLAY:
			case DVR_STOP:
			case DVR_REW:
			case DVR_FWD:
			case DVR_PAUSE:
			{
				on[dvTP,channel.channel]
				on[dvDevice,channel.channel]
				pulse[vdvDevice,channel.channel+240]
			}
		}
	}
}

BUTTON_EVENT [dvTP,0]
{
	PUSH:	
	{
		switch(button.input.channel)
		{
			case DVR_NEXT:
			case DVR_BACK: 
			{
				to[button.input]
				pulse[vdvDevice,DVR_PLAY]
			}
			default: pulse[vdvDevice,button.input.channel]	
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
