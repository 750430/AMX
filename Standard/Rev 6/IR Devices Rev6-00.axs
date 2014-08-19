module_name='IR Devices Rev6-00'(dev dvTP[], dev dvIR[])
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/29/2008  AT: 12:00:43        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//define_module 'IR Devices Rev6-00' ir1(dvTP_IR,dvIR)

#include 'HoppSNAPI Rev6-00.axi'
#include 'HoppSTRUCT Rev6-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant  //Default Values

DefaultMode		=	IR_TYPE
DefaultCarrier	=	CARON_TYPE
DefaultPulse	=	2

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

define_variable //Tech Variables

volatile		char			cActiveTechIRChannel[10][3]

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
		set_port(x)
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
	cActiveTechIRChannel[pt]="cActiveTechIRChannel[pt],itoa(digit)"
	send_command dvTP[pt],"'^TXT-',itoa(IR_TEXT),',0,',cActiveTechIRChannel[pt]"	
}

define_function tp_fb()
{
	for(x=1;x<=10;x++) 
	{
		[dvTP[x],IR_CARON]=mod_ir[x].carrier=CARON_TYPE
		[dvTP[x],IR_CAROFF]=mod_ir[x].carrier=CAROFF_TYPE
		[dvTP[x],IR_MODE_IR]=mod_ir[x].mode=IR_TYPE
		[dvTP[x],IR_MODE_DATA]=mod_ir[x].mode=DATA_TYPE
		[dvTP[x],IR_MODE_SERIAL]=mod_ir[x].mode=SERIAL_TYPE
		for(y=1;y<=10;y++) [dvTP[x],IR_PULSE[y]]=mod_ir[x].pulsetime=y
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

#INCLUDE 'HoppFB Rev6-00'

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
				set_pulse_time(mod_ir[get_last(dvTP)].pulsetime)
				pulse[dvIR[get_last(dvTP)],button.input.channel]
			}
			active(button.input.channel>1000 and button.input.channel<=1255):
			{
				to[dvIR[get_last(dvTP)],button.input.channel]
			}
			active(1):
			{
				switch(button.input.channel)
				{
					case IR_CARON: mod_ir[get_last(dvTP)].carrier=CARON_TYPE
					case IR_CAROFF: mod_ir[get_last(dvTP)].carrier=CAROFF_TYPE
					case IR_MODE_IR: mod_ir[get_last(dvTP)].mode=IR_TYPE
					case IR_MODE_SERIAL: mod_ir[get_last(dvTP)].mode=SERIAL_TYPE
					case IR_MODE_DATA: mod_ir[get_last(dvTP)].mode=DATA_TYPE
					case IR_PULSE_1:
					case IR_PULSE_2:
					case IR_PULSE_3:
					case IR_PULSE_4:
					case IR_PULSE_5:
					case IR_PULSE_6:
					case IR_PULSE_7:
					case IR_PULSE_8:
					case IR_PULSE_9:
					case IR_PULSE_10: mod_ir[get_last(dvTP)].pulsetime=button.input.channel-IR_PULSE_1+1
					case IR_CHAN_DIGIT_1:
					case IR_CHAN_DIGIT_2:
					case IR_CHAN_DIGIT_3:
					case IR_CHAN_DIGIT_4:
					case IR_CHAN_DIGIT_5:
					case IR_CHAN_DIGIT_6:
					case IR_CHAN_DIGIT_7:
					case IR_CHAN_DIGIT_8:
					case IR_CHAN_DIGIT_9: key(get_last(dvTP),button.input.channel-IR_CHAN_DIGIT_1+1)
					case IR_CHAN_DIGIT_10: key(get_last(dvTP),0)
					case IR_BACK: 
					{
						set_length_string(cActiveTechIRChannel[get_last(dvTP)],length_string(cActiveTechIRChannel[get_last(dvTP)])-1)
						send_command dvTP[get_last(dvTP)],"'^TXT-',itoa(IR_TEXT),',0,',cActiveTechIRChannel[get_last(dvTP)]"	
					}
					case IR_BTN_PULSE: pulse[dvIR[get_last(dvTP)],atoi(cActiveTechIRChannel[get_last(dvTP)])]
					case IR_BTN_TO: to[dvIR[get_last(dvTP)],atoi(cActiveTechIRChannel[get_last(dvTP)])]
				}                
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
