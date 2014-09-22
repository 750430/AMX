module_name='Fake Mixer Rev6-00'(dev dvTP[], dev vdvMixer[], dev vdvMixer_FB[], dev dvMixer)
(***********************************************************)
(*  FILE_LAST_MODifIED_ON: 12/02/2011  AT: 13:33:01        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                

*)
(***********************************************************)
(*----------------MODULE INSTRUCTIONS----------------------*)
(*


	define_module 'Fake Mixer Rev6-00' mxr1(dvTP_VOL,vdvMixer,vdvMixer_FB,dvMixer) 

*)
(***********************************************************)
#include 'HoppSNAPI Rev6-00.axi'
#include 'HoppSTRUCT Rev6-00.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //System Constants
NumVolBars		= 90

RampUp			= 1
RampDn			= 2

define_constant //Buttons

integer		btnVolBank1[]	=	{1,2,3,4,5,6}
integer		btnVolBank2[]	=	{11,12,13,14,15,16}
integer		btnVolBank3[]	=	{21,22,23,24,25,26}

define_constant //Default Values
integer		DefaultMax		= 255
integer		DefaultMin 		= 0
integer		DefaultInc		= 4
integer		DefaultRamp		= 4
integer		DefaultLevel	= 200
char		DefaultChan[]	= '1'
char		DefaultAddr[] 	= '1'


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable //Active Variables

volatile		integer		nActiveVolBar
volatile		integer		nActiveVolButton
volatile		integer		nRamping

define_variable //Volblock and Strings

volatile		volblock	mxr_vol[NumVolBars]

volatile 		char 		cMteTxt[10]
volatile 		char 		cLvlTxt[10]
volatile 		char 		cMteStr[NumVolBars][50]
volatile 		char 		cLvlStr[NumVolBars][50]
volatile 		char 		cBuff[255]
volatile 		long 		nArray[NumVolBars]
volatile 		integer 	nChange[NumVolBars]

define_variable //Binary File Variables

volatile		long		lPos
volatile		slong		slReturn
volatile		slong		slFile
volatile		slong		slResult
volatile		char		sBINString[10000]

sinteger		nValue


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function show_level(integer nI)
{
	if(mxr_vol[nI].enabled) 
	{
		select
		{
			active(nI>0 and nI<=30):	send_level dvTP[nI],1,mxr_vol[nI].lvl
			active(nI>30 and nI<=60):	send_level dvTP[nI-30],2,mxr_vol[nI].lvl
			active(nI>60 and nI<=90):	send_level dvTP[nI-60],3,mxr_vol[nI].lvl
		}
		send_level vdvMixer_FB[nI],1,mxr_vol[nI].lvl
	}
}

define_function OnPush(integer nCmd,integer nI)
{
	switch(nCmd)
	{
		case MIX_VOL_UP:		StartTimeline(RampUp,nI)	
		case MIX_VOL_DN: 		StartTimeline(RampDn,nI)	
		case MIX_MUTE_TOG: 		MXR_VOL[nI].mte=!MXR_VOL[nI].mte
		case MIX_MUTE_OFF: 		off[MXR_VOL[nI].mte]
		case MIX_MUTE_ON:  		on[MXR_VOL[nI].mte]
		case MIX_QUERY: 		show_level(nI)
		case MIX_UPDATE_ALL:	update_tp()
	}
}

define_function StartTimeline(integer nDir, integer nI)
{
	stack_var long lTLArray[1]
	Ramp(nDir,nI)
	nChange[nI]=nDir
	lTLArray[1]=nArray[nI]
	tp_fb()
	on[nRamping]
	timeline_create(2000+nI,lTLArray,max_length_array(lTLArray),timeline_relative,timeline_repeat)
}
define_function Ramp(integer nDir, integer nI)
{
	//stack_var sinteger nValue
	//we want to allow audio when a user initiates ramping
	off[MXR_VOL[nI].mte]
	
	switch(nDir)
	{
		case RampUp:
		{
			select
			{
				active((MXR_VOL[nI].lvl+MXR_VOL[nI].inc)>=MXR_VOL[nI].max):	MXR_VOL[nI].lvl=MXR_VOL[nI].max
				active(MXR_VOL[nI].lvl<MXR_VOL[nI].min):	MXR_VOL[nI].lvl=MXR_VOL[nI].min
				active(1):  MXR_VOL[nI].lvl=MXR_VOL[nI].lvl+MXR_VOL[nI].inc
			}
		}	
		case RampDn:
		{
			select
			{
				active((MXR_VOL[nI].lvl-MXR_VOL[nI].inc)<=MXR_VOL[nI].min):	MXR_VOL[nI].lvl=MXR_VOL[nI].min
				active(MXR_VOL[nI].lvl>MXR_VOL[nI].max): MXR_VOL[nI].lvl=MXR_VOL[nI].max
				active(1):	MXR_VOL[nI].lvl=MXR_VOL[nI].lvl-MXR_VOL[nI].inc
			}
		}
	}
	show_level(nI)
}

define_function read_mixer()
{
	// Read Binary File
	slFile = file_open('BinaryMXREncode.xml',1)
	slResult = file_read(slFile, sBINString, max_length_string(sBINString))
	slResult = file_close (slFile)
	// Convert To Binary
	lPos = 1
	slReturn = string_to_variable(MXR_VOL, sBINString, lPos)	
	
	update_tp()
}

define_function init_strings()
{
	for(x=1;x<=max_length_array(MXR_VOL);x++)
	{
		if(length_string(mxr_vol[x].name)>0 or length_string(mxr_vol[x].instIDTag)>0 or length_string(mxr_vol[x].addr)>0 or mxr_vol[x].instID) on[mxr_vol[x].enabled]
	
		//-------set up defaults-----
		//If max AND min=0, you either have mute block or you want defaults
		if(!MXR_VOL[x].max && !MXR_VOL[x].min)
		{
			MXR_VOL[x].max=DefaultMax
			MXR_VOL[x].min=DefaultMin
		}
		
		//If no chan, chanin, or chanout defined, fill in chan 
		if(!length_string(MXR_VOL[x].chan) && !length_string(MXR_VOL[x].chanin) && 
		   !length_string(MXR_VOL[x].chanout)) 	MXR_VOL[x].chan=DefaultChan
		
		///If any other value missing, fill it in
		if(!MXR_VOL[x].ramp) 					MXR_VOL[x].ramp=DefaultRamp
		if(!MXR_VOL[x].inc) 					MXR_VOL[x].inc=DefaultInc
		if(!length_string(MXR_VOL[x].addr)) 	MXR_VOL[x].addr=DefaultAddr
		if(!length_string(MXR_VOL[x].type)) 	MXR_VOL[x].type=FADER_TYPE
		if(!MXR_VOL[x].lvl)						MXR_VOL[x].lvl=DefaultLevel

		//sets up time that will be used for each timeline
		nArray[x]=(MXR_VOL[x].ramp*1000)/ABS_VALUE(((MXR_VOL[x].max-MXR_VOL[x].min)/MXR_VOL[x].inc))
		show_level(x)
	}
}

define_function update_tp()
{
	for(x=1;x<=max_length_array(MXR_VOL);x++) show_level(x)
}

define_function tp_fb()
{
	if(!nRamping)
	{
		for(x=1;x<=NumVolBars;x++)
		{
			if(mxr_vol[x].enabled)
			{
				[vdvMixer_FB[x],MIX_MUTE_ON]	=	MXR_VOL[x].mte
				[vdvMixer_FB[x],MIX_MUTE_OFF]	=	!MXR_VOL[x].mte
			}
		}	
		for(x=1;x<=30;x++)
		{
			if(mxr_vol[x].enabled)
			{
				[dvTP[x],MIX_MUTE_TOG]			=	MXR_VOL[x].mte
				[dvTP[x],MIX_MUTE_ON]			=	MXR_VOL[x].mte
				[dvTP[x],MIX_MUTE_OFF]			=	!MXR_VOL[x].mte
			}
		}
		
		for(x=31;x<=60;x++)
		{
			if(mxr_vol[x].enabled)
			{
				[dvTP[x-30],MIX_MUTE_TOG+10]	=	MXR_VOL[x].mte
				[dvTP[x-30],MIX_MUTE_ON+10]		=	MXR_VOL[x].mte
				[dvTP[x-30],MIX_MUTE_OFF+10]	=	!MXR_VOL[x].mte
			}
		}
		
		for(x=61;x<=90;x++)
		{
			if(mxr_vol[x].enabled)
			{
				[dvTP[x-60],MIX_MUTE_TOG+20]	=	MXR_VOL[x].mte
				[dvTP[x-60],MIX_MUTE_ON+20]		=	MXR_VOL[x].mte
				[dvTP[x-60],MIX_MUTE_OFF+20]	=	!MXR_VOL[x].mte
			}
		}	
	}
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

WAIT 20
{
	read_mixer()
	init_strings()
}

#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                THE eventS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvTP]
{
	online:
	{
		update_tp()
	}
}

data_event[dvMixer]
{
	online:
	{
		init_strings()
	}
}

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
timeline_event[2051]{Ramp(nChange[51],51)}
timeline_event[2052]{Ramp(nChange[52],52)}
timeline_event[2053]{Ramp(nChange[53],53)}
timeline_event[2054]{Ramp(nChange[54],54)}
timeline_event[2055]{Ramp(nChange[55],55)}
timeline_event[2056]{Ramp(nChange[56],56)}
timeline_event[2057]{Ramp(nChange[57],57)}
timeline_event[2058]{Ramp(nChange[58],58)}
timeline_event[2059]{Ramp(nChange[59],59)}
timeline_event[2060]{Ramp(nChange[60],60)}
timeline_event[2061]{Ramp(nChange[61],61)}
timeline_event[2062]{Ramp(nChange[62],62)}
timeline_event[2063]{Ramp(nChange[63],63)}
timeline_event[2064]{Ramp(nChange[64],64)}
timeline_event[2065]{Ramp(nChange[65],65)}
timeline_event[2066]{Ramp(nChange[66],66)}
timeline_event[2067]{Ramp(nChange[67],67)}
timeline_event[2068]{Ramp(nChange[68],68)}
timeline_event[2069]{Ramp(nChange[69],69)}
timeline_event[2070]{Ramp(nChange[70],70)}
timeline_event[2071]{Ramp(nChange[71],71)}
timeline_event[2072]{Ramp(nChange[72],72)}
timeline_event[2073]{Ramp(nChange[73],73)}
timeline_event[2074]{Ramp(nChange[74],74)}
timeline_event[2075]{Ramp(nChange[75],75)}
timeline_event[2076]{Ramp(nChange[76],76)}
timeline_event[2077]{Ramp(nChange[77],77)}
timeline_event[2078]{Ramp(nChange[78],78)}
timeline_event[2079]{Ramp(nChange[79],79)}
timeline_event[2080]{Ramp(nChange[80],80)}
timeline_event[2081]{Ramp(nChange[81],81)}
timeline_event[2082]{Ramp(nChange[82],82)}
timeline_event[2083]{Ramp(nChange[83],83)}
timeline_event[2084]{Ramp(nChange[84],84)}
timeline_event[2085]{Ramp(nChange[85],85)}
timeline_event[2086]{Ramp(nChange[86],86)}
timeline_event[2087]{Ramp(nChange[87],87)}
timeline_event[2088]{Ramp(nChange[88],88)}
timeline_event[2089]{Ramp(nChange[89],89)}
timeline_event[2090]{Ramp(nChange[90],90)}

CHANNEL_event[vdvMixer,0]
{
	ON:	  
	{
		OnPush(channel.channel,get_last(vdvMixer))
	}
	OFF:	
	{
		if(timeline_active(2000+get_last(vdvMixer)))	
		{
			timeline_kill(2000+get_last(vdvMixer))
			off[nRamping]
		}
	}	
}


button_event [dvTP,btnVolBank1]
{                  
	push:		
	{
		nActiveVolBar=get_last(dvTP)
		nActiveVolButton=get_last(btnVolBank1)
		if(nActiveVolButton=MIX_VOL_UP || nActiveVolButton=MIX_VOL_DN) to[button.input]
		to[vdvMixer[nActiveVolBar],nActiveVolButton]
	}
}

button_event [dvTP,btnVolBank2]
{                  
	push:		
	{
		nActiveVolBar=get_last(dvTP)+30
		nActiveVolButton=get_last(btnVolBank2)
		if(nActiveVolButton=MIX_VOL_UP || nActiveVolButton=MIX_VOL_DN) to[button.input]
		to[vdvMixer[nActiveVolBar],nActiveVolButton]
	}
}

button_event [dvTP,btnVolBank3]
{                  
	push:		
	{	
		nActiveVolBar=get_last(dvTP)+60
		nActiveVolButton=get_last(btnVolBank3)
		if(nActiveVolButton=MIX_VOL_UP || nActiveVolButton=MIX_VOL_DN) to[button.input]
		to[vdvMixer[nActiveVolBar],nActiveVolButton]
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program





(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

