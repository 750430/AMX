MODULE_NAME='iPort_UI' (DEV vdviPort, DEV dvTP[], INTEGER TP_BUTTONS[],INTEGER TP_FIELDS[], INTEGER TP_LEVELS[], INTEGER nLISTS[],
			INTEGER nR4_DMS_Port1, INTEGER nR4_DMS_Port2) //Added TP_LEVELS Edit v1_1 8-18-2006 - Added R4 ports in v3.21

(***********************************************************)
(*  FILE CREATED ON: 08/28/2005  AT: 19:00:15              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 07/23/2009  AT: 14:08:16        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)

//UI Version 3.24 release 02/2011
//Current iPod Firmware Tested: iPhone v4.2.1
//Tested with FS-22

//--Current iPort Firmware Tested: 3.07 on IW22 - 1.07 on FS22
//--Many of the programming methods follow the G3 usage so this module can be used for both G3 and G4 panels and now the MIO-DMS and MIO-R4
//--If using the MIO-DMS non-pinnacle you can set nDOUBLE_PUSH = 1 anywhere it appears and comment it in if so desired - this allows quick navigation to the bottom and top of the list
//--On the hold of a selection the selection will start to play all files within that list selection - 
// so if one pushes and holds an album selection it will start to play all the songs on that album.
//--The list size on the touch panels and DMS must be all the same.
//--One COMM file and only one UI file per iPort.
//--There is a known bug with the Audiobooks option that starts playing the first Audiobook when selected


DEFINE_DEVICE


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

//LstLength  = 8     // - Length of list on TP - old v1.0 beta way
LstRepeat  = 2     // - Repeat default setting
LstShuffle = 3    // - Shuffle Default setting

Name_TL1 = 1	//Timeline Name_TL1

WC_FORMAT_UTF8          = 3 	 //Unicode format type
WC_FORMAT_TP            = 100	//Unicode format type for panels

//R4_DMS_PORT1	=	nR4_DMS_PORT1
//R4_DMS_PORT2	=	nR4_DMS_PORT2

(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE


VOLATILE INTEGER nNOW_PLAYING          // FLAG TRACKS WHEN IPORT NOW PLAYING POPUP IS ON

VOLATILE INTEGER nDebug_Level = 0
VOLATILE INTEGER nPLAY_STATE = 0       // 1=PLAY, 0=PAUSE
VOLATILE INTEGER nONLINE = 0
VOLATILE INTEGER nFF_RWD_ON = 0		  //Is FForward or Rewind occurring?
VOLATILE INTEGER nREPEAT_ON = 0		 //Is Repeat occurring?
VOLATILE INTEGER nSHUFFLE_ON = 0	//Is Shuffle occurring?

VOLATILE CHAR strRESPONSE[6000]

VOLATILE INTEGER nSLIDER_LEVEL = 0
VOLATILE INTEGER nTIME_LEVEL = 0
VOLATILE INTEGER nKEY_PRESSED = 0       // TP PRESSED
VOLATILE INTEGER nRUN_ONCEa = 0
VOLATILE INTEGER nRUN_ONCEb = 0
VOLATILE INTEGER nRECORD_LEVEL[2]
VOLATILE INTEGER nHOLD = 0 // was button held down
VOLATILE INTEGER nDOUBLE_PUSH = 0 // was button pushed and then pushed again under a second
VOLATILE INTEGER nVIDEO_MENU = 0

VOLATILE INTEGER nCURRENT_INDEX_NUM[5]
VOLATILE INTEGER nMENU_RECORD_COUNT[5]	//Total number of records in the given menu 
VOLATILE INTEGER nTOTAL_CURRENT_SONGS = 0
VOLATILE INTEGER nCURRENT_INDEX_START = 0 //where list starts to report - incremented after each Database Record is returned
VOLATILE INTEGER nCURRENT_INDEX_TOTAL = 0
//VOLATILE INTEGER nCURRENT_INDEX_HILITE = 0
VOLATILE INTEGER nCURRENT_INDEX_LENGTH = 0	//List Length  - default is 10 - populated by UI_LIST Variable passed in define module for UI
VOLATILE INTEGER nCURRENT_MENU = 1
VOLATILE CHAR cCURRENT_SONG_LENGTH[8]		//'PLAYBACK_SONG_LENGTH='
VOLATILE CHAR cCURRENT_PLAYING_INDEX_NUM[8] // !! R !! WAS 5
VOLATILE INTEGER nSONG_SECONDS_LEVEL = 0
VOLATILE CHAR cINDEX_LIST_1[5][2][10][30]// MAX list size is 10 - if this UI runs a G4 panel then the Fourth array parameter can be extended to 200
(***************************************
The cINDEX_LIST_1 array is set up to record the ID numbers and info pertaining to that ID that is returned from the iPod for each menu and is set up as follows:

[5] 5 different menus of information. If one selects Playlist it will actually only use 3 of the menus – Songs will only use 2 – Artists will use 4 - Albums and videos use 5.

[2] 2 types of information in each menu – ID number[1] and either Song, Album, or Artist [2]. This info in [2] is sent to the Touch Panels when a list is produced or on the push of the Menu button.

[10] This is the list length of each menu. This can be set the same as the TP_UI_list variable in the Main.axs actually.

[30] The max character length of the information – set to 30 for the DMS length – G3 panels max is 39 – G4 panels max is 200
***************************************)

VOLATILE INTEGER nCURRENT_CATEGORY_START = 0 	//Category that was selected on the first menu eg: Playlists=1, Artists=2, Etc.
VOLATILE INTEGER nCURRENT_CATEGORY[5] 	       //Holds selection for each menu page
VOLATILE INTEGER nCURRENT_CATEGORY2[5]
VOLATILE INTEGER nCHANGE = 0
VOLATILE INTEGER nFLAG = 0
VOLATILE INTEGER nONLINE_FLAG = 0
VOLATILE INTEGER nWAIT_FLAG = 0
VOLATILE INTEGER nLEVEL_FLAG = 0
VOLATILE INTEGER nSELECT_FLAG = 0
VOLATILE CHAR cDIRECT_SELECTION[4] 
LONG Name_TimeArray[]	= {10000}//Time array set to poll every 10 seconds @ 10000 - 1 second = 1000
VOLATILE CHAR cMenu0[8][11] = {'Playlists','Artists','Albums','Genres','Songs','Composers','Audio Books','Podcasts'}
VOLATILE CHAR cMenu_VIDEOS[4][14] = {'Movies','Music Videos','TV Shows','Video Podcasts'} //Text sent to 
VOLATILE INTEGER nCURRENT_TP_PORT //Current Touch Panel port - used to determine which device port to send page flips when using more than 1 iPort on a DMS
VOLATILE INTEGER nDEV_LENGTH = 0
VOLATILE INTEGER nON_IPORT_PAGE[30] // 0 = Panel off page - 1 = on iPort Page
VOLATILE INTEGER nNO_ALBUM = 0
(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

DEFINE_FUNCTION DEBUG (INTEGER Priority, CHAR strMSG[]) //Debug messages
{
    If((Priority >= nDebug_Level) && (nDebug_Level > 0))
    {
        SEND_STRING 0, "'iPort_UI: ',strMSG"
    }
}

DEFINE_FUNCTION SEND_VTEXT (INTEGER nCHAN, CHAR strMSG[]) //All variable text to panel is sent thru this function
{
    STACK_VAR WIDECHAR strSTRING1[600]
    STACK_VAR CHAR strSTRING2[600]
    STACK_VAR INTEGER iTEXT
       
    strSTRING1 = WC_DECODE(strMSG,WC_FORMAT_UTF8,1) // Used to Decode 
    strSTRING2 = WC_ENCODE(strSTRING1,WC_FORMAT_TP,1)
    
    
    FOR(itext = 1;iTEXT <= nDEV_LENGTH;iTEXT++) //Check to see if G3 or G4 panel to send correct text command
    {
	//SEND_STRING 0,"'R4 Device_ID = ',ITOA(DEVICE_ID(dvTP[3]))" //R4 Device is 322
	IF(DEVICE_ID(dvTP[iTEXT]) < 256) //Is it a G3 Panel in the array?
	{
	    IF(nON_IPORT_PAGE[iTEXT] = 1) // Is the Panel currently on the iPort page?
	    {
		SEND_COMMAND dvTP[iTEXT], "'TEXT',ITOA(nCHAN),'-',strMSG"        //G3 Panels without Unicode Support
	    }							     		//NOTE: Unicode not supported on G3 panels
	}
	ELSE //It must be a Modero Panel and not a G3 panel
	{
	    IF(nON_IPORT_PAGE[iTEXT] = 1) // Is the Panel currently on the iPort page?
	    {
		(*IF(DEVICE_ID(dvTP[iTEXT]) = 322) //Is it an R4 Remote in the array?
		{
		    //Send Nothing - Use Virtual R4 in Main.axs in DEV array for iPort UI devices
		}
		ELSE
		{*)
		    SEND_COMMAND dvTP[iTEXT], "'^UNI-',ITOA(nCHAN),',0,',strSTRING2"   //Unicode Modero Panels
		    //SEND_COMMAND dvTP,"'^TXT-',ITOA(nCHAN),',1&2,',strMSG"      // G4 panels without Unicode
		//}
	    }
	}
    }
}

DEFINE_FUNCTION SEND_CMD (CHAR strCMD[]) //Commands sent to COMM module
{
    Send_Command vdviPort, strCMD
}

DEFINE_FUNCTION fnDO_FEEDBACK() //Feedback for panel channels is sent thru this function
{
(***** BUTTON FEEDBACK *****)
    [dvTP,TP_BUTTONS[2]] = nSELECT_FLAG
    [dvTP,TP_BUTTONS[3]]  = (nPLAY_STATE == 1)        // PLAY/PAUSE button
    [dvTP,TP_BUTTONS[4]] = (nONLINE == 1)	     // Online Status button
    [dvTP,TP_BUTTONS[5]] = (nFF_RWD_ON == 1)	    // Fast Forward button
    [dvTP,TP_BUTTONS[6]] = (nFF_RWD_ON == 2)	   // Rewind button
    [dvTP,TP_BUTTONS[23]] = (nREPEAT_ON > 0)	  // Repeat button
    [dvTP,TP_BUTTONS[24]] = (nSHUFFLE_ON > 0)	 // Shuffle button
    SWITCH(nREPEAT_ON) 				//Which Repeat?
    {
	CASE 0:
	{
	    SEND_VTEXT(TP_FIELDS[17],'REPEAT|OFF')
	}
	CASE 1:
	{
	    SEND_VTEXT(TP_FIELDS[17],'REPEAT|TRACK')
	}
	CASE 2:
	{
	    SEND_VTEXT(TP_FIELDS[17],'REPEAT|ALL')
	}
    }
    SWITCH(nSHUFFLE_ON)				//Which Shuffle?
    {
	CASE 0:
	{
	    SEND_VTEXT(TP_FIELDS[18],'SHUFFLE|OFF')
	}
	CASE 1:
	{
	    SEND_VTEXT(TP_FIELDS[18],'SHUFFLE|SONGS')
	}
	CASE 2:
	{
	    SEND_VTEXT(TP_FIELDS[18],'SHUFFLE|ALBUMS')
	}
    }
}

DEFINE_FUNCTION PROCESS_RESPONSE()	// Process the responses from the COMM 
{
    CHAR strTEMP_STRING[50]
    
    nONLINE_FLAG = 0
    strTEMP_STRING = REMOVE_STRING(strRESPONSE,'=',1)     // GET RETURNED STRING
                                                          // WHAT IS LEFT IS PARAMETER LIST
    SWITCH(strTEMP_STRING)
    {
        CASE 'IPOD_NAME=':	//COMM Returned iPod name
	{
	    STACK_VAR CHAR ciPodName[40]
	    ciPodName = strRESPONSE
	    SEND_VTEXT(TP_FIELDS[1],ciPodName)
	    nONLINE = 1
	    fnDO_FEEDBACK()
	    IF(ciPodName = '') //Send the command till it gets the iPod name
	    {
		SEND_CMD("'REQUEST_IPOD_NAME?'")
	    }
	}
	CASE 'ALBUM_NAME=':	//COMM Returned Album name
	{
	    STACK_VAR CHAR cAlbumName[30]
	    cAlbumName = strRESPONSE
	    SEND_VTEXT(TP_FIELDS[14],cAlbumName) // Send it to the touch panel
	}
	CASE 'TITLE_NAME=':	//COMM Returned Track name
	{
	    STACK_VAR CHAR cTrackName[50]
	    cTrackName = strRESPONSE
	    SEND_VTEXT(TP_FIELDS[15],cTrackName) // Send it to the touch panel
	}
	CASE 'ARTIST_NAME=':	//COMM Returned Artist name
	{
	    STACK_VAR CHAR cArtistName[30]
	    cArtistName = strRESPONSE
	    SEND_VTEXT(TP_FIELDS[13],cArtistName) // Send it to the touch panel
	}
	CASE 'NUM_PLAYING_SONGS=':	//COMM Returned Number of playing songs
	{
		STACK_VAR INTEGER nCONVERT
		
	    nTOTAL_CURRENT_SONGS = ATOI(strRESPONSE)
		nCONVERT=ATOI(cCURRENT_PLAYING_INDEX_NUM) 
	    SEND_VTEXT(TP_FIELDS[12],"ITOA(nCONVERT+1),' / ',ITOA(nTOTAL_CURRENT_SONGS)") 
	}
	CASE 'UI_MODE=': //Online or offline
	{
	    STACK_VAR INTEGER UIMode
	    UIMode = ATOI(strRESPONSE)
	    SWITCH(UIMode)
	    {
		CASE 1: //Online
		{
		    nONLINE = 1
		    fnUpdate_Info_Online()
		    nRUN_ONCEb = 0
		    nONLINE_FLAG = 0
		}
		
		CASE 0: //Offline
		{
		    nONLINE = 0
		    nRUN_ONCEa = 0
		    nRUN_ONCEb = 0
		    fnUpdate_Info_Offline()
		}
	    }
	}
	
	CASE 'IPOD_DOCK_STATUS=': //Online or offline when docked - added v1.2 - 09-15-2006
	{
	    STACK_VAR INTEGER DockStatus
	    DockStatus = ATOI(strRESPONSE)
	    SWITCH(DockStatus)
	    {
		CASE 1: //Online
		{
		    nONLINE = 1
		    fnUpdate_Info_Online()
		    nRUN_ONCEb = 0
		    nONLINE_FLAG = 0
		}
		
		CASE 0: //Offline
		{
		    nONLINE = 0
		    nRUN_ONCEa = 0
		    nRUN_ONCEb = 0
		    fnUpdate_Info_Offline()
		}
	    }
	}
	CASE 'IPORT_FIRMWARE=':	//COMM Returned iPort Firmware Version
	{
	    SEND_CMD("'REQUEST_REMOTE_UI_MODE?'") //Check for iPod Online
	    //nONLINE_FLAG = 1 //v3.22 commented out
	    SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=0'") //Restart Time return
	    WAIT 90
	    IF(nONLINE_FLAG)
	    {
		nONLINE = 0
		fnDO_FEEDBACK()
		nRUN_ONCEa = 0
	    }
	}
	
	CASE 'PLAY_STATUS=': //Current playback status
	{
	    STACK_VAR INTEGER PLAYMode
	    PLAYMode = ATOI(strRESPONSE)
	    SWITCH(PLAYMode)
	    {
		CASE 0:		//Stopped
		{
		    SEND_VTEXT(TP_FIELDS[19],'w') // w = stop icon with AMXBOLD font
		    OFF[dvTP,TP_BUTTONS[3]] //turns DMS play button OFF
		}
		
		CASE 1:		//Playing
		{
		    SEND_VTEXT(TP_FIELDS[19],'q') // q = play icon with AMXBOLD font
		    ON[dvTP,TP_BUTTONS[3]] //turns DMS play button ON
		}
		
		CASE 2:		//Paused
		{
		     SEND_VTEXT(TP_FIELDS[19],'e') // e = pause icon with AMXBOLD font
		     OFF[dvTP,TP_BUTTONS[3]] //turns DMS play button OFF
		}
		
		CASE 3:		//Error
		{
		    SEND_VTEXT(TP_FIELDS[19],'A') // A = AMX icon with AMXBOLD font
		    OFF[dvTP,TP_BUTTONS[3]] //turns DMS play button OFF
		}
	    }
	}
	
	CASE 'REPEAT_STATUS=': //Current repeating status
	{
	    STACK_VAR INTEGER nRepeatMode
	    nRepeatMode = ATOI(strRESPONSE)
	    SWITCH(nRepeatMode)
	    {
		CASE 0:		//Repeat Off
		{
		    nREPEAT_ON = 0
		    fnDO_FEEDBACK()
		}
		
		CASE 1:		//Repeat one track
		{
		    nREPEAT_ON = 1
		    fnDO_FEEDBACK()
		}
		
		CASE 2:		//Repeat All
		{
		     nREPEAT_ON = 2
		    fnDO_FEEDBACK()
		}
	    }
	}
	
	CASE 'SHUFFLE_STATUS=':
	{
	    STACK_VAR INTEGER nShuffleMode
	    nShuffleMode = ATOI(strRESPONSE)
	    SWITCH(nShuffleMode)
	    {
		CASE 0:		//Shuffle Off
		{
		    nSHUFFLE_ON = 0
		    fnDO_FEEDBACK()
		}
		
		CASE 1:		//Shuffle songs
		{
		    nSHUFFLE_ON = 1
		    fnDO_FEEDBACK()
		}
		
		CASE 2:		//Shuffle Albums
		{
		     nSHUFFLE_ON = 2
		    fnDO_FEEDBACK()
		}
	    }
	}
	
	CASE 'PLAYBACK_SONG_CHANGED=':	//COMM Returned Playback Song Change
	{
	    cCURRENT_PLAYING_INDEX_NUM = ''
	    cCURRENT_PLAYING_INDEX_NUM = strRESPONSE
	    nONLINE = 1
	    fnDO_FEEDBACK()
	    SEND_CMD("'GET_INDEXED_PLAYING_SONG_INFO?',cCURRENT_PLAYING_INDEX_NUM")
	    WAIT 2
	    SEND_CMD("'GET_NUM_PLAYING_SONGS?'")
	}
	
	CASE 'PLAYBACK_SONG_POSITION_CHANGE=':	//COMM Returned Current song time passing
	{
	    STACK_VAR CHAR cSongTime[8]
	    INTEGER nTHour
	    INTEGER nTMinute
	    INTEGER nTSecond
	    STACK_VAR INTEGER iTEXT
	    
	    cSongTime = strRESPONSE
	    //SEND_VTEXT(TP_FIELDS[16],"cSongTime,'/',cCURRENT_SONG_LENGTH")  // 
	    nTHour = ATOI(REMOVE_STRING(cSongTime,':',1))
	    nTMinute = ATOI(REMOVE_STRING(cSongTime,':',1))
	    nTSecond = ATOI(cSongTime)
	    nTSecond = ((nTHour * 3600)+(nTMinute * 60)+ nTSecond)
	    
		//strSTRING1 = WC_DECODE(strMSG,WC_FORMAT_UTF8,1) // Used to Decode 
		//strSTRING2 = WC_ENCODE(strSTRING1,WC_FORMAT_TP,1)
		
		FOR(itext = 1;iTEXT <= nDEV_LENGTH;iTEXT++) //Check to see if G3 or G4 panel to send correct text command
		{

		    IF(DEVICE_ID(dvTP[iTEXT]) < 256) //Is it a G3 Panel in the array?
		    {
			IF(nON_IPORT_PAGE[iTEXT] = 1) // Is the Panel currently on the iPort page?
			{
			    SEND_COMMAND dvTP[iTEXT], "'TEXT',ITOA(TP_FIELDS[16]),'-',strRESPONSE,'/',cCURRENT_SONG_LENGTH"        //G3 Panels without Unicode Support
			    IF(nSONG_SECONDS_LEVEL = 0)
			    {
				//Do nothing - made to fix divide by 0 runtime errors
			    }
			    ELSE
			    {
				SEND_LEVEL dvTP,TP_LEVELS[2],((100-(nSONG_SECONDS_LEVEL - nTSecond)*100/nSONG_SECONDS_LEVEL)*255/100)
			    }
			}
			
			//NOTE: Unicode not supported on G3 panels
		    }
		    ELSE //It must be a Modero Panel and not a G3 panel
		    {
			IF(nON_IPORT_PAGE[iTEXT] = 1) // Is the Panel currently on the iPort page?
			{
			    IF((DEVICE_ID(dvTP[iTEXT]) = 322) OR (DEVICE_ID(dvTP[iTEXT]) = 65534)) //Is it an R4 Remote or virtual device in the array?
			    {
				//Send No Level or Text Level updates to R4 physical or virtual
			    }
			    ELSE
			    {
				SEND_COMMAND dvTP[iTEXT], "'^TXT-',ITOA(TP_FIELDS[16]),',0,',strRESPONSE,'/',cCURRENT_SONG_LENGTH"   //Standard Text on time return for Modero Panels
				
				IF(nSONG_SECONDS_LEVEL = 0)
				{
				    //Do nothing - made to fix divide by 0 runtime errors
				}
				ELSE
				{
				    SEND_LEVEL dvTP,TP_LEVELS[2],((100-(nSONG_SECONDS_LEVEL - nTSecond)*100/nSONG_SECONDS_LEVEL)*255/100)
				}
			    }
			}
		    }
		}
	}
	
	CASE 'PLAYBACK_SONG_LENGTH=':	//COMM Returned Current song time Length
	{
	    INTEGER nLHour
	    INTEGER nLMinute
	    INTEGER nLSecond
	    CHAR cSongLength[8]
	    
	    cCURRENT_SONG_LENGTH = strRESPONSE
	    //SEND_VTEXT(TP_FIELDS[16],cSongTime)
	    cSongLength = strRESPONSE
	    nLHour = ATOI(REMOVE_STRING(cSongLength,':',1))
	    nLMinute = ATOI(REMOVE_STRING(cSongLength,':',1))
	    nLSecond = ATOI(cSongLength)
	    nSONG_SECONDS_LEVEL = ((nLHour * 3600)+(nLMinute * 60)+ nLSecond)
	   
	}
	
	CASE 'CURRENT_PLAYING_SONG_INDEX=':	//COMM Returned Playback Song Change
	{
	    cCURRENT_PLAYING_INDEX_NUM = ''
	    cCURRENT_PLAYING_INDEX_NUM = strRESPONSE
	    nONLINE = 1
	    fnDO_FEEDBACK()
	    SEND_CMD("'GET_INDEXED_PLAYING_SONG_INFO?',cCURRENT_PLAYING_INDEX_NUM")
	    WAIT 2
	    SEND_CMD("'GET_NUM_PLAYING_SONGS?'")
	}
	
	CASE 'NUMBER_DB_RECORDS=': //COMM returned the number of records in the selected list
	{
	    SEND_LEVEL dvTP,TP_LEVELS[1],0 //Reset level on list bargraph - Edit v1_1 8-18-2006
	    nMENU_RECORD_COUNT[nCURRENT_MENU] = ATOI(strRESPONSE)
	    
	    IF (nMENU_RECORD_COUNT[nCURRENT_MENU] < 255)
	    {
		SEND_VTEXT(TP_FIELDS[20],"'1 / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") 
	    }
	    ELSE
	    {
		SEND_VTEXT(TP_FIELDS[20],"'1 / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") 
	    }
	    IF (nMENU_RECORD_COUNT[nCURRENT_MENU]>= 0)
	    {
		SWITCH(nCURRENT_MENU) //Which Menu is selected?
		{
		    CASE 2: // first menu after main menu
		    {
			IF(nCURRENT_CATEGORY_START = 1)  //If current category selected is Playlists
			{
			    nMENU_RECORD_COUNT[nCURRENT_MENU] -- // added - 1 to fix lists under 10 not showing in Playlists
			    nCURRENT_INDEX_NUM[nCURRENT_MENU] ++ //Added +1 to start Playlists after iPod Name playlist defect
			    SEND_VTEXT(TP_FIELDS[20],"'1 / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])")
			}
			IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
			{
			    
			    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY_START),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]-1),':',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)") // -1
			    nCURRENT_CATEGORY2[2] = nCURRENT_CATEGORY_START
			    nCURRENT_INDEX_START = 0
			}
			ELSE
			{
			    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY_START),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]-1),':',ITOA(nCURRENT_INDEX_LENGTH-1)") // -1
			    nCURRENT_CATEGORY2[2] = nCURRENT_CATEGORY_START
			    nCURRENT_INDEX_START = 0
			}
		    }
		    CASE 3: // Second Menu after start
		    {
			IF(nSELECT_FLAG) //Direct Select was enabled
			{
			    cDIRECT_SELECTION = cINDEX_LIST_1[2][2][nCURRENT_CATEGORY[1]]
			    //SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[3][2][nCURRENT_CATEGORY[1]]")
			    SEND_CMD("'PLAY_CURRENT_SELECTION=',cDIRECT_SELECTION")
			    nSELECT_FLAG = 0
			}
			SWITCH(nCURRENT_CATEGORY_START)
			{
			    CASE 1: //Playlist goes to Songs(5) on 2nd Menu
			    {
				IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)")// -1
				    nCURRENT_CATEGORY2[3] = 5
				    nCURRENT_INDEX_START = 0
				}
				ELSE
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nCURRENT_INDEX_LENGTH-1)")// -1
				    //SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5',':',ITOA(nCURRENT_INDEX_NUM),':',ITOA(nCURRENT_INDEX_LENGTH)")
				    nCURRENT_CATEGORY2[3] = 5
				    nCURRENT_INDEX_START = 0
				}
			    }
			    
			    CASE 2: //Artists goes to Albums(3) on 2nd Menu
			    {
				IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH) //is there less albums in the database for this artist than the total list length?
				{
				    IF(nMENU_RECORD_COUNT[nCURRENT_MENU] <= 1) //Send it to songs if there is 1 album or less
				    {
					//SEND_VTEXT(TP_FIELDS[2],'ALL')
					nCURRENT_CATEGORY2[3] = 3 //Current category on Menu 3 is 3 or Albums
					nCURRENT_INDEX_START = 0 //Reset counter for list return to 0
					SEND_CMD("'SELECT_DB_RECORD=3:0'") //Select Albums from this artist
					WAIT 2 
					SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?5'") // Look for number of Songs in the selected Artist 
					fnCLEAR_LIST()
					nCURRENT_MENU++ //Jump a menu
					nNO_ALBUM = 1 // Set for when going back it will go to Artists list
				    }
				    ELSE //there were more than 1 albums per this artist - show me the albums
				    {
					//SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?3:0:1'")
					SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?3:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)") // -1
					nCURRENT_CATEGORY2[3] = 3
					nCURRENT_INDEX_START = 0
				    }
				}
				ELSE //More albums in the list than the total List length
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?3:0:',ITOA(nCURRENT_INDEX_LENGTH-1)") // -1
				    //SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?3',':',ITOA(nCURRENT_INDEX_NUM),':',ITOA(nCURRENT_INDEX_LENGTH)")
				    nCURRENT_CATEGORY2[3] = 3
				    nCURRENT_INDEX_START = 0
				}
			    }
			    
			    CASE 3: //Albums goes to Songs(5) on 2nd Menu
			    {
				IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)") // -1
				    nCURRENT_CATEGORY2[3] = 5
				    nCURRENT_INDEX_START = 0
				}
				ELSE
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nCURRENT_INDEX_LENGTH-1)") // -1
				    nCURRENT_CATEGORY2[3] = 5
				    nCURRENT_INDEX_START = 0
				}
			    }
			    
			    CASE 4: //Genres goes to Artists(2) on 2nd Menu
			    {
				SWITCH(nVIDEO_MENU)
				{
				    CASE 0: 	//Music
				    CASE 2:    //Music Videos
				    CASE 3:   //TV Shows
				    CASE 4:  //Video Podcasts
				    {
					IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
					{
					    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?2:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)")// -1
					    nCURRENT_CATEGORY2[3] = 2
					    nCURRENT_INDEX_START = 0
					}
					ELSE
					{
					    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?2:0:',ITOA(nCURRENT_INDEX_LENGTH-1)") // -1
					    nCURRENT_CATEGORY2[3] = 2
					    nCURRENT_INDEX_START = 0
					}
				    }
				    CASE 1: //Movies
				    {
					IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
					{
					    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)")// -1
					    nCURRENT_CATEGORY2[3] = 5
					    nCURRENT_INDEX_START = 0
					}
					ELSE
					{
					    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nCURRENT_INDEX_LENGTH-1)") // -1
					    nCURRENT_CATEGORY2[3] = 5
					    nCURRENT_INDEX_START = 0
					}
				    }
				}
			    }
			    
			    CASE 5: //Songs is on Songs now- Use Play_current_selection=index# now
			    {
				// Should be playing SEND_CMD("'PLAY_CURRENT_SELECTION=',ITOA(nCURRENT_CATEGORY_START),':',ITOA(nCURRENT_INDEX_NUM),':6'")
				nCURRENT_INDEX_START = 0
			    }
			    
			    CASE 6: //Composers goes to Songs(5) on 2nd Menu
			    {
				IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)")// -1
				    nCURRENT_CATEGORY2[3] = 5
				    nCURRENT_INDEX_START = 0
				}
				ELSE
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nCURRENT_INDEX_LENGTH-1)")// -1
				    nCURRENT_CATEGORY2[3] = 5
				    nCURRENT_INDEX_START = 0
				}
			    }
			    CASE 7: //Audiobooks goes to Songs(5) on 2nd Menu
			    {
				IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)")// -1
				    nCURRENT_CATEGORY2[3] = 5
				    nCURRENT_INDEX_START = 0
				}
				ELSE
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nCURRENT_INDEX_LENGTH-1)")// -1
				    nCURRENT_CATEGORY2[3] = 5
				    nCURRENT_INDEX_START = 0
				}
			    }	
			    CASE 8: //Composers goes to Songs(5) on 2nd Menu
			    {
				IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)")// -1
				    nCURRENT_CATEGORY2[3] = 5
				    nCURRENT_INDEX_START = 0
				}
				ELSE
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nCURRENT_INDEX_LENGTH-1)")// -1
				    nCURRENT_CATEGORY2[3] = 5
				    nCURRENT_INDEX_START = 0
				}
			    }		
			}
		    }
		    CASE 4:
		    {
			IF(nSELECT_FLAG)
			{
			    SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[3][2][nCURRENT_CATEGORY[2]]")
			    nSELECT_FLAG = 0
			}
			SWITCH(nCURRENT_CATEGORY_START)
			{
			    CASE 2: //Artists goes to Songs here
			    {
				IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)")// -1
				    nCURRENT_CATEGORY2[4] = 5
				    nCURRENT_INDEX_START = 0
				}
				ELSE
				{
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nCURRENT_INDEX_LENGTH-1)")// -1
				    nCURRENT_CATEGORY2[4] = 5
				    nCURRENT_INDEX_START = 0
				}
			    }
			    CASE 4: // Genres goes to Albums here
			    {
				SWITCH(nVIDEO_MENU)
				{
				    CASE 0: 	//Music
				    CASE 3:    //TV Shows
				    {
					IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
					{
					    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?3:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)")// -1
					    nCURRENT_CATEGORY2[4] = 5
					    nCURRENT_INDEX_START = 0
					}
					ELSE
					{
					    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?3:0:',ITOA(nCURRENT_INDEX_LENGTH-1)")// -1
					    nCURRENT_CATEGORY2[4] = 5
					    nCURRENT_INDEX_START = 0
					}
				    }
				    CASE 2: //Music Videos
				    CASE 4: //Video Podcasts
				    {
					IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
					{
					    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)")// -1
					    nCURRENT_CATEGORY2[5] = 5
					    nCURRENT_INDEX_START = 0
					}
					ELSE
					{
					    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nCURRENT_INDEX_LENGTH-1)")// -1
					    nCURRENT_CATEGORY2[5] = 5
					    nCURRENT_INDEX_START = 0
					}
				    }
				}
			    }
			}
		    }
		    CASE 5: //Genres goes to Songs here
		    {
			IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
			{
			    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)")// -1
			    nCURRENT_CATEGORY2[5] = 5
			    nCURRENT_INDEX_START = 0
			}
			ELSE
			{
			    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?5:0:',ITOA(nCURRENT_INDEX_LENGTH-1)")// -1
			    nCURRENT_CATEGORY2[5] = 5
			    nCURRENT_INDEX_START = 0
			}
		    }
		}
	    }
	    ELSE
	    {
		SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY_START),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),':',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]-1)")// -1
	    }
	    
	}
	
	CASE 'DATABASE_RECORD=': // COMM returned database record
	{
	    STACK_VAR INTEGER i
	    CHAR cRecordIndex[5]
	    CHAR cRecord[50] //With DMS this will need to be set lower for word wrap options not to take up 3 lines with records
	    CHAR cTrash[5]
	    
	    cTrash = REMOVE_STRING(strRESPONSE,':',1)
	    cRecordIndex = REMOVE_STRING(strRESPONSE, ':',1)
	    cRecord = strRESPONSE
	    
	    IF(nCURRENT_INDEX_START >= nCURRENT_INDEX_LENGTH)
	    {
		nCURRENT_INDEX_START = 0
		nWAIT_FLAG = 0
	    }
	    
	    IF(nFLAG = 0) //Populate the Index Array
	    {
		nCURRENT_INDEX_START ++
		i = nCURRENT_INDEX_START
		cINDEX_LIST_1[nCURRENT_MENU][1][i] = cRecord		//This is the record that was returned
		cINDEX_LIST_1[nCURRENT_MENU][2][i] = cRecordIndex      //This is the Record Index or ID returned
	    }
	    SEND_VTEXT(TP_FIELDS[(i+1)],cRecord) //Send the record to the touch panel 
	}
    }
    CLEAR_BUFFER strRESPONSE
}

DEFINE_FUNCTION fnUpdate_Info_Online()
{
	IF(!nRUN_ONCEa)
	{
	    cINDEX_LIST_1[1][1][1] = cMenu0[1]
	    cINDEX_LIST_1[1][1][2] = cMenu0[2]
	    cINDEX_LIST_1[1][1][3] = cMenu0[3]
	    cINDEX_LIST_1[1][1][4] = cMenu0[4]
	    cINDEX_LIST_1[1][1][5] = cMenu0[5]
	    cINDEX_LIST_1[1][1][6] = cMenu0[6]
	    cINDEX_LIST_1[1][1][7] = cMenu0[7]
	    cINDEX_LIST_1[1][1][8] = cMenu0[8]
	    SEND_VTEXT(TP_FIELDS[2],'Playlists')
	    SEND_VTEXT(TP_FIELDS[3],'Artists')
	    SEND_VTEXT(TP_FIELDS[4],'Albums')
	    SEND_VTEXT(TP_FIELDS[5],'Genres')
	    SEND_VTEXT(TP_FIELDS[6],'Songs')
	    SEND_VTEXT(TP_FIELDS[7],'Composers')
	    SEND_VTEXT(TP_FIELDS[8],'Audiobooks') 
	    SEND_VTEXT(TP_FIELDS[9],'Podcasts')
	    SEND_VTEXT(TP_FIELDS[10],'')
	    SEND_VTEXT(TP_FIELDS[11],'')
	    SEND_VTEXT(TP_FIELDS[21],"'pick an option from below'")
	    SEND_CMD("'REQUEST_IPOD_NAME?'")
	    WAIT 5
	    SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //=1 ON, =0 OFF - Sets Unsolictied feedback of time and record index on song change
	    nRUN_ONCEa = 1
	    nCURRENT_INDEX_NUM[1] = 1
	    nCURRENT_INDEX_NUM[2] = 1
	    nCURRENT_INDEX_NUM[3] = 1
	    nCURRENT_INDEX_NUM[4] = 1
	    nCURRENT_INDEX_NUM[5] = 1
	    nCURRENT_MENU = 1
	    //fnINDEX_HILITE(1)
	    fnDO_FEEDBACK()
	    SEND_LEVEL dvTP,TP_LEVELS[1],0
	    SEND_COMMAND dvTP,'@PPN-SONG DETAILS;iPort Main' 
	    SEND_COMMAND dvTP, '@PPF-Eject;iPort'    // Popup eject off
	    WAIT 8
	    SEND_CMD("'GET_PLAY_STATUS?'")
	    WAIT 11
	    SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
	    WAIT 14
	    SEND_CMD('RESET_DB_SELECTION=0')
	    WAIT 16
	    SEND_CMD("'GET_REPEAT?'")
	    WAIT 19
	    SEND_CMD("'GET_SHUFFLE?'")
	    OFF[nNOW_PLAYING]
	}
}

DEFINE_FUNCTION fnUpdate_Info_Offline()
{

    IF(!nRUN_ONCEb)
    {
	SEND_VTEXT(TP_FIELDS[1],'Offline')
	SEND_VTEXT(TP_FIELDS[2],'')
	SEND_VTEXT(TP_FIELDS[3],'')
	SEND_VTEXT(TP_FIELDS[4],'')
	SEND_VTEXT(TP_FIELDS[5],'')
	SEND_VTEXT(TP_FIELDS[6],'')
	SEND_VTEXT(TP_FIELDS[7],'')
	SEND_VTEXT(TP_FIELDS[8],'')
	SEND_VTEXT(TP_FIELDS[9],'')
	SEND_VTEXT(TP_FIELDS[10],'')
	SEND_VTEXT(TP_FIELDS[11],'')
	SEND_VTEXT(TP_FIELDS[12],'x/x')
	SEND_VTEXT(TP_FIELDS[13],'')
	SEND_VTEXT(TP_FIELDS[14],'')
	SEND_VTEXT(TP_FIELDS[15],'')        
	SEND_VTEXT(TP_FIELDS[16],'00:00')
	SEND_VTEXT(TP_FIELDS[19],'w')
	SEND_VTEXT(TP_FIELDS[20],'')  // CLEAR X OF Y ON PLAYLIST POPUP
	SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //=1 ON, =0 OFF - Sets Unsolictied feedback of time and record index on song change
	SEND_LEVEL dvTP,TP_LEVELS[1],0
	SEND_LEVEL dvTP,TP_LEVELS[2],0
	//fnINDEX_HILITE(1)
	fnDO_FEEDBACK()
	nRUN_ONCEb = 1
	//SEND_COMMAND dvTP,'@PPA-iPort'     // CLOSE POPUP INFO
	SEND_COMMAND dvTP, '@PPF-Eject;iPort'    // Popup eject off
	OFF[nNOW_PLAYING]
    }
}

DEFINE_FUNCTION fnCLEAR_LIST() //Clear the list
{
    STACK_VAR INTEGER i
    
    FOR(i=1;i <= nCURRENT_INDEX_LENGTH;i++)
    {
	SEND_VTEXT(TP_FIELDS[i+1],'') //Lists start at TP_FIELDS[2]
    }
}

DEFINE_FUNCTION fnCLEAR_SONG_INFO()
{
    SEND_VTEXT(TP_FIELDS[13],'')
    SEND_VTEXT(TP_FIELDS[14],'')
    SEND_VTEXT(TP_FIELDS[15],'')
}

DEFINE_FUNCTION fnPROCESS_SELECTION(INTEGER nCategory)
{
    
    IF(nCURRENT_MENU <= 5)
    {
	SWITCH(nCURRENT_MENU)
	{
	    CASE 1: 	//Main Menu
	    {
		nCURRENT_CATEGORY_START = nCategory
		SEND_VTEXT(TP_FIELDS[21],"cMenu0[nCURRENT_CATEGORY_START]")
		IF(nCategory = 5) //Cat - Songs?
		{
		    SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?1'")
		    fnCLEAR_LIST()
		    WAIT 3
		    SEND_CMD("'SELECT_SORT_DB_RECORD=1:0:4'") //Sort the iPods default 0 playlist (all songs) alphabetically by Song
		    WAIT 5
		    SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?5'")
		    fnCLEAR_LIST()
		    
		}
		ELSE IF(nCategory = 3) //Cat - Albums?
		{
		    SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?3'")
		    fnCLEAR_LIST()
		    WAIT 3
		    SEND_CMD("'SELECT_SORT_DB_RECORD=3:0:3'") //Sort the iPods Albums alphabetically by Album
		    WAIT 5
		    SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?3'")
		    fnCLEAR_LIST()
		}
		ELSE
		{
		    SEND_CMD("'SELECT_DB_RECORD=',ITOA(nCategory),':0'") // Valid only 1-6 on Menu 0
		    WAIT 2
		    SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?',ITOA(nCategory)")
		    fnCLEAR_LIST()
		}
		
	    }
	
	    CASE 2: 	//Menu #2
	    {
		nCURRENT_CATEGORY[1] = nCategory
		//SEND_VTEXT(TP_FIELDS[21],"cMenu0[nCURRENT_CATEGORY_START],'/',cINDEX_LIST_1[2][1][nCURRENT_CATEGORY[1]]") //shortened below
		IF(nCURRENT_CATEGORY_START <> 5)
		{
		    SEND_VTEXT(TP_FIELDS[21],"cINDEX_LIST_1[2][1][nCURRENT_CATEGORY[1]]")
		}
		SWITCH(nCURRENT_CATEGORY_START)
		{
		    CASE 1:	//Playlist Goes to Songs on 3rd Menu
		    {
			SEND_CMD("'SELECT_DB_RECORD=1:',ITOA(ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]))")
			WAIT 2
			SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?5'") // Looking for number of Songs in the selected playlist 
			fnCLEAR_LIST()
			
		    }
		    
		    CASE 2:	//Artist Goes to Album on 3rd Menu
		    {
			SEND_CMD("'SELECT_DB_RECORD=2:',ITOA(ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]))")
			//SEND_CMD("'SELECT_DB_RECORD=3:3'")
			//SEND_CMD("'SELECT_SORT_DB_RECORD=3:',ITOA(ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory])),':255'")
			WAIT 3  //Changed to WAIT 3 to sidestep effect of $0A in string to physical device on pre-duet firmwares - Edit v1_1 8-18-2006
			
			SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?3'") // Looking for number of Albums in the selected Artist 
			fnCLEAR_LIST()
			nCURRENT_CATEGORY2[3] = 3
			
		    }
		    
		    CASE 3:	//Album Goes to Songs on 3rd Menu
		    {
			SEND_CMD("'SELECT_DB_RECORD=3:',ITOA(ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]))")
			WAIT 2
			SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?5'") // Looking for number of Songs in the selected playlist 
			fnCLEAR_LIST()
			nCURRENT_CATEGORY2[3] = 5
		    }
		    
		    CASE 4:	//Genre Goes to Artists on 3rd Menu
		    {
			SWITCH(nVIDEO_MENU)
			{
			    CASE 0: 	//Music
			    CASE 2:    //Music Videos
			    CASE 3:   //TV Shows
			    CASE 4:  //Video Podcasts
			    {
				SEND_CMD("'SELECT_DB_RECORD=4:',ITOA(ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]))")
				WAIT 2
				SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?2'") // Looking for number of Artists in the selected Genre
				fnCLEAR_LIST()
				nCURRENT_CATEGORY2[3] = 2
			    }
			    CASE 1: //Movies
			    {
				SEND_CMD("'SELECT_DB_RECORD=4:',ITOA(ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]))")
				WAIT 2
				SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?5'") // Looking for number of Artists in the selected Genre
				fnCLEAR_LIST()
				nCURRENT_CATEGORY2[3] = 5
			    }
			}
		    }
		    
		    CASE 5:	//Song goes to songs in this menu - Play this selection
		    {
			SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]")
			nCURRENT_MENU = 1
			fnCLEAR_SONG_INFO()
			WAIT 2
			SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
			WAIT 3
			SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'")   //Restart Time return
			SEND_COMMAND dvTP,'@PPF-SONG DETAILS'    // Popup iPort Now Playing on
			fnPAGE_FLIP_NP()
			ON[nNOW_PLAYING] // SET FLAG TO PREVENT MENU BUTTON FROM FLIPPING BACK TOO MANY LEVELS
		    }
		    CASE 6:	//Composer goes to songs on 3rd menu
		    {
			SEND_CMD("'SELECT_DB_RECORD=6:',ITOA(ATOI(cINDEX_LIST_1[2][2][nCategory]))")
			WAIT 2
			SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?5'") // Looking for number of Songs in the selected Composer 
			fnCLEAR_LIST()
			nCURRENT_CATEGORY2[3] = 5
		    }
		    CASE 7:	// audio books??? Needs work
		    {
			SEND_CMD("'SELECT_DB_RECORD=7:',ITOA(ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]))")
			WAIT 2
			SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?7'") // Looking for number of Entries in the selected Audio book 
			fnCLEAR_LIST()
			nCURRENT_CATEGORY2[3] = 7
		    }
		    CASE 8:	// PODCASTS
		    {
			SEND_CMD("'SELECT_DB_RECORD=8:',ITOA(ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]))")
			WAIT 2
			SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?5'") // Looking for number of Songs in the selected Podcast 
			fnCLEAR_LIST()
			nCURRENT_CATEGORY2[3] = 5
		    }
		}
		
	    }
	
	    CASE 3: 	// Menu #3
	    {
		STACK_VAR CHAR cSelectionTemp[15]
		
		nCURRENT_CATEGORY[2] = nCategory
		//cSelectionTemp = LEFT_STRING(cINDEX_LIST_1[2][1][nCURRENT_CATEGORY[1]], (LENGTH_STRING(cINDEX_LIST_1[2][1][nCURRENT_CATEGORY[1]]) -1)) // Take off the $00 on the end of the string to send v-text
		//SEND_VTEXT(TP_FIELDS[21],"cMenu0[nCURRENT_CATEGORY_START],'/',cSelectionTemp,'/',cINDEX_LIST_1[3][1][nCURRENT_CATEGORY[2]]") //Send v-text to path
		IF(nCURRENT_CATEGORY_START <> 1)
		{
		    SEND_VTEXT(TP_FIELDS[21],"cINDEX_LIST_1[3][1][nCURRENT_CATEGORY[2]]") //Send v-text to path
		}
		SWITCH(nCURRENT_CATEGORY_START)
		{
		    CASE 1:	//Playlist Goes to Songs on 3nd Menu
		    {
			SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]")
			nCURRENT_MENU = 2
			fnCLEAR_SONG_INFO()
			WAIT 2
			SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
			WAIT 3
			SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
			SEND_COMMAND dvTP,'@PPF-SONG DETAILS'    // Popup iPort Now Playing on
			fnPAGE_FLIP_NP()
			ON[nNOW_PLAYING] // SET FLAG TO PREVENT MENU BUTTON FROM FLIPPING BACK TOO MANY LEVELS
		    }
		    
		    CASE 2:	//Artist Goes to Songs on 3rd Menu
		    {
			SEND_CMD("'SELECT_DB_RECORD=3:',ITOA(ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]))")
			WAIT 2
			SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?5'") // Looking for number of Songs in the selected playlist 
			fnCLEAR_LIST()
		    }
		    
		    CASE 3:	//Album Goes to Songs on 3rd Menu
		    {
			SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]")
			nCURRENT_MENU = 2
			fnCLEAR_SONG_INFO()
			WAIT 2
			SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
			WAIT 3
			SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
			SEND_COMMAND dvTP,'@PPF-SONG DETAILS'    // Popup iPort Now Playing on
			fnPAGE_FLIP_NP()  // Page flip on DMS to Transports
			ON[nNOW_PLAYING] // SET FLAG TO PREVENT MENU BUTTON FROM FLIPPING BACK TOO MANY LEVELS
		    }
		    
		    CASE 4:	//Genre Goes to Artists on 3rd Menu - This is where the videos return their first selected list
		    {
			SWITCH(nVIDEO_MENU)
			{
			    CASE 0: 	//Music get album info
			    CASE 3:    //TV Shows get Season info
			    {
				SEND_CMD("'SELECT_DB_RECORD=2:',ITOA(ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]))")
				WAIT 2
				SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?3'") // Looking for number of Albums in the selected Artist 
				fnCLEAR_LIST()
			    }
			    CASE 1: //Movies Play Now
			    {
				SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]")
				nCURRENT_MENU = 2
				fnCLEAR_SONG_INFO()
				WAIT 2
				SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
				WAIT 3
				SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
				SEND_COMMAND dvTP,'@PPF-SONG DETAILS'    // Popup iPort Now Playing on
				fnPAGE_FLIP_NP()   // Page flip on DMS to Transports
				ON[nNOW_PLAYING] // SET FLAG TO PREVENT MENU BUTTON FROM FLIPPING BACK TOO MANY LEVELS
			    }
			    CASE 2:   //Music Videos get Album info
			    CASE 4:    //Video Podcasts get videos
			    {
				nCategory = ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory])
				SEND_CMD("'SELECT_DB_RECORD=2:',ITOA(nCategory)")
				WAIT 2
				SEND_CMD("'SELECT_DB_RECORD=2:',ITOA(nCategory)") //Fix applied for Music Videos to select correctly on first selection "Work around the iPod"
				WAIT 4
				SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?5'") // Looking for number of Songs in the selected album
				fnCLEAR_LIST()
			    }
			}
			
			//SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]")
			//nCURRENT_MENU = 2
			//fnCLEAR_SONG_INFO()
			//WAIT 2
			//SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
			//WAIT 3
			//SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
			//SEND_COMMAND dvTP,'@PPF-SONG DETAILS'    // Popup iPort Now Playing on
			//fnPAGE_FLIP_NP()   // Page flip on DMS to Transports
			//ON[nNOW_PLAYING] // SET FLAG TO PREVENT MENU BUTTON FROM FLIPPING BACK TOO MANY LEVELS
		    }
		    
		    CASE 5:	//Song goes to songs in this menu 	
		    {
			
		    }
		    CASE 6:	//Composer
		    {
			SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]")
			nCURRENT_MENU = 2
			fnCLEAR_SONG_INFO()
			WAIT 2
			SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
			WAIT 3
			SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
			SEND_COMMAND dvTP,'@PPF-SONG DETAILS'    // Popup iPort Now Playing on
			fnPAGE_FLIP_NP()   // Page flip on DMS to Transports
			ON[nNOW_PLAYING] // SET FLAG TO PREVENT MENU BUTTON FROM FLIPPING BACK TOO MANY LEVELS
		    }
		    CASE 7:	// audio books
		    {
		    
		    }
		    CASE 8:	// PODCASTS
		    {
			SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]")
			nCURRENT_MENU = 2
			fnCLEAR_SONG_INFO()
			WAIT 2
			SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
			WAIT 3
			SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
			SEND_COMMAND dvTP,'@PPF-SONG DETAILS'    // Popup iPort Now Playing on
			fnPAGE_FLIP_NP()   // Page flip on DMS to Transports
			ON[nNOW_PLAYING] // SET FLAG TO PREVENT MENU BUTTON FROM FLIPPING BACK TOO MANY LEVELS
		    }
		}
	    }
	
	    CASE 4: 	// Menu #3
	    {
		nCURRENT_CATEGORY[3] = nCategory
		SWITCH(nCURRENT_CATEGORY_START)
		{
		    CASE 2:	//Artist Goes to Songs on 4th Menu
		    {
			SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]")
			nCURRENT_MENU = 3
			fnCLEAR_SONG_INFO()
			WAIT 2
			SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
			WAIT 3
			SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
			SEND_COMMAND dvTP,'@PPF-SONG DETAILS'   	   // Popup iPort Now Playing ON
			fnPAGE_FLIP_NP()   // Page flip on DMS to Transports
			ON[nNOW_PLAYING] // SET FLAG TO PREVENT MENU BUTTON FROM FLIPPING BACK TOO MANY LEVELS
		    }
		    CASE 4:    //Genre Goes to Albums on 4th menu
		    {
			SWITCH(nVIDEO_MENU)
			{
			    CASE 0: 	//Music
			    CASE 3:    //TV Shows
			    {
				SEND_CMD("'SELECT_DB_RECORD=3:',ITOA(ATOI(cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]))")
				WAIT 2
				SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?5'") // Looking for number of Songs in the selected album
				fnCLEAR_LIST()
			    }
			    CASE 2:
			    CASE 4:
			    {
				SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]")
				nCURRENT_MENU = 3
				fnCLEAR_SONG_INFO()
				WAIT 2
				SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
				WAIT 3
				SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
				SEND_COMMAND dvTP,'@PPF-SONG DETAILS'    // Popup iPort Now Playing on
				fnPAGE_FLIP_NP()   // Page flip on DMS to Transports
				ON[nNOW_PLAYING] // SET FLAG TO PREVENT MENU BUTTON FROM FLIPPING BACK TOO MANY LEVELS
			    }
			}
		    }
		}
	    }
	    CASE 5:   //Menu #4 (Genres only in this menu)
	    {
		SEND_CMD("'PLAY_CURRENT_SELECTION=',cINDEX_LIST_1[nCURRENT_MENU][2][nCategory]")
		nCURRENT_MENU = 4
		fnCLEAR_SONG_INFO()
		WAIT 2
		SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
		WAIT 3
		SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
		SEND_COMMAND dvTP,'@PPF-SONG DETAILS'    // Popup iPort Now Playing on
		fnPAGE_FLIP_NP()   // Page flip on DMS to Transports
		ON[nNOW_PLAYING] // SET FLAG TO PREVENT MENU BUTTON FROM FLIPPING BACK TOO MANY LEVELS
	    }
	}
	IF(nCURRENT_MENU < 5)
	{
	    nCURRENT_MENU = nCURRENT_MENU + 1
	}
    }
    ELSE IF(nCURRENT_MENU > 5)
    {
	nCURRENT_MENU = 5
    }
}

DEFINE_FUNCTION fnUPDATE_INDEX_LEVEL(INTEGER nLevel) //Update bargraph for listings
{
    STACK_VAR INTEGER nTemp
    
    nTemp = nLevel
    IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
    {
	SEND_LEVEL dvTP,TP_LEVELS[1],1
	//made to fix divide by 0 runtime errors
    }
    ELSE IF(nTemp >= (nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH)) //Send the level to the bottom of the list
    {
	SEND_LEVEL dvTP,TP_LEVELS[1],255
	WAIT 2
	SEND_VTEXT(TP_FIELDS[20],"ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])")
    }
    ELSE
    {
	SEND_LEVEL dvTP,TP_LEVELS[1],((100-(nMENU_RECORD_COUNT[nCURRENT_MENU] - nTemp)*100/nMENU_RECORD_COUNT[nCURRENT_MENU])*255/100)
	//SEND_LEVEL dvTP,TP_LEVELS[1],(((nMENU_RECORD_COUNT[nCURRENT_MENU] - nTemp)*100/nMENU_RECORD_COUNT[nCURRENT_MENU])*255/100) //For G3 Panels
    }
}

DEFINE_FUNCTION fnRESET_DB_SELECTION()
{
    //LOCAL_VAR INTEGER iTP_TEMP
    
    //iTP_TEMP = GET_LAST(dvTP)
    cINDEX_LIST_1[1][1][1] = cMenu0[1]
    cINDEX_LIST_1[1][1][2] = cMenu0[2]
    cINDEX_LIST_1[1][1][3] = cMenu0[3]
    cINDEX_LIST_1[1][1][4] = cMenu0[4]
    cINDEX_LIST_1[1][1][5] = cMenu0[5]
    cINDEX_LIST_1[1][1][6] = cMenu0[6]
    cINDEX_LIST_1[1][1][7] = cMenu0[7]
    cINDEX_LIST_1[1][1][8] = cMenu0[8]
    SEND_VTEXT(TP_FIELDS[2],'Playlists')
    SEND_VTEXT(TP_FIELDS[3],'Artists')
    SEND_VTEXT(TP_FIELDS[4],'Albums')
    SEND_VTEXT(TP_FIELDS[5],'Genres')
    SEND_VTEXT(TP_FIELDS[6],'Songs')
    SEND_VTEXT(TP_FIELDS[7],'Composers')
    SEND_VTEXT(TP_FIELDS[8],'Audio Books')
    SEND_VTEXT(TP_FIELDS[9],'Podcasts')
    SEND_VTEXT(TP_FIELDS[10],'')
    SEND_VTEXT(TP_FIELDS[11],'')
    fnDO_FEEDBACK()
    nCURRENT_INDEX_NUM[1] = 1
    nCURRENT_INDEX_NUM[2] = 1
    nCURRENT_INDEX_NUM[3] = 1
    nCURRENT_INDEX_NUM[4] = 1 
    SEND_CMD('RESET_DB_SELECTION=0')
    OFF[nNOW_PLAYING]
}

DEFINE_FUNCTION fnPAGE_FLIP_NP()
{
    STACK_VAR INTEGER nTEMP
    
    nTEMP = GET_LAST(dvTP)
    
    SELECT   //This is done to page flip back to the corresponding iPort Page if there are multiple iPorts controlled from 1 DMS
    {		// More ports can be added depending on how many iPorts are being controlled by one DMS
	ACTIVE (nR4_DMS_PORT1 = nCURRENT_TP_PORT):
	{
	    SEND_COMMAND dvTP[nTEMP], 'PAGE-iPort Now Playing' //Flip DMS page to Now Playing page 1
	    WAIT 5
	    SEND_VTEXT(TP_FIELDS[19],'q') // q = play icon with AMXBOLD font
	    ON[dvTP,TP_BUTTONS[3]] //turns DMS play button ON
	}
	ACTIVE (nR4_DMS_PORT2 = nCURRENT_TP_PORT):
	{
	    SEND_COMMAND dvTP[nTEMP], 'PAGE-iPort Now Playing 2' //Flip DMS page to Now Playing page 2
	    WAIT 5
	    SEND_VTEXT(TP_FIELDS[19],'q') // q = play icon with AMXBOLD font
	    ON[dvTP,TP_BUTTONS[3]] //turns DMS play button ON
	}
    }
}
(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

nCURRENT_INDEX_LENGTH = nLISTS[1]	//Gets default from nLists for list length
CREATE_BUFFER vdviPort,strRESPONSE    // Feedback buffer

CREATE_LEVEL dvTP, TP_LEVELS[1], nSLIDER_LEVEL   // Follow Index slider
CREATE_LEVEL dvTP, TP_LEVELS[2], nTIME_LEVEL   // Follow Time slider

#INCLUDE 'UnicodeLib.axi'



(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

DATA_EVENT[vdviPort]
{
    STRING:
    {
	debug(1, "'RECEIVED FROM COMM: ',strRESPONSE") 
	PROCESS_RESPONSE() // Process the responses from the COMM module
    }
}

DATA_EVENT[dvTP]
{
    ONLINE:
    {
	nDEV_LENGTH = LENGTH_ARRAY(dvTP)
	
	WAIT 20
	SEND_CMD("'REQUEST_REMOTE_UI_MODE?'") //Check for iPod Online
	WAIT 40
	IF(nONLINE) //If the iPod is already online send updated info to TP
	{
	    nRUN_ONCEa = 0
	    fnUpdate_Info_Online()
		
	}
	ELSE
	{
	    OFF[dvTP,TP_BUTTONS[4]]      // Init in offline condition
	    SEND_VTEXT(TP_FIELDS[1],' Offline')        // Initialize text fields
	    SEND_VTEXT(TP_FIELDS[2],'iPort Netlinx Module')
	    SEND_VTEXT(TP_FIELDS[3],'Version 3.24 Release with Video')
	    SEND_VTEXT(TP_FIELDS[4],'')
	    SEND_VTEXT(TP_FIELDS[5],'')
	    SEND_VTEXT(TP_FIELDS[6],'')
	    SEND_VTEXT(TP_FIELDS[7],'')
	    SEND_VTEXT(TP_FIELDS[8],'')
	    SEND_VTEXT(TP_FIELDS[9],'')
	    SEND_VTEXT(TP_FIELDS[10],'')
	    SEND_VTEXT(TP_FIELDS[11],'')
	    SEND_VTEXT(TP_FIELDS[12],'x/x')
	    SEND_VTEXT(TP_FIELDS[13],'')
	    SEND_VTEXT(TP_FIELDS[14],'')
	    SEND_VTEXT(TP_FIELDS[15],'')        
	    SEND_VTEXT(TP_FIELDS[16],'00:00')
	    SEND_VTEXT(TP_FIELDS[20],'')  // CLEAR X OF Y ON PLAYLIST POPUP
	    fnDO_FEEDBACK()    			// Initialize panel feedback buttons
	    nCURRENT_INDEX_LENGTH = nLISTS[1]	//Gets default from nLists for list length
	    //SEND_COMMAND dvTP,'@PPN-SONG DETAILS;iPort Main'    // Popup iPort List on
	    SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
		OFF[nNOW_PLAYING]
	}
	//SEND_CMD("'VERSION?'")      // Get Comm module version number
	IF(!TIMELINE_ACTIVE(Name_TL1))
	{
	    TIMELINE_CREATE(Name_TL1, Name_TimeArray, 1, TIMELINE_ABSOLUTE,TIMELINE_REPEAT) // Timeline to poll for iPod name
	}
    }
    OFFLINE:
    {
	(*STACK_VAR INTEGER iPanel_off
		
	iPanel_off = GET_LAST(dvTP)
	nON_IPORT_PAGE[iPanel_off] = 0 //commented out v3.22 
	*)
    }
}

TIMELINE_EVENT[Name_TL1] //Runs every 10 seconds to check name and status
{
    
    //SEND_CMD("'REQUEST_REMOTE_UI_MODE?'") //Check for iPod Online
    //nONLINE_FLAG = 1 //v3.22 Commented out
    WAIT 50
    IF(nONLINE)
    {
	SEND_CMD("'GET_PLAY_STATUS?'") //Check for iPod Status and Total Song Length
    }
    WAIT 90
    IF(nONLINE_FLAG)
    {
	nONLINE = 0
	fnDO_FEEDBACK()
	nRUN_ONCEa = 0
    }
    ELSE
    {
	//nONLINE = 1
    }
}

BUTTON_EVENT[dvTP,TP_BUTTONS] //Buttons pushed 
{
    PUSH:
    {	
	nCURRENT_TP_PORT = button.input.device.port
	nKEY_PRESSED = GET_LAST(TP_BUTTONS) //Get last button pushed on panel
        debug(1,"'key pressed:',itoa(nKEY_PRESSED)")
        SWITCH(nKEY_PRESSED)
	{
	    CASE 1:	// Menu (Back button)
	    {
		SEND_COMMAND dvTP,'@PPN-SONG DETAILS;iPort Main'           // Popup iPort List on
		SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Start Time return
		nCURRENT_INDEX_START = 0
		IF(nCURRENT_MENU > 1)// AND !nNOW_PLAYING)
		{
		    
		    IF(nVIDEO_MENU >= 1 && nCURRENT_MENU = 3) //Since Video Menu is actually Genres Menu we want it to skip back 2 menus when going back to start
		    {
			nCURRENT_MENU = 2
			nVIDEO_MENU = 0
		    }
		    nCURRENT_MENU = nCURRENT_MENU - 1
		    SEND_LEVEL dvTP,TP_LEVELS[1],0 //Reset list bargraph to 0 - Edit v1_1 8-18-2006
		    IF(nCURRENT_MENU > 1)
		    {
			STACK_VAR INTEGER i
			
			IF(nNO_ALBUM = 1) // Added for when there are no albums for a specific artist to jump back to artists
			{
			    nCURRENT_MENU = 2
			    nNO_ALBUM = 0
			}
			FOR(i=1; i < (nCURRENT_INDEX_LENGTH + 1);i++)
			{
			    SEND_VTEXT(TP_FIELDS[i+1],"cINDEX_LIST_1[nCURRENT_MENU][1][i]")
			}
			//nCURRENT_INDEX_HILITE = 1
			//fnDO_HILITE()
			SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") 
			IF(nCURRENT_MENU = 2)
			{
			    SEND_VTEXT(TP_FIELDS[21],"cMenu0[nCURRENT_CATEGORY_START]")
			}
			FOR(i=1; i <= nCURRENT_INDEX_LENGTH;i++) //Clear the Array for back button to populate only current records
			{
			    cINDEX_LIST_1[(nCURRENT_MENU + 1)][1][i] = ''
			    cINDEX_LIST_1[(nCURRENT_MENU + 1)][2][i] = ''
			}
		    }
		    IF(nCURRENT_MENU = 1)
		    {
			STACK_VAR INTEGER i
			STACK_VAR INTEGER nTEMP
			    
			nTEMP = GET_LAST(dvTP)
			
			SELECT	//This is done to page flip back to the corresponding iPort Menu if there are multiple iPorts controlled from 1 DMS
			{		
			    ACTIVE (nR4_DMS_PORT1 = nCURRENT_TP_PORT):
			    {
				SEND_COMMAND dvTP[nTEMP], 'PAGE-iPort Menu' //Flip DMS page back to Menu 1
			    }
			    ACTIVE (nR4_DMS_PORT2 = nCURRENT_TP_PORT):
			    {
				SEND_COMMAND dvTP[nTEMP], 'PAGE-iPort Menu 2' //Flip DMS page back to Menu 2
			    }
			}
			fnRESET_DB_SELECTION()
			//nCURRENT_INDEX_HILITE = 0 //WAS 1
			//fnDO_HILITE()
			SEND_VTEXT(TP_FIELDS[20],"'1 / 6'") //
			SEND_VTEXT(TP_FIELDS[21],"'pick an option from below'")
			FOR(i=1; i <= nCURRENT_INDEX_LENGTH;i++) //Clear the Array for back button to populate only current records
			{
			    cINDEX_LIST_1[2][1][i] = ''
			    cINDEX_LIST_1[2][2][i] = ''
			    cINDEX_LIST_1[3][1][i] = ''
			    cINDEX_LIST_1[3][2][i] = ''
			    cINDEX_LIST_1[4][1][i] = ''
			    cINDEX_LIST_1[4][2][i] = ''
			}
		    }
		}
		ELSE IF(!nNOW_PLAYING)
		{
		    nCURRENT_MENU = 1
		    fnRESET_DB_SELECTION()
		}
		OFF[nNOW_PLAYING]	
	    }
            CASE 2: 	//Select  - occurs on Release and Hold event
	    // !! JP !! DISABLED DIRECT PLAY - Direct select occurs on the hold event of each select button
	    {
	    
	    }
            CASE 3:	//Play/Pause
            {
                IF(TP_BUTTONS[3])
		{
		    SEND_CMD("'PLAY_CONTROL=1'")
		    nPLAY_STATE = 0
		    
                }
		ELSE
		{
		    SEND_CMD("'PLAY_CONTROL=1'")
		    nPLAY_STATE = 1
		}
		
		fnDO_FEEDBACK()
		WAIT 2
		SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
		WAIT 5
		SEND_CMD("'GET_PLAY_STATUS?'")
		WAIT 7
		SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
		SEND_COMMAND dvTP,'@PPF-SONG DETAILS'        // Popup iPort Now Playing on
		ON[nNOW_PLAYING] // SET FLAG TO PREVENT MENU BUTTON FROM FLIPPING BACK TOO MANY LEVELS
	    }
            CASE 4:	//Offline/Online
            {
		IF(nONLINE)
		{
		    SEND_CMD("'EXIT_REMOTE_UI_MODE='")
		    SEND_COMMAND dvTP, '@PPN-EJECT;iPort'    // Popup EJECT on
			//SEND_COMMAND dvTP,'@PPA-iPort'     // CLOSE POPUP INFO
		    WAIT 5
		    SEND_CMD("'REQUEST_REMOTE_UI_MODE?'")
		    nRUN_ONCEa = 0
		    nRUN_ONCEb = 0
		    nONLINE = 0
		    WAIT 50
		    fnDO_FEEDBACK()
		    WAIT 60
		    fnUpdate_Info_Offline()
		    
		}
		ELSE
			{
				SEND_CMD("'ENTER_REMOTE_UI_MODE='")
				WAIT 20
				SEND_CMD("'REQUEST_REMOTE_UI_MODE?'")
			}
            }
            CASE 5:{}	   //Previous (Done in Release Event)
            CASE 6:{}     //Next (Done in Release Event)
            CASE 7:{}    //Fast Rewind (Done in Hold Event)
            CASE 8:{}	//Fast Forward (Done in Hold Event)
            CASE 9:    // -10 Up or list up full index length
	    {
		IF(nCURRENT_INDEX_NUM[nCURRENT_MENU] = 1)
		{
		    //Do nothing
		}
		ELSE
		{
		    IF(nDOUBLE_PUSH = 0) //Do a normal list jump 
		    {
			//nDOUBLE_PUSH = 1 //Set this to 0 or comment out if you do not want double push to occur
			nLEVEL_FLAG = 0
			nCURRENT_INDEX_START = 0
			IF(nCURRENT_INDEX_NUM[nCURRENT_MENU] > 1)
			{
			    IF(nCURRENT_INDEX_NUM[nCURRENT_MENU] <= nCURRENT_INDEX_LENGTH) // LESS THAN 10 RECORDS BACK FILL LIST WITH 0-9 RECORDS 
			    {
				IF(nCURRENT_CATEGORY_START = 1 && nCURRENT_MENU = 2) //Is the current menu the Playlists Menu?
				{
				    nCURRENT_INDEX_NUM[nCURRENT_MENU] = 1 // don't get the playlist which is the name of the iPod - iPod bug fix
				}
				ELSE
				{
				    nCURRENT_INDEX_NUM[nCURRENT_MENU] = 0 // Start menu at beginning of current list
				}
				SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_LENGTH - 1)")
				fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU])
				SEND_VTEXT(TP_FIELDS[20],"'1 / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])")
			    }
			    ELSE // MORE THAN List Length of RECORDS LEFT IN LIST
			    {
				IF((nCURRENT_INDEX_NUM[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH) <= 0)
				{
				    //End of list
				}
				ELSE
				{
				    nCURRENT_INDEX_NUM[nCURRENT_MENU] = nCURRENT_INDEX_NUM[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH
				    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]-1),':',ITOA(nCURRENT_INDEX_LENGTH - 1)") // -1:9
				    fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU])
				    SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])")
				}
			    }
			}
		    }
		    ELSE // Jump to the top of the list
		    {
			IF((nCURRENT_INDEX_NUM[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH) <= 0)
			{
			    //End of list
			}
			ELSE
			{
			    WAIT 1	//Added to slow the list down while it is still getting populated by the first push.
			    IF(nCURRENT_CATEGORY_START = 1 && nCURRENT_MENU = 2) //Is the current menu the Playlists Menu?
			    {
				nCURRENT_INDEX_NUM[nCURRENT_MENU] = 1 // don't get the playlist which is the name of the iPod - iPod bug fix
			    }
			    ELSE
			    {
				nCURRENT_INDEX_NUM[nCURRENT_MENU] = 0 // Start menu at beginning of current list
			    }
			    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_LENGTH - 1)")
			    fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU])
			    SEND_VTEXT(TP_FIELDS[20],"' 1 / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])")
			}
		    }
		    
		    WAIT 5
		    nDOUBLE_PUSH = 0
		}
	    }
            CASE 10:    // -1 Up
	    {
		STACK_VAR INTEGER i
		nLEVEL_FLAG = 0
		nCURRENT_INDEX_START = 0
		IF(nCURRENT_INDEX_NUM[nCURRENT_MENU] <= 1)
		{
		    //End of list
		}
		ELSE
		{
		    nCURRENT_INDEX_NUM[nCURRENT_MENU] --
		    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]-1),':',ITOA(nCURRENT_INDEX_LENGTH - 1)") // -1 0 was 1
		    fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU])
		}
		SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") // ADDED SPACES
	    }
            
            CASE 11:    // +1 Down
	    {
		STACK_VAR INTEGER i
					
		nLEVEL_FLAG = 0
		IF((nCURRENT_INDEX_NUM[nCURRENT_MENU]+ (nCURRENT_INDEX_LENGTH - 1)) >= nMENU_RECORD_COUNT[nCURRENT_MENU])
		{
		    //End of list
		}
		ELSE
		{
		    nCURRENT_INDEX_NUM[nCURRENT_MENU]++
		    //WAIT 1
		    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]-1),':',ITOA(nCURRENT_INDEX_LENGTH - 1)") // -1
		    fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU])
		}
		SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") // ADDED SPACES	
	    }
            
            CASE 12:    // +10 Down or list down full index length
	    {
		STACK_VAR INTEGER nTEMP
		IF(nCURRENT_INDEX_NUM[nCURRENT_MENU] >= (nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH))
		{
		    //Do Nothing - end of list.
		}
		ELSE IF(nMENU_RECORD_COUNT[nCURRENT_MENU]<=nCURRENT_INDEX_LENGTH)
		{
		    //Do Nothing - added to fix when people feel the need to push the down button when they don't need to and it produces a negative return
		}
		ELSE
		{
		    IF(nDOUBLE_PUSH = 0) // Do normal jump of list
		    {
			//nDOUBLE_PUSH = 1 // Comment this out if you do not want double push on down button to go to the bottom of the list
			nLEVEL_FLAG = 0
			nCURRENT_INDEX_START = 0
			nWAIT_FLAG = 1
			IF((nCURRENT_INDEX_NUM[nCURRENT_MENU]+(nCURRENT_INDEX_LENGTH * 2)) <= nMENU_RECORD_COUNT[nCURRENT_MENU]) // If the list is less than 2x the list length from the end
			{
			    nCURRENT_INDEX_NUM[nCURRENT_MENU] = nCURRENT_INDEX_NUM[nCURRENT_MENU] + nCURRENT_INDEX_LENGTH // changed from 10 for dynamic listing
			    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]-1),':',ITOA(nCURRENT_INDEX_LENGTH - 1)") // -1 and 9 was 10
			    fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU])
			    //SEND_STRING 0,"'in the IF'"
			}
			ELSE // LESS THAN Index Length of RECORDS FROM LAST
			{
			    nCURRENT_INDEX_NUM[nCURRENT_MENU] = nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH // changed from 10 for dynamic listing
			    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_LENGTH - 1)") // -1 and 9 was 10
			    fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU]+1)
			    nCURRENT_INDEX_NUM[nCURRENT_MENU]++ // NEED TO ADD 1 WHEN AT END OF LIST
			    //SEND_STRING 0,"'in the ELSE'"
			}
		    }
		    ELSE //Jump to the bottom of the list if double push occured
		    {
			WAIT 1		// Added to slow down the list population while the list is still populating from the first push
			nCURRENT_INDEX_NUM[nCURRENT_MENU] = nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH // changed from 10 for dynamic listing
			SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_LENGTH - 1)") // -1 and 9 was 10
			fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU]+1)
			nCURRENT_INDEX_NUM[nCURRENT_MENU]++ 
		    }
		    //SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU] + 1)")
		    IF (nMENU_RECORD_COUNT[nCURRENT_MENU] < 255)
		    {
			SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") 
		    }
		    ELSE
		    {
			SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") 
		    }		    
		    WAIT 5
		    nDOUBLE_PUSH = 0
		}
            }
	    CASE 13:          // Selection 1
	    CASE 14:         // Selection 2
	    CASE 15:        // Selection 3
	    CASE 16:       // Selection 4
	    CASE 17:      // Selection 5
	    CASE 18:     // Selection 6
	    CASE 19:    // Selection 7
	    CASE 20:   // Selection 8
	    CASE 21:  // Selection 9
	    CASE 22: // Selection 10
	    {
		// Moved to release of the button for version 1.1
		(*IF(LENGTH_STRING(cINDEX_LIST_1[nCURRENT_MENU][1][(nKEY_PRESSED - 12)]) = 0) //Checks array to see if position is empty and if so will not allow user to select nothing
		{
		    //Do Nothing
		}
		ELSE // Since the array has something it allows the selection
		{
		    //fnINDEX_HILITE(nKEY_PRESSED - 12)
		    fnPROCESS_SELECTION(nKEY_PRESSED - 12)
		}*)
            }

	    CASE 23: 	//Repeat options
	    {
		IF(nREPEAT_ON <= 1)
		{
		    nREPEAT_ON ++
		}
		ELSE
		{
		    nREPEAT_ON = 0
		}
		SEND_CMD("'SET_REPEAT=',ITOA(nREPEAT_ON)")
		fnDO_FEEDBACK()
		
	    }
            CASE 24:	//Shuffle Options
	    {
		IF(nSHUFFLE_ON <= 1)
		{
		    nSHUFFLE_ON ++
		}
		ELSE
		{
		    nSHUFFLE_ON = 0
		}
		SEND_CMD("'SET_SHUFFLE=',ITOA(nSHUFFLE_ON)")
		fnDO_FEEDBACK()
	    }
            CASE 25:	// Case 25 and 26 are both done on the Release below
	    {
	    
	    }
	    CASE 27:	//List Level Set
	    {
		nLEVEL_FLAG = 1
	    }
	    CASE 42:	// TP is on the iPort page
	    {
		STACK_VAR INTEGER iPanel_on
		
		iPanel_on = GET_LAST(dvTP)
		nON_IPORT_PAGE[iPanel_on] = 1 
		
		nDEV_LENGTH = LENGTH_ARRAY(dvTP)
	
		IF(nONLINE) //If the iPod is already online send updated info to TP
		{
		    nRUN_ONCEa = 0
		    fnUpdate_Info_Online()
		}
		ELSE //Clear info and show offline
		{
		    OFF[dvTP,TP_BUTTONS[4]]      // Init in offline condition
		    SEND_VTEXT(TP_FIELDS[1],' Offline')        // Initialize text fields
		    SEND_VTEXT(TP_FIELDS[2],'')
		    SEND_VTEXT(TP_FIELDS[3],'')
		    SEND_VTEXT(TP_FIELDS[4],'')
		    SEND_VTEXT(TP_FIELDS[5],'')
		    SEND_VTEXT(TP_FIELDS[6],'')
		    SEND_VTEXT(TP_FIELDS[7],'')
		    SEND_VTEXT(TP_FIELDS[8],'')
		    SEND_VTEXT(TP_FIELDS[9],'')
		    SEND_VTEXT(TP_FIELDS[10],'')
		    SEND_VTEXT(TP_FIELDS[11],'')
		    SEND_VTEXT(TP_FIELDS[12],'x/x')
		    SEND_VTEXT(TP_FIELDS[13],'')
		    SEND_VTEXT(TP_FIELDS[14],'')
		    SEND_VTEXT(TP_FIELDS[15],'')        
		    SEND_VTEXT(TP_FIELDS[16],'00:00')
		    SEND_VTEXT(TP_FIELDS[20],'')  // CLEAR X OF Y ON PLAYLIST POPUP
		    fnDO_FEEDBACK()    			// Initialize panel feedback buttons
		    nCURRENT_INDEX_LENGTH = nLISTS[1]	//Gets default from nLists for list length
		    //SEND_COMMAND dvTP,'@PPN-SONG DETAILS;iPort Main'    // Popup iPort List on
		    SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
			OFF[nNOW_PLAYING]
		}
	    }
	    CASE 43:	// TP is off the iPort page
	    {
		STACK_VAR INTEGER iPanel_off
		
		iPanel_off = GET_LAST(dvTP)
		nON_IPORT_PAGE[iPanel_off] = 0
	    }
	}
    }
    RELEASE:
    {
	IF(nFF_RWD_ON > 0)
	{
	    SEND_CMD("'PLAY_CONTROL=7'") //Stop Fast Forward Search/Rewind
	    nFF_RWD_ON = 0
	    fnDO_FEEDBACK()
	    nHOLD = 0
	}
	ELSE
	{
	    SWITCH(nKEY_PRESSED)
	    {
		CASE 5:     // Previous
		{
		    nHOLD = 0
		    SEND_CMD("'PLAY_CONTROL=4'")
		    nFF_RWD_ON = 1
		    fnDO_FEEDBACK()
		    WAIT 10
		    nFF_RWD_ON = 0
		    fnDO_FEEDBACK()
		}
            
		CASE 6:	//Next
		{
		    nHOLD = 0
		    SEND_CMD("'PLAY_CONTROL=3'")
		    nFF_RWD_ON = 2
		    fnDO_FEEDBACK()
		    WAIT 10
		    nFF_RWD_ON = 0
		    fnDO_FEEDBACK()
		}
		
		CASE 9:
		CASE 10:
		CASE 11:
		CASE 12:
		{
		    nLEVEL_FLAG = 1
		}
		
		CASE 13:          // Selection 1
		CASE 14:         // Selection 2
		CASE 15:        // Selection 3
		CASE 16:       // Selection 4
		CASE 17:      // Selection 5
		CASE 18:     // Selection 6
		CASE 19:    // Selection 7
		CASE 20:   // Selection 8
		CASE 21:  // Selection 9
		CASE 22: // Selection 10
		{
		    IF(nHOLD = 0) //If Hold was not produced process selection
		    {
			IF(LENGTH_STRING(cINDEX_LIST_1[nCURRENT_MENU][1][(nKEY_PRESSED - 12)]) = 0) //Checks array to see if position is empty and if so will not allow user to select nothing
			{
			    //Do Nothing
			}
			ELSE // Since the array has something it allows the selection
			{
			    //fnINDEX_HILITE(nKEY_PRESSED - 12)
			    fnPROCESS_SELECTION(nKEY_PRESSED - 12)
			}
			
			//WAIT 15
			//nCURRENT_INDEX_HILITE = 1
			fnDO_FEEDBACK()
		    }
		    nHOLD = 0
		}
		
		CASE 25:
		{
		    OFF[nNOW_PLAYING]
		    SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
		    //fnDO_HILITE()
			
		}
		
		CASE 26:
		{
		    SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'") //Restart Time return
		}
		CASE 28:         // Direct Select to Playlists
		CASE 29:        // Direct Select to Artists
		CASE 30:       // Direct Select to Albums
		CASE 31:      // Direct Select to Genres
		CASE 32:     // Direct Select to Songs
		CASE 33:    // Direct Select to Composers
		CASE 34:   // Direct Select to Audio Books
		CASE 35:  // Direct Select to Podcasts
		{
		    //STACK_VAR INTEGER i
		    
		    nVIDEO_MENU = 0
		    SEND_COMMAND dvTP,'@PPN-SONG DETAILS;iPort Main'           // Popup iPort List on
		    SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'")       //Stop Time return if = 0
		    nCURRENT_INDEX_START = 0
		    nCURRENT_MENU = 1
		    nCURRENT_INDEX_NUM[1] = 1
		    nCURRENT_INDEX_NUM[2] = 1
		    nCURRENT_INDEX_NUM[3] = 1
		    nCURRENT_INDEX_NUM[4] = 1
		    SEND_CMD('RESET_DB_SELECTION=0')
		    fnPROCESS_SELECTION(nKEY_PRESSED - 27)
		    fnDO_FEEDBACK()
		}
		CASE 36:     // Direct Select to Movies
		CASE 37:    // Direct Select to Music Videos
		CASE 38:   // Direct Select to TV Shows
		CASE 39:  // Direct Select to Podcast Videos
		{
		    //STACK_VAR INTEGER i
		    
		    nVIDEO_MENU = nKEY_PRESSED - 35 // Video Menu is: Movies = 1 -Music Vids = 2 -TV Shows = 3 -Vid Podcasts = 4
		    SEND_COMMAND dvTP,'@PPN-SONG DETAILS;iPort Main'           // Popup iPort List on
		    SEND_CMD("'SET_PLAY_STATUS_CHANGE_NOTIFICATION=1'")       //Start Time return feedback if = 1
		    nCURRENT_INDEX_START = 0 				     //Reset the counter for the list
		    nCURRENT_MENU = 2					    //We are now on the 2nd Menu
		    nCURRENT_CATEGORY_START = 4				   //Start on Genres Category for all movies
		    nCURRENT_INDEX_NUM[1] = 4				  //Since Category is 4 so is the 1st Index
		    nCURRENT_INDEX_NUM[2] = 1
		    nCURRENT_INDEX_NUM[3] = 1
		    nCURRENT_INDEX_NUM[4] = 1
		    nCURRENT_INDEX_NUM[5] = 1
		    SEND_CMD('RESET_DB_SELECTION=1') 		   //Set Database to search for Videos if = 1
		    //WAIT 2
		    //SEND_CMD("'SELECT_DB_RECORD=',ITOA(nKEY_PRESSED - 35),':0'")
		    //fnPROCESS_SELECTION(nKEY_PRESSED - 35)
		    //fnDO_FEEDBACK()
		    SWITCH(nVIDEO_MENU)
		    {
			CASE 2:
			CASE 3:
			CASE 4:
			{
			    SEND_CMD("'SELECT_DB_RECORD=4:',ITOA(nKEY_PRESSED - 36)") //Set for 4:0-3 For Video Genres and then 4 options in Video Genres
			    WAIT 2
			    SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?2'") // Looking for number of Artists in the selected list 
			    fnCLEAR_LIST()
			    SEND_VTEXT(TP_FIELDS[21],"cMenu_VIDEOS[nKEY_PRESSED - 35]")
			    nCURRENT_CATEGORY2[3] = 2
			    nCURRENT_MENU = 3
			}
			CASE 1:
			{
			    SEND_CMD("'SELECT_DB_RECORD=4:',ITOA(nKEY_PRESSED - 36)") //Set for 4:0-3 For Video Genres and then 4 options in Video Genres
			    WAIT 2
			    SEND_CMD("'GET_NUMBER_CATEGORIZED_DB_RECORDS?5'") // Looking for number of Movies in the selected list 
			    fnCLEAR_LIST()
			    SEND_VTEXT(TP_FIELDS[21],"cMenu_VIDEOS[nKEY_PRESSED - 35]")
			    nCURRENT_CATEGORY2[3] = 5
			    nCURRENT_MENU = 3
			}
		    }
		}
	    }
	}
    }
    HOLD[6,REPEAT]:
    {
	SWITCH(nKEY_PRESSED)
	{
	    CASE 5:     // Rewind
            {
		IF(nHOLD = 0) // Disables Hold Repeat
		{
		    nHOLD = 1
		    SEND_CMD("'PLAY_CONTROL=6'")
		    nFF_RWD_ON = 1
		    fnDO_FEEDBACK()
		}
            }
            
            CASE 6:	//FForward
            {
                IF(nHOLD = 0) // Disables Hold Repeat
		{
		    nHOLD = 1
		    SEND_CMD("'PLAY_CONTROL=5'")
		    nFF_RWD_ON = 2
		    fnDO_FEEDBACK()
		}
            }
	    
	    CASE 9:    // -10 Up
	    {
		nLEVEL_FLAG = 0
		nCURRENT_INDEX_START = 0
		IF(nCURRENT_INDEX_NUM[nCURRENT_MENU] > 1)
		{
		    IF(nCURRENT_INDEX_NUM[nCURRENT_MENU] <= nCURRENT_INDEX_LENGTH) // LESS THAN 10 RECORDS BACK FILL LIST WITH 0-9 RECORDS 
		    {
			nCURRENT_INDEX_NUM[nCURRENT_MENU] = 1
			SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':0:',ITOA(nCURRENT_INDEX_LENGTH - 1)")
			fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU])
		    }
		    ELSE // MORE THAN 10 RECORDS LEFT IN LIST
		    {
			IF((nCURRENT_INDEX_NUM[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH) <= 0)
			{
			    //End of list
			}
			ELSE
			{
			    nCURRENT_INDEX_NUM[nCURRENT_MENU] = nCURRENT_INDEX_NUM[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH
			    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]-1),':',ITOA(nCURRENT_INDEX_LENGTH - 1)") // -1:9
			    fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU])
			}
		    }
		    SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") // ADDED SPACES
		}
	    }
            CASE 10:    // -1 Up
	    {
		STACK_VAR INTEGER i
		nLEVEL_FLAG = 0
		nCURRENT_INDEX_START = 0
		IF(nCURRENT_INDEX_NUM[nCURRENT_MENU] <= 1)
		{
		    //End of list
		}
		ELSE
		{
		    nCURRENT_INDEX_NUM[nCURRENT_MENU] --
		    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]-1),':',ITOA(nCURRENT_INDEX_LENGTH - 1)") // -1 0 was 1
		    fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU])
		}
		SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") // ADDED SPACES
	    }
            
            CASE 11:    // +1 Down
	    {
		STACK_VAR INTEGER i
					
		nLEVEL_FLAG = 0
		IF((nCURRENT_INDEX_NUM[nCURRENT_MENU]+ (nCURRENT_INDEX_LENGTH - 1)) >= nMENU_RECORD_COUNT[nCURRENT_MENU])
		{
		    //End of list
		}
		ELSE
		{
		    nCURRENT_INDEX_NUM[nCURRENT_MENU]++
		    //WAIT 1
		    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]-1),':',ITOA(nCURRENT_INDEX_LENGTH - 1)") // -1
		    fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU])
		}
		SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") // ADDED SPACES	
	    }
            
            CASE 12:    // +10 Down
	    {
		STACK_VAR INTEGER nTEMP
					
		nLEVEL_FLAG = 0
		nCURRENT_INDEX_START = 0
		nWAIT_FLAG = 1
		IF((nCURRENT_INDEX_NUM[nCURRENT_MENU]+(nCURRENT_INDEX_LENGTH * 2)) <= nMENU_RECORD_COUNT[nCURRENT_MENU]) // If the list is less than 2x the list length from the end
		{
		    nCURRENT_INDEX_NUM[nCURRENT_MENU] = nCURRENT_INDEX_NUM[nCURRENT_MENU] + nCURRENT_INDEX_LENGTH // changed from 10 for dynamic listing
		    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]-1),':',ITOA(nCURRENT_INDEX_LENGTH - 1)") // -1 and 9 was 10
		    fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU])
		    //SEND_STRING 0,"'in the IF'"
		}
		ELSE // LESS THAN Index Length of RECORDS FROM LAST
		{
		    nCURRENT_INDEX_NUM[nCURRENT_MENU] = nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH // changed from 10 for dynamic listing
		    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_LENGTH - 1)") // -1 and 9 was 10
		    fnUPDATE_INDEX_LEVEL(nCURRENT_INDEX_NUM[nCURRENT_MENU]+1)
		    nCURRENT_INDEX_NUM[nCURRENT_MENU]++ // NEED TO ADD 1 WHEN AT END OF LIST
		    //SEND_STRING 0,"'in the ELSE'"
		}
		SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") 
	    }
	    	    
	    CASE 13:          // Selection 1
	    CASE 14:         // Selection 2
	    CASE 15:        // Selection 3
	    CASE 16:       // Selection 4
	    CASE 17:      // Selection 5
	    CASE 18:     // Selection 6
	    CASE 19:    // Selection 7
	    CASE 20:   // Selection 8
	    CASE 21:  // Selection 9
	    CASE 22: // Selection 10
	    {
		IF(nHOLD = 0) // Disables Hold Repeat
		{
		    nHOLD = 1
		    IF(LENGTH_STRING(cINDEX_LIST_1[nCURRENT_MENU][1][(nKEY_PRESSED - 12)]) = 0) //Checks array to see if position is empty and if so will not allow user to select nothing
		    {
		    //Do Nothing
		    }
		    ELSE // Since the array has something it allows the selection
		    {
			//fnINDEX_HILITE(nKEY_PRESSED - 12)
			nSELECT_FLAG = 1
			fnPROCESS_SELECTION(nKEY_PRESSED - 12)
			WAIT 15
			SEND_CMD("'GET_CURRENT_PLAYING_SONG_INDEX?'")
			
		    }
		}
	    }
	}
    }
}

LEVEL_EVENT[dvTP,TP_LEVELS[1]] 	//Level Control for Record Index
{
    
    SWITCH(nCURRENT_MENU)
    {
	CASE 1:
	{
		//If current menu is set to 1 - do nothing
	}
	DEFAULT:
	{
	    IF(nLEVEL_FLAG) // If level is currently not being pushed...
	    {
		nRECORD_LEVEL[1] = LEVEL.VALUE
		nCURRENT_INDEX_START = 0
		IF(nMENU_RECORD_COUNT[nCURRENT_MENU] < nCURRENT_INDEX_LENGTH)
		{
		    //Do Nothing if list is less than Default list size
		}
		ELSE IF(nMENU_RECORD_COUNT[nCURRENT_MENU] > 255) // Since bargraph level is max 255 on G3 panels - G4 panels can be made to dynamicaly set the bargraph to match the number of songs
		{
		    nCURRENT_INDEX_NUM[nCURRENT_MENU] = (100-((255 - nRECORD_LEVEL[1]) * 100/255))*nMENU_RECORD_COUNT[nCURRENT_MENU]/100
		    IF(((nMENU_RECORD_COUNT[nCURRENT_MENU]) - (nCURRENT_INDEX_NUM[nCURRENT_MENU])) < nCURRENT_INDEX_LENGTH) // is the amount of records to show less than the default list length?
		    {
			SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH),':',//nCURRENT_INDEX_NUM[nCURRENT_MENU]),':',
				    ITOA(nCURRENT_INDEX_LENGTH)")  //nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_NUM[nCURRENT_MENU])")
			
			//nCURRENT_INDEX_HILITE = nCURRENT_INDEX_LENGTH//nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_NUM[nCURRENT_MENU]
			fnCLEAR_LIST()
			//fnDO_HILITE()
			SEND_VTEXT(TP_FIELDS[20],"ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU] (*- nCURRENT_INDEX_NUM[nCURRENT_MENU]*)),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") 
			//SEND_STRING 0,"'Menu Less than index = ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU] (*- nCURRENT_INDEX_NUM[nCURRENT_MENU]*)),'/',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])"
			nLEVEL_FLAG = 0
		    }
		    ELSE
		    {
			SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_LENGTH-1)") // -1
			//nCURRENT_INDEX_HILITE = nCURRENT_INDEX_LENGTH
			//fnCLEAR_LIST()
			//fnDO_HILITE()
			SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") // ADDED SPACES
			nLEVEL_FLAG = 0
		    }
		}
		ELSE
		{
		    nCURRENT_INDEX_NUM[nCURRENT_MENU] = NRECORD_LEVEL[1] * nMENU_RECORD_COUNT[nCURRENT_MENU]/255
		    IF(nCURRENT_INDEX_NUM[nCURRENT_MENU] >= 2) //added to avoid the iPod name showing up in the Playlists page
		    {
			IF((nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_NUM[nCURRENT_MENU]) < nCURRENT_INDEX_LENGTH) // is the amount of records to show less than the default list length?
			{
			    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_LENGTH),':',ITOA(nCURRENT_INDEX_LENGTH-1)")// -1 //ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),':',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_NUM[nCURRENT_MENU])")
			    //nCURRENT_INDEX_HILITE = nCURRENT_INDEX_LENGTH //nMENU_RECORD_COUNT[nCURRENT_MENU] - nCURRENT_INDEX_NUM[nCURRENT_MENU]
			    fnCLEAR_LIST()
			    //fnDO_HILITE()
			    SEND_VTEXT(TP_FIELDS[20],"ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU] (*- nCURRENT_INDEX_NUM[nCURRENT_MENU]*)),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") // ADDED SPACES
			    //SEND_STRING 0,"'Menu More than index = ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU] (*- nCURRENT_INDEX_NUM[nCURRENT_MENU]*)),'/',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])"
			    nLEVEL_FLAG = 0
			}
			ELSE
			{
			    SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_LENGTH-1)") // -1
			    //nCURRENT_INDEX_HILITE = nCURRENT_INDEX_LENGTH
			    //fnCLEAR_LIST()
			    //fnDO_HILITE()
			    SEND_VTEXT(TP_FIELDS[20],"ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),' / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") // ADDED SPACES
			    nLEVEL_FLAG = 0
			}
		    }
		    ELSE
		    {
			IF(nCURRENT_CATEGORY_START = 1 && nCURRENT_MENU = 2) //Is the current menu the Playlists Menu?
			{
			    nCURRENT_INDEX_NUM[nCURRENT_MENU] = 1 // don't get the playlist which is the name of the iPod - iPod bug fix
			}
			ELSE
			{
			    nCURRENT_INDEX_NUM[nCURRENT_MENU] = 0 // Start menu at beginning of current list
			}
			SEND_CMD("'RETRIEVE_CATEGORIZED_DB_RECORDS?',ITOA(nCURRENT_CATEGORY2[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_NUM[nCURRENT_MENU]),':',ITOA(nCURRENT_INDEX_LENGTH-1)") // -1
			//nCURRENT_INDEX_HILITE = nCURRENT_INDEX_LENGTH
			//fnCLEAR_LIST()
			//fnDO_HILITE()
			SEND_VTEXT(TP_FIELDS[20],"'1 / ',ITOA(nMENU_RECORD_COUNT[nCURRENT_MENU])") // ADDED SPACES
			nLEVEL_FLAG = 0
		    }
		}
	    }
	}
    }
    WAIT 5 // NOTE: This WAIT is for how often the List gets updated when using the bargraph. 
          //This WAIT can be less if the list is smaller or if the Master is an NI2100, NI3100, or NI4100
    nLEVEL_FLAG = 1
}
(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvTP,TP_BUTTONS[4]] = (nONLINE == 1)	     // Online Status button
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)