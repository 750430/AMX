MODULE_NAME='Tandberg C Series Directory Rev5-00'(DEV vdvTP, DEV dvTP[], DEV vdvVTC, DEV dvVTC)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/06/2011  AT: 18:05:27        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
#INCLUDE 'HoppSNAPI Rev5-04.axi'

//define_module 'Tandberg C Series Directory Rev5-00' vtc1(vdvTP_VTC1,dvTP,vdvVTC1,dvVTC)
//Set Baud 38400,N,8,1
//Remember to set the Tandberg to not require authentication, and then reboot the tandberg
(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant

pbLocal		=	1
pbCorporate	=	2

pbContact	=	1
pbFolder	=	2

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_type

structure phonebookentry
{
	char name[40]
	char contactID[50]
	char number[70]
}

structure phonebookfolder
{
	char name[40]
	char folderID[30]
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable

volatile		integer			x
volatile		integer 		y
volatile		integer			z

volatile		char 			cVTC_Buff[2550]

volatile		integer			nBaseEntry

volatile		integer			nPBQuery
volatile		integer			nPBResponse

persistent		integer			nPhoneBookEntries
persistent		phonebookentry	pbPhoneBook[50]
persistent		phonebookfolder	pbPhoneBookFolder[20]
volatile		phonebookentry	pbBlankEntry

persistent		integer			nPBType
volatile		integer			nResultType

volatile		char			cPBType[2][10]

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
define_mutually_exclusive

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
define_function parse(char cMsg[100])
{
	stack_var integer nContact
	stack_var integer nFolder
	select
	{
		active(find_string(cMsg,"'*r ResultSet ResultInfo'",1)): 
		{
			on[nPBResponse]
			remove_string(cMsg,"'*r ResultSet ResultInfo TotalRows: '",1)
			nPhoneBookEntries=atoi(left_string(cMsg,find_string(cMsg,"$0D",1)-1))
			if(nPhoneBookEntries=0)
			{
				nResultType=pbContact
				pbPhoneBook[1].name='No Results Found'
			}
		}
		active(find_string(cMsg,"'*r ResultSet Contact'",1)): 
		{
			nResultType=pbContact
			remove_string(cMsg,"'*r ResultSet Contact '",1)
			nContact=atoi(left_string(cMsg,find_string(cMsg,"$20",1)-1))
			select
			{
				active(find_string(cMsg,"'Name:'",1)):
				{
					remove_string(cMsg,"'Name: "'",1)
					pbPhoneBook[nContact].name=left_string(cMsg,find_string(cMsg,'"',1)-1)
				}
				active(find_string(cMsg,"'ContactId:'",1)):
				{
					remove_string(cMsg,"'ContactId: "'",1)
					pbPhoneBook[nContact].contactId=left_string(cMsg,find_string(cMsg,'"',1)-1)
				}
				active(find_string(cMsg,"'ContactMethod'",1)):
				{
					remove_string(cMsg,"'ContactMethod'",1)
					select
					{
						active(find_string(cMsg,"'Number:'",1)):
						{
							remove_string(cMsg,"'Number: "'",1)
							pbPhoneBook[nContact].number=left_string(cMsg,find_string(cMsg,'"',1)-1)
						}
						active(find_string(cMsg,"'Device:'",1)):
						{
							//Do nothing
						}
						active(find_string(cMsg,"'CallRate:'",1)):
						{
							//Do nothing
						}						
					}
				}
			}
		}
		active(find_string(cMsg,"'*r ResultSet Folder'",1)):
		{
			nResultType=pbFolder
			remove_string(cMsg,"'*r ResultSet Folder '",1)
			nFolder=atoi(left_string(cMsg,find_string(cMsg,"$20",1)-1))
			select
			{
				active(find_string(cMsg,"'Name:'",1)):
				{
					remove_string(cMsg,"'Name: "'",1)
					pbPhoneBookFolder[nFolder].name=left_string(cMsg,find_string(cMsg,'"',1)-1)
				}
				active(find_string(cMsg,"'FolderId:'",1)):
				{
					remove_string(cMsg,"'FolderId: "'",1)
					pbPhoneBookFolder[nFolder].folderID=left_string(cMsg,find_string(cMsg,'"',1)-1)
				}
			}
		}
		active(find_string(cMsg,"'** end'",1) and nPBQuery and nPBResponse):
		{
			off[nPBQuery]
			off[nPBResponse]
			send_command vdvTP,"'^SHO-',itoa(VTC_PB_LOADING),',0'"
			nBaseEntry=1
			for(x=1;x<=length_array(VTC_PB_ENTRIES);x++)
			{
				switch(nPBType)
				{
					case pbLocal: send_command vdvTP,"'^TXT-',itoa(VTC_PB_ENTRIES[x]),',0,',pbPhoneBook[x].name"
					case pbCorporate: 
					{
						switch(nResultType)
						{
							case pbContact: send_command vdvTP,"'^TXT-',itoa(VTC_PB_ENTRIES[x]),',0,',pbPhoneBook[x].name"
							case pbFolder: send_command vdvTP,"'^TXT-',itoa(VTC_PB_ENTRIES[x]),',0,',pbPhoneBookFolder[x].name"
						}
					}
				}
			}
		}
	}
}

define_function init_phonebook_query()
{
	off[nPBResponse]
	on[nPBQuery]
	for(x=1;x<=50;x++) pbPhoneBook[x]=pbBlankEntry
	send_command vdvTP,"'^SHO-',itoa(VTC_PB_LOADING),',1'"
	for(x=1;x<=length_array(VTC_PB_ENTRIES);x++)
	{
		send_command vdvTP,"'^TXT-',itoa(VTC_PB_ENTRIES[x]),',0,'"
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start

cPBType[pbLocal]		=	'Local'
cPBType[pbCorporate]	=	'Corporate'

create_buffer dvVTC, cVTC_Buff

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event

data_event[dvVTC]
{
	string:
	{
		while(find_string(cVTC_Buff,"$0D,$0A",1) or find_string(cVTC_Buff,"'login:'",1))
		{
			if (find_string(cVTC_Buff,"$0D,$0A",1)) parse(remove_string(cVTC_Buff,"$0D,$0A",1))
			else parse(remove_string(cVTC_Buff,"'login:'",1))
		}
	}
}

data_event[dvTP]
{
	string:
	{
		stack_var char cTPResponse[255]
		cTPResponse=data.text
		send_string 0,"'TP Response Received: ',cTPResponse"
		if (left_string(cTPResponse,10)='KEYP-ABORT' or left_string(cTPResponse,10)='KEYB-ABORT')
		{
			//do nothing
		}
		else if (left_string(cTPResponse,5)='KEYP-')
		{
			//do nothing
		}
		else if (left_string(cTPResponse,5)='KEYB-')
		{
			remove_string(cTPResponse,'KEYB-',1)		//basic string parsing, remove KEYB- and attenuate string length
			init_phonebook_query()
			send_string dvVTC, "'xCommand Phonebook Search PhonebookType:',cPBType[nPBType],' SearchString:"',cTPResponse,'"',$0D,$0A"
//			switch(nPBType)
//			{
//				case pbLocal: 
//				case pbCorporate:
//				{
//					switch(nResultType)
//					{
//						case pbFolder:
//						{
//							send_string dvVTC, "'xCommand Phonebook Search PhonebookType:',cPBType[nPBType],' FolderID:',pbPhoneBookFolder[nChnl-VTC_PB_1+nBaseEntry].folderID,' SearchString:""',$0D,$0A"
//						}
//					}
//				}
//			}
		}
	}
}


button_event [vdvTP,0]
{
	push:		
	{
		to[button.input]
		to[vdvVTC,button.input.channel]
	}
}

channel_event [vdvVTC, 0]
{
	on:
	{
		stack_var integer nChnl
		nChnl = CHANNEL.CHANNEL
		switch (nChnl)
		{
			case VTC_PB_DISPLAY:	
			{
				init_phonebook_query()
				send_string dvVTC, "'xCommand Phonebook Search PhonebookType:',cPBType[nPBType],' SearchString:""',$0D,$0A"
			}
			case VTC_PB_REFRESH:
			{
				init_phonebook_query()
				send_string dvVTC, "'xCommand Phonebook Search PhonebookType:',cPBType[nPBType],' SearchString:""',$0D,$0A"
			}
			case VTC_PB_UP:
			{
				if(nBaseEntry>1)
				{
					nBaseEntry--
					for(x=1;x<=length_array(VTC_PB_ENTRIES);x++)
					{
						switch(nResultType)
						{
							case pbContact: send_command vdvTP,"'^TXT-',itoa(VTC_PB_ENTRIES[x]),',0,',pbPhoneBook[x+nBaseEntry-1].name"
							case pbFolder: send_command vdvTP,"'^TXT-',itoa(VTC_PB_ENTRIES[x]),',0,',pbPhoneBookFolder[x+nBaseEntry-1].name"
						}
					}
				}
			}
			case VTC_PB_DOWN:
			{
				if(nBaseEntry<nPhoneBookEntries)
				{
					nBaseEntry++
					for(x=1;x<=length_array(VTC_PB_ENTRIES);x++)
					{
						switch(nResultType)
						{
							case pbContact: send_command vdvTP,"'^TXT-',itoa(VTC_PB_ENTRIES[x]),',0,',pbPhoneBook[x+nBaseEntry-1].name"
							case pbFolder: send_command vdvTP,"'^TXT-',itoa(VTC_PB_ENTRIES[x]),',0,',pbPhoneBookFolder[x+nBaseEntry-1].name"
						}
					}
				}
			}	
			case VTC_PB_1:
			case VTC_PB_2:
			case VTC_PB_3:
			case VTC_PB_4:
			case VTC_PB_5:
			case VTC_PB_6:
			case VTC_PB_7: 
			{
				switch(nPBType)
				{
					case pbLocal: send_string dvVTC,"'xCommand Dial Number:',pbPhoneBook[nChnl-VTC_PB_1+nBaseEntry].number,$0D,$0A"
					case pbCorporate:
					{
						switch(nResultType)
						{
							case pbFolder:
							{
								init_phonebook_query()
								send_string dvVTC, "'xCommand Phonebook Search PhonebookType:',cPBType[nPBType],' FolderID:',pbPhoneBookFolder[nChnl-VTC_PB_1+nBaseEntry].folderID,' SearchString:""',$0D,$0A"
							}
							case pbContact:
							{
								send_string dvVTC,"'xCommand Dial Number:',pbPhoneBook[nChnl-VTC_PB_1+nBaseEntry].number,$0D,$0A"
							}
						}
					}
				}
			}
			case VTC_PB_LOCAL: 
			{
				nPBType=pbLocal
				pulse[vdvVTC,VTC_PB_REFRESH]
			}
			case VTC_PB_CORPORATE: 
			{
				nPBType=pbCorporate
				pulse[vdvVTC,VTC_PB_REFRESH]
			}
			case VTC_PB_SEARCH:
			{
				send_command vdvTP,"'@AKB-;Enter Search String'"
			}
		}              
	}
} 



(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program

[vdvTP,VTC_PB_LOCAL]=nPBType=pbLocal
[vdvTP,VTC_PB_CORPORATE]=nPBType=pbCorporate

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
