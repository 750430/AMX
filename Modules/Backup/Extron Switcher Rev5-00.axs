MODULE_NAME='Extron Switcher Rev5-00'(DEV vdvTP[], DEV vdvDevice, DEV dvSwitcher)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/20/2008  AT: 16:42:25        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
define_module 'Extron Switcher Rev5-00' dvr1(dvTP_DEV[1],vdvDEV1,dvSwitcher)
SEND_COMMAND data.device,"'SET BAUD 9600,N,8,1'"

*)

#INCLUDE 'HoppSNAPI Rev5-08.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

integer	btnInputs[]		=	{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48}
integer	btnOutputs[]	=	{101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148}

btnTake					=	200

FeedbackTL		=	3000


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile		integer		nActiveInput
volatile		integer		nActiveOutput[48]

volatile		long		lFeedbackTime[]={100}

volatile		integer		x
(**********************************************************)
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
define_function tp_fb()
{
	for(x=1;x<=length_array(btnInputs);x++) [vdvTP,btnInputs[x]]=nActiveInput=x
	for(x=1;x<=length_array(btnOutputs);x++) [vdvTP,btnOutputs[x]]=nActiveOutput[x]
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

timeline_create(FeedbackTL,lFeedbackTime,1,timeline_relative,timeline_repeat)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

button_event[vdvTP,btnInputs]
{
	push:
	{
		if(nActiveInput=get_last(btnInputs))
		{
			off[nActiveInput]
			for(x=1;x<=length_array(btnOutputs);x++) off[nActiveOutput[x]]
		}
		else
		{
			nActiveInput=get_last(btnInputs)
			for(x=1;x<=length_array(btnOutputs);x++) off[nActiveOutput[x]]
		}
	}
}

button_event[vdvTP,btnOutputs]
{
	push:
	{
		if(nActiveInput) nActiveOutput[get_last(btnOutputs)]=!nActiveOutput[get_last(btnOutputs)]
	}
}

button_event[vdvTP,btnTake]
{
	push:
	{
		to[button.input]
		if(nActiveInput)
		{
			for(x=1;x<=length_array(btnOutputs);x++)
			{
				if(nActiveOutput[x]) send_string dvSwitcher,"itoa(nActiveInput),'*',itoa(x),'!'"
			}
			off[nActiveInput]
			for(x=1;x<=length_array(btnOutputs);x++) off[nActiveOutput[x]]
		}
		else send_command button.input.device,"'ADBEEP'"
	}
}


timeline_event[FeedbackTL]
{
	tp_fb()
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM



(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
