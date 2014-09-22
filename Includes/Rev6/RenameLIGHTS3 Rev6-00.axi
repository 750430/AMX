PROGRAM_NAME='RenameLIGHTS3 Rev6-00'
(*   

This file should be placed in the define_start section labeled "Most Include Files Go Here"
#INCLUDE 'RenameLIGHTS3 Rev6-00'

*)

define_variable

persistent		char		cLight3PresetNames[8][30]

volatile		integer		nSetLight3PresetName

define_function update_light3presets()
{
	for(x=1;x<=max_length_array(cLight3PresetNames);x++) 
	{
		if(length_string(cLight3PresetNames[x])>0)
		{
			send_command dvTP_LIGHT[3],"'^BMF-',itoa(LIGHTS_PRESETS[x]),',0,%F21'"
			send_command dvTP_LIGHT[3],"'^TXT-',itoa(LIGHTS_PRESETS[x]),',0,',cLight3PresetNames[x]"
		}
		else
		{
			send_command dvTP_LIGHT[3],"'^BMF-',itoa(LIGHTS_PRESETS[x]),',0,%F23'"
			send_command dvTP_LIGHT[3],"'^TXT-',itoa(LIGHTS_PRESETS[x]),',0,',itoa(x)"
		}
	}	
}

define_event

data_event[dvTP]
{
	online:
	{
		update_light3presets()
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
				off[nSetLight3PresetName]
			}
			case RNM_KEYPAD_RCVD:
			{
				//Do nothing
			}
			case RNM_KEYBRD_RCVD:
			{
				if (nSetLight3PresetName)
				{
					remove_string(cTPResponse,'KEYB-',1)	//Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the name is 30 characters
					{
						set_length_string(cTPResponse,30)
					}
					cLight3PresetNames[nSetLight3PresetName]=cTPResponse
					off[nSetLight3PresetName]
					update_light3presets()
				}
			}
		}
	}
}


button_event[dvTP_LIGHT[3],LIGHTS_PRESETS]
{
	hold[15]:
	{
		nSetLight3PresetName=get_last(LIGHTS_PRESETS)
		send_command button.input.device,"'@AKB-',cLight3PresetNames[nSetLight3PresetName],';Input Preset Name'" //Pop up the keypad so the user can input a speed dial number
	}
}
