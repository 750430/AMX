MODULE_NAME='Extron SW Standard Switcher Rev5-00'(DEV vdvTP[], DEV vdvDevice, DEV dvSwitcher)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/20/2008  AT: 16:42:25        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
define_module 'Extron Switcher Rev5-00' sw1(dvTP_DEV[1],vdvDEV1,dvSwitcher)
SEND_COMMAND data.device,"'SET BAUD 9600,N,8,1'"

*)

#INCLUDE 'HoppSNAPI Rev5-09.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

integer	btnInputs[]		=	{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}

integer btnAudio		=	201
integer btnVideo		=	202

FeedbackTL		=	3000
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile		integer		nActiveInput
volatile		integer		nActiveOutput[48]
volatile		integer		nAudioSelect
volatile		integer		nVideoSelect

persistent		integer		nAudioStatus
persistent		integer		nVideoStatus


volatile		long		lFeedbackTime[]={100}

volatile		integer		x
volatile		integer		nBlink
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
	[vdvTP,btnAudio]=nAudioSelect
	[vdvTP,btnVideo]=nVideoSelect
	select
	{
		active(nVideoStatus=nAudioStatus):
		{
			for(x=1;x<=length_array(btnInputs);x++) [vdvTP,btnInputs[x]]=nVideoStatus=x
		}
		active(nVideoStatus<>nAudioStatus):
		{
			for(x=1;x<=length_array(btnInputs);x++)
			{
				if(x=nVideoStatus) on[vdvTP,btnInputs[x]]
				else if(x=nAudioStatus) [vdvTP,btnInputs[x]]=nBlink
				else off[vdvTP,btnInputs[x]]
			}
		}
	}
}

define_function parse(char cResponse[30])
{
	select
	{
		active(find_string(cResponse,'Vid',1)):
		{
			remove_string(cResponse,'In',1)
			nVideoStatus=atoi(left_string(cResponse,find_string(cResponse,' ',1)-1))
		}
		active(find_string(cResponse,'Aud',1)):
		{
			remove_string(cResponse,'In',1)
			nAudioStatus=atoi(left_string(cResponse,find_string(cResponse,' ',1)-1))
		}
		active(find_string(cResponse,'All',1)):
		{
			remove_string(cResponse,'In',1)
			nVideoStatus=atoi(left_string(cResponse,find_string(cResponse,' ',1)-1))
			nAudioStatus=nVideoStatus
		}
	}
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

DATA_EVENT[dvSwitcher]
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
				ACTIVE(FIND_STRING(cBuff,"$0A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0A",1)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
					Parse(cFullStr)
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

button_event[vdvTP,btnInputs]
{
	push:
	{
		select
		{
			active(nAudioSelect and !nVideoSelect): send_string dvSwitcher,"itoa(get_last(btnInputs)),'$'"
			active(!nAudioSelect and nVideoSelect): send_string dvSwitcher,"itoa(get_last(btnInputs)),'&'"
			active(nAudioSelect and nVideoSelect): send_string dvSwitcher,"itoa(get_last(btnInputs)),'!'"
			active(!nAudioSelect and !nVideoSelect): send_command button.input.device,"'ABEEP'"
		}
	}
}

button_event[vdvTP,btnAudio]
{
	push:
	{
		nAudioSelect=!nAudioSelect
	}
}

button_event[vdvTP,btnVideo]
{
	push:
	{
		nVideoSelect=!nVideoSelect
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

wait 5 nBlink=!nBlink

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
