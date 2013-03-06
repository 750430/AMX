MODULE_NAME='Tandberg MXP Rev5-01'(DEV vdvTP, DEV vdvVTC, DEV dvVTC)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/06/2008  AT: 09:22:47        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-00.axi'

//define_module 'Tandberg MXP Rev5-01' vtc1(vdvTP_VTC1,vdvVTC1,dvVTC)
//Set Baud 9600,N,8,1
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lFB	 		= 2000 		//Timeline for feedback

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

INTEGER btn_VTC[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,
										33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,
										62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,
										91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,
										115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,
										137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,
										159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,
										181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,
										203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,
										225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,
										247,248,249,250,251,252,253,254,255}

INTEGER nSRC = 1

CHAR cPRIV[2][3] = {'on','off'}
INTEGER nPRIV = 0

CHAR cCAM[6][6] = {'in','out','up','down','left','right'}
CHAR cVTCSrc[2][8] = {'Main','Duo'}

CHAR cVTC_Buff[255]
CHAR cVTC_Resp[255]

LONG lFBArray[] = {100}						//.1 seconds

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

([dvVTC, VTC_PRIVACY_ON],[dvVTC, VTC_PRIVACY_OFF])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

CREATE_BUFFER dvVTC, cVTC_Buff

TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvVTC]
{
	STRING:
	{
		cVTC_Buff = "cVTC_Buff,DATA.TEXT"
		SELECT
		{
			ACTIVE(FIND_STRING(cVTC_Buff,"'xconfiguration audio microphones mode:'",1)): 
			{
				cVTC_Resp = REMOVE_STRING(cVTC_Buff,"'xconfiguration audio microphones mode:'",1)
				IF(FIND_STRING(cVTC_Buff,"'on'",1))  ON[dvVTC, VTC_PRIVACY_OFF]
				IF(FIND_STRING(cVTC_Buff,"'off'",1))  ON[dvVTC, VTC_PRIVACY_ON]
			}
			ACTIVE(1):	cVTC_Buff=''
		}		
	}
}

BUTTON_EVENT [vdvTP, btn_VTC]
{
	PUSH:		
	{
		STACK_VAR INTEGER nBtn
		to[button.input.device,button.input.channel]
		nBtn = GET_LAST(btn_VTC)
		IF (!(nBtn = VTC_CAM_PRESET1 || nBtn = VTC_CAM_PRESET2 || nBtn = VTC_CAM_PRESET3 || 
					nBtn = VTC_CAM_PRESET4 || nBtn = VTC_CAM_PRESET5 || nBtn = VTC_CAM_PRESET6))
		{
			ON[vdvVTC,(GET_LAST(btn_VTC))]
		}
	}
	HOLD[30]:
	{
		STACK_VAR INTEGER nBtn
		nBtn = GET_LAST(btn_VTC)
		IF ((nBtn = VTC_CAM_PRESET1 || nBtn = VTC_CAM_PRESET2 || nBtn = VTC_CAM_PRESET3 || 
					nBtn = VTC_CAM_PRESET4 || nBtn = VTC_CAM_PRESET5 || nBtn = VTC_CAM_PRESET6))
		{
			ON[vdvVTC,(GET_LAST(btn_VTC))]
		}	
	}
	RELEASE:	
	{
		OFF[vdvVTC,(GET_LAST(btn_VTC))]
		SWITCH(GET_LAST(btn_VTC))
		{
			CASE VTC_CAM_PRESET1:
			CASE VTC_CAM_PRESET2:
			CASE VTC_CAM_PRESET3:
			CASE VTC_CAM_PRESET4:
			CASE VTC_CAM_PRESET5:
			CASE VTC_CAM_PRESET6:
			{
				SEND_STRING dvVTC,"'xcommand presetactivate number:',ITOA(GET_LAST(btn_VTC) - (VTC_CAM_PRESET1-1)),$0D,$0A"
			}
		}
	}
}

CHANNEL_EVENT [vdvVTC, 0]
{
	ON:
	{
		STACK_VAR INTEGER nChnl
		nChnl = CHANNEL.CHANNEL
		SWITCH (nChnl)
		{
			CASE VTC_KEY_1:
			CASE VTC_KEY_2:
			CASE VTC_KEY_3:
			CASE VTC_KEY_4:
			CASE VTC_KEY_5:
			CASE VTC_KEY_6:
			CASE VTC_KEY_7:
			CASE VTC_KEY_8:
			CASE VTC_KEY_9:
			{
				SEND_STRING dvVTC, "'key ',ITOA(nChnl-10),$0D,$0A"
			}
			CASE VTC_KEY_0:   		SEND_STRING dvVTC, "'key 0',$0D,$0A"
			CASE VTC_KEY_STAR:		SEND_STRING dvVTC, "'key *',$0D,$0A"
			CASE VTC_KEY_POUND:		SEND_STRING dvVTC, "'key #',$0D,$0A"
			CASE VTC_CONNECT:			SEND_STRING dvVTC, "'key conn',$0D,$0A"
			CASE VTC_DISCONNECT:	SEND_STRING dvVTC, "'key disc',$0D,$0A"
			CASE VTC_PIP_TOG:			SEND_STRING dvVTC, "'key lay',$0D,$0A"
			CASE VTC_SELFVIEW_TOG:		SEND_STRING dvVTC, "'key sv',$0D,$0A"
			CASE VTC_ADDRESSBOOK:	SEND_STRING dvVTC, "'key pb',$0D,$0A"
			CASE VTC_PRIVACY_TOG:	
			{
				SEND_STRING dvVTC, "'xconfiguration audio microphones mode:',cPriv[nPriv+1],$0D,$0A"
				nPriv = !nPriv
			}
			CASE VTC_MENU:				SEND_STRING dvVTC, "'key ok',$0D,$0A"
			CASE VTC_UP:					SEND_STRING dvVTC, "'key up',$0D,$0A"				
			CASE VTC_DOWN:				SEND_STRING dvVTC, "'key do',$0D,$0A"			
			CASE VTC_LEFT:				SEND_STRING dvVTC, "'key le',$0D,$0A"			
			CASE VTC_RIGHT:				SEND_STRING dvVTC, "'key ri',$0D,$0A"
			CASE VTC_CANCEL:			SEND_STRING dvVTC, "'key cancel',$0D,$0A"	
			CASE VTC_DELETE:			send_string dvVTC, "'key cancel',$0D,$0A"
			CASE VTC_OK:				SEND_STRING dvVTC, "'key ok',$0D,$0A"		
			CASE VTC_WAKE:			send_string dvVTC,"'xcommand ScreensaverDeactivate',$0D,$0A"
			CASE VTC_GRAPHICS:			send_string dvVTC, "'key present',$0D,$0A"
			CASE VTC_ZOOM_IN:
			CASE VTC_ZOOM_OUT:
			CASE VTC_CAM_UP:
			CASE VTC_CAM_DOWN:
			CASE VTC_CAM_LEFT:
			CASE VTC_CAM_RIGHT:
			{
				SEND_STRING dvVTC,"'xcommand cameramove camera:1 direction:',cCAM[nChnl - (VTC_ZOOM_IN-1)],$0D,$0A"
			}
			CASE VTC_NR_VID1:
			CASE VTC_NR_VID2:
			CASE VTC_NR_VID3:
			CASE VTC_NR_VID4:			
			CASE VTC_NR_VID5:	
			{
				nSRC = nChnl-VTC_NR_VID1+1
				SEND_STRING dvVTC, "'xconfiguration MainVideoSource: ',ITOA(nSRC),$0D"
			}
			CASE VTC_CAM_PRESET1:
			CASE VTC_CAM_PRESET2:
			CASE VTC_CAM_PRESET3:
			CASE VTC_CAM_PRESET4:
			CASE VTC_CAM_PRESET5:
			CASE VTC_CAM_PRESET6:
			{
				SEND_COMMAND vdvTP,'ADBEEP'			
				SEND_STRING dvVTC,"'xcommand presetstore number:',ITOA(nChnl - (VTC_CAM_PRESET1-1)),$0D,$0A"
			}
		}	
  }	
  OFF:
  {
		STACK_VAR INTEGER nChnl
		nChnl = CHANNEL.CHANNEL	
		SWITCH (nChnl)
		{	
			CASE VTC_ZOOM_IN:
			CASE VTC_ZOOM_OUT:
			CASE VTC_CAM_UP:
			CASE VTC_CAM_DOWN:
			CASE VTC_CAM_LEFT:
			CASE VTC_CAM_RIGHT:
			{
				SEND_STRING dvVTC,"'xcommand camerahalt camera:1',$0D,$0A"	
			}		
		}
	}
}

TIMELINE_EVENT[lFB]
{
	IF((nPriv = 0) && [dvVTC, VTC_PRIVACY_OFF])	SEND_STRING dvVTC, "'xconfiguration audio microphones mode:',cPriv[2],$0D,$0A" 
	IF((nPriv = 1) && [dvVTC, VTC_PRIVACY_ON]) SEND_STRING dvVTC, "'xconfiguration audio microphones mode:',cPriv[1],$0D,$0A" 	
	
	[vdvTP, VTC_PRIVACY_TOG] = [dvVTC, VTC_PRIVACY_ON]
	
	[vdvTP, VTC_NR_VID1]		= (nSRC = 1)
	[vdvTP, VTC_NR_VID2] 		= (nSRC = 2)
	[vdvTP, VTC_NR_VID3] = (nSRC = 3)
	[vdvTP, VTC_NR_VID4] 	= (nSRC = 4)
	[vdvTP, VTC_NR_VID5] 		= (nSRC = 5)
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
