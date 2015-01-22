MODULE_NAME='RGB Spectrum QuadView HD Rev4-00'(dev dvTP[], dev vdvAlto, dev dvAlto, char cIPAddress[])
(***********************************************************)
(*  FILE CREATED ON: 06/25/2008  AT: 12:44:26              *)
(***********************************************************)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/25/2008  AT: 13:37:39        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)
//define_module 'RGB Spectrum QuadView HD Rev4-00' wal1(dvTP_DEV[1],vdvDEV1,dvRGB,cRGBIPAddress)

#include 'HoppSNAPI Rev4-01.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
define_device

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant

ReconnectTL		=	3000

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

non_volatile 	integer	nIPConnected
volatile 		long 	lReconnectTime[1] = 30000

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start
ip_client_open(dvAlto.port,cIPAddress,8000,1)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvAlto]
{
	online:
	{
		on[nIPConnected]
	}
	offline:
	{
		off[nIPConnected]
	}
	string:
	{
		send_string 0,"data.text"
	}
}

channel_event[vdvAlto,0]
{
	on:
	{
		send_string dvAlto,"'wpload ',itoa(channel.channel),$0D,$0A"
		send_string 0,"'wpload ',itoa(channel.channel),$0D,$0A"
	}
}

button_event[dvTP,0]
{
	push:
	{
		pulse[vdvAlto,button.input.channel]
	}
}

timeline_event[ReconnectTL]
{
	ip_client_close(dvAlto.port)
	wait 5
	ip_client_open(dvAlto.port,cIPAddress,8000,1)
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program

if (!nIPConnected and !timeline_active(ReconnectTL))
{
	timeline_create (ReconnectTL,lReconnectTime,1,timeline_relative,timeline_repeat)	//Try to reconnect
}

if (nIPConnected and timeline_active(ReconnectTL))
{
	timeline_kill(ReconnectTL)	//Stop trying to reconnect
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

