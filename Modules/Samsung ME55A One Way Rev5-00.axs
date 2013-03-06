MODULE_NAME='Samsung ME55A One Way Rev5-00'(dev dvTP, dev vdvLCD, dev dvLCD)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/06/2011  AT: 17:12:06        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                   *)
(***********************************************************)

//define_module 'Samsung ME55A One Way Rev5-00' LCD1(vdvTP_DISP1,vdvDISP1,dvLCD)
//Set baud to 9600,N,8,1

#include 'HoppSNAPI Rev5-01.axi'
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

integer HDMI = $21

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

CHAR cCmdStr[35][10]	

INTEGER nCmd=0



(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTP,VD_PWR_ON],[dvTP,VD_PWR_OFF])

([dvLCD,VD_PWR_ON],[dvLCD,VD_PWR_OFF])
([dvLCD,VD_SRC_DVI1],[dvLCD,VD_SRC_RGB1],[dvLCD,VD_SRC_CMPNT1],[dvLCD,VD_SRC_VGA1],[dvLCD,VD_SRC_AUX2])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
define_function integer calcchecksum(char cMsg[])
{
	stack_var integer nLoop
	stack_var integer nCheckSum
	
	off[nCheckSum]
	for (nLoop=1;nLoop<=length_string(cMsg);nLoop++)
	{
		nCheckSum=((nCheckSum+cMsg[nLoop])& $FF)
	}
	return nCheckSum
}	

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

cCmdStr[VD_PWR_ON]		= "$AA,$11,$FF,$01,$01,calcchecksum("$11,$FF,$01,$01")" 			
cCmdStr[VD_PWR_OFF]		= "$AA,$11,$FF,$01,$00,calcchecksum("$11,$FF,$01,$00")"
cCmdStr[VD_SRC_RGB1]	= "$AA,$14,$FF,$01,$1E,calcchecksum("$14,$FF,$01,$1E")"
cCmdStr[VD_SRC_VGA1]	= "$AA,$14,$FF,$01,$14,calcchecksum("$14,$FF,$01,$14")"
cCmdStr[VD_SRC_CMPNT1]	= "$AA,$14,$FF,$01,$08,calcchecksum("$14,$FF,$01,$08")"
cCmdStr[VD_SRC_DVI1]	= "$AA,$14,$FF,$01,HDMI,calcchecksum("$14,$FF,$01,HDMI")"
cCmdStr[VD_SRC_AUX2]	= "$AA,$14,$FF,$01,$30,calcchecksum("$14,$FF,$01,$30")"

cCmdStr[VD_PCADJ]		= "$AA,$3D,$FF,$01,$00,calcchecksum("$3D,$FF,$01,$00")"


(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

CHANNEL_EVENT[vdvLCD,0]
{
	ON:
	{
		nCmd=channel.channel
		SWITCH(nCmd)
		{
			CASE VD_PWR_ON:
			{
				SEND_STRING dvLCD,cCmdStr[nCmd]
				on[dvLCD,VD_PWR_ON]
				on[dvTP,VD_PWR_ON]
			}
			CASE VD_PWR_OFF:
			{
				SEND_STRING dvLCD,cCmdStr[nCmd]
				on[dvLCD,VD_PWR_OFF]
				on[dvTP,VD_PWR_OFF]
			}
			CASE VD_SRC_RGB1:
			CASE VD_SRC_DVI1:
			CASE VD_SRC_AUX2:
			case VD_SRC_CMPNT1:
			case VD_SRC_VGA1:
			{
				IF([dvLCD,VD_PWR_ON])
				{
					SEND_STRING dvLCD,cCmdStr[nCmd]
				}
				ELSE
				{
					SEND_STRING dvLCD,cCmdStr[VD_PWR_ON]
					wait 20
					SEND_STRING dvLCD,cCmdStr[nCmd]
					wait 40
					SEND_STRING dvLCD,cCmdStr[nCmd]
				}
				on[dvLCD,VD_PWR_ON]
				on[dvTP,VD_PWR_ON]
			}
			case VD_PCADJ:
			{
				send_string dvLCD,cCmdStr[nCmd]
			}
		}
	}
}
BUTTON_EVENT[dvTP,0]
{
	PUSH:
	{
		PULSE[vdvLCD,button.input.channel]
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

