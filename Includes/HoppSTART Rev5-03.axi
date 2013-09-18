PROGRAM_NAME='HoppSTART Rev5-02'
(***********************************************************)
(*  FILE CREATED ON: 08/08/2008  AT: 15:53:26              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/22/2011  AT: 10:34:33        *)
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
SlowFeedbackTL	=	3003
IPPollTL		=	3004	//Timeline to slowly query Extron devices and keep them connected

define_variable //Mixer Variables

volatile		integer		nNumVolBars
non_volatile	long		lMixQueryTimes[]={200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200,200}

define_variable //IP Variables

non_volatile	long		lReconnectTime[]={5000}
non_volatile	long		lPollTL[]={60000}
non_volatile	char		cBiampBuffer[255]

define_variable //Feedback Variables

volatile		integer		nSkipFeedback
volatile		integer		nShowIPFeedback
non_volatile	long		lFeedbackTime[]={100}
non_volatile	long		lSlowFeedbackTime[]={3000}


//General useful functions

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

define_function query_mixer()
{
	nNumVolBars=0
	for(x=1;x<=max_length_array(vol);x++)
	{
		if(length_string(vol[x].chan)>0 or length_string(vol[x].name)>0 or length_string(vol[x].instidTag)) nNumVolBars++
	}
	if(!timeline_active(MixQueryTL)) 
	{
		timeline_create(MixQueryTL,lMixQueryTimes,nNumVolBars,timeline_relative,timeline_once)
		send_string 0,"'timeline create - nNumVolBars=',itoa(nNumVolBars)"
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

#IF_DEFINED dvBiamp
define_function biamp_recall_preset(char cPreset[])
{
	send_string dvBiamp,"'RECALL 0 PRESET ',cPreset,10"
	wait 5
	query_mixer()
}
#END_IF

define_start


timeline_create(FeedbackTL,lFeedbackTime,1,timeline_relative,timeline_repeat)
timeline_create(SlowFeedbackTL,lSlowFeedbackTime,1,timeline_relative,timeline_repeat)


#IF_DEFINED dvIPClient
for(x=1;x<=100;x++) 
{
	if(length_string(ip[x].ipaddress)>0) 
	{	
		dvIPClient[x]=ip[x].dvIP
		openclient(x)			//if IP address is defined, open client
	}
}

timeline_create(IPReconnectTL,lReconnectTime,1,timeline_relative,timeline_repeat)
timeline_create(IPPollTL,lPollTL,length_array(lPollTL),timeline_relative,timeline_repeat)

#END_IF



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
		//ip[get_last(dvIPClient)].reconn++
		off[IP[get_last(dvIPClient)].status]
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
		if(find_string(data.text,"'Extron Electronics'",1))
		{
			send_string data.device,"$1B,'0*65000TC',$0D,$0A"
			send_string data.device,"$1B,'1*65000TC',$0D,$0A"
		}
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
		to[button.input]
		pulse [dstMain[get_last(btnScreenUp)].screenup]
	}
}
#END_IF

#IF_DEFINED btnScreenDown
button_event[dvTP,btnScreenDown]
{
	push:
	{
		to[button.input]
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
		to[button.input]
		pulse [dstMain[get_last(btnLiftUp)].liftup]
	}
}
#END_IF

#IF_DEFINED btnLiftDown
button_event[dvTP,btnLiftDown]
{
	push:
	{
		to[button.input]
		pulse [dstMain[get_last(btnLiftDown)].liftdown]
	}
}
#END_IF

define_event //Timeline Events

timeline_event[MixQueryTL]
{
	if(vol[timeline.sequence].chan>0 or length_string(vol[timeline.sequence].name)>0 or length_string(vol[timeline.sequence].instIDtag)>0) pulse[vdvMXR[timeline.sequence],MIX_QUERY]
}

#IF_DEFINED dvIPClient
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


timeline_event[IPPollTL]
{
	for(x=1;x<=100;x++)
	{
		if(ip[x].dev_type=EXTRON_TYPE)
		{
			send_string dvIPClient[x],"'Q'"
		}
	}
}

#END_IF		

timeline_event[FeedbackTL]
{
	if (!nSkipFeedback) tp_fb()
}

DEFINE_PROGRAM


//If you want slow feedback, you have to declare this timeline in the main, becuase we don't include the slow_tp_fb line in every system
//timeline_event[SlowFeedbackTL]
//{
//	slow_tp_fb()
//}