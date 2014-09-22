PROGRAM_NAME='Example Room GuideConfig'

define_constant

guidePages		=	9

define_variable //Guide

volatile		guide		guideMain[guidePages]

define_function guide_fb()
{
	//Guide Feedback
	for(y=1;y<=NumTPs;y++) for(x=1;x<=length_array(GUIDE_STEPS);x++) [dvTP_GUIDE[y],GUIDE_STEPS[x]]=nActiveGuidePage[y]=x
	for(y=1;y<=NumTPs;y++) for(x=1;x<=length_array(GUIDE_STEPS);x++) for(z=1;z<=5;z++) [dvTP_GUIDE[y],GUIDE_STEP_DOTS[x][z]]=(nActiveGuidePage[y]=x and guideMain[x].nCurrentSubPage=z)
}

define_start //Guide

guideMain[1].name				=	'Getting Started'
guideMain[1].popup[1]			=	'[help]Getting Started 1'
guideMain[1].popup[2]			=	'[help]Getting Started 2'
guideMain[1].popup[3]			=	'[help]Getting Started 3'

guideMain[2].name				=	'Viewing a Source'
guideMain[2].popup[1]			=	'[help]Viewing a Source 1'
guideMain[2].popup[2]			=	'[help]Viewing a Source 2'
guideMain[2].paneRight			=	'[paneRight]Destinations'
guideMain[2].paneCenter			=	'[source]Blu-Ray'
guideMain[2].nActiveSource		=	srcBluRay

guideMain[3].name				=	'Controlling a Source'
guideMain[3].popup[1]			=	'[help]Controlling a Source'
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
guideMain[5].paneRight			=	'[paneRight]Destinations'
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

#INCLUDE 'HoppGUIDE Rev6-00'