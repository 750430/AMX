MODULE_NAME='Polycom Vortex ATC Rev4-00' (DEV vdvTP, DEV vdvATC, DEV dvATC, char cAddr[4])
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

//define_module 'Polycom Vortex ATC Rev4-00' atc1(vdvTP_ATC1,vdvATC1,dvVortex,cATCAddr)
//9600,N,8,1


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

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

INTEGER btn_ATC[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,
											25,26,27,28,29,30,31}

INTEGER nATCPriv			= 0
INTEGER nOnHook 			= 1
CHAR cPhoneNum[20]
CHAR cAUD_RESP[255]
CHAR cAUD_BUFF[255]

LONG lFBArray[] = {100}						//.1 seconds
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

([vdvATC, ATC_PRIVACY_ON_FB],[vdvATC, ATC_PRIVACY_OFF_FB])
([vdvATC, ATC_ON_HOOK_FB],[vdvATC, ATC_OFF_HOOK_FB])

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)
DEFINE_FUNCTION OnPush(INTEGER nIndex)
{
	STACK_VAR INTEGER nPriv
	SWITCH(nIndex)
	{
		CASE ATC_DIGIT_0:
		CASE ATC_DIGIT_1:
		CASE ATC_DIGIT_2:
		CASE ATC_DIGIT_3:
		CASE ATC_DIGIT_4:
		CASE ATC_DIGIT_5:
		CASE ATC_DIGIT_6:
		CASE ATC_DIGIT_7:
		CASE ATC_DIGIT_8:
		CASE ATC_DIGIT_9:
		{
		IF(nOnHook)	cPhoneNum = "cPhoneNum,ITOA(nIndex-10)"
		ELSE SEND_STRING dvATC,"cAddr,'DIAL',ITOA(nIndex-10),$0D"
		}
		CASE ATC_STAR_KEY:
		{
			IF(nOnHook) cphonenum = "cPhoneNum,'*'"
			ELSE SEND_STRING dvATC,"cAddr,'DIAL*',$0D"
		}
		CASE ATC_POUND_KEY:
		{
			IF(nOnHook) cPhonenum = "cPhoneNum,'#'"
			ELSE SEND_STRING dvATC,"cAddr,'DIAL#',$0D"
		}
		CASE ATC_PAUSE:
		{
			IF(nOnHook)	cPhoneNum = "cPhoneNum,','"
			ELSE SEND_STRING dvATC,"cAddr,'DIAL,',$0D"
		}
		CASE ATC_CLEAR:	//clear
		{
			cPhoneNum=''
		}
		CASE ATC_BACKSPACE:	//bs
		{
			cPhoneNum=LEFT_STRING(cPhoneNum,(LENGTH_STRING(cPhoneNum)-1))
		}
		CASE ATC_DIAL:	//dial
		{
			IF(cPhoneNum <>'') 
			{
				SEND_STRING dvATC,"cAddr,'DIAL',cPhoneNum,$0D"
				WAIT 2 SEND_STRING dvATC,"cAddr,'PHONE?',$0D"
			}	
		}
		CASE ATC_HANGUP:
		CASE ATC_ANSWER:	//answer - hangup
		{
			SEND_STRING dvATC,"cAddr,'PHONE',ITOA(nOnHook),$0D"
			WAIT 2 SEND_STRING dvATC,"cAddr,'PHONE?',$0D"
		}
		CASE ATC_PRIVACY_TOG:
		{
			nPriv = nATCPriv
			nPriv = !nPriv
			SEND_STRING dvATC,"cAddr,'MUTEOT',ITOA(nPriv),$0D"
		}
	} 
	SEND_COMMAND vdvTP,"'@TXT',1,cPhoneNum"
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvATC]
{
	ONLINE:
	{
		SEND_COMMAND dvATC, 'SET BAUD 9600,N,8,1'
		//per protocol document 'send a few CR to clear buffer on boot'
		WAIT 1 SEND_STRING dvATC,"$0D"	
		WAIT 2 SEND_STRING dvATC,"$0D"
		WAIT 3 SEND_STRING dvATC,"$0D"
		WAIT 10 SEND_STRING dvATC,"cAddr,'PHONE?',$0D"
		WAIT 11 SEND_STRING dvATC,"cAddr,'MUTEOT?',$0D"
		WAIT 12 SEND_STRING dvATC,"cAddr,'MUTEOL?',$0D"
	}
	STRING:
	{
		STACK_VAR INTEGER X
		cAUD_BUFF="cAUD_BUFF,DATA.TEXT"
		FOR(X=1; X<=2; X++)
		{
			cAUD_RESP=REMOVE_STRING(cAUD_BUFF,"$0D",1)
			SELECT
			{
				ACTIVE(FIND_STRING(cAUD_RESP,"'PHONE0'",1)): 
				{
					ON[vdvATC, ATC_ON_HOOK_FB]
					nOnHook=1
				}
				ACTIVE(FIND_STRING(cAUD_RESP,"'PHONE1'",1)): 
				{
					ON[vdvATC, ATC_OFF_HOOK_FB]
					nOnHook=0
				}
				ACTIVE(FIND_STRING(cAUD_RESP,"cAddr,'MUTEOT1',$0D",1)): 
				{
					ON[vdvATC, ATC_PRIVACY_ON_FB]
					nATCPriv=1
				}
				ACTIVE(FIND_STRING(cAUD_RESP,"cAddr,'MUTEOT0',$0D",1)): 
				{
					ON[vdvATC, ATC_PRIVACY_OFF_FB]
					nATCPriv=0
				}
				//ACTIVE(FIND_STRING(cAUD_RESP,"cAddr,'BLDATA'",1)): SEND_STRING dvATC,"cAddr,'BLAUTO0',$0D"
				ACTIVE(1):cAUD_BUFF=''
			}
		}	
	}
}

CHANNEL_EVENT[vdvATC,0]
{
	ON:		
	{
		OnPush(channel.channel)
	}
}

BUTTON_EVENT [vdvTP, btn_ATC]
{
	PUSH:		
	{
		ON[vdvATC,(GET_LAST(btn_ATC))]
		if (button.input.channel<>ATC_ANSWER and button.input.channel<>ATC_HANGUP and button.input.channel<>ATC_PRIVACY_TOG) to[button.input]
	}
	RELEASE:	OFF[vdvATC,(GET_LAST(btn_ATC))]
}

TIMELINE_EVENT[lFB]
{
	[vdvTP, ATC_ANSWER]	 = [vdvATC, ATC_OFF_HOOK_FB]
	[vdvTP, ATC_HANGUP]  = [vdvATC, ATC_OFF_HOOK_FB]
	[vdvTP,ATC_PRIVACY_TOG]	 = [vdvATC, ATC_PRIVACY_ON_FB]
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)