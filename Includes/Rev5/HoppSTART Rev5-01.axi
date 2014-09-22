PROGRAM_NAME='HoppSTART Rev5-01'
(***********************************************************)
(*  FILE CREATED ON: 08/08/2008  AT: 15:53:26              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/06/2011  AT: 18:17:06        *)
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

FeedbackTL		=	3000
MixQueryTL		=	3001
IPReconnectTL	=	3002

define_variable //Mixer Variables

volatile		integer		nNumVolBars
non_volatile	long		lMixQueryTimes[]={100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}

define_variable //IP Varibales

non_volatile	long		lReconnectTime[]={30000}

define_variable //Feedback Variables

volatile		integer		nSkipFeedback
non_volatile	long		lFeedbackTime[]={100}

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

define_function query_mixer()
{
	timeline_create(MixQueryTL,lMixQueryTimes,nNumVolBars,timeline_relative,timeline_once)
}

define_function openclient(integer nVal)
{
	ip_client_open(ip[nVal].dvIP.PORT,ip[nVal].IPAddress,ip[nVal].port,1)
}

define_function closeclient(integer nVal)
{
	ip_client_close(ip[nVal].dvIP.PORT)
}

define_start

timeline_create(FeedbackTL,lFeedbackTime,1,timeline_relative,timeline_repeat)

for(x=1;x<=30;x++)
{
	if(vol[x].chan>0 or length_string(vol[x].name)>0) nNumVolBars++
}

#IF_DEFINED dvIPClient
for(x=1;x<=100;x++) 
{
	if(length_string(ip[x].ipaddress)>0) 
	{	
		dvIPClient[x]=ip[x].dvIP
		openclient(x)			//if IP address is defined, open client
	}
}
#END_IF

timeline_create(IPReconnectTL,lReconnectTime,1,timeline_relative,timeline_repeat)

//Popup Kill and Revert to Title Page on start.  Only runs if dvTP is defined in mainline or HoppDEV
//Title page must be named Title Page
//If you want this to not run, simply define a constant hpNoStartPage as any value in your mainline, and it won't happen.
#IF_DEFINED dvTP 
#IF_NOT_DEFINED hpNoStartPage
wait 100
{
	send_command dvTP,"'@PPX'"
	send_command dvTP,"'PAGE-Title Page'"
}
#END_IF
#END_IF



//write_mixer()
//write_camera()
//write_window_wall()

define_event //IP Online/Offline Events
#IF_DEFINED dvIPClient
data_event[dvIPClient]
{
	online:
	{
		on[IP[get_last(dvIPClient)].status]
	}
	offline:
	{
		off[IP[get_last(dvIPClient)].status]
	}
}
#END_IF

define_event //Baudrate Events
//Online Events for the 8 most common baud rates.  Declare a device array of dv9600N in your define_variable section
//and the online event for that 9600,N,8,1 will automatically fire.

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

define_event //Screen

#IF_DEFINED btnScreenUp
button_event[dvTP,btnScreenUp]
{
	push:
	{
		pulse [dstMain[get_last(btnScreenUp)].screenup]
	}
}
#END_IF

#IF_DEFINED btnScreenDown
button_event[dvTP,btnScreenDown]
{
	push:
	{
		pulse [dstMain[get_last(btnScreenDown)].screendown]
	}
}
#END_IF
//Lift buttons.  If you define btnLiftUp, you must define rlyLiftUp.  If you do so, whatever you define as btnLiftUp
//will automatically fire the Lift up Relay, without you doing it in mainline.


define_event //Lift

#IF_DEFINED btnLiftUp
button_event[dvTP,btnLiftUp]
{
	push:
	{
		pulse [dstMain[get_last(btnLiftUp)].liftup]
	}
}
#END_IF

#IF_DEFINED btnLiftDown
button_event[dvTP,btnLiftDown]
{
	push:
	{
		pulse [dstMain[get_last(btnLiftDown)].liftdown]
	}
}
#END_IF

define_event //Timeline Events

timeline_event[MixQueryTL]
{
	if(vol[timeline.sequence].chan>0 or length_string(vol[timeline.sequence].name)>0) pulse[vdvMXR[timeline.sequence],MIX_QUERY]
}

timeline_event[IPReconnectTL]
{
	for(x=1;x<=100;x++)
	{
		if(!ip[x].status && length_string(ip[x].ipaddress)>0)
		{
			closeclient(x)
			openclient(x)
		}
	}
}

timeline_event[FeedbackTL]
{
	if (!nSkipFeedback) tp_fb()
}