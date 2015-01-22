PROGRAM_NAME='RenameDEV1 Dual Rev6-00'
(*   

This file should be placed in the define_start section labeled "Most Include Files Go Here"
#INCLUDE 'RenameDEV1 Dual Rev6-00'

*)


define_variable

persistent		speeddial	sdDEV1[10]
volatile		integer		nSetDev1Number
volatile		integer		nSetDev1Name

define_function update_favorite1()
{
	for(x=1;x<=max_length_array(sdDEV1);x++) 
	{
		if(length_string(sdDEV1[x].number)>0)
		{
			send_command dvTP_DEV[1],"'^TXT-',itoa(TUNER_FAVORITENAME[x]),',0,',sdDEV1[x].name"
			send_command dvTP_DEV[1],"'^TXT-',itoa(TUNER_FAVORITENUM[x]),',0,',sdDEV1[x].number"
		}
		else
		{
			send_command dvTP_DEV[1],"'^TXT-',itoa(TUNER_FAVORITENAME[x]),',0,Touch to set Favorite'"
			send_command dvTP_DEV[1],"'^TXT-',itoa(TUNER_FAVORITENUM[x]),',0, '"
		}
	}	
}

define_event

data_event[dvTP]
{
	online:
	{
		update_favorite1()
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
				off[nSetDev1Name]
				off[nSetDev1Number]
			}
			case RNM_KEYPAD_RCVD:
			{
				if (nSetDev1Number)
				{
					remove_string(cTPResponse,'-',1)	//Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the name is 30 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdDEV1[nSetDev1Number].number=cTPResponse
					off[nSetDev1Number]
					update_favorite1()
				}
			}
			case RNM_KEYBRD_RCVD:
			{
				if(nSetDev1Name)
				{
					remove_string(cTPResponse,'-',1) //Remove the Prefix
					if (length_string(cTPResponse)>30)	//Max length on the number is 10 characters
					{
						set_length_string(cTPResponse,30)
					}
					sdDEV1[nSetDev1Name].name=cTPResponse
					nSetDev1Number=nSetDev1Name
					off[nSetDev1Name]
					send_command dvTP[get_last(vdvRenaming)],"'@AKP-',sdDEV1[nSetDev1Number].number,';Input Favorite Number;;AKP-;1'" //Pop up the keypad so the user can input a Favorite number				
				}
			}
		}
	}
}


button_event[dvTP_DEV[1],TUNER_FAVORITENAME]
{
	push:
	{
		to[button.input]
	}
	hold[15]:
	{
		nSetDev1Name=get_last(TUNER_FAVORITENAME)
		send_command button.input.device,"'@AKB-',sdDEV1[nSetDev1Name].name,';Input Favorite Name;;AKB-;1'" //Pop up the keypad so the user can input a Favorite number
	}
	release:
	{
		if(!nSetDev1Name)
		{
			if(length_array(sdDEV1[get_last(TUNER_FAVORITENAME)].number)=0)
			{
				nSetDev1Name=get_last(TUNER_FAVORITENAME)
				send_command button.input.device,"'@AKB-',sdDEV1[nSetDev1Name].name,';Input Favorite Name;;AKB-;1'" //Pop up the keypad so the user can input a Favorite number
			}
			else send_command vdvDEV1,"'CHAN ',sdDEV1[get_last(TUNER_FAVORITENAME)].number"
		}				
	}
}
