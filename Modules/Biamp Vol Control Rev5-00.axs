MODULE_NAME='Biamp Vol Control Rev5-00'(DEV vdvTP[], DEV vdvMixer[], DEV dvMixer)
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
	
	
	
	define_module 'Biamp Vol Control Rev5-00' mxr1(vdvTP_VOL,vdvMXR,dvBiamp) 

*)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-00.axi'
#INCLUDE 'HoppSTRUCT Rev5-00.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

//default values
INTEGER DefaultMax  = 12
INTEGER DefaultMin 	= -40
INTEGER DefaultInc	= 1
INTEGER DefaultRamp	= 8
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

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nPos
	STACK_VAR INTEGER nAMXLvl
	STACK_VAR INTEGER x 
	STACK_VAR INTEGER nFlag
	
	IF(FIND_STRING(cCompStr,'LVL',1) || FIND_STRING(cCompStr,'MUTE',1))
	{
		FOR(x=1;x<=MAX_LENGTH_ARRAY(MXR_VOL);x++)
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cCompStr,cLvlStr[x],1)):
				{
					nFlag=1
					REMOVE_STRING(cCompStr,cLvlStr[x],1)
					nPos=FIND_STRING(cCompStr,"$20",1)
					MXR_VOL[x].lvl=ATOI(GET_BUFFER_STRING(cCompStr,nPos-1))
					
					IF(MXR_VOL[x].lvl>MXR_VOL[x].max)	MXR_VOL[x].lvl=MXR_VOL[x].max
					ELSE IF(MXR_VOL[x].lvl<MXR_VOL[x].min) MXR_VOL[x].lvl=MXR_VOL[x].min
					nAMXLvl= ABS_VALUE((255*(MXR_VOL[x].lvl-MXR_VOL[x].min))/(MXR_VOL[x].max-MXR_VOL[x].min))
					SEND_LEVEL vdvTP[x],1,nAMXLvl
				}
				ACTIVE(FIND_STRING(cCompStr,cMteStr[x],1)):
				{
					nFlag=1
					REMOVE_STRING(cCompStr,cMteStr[x],1)
					nPos=FIND_STRING(cCompStr,"$20",1)
					MXR_VOL[x].mte=ATOI(GET_BUFFER_STRING(cCompStr,nPos-1))
					
					//matrix point special case
					IF(LENGTH_STRING(MXR_VOL[x].chanin) && LENGTH_STRING(MXR_VOL[x].chanout))	
						MXR_VOL[x].mte=!MXR_VOL[x].mte
					
					IF(MXR_VOL[x].mte) 
					{
						ON[vdvMixer[x],MIX_MUTE_ON_FB]
						OFF[vdvMixer[x],MIX_MUTE_OFF_FB]
					}
					ELSE
					{
						OFF[vdvMixer[x],MIX_MUTE_ON_FB]
						ON[vdvMixer[x],MIX_MUTE_OFF_FB]
					}
					[vdvTP[x],3]	= [vdvMixer[x],MIX_MUTE_ON_FB]
					[vdvTP[x],6]	= [vdvMixer[x],MIX_MUTE_ON_FB]
					[vdvTP[x],5]	= [vdvMixer[x],MIX_MUTE_OFF_FB]
				}
			}
			IF(nFlag) BREAK
		}	
	}
	IF(FIND_STRING(cCompStr,'-ERR:INVALID SVC',1))
	{
		send_string 0,"'BIAMP ERROR!'"
		CALL 'READ_MIXER'
		CALL 'INIT_STRINGS'
	}
}
DEFINE_FUNCTION OnPush(INTEGER nCmd,INTEGER nIP)
{
	STACK_VAR INTEGER x
	LOCAL_VAR INTEGER nI
	nI=nIP
	SWITCH(nCmd)
	{
		CASE MIX_VOL_UP:		StartTimeline(RampUp,nI)	
		CASE MIX_VOL_DN: 		StartTimeline(RampDn,nI)	
		CASE MIX_MUTE_TOG: 	SEND_STRING dvMixer,"'S',cMteStr[nI],ITOA(!MXR_VOL[nI].mte),$0A" 
		CASE MIX_MUTE_OFF: 	
		{
			//matrix point special case
			IF(LENGTH_STRING(MXR_VOL[nI].chanin) && LENGTH_STRING(MXR_VOL[nI].chanout))	
				SEND_STRING dvMixer,"'S',cMteStr[nI],'1',$0A" 
			ELSE	
				SEND_STRING dvMixer,"'S',cMteStr[nI],'0',$0A" 
		}
		CASE MIX_MUTE_ON:  	
		{
			//matrix point special case
			IF(LENGTH_STRING(MXR_VOL[nI].chanin) && LENGTH_STRING(MXR_VOL[nI].chanout))	
				SEND_STRING dvMixer,"'S',cMteStr[nI],'0',$0A" 
			ELSE
				SEND_STRING dvMixer,"'S',cMteStr[nI],'1',$0A" 
		}
		CASE MIX_QUERY: 
		{
			IF(LENGTH_ARRAY(cMteStr[nI])) 
				SEND_STRING dvMixer,"'G',cMteStr[nI],$0A"
			IF(LENGTH_ARRAY(cLvlStr[nI]) && MXR_VOL[nI].type<>MUTE_TYPE) 
				WAIT 1 SEND_STRING dvMixer,"'G',cLvlStr[nI],$0A"
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
	STACK_VAR SINTEGER nValue

	//if chanin and chanout have length, we are dealing with a matrix point
	//a mute 1 will enable a matrix point (passing audio)
	//a mute 1 will stop audio for any other situation
	
	//we want to allow audio when a user initiates ramping
	SELECT
	{
		ACTIVE(MXR_VOL[nI].mte && !(LENGTH_STRING(MXR_VOL[nI].chanin) && LENGTH_STRING(MXR_VOL[nI].chanout))): 
			SEND_STRING dvMixer,"'S',cMteStr[nI],'0',$0A"
		ACTIVE(MXR_VOL[nI].mte && (LENGTH_STRING(MXR_VOL[nI].chanin) && LENGTH_STRING(MXR_VOL[nI].chanout))): 
			SEND_STRING dvMixer,"'S',cMteStr[nI],'1',$0A"
	}
	
	SWITCH(nDir)
	{
		CASE RampUp:
		{
			SELECT
			{
				ACTIVE((MXR_VOL[nI].lvl+MXR_VOL[nI].inc)>=MXR_VOL[nI].max):	nValue=MXR_VOL[nI].max
				ACTIVE(MXR_VOL[nI].lvl<MXR_VOL[nI].min):	nValue=MXR_VOL[nI].min
				ACTIVE(1):  nValue=MXR_VOL[nI].lvl+MXR_VOL[nI].inc
			}
		}	
		CASE RampDn:
		{
			SELECT
			{
				ACTIVE((MXR_VOL[nI].lvl-MXR_VOL[nI].inc)<=MXR_VOL[nI].min):	nValue=MXR_VOL[nI].min
				ACTIVE(MXR_VOL[nI].lvl>MXR_VOL[nI].max): nValue=MXR_VOL[nI].max
				ACTIVE(1):	nValue=MXR_VOL[nI].lvl-MXR_VOL[nI].inc
			}
		}
	}
	SEND_STRING dvMixer,"'S',cLvlStr[nI],ITOA(nValue),$0A"
}
DEFINE_CALL 'READ_MIXER'
{

	// Read Binary File
	slFile = FILE_OPEN('BinaryMXREncode.xml',1)
	slResult = FILE_READ(slFile, sBINString, MAX_LENGTH_STRING(sBINString))
	slResult = FILE_CLOSE (slFile)
	// Convert To Binary
	lPos = 1
	slReturn = STRING_TO_VARIABLE(MXR_VOL, sBINString, lPos)	
	send_string 0,"'BinString: ',sBINString"
}
DEFINE_CALL 'INIT_STRINGS'
{
	STACK_VAR INTEGER X
	FOR (x=1;x<=MAX_LENGTH_ARRAY(MXR_VOL);x++)
	{
		IF(MXR_VOL[x].instID)
		{ 
			//-------set up defaults-----
			//If max AND min=0, you either have mute block or you want defaults
			IF(!MXR_VOL[x].max && !MXR_VOL[x].min)
			{
				MXR_VOL[x].max=DefaultMax
				MXR_VOL[x].min=DefaultMin
			}
			//If no chan, chanin, or chanout defined, fill in chan 
			IF(!LENGTH_STRING(MXR_VOL[x].chan) && !LENGTH_STRING(MXR_VOL[x].chanin) && 
			   !LENGTH_STRING(MXR_VOL[x].chanout)) 	MXR_VOL[x].chan=DefaultChan
			///If any other value missing, fill it in
			IF(!MXR_VOL[x].ramp) 								MXR_VOL[x].ramp=DefaultRamp
			IF(!MXR_VOL[x].inc) 								MXR_VOL[x].inc=DefaultInc
			IF(!LENGTH_STRING(MXR_VOL[x].addr)) MXR_VOL[x].addr=DefaultAddr
			IF(!LENGTH_STRING(MXR_VOL[x].type)) MXR_VOL[x].type=FADER_TYPE
			

			

		
			SELECT
			{
				ACTIVE(ATOI(MXR_VOL[x].chan)>0):
				{
					cMteTxt="MXR_VOL[x].type,'MUTE'"
					cLvlTxt="MXR_VOL[x].type,'LVL'"
					cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chan,$20"
					cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chan,$20"
				}
				ACTIVE(ATOI(MXR_VOL[x].chanin)>0 && ATOI(MXR_VOL[x].chanout)>0):
				{
					cMteTxt="MXR_VOL[x].type,'MUTEXP'"
					cLvlTxt="MXR_VOL[x].type,'LVLXP'"
					cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanin,$20,MXR_VOL[x].chanout,$20"
					cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanin,$20,MXR_VOL[x].chanout,$20"
				}
				ACTIVE(ATOI(MXR_VOL[x].chanin)>0):
				{
					cMteTxt="MXR_VOL[x].type,'MUTEIN'"
					cLvlTxt="MXR_VOL[x].type,'LVLIN'"
					cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanin,$20"
					cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanin,$20"
				}
				ACTIVE(ATOI(MXR_VOL[x].chanout)>0):
				{
					cMteTxt="MXR_VOL[x].type,'MUTEOUT'"
					cLvlTxt="MXR_VOL[x].type,'LVLOUT'"
					cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanout,$20"
					cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanout,$20"
				}
			}
			//sets up time that will be used for each timeline
			nArray[x]=(MXR_VOL[x].ramp*1000)/ABS_VALUE(((MXR_VOL[x].max-MXR_VOL[x].min)/MXR_VOL[x].inc))
		}
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
	send_string 0,"'read mixer init string'"
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
DATA_EVENT[dvMixer]
{
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cBuff[255]
		LOCAL_VAR CHAR cFullStr[100]
		STACK_VAR INTEGER nPos
		
		cBuff = "cBuff,data.text"
		WHILE(LENGTH_STRING(cBuff))
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cBuff,"$0A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0A",1)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
					Parse(cFullStr)
				}
				ACTIVE(1):
				{
					cHold="cHold,cBuff"
					cBuff=''
				}
			}
		}
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

