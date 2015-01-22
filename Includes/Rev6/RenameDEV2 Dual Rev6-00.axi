PROGRAM_NAME='RenameDEV2 Dual Rev6-00'
(*   

This file should be placed in the define_start section labeled "Most Include Files Go Here"
#INCLUDE 'RenameDEV2 Dual Rev6-00'

*)


define_variable

persistent		speeddial	sdDEV2[10]
volatile		integer		nSetDev2Number
volatile		integer		nSetDev2Name

define_function update_favorite2()
{
	for(x=1;x<=max_length_array(sdDEV2);x++) 
	{
		if(length_string(sdDEV2[x].number)>0)
		{
			send_command dvTP_DEV[2],"'^TXT-',itoa(TUNER_FAVORITENAME[x]),',0,',sdDEV2[x].name"
			send_command dvTP_DEV[2],"'^TXT-',itoa(TUNER_FAVORITENUM[x]),',0,',sdDEV2[x].number"
		}
		else
		{
			send_command dvTP_DEV[2],"'^TXT-',itoa(TUNER_FAVORITENAME[x]),',0,Touch to set Favorite'"
			send_command dvTP_DEV[2],"'^TXT-',itoa(TUNER_FAVORITENUM[x]),',0, '"
		}
	}	
}

define_event

data_event[dvTP]
{
	online:
	{
		update_favorite2()
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
				off[nSetDev2Name]
				off[nSetDev2Number]
			}
			case RNM_KEYPAD_RCVD:
			{
				if (nSetDev2Number)
				{
					remove_string(cTPResponse,'-',1)	//Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the name is 30 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdDEV2[nSetDev2Number].number=cTPResponse
					off[nSetDev2Number]
					update_favorite2()
				}
			}
			case RNM_KEYBRD_RCVD:
			{
				if(nSetDev2Name)
				{
					remove_string(cTPResponse,'-',1) //Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the number is 10 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdDEV2[nSetDev2Name].name=cTPResponse
					nSetDev2Number=nSetDev2Name
					off[nSetDev2Name]
					send_command dvTP[get_last(vdvRenaming)],"'@AKP-',sdDEV2[nSetDev2Number].number,';Input Favorite Number;;AKP-;1'" //Pop up the keypad so the user can input a Favorite number				
				}
			}
		}
	}
}


button_event[dvTP_DEV[2],TUNER_FAVORITENAME]
{
	push:
	{
		to[button.input]
	}
	hold[15]:
	{
		nSetDev2Name=get_last(TUNER_FAVORITENAME)
		send_command button.input.device,"'@AKB-',sdDEV2[nSetDev2Name].name,';Input Favorite Name;;AKB-;1'" //Pop up the keypad so the user can input a Favorite number
	}
	release:
	{
		if(!nSetDev2Name)
		{
			if(length_array(sdDEV2[get_last(TUNER_FAVORITENAME)].number)=0)
			{
				nSetDev2Name=get_last(TUNER_FAVORITENAME)
				send_command button.input.device,"'@AKB-',sdDEV2[nSetDev2Name].name,';Input Favorite Name;;AKB-;1'" //Pop up the keypad so the user can input a Favorite number
			}
			else send_command vdvDEV2,"'CHAN ',sdDEV2[get_last(TUNER_FAVORITENAME)].number"
		}				
	}
}
