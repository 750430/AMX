MODULE_NAME='Extron AVT 200HD Rev5-00'(DEV vdvTP[], DEV vdvTuner, DEV dvTuner)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/21/2011  AT: 13:44:30        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  		                                       *)
(*----------------MODULE INSTRUCTIONS----------------------*)
(*

	define_module 'Extron AVT 200HD Rev5-00' dev1(dvTP_DEV[1],vdvDEV1,dvTuner)
	SEND_COMMAND data.device, 'SET BAUD 9600,N,8,1'
*)
(***********************************************************)

#INCLUDE 'HoppSNAPI Rev5-03.axi'
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
	send_string 0,"cCompStr"
	SELECT
	{
		ACTIVE(FIND_STRING(cCompStr,'Tvct',1)):
		{
			remove_string(cCompStr,'Tvct',1)
			while(left_string(cCompStr,1)='0') remove_string(cCompStr,'0',1)
			if(find_string(cCompStr,"$0D,$0A",1)) cCompStr=left_string(cCompStr,find_string(cCompStr,"$0D,$0A",1)-1)
			SEND_COMMAND vdvTP,"'^TXT-1,1&2,',cCompStr"
			send_string 0,"cCompStr"
		}	
		ACTIVE(FIND_STRING(cCompStr,'E13',1)):
		{
			SEND_COMMAND vdvTP,"'^TXT-1,1&2,Error'"
			send_string 0,"'Error'"
		}
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
			if(find_string(cChan,'.',1))
			{
				if(length_string(cChan)=find_string(cChan,'.',1))
				{
					cChan = "cChan,ITOA(nIndex-10)"
				}
			}
			else
			{
				cChan = "cChan,ITOA(nIndex-10)"
			}
			SEND_COMMAND vdvTP,"'^TXT-1,1&2,',cChan"
		}
		CASE TUNER_DASH: 				
		{
			if(length_string(cChan)>0) cChan="cChan,'.'"
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
		CASE TUNER_CHAN_UP:			SEND_STRING dvTuner,"'+T'"
		CASE TUNER_CHAN_DN:			SEND_STRING dvTuner,"'-T'"		
		CASE TUNER_UP:					SEND_STRING dvTuner,"'+tvpg',$0D"
		CASE TUNER_DN:					SEND_STRING dvTuner,"'-tvpg',$0D"
		CASE TUNER_EXIT:        send_string dvTuner,"'0tvpg',$0D"
		CASE TUNER_GUIDE:		send_string dvTuner,"'1tvpg',$0D"

		CASE TUNER_ENTER: 
		{
			if(find_string(cChan,'.',1))
			{
				if(length_string(cChan)>find_string(cChan,'.',1))
				{
					send_string dvTuner,"left_string(cChan,(find_string(cChan,'.',1)-1)),'*',mid_string(cChan,find_string(cChan,'.',1)+1,1),'T'"
				}
				else
				{
					send_string dvTuner,"left_string(cChan,(find_string(cChan,'.',1)-1)),'*0T'"
				}
			}
			else
			{
				send_string dvTuner,"cChan,'*0T'"
			}
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
		parse(data.text)
		//cBuff = "cBuff,data.text"
//		WHILE(LENGTH_STRING(cBuff))
//		{
//			SELECT
//			{
//				ACTIVE(FIND_STRING(cBuff,"$0A",1)&& LENGTH_STRING(cHold)):
//				{
//					nPos=FIND_STRING(cBuff,"$0A",1)
//					cFullStr="cHold,GET_BUFFER_STRING(cBuff,nPos)"
//					Parse(cFullStr)
//					cHold=''
//				}
//				ACTIVE(FIND_STRING(cBuff,"$0A",1)):
//				{
//					nPos=FIND_STRING(cBuff,"$0A",1)
//					cFullStr=GET_BUFFER_STRING(cBuff,nPos)
//					Parse(cFullStr)
//				}
//				ACTIVE(1):
//				{
//					cHold="cHold,cBuff"
//					cBuff=''
//				}
//			}
//		}
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
		on[vdvTuner,button.input.channel]
		SEND_STRING 0,"'my chan1 is ',itoa(button.input.channel)"
	}
	release:
	{
		off[vdvTuner,button.input.channel]
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

