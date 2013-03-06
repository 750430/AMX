PROGRAM_NAME='HoppSTART Rev4-01'
(***********************************************************)
(*  FILE CREATED ON: 08/08/2008  AT: 15:53:26              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/23/2008  AT: 16:18:14        *)
(***********************************************************)


//This file requires that you have defined HoppSTRUCT earlier in the mainline
//You cannot call query_mixer until after your mixer has performed the call READ_MIXER.
//This means you cannot call query_mixer in an online event unless you use a wait, such as
//data_event[dvBiamp]
//{
//	online:
//	{
//		wait 100 query_mixer(10)
//	}
//}


define_constant

MixQueryTL	=	3001
IPReconnectTL	=	3002

define_variable

non_volatile	long		lMixQueryTimes[]={100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}
non_volatile	long		lReconnectTime[]={30000}

volatile		integer		nIPConnected[100]

//dev dvIPClient[100]

define_function integer calcchecksum(char cMsg[])
{
	stack_var integer nLoop
	stack_var integer nCheckSum
	
	off[nCheckSum]
	for (nLoop=1;nLoop<=length_string(cMsg);nLoop++)
	{
		nCheckSum=((nCheckSum+cMsg[nLoop])& $FF)
	}
	return nCheckSum
}

define_function query_mixer(integer i)
{
	timeline_create(MixQueryTL,lMixQueryTimes,i,timeline_relative,timeline_once)
}
define_function openclient(integer nVal)
{
	ip_client_open(ip[nVal].dvIP.PORT,ip[nVal].cIPAddress,ip[nVal].nPort,1)
}

define_function closeclient(integer nVal)
{
	ip_client_close(ip[nVal].dvIP.PORT)
}

define_start

wait 50
{
	for(x=1;x<=100;x++) 
	{
		if(ip[x].nIPType>0) 
		{	
			//dvIPClient[x]=ip[x].dvIP
			openclient(x)			//if IP address is defined, open client
		}
	}
}
timeline_create(IPReconnectTL,lReconnectTime,1,timeline_relative,timeline_repeat)

//Popup Kill and Revert to Title Page on start.  Only runs if dvTP is defined in mainline or HoppDEV
//Title page must be named Title Page
#IF_DEFINED dvTP 
wait 100
{
	send_command dvTP,"'@PPX'"
	send_command dvTP,"'PAGE-Title Page'"
}
#END_IF

call 'WRITE_MIXER'
call 'WRITE_CAMERA'
call 'WRITE_JUPITER'

define_event //Baudrate Events
//Online Events for the 8 most common baud rates.  Declare a device array of dv9600N in your define_variable section
//and the online event for that 9600,N,8,1 will automatically fire.

data_event[dvIPClient]
{
	online:
	{
		send_string 0,"'dvIPClient ',itoa(get_last(dvIPClient)),' Online'"
		on[nIPConnected[get_last(dvIPClient)]]
	}
	offline:
	{
		send_string 0,"'dvIPClient ',itoa(get_last(dvIPClient)),' Offline'"
		off[nIPConnected[get_last(dvIPClient)]]
	}
}

#IF_DEFINED dv9600N data_event[dv9600N]
{
	online:
	{
		send_command data.device,"'SET BAUD 9600,N,8,1 485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSOFF'"
	}
}
#END_IF

#IF_DEFINED dv9600O data_event[dv9600O]
{
	online:
	{
		send_command data.device,"'SET BAUD 9600,O,8,1 485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSOFF'"
	}
}
#END_IF

#IF_DEFINED dv19200N data_event[dv19200N]
{
	online:
	{
		send_command data.device,"'SET BAUD 19200,N,8,1 485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSOFF'"
	}
}
#END_IF

#IF_DEFINED dv19200O data_event[dv19200O]
{
	online:
	{
		send_command data.device,"'SET BAUD 19200,O,8,1 485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSOFF'"
	}
}
#END_IF

#IF_DEFINED dv38400N data_event[dv38400N]
{
	online:
	{
		send_command data.device,"'SET BAUD 38400,N,8,1 485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSOFF'"
	}
}
#END_IF

#IF_DEFINED dv38400O data_event[dv38400O]
{
	online:
	{
		send_command data.device,"'SET BAUD 38400,O,8,1 485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSOFF'"
	}
}
#END_IF

#IF_DEFINED dv57600N data_event[dv57600N]
{
	online:
	{
		send_command data.device,"'SET BAUD 57600,N,8,1 485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSOFF'"
	}
}
#END_IF

#IF_DEFINED dv57600O data_event[dv57600O]
{
	online:
	{
		send_command data.device,"'SET BAUD 57600,O,8,1 485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSOFF'"
	}
}
#END_IF

#IF_DEFINED dv115200N data_event[dv115200N]
{
	online:
	{
		send_command data.device,"'SET BAUD 115200,N,8,1 485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSOFF'"
	}
}
#END_IF

#IF_DEFINED dv115200O data_event[dv115200O]
{
	online:
	{
		send_command data.device,"'SET BAUD 115200,O,8,1 485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSOFF'"
	}
}
#END_IF

//Screen buttons.  If you define btnScreenUp, you must define rlyScreenUp.  If you do so, whatever you define as btnScreenUp
//will automatically fire the Screen up Relay, without you doing it in mainline.
#IF_DEFINED btnScreenUp
define_event //Screen
button_event[dvTP,btnScreenUp]
button_event[dvTP,btnScreenDown]
{
	push:
	{
		to[button.input]
		switch(button.input.channel)
		{
			case btnScreenUp:pulse[dvRelays,rlyScreenUp]
			case btnScreenDown:pulse[dvRelays,rlyScreenDown]
		}
	}
}
#END_IF

//Lift buttons.  If you define btnLiftUp, you must define rlyLiftUp.  If you do so, whatever you define as btnLiftUp
//will automatically fire the Lift up Relay, without you doing it in mainline.
#IF_DEFINED btnLiftUp 
define_event //Lift
button_event[dvTP,btnLiftUp]
button_event[dvTP,btnLiftDown]
{
	push:
	{
		to[button.input]
		switch(button.input.channel)
		{
			case btnLiftUp:pulse[dvRelays,rlyLiftUp]
			case btnLiftDown:pulse[dvRelays,rlyLiftDown]
		}
	}
}
#END_IF

define_event //Timeline Events

timeline_event[MixQueryTL]
{
	pulse[vdvMXR[timeline.sequence],MIX_QUERY]
}

timeline_event[IPReconnectTL]
{
	for(x=1;x<=100;x++)
	{
		if(!(nIPConnected[x])&& ip[x].nIPType>0)
		{
			closeclient(x)
			openclient(x)
		}
	}
}