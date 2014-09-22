MODULE_NAME='Extron DMP 64 Rev5-00'(DEV vdvTP[], DEV vdvMixer[], DEV dvMixer)
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



	DEFINE_START
	
	VOL[1].flag1 		= 1						//Volume Group to Control
	VOL[1].flag2		= 2						//Mute Group to Control
	
	
	You must set the Volume and Mute groups in the DMP Config software.  This module only controls group volume and group mutes.
	If you want the mix query timeline to work, you also have to define something under vol[1].chan, even if it's just '1'.  I'll fix this in a future release but for now
	just define a blank variable and it'll work  fine.
	
	
	define_module 'Extron DMP 64 Rev5-00' mxr1(vdvTP_VOL,vdvMXR,dvMixer) 

*)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-09.axi'
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
INTEGER DefaultRamp	= 10

INTEGER RampUp			= 1
INTEGER RampDn			= 2

MixQueryTL			=	3001
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLBLOCK MXR_VOL[50]

volatile char cVolRespStr[50][20]
volatile char cMuteRespStr[50][20]
VOLATILE LONG nArray[50]
VOLATILE INTEGER nChange[50]

VOLATILE	LONG lPos
VOLATILE	SLONG slReturn
VOLATILE	SLONG slFile
VOLATILE	SLONG slResult
VOLATILE	CHAR sBINString[10000]

VOLATILE INTEGER nVolBtn[]={1,2,3,4,5,6,7,8,9,10}

non_volatile	long		lMixQueryTimes[]={100}
non_volatile	char		cMixQueryQueue[50][20]
non_volatile	char		cMixQueryResp[50][20]
non_volatile	integer		nMixQueryQueuePos
non_volatile	integer		nMixQueryQueueSent
non_volatile	integer		nWaitingforResponse
non_volatile	integer		nNoResponse
non_volatile	integer		nMixQueryQueueWrapped

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
	if(nWaitingforResponse)
	{
		off[nWaitingforResponse]
		cCompStr="cMixQueryResp[nMiXQueryQueueSent],cCompStr"  //For some reason the Extron doesn't return the proper prefix when you poll the status of a group.
																//This adds the prefix back so the parsing below happens correctly all the time.
		send_string 0,"'cCompStr=',cCompstr"
		cMixQueryResp[nMixQueryQueueSent]=''
	}
	for(x=1;x<=max_length_array(MXR_VOL);x++)
	{
		send_string 0,"'x=',itoa(x)"
		if(find_string(cCompStr,cVolRespStr[x],1))
		{
			send_string 0,"'find_string cVolRespStr Successful'"
			remove_string(cCompStr,cVolRespStr[x],1)
			remove_string(cCompStr,'*',1)
			if(find_string(cCompStr,'+',1)) remove_string(cCompStr,'+',1)
			MXR_VOL[x].lvl=atoi(cCompStr)
			MXR_VOL[x].lvl=MXR_VOL[x].lvl/10
			nAMXLvl=abs_value((255*(MXR_VOL[x].lvl-MXR_VOL[x].min))/(MXR_VOL[x].max-MXR_VOL[x].min))
			SEND_LEVEL vdvTP[x],1,nAMXLvl			
		}
		if(find_string(cCompStr,cMuteRespStr[x],1))
		{	
			send_string 0,"'find_string cVolMuteStr Successful'"
			select
			{
				active(find_string(cCompStr,"'00001'",1)): on[MXR_VOL[x].mte]
				active(find_string(cCompStr,"'00000'",1)): off[MXR_VOL[x].mte]
			}
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
		CASE MIX_MUTE_TOG: 	
		{
			switch(MXR_VOL[nI].mte)
			{
				case 1: pulse[vdvMixer[nI],MIX_MUTE_OFF]
				case 0: pulse[vdvMixer[nI],MIX_MUTE_ON]
			}
		}
		CASE MIX_MUTE_OFF: 	
		{
			SEND_STRING dvMixer,"$1B,'D',itoa(MXR_VOL[nI].flag2),'*0GRPM',$0D,$0A"
		}
		CASE MIX_MUTE_ON:  	
		{
			SEND_STRING dvMixer,"$1B,'D',itoa(MXR_VOL[nI].flag2),'*1GRPM',$0D,$0A"
		}
		CASE MIX_QUERY: 
		{
			add_to_mix_query_queue(nI)
		}
	}
}

define_function add_to_mix_query_queue(integer nI)
{
	IF(MXR_VOL[nI].flag1)
	{
		if(nMixQueryQueuePos<50) nMixQueryQueuePos++
		else 
		{
			nMixQueryQueuePos=1
			on[nMixQueryQueueWrapped]
		}
		cMixQueryQueue[nMixQueryQueuePos]="$1B,'D',itoa(MXR_VOL[nI].flag1),'GRPM',$0D,$0A"
		cMixQueryResp[nMiXQueryQueuePos]="cVolRespStr[nI],'*'"
	}
	
	IF(MXR_VOL[nI].flag2)
	{
		if(nMixQueryQueuePos<50) nMixQueryQueuePos++
		else 
		{
			nMixQueryQueuePos=1
			on[nMixQueryQueueWrapped]
		}
		cMixQueryQueue[nMixQueryQueuePos]="$1B,'D',itoa(MXR_VOL[nI].flag2),'GRPM',$0D,$0A"
		cMixQueryResp[nMiXQueryQueuePos]="cMuteRespStr[nI],'*'"
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
	
	SWITCH(nDir)
	{
		CASE RampUp:
		{
			SELECT
			{
				ACTIVE((MXR_VOL[nI].lvl)>=MXR_VOL[nI].max):
				{
					SEND_LEVEL vdvTP[nI],1,abs_value((255*(MXR_VOL[nI].lvl-MXR_VOL[nI].min))/(MXR_VOL[nI].max-MXR_VOL[nI].min))
				}
				ACTIVE(MXR_VOL[nI].lvl<MXR_VOL[nI].min):	send_string dvMixer,"$1B,'D',itoa(MXR_VOL[nI].flag1),'*',itoa(MXR_VOL[nI].min),'GRPM',$0D,$0A"
				ACTIVE(1):  send_string dvMixer,"$1B,'D',itoa(MXR_VOL[nI].flag1),'*10+GRPM',$0D,$0A"
			}
		}	
		CASE RampDn:
		{
			SELECT
			{
				ACTIVE((MXR_VOL[nI].lvl)<=MXR_VOL[nI].min):
				{
					SEND_LEVEL vdvTP[nI],1,abs_value((255*(MXR_VOL[nI].lvl-MXR_VOL[nI].min))/(MXR_VOL[nI].max-MXR_VOL[nI].min))
				}
				ACTIVE(MXR_VOL[nI].lvl>MXR_VOL[nI].max): send_string dvMixer,"$1B,'D',itoa(MXR_VOL[nI].flag1),'*',itoa(MXR_VOL[nI].max),'GRPM',$0D,$0A"
				ACTIVE(1):	send_string dvMixer,"$1B,'D',itoa(MXR_VOL[nI].flag1),'*10-GRPM',$0D,$0A"
			}
		}
	}
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
	send_string 0,"'Read Binary File'"
}


DEFINE_CALL 'INIT_STRINGS'
{
	FOR (x=1;x<=MAX_LENGTH_ARRAY(MXR_VOL);x++)
	{
		IF(!MXR_VOL[x].max && !MXR_VOL[x].min)
		{
			MXR_VOL[x].max=DefaultMax
			MXR_VOL[x].min=DefaultMin
		}
//		///If any other value missing, fill it in
		IF(!MXR_VOL[x].ramp) 								MXR_VOL[x].ramp=DefaultRamp
		IF(!MXR_VOL[x].inc) 								MXR_VOL[x].inc=DefaultInc

		if(MXR_VOL[x].flag1) 
		{
			if(length_string(itoa(MXR_VOL[x].flag1))=1) cVolRespStr[x]="'GrpmD0',itoa(MXR_VOL[x].flag1)"
			if(length_string(itoa(MXR_VOL[x].flag1))=2) cVolRespStr[x]="'GrpmD',itoa(MXR_VOL[x].flag1)"
		}
		if(MXR_VOL[x].flag2) 
		{
			if(length_string(itoa(MXR_VOL[x].flag2))=1) cMuteRespStr[x]="'GrpmD0',itoa(MXR_VOL[x].flag2)"
			if(length_string(itoa(MXR_VOL[x].flag2))=2) cMuteRespStr[x]="'GrpmD',itoa(MXR_VOL[x].flag2)"
		}


		//sets up time that will be used for each timeline
		nArray[x]=(MXR_VOL[x].ramp*1000)/ABS_VALUE(((MXR_VOL[x].max-MXR_VOL[x].min)/MXR_VOL[x].inc))
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

TIMELINE_CREATE(MixQueryTL,lMixQueryTimes,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)

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

timeline_event[MixQueryTL]
{
	if (nWaitingforResponse)
	{
		nNoResponse++
	}
	if(nNoResponse>5)
	{
		nNoResponse=0
		for(x=1;x<=50;x++)
		{
			cMixQueryQueue[x]=''
			cMixQueryResp[x]=''
		}
		nMixQueryQueueSent=0
		nMiXQueryQueuePos=0
		off[nMixQueryQueueWrapped]
		off[nWaitingforResponse]
	}	
	if(nMixQueryQueueSent<nMixQueryQueuePos or (nMixQueryQueueSent>nMixQueryQueuePos and nMixQueryQueueWrapped))
	{
		if(!nWaitingforResponse)
		{
			on[nWaitingforResponse]
			if(nMixQueryQueueSent<50) nMixQueryQueueSent++
			else 
			{
				nMixQueryQueueSent=1
				off[nMixQueryQueueWrapped]
			}
			send_string dvMixer,cMixQueryQueue[nMixQueryQueueSent]
			cMixQueryQueue[nMixQueryQueueSent]=''
		}
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

