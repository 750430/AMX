MODULE_NAME='Biamp VOIP Dialer Rev4-00'(DEV vdvTP, DEV vdvATC, DEV dvATC, CHAR cAddr, INTEGER nInstID, integer nLine)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 08/22/2008  AT: 17:16:10        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*----------------MODULE INSTRUCTIONS----------------------*)
(*

	In your program, do these operations - 

	1) 	Use include files as specified below:


	#INCLUDE 'HoppSNAPI.axi'		//Required
	#INCLUDE 'HoppDEV.axi'			//Optional

	2)	In DEFINE_VARIABLE, declare variables as shown. You 
			absolutely must define the Instance ID.
	
define_variable //ATC Variables

volatile		integer		nInstID		=	50
volatile		char		cATCAddr	=	'1'	


	3)  Define your module as shown.  You must pass a touch panel
			(virtual suggested), a virtual device, and the
			actual device.  
			
			If you use: #INCLUDE 'HoppDEV.axi'you can insert the line 
			below and you only need to define dvATC in DEFINE_DEVICE

	define_module 'Biamp VOIP Dialer Rev4-00' ATC1(vdvTP_ATC1,vdvATC1,dvBiamp,cATCAddr,nInstID,nLine) 
*)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev4-00.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

//default values
CHAR DefaultAddr[] 	= '1'

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

VOLATILE CHAR cDialStr[50]
VOLATILE CHAR cRingStr[50]
VOLATILE CHAR cHookStr[50]
VOLATILE CHAR cFlashStr[50]
VOLATILE CHAR cBuff[255]
VOLATILE CHAR cPhoneNum[50]

VOLATILE INTEGER nATCBtn[]={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,
														20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,
														36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51}

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nPos
	STACK_VAR INTEGER nHook
	
	IF(FIND_STRING(cCompStr,'RING',1) || FIND_STRING(cCompStr,'VOIPHOOKSTATE',1))
	{
		SELECT
		{
//			ACTIVE(FIND_STRING(cCompStr,cRingStr,1)):
//			{
//				ON[vdvTP,ATC_RINGING_FB]
//				SEND_COMMAND vdvTP,"'ADBEEP'"
//				WAIT 50 OFF[vdvTP,ATC_RINGING_FB]
//			}
			ACTIVE(FIND_STRING(cCompStr,cHookStr,1)):
			{
				if(find_string(cCompStr,"'+OK'",1)) pulse[vdvATC,ATC_QUERY]
				else
				{
					REMOVE_STRING(cCompStr,cHookStr,1)
					nPos=FIND_STRING(cCompStr,"$20",1)
					nHook=ATOI(GET_BUFFER_STRING(cCompStr,nPos-1))
					[vdvATC,ATC_ON_HOOK_FB]=nHook		
					[vdvATC,ATC_OFF_HOOK_FB]=!nHook	
				}
			}
		}
	}	
}

DEFINE_FUNCTION Key(CHAR nVal[1])
{
	IF(![vdvATC,ATC_OFF_HOOK_FB])	cPhoneNum = "cPhoneNum,nVal"
	ELSE SEND_STRING dvATC,"cDialStr,nVal,$0A"
}
DEFINE_FUNCTION OnPush(INTEGER nCmd)
{
	SWITCH(nCmd)
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
			Key(ITOA(nCmd-10))
		}
		CASE ATC_STAR_KEY: 	Key('*')
		CASE ATC_POUND_KEY: Key('#')
		CASE ATC_PAUSE: 		Key(',')					
		CASE ATC_CLEAR:  		cPhoneNum=''					
		CASE ATC_BACKSPACE: cPhoneNum=LEFT_STRING(cPhoneNum,(LENGTH_STRING(cPhoneNum)-1))
		CASE ATC_ANSWER: 		SEND_STRING dvATC,"'S',cHookStr,'0',$0A"
		CASE ATC_HANGUP: 		SEND_STRING dvATC,"'S',cHookStr,'1',$0A"	
		CASE ATC_QUERY: 		SEND_STRING dvATC,"'G',cHookStr,$0A"
		//CASE ATC_FLASH:			send_string dvATC,"cFlashStr"
		CASE ATC_DIAL: 
		{
			IF(LENGTH_STRING(cPhoneNum))
			{	
				SEND_STRING dvATC,"cDialStr,cPhoneNum,$0A"
				wait 20
				pulse[vdvATC,ATC_QUERY]
			}
			ELSE SEND_STRING dvATC,"'S',cHookStr,'0',$0A"
		}		
	}
	SEND_COMMAND vdvTP,"'!T',1,cPhoneNum"						
}

DEFINE_CALL 'INIT_STRINGS'
{
	IF(!LENGTH_STRING(cAddr)) cAddr=DefaultAddr
	cDialStr ="'DIAL',$20,cAddr,$20,'VOIPPHONENUM',$20,ITOA(nInstID),$20,itoa(nLine),$20"
    cHookStr ="'ETD',$20,cAddr,$20,'VOIPHOOKSTATE',$20,ITOA(nInstID),$20,itoa(nLine),$20"
//	cFlashStr="'FLASH',$20,cAddr,$20,'VOIPLINE',$20,itoa(nInstID),$0D,$0A"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

WAIT 20	CALL 'INIT_STRINGS'

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT
DATA_EVENT[dvATC]
{
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cBuff[255]
		LOCAL_VAR CHAR cFullStr[100]
		STACK_VAR INTEGER nPos
		
		cBuff = "cBuff,data.text"
		WHILE(LENGTH_STRING(cBuff))
		{
			SELECT
			{
				ACTIVE(FIND_STRING(cBuff,"$0A",1)&& LENGTH_STRING(cHold)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
					Parse(cFullStr)
					cHold=''
				}
				ACTIVE(FIND_STRING(cBuff,"$0A",1)):
				{
					nPos=FIND_STRING(cBuff,"$0A",1)
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
CHANNEL_EVENT[vdvATC,0]
{
	ON:	  
	{
		IF(channel.channel<200) OnPush(channel.channel)
	}
}
BUTTON_EVENT [vdvTP,nATCBtn]
{
	PUSH:		
	{
		TO[button.input.device,button.input.channel]
		PULSE[vdvATC,button.input.channel]
	}
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[vdvTP,ATC_ON_HOOK_FB]=[vdvATC,ATC_ON_HOOK_FB]
[vdvTP,ATC_OFF_HOOK_FB]=[vdvATC,ATC_OFF_HOOK_FB]

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
