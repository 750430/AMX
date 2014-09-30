module_name='Planar Simplicity Rev6-00'(dev dvTP[], dev vdvDisp, dev vdvDisp_FB, dev dvDisp)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   
	set baud to 9600,N,8,1 485 DISABLE
	define_module 'Planar Simplicity Rev6-00' disp1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvDisp1)
*)

#include 'HoppSNAPI Rev6-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //Timelines

tlPoll		=	2001
tlCmd		=	2002

define_constant //Polling

PollPower	=	1
PollInput	=	2

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable //Loop Variables

integer		x
integer		y

define_variable //Timeline Variables

long		lPollArray[]={2000,2000}
long		lCmdArray[]={1000,1000}

integer		nPollType
integer		nCmd

define_variable //Active Variables

integer		nActivePower
integer		nActiveInput

define_variable //Strings

char 		cCmdStr[31][20]	
char		cRespStr[31][20]
char		cPollStr[2][20]

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function tp_fb()
{
	for(x=1;x<=length_array(VD_PWR);x++) 
	{
		[vdvDisp_FB,VD_PWR[x]]=nActivePower=VD_PWR[x]
		[dvTP,VD_PWR[x]]=nActivePower=VD_PWR[x]
	}
	
	for(x=1;x<=length_array(VD_SRC);x++)
	{
		[vdvDisp_FB,VD_SRC[x]]=nActiveInput=VD_SRC[x]
		[dvTP,VD_SRC[x]]=nActiveInput=VD_SRC[x]
	}	
}

define_function cmd_executed()
{
	ncmd=0
	if(timeline_active(tlCmd)) timeline_kill(tlCmd)
	timeline_restart(tlPoll)
}

define_function start_command_timeline()
{
	timeline_pause(tlPoll)
	wait 1 if(!timeline_active(tlCmd))timeline_create(tlCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

define_function parse(char cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,cRespStr[VD_PWR_ON],1)):
		{			
			nActivePower=VD_PWR_ON
			IF(nCmd = VD_PWR_ON) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_PWR_OFF],1)):
		{	
			nActivePower=VD_PWR_OFF
			IF(nCmd = VD_PWR_OFF) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_DVI1],1)):
		{
			nActiveInput=VD_SRC_DVI1
			IF(ncmd = VD_SRC_DVI1) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_VGA1],1)):
		{
			nActiveInput=VD_SRC_VGA1
			IF(ncmd = VD_SRC_VGA1) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_HDMI1],1)):
		{
			nActiveInput=VD_SRC_HDMI1
			IF(ncmd = VD_SRC_HDMI1) cmd_executed()
		}
	}	
}


define_function command_to_display()
{
	switch(nCmd)
	{
		case VD_PWR_ON:
		{
			nActivePower=VD_WARMING
			send_string dvDisp,"cCmdStr[nCmd]"
			nPollType = pollPower
		}
		case VD_PWR_OFF: 
		{
			nActivePower=VD_COOLING
			send_string dvDisp,"cCmdStr[nCmd]"
			nPollType = pollPower
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
			switch(nActivePower)
			{
				case VD_PWR_ON:
				{
					send_string dvDisp,"cCmdStr[nCmd]"
					nPollType = pollInput
				}
				case VD_PWR_OFF:
				{
					nActivePower=VD_WARMING
					send_string dvDisp,"cCmdStr[VD_PWR_ON]"
					nPollType = pollPower
				}
				default:
				{
					nPollType=pollPower
				}
			}
		}
		default:
		{
			if(nCmd) send_string dvDisp,"cCmdStr[nCmd]"
			cmd_executed()
		}
	}	
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start //Set All Strings

cCmdStr[VD_PWR_ON]		=	"$A6,$01,$00,$00,$00,$04,$01,$18,$02,$B8"
cCmdStr[VD_PWR_OFF]		=	"$A6,$01,$00,$00,$00,$04,$01,$18,$01,$BB"
cCmdStr[VD_SRC_HDMI1]	=	"$A6,$01,$00,$00,$00,$07,$01,$AC,$09,$00,$00,$00,$04"
cCmdStr[VD_SRC_DVI1]	=	"$A6,$01,$00,$00,$00,$07,$01,$AC,$09,$00,$00,$00,$0E"
cCmdStr[VD_SRC_VGA1]	=	"$A6,$01,$00,$00,$00,$07,$01,$AC,$05,$00,$00,$00,$08"

cRespStr[VD_PWR_ON]		=	"$21,$01,$00,$00,$04,$01,$19,$02,$3E"
cRespStr[VD_PWR_OFF]	=	"$21,$01,$00,$00,$04,$01,$19,$01,$3D"
cRespStr[VD_SRC_HDMI1]	=	"$21,$01,$00,$00,$05,$01,$AD,$FD,$0A,$7E"
cRespStr[VD_SRC_DVI1]	=	"$21,$01,$00,$00,$05,$01,$AD,$FD,$0B,$7F"
cRespStr[VD_SRC_VGA1]	=	"$21,$01,$00,$00,$05,$01,$AD,$FD,$08,$DA"

cPollStr[PollPower]		=	"$A6,$01,$00,$00,$00,$03,$01,$19,$BC"
cPollStr[PollInput]		=	"$A6,$01,$00,$00,$00,$03,$01,$AD,$08"

define_start //Timelines and Feedback

timeline_create(tlPoll,lPollArray,max_length_array(lPollArray),timeline_relative,timeline_repeat)

#include 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event //Parse Response

data_event[dvDisp]
{
	string:
	{
		parse(data.text)
	}
}

define_event //Input

channel_event[vdvDisp,0]
{
	on:
	{
		nCmd=channel.channel
		command_to_display()
		if(nCmd) start_command_timeline()
	}
}

button_event[dvTP,0]
{
	push:
	{
		to[button.input]
		pulse[vdvDisp,button.input.channel]
	}
}

define_event //Timelines

timeline_event[tlPoll]		//Display Polling
{	
	nPollType = timeline.sequence
	send_string dvDisp,cPollStr[nPollType]
}

timeline_event[tlCmd]		//Display Commands
{
	switch(timeline.sequence)
	{
		case 1:	//1st time
		{
			if(nPollType) send_string dvDisp,cPollStr[nPollType]
		}
		case 2:	//2nd time
		{
			if(timeline.repetition>5) command_to_display()  //This means we don't spam it with the change until we've given it enough time to respond to the
															//first attempt, then we start trying a little more aggressively.
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


