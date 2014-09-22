MODULE_NAME='Biamp Tesira Vol Control Rev5-00'(DEV vdvTP[], DEV vdvMixer[], DEV dvMixer)
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

*)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-12.axi'
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
INTEGER DefaultInc	= 1
integer DefaultRamp	= 100
char DefaultChan=	'1'

INTEGER RampUp			= 1
INTEGER RampDn			= 2

integer MuteOn			=	1
integer MuteOff			=	2
integer MuteTog			=	3

integer	tlSubscribe		=	1001
integer tlResubscribe	=	1002

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

integer nJeff

VOLBLOCK MXR_VOL[50]

volatile	char		cLvlStr[2][50][50]
volatile	char		cMteStr[3][50][50]
volatile	char		cQueryStr[50][50]
volatile	char		cQueryMuteStr[50][50]

volatile	char		cLvlResponse[50][50]
volatile	char		cMaxResponse[50][50]
volatile	char		cMinResponse[50][50]
volatile	char		cMuteResponse[50][50]
volatile	char		cQueryResponse[50][50]
volatile	char		cQueryMuteResponse[50][50]

volatile	integer nMaxResponseFound
volatile	integer	nMinResponseFound
volatile	integer	nQueryResponseFound
volatile	integer	nQueryMuteResponseFound

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

long		lSubscribeTimes[6]={100,100,100,100,100,100}


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	stack_var integer nPos
	STACK_VAR INTEGER nAMXLvl
	
	select
	{
		active(find_string(cCompStr,"'Welcome to the Tesira Text Protocol Server'",1)):
		{
			subscribe()
		}
		active(nMaxResponseFound):
		{
			remove_string(cCompStr,"'+OK',$20,'"value":'",1)
			nPos=find_string(cCompStr,"'.'",1)
			MXR_VOL[nMaxResponseFound].max=atoi(get_buffer_string(cCompStr,nPos-1))
			off[nMaxResponseFound]
		}
		active(nMinResponseFound):
		{
			remove_string(cCompStr,"'+OK',$20,'"value":'",1)
			nPos=find_string(cCompStr,"'.'",1)
			MXR_VOL[nMinResponseFound].min=atoi(get_buffer_string(cCompStr,nPos-1))
			off[nMinResponseFound]
		}
		active(nQueryResponseFound):
		{
			remove_string(cCompStr,"'+OK',$20,'"value":'",1)
			nPos=find_string(cCompStr,"'.'",1)
			MXR_VOL[nQueryResponseFound].lvl=atoi(get_buffer_string(cCompStr,nPos-1))
			nAMXLvl= ABS_VALUE((255*(MXR_VOL[nQueryResponseFound].lvl-MXR_VOL[nQueryResponseFound].min))/(MXR_VOL[nQueryResponseFound].max-MXR_VOL[nQueryResponseFound].min))
			send_level vdvTP[nQueryResponseFound],1,nAMXLvl
			off[nQueryResponseFound]
		}
		active(nQueryMuteResponseFound):
		{
			remove_string(cCompStr,"'+OK',$20,'"value":'",1)
			nPos=find_string(cCompStr,"$0D",1)
			switch(get_buffer_string(cCompStr,nPos-1))
			{
				case 'false': set_mute_off(nQueryMuteResponseFound)
				case 'true': set_mute_on(nQueryMuteResponseFound)
			}
			off[nQueryMuteResponseFound]
		}
		active(1):
		{
			off[nMaxResponseFound]
			off[nMinResponseFound]
			off[nQueryResponseFound]
			off[nQueryMuteResponseFound]
			for(x=1;x<=max_length_array(mxr_vol);x++)
			{
				select
				{
					active(find_string(cCompStr,cLvlResponse[x],1)):
					{
						remove_string(cCompStr,cLvlResponse[x],1)
						nPos=find_string(cCompStr,"'.'",1)
						MXR_VOL[x].lvl=atoi(get_buffer_string(cCompStr,nPos-1))
						//send_string 0,"'MXR_VOL[x].lvl=',itoa(MXR_VOL[x].lvl)"
						nAMXLvl= ABS_VALUE((255*(MXR_VOL[x].lvl-MXR_VOL[x].min))/(MXR_VOL[x].max-MXR_VOL[x].min))
						//send_string 0,"'nAMXLvl=',itoa(nAMXLvl)"
						send_level vdvTP[x],1,nAMXLvl
					}
					active(find_string(cCompStr,cMuteResponse[x],1)):
					{
						remove_string(cCompStr,cMuteResponse[x],1)
						nPos=find_string(cCompStr,"$0D",1)
						switch(get_buffer_string(cCompStr,nPos-1))
						{
							case 'false': set_mute_off(x)
							case 'true': set_mute_on(x)
						}
					}
					active(find_string(cCompStr,cMaxResponse[x],1)): nMaxResponseFound=x
					active(find_string(cCompStr,cMinResponse[x],1)): nMinResponseFound=x
					active(find_string(cCompStr,cQueryResponse[x],1)): nQueryResponseFound=x
					active(find_string(cCompStr,cQueryMuteResponse[x],1)): nQueryMuteResponseFound=x
				}
			}
		}
	}
}

define_function set_mute_on(nVal)
{
	on[MXR_VOL[nVal].mte]
	on[vdvMixer[nVal],MIX_MUTE_ON_FB]
	off[vdvMixer[nVal],MIX_MUTE_OFF_FB]

	[vdvTP[nVal],MIX_MUTE_TOG]	= [vdvMixer[nVal],MIX_MUTE_ON_FB]
	[vdvTP[nVal],MIX_MUTE_ON]	= [vdvMixer[nVal],MIX_MUTE_ON_FB]
	[vdvTP[nVal],MIX_MUTE_OFF]	= [vdvMixer[nVal],MIX_MUTE_OFF_FB]
}

define_function set_mute_off(nVal)
{
	off[MXR_VOL[nVal].mte]
	off[vdvMixer[nVal],MIX_MUTE_ON_FB]
	on[vdvMixer[nVal],MIX_MUTE_OFF_FB]
	
	[vdvTP[nVal],MIX_MUTE_TOG]	= [vdvMixer[nVal],MIX_MUTE_ON_FB]
	[vdvTP[nVal],MIX_MUTE_ON]	= [vdvMixer[nVal],MIX_MUTE_ON_FB]
	[vdvTP[nVal],MIX_MUTE_OFF]	= [vdvMixer[nVal],MIX_MUTE_OFF_FB]
}

DEFINE_FUNCTION OnPush(INTEGER nCmd,INTEGER nCurrentVolBar)
{
	STACK_VAR INTEGER x
	SWITCH(nCmd)
	{
		CASE MIX_VOL_UP:		StartTimeline(RampUp,nCurrentVolBar)	
		CASE MIX_VOL_DN: 		StartTimeline(RampDn,nCurrentVolBar)	
		CASE MIX_MUTE_TOG:	send_string dvMixer,"cMteStr[MuteTog][nCurrentVolBar]"
		CASE MIX_MUTE_OFF: 	send_string dvMixer,"cMteStr[MuteOff][nCurrentVolBar]"
		CASE MIX_MUTE_ON:  	send_string dvMixer,"cMteStr[MuteOn][nCurrentVolBar]"
		CASE MIX_QUERY:  
		{
			send_string dvMixer,"cQueryStr[nCurrentVolBar]"
			send_string dvMixer,"cQueryMuteStr[nCurrentVolBar]"
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
	send_string dvMixer,"cLvlStr[nDirection][nCurrentVolBar]"
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
		IF(length_string(MXR_VOL[x].instIDTag)>0)
		{ 
			nVolBars++

			///If no increment is set, use default
			IF(!MXR_VOL[x].inc) 			MXR_VOL[x].inc=DefaultInc
			
			if(!mxr_vol[x].ramp)			MXR_VOL[x].ramp=DefaultRamp
			
			if(length_array(mxr_vol[x].chan)=0)			MXR_VOL[x].chan=DefaultChan
			
			cLvlStr[RampUp][x]="mxr_vol[x].instIDTag,$20,'increment',$20,'level',$20,MXR_VOL[x].chan,$20,itoa(MXR_VOL[x].inc),$0D"
			cLvlStr[RampDn][x]="mxr_vol[x].instIDTag,$20,'decrement',$20,'level',$20,MXR_VOL[x].chan,$20,itoa(MXR_VOL[x].inc),$0D"
			
			cMteStr[MuteOn][x]="mxr_vol[x].instIDTag,$20,'set',$20,'mute',$20,MXR_VOL[x].chan,$20,'true',$0D"
			cMteStr[MuteOff][x]="mxr_vol[x].instIDTag,$20,'set',$20,'mute',$20,MXR_VOL[x].chan,$20,'false',$0D"
			cMteStr[MuteTog][x]="mxr_vol[x].instIDTag,$20,'toggle',$20,'mute',$20,MXR_VOL[x].chan,$0D"
			
			cQueryStr[x]="mxr_vol[x].instIDTag,$20,'get',$20,'level',$20,MXR_VOL[x].chan,$0D"
			cQueryMuteStr[x]="mxr_vol[x].instIDTag,$20,'get',$20,'mute',$20,MXR_VOL[x].chan,$0D"
			
			cLvlResponse[x]="'! "publishToken":"',mxr_vol[x].instIDTag,'level" "value":'"
			cMuteResponse[x]="'! "publishToken":"',mxr_vol[x].instIDTag,'mute" "value":'"
			cMaxResponse[x]="mxr_vol[x].instIDTag,$20,'get',$20,'maxLevel',$20,MXR_VOL[x].chan"
			cMinResponse[x]="mxr_vol[x].instIDTag,$20,'get',$20,'minLevel',$20,MXR_VOL[x].chan"
			cQueryResponse[x]="mxr_vol[x].instIDTag,$20,'get',$20,'level',$20,MXR_VOL[x].chan"
			cQueryMuteResponse[x]="mxr_vol[x].instIDTag,$20,'get',$20,'mute',$20,MXR_VOL[x].chan"
			
		}
	}
	resubscribe()
}

define_function resubscribe()
{
	if(!timeline_active(tlResubscribe)) timeline_kill(tlResubscribe)
	timeline_create(tlResubscribe,lSubscribeTimes,2,timeline_relative,timeline_repeat)
}

define_function subscribe()
{
	if(!timeline_active(tlSubscribe)) timeline_kill(tlSubscribe)
	timeline_create(tlSubscribe,lSubscribeTimes,length_array(lSubscribeTimes),timeline_relative,timeline_repeat)
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
		LOCAL_VAR CHAR cHold[2056]
		LOCAL_VAR CHAR cBuff[2056]
		LOCAL_VAR CHAR cFullStr[100]
		STACK_VAR INTEGER nPos
		
		cBuff = "cBuff,data.text"
		WHILE(LENGTH_STRING(cBuff))
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cBuff,"$0D,$0A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0D,$0A",1)+1
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0D,$0A",1)):
				{
					nPos=FIND_STRING(cBuff,"$0D,$0A",1)+1
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

timeline_event[tlSubscribe]
{
	if(timeline.repetition+1>nVolBars) timeline_kill(tlSubscribe)
	else
	{
		switch(timeline.sequence)
		{
			case 1: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'get',$20,'maxLevel',$20,MXR_VOL[timeline.repetition+1].chan,$0D"
			case 2: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'get',$20,'minLevel',$20,MXR_VOL[timeline.repetition+1].chan,$0D"
			case 3: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'subscribe',$20,'level',$20,MXR_VOL[timeline.repetition+1].chan,$20,mxr_vol[timeline.repetition+1].instIDTag,'level',$0D"
			case 4: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'subscribe',$20,'mute',$20,MXR_VOL[timeline.repetition+1].chan,$20,mxr_vol[timeline.repetition+1].instIDTag,'mute',$0D"
			case 5: send_string dvMixer,"cQueryStr[timeline.repetition+1]"
			case 6: send_string dvMixer,"cQueryMuteStr[timeline.repetition+1]"
		}
	}
}

timeline_event[tlResubscribe]
{
	if(timeline.repetition+1>nVolBars) 
	{
		timeline_kill(tlResubscribe)
		subscribe()
	}
	else
	{
		switch(timeline.sequence)
		{
			case 1: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'unsubscribe',$20,'level',$20,MXR_VOL[timeline.repetition+1].chan,$20,mxr_vol[timeline.repetition+1].instIDTag,'level',$0D"
			case 2: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'unsubscribe',$20,'mute',$20,MXR_VOL[timeline.repetition+1].chan,$20,mxr_vol[timeline.repetition+1].instIDTag,'mute',$0D"
		}	
	}
}


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

if(nJeff)
{
	for(x=1;x<=50;x++)
	{
		mxr_vol[x].max=0
		mxr_vol[x].min=0
	}
	off[nJeff]
	resubscribe()
	
}

if (time_to_second(TIME) == 0)
{
	if(time_to_hour(time)=23 and time_to_minute(time)=0)
	{
		resubscribe()
	}
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

