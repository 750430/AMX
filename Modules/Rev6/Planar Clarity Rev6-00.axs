module_name='Planar Clarity Rev6-00'(dev dvTP[], dev vdvDisp, dev vdvDisp_FB, dev dvDisp)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   
	Baud Rate is selectable on the video wall
	define_module 'Planar Clarity Rev6-00' lcd1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvDisp)
*)

#include 'HoppSNAPI Rev6-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //Timelines

tlPoll		= 2001
tlCmd		= 2002

define_constant //Polling

pollPower 	=	1
pollInput 	=	2

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable	//Loop Variables

integer		x

define_variable //Timelines Variables

long		lPollArray[]	=	{1500}
long		lCmdArray[]  	=	{1000,1000}

integer 	nPollType
integer		nCmd

define_variable //Active Variables

integer		nActivePower
integer		nActiveInput

define_variable //Strings

char		cResp[100]
char 		cCmdStr[40][40]	
char 		cPollStr[2][40]
char 		cRespStr[40][40]

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
	for(x=1;x<=length_array(VD_PWR);x++)
	{
		if(find_string(cCompStr,cRespStr[VD_PWR[x]],1))
		{
			nActivePower=VD_PWR[x]
			if(nCmd=VD_PWR[x]) cmd_executed()
		}
	}
		
	for(x=1;x<=length_array(VD_SRC);x++)
	{
		if(find_string(cCompStr,cRespStr[VD_SRC[x]],1))
		{
			nActiveInput=VD_SRC[x]
			if(nCmd=VD_SRC[x]) cmd_executed()
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

cCmdStr[VD_PWR_ON]			= "'OPA1DISPLAY.POWER=ON',$0D"
cCmdStr[VD_PWR_OFF]			= "'OPA1DISPLAY.POWER=OFF',$0D"

cPollStr[pollPower]			=	"'OPA1DISPLAY.POWER?',$0D"

cRespStr[VD_PWR_ON] 		= "'OPA1DISPLAY.POWER=ON',$0D"
cRespStr[VD_PWR_OFF]		= "'OPA1DISPLAY.POWER=OFF',$0D"

define_start //Timelines and Feedback

timeline_create(tlPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)

#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event  //Parse Response

data_event[dvDisp]
{
	string:
	{
		local_var char cHold[100]
		local_var char cFullStr[100]
		local_var char cBuff[255]
		stack_var integer nPos	
		
		//parse(data.text)
		
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
		to[vdvDisp,button.input.channel]
	}
}

define_event //Timelines

timeline_event[tlPoll]		//Display Polling
{	
	nPollType = timeline.sequence
	send_string dvDisp,"cPollStr[nPollType]"
	
}

timeline_event[tlCmd]		//Display Commands
{
	switch(timeline.sequence)
	{
		case 1:	//1st time
		{
			if(nPollType) send_string dvDisp,"cPollStr[nPollType]"
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
DEFINE_PROGRAM


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


