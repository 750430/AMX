MODULE_NAME='Digital Projection Titan Rev4-00'(DEV vdvTP, DEV vdvProj, DEV dvProj)
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
*)
#include 'HoppSNAPI Rev4-00.axi'
#include 'HoppSTRUCT Rev4-00.axi'
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

([vdvTP,VD_PWR_ON],[vdvTP,VD_PWR_OFF])
([vdvTP,VD_MUTE_ON],[vdvTP,VD_MUTE_OFF])
([vdvTP,VD_SRC_RGB1],[vdvTP,VD_SRC_RGB2],[vdvTP,VD_SRC_RGB3],[vdvTP,VD_SRC_VID],[vdvTP,VD_SRC_SVID])

([vdvProj,VD_PWR_ON_FB],[vdvProj,VD_WARMING_FB],[vdvProj,VD_COOLING_FB],[vdvProj,VD_PWR_OFF_FB])
([vdvProj,VD_MUTE_ON_FB],[vdvProj,VD_MUTE_OFF_FB])
([vdvProj,VD_SRC_RGB1_FB],[vdvProj,VD_SRC_RGB2_FB],[vdvProj,VD_SRC_RGB3_FB],[vdvProj,VD_SRC_VID_FB],[vdvProj,VD_SRC_SVID_FB])
([vdvProj,VD_ASPECT1_FB],[vdvProj,VD_ASPECT2_FB],[vdvProj,VD_ASPECT3_FB],[vdvProj,VD_ASPECT4_FB],[vdvProj,VD_ASPECT5_FB],[vdvProj,VD_ASPECT6_FB],[vdvProj,VD_ASPECT7_FB],[vdvProj,VD_ASPECT8_FB])

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
		CASE VD_SRC_VID:
		CASE VD_SRC_SVID:
		CASE VD_SRC_RGB1:
		CASE VD_SRC_RGB2:
		CASE VD_SRC_RGB3:
		CASE VD_SRC_CMPNT:
		{
			IF([vdvProj,VD_PWR_ON_FB])
			{
				SEND_STRING dvProj,cCmdStr[nDPTitanActiveCmd]
				nPollType = PollInput
			}
			IF([vdvProj,VD_PWR_OFF_FB])
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
					on[vdvTP,VD_PWR_ON]
					if(nDPTitanActiveCmd=VD_PWR_ON) CmdExecuted()
				}
				case 4:
				{
					on[vdvTP,VD_PWR_OFF]
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
					on[vdvProj,VD_SRC_RGB1_FB]
					on[vdvTP,VD_SRC_RGB1]
					nDPTitanSource=1
					if(nDPTitanActiveCmd=VD_SRC_RGB1) CmdExecuted()
				}
				case 1:
				{
					on[vdvProj,VD_SRC_RGB2_FB]
					on[vdvTP,VD_SRC_RGB2]
					nDPTitanSource=2
					if(nDPTitanActiveCmd=VD_SRC_RGB2) CmdExecuted()
				}
				case 2:
				{
					on[vdvProj,VD_SRC_RGB3_FB]
					on[vdvTP,VD_SRC_RGB3]
					nDPTitanSource=3
					if(nDPTitanActiveCmd=VD_SRC_RGB3) CmdExecuted()
				}
				case 4:
				{
					on[vdvProj,VD_SRC_VID_FB]
					on[vdvTP,VD_SRC_VID]
					nDPTitanSource=4
					if(nDPTitanActiveCmd=VD_SRC_VID) CmdExecuted()
				}
				case 5:
				{
					on[vdvProj,VD_SRC_SVID_FB]
					on[vdvTP,VD_SRC_SVID]
					nDPTitanSource=5
					if(nDPTitanActiveCmd=VD_SRC_SVID) CmdExecuted()
				}
				case 6:
				{
					on[vdvProj,VD_SRC_CMPNT_FB]
					on[vdvTP,VD_SRC_CMPNT]
					nDPTitanSource=6
					if(nDPTitanActiveCmd=VD_SRC_CMPNT) CmdExecuted()
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
					on[vdvProj,VD_ASPECT1_FB]
					on[vdvTP,VD_ASPECT1]
					nDPTitanAspect=1
					if(nDPTitanActiveCmd=VD_ASPECT1) CmdExecuted()
				}
				case $01:
				{	
					on[vdvProj,VD_ASPECT2_FB]
					on[vdvTP,VD_ASPECT2]
					nDPTitanAspect=2
					if(nDPTitanActiveCmd=VD_ASPECT2) CmdExecuted()
				}
				case $14:
				{	
					on[vdvProj,VD_ASPECT3_FB]
					on[vdvTP,VD_ASPECT3]
					nDPTitanAspect=3
					if(nDPTitanActiveCmd=VD_ASPECT3) CmdExecuted()
				}
				case $16:
				{	
					on[vdvProj,VD_ASPECT4_FB]
					on[vdvTP,VD_ASPECT4]
					nDPTitanAspect=4
					if(nDPTitanActiveCmd=VD_ASPECT4) CmdExecuted()
				}
				case $17:
				{	
					on[vdvProj,VD_ASPECT5_FB]
					on[vdvTP,VD_ASPECT5]
					nDPTitanAspect=5
					if(nDPTitanActiveCmd=VD_ASPECT5) CmdExecuted()
				}
				case $18:
				{	
					on[vdvProj,VD_ASPECT6_FB]
					on[vdvTP,VD_ASPECT6]
					nDPTitanAspect=6
					if(nDPTitanActiveCmd=VD_ASPECT6) CmdExecuted()
				}
				case $19:
				{	
					on[vdvProj,VD_ASPECT7_FB]
					on[vdvTP,VD_ASPECT7]
					nDPTitanAspect=7
					if(nDPTitanActiveCmd=VD_ASPECT7) CmdExecuted()
				}
				case $1A:
				{	
					on[vdvProj,VD_ASPECT8_FB]
					on[vdvTP,VD_ASPECT8]
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
			if (cDPTitanTemp=$01 or cDPTitanTemp2=$01)
			{
				on[vdvTP,VD_PWR_OFF]
				on[vdvProj,VD_PWR_OFF_FB]
				nDPTitanPower=1
				if(nDPTitanActiveCmd=VD_PWR_OFF) CmdExecuted()
			}   
			else
			{
				switch(cDPTitanTemp)
				{
					case $02:
					{
						on[vdvProj,VD_WARMING_FB]
						nDPTitanPower=2
						if(nDPTitanActiveCmd=VD_PWR_ON) CmdExecuted()
					}
					case $03:
					{
						on[vdvTP,VD_PWR_ON]
						on[vdvProj,VD_PWR_ON_FB]
						nDPTitanPower=3
						if(nDPTitanActiveCmd=VD_PWR_ON) CmdExecuted()
					}
					case $04:
					{
						on[vdvProj,VD_COOLING_FB]
						nDPTitanPower=4
						if(nDPTitanActiveCmd=VD_PWR_OFF) CmdExecuted()
					}
				}
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
					off[vdvTP,VD_MUTE_TOG]
					off[nMuteStatus]
					on[vdvProj,VD_MUTE_OFF_FB]
					if(nDPTitanActiveCmd=VD_MUTE_OFF) CmdExecuted()
				}
				case 0:
				{
					on[vdvTP,VD_MUTE_TOG]
					on[nMuteStatus]
					on[vdvProj,VD_MUTE_ON_FB]
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
cCmdStr[VD_SRC_CMPNT]		= "$BE,$EF, $03, $19,$00, $58,$58, $01, $37,$02, $00,$00, $00,$00,$00,$00, $06,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//input2 Y/Pb/Pr
cCmdStr[VD_SRC_VID] 		= "$BE,$EF, $03, $19,$00, $58,$58, $01, $37,$02, $00,$00, $00,$00,$00,$00, $04,$00,$00,$00, $00,$00,$00,$00, $00,$00,$00,$00"	//input3 video
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
		on[vdvTP,VD_PWR_OFF]
	}
}

DATA_EVENT[dvProj]
{
	ONLINE:
	{
		SEND_COMMAND dvProj,"'SET BAUD 19200,N,8,1,485 DISABLE'" 
		WAIT 1 SEND_COMMAND dvproj,'RXON'
		WAIT 2 SEND_COMMAND dvProj,'HSOFF'
	}
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

button_event[vdvTP,VD_PWR_ON]
button_event[vdvTP,VD_PWR_OFF]	
button_event[vdvTP,VD_SRC_RGB1]
button_event[vdvTP,VD_SRC_RGB2]
button_event[vdvTP,VD_SRC_RGB3]
button_event[vdvTP,VD_SRC_CMPNT]
button_event[vdvTP,VD_SRC_VID] 
button_event[vdvTP,VD_SRC_SVID]
{
	push:
	{
		to[vdvProj,button.input.channel]
	}
}

button_event[vdvTP,VD_MUTE_TOG]
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

