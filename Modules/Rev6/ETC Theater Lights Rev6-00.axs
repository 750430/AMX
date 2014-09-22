MODULE_NAME='ETC Theater Lights Rev6-00'(DEV dvTP[], DEV dvLights)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
//SET BAUD 19200,N,8,1 485 DISABLE
//define_module 'ETC Theater Lights Rev6-00' LIGHTS1(dvTP_LIGHT[1],dvLights)

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

integer nActivePreset
integer x


define_function tp_fb()
{
	for(x=1;x<=8;x++) [dvTP,x]=nActivePreset=x
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start


#include 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
define_event

data_event[dvLights]
{
	online:
	{
		
	}
	string:
	{
		if(find_string(data.text,"'rq 90'",1))
		{
			remove_string(data.text,"'rq 90'",1)
			nActivePreset=atoi(left_string(data.text,find_string(data.text,$20,1)-1))
		}
	}
}

button_event[dvTP,0]
{
	push:
	{
		to[button.input]
		send_string dvLights,"'runcue 90',itoa(button.input.channel),$0D,$0A"
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


