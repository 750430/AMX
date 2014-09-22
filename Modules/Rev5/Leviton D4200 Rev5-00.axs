MODULE_NAME='Leviton D4200 Rev5-00'(DEV dvTP, DEV dvLights, INTEGER nAddr)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
//SET BAUD 9600,N,8,1 485 DISABLE
//define_module 'Leviton D4200 Rev5-00' LIGHTS1(vdvTP_LIGHT1,dvLights,nLightingAddr)
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
INTEGER btnScenes[] = {1,2,3,4,5,6,7,8,9,10}
INTEGER btn_AllUp = 10
INTEGER btn_AllDn = 11
INTEGER nScene
CHAR cResp[100]
char cAddr[5]

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
		if(find_string(cBuffer,"'P'",1) and find_string(cBuffer,"$0D",find_string(cBuffer,"'P'",1)))
		{
			remove_string(cBuffer,"'P'",1)
			cResp=left_string(cBuffer,find_string(cBuffer,'@',1)-1)
			remove_string(cBuffer,"'@'",1)
			cAddr=left_string(cBuffer,find_string(cBuffer,"$0D",1)-1)
			if (cAddr=itoa(nAddr))
			{
				SELECT
				{
					ACTIVE (cResp = '1'):nScene = 1
					ACTIVE (cResp = '2'):nScene = 2
					ACTIVE (cResp = '3'):nScene = 3
					ACTIVE (cResp = '4'):nScene = 4
					ACTIVE (cResp = '5'):nScene = 5
					ACTIVE (cResp = '6'):nScene = 6
					ACTIVE (cResp = '7'):nScene = 7
					ACTIVE (cResp = '8'):nScene = 8
					ACTIVE (cResp = '18'):nScene=0
					active (cResp = '17'):nScene=9
					ACTIVE (1):nScene=0
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
		SELECT
		{
			ACTIVE(GET_LAST(btnScenes) = 9):
			{
				SEND_STRING dvlights,"'P18@',ITOA(nAddr),$0D,$0A" 
			}
			active(get_last(btnScenes)=10):
			{
				SEND_STRING dvlights,"'P17@',ITOA(nAddr),$0D,$0A" 
			}
			ACTIVE (GET_LAST(btnScenes)):  
			{
				SEND_STRING dvlights,"'P',ITOA(GET_LAST(btnScenes)),'@',ITOA(nAddr),$0D,$0A"
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
	[dvTP, btnScenes[10]] = (nScene = 9)
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)



