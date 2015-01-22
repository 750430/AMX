module_name='Sharp LC90LE657U Rev6-00'(dev dvTP[], dev vdvLCD, dev vdvLCD_FB, dev dvLCD)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   
	set baud to 9600,N,8,1 485 DISABLE
	define_module 'Sharp LC90LE657U Rev6-00' disp1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvLCD1)
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

long		lPollTime[]={2000,2000}
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
		[vdvLCD_FB,VD_PWR[x]]=nActivePower=VD_PWR[x]
		[dvTP,VD_PWR[x]]=nActivePower=VD_PWR[x]
	}
	
	for(x=1;x<=length_array(VD_SRC);x++)
	{
		[vdvLCD_FB,VD_SRC[x]]=nActiveInput=VD_SRC[x]
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
	switch(nPollType)
	{
		case PollPower:
		{
			select
			{
				active(find_string(cCompStr,'1',1) or find_string(cCompStr,'2',1)):
				{			
					nActivePower=VD_PWR_ON
					IF(nCmd = VD_PWR_ON) cmd_executed()
				}
				active(find_string(cCompStr,'0',1)):
				{	
					nActivePower=VD_PWR_OFF
					IF(nCmd = VD_PWR_OFF) cmd_executed()
				}
				active(find_string(cCompStr,'OK',1)):
				{	
					if(nCmd = VD_PWR_OFF) nActivePower=VD_COOLING
					if(nCmd = VD_PWR_ON) nActivePower=VD_WARMING
				}
			}
		}
		case PollInput:
		{
			for(x=1;x<=length_array(VD_SRC);x++)
			{
				if(find_string(cCompStr,cRespStr[VD_SRC[x]],1))
				{
					nActiveInput=VD_SRC[x]
					if(nCmd=VD_SRC[x]) cmd_executed()
				}
			}
		}
	}
}

define_function command_to_display()
{
	switch(nCmd)
	{
		case VD_PWR_ON:
		{
			send_string dvLCD,"cCmdStr[nCmd]"
			nPollType = pollPower
		}
		case VD_PWR_OFF: 
		{
			send_string dvLCD,"cCmdStr[nCmd]"
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
					send_string dvLCD,"cCmdStr[nCmd]"
					nPollType = pollInput
				}
				case VD_PWR_OFF:
				{
					send_string dvLCD,"cCmdStr[VD_PWR_ON]"
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
			if(nCmd) send_string dvLCD,"cCmdStr[nCmd]"
			cmd_executed()
		}
	}	
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start //Set All Strings

cCmdStr[VD_PWR_ON]		=	"'POWR1   ',$0D" 			
cCmdStr[VD_PWR_OFF]		=	"'POWR0   ',$0D"

cCmdStr[VD_SRC_HDMI1]	=	"'IAVD1   ',$0D"	//hdmi 1
cCmdStr[VD_SRC_HDMI2]	=	"'IAVD2   ',$0D"	//hdmi 2
cCmdStr[VD_SRC_HDMI3]	=	"'IAVD3   ',$0D"	//hdmi 3 
cCmdStr[VD_SRC_HDMI4]	=	"'IAVD4   ',$0D"	//hdmi 4
cCmdStr[VD_SRC_CMPNT]	=	"'IAVD5   ',$0D"	//component
cCmdStr[VD_SRC_VID]		=	"'IAVD6   ',$0D"	//video
cCmdStr[VD_SRC_AUX1]	=	"'IAVD7   ',$0D"	//video 2
cCmdStr[VD_SRC_VGA1]	=	"'IAVD8   ',$0D"	//pc in

cRespStr[VD_SRC_HDMI1]	=	"'1'"
cRespStr[VD_SRC_HDMI2]	=	"'2'"
cRespStr[VD_SRC_HDMI3]	=	"'3'"
cRespStr[VD_SRC_HDMI4]	=	"'4'"
cRespStr[VD_SRC_CMPNT]	=	"'5'"
cRespStr[VD_SRC_VID]	=	"'6'"
cRespStr[VD_SRC_AUX1]	=	"'7'"
cRespStr[VD_SRC_VGA1]	=	"'8'"

cPollStr[PollPower]		=	"'POWR????',$0D"
cPollStr[PollInput]		=	"'IAVD????',$0D"

define_start

wait 200
{
	send_string dvLCD,"'RSPW1   ',$0D"
	send_string dvLCD,"'RSPW2   ',$0D"
}

timeline_create(tlPoll,lPollTime,max_length_array(lPollTime),timeline_relative,timeline_repeat)

#include 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvLCD]
{
	online:
	{
		send_string dvLCD,"'RSPW1   ',$0D"
		send_string dvLCD,"'RSPW2   ',$0D"
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

channel_event[vdvLCD,0]
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
		pulse[vdvLCD,button.input.channel]
	}
}

timeline_event[tlPoll]		//Display Polling
{	
	nPollType = timeline.sequence
	send_string dvLCD,cPollStr[nPollType]
}

timeline_event[tlCmd]		//Display Commands
{
	switch(timeline.sequence)
	{
		case 1:	//1st time
		{
			if(nPollType=PollPower) send_string dvLCD,cPollStr[nPollType]
			else if (nActivePower<>VD_PWR_OFF) send_string dvLCD,cPollStr[nPollType]
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


