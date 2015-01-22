MODULE_NAME='Sonic Foundry MediaSite LIVE Rev4-00'(DEV vdvTP[], DEV vdvMedia, DEV dvMedia)
(***********************************************************)
(*  FILE CREATED ON: 05/08/2008  AT: 14:11:04              *)
(***********************************************************)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/07/2008  AT: 17:01:39        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
	define_module 'Sonic Foundry MediaSite LIVE Rev4-00' DMR1(dvTP_DEV[1],vdvDEV1,dvDVR)
	//SET BAUD 9600,N,8,1
*)
#include 'HoppSNAPI Rev4-04.axi'

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
define_device

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant

lPollTL				=	2000
lPresentationTL		=	2001

define_constant //Status

stIdle			=	1
stRecBusy		=	2
stRecord		=	3
stPaused		=	4
stPublish		=	5
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_type

structure presentation
{
	char name[40]
	char id[40]
}

define_variable

non_volatile integer x
non_volatile integer y

non_volatile integer nLastMediaStatus
non_volatile integer nMediaStatus

non_volatile	integer		nPresentations
persistent		presentation	prPresentation[50]
non_volatile	integer		nVisiblePresentation
non_volatile	char		nActiveID[40]
persistent		integer		nAutoImage

non_volatile long lPollTimes[]={3000,3000,3000,3000}
non_volatile	long	lPresentationTimes[]={200}



define_mutually_exclusive

([vdvMedia,DMR_SRC_VID1_FB],[vdvMedia,DMR_SRC_RGB1_FB],[vdvMedia,DMR_SRC_RGB1_PIP_FB])
([vdvMedia,DMR_RECORDING_FB],[vdvMedia,DMR_IDLE_FB],[vdvMedia,DMR_PAUSED_FB])
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

define_function parse(char cCompStr[100])
{
	stack_var integer nActivePresentation
	select
	{
//		active(find_string(cCompStr,'AUDIOSTATUS',1)):
//		{
//			if(find_string(cCompStr,'AUDIOSTATUS 2',1) or find_string(cCompStr,'AUDIOSTATUS 1',1))
//			{
//				on[vdvTP,DMR_STATUS]
//				send_command vdvTP,"'^TXT-',itoa(DMR_STATUS),',2,Low Audio Warning'"
//				wait 20 off[vdvTP,DMR_STATUS]
//			}
//		}
		active(find_string(cCompStr,'STATUS',1)):
		{
			select
			{
				active(find_string(cCompStr,'RECBUSY',1)): nMediaStatus=stRecbusy
				active(find_string(cCompStr,'IDLE',1)): 
				{
					if (nMediaStatus=stRecBusy or nMediaStatus=stPublish or nMediaStatus=stRecord)
					pulse[vdvMedia,DMR_GET_PRESENTATIONS]
					nMediaStatus=stIdle
				}
				active(find_string(cCompStr,'PAUSED',1)): nMediaStatus=stPaused
				active(find_string(cCompStr,'RECORD',1)): nMediaStatus=stRecord
				active(find_string(cCompStr,'PUBLISH',1)): nMediaStatus=stPublish
			}
		}
		active(find_string(cCompStr,'ENCODERVIDEOINPUT',1)):
		{
			select
			{
				active(find_string(cCompStr,'0',1)): on[vdvMedia,DMR_SRC_VID1_FB]
				active(find_string(cCompStr,'1',1)): on[vdvMedia,DMR_SRC_RGB1_FB]
				active(find_string(cCompStr,'2',1)): on[vdvMedia,DMR_SRC_RGB1_PIP_FB]
			}
		}
		active(find_string(cCompStr,'SCHEDULEDCOUNT',1)):
		{
			remove_string(cCompStr,'SCHEDULEDCOUNT ',1)
			nPresentations=atoi(left_string(cCompStr,find_string(cCompStr,"$0D",1)-1))
			timeline_pause(lPollTL)
			timeline_create(lPresentationTL,lPresentationTimes,1,timeline_relative,timeline_repeat)
		}
		active(find_string(cCompStr,'SCHEDULEDINFO',1)):
		{
			remove_string(cCompStr,'SCHEDULEDINFO ',1)
			nActivePresentation=atoi(get_buffer_string(cCompStr,find_string(cCompStr,' ',1)-1))+1
			remove_string(cCompStr,' ',1)
			prPresentation[nActivePresentation].id=get_buffer_string(cCompStr,find_string(cCompStr,' ',1)-1)
			remove_string(cCompStr,' ',1)
			prPresentation[nActivePresentation].name=get_buffer_string(cCompStr,find_string(cCompStr,"$0D",1)-2)
			populate_presentations(1)
		}
		active(find_string(cCompStr,'SCHEDULEDID',1)):
		{
			if(find_string(cCompStr,"'SCHEDULEDID  ',13",1))
			{
				send_command vdvTP,"'^TXT-',itoa(DMR_CURRENT_PRESENTATION),',0,No Presentation Loaded'"
			}
			else
			{
				remove_string(cCompStr,'SCHEDULEDID ',1)
				nActiveID=get_buffer_string(cCompStr,find_string(cCompStr,"$0D",1)-2)
				for(x=1;x<=nPresentations;x++)
				{
					if(nActiveID=prPresentation[x].id) 
					{
						if(length_string(prPresentation[x].name)<=32)
						{
							send_command vdvTP,"'^TXT-',itoa(DMR_CURRENT_PRESENTATION),',0,',prPresentation[x].name"
						}
						else
						{
							send_command vdvTP,"'^TXT-',itoa(DMR_CURRENT_PRESENTATION),',0,',left_string(prPresentation[x].name,32),'...'"
						}
					}
				}
			}
		}
		active(find_string(cCompStr,"'IMAGEAUTO'",1)):
		{
			select
			{
				active(find_string(cCompStr,"'TRUE'",1)):
				{
					on[nAutoImage]
				}
				active(find_string(cCompStr,"'FALSE'",1)):
				{
					off[nAutoImage]
				}
			}
		}
	}
}

define_function populate_presentations(i)
{
	nVisiblePresentation=i
	for(x=1;x<=8;x++) 
	{
		if(length_string(prPresentation[x+i-1].name)<=21)
		{
			send_command vdvTP,"'^TXT-',itoa(DMR_SELECT_PRE[x]),',0,',prPresentation[x+i-1].name"
		}
		else
		{
			send_command vdvTP,"'^TXT-',itoa(DMR_SELECT_PRE[x]),',0,',left_string(prPresentation[x+i-1].name,21),'...'"
		}
	}
}

define_function clear_presentations()
{
	send_command vdvTP,"'^TXT-',itoa(DMR_SELECT_PRE[1]),',0,Loading . . . . .'"
	for(x=2;x<=8;x++) send_command vdvTP,"'^TXT-',itoa(DMR_SELECT_PRE[x]),',0,'"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

timeline_Create(lPollTL,lPollTimes,4,timeline_relative,timeline_repeat)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvMedia]
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

button_event[vdvTP,0]
{
	push:
	{
		to[button.input]
		pulse[vdvMedia,button.input.channel]
	}
}

channel_event[vdvMedia,0]
{
	on:
	{
		switch(channel.channel)
		{
			case DMR_SRC_VID1: 
			{
				send_string dvMedia,"'*ENCODERVIDEOINPUT 0',13"
			}
			case DMR_SRC_RGB1: 
			{
				send_string dvMedia,"'*ENCODERVIDEOINPUT 1',13"
			}
			case DMR_SRC_RGB1_PIP:
			{
				send_string dvMedia,"'*ENCODERVIDEOINPUT 2',13"
			}
			case DMR_REC_START:
			{
				send_string dvMedia,"'*RECORD',13"
			}
			case DMR_REC_STOP:
			{
				send_string dvMedia,"'*STOP',13"
			}
			case DMR_REC_PAUSE:
			{
				send_string dvMedia,"'*PAUSE',13"
			}
			case DMR_GET_PRESENTATIONS:
			{
				clear_presentations()
				send_string dvMedia,"'*SCHEDULEDCOUNT ?',13"
			}
			case DMR_SELECT_PRE_UP:
			{
				if(nVisiblePresentation>1) nVisiblePresentation--
				populate_presentations(nVisiblePresentation)
			}
			case DMR_SELECT_PRE_DOWN:
			{
				if(nVisiblePresentation<42) nVisiblePresentation++
				populate_presentations(nVisiblePresentation)
			}
			case DMR_SELECT_PRE_1:
			case DMR_SELECT_PRE_2:
			case DMR_SELECT_PRE_3:
			case DMR_SELECT_PRE_4:
			case DMR_SELECT_PRE_5:
			case DMR_SELECT_PRE_6:
			case DMR_SELECT_PRE_7:
			case DMR_SELECT_PRE_8:
			{
				if(prPresentation[channel.channel-DMR_SELECT_PRE_1+nVisiblePresentation].id)
				{
					send_string dvMedia,"'*SCHEDULEDID ',prPresentation[channel.channel-DMR_SELECT_PRE_1+nVisiblePresentation].id,13"
					send_command vdvTP,"'^TXT-',itoa(DMR_CURRENT_PRESENTATION),',0,Loading . . . . .'"
				}
			}
			case DMR_AUTO_IMAGE:
			{
				switch(nAutoImage)
				{
					case 1: send_string dvMedia,"'*IMAGEAUTO FALSE',13"
					case 0: send_string dvMedia,"'*IMAGEAUTO TRUE',13"
				}
			}
		}                     
	}
}

timeline_event[lPollTL]
{
	switch(timeline.sequence)
	{
		case 1: send_string dvMedia,"'*STATUS ?',13"
		case 2: send_string dvMedia,"'*ENCODERVIDEOINPUT ?',13"
		case 3: send_string dvMedia,"'*SCHEDULEDID ?',13"
		case 4: send_string dvMedia,"'*IMAGEAUTO ?',13"
	}
}

timeline_event[lPresentationTL]
{
	if(timeline.repetition<nPresentations)
	{
		send_string dvMedia,"'*SCHEDULEDINFO ',itoa(timeline.repetition),' ?',13"
	}
	else
	{
		for(x=nPresentations+1;x<=50;x++) 
		{
			prPresentation[x].id=''
			prPresentation[x].name=''
		}
		populate_presentations(1)
		timeline_restart(lPollTL)
		timeline_kill(lPresentationTL)
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program

if(nMediaStatus<>nLastMediaStatus)
{
	switch(nMediaStatus)
	{
		case stRecord: send_command vdvTP,"'^TXT-',itoa(DMR_STATUS),',1,Recording'"
		case stIdle: send_command vdvTP,"'^TXT-',itoa(DMR_STATUS),',1,Idle'"
		case stRecBusy: send_command vdvTP,"'^TXT-',itoa(DMR_STATUS),',1,Busy'"
		case stPaused: send_command vdvTP,"'^TXT-',itoa(DMR_STATUS),',1,Paused'"
		case stPublish: send_command vdvTP,"'^TXT-',itoa(DMR_STATUS),',1,Publishing'"
	}
	nLastMediaStatus=nMediaStatus
}

[vdvTP,DMR_AUTO_IMAGE]=!nAutoImage

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

