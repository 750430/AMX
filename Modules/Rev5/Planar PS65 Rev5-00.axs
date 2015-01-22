module_name='Planar PS65 Rev5-00'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   
	Set baud to 9600,N,8,1,485 DISABLE
	define_module 'Planar PS65 Rev6-00' lcd1(vdvTP_DISP,vdvLCD1,dvLCD)
*)

#include 'HoppSNAPI Rev5-12.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //Timelines

tlPoll		= 2001
tlCmd		= 2002
tlFeedback	= 2003

define_constant //Polling

pollPower 	=	1
pollInput 	=	2

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable	//Loop Variables

integer		x

define_variable //Timelines Variables

long		lPollArray[]	=	{1500,1500}
long		lCmdArray[]  	=	{1000,1000}

integer 	nPollType
integer		nCmd

define_variable //Active Variables

integer		nActivePower
integer		nActiveInput

define_variable //Strings

char		cResp[100]
char 		cCmdStr[75][40]	
char 		cPollStr[2][40]
char 		cRespStr[75][40]

define_variable //Feedback Variables

non_volatile	long		lFeedbackTime[]={300}

define_variable //Channel Arrays

integer		nPower[]={VD_PWR_ON,VD_PWR_OFF,VD_WARMING,VD_COOLING}
integer		nInput[]={VD_SRC_VGA1,VD_SRC_VGA2,VD_SRC_VGA3,VD_SRC_DVI1,VD_SRC_DVI2,VD_SRC_DVI3,VD_SRC_RGB1,VD_SRC_RGB2,VD_SRC_RGB3,
						VD_SRC_HDMI1,VD_SRC_HDMI2,VD_SRC_HDMI3,VD_SRC_SVID,VD_SRC_AUX1,VD_SRC_AUX2,VD_SRC_AUX3,VD_SRC_AUX4,VD_SRC_CMPNT1,VD_SRC_VID1,VD_SRC_VID2}


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function tp_fb()
{
	for(x=1;x<=length_array(nPower);x++) 
	{
		[dvLCD,nPower[x]]=nActivePower=nPower[x]
		[dvTP,nPower[x]]=nActivePower=nPower[x]
	}
	
	for(x=1;x<=length_array(nInput);x++)
	{
		[dvLCD,nInput[x]]=nActiveInput=nInput[x]
		[dvTP,nInput[x]]=nActiveInput=nInput[x]
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
	for(x=1;x<=length_array(nPower);x++)
	{
		if(find_string(cCompStr,cRespStr[nPower[x]],1))
		{
			nActivePower=nPower[x]
			if(nCmd=nPower[x]) cmd_executed()
		}
	}
		
	for(x=1;x<=length_array(nInput);x++)
	{
		if(find_string(cCompStr,cRespStr[nInput[x]],1))
		{
			nActiveInput=nInput[x]
			if(nCmd=nInput[x]) cmd_executed()
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
			send_string dvLCD,"cCmdStr[nCmd]"
			nPollType = pollPower
		}
		case VD_PWR_OFF: 
		{
			nActivePower=VD_COOLING
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
		case VD_SRC_VID1:
		case VD_SRC_SVID:
		case VD_SRC_CMPNT1:
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
					nActivePower=VD_WARMING
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

cCmdStr[VD_PWR_ON]			= "$38,$30,$31,$73,$21,$30,$30,$31,$0D"		//on
cCmdStr[VD_PWR_OFF]			= "$38,$30,$31,$73,$21,$30,$30,$30,$0D"		//off
cCmdStr[VD_SRC_DVI1] 		= "$38,$30,$31,$73,$22,$30,$30,$36,$0D"
cCmdStr[VD_SRC_HDMI1]		= "$38,$30,$31,$73,$22,$30,$30,$31,$0D"
cCmdStr[VD_SRC_VGA1]		= "$38,$30,$31,$73,$22,$30,$30,$30,$0D"

cPollStr[pollPower]		=	"$38,$30,$31,$67,$6C,$30,$30,$30,$0D"		//pwr
cPollStr[pollInput] 	=	"$38,$30,$31,$67,$6A,$30,$30,$30,$0D"		//input

cRespStr[VD_PWR_ON] 		= "$38,$30,$31,$72,$6C,$30,$30,$31,$0D"
cRespStr[VD_PWR_OFF]		= "$38,$30,$31,$72,$6C,$30,$30,$30,$0D"
cRespStr[VD_SRC_DVI1] 		= "$38,$30,$31,$72,$6A,$30,$30,$36,$0D"
cRespStr[VD_SRC_HDMI1]		= "$38,$30,$31,$72,$6A,$30,$30,$31,$0D"
cRespStr[VD_SRC_VGA1]		= "$38,$30,$31,$72,$6A,$30,$30,$30,$0D"

define_start //Timelines and Feedback

timeline_create(tlPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)
timeline_create(tlFeedback,lFeedbackTime,1,timeline_relative,timeline_repeat)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event  //Parse Response

data_event[dvLCD]
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
		to[vdvLCD,button.input.channel]
	}
}

define_event //Timelines

timeline_event[tlPoll]		//Display Polling
{	
	nPollType = timeline.sequence
	send_string dvLCD,"cPollStr[nPollType]"
	
}

timeline_event[tlCmd]		//Display Commands
{
	switch(timeline.sequence)
	{
		case 1:	//1st time
		{
			if(nPollType) send_string dvLCD,"cPollStr[nPollType]"
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


