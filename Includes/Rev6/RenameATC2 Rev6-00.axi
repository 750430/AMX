PROGRAM_NAME='Rename ATC2 Rev6-00'
(*   

This file should be placed in the define_start section labeled "Most Include Files Go Here"
#INCLUDE 'Rename ATC2 Rev6-00'

*)

define_variable

persistent		speeddial	sdATC2[10]
volatile		integer		nSetSpeedDial2Number
volatile		integer		nSetSpeedDial2Name

define_function update_speeddial2()
{
	for(x=1;x<=max_length_array(sdATC2);x++) 
	{
		if(length_string(sdATC2[x].number)>0)
		{
			send_command dvTP_ATC[2],"'^TXT-',itoa(ATC_SPEEDDIALNAME[x]),',0,',sdATC2[x].name"
			send_command dvTP_ATC[2],"'^TXT-',itoa(ATC_SPEEDDIALNUM[x]),',0,',sdATC2[x].number"
		}
		else
		{
			send_command dvTP_ATC[2],"'^TXT-',itoa(ATC_SPEEDDIALNAME[x]),',0,Touch to set Speed Dial'"
			send_command dvTP_ATC[2],"'^TXT-',itoa(ATC_SPEEDDIALNUM[x]),',0, '"
		}
	}	
}

define_event

data_event[dvTP]
{
	online:
	{
		update_speeddial2()
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
				off[nSetSpeedDial2Name]
				off[nSetSpeedDial2Number]
			}
			case RNM_KEYPAD_RCVD:
			{
				//Do nothing
			}
			case RNM_KEYBRD_RCVD:
			{
				if(nSetSpeedDial2Name)
				{
					remove_string(cTPResponse,'KEYB-',1) //Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the number is 10 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdATC2[nSetSpeedDial2Name].name=cTPResponse
					nSetSpeedDial2Number=nSetSpeedDial2Name
					off[nSetSpeedDial2Name]
					send_command dvTP[get_last(vdvRenaming)],"'@AKB-',sdATC2[nSetSpeedDial2Number].number,';Input Speed Dial Number'" //Pop up the keypad so the user can input a speed dial number				
				}
				else if (nSetSpeedDial2Number)
				{
					remove_string(cTPResponse,'KEYB-',1)	//Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the name is 30 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdATC2[nSetSpeedDial2Number].number=cTPResponse
					off[nSetSpeedDial2Number]
					update_speeddial2()
				}
			}
		}
	}
}


button_event[dvTP_ATC[2],ATC_SPEEDDIALNAME]
{
	push:
	{
		to[button.input]
	}
	hold[15]:
	{
		nSetSpeedDial2Name=get_last(ATC_SPEEDDIALNAME)
		send_command button.input.device,"'@AKB-',sdATC2[nSetSpeedDial2Name].name,';Input Speed Dial Name'" //Pop up the keypad so the user can input a speed dial number
	}
	release:
	{
		if(length_array(sdATC2[get_last(ATC_SPEEDDIALNAME)].number)=0)
		{
			nSetSpeedDial2Name=get_last(ATC_SPEEDDIALNAME)
			send_command button.input.device,"'@AKB-',sdATC2[nSetSpeedDial2Name].name,';Input Speed Dial Name'" //Pop up the keypad so the user can input a speed dial number
		}
		if(!nSetSpeedDial2Name)
		{
			send_command vdvATC2,"'DIAL ',sdATC2[get_last(ATC_SPEEDDIALNAME)].number"
		}				
	}
}
