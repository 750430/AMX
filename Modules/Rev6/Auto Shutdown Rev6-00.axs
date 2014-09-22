MODULE_NAME='Auto Shutdown Rev6-00'(dev dvTP[],devchan dcShutDown)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:  *)

(***********************************************************)
(*   

define_module 'Auto Shutdown Rev6-00' sd1(dvTP_DEV[1],dcShutDown)
*)

#INCLUDE 'HoppSNAPI Rev6-00.axi'

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

btnShutDown		=	1

btnEnable		=	1
btnTimeLabel	=	2
btnCurrentTime	=	3

btnConfirmShutDown	=	4
btnCancelShutDown	=	5

btnHoursUp		=	11
btnHoursDown	=	12
btnMinutesUp	=	13
btnMinutesDown	=	14
btnAM			=	15
btnPM			=	16

perAM			=	0
perPM			=	1

tlCurrentTime	=	1
tlShutDownWarning=	2


nInteger		=	1
(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

structure shutdown
{
	integer hours
	integer minutes
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


persistent		shutdown	sdShutDownConfig

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
	send_command dvTP,"'ADBEEP'"
	send_command dvTP,"'PAGE-Shut Down Warning'"
	
	timeline_create(tlShutDownWarning,lShutDownWarningTimes,length_array(lShutDownWarningTimes),timeline_relative,timeline_once)
}

define_function set_shutdown_time()
{
	//sdShutDownConfig.viewtimestring is the string to show the time on the panel

	if(sdShutDownConfig.hours<10) sdShutDownConfig.viewtimestring="'0',itoa(sdShutDownConfig.hours)"
		else sdShutDownConfig.viewtimestring=itoa(sdShutDownConfig.hours)
		
	if(sdShutDownConfig.minutes<10) sdShutDownConfig.viewtimestring="sdShutDownConfig.viewtimestring,':0',itoa(sdShutDownConfig.minutes)"
		else sdShutDownConfig.viewtimestring="sdShutDownConfig.viewtimestring,':',itoa(sdShutDownConfig.minutes)"
	
	switch(sdShutDownConfig.period)
	{
		case perAM: sdShutDownConfig.viewtimestring="sdShutDownConfig.viewtimestring,' AM'"
		case perPM: sdShutDownConfig.viewtimestring="sdShutDownConfig.viewtimestring,' PM'"
	}
	
	//sdShutDownConfig.timestring is the HH:MM:SS version we actually use to shut down
	
	switch(sdShutDownConfig.period)
	{
		case perAM: 
		{
			if(sdShutDownConfig.hours<10) sdShutDownConfig.timestring="'0',itoa(sdShutDownConfig.hours)"
				else sdShutDownConfig.timestring=itoa(sdShutDownConfig.hours)
			if(sdShutDownConfig.minutes<10) sdShutDownConfig.timestring="sdShutDownConfig.timestring,':0',itoa(sdShutDownConfig.minutes),':00'"
				else sdShutDownConfig.timestring="sdShutDownConfig.timestring,':',itoa(sdShutDownConfig.minutes),':00'"
		}
		case perPM:
		{
			sdShutDownConfig.timestring="itoa(sdShutDownConfig.hours+12)"
			if(sdShutDownConfig.minutes<10) sdShutDownConfig.timestring="sdShutDownConfig.timestring,':0',itoa(sdShutDownConfig.minutes),':00'"
				else sdShutDownConfig.timestring="sdShutDownConfig.timestring,':',itoa(sdShutDownConfig.minutes),':00'"
		}		
	}	
	
	show_shutdown_time()
}

define_function show_shutdown_time()
{
	send_command dvTP,"'^TXT-',itoa(btnTimeLabel),',0,Shutdown Time: ',sdShutDownConfig.viewtimestring"
}

define_function show_current_time()
{
	
	if(time_to_hour(time)>12) cCurrentTime=itoa(time_to_hour(time)-12)
		else cCurrentTime=itoa(time_to_hour(time))
		
	if(atoi(cCurrentTime)<10) cCurrentTime="'0',cCurrentTime"
	
	if(time_to_minute(time)<10) cCurrentTime="cCurrentTime,':0',itoa(time_to_minute(time))"
		else cCurrentTime="cCurrentTime,':',itoa(time_to_minute(time))"
	
	if(time_to_hour(time)>12) cCurrentTime="cCurrentTime,' PM'"
		else cCurrentTime="cCurrentTime,' AM'"
		
	send_command dvTP,"'^TXT-',itoa(btnCurrentTime),',0,Current Time: ',cCurrentTime"
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
	slReturn = variable_to_string(sdShutDownConfig, sXMLString, lPos)
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
	slReturn = STRING_TO_VARIABLE(sdShutDownConfig, sXMLString, lPos)	
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
	appendToFile('log.txt',"'hours = ',itoa(sdShutDownConfig.hours)")
	appendToFile('log.txt',"'minutes = ',itoa(sdShutDownConfig.minutes)")
	appendToFile('log.txt',"'period = ',itoa(sdShutDownConfig.period)")
	appendToFile('log.txt',"'enabled = ',itoa(sdShutDownConfig.enabled)")
	appendToFile('log.txt',"'timestring = ',sdShutDownConfig.timestring")
	appendToFile('log.txt',"'viewtimestring = ',sdShutDownConfig.viewtimestring")
}

define_function tp_fb()
{
	[dvTP,btnAM]=sdShutDownConfig.period=perAM
	[dvTP,btnPM]=sdShutDownConfig.period=perPM
	
	[dvTP,btnEnable]=sdShutDownConfig.enabled

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
	appendToFile('log.txt','set_shutdown_time() called')
	set_shutdown_time()
}

#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvTP]
{
	online:
	{
		show_current_time()
		show_shutdown_time()
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
				if(sdShutDownConfig.hours<12) sdShutDownConfig.hours++
				else sdShutDownConfig.hours=0
			}
			case btnHoursDown:
			{
				if(sdShutDownConfig.hours>0) sdShutDownConfig.hours--
				else sdShutDownConfig.hours=12
			}
		}
		set_shutdown_time()
	}
	hold[3,repeat]:
	{
		switch(button.input.channel)
		{
			case btnHoursUp:
			{
				if(sdShutDownConfig.hours<12) sdShutDownConfig.hours++
				else sdShutDownConfig.hours=0
			}
			case btnHoursDown:
			{
				if(sdShutDownConfig.hours>0) sdShutDownConfig.hours--
				else sdShutDownConfig.hours=12
			}
		}
		set_shutdown_time()		
	}
	release:
	{
		write_shutdown()
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
				if(sdShutDownConfig.minutes<59) sdShutDownConfig.minutes++
				else sdShutDownConfig.minutes=0
			}
			case btnMinutesDown:
			{
				if(sdShutDownConfig.minutes>0) sdShutDownConfig.minutes--
				else sdShutDownConfig.minutes=59
			}
		}
		set_shutdown_time()
	}
	hold[3,repeat]:
	{
		switch(button.input.channel)
		{
			case btnMinutesUp:
			{
				if(sdShutDownConfig.minutes<59) sdShutDownConfig.minutes++
				else sdShutDownConfig.minutes=0
			}
			case btnMinutesDown:
			{
				if(sdShutDownConfig.minutes>0) sdShutDownConfig.minutes--
				else sdShutDownConfig.minutes=59
			}
		}
		set_shutdown_time()
	}
	release:
	{
		write_shutdown()
	}
}

button_event[dvTP,btnAM]
button_event[dvTP,btnPM]
{
	push:
	{
		switch(button.input.channel)
		{
			case btnAM: sdShutDownConfig.period=perAM
			case btnPM: sdShutDownConfig.period=perPM
		}
		set_shutdown_time()
		write_shutdown()
	}
}

button_event[dvTP,btnEnable]
{
	push:
	{
		sdShutDownConfig.enabled=!sdShutDownConfig.enabled
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
			case btnCancelShutDown: send_command button.input.device,"'PAGE-Main Page'"
		}
	}
}

timeline_event[tlCurrentTime]
{
	if (time_to_second(TIME) == 0)
	{
		show_current_time()
		if(sdShutDownConfig.enabled)//Check to See if you should Shut Down
		{
			if(time_to_hour(time)=time_to_hour(sdShutDownConfig.timestring) and time_to_minute(time)=time_to_minute(sdShutDownConfig.timestring))
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


