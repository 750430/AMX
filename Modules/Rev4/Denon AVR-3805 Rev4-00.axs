MODULE_NAME='Denon AVR-3805 Rev4-00'(dev dvTP[], dev vdvDenon, dev dvDenon)
(***********************************************************)
(*  FILE CREATED ON: 05/05/2008  AT: 14:42:20              *)
(***********************************************************)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 06/05/2008  AT: 09:36:13        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
	set baud 9600,n,8,1
	define_module 'Denon AVR-3805 Rev4-00' pre1(vdvTP_DEV[1],vdvDEV1,dvDenon)
*)
#include 'HoppSNAPI Rev4-00.axi'
#include 'HoppSTRUCT Rev4-00.axi'
#include 'Queue_and_Threshold_Sizes'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
define_device

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

non_volatile integer nVol
non_volatile integer nMuted



(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

define_function parse(char cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,"'MUON'",1)): on[nMuted]
		active(find_string(cCompStr,"'MUOFF'",1)): off[nMuted]
		active(find_string(cCompStr,"'MV'",1)):
		{
			remove_string(cCompStr,"'MV'",1)
			nVol=atoi(left_string(cCompStr,2))
			if(nVol=99) nVol=0
			send_level dvTP,PRE_VOL_LVL,(nVol*255/98)
		}
	}
}






(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvTP]
{
	online:
	{
		send_level dvTP,PRE_VOL_LVL,(nVol*255/98)
	}
}

data_event[dvDenon]
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

channel_event[vdvDenon,0]
{
	on:
	{
		switch(channel.channel)
		{
			case PRE_SRC_DVD:send_string dvDenon,"'SIDVD',13"
			//case PRE_SRC_DVD2:send_string dvDenon,"'SIDVD',13"
			//case PRE_SRC_LD:send_string dvDenon,"'SIDVD',13"
			//case PRE_SRC_DVR:send_string dvDenon,"'SIDVD',13"
			case PRE_SRC_VCR:send_string dvDenon,"'SIVCR-1',13"
			//case PRE_SRC_CBL:send_string dvDenon,"'SITUNER',13"
			case PRE_SRC_SAT:send_string dvDenon,"'SIDBS/SAT',13"
			case PRE_SRC_GAME:send_string dvDenon,"'SIVDP',13"
			case PRE_SRC_TV:send_string dvDenon,"'SITV',13"
			case PRE_SRC_AUX1:send_string dvDenon,"'SIV.AUX',13"
			case PRE_SRC_CD:send_string dvDenon,"'SICD',13"
			case PRE_SRC_FM:send_string dvDenon,"'SITUNER',13"
			case PRE_SRC_TAPE:send_string dvDenon,"'SICDR/TAPE1',13"
			
			case PRE_MUTE_ON:send_string dvDenon,"'MUON',13"
			case PRE_MUTE_OFF:send_string dvDenon,"'MUOFF',13"
			
		}
	}
}

button_event[dvTP,0]
{
	push:
	{
		to[button.input]
		switch(button.input.channel)
		{
			case PRE_VOL_UP:
			{
				send_string dvDenon,"'MVUP',13"
			}
			case PRE_VOL_DN:
			{
				send_string dvDenon,"'MVDOWN',13"
			}
			case PRE_MUTE_TOG:
			{
				switch(nMuted)
				{
					case 1: send_string dvDenon,"'MUOFF',13"
					case 0: send_string dvDenon,"'MUON',13"
				}
			}
			default: to[vdvDenon,button.input.channel]
		}
	}
	hold[2,repeat]:
	{
		if (button.holdtime>200 and button.holdtime<2000)
		{
			switch(button.input.channel)
			{
				case PRE_VOL_UP:
				{
					nVol=nVol+2
					if(nVol>98) nVol=98
					if (nVol>9) send_string dvDenon,"'MV',itoa(nVol),13"
					else send_string dvDenon,"'MV0',itoa(nVol),13"
				}
				case PRE_VOL_DN:
				{
					if(nVol<2) nVol=0
					else nVol=nVol-2
					if (nVol>9) send_string dvDenon,"'MV',itoa(nVol),13"
					else send_string dvDenon,"'MV0',itoa(nVol),13"
				}
			}
		}
		if (button.holdtime>2000)
		{
			switch(button.input.channel)
			{
				case PRE_VOL_UP:
				{
					nVol=nVol+5
					if(nVol>98) nVol=98
					if (nVol>9) send_string dvDenon,"'MV',itoa(nVol),13"
					else send_string dvDenon,"'MV0',itoa(nVol),13"
				}
				case PRE_VOL_DN:
				{
					if(nVol<5) nVol=0
					else nVol=nVol-5
					if (nVol>9) send_string dvDenon,"'MV',itoa(nVol),13"
					else send_string dvDenon,"'MV0',itoa(nVol),13"
				}
			}
		}
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program
[dvTP,PRE_MUTE_TOG]=nMuted
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

