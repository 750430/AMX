MODULE_NAME='Biamp Dialer Rev5-04'(DEV vdvTP, DEV vdvATC, DEV dvATC, CHAR cAddr, char cInstIDTag)
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

SET BAUD 38400,N,8,1 485 DISABLE

define_variable //ATC Variables
non_volatile	char	cAddr 		= '1'
non_volatile	char	cInstIDtag 	= dlrMain

define_module 'Biamp Dialer Rev5-04' atc1(vdvTP_ATC1,vdvATC1,dvBiamp,cAddr,cInstIDTag) 


If you want Speed Dial to work, you have to add the following to the TP data event in the mainline.
There is no way to have a keyboard send string directly to a module, so it comes to your main code,
and then you have to send it to the module for the module to get it.

data_event[dvTP]
{
	string:
	{
		send_string vdvATC1,"data.text"
	}
}

*)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-09.axi'
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

tlHook		=	1
tlSpeedDial	=	2

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

structure speeddial
{
	char name[50]
	char number[50]
}

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

persistent	speeddial spdMain[8]


non_volatile	long		lHookTime[]={5000,5000,500,500}
non_volatile	long		lSpeedDialTime[]={100,100,100,100,100,100,100,100}

VOLATILE INTEGER nATCBtn[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,
														20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,
														36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51}


integer nSetSpeedDialNumber
integer nSetSpeedDialName
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

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nPos
	stack_var char cText[50]
	//STACK_VAR INTEGER nHook
	if(find_string(cCompStr,"'TISDLABEL ',cInstIDTag,' '",1))
	{
		remove_string(cCompStr,"'TISDLABEL ',cInstIDTag,' '",1)
		nPos=atoi(left_string(cCompStr,find_string(cCompStr,' ',1)-1))
		remove_string(cCompStr,' ',1)
		cText=left_string(cCompStr,find_string(cCompStr,"$0D",1)-1)
		spdMain[nPos].name=cText
		if(spdMain[nPos].name=itoa(nPos)) {}
		else send_command vdvTP,"'^TXT-',itoa(ATC_SPEEDDIAL[nPos]),',0,',spdMain[nPos].name"
	}
	if(find_string(cCompStr,"'TISDENTRY ',cInstIDTag,' '",1))
	{
		remove_string(cCompStr,"'TISDENTRY ',cInstIDTag,' '",1)
		nPos=atoi(left_string(cCompStr,find_string(cCompStr,' ',1)-1))
		remove_string(cCompStr,' ',1)
		cText=left_string(cCompStr,find_string(cCompStr,"$0D",1)-1)
		spdMain[nPos].number=cText
		if(spdMain[nPos].number=itoa(nPos)) {}
		else send_command vdvTP,"'^TXT-',itoa(ATC_SPEEDDIALNUM[nPos]),',0,',spdMain[nPos].number"
	}	
	IF(FIND_STRING(cCompStr,'RING',1) || FIND_STRING(cCompStr,'TIHOOKSTATE',1))
	{
		SELECT
		{
			ACTIVE(FIND_STRING(cCompStr,cRingStr,1)):
			{
				ON[vdvTP,ATC_RINGING]
				SEND_COMMAND vdvTP,"'ADBEEP'"
				WAIT 50 OFF[vdvTP,ATC_RINGING]
			}
			ACTIVE(FIND_STRING(cCompStr,cHookStr,1)):
			{
				REMOVE_STRING(cCompStr,cHookStr,1)
				nPos=FIND_STRING(cCompStr,"$20",1)
				
				switch(GET_BUFFER_STRING(cCompStr,nPos-1))
				{
					case '1': 
					{
						on[nHook]
						on[dvATC,ATC_ON_HOOK]
						off[dvATC,ATC_OFF_HOOK]
						on[vdvTP,ATC_ON_HOOK]
						off[vdvTP,ATC_OFF_HOOK]
					}
					case '0': 
					{
						off[nHook]
						off[dvATC,ATC_ON_HOOK]
						on[dvATC,ATC_OFF_HOOK]
						on[vdvTP,ATC_OFF_HOOK]
						off[vdvTP,ATC_ON_HOOK]
					}
				}
				//[dvATC,ATC_ON_HOOK]=nHook
				//[dvATC,ATC_OFF_HOOK]=!nHook	
				//if(nHook) off[vdvTP,ATC_ON_HOOK_F]
//				else on[vdvTP,ATC_ON_HOOK_FB]
			}
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
		SEND_STRING dvATC,"cDialStr,nVal,$0A"
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
		CASE ATC_ANSWER: 		SEND_STRING dvATC,"'S',cHookStr,'0',$0A"
		CASE ATC_HANGUP: 		
		{
			cPhoneNum=''
			SEND_STRING dvATC,"'S',cHookStr,'1',$0A"	
			SEND_COMMAND vdvTP,"'!T',1,cPhoneNum"	
		}
		CASE ATC_QUERY: 		SEND_STRING dvATC,"'G',cHookStr,$0A"
		CASE ATC_FLASH:			send_string dvATC,"cFlashStr"
		CASE ATC_DIAL: 
		{
			IF(LENGTH_STRING(cPhoneNum))
			{	
				SEND_STRING dvATC,"cDialStr,cPhoneNum,$0A"
				wait 20
				pulse[vdvATC,ATC_QUERY]
			}
			ELSE SEND_STRING dvATC,"'S',cHookStr,'0',$0A"
		}		
		CASE ATC_SPEEDDIAL_QUERY: get_speeddial()
	}                   
}

DEFINE_CALL 'INIT_STRINGS'
{
	IF(!LENGTH_STRING(cAddr)) cAddr=DefaultAddr
	cDialStr ="'DIAL',$20,cAddr,$20,'TIPHONENUM',$20,cInstIDTag,$20"
	cRingStr ="'RING',$20,cAddr,$20,cInstIDTag,$0D,$0A"		
    cHookStr ="'ETD',$20,cAddr,$20,'TIHOOKSTATE',$20,cInstIDTag,$20"
	cFlashStr="'FLASH',$20,cAddr,$20,'TILINE',$20,cInstIDTag,$0D,$0A"
	get_speeddial()
}

define_function get_speeddial()
{
	timeline_create(tlSpeedDial,lSpeedDialTime,length_array(lSpeedDialTime),timeline_relative,timeline_once)
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

timeline_create(tlHook,lHookTime,length_array(lHookTime),timeline_relative,timeline_repeat)
WAIT 20	CALL 'INIT_STRINGS'


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
data_event[vdvATC]
{
	string:
	{
		stack_var cTPResponse[65]
		cTPResponse=data.text
		if (left_string(cTPResponse,10)='KEYP-ABORT' or left_string(cTPResponse,10)='KEYB-ABORT')
		{
			//ignore, the user aborted the process
		}
		else if (left_string(cTPResponse,5)='KEYP-')
		{
			//do nothing
		}
		else if (left_string(cTPResponse,5)='KEYB-')
		{
			if(nSetSpeedDialNumber)
			{
				remove_string(cTPResponse,'KEYB-',1) //Remove the Prefix
				if (length_string(cTPResponse)>30)	//Max length on the number is 10 characters
				{
					set_length_string(cTPResponse,30)
				}
				spdMain[nSetSpeedDialNumber].number=cTPResponse
				send_string dvATC,"'SETD ',cAddr,' TISDENTRY ',cInstIDTag,' ',itoa(nSetSpeedDialNumber),' ',spdMain[nSetSpeedDialNumber].number,$0A"
				nSetSpeedDialName=nSetSpeedDialNumber
				off[nSetSpeedDialNumber]
				send_command vdvTP,"'@AKB-',spdMain[nSetSpeedDialName].name,';Input Speed Dial Name'" //Pop up the keypad so the user can input a speed dial number				
			}
			else if (nSetSpeedDialName)
			{
				remove_string(cTPResponse,'KEYB-',1)	//Remove the Prefix
				if (length_string(cTPResponse)>30)	//Max length on the name is 30 characters
				{
					set_length_string(cTPResponse,30)
				}
				spdMain[nSetSpeedDialName].name=cTPResponse
				send_string dvATC,"'SETD ',cAddr,' TISDLABEL ',cInstIDTag,' ',itoa(nSetSpeedDialName),' ',spdMain[nSetSpeedDialName].name,$0A"
				off[nSetSpeedDialName]
				get_speeddial()
			}
		}
	}
}


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

button_event [vdvTP,ATC_SPEEDDIAL]
{
	push:
	{
		to[button.input]
	}
	hold[20]:
	{
		nSetSpeedDialNumber=get_last(ATC_SPEEDDIAL)
		send_command vdvTP,"'@AKB-',spdMain[nSetSpeedDialNumber].number,';Input Speed Dial Number'" //Pop up the keypad so the user can input a speed dial number
	}
	release:
	{
		if(!nSetSpeedDialNumber)
		{
			send_string dvATC,"'DIAL ',cAddr,' TISPEEDDIAL ',cInstIDTag,' ',itoa(get_last(ATC_SPEEDDIAL)),$0A"
		}
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

timeline_event[tlHook]
{
	switch(timeline.sequence)
	{
		case 1: pulse[vdvATC,ATC_QUERY]
		default: if ([dvATC,ATC_OFF_HOOK]) pulse[vdvATC,ATC_QUERY]
	}
}

timeline_event[tlSpeedDial]
{
	send_string dvATC,"'GETD ',cAddr,' TISDLABEL ',cInstIDTag,' ',itoa(timeline.sequence),$0A"
	send_string dvATC,"'GETD ',cAddr,' TISDENTRY ',cInstIDTag,' ',itoa(timeline.sequence),$0A"
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

//[vdvTP,ATC_ON_HOOK]=[dvATC,ATC_ON_HOOK]
//[vdvTP,ATC_OFF_HOOK]=[dvATC,ATC_ON_HOOK]

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
