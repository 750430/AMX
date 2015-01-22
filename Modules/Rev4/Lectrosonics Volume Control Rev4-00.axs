MODULE_NAME='Lectrosonics Volume Control Rev4-00'(DEV vdvTP[], DEV vdvMXR[], DEV dvMXR)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//'SET BAUD 9600,N,8,1,485 DISABLE'
//DEFINE_MODULE 'Lectrosonics Volume Control Rev4-00' mxr1(vdvTP_VOL,vdvMXR,dvMixer) 

#INCLUDE 'HoppSNAPI Rev4-01.axi'
#INCLUDE 'HoppSTRUCT Rev4-02.axi'

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

INTEGER VolBar	=	1
INTEGER MuteBtn	=	3

INTEGER VolUp = 1
INTEGER VolDn = 2
INTEGER MteTog = 3
INTEGER MteOff = 5
INTEGER MteOn = 6
INTEGER VolUpRmp = 7
INTEGER VolDnRmp = 8

LONG lFB	 		= 2000 		//Timeline for feedback
LONG lFBVol		= 2001		//Timeline for volume up/down

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLBLOCK MXR_VOL[20]

INTEGER nAMXLvl

INTEGER btn_VOL[] = {1,2,3,4,5,6}

SINTEGER nLvlVal[20]
INTEGER nLvlFB
INTEGER nLvlStep
INTEGER nMteVal[20]

CHAR MXR_Buff[255]
CHAR cMteStr[20][100]
CHAR cLvlStr[20][100]
CHAR cGainStr[20][100]

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
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

DEFINE_CALL 'READ_MIXER'
{
	LOCAL_VAR	LONG lPos
	LOCAL_VAR	SLONG slReturn
	LOCAL_VAR	SLONG slFile
	LOCAL_VAR	SLONG slResult
	LOCAL_VAR	CHAR sBINString[10000]
	// Read Binary File
	slFile = FILE_OPEN('BinaryMXREncode.xml',1)
	slResult = FILE_READ(slFile, sBINString, MAX_LENGTH_STRING(sBINString))
	slResult = FILE_CLOSE (slFile)
	// Convert To Binary
	lPos = 1
	slReturn = STRING_TO_VARIABLE(MXR_VOL, sBINString, lPos)	
}


DEFINE_FUNCTION OnPush(INTEGER nLVL, INTEGER nIndex)
{
	SWITCH(nIndex)
	{
		CASE VolUp:
		{			
			IF(nMteVal[nLvl]) 
			{
				nMteVal[nLvl] = 0
				SEND_STRING dvMXR,"cMteStr[nLvl],'0',$0D"
			}
			IF(nLvlVal[nLvl] < (MXR_VOL[nLvl].max - MXR_VOL[nLvl].ramp))	nLvlVal[nLvl] = nLvlVal[nLvl] + MXR_VOL[nLvl].ramp
			ELSE nLvlVal[nLvl] = MXR_VOL[nLvl].max
			SEND_STRING dvMXR,"cGainStr[nLvl],ITOA(nLvlVal[nLvl]),$0D"				
		}
		CASE VolDn: 
		{	
			IF(nMteVal[nLvl]) 
			{
				nMteVal[nLvl] = 0
				SEND_STRING dvMXR,"cMteStr[nLvl],'0',$0D"
			}
			IF(nLvlVal[nLvl] > (MXR_VOL[nLvl].min + MXR_VOL[nLvl].ramp))	nLvlVal[nLvl] = nLvlVal[nLvl] - MXR_VOL[nLvl].ramp
			ELSE nLvlVal[nLvl] = MXR_VOL[nLvl].min
			SEND_STRING dvMXR,"cGainStr[nLvl],ITOA(nLvlVal[nLvl]),$0D"
		}
		CASE MteTog: 
		{
			nMteVal[nLvl] = !nMteVal[nLvl]
			SEND_STRING dvMXR,"cMteStr[nLvl],ITOA(nMteVal[nLvl]),$0D,$0A" 
		}
		CASE MteOff: 
		{
			nMteVal[nLvl] = 0		
			SEND_STRING dvMXR,"cMteStr[nLvl],'0',$0D" 
		}
		CASE MteOn: 
		{
			nMteVal[nLvl] = 1
			SEND_STRING dvMXR,"cMteStr[nLvl],'1',$0D" 
		}
		CASE VolUpRmp:
		{			
			IF(nLvlVal[nLvl] < MXR_VOL[nLvl].max)	nLvlVal[nLvl]++
			ELSE nLvlVal[nLvl] = MXR_VOL[nLvl].max
			SEND_STRING dvMXR,"cGainStr[nLvl],ITOA(nLvlVal[nLvl]),$0D"				
		}
		CASE VolDnRmp: 
		{	
			IF(nLvlVal[nLvl] > MXR_VOL[nLvl].min)	nLvlVal[nLvl]--
			ELSE nLvlVal[nLvl] = MXR_VOL[nLvl].min
			SEND_STRING dvMXR,"cGainStr[nLvl],ITOA(nLvlVal[nLvl]),$0D"
		}		
	}
	nAMXLvl = ABS_VALUE((255*(nLvlVal[nLvl]-MXR_VOL[nLvl].min))/(MXR_VOL[nLvl].max-MXR_VOL[nLvl].min))
	SEND_LEVEL vdvTP[nLvl],VolBar,nAMXLvl	
}

DEFINE_CALL 'INIT_STRINGS'
{
	STACK_VAR INTEGER X
	FOR (X=1; X<21; X++)
	{
		cMteStr[X]="MXR_VOL[X].type,'mt(',MXR_VOL[X].chan,')='"
		cLvlStr[X]="MXR_VOL[X].type,'gn(',MXR_VOL[X].chan,')?'"
		cGainStr[X]="MXR_VOL[X].type,'gn(',MXR_VOL[X].chan,')='"
		nLvlVal[X] = (MXR_VOL[X].max + MXR_VOL[X].min)/2
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

CREATE_BUFFER dvMXR, MXR_Buff

WAIT 20
{
  CALL 'READ_MIXER'
	CALL 'INIT_STRINGS'
}

TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvMXR]														// Data Event For Extron Switcher
{
	ONLINE:
	{
		SEND_COMMAND dvMXR,"'SET BAUD 9600,N,8,1,485 DISABLE'"		
	}
}

CHANNEL_EVENT[vdvMXR,0]
{
	ON:	OnPush((GET_LAST(vdvMXR)),channel.channel)	
}

BUTTON_EVENT [vdvTP, btn_VOL]
{
	PUSH:		ON[vdvMXR[GET_LAST(vdvTP)],(GET_LAST(btn_VOL))]
	HOLD[2,REPEAT]:	
	{	
		OFF[vdvMXR[GET_LAST(vdvTP)],(GET_LAST(btn_VOL))]
		PULSE[vdvMXR[GET_LAST(vdvTP)],(GET_LAST(btn_VOL)+6)]
	}
	RELEASE:	
	{
		OFF[vdvMXR[GET_LAST(vdvTP)],(GET_LAST(btn_VOL))]	
		OFF[vdvMXR[GET_LAST(vdvTP)],(GET_LAST(btn_VOL)+6)]
	}
}

TIMELINE_EVENT[lFB]
{
	STACK_VAR INTEGER X	
	FOR(X=1; X<=20; X++)
	{
		[vdvTP[X], MuteBtn] = nMteVal[X]
		[vdvTP[X], 5] = !(nMteVal[X])
		[vdvTP[X], 6] = nMteVal[X]
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

