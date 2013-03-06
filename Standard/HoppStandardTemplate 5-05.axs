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
#include 'HoppSNAPI Rev5-09.axi'
#include 'HoppDEV Rev5-01.axi'
#include 'HoppSTRUCT Rev5-07.axi'
#include 'Queue_and_Threshold_Sizes.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE //leave this line in all caps or device mapping won't work

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //System Constants

NumTPs						=	1

define_constant //buttons

btnStart					=	1
btnShutDown					=	2
btnShutDownCancel			=	3
btnShutDownConfirm			=	4

integer btnMenus[]			=	{}
integer btnSources[]		=	{}
integer btnDests[]			=	{}
integer btnTechControl[]	=	{}

integer btnRoomSettings[]	=	{21,22,23}

//integer btnScreenUp[]	=	{11,13}
//integer btnScreenDown[]	=	{12,14}
//integer btnLiftUp[]		=	{}
//integer btnLiftDown[]	=	{}

define_constant //Sources, Destinations, Menus, and Tech Control



mnuRoomSettings		=	1

tchSwitcher			=	1

define_constant //TPs

tpMain				=	1

define_constant //Flags


define_constant //Volumes


define_constant //IP


define_constant //Relays



(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_variable //Active Variables

volatile		integer		nActiveTP
volatile		integer		nActiveSource[NumTPs]
volatile		integer		nPrevSource[NumTPs]
volatile		integer		nActiveDest[NumTPs]
volatile		integer		nActiveMenu[NumTPs]
volatile		integer		nActiveTechControl[NumTPs]

define_variable //Navigation Variables

volatile		integer		nEnterTechMode

define_variable //Sources and Destinations

non_volatile	source		srcMain[]
persistent		destination	dstMain[]
volatile		menu		mnuMain[]
volatile		menu		mnuTech[]

define_variable //Popups

volatile		char		cSourcePopups[NumTPs][35]
volatile		char		cHeaderPopups[NumTPs][35]
volatile		char		cStartupPopups[NumTPs][35]

define_variable //Device Arrays

volatile		dev			dvIR[]={}
volatile		dev			dvDisp[]={}
volatile		dev			dvIPClient[]={}

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)
define_function tp_fb()
{
	//Source and Menu Feedback
	for(y=1;y<=NumTPs;y++) for(x=1;x<=length_array(btnSources);x++) [dvTP_SRC[1][y],btnSources[x]]=nActiveSource[y]=x
	for(y=1;y<=NumTPs;y++) for(x=1;x<=length_array(btnMenus);x++) [dvTP[y],btnMenus[x]]=nActiveMenu[y]=x
	//Tech Control Feedback
	for(y=1;y<=NumTPs;y++) for(x=1;x<=length_array(btnTechControl);x++) [dvTP_TECH[y],btnTechControl[x]]=nActiveTechControl[y]=x
	//Submenu Feedback
	for(y=1;y<=NumTPs;y++) for(x=1;x<=length_array(btnRoomSettings);x++) [dvTP[y],btnRoomSettings[x]]=mnuMain[mnuRoomSettings].activesubmenu[y]=x
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
	send_command dvTP[tp],"'@PPN-',cStartupPopups[tp]"
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start //Sources

srcMain[    ].name					=	'Name'
srcMain[    ].tie					=	1
srcMain[    ].type					=	RGB_TYPE
srcMain[    ].popup					=	'[source]Name'
srcMain[    ].paneright				=	'[paneRight]Destinations'

//srcMain[srcVTC].name						=	'VTC'
//srcMain[srcVTC].tie							=	7
//srcMain[srcVTC].type						=	RGB_TYPE
//srcMain[srcVTC].paneleft					=	'[paneLeft]Video Conf'
//srcMain[srcVTC].paneright					=	'[paneRight]Destinations'
//srcMain[srcVTC].hassubmenu					=	1
//srcMain[srcVTC].submenupopups[1]			=	'[videoConf]Menus'
//srcMain[srcVTC].submenupopups[2]			=	'[videoConf]Keypad'
//srcMain[srcVTC].submenupopups[3]			=	'[videoConf]Cameras'
//srcMain[srcVTC].submenupopups[4]			=	'[videoConf]Dual'

define_start //Destinations

dstMain[    ].name					=	'Name'
dstMain[    ].tie					=	1
//dstMain[    ].screenup				=	{dvRelays,1}
//dstMain[    ].screendown			=	{dvRelays,2}
//dstMain[    ].liftup				=	{dvRelays,3}
//dstMain[    ].liftdown				=	{dvRelays,4}

define_start //Menus

mnuMain[mnuRoomSettings].hassubmenu			=	1
mnuMain[mnuRoomSettings].paneleft			=	'[paneLeft]Room Settings'
mnuMain[mnuRoomSettings].submenupopups[1]	=	'[roomSettings]Displays'
mnuMain[mnuRoomSettings].submenupopups[2]	=	'[roomSettings]Audio'
mnuMain[mnuRoomSettings].submenupopups[3]	=	'[roomSettings]Lights'
//mnuMain[mnuRoomSettings].popup			=	'[roomSettings]Main'

define_start //Tech Control

mnuTech[tchSwitcher].popup					=	'[device]Switcher'

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

write_mixer()

define_start //IP

//ip[].dvIP					=	dvIPDevice
//ip[].IPAddress 				=	'192.168.1.1'
//ip[].port					=	23
//ip[].type					=	1

define_start //Actual Startup

#INCLUDE 'HoppSTART Rev5-02'
(***********************************************************)
(*                  MODULES GO BELOW                       *)
(***********************************************************)
define_module 'IR Devices Rev5-00' ir1(vdvTP_IR,dvIR)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
define_event //Data Events

data_event[dvTP]
{
	online:
	{
		wait 100 query_mixer()
		off[dvDisp,VD_PWR_ON]
		off[dvDisp,VD_PWR_OFF]
	}
	string:
	{
		send_string vdvATC1,"data.text"
	}	
}

define_event //Channel Events

channel_event[dvDisp,0]
{
	on:
	{
		stack_var integer nActiveDisp
		nActiveDisp=get_last(dvDisp)
		switch(channel.channel)
		{
			case VD_PWR_ON:
			{
				on[dstMain[nActiveDisp].pwr]
				send_command dvTP_DEST[1],"'^TXT-',itoa(nActiveDisp),',0,',srcMain[dstMain[nActiveDisp].src].name"
				send_command dvTP_DEST[1],"'^TXT-',itoa(nActiveDisp+100),',0,',srcMain[dstMain[nActiveDisp].src].name"
				send_command dvTP_DEST[1],"'^BMF-',itoa(nActiveDisp+100),',0,%CT LightLime'"
			}
			case VD_PWR_OFF:
			{
				off[dstMain[nActiveDisp].pwr]
				pulse[dstMain[nActiveDisp].liftup]
				send_command dvTP_DEST[1],"'^TXT-',itoa(nActiveDisp),',0,Off'"
				send_command dvTP_DEST[1],"'^TXT-',itoa(nActiveDisp+100),',0,Off'"
				send_command dvTP_DEST[1],"'^BMF-',itoa(nActiveDisp+100),',0,%CT LightRed'"
			}
			case VD_COOLING:
			{
				off[dstMain[nActiveDisp].pwr]
				pulse[dstMain[nActiveDisp].screenup]
				send_command dvTP_DEST[1],"'^TXT-',itoa(nActiveDisp),',0,Cooling Down'"
				send_command dvTP_DEST[1],"'^TXT-',itoa(nActiveDisp+100),',0,Cooling Down'"
				send_command dvTP_DEST[1],"'^BMF-',itoa(nActiveDisp+100),',0,%CT VeryLightYellow'"
			}
			case VD_WARMING:
			{
				on[dstMain[nActiveDisp].pwr]
				pulse[dstMain[nActiveDisp].screendown]
				pulse[dstMain[nActiveDisp].liftdown]
				send_command dvTP_DEST[1],"'^TXT-',itoa(nActiveDisp),',0,Warming Up'"
				send_command dvTP_DEST[1],"'^TXT-',itoa(nActiveDisp+100),',0,Warming Up'"
				send_command dvTP_DEST[1],"'^BMF-',itoa(nActiveDisp+100),',0,%CT VeryLightYellow'"
			}
		}
	}
}

define_event //Startup and Shutdown

button_event[dvTP,btnStart]
{
	push:
	{
		to[button.input]
		nActiveTP=get_last(dvTP)
		send_command button.input.device,"'PAGE-Main Page'"
		send_command button.input.device,"'@PPN-',cSourcePopups[nActiveTP]"
		send_command button.input.device,"'@PPN-',cHeaderPopups[nActiveTP]"		
		show_startup_instructions(nActiveTP)
	}
}


button_event[dvTP,btnShutDown]
button_event[dvTP,btnShutDownCancel]
button_event[dvTP,btnShutDownConfirm]
{
	push:
	{
		nActiveTP=get_last(dvTP)
		to[button.input]
	}
	hold[30]:
	{
		switch(button.input.channel)
		{
			case btnShutDown: 
			{
				on[nEnterTechMode]
				send_command button.input.device,"'ABEEP'"
				send_command button.input.device,"'PAGE-Tech Page'"
				send_command button.input.device,"'@PPN-[devices]Main;Tech Page'"
			}
		}
	}	
	release:
	{
		nActiveTP=get_last(dvTP)
		switch(button.input.channel)
		{
			case btnShutDown: 
			{
				if(!nEnterTechMode)	send_command button.input.device,"'@PPN-[popup]Power'"
			}
			case btnShutDownCancel: send_command button.input.device,"'@PPF-[popup]Power'"
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
				switchaudio(0,1)
			}
		}
		off[nEnterTechMode]
	}
}

define_event //Panel Events

button_event[dvTP,btnMenus]
{
	push:
	{
		nActiveTP=get_last(dvTP)
		if(nActiveMenu[nActiveTP]=get_last(btnMenus))
		{
			if(nPrevSource[nActiveTP]) do_push(dvTP_SRC[1][nActiveTP],btnSources[nPrevSource[nActiveTP]])
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
			if(mnuMain[nActiveMenu[nActiveTP]].paneleft) send_command button.input.device,"'@PPN-',mnuMain[nActiveMenu[nActiveTP]].paneleft"
			else send_command button.input.device,"'@PPF-[paneLeft]Tabs'"
			if(mnuMain[nActiveMenu[nActiveTP]].paneright) send_command button.input.device,"'@PPN-',mnuMain[nActiveMenu[nActiveTP]].paneright"
			else send_command button.input.device,"'@PPF-[paneRight]Tabs'"
			if(mnuMain[nActiveMenu[nActiveTP]].hassubmenu)
			{
				if(!mnuMain[nActiveMenu[nActiveTP]].activesubmenu[nActiveTP]) mnuMain[nActiveMenu[nActiveTP]].activesubmenu[nActiveTP]=1
				send_command button.input.device,"'@PPN-',mnuMain[nActiveMenu[nActiveTP]].submenupopups[mnuMain[nActiveMenu[nActiveTP]].activesubmenu[nActiveTP]]"
			}
			else
			{
				send_command button.input.device,"'@PPN-',mnuMain[nActiveMenu[nActiveTP]].popup"
			}
		}
	}
}

button_event[dvTP,btnRoomSettings]
{
	push:
	{
		nActiveTP=get_last(dvTP)
		mnuMain[mnuRoomSettings].activesubmenu[nActiveTP]=get_last(btnRoomSettings)
		send_command button.input.device,"'@PPN-',mnuMain[mnuRoomSettings].submenupopups[mnuMain[mnuRoomSettings].activesubmenu[nActiveTP]]"
	}
}

define_event //Routing

button_event[dvTP_SRC[1],btnSources]
{
	push:
	{
		nActiveTP=get_last(dvTP_SRC[1])
		nActiveSource[nActiveTP]=get_last(btnSources)
		off[nActiveMenu[nActiveTP]]
		
		if(srcMain[nActiveSource[nActiveTP]].paneleft) send_command button.input.device,"'@PPN-',srcMain[nActiveSource[nActiveTP]].paneleft"
		else send_command button.input.device,"'@PPF-[paneLeft]Tabs'"
		
		if(srcMain[nActiveSource[nActiveTP]].paneright)  send_command button.input.device,"'@PPN-',srcMain[nActiveSource[nActiveTP]].paneright"
		else send_command button.input.device,"'@PPF-[paneRight]Tabs'"
		
		if(srcMain[nActiveSource[nActiveTP]].hassubmenu)
		{
			if(!srcMain[nActiveSource[nActiveTP]].activesubmenu[nActiveTP]) 
				srcMain[nActiveSource[nActiveTP]].activesubmenu[nActiveTP]=1  
			send_command button.input.device,"'@PPN-',srcMain[nActiveSource[nActiveTP]].submenupopups[srcMain[nActiveSource[nActiveTP]].activesubmenu[nActiveTP]]"
		}
		else send_command button.input.device,"'@PPN-',srcMain[nActiveSource[nActiveTP]].popup"
	}
	hold[10]:
	{
		show_startup_instructions(nActiveTP)
		off[nActiveSource[nActiveTP]]
	}
}

button_event[dvTP_DEST[1],btnDests]
{
	push:
	{
		to[button.input]
		nActiveTP=get_last(dvTP_DEST[1])
		nActiveDest[nActiveTP]=get_last(btnDests)
		dstMain[nActiveDest[nActiveTP]].src=nActiveSource[nActiveTP]
		if (dstMain[nActiveDest[nActiveTP]].pwr) 
		{
			send_command dvTP_DEST[1],"'^TXT-',itoa(nActiveDest[nActiveTP]),',0,',srcMain[nActiveSource[nActiveTP]].name"
			send_command dvTP_DEST[1],"'^TXT-',itoa(nActiveDest[nActiveTP]+100),',0,',srcMain[nActiveSource[nActiveTP]].name"
		}
		
		//Switch Video and Audio here
	}
}

define_event //Tech Control

button_event[dvTP_TECH,btnTechControl]
{
	push:
	{
		nActiveTP=get_last(dvTP)
		nActiveTechControl[nActiveTP]=get_last(btnTechControl)
		if(mnuTech[nActiveTechControl[nActiveTP]].paneleft) send_command button.input.device,"'@PPN-',mnuTech[nActiveTechControl[nActiveTP]].paneleft"
		else send_command button.input.device,"'@PPF-[paneLeft]Tabs'"
		if(mnuTech[nActiveTechControl[nActiveTP]].paneright) send_command button.input.device,"'@PPN-',mnuTech[nActiveTechControl[nActiveTP]].paneright"
		else send_command button.input.device,"'@PPF-[paneRight]Tabs'"
		if(mnuTech[nActiveTechControl[nActiveTP]].hassubmenu)
		{
			if(!mnuTech[nActiveTechControl[nActiveTP]].activesubmenu[nActiveTP]) mnuTech[nActiveTechControl[nActiveTP]].activesubmenu[nActiveTP]=1
			send_command button.input.device,"'@PPN-',mnuTech[nActiveTechControl[nActiveTP]].submenupopups[mnuTech[nActiveTechControl[nActiveTP]].activesubmenu[nActiveTP]]"
		}
		else
		{
			send_command button.input.device,"'@PPN-',mnuTech[nActiveTechControl[nActiveTP]].popup"
		}
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
