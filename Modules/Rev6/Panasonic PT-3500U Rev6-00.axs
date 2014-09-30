module_name='Panasonic PT-3500U Rev6-00'(DEV dvTP[], DEV vdvDisp, dev vdvDisp_FB, DEV dvDisp)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(***********************************************************)
(*   
	Set baud to 19200,N,8,1,485 DISABLE
	Baud Rate is selectable
	define_module 'Panasonic PT-3500U Rev6-00' proj1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvDisp)
*)

#include 'HoppSNAPI Rev6-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //Timelines

tlPoll		=	2001
tlCmd		=	2002

define_constant //Polling

PollPower	= 1
PollInput	= 2
PollMute 	= 3
PollLamp	= 4

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable //Loop Variables

integer		x

define_variable //Timeline Variables

long		lPollArray[]	={1500,1500,1500,1500}
long 		lCmdArray[]  	={500,500}

integer		nPollType
integer		nCmd

define_variable //Active Variables

integer		nActivePower
integer		nActiveInput
integer		nActiveMute
integer 	nActiveLampHours

define_variable //Strings

char 		cResp[100]
char 		cCmdStr[52][20]	
char 		cPollStr[4][20]
char 		cRespStr[52][20]

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

	for(x=1;x<=length_array(VD_MUTE);x++)
	{
		[vdvDisp_FB,VD_MUTE[x]]=nActiveMute=VD_MUTE[x]
		[dvTP,VD_MUTE[x]]=nActiveMute=VD_MUTE[x]
	}	
	
	[vdvDisp_FB,VD_MUTE_TOG]=nActiveMute=VD_MUTE_ON
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

define_function parse(CHAR cCompStr[100])
{
	switch(nPollType)
	{
		case PollPower:
		{
			select
			{
				active(find_string(cCompStr,cRespStr[VD_PWR_ON],1)):
				{			
					if(nActivePower=VD_PWR_OFF) 
					{
						if(nCmd=VD_PWR_ON) cmd_executed()
						nActivePower=VD_WARMING
						wait 200 nActivePower=VD_PWR_ON
					}
					else if (nActivePower<>VD_WARMING)
					{	
						if(nCmd=VD_PWR_ON) cmd_executed()
						nActivePower=VD_PWR_ON
					}
				}
				active(find_string(cCompStr,cRespStr[VD_PWR_OFF],1)):
				{	
					if(nActivePower=VD_PWR_ON)
					{
						if(nCmd=VD_PWR_OFF) cmd_executed()
						nActivePower=VD_COOLING
						wait 600 nActivePower=VD_PWR_OFF
					}
					else if (nActivePower<>VD_COOLING)
					{
						if(nCmd=VD_PWR_OFF) cmd_executed()
						nActivePower=VD_PWR_OFF
					}
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
		case PollMute:
		{
			for(x=1;x<=length_array(VD_MUTE);x++)
			{
				if(find_string(cCompStr,cRespStr[VD_MUTE[x]],1))
				{
					nActiveMute=VD_MUTE[x]
					if(nCmd=VD_MUTE[x]) cmd_executed()
				}
			}
		}
		case PollLamp:
		{
			remove_string(cCompStr,"$02",1)
			nActiveLampHours=atoi(left_string(cCompStr,find_string(cCompStr,"$03",1)-1))
			send_command dvTP,"'^TXT-',itoa(VD_LAMP_TEXT),',0,Lamp Hours: ',itoa(nActiveLampHours)"
		}
	}
}

define_function command_to_display()
{
	switch(nCmd)
	{
		case VD_PWR_ON:
		case VD_PWR_OFF: 
		{
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
				case VD_COOLING:
				{
					send_string dvDisp,"cCmdStr[VD_PWR_ON]"
					nPollType = pollPower
				}
				case VD_WARMING:
				default:
				{
					nPollType=pollPower
				}
			}
		}
		case VD_MUTE_ON:
		case VD_MUTE_OFF:
		{
			if(nActiveMute<>nCmd) send_string dvDisp,"cCmdStr[nCmd]"
			else cmd_executed()
			nPollType=pollMute
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

cCmdStr[VD_PWR_ON]			= "$02,'ADZZ;PON',$03"	//on
cCmdStr[VD_PWR_OFF]			= "$02,'ADZZ;POF',$03"	//off
cCmdStr[VD_SRC_RGB1]  		= "$02,'ADZZ;IIS:RG1',$03"	//input2 RGBHV
cCmdStr[VD_SRC_VGA1]  		= "$02,'ADZZ;IIS:RG2',$03"	//input2 VGA
cCmdStr[VD_SRC_SVID]  		= "$02,'ADZZ;IIS:SVD',$03"	//SVid
cCmdStr[VD_SRC_VID] 		= "$02,'ADZZ;IIS:VID',$03"	//input2 video
cCmdStr[VD_SRC_DVI1] 		= "$02,'ADZZ;IIS:DVI',$03"	//input2 video
cCmdStr[VD_SRC_AUX1] 		= "$02,'ADZZ;IIS:SDI',$03"	//input2 video
cCmdStr[VD_MUTE_ON] 		= "$02,'ADZZ;OSH:1',$03"	//input2 video
cCmdStr[VD_MUTE_OFF] 		= "$02,'ADZZ;OSH:0',$03"	//input2 video
cCmdStr[VD_PCADJ]			= "$02,'ADZZ;OAS',$03" //PC Adjust

cPollStr[PollPower]		= "$02,'ADZZ;QPW',$03"	//pwr
cPollStr[PollInput] 	= "$02,'ADZZ;QIN',$03"	//input
cPollStr[PollMute]		= "$02,'ADZZ;QSH',$03"	//mute
cPollStr[PollLamp]		= "$02,'ADZZ;QST',$03"

cRespStr[VD_PWR_ON] 		= "'001'"
cRespStr[VD_PWR_OFF]		= "'000'"
cRespStr[VD_SRC_RGB1]		= "'RG1'"
cRespStr[VD_SRC_VGA1]		= "'RG2'"
cRespStr[VD_SRC_VID]		= "'VID'"
cRespStr[VD_SRC_SVID]		= "'SVD'"
cRespStr[VD_SRC_DVI1]		= "'DVI'"
cRespStr[VD_SRC_AUX1]		= "'SDI'"
cRespStr[VD_MUTE_ON]		= "'1'"
cRespStr[VD_MUTE_OFF]		= "'0'"

define_start //Timelines and Feedback

timeline_create(tlPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)

#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event //Parse Response

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
				active(find_string(cBuff,"$03",1)&& length_string(cHold)):
				{
					nPos=find_string(cBuff,"$03",1)
					cFullStr="cHold,get_buffer_string(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				active(find_string(cBuff,"$03",1)):
				{
					nPos=find_string(cBuff,"$03",1)
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
		pulse[vdvDisp,button.input.channel]
	}
}

define_event //Timelines

timeline_event[tlPoll]				//Projector Polling
{
	nPollType=timeline.sequence
	switch(timeline.sequence)
	{
		case PollPower: send_string dvDisp,"cPollStr[timeline.sequence]"
		case PollMute:
		case PollLamp:
		case PollInput: if (nActivePower=VD_PWR_ON) send_string dvDisp,"cPollStr[timeline.sequence]"
	}
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
define_program
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


