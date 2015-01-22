module_name='Christie CP2000zx Rev6-00'(dev dvTP[], dev vdvProj, dev vdvProj_FB, dev dvProj, integer nDefaultChannels[], char cDefaultChannelNames[][])
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:25:55        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   
	Set baud to 115200,N,8,1,485 DISABLE
	Baud Rate is selectable, make sure you configure it to 115200
	define_module 'Christie CP2000zx Rev6-00' proj1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvProj)
*)

#INCLUDE 'HoppSNAPI Rev6-00.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //Timelines

tlPoll		= 2001
tlCmd		= 2002
tlCooling	= 2003

define_constant //Polling

pollPower 	=	1
pollInput 	=	2
pollMute	=	3
pollLamp	=	4
pollChannel	=	5

define_type

structure chDisp
{
	integer		number
	char		name[30]
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable	//System Variables

integer		x

define_variable //Timelines and Polling

long		lPollArray[]	=	{1500,1500,1500,1500,1500}
long		lCmdArray[]  	=	{1000,1000}
long		lCoolingArray[]	=	{1000}

integer 	nPollType
integer		nCmd

define_variable //Strings

char		cResp[100]
char 		cCmdStr[104][40]	
char 		cPollStr[5][40]
char 		cRespStr[80][40]
char		cDebugBuffer[5000]

define_variable //ActiveVariables

integer		nActivePower
integer 	nPrevPower
integer		nActiveLamp
integer		nActiveInput
integer		nActiveMute
integer		nActiveChannel
integer 	nActiveLampHours

integer		nReportedCoolingTime
integer		nCalculatedCoolingTime
char		cInputText[20]

chDisp		chChannels[4]

integer		nSetDispChannelNumber
integer		nSetDispChannelName

define_variable //Channel Arrays

integer		nPower[]={VD_PWR_ON,VD_PWR_OFF,VD_WARMING,VD_COOLING}
integer		nInput[]={VD_SRC_VGA1,VD_SRC_VGA2,VD_SRC_VGA3,VD_SRC_DVI1,VD_SRC_DVI2,VD_SRC_DVI3,VD_SRC_RGB1,VD_SRC_RGB2,VD_SRC_RGB3,
						VD_SRC_HDMI1,VD_SRC_HDMI2,VD_SRC_HDMI3,VD_SRC_HDMI4,VD_SRC_VID,VD_SRC_SVID,VD_SRC_CMPNT,VD_SRC_CATV,
						VD_SRC_AUX1,VD_SRC_AUX2,VD_SRC_AUX3,VD_SRC_AUX4}
integer		nMute[]={VD_MUTE_ON,VD_MUTE_OFF}
integer		nChan[]={VD_CHAN_1,VD_CHAN_2,VD_CHAN_3,VD_CHAN_4}
integer		nLamp[]={VD_LAMP_ON,VD_LAMP_OFF}

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
	
	for(x=1;x<=length_array(nLamp);x++)
	{
		[vdvProj_FB,nLamp[x]]=nActiveLamp=nLamp[x]
		[dvTP,nLamp[x]]=nActiveLamp=nLamp[x]
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
	
	for(x=1;x<=length_array(nChan);x++)
	{
		[vdvProj_FB,nChan[x]]=nActiveChannel=nChan[x]
		[dvTP,nChan[x]]=nActiveChannel=nChan[x]
		[dvTP,VD_CHAN_NAME[x]]=nActiveChannel=nChan[x]
	}	
}


define_function cmd_executed()
{
	ncmd=0
	if(timeline_active(tlCmd)) timeline_kill(tlCmd)
	timeline_restart(tlPoll)
	update_destination_text()
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
		active(find_string(cCompStr,"'ERR'",1)):
		{
			cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_PWR_ON],1)):
		{			
			nPrevPower=nActivePower
			nActivePower=VD_PWR_ON
			nActiveLamp=VD_LAMP_OFF
			IF(nCmd = VD_PWR_ON or nCmd=VD_LAMP_OFF) 
			{
				cmd_executed()
				update_destination_text()
			}
			else if(nPrevPower<>nActivePower) update_destination_text()
		}
		active(find_string(cCompStr,cRespStr[VD_LAMP_ON],1)):
		{			
			nPrevPower=nActivePower
			nActivePower=VD_PWR_ON
			nActiveLamp=VD_LAMP_ON
			IF(nCmd = VD_PWR_ON or nCmd=VD_LAMP_ON)
			{
				cmd_executed()
				update_destination_text()
			}
			else if(nPrevPower<>nActivePower) update_destination_text()
		}		
		active(find_string(cCompStr,cRespStr[VD_PWR_OFF],1)):
		{	
			nPrevPower=nActivePower
			nActivePower=VD_PWR_OFF
			nActiveLamp=VD_LAMP_OFF
			if(timeline_active(tlCooling)) timeline_kill(tlCooling)
			IF(nCmd = VD_PWR_OFF) 
			{
				cmd_executed()
				update_destination_text()
			}
			else if(nPrevPower<>nActivePower) update_destination_text()
		}
		active(find_string(cCompStr,cRespStr[VD_WARMING],1)):	//Warming Up
		{
			nPrevPower=nActivePower
			nActivePower=VD_WARMING
			off[nActiveLamp]
			IF(ncmd = VD_PWR_ON or nCmd = VD_LAMP_ON)
			{
				cmd_executed()
				update_destination_text()
			}
			else if(nPrevPower<>nActivePower) update_destination_text()
		}
		active(find_string(cCompStr,cRespStr[VD_COOLING],1)):	//Cooling Down
		{
			off[nActiveLamp]
			send_str(dvProj,cCmdStr[VD_COOLING])
			if(!timeline_active(tlCooling))
			{
				nCalculatedCoolingTime=900
				timeline_create(tlCooling,lCoolingArray,length_array(lCoolingArray),timeline_relative,timeline_repeat)
			}
			nPrevPower=nActivePower
			nActivePower=VD_COOLING
			IF(ncmd = VD_PWR_OFF) cmd_executed()
		}
		active(find_string(cCompStr,"'(PWR+COOL!'",1)):
		{
			remove_string(cCompStr,"'(PWR+COOL!'",1)
			nReportedCoolingTime=atoi(left_string(cCompStr,find_string(cCompStr,')',1)-1))
			if((nCalculatedCoolingTime<nReportedCoolingTime-4) or (nCalculatedCoolingTime>nReportedCoolingTime+4))
			{
				nCalculatedCoolingTime=nReportedCoolingTime
			}
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_AUX1],1)):
		{
			remove_string(cComPStr,'"',1)
			if(cInputText=left_string(cComPStr,find_string(cComPStr,'"',1)-1))
			{
				//Do Nothing
			}
			else
			{
				cInputText=left_string(cComPStr,find_string(cComPStr,'"',1)-1)
				show_input_text()
			}
			nActiveInput=VD_SRC_AUX1
			IF(ncmd = VD_SRC_AUX1) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_AUX2],1)):
		{
			remove_string(cComPStr,'"',1)
			if(cInputText=left_string(cComPStr,find_string(cComPStr,'"',1)-1))
			{
				//Do Nothing
			}
			else
			{
				cInputText=left_string(cComPStr,find_string(cComPStr,'"',1)-1)
				show_input_text()
			}
			nActiveInput=VD_SRC_AUX2
			IF(nCmd = VD_SRC_AUX2) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_DVI1],1)):
		{
			remove_string(cComPStr,'"',1)
			if(cInputText=left_string(cComPStr,find_string(cComPStr,'"',1)-1))
			{
				//Do Nothing
			}
			else
			{
				cInputText=left_string(cComPStr,find_string(cComPStr,'"',1)-1)
				show_input_text()
			}
			nActiveInput=VD_SRC_DVI1
			IF(nCmd = VD_SRC_DVI1) cmd_executed()
		}
		active(find_string(cCompStr,cRespStr[VD_SRC_DVI2],1)):
		{
			remove_string(cComPStr,'"',1)
			if(cInputText=left_string(cComPStr,find_string(cComPStr,'"',1)-1))
			{
				//Do Nothing
			}
			else 
			{
				cInputText=left_string(cComPStr,find_string(cComPStr,'"',1)-1)
				show_input_text()
			}
			nActiveInput=VD_SRC_DVI2
			IF(nCmd = VD_SRC_DVI2) cmd_executed()
		}
		active(find_string(cCompStr,"'(SIN!'",1)):
		{
			remove_string(cComPStr,'"',1)
			if(cInputText=left_string(cComPStr,find_string(cComPStr,'"',1)-1))
			{
				//Do Nothing
			}
			else 
			{
				cInputText=left_string(cComPStr,find_string(cComPStr,'"',1)-1)
				show_input_text()
			}
		}
		active(find_string(cCompStr,"'(SHU!'",1)):
		{
			remove_string(cCompStr,"'(SHU!'",1)
			switch(atoi(left_string(cCompStr,find_string(cCompStr,')',1)-1)))
			{
				case 1:
				{
					nActiveMute=VD_MUTE_ON
					IF(nCmd = VD_MUTE_ON) cmd_executed()
				}
				case 0:
				{
					nActiveMute=VD_MUTE_OFF
					IF(nCmd = VD_MUTE_OFF) cmd_executed()
				}   
			}
		}
//		active(find_string(cCompStr,cRespStr[VD_MUTE_ON],1)):
//		{
//			nActiveMute=VD_MUTE_ON
//			IF(nCmd = VD_MUTE_ON) cmd_executed()
//		}
//		active(find_string(cCompStr,cRespStr[VD_MUTE_OFF],1)):
//		{
//			nActiveMute=VD_MUTE_OFF
//			IF(nCmd = VD_MUTE_OFF) cmd_executed()
//		}
		active(find_string(cCompStr,"'(CHA!'",1)):
		{
			remove_string(cCompStr,"'(CHA!1'",1)
			for(x=1;x<=4;x++) 
			{
				if(chChannels[x].number=atoi(left_string(cCompStr,find_string(cCompStr,')',1)-1)))
				{
					nActiveChannel=nChan[x]
					if(nCmd=nActiveChannel) cmd_executed()
				}
			}
		}
		active(find_string(cCompStr,"'(LPH!'",1)):
		{
			remove_string(cCompStr,"'(LPH!'",1)
			if(nActiveLampHours=atoi(left_string(cCompStr,find_string(cCompStr,')',1)-1)))
			{
				//Do nothing
			}
			else
			{
				nActiveLampHours=atoi(left_string(cCompStr,find_string(cCompStr,')',1)-1))
				show_lamp_text()
			}
			
		}
	}	
}

define_function update_destination_text()
{
	switch(nActivePower)
	{
		case VD_PWR_ON:
		{
			switch(nActiveLamp)
			{
				case VD_LAMP_OFF:
				{
					send_command dvTP,"'^TXT-',itoa(VD_SOURCE_TEXT),',0,Power On Lamp Off'"
					send_command dvTP,"'^BMF-',itoa(VD_SOURCE_TEXT),',0,%CT LightLime'"
				}
				case VD_LAMP_ON:
				{
					send_command dvTP,"'^TXT-',itoa(VD_SOURCE_TEXT),',0,Full Power On'"
					send_command dvTP,"'^BMF-',itoa(VD_SOURCE_TEXT),',0,%CT LightLime'"
				}
			}
		}
		case VD_PWR_OFF:
		{
			send_command dvTP,"'^TXT-',itoa(VD_SOURCE_TEXT),',0,Off'"
			send_command dvTP,"'^BMF-',itoa(VD_SOURCE_TEXT),',0,%CT LightRed'"
		}
//		case VD_COOLING:
//		{
//			send_command dvTP,"'^TXT-',itoa(VD_SOURCE_TEXT),',0,Cooling Down'"
//			send_command dvTP,"'^BMF-',itoa(VD_SOURCE_TEXT),',0,%CT VeryLightYellow'"
//		}
		case VD_WARMING:
		{
			send_command dvTP,"'^TXT-',itoa(VD_SOURCE_TEXT),',0,Warming Up'"
			send_command dvTP,"'^BMF-',itoa(VD_SOURCE_TEXT),',0,%CT VeryLightYellow'"
		}
	}
}

define_function show_processing_text()
{
	send_command dvTP,"'^TXT-',itoa(VD_SOURCE_TEXT),',0,Processing Command'"
	send_command dvTP,"'^BMF-',itoa(VD_SOURCE_TEXT),',0,%CT Grey8'"

}

define_function show_input_text()
{
	if(nActivePower=VD_PWR_OFF) send_command dvTP,"'^TXT-',itoa(VD_INPUT_TEXT),',0,N/A'"
	else send_command dvTP,"'^TXT-',itoa(VD_INPUT_TEXT),',0,',cInputText"
	send_command dvTP,"'^BMF-',itoa(VD_INPUT_TEXT),',0,%CT Grey8'"
}

define_function show_lamp_text()
{
	send_command dvTP,"'^TXT-',itoa(VD_LAMP_TEXT),',0,',itoa(nActiveLampHours)"
	send_command dvTP,"'^BMF-',itoa(VD_LAMP_TEXT),',0,%CT Grey8'"	
}

define_function show_channel_text()
{
	for(x=1;x<=max_length_array(chChannels);x++) 
	{
		if(chChannels[x].number>0) 
		{
			send_command dvTP,"'^TXT-',itoa(VD_CHAN_NAME[x]),',0,',chChannels[x].name"
			send_command dvTP,"'^TXT-',itoa(VD_CHAN_NUMBER[x]),',0,',itoa(chChannels[x].number)"
		}
		else 
		{
			send_command dvTP,"'^TXT-',itoa(VD_CHAN_NAME[x]),',0,Touch to set Channel'"
			send_command dvTP,"'^TXT-',itoa(VD_CHAN_NUMBER[x]),',0,'"
		}
	}		
}

define_function command_to_display()
{
	switch(nCmd)
	{
		case VD_PWR_ON:
		case VD_PWR_OFF: 
		case VD_LAMP_ON:
		case VD_LAMP_OFF:
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
		case VD_MUTE_ON:
		case VD_MUTE_OFF:
		{
			if(nActiveMute<>nCmd) send_str(dvProj,cCmdStr[nCmd])
			else cmd_executed()
			nPollType=pollMute
		}
		case VD_CHAN_1: 
		{
			if(length_string(itoa(chChannels[1].number))<2) send_str(dvProj,"'(CHA 10',itoa(chChannels[1].number),')'")
			else send_str(dvProj,"'(CHA 1',itoa(chChannels[1].number),')'")                            
			nPollType=pollChannel                                                                          
		}                                                                                             
		case VD_CHAN_2:                                                                                
		{                                                                                             
			if(length_string(itoa(chChannels[2].number))<2) send_str(dvProj,"'(CHA 10',itoa(chChannels[2].number),')'")
			else send_str(dvProj,"'(CHA 1',itoa(chChannels[2].number),')'")                            
			nPollType=pollChannel                                                                             
		}                                                                                             
		case VD_CHAN_3:                                                                                
		{                                                                                             
			if(length_string(itoa(chChannels[3].number))<2) send_str(dvProj,"'(CHA 10',itoa(chChannels[3].number),')'")
			else send_str(dvProj,"'(CHA 1',itoa(chChannels[3].number),')'")                            
			nPollType=pollChannel                                                                             
		}                                                                                             
		case VD_CHAN_4:                                                                                
		{                                                                                             
			if(length_string(itoa(chChannels[4].number))<2) send_str(dvProj,"'(CHA 10',itoa(chChannels[4].number),')'")
			else send_str(dvProj,"'(CHA 1',itoa(chChannels[4].number),')'")                         
			nPollType=pollChannel        
		}

		default:
		{
			send_string 0,"'default command to display'"
			send_str(dvProj,cCmdStr[nCmd])
			cmd_executed()
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

cCmdStr[VD_PWR_ON]			= "'(PWR0)'"		//on
cCmdStr[VD_PWR_OFF]			= "'(PWR3)'"		//off
cCmdStr[VD_LAMP_ON]			= "'(PWR1)'"		//on
cCmdStr[VD_LAMP_OFF]		= "'(PWR0)'"		//on
cCmdStr[VD_COOLING]			= "'(PWR+COOL?)'"
cCmdStr[VD_SRC_DVI1] 		= "'(SIN "DVI-A")'"		//video
cCmdStr[VD_SRC_DVI2]		= "'(SIN "DVI-B")'"		//svideo
cCmdStr[VD_SRC_AUX1]		= "'(SIN "292-A")'"		//input A
cCmdStr[VD_SRC_AUX2]		= "'(SIN "292-B")'"		//input B
cCmdStr[VD_MUTE_ON]			=	"'(SHU 1)'"
cCmdStr[VD_MUTE_OFF]		=	"'(SHU 0)'"

         
cPollStr[pollPower]		=	"'(PWR+STAT?)'"		//pwr
cPollStr[pollInput] 	=	"'(SIN?)'"		//input
cPollStr[pollMute]		=	"'(SHU?)'"
cPollStr[pollLamp]		=	"'(LPH?)'" 	//lamp hours
cPollStr[pollChannel]	=	"'(CHA?)'" 	//Channel

cRespStr[VD_PWR_ON] 		= "'(PWR+STAT!000 "Power On")'"
cRespStr[VD_LAMP_ON] 		= "'(PWR+STAT!001 "Full Power")'"
cRespStr[VD_PWR_OFF]		= "'(PWR+STAT!003 "Power Off")'"
cRespStr[VD_WARMING]		= "'(PWR+STAT!011 "Warm Up")'"
cRespStr[VD_COOLING]		= "'(PWR+STAT!010 "Cooling Down")'"
cRespStr[VD_SRC_DVI1] 		= "'(SIN!003 "DVI-A")'"
cRespStr[VD_SRC_DVI2]		= "'(SIN!004 "DVI-B")'"
cRespStr[VD_SRC_AUX1]		= "'(SIN!000 "292-A")'"
cRespStr[VD_SRC_AUX2]		= "'(SIN!001 "282-B")'"
cRespStr[VD_MUTE_ON]		=	"'(SHU!001)'"
cRespStr[VD_MUTE_OFF]		=	"'(SHU!000)'"

define_start //Channels

for(x=1;x<=4;x++)
{
	if(chChannels[x].number=0) chChannels[x].number=nDefaultChannels[x]
	if(length_string(chChannels[x].name)=0) chChannels[x].name=cDefaultChannelNames[x]
}

define_start //Timelines and Feedback

timeline_create(tlPoll,lPollArray,length_array(lPollArray),TIMELINE_RELATIVE,TIMELINE_REPEAT)

create_buffer vdvProj,cDebugBuffer

send_command vdvProj_FB,"'GET CHANNELS'"

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
		
		//parse(data.text)
		
		//send_string vdvProj,"'String From: ',data.text,$0D"
		cBuff = "cBuff,data.text"
		while(length_string(cBuff))
		{
			select
			{
				active(find_string(cBuff,"')'",1)&& length_string(cHold)):
				{
					nPos=find_string(cBuff,"')'",1)
					cFullStr="cHold,get_buffer_string(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				active(find_string(cBuff,"')'",1)):
				{
					nPos=find_string(cBuff,"')'",1)
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

data_event[vdvProj]
{
	command:
	{
		stack_var nChan
		if(find_string(data.text,"'CHANNAME'",1))
		{
			remove_string(data.text,"'CHANNAME'",1)
			nChan=atoi(left_string(data.text,find_string(data.text,'-',1)-1))
			remove_string(data.text,"'-'",1)
			chChannels[nChan].name=data.text
		}
		else if(find_string(data.text,"'CHANNUMBER'",1))
		{
			remove_string(data.text,"'CHANNUMBER'",1)
			nChan=atoi(left_string(data.text,find_string(data.text,'-',1)-1))
			remove_string(data.text,"'-'",1)
			chChannels[nChan].number=atoi(data.text)
		}
	}
}

data_event[dvTP]
{
	online:
	{
		update_destination_text()
		show_lamp_text()
		show_input_text()
		show_channel_text()
	}
	string:
	{
		if (left_string(data.text,10)='KEYP-ABORT' or left_string(data.text,10)='KEYB-ABORT')
		{
			off[nSetDispChannelNumber]
			off[nSetDispChannelName]
		}
		else if ((left_string(data.text,5)='KEYP-') or (left_string(data.text,4)='AKP-'))
		{
			if (nSetDispChannelNumber)
			{
				if(find_string(data.text,'KEYP-',1)) remove_string(data.text,'KEYP-',1)	//Remove the Prefix
				if(find_string(data.text,'AKP-',1)) remove_string(data.text,'AKP-',1)	//Remove the Prefix
				if (length_string(data.text)>2)	//Max length on the number is 2 characters
				{
					set_length_string(data.text,2)
				}
				chChannels[nSetDispChannelNumber].number=atoi(data.text)
				if(chChannels[nSetDispChannelNumber].number>64) chChannels[nSetDispChannelNumber].number=64
				off[nSetDispChannelNumber]
				show_channel_text()
			}
		}
		else if ((left_string(data.text,5)='KEYB-') or (left_string(data.text,4)='AKB-'))
		{
			if(nSetDispChannelName)
			{
				if(find_string(data.text,'KEYB-',1)) remove_string(data.text,'KEYB-',1)	//Remove the Prefix
				if(find_string(data.text,'AKB-',1)) remove_string(data.text,'AKB-',1)	//Remove the Prefix
				if (length_string(data.text)>30)	//Max length on the number is 30 characters
				{
					set_length_string(data.text,30)
				}
				chChannels[nSetDispChannelName].name=data.text
				nSetDispChannelNumber=nSetDispChannelName
				off[nSetDispChannelName]
				if(chChannels[nSetDispChannelNumber].number>0) send_command dvTP,"'^AKP-',itoa(chChannels[nSetDispChannelNumber].number),';Input Channel Number'" //Pop up the keypad so the user can input a speed dial number				
				else send_command dvTP,"'^AKP-;Input Channel Number'" //Pop up the keypad so the user can input a speed dial number				
			}
		}		
	}
}

timeline_event[tlPoll]		//Display Polling
{	
	switch(timeline.sequence)
	{
		case pollChannel:
		case pollInput:
		case pollMute: 
		{
			if(nActivePower<>VD_PWR_OFF) 
			{
				send_str(dvProj,cPollStr[timeline.sequence])
				nPollType = timeline.sequence
			}
			else
			{
				send_str(dvProj,cPollStr[pollPower])
				nPollType = pollPower
			}
		}
		case pollPower:
		case pollLamp:
		{
			send_str(dvProj,cPollStr[timeline.sequence])
			nPollType = timeline.sequence
		}
	}
	
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
			if(timeline.repetition>5) command_to_display()  //This means we don't spam it with the change until we've given it enough time to respond to the
															//first attempt, then we start trying a little more aggressively.
		}
	}
}

timeline_event[tlCooling]
{
	stack_var integer nMinutes
	stack_var integer nSeconds
	
	if(timeline.repetition=0) send_command dvTP,"'^BMF-',itoa(VD_SOURCE_TEXT),',0,%CT VeryLightYellow'"
	
	nCalculatedCoolingTime--
	nMinutes=nCalculatedCoolingTime/60
	nSeconds=nCalculatedCoolingTime-(nMinutes*60)
	if(nSeconds<10) send_command dvTP,"'^TXT-',itoa(VD_SOURCE_TEXT),',0,Cooling Down ',itoa(nMinutes),':0',itoa(nSeconds)"
	else send_command dvTP,"'^TXT-',itoa(VD_SOURCE_TEXT),',0,Cooling Down ',itoa(nMinutes),':',itoa(nSeconds)"
	if(nCalculatedCoolingTime=0) timeline_kill(tlCooling)
}

channel_event[vdvProj,0]
{
	on:
	{
		nCmd=channel.channel
		switch(nCmd)
		{
			case VD_MUTE_ON:
			case VD_MUTE_OFF:
			{
				if(nActiveMute<>nCmd) 
				{
					show_processing_text()
					command_to_display()
					if(nCmd) start_command_timeline()
					nPollType=pollMute
				}
				else cmd_executed()
			}
			case VD_PWR_ON:
			case VD_PWR_OFF:
			case VD_LAMP_ON:
			case VD_LAMP_OFF:
			{
				if(nActivePower<>VD_COOLING) 
				{
					show_processing_text()
					command_to_display()
					if(nCmd) start_command_timeline()
				}
			}
			default:
			{
				show_processing_text()
				command_to_display()
				if(nCmd) start_command_timeline()
			}
		}
		
	}
}

button_event[dvTP,0]
{
	push:
	{
		to[button.input]
		switch(button.input.channel)
		{
			case VD_CHAN_1_NAME:
			case VD_CHAN_2_NAME:
			case VD_CHAN_3_NAME:
			case VD_CHAN_4_NAME: {}
			default: to[vdvProj,button.input.channel]
		}
	}
	hold[15]:
	{
		switch(button.input.channel)
		{
			case VD_CHAN_1_NAME:
			case VD_CHAN_2_NAME:
			case VD_CHAN_3_NAME:
			case VD_CHAN_4_NAME: 
			{
				nSetDispChannelName=button.input.channel-VD_CHAN_1_NAME+1
				send_command button.input.device,"'^AKB-',chChannels[nSetDispChannelName].name,';Input Channel Name'" //Pop up the keypad so the user can input a speed dial number
			}
		}
	}
	release:
	{
		stack_var nI
		switch(button.input.channel)
		{
			case VD_CHAN_1_NAME:
			case VD_CHAN_2_NAME:
			case VD_CHAN_3_NAME:
			case VD_CHAN_4_NAME: 
			{
				if(!nSetDispChannelName)
				{
					nI=button.input.channel-VD_CHAN_1_NAME+1
					if(chChannels[nI].number=0)
					{
						nSetDispChannelName=nI
						send_command button.input.device,"'^AKB-',chChannels[nSetDispChannelName].name,';Input Channel Name'" //Pop up the keypad so the user can input a speed dial number
					}
					else pulse[vdvProj,VD_CHAN[nI]]
				}
			}
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


