MODULE_NAME='Gentner GT1524 Volume Rev4-00'(DEV vdvTP, DEV vdvATC, DEV dvATC,integer nChan,char cIO)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/20/2009  AT: 12:20:49        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//SEND_COMMAND dvSW,"'SET BAUD 9600,N,8,1,485 DISABLE'"
//define_module 'Gentner GT1524 Volume Rev4-00' vol1(vdvTP_VOL[1],vdvMXR1,dvATC,nATCChannel,cATCIO)

#INCLUDE 'HoppSNAPI Rev4-01.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

GNTNR_MICLINE	=	1
GNTNR_AUX		=	2
GNTNR_4WIRE		=	3
GNTNR_TELCO		=	4

GNTNR_IN		=	'I'
GNTNR_OUT		=	'O'

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

persistent INTEGER nLvl
persistent integer nMteVal


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
define_function parse (CHAR cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,"'GAIN ',itoa(nChan),' ',cIO,' '",1)):
		{
			remove_string(cCompStr,"'GAIN ',itoa(nChan),' ',cIO,' '",1)
			set_length_string(cCompstr,find_string(cCompStr,' A',1)-1)
			if(left_string(cCompStr,1)='-')
			{
				remove_string(cCompStr,'-',1)
				nLvl=((20-atoi(cCompStr))*128/20)
			}
			else
			{
				nLvl=(atoi(cCompStr)*128/20)+128
			}
			send_level vdvTP,1,nLvl
		}
		active(find_string(cCompStr,"'MUTE ',itoa(nChan),' ',cIO,' '",1)):
		{
			remove_string(cCompStr,"'MUTE ',itoa(nChan),' ',cIO,' '",1)
			switch(left_string(cCompStr,1))
			{
				case '1': on[nMteVal]
				case '0': off[nMteVal]
			}
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

DATA_EVENT[dvATC]														// Data Event For Extron Switcher
{
	STRING:
	{
		
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cFullStr[100]
		LOCAL_VAR CHAR cBuff[255]
		STACK_VAR INTEGER nPos	
		
		cBuff = "cBuff,data.text"
		WHILE(LENGTH_STRING(cBuff))
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cBuff,"$0D",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0D",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0D",1)):
				{
					nPos=FIND_STRING(cBuff,"$0D",1)
					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
					parse(cFullStr)
				}
				ACTIVE(1):
				{
					cHold="cHold,cBuff"
					cBuff=''
				}
			}
		}
	}
}

data_event[vdvTP]
{
	online:
	{
		stack_var integer x
		pulse[vdvATC,MIX_QUERY]
	}
}

channel_event[vdvATC, MIX_QUERY]
{
	on:
	{
		send_string dvATC,"'GAIN ',itoa(nChan),' ',cIO,13"
		send_string dvATC,"'MUTE ',itoa(nChan),' ',cIO,13"
	}
}

BUTTON_EVENT [vdvTP, 1]  //Volume Up
{
	PUSH:
	{
		to[button.input]
		send_string dvATC,"'GAIN ',itoa(nChan),' ',cIO,' 1',13"
	}
	hold[3,repeat]:
	{
		send_string dvATC,"'GAIN ',itoa(nChan),' ',cIO,' 1',13"
	}
}

BUTTON_EVENT [vdvTP, 2]  //Volume Down
{
	PUSH:
	{
		to[button.input]
		send_string dvATC,"'GAIN ',itoa(nChan),' ',cIO,' -1',13"
	}
	hold[3,repeat]:
	{
		send_string dvATC,"'GAIN ',itoa(nChan),' ',cIO,' -1',13"
	}
}

BUTTON_EVENT [vdvTP,3]  //Master Volume Mute
{
	push:
	{
		send_string dvATC,"'MUTE ',itoa(nChan),' ',cIO,' 2',13"
	}
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
