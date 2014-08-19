PROGRAM_NAME='HoppDEBUG Rev6-00'

define_constant

tlDebugFeedback		=	3001

strTo		=	1
strFrom		=	2

mdASCII		=	1
mdMIX		=	2
mdHEX		=	3

define_type

structure debug
{
	char str[255]
	integer dir
}

define_variable //Feedback Variables

non_volatile	long		lDebugFeedbackTime[]={300}

define_variable

integer		nDebugStatus
integer		nDebugMode=mdMIX

char		cDebugStrings[26][255]

debug		dbgMain[26]

define_function debug_fb()
{
	stack_var integer z
	for(z=1;z<=length_array(DEBUG_MODE);z++) [dvTP,DEBUG_MODE[z]]=nDebugMode=z
	[dvTP,DEBUG_ON]=nDebugStatus
	[dvTP,DEBUG_OFF]=!nDebugStatus
}

define_function send_str(dev dv,char cStr[100])
{
	send_string dv,cStr
	add_to_debug(cStr,strTo)
}

define_function add_to_debug(char cStr[255],integer nDir)
{
	stack_var integer z
	if(nDebugStatus) 
	{
		for(z=25;z>0;z--) 
		{
			dbgMain[z+1].str=dbgMain[z].str
			dbgMain[z+1].dir=dbgMain[z].dir
		}
		
		dbgMain[1].str=cStr
		dbgMain[1].dir=nDir
		
		show_debug()
	}
}

define_function show_debug()
{
	stack_var integer z
	for(z=1;z<=26;z++) 
	{
		switch(dbgMain[z].dir)
		{
			case strTo: send_command dvTP,"'^BMF-',itoa(200+z),',0,%J6'"
			case strFrom: send_command dvTP,"'^BMF-',itoa(200+z),',0,%J4'"
		}
		send_command dvTP,"'^TXT-',itoa(200+z),',0,',convert_to_ascii(dbgMain[z].str)"
	}	
}

define_function char[255] convert_to_ascii(cStr[])
{
	stack_var char cNewStr[255]
	stack_var integer z
	cNewStr=''
	if(length_string(cStr)>0)
	{
		switch(nDebugMode)
		{
			case mdASCII:
			{
				for(z=1;z<=length_string(cStr);z++)
				{
					if(cStr[z]>=32 and cStr[z]<=126) cNewStr="cNewStr,cStr[z]"
				}
			}
			case mdMIX:
			{
				for(z=1;z<=length_string(cStr);z++)
				{
					if(cStr[z]<32 or cStr[z]>126)
					{
						if(cNewStr[length_string(cNewStr)]=',') set_length_string(cNewStr,length_string(cNewStr)-1)
					
						if(length_string(itohex(cStr[z]))=1) cNewStr="cNewStr,',$0',itohex(cStr[z]),','"
						else cNewStr="cNewStr,',$',itohex(cStr[z]),','"
					}
					else  cNewStr="cNewStr,cStr[z]"
				}
				if(cNewStr[length_string(cNewStr)]=',') set_length_string(cNewStr,length_string(cNewStr)-1)
			}
			case mdHEX:
			{
				for(z=1;z<=length_string(cStr);z++)
				{
					if(length_string(itohex(cStr[z]))=1) cNewStr="cNewStr,'$0',itohex(cStr[z]),','"
					else cNewStr="cNewStr,'$',itohex(cStr[z]),','"
				}
				if(cNewStr[length_string(cNewStr)]=',') set_length_string(cNewStr,length_string(cNewStr)-1)
			}
		}
	}
	return cNewStr
}

define_function clear_debug()
{
	stack_var integer z
	for(z=1;z<=26;z++) 
	{
		dbgMain[z].str=''
		off[dbgMain[z].dir]
		send_command dvTP,"'^TXT-',itoa(200+z),',0,',dbgMain[z].str"
	}
}

define_start

timeline_create(tlDebugFeedback,lDebugFeedbackTime,1,timeline_relative,timeline_repeat)

define_event

button_event[dvTP,DEBUG_ON]
button_event[dvTP,DEBUG_OFF]
button_event[dvTP,DEBUG_CLEAR]
button_event[dvTP,DEBUG_ASCII]
button_event[dvTP,DEBUG_MIX]
button_event[dvTP,DEBUG_HEX]
{
	push:
	{
		switch(button.input.channel)
		{
			CASE DEBUG_ON: on[nDebugStatus]
			CASE DEBUG_OFF: off[nDebugStatus]
			CASE DEBUG_CLEAR: clear_debug()
			CASE DEBUG_ASCII:
			{
				nDebugMode=mdASCII
				show_debug()
			}
			CASE DEBUG_MIX: 
			{
				nDebugMode=mdMIX
				show_debug()
			}
			CASE DEBUG_HEX:
			{
				nDebugMode=mdHEX
				show_debug()
			}
		}
	}
}

timeline_event[tlDebugFeedback]
{
	debug_fb()
}