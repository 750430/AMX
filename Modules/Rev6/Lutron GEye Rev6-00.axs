MODULE_NAME='Lutron GEye Rev6-00'(dev dvTP[], dev vdvLights, dev vdvLightsFB, dev dvLights, integer nAddr)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
//SET BAUD 9600,N,8,1 485 DISABLE
//define_module 'Lutron GEye Rev6-00' LIGHTS1(dvTP_LIGHT[1],vdvLIGHT1,vdvLIGHT1_FB,dvLights,nLightingAddr)
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
	online:
	{
		send_string dvLights,"':G',$0D"
	}
	STRING:
	{
		send_string 0,"'string received'"
		if(find_string(data.text,"'A'",1) and find_string(data.text,"$0D,$0A",1))
		{
			send_string 0,"'find string A and CRLF'"
			remove_string(data.text,"'A'",1)
			send_string 0,"'string removed'"
			cResp=left_string(data.text,find_string(data.text,"$0D",1)-1)
			send_string 0,"'cResp=',cResp"
			SELECT
			{
				ACTIVE (cResp = '0'):nScene = 0
				ACTIVE (cResp = '1'):nScene = 1
				ACTIVE (cResp = '2'):nScene = 2
				ACTIVE (cResp = '3'):nScene = 3
				ACTIVE (cResp = '4'):nScene = 4
				ACTIVE (cResp = '5'):nScene = 5
				ACTIVE (cResp = '6'):nScene = 6
				ACTIVE (cResp = '7'):nScene = 7
				ACTIVE (cResp = '8'):nScene = 8
			}
		}
		else if(find_string(data.text,"':ss '",1) and find_string(data.text,"$0D,$0A",1))
		{
			remove_string(data.text,"':ss '",1)
			cResp=left_string(data.text,1)
			SELECT
			{
				ACTIVE (cResp = '0'):nScene = 0
				ACTIVE (cResp = '1'):nScene = 1
				ACTIVE (cResp = '2'):nScene = 2
				ACTIVE (cResp = '3'):nScene = 3
				ACTIVE (cResp = '4'):nScene = 4
				ACTIVE (cResp = '5'):nScene = 5
				ACTIVE (cResp = '6'):nScene = 6
				ACTIVE (cResp = '7'):nScene = 7
				ACTIVE (cResp = '8'):nScene = 8
			}
		}
	}
}

BUTTON_EVENT[dvTP, btnScenes]//call scenes
{
	PUSH:
	{
		TO[dvTP,BUTTON.INPUT.CHANNEL]
		nScene=get_last(btnScenes)
		SELECT
		{
			ACTIVE(nScene = 9):
			{
				SEND_STRING dvlights,"':A0',ITOA(nAddr),$0D" 
			}
			ACTIVE (nScene):  
			{	
				SEND_STRING dvlights,"':A',ITOA(nScene),ITOA(nAddr),$0D"
			}
		}    
	}
	release:
	{
		wait 50 send_string dvLights,"':G',$0D"
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
	[dvTP, btnScenes[9]] = (nScene = 0) or (nScene = 9)
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


