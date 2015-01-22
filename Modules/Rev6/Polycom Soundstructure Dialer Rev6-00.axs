module_name='Polycom Soundstructure Dialer Rev6-00'(dev dvTP[], dev vdvATC, dev vdvATC_FB, dev dvATC, char cChannel[])
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

define_module 'Polycom Soundstructure Dialer Rev6-00' atc1(dvTP_ATC[1],vdvATC1,vdvATC1_FB,dvSoundStructure,cPolycomChannel) 

For IP Connections, use port 52774
*)
(***********************************************************)
#include 'HoppSNAPI Rev6-00.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //Default Values
DefaultAddr[]			=	'1'

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable		//Text Window Variables

char 		cPhoneNum[50]
char		cInCallNum[50]
integer		nNewDigits

define_variable		//Active Variables

integer		nActiveCallStatus
integer		nActiveRinging
integer		nCallStateResponseFound

define_variable 	//Strings

char	 	cDialStr[50]
char	 	cRingStr[50]
char	 	cHookStr[50]
char	 	cFlashStr[50]
char	 	cBuff[255]


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function show_phone_number(char cNumber[])
{
	if(length_string(cNumber)<=12) send_command dvTP,"'^TXT-1,0,',cNumber"	
	else if(length_string(cNumber)<=24) send_command dvTP,"'^TXT-1,0,',left_string(cNumber,12),$0D,$0A,mid_string(cNumber,13,12)"	
	else send_command dvTP,"'^TXT-1,0,',mid_string(cNumber,length_string(cNumber)-23,12),$0D,$0A,right_string(cNumber,12)"
}

define_function key(char nVal[])
{
	if(nActiveCallStatus)
	{
		send_string dvATC,"'set phone_dial "',cChannel,'" "',nVal,'"',$0D"
		
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
	if(length_string(cPhoneNum)>0 and !nActiveCallStatus) send_command dvTP,"'^TXT-',itoa(ATC_DIAL),',0,Dial'"
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

define_function parse(char cCompStr[100])
{
	stack_var integer nPos
	if(find_string(cCompStr,"'val phone_connect "',cChannel,'"'",1)) 
	{
		remove_string(cCompStr,"'val phone_connect "',cChannel,'" '",1)
		switch(get_buffer_char(cCompStr))
		{
			case '0': off[nActiveCallStatus]
			case '1': on[nActiveCallStatus]
		}
		update_status_text()
		update_dial_text()
	}		
}

define_function update_status_text()
{
	switch(nActiveCallStatus)
	{
		case '1': send_command dvTP,"'^TXT-2,0,Phone Status: Connected'"
		case '0': send_command dvTP,"'^TXT-2,0,Phone Status: Idle'"
	}
}

define_function init_strings()
{
//	cDialStr ="'DIAL',$20,cAddr,$20,'TIPHONENUM',$20,ITOA(nInstID),$20"
//	cRingStr ="'RING',$20,cAddr,$20,ITOA(nInstID),$0D,$0A"		
//    cHookStr ="'ETD',$20,cAddr,$20,'TIHOOKSTATE',$20,ITOA(nInstID),$20"
//	cFlashStr="'FLASH',$20,cAddr,$20,'TILINE',$20,itoa(nInstID),$0D,$0A"	
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

wait 20 init_strings()

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
	online:
	{
		init_strings()
	}
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

data_event[dvATC]
{
	string:
	{
		local_var char cHold[100]
		local_var char cBuff[255]
		local_var char cFullStr[100]
		stack_var integer nPos
		
		cBuff = "cBuff,data.text"
		while(length_string(cBuff))
		{
			select
			{
				active(find_string(cBuff,"$0D",1)&& length_string(cHold)):
				{
					nPos=find_string(cBuff,"$0D",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				active(find_string(cBuff,"$0D",1)):
				{
					nPos=find_string(cBuff,"$0D",1)
					cFullStr=get_buffer_string(cBuff,nPos)
					parse(cFullStr)
				}
				active(1):
				{
					cHold="cHold,cBuff"
					cBuff=''
				}
			}
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
				if(length_string(cPhoneNum))
				{
					send_string dvATC,"'set phone_connect "',cChannel,'" 1',$0D"
					send_string dvATC,"'set phone_dial "',cChannel,'" "',cPhoneNum,'"',$0D"
					on[nActiveCallStatus]
					wait 20 pulse[vdvATC,ATC_QUERY]
				}
				send_string dvATC,"'set phone_connect "',cChannel,'" 1',$0D"
				
				update_dial_text()
			}
			case ATC_HANGUP: 
			{
				if(nActiveCallStatus) 
				{
					show_phone_number(cPhoneNum)
				}
				else
				{
					cPhoneNum=''
					show_phone_number(cPhoneNum)
				}
				send_string dvATC,"'set phone_connect "',cChannel,'" 0',$0D"	
				off[nActiveCallStatus]
				update_dial_text()
			}
			case ATC_QUERY: send_string dvATC,"'get phone_connect "',cChannel,'"',$0D"
			case ATC_FLASH: send_string dvATC,"'set phone_flash "',cChannel,'"',$0D"
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