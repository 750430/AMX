module_name='Gentner GT1524 Rev4-00'(dev dvTP, dev vdvATC, dev dvATC)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/19/2008  AT: 14:28:36        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//define_module 'Gentner GT1524 Rev4-00' atc1(vdvTP_ATC1,vdvATC1,dvATC)
//SET BAUD 9600,N,8,1

#include 'HoppSNAPI Rev4-01.axi'

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

non_volatile	char		cPhoneNum[21]

non_volatile	integer		nHook=0
non_volatile	char		cBuff[255]

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

define_function parse(char cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,"'TE 1'",1)):
		{
			nHook = 1
		}
		active(find_string(cCompStr,"'TE 0'",1)):
		{
			nHook = 0
		}
	}
}

define_function key(char c[])
{
	if(!nHook) cPhoneNum="cPhoneNum,c"
	else send_string dvATC,"'DIAL ',c,$0D"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

create_buffer dvATC, cBuff
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event [dvATC] 
{ 
	string:
	{
		local_var char cHold[100]
		local_var char cFullStr[100]
		stack_var integer nPos	
		//this accounts for multiple strings in cBuff
		//or receiving partial string(s) 
		while(length_string(cBuff))
		{
			select
			{
				active(find_string(cBuff,"$0D",1)&& length_string(cHold)):
				{
					nPos=find_string(cBuff,"$0D",1)
					cFullStr="cHold,get_buffer_string(cBuff,nPos)"
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

button_event[dvTP,0]							
{
	push:
	{
		to[button.input]
		pulse[vdvATC,button.input.channel]
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
				send_string dvATC,"'TE 1',$0D"
			}
			case ATC_HANGUP: 
			{
				send_string dvATC,"'TE 0',$0D"
				cPhoneNum=''
				send_command dvTP,"'^TXT-1,',cPhoneNum"
			}
			case ATC_FLASH: send_string dvATC,"'HOOK',$0D"
			case ATC_QUERY: send_string dvATC,"'TE',$0D"
			case ATC_DIAL:
			{
				switch([vdvATC,ATC_OFF_HOOK_FB])
				{
					case 0:
					{
						if(length_string(cPhoneNum) and !nHook)
						{
							send_string dvATC,"'DIAL ',cPhoneNum,$0D"
						}
						else
						{
							send_string dvATC,"'TE 1',$0D"
						}
					}
				}
				wait 20
				pulse[vdvATC,ATC_QUERY]
			}
		}
		send_command dvTP,"'^TXT-1,0,',cPhoneNum"
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvTP, 251] = nHOOK
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
