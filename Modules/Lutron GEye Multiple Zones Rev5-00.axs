MODULE_NAME='Lutron GEye Multiple Zones Rev5-00'(DEV dvTP, DEV dvLights, char cAddr[])
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
//SET BAUD 9600,N,8,1 485 DISABLE
//define_module 'Lutron GEye Multiple Zones Rev5-00' LIGHTS1(vdvTP_LIGHT1,dvLights,cLightingAddr)
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
		stack_var integer x
		stack_var integer y
		stack_var char z
		
		z=cAddr[1]
		y=atoi(z)
		send_string 0,"'Y=',itoa(y)"
		if(find_string(cBuffer,"':ss '",1) and find_string(cBuffer,"$0D,$0A",find_string(cBuffer,"':ss '",1)))
		{
			remove_string(cBuffer,"':ss'",1)
			for(x=1;x<=3;x++)	
			{
				z=get_buffer_char(cBuffer)
				send_string 0,"itoa(x),':',z"
				
			}
			cResp=LEFT_STRING(cBuffer,1)
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
				SEND_STRING dvlights,"':A0',cAddr,$0D"
				nScene=0
			}
			ACTIVE (GET_LAST(btnScenes)):  
			{
				SEND_STRING dvlights,"':A',ITOA(GET_LAST(btnScenes)),cAddr,$0D"
				nScene=get_last(btnScenes)
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


