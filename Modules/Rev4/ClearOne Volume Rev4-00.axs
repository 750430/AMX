MODULE_NAME='ClearOne Volume Rev4-00'(DEV vdvTP[], DEV vdvXAP[], DEV dvXAP)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/19/2008  AT: 14:19:23        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
//volume up 	= button/channel 1
//volume dwn 	= button/channel 2
//mute 				= button/channel 3
//query 			= button/channel 4
//mute off 		= button/channel 5
//mute on 		= button/channel 6

//PSR1212 =40
//XAP800	=50
//TH2			=60
//XAP400	=70


VOL[1].addr = '40' 			//Address of XAP unit
VOL[1].type = 'P'			//I=Input, O=Output, P=Process, M=Mic
VOL[1].chan = 'A'			//Channel to be controlled
VOL[1].min	= -30			//Min level
VOL[1].max	= 0				//Max level
VOL[1].ramp = 10			//Ramp time (dB/s)

VOL[2].addr = '40' 			//Address of XAP unit
VOL[2].type = 'P'			//I=Input, O=Output, P=Process, M=Mic
VOL[2].chan = 'B'			//Channel to be controlled
VOL[2].min	= -30			//Min Level
VOL[2].max	= 0				//Max Level
VOL[2].ramp = 10			//Ramp time (db/s)


define_module 'ClearOne Volume Rev4-00' mxr1(vdvTP_VOL,vdvMXR,dvClearOne)
*)

#INCLUDE 'HoppSNAPI Rev4-01.axi'
#INCLUDE 'HoppSTRUCT Rev4-00.axi'

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

slong nLvlVal[20]
INTEGER nLvlFB
INTEGER nLvlStep
INTEGER nMteVal[20]

CHAR XAP_Buff[255]
CHAR cMteStr[20][100]
CHAR cLvlStr[20][100]
CHAR cGainStr[20][100]

char cJeffString[20][10]

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


DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nPos
	STACK_VAR INTEGER nAMXLvl
	STACK_VAR INTEGER nLvl
	FOR (nLvl=1; nLvl<21; nLvl++)
	{
		SELECT
		{
			ACTIVE(FIND_STRING(cCompStr,cGainStr[nLvl],1)):
			{
				remove_string(cCompStr,cGainStr[nLvl],1)
				nPos=FIND_STRING(cCompStr,'.',1)
				nLvlVal[nLvl]=ATOI(GET_BUFFER_STRING(cCompStr,nPos-1))
				IF(nLvlVal[nLvl]<MXR_VOL[nLvl].min) nLvlVal[nLvl]=MXR_VOL[nLvl].min
				ELSE IF(nLvlVal[nLvl]>MXR_VOL[nLvl].max) nLvlVal[nLvl]=MXR_VOL[nLvl].max
				nAMXLvl=ABS_VALUE((255*(nLvlVal[nLvl]-MXR_VOL[nLvl].min))/(MXR_VOL[nLvl].max-MXR_VOL[nLvl].min))
				SEND_LEVEL vdvTP[nLvl],VolBar,nAMXLvl
			}
			ACTIVE(FIND_STRING(cCompStr,cMteStr[nLvl],1)):
			{
				REMOVE_STRING(cCompStr,cMteStr[nLvl],1)
				nPos=FIND_STRING(cCompStr,"$0D",1)
				nMteVal[nLvl]=ATOI(GET_BUFFER_STRING(cCompStr,nPos-1))
				[vdvXAP[nLvl],256]=nMteVal[nLvl]
			}
		}
	}
}

DEFINE_FUNCTION OnPush(INTEGER nLVL, INTEGER nIndex)
{
	SWITCH(nIndex)
	{
		CASE MIX_VOL_UP:
		{			
			IF(nMteVal[nLvl]) SEND_STRING dvXAP,"cMteStr[nLvl],'0',$0D,$0A"
			SEND_STRING dvXAP,"cLvlStr[nLvl],ITOA(MXR_VOL[nLVL].ramp),$20,ITOA(MXR_VOL[nLVL].max),$0D,$0A"				
			
		}
		CASE MIX_VOL_DN: 
		{	
			IF(nMteVal[nLvl]) SEND_STRING dvXAP,"cMteStr[nLvl],'0',$0D,$0A"
			SEND_STRING dvXAP,"cLvlStr[nLvl],'-',ITOA(MXR_VOL[nLVL].ramp),$20,ITOA(MXR_VOL[nLVL].min),$0D,$0A"	
		}
		CASE MIX_MUTE_TOG: 
		{
			nMteVal[nLvl] = !nMteVal[nLvl]
			SEND_STRING dvXAP,"cMteStr[nLvl],ITOA(nMteVal[nLvl]),$0D,$0A" 
		}
		CASE MIX_QUERY: 
		{
			send_string dvXAP,"cGainStr[nLvl],$0D,$0A"
			send_string dvXAP,"cMteStr[nLvl],$0D,$0A"
		}
		CASE MIX_MUTE_OFF: SEND_STRING dvXAP,"cMteStr[nLvl],'0',$0D,$0A" 
		CASE MIX_MUTE_ON: SEND_STRING dvXAP,"cMteStr[nLvl],'1',$0D,$0A" 
	}
}

DEFINE_FUNCTION OffRelease(INTEGER nLVL, INTEGER nIndex)
{
	SWITCH(nIndex)
	{
		CASE 1: SEND_STRING dvXAP, "cLvlStr[nLvl],'0',$0D,$0A"
		CASE 2: SEND_STRING dvXAP, "cLvlStr[nLvl],'0',$0D,$0A"
	}
	wait 5 send_string dvXAP,"cGainStr[nLvl],$0D,$0A"
	wait 20 send_string dvXAP,"cGainStr[nLvl],$0D,$0A"
}

DEFINE_CALL 'INIT_STRINGS'
{
	STACK_VAR INTEGER X
	FOR (X=1; X<21; X++)
	{
		cMteStr[X]="'#',MXR_VOL[X].addr,$20,'MUTE',$20,MXR_VOL[X].chan,$20,MXR_VOL[X].type,$20"
		cLvlStr[X]="'#',MXR_VOL[X].addr,$20,'RAMP',$20,MXR_VOL[X].chan,$20,MXR_VOL[X].type,$20"
		if (mxr_vol[x].type='I') cGainStr[X]="'#',MXR_VOL[X].addr,$20,'GAIN',$20,MXR_VOL[X].chan,$20,'M',$20"
		else cGainStr[X]="'#',MXR_VOL[X].addr,$20,'GAIN',$20,MXR_VOL[X].chan,$20,MXR_VOL[X].type,$20"
	}
}



(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

CREATE_BUFFER dvXAP, XAP_Buff

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

DATA_EVENT [dvXAP] 
{ 
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cFullStr[100]
		STACK_VAR INTEGER nPos	
		//this accounts for multiple strings in XAP_Buff
		//or receiving partial string(s) 
		WHILE(LENGTH_STRING(XAP_Buff))
		{
			SELECT
			{
				ACTIVE(FIND_STRING(XAP_Buff,"$0A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(XAP_Buff,"$0A",1)
					cFullStr="cHold,GET_BUFFER_STRING(XAP_Buff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(XAP_Buff,"$0A",1)):
				{
					nPos=FIND_STRING(XAP_Buff,"$0A",1)
					cFullStr=GET_BUFFER_STRING(XAP_Buff,nPos)
					Parse(cFullStr)
				}
				ACTIVE(1):
				{
					cHold="cHold,XAP_Buff"
					XAP_Buff=''
				}
			}
		}
  }
}   

CHANNEL_EVENT[vdvXAP,0]
{
	ON:		OnPush((GET_LAST(vdvXAP)),channel.channel)
	OFF:	OffRelease((GET_LAST(vdvXAP)),channel.channel)
}

BUTTON_EVENT [vdvTP, btn_VOL]
{
	PUSH:		
	{
		switch(button.input.channel)
		{
			case MIX_VOL_UP:
			case MIX_VOL_DN:
			{
				to[button.input]
			}
		}
		ON[vdvXAP[GET_LAST(vdvTP)],(GET_LAST(btn_VOL))]
	}
	RELEASE:	OFF[vdvXAP[GET_LAST(vdvTP)],(GET_LAST(btn_VOL))]
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
