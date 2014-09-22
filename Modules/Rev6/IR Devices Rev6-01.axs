module_name='IR Devices Rev6-01'(dev dvTP[], dev dvIR[])
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/29/2008  AT: 12:00:43        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//define_module 'IR Devices Rev6-01' ir1(vdvTP_IR,dvIR)

#include 'HoppSNAPI Rev6-00.axi'
#include 'HoppSTRUCT Rev6-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant  //Default Values

kpOn			=	1
kpOff			=	2

DefaultMode		=	IR_TYPE
DefaultCarrier	=	CARON_TYPE
DefaultPulse	=	2
DefaultKeypad	=	kpOn

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_type

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

volatile		ir_struct	mod_ir[10]

define_variable //Binary File Variables

volatile		long		lPos
volatile		slong		slReturn
volatile		slong		slFile
volatile		slong		slResult
volatile		char		sBINString[10000]

define_variable //Key Preview Variables

volatile		char		cKeyPreview[10][10]

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

define_function read_ir()
{
	// Read Binary File
	slFile = file_open('BinaryirEncode.xml',1)
	slResult = file_read(slFile, sBINString, max_length_string(sBINString))
	slResult = file_close (slFile)
	// Convert To Binary
	lPos = 1
	slReturn = string_to_variable(mod_ir, sBINString, lPos)	
}

define_function init_values()
{
	for(x=1;x<=max_length_array(mod_ir);x++)
	{
		if(!mod_ir[x].carrier) mod_ir[x].carrier=DefaultCarrier
		if(!mod_ir[x].mode) mod_ir[x].mode=DefaultMode
		if(!mod_ir[x].pulsetime) mod_ir[x].pulsetime=DefaultPulse
		if(!mod_ir[x].keypad) mod_ir[x].keypad=DefaultKeypad
		if(x<=max_length_array(dvIR)) set_port(x)
	}
}

define_function set_port(i)
{
	switch(mod_ir[i].carrier)
	{
		case CARON_TYPE: send_command dvIR[i],'CARON'
		case CAROFF_TYPE: send_command dvIR[i],'CAROFF'
	}
	switch(mod_ir[i].mode)
	{
		case IR_TYPE: send_command dvIR[i],'SET MODE IR'
		case DATA_TYPE: send_command dvIR[i],'SET MODE DATA'
		case SERIAL_TYPE: send_command dvIR[i],'SET MODE SERIAL'
	}	
}

define_function key(integer pt,integer digit)
{
	cKeyPreview[pt]="cKeyPreview[pt],itoa(digit)"
	send_command button.input.device,"'^TXT-1,0,',cKeyPreview[pt]"
	cancel_wait 'KeyPreview'
	wait 50 'KeyPreview'
	{
		for(x=1;x<=10;x++) cKeyPreview[x]=""
		send_command dvTP,"'^TXT-1,0,'"
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

wait 20
{
	read_ir()
	init_values()
}


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvIR] 													//Data event IR devices
{ 
	online: 
	{
		set_port(get_last(dvIR))
	}
}


button_event[dvTP, 0]
{                
	push:
	{
		to[button.input]
		select
		{
			active(button.input.channel>0 and button.input.channel<=255):
			{
				if(mod_ir[get_last(dvTP)].keypad=kpOn)
				{
					if(button.input.channel=10) key(get_last(dvTP),0)
					else if(button.input.channel>=11 and button.input.channel<=19) key(get_last(dvTP),button.input.channel-10)
				}
				set_pulse_time(mod_ir[get_last(dvTP)].pulsetime)
				pulse[dvIR[get_last(dvTP)],button.input.channel]
			}
			active(button.input.channel>1000 and button.input.channel<=1255):
			{
				to[dvIR[get_last(dvTP)],button.input.channel]
			}
		}
	}
}


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
