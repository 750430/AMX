module_name='Biamp Tesira Vol Control Rev6-00'(dev dvTP[], dev vdvMixer[], dev vdvMixer_FB[], dev dvMixer)
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
	define_module 'Biamp Tesira Vol Control Rev6-00' mxr1(vdvTP_VOL,vdvMixer,vdvMixer_FB,dvBiamp) 
*)
(***********************************************************)
#include 'HoppSNAPI Rev6-00.axi'
#include 'HoppSTRUCT Rev6-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //System Constants
NumVolBars		= 90

rampUp			= 1
rampDn			= 2

define_constant //Buttons

integer		btnVolBank1[]	=	{1,2,3,4,5,6}
integer		btnVolBank2[]	=	{11,12,13,14,15,16}
integer		btnVolBank3[]	=	{21,22,23,24,25,26}

define_constant //Default values
integer 	DefaultInc	=	1
integer 	DefaultRamp	=	100
char 		DefaultChan	=	'1'

integer MuteOn			=	1
integer MuteOff			=	2
integer MuteTog			=	3

define_constant //Timelines

integer	tlSubscribe		=	1001
integer tlResubscribe	=	1002

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable //Active Variables

volatile		integer		nJeff
volatile		char		cJeff[255]

volatile		integer		nSubscribeTLActive
volatile		integer		nResubscribeTLActive

volatile		integer		nActiveVolBar
volatile		integer		nActiveVolButton
volatile		integer		nActiveRamping
volatile		integer		nHighestVolBar

volatile		integer		nAMXLevel

define_variable //Volblock and Strings

volatile	volblock 	mxr_vol[NumVolBars]

volatile	char		cLvlStr[2][NumVolBars][50]
volatile	char		cMteStr[3][NumVolBars][50]
volatile	char		cQueryStr[NumVolBars][50]
volatile	char		cQueryMuteStr[NumVolBars][50]

volatile	char		cLvlResponse[NumVolBars][50]
volatile	char		cMaxResponse[NumVolBars][50]
volatile	char		cMinResponse[NumVolBars][50]
volatile	char		cMuteResponse[NumVolBars][50]
volatile	char		cQueryResponse[NumVolBars][50]
volatile	char		cQueryMuteResponse[NumVolBars][50]

volatile	integer 	nMaxResponseFound
volatile	integer		nMinResponseFound
volatile	integer		nQueryResponseFound
volatile	integer		nQueryMuteResponseFound

volatile	integer		nChange[50]		//Direction Change
	//dro//  	nChange[1] is for volume 1
	//dro//		nChange is 1 or 2 for RampUp or RampDown, respectively

define_variable //Binary File Variables

volatile		long		lPos
volatile		slong		slReturn
volatile		slong		slFile
volatile		slong		slResult
volatile		char		sBINString[10000]

define_variable //Timeline Variables

long		lSubscribeTimes[6]={150,150,150,150,150,150}


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
define_function read_mixer()
{

	// Read Binary File
	slFile = FILE_OPEN('BinaryMXREncode.xml',1)
	slResult = FILE_READ(slFile, sBINString, MAX_LENGTH_STRING(sBINString))
	slResult = FILE_CLOSE (slFile)
	// Convert To Binary
	lPos = 1
	slReturn = STRING_TO_VARIABLE(mxr_vol, sBINString, lPos)	
	
	update_tp()
}

define_function init_strings()
{
	for (x=1;x<=max_length_array(mxr_vol);x++)
	{
		if(length_string(mxr_vol[x].instIDTag)>0)
		{ 
			if(x>nHighestVolBar) nHighestVolBar=x
			on[mxr_vol[x].enabled]

			///Set Up Defaults
			if(!mxr_vol[x].inc) 					mxr_vol[x].inc=DefaultInc
			if(!mxr_vol[x].ramp)					mxr_vol[x].ramp=DefaultRamp
			if(length_array(mxr_vol[x].chan)=0)		mxr_vol[x].chan=DefaultChan
			
			//Set Level Strings
			cLvlStr[RampUp][x]="mxr_vol[x].instIDTag,$20,'increment',$20,'level',$20,mxr_vol[x].chan,$20,itoa(mxr_vol[x].inc),$0D"
			cLvlStr[RampDn][x]="mxr_vol[x].instIDTag,$20,'decrement',$20,'level',$20,mxr_vol[x].chan,$20,itoa(mxr_vol[x].inc),$0D"
			
			//Set Mute Strings
			cMteStr[MuteOn][x]="mxr_vol[x].instIDTag,$20,'set',$20,'mute',$20,mxr_vol[x].chan,$20,'true',$0D"
			cMteStr[MuteOff][x]="mxr_vol[x].instIDTag,$20,'set',$20,'mute',$20,mxr_vol[x].chan,$20,'false',$0D"
			cMteStr[MuteTog][x]="mxr_vol[x].instIDTag,$20,'toggle',$20,'mute',$20,mxr_vol[x].chan,$0D"
			
			//Set Query Strings
			cQueryStr[x]="mxr_vol[x].instIDTag,$20,'get',$20,'level',$20,mxr_vol[x].chan,$0D"
			cQueryMuteStr[x]="mxr_vol[x].instIDTag,$20,'get',$20,'mute',$20,mxr_vol[x].chan,$0D"
			
			//Set Response Strings
			cLvlResponse[x]="'! "publishToken":"',mxr_vol[x].instIDTag,mxr_vol[x].chan,'level" "value":'"
			cMuteResponse[x]="'! "publishToken":"',mxr_vol[x].instIDTag,mxr_vol[x].chan,'mute" "value":'"
			cMaxResponse[x]="mxr_vol[x].instIDTag,$20,'get',$20,'maxLevel',$20,mxr_vol[x].chan"
			cMinResponse[x]="mxr_vol[x].instIDTag,$20,'get',$20,'minLevel',$20,mxr_vol[x].chan"
			cQueryResponse[x]="mxr_vol[x].instIDTag,$20,'get',$20,'level',$20,mxr_vol[x].chan"
			cQueryMuteResponse[x]="mxr_vol[x].instIDTag,$20,'get',$20,'mute',$20,mxr_vol[x].chan"
			
		}
	}
	resubscribe()
}

define_function resubscribe()
{
	if(!timeline_active(tlResubscribe)) timeline_create(tlResubscribe,lSubscribeTimes,2,timeline_relative,timeline_repeat)
}

define_function subscribe()
{
	if(!timeline_active(tlSubscribe)) timeline_create(tlSubscribe,lSubscribeTimes,length_array(lSubscribeTimes),timeline_relative,timeline_repeat)
}

define_function parse(CHAR cCompStr[100])
{
	stack_var integer nPos
	stack_var integer nFlag
	
	select
	{
		active(find_string(cCompStr,"'Welcome to the Tesira Text Protocol Server'",1)):
		{
			subscribe()
		}
		active(cCompStr[1]='^'):
		{
			//Do Nothing
			//If this character is the first character, it's a string we're sending from the Biamp for other reasons, don't waste time parsing it
		}
		active(nMaxResponseFound):
		{
			remove_string(cCompStr,"'+OK',$20,'"value":'",1)
			nPos=find_string(cCompStr,"'.'",1)
			mxr_vol[nMaxResponseFound].max=atoi(get_buffer_string(cCompStr,nPos-1))
			off[nMaxResponseFound]
		}
		active(nMinResponseFound):
		{
			remove_string(cCompStr,"'+OK',$20,'"value":'",1)
			nPos=find_string(cCompStr,"'.'",1)
			mxr_vol[nMinResponseFound].min=atoi(get_buffer_string(cCompStr,nPos-1))
			off[nMinResponseFound]
		}
		active(nQueryResponseFound):
		{
			remove_string(cCompStr,"'+OK',$20,'"value":'",1)
			nPos=find_string(cCompStr,"'.'",1)
			mxr_vol[nQueryResponseFound].lvl=atoi(get_buffer_string(cCompStr,nPos-1))
			show_level(nQueryResponseFound)
			off[nQueryResponseFound]
		}
		active(nQueryMuteResponseFound):
		{
			remove_string(cCompStr,"'+OK',$20,'"value":'",1)
			nPos=find_string(cCompStr,"$0D",1)
			switch(get_buffer_string(cCompStr,nPos-1))
			{
				case 'false': off[mxr_vol[nQueryMuteResponseFound].mte]
				case 'true': on[mxr_vol[nQueryMuteResponseFound].mte]
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
				on[nFlag]
				select
				{
					active(find_string(cCompStr,cLvlResponse[x],1)):
					{
						remove_string(cCompStr,cLvlResponse[x],1)
						nPos=find_string(cCompStr,"'.'",1)
						mxr_vol[x].lvl=atoi(get_buffer_string(cCompStr,nPos-1))
						
						show_level(x)
					}
					active(find_string(cCompStr,cMuteResponse[x],1)):
					{
						remove_string(cCompStr,cMuteResponse[x],1)
						nPos=find_string(cCompStr,"$0D",1)
						switch(get_buffer_string(cCompStr,nPos-1))
						{
							case 'false': off[mxr_vol[x].mte]
							case 'true': on[mxr_vol[x].mte]
						}
					}
					active(find_string(cCompStr,cMaxResponse[x],1)): nMaxResponseFound=x
					active(find_string(cCompStr,cMinResponse[x],1)): nMinResponseFound=x
					active(find_string(cCompStr,cQueryResponse[x],1)): nQueryResponseFound=x
					active(find_string(cCompStr,cQueryMuteResponse[x],1)): nQueryMuteResponseFound=x
					active(1): off[nFlag]
				}
				if(nFlag) break	//This line stops running the For Loop if we find the vol bar we were looking for
			}
		}
	}
}


define_function OnPush(integer nCmd,integer nCurrentVolBar)
{
	stack_var integer x
	switch(nCmd)
	{
		case MIX_VOL_UP:		start_ramp_timeline(RampUp,nCurrentVolBar)	
		case MIX_VOL_DN: 		start_ramp_timeline(RampDn,nCurrentVolBar)	
		case MIX_MUTE_TOG:		send_string dvMixer,"cMteStr[MuteTog][nCurrentVolBar]"
		case MIX_MUTE_OFF: 		send_string dvMixer,"cMteStr[MuteOff][nCurrentVolBar]"
		case MIX_MUTE_ON:  		send_string dvMixer,"cMteStr[MuteOn][nCurrentVolBar]"
		case MIX_QUERY:  
		{
			send_string dvMixer,"cQueryStr[nCurrentVolBar]"
			send_string dvMixer,"cQueryMuteStr[nCurrentVolBar]"
		}
		case MIX_RESUBSCRIBE:
		{
			resubscribe()
		}
	}
}
define_function start_ramp_timeline(INTEGER nDirection, INTEGER nCurrentVolBar)
{
	stack_var long lTLArray[1]

	ramp(nDirection,nCurrentVolBar)
	nChange[nCurrentVolBar]=nDirection
	lTLArray[1]=mxr_vol[nCurrentVolBar].ramp
	timeline_create(2000+nCurrentVolBar,lTLArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
}

define_function ramp(integer nDirection, integer nCurrentVolBar)
{
	send_string dvMixer,"cLvlStr[nDirection][nCurrentVolBar]"
}



define_function show_level(integer nI)
{
	if(mxr_vol[nI].enabled)
	{
		nAMXLevel=ABS_VALUE((255*(mxr_vol[nI].lvl-mxr_vol[nI].min))/(mxr_vol[nI].max-mxr_vol[nI].min))
		select
		{
			active(nI>0 and nI<=30):	send_level dvTP[nI],1,nAMXLevel
			active(nI>30 and nI<=60):	send_level dvTP[nI-30],2,nAMXLevel
			active(nI>60 and nI<=90):	send_level dvTP[nI-60],3,nAMXLevel
		}
		send_level vdvMixer_FB[nI],1,nAMXLevel
	}
}

define_function update_tp()
{
	for(x=1;x<=max_length_array(mxr_vol);x++)
	{
		show_level(x)
	}
}

define_function tp_fb()
{
	for(x=1;x<=NumVolBars;x++)
	{
		if(mxr_vol[x].enabled) 
		{
			[vdvMixer_FB[x],MIX_MUTE_ON]	=	mxr_vol[x].mte
			[vdvMixer_FB[x],MIX_MUTE_OFF]	=	!mxr_vol[x].mte
		}
	}	
	for(x=1;x<=30;x++)
	{
		if(mxr_vol[x].enabled)
		{
			[dvTP[x],MIX_MUTE_TOG]			=	mxr_vol[x].mte
			[dvTP[x],MIX_MUTE_ON]			=	mxr_vol[x].mte
			[dvTP[x],MIX_MUTE_OFF]			=	!mxr_vol[x].mte
		}
	}
	for(x=31;x<=60;x++)
	{
		if(mxr_vol[x].enabled)
		{
			[dvTP[x-30],MIX_MUTE_TOG+10]	=	mxr_vol[x].mte
			[dvTP[x-30],MIX_MUTE_ON+10]		=	mxr_vol[x].mte
			[dvTP[x-30],MIX_MUTE_OFF+10]	=	!mxr_vol[x].mte
		}
	}
	for(x=61;x<=90;x++)
	{
		if(mxr_vol[x].enabled)
		{
			[dvTP[x-60],MIX_MUTE_TOG+20]	=	mxr_vol[x].mte
			[dvTP[x-60],MIX_MUTE_ON+20]		=	mxr_vol[x].mte
			[dvTP[x-60],MIX_MUTE_OFF+20]	=	!mxr_vol[x].mte
		}
	}	
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

wait 20
{
	read_mixer()
	init_strings()
}

#include 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event //Data Events
data_event[dvMixer]
{
	STRING:
	{
		LOCAL_VAR CHAR cHold[2056]
		LOCAL_VAR CHAR cBuff[2056]
		LOCAL_VAR CHAR cFullStr[100]
		STACK_VAR INTEGER nPos
		
		cBuff = "cBuff,data.text"
		cJeff = "cJeff,data.text"
		
		WHILE(LENGTH_STRING(cBuff))
		{
			SELECT
			{
				active(left_string(cBuff,1)=$FF):
				{
					if(left_string(cBuff,3)="$FF,$FB,$01")
					{
						send_string dvMixer,"$FF,$FD,$01"
					}
					else
					{
						switch(mid_string(cBuff,2,1))
						{
							case $FD: send_string dvMixer,"$FF,$FC,mid_string(cBuff,3,1)"
							case $FB: send_string dvMixer,"$FF,$FE,mid_string(cBuff,3,1)"
						}
					}
					remove_string(cBuff,mid_string(cBuff,3,1),1)
				}
				active(FIND_STRING(cBuff,"$0D,$0A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0D,$0A",1)+1
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				active(FIND_STRING(cBuff,"$0D,$0A",1)):
				{
					nPos=FIND_STRING(cBuff,"$0D,$0A",1)+1
					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
					parse(cFullStr)
				}
				active(1):
				{
					cHold="cHold,cBuff"
					cBuff=''
				}
			}
		}
	}
}

define_event //Ramp Timelines

timeline_event[2001]{Ramp(nChange[1],1)}
timeline_event[2002]{Ramp(nChange[2],2)}
timeline_event[2003]{Ramp(nChange[3],3)}
timeline_event[2004]{Ramp(nChange[4],4)}
timeline_event[2005]{Ramp(nChange[5],5)}
timeline_event[2006]{Ramp(nChange[6],6)}
timeline_event[2007]{Ramp(nChange[7],7)}
timeline_event[2008]{Ramp(nChange[8],8)}
timeline_event[2009]{Ramp(nChange[9],9)}
timeline_event[2010]{Ramp(nChange[10],10)}
timeline_event[2011]{Ramp(nChange[11],11)}
timeline_event[2012]{Ramp(nChange[12],12)}
timeline_event[2013]{Ramp(nChange[13],13)}
timeline_event[2014]{Ramp(nChange[14],14)}
timeline_event[2015]{Ramp(nChange[15],15)}
timeline_event[2016]{Ramp(nChange[16],16)}
timeline_event[2017]{Ramp(nChange[17],17)}
timeline_event[2018]{Ramp(nChange[18],18)}
timeline_event[2019]{Ramp(nChange[19],19)}
timeline_event[2020]{Ramp(nChange[20],20)}
timeline_event[2021]{Ramp(nChange[21],21)}
timeline_event[2022]{Ramp(nChange[22],22)}
timeline_event[2023]{Ramp(nChange[23],23)}
timeline_event[2024]{Ramp(nChange[24],24)}
timeline_event[2025]{Ramp(nChange[25],25)}
timeline_event[2026]{Ramp(nChange[26],26)}
timeline_event[2027]{Ramp(nChange[27],27)}
timeline_event[2028]{Ramp(nChange[28],28)}
timeline_event[2029]{Ramp(nChange[29],29)}
timeline_event[2030]{Ramp(nChange[30],30)}
timeline_event[2031]{Ramp(nChange[31],31)}
timeline_event[2032]{Ramp(nChange[32],32)}
timeline_event[2033]{Ramp(nChange[33],33)}
timeline_event[2034]{Ramp(nChange[34],34)}
timeline_event[2035]{Ramp(nChange[35],35)}
timeline_event[2036]{Ramp(nChange[36],36)}
timeline_event[2037]{Ramp(nChange[37],37)}
timeline_event[2038]{Ramp(nChange[38],38)}
timeline_event[2039]{Ramp(nChange[39],39)}
timeline_event[2040]{Ramp(nChange[40],40)}
timeline_event[2041]{Ramp(nChange[41],41)}
timeline_event[2042]{Ramp(nChange[42],42)}
timeline_event[2043]{Ramp(nChange[43],43)}
timeline_event[2044]{Ramp(nChange[44],44)}
timeline_event[2045]{Ramp(nChange[45],45)}
timeline_event[2046]{Ramp(nChange[46],46)}
timeline_event[2047]{Ramp(nChange[47],47)}
timeline_event[2048]{Ramp(nChange[48],48)}
timeline_event[2049]{Ramp(nChange[49],49)}
timeline_event[2050]{Ramp(nChange[50],50)}

define_event //Channel and Button Control

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


button_event [dvTP,0]
{                  
	push:		
	{
		if(button.input.channel=MIX_VOL_UP || button.input.channel=MIX_VOL_DN) TO[button.input]
		to[vdvMixer[get_last(dvTP)],button.input.channel]
	}
}

define_event //Subscription Events

timeline_event[tlSubscribe]
{
	if(timeline.repetition+1>nHighestVolBar) timeline_kill(tlSubscribe)
	else
	{
		switch(timeline.sequence)
		{
			case 1: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'get',$20,'maxLevel',$20,mxr_vol[timeline.repetition+1].chan,$0D"
			case 2: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'get',$20,'minLevel',$20,mxr_vol[timeline.repetition+1].chan,$0D"
			case 3: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'subscribe',$20,'level',$20,mxr_vol[timeline.repetition+1].chan,$20,mxr_vol[timeline.repetition+1].instIDTag,mxr_vol[timeline.repetition+1].chan,'level',$0D"
			case 4: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'subscribe',$20,'mute',$20,mxr_vol[timeline.repetition+1].chan,$20,mxr_vol[timeline.repetition+1].instIDTag,mxr_vol[timeline.repetition+1].chan,'mute',$0D"
			case 5: send_string dvMixer,"cQueryStr[timeline.repetition+1]"
			case 6: send_string dvMixer,"cQueryMuteStr[timeline.repetition+1]"
		}
	}
}

timeline_event[tlResubscribe]
{
	if(timeline.repetition+1>nHighestVolBar) 
	{
		timeline_kill(tlResubscribe)
		subscribe()
	}
	else
	{
		switch(timeline.sequence)
		{
			case 1: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'unsubscribe',$20,'level',$20,mxr_vol[timeline.repetition+1].chan,$20,mxr_vol[timeline.repetition+1].instIDTag,mxr_vol[timeline.repetition+1].chan,'level',$0D"
			case 2: send_string dvMixer,"mxr_vol[timeline.repetition+1].instIDTag,$20,'unsubscribe',$20,'mute',$20,mxr_vol[timeline.repetition+1].chan,$20,mxr_vol[timeline.repetition+1].instIDTag,mxr_vol[timeline.repetition+1].chan,'mute',$0D"
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

nSubscribeTLActive=timeline_active(tlSubscribe)
nResubscribeTLActive=timeline_active(tlResubscribe)

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

