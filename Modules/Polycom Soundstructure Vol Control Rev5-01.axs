MODULE_NAME='Polycom Soundstructure Vol Control Rev5-01'(DEV vdvTP[], DEV vdvMixer[], DEV dvMixer)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/22/2011  AT: 10:28:57        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*----------------MODULE INSTRUCTIONS----------------------*)
(*


SET BAUD 9600,N,8,1 485 DISABLE

For IP Connections, use port 52774
	
	
	
	define_module 'Polycom Soundstructure Vol Control Rev5-00' mxr1(vdvTP_VOL,vdvMXR,dvPolycom) 

*)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-10.axi'
#INCLUDE 'HoppSTRUCT Rev5-08.axi'
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
integer DefaultRamp	= 100

INTEGER RampUp			= 1
INTEGER RampDn			= 2

integer MuteOn			=	1
integer MuteOff			=	2

long 	tlQuery			=	3001

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLBLOCK MXR_VOL[50]

volatile	char		cLvlStr[2][50][50]
volatile	char		cMteStr[2][50][50]
volatile	char		cQueryStr[50][50]
volatile	char		cQueryMuteStr[50][50]

volatile	char		cLvlResponse[50][50]
volatile	char		cMaxResponse[50][50]
volatile	char		cMinResponse[50][50]
volatile	char		cMuteResponse[50][50]

volatile	integer		nChange[50]		//Direction Change
	//dro//  	nChange[1] is for volume 1
	//dro//		nChange is 1 or 2 for RampUp or RampDown, respectively

//Binary handling for reading VOLblock
VOLATILE	LONG lPos
VOLATILE	SLONG slReturn
VOLATILE	SLONG slFile
VOLATILE	SLONG slResult
VOLATILE	CHAR sBINString[10000]

volatile	integer		nVolBars

long lQueryTimes[]	=	{60000,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400}


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
	stack_var integer nPos
	STACK_VAR INTEGER nAMXLvl

	for(x=1;x<=max_length_array(mxr_vol);x++)
	{
		select
		{
			active(find_string(cCompStr,cLvlResponse[x],1)):
			{
				remove_string(cCompStr,cLvlResponse[x],1)
				nPos=find_string(cCompStr,"'.'",1)
				MXR_VOL[x].lvl=atoi(get_buffer_string(cCompStr,nPos-1))
				send_string 0,"'MXR_VOL[x].lvl=',itoa(MXR_VOL[x].lvl)"
				nAMXLvl= ABS_VALUE((255*(MXR_VOL[x].lvl-MXR_VOL[x].min))/(MXR_VOL[x].max-MXR_VOL[x].min))
				send_string 0,"'nAMXLvl=',itoa(nAMXLvl)"
				send_level vdvTP[x],1,nAMXLvl
			}
			active(find_string(cCompStr,cMuteResponse[x],1)):
			{
				remove_string(cCompStr,cMuteResponse[x],1)
				nPos=find_string(cCompStr,"$0D",1)
				MXR_VOL[x].mte=atoi(get_buffer_string(cCompStr,nPos-1))
				
				switch(MXR_VOL[x].mte)
				{
					case 1: 
					{
						on[vdvMixer[x],MIX_MUTE_ON_FB]
						off[vdvMixer[x],MIX_MUTE_OFF_FB]
					}
					case 0:
					{
						off[vdvMixer[x],MIX_MUTE_ON_FB]
						on[vdvMixer[x],MIX_MUTE_OFF_FB]
					}
				}
				[vdvTP[x],MIX_MUTE_TOG]	= [vdvMixer[x],MIX_MUTE_ON_FB]
				[vdvTP[x],MIX_MUTE_ON]	= [vdvMixer[x],MIX_MUTE_ON_FB]
				[vdvTP[x],MIX_MUTE_OFF]	= [vdvMixer[x],MIX_MUTE_OFF_FB]
			}
			active(find_string(cCompStr,cMaxResponse[x],1)):
			{
				remove_string(cCompStr,cMaxResponse[x],1)
				nPos=find_string(cCompStr,"'.'",1)
				MXR_VOL[x].max=atoi(get_buffer_string(cCompStr,nPos-1))
			}
			active(find_string(cCompStr,cMinResponse[x],1)):
			{
				remove_string(cCompStr,cMinResponse[x],1)
				nPos=find_string(cCompStr,"'.'",1)
				MXR_VOL[x].min=atoi(get_buffer_string(cCompStr,nPos-1))
			}
		}
	}
}


DEFINE_FUNCTION OnPush(INTEGER nCmd,INTEGER nCurrentVolBar)
{
	STACK_VAR INTEGER x
	SWITCH(nCmd)
	{
		CASE MIX_VOL_UP:		StartTimeline(RampUp,nCurrentVolBar)	
		CASE MIX_VOL_DN: 		StartTimeline(RampDn,nCurrentVolBar)	
		CASE MIX_MUTE_TOG:
		{
			switch(MXR_VOL[nCurrentVolBar].mte)
			{
				case 1: 
				{
					send_string dvMixer,"cMteStr[MuteOff][nCurrentVolBar]"
					//send_string 0,"cMteStr[MuteOff][nCurrentVolBar]"
				}
				case 0: 
				{
					send_string dvMixer,"cMteStr[MuteOn][nCurrentVolBar]"
					//send_string 0,"cMteStr[MuteOn][nCurrentVolBar]"
				}
			}
		}
		CASE MIX_MUTE_OFF: 	send_string dvMixer,"cMteStr[MuteOff][nCurrentVolBar]"
		CASE MIX_MUTE_ON:  	send_string dvMixer,"cMteStr[MuteOn][nCurrentVolBar]"
		CASE MIX_QUERY: 
		{
			send_string dvMixer,"cQueryStr[nCurrentVolBar]"
			send_string dvMixer,"cQueryMuteStr[nCurrentVolBar]"
			send_string dvMixer,"'get fader max "',MXR_VOL[nCurrentVolBar].name,'"',$0D"
			send_string dvMixer,"'get fader min "',MXR_VOL[nCurrentVolBar].name,'"',$0D"
//			IF(LENGTH_ARRAY(cMteStr[nI])) 
//				SEND_STRING dvMixer,"'G',cMteStr[nI],$0A"
//			IF(LENGTH_ARRAY(cLvlStr[nI]) && MXR_VOL[nI].type<>MUTE_TYPE) 
//				WAIT 1 SEND_STRING dvMixer,"'G',cLvlStr[nI],$0A"
		}
	}
}
DEFINE_FUNCTION StartTimeline(INTEGER nDirection, INTEGER nCurrentVolBar)
{
	STACK_VAR LONG lTLArray[1]

	Ramp(nDirection,nCurrentVolBar)
	nChange[nCurrentVolBar]=nDirection
	lTLArray[1]=mxr_vol[nCurrentVolBar].ramp
	TIMELINE_CREATE(2000+nCurrentVolBar,lTLArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
}
DEFINE_FUNCTION Ramp(INTEGER nDirection, INTEGER nCurrentVolBar)
{
//	STACK_VAR SINTEGER nValue

send_string dvMixer,"cLvlStr[nDirection][nCurrentVolBar]"
//send_string 0,"cLvlStr[nDirection][nCurrentVolBar]"


	//if chanin and chanout have length, we are dealing with a matrix point
	//a mute 1 will enable a matrix point (passing audio)
	//a mute 1 will stop audio for any other situation
	
	//we want to allow audio when a user initiates ramping
//	SELECT
//	{
//		ACTIVE(MXR_VOL[nI].mte && !(LENGTH_STRING(MXR_VOL[nI].chanin) && LENGTH_STRING(MXR_VOL[nI].chanout))): 
//			SEND_STRING dvMixer,"'S',cMteStr[nI],'0',$0A"
//		ACTIVE(MXR_VOL[nI].mte && (LENGTH_STRING(MXR_VOL[nI].chanin) && LENGTH_STRING(MXR_VOL[nI].chanout))): 
//			SEND_STRING dvMixer,"'S',cMteStr[nI],'1',$0A"
//	}
//	
//	SWITCH(nDir)
//	{
//		CASE RampUp:
//		{
//			SELECT
//			{
//				ACTIVE((MXR_VOL[nI].lvl+MXR_VOL[nI].inc)>=MXR_VOL[nI].max):	nValue=MXR_VOL[nI].max
//				ACTIVE(MXR_VOL[nI].lvl<MXR_VOL[nI].min):	nValue=MXR_VOL[nI].min
//				ACTIVE(1):  nValue=MXR_VOL[nI].lvl+MXR_VOL[nI].inc
//			}
//		}	
//		CASE RampDn:
//		{
//			SELECT
//			{
//				ACTIVE((MXR_VOL[nI].lvl-MXR_VOL[nI].inc)<=MXR_VOL[nI].min):	nValue=MXR_VOL[nI].min
//				ACTIVE(MXR_VOL[nI].lvl>MXR_VOL[nI].max): nValue=MXR_VOL[nI].max
//				ACTIVE(1):	nValue=MXR_VOL[nI].lvl-MXR_VOL[nI].inc
//			}
//		}
//	}
//	SEND_STRING dvMixer,"'S',cLvlStr[nI],ITOA(nValue),$0A"
}
define_function read_mixer()
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

define_function init_strings()
{
	STACK_VAR INTEGER X
	FOR (x=1;x<=MAX_LENGTH_ARRAY(MXR_VOL);x++)
	{
		IF(MXR_VOL[x].name)
		{ 
			nVolBars++
			//-------set up defaults-----
			//If max AND min=0, you either have mute block or you want defaults
			send_string dvMixer,"'get fader max "',MXR_VOL[x].name,'"',$0D"
			send_string dvMixer,"'get fader min "',MXR_VOL[x].name,'"',$0D"

			///If no increment is set, use default
			IF(!MXR_VOL[x].inc) 			MXR_VOL[x].inc=DefaultInc
			
			if(!mxr_vol[x].ramp)			MXR_VOL[x].ramp=DefaultRamp
			
			cLvlStr[RampUp][x]="'inc fader "',MXR_VOL[x].name,'" ',itoa(MXR_VOL[x].inc),$0D"
			cLvlStr[RampDn][x]="'dec fader "',MXR_VOL[x].name,'" ',itoa(MXR_VOL[x].inc),$0D"
			
			cMteStr[MuteOn][x]="'set mute "',MXR_VOL[x].name,'" 1',$0D"
			cMteStr[MuteOff][x]="'set mute "',MXR_VOL[x].name,'" 0',$0D"
			
			cQueryStr[x]="'get fader "',MXR_VOL[x].name,'"',$0D"
			cQueryMuteStr[x]="'get mute "',MXR_VOL[x].name,'"',$0D"
			
			cLvlResponse[x]="'val fader "',MXR_VOL[x].name,'" '"
			cMaxResponse[x]="'val fader max "',MXR_VOL[x].name,'" '"
			cMinResponse[x]="'val fader min "',MXR_VOL[x].name,'" '"
			cMuteResponse[x]="'val mute "',MXR_VOL[x].name,'" '"
		}
	}
	if(!timeline_active(tlQuerY))timeline_create(tlQuery,lQueryTimes,nVolBars+1,timeline_relative,timeline_repeat)
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

WAIT 20
{
	read_mixer()
	init_strings()
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
				ACTIVE(FIND_STRING(cBuff,"$0D",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0D",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0D",1)):
				{
					nPos=FIND_STRING(cBuff,"$0D",1)
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



channel_event[vdvMixer,0]
{
	on:	  
	{
		OnPush(channel.channel,get_last(vdvMixer))
	}
	off:	
	{
		IF(timeline_active(2000+get_last(vdvMixer)))	
			timeline_kill(2000+get_last(vdvMixer))
	}	
}


button_event [vdvTP,0]
{                  
	push:		
	{
		if(button.input.channel=MIX_VOL_UP || button.input.channel=MIX_VOL_DN) TO[button.input]
		to[vdvMixer[get_last(vdvTP)],button.input.channel]
	}
}

timeline_event[tlQuery]
{
	if(timeline.sequence>1)
	{
		pulse[vdvMixer[timeline.sequence-1],MIX_QUERY]
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

