MODULE_NAME='Canon VC-C50i Cam Rev5-00' (DEV vdvTP, DEV vdvCAM, DEV dvCAM)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:24:09        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                  

                          *)
(***********************************************************)

//Sony VISCA Cameras should be be set at 9600,N,8,1,485 DISABLE
//define_module 'Canon VC-C50i Cam Rev5-00' CAM1(vdvTP_CAM[1],vdvCAM1,dvCam)

#INCLUDE 'HoppSTRUCT Rev5-00.axi'
#INCLUDE 'HoppSNAPI Rev5-00.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT
//PAN_SPEED                  (* 1-$18, $18 IS MAX *)
//TILT_SPEED                 (* 1-$14, $14 IS MAX *)
//ZOOM_SPEED                 (* 1-8, 8 IS MAX *)  
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE
 
//CAMERA PAN_CAM[10] 

INTEGER btn_CTRL[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}
integer btn_lvl[]	=	{31,32,33}
integer lvlMain[]	=	{1,2,3}

integer nLevelActive[3]
integer nActiveLevel

CHAR cPTZPre[25][16]

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
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

//DEFINE_CALL 'READ_CAMERA'
//{
//	STACK_VAR INTEGER X
//	LOCAL_VAR	LONG lPos
//	LOCAL_VAR	SLONG slReturn
//	LOCAL_VAR	SLONG slFile
//	LOCAL_VAR	SLONG slResult
//	LOCAL_VAR	CHAR sBINString[10000]
//	// Read Binary File
//	slFile = FILE_OPEN('BinaryCAMEncode.xml',1)
//	slResult = FILE_READ(slFile, sBINString, MAX_LENGTH_STRING(sBINString))
//	slResult = FILE_CLOSE (slFile)
//	// Convert To Binary
//	lPos = 1
//	slReturn = STRING_TO_VARIABLE(PAN_CAM, sBINString, lPos)
//	FOR(X=1; X<=10; X++)
//	{
//		IF(!(PAN_CAM[X].addr = 0))  dvCAM[X] = PAN_CAM[X].dvCAM
//	}
//}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
//
//CALL 'READ_CAMERA'

cPTZPre[CAM_UP] 		= "$33,$EF"
cPTZPre[CAM_DOWN] 		= "$34,$EF"
cPTZPre[CAM_LEFT]		= "$32,$EF"
cPTZPre[CAM_RIGHT]		= "$31,$EF"
cPTZPre[CAM_PRESET1]	= "$31"
cPTZPre[CAM_PRESET2]	= "$32"
cPTZPre[CAM_PRESET3]	= "$33"
cPTZPre[CAM_PRESET4]	= "$34"
cPTZPre[CAM_PRESET5]	= "$35"
cPTZPre[CAM_PRESET6]	= "$36"

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

//DATA_EVENT [vdvCAM]											// Vaddio Camera
//{
//	ONLINE:
//	{
//		STACK_VAR INTEGER nCAM
//		nCAM = GET_LAST(vdvTP)
//		SEND_COMMAND PAN_CAM[nCAM].dvCAM,"'SET BAUD 9600,N,8,1,485 DISABLE'"
//		SEND_STRING PAN_CAM[nCAM].dvCAM,"$81,$01,$04,$38,$02,$FF"
//	}
//}

DATA_EVENT [dvCAM]											// Vaddio Camera
{
	ONLINE:
	{
		wait 100
		{
			SEND_STRING data.device,"$FF,$30,$30,$00,$90,$30,$EF"		//Home
		}
	}
	string:
	{
		if(find_string(data.text,"$FE,$30,$30,$39,$30,$EF",1))
		{
			send_string data.device,"$FF,$30,$30,$00,$90,$30,$EF"
		}
	}
}

BUTTON_EVENT [vdvTP, btn_CTRL]				
{
  PUSH:
  {
		STACK_VAR INTEGER nCTRL
		to[button.input]
		nCTRL = GET_LAST(btn_CTRL)
		IF(!(nCTRL >= CAM_PRESET1 && nCTRL <= CAM_PRESET6))		ON[vdvCAM,GET_LAST(btn_CTRL)]
  }
	HOLD[30]:
	{
		STACK_VAR INTEGER nCTRL
		
		nCTRL = GET_LAST(btn_CTRL)	
		IF(nCTRL >= CAM_PRESET1 && nCTRL <= CAM_PRESET6)
		{
			SEND_STRING dvCAM, "$FF,$30,$30,$00,$89,cPTZPre[nCTRL],$EF"
			SEND_COMMAND vdvTP,"'ABEEP'"
		}
	}
  RELEASE:
  {
		STACK_VAR INTEGER nCAM	
		STACK_VAR INTEGER nCTRL
		STACK_VAR INTEGER addr
		
		nCTRL = GET_LAST(btn_CTRL)
		OFF[vdvCAM,GET_LAST(btn_CTRL)]
		IF(nCTRL >= CAM_PRESET1 && nCTRL <= CAM_PRESET6)	
		{
			SWITCH(nCTRL)
			{
				CASE CAM_PRESET1:
				CASE CAM_PRESET2:
				CASE CAM_PRESET3:
				CASE CAM_PRESET4:
				CASE CAM_PRESET5:
				CASE CAM_PRESET6:
				{
					SEND_STRING dvCAM, "$FF,$30,$30,$00,$8A,cPTZPre[nCTRL],$EF"
				}
			}
		}
  }
}

button_event[vdvTP,btn_lvl]
{
	push:
	{
		to[button.input]
		to[nLevelActive[get_last(btn_lvl)]]
	}
}

//level_event[vdvTP,lvlMain]
//{
//	nActiveLevel=get_last(lvlMain)
//	if(nLevelActive[nActiveLevel])
//	{
//		switch(nActiveLevel)
//		{
//			case CAM_PAN_LVL: PAN_CAM[get_last(vdvTP)].pan=level.value*24/255
//			case CAM_TILT_LVL: PAN_CAM[get_last(vdvTP)].tilt=level.value*20/255
//			case CAM_ZOOM_LVL: PAN_CAM[get_last(vdvTP)].zoom=level.value*8/255
//		}
//	}
//}


CHANNEL_EVENT[vdvCAM, 0]
{
  ON:
  {
		STACK_VAR INTEGER nCAM
		STACK_VAR INTEGER nPTZPre
		
		nCAM = GET_LAST(vdvCAM)
		nPTZPre = CHANNEL.CHANNEL
		
		SWITCH(nPTZPre)
		{
			CASE CAM_HOME: 	SEND_STRING dvCam,"$FF,$30,$30,$00,$57,$EF"		//Home
			CASE CAM_UP:
			CASE CAM_DOWN:
			CASE CAM_LEFT:
			CASE CAM_RIGHT:
			{
				SEND_STRING dvCAM, "$FF,$30,$30,$00,$53,cPTZPre[nPTZPre]"
			}
			CASE CAM_ZOOM_IN: 
			{
//				zoom_speed = PAN_CAM[nCAM].zoom + 32
				SEND_STRING dvCAM, "$FF,$30,$30,$00,$A2,$32,$EF"
			}			
			CASE CAM_ZOOM_OUT:	
			{
//				zoom_speed = PAN_CAM[nCAM].zoom + 48			
				SEND_STRING dvCAM, "$FF,$30,$30,$00,$A2,$31,$EF"
			}
			CASE CAM_PRESET1:
			CASE CAM_PRESET2:
			CASE CAM_PRESET3:
			CASE CAM_PRESET4:
			CASE CAM_PRESET5:
			CASE CAM_PRESET6:
			{
				SEND_STRING dvCAM, "$FF,$30,$30,$00,$8A,cPTZPre[nPTZPre],$EF"
			}
		}
  }
  OFF:
  {
		STACK_VAR INTEGER nPTZPre
		
		nPTZPre = CHANNEL.CHANNEL
//		addr = PAN_CAM[nCAM].addr + 128
//		pan_speed = PAN_CAM[nCAM].pan
//		tilt_speed = PAN_CAM[nCAM].tilt
//		
		SWITCH(nPTZPre)
		{
			CASE CAM_UP:
			CASE CAM_DOWN:
			CASE CAM_LEFT:
			CASE CAM_RIGHT:
			{			
				SEND_STRING dvCAM, "$FF,$30,$30,$00,$53,$30,$EF"
			}
			CASE CAM_ZOOM_IN: 	
			CASE CAM_ZOOM_OUT:	
			{
				SEND_STRING dvCAM, "$FF,$30,$30,$00,$A2,$30,$EF"			
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
