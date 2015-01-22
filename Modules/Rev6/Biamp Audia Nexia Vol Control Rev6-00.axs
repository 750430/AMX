module_name='Biamp Audia Nexia Vol Control Rev6-00'(dev dvTP[], dev vdvMixer[], dev vdvMixer_FB[], dev dvMixer)
(***********************************************************)
(*  FILE_LAST_MODifIED_ON: 12/02/2011  AT: 13:33:01        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                

*)
(***********************************************************)
(*

	SET BAUD 38400,N,8,1 485 DISABLE
	define_module 'Biamp Audia Nexia Vol Control Rev6-00' mxr1(vdvTP_VOL,vdvMixer,vdvMixer_FB,dvBiamp) 

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

define_constant //Default Values
integer		DefaultMax		= 12
integer		DefaultMin 		= -40
integer		DefaultInc		= 1
integer		DefaultRamp		= 8
char		DefaultChan[]	= '1'
char		DefaultAddr[] 	= '1'

define_constant //Timelines
integer 	tlMixQuery		=	3001
integer		tlPollMixQuery	=	3002

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable //Active Variables

volatile		integer		nActiveVolBar
volatile		integer		nActiveVolButton
volatile		integer		nActiveRamping

volatile		integer		nAMXLevel

define_variable //Volblock and Strings

volatile		volblock	mxr_vol[NumVolBars]

volatile 		char 		cMteTxt[10]
volatile 		char 		cLvlTxt[10]
volatile 		char 		cMteStr[NumVolBars][50]
volatile 		char 		cLvlStr[NumVolBars][50]
volatile 		char 		cBuff[255]
volatile 		long 		nRampTimesArray[NumVolBars]
volatile 		integer 	nChange[NumVolBars]

define_variable //Binary File Variables

volatile		long		lPos
volatile		slong		slReturn
volatile		slong		slFile
volatile		slong		slResult
volatile		char		sBINString[10000]

define_variable //Mix Query Variables

volatile		integer		nMaxVolBar
volatile		long		lMixQueryTimes[NumVolBars]
non_volatile	long		lPollMixQueryTimes[]={60000}


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
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

		if(MXR_VOL[x].instID or length_string(MXR_VOL[x].instIDTag)>0)
		{ 
			on[MXR_VOL[x].enabled]
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
			
			select
			{
				active(length_string(MXR_VOL[x].instIDTag)>0):
				{
					select
					{
						active(atoi(MXR_VOL[x].chan)>0):
						{
							if (MXR_VOL[x].type<>LOGIC_TYPE) cMteTxt="MXR_VOL[x].type,'MUTE'"
							else cMteTxt="MXR_VOL[x].type"
							cLvlTxt="MXR_VOL[x].type,'LVL'"
							cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,MXR_VOL[x].instIDTag,$20,MXR_VOL[x].chan,$20"
							cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,MXR_VOL[x].instIDTag,$20,MXR_VOL[x].chan,$20"
						}
						active(atoi(MXR_VOL[x].chanin)>0 && atoi(MXR_VOL[x].chanout)>0):
						{
							cMteTxt="MXR_VOL[x].type,'MUTEXP'"
							cLvlTxt="MXR_VOL[x].type,'LVLXP'"
							cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,MXR_VOL[x].instIDTag,$20,MXR_VOL[x].chanin,$20,MXR_VOL[x].chanout,$20"
							cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,MXR_VOL[x].instIDTag,$20,MXR_VOL[x].chanin,$20,MXR_VOL[x].chanout,$20"
						}
						active(atoi(MXR_VOL[x].chanin)>0):
						{
							cMteTxt="MXR_VOL[x].type,'MUTEIN'"
							cLvlTxt="MXR_VOL[x].type,'LVLIN'"
							cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,MXR_VOL[x].instIDTag,$20,MXR_VOL[x].chanin,$20"
							cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,MXR_VOL[x].instIDTag,$20,MXR_VOL[x].chanin,$20"
						}
						active(atoi(MXR_VOL[x].chanout)>0):
						{
							cMteTxt="MXR_VOL[x].type,'MUTEOUT'"
							cLvlTxt="MXR_VOL[x].type,'LVLOUT'"
							cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,MXR_VOL[x].instIDTag,$20,MXR_VOL[x].chanout,$20"
							cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,MXR_VOL[x].instIDTag,$20,MXR_VOL[x].chanout,$20"
						}
					}					
				}				
				active(MXR_VOL[x].instID):
				{
					select
					{
						active(atoi(MXR_VOL[x].chan)>0):
						{
							if (MXR_VOL[x].type<>LOGIC_TYPE) cMteTxt="MXR_VOL[x].type,'MUTE'"
							else cMteTxt="MXR_VOL[x].type"
							cLvlTxt="MXR_VOL[x].type,'LVL'"
							cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chan,$20"
							cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chan,$20"
						}
						active(atoi(MXR_VOL[x].chanin)>0 && atoi(MXR_VOL[x].chanout)>0):
						{
							cMteTxt="MXR_VOL[x].type,'MUTEXP'"
							cLvlTxt="MXR_VOL[x].type,'LVLXP'"
							cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanin,$20,MXR_VOL[x].chanout,$20"
							cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanin,$20,MXR_VOL[x].chanout,$20"
						}
						active(atoi(MXR_VOL[x].chanin)>0):
						{
							cMteTxt="MXR_VOL[x].type,'MUTEIN'"
							cLvlTxt="MXR_VOL[x].type,'LVLIN'"
							cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanin,$20"
							cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanin,$20"
						}
						active(atoi(MXR_VOL[x].chanout)>0):
						{
							cMteTxt="MXR_VOL[x].type,'MUTEOUT'"
							cLvlTxt="MXR_VOL[x].type,'LVLOUT'"
							cMteStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cMteTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanout,$20"
							cLvlStr[x]="'ETD',$20,MXR_VOL[x].addr,$20,cLvlTxt,$20,ITOA(MXR_VOL[x].instID),$20,MXR_VOL[x].chanout,$20"
						}
					}
				}
			}
			//sets up time that will be used for each timeline
			nRampTimesArray[x]=(MXR_VOL[x].ramp*1000)/ABS_VALUE(((MXR_VOL[x].max-MXR_VOL[x].min)/MXR_VOL[x].inc))
			show_level(x)
		}
	}
}


define_function parse(char cCompStr[100])
{
	stack_var integer nPos
	stack_var integer nFlag
	
	if(find_string(cCompStr,"'#'",1))  //Only parse things with a #, that means they're actually responses and not echoes
	{
		if(find_string(cCompStr,'LVL',1) || find_string(cCompStr,'MUTE',1) || find_string(cCompStr,'LGSTATE',1))
		{
			for(x=1;x<=max_length_array(MXR_VOL);x++)
			{
				select
				{
					active(find_string(cCompStr,cLvlStr[x],1)):
					{
						on[nFlag]
						remove_string(cCompStr,cLvlStr[x],1)
						nPos=find_string(cCompStr,"$20",1)
						MXR_VOL[x].lvl=atoi(get_buffer_string(cCompStr,nPos-1))
						
						if(MXR_VOL[x].lvl>MXR_VOL[x].max)	MXR_VOL[x].lvl=MXR_VOL[x].max
						else if(MXR_VOL[x].lvl<MXR_VOL[x].min) MXR_VOL[x].lvl=MXR_VOL[x].min
						show_level(x)
					}
					active(find_string(cCompStr,cMteStr[x],1)):
					{
						on[nFlag]
						remove_string(cCompStr,cMteStr[x],1)
						nPos=find_string(cCompStr,"$20",1)
						MXR_VOL[x].mte=atoi(get_buffer_string(cCompStr,nPos-1))
						
						//matrix point and logic type special case.  0 and 1 are reversed in these instances
						if(length_string(MXR_VOL[x].chanin) && length_string(MXR_VOL[x].chanout))
							MXR_VOL[x].mte=!MXR_VOL[x].mte
					}
				}
				if(nFlag) break	//This line stops running the For Loop if we find the vol bar we were looking for
			}	
		}
	}
}


define_function query_mixer()
{
	nMaxVolBar=0
	for(x=1;x<=max_length_array(mxr_vol);x++)
	{
		if(length_string(mxr_vol[x].chan)>0 or length_string(mxr_vol[x].instidTag)) nMaxVolBar=x
	}
	
	if(!timeline_active(tlMixQuery)) 
	{
		timeline_create(tlMixQuery,lMixQueryTimes,nMaxVolBar,timeline_relative,timeline_once)
	}
}




define_function start_ramp_timeline(integer nDir, integer nI)
{
	stack_var long lTLArray[1]
	ramp(nDir,nI)
	nChange[nI]=nDir
	lTLArray[1]=nRampTimesArray[nI]
	timeline_create(2000+nI,lTLArray,max_length_array(lTLArray),timeline_relative,timeline_repeat)
}

define_function ramp(integer nDir, integer nI)
{
	stack_var sinteger nValue
	on[nActiveRamping]
	if(timeline_active(tlMixQuery)) timeline_kill(tlMixQuery)

	//if chanin and chanout have length, we are dealing with a matrix point
	//a mute 1 will enable a matrix point (passing audio)
	//a mute 1 will stop audio for any other situation
	
	//we want to allow audio when a user initiates ramping
	select
	{
		active(MXR_VOL[nI].mte && !(length_string(MXR_VOL[nI].chanin) && length_string(MXR_VOL[nI].chanout))): 
			SEND_string dvMixer,"'S',cMteStr[nI],'0',$0A"
		active(MXR_VOL[nI].mte && (length_string(MXR_VOL[nI].chanin) && length_string(MXR_VOL[nI].chanout))): 
			SEND_string dvMixer,"'S',cMteStr[nI],'1',$0A"
	}
	
	switch(nDir)
	{
		case rampUp:
		{
			select
			{
				active((MXR_VOL[nI].lvl+MXR_VOL[nI].inc)>=MXR_VOL[nI].max):	nValue=MXR_VOL[nI].max
				active(MXR_VOL[nI].lvl<MXR_VOL[nI].min):	nValue=MXR_VOL[nI].min
				active(1):  nValue=MXR_VOL[nI].lvl+MXR_VOL[nI].inc
			}
		}	
		case rampDn:
		{
			select
			{
				active((MXR_VOL[nI].lvl-MXR_VOL[nI].inc)<=MXR_VOL[nI].min):	nValue=MXR_VOL[nI].min
				active(MXR_VOL[nI].lvl>MXR_VOL[nI].max): nValue=MXR_VOL[nI].max
				active(1):	nValue=MXR_VOL[nI].lvl-MXR_VOL[nI].inc
			}
		}
	}
	SEND_STRING dvMixer,"'S',cLvlStr[nI],ITOA(nValue),$0A"
}

define_function show_level(integer nI)
{
	if(MXR_VOL[nI].enabled)
	{
		nAMXLevel=ABS_VALUE((255*(MXR_VOL[x].lvl-MXR_VOL[x].min))/(MXR_VOL[x].max-MXR_VOL[x].min))
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
	for(x=1;x<=max_length_array(MXR_VOL);x++)
	{
		show_level(x)
		if(length_string(MXR_VOL[x].name)>0) send_command dvTP[x],"'^TXT-',itoa(MIX_NAME),',0,',MXR_VOL[x].name"
		else send_command dvTP[x],"'^TXT-',itoa(MIX_NAME),',0,Level ',itoa(x)"
	}
}

define_function tp_fb()
{
	for(x=1;x<=NumVolBars;x++)
	{
		if(MXR_VOL[x].enabled) 
		{
			[vdvMixer_FB[x],MIX_MUTE_ON]	=	MXR_VOL[x].mte
			[vdvMixer_FB[x],MIX_MUTE_OFF]	=	!MXR_VOL[x].mte
		}
	}	
	for(x=1;x<=30;x++)
	{
		if(MXR_VOL[x].enabled)
		{
			[dvTP[x],MIX_MUTE_TOG]			=	MXR_VOL[x].mte
			[dvTP[x],MIX_MUTE_ON]			=	MXR_VOL[x].mte
			[dvTP[x],MIX_MUTE_OFF]			=	!MXR_VOL[x].mte
		}
	}
	for(x=31;x<=60;x++)
	{
		if(MXR_VOL[x].enabled)
		{
			[dvTP[x-30],MIX_MUTE_TOG+10]	=	MXR_VOL[x].mte
			[dvTP[x-30],MIX_MUTE_ON+10]		=	MXR_VOL[x].mte
			[dvTP[x-30],MIX_MUTE_OFF+10]	=	!MXR_VOL[x].mte
		}
	}
	for(x=61;x<=90;x++)
	{
		if(MXR_VOL[x].enabled)
		{
			[dvTP[x-60],MIX_MUTE_TOG+20]	=	MXR_VOL[x].mte
			[dvTP[x-60],MIX_MUTE_ON+20]		=	MXR_VOL[x].mte
			[dvTP[x-60],MIX_MUTE_OFF+20]	=	!MXR_VOL[x].mte
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
	query_mixer()
}
for(x=1;x<=NumVolBars;x++) lMixQueryTimes[x]=200
timeline_create(tlPollMixQuery,lPollMixQueryTimes,1,timeline_relative,timeline_repeat)

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
		read_mixer()
		init_strings()
		query_mixer()
		
	}
	string:
	{
		local_var char cHold[100]
		local_var char cBuff[255]
		local_var char cFullStr[100]
		stack_var integer nPos
		
		cBuff = "cBuff,data.text"
		while(length_string(cBuff))
		{
			select
			{
				active(find_string(cBuff,"$0A",1)&& length_string(cHold)):
				{
					nPos=find_string(cBuff,"$0A",1)
					cFullStr="cHold,get_buffer_string(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				active(find_string(cBuff,"$0A",1)):
				{
					nPos=find_string(cBuff,"$0A",1)
					cFullStr=get_buffer_string(cBuff,nPos)
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

timeline_event[2001]{ramp(nChange[1],1)}
timeline_event[2002]{ramp(nChange[2],2)}
timeline_event[2003]{ramp(nChange[3],3)}
timeline_event[2004]{ramp(nChange[4],4)}
timeline_event[2005]{ramp(nChange[5],5)}
timeline_event[2006]{ramp(nChange[6],6)}
timeline_event[2007]{ramp(nChange[7],7)}
timeline_event[2008]{ramp(nChange[8],8)}
timeline_event[2009]{ramp(nChange[9],9)}
timeline_event[2010]{ramp(nChange[10],10)}
timeline_event[2011]{ramp(nChange[11],11)}
timeline_event[2012]{ramp(nChange[12],12)}
timeline_event[2013]{ramp(nChange[13],13)}
timeline_event[2014]{ramp(nChange[14],14)}
timeline_event[2015]{ramp(nChange[15],15)}
timeline_event[2016]{ramp(nChange[16],16)}
timeline_event[2017]{ramp(nChange[17],17)}
timeline_event[2018]{ramp(nChange[18],18)}
timeline_event[2019]{ramp(nChange[19],19)}
timeline_event[2020]{ramp(nChange[20],20)}
timeline_event[2021]{ramp(nChange[21],21)}
timeline_event[2022]{ramp(nChange[22],22)}
timeline_event[2023]{ramp(nChange[23],23)}
timeline_event[2024]{ramp(nChange[24],24)}
timeline_event[2025]{ramp(nChange[25],25)}
timeline_event[2026]{ramp(nChange[26],26)}
timeline_event[2027]{ramp(nChange[27],27)}
timeline_event[2028]{ramp(nChange[28],28)}
timeline_event[2029]{ramp(nChange[29],29)}
timeline_event[2030]{ramp(nChange[30],30)}
timeline_event[2031]{ramp(nChange[31],31)}
timeline_event[2032]{ramp(nChange[32],32)}
timeline_event[2033]{ramp(nChange[33],33)}
timeline_event[2034]{ramp(nChange[34],34)}
timeline_event[2035]{ramp(nChange[35],35)}
timeline_event[2036]{ramp(nChange[36],36)}
timeline_event[2037]{ramp(nChange[37],37)}
timeline_event[2038]{ramp(nChange[38],38)}
timeline_event[2039]{ramp(nChange[39],39)}
timeline_event[2040]{ramp(nChange[40],40)}
timeline_event[2041]{ramp(nChange[41],41)}
timeline_event[2042]{ramp(nChange[42],42)}
timeline_event[2043]{ramp(nChange[43],43)}
timeline_event[2044]{ramp(nChange[44],44)}
timeline_event[2045]{ramp(nChange[45],45)}
timeline_event[2046]{ramp(nChange[46],46)}
timeline_event[2047]{ramp(nChange[47],47)}
timeline_event[2048]{ramp(nChange[48],48)}
timeline_event[2049]{ramp(nChange[49],49)}
timeline_event[2050]{ramp(nChange[50],50)}
timeline_event[2051]{ramp(nChange[51],51)}
timeline_event[2052]{ramp(nChange[52],52)}
timeline_event[2053]{ramp(nChange[53],53)}
timeline_event[2054]{ramp(nChange[54],54)}
timeline_event[2055]{ramp(nChange[55],55)}
timeline_event[2056]{ramp(nChange[56],56)}
timeline_event[2057]{ramp(nChange[57],57)}
timeline_event[2058]{ramp(nChange[58],58)}
timeline_event[2059]{ramp(nChange[59],59)}
timeline_event[2060]{ramp(nChange[60],60)}
timeline_event[2061]{ramp(nChange[61],61)}
timeline_event[2062]{ramp(nChange[62],62)}
timeline_event[2063]{ramp(nChange[63],63)}
timeline_event[2064]{ramp(nChange[64],64)}
timeline_event[2065]{ramp(nChange[65],65)}
timeline_event[2066]{ramp(nChange[66],66)}
timeline_event[2067]{ramp(nChange[67],67)}
timeline_event[2068]{ramp(nChange[68],68)}
timeline_event[2069]{ramp(nChange[69],69)}
timeline_event[2070]{ramp(nChange[70],70)}
timeline_event[2071]{ramp(nChange[71],71)}
timeline_event[2072]{ramp(nChange[72],72)}
timeline_event[2073]{ramp(nChange[73],73)}
timeline_event[2074]{ramp(nChange[74],74)}
timeline_event[2075]{ramp(nChange[75],75)}
timeline_event[2076]{ramp(nChange[76],76)}
timeline_event[2077]{ramp(nChange[77],77)}
timeline_event[2078]{ramp(nChange[78],78)}
timeline_event[2079]{ramp(nChange[79],79)}
timeline_event[2080]{ramp(nChange[80],80)}
timeline_event[2081]{ramp(nChange[81],81)}
timeline_event[2082]{ramp(nChange[82],82)}
timeline_event[2083]{ramp(nChange[83],83)}
timeline_event[2084]{ramp(nChange[84],84)}
timeline_event[2085]{ramp(nChange[85],85)}
timeline_event[2086]{ramp(nChange[86],86)}
timeline_event[2087]{ramp(nChange[87],87)}
timeline_event[2088]{ramp(nChange[88],88)}
timeline_event[2089]{ramp(nChange[89],89)}
timeline_event[2090]{ramp(nChange[90],90)}


channel_event[vdvMixer,0]
{
	ON:	  
	{
		nActiveVolBar=get_last(vdvMixer)
		nActiveVolButton=channel.channel
		if(mxr_vol[nActiveVolBar].chan>0 or length_string(mxr_vol[nActiveVolBar].instIDtag)>0)
		{
			switch(nActiveVolButton)
			{
				case MIX_VOL_UP:		start_ramp_timeline(rampUp,nActiveVolBar)	
				case MIX_VOL_DN: 		start_ramp_timeline(rampDn,nActiveVolBar)	
				case MIX_MUTE_TOG: 		send_string dvMixer,"'S',cMteStr[nActiveVolBar],ITOA(!MXR_VOL[nActiveVolBar].mte),$0A" 
				case MIX_MUTE_OFF: 	
				{
					//matrix point special case
					if(length_string(MXR_VOL[nActiveVolBar].chanin) && length_string(MXR_VOL[nActiveVolBar].chanout))	
						send_string dvMixer,"'S',cMteStr[nActiveVolBar],'1',$0A" 
					else	
						send_string dvMixer,"'S',cMteStr[nActiveVolBar],'0',$0A" 
				}
				case MIX_MUTE_ON:  	
				{
					//matrix point special case
					if(length_string(MXR_VOL[nActiveVolBar].chanin) && length_string(MXR_VOL[nActiveVolBar].chanout))	
						send_string dvMixer,"'S',cMteStr[nActiveVolBar],'0',$0A" 
					else
						send_string dvMixer,"'S',cMteStr[nActiveVolBar],'1',$0A" 
				}
				case MIX_QUERY: 
				{
					if(length_array(cMteStr[nActiveVolBar])) 
						send_string dvMixer,"'G',cMteStr[nActiveVolBar],$0A"
					if(length_array(cLvlStr[nActiveVolBar]) && MXR_VOL[nActiveVolBar].type<>MUTE_TYPE) 
						WAIT 1 send_string dvMixer,"'G',cLvlStr[nActiveVolBar],$0A"
				}
				case MIX_UPDATE_ALL:
				{
					query_mixer()
				}
			}
		}		
	}
	OFF:	
	{
		if(timeline_active(2000+get_last(vdvMixer))) timeline_kill(2000+get_last(vdvMixer))
		off[nActiveRamping]
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

timeline_event[tlMixQuery]
{
	if(mxr_vol[timeline.sequence].chan>0 or length_string(mxr_vol[timeline.sequence].instIDtag)>0) pulse[vdvMixer[timeline.sequence],MIX_QUERY]
}

timeline_event[tlPollMixQuery]
{
	if(!nActiveRamping) query_mixer()
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

