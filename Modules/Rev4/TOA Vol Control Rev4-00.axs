MODULE_NAME='TOA Vol Control Rev4-00'(DEV vdvTP[], DEV vdvMixer[], DEV dvMixer)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/29/2008  AT: 11:53:24        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*----------------MODULE INSTRUCTIONS----------------------*)
(*

	In your program, do these operations - 

	1) 	Use include files as specified below:


	#INCLUDE 'HoppSNAPI.axi'		//Required
	#INCLUDE 'HoppSTRUCT.axi'		//Required
	#INCLUDE 'HoppDEV.axi'			//Optional


	2)	In DEFINE_START, fill in VOL structure as shown. You 
			absolutely must define the Instance ID for each block; 
			all other values will default unless defined.
		
			You must also call the function 'WRITE_MIXER' in order
			for the structure to be used by this module
	
	DEFINE_START
	
	VOL[1].chan			= $00					//Channels: 1-8 ($00-$07)
	VOL[1].max			= 10					//Max: 10
	VOL[1].min			= -70					//Min: -70
	VOL[1].inc			= 1						//Step: dB
	VOL[1].ramp 		= 8						//Ramp Time: Steps/Sec 
	VOL[1].type			= $01					//Type:($00 = Input, $01 = Output)
	
	CALL 'WRITE_MIXER'						//<--You must call this function!
	CALL 'INIT_COMBINE'						//Optional
	
	3)  Define your module as shown.  You must pass a touch panel
			array (virtual suggested), a virtual device array, and the
			actual device.  
			
			If you use: #INCLUDE 'HoppDEV.axi' and CALL 'INIT_COMBINE , 
			you can insert the line below and you only need to define 
			dvMixer in DEFINE_DEVICE
	
	DEFINE_MODULE 'TOA Vol Control Rev4-00' Mix1(vdvTP_VOL,vdvMXR,dvMixer) 

*)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev4-00.axi'
#INCLUDE 'HoppSTRUCT Rev4-00.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

INTEGER RampUp			= 1
INTEGER RampDn			= 2
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

STRUCTURE _CONVERSION
{
	CHAR valHex
	SINTEGER valDb
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLBLOCK MXR_VOL[20]

VOLATILE CHAR cMteStr[20][50]
VOLATILE CHAR cLvlStr[20][50]
VOLATILE CHAR cLvlVal[20][4]
VOLATILE INTEGER nMin[20]
VOLATILE INTEGER nMax[20]
VOLATILE INTEGER nLvl[20]
_CONVERSION sLvl[126]
VOLATILE CHAR cBuff[255]
VOLATILE LONG nArray[20]
VOLATILE INTEGER nChange[20]

VOLATILE INTEGER nVolBtn[]={1,2,3,4,5,6,7,8,9,10}

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

//DEFINE_FUNCTION Parse(CHAR cCompStr[100])
//{
//	STACK_VAR INTEGER nPos
//	STACK_VAR INTEGER nAMXLvl
//	STACK_VAR INTEGER x 
//	STACK_VAR INTEGER nFlag
//	
//	FOR(x=1;x<=MAX_LENGTH_ARRAY(MXR_VOL);x++)
//	{
//		SELECT
//		{
//			ACTIVE(FIND_STRING(cCompStr,cLvlStr[x],1)):
//			{
//				nFlag=1
//				REMOVE_STRING(cCompStr,cLvlStr[x],1)
//				nPos=FIND_STRING(cCompStr,"$20",1)
//				MXR_VOL[x].lvl=ATOI(GET_BUFFER_STRING(cCompStr,nPos-1))
//				
//				IF(MXR_VOL[x].lvl>MXR_VOL[x].max)	MXR_VOL[x].lvl=MXR_VOL[x].max
//				ELSE IF(MXR_VOL[x].lvl<MXR_VOL[x].min) MXR_VOL[x].lvl=MXR_VOL[x].min
//				nAMXLvl= ABS_VALUE((255*(MXR_VOL[x].lvl-MXR_VOL[x].min))/(MXR_VOL[x].max-MXR_VOL[x].min))
//				SEND_LEVEL vdvTP[x],1,nAMXLvl
//			}
//			ACTIVE(FIND_STRING(cCompStr,cMteStr[x],1)):
//			{
//				nFlag=1
//				REMOVE_STRING(cCompStr,cMteStr[x],1)
//				nPos=FIND_STRING(cCompStr,"$20",1)
//				MXR_VOL[x].mte=ATOI(GET_BUFFER_STRING(cCompStr,nPos-1))
//				
//				//matrix point special case
//				IF(LENGTH_STRING(MXR_VOL[x].chanin) && LENGTH_STRING(MXR_VOL[x].chanout))	
//					MXR_VOL[x].mte=!MXR_VOL[x].mte
//				
//				IF(MXR_VOL[x].mte) 
//				{
//					ON[vdvMixer[x],MIX_MUTE_ON_FB]
//					OFF[vdvMixer[x],MIX_MUTE_OFF_FB]
//				}
//				ELSE
//				{
//					OFF[vdvMixer[x],MIX_MUTE_ON_FB]
//					ON[vdvMixer[x],MIX_MUTE_OFF_FB]
//				}
//				[vdvTP[x],3]	= [vdvMixer[x],MIX_MUTE_ON_FB]
//				[vdvTP[x],6]	= [vdvMixer[x],MIX_MUTE_ON_FB]
//				[vdvTP[x],5]	= [vdvMixer[x],MIX_MUTE_OFF_FB]
//			}
//		}
//		IF(nFlag) BREAK
//	}	
//}

DEFINE_FUNCTION OnPush(INTEGER nCmd,INTEGER nIP)
{
	STACK_VAR INTEGER x
	LOCAL_VAR INTEGER nI
	nI=nIP
	SWITCH(nCmd)
	{
		CASE MIX_VOL_UP:
		{
			MXR_VOL[nI].mte = 0		
			SEND_STRING dvMixer,"cMteStr[nI],$01" 			
			StartTimeline(RampUp,nI)	
		}
		CASE MIX_VOL_DN:
 		{
			MXR_VOL[nI].mte = 0		
			SEND_STRING dvMixer,"cMteStr[nI],$01" 			
			StartTimeline(RampDn,nI)	
		}
		CASE MIX_MUTE_TOG: 	
		{
			MXR_VOL[nI].mte = !MXR_VOL[nI].mte
			IF(MXR_VOL[nI].mte) SEND_STRING dvMixer,"cMteStr[nI],$00" 
			ELSE	SEND_STRING dvMixer,"cMteStr[nI],$01" 
		}
		CASE MIX_MUTE_OFF: 	
		{
			MXR_VOL[nI].mte = 0		
			SEND_STRING dvMixer,"cMteStr[nI],$01" 
		}
		CASE MIX_MUTE_ON:
		{
			MXR_VOL[nI].mte = 1		
			SEND_STRING dvMixer,"cMteStr[nI],$00" 
		}
		CASE MIX_QUERY: 
		{
			IF(LENGTH_ARRAY(cMteStr[nI])) 
				SEND_STRING dvMixer,"cMteStr[nI],ITOHEX(MXR_VOL[nI].mte)"
			IF(LENGTH_ARRAY(cLvlStr[nI])) 
				WAIT 1 SEND_STRING dvMixer,"cLvlStr[nI],cLvlVal[nI]"
		}
	}
	[vdvTP, 3] = MXR_VOL[nI].mte 	
}

DEFINE_FUNCTION StartTimeline(INTEGER nDirP, INTEGER nIP)
{
	STACK_VAR LONG lTLArray[1]
	LOCAL_VAR INTEGER nI
	LOCAL_VAR INTEGER nDir
	nI=nIP
	nDir=nDirP
	Ramp(nDir,nI)
	nChange[nI]=nDir
	lTLArray[1]=nArray[nI]
	TIMELINE_CREATE(2000+nI,lTLArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

DEFINE_FUNCTION Ramp(INTEGER nDir, INTEGER nI)
{
	STACK_VAR INTEGER nAMXLvl
	
	IF(MXR_VOL[nI].mte)	SEND_STRING dvMixer,"cMteStr[nI],$01"
	
	SWITCH(nDir)
	{
		CASE RampUp:
		{
			SELECT
			{
				ACTIVE((nLvl[nI]+MXR_VOL[nI].inc)>=nMax[nI]):	nLvl[nI]=nMax[nI]
				ACTIVE(nLvl[nI]<nMin[nI]):	nLvl[nI]=nMin[nI]
				ACTIVE(1):  nLvl[nI]++
			}
		}	
		CASE RampDn:
		{
			SELECT
			{
				ACTIVE((nLvl[nI]-MXR_VOL[nI].inc)<=nMin[nI]):	nLvl[nI]=nMin[nI]
				ACTIVE(nLvl[nI]>nMax[nI]): nLvl[nI]=nMax[nI]
				ACTIVE(1):	nLvl[nI]--
			}
		}
	}
	nAMXLvl= ABS_VALUE((255*(nLvl[nI]-nMin[nI]))/(nMax[nI]-nMin[nI]))
	SEND_LEVEL vdvTP[nI],1,nAMXLvl	
	SEND_STRING dvMixer,"cLvlStr[nI],sLvl[nLvl[nI]].valHex"
}

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
DEFINE_CALL 'INIT_STRINGS'
{
	STACK_VAR INTEGER X
	STACK_VAR CHAR Y
	STACK_VAR INTEGER Z
	
	FOR (x=1;x<=MAX_LENGTH_ARRAY(MXR_VOL);x++)
	{
		cMteStr[x]="$92,$03,MXR_VOL[x].type,MXR_VOL[x].chan"
		cLvlStr[x]="$91,$03,MXR_VOL[x].type,MXR_VOL[x].chan"
		//sets up time that will be used for each timeline
		FOR (z=1;z<=126;z++)
		{
			IF(MXR_VOL[x].min >= sLvl[z].valDb)	nMin[x] = z
		}
		nMax[x] = 70		// -18db is the max!!
		nLvl[x] = (nMax[x]+nMin[x])/2
		nArray[x]=(MXR_VOL[x].ramp*1000)/ABS_VALUE(((nMax[x]-nMin[x])/MXR_VOL[x].inc))
	}
	Y = $00
	FOR (x=1;x<=126;x++)
	{
	  Y++
		sLvl[x].valHex = Y
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

WAIT 20
{
  CALL 'READ_MIXER'
	CALL 'INIT_STRINGS'
}

sLvl[1].valDB = -70
sLvl[2].valDB = -68
sLvl[3].valDB = -66
sLvl[4].valDB = -64
sLvl[5].valDB = -62
sLvl[6].valDB = -60
sLvl[7].valDB = -59
sLvl[8].valDB = -58
sLvl[9].valDB = -57
sLvl[10].valDB = -56
sLvl[11].valDB = -55
sLvl[12].valDB = -54
sLvl[13].valDB = -53
sLvl[14].valDB = -52
sLvl[15].valDB = -51
sLvl[16].valDB = -50
sLvl[17].valDB = -49
sLvl[18].valDB = -48
sLvl[19].valDB = -47
sLvl[20].valDB = -46
sLvl[21].valDB = -45
sLvl[22].valDB = -44
sLvl[23].valDB = -43
sLvl[24].valDB = -42
sLvl[25].valDB = -41
sLvl[26].valDB = -40
sLvl[27].valDB = -39
sLvl[28].valDB = -39
sLvl[29].valDB = -38
sLvl[30].valDB = -38
sLvl[31].valDB = -37
sLvl[32].valDB = -37
sLvl[33].valDB = -36
sLvl[34].valDB = -36
sLvl[35].valDB = -35
sLvl[36].valDB = -35
sLvl[37].valDB = -34
sLvl[38].valDB = -34
sLvl[39].valDB = -33
sLvl[40].valDB = -33
sLvl[41].valDB = -32
sLvl[42].valDB = -32
sLvl[43].valDB = -31
sLvl[44].valDB = -31
sLvl[45].valDB = -30
sLvl[46].valDB = -30
sLvl[47].valDB = -29
sLvl[48].valDB = -29
sLvl[49].valDB = -28
sLvl[50].valDB = -28
sLvl[51].valDB = -27
sLvl[52].valDB = -27
sLvl[53].valDB = -26
sLvl[54].valDB = -26
sLvl[55].valDB = -25
sLvl[56].valDB = -25
sLvl[57].valDB = -24
sLvl[58].valDB = -24
sLvl[59].valDB = -23
sLvl[60].valDB = -23
sLvl[61].valDB = -22
sLvl[62].valDB = -22
sLvl[63].valDB = -21
sLvl[64].valDB = -21
sLvl[65].valDB = -20
sLvl[66].valDB = -20
sLvl[67].valDB = -19
sLvl[68].valDB = -19
sLvl[69].valDB = -18
sLvl[70].valDB = -18
sLvl[71].valDB = -17
sLvl[72].valDB = -17
sLvl[73].valDB = -16
sLvl[74].valDB = -16
sLvl[75].valDB = -15
sLvl[76].valDB = -15
sLvl[77].valDB = -14
sLvl[78].valDB = -14
sLvl[79].valDB = -13
sLvl[80].valDB = -13
sLvl[81].valDB = -12
sLvl[82].valDB = -12
sLvl[83].valDB = -11
sLvl[84].valDB = -11
sLvl[85].valDB = -10
sLvl[86].valDB = -10
sLvl[87].valDB = -9
sLvl[88].valDB = -9
sLvl[89].valDB = -8
sLvl[90].valDB = -8
sLvl[91].valDB = -7
sLvl[92].valDB = -7
sLvl[93].valDB = -6
sLvl[94].valDB = -6
sLvl[95].valDB = -5
sLvl[96].valDB = -5
sLvl[97].valDB = -4
sLvl[98].valDB = -4
sLvl[99].valDB = -3
sLvl[100].valDB = -3
sLvl[101].valDB = -2
sLvl[102].valDB = -2
sLvl[103].valDB = -1
sLvl[104].valDB = -1
sLvl[105].valDB = 0
sLvl[106].valDB = 0
sLvl[107].valDB = 0
sLvl[108].valDB = 1
sLvl[109].valDB = 1
sLvl[110].valDB = 2
sLvl[111].valDB = 2
sLvl[112].valDB = 3
sLvl[113].valDB = 3
sLvl[114].valDB = 4
sLvl[115].valDB = 4
sLvl[116].valDB = 5
sLvl[117].valDB = 5
sLvl[119].valDB = 6
sLvl[119].valDB = 6
sLvl[120].valDB = 7
sLvl[121].valDB = 7
sLvl[122].valDB = 8
sLvl[123].valDB = 8
sLvl[124].valDB = 9
sLvl[125].valDB = 9
sLvl[126].valDB = 10

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
DATA_EVENT[dvMixer]
{
	STRING:
	{
//		LOCAL_VAR CHAR cHold[100]
//		LOCAL_VAR CHAR cBuff[255]
//		LOCAL_VAR CHAR cFullStr[100]
//		STACK_VAR INTEGER nPos
//		
//		cBuff = "cBuff,data.text"
//		Parse(cBuff)		
	}
}

TIMELINE_EVENT[2001]{Ramp(nChange[1],1)}
TIMELINE_EVENT[2002]{Ramp(nChange[2],2)}
TIMELINE_EVENT[2003]{Ramp(nChange[3],3)}
TIMELINE_EVENT[2004]{Ramp(nChange[4],4)}
TIMELINE_EVENT[2005]{Ramp(nChange[5],5)}
TIMELINE_EVENT[2006]{Ramp(nChange[6],6)}
TIMELINE_EVENT[2007]{Ramp(nChange[7],7)}
TIMELINE_EVENT[2008]{Ramp(nChange[8],8)}
TIMELINE_EVENT[2009]{Ramp(nChange[9],9)}
TIMELINE_EVENT[2010]{Ramp(nChange[10],10)}
TIMELINE_EVENT[2011]{Ramp(nChange[11],11)}
TIMELINE_EVENT[2012]{Ramp(nChange[12],12)}
TIMELINE_EVENT[2013]{Ramp(nChange[13],13)}
TIMELINE_EVENT[2014]{Ramp(nChange[14],14)}
TIMELINE_EVENT[2015]{Ramp(nChange[15],15)}
TIMELINE_EVENT[2016]{Ramp(nChange[16],16)}
TIMELINE_EVENT[2017]{Ramp(nChange[17],17)}
TIMELINE_EVENT[2018]{Ramp(nChange[18],18)}
TIMELINE_EVENT[2019]{Ramp(nChange[19],19)}
TIMELINE_EVENT[2020]{Ramp(nChange[20],20)}

CHANNEL_EVENT[vdvMixer,0]
{
	ON:	  
	{
		IF(channel.channel<200) 
			OnPush(channel.channel,GET_LAST(vdvMixer))
	}
	OFF:	
	{
		IF(channel.channel<200 && TIMELINE_ACTIVE(2000+GET_LAST(vdvMixer)))	
			TIMELINE_KILL(2000+GET_LAST(vdvMixer))
	}	
}

button_event [vdvTP,nVolBtn]
{                  
	PUSH:		
	{
		STACK_VAR INTEGER nIBtn
		nIBtn=GET_LAST(nVolBtn)
		IF(nIBtn=MIX_VOL_UP || nIBtn=MIX_VOL_DN) TO[button.input.device,button.input.channel]
		ON[vdvMixer[GET_LAST(vdvTP)],nIBtn]
	}
	RELEASE:	OFF[vdvMixer[GET_LAST(vdvTP)],(GET_LAST(nVolBtn))]
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

