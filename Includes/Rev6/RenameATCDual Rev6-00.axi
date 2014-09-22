PROGRAM_NAME='RenameATCDual Rev6-00'
(*   

This file should be placed in the define_start section labeled "Most Include Files Go Here"
#INCLUDE 'RenameATCDual Rev6-00'

*)


define_variable

persistent		speeddial	sdATC[10]
volatile		integer		nSetSpeedDialNumber
volatile		integer		nSetSpeedDialName

define_function update_SpeedDial()
{
	for(x=1;x<=max_length_array(sdATC);x++) 
	{
		if(length_string(sdATC[x].number)>0)
		{
			send_command dvTP_ATC[1],"'^TXT-',itoa(ATC_SPEEDDIAL[x]),',0,',sdATC[x].name"
			send_command dvTP_ATC[1],"'^TXT-',itoa(ATC_SPEEDDIALNUM[x]),',0,',sdATC[x].number"
		}
		else
		{
			send_command dvTP_ATC[1],"'^TXT-',itoa(ATC_SPEEDDIAL[x]),',0,Touch to set Speed Dial'"
			send_command dvTP_ATC[1],"'^TXT-',itoa(ATC_SPEEDDIALNUM[x]),',0, '"
		}
	}	
}

define_event

data_event[dvTP]
{
	online:
	{
		update_SpeedDial()
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
				off[nSetSpeedDialName]
				off[nSetSpeedDialNumber]
			}
			case RNM_KEYPAD_RCVD:
			{
				if (nSetSpeedDialNumber)
				{
					remove_string(cTPResponse,'-',1)	//Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the name is 30 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdATC[nSetSpeedDialNumber].number=cTPResponse
					off[nSetSpeedDialNumber]
					update_SpeedDial()
				}
			}
			case RNM_KEYBRD_RCVD:
			{
				if(nSetSpeedDialName)
				{
					remove_string(cTPResponse,'-',1) //Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the number is 10 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdATC[nSetSpeedDialName].name=cTPResponse
					nSetSpeedDialNumber=nSetSpeedDialName
					off[nSetSpeedDialName]
					send_command dvTP[get_last(vdvRenaming)],"'@AKP-',sdATC[nSetSpeedDialNumber].number,';Input Speed Dial Number;;AKP-;1'" //Pop up the keypad so the user can input a speed dial number				
				}
			}
		}
	}
}


button_event[dvTP_ATC[1],ATC_SPEEDDIAL]
{
	push:
	{
		to[button.input]
	}
	hold[15]:
	{
		nSetSpeedDialName=get_last(ATC_SPEEDDIAL)
		send_command button.input.device,"'@AKB-',sdATC[nSetSpeedDialName].name,';Input Speed Dial Name;;AKB-;1'" //Pop up the keypad so the user can input a speed dial number
	}
	release:
	{
		if(!nSetSpeedDialName)
		{
			if(length_array(sdATC[get_last(ATC_SPEEDDIAL)].number)=0)
			{
				nSetSpeedDialName=get_last(ATC_SPEEDDIAL)
				send_command button.input.device,"'@AKB-',sdATC[nSetSpeedDialName].name,';Input Speed Dial Name;;AKB-;1'" //Pop up the keypad so the user can input a speed dial number
			}
			else send_command vdvATC1,"'DIAL ',sdATC[get_last(ATC_SPEEDDIAL)].number"
		}				
	}
}
