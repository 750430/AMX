PROGRAM_NAME='HoppCOMM Rev5-00'
(***********************************************************)
(*  FILE CREATED ON: 08/08/2008  AT: 15:53:26              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/22/2011  AT: 10:34:33        *)
(***********************************************************)



define_constant



define_variable

volatile		dev		dvDebug


define_function send_string_to_device(dev dvDev, char cMsg[])
{
	send_string dvDev,"cMsg"
	if (dvDebug=dvDev)
	{
		send_command dvTP_TECH,"'^TXT-1,0,',cMsg"
	}
}


define_start



define_event 

#IF_DEFINED dvIPClient
data_event[dvIPClient]
{
	string:
	{
		if(dvDebug=data.device)
		{
			send_command dvTP_TECH,"'^TXT-2,0,',data.text"
		}		
	}
}
#END_IF

#IF_DEFINED dvSerial
data_event[dvSerial]
{
	string:
	{
		if(dvDebug=data.device)
		{
			send_command dvTP_TECH,"'^TXT-2,0,',data.text"
		}
	}
}
#END_IF

DEFINE_PROGRAM

