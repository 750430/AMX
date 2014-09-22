program_name='Example Rev6 Room'
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
#include 'HoppSNAPI Rev6-00.axi' 	//API: Commands used to communicate between modules
#include 'HoppSTRUCT Rev6-00.axi'	//Structure definitions
#include 'HoppDEV Rev6-00.axi'		//Devices, Devices Arrays
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE //leave this line in all caps or device mapping won't work

dvProj1				=	05001:1:0
dvProj2				=	05001:2:0
dvLights			=	05001:3:0
dvMixer				=	05001:4:0
dvVTC				=	05001:5:0

dvRelays			=	05001:8:0

dvSwitcher			=	00000:3:0

dvTuner				=	05001:9:0
dvBluRay			=	05001:10:0

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //System Constants

NumTPs						=	8 	//This constant sets the number of touchpanels in the system and is used to create appropriately sized arrays

define_constant //buttons

integer btnSources[]		=	{1,2,3,4,5,6,7,8,9,10} //Starting at 1, these are the buttons for Sources.  These buttons use dvTP_SRC (1000X:2:1)
integer btnDests[]			=	{1,2,3} //Starting at 1, these are the buttons for Destinations.  These buttons use dvTP_DEST (1000X:3:1)
integer btnMenus[]			=	{1,2} //Starting at 1, these are the buttons for Menus.  These buttons use dvTP_MENU (1000X:4:1)
integer btnSubmenus[]		=	{11,12,13,14,15,16,17,18} //Starting at 11, these are the buttons for the left side Submenus.  These buttons use dvTP_MENU (1000X:4:1)


btnStart					=	1
btnShutDown					=	2
btnShutDownCancel			=	3
btnShutDownConfirm			=	4

integer btnPresets[]		=	{11,12,13,14,15,16,17,18}
btnPresetStart				=	19
btnPresetCancel				=	20



integer btnVTCContentSelect[]	=	{41,42,43,44}
integer btnVTCCamSelect[]		=	{51,52,53}



define_constant //Sources, Destinations, and Menus

srcPC1				=	1
srcPC2				=	2
srcLaptop1			=	3
srcLaptop2			=	4
srcTV				=	5
srcBluRay			=	6
srcCam				=	7
srcATC1				=	8
srcATC2				=	9
srcVTC				=	10
srcVTCDual			=	11

dstProj1			=	1
dstProj2			=	2
dstVTCCam			=	3
dstVTCContent		=	4
dstVTCDual			=	5

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
tpWindows			=	2

rmMain				=	1

define_constant //Flags



define_constant //Volumes

volMaster			=	1
volPrivacy			=	2
volATC1				=	3
volATC2				=	4
volVTC				=	5
volProgram			=	6
volLectern			=	7
volWireless1		=	8
volWireless2		=	9

define_constant //IP

ipSwitcher		=	1

define_constant //Relays

//Screen and Lift Relays don't need to go here

define_constant //Guide

guidePages			=	9

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
volatile		integer		nActiveGuidePage[NumTPs]

define_variable //Sources and Destinations  

non_volatile	source		srcMain[11]
persistent		destination	dstMain[4]
persistent		destination	dstSpeakers[1]
volatile		menu		mnuMain[2]

define_variable //Structure Instances

volatile		volblock	vol[30]
volatile		camera		cam[10]
volatile		ipcomm 		ip[10]
volatile		ir_struct	ir[10]

define_variable //Guide

volatile		guide		guideMain[guidePages]

define_variable //Lighting

volatile	char	cLightingAddr[] = '00bdea33'

define_variable //ATC Variables
non_volatile	char	cAddr 		= '1'
non_volatile	integer	nInstID 	= 44

define_variable //Popups

volatile		char		cSourcePopups[NumTPs][35]
volatile		char		cHeaderPopups[NumTPs][35]
volatile		char		cStartupPopups[NumTPs][35]

define_variable //Device Arrays

volatile		dev			dvIR[]={dvTuner,dvBluRay}
volatile		dev			dvIPClient[]={dvSwitcher}

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
	//VTC Feedback
	for(x=1;x<=length_array(btnVTCCamSelect);x++) [dvTP,btnVTCCamSelect[x]]=dstMain[dstVTCCam].src=x
	for(x=1;x<=length_array(btnVTCContentSelect);x++) [dvTP,btnVTCContentSelect[x]]=dstMain[dstVTCContent].src=x
	//Guide Feedback
	for(y=1;y<=NumTPs;y++) for(x=1;x<=guidePages;x++) [dvTP_GUIDE[y],GUIDE_STEPS[x]]=nActiveGuidePage[y]=x
	for(y=1;y<=NumTPs;y++) for(x=1;x<=guidePages;x++) for(z=1;z<=5;z++) [dvTP_GUIDE[y],GUIDE_STEP_DOTS[x][z]]=(nActiveGuidePage[y]=x and guideMain[x].nCurrentSubPage=z)
}

define_function switchaudio(i,o)
{
	//Autopatch Style
	//if(i=0) send_string dvSwitcher,"'DL2O',itoa(o),'T'"
	//else send_string dvSwitcher,"'CL2I',itoa(i),'O',itoa(o),'T'"
	
	//Extron Style
	send_string dvSwitcher,"itoa(i),'*',itoa(o),'$'"
	
	//AMX Enova DVX Style
	//send_command dvSwitcher,"'CLAUDIOI',itoa(i),'O',itoa(o)"
}

define_function switchvideo(i,o) //Extron Crosspoint
{  
	//Autopatch Style
	//if(i=0) send_string dvSwitcher,"'DL1O',itoa(o),'T'"
	//else send_string dvSwitcher,"'CL1I',itoa(i),'O',itoa(o),'T'"

	//Extron Style
	send_string dvSwitcher,"itoa(i),'*',itoa(o),'%'"
	
	//AMX Enova DVX Style
	//send_command dvSwitcher,"'CLVIDEOI',itoa(i),'O',itoa(o)"
	
	//AMX Enova DGX Style
	//if(i=0) send_command dvSwitcher,"'DO',itoa(o),'T'"
	//else send_command dvSwitcher,"'CI',itoa(i),'O',itoa(o),'T'"
}


define_function update_panel()
{
	update_destination_text()
	for(x=1;x<=20;x++) 
	{
		if(x<=max_length_array(dstMain))
		{
			if(length_string(dstMain[x].name)>0) send_command dvTP_DISP[x],"'^TXT-',itoa(VD_NAME_TEXT),',0,',dstMain[x].name"
			else send_command dvTP_DISP[x],"'^TXT-',itoa(VD_NAME_TEXT),',0,Display ',itoa(x)"
		}
		else send_command dvTP_DISP[x],"'^TXT-',itoa(VD_NAME_TEXT),',0,Display ',itoa(x)"
	}
	
	pulse[vdvMixer[1],MIX_UPDATE_ALL]
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
					send_command dvTP_DISP[x],"'^TXT-',itoa(VD_SOURCE_TEXT),',0,',srcMain[dstMain[x].src].name"
				}
				else
				{
					send_command dvTP_DEST,"'^TXT-',itoa(x),',0,On'"
					send_command dvTP_DISP[x],"'^TXT-',itoa(VD_SOURCE_TEXT),',0,On'"
				}
				send_command dvTP_DISP[x],"'^BMF-',itoa(VD_SOURCE_TEXT),',0,%CT LightLime'"
			}
			case VD_PWR_OFF:
			{
				send_command dvTP_DEST,"'^TXT-',itoa(x),',0,Off'"
				send_command dvTP_DISP[x],"'^TXT-',itoa(VD_SOURCE_TEXT),',0,Off'"
				send_command dvTP_DISP[x],"'^BMF-',itoa(VD_SOURCE_TEXT),',0,%CT LightRed'"
			}
			case VD_COOLING:
			{
				send_command dvTP_DEST,"'^TXT-',itoa(x),',0,Cooling Down'"
				send_command dvTP_DISP[x],"'^TXT-',itoa(VD_SOURCE_TEXT),',0,Cooling Down'"
				send_command dvTP_DISP[x],"'^BMF-',itoa(VD_SOURCE_TEXT),',0,%CT VeryLightYellow'"
			}
			case VD_WARMING:
			{
				send_command dvTP_DEST,"'^TXT-',itoa(x),',0,Warming Up'"
				send_command dvTP_DISP[x],"'^TXT-',itoa(VD_SOURCE_TEXT),',0,Warming Up'"
				send_command dvTP_DISP[x],"'^BMF-',itoa(VD_SOURCE_TEXT),',0,%CT VeryLightYellow'"
			}
		}
	}
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
define_start //Sources

srcMain[srcPC1].name					=	'PC 1'
srcMain[srcPC1].tie						=	3
srcMain[srcPC1].popup					=	'[source]PC'
srcMain[srcPC1].paneright				=	'[paneRight]Destinations'
srcMain[srcPC1].vol						=	volProgram
srcMain[srcPC1].voltype					=	PROG_VOL_TYPE

srcMain[srcPC2].name					=	'PC 2'
srcMain[srcPC2].tie						=	1
srcMain[srcPC2].popup					=	'[source]PC'
srcMain[srcPC2].paneright				=	'[paneRight]Destinations'
srcMain[srcPC2].vol						=	volProgram
srcMain[srcPC2].voltype					=	PROG_VOL_TYPE

srcMain[srcLaptop1].name				=	'Laptop 1'
srcMain[srcLaptop1].tie					=	1
srcMain[srcLaptop1].popup				=	'[source]Laptop'
srcMain[srcLaptop1].paneright			=	'[paneRight]Destinations'
srcMain[srcLaptop1].vol					=	volProgram
srcMain[srcLaptop1].voltype				=	PROG_VOL_TYPE

srcMain[srcLaptop2].name				=	'Laptop 2'
srcMain[srcLaptop2].tie					=	2
srcMain[srcLaptop2].popup				=	'[source]Laptop'
srcMain[srcLaptop2].paneright			=	'[paneRight]Destinations'
srcMain[srcLaptop2].vol					=	volProgram
srcMain[srcLaptop2].voltype				=	PROG_VOL_TYPE

srcMain[srcTV].name						=	'TV'
srcMain[srcTV].tie						=	5
srcMain[srcTV].popup					=	'[source]TV'
srcMain[srcTV].paneright				=	'[paneRight]Destinations'
srcMain[srcTV].vol						=	volProgram
srcMain[srcTV].voltype					=	PROG_VOL_TYPE

srcMain[srcBluRay].name					=	'Blu-Ray'
srcMain[srcBluRay].tie					=	4
srcMain[srcBluRay].popup				=	'[source]Blu-Ray'
srcMain[srcBluRay].paneright			=	'[paneRight]Destinations'
srcMain[srcBluRay].vol					=	volProgram
srcMain[srcBluRay].voltype				=	PROG_VOL_TYPE

srcMain[srcCam].name					=	'Cameras'
srcMain[srcCam].tie						=	1
srcMain[srcCam].paneleft				=	'[paneLeft]Cameras'
srcMain[srcCam].submenupopups[1]		=	'[cameras]Camera 1'
srcMain[srcCam].submenupopups[2]		=	'[cameras]Camera 2'
srcMain[srcCam].submenupopups[3]		=	'[cameras]Camera 3'

srcMain[srcATC1].name					=	'ATC 1'
srcMain[srcATC1].paneright				=	'[paneRight]Audio Conf'
srcMain[srcATC1].submenupopups[1]		=	'[audioConf1]Keypad'
srcMain[srcATC1].submenupopups[2]		=	'[audioConf1]Contacts'
srcMain[srcATC1].vol					=	volATC1
srcMain[srcATC1].voltype				=	CONF_VOL_TYPE

srcMain[srcATC2].name					=	'ATC 2'
srcMain[srcATC2].paneright				=	'[paneRight]Audio Conf'
srcMain[srcATC2].submenupopups[1]		=	'[audioConf2]Keypad'
srcMain[srcATC2].submenupopups[2]		=	'[audioConf2]Contacts'
srcMain[srcATC2].vol					=	volATC2
srcMain[srcATC2].voltype				=	CONF_VOL_TYPE

srcMain[srcVTC].name					=	'VTC'
srcMain[srcVTC].tie						=	1
srcMain[srcVTC].paneleft				=	'[paneLeft]Video Conf'
srcMain[srcVTC].paneright				=	'[paneRight]VTC Destinations'
srcMain[srcVTC].submenupopups[1]		=	'[videoConf]Cisco Menus'
srcMain[srcVTC].submenupopups[2]		=	'[videoConf]Cameras'
srcMain[srcVTC].submenupopups[3]		=	'[videoConf]Content'
srcMain[srcVTC].vol						=	volVTC
srcMain[srcVTC].voltype					=	CONF_VOL_TYPE

srcMain[srcVTCDual].name				=	'VTC Dual'
srcMain[srcVTCDual].tie					=	1


define_start //Destinations

dstMain[dstProj1].name					=	'Left Projector'
dstMain[dstProj1].tie					=	3
dstMain[dstProj1].screenup				=	{dvRelays,1}
dstMain[dstProj1].screendown			=	{dvRelays,2}
dstMain[dstProj1].liftup				=	{dvRelays,3}
dstMain[dstProj1].liftdown				=	{dvRelays,4}

dstMain[dstProj2].name					=	'Right Projector'
dstMain[dstProj2].tie					=	2
dstMain[dstProj2].screenup				=	{dvRelays,5}
dstMain[dstProj2].screendown			=	{dvRelays,6}
dstMain[dstProj2].liftup				=	{dvRelays,7}
dstMain[dstProj2].liftdown				=	{dvRelays,8}
                                        
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

for(x=1;x<=NumTPs;x++) 
{
	cSourcePopups[x]			=	'[sources]Main'
	cHeaderPopups[x]			=	'[header]Main'
	cStartupPopups[x]			=	'[help]Startup'
}

define_start //Camera
//
//Cam[1].dvcam	= dvCam
//Cam[1].addr 	= 1
//Cam[1].pan 		= 8
//Cam[1].tilt 	= 6
//Cam[1].zoom 	= 3

write_camera(cam,'BinaryCAMEncode.xml')

define_start //IR

ir[1].carrier	=	CAROFF_TYPE
ir[1].mode		=	IR_TYPE

ir[2].pulsetime	=	5

write_ir(ir,'BinaryIREncode.xml')

define_start //Volumes
//Biamp Style
//vol[].instID			=	12
//vol[].chan			=	'1'
//vol[].addr			=	'1'

vol[volMaster].name			=	'Master Volume'
vol[volMaster].instID		=	26
vol[volMaster].chan			=	'1'

vol[volPrivacy].name		=	'Privacy Mute'
vol[volPrivacy].instID		=	24
vol[volPrivacy].chan		=	'1'

vol[volATC1].name			=	'Audio Conf 1'
vol[volATC1].instID			=	9
vol[volATC1].chan			=	'1'

vol[volATC2].name			=	'Audio Conf 2'
vol[volATC2].instID			=	9
vol[volATC2].chan			=	'1'

vol[volVTC].name			=	'Video Conf'
vol[volVTC].instID			=	9
vol[volVTC].chan			=	'1'

vol[volProgram].name		=	'Program Volume'
vol[volProgram].instID		=	47
vol[volProgram].chan		=	'1'

vol[volWireless1].name		=	'Wireless Mic 1'
vol[volWireless1].instID	=	47
vol[volWireless1].chan		=	'1'

vol[volWireless2].name		=	'Wireless Mic 2'
vol[volWireless2].instID	=	47
vol[volWireless2].chan		=	'1'

vol[volLectern].name		=	'Lectern Mic'
vol[volLectern].instID		=	47
vol[volLectern].chan		=	'1'


//
//ClearOne Style
//vol[].addr		= 'D0'	//Address of XAP unit
//vol[].type		= 'F'			//I=Input, O=Output, P=Process, M=Mic
//vol[].chan		= '1'			//Channel to be controlled
//vol[].min			= -30			//Min level
//vol[].max			= 18			//Max level
//vol[].ramp		= 10			//Ramp time (dB/s)

write_mixer(vol,'BinaryMXREncode.xml')

define_start //IP

ip[ipSwitcher].dvIP					=	dvSwitcher
ip[ipSwitcher].name					=	'Switcher'
ip[ipSwitcher].IPAddress 			=	'98.191.72.186'
ip[ipSwitcher].port					=	1320
ip[ipSwitcher].type					=	IP_TCP
ip[ipSwitcher].dev_type				=	EXTRON_TYPE

define_start //Auto Shutdown

dcShutDown.device=dvTP[tpMain]
dcShutDown.channel=btnShutDownConfirm

define_start //Guide

guideMain[1].name				=	'Getting Started'
guideMain[1].popup[1]			=	'[help]Getting Started 1'
guideMain[1].popup[2]			=	'[help]Getting Started 2'
guideMain[1].popup[3]			=	'[help]Getting Started 3'

guideMain[2].name				=	'Understanding Sources'
guideMain[2].popup[1]			=	'[help]Understanding Sources'

guideMain[3].name				=	'Seeing and Hearing Sources'
guideMain[3].popup[1]			=	'[help]Seeing a Source'
guideMain[3].popup[2]			=	'[help]Hearing a Source'
guideMain[3].paneRight			=	'[paneRight]Destinations'
guideMain[3].paneCenter			=	'[source]Blu-Ray'
guideMain[3].nActiveSource		=	srcBluRay

guideMain[4].name				=	'Audio Conferencing'
guideMain[4].popup[1]			=	'[help]Audio Conferencing'
guideMain[4].paneCenter			=	'[audioConf1]Keypad'
guideMain[4].paneRight			=	'[paneRight]Audio Conf'
guideMain[4].nActiveSource		=	srcATC1
guideMain[4].nActiveSubMenu		=	1

guideMain[5].name				=	'Video Conferencing'
guideMain[5].popup[1]			=	'[help]Video Conferencing 1'
guideMain[5].popup[2]			=	'[help]Video Conferencing 2'
guideMain[5].popup[3]			=	'[help]Video Conferencing 3'
guideMain[5].popup[4]			=	'[help]Video Conferencing 4'
guideMain[5].paneLeft			=	'[paneLeft]Video Conf'
guideMain[5].paneCenter			=	'[videoConf]Cisco Menus'
guideMain[5].paneRight			=	'[paneRight]VTC Destinations'
guideMain[5].nActiveSource		=	srcVTC
guideMain[5].nActiveSubMenu		=	1

guideMain[6].name				=	'Controlling Volume'
guideMain[6].popup[1]			=	'[help]Volume'
guideMain[6].paneCenter			=	'[audio]Volume'
guideMain[6].nActiveMenu		=	mnuAudio

guideMain[7].name				=	'Advanced Settings'
guideMain[7].popup[1]			=	'[help]Advanced'
guideMain[7].paneLeft			=	'[paneLeft]Advanced'
guideMain[7].paneCenter			=	'[roomSettings]Displays'
guideMain[7].nActiveMenu		=	mnuAdvanced
guideMain[7].nActiveSubMenu		=	1

guideMain[8].name				=	'Shutting Down'
guideMain[8].popup[1]			=	'[help]Shutting Down'

guideMain[9].name				=	'Service'
guideMain[9].popup[1]			=	'[help]Service'

//This loop adds the "Show Me" guide popup for each page except the last, which is the Service page and has no guide popup
for(x=1;x<=guidePages-1;x++) guideMain[x].guidepopup		=	"'[guide]',itoa(x)"

//This loop stores in the .nSubPages variable the number of subpages for each guide, which is used for creating the correct
//number of pips for each page on the screen
for(x=1;x<=guidePages;x++) 
{
	guideMain[x].nSubPages=0
	for(y=1;y<=5;y++) if(length_string(guideMain[x].popup[y])>0) guideMain[x].nSubPages++
}
//
//define_start //Guide Alternate Look
//
//guideMain[1].name				=	'Getting Started'
//guideMain[1].popup[1]			=	'[help]Getting Started 1'
//guideMain[1].popup[2]			=	'[help]Getting Started 2'
//
//guideMain[2].name				=	'Understanding Sources'
//guideMain[2].popup[1]			=	'[help]Understanding Sources'
//guideMain[2].popup[2]			=	'[help]Getting Started 3'
//
//guideMain[3].name				=	'Seeing and Hearing Sources'
//guideMain[3].popup[1]			=	'[help]Seeing a Source'
//guideMain[3].popup[2]			=	'[help]Hearing a Source'
//guideMain[3].paneRight			=	'[paneRight]Destinations'
//guideMain[3].paneCenter			=	'[source]Blu-Ray'
//guideMain[3].nActiveSource		=	srcBluRay
//
//guideMain[4].name				=	'Audio Conferencing'
//guideMain[4].popup[1]			=	'[help]Audio Conferencing'
//guideMain[4].popup[2]			=	'[help]Hearing a Source'
//guideMain[4].popup[3]			=	'[help]Audio Conferencing'
//guideMain[4].paneCenter			=	'[audioConf1]Keypad'
//guideMain[4].paneRight			=	'[paneRight]Audio Conf'
//guideMain[4].nActiveSource		=	srcATC1
//guideMain[4].nActiveSubMenu		=	1
//
//guideMain[5].name				=	'Video Conferencing'
//guideMain[5].popup[1]			=	'[help]Video Conferencing 1'
//guideMain[5].popup[2]			=	'[help]Video Conferencing 2'
//guideMain[5].popup[3]			=	'[help]Video Conferencing 3'
//guideMain[5].popup[4]			=	'[help]Video Conferencing 4'
//guideMain[5].paneLeft			=	'[paneLeft]Video Conf'
//guideMain[5].paneCenter			=	'[videoConf]Cisco Menus'
//guideMain[5].paneRight			=	'[paneRight]VTC Destinations'
//guideMain[5].nActiveSource		=	srcVTC
//guideMain[5].nActiveSubMenu		=	1
//
//guideMain[6].name				=	'Controlling Volume'
//guideMain[6].popup[1]			=	'[help]Volume'
//guideMain[6].paneCenter			=	'[audio]Volume'
//guideMain[6].nActiveMenu		=	mnuAudio
//
//guideMain[7].name				=	'Service'
//guideMain[7].popup[1]			=	'[help]Service'
//
////This loop adds the "Show Me" guide popup for each page except the last, which is the Service page and has no guide popup
//for(x=1;x<=6;x++) guideMain[x].guidepopup		=	"'[guide]',itoa(x)"
//
////This loop stores in the .nSubPages variable the number of subpages for each guide, which is used for creating the correct
////number of pips for each page on the screen
//for(x=1;x<=6;x++) 
//{
//	guideMain[x].nSubPages=0
//	for(y=1;y<=5;y++) if(length_string(guideMain[x].popup[y])>0) guideMain[x].nSubPages++
//}


define_start //Actual Startup


define_start //Most Include Files go here
#INCLUDE 'HoppSTART Rev6-00'
#INCLUDE 'HoppFB Rev6-00'
#INCLUDE 'RenameATC1 Rev6-00'
#INCLUDE 'RenameATC2 Rev6-00'
#INCLUDE 'RenameLIGHTS1 Rev6-00'
#INCLUDE 'RenameLIGHTS2 Rev6-00'
#INCLUDE 'RenameLIGHTS3 Rev6-00'
#INCLUDE 'HoppGUIDE Rev6-00'
//#INCLUDE 'HoppSERVER Rev6-00'
(***********************************************************)
(*                  MODULES GO BELOW                       *)
(***********************************************************)
define_module 'IR Devices Rev6-01' ir1(vdvTP_IR,dvIR)
define_module 'Fake Projector Rev6-01' disp1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvProj1)
define_module 'Fake Projector Rev6-01' disp2(dvTP_DISP[2],vdvDISP2,vdvDISP2_FB,dvProj2)
define_module 'Lutron QSE-CL-NWK-E Rev6-00' lights1(dvTP_LIGHT[1],vdvLIGHT1,vdvLIGHT1_FB,dvLights,cLightingAddr)                                         
define_module 'Lutron QSE-CL-NWK-E Rev6-00' lights2(dvTP_LIGHT[2],vdvLIGHT2,vdvLIGHT2_FB,dvLights,cLightingAddr)                                         
define_module 'Lutron QSE-CL-NWK-E Rev6-00' lights3(dvTP_LIGHT[3],vdvLIGHT3,vdvLIGHT3_FB,dvLights,cLightingAddr)                                         
define_module 'Fake Mixer Rev6-00' mxr1(vdvTP_VOL,vdvMixer,vdvMixer_FB,dvMixer)     
define_module 'Fake Video Conference Rev6-00' vtc1(dvTP_VTC[1],vdvVTC1,vdvVTC1_FB,dvVTC) 
define_module 'Fake Audio Conference Rev6-00' atc1(dvTP_ATC[1],vdvATC1,vdvATC1_FB,dvMixer) 
define_module 'Fake Audio Conference Rev6-00' atc2(dvTP_ATC[2],vdvATC2,vdvATC2_FB,dvMixer) 
define_module 'Auto Shutdown Rev6-00' sd1(dvTP_DEV[1],dcShutDown)
//define_module 'Fake Switcher Rev6-00' sw1(dvTP_SWITCH[1],vdvSWITCH1,vdvSWITCH1_FB,dvSwitcher)
//define_module 'Sony VPL-FH30 Rev6-00' proj1(dvTP_DISP[1],vdvDISP1,vdvDISP1_FB,dvProj)
//define_module 'Biamp Vol Control Rev6-00' mxr1(vdvTP_VOL,vdvMixer,vdvMixer_FB,dvMixer) 
//define_module 'Biamp Dialer Rev6-00' atc1(dvTP_ATC[1],vdvATC1,vdvATC1_FB,dvMixer,cAddr,nInstID) 
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
		if(get_last(vdvMixer_FB)<=max_length_array(vol))
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
}

level_event[vdvMixer_FB,1]
{
	if(get_last(vdvMixer_FB)<=max_length_array(vol))
	{
		vol[get_last(vdvMixer_FB)].lvl=level.value
	}
}

define_event //Startup and Shutdown

button_event[dvTP,btnStart]  //This version of the Start Button is for a regular system without presets
{
	push:
	{
		to[button.input]
		nActiveTP=get_last(dvTP)
		send_command button.input.device,"'@PPX'"
		send_command button.input.device,"'@PPN-',cSourcePopups[nActiveTP],';Main Page'"
		send_command button.input.device,"'@PPN-',cHeaderPopups[nActiveTP],';Main Page'"		
		send_command button.input.device,"'@PPN-',cStartupPopups[nActiveTP],';Main Page'"
		send_command button.input.device,"'PAGE-Main Page'"
		pulse[vdvMixer[1],MIX_UPDATE_ALL]
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
//					{	
//						do_push(dvTP_SRC[nActiveTP],btnSources[srcPC1])
//						do_push(dvTP_DEST[nActiveTP],btnDests[dstProj1])
//					}
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
//						send_command dvTP[nActiveTP],"'@PPF-[paneLeft]Tabs'"
//						send_command dvTP[nActiveTP],"'@PPF-[paneRight]Tabs'"
//						send_command dvTP[nActiveTP],"'@PPN-',cStartupPopups[nActiveTP],';Main Page'"
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
			case btnShutDown: send_command button.input.device,"'@PPN-[popup]Power;Main Page'"
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
		if(nActiveMenu[nActiveTP]=get_last(btnMenus) and nPrevSource[nActiveTP]) do_push(dvTP_SRC[nActiveTP],btnSources[nPrevSource[nActiveTP]])
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
			else if(srcMain[nActiveSource[nActiveTP]].popup) send_command button.input.device,"'@PPN-',srcMain[nActiveSource[nActiveTP]].popup,';Main Page'"	
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

button_event[dvTP_DEST,dstVTCDual]
{
	push:
	{
		to[button.input]
		
		dstMain[dstProj1].src=srcVTC
		dstMain[dstProj2].src=srcVTCDual
		
		for(x=dstProj1;x<=dstProj2;x++) pulse[vdvDisp[x],VD_SRC_HDMI1]
		
		update_destination_text()
	}
}

define_event //VTC Events

button_event[dvTP,btnVTCCamSelect]
{
	push:
	{
		dstMain[dstVTCCam].src=get_last(btnVTCCamSelect)
	}
}

button_event[dvTP,btnVTCContentSelect]
{
	push:
	{
		dstMain[dstVTCContent].src=get_last(btnVTCContentSelect)
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
