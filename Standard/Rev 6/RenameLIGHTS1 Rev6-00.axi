PROGRAM_NAME='RenameLIGHTS1 Rev6-00'
(*   

This file should be placed in the define_start section labeled "Most Include Files Go Here"
#INCLUDE 'RenameLIGHTS1 Rev6-00'

*)

define_variable

persistent		char		cLight1PresetNames[8][30]

volatile		integer		nSetLight1PresetName

define_function update_light1presets()
{
	for(x=1;x<=max_length_array(cLight1PresetNames);x++) 
	{
		if(length_string(cLight1PresetNames[x])>0)
		{
			send_command dvTP_LIGHT[1],"'^BMF-',itoa(LIGHTS_PRESETS[x]),',0,%F21'"
			send_command dvTP_LIGHT[1],"'^TXT-',itoa(LIGHTS_PRESETS[x]),',0,',cLight1PresetNames[x]"
		}
		else
		{
			send_command dvTP_LIGHT[1],"'^BMF-',itoa(LIGHTS_PRESETS[x]),',0,%F23'"
			send_command dvTP_LIGHT[1],"'^TXT-',itoa(LIGHTS_PRESETS[x]),',0,',itoa(x)"
		}
	}	
}

define_event

data_event[dvTP]
{
	online:
	{
		update_light1presets()
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
				off[nSetLight1PresetName]
			}
			case RNM_KEYPAD_RCVD:
			{
				//Do nothing
			}
			case RNM_KEYBRD_RCVD:
			{
				if (nSetLight1PresetName)
				{
					remove_string(cTPResponse,'KEYB-',1)	//Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the name is 30 characters
					{
						set_length_string(cTPResponse,30)
					}
					cLight1PresetNames[nSetLight1PresetName]=cTPResponse
					off[nSetLight1PresetName]
					update_light1presets()
				}
			}
		}
	}
}


button_event[dvTP_LIGHT[1],LIGHTS_PRESETS]
{
	hold[15]:
	{
		nSetLight1PresetName=get_last(LIGHTS_PRESETS)
		send_command button.input.device,"'@AKB-',cLight1PresetNames[nSetLight1PresetName],';Input Preset Name'" //Pop up the keypad so the user can input a speed dial number
	}
}
