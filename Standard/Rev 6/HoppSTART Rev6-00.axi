PROGRAM_NAME='HoppSTART Rev6-00'
(***********************************************************)
(*  FILE CREATED ON: 08/08/2008  AT: 15:53:26              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/22/2011  AT: 10:34:33        *)
(***********************************************************)

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //Timelines

//tlFeedback		=	3000
tlMixQuery		=	3001
tlIPReconnect	=	3002
tlIPPoll		=	3003	//Timeline to slowly query Extron devices and keep them connected

define_constant //IP

NumIPDevices				=	30 	//This constant sets the number of IP Devices in the system and is used to create appropriately sized arrays

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable //Mix Query Variables

volatile		integer		nMaxVolBars
non_volatile	long		lMixQueryTimes[90]

define_variable //IP Variables

volatile		integer		nNumIPDevices=0
non_volatile	long		lReconnectTime[]={30000}
non_volatile	long		lPollTL[]={300000}
non_volatile	char		cBiampBuffer[255]
volatile		integer		nShowIPFeedback


(***********************************************************)
(*                GENERAL FUNCTIONS GO BELOW               *)
(***********************************************************)

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

define_function integer calcchecksumor(char cMsg[])
{
	stack_var integer nLoop
	stack_var integer nCheckSum
	
	off[nCheckSum]
	for (nLoop=1;nLoop<=length_string(cMsg);nLoop++)
	{
		nCheckSum=((nCheckSum+cMsg[nLoop])| $FF)
	}
	return nCheckSum
}

define_function enable_button(dev tp[],integer btn)
{
	send_command tp,"'^BMF-',itoa(btn),',0,%OP255%EN1'"
}

define_function disable_button(dev tp[],integer btn)
{
	send_command tp,"'^BMF-',itoa(btn),',0,%OP80%EN0'"
}

define_function query_mixer()
{
	nMaxVolBars=0
	for(x=1;x<=max_length_array(vol);x++)
	{
		if(length_string(vol[x].chan)>0 or length_string(vol[x].name)>0 or length_string(vol[x].instidTag)) nMaxVolBars++
	}
	
	
	if(!timeline_active(tlMixQuery)) 
	{
		timeline_create(tlMixQuery,lMixQueryTimes,nMaxVolBars,timeline_relative,timeline_once)
	}
}

define_function openclient(integer nVal)
{
	ip_client_open(ip[nVal].dvIP.PORT,ip[nVal].IPAddress,ip[nVal].port,1)
}

define_function closeclient(integer nVal)
{
	ip_client_close(ip[nVal].dvIP.PORT)
}

define_function reconnect_client(integer nVal)
{
	closeclient(nVal)
	wait 10
	openclient(nVal)
}

#IF_DEFINED dvBiamp
define_function biamp_recall_preset(char cPreset[])
{
	send_string dvBiamp,"'RECALL 0 PRESET ',cPreset,10"
	wait 5
	query_mixer()
}
#END_IF

(***********************************************************)
(*                      STARTUP GOES BELOW                 *)
(***********************************************************)

define_start //Mix Query Startup

for(x=1;x<=90;x++) lMixQueryTimes[x]=200

define_start //IP Connection on startup

#IF_DEFINED dvIPClient
wait 100
{
	for(x=1;x<=NumIPDevices;x++) 
	{
		if(length_string(ip[x].ipaddress)>0) 
		{	
			//dvIPClient[x]=ip[x].dvIP
			openclient(x)			//if IP address is defined, open client
		}
	}
}

timeline_create(tlIPReconnect,lReconnectTime,1,timeline_relative,timeline_repeat)
timeline_create(tlIPPoll,lPollTL,length_array(lPollTL),timeline_relative,timeline_repeat)

#END_IF

define_start //Actual Startup

//Popup Kill and Revert to Title Page on start.
wait 100
{
	send_command dvTP,"'@PPX'"
	send_command dvTP,"'PAGE-Title Page'"
}

define_event //IP Online/Offline Events
#IF_DEFINED dvIPClient
data_event[dvIPClient]
{
	online:
	{
		on[IP[get_last(dvIPClient)].status]
		if(ip[get_last(dvIPClient)].reconnect)
		{
			off[ip[get_last(dvIPClient)].reconnect]
			IP[get_last(dvIPClient)].connectcount++
		}
	}
	offline:
	{
		off[IP[get_last(dvIPClient)].status]
		on[ip[get_last(dvIPClient)].reconnect]
	}
	string:
	{
		if(nShowIPFeedback) 
		{
			select
			{
				active(ip[get_last(dvIPClient)].dev_type=BIAMP_TYPE):
				{
					cBiampBuffer="cBiampBuffer,data.text"
					if(find_string(cBiampBuffer,"$0D,$0A",1))
					{
						send_string 0,"'dvIPClient[',itoa(get_last(dvIPClient)),'] String: ',remove_string(cBiampBuffer,"$0D,$0A",1)"
					}
					if(length_string(cBiampBuffer)>250) cBiampBuffer=''
				}
				active(1): send_string 0,"'dvIPClient[',itoa(get_last(dvIPClient)),'] String: ',data.text"
			}
		}
	}
	onerror:
	{
		switch(data.number)
		{
			case 0: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Success!'"
			case 2: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] General Failure (Out of Memory) (IP_CLIENT_OPEN/IP_SERVER_OPEN)'"
			case 4: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Unknown Host (IP_CLIENT_OPEN)'"
			case 6: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Connection Refused (IP_CLIENT_OPEN)'"
			case 7: 
			{
				send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Connection Timed Out (IP_CLIENT_OPEN)'"
				reconnect_client(get_last(dvIPClient))
			}
			case 8: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Unknown Connection Error (IP_CLIENT_OPEN)'"
			case 9: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Already Closed (IP_CLIENT_CLOSE/IP_SERVER_CLOSE)'"
			case 10: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Binding Error (IP_SERVER_OPEN)'"
			case 11: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Listening Error (IP_SERVER_OPEN)'"
			case 13: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Send to Socket Unknown. Some other error (undefined) occurred in trying to do the sendto'"
			case 14: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Local Port Already Used (IP_CLIENT_OPEN/IP_SERVER_OPEN)'"
			case 15: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] UDP Socket Already Listening (IP_SERVER_OPEN)'"
			case 16: send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Too Many Open Sockets (IP_CLIENT_OPEN/IP_SERVER_OPEN)'"
			case 17: 
			{
				send_string 0,"'IP[',itoa(get_last(dvIPClient)),'] Local Port Not Open'"
				reconnect_client(get_last(dvIPClient))
			}
		}
	}
}
#END_IF

define_event //Baudrate Events
//Online Events for the 15 most common baud rates.  Declare a device array of dv9600N in your define_variable section
//and the the baud rate for devices in that array will be set in the online event.

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

#IF_DEFINED dv9600E data_event[dv9600E]
{
	online:
	{
		send_command data.device,"'SET BAUD 9600,E,8,1 485 DISABLE'"
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

#IF_DEFINED dv19200E data_event[dv19200E]
{
	online:
	{
		send_command data.device,"'SET BAUD 19200,E,8,1 485 DISABLE'"
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

#IF_DEFINED dv38400E data_event[dv38400E]
{
	online:
	{
		send_command data.device,"'SET BAUD 38400,E,8,1 485 DISABLE'"
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

#IF_DEFINED dv57600E data_event[dv57600E]
{
	online:
	{
		send_command data.device,"'SET BAUD 57600,E,8,1 485 DISABLE'"
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


#IF_DEFINED dv115200E data_event[dv115200E]
{
	online:
	{
		send_command data.device,"'SET BAUD 115200,E,8,1 485 DISABLE'"
		send_command data.device,"'RXON'"
		send_command data.device,"'HSOFF'"
	}
}
#END_IF

//Screen buttons.  If you define btnScreenUp, you must define rlyScreenUp.  If you do so, whatever you define as btnScreenUp
//will automatically fire the Screen up Relay, without you doing it in mainline.

define_event //Screen and Lift


//button_event[vdvTP_DISP,VD_SCREEN_UP]
//button_event[vdvTP_DISP,VD_SCREEN_DOWN]
//{
//	push:
//	{
//		to[button.input]
//		switch(button.input.channel)
//		{
//			case VD_SCREEN_UP: pulse [dstMain[get_last(vdvTP_DISP)].screenup]
//			case VD_SCREEN_DOWN: pulse [dstMain[get_last(vdvTP_DISP)].screendown]
//		}
//	}
//}
//
//button_event[vdvTP_DISP,VD_LIFT_UP]
//button_event[vdvTP_DISP,VD_LIFT_DOWN]
//{
//	push:
//	{
//		to[button.input]
//		switch(button.input.channel)
//		{
//			case VD_LIFT_UP: pulse [dstMain[get_last(vdvTP_DISP)].liftup]
//			case VD_LIFT_DOWN: pulse [dstMain[get_last(vdvTP_DISP)].liftdown]
//		}
//	}
//}

define_event //Timeline Events

timeline_event[tlMixQuery]
{
	if(vol[timeline.sequence].chan>0 or length_string(vol[timeline.sequence].name)>0 or length_string(vol[timeline.sequence].instIDtag)>0) pulse[vdvMixer[timeline.sequence],MIX_QUERY]
}


#IF_DEFINED dvIPClient
timeline_event[tlIPReconnect]
{
	for(x=1;x<=NumIPDevices;x++)
	{
		if(!ip[x].status and length_string(ip[x].ipaddress)>0)
		{
			reconnect_client(x)
		}
	}
}


timeline_event[tlIPPoll]
{
	for(x=1;x<=nNumIPDevices;x++)
	{
		if(ip[x].dev_type=EXTRON_TYPE) send_string dvIPClient[x],"'Q'"	
		if(ip[x].dev_type=CLEARONE_TYPE) send_string dvIPClient[x],"'VER'"	
	}
}

#END_IF		


DEFINE_PROGRAM

