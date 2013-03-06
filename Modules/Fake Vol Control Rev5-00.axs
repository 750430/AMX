MODULE_NAME='Fake Vol Control Rev5-00'(DEV vdvTP[], DEV vdvMixer[])
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 12/02/2011  AT: 13:33:01        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*----------------MODULE INSTRUCTIONS----------------------*)
(*


SET BAUD 38400,N,8,1 485 DISABLE

	DEFINE_START
	
	VOL[1].instID		= 50          //<----You must fill this in!
	VOL[1].addr 		= '1'					//Default: '1'
	VOL[1].chan			= '1'					//Default: '1'
	VOL[1].max			= 12					//Default: 12
	VOL[1].min			= -40					//Default: -40
	VOL[1].inc			= 1						//Default: 1
	VOL[1].ramp 		= 8						//Default: 8
	VOL[1].type			= FADER_TYPE			//Default: 'FDR'
	
	
	
	define_module 'Fake Vol Control Rev5-00' mxr1(vdvTP_VOL,vdvMXR) 

*)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-04.axi'
#INCLUDE 'HoppSTRUCT Rev5-02.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

//default values
INTEGER DefaultMax  = 255
INTEGER DefaultMin 	= 0
INTEGER DefaultInc	= 10
INTEGER DefaultRamp	= 1
CHAR DefaultChan[]	=	'1'
CHAR DefaultAddr[] 	= '1'

INTEGER RampUp			= 1
INTEGER RampDn			= 2
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLBLOCK MXR_VOL[50]

VOLATILE CHAR cMteTxt[10]
VOLATILE CHAR cLvlTxt[10]
VOLATILE CHAR cMteStr[50][50]
VOLATILE CHAR cLvlStr[50][50]
VOLATILE CHAR cBuff[255]
VOLATILE LONG nArray[50]
VOLATILE INTEGER nChange[50]

VOLATILE	LONG lPos
VOLATILE	SLONG slReturn
VOLATILE	SLONG slFile
VOLATILE	SLONG slResult
VOLATILE	CHAR sBINString[10000]

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

DEFINE_FUNCTION OnPush(INTEGER nCmd,INTEGER nIP)
{
	STACK_VAR INTEGER x
	LOCAL_VAR INTEGER nI
	nI=nIP
	SWITCH(nCmd)
	{
		CASE MIX_VOL_UP:		StartTimeline(RampUp,nI)	
		CASE MIX_VOL_DN: 		StartTimeline(RampDn,nI)	
		CASE MIX_MUTE_TOG: 		
		{
			MXR_VOL[nIP].mte=!MXR_VOL[nIP].mte
			IF(MXR_VOL[nIP].mte) 
			{
				ON[vdvMixer[nIP],MIX_MUTE_ON_FB]
				OFF[vdvMixer[nIP],MIX_MUTE_OFF_FB]
			}
			ELSE
			{
				OFF[vdvMixer[nIP],MIX_MUTE_ON_FB]
				ON[vdvMixer[nIP],MIX_MUTE_OFF_FB]
			}
			[vdvTP[nIP],3]	= [vdvMixer[nIP],MIX_MUTE_ON_FB]
		}
	}
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
	SWITCH(nDir)
	{
		CASE RampUp:
		{
			SELECT
			{
				ACTIVE((MXR_VOL[nI].lvl+MXR_VOL[nI].inc)>=MXR_VOL[nI].max):	MXR_VOL[nI].lvl=MXR_VOL[nI].max
				ACTIVE(MXR_VOL[nI].lvl<MXR_VOL[nI].min):	MXR_VOL[nI].lvl=MXR_VOL[nI].min
				ACTIVE(1):  MXR_VOL[nI].lvl=MXR_VOL[nI].lvl+MXR_VOL[nI].inc
			}
		}	
		CASE RampDn:
		{
			SELECT
			{
				ACTIVE((MXR_VOL[nI].lvl-MXR_VOL[nI].inc)<=MXR_VOL[nI].min):	MXR_VOL[nI].lvl=MXR_VOL[nI].min
				ACTIVE(MXR_VOL[nI].lvl>MXR_VOL[nI].max): MXR_VOL[nI].lvl=MXR_VOL[nI].max
				ACTIVE(1):	MXR_VOL[nI].lvl=MXR_VOL[nI].lvl-MXR_VOL[nI].inc
			}
		}
	}
	SEND_LEVEL vdvTP[nI],1,MXR_VOL[nI].lvl
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

FOR (x=1;x<=MAX_LENGTH_ARRAY(MXR_VOL);x++)
{
	MXR_VOL[x].max=DefaultMax
	MXR_VOL[x].min=DefaultMin
	MXR_VOL[x].inc=DefaultInc
	MXR_VOL[x].ramp=DefaultRamp
	nArray[x]=(MXR_VOL[x].ramp*1000)/ABS_VALUE(((MXR_VOL[x].max-MXR_VOL[x].min)/MXR_VOL[x].inc))
}


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

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
TIMELINE_EVENT[2021]{Ramp(nChange[21],21)}
TIMELINE_EVENT[2022]{Ramp(nChange[22],22)}
TIMELINE_EVENT[2023]{Ramp(nChange[23],23)}
TIMELINE_EVENT[2024]{Ramp(nChange[24],24)}
TIMELINE_EVENT[2025]{Ramp(nChange[25],25)}
TIMELINE_EVENT[2026]{Ramp(nChange[26],26)}
TIMELINE_EVENT[2027]{Ramp(nChange[27],27)}
TIMELINE_EVENT[2028]{Ramp(nChange[28],28)}
TIMELINE_EVENT[2029]{Ramp(nChange[29],29)}
TIMELINE_EVENT[2030]{Ramp(nChange[30],30)}
TIMELINE_EVENT[2031]{Ramp(nChange[31],31)}
TIMELINE_EVENT[2032]{Ramp(nChange[32],32)}
TIMELINE_EVENT[2033]{Ramp(nChange[33],33)}
TIMELINE_EVENT[2034]{Ramp(nChange[34],34)}
TIMELINE_EVENT[2035]{Ramp(nChange[35],35)}
TIMELINE_EVENT[2036]{Ramp(nChange[36],36)}
TIMELINE_EVENT[2037]{Ramp(nChange[37],37)}
TIMELINE_EVENT[2038]{Ramp(nChange[38],38)}
TIMELINE_EVENT[2039]{Ramp(nChange[39],39)}
TIMELINE_EVENT[2040]{Ramp(nChange[40],40)}
TIMELINE_EVENT[2041]{Ramp(nChange[41],41)}
TIMELINE_EVENT[2042]{Ramp(nChange[42],42)}
TIMELINE_EVENT[2043]{Ramp(nChange[43],43)}
TIMELINE_EVENT[2044]{Ramp(nChange[44],44)}
TIMELINE_EVENT[2045]{Ramp(nChange[45],45)}
TIMELINE_EVENT[2046]{Ramp(nChange[46],46)}
TIMELINE_EVENT[2047]{Ramp(nChange[47],47)}
TIMELINE_EVENT[2048]{Ramp(nChange[48],48)}
TIMELINE_EVENT[2049]{Ramp(nChange[49],49)}
TIMELINE_EVENT[2050]{Ramp(nChange[50],50)}

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

//BUTTON_EVENT [vdvTP[1],nVolBtn]
//BUTTON_EVENT [vdvTP[2],nVolBtn]
//BUTTON_EVENT [vdvTP[3],nVolBtn]
//BUTTON_EVENT [vdvTP[4],nVolBtn]
//BUTTON_EVENT [vdvTP[5],nVolBtn]
//BUTTON_EVENT [vdvTP[6],nVolBtn]
//BUTTON_EVENT [vdvTP[7],nVolBtn]
//BUTTON_EVENT [vdvTP[8],nVolBtn]
//BUTTON_EVENT [vdvTP[9],nVolBtn]
//BUTTON_EVENT [vdvTP[10],nVolBtn]
//BUTTON_EVENT [vdvTP[11],nVolBtn]
//BUTTON_EVENT [vdvTP[12],nVolBtn]
//BUTTON_EVENT [vdvTP[13],nVolBtn]
//BUTTON_EVENT [vdvTP[14],nVolBtn]
//BUTTON_EVENT [vdvTP[15],nVolBtn]
//BUTTON_EVENT [vdvTP[16],nVolBtn]
//BUTTON_EVENT [vdvTP[17],nVolBtn]
//BUTTON_EVENT [vdvTP[18],nVolBtn]
//BUTTON_EVENT [vdvTP[19],nVolBtn]
//BUTTON_EVENT [vdvTP[20],nVolBtn]
//BUTTON_EVENT [vdvTP[21],nVolBtn]
//BUTTON_EVENT [vdvTP[22],nVolBtn]
//BUTTON_EVENT [vdvTP[23],nVolBtn]
//BUTTON_EVENT [vdvTP[24],nVolBtn]
//BUTTON_EVENT [vdvTP[25],nVolBtn]
//BUTTON_EVENT [vdvTP[26],nVolBtn]
//BUTTON_EVENT [vdvTP[27],nVolBtn]
//BUTTON_EVENT [vdvTP[28],nVolBtn]
//BUTTON_EVENT [vdvTP[29],nVolBtn]
//BUTTON_EVENT [vdvTP[30],nVolBtn]
button_event [vdvTP,nVolBtn]
{                  
	PUSH:		
	{
		STACK_VAR INTEGER nIBtn
		nIBtn=GET_LAST(nVolBtn)
		IF(nIBtn=MIX_VOL_UP || nIBtn=MIX_VOL_DN) TO[button.input.device,button.input.channel]
		to[vdvMixer[GET_LAST(vdvTP)],nIBtn]
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

