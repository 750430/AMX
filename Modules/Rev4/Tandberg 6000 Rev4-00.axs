MODULE_NAME='Tandberg 6000 Rev4-00'(DEV vdvTP, DEV vdvVTC, DEV dvVTC)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/06/2008  AT: 09:22:47        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev4-01.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

LONG lFB	 		= 2000 		//Timeline for feedback
long lPoll			=	2001

btnGreen	=	71
btnYellow	=	72
btnBlue		=	73

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

INTEGER nCMD = 0
INTEGER nSRC = 1
INTEGER nPRIV = 0
LONG lFBArray[] = {100}						//.1 seconds
long lPollArray[]	=	{2000}		//2 seconds

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	select
	{
		active(find_string(cCompStr,"'mic on'",1)):
		{
			off[nPriv]
			on[vdvVTC,VTC_PRIVACY_OFF_FB]
		}
		active(find_string(cCompStr,"'mic off'",1)):
		{
			on[nPriv]
			on[vdvVTC,VTC_PRIVACY_ON_FB]
		}
	}
}

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

([vdvVTC, VTC_PRIVACY_ON_FB],[vdvVTC, VTC_PRIVACY_OFF_FB])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
TIMELINE_CREATE(lPoll,lPollArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvVTC]
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

BUTTON_EVENT [vdvTP,0]
{
	PUSH:		
	{
		STACK_VAR INTEGER nBtn
		to[button.input.device,button.input.channel]
		nBtn=button.input.channel
		switch(nBtn)
		{
			case VTC_ZOOM_IN:		send_string dvVTC,"'key z+',$0D,$0A"
			case VTC_ZOOM_OUT:		send_string dvVTC,"'key z-',$0D,$0A"
			case VTC_CAM_UP:		send_string dvVTC,"'key up',$0D,$0A"
			case VTC_CAM_DOWN:		send_string dvVTC,"'key do',$0D,$0A"
			case VTC_CAM_LEFT:		send_string dvVTC,"'key le',$0D,$0A"
			case VTC_CAM_RIGHT:		send_string dvVTC,"'key ri',$0D,$0A"
			default:				to[vdvVTC,button.input.channel]
		}
	}
	hold[2,repeat]:
	{
		switch(button.input.channel)
		{
			case VTC_ZOOM_IN:		send_string dvVTC,"'key z+',$0D,$0A"
			case VTC_ZOOM_OUT:		send_string dvVTC,"'key z-',$0D,$0A"
			case VTC_CAM_UP:		send_string dvVTC,"'key up',$0D,$0A"
			case VTC_CAM_DOWN:		send_string dvVTC,"'key do',$0D,$0A"
			case VTC_CAM_LEFT:		send_string dvVTC,"'key le',$0D,$0A"
			case VTC_CAM_RIGHT:		send_string dvVTC,"'key ri',$0D,$0A"
		}
	}
}

CHANNEL_EVENT [vdvVTC,0]
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
				send_string dvVTC,"'key ',ITOA(nChnl-10),$0D,$0A"
			}
			CASE VTC_KEY_0:   		send_string dvVTC,"'key 0',$0D,$0A"
			case VTC_DELETE:		send_string dvVTC,"'key de',$0D,$0A"
			CASE VTC_KEY_STAR:		send_string dvVTC,"'key *',$0D,$0A"
			CASE VTC_KEY_POUND:		send_string dvVTC,"'key #',$0D,$0A"
			CASE VTC_CONNECT:		send_string dvVTC,"'key conn',$0D,$0A"
			CASE VTC_DISCONNECT:	send_string dvVTC,"'key disc',$0D,$0A"
			CASE VTC_PIP_TOG:		send_string dvVTC,"'key pip',$0D,$0A"
			CASE VTC_SELFVIEW_TOG:	send_string dvVTC,"'key sv',$0D,$0A"
			CASE VTC_ADDRESSBOOK:	send_string dvVTC,"'key di',$0D,$0A"
			CASE VTC_PRIVACY_TOG:	
			{
				send_string dvVTC,"'key mm',$0D,$0A"
				nPriv = !nPriv
			}
			CASE VTC_MENU:			send_string dvVTC,"'key me',$0D,$0A"
			CASE VTC_UP:			send_string dvVTC,"'key up',$0D,$0A"				
			CASE VTC_DOWN:			send_string dvVTC,"'key do',$0D,$0A"			
			CASE VTC_LEFT:			send_string dvVTC,"'key le',$0D,$0A"			
			CASE VTC_RIGHT:			send_string dvVTC,"'key ri',$0D,$0A"
			CASE VTC_CANCEL:		send_string dvVTC,"'key cancel',$0D,$0A"	
			CASE VTC_OK:			send_string dvVTC,"'key ok',$0D,$0A"		
			CASE VTC_WAKE:			send_string dvVTC,"'screensaver off',$0D,$0A"
			CASE VTC_FAR:			send_string dvVTC,"'key fe',$0D,$0A"
			CASE VTC_NR_VID1:		send_string dvVTC,"'key maincam',$0D,$0A"
			CASE VTC_NR_VID2:		send_string dvVTC,"'key aux',$0D,$0A"
			CASE VTC_NR_VID3:		send_string dvVTC,"'key doccam',$0D,$0A"
			CASE VTC_NR_VID4:		send_string dvVTC,"'key vcr',$0D,$0A"
			CASE VTC_NR_VID5:		send_string dvVTC,"'key pc',$0D,$0A"
			case btnGreen:			send_string dvVTC,"'key f1',$0D,$0A"
			case btnYellow:			send_string dvVTC,"'key f2',$0D,$0A"
			case btnBlue:			send_string dvVTC,"'key f3',$0D,$0A"
		}	                                            
  }	
}

TIMELINE_EVENT[lFB]
{
	[vdvTP, VTC_PRIVACY_TOG] = nPriv
	[vdvTP, VTC_NR_VID1]=(nSRC=1)
	[vdvTP, VTC_NR_VID2]=(nSRC=2)
	[vdvTP, VTC_NR_VID3]=(nSRC=3)
	[vdvTP, VTC_NR_VID4]=(nSRC=4)
	[vdvTP, VTC_NR_VID5]=(nSRC=5)
}

timeline_event[lPoll]
{
	send_string dvVTC,"'mic',$0D"
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
