module_name='NEC X551UN Rev6-00'(dev dvTP[], dev vdvLCD, dev vdvLCD_FB, dev dvLCD)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   
	set baud to 9600,N,8,1 485 DISABLE
	If controlling via IP, use port 7142
	define_module 'NEC X551UN Rev6-00' disp1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvLCD1)
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
char		cCheckSum

define_variable //Timeline Variables

long		lPollTime[]={2000,2000}
long		lCmdArray[]={1000,1000}

integer		nPollType
integer		nCmd

define_variable //Active Variables

integer		nActivePower
integer		nActiveInput

define_variable //Strings

char 		cCmdStr[31][30]	
char		cRespStr[31][30]
char		cPollStr[2][30]

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
	select
	{
		active(find_string(cCompStr,"'C203D60001',$03,'v'",1) || find_string(cCompStr,"'D60000040001',$03,'t'",1)):
		{			
			nActivePower=VD_PWR_ON
			IF(nCmd = VD_PWR_ON) cmd_executed()
		}
		active(find_string(cCompStr,"'C203D60004',$03,'s'",1) || find_string(cCompStr,"'D60000040004',$03,'q'",1)):
		{	
			nActivePower=VD_PWR_OFF
			IF(nCmd = VD_PWR_OFF) cmd_executed()
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
			send_string 0,"'cCmdStr[VD_PWR_ON]=',cCmdStr[nCmd]"
			send_string dvLCD,"cCmdStr[nCmd]"
			nPollType = pollPower
		}
		case VD_PWR_OFF: 
		{
			nActivePower=VD_COOLING
			send_string 0,"'cCmdStr[VD_PWR_OFF]=',cCmdStr[nCmd]"
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

define_function char calcBCC(char cCommStr[100])
{
	stack_var char cResult
	cResult = $00
	for(x=2;x<=(length_string(cCommStr));x++)
	{
		cResult=cResult bxor cCommStr[x]
	}
	return cResult
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start //Set All Strings

cCmdStr[VD_PWR_ON]		=	"$01,$30,$41,$30,$41,$30,$43,$02,$43,$32,$30,$33,$44,$36,$30,$30,$30,$31,$03,$73,$0D"
cCmdStr[VD_PWR_OFF]		=	"$01,$30,$41,$30,$41,$30,$43,$02,$43,$32,$30,$33,$44,$36,$30,$30,$30,$34,$03,$76,$0D"

cCmdStr[VD_SRC_DVI1]	=	"$01,'0A0E0A',$02,'00600003',$03,$71,$0D"
cCmdStr[VD_SRC_HDMI1]	=	"$01,'0A0E0A',$02,'00600011',$03,$72,$0D"
cCmdStr[VD_SRC_AUX1]	=	"$01,'0A0E0A',$02,'0060000D',$03,$06,$0D"

cRespStr[VD_SRC_DVI1]	=	"'0600000110003',$03"
cRespStr[VD_SRC_HDMI1]	=	"'0600000110011',$03"
cRespStr[VD_SRC_AUX1]	=	"'060000011000D',$03"

cPollStr[PollPower]		=	"$01,'0A0A06',$02,'01D6',$03,$74,$0D"
cPollStr[PollInput]		=	"$01,'0A0C06',$02,$30,$30,$36,$30,$03,$03,$0D"
//cPollStr[PollInput]		=	"$01,'0A0C0A',$02,$60,$60,$66,$60,$03,$1F,$0D"



define_start

timeline_create(tlPoll,lPollTime,max_length_array(lPollTime),timeline_relative,timeline_repeat)

#include 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvLCD]
{
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
			if(nPollType) send_string dvLCD,cPollStr[nPollType]
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


