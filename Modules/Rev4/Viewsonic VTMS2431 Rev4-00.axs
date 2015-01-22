MODULE_NAME='Viewsonic VTMS2431 Rev4-00'(dev dvTP, dev vdvPlas, dev dvPlas)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 07/25/2008  AT: 10:46:24        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                   *)
(***********************************************************)

//define_module 'Viewsonic VTMS2431 Rev4-00' disp1(vdvTP_DISP1,vdvDISP1,dvPlasma)
//Set baud to 9600,N,8,1

#include 'HoppSNAPI Rev4-01.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant

LONG lTLPoll				= 2001
LONG lTLCmd         = 2002

PollPwr 	= 1
PollSrc		= 2

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_type

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

long lPollArray[]				= {3100,3100}
long lCmdArray[]				=	{510,510}

char cCmdStr[35][10]	
char cPollStr[4][20]


integer nCmd=0
integer nNoResponse=0


integer nPlasBtns[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
										21,22,23,24,25,26,27,28,29,30,31,32,33,34}

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
define_latching

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
define_mutually_exclusive

([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])
([vdvPlas,VD_PWR_ON_FB],[vdvPlas,VD_PWR_OFF_FB])
([vdvPlas,VD_SRC_VGA1_FB],[vdvPlas,VD_SRC_CMPNT1_FB],[vdvPlas,VD_SRC_VID1_FB],[vdvPlas,VD_SRC_SVID_FB],[vdvPlas,VD_SRC_AUX1_FB],
[vdvPlas,VD_SRC_AUX2_FB])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function CmdExecuted()
{
	ncmd=0
	nNoResponse=0
	timeline_kill(lTLCmd)
	timeline_restart(lTLPoll)
}

define_function Parse(char cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,"'2+'",1)):
		{
			on[vdvPlas,VD_PWR_ON_FB]
			on[dvTP,VD_PWR_ON]
			nNoResponse=0
			if(nCmd=VD_PWR_ON) CmdExecuted()
		}
		active(find_string(cCompStr,"'6rl000'",1) or find_string(cCompStr,"$0B,$13,$13,$A6,$08,$00",1)):
		{
			on[vdvPlas,VD_PWR_OFF_FB]
			on[dvTP,VD_PWR_OFF]
			nNoResponse=0
			if(nCmd=VD_PWR_OFF) CmdExecuted()
		}
	}
}

define_function SourceFeedback(integer nSrc)
{
	cPollStr[PollSrc]="cCmdStr[nSrc]"
	
	switch(nSrc)
	{
		case VD_SRC_VGA1:
		{
			ON[vdvPlas,VD_SRC_VGA1_FB]
			ON[dvTP,VD_SRC_VGA1]
		}
		case VD_SRC_VID1:
		{
			ON[vdvPlas,VD_SRC_VID1_FB]
			ON[dvTP,VD_SRC_VID1]
		}
		case VD_SRC_SVID:
		{
			ON[vdvPlas,VD_SRC_SVID_FB]
			ON[dvTP,VD_SRC_SVID]
		}
		case VD_SRC_CMPNT1:
		{
			ON[vdvPlas,VD_SRC_CMPNT1_FB]
			ON[dvTP,VD_SRC_CMPNT1]
		}
		case VD_SRC_AUX1:
		{
			ON[vdvPlas,VD_SRC_AUX1_FB]
			ON[dvTP,VD_SRC_AUX1]
		}
		case VD_SRC_AUX2:
		{
			ON[vdvPlas,VD_SRC_AUX2_FB]
			ON[dvTP,VD_SRC_AUX2]
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

cCmdStr[VD_PWR_ON]			= "'6s!001',$0D" 			
cCmdStr[VD_PWR_OFF]			= "'801s!000',$0D"
cCmdStr[VD_SRC_VGA1]		= "'801s"005',$0D"
cCmdStr[VD_SRC_VID1]		= "'801s"001',$0D"
cCmdStr[VD_SRC_SVID]		= "'801s"002',$0D"
cCmdStr[VD_SRC_CMPNT1]		= "'801s"003',$0D"
cCmdStr[VD_SRC_AUX1]		= "'801s"004',$0D"			//HDMI
cCmdStr[VD_SRC_AUX2]		= "'801s"000',$0D"			//TV

cPollStr[PollPwr]			= "'6gl000',$0D"			
cPollStr[PollSrc]			= "'801s"005',$0D"

wait 200
{
	if(!timeline_active(lTLPoll))
	{
		timeline_create(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
	}
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvPlas]
{
	string:
	{
		parse(data.text)
	}	
}

timeline_event[lTLPoll]
{
	switch(timeline.sequence)
	{
		case 1:	
		{
			send_string dvPlas,"cPollStr[PollPwr]"
			nNoResponse++
			if((nNoResponse>=4) && [vdvPlas,VD_PWR_OFF_FB])
			{
				on[vdvPlas,VD_PWR_ON_FB]
				on[dvTP,VD_PWR_ON]
				nNoResponse=0
			}
		}
		case 2: 
		{
			if([vdvPlas,VD_PWR_ON_FB])
			{
				send_string dvPlas,"cPollStr[PollSrc]"
			}
		}
	}
}

timeline_event[lTLCmd]
{
	switch(timeline.sequence)
	{
		case 1:	//first time
		{
			switch(nCmd)
			{
				case VD_PWR_ON:
				case VD_PWR_OFF:
				{
					send_string dvPlas,"cCmdStr[nCmd]"
				}
				case VD_SRC_VGA1:
				case VD_SRC_VID1:
				case VD_SRC_SVID:
				case VD_SRC_CMPNT1:
				case VD_SRC_AUX1:
				case VD_SRC_AUX2:
				{
					if([vdvPlas,VD_PWR_ON_FB])
					{
						send_string dvPlas,"cCmdStr[nCmd]"
						SourceFeedback(nCmd)
						CmdExecuted()
					}
					else
					{
						send_string dvPlas,"cCmdStr[VD_PWR_ON]"
					}
				}
				case VD_PCADJ:
				{
					send_string dvPlas,"cCmdStr[nCmd]"
					CmdExecuted()
				}
			}
		}
		case 2:	//2nd time
		{
			send_string dvPlas,"cPollStr[PollPwr]"
			nNoResponse++
			if((nNoResponse>=4) && ![vdvPlas,VD_PWR_ON_FB])
			{
				on[vdvPlas,VD_PWR_ON_FB]
				on[dvTP,VD_PWR_ON]
				nNoResponse=0
			}
		}
	}
}

channel_event[vdvPlas,nPlasBtns]
{
	on:
	{
		if(channel.channel<200)
		{
			nCmd=channel.channel
			timeline_pause(lTLPoll)
			WAIT 1 timeline_create(lTLCmd,lCmdArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
		}
		else if(channel.channel=VD_POLL_BEGIN)
		{
			timeline_create(lTLPoll,lPollArray,2,TIMELINE_RELATIVE,TIMELINE_REPEAT)
		}
	}
}
button_event[dvTP,nPlasBtns]
{
	push:
	{
		to[button.input]
		pulse[vdvPlas,button.input.channel]
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


