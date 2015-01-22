PROGRAM_NAME='RenameDEV3 Dual Rev6-00'
(*   

This file should be placed in the define_start section labeled "Most Include Files Go Here"
#INCLUDE 'RenameDEV3 Dual Rev6-00'

*)


define_variable

persistent		speeddial	sdDEV3[10]
volatile		integer		nSetDev3Number
volatile		integer		nSetDev3Name

define_function update_favorite3()
{
	for(x=1;x<=max_length_array(sdDEV3);x++) 
	{
		if(length_string(sdDEV3[x].number)>0)
		{
			send_command dvTP_DEV[3],"'^TXT-',itoa(TUNER_FAVORITENAME[x]),',0,',sdDEV3[x].name"
			send_command dvTP_DEV[3],"'^TXT-',itoa(TUNER_FAVORITENUM[x]),',0,',sdDEV3[x].number"
		}
		else
		{
			send_command dvTP_DEV[3],"'^TXT-',itoa(TUNER_FAVORITENAME[x]),',0,Touch to set Favorite'"
			send_command dvTP_DEV[3],"'^TXT-',itoa(TUNER_FAVORITENUM[x]),',0, '"
		}
	}	
}

define_event

data_event[dvTP]
{
	online:
	{
		update_favorite3()
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
				off[nSetDev3Name]
				off[nSetDev3Number]
			}
			case RNM_KEYPAD_RCVD:
			{
				if (nSetDev3Number)
				{
					remove_string(cTPResponse,'-',1)	//Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the name is 30 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdDEV3[nSetDev3Number].number=cTPResponse
					off[nSetDev3Number]
					update_favorite3()
				}
			}
			case RNM_KEYBRD_RCVD:
			{
				if(nSetDev3Name)
				{
					remove_string(cTPResponse,'-',1) //Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the number is 10 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdDEV3[nSetDev3Name].name=cTPResponse
					nSetDev3Number=nSetDev3Name
					off[nSetDev3Name]
					send_command dvTP[get_last(vdvRenaming)],"'@AKP-',sdDEV3[nSetDev3Number].number,';Input Favorite Number;;AKP-;1'" //Pop up the keypad so the user can input a Favorite number				
				}
			}
		}
	}
}


button_event[dvTP_DEV[3],TUNER_FAVORITENAME]
{
	push:
	{
		to[button.input]
	}
	hold[15]:
	{
		nSetDev3Name=get_last(TUNER_FAVORITENAME)
		send_command button.input.device,"'@AKB-',sdDEV3[nSetDev3Name].name,';Input Favorite Name;;AKB-;1'" //Pop up the keypad so the user can input a Favorite number
	}
	release:
	{
		if(!nSetDev3Name)
		{
			if(length_array(sdDEV3[get_last(TUNER_FAVORITENAME)].number)=0)
			{
				nSetDev3Name=get_last(TUNER_FAVORITENAME)
				send_command button.input.device,"'@AKB-',sdDEV3[nSetDev3Name].name,';Input Favorite Name;;AKB-;1'" //Pop up the keypad so the user can input a Favorite number
			}
			else send_command vdvDEV3,"'CHAN ',sdDEV3[get_last(TUNER_FAVORITENAME)].number"
		}				
	}
}
