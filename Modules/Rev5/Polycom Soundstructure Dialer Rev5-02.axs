MODULE_NAME='Polycom Soundstructure Dialer Rev5-02'(DEV vdvTP, DEV vdvATC, DEV dvATC, char cChannel[])
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/22/2011  AT: 14:08:51        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*----------------MODULE INSTRUCTIONS----------------------*)
(*

SET BAUD 9600,N,8,1 485 DISABLE

define_module 'Polycom Soundstructure Dialer Rev5-02' atc1(vdvTP_ATC1,vdvATC1,dvPolycom,cPolycomChannel) 

For IP Connections, use port 52774
*)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-10.axi'
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

HookTL		=	1
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile	integer	x

VOLATILE CHAR cDialStr[50]
VOLATILE CHAR cRingStr[50]
VOLATILE CHAR cHookStr[50]
VOLATILE CHAR cFlashStr[50]
VOLATILE CHAR cBuff[255]
VOLATILE CHAR cPhoneNum[50]
volatile	char	cInCallNum[50]
volatile	integer	nHook=1
volatile	integer	nNewDigits

volatile		integer		nHookStatus[]={ATC_ON_HOOK,ATC_OFF_HOOK}

non_volatile	long		lHookTime[]={20000}

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

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nPos
	//STACK_VAR INTEGER nHook
	IF(FIND_STRING(cCompStr,"'val phone_connect "',cChannel,'"'",1)) 
	{
		REMOVE_STRING(cCompStr,"'val phone_connect "',cChannel,'" '",1)
		switch(get_buffer_char(cCompStr))
		{
			case '0': on[nHook]
			case '1': off[nHook]
		}
	}	
}

DEFINE_FUNCTION Key(CHAR nVal[1])
{
	IF(nHook)
	{
		cPhoneNum = "cPhoneNum,nVal"
		SEND_COMMAND vdvTP,"'!T',1,cPhoneNum"	
	}
	ELSE 
	{
		cancel_wait 'NewDigits'
		
		if(nNewDigits) cInCallNum="cInCallNum,nVal"
		else cInCallNum=nVal

		SEND_COMMAND vdvTP,"'!T',1,cInCallNum"
		on[nNewDigits]
		wait 50 'NewDigits' off[nNewDigits]
		SEND_STRING dvATC,"'set phone_dial "',cChannel,'" "',nVal,'"',$0D"
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
				SEND_COMMAND vdvTP,"'!T',1,cPhoneNum"	
			}
		}
		CASE ATC_ANSWER: 		SEND_STRING dvATC,"'set phone_connect "',cChannel,'" 1',$0D"
		CASE ATC_HANGUP: 		
		{
			cPhoneNum=''
			SEND_STRING dvATC,"'set phone_connect "',cChannel,'" 0',$0D"	
			SEND_COMMAND vdvTP,"'!T',1,cPhoneNum"	
		}
		CASE ATC_QUERY: 		SEND_STRING dvATC,"'get phone_connect "',cChannel,'"',$0D"
		CASE ATC_FLASH:			SEND_STRING dvATC,"'set phone_flash "',cChannel,'"',$0D"
		CASE ATC_DIAL: 
		{
			SEND_STRING dvATC,"'set phone_connect "',cChannel,'" 1',$0D"
			IF(LENGTH_STRING(cPhoneNum))
			{	
				SEND_STRING dvATC,"'set phone_dial "',cChannel,'" "',cPhoneNum,'"',$0D"
			}
			wait 20 pulse[vdvATC,ATC_QUERY]
		}		
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

timeline_create(HookTL,lHookTime,length_array(lHookTime),timeline_relative,timeline_repeat)


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
				ACTIVE(FIND_STRING(cBuff,"$0D",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0D",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0D",1)):
				{
					nPos=FIND_STRING(cBuff,"$0D",1)
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
		OnPush(channel.channel)
	}
}
BUTTON_EVENT [vdvTP,0]
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

timeline_event[HookTL]
{
	pulse[vdvATC,ATC_QUERY]
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[vdvTP,ATC_ON_HOOK]=nHook
[vdvTP,ATC_OFF_HOOK]=!nHook

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
