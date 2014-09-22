MODULE_NAME='Sony VISCA Cam Rev6-00' (DEV vdvTP[], DEV vdvCAM[])
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/09/2008  AT: 11:24:09        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                  
Rev 4-01: Add Pan/Tilt/Zoom speed control
                          *)
(***********************************************************)

//Sony VISCA Cameras should be be set at 9600,N,8,1,485 DISABLE
//define_module 'Sony VISCA Cam Rev6-00' CAM1(vdvTP_CAM,vdvCAM)

#INCLUDE 'HoppSTRUCT Rev6-00.axi'
#INCLUDE 'HoppSNAPI Rev6-00.axi'
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
 
CAMERA SONY_CAM[10] 

DEV dvCAM[10] 

INTEGER btn_CTRL[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}
integer btn_lvl[]	=	{31,32,33}
integer lvlMain[]	=	{1,2,3}

integer nLevelActive[3]
integer nActiveLevel

CHAR cPTZPre[66][16]

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

DEFINE_CALL 'READ_CAMERA'
{
	STACK_VAR INTEGER X
	LOCAL_VAR	LONG lPos
	LOCAL_VAR	SLONG slReturn
	LOCAL_VAR	SLONG slFile
	LOCAL_VAR	SLONG slResult
	LOCAL_VAR	CHAR sBINString[10000]
	
	// Read Binary File
	slFile = FILE_OPEN('BinaryCAMEncode.xml',1)
	slResult = FILE_READ(slFile, sBINString, MAX_LENGTH_STRING(sBINString))
	slResult = FILE_CLOSE (slFile)
	// Convert To Binary
	lPos = 1
	slReturn = STRING_TO_VARIABLE(SONY_CAM, sBINString, lPos)
	FOR(X=1; X<=10; X++)
	{
		IF(!(SONY_CAM[X].addr = 0))  dvCAM[X] = SONY_CAM[X].dvCAM
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

wait 200 CALL 'READ_CAMERA'

cPTZPre[CAM_UP] 		= "$03,$01,$FF"
cPTZPre[CAM_DOWN] 		= "$03,$02,$FF"
cPTZPre[CAM_LEFT]		= "$01,$03,$FF"
cPTZPre[CAM_RIGHT]		= "$02,$03,$FF"
cPTZPre[CAM_PRESET1]	= "$00"
cPTZPre[CAM_PRESET2]	= "$01"
cPTZPre[CAM_PRESET3]	= "$02"
cPTZPre[CAM_PRESET4]	= "$03"
cPTZPre[CAM_PRESET5]	= "$04"
cPTZPre[CAM_PRESET6]	= "$05"

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
//		SEND_COMMAND SONY_CAM[nCAM].dvCAM,"'SET BAUD 9600,N,8,1,485 DISABLE'"
//		SEND_STRING SONY_CAM[nCAM].dvCAM,"$81,$01,$04,$38,$02,$FF"
//	}
//}

DATA_EVENT [dvCAM]											// Vaddio Camera
{
	ONLINE:
	{
		wait 100
		{
			SEND_STRING data.device,"$81,$01,$04,$38,$02,$FF"
		}
	}
}

BUTTON_EVENT [vdvTP, 0]				
{
  PUSH:
  {
		STACK_VAR INTEGER nCTRL
		to[button.input]
		
		nCTRL = button.input.channel
		IF(!(nCTRL >= CAM_PRESET1 && nCTRL <= CAM_PRESET6))		ON[vdvCAM[GET_LAST(vdvTP)],button.input.channel]
  }
	HOLD[30]:
	{
		STACK_VAR INTEGER nCTRL
		STACK_VAR INTEGER addr
		STACK_VAR INTEGER nCAM
		
		nCAM = GET_LAST(vdvTP)
		addr = SONY_CAM[nCAM].addr + 128
		
		nCTRL = button.input.channel
		IF(nCTRL >= CAM_PRESET1 && nCTRL <= CAM_PRESET6)
		{
			SEND_STRING SONY_CAM[nCAM].dvCAM, "addr,$01,$04,$3F,$01,cPTZPre[nCTRL],$FF"
			SEND_COMMAND vdvTP[nCAM],"'ABEEP'"
		}
	}
  RELEASE:
  {
		STACK_VAR INTEGER nCAM	
		STACK_VAR INTEGER nCTRL
		STACK_VAR INTEGER addr
		
		nCTRL = button.input.channel
		nCAM = GET_LAST(vdvTP)	
		addr = SONY_CAM[nCAM].addr + 128		
		OFF[vdvCAM[GET_LAST(vdvTP)],button.input.channel]
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
					SEND_STRING SONY_CAM[nCAM].dvCAM, "addr,$01,$04,$3F,$02,cPTZPre[nCTRL],$FF"
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

level_event[vdvTP,lvlMain]
{
	nActiveLevel=get_last(lvlMain)
	if(nLevelActive[nActiveLevel])
	{
		switch(nActiveLevel)
		{
			case CAM_PAN_LVL: SONY_CAM[get_last(vdvTP)].pan=level.value*24/255
			case CAM_TILT_LVL: SONY_CAM[get_last(vdvTP)].tilt=level.value*20/255
			case CAM_ZOOM_LVL: SONY_CAM[get_last(vdvTP)].zoom=level.value*8/255
		}
	}
}


CHANNEL_EVENT[vdvCAM, 0]
{
  ON:
  {
		STACK_VAR INTEGER nCAM
		STACK_VAR INTEGER nPTZPre
		STACK_VAR INTEGER addr
		STACK_VAR INTEGER pan_speed
		STACK_VAR INTEGER tilt_speed
		STACK_VAR INTEGER zoom_speed
		
		
		nCAM = GET_LAST(vdvCAM)
		nPTZPre = CHANNEL.CHANNEL
		addr = SONY_CAM[nCAM].addr + 128
		pan_speed = SONY_CAM[nCAM].pan
		tilt_speed = SONY_CAM[nCAM].tilt
		
		if(SONY_CAM[nCam].addr=0) CALL 'READ_CAMERA'
		
		SWITCH(nPTZPre)
		{
			CASE CAM_HOME: SEND_STRING SONY_CAM[nCAM].dvCAM, "addr,$01,$06,$04,$FF"
			CASE CAM_UP:
			CASE CAM_DOWN:
			CASE CAM_LEFT:
			CASE CAM_RIGHT:
			{
				SEND_STRING SONY_CAM[nCAM].dvCAM, "addr,$01,$06,$01,pan_speed,tilt_speed,cPTZPre[nPTZPre]"
			}
			CASE CAM_ZOOM_IN: 
			{
				zoom_speed = SONY_CAM[nCAM].zoom + 32
				SEND_STRING SONY_CAM[nCAM].dvCAM, "addr,$01,$04,$07,zoom_speed,$FF"
			}			
			CASE CAM_ZOOM_OUT:	
			{
				zoom_speed = SONY_CAM[nCAM].zoom + 48			
				SEND_STRING SONY_CAM[nCAM].dvCAM, "addr,$01,$04,$07,zoom_speed,$FF"
			}
			CASE CAM_PRESET1:
			CASE CAM_PRESET2:
			CASE CAM_PRESET3:
			CASE CAM_PRESET4:
			CASE CAM_PRESET5:
			CASE CAM_PRESET6:
			{
				SEND_STRING SONY_CAM[nCAM].dvCAM, "addr,$01,$04,$3F,$02,cPTZPre[nPTZPre],$FF"
			}
		}
  }
  OFF:
  {
		STACK_VAR INTEGER nCAM
		STACK_VAR INTEGER nPTZPre
		STACK_VAR INTEGER addr
		STACK_VAR INTEGER pan_speed
		STACK_VAR INTEGER tilt_speed
		nCAM = GET_LAST(vdvCAM)
		nPTZPre = CHANNEL.CHANNEL
		addr = SONY_CAM[nCAM].addr + 128
		pan_speed = SONY_CAM[nCAM].pan
		tilt_speed = SONY_CAM[nCAM].tilt
		
		SWITCH(nPTZPre)
		{
			CASE CAM_UP:
			CASE CAM_DOWN:
			CASE CAM_LEFT:
			CASE CAM_RIGHT:
			{			
				SEND_STRING SONY_CAM[nCAM].dvCAM, "addr,$01,$06,$01,pan_speed,tilt_speed,$03,$03,$FF"
			}
			CASE CAM_ZOOM_IN: 	
			CASE CAM_ZOOM_OUT:	
			{
				SEND_STRING SONY_CAM[nCAM].dvCAM, "addr,$01,$04,$07,$00,$FF"			
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
