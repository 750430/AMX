MODULE_NAME='Digital Projection Titan Single Lamp Rev5-00'(DEV dvTP, DEV vdvProj, DEV dvProj)
(***********************************************************)
(*  FILE CREATED ON: 06/18/2008  AT: 11:03:24              *)
(***********************************************************)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/18/2008  AT: 11:56:30        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
	
	define_module 'Digital Projection Titan Rev5-00' disp1(vdvTP_DISP1,vdvDisp1,dvProj)
	SEND_COMMAND dvProj,"'SET BAUD 19200,N,8,1,485 DISABLE'" 
*)
#include 'HoppSNAPI Rev5-00.axi'
#include 'HoppSTRUCT Rev5-00.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
define_device

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant

ProjTL	=	2001

RespPower	=1
RespInput	=2
RespAspect	=3
RespLampStat=4
RespMute	=5

PollPower = 1
PollInput = 2
PollRatio 	= 3
PollLampStatus	= 4

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

non_volatile char cCmdStr[34][30]
non_volatile char cPollStr[4][30]
non_volatile char cRespStr[5][3]

non_volatile char cProjBuffer[255]

non_volatile long lProjTimes[]  ={100}

non_volatile integer nPollType

non_Volatile integer nMuteStatus

non_volatile integer nDPTitanPower
non_volatile integer nDPTitanSource
non_volatile integer nDPTitanAspect
non_volatile integer nDPTitanTemp
non_volatile char	 cDPTitanTemp[1]
non_volatile char	 cDPTitanTemp2[1]

non_volatile integer nDPTitanCmdList[30]
non_volatile integer nDPTitanActiveCmd



non_volatile integer nNumCmds

non_volatile integer nStringSent


DEFINE_MUTUALLY_EXCLUSIVE

([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF],[dvTP,VD_WARMING],[dvTP,VD_COOLING])
([dvTP,VD_MUTE_ON],[dvTP,VD_MUTE_OFF])
([dvTP,VD_SRC_RGB1],[dvTP,VD_SRC_RGB2],[dvTP,VD_SRC_RGB3],[dvTP,VD_SRC_VID1],[dvTP,VD_SRC_SVID],[dvTP,VD_SRC_CMPNT1])

([dvProj,VD_PWR_ON],[dvProj,VD_PWR_OFF])
([dvProj,VD_MUTE_ON],[dvProj,VD_MUTE_OFF])
([dvProj,VD_SRC_RGB1],[dvProj,VD_SRC_RGB2],[dvProj,VD_SRC_RGB3],[dvProj,VD_SRC_VID1],[dvProj,VD_SRC_SVID],[dvProj,VD_SRC_CMPNT1])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

define_function SendCommand()
{
	SWITCH(nDPTitanActiveCmd)
	{
		CASE VD_PWR_ON:
		CASE VD_PWR_OFF: 
		{
			SEND_STRING dvProj,cCmdStr[nDPTitanActiveCmd]
			nPollType = PollPower
		}
		CASE VD_SRC_VID1:
		CASE VD_SRC_SVID:
		CASE VD_SRC_RGB1:
		CASE VD_SRC_RGB2:
		CASE VD_SRC_RGB3:
		CASE VD_SRC_CMPNT1:
		{
			IF([dvProj,VD_PWR_ON])
			{
				SEND_STRING dvProj,cCmdStr[nDPTitanActiveCmd]
				nPollType = PollInput
			}
			IF([dvProj,VD_PWR_OFF])
			{
				SEND_STRING dvProj,cCmdStr[VD_PWR_ON]
				for(x=1;x<nNumCmds;x++)
				{
					nDPTitanCmdList[x+1]=nDPTitanCmdList[x]
				}
				nDPTitanCmdList[1]=nDPTitanActiveCmd
				nDPTitanActiveCmd=VD_PWR_ON
				nPollType = PollPower
			}
		}
		case VD_MUTE_ON:
		case VD_MUTE_OFF:
		{
			send_string dvProj,CCmdStr[nDPTitanActiveCmd]
		}
	}
}

define_function CmdExecuted()
{
	nDPTitanActiveCmd=0
	
}

define_function parse()
{
	select
	{
		active(find_string(cProjBuffer,cRespStr[RespPower],1)):
		{
			remove_string(cProjBuffer,cRespStr[RespPower],1)
			cDPTitanTemp=mid_string(cProjBuffer,6,1)
			switch(cDPTitanTemp)
			{
				case 0:
				{
					on[dvTP,VD_PWR_ON]
					on[dvProj,VD_PWR_ON]
					if(nDPTitanActiveCmd=VD_PWR_ON) CmdExecuted()
				}
				case 4:
				{
					on[dvTP,VD_PWR_OFF]
					on[dvProj,VD_PWR_OFF]
					if(nDPTitanActiveCmd=VD_PWR_OFF) CmdExecuted()
				}
			}
		}
		active(find_string(cProjBuffer,cRespStr[RespInput],1)):
		{
			remove_string(cProjBuffer,cRespStr[RespInput],1)
			cDPTitanTemp=mid_string(cProjBuffer,6,1)
			switch(cDPTitanTemp)
			{
				case 0:
				{
					on[dvProj,VD_SRC_RGB1]
					on[dvTP,VD_SRC_RGB1]
					nDPTitanSource=1
					if(nDPTitanActiveCmd=VD_SRC_RGB1) CmdExecuted()
				}
				case 1:
				{
					on[dvProj,VD_SRC_RGB2]
					on[dvTP,VD_SRC_RGB2]
					nDPTitanSource=2
					if(nDPTitanActiveCmd=VD_SRC_RGB2) CmdExecuted()
				}
				case 2:
				{
					on[dvProj,VD_SRC_RGB3]
					on[dvTP,VD_SRC_RGB3]
					nDPTitanSource=3
					if(nDPTitanActiveCmd=VD_SRC_RGB3) CmdExecuted()
				}
				case 4:
				{
					on[dvProj,VD_SRC_VID1]
					on[dvTP,VD_SRC_VID1]
					nDPTitanSource=4
					if(nDPTitanActiveCmd=VD_SRC_VID1) CmdExecuted()
				}
				case 5:
				{
					on[dvProj,VD_SRC_SVID]
					on[dvTP,VD_SRC_SVID]
					nDPTitanSource=5
					if(nDPTitanActiveCmd=VD_SRC_SVID) CmdExecuted()
				}
				case 6:
				{
					on[dvProj,VD_SRC_CMPNT1]
					on[dvTP,VD_SRC_CMPNT1]
					nDPTitanSource=6
					if(nDPTitanActiveCmd=VD_SRC_CMPNT1) CmdExecuted()
				}
			}
		}
		active(find_string(cProjBuffer,cRespStr[RespAspect],1)):
		{
			remove_string(cProjBuffer,cRespStr[RespAspect],1)
			cDPTitanTemp=mid_string(cProjBuffer,6,1)
			switch(cDPTitanTemp)
			{
				case $00:
				{	
					on[dvProj,VD_ASPECT1]
					on[dvTP,VD_ASPECT1]
					nDPTitanAspect=1
					if(nDPTitanActiveCmd=VD_ASPECT1) CmdExecuted()
				}
				case $01:
				{	
					on[dvProj,VD_ASPECT2]
					on[dvTP,VD_ASPECT2]
					nDPTitanAspect=2
					if(nDPTitanActiveCmd=VD_ASPECT2) CmdExecuted()
				}
				case $14:
				{	
					on[dvProj,VD_ASPECT3]
					on[dvTP,VD_ASPECT3]
					nDPTitanAspect=3
					if(nDPTitanActiveCmd=VD_ASPECT3) CmdExecuted()
				}
				case $16:
				{	
					on[dvProj,VD_ASPECT4]
					on[dvTP,VD_ASPECT4]
					nDPTitanAspect=4
					if(nDPTitanActiveCmd=VD_ASPECT4) CmdExecuted()
				}
				case $17:
				{	
					on[dvProj,VD_ASPECT5]
					on[dvTP,VD_ASPECT5]
					nDPTitanAspect=5
					if(nDPTitanActiveCmd=VD_ASPECT5) CmdExecuted()
				}
				case $18:
				{	
					on[dvProj,VD_ASPECT6]
					on[dvTP,VD_ASPECT6]
					nDPTitanAspect=6
					if(nDPTitanActiveCmd=VD_ASPECT6) CmdExecuted()
				}
				case $19:
				{	
					on[dvProj,VD_ASPECT7]
					on[dvTP,VD_ASPECT7]
					nDPTitanAspect=7
					if(nDPTitanActiveCmd=VD_ASPECT7) CmdExecuted()
				}
				case $1A:
				{	
					on[dvProj,VD_ASPECT8]
					on[dvTP,VD_ASPECT8]
					nDPTitanAspect=8
					if(nDPTitanActiveCmd=VD_ASPECT8) CmdExecuted()
				}
			}
		}
		active(find_string(cProjBuffer,cRespStr[RespLampStat],1)):
		{
			remove_string(cProjBuffer,cRespStr[RespLampStat],1)
			cDPTitanTemp=mid_string(cProjBuffer,6,1)
			cDPTitanTemp2=mid_string(cProjBuffer,7,1)
			if (cDPTitanTemp=$03 or cDPTitanTemp2=$03)
			{
				on[dvTP,VD_PWR_ON]
				on[dvProj,VD_PWR_ON]
				nDPTitanPower=1
				if(nDPTitanActiveCmd=VD_PWR_ON) CmdExecuted()
			}   
			else if (cDPTitanTemp=$02 or cDPTitanTemp2=$02)
			{
				on[dvProj,VD_WARMING]
				on[dvTP,VD_WARMING]
				nDPTitanPower=2
				if(nDPTitanActiveCmd=VD_PWR_ON) CmdExecuted()
			}   
			else if (cDPTitanTemp=$04 or cDPTitanTemp2=$04)
			{
				on[dvProj,VD_COOLING]
				on[dvTP,VD_COOLING]
				nDPTitanPower=3
				if(nDPTitanActiveCmd=VD_PWR_OFF) CmdExecuted()
			}   
			else if (cDPTitanTemp=$01 or cDPTitanTemp2=$01)
			{
				on[dvProj,VD_PWR_OFF]
				on[dvTP,VD_PWR_OFF]
				nDPTitanPower=4
				if(nDPTitanActiveCmd=VD_PWR_OFF) CmdExecuted()
			}   
			else
			{
				on[dvProj,VD_PWR_OFF]
				on[dvTP,VD_PWR_OFF]
				nDPTitanPower=4
				if(nDPTitanActiveCmd=VD_PWR_OFF) CmdExecuted()				
			}
		}
		active(find_string(cProjBuffer,cRespStr[RespMute],1)):
		{
			remove_string(cProjBuffer,cRespStr[RespMute],1)
			cDPTitanTemp=mid_string(cProjBuffer,2,1)
			switch(cDPTitanTemp)
			{
				case 1:
				{
					off[dvTP,VD_MUTE_TOG]
					off[nMuteStatus]
					on[dvProj,VD_MUTE_OFF]
					if(nDPTitanActiveCmd=VD_MUTE_OFF) CmdExecuted()
				}
				case 0:
				{
					on[dvTP,VD_MUTE_TOG]
					on[nMuteStatus]
					on[dvProj,VD_MUTE_ON]
					if(nDPTitanActiveCmd=VD_MUTE_ON) CmdExecuted()
				}
			}
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

cCmdStr[VD_PWR_ON]			= "$BE,$EF, $03, $19,$00, $58,$58, $01, $01,$02, $00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//on
cCmdStr[VD_PWR_OFF]			= "$BE,$EF, $03, $19,$00, $58,$58, $01, $01,$02, $00,$00, $00,$00,$00,$00, $04,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//off
cCmdStr[VD_SRC_RGB1]  		= "$BE,$EF, $03, $19,$00, $58,$58, $01, $37,$02, $00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//input1
cCmdStr[VD_SRC_RGB2]		= "$BE,$EF, $03, $19,$00, $58,$58, $01, $37,$02, $00,$00, $00,$00,$00,$00, $01,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//input2
cCmdStr[VD_SRC_RGB3]		= "$BE,$EF, $03, $19,$00, $58,$58, $01, $37,$02, $00,$00, $00,$00,$00,$00, $02,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//input1 DVI PC Digital
cCmdStr[VD_SRC_CMPNT1]		= "$BE,$EF, $03, $19,$00, $58,$58, $01, $37,$02, $00,$00, $00,$00,$00,$00, $06,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//input2 Y/Pb/Pr
cCmdStr[VD_SRC_VID1] 		= "$BE,$EF, $03, $19,$00, $58,$58, $01, $37,$02, $00,$00, $00,$00,$00,$00, $04,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//input3 video
cCmdStr[VD_SRC_SVID]		= "$BE,$EF, $03, $19,$00, $58,$58, $01, $37,$02, $00,$00, $00,$00,$00,$00, $05,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//input3 svideo

cCmdStr[VD_MUTE_ON]			= "$BE,$EF, $03, $19,$00, $58,$58, $01, $CF,$02, $00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//input3 svideo
cCmdStr[VD_MUTE_OFF]		= "$BE,$EF, $03, $19,$00, $58,$58, $01, $CF,$02, $00,$00, $01,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//input3 svideo

cPollStr[PollPower]			= "$BE,$EF, $03, $19,$00, $58,$58, $02, $01,$02, $00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"
cPollStr[PollInput] 		= "$BE,$EF, $03, $19,$00, $58,$58, $02, $37,$02, $00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"
cPollStr[PollRatio]			= "$BE,$EF, $03, $19,$00, $58,$58, $02, $7A,$02, $00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"
cPollStr[PollLampStatus] 	= "$BE,$EF, $03, $19,$00, $58,$58, $02, $11,$03, $00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"

cRespStr[RespPower]		="$01,$02,$01"
cRespStr[RespInput]		="$37,$02,$01"
cRespStr[RespAspect]	="$7A,$02,$01"
cRespStr[RespLampStat]	="$11,$03,$01"
cRespStr[RespMute]		="$CF,$02,$01"

create_buffer dvProj,cProjBuffer
timeline_create(ProjTL,lProjTimes,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[vdvProj]
{
	online:
	{
		on[dvTP,VD_PWR_OFF]
	}
}

DATA_EVENT[dvProj]
{
	STRING:
	{
		for (x=1;x<=5;x++)
		{
			if(find_string(cProjBuffer,cRespStr[x],1))
			{
				Parse()
				off[nStringSent]
				cancel_wait 'StringSent'
			}
		}
	}
}

timeline_event[ProjTL]
{
	if (!nStringSent)
	{
		if (nDPTitanActiveCmd)
		{
			SendCommand()
		}
		if (nDPTitanCmdList[1])
		{
			nDPTitanActiveCmd=nDPTitanCmdList[1]
			SendCommand()
			for(x=1;x<nNumCmds;x++)
			{
				nDPTitanCmdList[x]=nDPTitanCmdList[x+1]
			}
			nDPTitanCmdList[nNumCmds]=0
			nNumCmds--
		}
		else
		{
			send_string dvProj,"cPollStr[nPollType]"
			nPollType++
			if(nPollType=5)nPollType=1
		}
		on[nStringSent]
		wait 40 'StringSent' off[nStringSent]
	}
}

channel_event[vdvProj,0]
{
	on:
	{
		if(channel.channel<200)
		{
			nNumCmds++
			nDPTitanCmdList[nNumCmds]=channel.channel
		}
	}
}

button_event[dvTP,VD_PWR_ON]
button_event[dvTP,VD_PWR_OFF]	
button_event[dvTP,VD_SRC_RGB1]
button_event[dvTP,VD_SRC_RGB2]
button_event[dvTP,VD_SRC_RGB3]
button_event[dvTP,VD_SRC_CMPNT1]
button_event[dvTP,VD_SRC_VID1] 
button_event[dvTP,VD_SRC_SVID]
{
	push:
	{
		to[vdvProj,button.input.channel]
	}
}

button_event[dvTP,VD_MUTE_TOG]
{
	push:
	{
		to[button.input.device,button.input.channel]
		if (nMuteStatus) to[vdvProj,VD_MUTE_OFF]
		else to[vdvProj,VD_MUTE_ON]
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

