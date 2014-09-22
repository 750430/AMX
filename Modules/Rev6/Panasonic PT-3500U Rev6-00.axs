MODULE_NAME='Panasonic PT-3500U Rev6-00'(DEV dvTP, DEV vdvProj, dev vdvProj_FB, DEV dvProj)
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
	define_module 'Panasonic PT-3500U Rev6-00' proj1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvProj)
*)

#INCLUDE 'HoppSNAPI Rev6-00.axi'

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG tlPoll		= 2001
LONG tlCmd         = 2002

INTEGER PollPower 	= 1
INTEGER PollInput 	= 2
INTEGER PollMute 	= 3
INTEGER PollLamp	= 4

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

LONG lPollArray[]	= {1500,1500,1500,1500}
LONG lCmdArray[]  =	{500,500}

INTEGER nPollType

CHAR cResp[100]
CHAR cCmdStr[52][20]	
CHAR cPollStr[4][20]
CHAR cRespStr[52][20]

integer nProjOnFB
integer nProjOffFB

integer x

INTEGER nPwrVerify = 0

integer		nActivePower
integer		nActiveInput
integer		nActiveMute
integer 	nActiveLampHours

INTEGER nCmd = 0

define_variable //Channel Arrays

integer		nPower[]={VD_PWR_ON,VD_PWR_OFF,VD_WARMING,VD_COOLING}
integer		nInput[]={VD_SRC_VGA1,VD_SRC_VGA2,VD_SRC_VGA3,VD_SRC_DVI1,VD_SRC_DVI2,VD_SRC_DVI3,VD_SRC_RGB1,VD_SRC_RGB2,VD_SRC_RGB3,
						VD_SRC_HDMI1,VD_SRC_HDMI2,VD_SRC_HDMI3,VD_SRC_HDMI4,VD_SRC_VID,VD_SRC_SVID,VD_SRC_CMPNT,VD_SRC_CATV,
						VD_SRC_AUX1,VD_SRC_AUX2,VD_SRC_AUX3,VD_SRC_AUX4}
integer		nMute[]={VD_MUTE_ON,VD_MUTE_OFF}

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
	
	for(x=1;x<=length_array(nMute);x++)
	{
		[vdvProj_FB,nMute[x]]=nActiveMute=nMute[x]
		[dvTP,nMute[x]]=nActiveMute=nMute[x]
	}	
}

DEFINE_FUNCTION CmdExecuted()
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

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER x 
	STACK_VAR INTEGER nLamp
	switch(nPollType)
	{
		case PollPower:
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_ON],1)):
				{			
					IF(nActivePower=VD_PWR_OFF) 
					{
						if(nCmd=VD_PWR_ON) CmdExecuted()
						nActivePower=VD_WARMING
						wait 200 nActivePower=VD_PWR_ON
					}
					else if (nActivePower<>VD_WARMING)
					{	
						if(nCmd=VD_PWR_ON) CmdExecuted()
						nActivePower=VD_PWR_ON
					}
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_PWR_OFF],1)):
				{	
					IF(nActivePower=VD_PWR_ON)
					{
						if(nCmd=VD_PWR_OFF) CmdExecuted()
						nActivePower=VD_COOLING
						wait 600 nActivePower=VD_PWR_OFF
					}
					else if (nActivePower<>VD_COOLING)
					{
						if(nCmd=VD_PWR_OFF) CmdExecuted()
						nActivePower=VD_PWR_OFF
					}
				}
			}
		}
		case PollInput:
		{
			select
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_RGB1],1)):
				{
					nActiveInput=VD_SRC_RGB1
					if (nCmd=VD_SRC_RGB1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VID],1)):
				{
					nActiveInput=VD_SRC_VID
					if (nCmd=VD_SRC_VID) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_VGA1],1)):
				{
					nActiveInput=VD_SRC_VGA1
					if (nCmd=VD_SRC_VGA1) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_SVID],1)):
				{
					nActiveInput=VD_SRC_SVID
					if (nCmd=VD_SRC_SVID) CmdExecuted()
				}	
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_DVI1],1)):
				{
					nActiveInput=VD_SRC_DVI1
					if (nCmd=VD_SRC_DVI1) CmdExecuted()
				}	
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_SRC_AUX1],1)):
				{
					nActiveInput=VD_SRC_AUX1
					if (nCmd=VD_SRC_AUX1) CmdExecuted()
				}	
			}
		}
		case PollMute:
		{
			select
			{
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_MUTE_ON],1)):
				{
					nActiveMute=VD_MUTE_ON
					IF(nCmd = VD_MUTE_ON) CmdExecuted()
				}
				ACTIVE(FIND_STRING(cCompStr,cRespStr[VD_MUTE_OFF],1)):
				{
					nActiveMute=VD_MUTE_OFF
					IF(nCmd = VD_MUTE_OFF) CmdExecuted()
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
			send_string dvProj,"cCmdStr[nCmd]"
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
					send_string dvProj,"cCmdStr[nCmd]"
					nPollType = pollInput
				}
				case VD_PWR_OFF:
				case VD_COOLING:
				{
					send_string dvProj,"cCmdStr[VD_PWR_ON]"
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
			if(nActiveMute<>nCmd) send_string dvProj,"cCmdStr[nCmd]"
			else CmdExecuted()
			nPollType=pollMute
		}
		default:
		{
			if(nCmd) send_string dvProj,"cCmdStr[nCmd]"
			CmdExecuted()
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

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
DEFINE_EVENT

data_event[dvProj]
{
	string:
	{
		local_var char cHold[100]
		local_var char cFullStr[100]
		local_var char cBuff[255]
		stack_var integer nPos	
		
		//parse(data.text)
		
		//send_string vdvProj,"'String From: ',data.text,$0D"
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

TIMELINE_EVENT[tlPoll]				//Projector Polling
{
	switch(timeline.sequence)
	{
		case PollPower: SEND_STRING dvProj,"cPollStr[TIMELINE.SEQUENCE]"
		case PollMute:
		case PollLamp:
		case PollInput: if (nActivePower=VD_PWR_ON) SEND_STRING dvProj,"cPollStr[TIMELINE.SEQUENCE]"
	}
	nPollType = TIMELINE.SEQUENCE
}

timeline_event[tlCmd]		//Display Commands
{
	switch(timeline.sequence)
	{
		case 1:	//1st time
		{
			if(nPollType) send_string dvProj,"cPollStr[nPollType]"
		}
		case 2:	//2nd time
		{
			if(timeline.repetition>5) command_to_display()  //This means we don't spam it with the change until we've given it enough time to respond to the
															//first attempt, then we start trying a little more aggressively.
		}
	}
}

CHANNEL_EVENT[vdvProj,0]
{
	ON:
	{
		nCmd=channel.channel
		command_to_display()
		start_command_timeline()
	}
}

BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		to[button.input]
		to[vdvProj,button.input.channel]
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


