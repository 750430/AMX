MODULE_NAME='Biamp Tesira Dialer Rev5-00'(DEV vdvTP, DEV vdvATC, DEV dvATC, char cDialTag[], char cStatusTag[])
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/22/2008  AT: 17:16:10        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:   5-03 Adds Speed Dial                     *)
(***********************************************************)
(*----------------MODULE INSTRUCTIONS----------------------*)
(*

SET BAUD 115200,N,8,1 485 DISABLE

define_variable //ATC Variables
non_volatile	char cDialTag[] 		= 'Dialer1'
non_volatile	char cStatusTag[] 		= 'TIControlStatus1'

define_module 'Biamp Tesira Dialer Rev5-00' atc1(vdvTP_ATC1,vdvATC1,dvBiamp,cDialTag,cStatusTag) 


*)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-11.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

//default values
CHAR DefaultAddr[] 	= '1'


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE CHAR cDialStr[50]
VOLATILE CHAR cRingStr[50]
VOLATILE CHAR cHookStr[50]
VOLATILE CHAR cFlashStr[50]
VOLATILE CHAR cBuff[255]
VOLATILE CHAR cPhoneNum[50]
volatile	char	cInCallNum[50]
volatile	integer	nHook=1
volatile	integer	nNewDigits
volatile		integer	nCallStateResponseFound


VOLATILE INTEGER nATCBtn[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,
														20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,
														36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51}

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
//([dvATC,ATC_ON_HOOK],[dvATC,ATC_OFF_HOOK])
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function subscribe()
{
	send_string dvATC,"cStatusTag,$20,'subscribe',$20,'callState',$20,cStatusTag,$20,'10',$0A"
}

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nPos
	stack_var char cText[50]
	//STACK_VAR INTEGER nHook
	select
	{
		active(find_string(cCompStr,"'Welcome to the Tesira Text Protocol Server'",1)):
		{
			subscribe()
		}
		active(nCallStateResponseFound):
		{
			remove_string(cCompStr,"'+OK "value":{"callStateInfo":[{"state":'",1)
			nPos=FIND_STRING(cCompStr,"$20",1)
			parse_hook_status(left_string(cCompStr,nPos-1))
			off[nCallStateResponseFound]
		}
		active(1):
		{
			off[nCallStateResponseFound]
			select
			{
				active(find_string(cCompStr,"'"publishToken":"',cStatusTag,'" "value":{"callStateInfo":[{"state":'",1)):
				{
					remove_string(cCompStr,"'"publishToken":"',cStatusTag,'" "value":{"callStateInfo":[{"state":'",1)
					nPos=FIND_STRING(cCompStr,"$20",1)
					parse_hook_status(left_string(cCompStr,nPos-1))
					
				}
				active(find_string(cCompStr,"cStatusTag,$20,'get callState'",1)):
				{
					on[nCallStateResponseFound]
				}
			}
		}
	}
}

define_function parse_hook_status(cStatus[50])
{
	switch(cStatus)
	{
		case 'TI_CALL_STATE_IDLE': 				
		{
			send_command vdvTP,"'^TXT-2,0,Phone Status: Idle'"
			on[nHook]
		}
		case 'TI_CALL_STATE_DIALING':			
		{
			send_command vdvTP,"'^TXT-2,0,Phone Status: Dialing'"
			off[nHook]
		}
		case 'TI_CALL_STATE_RINGBACK':			send_command vdvTP,"'^TXT-2,0,Phone Status: Ringing'"
		case 'TI_CALL_STATE_BUSY_TONE':			send_command vdvTP,"'^TXT-2,0,Phone Status: Busy'"
		case 'TI_CALL_STATE_ERROR_TONE':		send_command vdvTP,"'^TXT-2,0,Phone Status: Error'"
		case 'TI_CALL_STATE_CONNECTED':			
		{
			send_command vdvTP,"'^TXT-2,0,Phone Status: Connected'"
			off[nHook]
		}
		case 'TI_CALL_STATE_DROPPED':			send_command vdvTP,"'^TXT-2,0,Phone Status: Dropped'"
		case 'TI_CALL_STATE_INIT':				send_command vdvTP,"'^TXT-2,0,Phone Status: Initializing'"
		case 'TI_CALL_STATE_FAULT':				send_command vdvTP,"'^TXT-2,0,Phone Status: Fault'"
		case 'TI_CALL_STATE_CONNECTION_MUTED':	send_command vdvTP,"'^TXT-2,0,Phone Status: Connection Muted'"
	}
}

define_function show_phone_number(char cNumber[])
{
	if(length_string(cNumber)<=12) SEND_COMMAND vdvTP,"'!T',1,cNumber"	
	else if(length_string(cNumber)<24) SEND_COMMAND vdvTP,"'!T',1,left_string(cNumber,12),$0D,$0A,mid_string(cNumber,13,12)"	
	else SEND_COMMAND vdvTP,"'!T',1,mid_string(cNumber,length_string(cNumber)-23,12),$0D,$0A,right_string(cNumber,12)"
}

DEFINE_FUNCTION Key(CHAR nVal[1])
{
	IF(nHook)
	{
		cPhoneNum = "cPhoneNum,nVal"
		show_phone_number(cPhoneNum)
		
		
	}
	ELSE 
	{
		cancel_wait 'NewDigits'
		
		if(nNewDigits) cInCallNum="cInCallNum,nVal"
		else cInCallNum=nVal

		show_phone_number(cInCallNum)
		on[nNewDigits]
		wait 50 'NewDigits' off[nNewDigits]
		send_string dvATC,"cDialTag,' dtmf 1 ',nVal,$0A"
	}
}
DEFINE_FUNCTION OnPush(INTEGER nCmd)
{
	SWITCH(nCmd)
	{
		CASE ATC_DIGIT_0:
		CASE ATC_DIGIT_1:    
		CASE ATC_DIGIT_2:        
		CASE ATC_DIGIT_3:        
		CASE ATC_DIGIT_4:        	
		CASE ATC_DIGIT_5:        	
		CASE ATC_DIGIT_6:        	
		CASE ATC_DIGIT_7:       
		CASE ATC_DIGIT_8:       	
		CASE ATC_DIGIT_9:       
		{
			Key(ITOA(nCmd-10))
		}
		CASE ATC_STAR_KEY: 	Key('*')
		CASE ATC_POUND_KEY: Key('#')
		CASE ATC_PAUSE: 		Key(',')					
		CASE ATC_CLEAR:  		
		{
			cPhoneNum=''	
			SEND_COMMAND vdvTP,"'!T',1,cPhoneNum"	
		}
		CASE ATC_BACKSPACE: 
		{
			if (nHook)
			{
				cPhoneNum=LEFT_STRING(cPhoneNum,(LENGTH_STRING(cPhoneNum)-1))
				show_phone_number(cPhoneNum)
			}
		}
		CASE ATC_ANSWER: 		SEND_STRING dvATC,"cDialTag,' answer 1 1',$0A"
		CASE ATC_HANGUP: 		
		{
			cPhoneNum=''
			SEND_STRING dvATC,"cDialTag,' end 1 1',$0A"
			show_phone_number(cPhoneNum)
			wait 10 pulse[vdvATC,ATC_QUERY]
		}
		CASE ATC_QUERY: 		send_string dvATC,"cStatusTag,' get callState',$0A"
		CASE ATC_FLASH:			SEND_STRING dvATC,"cDialTag,' flash 1 1',$0A"
		CASE ATC_DIAL: 
		{
			IF(LENGTH_STRING(cPhoneNum))
			{	
				dial(cPhoneNum)
				wait 20
				pulse[vdvATC,ATC_QUERY]
			}
			ELSE SEND_STRING dvATC,"cDialTag,' offhook 1 1',$0A"
		}		
	}                   
}

define_function dial(char cDialNum[20])
{
	send_string dvATC,"cDialTag,' dial 1 1 "',cDialNum,'"',$0A"
}

DEFINE_CALL 'INIT_STRINGS'
{
//	IF(!LENGTH_STRING(cAddr)) cAddr=DefaultAddr
//	cRingStr ="'RING',$20,cAddr,$20,ITOA(nInstID),$0D,$0A"		
//    cHookStr ="'ETD',$20,cAddr,$20,'TIHOOKSTATE',$20,ITOA(nInstID),$20"
//	cFlashStr="'FLASH',$20,cAddr,$20,'TILINE',$20,itoa(nInstID),$0D,$0A"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

WAIT 20	subscribe()


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT



DATA_EVENT[dvATC]
{
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cBuff[255]
		LOCAL_VAR CHAR cFullStr[100]
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

data_event[vdvATC]
{
	command:
	{
		if(find_string(data.text,"'DIAL '",1))
		{
			remove_string(data.text,"'DIAL '",1)
			cPhoneNum=data.text
			pulse[vdvATC,ATC_DIAL]
		}
	}
}

CHANNEL_EVENT[vdvATC,0]
{
	ON:	  
	{
		IF(channel.channel<200) OnPush(channel.channel)
	}
}
BUTTON_EVENT [vdvTP,nATCBtn]
{
	PUSH:		
	{
		TO[button.input.device,button.input.channel]
		on[vdvATC,button.input.channel]
	}
	release:
	{
		off[vdvATC,button.input.channel]
	}
}

button_event[vdvTP,ATC_BACKSPACE]
{
	hold[3,repeat]:
	{
		set_pulse_time(1)
		pulse[vdvATC,button.input.channel]
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[vdvTP,ATC_ON_HOOK]=nHook
[vdvTP,ATC_OFF_HOOK]=!nHook
[dvATC,ATC_ON_HOOK]=nHook
[dvATC,ATC_OFF_HOOK]=!nHook

if (time_to_second(TIME) == 0)
{
	if(time_to_hour(time)=23 and time_to_minute(time)=1)
	{
		subscribe()
	}
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
