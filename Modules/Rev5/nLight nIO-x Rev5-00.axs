MODULE_NAME='nLight nIO-x Rev5-00'(DEV dvTP, DEV dvLights)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
//SET BAUD 115200,N,8,1 485 DISABLE
//define_module 'nLight nIO-x Rev5-00' LIGHTS1(vdvTP_LIGHT1,dvLights,nLightingAddr)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
LONG lFB	 		= 2000 		//Timeline for feedback
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
INTEGER btnScenes[] = {1,2,3,4}
INTEGER btnAllUp = 10
INTEGER btnAllDn = 11
INTEGER nScene
CHAR cResp[100]
integer x

char cBuffer[100]

LONG lFBArray[] = {100}						//.1 seconds
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
//TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvLights]
{
	STRING:
	{
//		if(find_string(cBuffer,"':ss '",1) and find_string(cBuffer,"$0D,$0A",find_string(cBuffer,"':ss '",1)))
//		{
//			remove_string(cBuffer,"':ss '",1)
//			cResp=MID_STRING(cBuffer,nAddr,1)
//			SELECT
//			{
//				ACTIVE (cResp = '0'):nScene = 0
//				ACTIVE (cResp = '1'):nScene = 1
//				ACTIVE (cResp = '2'):nScene = 2
//				ACTIVE (cResp = '3'):nScene = 3
//				ACTIVE (cResp = '4'):nScene = 4
//				ACTIVE (cResp = '5'):nScene = 5
//				ACTIVE (cResp = '6'):nScene = 6
//				ACTIVE (cResp = '7'):nScene = 7
//				ACTIVE (cResp = '8'):nScene = 8
//			}
//		}
	}
}

BUTTON_EVENT[dvTP, btnScenes]//call scenes
{
	PUSH:
	{
		to[button.input]
		nScene=get_last(btnScenes)
		switch(nScene)
		{
			case 1: send_string dvLights,"$A5,$06,$85,$01,$DF,$F8"
			case 2: send_string dvLights,"$A5,$06,$85,$02,$DF,$FB"
			case 3: send_string dvLights,"$A5,$06,$85,$03,$DF,$FA"
			case 4: send_string dvLights,"$A5,$06,$85,$04,$DF,$FD"
		}
	}
}

button_event[dvTP,btnAllUp]
{
	push:
	{
		to[button.input]
		send_string dvLights,"$A5,$08,$7A,$01,$01,$00,$21,$F6"
	}
}

button_event[dvTP,btnAllDn]
{
	push:
	{
		to[button.input]
		send_string dvLights,"$A5,$08,$7A,$01,$02,$00,$22,$F6"
	}
}

TIMELINE_EVENT[lFB]
{
	//for(x=1;x<=4;x++) [dvTP, btnScenes[x]]=nScene=x
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


