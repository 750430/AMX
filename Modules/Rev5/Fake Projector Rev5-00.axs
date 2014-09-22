MODULE_NAME='Fake Projector Rev5-00'(DEV dvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   

define_module 'Fake Projector Rev5-00' disp1(vdvTP_DISP1,vdvDISP1,dvProj)
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

tlLamp		=	2001

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

persistent		integer		nLampLife

non_volatile	long		lLampTime[]={10000}

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF],[dvTP,VD_COOLING],[dvTP,VD_WARMING])
([dvTP,VD_MUTE_ON],[dvTP,VD_MUTE_OFF])
([dvTP,VD_SRC_RGB1],[dvTP,VD_SRC_RGB2],[dvTP,VD_SRC_RGB3],[dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_AUX1])

([dvProj,VD_PWR_ON],[dvProj,VD_WARMING],[dvProj,VD_COOLING],[dvProj,VD_PWR_OFF])
([dvProj,VD_MUTE_ON],[dvProj,VD_MUTE_OFF])
([dvProj,VD_SRC_RGB1],[dvProj,VD_SRC_RGB2],[dvProj,VD_SRC_RGB3],[dvProj,VD_SRC_VID1],[dvProj,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1],[dvTP,VD_SRC_AUX1])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
timeline_create(tlLamp,lLampTime,length_array(lLampTime),timeline_relative,timeline_repeat)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

CHANNEL_EVENT[vdvProj,0]
{
	ON:
	{
		SWITCH(channel.channel)
		{
			CASE VD_PWR_ON:
			{
				if(![dvProj,VD_PWR_ON])
				{
					on[dvTP,VD_WARMING]
					on[dvProj,VD_WARMING]
					wait 20
					{
						on[dvTP,VD_PWR_ON]
						on[dvProj,VD_PWR_ON]
					}
				}
				send_string vdvProj,"'POWER=1'"
			}
			CASE VD_PWR_OFF: 
			{
				if(![dvProj,VD_PWR_OFF])
				{
					on[dvTP,VD_COOLING]
					on[dvProj,VD_COOLING]
					wait 20
					{
						on[dvTP,VD_PWR_OFF]
						on[dvProj,VD_PWR_OFF]
					}
				}
				send_string vdvProj,"'POWER=0'"
			}
			CASE VD_SRC_VID1:
			CASE VD_SRC_SVID:
			CASE VD_SRC_RGB1:
			CASE VD_SRC_RGB2:
			CASE VD_SRC_RGB3:
			CASE VD_SRC_CMPNT1:
			CASE VD_SRC_AUX1:
			{
				on[dvTP,channel.channel]
				on[dvProj,channel.channel]
				if(![dvProj,VD_PWR_ON])
				{
					on[dvTP,VD_WARMING]
					on[dvProj,VD_WARMING]
					wait 20
					{
						on[dvTP,VD_PWR_ON]
						on[dvProj,VD_PWR_ON]
					}
				}
				send_string vdvProj,"'POWER=1'"
			}
		}
	}
}

BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		pulse[vdvProj,button.input.channel]
	}
}

timeline_event[tlLamp]
{
	nLampLife++
	send_string vdvProj,"'LAMPTIME=',itoa(nLampLife)"
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


