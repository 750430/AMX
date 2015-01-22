program_name='HoppSTRUCT Rev6-00'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/17/2012  AT: 21:45:46        *)
(***********************************************************)
(*yo*)
(***********************************************************)
(*              STRUCTURE DEFINITIONS GO BELOW             *)
(***********************************************************)
define_type

//used for input sources to a system
structure source
{
	dev 		addr				//
	integer 	tie					//tie to switcher
	integer 	atie				//tie to audio
	integer 	vtie				//tie to video
	integer 	multitie[10]		//ties to multiple devices
	integer 	type				//type of signal (RGB,VID,etc)
	integer 	flag1				//user flag for anything
	integer 	flag2				//user flag for anything
	integer 	rms					//RMS Channel
	integer 	room				//Room the source is in
	integer 	input				//Input to a destination
	integer		vol					//Volume bar that controls the sources audio
	integer		voltype				//Either PROG_VOL_TYPE or CONF_VOL_TYPE.  
	char 		cflag[25]			//user character flag for anything
	char 		name[35]			//name of source
	char 		popup[35]			//popup page associated with source
	char 		popup2[35]			//second popup page
	char 		paneleft[35]		//Left Popup Nav
	char 		paneright[35] 		//Right Popup Nav
	integer 	hassubmenu			//
	integer 	activesubmenu[8]	//
	char 		submenupopups[7][35]//
}

//used for any destination type in a system
structure destination
{
	dev			addr			//
	devchan		screenup		//
	devchan		screendown		//
	devchan		liftup			//
	devchan		liftdown		//
	integer 	tie				//tie to switcher
	integer 	atie			//tie to audio
	integer 	vtie			//tie to video
	integer 	multitie[10]	//multiple ties/devices
	integer 	srcinput[10]	//Input to pulse per source
	integer 	input			//For only a single input
	integer 	pwr 			//Power status
	integer 	type			//Input status
	integer 	aspct			//Aspect status
	integer 	mte 			//Mute status
	integer 	src 			//index of source routed to destination
	integer 	room			//Room the destination is in
	integer 	flag1			//user flag for anything
	integer 	flag2			//user flag for anything
	char 		cflag[25]		//user character flag for anything
	char 		name[25]		//name of source	
	char 		lamp1[10]		//lamp1 hours status
	char 		lamp2[10]		//lamp2 hours status
	char 		popup[25]		//
	char 		popup2[25]		//
}

structure menu
{
	integer 	hassubmenu
	char 		paneleft[45]
	char 		paneright[45]
	char 		popup[35]
	integer 	activesubmenu[8]
	char 		submenupopups[8][45]
}

//used for volume/mute control through mixer
structure volblock 
{
	integer		enabled
	char 		addr[4]			//device address/number
	integer 	instID			//Biamp Only - Block#
	char 		instIDTag[20]	//Instance ID Tag
	char 		type[7]			//type of volume/mute being controlled
	char 		chan[3]			//channel being controlled (not crosspoint)
	char 		chanin[3] 		//intput being controlled for crosspoint gain
	char 		chanout[3] 		//output being controlled for crosspoint gain
	sinteger	inc 			//increment to step
	sinteger 	min 			//min volume 
	sinteger 	max				//max volume
	integer 	ramp 			//time for ramp to execute 0-255
	long 		ramplong		//ramp speed in long format
	char 		name[35]		//name of bar 
	sinteger 	lvl				//device level
	integer 	mte 			//mute feedback
	integer 	flag1			//user flag for anything
	integer 	flag2			//user flag for anything
}

structure camera
{
	dev 		dvCAM
	char 		addr
	char 		pan
	char 		tilt
	char 		zoom
}

structure ipcomm
{
	dev 		dvIP
	char		name[25]
	char		IPAddress[15]
	integer 	port
	integer 	type 		
	integer 	status
	integer 	reconnect
	integer		connectcount
	integer 	dev_type		
}

structure speeddial
{
	char number[20]
	char name[35]
}

structure ir_struct
{
	integer 	carrier
	integer		mode
	integer		pulsetime
	integer		keypad
}

structure guide
{
	char name[50]
	char page[30]
	char guidepopup[9]
	char popup[5][35]
	char paneCenter[35]
	char paneLeft[35]
	char paneRight[35]
	char sourcepopup[35]
	char headerpopup[35]
	integer nActiveSource
	integer nActiveMenu
	integer nActiveSubMenu
	integer nCurrentSubPage
	integer nSubPages
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)

define_variable  //Generic Variables for use in loops or debugging.  At any point in your code you can declare something equal to nInteger, and track it in Debug.

volatile		integer		w
volatile		integer		x
volatile		integer		y
volatile		integer		z
volatile		integer		nInteger
volatile		integer		nInteger2
volatile		sinteger	sSinteger
volatile		char		cString[100]


(***********************************************************)
(*               FUNCTION DEFINITIONS GO BELOW             *)
(***********************************************************)

define_function write_mixer(volblock vB[], char cFileName[])			//This function is called in DEFINE_START to pass the VOL structure to the module
{
	local_var	long lPos
	local_var	slong slReturn
	local_var	slong slFile
	local_var	slong slResult
	local_var	char sBINString[10000]
	// Convert To Binary
	lPos = 1
	slReturn = variable_to_string(vB, sBINString, lPos)
	// Save Structure to Disk - Binary
	slFile = file_open(cFileName, 2)
	slReturn = file_write(slFile, sBINString, length_string(sBINString))
	slReturn = file_close(slFile)
}

define_function write_camera(camera cI[], char cFileName[])		//This function is called in DEFINE_START to pass the CAM_PTZ structure to the module
{
	local_var	long lPos
	local_var	slong slReturn
	local_var	slong slFile
	local_var	slong slResult
	local_var	char sBINString[10000]
	// Convert To Binary
	lPos = 1
	slReturn = variable_to_string(cI, sBINString, lPos)
	// Save Structure to Disk - Binary
	slFile = file_open(cFileName, 2)
	slReturn = file_write(slFile, sBINString, length_string(sBINString))
	slReturn = file_close(slFile)
}

define_function write_ir(ir_struct iI[], char cFileName[])		//This function is called in DEFINE_START to pass the IR structure to the module
{
	local_var	long lPos
	local_var	slong slReturn
	local_var	slong slFile
	local_var	slong slResult
	local_var	char sBINString[10000]
	// Convert To Binary
	lPos = 1
	slReturn = variable_to_string(iI, sBINString, lPos)
	// Save Structure to Disk - Binary
	slFile = file_open(cFileName, 2)
	slReturn = file_write(slFile, sBINString, length_string(sBINString))
	slReturn = file_close(slFile)
}


