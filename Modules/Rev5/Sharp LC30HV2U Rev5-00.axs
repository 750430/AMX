module_name='Sharp LC30HV2U Rev5-00'(dev vdvTP, dev vdvLCD, dev dvLCD, dev dvLCDIR)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 04/04/2006  AT: 11:33:16        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
	
	Written specifically for the LCDs at OPIC.  For Sharp LCDs without a power on command.
	Integrates IR control as well as RS232 for power on.
	
	Vid1 	= Input1 Video
	SVid1	= Input2 Video
	VGA1	= Input3 VGA
	CMPNT	= Input1 Component
	
	
define_module 'Sharp LC30HV2U Rev5-00' plas1(vdvTP_DISP1,vdvDisp1,dvLCD1,dvLCD1IR)	
	
*)    
#include 'HoppSNAPI Rev5-00.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant

TLPoll		=	2001
TLCmd		=	2002

IR_PWR_ON	=	9

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

volatile		long		lPollArray[]	={5100}
volatile		long		lCmdArray[]		={0,3100}

volatile		integer		x

volatile		char		cCmdStr[17][10]
volatile		char		cPollStr[10]

volatile		integer		nCmd
volatile		integer		nPolled
volatile		integer		nCommanded
(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
define_mutually_exclusive

([vdvTP,VD_PWR_ON],[vdvTP,VD_PWR_OFF])
([vdvTP,VD_SRC_VGA1],[vdvTP,VD_SRC_SVID],[vdvTP,VD_SRC_CMPNT1],[vdvTP,VD_SRC_VID1])
 
([dvLCD,VD_PWR_ON],[dvLCD,VD_PWR_OFF])
([dvLCD,VD_SRC_VGA1],[dvLCD,VD_SRC_SVID],[dvLCD,VD_SRC_CMPNT1],[dvLCD,VD_SRC_VID1])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

define_function CmdExecuted()
{
	off[nCmd]
	if(timeline_active(TLCmd)) timeline_kill(TLCmd)
	timeline_create(TLPoll,lPollArray,1,timeline_relative,timeline_repeat)
}

define_function parse(char cCompStr[100])
{
	cancel_wait 'Poll'
	off[nPolled]
	off[nCommanded]
	cancel_wait 'Cmd'
	on[dvLCD,VD_PWR_ON]
	on[vdvTP,VD_PWR_ON]
	if(nCmd=VD_PWR_ON) CmdExecuted()
	select
	{
		active(find_string(cCompStr,"'ERR'",1)):
		{
			on[dvLCD,VD_SRC_VGA1]
			on[vdvTP,VD_SRC_VGA1]
			CmdExecuted()
		}
		active(find_string(cCompStr,"'2'",1)):
		{
			on[dvLCD,VD_SRC_SVID]
			on[vdvTP,VD_SRC_SVID]
			CmdExecuted()
		}
		active(find_string(cCompStr,"'1'",1)):
		{
			if(nCmd=VD_SRC_VID1)
			{
				on[dvLCD,VD_SRC_VID1]
				on[vdvTP,VD_SRC_VID1]
				CmdExecuted()
			}
			if(nCmd=VD_SRC_CMPNT1)
			{
				on[dvLCD,VD_SRC_CMPNT1]
				on[vdvTP,VD_SRC_CMPNT1]
				CmdExecuted()
			}
		}
		active(find_string(cCompStr,"'OK'",1)):
		{
			send_string dvLCD,"cPollStr"
			if (nCmd=VD_PWR_OFF) 
			{
				CmdExecuted()
				on[dvLCD,VD_PWR_OFF]
				on[vdvTP,VD_PWR_OFF]
			}
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

cCmdStr[VD_PWR_OFF]		=	"'POWR   0',$0D"
cCmdStr[VD_SRC_VGA1]	=	"'IPCD   X',$0D"
cCmdStr[VD_SRC_VID1]	=	"'INP1   1',$0D"
cCmdStr[VD_SRC_SVID]	=	"'IAVD   2',$0D"
cCmdStr[VD_SRC_CMPNT1]	=	"'INP1   2',$0D"

cPollStr				=	"'IAVD????',$0D"

wait 200
{
	if(!timeline_active(TLPoll))
	{
		timeline_create(TLPoll,lPollArray,1,timeline_relative,timeline_repeat)
	}
}

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event //Data Event

data_event[dvLCD]
{
	string:
	{
		local_var	char	cHold[100]
		local_var	char	cFullStr[100]
		local_var	char	cBuff[255]
		stack_var	integer	nPos
		
		cBuff="cBuff,data.text"
		while(length_string(cBuff))
		{
			select
			{
				active(find_string(cBuff,"$0D",1)&&length_string(cHold)):
				{
					nPos=find_string(cBuff,"$0D",1)
					cFullStr="cHold,get_buffer_string(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				active(find_string(cBuff,"$0D",1)):
				{
					nPos=find_string(cBuff,"$0D",1)
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

define_event //Timeline Events

timeline_event[TLPoll]
{
	if(!nPolled)
	{
		send_string dvLCD,"cPollStr"
		on[nPolled]
		wait 60 'Poll'
		{
			if (nCmd=VD_PWR_OFF) CmdExecuted()
			on[dvLCD,VD_PWR_OFF]
			on[vdvTP,VD_PWR_OFF]
			off[nPolled]
		}
	}
}

timeline_event[TLCmd]
{	
	switch(timeline.sequence)
	{
		case 1:
		{
			if (!nCommanded)
			{
				on[nCommanded]
				wait 180 'Cmd'
				{
					if(nCmd=VD_PWR_OFF) CmdExecuted()
					on[dvLCD,VD_PWR_OFF]
					on[vdvTP,VD_PWR_OFF]
					off[nPolled]
					off[nCommanded]
				}
			}
			switch(nCmd)
			{
				case VD_PWR_ON:
				{
					if(![dvLCD,VD_PWR_ON])
					{
						pulse[dvLCDIR,IR_PWR_ON]
						cancel_wait 'Poll'
						off[nPolled]
						off[nCommanded]
						cancel_wait 'Cmd'
						on[dvLCD,VD_PWR_ON]
						on[vdvTP,VD_PWR_ON]
						CmdExecuted()
					}
				}
				case VD_PWR_OFF: send_string dvLCD,cCmdStr[nCmd]
				case VD_SRC_VID1:
				case VD_SRC_SVID:
				case VD_SRC_VGA1:
				case VD_SRC_CMPNT1:
				{
					if([dvLCD,VD_PWR_ON])
					{
						send_string dvLCD,cCmdStr[nCmd]
					}
					else
					{
						pulse[dvLCDIR,IR_PWR_ON]
						cancel_wait 'Poll'
						off[nPolled]
						off[nCommanded]
						cancel_wait 'Cmd'
						on[dvLCD,VD_PWR_ON]
						on[vdvTP,VD_PWR_ON]
					}
				}
			}
		}
	}
}

define_event //Channel Events

channel_event[vdvLCD,0]
{
	on:
	{
		select
		{
			active(channel.channel<VD_POLL_BEGIN):
			{
				nCmd=channel.channel
				timeline_kill(TLPoll)
				timeline_create(TLCmd,lCmdArray,2,timeline_relative,timeline_repeat)
			}
			active(channel.channel=VD_POLL_BEGIN):
			{
				timeline_create(TLPoll,lPollArray,1,timeline_relative,timeline_repeat)
			}
		}
	}
}

define_event //Button Events

button_event[vdvTP,0]
{
	push:
	{
		pulse[vdvLCD,button.input.channel]
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
