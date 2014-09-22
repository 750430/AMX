module_name='Sony VPL-FH30 Rev6-00'(dev dvTP[], dev vdvProj, dev vdvProj_FB, dev dvProj)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   
	Set baud to 38400,E,8,1,485 DISABLE
	define_module 'Sony VPL-FH30 Rev6-00' proj1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvProj)
*)

#INCLUDE 'HoppSNAPI Rev6-00.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //Timelines

tlPoll		= 2001
tlCmd		= 2002

define_constant //Polling

pollPower 	= 1
pollInput 	= 2
pollLamp	= 3


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable	//System Variables

integer		x

define_variable //Timelines and Polling

long		lPollArray[]	=	{3000,3000,3000}
long		lCmdArray[]  	=	{500,500}

integer 	nPollType
integer		nCmd

define_variable //Strings

char		cResp[100]
char 		cCmdStr[26][20]	
char 		cPollStr[4][20]
char 		cRespStr[80][20]
char		cDebugBuffer[5000]

define_variable //ActiveVariables

integer		nActivePower
integer		nActiveInput
integer 	nActiveLampHours

define_variable //Channel Arrays

integer		nPower[]={VD_PWR_ON,VD_PWR_OFF,VD_WARMING,VD_COOLING}
integer		nInput[]={VD_SRC_VGA1,VD_SRC_VGA2,VD_SRC_VGA3,VD_SRC_DVI1,VD_SRC_DVI2,VD_SRC_DVI3,VD_SRC_RGB1,VD_SRC_RGB2,VD_SRC_RGB3,
						VD_SRC_HDMI1,VD_SRC_HDMI2,VD_SRC_HDMI3,VD_SRC_HDMI4,VD_SRC_VID,VD_SRC_SVID,VD_SRC_CMPNT,VD_SRC_CATV,
						VD_SRC_AUX1,VD_SRC_AUX2,VD_SRC_AUX3,VD_SRC_AUX4}

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

define_function integer calcchecksumor(char cMsg[])
{
	stack_var integer nLoop
	stack_var char cCheckSum
	
	off[cCheckSum]
	for (nLoop=1;nLoop<=length_string(cMsg);nLoop++)
	{
		cCheckSum=cCheckSum|cMsg[nLoop]
	}
	return cCheckSum
}

define_function char[8] build_string(char cMsg[])
{
	if(length_string(cMsg)) cMsg="$A9,cMsg,calcchecksumor(cMsg),$9A"
	return cMsg
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
		active( find_string(cCompStr,cRespStr[VD_PWR_OFF],1) or
				find_string(cCompStr,build_string("$01,$02,$02,$00,$08"),1)):
		{	
			nActivePower=VD_PWR_OFF
			IF(nCmd = VD_PWR_OFF) cmd_executed()
		}
		active( find_string(cCompStr,build_string("$01,$02,$02,$00,$01"),1) or
				find_string(cCompStr,build_string("$01,$02,$02,$00,$02"),1)):	//Warming Up
		{
			nActivePower=VD_WARMING
			IF(ncmd = VD_PWR_ON) cmd_executed()
		}
		active( find_string(cCompStr,build_string("$01,$02,$02,$00,$04"),1) or
				find_string(cCompStr,build_string("$01,$02,$02,$00,$05"),1) or
				find_string(cCompStr,build_string("$01,$02,$02,$00,$06"),1) or
				find_string(cCompStr,build_string("$01,$02,$02,$00,$07"),1)):	//Cooling Down
		{
			nActivePower=VD_COOLING
			IF(ncmd = VD_PWR_OFF) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_HDMI1],1)):
		{
			nActiveInput=VD_SRC_HDMI1
			IF(ncmd = VD_SRC_HDMI1) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_AUX1],1)):
		{
			nActiveInput=VD_SRC_AUX1
			IF(ncmd = VD_SRC_AUX1) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_AUX2],1)):
		{
			nActiveInput=VD_SRC_AUX2
			IF(nCmd = VD_SRC_AUX2) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_AUX3],1)):
		{
			nActiveInput=VD_SRC_AUX3
			IF(nCmd = VD_SRC_AUX3) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_VID],1)):
		{
			nActiveInput=VD_SRC_VID
			IF(nCmd = VD_SRC_VID) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_SVID],1)):
		{
			nActiveInput=VD_SRC_SVID
			IF(nCmd = VD_SRC_SVID) cmd_executed()
		}
		active(find_string(cCompStr,"$A9,$01,$13,$02",1)):
		{
			nActiveLampHours=(cCompStr[5] * 256) + cCompStr[6];
			send_command dvTP,"'^TXT-1,0,Lamp Hours: ',itoa(nActiveLampHours)"
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
			send_str(dvProj,cCmdStr[nCmd])
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
					send_str(dvProj,cCmdStr[nCmd])
					nPollType = pollInput
				}
				case VD_PWR_OFF:
				case VD_COOLING:
				{
					send_str(dvProj,cCmdStr[VD_PWR_ON])
					nPollType = pollPower
				}
				case VD_WARMING:
				default:
				{
					nPollType=pollPower
				}
			}
		}
	}	
}

define_function send_str(dev dv,char cStr[])
{
	send_string dv,cStr
	send_string vdvProj,"'String To: ',cStr,$0D"
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start //Set All Strings

cCmdStr[VD_PWR_ON]			= "$17,$2E,$00,$00,$00"		//on
cCmdStr[VD_PWR_OFF]			= "$17,$2F,$00,$00,$00"		//off
cCmdStr[VD_SRC_VID] 		= "$00,$01,$00,$00,$00"		//video
cCmdStr[VD_SRC_SVID]		= "$00,$01,$00,$00,$01"		//svideo
cCmdStr[VD_SRC_AUX1]		= "$00,$01,$00,$00,$02"		//input A
cCmdStr[VD_SRC_AUX2]		= "$00,$01,$00,$00,$03"		//input B
cCmdStr[VD_SRC_AUX3]		= "$00,$01,$00,$00,$04"		//input C
cCmdStr[VD_SRC_HDMI1]		= "$00,$01,$00,$00,$05"		//input D

for(x=1;x<=max_length_array(cCmdStr);x++) cCmdStr[x]=build_string(cCmdStr[x])



cPollStr[pollPower]		= "$01,$02,$01,$00,$00"		//pwr
cPollStr[pollInput] 	= "$00,$01,$01,$00,$00"		//input
cPollStr[pollLamp]		= "$01,$13,$01,$00,$00" 	//lamp hours

for(x=1;x<=max_length_array(cPollStr);x++) cPollStr[x]=build_string(cPollStr[x])

cRespStr[VD_PWR_ON] 		= "$01,$02,$02,$00,$03"
cRespStr[VD_PWR_OFF]		= "$01,$02,$02,$00,$00"
cRespStr[VD_SRC_VID] 		= "$00,$01,$02,$00,$00"
cRespStr[VD_SRC_SVID]		= "$00,$01,$02,$00,$01"
cRespStr[VD_SRC_AUX1]		= "$00,$01,$02,$00,$02"
cRespStr[VD_SRC_AUX2]		= "$00,$01,$02,$00,$03"
cRespStr[VD_SRC_AUX3]		= "$00,$01,$02,$00,$04"
cRespStr[VD_SRC_HDMI1]		= "$00,$01,$02,$00,$05"

for(x=1;x<=max_length_array(cRespStr);x++) cRespStr[x]=build_string(cRespStr[x])

define_start //Timelines and Feedback

timeline_create(tlPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)

create_buffer vdvProj,cDebugBuffer

#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvProj]
{
	string:
	{
		local_var char cHold[100]
		local_var char cFullStr[100]
		local_var char cBuff[255]
		stack_var integer nPos	
		
		cBuff = "cBuff,data.text"
		send_string vdvProj,"'String From: ',data.text,$0D"
		while(length_string(cBuff))
		{
			select
			{
				active(find_string(cBuff,"$9A",1)&& length_string(cHold)):
				{
					nPos=find_string(cBuff,"$9A",1)
					cFullStr="cHold,get_buffer_string(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				active(find_string(cBuff,"$9A",1)):
				{
					nPos=find_string(cBuff,"$9A",1)
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



timeline_event[tlPoll]		//Display Polling
{	
	send_str(dvProj,cPollStr[timeline.sequence])
	nPollType = timeline.sequence
}

timeline_event[tlCmd]		//Display Commands
{
	switch(timeline.sequence)
	{
		case 1:	//1st time
		{
			if(nPollType) send_str(dvProj,cPollStr[nPollType])
		}
		case 2:	//2nd time
		{
			command_to_display()
		}
	}
}

channel_event[vdvProj,0]
{
	on:
	{
		nCmd=channel.channel
		command_to_display()
		start_command_timeline()
	}
}

button_event[dvTP,0]
{
	push:
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


