module_name='ClearOne ATC Rev5-01'(dev dvTP, dev vdvATC, dev dvXAP, char cAddr[])
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/19/2008  AT: 14:28:36        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
//non_volatile	char		cClearOneAddr[]='30'
//define_module 'ClearOne ATC Rev5-01' atc1(vdvTP_ATC1,vdvATC1,dvClearOne,cClearOneAddr)
//SET BAUD 9600,N,8,1

#include 'HoppSNAPI Rev5-11.axi'

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

non_volatile	char		cPhoneNum[21]

non_volatile	integer		nHook=0
non_volatile	char		xap_buff[255]

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

define_function parse(char cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,"'#',cAddr,' TE 1 1'",1)):
		{
			nHook = 1
		}
		active(find_string(cCompStr,"'#',cAddr,' TE 1 0'",1)):
		{
			nHook = 0
		}
	}
}

define_function key(char c[])
{
	if(!nHook) cPhoneNum="cPhoneNum,c"
	else send_string dvXAP,"'#',cAddr,' DIAL 1 ',c,$0D"
}

define_function show_phone_number(char cNumber[])
{
	if(length_string(cNumber)<12) SEND_COMMAND dvTP,"'!T',1,cNumber"	
	else if(length_string(cNumber)<24) SEND_COMMAND dvTP,"'!T',1,left_string(cNumber,12),$0D,$0A,mid_string(cNumber,13,12)"	
	else SEND_COMMAND dvTP,"'!T',1,mid_string(cNumber,length_string(cNumber)-23,12),$0D,$0A,right_string(cNumber,12)"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

create_buffer dvXAP, xap_buff
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event [dvXAP] 
{ 
	string:
	{
		local_var char cHold[100]
		local_var char cFullStr[100]
		stack_var integer nPos	
		//this accounts for multiple strings in XAP_Buff
		//or receiving partial string(s) 
		while(length_string(XAP_Buff))
		{
			select
			{
				active(find_string(XAP_Buff,"$0A",1)&& length_string(cHold)):
				{
					nPos=find_string(XAP_Buff,"$0A",1)
					cFullStr="cHold,get_buffer_string(XAP_Buff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				active(find_string(XAP_Buff,"$0A",1)):
				{
					nPos=find_string(XAP_Buff,"$0A",1)
					cFullStr=get_buffer_string(XAP_Buff,nPos)
					parse(cFullStr)
				}
				active(1):
				{
					cHold="cHold,XAP_Buff"
					XAP_Buff=''
				}
			}
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
	release:
	{
		off[vdvATC,button.input.channel]
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
			case ATC_STAR_KEY: key('*')
			case ATC_POUND_KEY: key('#')
			case ATC_PAUSE: key(',')
			case ATC_CLEAR:
			{
				cPhoneNum=''
			}
			case ATC_BACKSPACE:
			{
				cPhoneNum=left_string(cPhoneNum,(length_string(cPhoneNum)-1))
			}
			case ATC_ANSWER: 
			{
				cPhoneNum=''
				send_string dvXAP,"'#',cAddr,' TE 1 1',$0D"
			}
			case ATC_HANGUP: 
			{
				send_string dvXAP,"'#',cAddr,' TE 1 0',$0D"
				cPhoneNum=''
				show_phone_number(cPhoneNum)
			}
			case ATC_FLASH: send_string dvXAP,"'#',cAddr,' HOOK 1',$0D"
			case ATC_QUERY: send_string dvXAP,"'#',cAddr,' TE 1',$0D"
			case ATC_DIAL:
			{
				switch([vdvATC,ATC_OFF_HOOK])
				{
					case 0:
					{
						if(length_string(cPhoneNum) and !nHook)
						{
							send_string dvXAP,"'#',cAddr,' DIAL 1 ',cPhoneNum,$0D"
						}
						else
						{
							send_string dvXAP,"'#',cAddr,' TE 1 1',$0D"
						}
					}
				}
				wait 20
				pulse[vdvATC,ATC_QUERY]
			}
		}
		show_phone_number(cPhoneNum)
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvTP, ATC_OFF_HOOK] = nHOOK
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
