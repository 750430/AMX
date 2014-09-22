module_name='Fake Projector Rev6-01'(dev dvTP[], dev vdvProj, dev vdvProj_FB, dev dvProj)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   

	define_module 'Fake Projector Rev6-01' disp1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvProj1)
*)

#include 'HoppSNAPI Rev6-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //Timelines

tlLamp		=	2001
tlPoll		=	2002

define_constant //Polling

PollPower	=	1
PollInput	=	2
PollLamp	=	3

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable //Loop and Timeline Variables

integer		x
integer		y

long		lLampTime[]={10000}
long		lPollTime[]={2000,2000,2000}

define_variable //Active Variables

integer		nActivePower=VD_PWR_OFF
integer		nActiveInput=VD_SRC_AUX1
integer		nLampLife

define_variable //Strings

char 		cCmdStr[26][20]	
char		cPollStr[3][20]

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function tp_fb()
{
	for(x=1;x<=length_array(VD_PWR);x++) 
	{
		[vdvProj_FB,VD_PWR[x]]=nActivePower=VD_PWR[x]
		[dvTP,VD_PWR[x]]=nActivePower=VD_PWR[x]
	}
	
	for(x=1;x<=length_array(VD_SRC);x++)
	{
		[vdvProj_FB,VD_SRC[x]]=nActiveInput=VD_SRC[x]
		[dvTP,VD_SRC[x]]=nActiveInput=VD_SRC[x]
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start //Set All Strings

cCmdStr[VD_PWR_ON]		=	'Power On'
cCmdStr[VD_PWR_OFF]		=	'Power Off'

cPollStr[PollPower]		=	'Power?'
cPollStr[PollInput]		=	'Input?'
cPollStr[PollLamp]		=	'Lamp?'


define_start

nLampLife=random_number(1000)
timeline_create(tlLamp,lLampTime,max_length_array(lLampTime),timeline_relative,timeline_repeat)
timeline_create(tlPoll,lPollTime,max_length_array(lPollTime),timeline_relative,timeline_repeat)


#include 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvProj]
{
	string:
	{
		//Parse
	}
}

data_event[dvTP]
{
	online:
	{
		
	}
}

channel_event[vdvProj,VD_PWR]
{
	on:
	{
		switch(channel.channel)
		{
			case VD_PWR_ON:
			{
				if(nActivePower<>VD_PWR_ON)
				{
					nActivePower=VD_WARMING
					wait 20 nActivePower=VD_PWR_ON
				}
			}
			case VD_PWR_OFF:
			{
				if(nActivePower<>VD_PWR_OFF)
				{
					nActivePower=VD_COOLING
					wait 20 nActivePower=VD_PWR_OFF
				}
			}
		}
	}
}

channel_event[vdvProj,VD_SRC]
{
	on:
	{
		nActiveInput=channel.channel
		if(nActivePower<>VD_PWR_ON)
		{
			nActivePower=VD_WARMING
			wait 20 nActivePower=VD_PWR_ON
		}
	}
}

button_event[dvTP,0]
{
	push:
	{
		to[button.input]
		pulse[vdvProj,button.input.channel]
	}
}

timeline_event[tlLamp]
{
	nLampLife++
	send_command dvTP,"'^TXT-',itoa(VD_LAMP_TEXT),',0,Lamp Hours: ',itoa(nLampLife)"
}

timeline_event[tlPoll]
{
	//Poll timeline.sequence
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


