module_name='Lutron QSE-CL-NWK-E Rev6-00'(dev dvTP[], dev vdvLights, dev vdvLightsFB, dev dvLights, char cAddr[])
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/11/2012  AT: 10:17:56        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
//SET BAUD 9600,N,8,1 485 DISABLE
//define_module 'Lutron QSE-CL-NWK-E Rev6-00' lights1(dvTP_LIGHT[1],vdvLIGHT1,vdvLIGHT1_FB,dvLights,cLightingAddr)

//define_variable //Lighting
//
//volatile	char	cLightingAddr[] = '00bdea33'

#include 'HoppSNAPI Rev6-00.axi'
#include 'HoppDEBUG Rev6-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //Flags
shdUp			=	1
shdDown			=	2

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable //Buttons

integer 	btnScenes[] 		= {LIGHTS_PRESET_1,LIGHTS_PRESET_2,LIGHTS_PRESET_3,LIGHTS_PRESET_4,LIGHTS_PRESET_5,LIGHTS_PRESET_6,LIGHTS_PRESET_7,LIGHTS_PRESET_8,LIGHTS_OFF}
integer 	btnShadesUp[]		= {LIGHTS_SHADE1_UP,LIGHTS_SHADE2_UP,LIGHTS_SHADE3_UP}
integer 	btnShadesDown[]		= {LIGHTS_SHADE1_DOWN,LIGHTS_SHADE2_DOWN,LIGHTS_SHADE3_DOWN}

define_variable //Active Variables

integer 	nActiveScene
integer		nActiveShadePos[3]

define_variable //Other Variables

integer		x

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function parse(char cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,"'login'",1)): send_string dvLights,"'nwk',$0D,$0A"	
		active(find_string(cCompStr,"'141,7,'",1)):
		{	
			remove_string(cCompStr,"'141,7,'",1)
			nActiveScene=atoi(left_string(cCompStr,1))
		}
		active(find_string(cCompStr,"cAddr,',38,4'",1)): nActiveShadePos[1]=shdUp
		active(find_string(cCompStr,"cAddr,',40,4'",1)): nActiveShadePos[1]=shdDown
		active(find_string(cCompStr,"cAddr,',44,4'",1)): nActiveShadePos[2]=shdUp
		active(find_string(cCompStr,"cAddr,',46,4'",1)): nActiveShadePos[2]=shdDown
		active(find_string(cCompStr,"cAddr,',50,4'",1)): nActiveShadePos[3]=shdUp
		active(find_string(cCompStr,"cAddr,',56,4'",1)): nActiveShadePos[3]=shdDown
	}                                    
}


define_function tp_fb()
{
	for(x=LIGHTS_PRESET_1;x<=LIGHTS_PRESET_8;x++) [dvTP,btnScenes[x]]=nActiveScene=x
	[dvTP,btnScenes[LIGHTS_OFF]]=nActiveScene=0
	
	for(x=1;x<=max_length_array(btnShadesUp);x++) [dvTP,btnShadesUp[x]]=nActiveShadePos[x]=shdUp
	for(x=1;x<=max_length_array(btnShadesDown);x++) [dvTP,btnShadesDown[x]]=nActiveShadePos[x]=shdDown	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
define_event //Data Events

data_event[dvLights]
{
	online:
	{
		send_str(dvLights,"'?INTEGRATIONID,1,',cAddr,',',$0D,$0A")
	}
	string:
	{
		add_to_debug(data.text,strFrom)
		parse(data.text)
	}
}    

define_event //Button Events

button_event[dvTP,btnScenes] //call scenes
{
	PUSH:
	{
		to[button.input]
		pulse[vdvLights,button.input.channel]
	}
}

button_event[dvTP,btnShadesUp]
{
	push:
	{
		nActiveShadePos[get_last(btnShadesUp)]=shdUp
		pulse[vdvLights,button.input.channel]
	}
}

button_event[dvTP,btnShadesDown]
{
	push:
	{
		nActiveShadePos[get_last(btnShadesDown)]=shdDown
		pulse[vdvLights,button.input.channel]
	}
}



define_event //Channel Events

channel_event[vdvLights,0]
{
	on:
	{
		switch(channel.channel)
		{
			case LIGHTS_PRESET_1:
			case LIGHTS_PRESET_2:
			case LIGHTS_PRESET_3:
			case LIGHTS_PRESET_4:
			case LIGHTS_PRESET_5:
			case LIGHTS_PRESET_6:
			case LIGHTS_PRESET_7:
			case LIGHTS_PRESET_8:
			{                
				send_str(dvLights,"'#DEVICE,0x0',cAddr,',141,7,',ITOA(channel.channel),$0D")
				nActiveScene=channel.channel
			}
			case LIGHTS_OFF:
			{
				send_str(dvLights,"'#DEVICE,0x',cAddr,',141,7,0',$0D")
				nActiveScene=0
			}			
			case LIGHTS_SHADE1_UP: 		send_str(dvLights,"'#DEVICE,0x',cAddr,',38,4',$0D")
			case LIGHTS_SHADE1_DOWN: 	send_str(dvLights,"'#DEVICE,0x',cAddr,',40,4',$0D")
			case LIGHTS_SHADE2_UP: 		send_str(dvLights,"'#DEVICE,0x',cAddr,',44,4',$0D")
			case LIGHTS_SHADE2_DOWN: 	send_str(dvLights,"'#DEVICE,0x',cAddr,',46,4',$0D")
			case LIGHTS_SHADE3_UP: 		send_str(dvLights,"'#DEVICE,0x',cAddr,',50,4',$0D")
			case LIGHTS_SHADE3_DOWN: 	send_str(dvLights,"'#DEVICE,0x',cAddr,',56,4',$0D")
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


