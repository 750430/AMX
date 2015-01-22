MODULE_NAME='Lutron GEye LIUNA Rev4-00'(DEV dvTP, DEV dvLights, INTEGER nAddr)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
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
INTEGER btn_SCENES0to4[] = {1,2,3,4,5}
INTEGER btn_AllUp = 6
INTEGER btn_AllDn = 7
INTEGER nScene
CHAR cResp[100]

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

//TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvLights]
{
	ONLINE:
	{
		SEND_COMMAND dvLights, 'SET BAUD 9600,N,8,1'
		WAIT 1 SEND_COMMAND dvLights,'RXON'
		WAIT 2 SEND_COMMAND dvLights,'HSOFF'
	}
	STRING:
	{
		cResp = MID_STRING(DATA.TEXT,(nAddr+4),1)
		SELECT
		{
			ACTIVE (cResp = '0'):nScene = 0
			ACTIVE (cResp = '1'):nScene = 1
			ACTIVE (cResp = '2'):nScene = 2
			ACTIVE (cResp = '3'):nScene = 3
			ACTIVE (cResp = '4'):nScene = 4
		}
	}
}

BUTTON_EVENT[dvTP, btn_SCENES0to4]//call scenes
{
	PUSH:
  {
    TO[dvTP,BUTTON.INPUT.CHANNEL]
    SELECT
		{
		ACTIVE(GET_LAST(btn_SCENES0to4) = 5):
		{
			SEND_STRING dvlights,"':A0',ITOA(nAddr),$0D" 
			wait 2 SEND_STRING dvlights,"':A0',ITOA(nAddr+1),$0D" 
		}
		ACTIVE (GET_LAST(btn_SCENES0to4)):  
		{
			SEND_STRING dvlights,"':A',ITOA(GET_LAST(btn_SCENES0to4)),ITOA(nAddr),$0D"
			wait 2 SEND_STRING dvlights,"':A',ITOA(GET_LAST(btn_SCENES0to4)),ITOA(nAddr+1),$0D"
		}
    }    
  }
}

TIMELINE_EVENT[lFB]
{
	[dvTP, btn_SCENES0to4[1]] = (nScene = 1)
	[dvTP, btn_SCENES0to4[2]] = (nScene = 2)
	[dvTP, btn_SCENES0to4[3]] = (nScene = 3)
	[dvTP, btn_SCENES0to4[4]] = (nScene = 4)
	[dvTP, btn_SCENES0to4[5]] = (nScene = 0)
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

