PROGRAM_NAME='HoppTECH Rev6-00'


define_constant //Tech Buttons

integer		btnTechMenus[]		=	{1,2,3,4,5,6,7,8,9,10}
integer		btnTechSubMenus[]	=	{11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30}
integer		btnTechLeftMenus[]	=	{31,32,33,34,35,36,37,38,39,40}

integer		btnTechSwitcherInputs[]	=	{101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132}
integer		btnTechSwitcherOutputs[]=	{133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164}
btnTechSwitcherAudio		=	165
btnTechSwitcherVideo		=	166
btnTechSwitcherTake			=	167

integer 	btnTechIRPort[]	=	{211,212,213,214,215,216,217,218,219,220}
integer		btnTechIRChannelDigits[]	=	{221,222,223,224,225,226,227,228,229,230}
btnTechIRBack		=	231
btnTechIRPulse		=	232
btnTechIRTo			=	233
btnTechIRText		=	234

integer 	btnTechBack		=	200
integer 	btnTechHome		=	201

define_constant //Tech Menus

mnuTechMaster		=	1
mnuTechSwitcher		=	2
mnuTechMixer		=	3
mnuTechDisplays		=	4
mnuTechIR			=	5
mnuTechDevices		=	6
mnuTechCam			=	7
mnuTechVTC			=	8
mnuTechATC			=	9
mnuTechLights		=	10


define_type

structure techmenu
{
	char 		popup[35]
	
	integer		activesubmenu
	integer		activeleftmenu

	char 		submenupopups[20][35]
	
	char		leftmenu[20][35]
	char 		leftmenupopups[20][8][35]
	
	char		paneright[35]
	
}


define_variable //Tech Menus

volatile		integer			nActiveTechMenu



volatile		techmenu		mnuTech[10]

define_variable //Tech Switcher

volatile		integer			nActiveTechSwitcherAudio=1
volatile		integer			nActiveTechSwitcherVideo=1
volatile		integer			nActiveTechSwitcherInput
volatile		integer			nActiveTechSwitcherOutputs[32]



define_function tech_fb()
{
	for(y=1;y<=NumTPs;y++) for(x=1;x<=length_array(btnTechMenus);x++) [dvTP_TECH[y],btnTechMenus[x]]=nActiveTechMenu=x
	if(nActiveTechMenu) for(y=1;y<=NumTPs;y++) for(x=1;x<=length_array(btnTechSubMenus);x++) [dvTP_TECH[y],btnTechSubMenus[x]]=mnuTech[nActiveTechMenu].activesubmenu=x
	if(nActiveTechMenu) for(y=1;y<=NumTPs;y++) for(x=1;x<=length_array(btnTechLeftMenus);x++) [dvTP_TECH[y],btnTechLeftMenus[x]]=mnuTech[nActiveTechMenu].activeleftmenu=x
	for(x=1;x<=length_array(btnTechSwitcherInputs);x++) [dvTP_TECH,btnTechSwitcherInputs[x]]=nActiveTechSwitcherInput=x
	for(x=1;x<=length_array(btnTechSwitcherOutputs);x++) [dvTP_TECH,btnTechSwitcherOutputs[x]]=nActiveTechSwitcherOutputs[x]
	[dvTP_TECH,btnTechSwitcherAudio]=nActiveTechSwitcherAudio
	[dvTP_TECH,btnTechSwitcherVideo]=nActiveTechSwitcherVideo	
	
}



define_start //Tech Menus

mnuTech[mnuTechMaster].submenupopups[1]			=	'[tech][master]Main'

mnuTech[mnuTechSwitcher].popup			=	'[tech]Switcher'
for(x=1;x<=3;x++)
{
	mnuTech[mnuTechSwitcher].leftmenu[x]				=	"'[tech][switcher]Menu'"
	mnuTech[mnuTechSwitcher].leftmenupopups[x][1]	=	"'[tech][switcher',itoa(x),']Controls'"
	mnuTech[mnuTechSwitcher].leftmenupopups[x][2]	=	"'[tech][switcher',itoa(x),']Debug'"
}

mnuTech[mnuTechMixer].leftmenu[1]					=	'[tech][mixer]Menu'
mnuTech[mnuTechMixer].leftmenupopups[1][1]			=	'[tech][mixer]1-10'
mnuTech[mnuTechMixer].leftmenupopups[1][2]			=	'[tech][mixer]11-20'
mnuTech[mnuTechMixer].leftmenupopups[1][3]			=	'[tech][mixer]21-30'
mnuTech[mnuTechMixer].leftmenupopups[1][4]			=	'[tech][mixer]Debug'

mnuTech[mnuTechDisplays].popup					=	'[tech]Displays'
for(x=1;x<=20;x++)
{
	mnuTech[mnuTechDisplays].leftmenu[x]			=	"'[tech][display]Menu'"
	mnuTech[mnuTechDisplays].leftmenupopups[x][1]	=	"'[tech][display',itoa(x),']Controls'"
	mnuTech[mnuTechDisplays].leftmenupopups[x][2]	=	"'[tech][display',itoa(x),']Debug'"
}

mnuTech[mnuTechIR].popup				=	'[tech]IR'
for(x=1;x<=10;x++)
{
	mnuTech[mnuTechIR].submenupopups[x]		=	"'[tech][ir]IR ',itoa(x)"
}

mnuTech[mnuTechATC].popup			=	'[tech]ATC'
for(x=1;x<=3;x++)
{
	mnuTech[mnuTechATC].leftmenu[x]				=	"'[tech][audioConf]Menu'"
	mnuTech[mnuTechATC].leftmenupopups[x][1]	=	"'[tech][audioConf',itoa(x),']Controls'"
	mnuTech[mnuTechATC].leftmenupopups[x][2]	=	"'[tech][audioConf',itoa(x),']Debug'"
}

mnuTech[mnuTechLights].popup			=	'[tech]Lights'
for(x=1;x<=3;x++)
{
	mnuTech[mnuTechLights].leftmenu[x]			=	"'[tech][lights]Menu'"
	mnuTech[mnuTechLights].leftmenupopups[x][1]	=	"'[tech][lights',itoa(x),']Controls'"
	mnuTech[mnuTechLights].leftmenupopups[x][2]	=	"'[tech][lights',itoa(x),']Debug'"
}

define_event 



button_event[dvTP_TECH,btnTechHome]
{
	push:
	{
		to[button.input]
		off[nActiveTechMenu]
		for(x=1;x<=20;x++) pulse[vdvDisp[x],DEBUG_OFF]
	}
	release:
	{
		send_command button.input.device,"'PAGE-Tech Page'"
		send_command button.input.device,"'@PPN-[tech]Main'"
		send_command button.input.device,"'@PPF-[tech][master]Main'"
		send_command button.input.device,"'@PPF-[paneLeft]Tabs'"
	}
}

button_event[dvTP_TECH,btnTechMenus]
{
	push:
	{
		nActiveTechMenu=get_last(btnTechMenus)
	
		mnuTech[nActiveTechMenu].activesubmenu=1
		mnuTech[nActiveTechMenu].activeleftmenu=1
		
		if(length_string(mnuTech[nActiveTechMenu].submenupopups[mnuTech[nActiveTechMenu].activesubmenu])>0)
		{
			send_command button.input.device,"'@PPF-[paneLeft]Tabs'"
			if(length_string(mnuTech[nActiveTechMenu].popup)>0) send_command button.input.device,"'@PPN-',mnuTech[nActiveTechMenu].popup"
			send_command button.input.device,"'@PPN-',mnuTech[nActiveTechMenu].submenupopups[mnuTech[nActiveTechMenu].activesubmenu]"
		}
		else if(length_string(mnuTech[nActiveTechMenu].leftmenu[mnuTech[nActiveTechMenu].activesubmenu])>0)
		{
			send_command button.input.device,"'@PPN-',mnuTech[nActiveTechMenu].popup"
			send_command button.input.device,"'@PPN-',mnuTech[nActiveTechMenu].leftmenu[mnuTech[nActiveTechMenu].activesubmenu]"
			send_command button.input.device,"'@PPN-',mnuTech[nActiveTechMenu].leftmenupopups[mnuTech[nActiveTechMenu].activesubmenu][1]"
		}
		
		
	}
}

button_event[dvTP_TECH,btnTechSubMenus]
{
	push:
	{
		mnuTech[nActiveTechMenu].activesubmenu=get_last(btnTechSubMenus)
		if(length_string(mnuTech[nActiveTechMenu].submenupopups[mnuTech[nActiveTechMenu].activesubmenu])>0)
		{
			send_command button.input.device,"'@PPN-',mnuTech[nActiveTechMenu].submenupopups[mnuTech[nActiveTechMenu].activesubmenu]"
		}
		else if(length_string(mnuTech[nActiveTechMenu].leftmenu[mnuTech[nActiveTechMenu].activesubmenu])>0)
		{
			send_command button.input.device,"'@PPN-',mnuTech[nActiveTechMenu].leftmenu[mnuTech[nActiveTechMenu].activesubmenu]"
			send_command button.input.device,"'@PPN-',mnuTech[nActiveTechMenu].leftmenupopups[get_last(btnTechSubMenus)][mnuTech[nActiveTechMenu].activeleftmenu]"
			//send_command button.input.device,"'@PPN-',mnuTech[nActiveTechMenu].leftmenupopups[1][mnuTech[nActiveTechMenu].activeleftmenu]"
		}		
		for(x=1;x<=20;x++) pulse[vdvDisp[x],DEBUG_OFF]
	}
}

button_event[dvTP_TECH,btnTechLeftMenus]
{
	push:
	{
		mnuTech[nActiveTechMenu].activeleftmenu=get_last(btnTechLeftMenus)
		send_command button.input.device,"'@PPN-',mnuTech[nActiveTechMenu].leftmenupopups[mnuTech[nActiveTechMenu].activesubmenu][get_last(btnTechLeftMenus)]"
	}
}

button_event[dvTP_TECH,btnTechBack]
{
	push:
	{
		to[button.input]
		off[nActiveTechMenu]
		for(x=1;x<=20;x++) pulse[vdvDisp[x],DEBUG_OFF]
	}
	release:
	{
		send_command button.input.device,"'@PPN-[tech]Main'"
		send_command button.input.device,"'@PPF-[tech][master]Main'"
		send_command button.input.device,"'@PPF-[paneLeft]Tabs'"
		
	}
}

button_event[dvTP_TECH,btnTechSwitcherInputs]
{
	push:
	{
		if(nActiveTechSwitcherAudio or nActiveTechSwitcherVideo)
		{
			nActiveTechSwitcherInput=get_last(btnTechSwitcherInputs)
			for(x=1;x<=32;x++) off[nActiveTechSwitcherOutputs[x]]
		}
	}
}

button_event[dvTP_TECH,btnTechSwitcherOutputs]
{
	push:
	{
		if(nActiveTechSwitcherInput and (nActiveTechSwitcherAudio or nActiveTechSwitcherVideo))
		{
			nActiveTechSwitcherOutputs[get_last(btnTechSwitcherOutputs)]=!nActiveTechSwitcherOutputs[get_last(btnTechSwitcherOutputs)]
		}
	}
}

button_event[dvTP_TECH,btnTechSwitcherAudio]
button_event[dvTP_TECH,btnTechSwitcherVideo]
{
	push:
	{
		switch(button.input.channel)
		{
			case btnTechSwitcherAudio: nActiveTechSwitcherAudio=!nActiveTechSwitcherAudio
			case btnTechSwitcherVideo: nActiveTechSwitcherVideo=!nActiveTechSwitcherVideo
		}
		if(!nActiveTechSwitcherAudio and !nActiveTechSwitcherVideo)
		{
			off[nActiveTechSwitcherInput]
			for(x=1;x<=32;x++) off[nActiveTechSwitcherOutputs[x]]
		}
	}
}

button_event[dvTP_TECH,btnTechSwitcherTake]
{
	push:
	{
		to[button.input]
		
		#IF_DEFINED switchaudio
		if(nActiveTechSwitcherAudio and nActiveTechSwitcherInput) 
		{
			for(x=1;x<=32;x++) if(nActiveTechSwitcherOutputs[x]) switchaudio(nActiveTechSwitcherInput,x)
		}
		#END_IF
		
		#IF_DEFINED switchvideo
		if(nActiveTechSwitcherVideo and nActiveTechSwitcherInput) 
		{
			for(x=1;x<=32;x++) if(nActiveTechSwitcherOutputs[x]) switchvideo(nActiveTechSwitcherInput,x)
		}
		#END_IF
		
		off[nActiveTechSwitcherInput]
		for(x=1;x<=32;x++) off[nActiveTechSwitcherOutputs[x]]
		
	}
}


define_program
