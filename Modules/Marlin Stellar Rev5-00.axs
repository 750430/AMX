MODULE_NAME='Marlin Stellar Rev5-00'(DEV dvTP, DEV dvLights)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
//SET BAUD 9600,N,8,1 485 DISABLE
//define_module 'Marlin Stellar Rev5-00' LIGHTS1(vdvTP_LIGHT1,dvLights)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
LONG lFB	 		= 2000 		//Timeline for feedback

INTEGER btnScenes[] = {1,2,3,4,5,6,7,8}
integer btnLights[]	=	{1,2,3,4,5,6,7,8,9,10}

btnOn			=	10
btnOff			=	9
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE


INTEGER btn_AllUp = 10
INTEGER btn_AllDn = 11
INTEGER nScene
CHAR cResp[100]
integer x

char cBuffer[100]

LONG lFBArray[] = {100}						//.1 seconds

volatile		integer		nLightCommand
persistent		integer		nActiveLight
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
create_buffer dvLights,cBuffer
TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvLights]
{
	STRING:
	{
		select
		{
			active(find_string(data.text,"'OK: 0'",1)):
			{
				if(nLightCommand) nActiveLight=nLightCommand
			}
			active(find_string(data.text,"'Recall Preset'",1)):
			{
				remove_string(data.text,"'Recall Preset '",1)
				select
				{
					active(find_string(data.text,"'ON'",1)):
					{ 
						nActiveLight=btnOn
					}
					active(find_string(data.text,"'OFF'",1)):
					{
						nActiveLight=btnOff
					}
					active(1):
					{
						nActiveLight=atoi(left_string(data.text,1))
					}
				}
			}
		}
	}
}

BUTTON_EVENT[dvTP, btnScenes]//call scenes
{
	PUSH:
	{
		TO[dvTP,BUTTON.INPUT.CHANNEL]
		SEND_STRING dvlights,"'recall #',ITOA(get_last(btnScenes)),$0D,$0A" 
		nLightCommand=get_last(btnScenes)
		cancel_wait 'Light Command'
		wait 10 'Light Command' off[nLightCommand]		
	}
}

button_event[dvTP,btnOn]
button_event[dvTP,btnOff]
{
	push:
	{
		switch(button.input.channel)
		{
			case btnOn: 
			{
				nLightCommand=btnOn
				SEND_STRING dvlights,"'recall ON',$0D,$0A"
			}
			case btnOff: 
			{
				nLightCommand=btnOff
				SEND_STRING dvlights,"'recall OFF',$0D,$0A"
			}
		}
		cancel_wait 'Light Command'
		wait 10 'Light Command' off[nLightCommand]
	}
}

TIMELINE_EVENT[lFB]
{
	for(x=1;x<=length_array(btnLights);x++) [dvTP, btnLights[x]]=nActiveLight=x
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


