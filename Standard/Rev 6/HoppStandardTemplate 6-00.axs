(***********************************************************)
(*  FILE CREATED ON: 10/02/2008  AT: 10:14:28              *)
(***********************************************************)
(***********************************************************)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 10/02/2008  AT: 10:40:17        *)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
    $History: $
*)
#include 'HoppSNAPI Rev6-00.axi'
#include 'HoppDEV Rev6-00.axi'
#include 'HoppSTRUCT Rev6-00.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE //leave this line in all caps or device mapping won't work

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //System Constants

NumTPs						=	1 	//This constant sets the number of touchpanels in the system and is used to create appropriately sized arrays

define_constant //buttons

integer btnSources[]		=	{	} //Starting at 1, these are the buttons for Sources.  These buttons use dvTP_SRC (1000X:2:1)
integer btnDests[]			=	{	} //Starting at 1, these are the buttons for Destinations.  These buttons use dvTP_DEST (1000X:3:1)
integer btnMenus[]			=	{	} //Starting at 1, these are the buttons for Menus.  These buttons use dvTP_MENU (1000X:4:1)
integer btnSubmenus[]		=	{11,12,13,14,15,16,17,18} //Starting at 11, these are the buttons for the left side Submenus.  These buttons use dvTP_MENU (1000X:4:1)

btnStart					=	1
btnShutDown					=	2
btnShutDownCancel			=	3
btnShutDownConfirm			=	4

integer btnPresets[]		=	{11,12,13,14,15,16,17,18}
btnPresetStart				=	19
btnPresetCancel				=	20

//integer btnScreenUp[]	=	{21,23}
//integer btnScreenDown[]	=	{22,23}
//integer btnLiftUp[]		=	{}
//integer btnLiftDown[]	=	{}

define_constant //Sources, Destinations, and Menus

//Sources

//Destinations

//Menus
mnuAdvanced			=	1
mnuAudio			=	2


define_constant //Presets

prs1			=	1
prs2			=	2
prs3			=	3
prs4			=	4
prs5			=	5
prs6			=	6
prs7			=	7
prsManual		=	8

define_constant //TPs and Rooms

tpMain				=	1

rmMain				=	1

define_constant //Flags



define_constant //Volumes

volMaster			=	1
volPrivacy			=	2

define_constant //IP



define_constant //Relays



(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable //Active Variables

volatile		integer		nActiveTP
volatile		integer		nActivePreset[NumTPs]
volatile		integer		nActiveSource[NumTPs]
volatile		integer		nPrevSource[NumTPs]
volatile		integer		nActiveDest[NumTPs]
volatile		integer		nActiveMenu[NumTPs]

define_variable //Navigation Variables

volatile		integer		nEnterTechMode

define_variable //Sources and Destinations

non_volatile	source		srcMain[10]
persistent		destination	dstMain[3]
persistent		destination	dstSpeakers[1]
volatile		menu		mnuMain[2]

define_variable //Popups

volatile		char		cSourcePopups[NumTPs][35]
volatile		char		cHeaderPopups[NumTPs][35]
volatile		char		cStartupPopups[NumTPs][35]

define_variable //Device Arrays

//volatile		dev			dvIR[]={}
//volatile		dev			dvIPClient[]={}

define_variable //Other Variables

volatile		integer		nSourcePressed[NumTPs]
volatile		integer		nSourceHeld
volatile		integer		nDestHeld
volatile		char		cTPResponse[255]
volatile		devchan		dcShutDown

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)
define_function tp_fb()
{
	//Preset Feedback
	for(y=1;y<=NumTPs;y++) for(x=1;x<=length_array(btnPresets);x++) [dvTP[y],btnPresets[x]]=nActivePreset[y]=x
	//Source and Menu Feedback
	for(y=1;y<=NumTPs;y++) if(!nSourcePressed[y]) for(x=1;x<=length_array(btnSources);x++) [dvTP_SRC[y],btnSources[x]]=nActiveSource[y]=x
	for(y=1;y<=NumTPs;y++) for(x=1;x<=length_array(btnMenus);x++) [dvTP_MENU[y],btnMenus[x]]=nActiveMenu[y]=x
	//Audio Feedback
	for(x=1;x<=length_array(btnSources);x++)
	{
		switch(srcMain[x].voltype)
		{
			case PROG_VOL_TYPE:	
			{
				if(dstSpeakers[rmMain].src=x) 
				{
					switch(vol[srcMain[x].vol].mte)
					{
						case 1:	send_level dvTP_SRC,x,1
						case 0: 
						{
							select
							{
								active(vol[srcMain[x].vol].lvl>=0 and vol[srcMain[x].vol].lvl<=85): send_level dvTP_SRC,x,2
								active(vol[srcMain[x].vol].lvl>85 and vol[srcMain[x].vol].lvl<=170): send_level dvTP_SRC,x,3
								active(vol[srcMain[x].vol].lvl>170 and vol[srcMain[x].vol].lvl<=255): send_level dvTP_SRC,x,4
							}
						}
					}
				}
				else send_level dvTP_SRC,x,0
			}
			case CONF_VOL_TYPE:
			{
				switch(vol[srcMain[x].vol].mte)
				{
					case 1:	send_level dvTP_SRC,x,1
					case 0: 
					{
						select
						{
							active(vol[srcMain[x].vol].lvl>=0 and vol[srcMain[x].vol].lvl<=85): send_level dvTP_SRC,x,2
							active(vol[srcMain[x].vol].lvl>85 and vol[srcMain[x].vol].lvl<=170): send_level dvTP_SRC,x,3
							active(vol[srcMain[x].vol].lvl>170 and vol[srcMain[x].vol].lvl<=255): send_level dvTP_SRC,x,4
						}
					}
				}
			}
		}
	}
	//Submenu Feedback
	for(y=1;y<=NumTPs;y++) 
	{
		if(nActiveSource[y]) for(x=1;x<=length_array(btnSubmenus);x++)[dvTP_MENU[y],btnSubmenus[x]]=srcMain[nActiveSource[y]].activesubmenu[y]=x
		if(nActiveMenu[y]) for(x=1;x<=length_array(btnSubmenus);x++)[dvTP_MENU[y],btnSubmenus[x]]=mnuMain[nActiveMenu[y]].activesubmenu[y]=x
	}
}

define_function switchaudio(i,o)
{
	//Autopatch Style
	//if(i=0) send_string dvSwitcher,"'DL2O',itoa(o),'T'"
	//else send_string dvSwitcher,"'CL2I',itoa(i),'O',itoa(o),'T'"
	
	//Extron Style
	//send_string dvSwitcher,"itoa(i),'*',itoa(o),'$'"
	
	//AMX Enova DVX Style
	//send_command dvSwitcher,"'CLAUDIOI',itoa(i),'O',itoa(o)"
}

define_function switchvideo(i,o) //Extron Crosspoint
{  
	//Autopatch Style
	//if(i=0) send_string dvSwitcher,"'DL1O',itoa(o),'T'"
	//else send_string dvSwitcher,"'CL1I',itoa(i),'O',itoa(o),'T'"

	//Extron Style
	//send_string dvSwitcher,"itoa(i),'*',itoa(o),'%'"
	
	//AMX Enova DVX Style
	//send_command dvSwitcher,"'CLVIDEOI',itoa(i),'O',itoa(o)"
	
	//AMX Enova DGX Style
	//if(i=0) send_command dvSwitcher,"'DO',itoa(o),'T'"
	//else send_command dvSwitcher,"'CI',itoa(i),'O',itoa(o),'T'"
}

define_function show_startup_instructions(TP)
{
	send_command dvTP[tp],"'@PPF-[paneLeft]Tabs'"
	send_command dvTP[tp],"'@PPF-[paneRight]Tabs'"
	send_command dvTP[tp],"'@PPN-',cStartupPopups[tp],';Main Page'"
}

define_function update_panel()
{
	update_destination_text()
}

define_function update_destination_text()
{
	for(x=1;x<=length_array(btnDests);x++)
	{
		switch(dstMain[x].pwr)
		{
			case VD_PWR_ON:
			{
				if(dstMain[x].src and length_string(srcMain[dstMain[x].src].name)>0)
				{
					send_command dvTP_DEST,"'^TXT-',itoa(x),',0,',srcMain[dstMain[x].src].name"
					send_command dvTP_DEST,"'^TXT-',itoa(x+100),',0,',srcMain[dstMain[x].src].name"
				}
				else
				{
					send_command dvTP_DEST,"'^TXT-',itoa(x),',0,On'"
					send_command dvTP_DEST,"'^TXT-',itoa(x+100),',0,On'"
				}
				send_command dvTP_DEST,"'^BMF-',itoa(x+100),',0,%CT LightLime'"
			}
			case VD_PWR_OFF:
			{
				send_command dvTP_DEST,"'^TXT-',itoa(x),',0,Off'"
				send_command dvTP_DEST,"'^TXT-',itoa(x+100),',0,Off'"
				send_command dvTP_DEST,"'^BMF-',itoa(x+100),',0,%CT LightRed'"
			}
			case VD_COOLING:
			{
				send_command dvTP_DEST,"'^TXT-',itoa(x),',0,Cooling Down'"
				send_command dvTP_DEST,"'^TXT-',itoa(x+100),',0,Cooling Down'"
				send_command dvTP_DEST,"'^BMF-',itoa(x+100),',0,%CT VeryLightYellow'"
			}
			case VD_WARMING:
			{
				send_command dvTP_DEST,"'^TXT-',itoa(x),',0,Warming Up'"
				send_command dvTP_DEST,"'^TXT-',itoa(x+100),',0,Warming Up'"
				send_command dvTP_DEST,"'^BMF-',itoa(x+100),',0,%CT VeryLightYellow'"
			}
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start //Sources

//srcMain[	].name						=	'PC 1'
//srcMain[	].tie						=	3
//srcMain[	].popup						=	'[source]PC'
//srcMain[	].paneright					=	'[paneRight]Destinations'
//srcMain[	].vol						=	volProgram
//srcMain[	].voltype					=	PROG_VOL_TYPE
//
//srcMain[srcATC].name					=	'ATC'
//srcMain[srcATC].popup					=	'[audioConf]Keypad'
//srcMain[srcATC].vol						=	volATC
//srcMain[srcATC].voltype					=	CONF_VOL_TYPE
//
//srcMain[srcVTC].name					=	'VTC'
//srcMain[srcVTC].tie						=	1
//srcMain[srcVTC].paneleft				=	'[paneLeft]Video Conf'
//srcMain[srcVTC].paneright				=	'[paneRight]Destinations'
//srcMain[srcVTC].submenupopups[1]		=	'[videoConf]Cisco Menus'
//srcMain[srcVTC].submenupopups[2]		=	'[videoConf]Cameras'
//srcMain[srcVTC].submenupopups[3]		=	'[videoConf]Content'
//srcMain[srcVTC].vol						=	volVTC
//srcMain[srcVTC].voltype					=	CONF_VOL_TYPE

define_start //Destinations

//dstMain[	].name					=	'Projector 1'
//dstMain[	].tie					=	3
//dstMain[	].screenup				=	{dvRelays,1}
//dstMain[	].screendown			=	{dvRelays,2}
//dstMain[    ].liftup					=	{dvRelays,3}
//dstMain[    ].liftdown				=	{dvRelays,4}
//
//dstMain[	].name					=	'Projector 2'
//dstMain[	].tie					=	2
//dstMain[    ].screenup				=	{dvRelays,1}
//dstMain[    ].screendown				=	{dvRelays,2}
//dstMain[    ].liftup					=	{dvRelays,3}
//dstMain[    ].liftdown				=	{dvRelays,4}

dstSpeakers[rmMain].tie					=	1


define_start //Menus

mnuMain[mnuAdvanced].paneleft				=	'[paneLeft]Advanced'
mnuMain[mnuAdvanced].submenupopups[1]		=	'[roomSettings]Displays'
mnuMain[mnuAdvanced].submenupopups[2]		=	'[roomSettings]Lights'
mnuMain[mnuAdvanced].submenupopups[3]		=	'[roomSettings]Shut Down'
//mnuMain[mnuRoomSettings].popup			=	'[roomSettings]Main'

//mnuMain[mnuAudio].paneleft				=	'[paneLeft]Audio'
//mnuMain[mnuAudio].submenupopups[1]		=	'[audio]Mics'
//mnuMain[mnuAudio].submenupopups[2]		=	'[audio]Speakers'
mnuMain[mnuAudio].popup						=	'[audio]Volume'

define_start //Popups

cSourcePopups[tpMain]				=	'[sources]Main'

cHeaderPopups[tpMain]				=	'[header]Main'

cStartupPopups[tpMain]				=	'[help]Startup'

define_start //Camera
//
//Cam[1].dvcam	= dvCam
//Cam[1].addr 	= 1
//Cam[1].pan 		= 8
//Cam[1].tilt 	= 6
//Cam[1].zoom 	= 3

write_camera()


define_start //Volumes
//Biamp Style
//vol[].instID			=	12
//vol[].chan			=	'1'
//vol[].addr			=	'1'
//
//ClearOne Style
//vol[].addr		= 'D0'	//Address of XAP unit
//vol[].type		= 'F'			//I=Input, O=Output, P=Process, M=Mic
//vol[].chan		= '1'			//Channel to be controlled
//vol[].min			= -30			//Min level
//vol[].max			= 18			//Max level
//vol[].ramp		= 10			//Ramp time (dB/s)

//Polycom Style
//
//vol[].name		=	''

write_mixer()

define_start //IP

//ip[    ].dvIP					=	dvDevice
//ip[    ].IPAddress 				=	'192.168.1.101'
//ip[    ].port					=	23
//ip[    ].type					=	IP_TCP
//ip[    ].dev_type				=	EXTRON_TYPE

define_start //Auto Shutdown

dcShutDown.device=dvTP[tpMain]
dcShutDown.channel=btnShutDownConfirm

define_start //Actual Startup


define_start //Most Include Files go here
#INCLUDE 'HoppSTART Rev6-00'
#INCLUDE 'HoppTECH Rev6-00'
#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                  MODULES GO BELOW                       *)
(***********************************************************)
//define_module 'IR Devices Rev6-00' ir1(vdvTP_IR,dvIR)
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event //Module Communication

data_event[dvTP]
{
	online:
	{
		update_panel()
	}
	string:
	{
		cTPResponse=data.text
		if (left_string(cTPResponse,10)='KEYP-ABORT' or left_string(cTPResponse,10)='KEYB-ABORT')
		{
			pulse[vdvRenaming[get_last(dvTP)],RNM_ABORT]
		}
		else if (left_string(cTPResponse,5)='KEYP-')
		{
			pulse[vdvRenaming[get_last(dvTP)],RNM_KEYPAD_RCVD]
		}
		else if (left_string(cTPResponse,5)='KEYB-')
		{
			pulse[vdvRenaming[get_last(dvTP)],RNM_KEYBRD_RCVD]
		}
	}
}

channel_event[vdvDISP_FB,0]
{
	on:
	{
		stack_var integer nActiveDisp
		nActiveDisp=get_last(vdvDISP_FB)
		switch(channel.channel)
		{
			case VD_PWR_ON: 
			{
				dstMain[nActiveDisp].pwr=channel.channel
			}
			case VD_PWR_OFF:
			{
				dstMain[nActiveDisp].pwr=channel.channel
				pulse[dstMain[nActiveDisp].liftup]
			}
			case VD_COOLING:
			{
				dstMain[nActiveDisp].pwr=channel.channel
				pulse[dstMain[nActiveDisp].screenup]
			}
			case VD_WARMING:
			{
				dstMain[nActiveDisp].pwr=channel.channel
				pulse[dstMain[nActiveDisp].screendown]
				pulse[dstMain[nActiveDisp].liftdown]
			}
		}
		update_destination_text()
	}
}

channel_event[vdvMixer_FB,0]
{
	on:
	{
		switch(channel.channel)
		{
			case MIX_MUTE_ON:
			{
				on[vol[get_last(vdvMixer_FB)].mte]
			}
			case MIX_MUTE_OFF:
			{
				off[vol[get_last(vdvMixer_FB)].mte]
			}
		}
	}
}

level_event[vdvMixer_FB,1]
{
	vol[get_last(vdvMixer_FB)].lvl=level.value
}

define_event //Startup and Shutdown

button_event[dvTP,btnStart]  //This version of the Start Button is for a regular system without presets
{
	push:
	{
		to[button.input]
		nActiveTP=get_last(dvTP)
		send_command button.input.device,"'@PPN-',cSourcePopups[nActiveTP],';Main Page'"
		send_command button.input.device,"'@PPN-',cHeaderPopups[nActiveTP],';Main Page'"		
		send_command button.input.device,"'PAGE-Main Page'"
		show_startup_instructions(nActiveTP)
		query_mixer()
	}
}

//button_event[dvTP,btnStart]  //This version of the Start Button is for a system with Presets
//{
//	push:
//	{
//		to[button.input]
//		send_command button.input.device,"'PAGE-Preset Page'"
//	}
//}
//
//
//button_event[dvTP,btnPresets]
//{
//	push:
//	{
//		nActiveTP=get_last(dvTP)
//		nActivePreset[nActiveTP]=get_last(btnPresets)
//	}
//}
//
//button_event[dvTP,btnPresetStart]
//button_event[dvTP,btnPresetCancel]
//{
//	push:
//	{
//		to[button.input]
//		nActiveTP=get_last(dvTP)
//		switch(button.input.channel)
//		{
//			case btnPresetCancel: send_command button.input.device,"'PAGE-Title Page'"
//			case btnPresetStart:
//			{
//				switch(nActivePreset[nActiveTP])
//				{
//					case prs1:
//					case prs2:
//					case prs3:
//					case prs4:
//					case prs5:
//					case prs6:
//					case prs7:
//					{
//						//Insert Preset here.  Usually just a bunch of do_pushes on sources and destinations to set up the system the way the client wants it
//					}
//					case prsManual:
//					{
//						show_startup_instructions(nActiveTP)
//					}
//				}
//			}
//			send_command button.input.device,"'@PPN-',cSourcePopups[nActiveTP],';Main Page'"
//			send_command button.input.device,"'@PPN-',cHeaderPopups[nActiveTP],';Main Page'"		
//			send_command button.input.device,"'PAGE-Main Page'"
//		}
//	}
//}

button_event[dvTP,btnShutDown]
button_event[dvTP,btnShutDownCancel]
button_event[dvTP,btnShutDownConfirm]
{
	push:
	{
		nActiveTP=get_last(dvTP)
		to[button.input]
	}
	release:
	{
		nActiveTP=get_last(dvTP)
		switch(button.input.channel)
		{
			case btnShutDown: 
			{
				send_command button.input.device,"'@PPN-[popup]Power;Main Page'"
			}
			case btnShutDownCancel: send_command button.input.device,"'@PPF-[popup]Power;Main Page'"
			case btnShutDownConfirm:
			{
				send_command dvTP,"'@PPX'"
				send_command dvTP,"'PAGE-Title Page'"
				for(x=1;x<=NumTPs;x++) 
				{
					off[nActiveMenu[x]]
					off[nActiveSource[x]]
				}
				for(x=1;x<=length_array(btnDests);x++) pulse[vdvDisp[x],VD_PWR_OFF]
				switchaudio(0,dstSpeakers[rmMain].tie)
				off[dstSpeakers[rmMain].src]
				pulse[vdvVTC1,VTC_HANGUP]
				pulse[vdvATC1,ATC_HANGUP]
			}
		}
	}
}

define_event //Panel Navigation

button_event[dvTP_MENU,btnMenus]
{
	push:
	{
		nActiveTP=get_last(dvTP)
		if(nActiveMenu[nActiveTP]=get_last(btnMenus))
		{
			if(nPrevSource[nActiveTP]) do_push(dvTP_SRC[nActiveTP],btnSources[nPrevSource[nActiveTP]])
			else 
			{
				show_startup_instructions(nActiveTP)
				off[nActiveMenu[nActiveTP]]
			}
		}		
		else
		{
			nActiveMenu[nActiveTP]=get_last(btnMenus)
			nPrevSource[nActiveTP]=nActiveSource[nActiveTP]
			off[nActiveSource[nActiveTP]]
			if(mnuMain[nActiveMenu[nActiveTP]].paneleft) send_command button.input.device,"'@PPN-',mnuMain[nActiveMenu[nActiveTP]].paneleft,';Main Page'"
			else send_command button.input.device,"'@PPF-[paneLeft]Tabs;Main Page'"
			if(mnuMain[nActiveMenu[nActiveTP]].paneright) send_command button.input.device,"'@PPN-',mnuMain[nActiveMenu[nActiveTP]].paneright,';Main Page'"
			else send_command button.input.device,"'@PPF-[paneRight]Tabs;Main Page'"
			if(length_string(mnuMain[nActiveMenu[nActiveTP]].submenupopups[1])>0)
			{
				if(!mnuMain[nActiveMenu[nActiveTP]].activesubmenu[nActiveTP]) mnuMain[nActiveMenu[nActiveTP]].activesubmenu[nActiveTP]=1
				send_command button.input.device,"'@PPN-',mnuMain[nActiveMenu[nActiveTP]].submenupopups[mnuMain[nActiveMenu[nActiveTP]].activesubmenu[nActiveTP]],';Main Page'"
			}
			else
			{
				send_command button.input.device,"'@PPN-',mnuMain[nActiveMenu[nActiveTP]].popup,';Main Page'"
			}
		}
	}
}

button_event[dvTP_MENU,btnSubmenus]
{
	push:
	{
		nActiveTP=get_last(dvTP)
		if(nActiveMenu[nActiveTP])
		{
			mnuMain[nActiveMenu[nActiveTP]].activesubmenu[nActiveTP]=get_last(btnSubmenus)
			send_command button.input.device,"'@PPN-',mnuMain[nActiveMenu[nActiveTP]].submenupopups[mnuMain[nActiveMenu[nActiveTP]].activesubmenu[nActiveTP]],';Main Page'"
		}
		else if(nActiveSource[nActiveTP])
		{
			srcMain[nActiveSource[nActiveTP]].activesubmenu[nActiveTP]=get_last(btnSubmenus)
			send_command button.input.device,"'@PPN-',srcMain[nActiveSource[nActiveTP]].submenupopups[srcMain[nActiveSource[nActiveTP]].activesubmenu[nActiveTP]],';Main Page'"
		}
	}
}

define_event //Routing

button_event[dvTP_SRC,btnSources]
{
	push:
	{
		nActiveTP=get_last(dvTP_SRC)
		to[nSourcePressed[nActiveTP]]
		on[button.input]
	}
	hold[10]:
	{
		on[nSourceHeld]
		dstSpeakers[rmMain].src=get_last(btnSources)
		switchaudio(srcMain[dstSpeakers[rmMain].src].tie,dstSpeakers[rmMain].tie)
	}
	release:
	{
		if(!nSourceHeld)
		{
			nActiveTP=get_last(dvTP_SRC)
			nActiveSource[nActiveTP]=get_last(btnSources)
			off[nActiveMenu[nActiveTP]]
			
			if(srcMain[nActiveSource[nActiveTP]].paneleft) send_command button.input.device,"'@PPN-',srcMain[nActiveSource[nActiveTP]].paneleft,';Main Page'"
			else send_command button.input.device,"'@PPF-[paneLeft]Tabs;Main Page'"
			
			if(srcMain[nActiveSource[nActiveTP]].paneright)  send_command button.input.device,"'@PPN-',srcMain[nActiveSource[nActiveTP]].paneright,';Main Page'"
			else send_command button.input.device,"'@PPF-[paneRight]Tabs;Main Page'"
			
			if(length_string(srcMain[nActiveSource[nActiveTP]].submenupopups[1])>0)
			{
				if(!srcMain[nActiveSource[nActiveTP]].activesubmenu[nActiveTP]) 
					srcMain[nActiveSource[nActiveTP]].activesubmenu[nActiveTP]=1  
				send_command button.input.device,"'@PPN-',srcMain[nActiveSource[nActiveTP]].submenupopups[srcMain[nActiveSource[nActiveTP]].activesubmenu[nActiveTP]],';Main Page'"
			}
			else send_command button.input.device,"'@PPN-',srcMain[nActiveSource[nActiveTP]].popup,';Main Page'"	
		}
		off[nSourceHeld]
	}
}

button_event[dvTP_DEST,btnDests]
{
	push:
	{
		to[button.input]
		nActiveTP=get_last(dvTP_DEST)
		nActiveDest[nActiveTP]=get_last(btnDests)
		
	}
	hold[10]:
	{
		if(dstMain[nActiveDest[nActiveTP]].pwr=VD_PWR_ON)
		{
			on[nDestHeld]
			dstSpeakers[rmMain].src=dstMain[nActiveDest[nActiveTP]].src
			switchaudio(srcMain[dstSpeakers[rmMain].src].tie,dstSpeakers[rmMain].tie)
		}
	}
	release:
	{
		if(!nDestHeld)
		{
			nActiveTP=get_last(dvTP_DEST)
			nActiveDest[nActiveTP]=get_last(btnDests)
			dstMain[nActiveDest[nActiveTP]].src=nActiveSource[nActiveTP]
			dstSpeakers[rmMain].src=nActiveSource[nActiveTP]
			update_destination_text()
			
			pulse[vdvDisp[nActiveDest[nActiveTP]],VD_SRC_HDMI1]
			
			switchvideo(srcMain[nActiveSource[nActiveTP]].tie,dstMain[nActiveDest[nActiveTP]].tie)
			switchaudio(srcMain[nActiveSource[nActiveTP]].tie,dstSpeakers[rmMain].tie)
		}
		off[nDestHeld]
	}
}



(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
define_program

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
