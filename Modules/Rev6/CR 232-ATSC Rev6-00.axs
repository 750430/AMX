module_name='CR 232-ATSC Rev6-00'(dev dvTP[], dev vdvDevice, dev vdvDevice_FB, dev dvDevice)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/13/2008  AT: 09:29:16        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  		                                       *)
(*----------------MODULE INSTRUCTIONS----------------------*)
(*

	define_module 'CR 232-ATSC Rev6-00' dev1(dvTP_DEV[1],vdvDEV1,vdvDEV1_FB,dvDevice)
	send_command data.device, 'SET BAUD 9600,N,8,1'
*)
(***********************************************************)

#include 'HoppSNAPI Rev6-00.axi'
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

char 	cBuff[255]
integer nCaption
integer	nPower		
char	cChan[10]

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
define_function tp_fb()
{
	[vdvDevice_FB,TUNER_PWR_ON]=nPower
	[vdvDevice_FB,TUNER_PWR_OFF]=!nPower
	
	[dvTP,TUNER_PWR_ON]=nPower
	[dvTP,TUNER_PWR_OFF]=!nPower
}

define_function parse(char cCompStr[100])
{
	stack_var integer nPos
	stack_var char cMajor[3]
	stack_var char cJunk[5]
	stack_var char cMinor[3]
	
	select
	{
		active(find_string(cCompStr,'<1TU',1)):
		{
			remove_string(cCompStr,'<1TU',1)
			cMajor=left_string(cCompStr,3)
			remove_string(cCompStr,cMajor,1)
			cJunk=left_string(cCompStr,4)
			remove_string(cCompStr,cJunk,1)
			cMinor=left_string(cCompStr,3)
			send_command dvTP,"'^TXT-1,1&2,',itoa(atoi(cMajor)),'-',itoa(atoi(cMinor))"
			on[nPower]
		}	
		active(find_string(cCompStr,'<1TM',1)): off[nPower]
		active(find_string(cCompStr,'<1Q01',1)): nCaption=0
		active(find_string(cCompStr,'<1Q11',1)): nCaption=1
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

#include 'HoppFB Rev6-00.axi'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvDevice] 
{ 
	string:
	{
		local_var char 		cHold[100]
		local_var char 		cFullStr[100]
		stack_var integer	nPos	
	
		cBuff = "cBuff,data.text"
		while(length_string(cBuff))
		{
			select
			{
				active(find_string(cBuff,"$0A",1)&& length_string(cHold)):
				{
					nPos=find_string(cBuff,"$0A",1)
					cFullStr="cHold,get_buffer_string(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				active(find_string(cBuff,"$0A",1)):
				{
					nPos=find_string(cBuff,"$0A",1)
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

data_event[vdvDevice]
{
	command:
	{
		if(find_string(data.text,"'CHAN '",1))
		{
			remove_string(data.text,"'CHAN '",1)
			cChan=data.text
			pulse[vdvDevice,TUNER_ENTER]
		}
	}
}

channel_event[vdvDevice,0]
{
	on:	
	{
		switch(channel.channel)
		{
			case TUNER_DIGIT_0:	 
			case TUNER_DIGIT_1:	
			case TUNER_DIGIT_2:	
			case TUNER_DIGIT_3:	
			case TUNER_DIGIT_4:	
			case TUNER_DIGIT_5:	
			case TUNER_DIGIT_6:	
			case TUNER_DIGIT_7:	
			case TUNER_DIGIT_8:	
			case TUNER_DIGIT_9:
			{
				cChan = "cChan,itoa(channel.channel-TUNER_DIGIT_0)"
				send_command dvTP,"'^TXT-1,1&2,',cChan"
			}
			case TUNER_DASH: 				
			{
				cChan="cChan,'-'"
				send_command dvTP,"'^TXT-1,1&2,',cChan"
			}
			case TUNER_CLEAR: 			
			{
				cChan	= ''
				send_command dvTP,"'^TXT-1,1&2,',cChan"
			}
			case TUNER_BACK: 				
			{
				cChan = left_string(cChan,(length_string(cChan)-1))
				send_command dvTP,"'^TXT-1,1&2,',cChan"
			}
			case TUNER_CHAN_UP:			send_string dvDevice,"'>1TU',$0D"
			case TUNER_CHAN_DN:			send_string dvDevice,"'>1TD',$0D"		
			case TUNER_QUERY: 			send_string dvDevice,"'>1ST',$0D"
			case TUNER_PWR_ON:			send_string dvDevice,"'>1P1',$0D"
			case TUNER_PWR_OFF:			send_string dvDevice,"'>1P0',$0D"
			case TUNER_CAPTION_ON: 		send_string dvDevice,"'>1Q0=1',$0D"
			case TUNER_CAPTION_OFF:		send_string dvDevice,"'>1Q0=0',$0D"
			case TUNER_MENU:        	send_string dvDevice,"'>1KK=105',$0D"
			case TUNER_UP:				send_string dvDevice,"'>1KK=108',$0D"
			case TUNER_DN:				send_string dvDevice,"'>1KK=109',$0D"
			case TUNER_LEFT:			send_string dvDevice,"'>1KK=107',$0D"
			case TUNER_OK:				send_string dvDevice,"'>1KK=110',$0D"
			case TUNER_EXIT:        	send_string dvDevice,"'>1KK=111',$0D"
			case TUNER_GUIDE:			send_string dvDevice,"'>1KK=62',$0D"
			case TUNER_RIGHT:			send_string dvDevice,"'>1KK=106',$0D"
			case TUNER_RATIO:			send_string dvDevice,"'>1KK=82',$0D"
			case TUNER_CAPTION_TOG:		send_string dvDevice,"'>1Q0=',itoa(!nCaption),$0D"
			case TUNER_ENTER: 
			{
				while(find_string(cChan,'-',1))
				{
					cChan="left_string(cChan,find_string(cChan,'-',1)-1),':',right_string(cChan,length_string(cChan)-find_string(cChan,'-',1))"
				}
				send_string dvDevice,"'>1TC=',cChan,$0D"
				cChan=''
			}	
		}
	}
}

button_event [dvTP,0]
{
	push:	
	{
		to[button.input.device,button.input.channel]
		pulse[vdvDevice,button.input.channel]
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

