PROGRAM_NAME='MultiLine ATC RenameAndDial Rev6-00'
(*   

This file should be placed in the define_start section labeled "Most Include Files Go Here"
#INCLUDE 'MultiLine ATC RenameAndDial Rev6-00'

*)


define_variable

persistent		speeddial	sdATC1[10]
volatile		integer		nSetSpeedDial1Number
volatile		integer		nSetSpeedDial1Name

define_function update_speeddial1()
{
	for(x=1;x<=max_length_array(sdATC1);x++) 
	{
		if(length_string(sdATC1[x].number)>0)
		{
			send_command dvTP_ATC[1],"'^TXT-',itoa(ATC_SPEEDDIALNAME[x]),',0,',sdATC1[x].name"
			send_command dvTP_ATC[1],"'^TXT-',itoa(ATC_SPEEDDIALNUM[x]),',0,',sdATC1[x].number"
		}
		else
		{
			send_command dvTP_ATC[1],"'^TXT-',itoa(ATC_SPEEDDIALNAME[x]),',0,Touch to set Speed Dial'"
			send_command dvTP_ATC[1],"'^TXT-',itoa(ATC_SPEEDDIALNUM[x]),',0, '"
		}
	}	
}

define_function clear_speeddial()
{
	for(x=1;x<=10;x++) 
	{
		send_command dvTP_ATC[1],"'^SHO-',itoa(ATC_SPEEDDIAL[x]),',0'"
		send_command dvTP_ATC[2],"'^SHO-',itoa(ATC_SPEEDDIAL[x]),',0'"
	}
}

define_function show_speeddial(integer nSD)
{
	for(x=1;x<=10;x++) 
	{
		if(x=nSD)
		{
			send_command dvTP_ATC[1],"'^SHO-',itoa(ATC_SPEEDDIAL[x]),',1'"
			send_command dvTP_ATC[2],"'^SHO-',itoa(ATC_SPEEDDIAL[x]),',1'"
		}
		else
		{
			send_command dvTP_ATC[1],"'^SHO-',itoa(ATC_SPEEDDIAL[x]),',0'"
			send_command dvTP_ATC[2],"'^SHO-',itoa(ATC_SPEEDDIAL[x]),',0'"
		}
	}
	
}

define_event

data_event[dvTP]
{
	online:
	{
		update_speeddial1()
	}
}

channel_event[vdvRenaming,0]
{
	on:
	{
		switch(channel.channel)
		{
			case RNM_ABORT:
			{
				off[nSetSpeedDial1Name]
				off[nSetSpeedDial1Number]
			}
			case RNM_KEYPAD_RCVD:
			{
				if (nSetSpeedDial1Number)
				{
					remove_string(cTPResponse,'-',1)	//Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the name is 30 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdATC1[nSetSpeedDial1Number].number=cTPResponse
					off[nSetSpeedDial1Number]
					update_speeddial1()
				}
			}
			case RNM_KEYBRD_RCVD:
			{
				if(nSetSpeedDial1Name)
				{
					remove_string(cTPResponse,'-',1) //Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the number is 10 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdATC1[nSetSpeedDial1Name].name=cTPResponse
					nSetSpeedDial1Number=nSetSpeedDial1Name
					off[nSetSpeedDial1Name]
					send_command dvTP[get_last(vdvRenaming)],"'@AKP-',sdATC1[nSetSpeedDial1Number].number,';Input Speed Dial Number;;AKP-;1'" //Pop up the keypad so the user can input a speed dial number				
				}
			}
		}
	}
}


button_event[dvTP_ATC[1],ATC_SPEEDDIALNAME]
{
	push:
	{
		to[button.input]
	}
	hold[15]:
	{
		nSetSpeedDial1Name=get_last(ATC_SPEEDDIALNAME)
		send_command button.input.device,"'@AKB-',sdATC1[nSetSpeedDial1Name].name,';Input Speed Dial Name;;AKB-;1'" //Pop up the keypad so the user can input a speed dial number
	}
	release:
	{
		if(!nSetSpeedDial1Name)
		{
			if(length_array(sdATC1[get_last(ATC_SPEEDDIALNAME)].number)=0)
			{
				nSetSpeedDial1Name=get_last(ATC_SPEEDDIALNAME)
				send_command button.input.device,"'@AKB-',sdATC1[nSetSpeedDial1Name].name,';Input Speed Dial Name;;AKB-;1'" //Pop up the keypad so the user can input a speed dial number
			}
			else 
			{
				show_speeddial(get_last(ATC_SPEEDDIALNAME))
			}
		}				
	}
}

button_event[dvTP_ATC[1],ATC_SPEEDDIAL]
{
	push:
	{
		to[button.input]
		send_command vdvATC1,"'DIAL ',sdATC1[get_last(ATC_SPEEDDIAL)].number"
	}
}

button_event[dvTP_ATC[2],ATC_SPEEDDIAL]
{
	push:
	{
		to[button.input]
		send_command vdvATC2,"'DIAL ',sdATC1[get_last(ATC_SPEEDDIAL)].number"
	}
}
