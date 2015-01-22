MODULE_NAME='Polycom Vortex Volume Rev4-00'(DEV vdvTP[], DEV vdvVTX[], DEV dvVTX)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
define_module 'Polycom Vortex Volume Rev4-00' mxr1(vdvTP_VOL,vdvMXR,dvVortex)
9600,N,8,1
*)

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

INTEGER VolUp 	= 1
INTEGER VolDn 	= 2
INTEGER MuteTog = 3
INTEGER Query		= 4
INTEGER MuteOff = 5
INTEGER MuteOn	= 6

INTEGER VolBar	=	1
INTEGER MuteBtn	=	3

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

INTEGER btn_VOL[] = {1,2,3,4,5,6}

INTEGER nVol
INTEGER nVolCh
SINTEGER nLvlVal[20]
INTEGER nLvlFB
INTEGER nMteVal[20]

CHAR cAud_Buff[255]
CHAR cAud_Resp[255]

CHAR cMteStr[20][100]
CHAR cLvlStr[20][100]
CHAR cGainStr[20][100]

LONG lFBArray[] = {100}						//.1 seconds
LONG lFBVolArray[][] = {{0},{0},{0},{0},{0},{0},{0},{0},{0},{0},
											 {0},{0},{0},{0},{0},{0},{0},{0},{0},{0}}
											 
										 
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

DEFINE_FUNCTION	SLONG nAMXLvl(INTEGER nVolLvl)
{
	STACK_VAR SLONG nRange
	STACK_VAR SLONG nNumerator
	STACK_VAR SLONG nResult
	
	nRange	= MXR_VOL[nVolLvl].max - MXR_VOL[nVolLvl].min
	nNumerator = 255* (nLvlVal[nVolLvl] - MXR_VOL[nVolLvl].min)
	nResult = (nNumerator -(nNumerator%nRange))/nRange
	
	RETURN nResult
}

DEFINE_FUNCTION OnPush(INTEGER nLVL, INTEGER nIndex)
{
	SWITCH(nIndex)
	{
		CASE VolUp:
		CASE VolDn: 
		{	
			IF(nMteVal[nLvl]) 
			{
				SEND_STRING dvVTX,"cMteStr[nLvl],'0',$0D,$0A"
				nMteVal[nLvl] = 0
			}
			TIMELINE_CREATE(lFBVol,lFBVolArray[nLvl],1,TIMELINE_RELATIVE,TIMELINE_REPEAT)	
		}
		CASE MuteTog: 
		{
			nMteVal[nLvl] = !nMteVal[nLvl]
			SEND_STRING dvVTX,"cMteStr[nLvl],ITOA(nMteVal[nLvl]),$0D" 
		}
		CASE Query: 
		{
			SEND_STRING dvVTX,"cLvlStr[nLvl]"
		}
		CASE MuteOff: SEND_STRING dvVTX,"cMteStr[nLvl],'0',$0D" 
		CASE MuteOn: SEND_STRING dvVTX,"cMteStr[nLvl],'1',$0D" 
	}
}

DEFINE_FUNCTION OffRelease(INTEGER nLVL, INTEGER nIndex)
{
	SWITCH(nIndex)
	{
		CASE VolUp: 
		CASE VolDn:
		{
			TIMELINE_KILL(lFBVol)
		}
	}
}

DEFINE_CALL 'INIT_STRINGS'
{
	STACK_VAR INTEGER X
	FOR (X=1; X<=20; X++)
	{
		SELECT
		{
			ACTIVE(FIND_STRING(MXR_VOL[X].type,"'I'",1)):
			{
				cMteStr[X] = "MXR_VOL[X].addr,'MUTEI',MXR_VOL[X].chan"
				cLvlStr[X] = "MXR_VOL[X].addr,'FADERI',MXR_VOL[X].chan"
				cGainStr[X] = "MXR_VOL[X].addr,'FADERI',MXR_VOL[X].chan,'?',$0D"
			}
			ACTIVE(FIND_STRING(MXR_VOL[X].type,"'O'",1)):
			{
				cMteStr[X] = "MXR_VOL[X].addr,'MUTEO',MXR_VOL[X].chan"
				cLvlStr[X] = "MXR_VOL[X].addr,'GAINO',MXR_VOL[X].chan"
				cGainStr[X] = "MXR_VOL[X].addr,'GAINO',MXR_VOL[X].chan,'?',$0D"
			}	
			ACTIVE(FIND_STRING(MXR_VOL[X].type,"'MX'",1)):
			{
				cMteStr[X] = "MXR_VOL[X].addr,'MMUTE',MXR_VOL[X].chanin,',',MXR_VOL[X].chanout,','"
				cLvlStr[X] = "MXR_VOL[X].addr,'MGAIN',MXR_VOL[X].chanin,',',MXR_VOL[X].chanout,','"
				cGainStr[X] = "MXR_VOL[X].addr,'MGAIN',MXR_VOL[X].chanin,',',MXR_VOL[X].chanout,',?',$0D"
			}				
		}
	}
}



(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

CREATE_BUFFER dvVTX, cAUD_BUFF

WAIT 20
{
  CALL 'READ_MIXER'
	CALL 'INIT_STRINGS'
	FOR (X=1; X<=20; X++)
	{
		lFBVolArray[X][1] = 1000/MXR_VOL[X].ramp
		nLvlVal[X] = (MXR_VOL[X].max + MXR_VOL[X].min)/2
		SEND_LEVEL vdvTP[X],1,nAMXLvl(X)	
	}
}

TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT [dvVTX] 
{ 
	ONLINE:
	{
    SEND_COMMAND dvVTX, "'SET BAUD 9600,N,8,1'"
		SEND_COMMAND dvVTX, "'RXON'"
		SEND_COMMAND dvVTX, "'HSOFF'"
	}
	STRING:
	{
		cAUD_BUFF="cAUD_BUFF,DATA.TEXT"
		cAUD_RESP=REMOVE_STRING(cAUD_BUFF,"$0D",1)
		SELECT
		{
			ACTIVE(FIND_STRING(cAUD_RESP,"'BLDATA'",1)): 
			{
//			  SEND_STRING dvAUD,"'B00BLAUTO0',$0D"
//				SEND_STRING dvAUD,"'F01BLAUTO0',$0D"
//				SEND_STRING dvAUD,"'F02BLAUTO0',$0D"
//				SEND_STRING dvAUD,"'F03BLAUTO0',$0D"
			}	
			ACTIVE(1):cAUD_BUFF=''
		}	
	}   
}

CHANNEL_EVENT[vdvVTX,0]
{
	ON:		
	{
		nVol = GET_LAST(vdvVTX)
		nVolCh = channel.channel
		OnPush((GET_LAST(vdvVTX)),channel.channel)
	}
	OFF:	OffRelease((GET_LAST(vdvVTX)),channel.channel)
}

BUTTON_EVENT [vdvTP, btn_VOL]
{
	PUSH:		ON[vdvVTX[GET_LAST(vdvTP)],(GET_LAST(btn_VOL))]
	RELEASE:	OFF[vdvVTX[GET_LAST(vdvTP)],(GET_LAST(btn_VOL))]
}

TIMELINE_EVENT[lFBVol]
{
	STACK_VAR CHAR cGain[4]
	STACK_VAR SINTEGER nMax
	STACK_VAR SINTEGER nMin
	
	nMax = MXR_VOL[nVolCh].max	
	nMin = MXR_VOL[nVolCh].min
	SWITCH(nVolCh)
	{
		CASE VolUp:		
		{
			IF(!(nLvlVal[nVol] = nMax))  nLvlVal[nVol]++
			ELSE  nLvlVal[nVol] = nMax
			cGain = "ITOA(nLvlVal[nVol])"			
		}
		CASE VolDn: 	
		{
			IF(!(nLvlVal[nVol] = nMin))  nLvlVal[nVol]--
			ELSE	nLvLVal[nVol] = nMin
			cGain = "ITOA(nLvlVal[nVol])"
		}
	}
	SEND_STRING dvVTX, "cLvLStr[nVol],cGain,$0D"
	SEND_LEVEL vdvTP[nVol],1,nAMXLvl(nVol)
}

TIMELINE_EVENT[lFB]
{
	STACK_VAR INTEGER X	
	FOR(X=1; X<21; X++)
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