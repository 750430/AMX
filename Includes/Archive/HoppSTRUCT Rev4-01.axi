PROGRAM_NAME='HoppSTRUCT Rev4-01'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/25/2008  AT: 09:13:23        *)
(***********************************************************)

(***********************************************************)
(*              STRUCTURE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

//used for input sources to a system
STRUCTURE SOURCE
{
	DEV addr
	INTEGER tie				//tie to switcher
	INTEGER atie[10]	//ties to multiple devices
	INTEGER type			//type of signal (RGB,VID,etc)
	INTEGER flag1			//user flag for anything
	INTEGER flag2			//user flag for anything
	char cflag[25]			//user character flag for anything
	CHAR name[25]			//name of source
	CHAR popup[25]		//popup page associated with source
}

//used for any destination type in a system
STRUCTURE DESTINATION
{
	DEV addr
	INTEGER tie				//tie to switcher
	INTEGER atie[10]	//multiple ties/devices
	INTEGER pwr 			//Power status
	INTEGER type			//Input status
	INTEGER aspct			//Aspect status
	INTEGER mte 			//Mute status
	INTEGER src 			//index of source routed to destination
	INTEGER flag1			//user flag for anything
	INTEGER flag2			//user flag for anything
	CHAR name[25]			//name of source	
	CHAR lamp1[10]		//lamp1 hours status
	CHAR lamp2[10]		//lamp2 hours status
}

STRUCTURE WINDOW
{
	INTEGER type
  INTEGER	src
	INTEGER tie
	INTEGER ratio
	INTEGER sizepos[4]		//[1=left,2=top,3=width,4=height]
}

//used for volume/mute control through mixer
STRUCTURE VOLBLOCK 
{
	CHAR addr[4]		//device address/number
	INTEGER instID	//Biamp Only - Block#
	CHAR type[6]		//type of volume/mute being controlled
	CHAR chan[3]		//channel being controlled (not crosspoint)
	CHAR chanin[3] 	//intput being controlled for crosspoint gain
	CHAR chanout[3] //output being controlled for crosspoint gain
	SINTEGER	inc 		//increment to step
	SINTEGER min 		//min volume 
  SINTEGER max		//max volume
	INTEGER ramp 		//time for ramp to execute 0-255
	CHAR name[25]		//name of bar 
	SINTEGER lvl		//device level
	INTEGER mte 		//mute feedback
	INTEGER flag1		//user flag for anything
	INTEGER flag2		//user flag for anything
}

STRUCTURE CAMERA
{
	DEV dvCAM
	CHAR addr
	CHAR pan
	CHAR tilt
	CHAR zoom
}
(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile		integer		w
volatile		integer		x
volatile		integer		y
volatile		integer		nInteger
volatile		integer		nInteger2
volatile		sinteger	sSinteger
volatile		char		cString[100]

VOLBLOCK VOL[30]
WINDOW WIN
CAMERA CAM[10]

DEFINE_MUTUALLY_EXCLUSIVE

DEFINE_CALL 'WRITE_MIXER'			//This function is called in DEFINE_START to pass the VOL structure to the module
{
	LOCAL_VAR INTEGER X
	LOCAL_VAR	LONG lPos
	LOCAL_VAR	SLONG slReturn
	LOCAL_VAR	SLONG slFile
	LOCAL_VAR	SLONG slResult
	LOCAL_VAR	CHAR sBINString[10000]
	// Convert To Binary
	lPos = 1
	slReturn = VARIABLE_TO_STRING(VOL, sBINString, lPos)
	// Save Structure to Disk - Binary
	slFile = FILE_OPEN('BinaryMXREncode.xml', 2)
	slReturn = FILE_WRITE(slFile, sBINString, LENGTH_STRING(sBINString))
	slReturn = FILE_CLOSE(slFile)
}

DEFINE_CALL 'WRITE_CAMERA'		//This function is called in DEFINE_START to pass the CAM_PTZ structure to the module
{
	LOCAL_VAR INTEGER X
	LOCAL_VAR	LONG lPos
	LOCAL_VAR	SLONG slReturn
	LOCAL_VAR	SLONG slFile
	LOCAL_VAR	SLONG slResult
	LOCAL_VAR	CHAR sBINString[10000]
	// Convert To Binary
	lPos = 1
	slReturn = VARIABLE_TO_STRING(CAM, sBINString, lPos)
	// Save Structure to Disk - Binary
	slFile = FILE_OPEN('BinaryCAMEncode.xml', 2)
	slReturn = FILE_WRITE(slFile, sBINString, LENGTH_STRING(sBINString))
	slReturn = FILE_CLOSE(slFile)
}

DEFINE_CALL 'WRITE_JUPITER'			//This function is called in the main program to pass the WIN structure to the Jupiter module
{
	LOCAL_VAR	LONG lPos
	LOCAL_VAR	SLONG slReturn
	LOCAL_VAR	SLONG slFile
	LOCAL_VAR	SLONG slResult
	LOCAL_VAR	CHAR sXMLString[50000]
	// Convert To XML
	lPos = 1
	slReturn = VARIABLE_TO_XML(WIN, sXMLString, lPos, 0)
	// Save Structure To Disk – XML
	slFile = FILE_OPEN('XMLJupEncode.xml', 2)
	slReturn = FILE_WRITE(slFile, sXMLString, LENGTH_STRING(sXMLString))
	slReturn = FILE_CLOSE(slFile)	
}
