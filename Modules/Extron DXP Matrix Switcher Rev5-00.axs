MODULE_NAME='Extron DXP Matrix Switcher Rev5-00'(DEV vdvTP[], DEV vdvDevice, DEV dvSwitcher)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/20/2008  AT: 16:42:25        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
define_variable //Switcher Variables
volatile		integer		nSwitcherInputs=8
volatile		integer		nSwitcherOutputs=8

define_module 'Extron DXP Matrix Switcher Rev5-00' sw1(dvTP_DEV[1],vdvDEV1,dvSwitcher,nSwitcherInputs,nSwitcherOutputs)
SEND_COMMAND data.device,"'SET BAUD 9600,N,8,1'"



This module draws its data from responses from the switcher.  It does not poll the switcher for updates on reboot, so it won't know what's going on until
some switching actually occurs.  

Future implementation should include blinking to signify which commands haven't been Taken yet, some level of polling to get status of all input on reboot,
and potentially writing data to a file to achieve persistence in the data (since you can't have persistent values within a module).  Also perhaps some way
to dynamically define the inputs and outputs so it doesn't waste so much memory.  I don't think this is possible, but I'd like to explore it.


*)

#INCLUDE 'HoppSNAPI Rev5-09.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

integer	btnInputs[]		=	{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48}
integer	btnOutputs[]	=	{101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148}

integer btnTake			=	200
integer btnAudio		=	201
integer btnVideo		=	202

FeedbackTL		=	3000


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile		integer		nActiveInput
volatile		integer		nActiveVideoOutput[48]
volatile		integer		nActiveAudioOutput[48]

volatile		integer		nAudioSelect=1
volatile		integer		nVideoSelect=1

persistent		integer		nAudioStatus[48][48]
persistent		integer		nVideoStatus[48][48]

volatile		long		lFeedbackTime[]={100}

volatile		integer		x

(**********************************************************)
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
define_function tp_fb()
{
	[vdvTP,btnAudio]=nAudioSelect
	[vdvTP,btnVideo]=nVideoSelect
	
	if(nAudioSelect or nVideoSelect)
	{
		for(x=1;x<=48;x++) [vdvTP,btnInputs[x]]=nActiveInput=x
		
		select
		{
			active(nVideoSelect & nAudioSelect):
			{
				for(x=1;x<=48;x++) 
				{
					[vdvTP,btnOutputs[x]]=nActiveVideoOutput[x] or nActiveAudioOutput[x]
				}
			}
			active(nVideoSelect & !nAudioSelect): for(x=1;x<=48;x++) [vdvTP,btnOutputs[x]]=nActiveVideoOutput[x]
			active(!nVideoSelect & nAudioSelect): for(x=1;x<=48;x++) [vdvTP,btnOutputs[x]]=nActiveAudioOutput[x]
		}
	}
	else
	{
		for(x=1;x<=48;x++) [vdvTP,btnInputs[x]]=0
		for(x=1;x<=48;x++) [vdvTP,btnOutputs[x]]=0
	}
	
//	
//	
//	select
//	{
//		active(nActiveVideoOutput[nActiveInput]=nAudioStatus):
//		{
//			for(x=1;x<=length_array(btnInputs);x++) [vdvTP,btnInputs[x]]=nVideoStatus=x
//		}
//		active(nVideoStatus<>nAudioStatus):
//		{
//			for(x=1;x<=length_array(btnInputs);x++)
//			{
//				if(x=nVideoStatus) on[vdvTP,btnInputs[x]]
//				else if(x=nAudioStatus) [vdvTP,btnInputs[x]]=nBlink
//				else off[vdvTP,btnInputs[x]]
//			}
//		}
//	}	
}

define_function parse(char cResponse[30])
{
	stack_var nInput
	stack_var nOutput
	select
	{
		active(find_string(cResponse,'Vid',1) or find_string(cResponse,'RGB',1)):
		{
			remove_string(cResponse,'Out',1)
			nOutput=atoi(left_string(cResponse,find_string(cResponse,' ',1)-1))
			remove_string(cResponse,'In',1)
			nInput=atoi(left_string(cResponse,find_string(cResponse,' ',1)-1))
			for(x=1;x<=48;x++) off[nVideoStatus[x][nOutput]]
			if(nInput) on[nVideoStatus[nInput][nOutput]]
		}
		active(find_string(cResponse,'Aud',1)):
		{
			remove_string(cResponse,'Out',1)
			nOutput=atoi(left_string(cResponse,find_string(cResponse,' ',1)-1))
			remove_string(cResponse,'In',1)
			nInput=atoi(left_string(cResponse,find_string(cResponse,' ',1)-1))
			for(x=1;x<=48;x++) off[nAudioStatus[x][nOutput]]
			if(nInput) on[nAudioStatus[nInput][nOutput]]
		}
		active(find_string(cResponse,'All',1)):
		{
			remove_string(cResponse,'Out',1)
			nOutput=atoi(left_string(cResponse,find_string(cResponse,' ',1)-1))
			remove_string(cResponse,'In',1)
			nInput=atoi(left_string(cResponse,find_string(cResponse,' ',1)-1))
			for(x=1;x<=48;x++) off[nVideoStatus[x][nOutput]]
			for(x=1;x<=48;x++) off[nAudioStatus[x][nOutput]]
			if(nInput) on[nVideoStatus[nInput][nOutput]]
			if(nInput) on[nAudioStatus[nInput][nOutput]]
			
		}
	}
	update_output_colors()
}

define_function switchaudio(i,o)
{
	send_string dvSwitcher,"itoa(i),'*',itoa(o),'$'"
	send_string 0,"'switchaudio: ',itoa(i),'*',itoa(o),'$'"
}

define_function switchvideo(i,o) //Extron Crosspoint
{  
	send_string dvSwitcher,"itoa(i),'*',itoa(o),'&'"
	send_string 0,"'switchvideo: ',itoa(i),'*',itoa(o),'&'"
}

define_function update_input_colors()
{
	select
	{
		active(nAudioSelect & nVideoSelect): 
		{
			send_command vdvTP,"'^BMF-',itoa(btnInputs[nActiveInput]),',2,%CF LightOrange'"
		}
		active(nAudioSelect & !nVideoSelect): 
		{
			send_command vdvTP,"'^BMF-',itoa(btnInputs[nActiveInput]),',2,%CF LightRed'"
		}		
		active(!nAudioSelect & nVideoSelect): 
		{
			send_command vdvTP,"'^BMF-',itoa(btnInputs[nActiveInput]),',2,%CF LightLime'"
		}

	}
}

define_function update_output_colors()
{
	for(x=1;x<=48;x++)
	{
		select
		{
			active(nActiveVideoOutput[x]=nActiveAudioOutput[x] and nActiveVideoOutput[x]>0): 
			{
				select
				{
					active(nVideoSelect & nAudioSelect): send_command vdvTP,"'^BMF-',itoa(btnOutputs[x]),',2,%CF LightOrange'"
					active(nVideoSelect & !nAudioSelect): send_command vdvTP,"'^BMF-',itoa(btnOutputs[x]),',2,%CF LightLime'"
					active(!nVideoSelect & nAudioSelect): send_command vdvTP,"'^BMF-',itoa(btnOutputs[x]),',2,%CF LightRed'"
				}
			}
			active(nActiveVideoOutput[x]): send_command vdvTP,"'^BMF-',itoa(btnOutputs[x]),',2,%CF LightLime'"
			active(nActiveAudioOutput[x]): send_command vdvTP,"'^BMF-',itoa(btnOutputs[x]),',2,%CF LightRed'"
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

timeline_create(FeedbackTL,lFeedbackTime,1,timeline_relative,timeline_repeat)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvSwitcher]
{
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cFullStr[100]
		LOCAL_VAR CHAR cBuff[255]
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

button_event[vdvTP,btnAudio]
{
	push:
	{
		nAudioSelect=!nAudioSelect
		update_input_colors()
		update_output_colors()
	}
}

button_event[vdvTP,btnVideo]
{
	push:
	{
		nVideoSelect=!nVideoSelect
		update_input_colors()
		update_output_colors()
	}
}

button_event[vdvTP,btnInputs]
{
	push:
	{
		if(nActiveInput=get_last(btnInputs))
		{
			off[nActiveInput]
			for(x=1;x<=length_array(btnOutputs);x++) 
			{
				off[nActiveAudioOutput[x]]
				off[nActiveVideoOutput[x]]
			}
		}
		else
		{
			nActiveInput=get_last(btnInputs)
			for(x=1;x<=length_array(btnOutputs);x++) 
			{
				nActiveVideoOutput[x]=nVideoStatus[nActiveInput][x]
				nActiveAudioOutput[x]=nAudioStatus[nActiveInput][x]
			}
		}
		update_input_colors()
		update_output_colors()
	}
}

button_event[vdvTP,btnOutputs]
{
	push:
	{
		if(nActiveInput) 
		{
			select
			{
				active(nVideoSelect & nAudioSelect):
				{
					nActiveVideoOutput[get_last(btnOutputs)]=!nActiveVideoOutput[get_last(btnOutputs)]
					nActiveAudioOutput[get_last(btnOutputs)]=!nActiveAudioOutput[get_last(btnOutputs)]
				}
				active(nVideoSelect & !nAudioSelect):
				{
					nActiveVideoOutput[get_last(btnOutputs)]=!nActiveVideoOutput[get_last(btnOutputs)]
				}
				active(!nVideoSelect & nAudioSelect):
				{
					nActiveAudioOutput[get_last(btnOutputs)]=!nActiveAudioOutput[get_last(btnOutputs)]
				}
				active(!nVideoSelect & !nAudioSelect):
				{
					send_command button.input.device,"'ABEEP'"
				}
			}
		}
		else send_command button.input.device,"'ABEEP'"
		update_output_colors()
	}
}

button_event[vdvTP,btnTake]
{
	push:
	{
		to[button.input]
		if(nActiveInput)
		{
			for(x=1;x<=48;x++)
			{
				if(nActiveAudioOutput[x]<>nAudioStatus[nActiveInput][x]) 
				{
					if(nActiveAudioOutput[x]) switchaudio(nActiveInput,x)
					else switchaudio(0,x)
				}
				if(nActiveVideoOutput[x]<>nVideoStatus[nActiveInput][x]) 
				{
					if(nActiveVideoOutput[x]) switchvideo(nActiveInput,x)
					else switchvideo(0,x)
				}
			}
		}
		else send_command button.input.device,"'ABEEP'"
		update_output_colors()
	}
}


timeline_event[FeedbackTL]
{
	tp_fb()
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
