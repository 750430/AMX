module_name='QSC DCP-300 Rev6-00'(dev dvTP[], dev vdvQSC, dev vdvQSC_FB, dev dvQSC)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/20/2009  AT: 12:20:49        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//send_command dvQSC,"'SET BAUD 115200,N,8,1,485 DISABLE'"
//define_module 'QSC DCP-300 Rev6-00' vol1(dvTP_DEV[1],vdvDEV1,vdvDEV1_FB,dvQSC)

#include 'HoppSNAPI Rev6-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant

MaxLevel		=	4
MinLevel		=	-60

tlPollLevel		=	3001

integer btnPresets[]	=	{11,12,13,14,15,16,17,18,19,20}
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

float 		nLvlVal
integer 	nAMXLvl
integer 	nMteVal
integer		nActiveLvl
integer		nActivePreset

integer		nVolRate

integer 	x

define_variable //Poll Variables

non_volatile	long		lPollTime[]={30000}

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function parse (char cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,"'dcp300fader='",1)):
		{	
			remove_string(cCompStr,"'dcp300fader='",1)
			
			if(find_string(cCompStr,"$0D",1)>2)
			{
				nLvlVal=atof(left_string(cCompStr,find_string(cCompStr,"$0D",1)-1))
				nAMXLvl= ABS_VALUE((255*(nLvlVal-MinLevel))/(MaxLevel-MinLevel))
				if(right_string(ftoa(nLvlVal),2)='.5') send_command dvTP,"'^TXT-1,0,',ftoa(nLvlVal),' dB'"
				else send_command dvTP,"'^TXT-1,0,',ftoa(nLvlVal),'.0 dB'"
				SEND_LEVEL dvTP,1,nAMXLvl
			}
		}
		active(find_string(cCompStr,"'dcp300mute='",1)):
		{	
			remove_string(cCompStr,"'dcp300mute='",1)
			
			if(find_string(cCompStr,"$0D",1)>1)
			{
				nMteVal=atoi(left_string(cCompStr,1))
			}
		}
		active(find_string(cCompStr,"'dcp300preset='",1)):
		{	
			remove_string(cCompStr,"'dcp300preset='",1)
			
			if(find_string(cCompStr,"$0D",1)>1)
			{
				nActivePreset=atoi(left_string(cCompStr,1))
			}
		}
	}
}

define_function tp_fb()
{
	[dvTP,MIX_MUTE_TOG]=nMteVal
	for(x=1;x<=length_array(btnPresets);x++) [dvTP,btnPresets[x]]=nActivePreset=x
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start


timeline_create(tlPollLevel,lPollTime,1,timeline_relative,timeline_repeat)
#include 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvQSC]
{
	online:
	{
		wait 100 
		{
			send_string dvQSC,"'dcp300fader=',$0D"
			send_string dvQSC,"'dcp300mute=',$0D"
			send_string dvQSC,"'dcp300preset=',$0D"
		}
	}
	string:
	{
		local_var char cHold[100]
		local_var char cFullStr[100]
		local_var char cBuff[255]
		stack_var integer nPos	
		
		cBuff = "cBuff,data.text"
		while(length_string(cBuff))
		{
			select
			{
				active(find_string(cBuff,"$0D,$0A",1)&& length_string(cHold)):
				{
					nPos=find_string(cBuff,"$0A",1)
					cFullStr="cHold,get_buffer_string(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				active(find_string(cBuff,"$0D,$0A",1)):
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


data_event[dvTP]
{
	online:
	{
		send_string dvQSC,"'dcp300fader=',$0D"
	}
}

button_event[dvTP,MIX_VOL_UP]
{
	push:
	{
		to[button.input]
		nLvlVal=.5+nLvlVal
		send_string dvQSC,"'dcp300fader=',ftoa(nLvlVal),$0D"
	}
	hold[2,repeat]:
	{
		if(button.holdtime>4000) nLvlVal=2+nLvlVal
		else if(button.holdtime>2000) nLvlVal=1+nLvlVal
		else nLvlVal=.5+nLvlVal
		
		if(nLvlVal>MaxLevel) nLvlVal=MaxLevel
		
		send_string dvQSC,"'dcp300fader=',ftoa(nLvlVal),$0D"
	}
}

button_event[dvTP,MIX_VOL_DN]
{
	push:
	{
		to[button.input]
		nLvlVal=-.5+nLvlVal
		send_string dvQSC,"'dcp300fader=',ftoa(nLvlVal),$0D"
	}
	hold[2,repeat]:
	{
		if(button.holdtime>4000) nLvlVal=-2+nLvlVal
		else if(button.holdtime>2000) nLvlVal=-1+nLvlVal
		else nLvlVal=-.5+nLvlVal
		
		if(nLvlVal<MinLevel) nLvlVal=MinLevel
		
		send_string dvQSC,"'dcp300fader=',ftoa(nLvlVal),$0D"
	}
}


button_event[dvTP,MIX_MUTE_TOG]
{
	push:
	{
		if(nMteVal) send_string dvQSC,"'dcp300mute=0',$0D"
		else send_string dvQSC,"'dcp300mute=1',$0D"
	}
}

button_event[dvTP,btnPresets]
{
	push:
	{
		send_string dvQSC,"'dcp300preset=',itoa(get_last(btnPresets)),$0D"
	}
}

timeline_event[tlPollLevel]
{
	send_string dvQSC, "'dcp300fader=',$0D"
}

//BUTTON_EVENT [dvTP,MIX_MUTE_TOG]  //Master Volume Mute
//{
//  PUSH:
//  {
//    IF (nMteVal[get_last(dvTP)])
//    {
//      SEND_STRING dvQSC, "itoa(get_last(dvTP)),'*0Z'"
//    }
//    IF (!nMteVal[get_last(dvTP)]) 
//    {
//      SEND_STRING dvQSC, "itoa(get_last(dvTP)),'*1Z'"
//    }
//  }
//} 

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
