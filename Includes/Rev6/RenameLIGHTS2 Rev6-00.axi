PROGRAM_NAME='RenameLIGHTS2 Rev6-00'
(*   

This file should be placed in the define_start section labeled "Most Include Files Go Here"
#INCLUDE 'RenameLIGHTS2 Rev6-00'

*)

define_variable

persistent		char		cLight2PresetNames[8][30]

volatile		integer		nSetLight2PresetName

define_function update_light2presets()
{
	for(x=1;x<=max_length_array(cLight2PresetNames);x++) 
	{
		if(length_string(cLight2PresetNames[x])>0)
		{
			//send_command dvTP_LIGHT[2],"'^BMF-',itoa(LIGHTS_PRESETS[x]),',0,%F21'"
			send_command dvTP_LIGHT[2],"'^TXT-',itoa(LIGHTS_PRESETS[x]),',0,',cLight2PresetNames[x]"
		}
		else
		{
			//send_command dvTP_LIGHT[2],"'^BMF-',itoa(LIGHTS_PRESETS[x]),',0,%F23'"
			send_command dvTP_LIGHT[2],"'^TXT-',itoa(LIGHTS_PRESETS[x]),',0,',itoa(x)"
		}
	}	
}

define_event

data_event[dvTP]
{
	online:
	{
		update_light2presets()
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
				off[nSetLight2PresetName]
			}
			case RNM_KEYPAD_RCVD:
			{
				//Do nothing
			}
			case RNM_KEYBRD_RCVD:
			{
				if (nSetLight2PresetName)
				{
					remove_string(cTPResponse,'-',1)	//Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the name is 30 characters
					{
						set_length_string(cTPResponse,30)
					}
					cLight2PresetNames[nSetLight2PresetName]=cTPResponse
					off[nSetLight2PresetName]
					update_light2presets()
				}
			}
		}
	}
}


button_event[dvTP_LIGHT[2],LIGHTS_PRESETS]
{
	hold[15]:
	{
		nSetLight2PresetName=get_last(LIGHTS_PRESETS)
		send_command button.input.device,"'@AKB-',cLight2PresetNames[nSetLight2PresetName],';Input Preset Name;;AKB-;1'" //Pop up the keypad so the user can input a speed dial number
	}
}
