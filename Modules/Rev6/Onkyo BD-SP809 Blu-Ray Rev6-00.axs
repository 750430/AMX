module_name='Onkyo BD-SP809 Blu-Ray Rev6-00'(dev dvTP[], dev vdvBluRay, dev vdvBluRay_FB, dev dvBluRay)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/20/2008  AT: 16:42:25        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
define_module 'Onkyo BD-SP809 Blu-Ray Rev6-00' dvr1(dvTP_DEV[1],vdvDEV1,vdvDEV1_FB,dvBluray)
send_command data.device,"'SET BAUD 9600,N,8,1'"

*)

#include 'HoppSNAPI Rev6-00.axi'
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

char 		cCmdStr[200][16]

integer		x
integer		nPlayStatus

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function parse(char cMsg[])
{
	remove_string(cMsg,"'!7'",1)
	select
	{
		active(left_string(cMsg,3)='SST'):
		{
			remove_string(cMsg,'SST',1)
			switch(left_string(cMsg,2))
			{
				case '00':
				case '03': nPlayStatus=DVR_STOP
				case '01': nPlayStatus=DVR_PLAY
				case '02': nPlayStatus=DVR_PAUSE
			}
		}
	}
}

define_function tp_fb()
{
	[dvTP,DVR_PLAY]=nPlayStatus=DVR_PLAY
	[dvTP,DVR_PAUSE]=nPlayStatus=DVR_PAUSE
	[dvTP,DVR_STOP]=nPlayStatus=DVR_STOP
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[DVR_PLAY]		="'!7PLYUP',$0D,$0A"
cCmdStr[DVR_STOP]		="'!7STP',$0D,$0A"
cCmdStr[DVR_PAUSE]		="'!7PAS',$0D,$0A"
cCmdStr[DVR_NEXT]		="'!7SKPUP',$0D,$0A"
cCmdStr[DVR_BACK]		="'!7SKPDN',$0D,$0A"
cCmdStr[DVR_FWD]		="'!7SCNUP',$0D,$0A"
cCmdStr[DVR_REW] 		="'!7SCNDN',$0D,$0A"
cCmdStr[DVR_PWR_ON]		="'!7PWR01',$0D,$0A"
cCmdStr[DVR_PWR_OFF]	="'!7PWR00',$0D,$0A"
cCmdStr[DVR_DISC_MENU]  ="'!7MNU',$0D,$0A"
cCmdStr[DVR_UP]			="'!7OSDUP',$0D,$0A"
cCmdStr[DVR_DN]			="'!7OSDDN',$0D,$0A"
cCmdStr[DVR_LEFT]  		="'!7OSDLF',$0D,$0A"
cCmdStr[DVR_RIGHT]		="'!7OSDRH',$0D,$0A"
cCmdStr[DVR_OK]			="'!7ENT',$0D,$0A"
cCmdStr[DVR_EXIT]		="'!7RET',$0D,$0A"
cCmdStr[DVR_HOME]		="'!7HOM',$0D,$0A"


wait 200 send_string dvBluRay,"'!7PMS01',$0D,$0A" //This registers to receive notices from the device when the play status changes

#include 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvBluRay]
{
	string:
	{
		local_var char cHold[100]
		local_var char cFullStr[100]
		local_var char cBuff[255]
		stack_var integer nPos	
		
		cBuff = "cBuff,data.text"
		while(length_string(cBuff))
		{
			select
			{
				active(find_string(cBuff,"$1A",1)&& length_string(cHold)):
				{
					nPos=find_string(cBuff,"$1A",1)
					cFullStr="cHold,get_buffer_string(cBuff,nPos)"
					parse(cFullStr)
					cHold=''
				}
				active(find_string(cBuff,"$1A",1)):
				{
					nPos=find_string(cBuff,"$1A",1)
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

channel_event[vdvBluRay,0]
{
	on:	
	{
		send_string dvBluRay,cCmdStr[channel.channel]
		if(channel.channel=DVR_PLAY) wait 2 send_string dvBluRay,"'!7PMS01',$0D,$0A" //Register to receive status updates
	}
}

button_event [dvTP,0]
{
	push:	
	{
		to[button.input.device,button.input.channel]
		on[vdvBluRay,button.input.channel]	
	}
	release: 
	{
		off[vdvBluRay,button.input.channel]
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
