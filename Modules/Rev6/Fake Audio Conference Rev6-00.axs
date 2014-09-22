module_name='Fake Audio Conference Rev6-00'(dev dvTP[], dev vdvATC, dev vdvATC_FB, dev dvATC)
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


*)
(***********************************************************)
#include 'HoppSNAPI Rev6-00.axi'
//define_module 'Fake Audio Conference Rev6-00' atc1(dvTP_ATC[1],vdvATC1,vdvATC1_FB,dvATC) 

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

volatile 	char 	cPhoneNum[50]
volatile	char	cInCallNum[50]
volatile	integer	nActiveCallStatus
volatile	integer	nNewDigits

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function show_phone_number(char cNumber[])
{
	if(length_string(cNumber)<=12) send_command dvTP,"'!T',1,cNumber"	
	else if(length_string(cNumber)<=24) send_command dvTP,"'!T',1,left_string(cNumber,12),$0D,$0A,mid_string(cNumber,13,12)"	
	else send_command dvTP,"'!T',1,mid_string(cNumber,length_string(cNumber)-23,12),$0D,$0A,right_string(cNumber,12)"
}

define_function key(char nVal[])
{
	if(nActiveCallStatus)
	{
		send_string dvATC,"'Dial ',nVal"
		
		cancel_wait 'NewDigits'
		if(nNewDigits) cInCallNum="cInCallNum,nVal"
		else cInCallNum=nVal
		show_phone_number(cInCallNum)
		on[nNewDigits]
		wait 50 'NewDigits' off[nNewDigits]
		
	}
	else 
	{
		cPhoneNum = "cPhoneNum,nVal"
		show_phone_number(cPhoneNum)
	}
	update_dial_text()
}

define_function backspace()
{
	if(length_string(cPhoneNum)>0)
	{
		set_length_string(cPhoneNum,length_string(cPhoneNum)-1)
		show_phone_number(cPhoneNum)
	}
	update_dial_text()
}

define_function update_dial_text()
{
	if(length_string(cPhoneNum)>0) send_command dvTP,"'^TXT-',itoa(VTC_DIAL),',0,Dial'"
	else send_command dvTP,"'^TXT-',itoa(ATC_DIAL),',0,Answer'"
	
	switch(nActiveCallStatus)
	{
		case 1: disable_button(dvTP,ATC_DIAL)
		case 0: enable_button(dvTP,ATC_DIAL)
	}
}

define_function enable_button(dev tp[],integer btn)
{
	send_command tp,"'^BMF-',itoa(btn),',0,%OP255%EN1'"
}

define_function disable_button(dev tp[],integer btn)
{
	send_command tp,"'^BMF-',itoa(btn),',0,%OP150%EN0'"
}

define_function tp_fb()
{
	[dvTP,ATC_ON_HOOK]=nActiveCallStatus
	[dvTP,ATC_OFF_HOOK]=!nActiveCallStatus
	
	[vdvATC_FB,ATC_ON_HOOK]=nActiveCallStatus
	[vdvATC_FB,ATC_OFF_HOOK]=!nActiveCallStatus	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvTP]
{
	online:
	{
		update_dial_text()
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
			show_phone_number(cPhoneNum)
			pulse[vdvATC,ATC_DIAL]
		}
	}
}

channel_event[vdvATC,0]
{
	on:	  
	{
		switch(channel.channel)
		{
			case ATC_DIGIT_0:
			case ATC_DIGIT_1:    
			case ATC_DIGIT_2:        
			case ATC_DIGIT_3:        
			case ATC_DIGIT_4:        	
			case ATC_DIGIT_5:        	
			case ATC_DIGIT_6:        	
			case ATC_DIGIT_7:       
			case ATC_DIGIT_8:       	
			case ATC_DIGIT_9:       
			{
				key(itoa(channel.channel-10))
			}
			case ATC_STAR_KEY: 	key('*')
			case ATC_POUND_KEY: key('#')
			case ATC_PAUSE: 	key(',')	
			case ATC_BACKSPACE: backspace()
			case ATC_CLEAR:  		
			{
				cPhoneNum=''	
				show_phone_number(cPhoneNum)
			}
			case ATC_DIAL: 
			{
				on[nActiveCallStatus]
				send_string dvATC,"'Dial ',cPhoneNum"
				update_dial_text()
			}
			case ATC_HANGUP: 
			{
				if(nActiveCallStatus) 
				{
					show_phone_number(cPhoneNum)
					off[nActiveCallStatus]
					send_string dvATC,"'Hang Up'"
				}
				else
				{
					cPhoneNum=''
					show_phone_number(cPhoneNum)
				}
				update_dial_text()
			}
			case ATC_QUERY: 		
			case ATC_FLASH: {}
		}         
	}
}

button_event[dvTP,0]
{
	push:		
	{
		to[button.input]
		on[vdvATC,button.input.channel]
	}
	hold[3,repeat]:
	{
		switch(button.input.channel)
		{
			case ATC_BACKSPACE:
			{
				if(button.holdtime>=500)
				{
					backspace()
				}
			}
		}
	}
	release:
	{
		off[vdvATC,button.input.channel]
	}
}

channel_event[vdvATC_FB,0]
{
	on:
	{
		switch(channel.channel)
		{
			case ATC_ON_HOOK: disable_button(dvTP,ATC_BACKSPACE)
			case ATC_OFF_HOOK: enable_button(dvTP,ATC_BACKSPACE)
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
