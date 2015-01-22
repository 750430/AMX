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
tlIPReconnect	=	3002
tlIPPoll		=	3003	//Timeline to slowly query Extron devices and keep them connected

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable //Mix Query Variables

volatile		integer		nMaxVolBars

define_variable //IP Variables

non_volatile	long		lReconnectTime[]={30000}
non_volatile	long		lPollTL[]={30000}
non_volatile	char		cBiampBuffer[255]
volatile		integer		nShowIPFeedback[100]

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

define_function show_button(dev tp[],integer btn)
{
	send_command tp,"'^SHO-',itoa(btn),',1'"
}

define_function hide_button(dev tp[],integer btn)
{
	send_command tp,"'^SHO-',itoa(btn),',0'"
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
//	wait 5
//	query_mixer()
//JDM Add mIx Query All Here
}
#END_IF

(***********************************************************)
(*                      STARTUP GOES BELOW                 *)
(***********************************************************)

define_start //IP Connection on startup

#IF_DEFINED dvIPClient

wait 100
{
	for(x=1;x<=max_length_array(ip);x++) 
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
		if(nShowIPFeedback[get_last(dvIPClient)]) 
		{
			select
			{
				active(ip[get_last(dvIPClient)].dev_type=BIAMP_TYPE):
				{
					cBiampBuffer="cBiampBuffer,data.text"
					if(find_string(cBiampBuffer,"$0D,$0A",1))
					{
						if(ip[get_last(dvIPClient)].name) send_string 0,"ip[get_last(dvIPClient)].name,' String: ',remove_string(cBiampBuffer,"$0D,$0A",1)"
						else send_string 0,"'dvIPClient[',itoa(get_last(dvIPClient)),'] String: ',remove_string(cBiampBuffer,"$0D,$0A",1)"
					}
					if(length_string(cBiampBuffer)>250) cBiampBuffer=''
				}
				active(1): 
				{
					if(ip[get_last(dvIPClient)].name) send_string 0,"ip[get_last(dvIPClient)].name,' String: ',data.text"
					else send_string 0,"'dvIPClient[',itoa(get_last(dvIPClient)),'] String: ',data.text"
				}
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

define_event //Screen and Lift

button_event[dvTP_DISP[1],VD_SCREEN_UP]
button_event[dvTP_DISP[2],VD_SCREEN_UP]
button_event[dvTP_DISP[3],VD_SCREEN_UP]
button_event[dvTP_DISP[4],VD_SCREEN_UP]
button_event[dvTP_DISP[5],VD_SCREEN_UP]
button_event[dvTP_DISP[6],VD_SCREEN_UP]
button_event[dvTP_DISP[7],VD_SCREEN_UP]
button_event[dvTP_DISP[8],VD_SCREEN_UP]
button_event[dvTP_DISP[9],VD_SCREEN_UP]
button_event[dvTP_DISP[10],VD_SCREEN_UP]
button_event[dvTP_DISP[11],VD_SCREEN_UP]
button_event[dvTP_DISP[12],VD_SCREEN_UP]
button_event[dvTP_DISP[13],VD_SCREEN_UP]
button_event[dvTP_DISP[14],VD_SCREEN_UP]
button_event[dvTP_DISP[15],VD_SCREEN_UP]
button_event[dvTP_DISP[16],VD_SCREEN_UP]
button_event[dvTP_DISP[17],VD_SCREEN_UP]
button_event[dvTP_DISP[18],VD_SCREEN_UP]
button_event[dvTP_DISP[19],VD_SCREEN_UP]
button_event[dvTP_DISP[20],VD_SCREEN_UP]
button_event[dvTP_DISP[1],VD_SCREEN_DOWN]
button_event[dvTP_DISP[2],VD_SCREEN_DOWN]
button_event[dvTP_DISP[3],VD_SCREEN_DOWN]
button_event[dvTP_DISP[4],VD_SCREEN_DOWN]
button_event[dvTP_DISP[5],VD_SCREEN_DOWN]
button_event[dvTP_DISP[6],VD_SCREEN_DOWN]
button_event[dvTP_DISP[7],VD_SCREEN_DOWN]
button_event[dvTP_DISP[8],VD_SCREEN_DOWN]
button_event[dvTP_DISP[9],VD_SCREEN_DOWN]
button_event[dvTP_DISP[10],VD_SCREEN_DOWN]
button_event[dvTP_DISP[11],VD_SCREEN_DOWN]
button_event[dvTP_DISP[12],VD_SCREEN_DOWN]
button_event[dvTP_DISP[13],VD_SCREEN_DOWN]
button_event[dvTP_DISP[14],VD_SCREEN_DOWN]
button_event[dvTP_DISP[15],VD_SCREEN_DOWN]
button_event[dvTP_DISP[16],VD_SCREEN_DOWN]
button_event[dvTP_DISP[17],VD_SCREEN_DOWN]
button_event[dvTP_DISP[18],VD_SCREEN_DOWN]
button_event[dvTP_DISP[19],VD_SCREEN_DOWN]
button_event[dvTP_DISP[20],VD_SCREEN_DOWN]
{                      
	push:
	{
		stack_var nDest
		switch(button.input.channel)
		{
			//All of the goofy math below is my workaround because Netlinx won't let me do this with arrays.  We use the port on the device
			//combined with the port of the first dvTP_DISP to determine which display it is.  It's clunky, but it works, and it will work if
			//dvTP_DISP becomes a different port, as long as all of the ports are in order.
			case VD_SCREEN_UP: pulse [dstMain[button.input.device.port-dvTP_DISP[1][1].port+1].screenup]
			case VD_SCREEN_DOWN: pulse [dstMain[button.input.device.port-dvTP_DISP[1][1].port+1].screendown]
		}
	}
}


button_event[dvTP_DISP[1],VD_LIFT_UP]
button_event[dvTP_DISP[2],VD_LIFT_UP]
button_event[dvTP_DISP[3],VD_LIFT_UP]
button_event[dvTP_DISP[4],VD_LIFT_UP]
button_event[dvTP_DISP[5],VD_LIFT_UP]
button_event[dvTP_DISP[6],VD_LIFT_UP]
button_event[dvTP_DISP[7],VD_LIFT_UP]
button_event[dvTP_DISP[8],VD_LIFT_UP]
button_event[dvTP_DISP[9],VD_LIFT_UP]
button_event[dvTP_DISP[10],VD_LIFT_UP]
button_event[dvTP_DISP[11],VD_LIFT_UP]
button_event[dvTP_DISP[12],VD_LIFT_UP]
button_event[dvTP_DISP[13],VD_LIFT_UP]
button_event[dvTP_DISP[14],VD_LIFT_UP]
button_event[dvTP_DISP[15],VD_LIFT_UP]
button_event[dvTP_DISP[16],VD_LIFT_UP]
button_event[dvTP_DISP[17],VD_LIFT_UP]
button_event[dvTP_DISP[18],VD_LIFT_UP]
button_event[dvTP_DISP[19],VD_LIFT_UP]
button_event[dvTP_DISP[20],VD_LIFT_UP]
button_event[dvTP_DISP[1],VD_LIFT_DOWN]
button_event[dvTP_DISP[2],VD_LIFT_DOWN]
button_event[dvTP_DISP[3],VD_LIFT_DOWN]
button_event[dvTP_DISP[4],VD_LIFT_DOWN]
button_event[dvTP_DISP[5],VD_LIFT_DOWN]
button_event[dvTP_DISP[6],VD_LIFT_DOWN]
button_event[dvTP_DISP[7],VD_LIFT_DOWN]
button_event[dvTP_DISP[8],VD_LIFT_DOWN]
button_event[dvTP_DISP[9],VD_LIFT_DOWN]
button_event[dvTP_DISP[10],VD_LIFT_DOWN]
button_event[dvTP_DISP[11],VD_LIFT_DOWN]
button_event[dvTP_DISP[12],VD_LIFT_DOWN]
button_event[dvTP_DISP[13],VD_LIFT_DOWN]
button_event[dvTP_DISP[14],VD_LIFT_DOWN]
button_event[dvTP_DISP[15],VD_LIFT_DOWN]
button_event[dvTP_DISP[16],VD_LIFT_DOWN]
button_event[dvTP_DISP[17],VD_LIFT_DOWN]
button_event[dvTP_DISP[18],VD_LIFT_DOWN]
button_event[dvTP_DISP[19],VD_LIFT_DOWN]
button_event[dvTP_DISP[20],VD_LIFT_DOWN]
{
	push:
	{
		switch(button.input.channel)
		{
			case VD_LIFT_UP: pulse [dstMain[button.input.device.port-dvTP_DISP[1][1].port+1].liftup]
			case VD_LIFT_DOWN: pulse [dstMain[button.input.device.port-dvTP_DISP[1][1].port+1].liftdown]
		}
	}
}

define_event //Timeline Events

#IF_DEFINED dvIPClient
timeline_event[tlIPReconnect]
{
	for(x=1;x<=max_length_array(ip);x++)
	{
		if(!ip[x].status and length_string(ip[x].ipaddress)>0)
		{
			reconnect_client(x)
		}
	}
}


timeline_event[tlIPPoll]
{
	for(x=1;x<=max_length_array(ip);x++)
	{
		if(ip[x].dev_type=EXTRON_TYPE) send_string dvIPClient[x],"'Q'"	
		if(ip[x].dev_type=CLEARONE_TYPE) send_string dvIPClient[x],"'VER'"	
	}
}

#END_IF		


DEFINE_PROGRAM

