MODULE_NAME='Lutron QSE-CL-NWK-E Rev5-02'(DEV dvTP[], dev vdvLights, DEV dvLights, CHAR cAddr[])
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
//define_module 'Lutron QSE-CL-NWK-E Rev5-02' LIGHTS1(dvTP_LIGHT[1],vdvLIGHT1,dvLights,cLightingAddr)

#include 'HoppSNAPI Rev5-11.axi'
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
LONG lFB	 		= 2000 		//Timeline for feedback

shdUp			=	1
shdDown			=	2
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
INTEGER btnScenes[] = {LIGHTS_PRESET_1,LIGHTS_PRESET_2,LIGHTS_PRESET_3,LIGHTS_PRESET_4,LIGHTS_PRESET_5,LIGHTS_PRESET_6,LIGHTS_PRESET_7,LIGHTS_PRESET_8,LIGHTS_OFF}
INTEGER btnShadesUp[]	=	{LIGHTS_SHADE1_UP,LIGHTS_SHADE2_UP,LIGHTS_SHADE3_UP}
INTEGER btnShadesDown[]	=	{LIGHTS_SHADE1_DOWN,LIGHTS_SHADE2_DOWN,LIGHTS_SHADE3_DOWN}
INTEGER nScene
CHAR cResp[100]

non_volatile		integer		nActiveShadePos[3]

integer	x

char cBuffer[100]

LONG lFBArray[] = {100}						//.1 seconds

persistent	char	cPresetNames[9][30]
volatile	integer	nSetPresetName

volatile	integer	nScenePressed
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,"'login'",1)): send_string dvLights,"'nwk',$0D,$0A"	
		active(find_string(cCompStr,"'141,7,'",1)):
		{	
			remove_string(cCompStr,"'141,7,'",1)
			nScene=atoi(left_string(cCompStr,1))
		}
		active(find_string(cCompStr,"cAddr,',38,4'",1)): nActiveShadePos[1]=shdUp
		active(find_string(cCompStr,"cAddr,',40,4'",1)): nActiveShadePos[1]=shdDown
	}
	
	
	//if(find_string(cCompStr,"'141,7,0'",1)) nScene = 0
//	if(find_string(cCompStr,"'141,7,1'",1)) nScene = 1
//	if(find_string(cCompStr,"'141,7,2'",1)) nScene = 2
//	if(find_string(cCompStr,"'141,7,3'",1)) nScene = 3
//	if(find_string(cCompStr,"'141,7,4'",1)) nScene = 4
//	if(find_string(cCompStr,"'141,7,5'",1)) nScene = 5
//	if(find_string(cCompStr,"'141,7,6'",1)) nScene = 6
//	if(find_string(cCompStr,"'141,7,7'",1)) nScene = 7
//	if(find_string(cCompStr,"'141,7,8'",1)) nScene = 8	
}

define_function update_preset_text()
{
	for(x=1;x<=9;x++) 
	{
		if(length_string(cPresetNames[x])>0) 
		{
			send_command dvTP,"'^TXT-',itoa(btnScenes[x]),',0,',cPresetNames[x]"
			send_command dvTP,"'^BMF-',itoa(btnScenes[x]),',0,%F21'"
		}
		else if(x<9) 
		{
			send_command dvTP,"'^TXT-',itoa(btnScenes[x]),',0,',itoa(x)"
			send_command dvTP,"'^BMF-',itoa(btnScenes[x]),',0,%F22'"
		}
		else if(x=9) 
		{
			send_command dvTP,"'^TXT-',itoa(btnScenes[x]),',0,Off'"
			send_command dvTP,"'^BMF-',itoa(btnScenes[x]),',0,%F22'"
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
//create_buffer dvLights,cBuffer
TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvLights]
{
	ONLINE:
	{
		send_string dvLights,"'?INTEGRATIONID,1,',cAddr,',',$0D,$0A"
	}
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cBuff[255]
		LOCAL_VAR CHAR cFullStr[100]
		STACK_VAR INTEGER nPos
		
		parse(data.text)
		
//		cBuff = "cBuff,data.text"
//		WHILE(LENGTH_STRING(cBuff))
//		{
//			SELECT
//			{
//				ACTIVE(FIND_STRING(cBuff,"$0A",1)&& LENGTH_STRING(cHold)):
//				{
//					nPos=FIND_STRING(cBuff,"$0A",1)
//					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
//					Parse(cFullStr)
//					cHold=''
//				}
//				ACTIVE(FIND_STRING(cBuff,"$0A",1)):
//				{
//					nPos=FIND_STRING(cBuff,"$0A",1)
//					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
//					Parse(cFullStr)
//				}
//				ACTIVE(1):
//				{
//					cHold="cHold,cBuff"
//					cBuff=''
//				}
//			}
//		}
	}
}    

data_event[vdvLIGHTS]
{
	string:
	{
		stack_var cTPResponse[65]
		cTPResponse=data.text
		if (left_string(cTPResponse,10)='KEYP-ABORT' or left_string(cTPResponse,10)='KEYB-ABORT')
		{
			//ignore, the user aborted the process
		}
		else if (left_string(cTPResponse,5)='KEYP-')
		{
			//do nothing
		}
		else if (left_string(cTPResponse,5)='KEYB-')
		{
			if(nSetPresetName)
			{
				remove_string(cTPResponse,'KEYB-',1) //Remove the Prefix
				if (length_string(cTPResponse)>30)	//Max length on the number is 10 characters
				{
					set_length_string(cTPResponse,30)
				}
				cPresetNames[nSetPresetName]=cTPResponse
				update_preset_text()
			}
		}
		off[nSetPresetName]
	}
}

data_event[dvTP]
{
	online:
	{
		update_preset_text()
	}
}


BUTTON_EVENT[dvTP, btnScenes]//call scenes
{
	PUSH:
	{
		TO[button.input]
		nScenePressed=get_last(btnScenes)
	}
	HOLD[10]:
	{
		nSetPresetName=get_last(btnScenes)
		send_command button.input.device,"'@AKB-',cPresetNames[nSetPresetName],';Enter Preset Name'" //Pop up the keypad so the user can input a speed dial number
	}
	release:
	{
		if(!nSetPresetName) pulse[vdvLights,button.input.channel]
		off[nScenePressed]
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
				SEND_STRING dvlights,"'#DEVICE,0x0',cAddr,',141,7,',ITOA(channel.channel),$0D"
				nScene=channel.channel
			}
			case LIGHTS_OFF:
			{
				SEND_STRING dvlights,"'#DEVICE,0x',cAddr,',141,7,0',$0D" 
				nScene=0
			}			
			case LIGHTS_SHADE1_UP: send_string dvLights,"'#DEVICE,0x',cAddr,',38,4',$0D"
			case LIGHTS_SHADE1_DOWN: send_string dvLights,"'#DEVICE,0x',cAddr,',40,4',$0D"
			case LIGHTS_SHADE2_UP: send_string dvLights,"'#DEVICE,0x',cAddr,',44,4',$0D"
			case LIGHTS_SHADE2_DOWN: send_string dvLights,"'#DEVICE,0x',cAddr,',46,4',$0D"
			case LIGHTS_SHADE3_UP: send_string dvLights,"'#DEVICE,0x',cAddr,',50,4',$0D"
			case LIGHTS_SHADE3_DOWN: send_string dvLights,"'#DEVICE,0x',cAddr,',56,4',$0D"
		}
    }	
}

TIMELINE_EVENT[lFB]
{
	for(x=1;x<=8;x++) if(nScenePressed<>x) [dvTP, btnScenes[x]] = (nScene = x)
	if(nScenePressed<>9) [dvTP, btnScenes[9]] = (nScene = 0)
	
	for(x=1;x<=max_length_array(btnShadesUp);x++) [dvTP,btnShadesUp[x]]=nActiveShadePos[x]=shdUp
	for(x=1;x<=max_length_array(btnShadesDown);x++) [dvTP,btnShadesDown[x]]=nActiveShadePos[x]=shdDown
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


