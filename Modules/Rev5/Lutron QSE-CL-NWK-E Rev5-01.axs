MODULE_NAME='Lutron QSE-CL-NWK-E Rev5-01'(DEV dvTP, dev vdvLights, DEV dvLights, CHAR cAddr[])
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/11/2012  AT: 10:17:56        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
//SET BAUD 9600,N,8,1 485 DISABLE
//define_module 'Lutron QSE-CL-NWK-E Rev5-00' LIGHTS1(vdvTP_LIGHT1,dvLights,cLightingAddr)
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
INTEGER btnScenes[] = {1,2,3,4,5,6,7,8,9}
INTEGER btn_AllUp = 10
INTEGER btn_AllDn = 11
INTEGER nScene
CHAR cResp[100]

char cBuffer[100]

LONG lFBArray[] = {100}						//.1 seconds
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
	if(find_string(cCompStr,"'login'",1)) send_string dvLights,"'nwk',$0D,$0A"	
	if(find_string(cCompStr,"'141,7,0'",1)) nScene = 0
	if(find_string(cCompStr,"'141,7,1'",1)) nScene = 1
	if(find_string(cCompStr,"'141,7,2'",1)) nScene = 2
	if(find_string(cCompStr,"'141,7,3'",1)) nScene = 3
	if(find_string(cCompStr,"'141,7,4'",1)) nScene = 4
	if(find_string(cCompStr,"'141,7,5'",1)) nScene = 5
	if(find_string(cCompStr,"'141,7,6'",1)) nScene = 6
	if(find_string(cCompStr,"'141,7,7'",1)) nScene = 7
	if(find_string(cCompStr,"'141,7,8'",1)) nScene = 8	
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START
//create_buffer dvLights,cBuffer
TIMELINE_CREATE(lFB,lFBArray,1,TIMELINE_RELATIVE,TIMELINE_REPEAT)
(***********************************************************)
(*                THE EVENTS GOES BELOW                    *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[dvLights]
{
	ONLINE:
	{
		send_string dvLights,"'?INTEGRATIONID,1,',cAddr,',',$0D,$0A"
	}
	STRING:
	{
		LOCAL_VAR CHAR cHold[100]
		LOCAL_VAR CHAR cBuff[255]
		LOCAL_VAR CHAR cFullStr[100]
		STACK_VAR INTEGER nPos
		
		parse(data.text)
		
//		cBuff = "cBuff,data.text"
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


BUTTON_EVENT[dvTP, btnScenes]//call scenes
{
	PUSH:
	{
		TO[button.input]
		pulse[vdvLights,button.input.channel]
	}
	HOLD[10]:
	{
		send_command button.input.device,"'@AKB-;Type Something'" //Pop up the keypad so the user can input a speed dial number
	}
}

channel_event[vdvLights,0]
{
	on:
	{
		SELECT
		{
			ACTIVE(channel.channel=9):
			{
				SEND_STRING dvlights,"'#DEVICE,0x',cAddr,',141,7,0',$0D" 
			}
			ACTIVE(1):  
			{
				SEND_STRING dvlights,"'#DEVICE,0x0',cAddr,',141,7,',ITOA(channel.channel),$0D"
			}
		}
    }	
}

TIMELINE_EVENT[lFB]
{
	[dvTP, btnScenes[1]] = (nScene = 1)
	[dvTP, btnScenes[2]] = (nScene = 2)
	[dvTP, btnScenes[3]] = (nScene = 3)
	[dvTP, btnScenes[4]] = (nScene = 4)
	[dvTP, btnScenes[5]] = (nScene = 5)
	[dvTP, btnScenes[6]] = (nScene = 6)
	[dvTP, btnScenes[7]] = (nScene = 7)
	[dvTP, btnScenes[8]] = (nScene = 8)
	[dvTP, btnScenes[9]] = (nScene = 0)
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


