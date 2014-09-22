MODULE_NAME='CR 232-ATSC Rev5-00'(DEV vdvTP[], DEV vdvTuner, DEV dvTuner)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/13/2008  AT: 09:29:16        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  		                                       *)
(*----------------MODULE INSTRUCTIONS----------------------*)
(*

	define_module 'CR 232-ATSC Rev5-00' dev1(dvTP_DEV[1],vdvDEV1,dvTuner)
	SEND_COMMAND data.device, 'SET BAUD 9600,N,8,1'
*)
(***********************************************************)

#INCLUDE 'HoppSNAPI Rev5-01.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

CHAR cBuff[255]
INTEGER nCaption 		= 0
INTEGER nTunerBtn[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
											21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,
											38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55}
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE
([dvTuner,TUNER_PWR_ON],[dvTuner,TUNER_PWR_OFF])
([vdvTP,TUNER_PWR_ON],[vdvTP,TUNER_PWR_OFF])
(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
DEFINE_FUNCTION Parse(CHAR cCompStr[100])
{
	STACK_VAR INTEGER nPos
	STACK_VAR CHAR cMajor[3]
	STACK_VAR CHAR cJunk[5]
	STACK_VAR CHAR cMinor[3]
	
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,'<1TU',1)):
		{
			REMOVE_STRING(cCompStr,'<1TU',1)
			cMajor=LEFT_STRING(cCompStr,3)
			REMOVE_STRING(cCompStr,cMajor,1)
			cJunk=LEFT_STRING(cCompStr,4)
			REMOVE_STRING(cCompStr,cJunk,1)
			cMinor=LEFT_STRING(cCompStr,3)
			SEND_COMMAND vdvTP,"'^TXT-1,1&2,',ITOA(ATOI(cMajor)),'-',ITOA(ATOI(cMinor))"
			ON[dvTuner,TUNER_PWR_ON]
			[vdvTP,TUNER_PWR_ON]=[dvTuner,TUNER_PWR_ON]
		}	
		ACTIVE(FIND_STRING(cCompStr,'<1TM',1)):
		{
			ON[dvTuner,TUNER_PWR_OFF]
			[vdvTP,TUNER_PWR_OFF]=[dvTuner,TUNER_PWR_OFF]
		}
		ACTIVE(FIND_STRING(cCompStr,'<1Q01',1)): nCaption=0
		ACTIVE(FIND_STRING(cCompStr,'<1Q11',1)): nCaption=1
	}
}

DEFINE_FUNCTION OnPush(nIndex)
{
	LOCAL_VAR CHAR cChan[10]
	
	SWITCH(nIndex)
	{
		CASE TUNER_DIGIT_0:	 
		CASE TUNER_DIGIT_1:	
		CASE TUNER_DIGIT_2:	
		CASE TUNER_DIGIT_3:	
		CASE TUNER_DIGIT_4:	
		CASE TUNER_DIGIT_5:	
		CASE TUNER_DIGIT_6:	
		CASE TUNER_DIGIT_7:	
		CASE TUNER_DIGIT_8:	
		CASE TUNER_DIGIT_9:
		{
			cChan = "cChan,ITOA(nIndex-10)"
			SEND_COMMAND vdvTP,"'^TXT-1,1&2,',cChan"
		}
		CASE TUNER_DASH: 				
		{
			cChan="cChan,':'"
			SEND_COMMAND vdvTP,"'^TXT-1,1&2,',cChan"
		}
		CASE TUNER_CLEAR: 			
		{
			cChan	= ''
			SEND_COMMAND vdvTP,"'^TXT-1,1&2,',cChan"
		}
		CASE TUNER_BACK: 				
		{
			cChan = LEFT_STRING(cChan,(LENGTH_STRING(cChan)-1))
			SEND_COMMAND vdvTP,"'^TXT-1,1&2,',cChan"
		}
		CASE TUNER_CHAN_UP:			SEND_STRING dvTuner,"'>1TU',$0D"
		CASE TUNER_CHAN_DN:			SEND_STRING dvTuner,"'>1TD',$0D"		
		CASE TUNER_QUERY: 			SEND_STRING dvTuner,"'>1ST',$0D"
		CASE TUNER_PWR_ON:			SEND_STRING dvTuner,"'>1P1',$0D"
		CASE TUNER_PWR_OFF:			SEND_STRING dvTuner,"'>1P0',$0D"
		CASE TUNER_CAPTION_ON: 	SEND_STRING dvTuner,"'>1Q0=1',$0D"
		CASE TUNER_CAPTION_OFF:	SEND_STRING dvTuner,"'>1Q0=0',$0D"
		CASE TUNER_MENU:        SEND_STRING dvTuner,"'>1KK=105',$0D"
		CASE TUNER_UP:					SEND_STRING dvTuner,"'>1KK=108',$0D"
		CASE TUNER_DN:					SEND_STRING dvTuner,"'>1KK=109',$0D"
		CASE TUNER_LEFT:				SEND_STRING dvTuner,"'>1KK=107',$0D"
		CASE TUNER_OK:					SEND_STRING dvTuner,"'>1KK=110',$0D"
		CASE TUNER_EXIT:        SEND_STRING dvTuner,"'>1KK=111',$0D"
		CASE TUNER_GUIDE:				SEND_STRING dvTuner,"'>1KK=62',$0D"
		CASE TUNER_RIGHT:				SEND_STRING dvTuner,"'>1KK=106',$0D"
		CASE TUNER_RATIO:			send_string dvTuner,"'>1KK=82',$0D"
		CASE TUNER_CAPTION_TOG:
		{
			SEND_STRING dvTuner,"'>1Q0=',ITOA(!nCaption),$0D"
		}
		CASE TUNER_ENTER: 
		{
			SEND_STRING dvTuner,"'>1TC=',cChan,$0D"
			cChan=''
		}	
		
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvTuner] 
{ 
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cFullStr[100]
		STACK_VAR INTEGER nPos	
	
		//this accounts for multiple strings in cBuff
		//or receiving partial string(s) 
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
CHANNEL_EVENT[vdvTuner,0]
{
	ON:	
	{
		IF(channel.channel<200) 
		{
			OnPush(channel.channel)
			send_string 0,"'my chan2 is ',itoa(channel.channel)"
		}
	}
}
BUTTON_EVENT [vdvTP,nTunerBtn]
{
	PUSH:	
	{
		TO[button.input.device,button.input.channel]
		PULSE[vdvTuner,button.input.channel]
		SEND_STRING 0,"'my chan1 is ',itoa(button.input.channel)"
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

