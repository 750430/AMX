MODULE_NAME='Lutron QSE-CL-NWK-E Rev5-00'(DEV dvTP, DEV dvLights, CHAR cAddr[])
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
//define_module 'Lutron QSE-CL-NWK-E Rev5-00' LIGHTS1(vdvTP_LIGHT1,dvLights,nLightingAddr)
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
INTEGER btnScenes[] = {1,2,3,4,5,6,7,8,9}
INTEGER btn_AllUp = 10
INTEGER btn_AllDn = 11
INTEGER nScene
CHAR cResp[100]

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
TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvLights]
{
	STRING:
	{
		if(find_string(cBuffer,"'141,7,0'",1)) nScene = 0
		if(find_string(cBuffer,"'141,7,1'",1)) nScene = 1
		if(find_string(cBuffer,"'141,7,2'",1)) nScene = 2
		if(find_string(cBuffer,"'141,7,3'",1)) nScene = 3
		if(find_string(cBuffer,"'141,7,4'",1)) nScene = 4
		if(find_string(cBuffer,"'141,7,5'",1)) nScene = 5
		if(find_string(cBuffer,"'141,7,6'",1)) nScene = 6
		if(find_string(cBuffer,"'141,7,7'",1)) nScene = 7
		if(find_string(cBuffer,"'141,7,8'",1)) nScene = 8		
		
//		if(find_string(cBuffer,"'141,7,'",1) and find_string(cBuffer,"$0D,$0A",find_string(cBuffer,"'141,7,'",1)))
//		{
//			remove_string(cBuffer,"'141,7,'",1)
//			cResp=MID_STRING(cBuffer,$0D,1)
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
    TO[dvTP,BUTTON.INPUT.CHANNEL]
    SELECT
		{
		ACTIVE(GET_LAST(btnScenes) = 9):
		{
			SEND_STRING dvlights,"'#DEVICE,0x',cAddr,',141,7,0',$0D" 
		}
		ACTIVE (GET_LAST(btnScenes)):  
		{
			SEND_STRING dvlights,"'#DEVICE,0x0',cAddr,',141,7,',ITOA(GET_LAST(btnScenes)),$0D"
		}
    }    
  }
}

TIMELINE_EVENT[lFB]
{
	[dvTP, btnScenes[1]] = (nScene = 1)
	[dvTP, btnScenes[2]] = (nScene = 2)
	[dvTP, btnScenes[3]] = (nScene = 3)
	[dvTP, btnScenes[4]] = (nScene = 4)
	[dvTP, btnScenes[5]] = (nScene = 5)
	[dvTP, btnScenes[6]] = (nScene = 6)
	[dvTP, btnScenes[7]] = (nScene = 7)
	[dvTP, btnScenes[8]] = (nScene = 8)
	[dvTP, btnScenes[9]] = (nScene = 0)
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


