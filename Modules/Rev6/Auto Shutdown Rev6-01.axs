MODULE_NAME='Auto Shutdown Rev6-01'(dev dvTP[],devchan dcShutDown)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   

define_module 'Auto Shutdown Rev6-01' sd1(dvTP_DEV[1],dcShutDown)
*)

#INCLUDE 'HoppSNAPI Rev6-00.axi'

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant  //Buttons

btnShutDown		=	1

btnEnable		=	1
btnShutDownTime	=	2
btnCurrentTime	=	3

btnConfirmShutDown	=	4
btnCancelShutDown	=	5

btnHoursUp		=	11
btnHoursDown	=	12
btnMinutesUp	=	13
btnMinutesDown	=	14
btnAM			=	15
btnPM			=	16



define_constant //Flags

perAM			=	0
perPM			=	1

tmShutDown		=	1
tmCurrent		=	2

define_constant //Timelines

tlCurrentTime	=	1
tlShutDownWarning=	2



(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

structure timestore
{
	sinteger hours
	sinteger minutes
	integer period
	integer enabled
	char	timestring[8]
	char 	viewtimestring[8]
}


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile		long		lTimeTimes[]={1000}
volatile		long		lShutDownWarningTimes[]={60000}

volatile		integer		nActiveTimeSet=tmShutDown

persistent		timestore	timeMain[2]

volatile		char 		cCurrentTime[8]
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

define_function initiate_shutdown()
{
	send_command dvTP,"'^ADB'"
	send_command dvTP,"'@PPN-[popup]Auto Shut Down'"
	
	timeline_create(tlShutDownWarning,lShutDownWarningTimes,length_array(lShutDownWarningTimes),timeline_relative,timeline_once)
}

define_function set_time(tm)
{
	//timeMain[tm].viewtimestring is the string to show the time on the panel

	if(timeMain[tm].hours<10) timeMain[tm].viewtimestring="'0',itoa(timeMain[tm].hours)"
		else timeMain[tm].viewtimestring=itoa(timeMain[tm].hours)
		
	if(timeMain[tm].minutes<10) timeMain[tm].viewtimestring="timeMain[tm].viewtimestring,':0',itoa(timeMain[tm].minutes)"
		else timeMain[tm].viewtimestring="timeMain[tm].viewtimestring,':',itoa(timeMain[tm].minutes)"
	
	switch(timeMain[tm].period)
	{
		case perAM: timeMain[tm].viewtimestring="timeMain[tm].viewtimestring,' AM'"
		case perPM: timeMain[tm].viewtimestring="timeMain[tm].viewtimestring,' PM'"
	}
	
	//timeMain[tm].timestring is the HH:MM:SS version we actually use to shut down
	
	switch(timeMain[tm].period)
	{
		case perAM: 
		{
			if(timeMain[tm].hours<10) timeMain[tm].timestring="'0',itoa(timeMain[tm].hours)"
				else timeMain[tm].timestring=itoa(timeMain[tm].hours)
			if(timeMain[tm].minutes<10) timeMain[tm].timestring="timeMain[tm].timestring,':0',itoa(timeMain[tm].minutes),':00'"
				else timeMain[tm].timestring="timeMain[tm].timestring,':',itoa(timeMain[tm].minutes),':00'"
		}
		case perPM:
		{
			timeMain[tm].timestring="itoa(timeMain[tm].hours+12)"
			if(timeMain[tm].minutes<10) timeMain[tm].timestring="timeMain[tm].timestring,':0',itoa(timeMain[tm].minutes),':00'"
				else timeMain[tm].timestring="timeMain[tm].timestring,':',itoa(timeMain[tm].minutes),':00'"
		}		
	}	
	
	show_time(tm)
}

define_function show_time(tm)
{
	switch(tm)
	{
		case tmShutDown: send_command dvTP,"'^TXT-',itoa(btnShutDownTime),',0,Shutdown Time: ',timeMain[tmShutDown].viewtimestring"
		case tmCurrent: send_command dvTP,"'^TXT-',itoa(btnCurrentTime),',0,Current Time: ',timeMain[tmCurrent].viewtimestring"
//		case tmCurrent: 
//		{
//			if(time_to_hour(time)>12) cCurrentTime=itoa(time_to_hour(time)-12)
//				else cCurrentTime=itoa(time_to_hour(time))
//				
//			if(atoi(cCurrentTime)<10) cCurrentTime="'0',cCurrentTime"
//			
//			if(time_to_minute(time)<10) cCurrentTime="cCurrentTime,':0',itoa(time_to_minute(time))"
//				else cCurrentTime="cCurrentTime,':',itoa(time_to_minute(time))"
//			
//			if(time_to_hour(time)>12) cCurrentTime="cCurrentTime,' PM'"
//				else cCurrentTime="cCurrentTime,' AM'"
//				
//			send_command dvTP,"'^TXT-',itoa(btnCurrentTime),',0,Current Time: ',cCurrentTime"
//		}
	}
}

define_function get_current_time()
{
	if(time_to_hour(time)>12) timeMain[tmCurrent].hours=time_to_hour(time)-12
		else timeMain[tmCurrent].hours=time_to_hour(time)

	timeMain[tmCurrent].minutes=time_to_minute(time)
	
	if(time_to_hour(time)>12) timeMain[tmCurrent].period=perPM
		else timeMain[tmCurrent].period=perAM
		
	set_time(tmCurrent)
}

define_function set_current_time()
{
	send_command 0,"'CLOCK ',date,' ',timeMain[tmCurrent].timestring"
}

define_function write_shutdown()			//This function is called in the main program to pass the WIN structure to the Jupiter module
{
	local_var	long lPos
	local_var	slong slReturn
	local_var	slong slFile
	local_var	slong slResult
	local_var	char sXMLString[50000]
	appendToFile('log.txt','write_shutdown() runs')
	// Convert To XML
	lPos = 1
	slReturn = variable_to_string(timeMain[tmShutDown], sXMLString, lPos)
	// Save Structure To Disk – XML
	slFile = file_open('XMLShutDownEncode.xml', 2)
	slReturn = file_write(slFile, sXMLString, length_string(sXMLString))
	appendToFile('log.txt',"'write_shutdown() file_write return is ',itoa(slReturn)")
	slReturn = file_close(slFile)	
	appendToFile('log.txt',"'write_shutdown() file_close return is ',itoa(slReturn)")
}

define_function read_shutdown()
{
	local_var	long lPos
	local_var	slong slReturn
	local_var	slong slFile
	local_var	slong slResult
	local_var	char sXMLString[50000]
	appendToFile('log.txt','read_shutdown() runs')
	// Read XML File
	slFile = FILE_OPEN('XMLShutDownEncode.xml',1)
	slResult = FILE_READ(slFile, sXMLString, MAX_LENGTH_STRING(sXMLString))
	appendToFile('log.txt',"'read_shutdown() file_read result is ',itoa(slResult)")
	slResult = FILE_CLOSE (slFile)
	appendToFile('log.txt',"'read_shutdown() file_close result is ',itoa(slResult)")
	// Convert To XML
	lPos = 1
	slReturn = STRING_TO_VARIABLE(timeMain[tmShutDown], sXMLString, lPos)	
	appendToFile('log.txt',"'read_shutdown() string_to_variable return is ',itoa(slReturn)")
	log_shutdown_values()
	
}

define_function appendToFile (CHAR cFileName[],CHAR cLogString[])
{
	STACK_VAR SLONG slFileHandle     // stores the tag that represents the file (or and error code)
	LOCAL_VAR SLONG slResult         // stores the number of bytes written (or an error code)

	slFileHandle = FILE_OPEN(cFileName,FILE_RW_APPEND) // OPEN OLD FILE (OR CREATE NEW ONE)    

	IF(slFileHandle>0)               // A POSITIVE NUMBER IS RETURNED IF SUCCESSFUL
	{
		slResult = FILE_WRITE_LINE(slFileHandle,cLogString,LENGTH_STRING(cLogString)) // WRITE THE NEW INFO
		FILE_CLOSE(slFileHandle)   // CLOSE THE LOG FILE
	}
	ELSE
	{
		SEND_STRING 0,"'FILE OPEN ERROR:',ITOA(slFileHandle)" // IF THE LOG FILE COULD NOT BE CREATED
	}
}

define_function log_shutdown_values()
{
	appendToFile('log.txt',"'Current Shutdown Values'")
	appendToFile('log.txt',"'hours = ',itoa(timeMain[tmShutDown].hours)")
	appendToFile('log.txt',"'minutes = ',itoa(timeMain[tmShutDown].minutes)")
	appendToFile('log.txt',"'period = ',itoa(timeMain[tmShutDown].period)")
	appendToFile('log.txt',"'enabled = ',itoa(timeMain[tmShutDown].enabled)")
	appendToFile('log.txt',"'timestring = ',timeMain[tmShutDown].timestring")
	appendToFile('log.txt',"'viewtimestring = ',timeMain[tmShutDown].viewtimestring")
}

define_function tp_fb()
{
	[dvTP,btnAM]=timeMain[nActiveTimeSet].period=perAM
	[dvTP,btnPM]=timeMain[nActiveTimeSet].period=perPM
	
	[dvTP,btnEnable]=timeMain[tmShutDown].enabled
	
	[dvTP,btnShutDownTime]=nActiveTimeSet=tmShutDown
	[dvTP,btnCurrentTime]=nActiveTimeSet=tmCurrent

	SYSTEM_CALL 'NEWDST'
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

timeline_create(tlCurrentTime,lTimeTimes,length_array(lTimeTimes),timeline_relative,timeline_repeat)

appendToFile('log.txt','Module Define_Start Runs')

wait 100 
{
	appendToFile('log.txt','read_shutdown() called')
	read_shutdown()
	appendToFile('log.txt','set_time(tmShutDown) called')
	set_time(tmShutDown)
}

get_current_time()

#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvTP]
{
	online:
	{
		get_current_time()
		show_time(tmCurrent)
		show_time(tmShutDown)
	}
}

button_event[dvTP,btnShutDownTime]
button_event[dvTP,btnCurrentTime]
{
	push:
	{
		switch(button.input.channel)
		{
			case btnShutDownTime: nActiveTimeSet=tmShutDown
			case btnCurrentTime: nActiveTimeSet=tmCurrent
		}
	}
}

button_event[dvTP,btnHoursUp]
button_event[dvTP,btnHoursDown]
{
	push:
	{
		switch(button.input.channel)
		{
			case btnHoursUp:
			{
				if(timeMain[nActiveTimeSet].hours<12) timeMain[nActiveTimeSet].hours++
				else timeMain[nActiveTimeSet].hours=1
			}
			case btnHoursDown:
			{
				if(timeMain[nActiveTimeSet].hours>1) timeMain[nActiveTimeSet].hours--
				else timeMain[nActiveTimeSet].hours=12
			}
		}
		set_time(nActiveTimeSet)
	}
	hold[3,repeat]:
	{
		switch(button.input.channel)
		{
			case btnHoursUp:
			{
				if(timeMain[nActiveTimeSet].hours<12) timeMain[nActiveTimeSet].hours++
				else timeMain[nActiveTimeSet].hours=1
			}
			case btnHoursDown:
			{
				if(timeMain[nActiveTimeSet].hours>1) timeMain[nActiveTimeSet].hours--
				else timeMain[nActiveTimeSet].hours=12
			}
		}
		set_time(nActiveTimeSet)		
	}
	release:
	{
		switch(nActiveTimeSet)
		{
			case tmCurrent: set_current_time()
			case tmShutDown: write_shutdown()
		}
	}
}

button_event[dvTP,btnMinutesUp]
button_event[dvTP,btnMinutesDown]
{
	push:
	{
		to[button.input]
		switch(button.input.channel)
		{
			case btnMinutesUp:
			{
				if(timeMain[nActiveTimeSet].minutes<59) timeMain[nActiveTimeSet].minutes++
				else timeMain[nActiveTimeSet].minutes=0
			}
			case btnMinutesDown:
			{
				if(timeMain[nActiveTimeSet].minutes>0) timeMain[nActiveTimeSet].minutes--
				else timeMain[nActiveTimeSet].minutes=59
			}
		}
		set_time(nActiveTimeSet)
	}
	hold[3,repeat]:
	{
		switch(button.input.channel)
		{
			case btnMinutesUp:
			{
				if(timeMain[nActiveTimeSet].minutes<59) timeMain[nActiveTimeSet].minutes++
				else timeMain[nActiveTimeSet].minutes=0
			}
			case btnMinutesDown:
			{
				if(timeMain[nActiveTimeSet].minutes>0) timeMain[nActiveTimeSet].minutes--
				else timeMain[nActiveTimeSet].minutes=59
			}
		}
		set_time(nActiveTimeSet)
	}
	release:
	{
		switch(nActiveTimeSet)
		{
			case tmCurrent: set_current_time()
			case tmShutDown: write_shutdown()
		}
	}
}

button_event[dvTP,btnAM]
button_event[dvTP,btnPM]
{
	push:
	{
		switch(button.input.channel)
		{
			case btnAM: timeMain[nActiveTimeSet].period=perAM
			case btnPM: timeMain[nActiveTimeSet].period=perPM
		}
		set_time(nActiveTimeSet)
		switch(nActiveTimeSet)
		{
			case tmCurrent: set_current_time()
			case tmShutDown: write_shutdown()
		}
	}
}

button_event[dvTP,btnEnable]
{
	push:
	{
		timeMain[tmShutDown].enabled=!timeMain[tmShutDown].enabled
		write_shutdown()
	}
}

button_event[dvTP,btnConfirmShutDown]
button_event[dvTP,btnCancelShutDown]
{
	push:
	{
		timeline_kill(tlShutDownWarning)
		switch(button.input.channel)
		{
			case btnConfirmShutDown: do_push(dcShutDown.device,dcShutDown.channel)
			case btnCancelShutDown: send_command dvTP,"'@PPF-[popup]Auto Shut Down'"
		}
	}
}

timeline_event[tlCurrentTime]
{
	if (time_to_second(TIME) == 0)
	{
		get_current_time()
		show_time(tmCurrent)
		if(timeMain[tmShutDown].enabled)//Check to See if you should Shut Down
		{
			if(time_to_hour(time)=time_to_hour(timeMain[tmShutDown].timestring) and time_to_minute(time)=time_to_minute(timeMain[tmShutDown].timestring))
			{
				initiate_shutdown()
			}
		}
	}
}

timeline_event[tlShutDownWarning]
{
	do_push(dcShutDown.device,dcShutDown.channel)
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM




(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)


