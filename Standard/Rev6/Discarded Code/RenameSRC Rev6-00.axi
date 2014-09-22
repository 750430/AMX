PROGRAM_NAME='RenameSRC Rev6-00'
(*   

This file should be placed in the mainline between the define_variable section and the first define_function
#INCLUDE 'RenameSRC Rev6-00'

*)

define_variable

persistent		char		cSourceNames[30][30]

volatile		integer		nSetSourceName

define_function update_source_names()
{
	for(x=1;x<=max_length_array(cSourceNames);x++) 
	{
		if(length_string(cSourceNames[x])>0)
		{
			send_command dvTP_SRC,"'^TXT-',itoa(btnSources[x]),',0,',cSourceNames[x]"
		}
		else
		{
			send_command dvTP_SRC,"'^TXT-',itoa(btnSources[x]),',0,',srcMain[x].name"
		}
	}	
	update_destination_text()
}

define_event

data_event[dvTP]
{
	online:
	{
		update_source_names()
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
				off[nSetSourceName]
			}
			case RNM_KEYPAD_RCVD:
			{
				//Do nothing
			}
			case RNM_KEYBRD_RCVD:
			{
				if (nSetSourceName)
				{
					remove_string(cTPResponse,'KEYB-',1)	//Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the name is 30 characters
					{
						set_length_string(cTPResponse,30)
					}
					cSourceNames[nSetSourceName]=cTPResponse
					off[nSetSourceName]
					update_source_names()
				}
			}
		}
	}
}


button_event[dvTP_SRC,btnSources]
{
	hold[15]:
	{
		nSetSourceName=get_last(btnSources)
		send_command button.input.device,"'@AKB-',cSourceNames[nSetSourceName],';Input Source Name'" //Pop up the keypad so the user can input a speed dial number
	}
}
