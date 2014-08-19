module_name='Fake Projector Rev6-00'(dev dvTP[], dev vdvProj, dev vdvProj_FB, dev dvProj, devchan dcScreenUp, devchan dcScreenDown, devchan dcLiftUp, devchan dcLiftDown)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   

define_module 'Fake Projector Rev6-00' disp1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvProj1,dstMain[1].dcScreenUp,dstMain[1].dcScreenDown,dstMain[1].dcLiftUp,dstMain[1].dcLiftDown)
*)

#include 'HoppSNAPI Rev6-00.axi'
#include 'HoppDEBUG Rev6-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant

tlLamp		=	2001
tlPoll		=	2002

PollPower	=	1
PollInput	=	2
PollLamp	=	3

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

integer		x
integer		y

integer		nLampLife

long		lLampTime[]={10000}

long		lPollTime[]={2000,2000,2000}

integer		nActivePower=VD_PWR_OFF
integer		nActiveInput=VD_SRC_AUX1

integer		nPower[]={VD_PWR_ON,VD_PWR_OFF,VD_WARMING,VD_COOLING}
integer		nInput[]={VD_SRC_VGA1,VD_SRC_VGA2,VD_SRC_VGA3,VD_SRC_DVI1,VD_SRC_DVI2,VD_SRC_DVI3,VD_SRC_RGB1,VD_SRC_RGB2,VD_SRC_RGB3,
						VD_SRC_HDMI1,VD_SRC_HDMI2,VD_SRC_HDMI3,VD_SRC_HDMI4,VD_SRC_VID,VD_SRC_SVID,VD_SRC_CMPNT,VD_SRC_CATV,
						VD_SRC_AUX1,VD_SRC_AUX2,VD_SRC_AUX3,VD_SRC_AUX4}



define_variable //Strings

char 		cCmdStr[26][20]	
char		cPollStr[3][20]

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function tp_fb()
{
	for(x=1;x<=length_array(nPower);x++) 
	{
		[vdvProj_FB,nPower[x]]=nActivePower=nPower[x]
		[dvTP,nPower[x]]=nActivePower=nPower[x]
	}
	
	for(x=1;x<=length_array(nInput);x++)
	{
		[vdvProj_FB,nInput[x]]=nActiveInput=nInput[x]
		[dvTP,nInput[x]]=nActiveInput=nInput[x]
	}	
}

define_function enable_button(dev tp[],integer btn)
{
	send_command tp,"'^BMF-',itoa(btn),',0,%OP255%EN1'"
}

define_function disable_button(dev tp[],integer btn)
{
	send_command tp,"'^BMF-',itoa(btn),',0,%OP80%EN0'"
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

for(x=VD_SRC_VGA1;x<=VD_SRC_AUX4;x++)
{
	switch(random_number(2))
	{
		case 1: cCmdStr[x]="'Select Input ',itoa(x)"
		case 0: cCmdStr[x]=''
	}
}


DEFINE_START
nLampLife=random_number(1000)
timeline_create(tlLamp,lLampTime,max_length_array(lLampTime),timeline_relative,timeline_repeat)
timeline_create(tlPoll,lPollTime,max_length_array(lPollTime),timeline_relative,timeline_repeat)
#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvProj]
{
	string:
	{
		add_to_debug(data.text,strFrom)
	}
}

data_event[dvTP]
{
	online:
	{
		for(x=VD_SRC_VGA1;x<=VD_SRC_AUX4;x++)
		{
			if(length_string(cCmdStr[x])) enable_button(dvTP,x)
			else disable_button(dvTP,x)
		}
		if(dcScreenUp.channel>0) enable_button(dvTP,VD_SCREEN_UP)
		else disable_button(dvTP,VD_SCREEN_UP)
		if(dcScreenDown.channel>0) enable_button(dvTP,VD_SCREEN_DOWN)
		else disable_button(dvTP,VD_SCREEN_DOWN)
		if(dcLiftUp.channel>0) enable_button(dvTP,VD_LIFT_UP)
		else disable_button(dvTP,VD_LIFT_UP)
		if(dcLiftDown.channel>0) enable_button(dvTP,VD_LIFT_DOWN)
		else disable_button(dvTP,VD_LIFT_DOWN)
	}
}

CHANNEL_EVENT[vdvProj,0]
{
	ON:
	{
		SWITCH(channel.channel)
		{
			CASE VD_PWR_ON:
			{
				if(nActivePower<>VD_PWR_ON)
				{
					send_str(dvProj,cCmdStr[VD_PWR_ON])
					nActivePower=VD_WARMING
					wait 20 nActivePower=VD_PWR_ON
				}
			}
			CASE VD_PWR_OFF: 
			{
				if(nActivePower<>VD_PWR_OFF)
				{
					send_str(dvProj,cCmdStr[VD_PWR_OFF])
					nActivePower=VD_COOLING
					wait 20 nActivePower=VD_PWR_OFF
				}
			}
			case VD_SRC_VGA1:
			case VD_SRC_VGA2:
			case VD_SRC_VGA3:
			case VD_SRC_DVI1:
			case VD_SRC_DVI2:
			case VD_SRC_DVI3:
			case VD_SRC_RGB1:
			case VD_SRC_RGB2:
			case VD_SRC_RGB3:
			case VD_SRC_HDMI1:
			case VD_SRC_HDMI2:
			case VD_SRC_HDMI3:
			case VD_SRC_HDMI4:
			case VD_SRC_VID:
			case VD_SRC_SVID:
			case VD_SRC_CMPNT:
			case VD_SRC_CATV:
			case VD_SRC_AUX1:
			case VD_SRC_AUX2:
			case VD_SRC_AUX3:
			case VD_SRC_AUX4:
			{
				nActiveInput=channel.channel
				send_str(dvProj,cCmdStr[nActiveInput])
				if(nActivePower<>VD_PWR_ON)
				{
					send_str(dvProj,cCmdStr[VD_PWR_ON])
					nActivePower=VD_WARMING
					wait 20 nActivePower=VD_PWR_ON
				}
			}
			CASE VD_SCREEN_UP: pulse [dcScreenUp]
			CASE VD_SCREEN_DOWN: pulse [dcScreenDown]
			CASE VD_LIFT_UP: pulse [dcLiftUp]
			CASE VD_LIFT_DOWN: pulse [dcLiftDown]
		}
	}
}

BUTTON_EVENT[dvTP,0]
{
	PUSH:
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
	send_str(dvProj,cPollStr[timeline.sequence])
	switch(timeline.sequence)
	{
		case PollPower:	
		{
			switch(nActivePower)
			{
				case VD_PWR_ON: add_to_debug('Power On',strFrom)
				case VD_PWR_OFF: add_to_debug('Power Off',strFrom)
				case VD_WARMING: add_to_debug('Warming',strFrom)
				case VD_COOLING: add_to_debug('Cooling',strFrom)
			}
		}
		case PollInput: add_to_debug("'Input ',itoa(nActiveInput)",strFrom)
		case PollLamp: add_to_debug("'Lamp Hours ',itoa(nLampLife)",strFrom)
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


