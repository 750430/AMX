MODULE_NAME='MXA_MPx' (DEV vdvMXA, DEV dvPNL, DEV dvSWT[16])
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(*                                                         *)
(*  Rev  1.08     08/26/2014  FA                           *)
(*  - Added DGX 8 and DGX 64 options as valid device types *)
(*    in "swtTypeAssign" function.												 *)
(*                                                         *)
(*  Rev  1.07     06/5/2014   SWN                          *)
(*  - Added new optional synchronous mode property that    *)
(*    will pause the scanning timeline in snapshot mode    *)
(*    until confirmation (via custom event ID 1400) from   *)
(*    the panel that the snapshot has successfully loaded. *)
(*    This prevents switching of input source prior to     *)
(*    completion of the snapshot.                          *)
(*                                                         *)
(*  Rev  1.06     02/24/2014   GCS                         *)
(*  - Changed the buttons on the subpage previews to use   *)
(*    bounding box instead of active touch in the TP5 file *)
(*  - Removed dummy dynamo image from TP5 example pages.   *)
(*  - Removed button triggered ^SSH on TP5 example pages.  *)
(*    This is done in this module instead.                 *)
(*  - Significant code cleanup                             *)
(*  - Added ^SHA command to hide any open subpages on the  *)
(*    panel whenever the MPL restarts                      *)
(*                                                         *)
(*  Rev  1.05     01/29/2014   GCS                         *)
(*  - Cleaned up some race conditions with G5 panels	   *)
(*  - Added back in ^SDM commands that should not have     *)
(*    been removed.                                        *)
(*                                                         *)
(*  Rev  1.04     01/20/2014   FA                          *)
(*  - Replaced old 'TEXT' command with ^TXT commands	   *)
(*  - Removed all ^SDM commands.                    	   *)
(*                                                         *)
(*  Rev  1.03     01/18/2013   FA                          *)
(*  - Added Dynamo preview images for all possible inputs  *)
(*    to enable size-to-fit feature (TPD file).            *)
(*  - Removed MPL fill from each preview window in TPD     *)
(*    Video now is sent from code using ^SDM and ^BOS cmds *)
(*  - Fixed random instances where same image shows up in  *)
(*    multiple preview windows.				   *)
(*  - Added ability to show a separate Video Window instead*)
(*    of showing video in same preview buttons.            *)
(*  - Added "simple" code to show how preview operation is *)
(*    is performed.                                        *)
(*                                                         *)
(*  Rev  1.02     10/23/2012   ECN                         *)
(*  - Added conditional to ensure that scanning            *)
(*    is not restarted if when the stream                  *)
(*    is being activated                                   *)
(*                                                         *)
(*  Rev  1.01     09/10/2012   CWR                         *)
(*  - Added streaming support for MXA-MPL.                 *)
(*    - Preview window button states:                      *)
(*      - OFF Used for snapshots                           *)
(*      -  ON Used for streaming                           *)
(*  - Expanded default support for 32 sources.             *)
(*  - Added preserve for dynamo images (%V0/%V1).          *)
(*                                                         *)
(*  Rev  1.00     08/01/2012   CWR                         *)
(*  - Initial creation.                                    *)
(***********************************************************)
(* NOTES:                                                  *)
(*                                                         *)
(* -Minimum firmware versions:                             *)
(*    MXA-MP      1.1.85                                   *)
(*    MXA-MPL     2.1.28                                   *)
(*    ModeroX     2.103.52                                 *)
(*    ModeroX G5  1.1.10                                   *)
(*    DVX         1.2.32                                   *)
(*    DGX         1.2.1.1                                  *)
(*                                                         *)
(* -Dynamo preview images created:                         *)
(*    MXA_PVW_1  (http://mxamp/snapit/slot1.jpg)           *)
(*    MXA_PVW_2  (http://mxamp/snapit/slot2.jpg)           *)
(*    MXA_PVW_3  (http://mxamp/snapit/slot3.jpg)           *)
(***********************************************************)

(***********************************************************)
(*                INCLUDE DEFINITIONS GO BELOW             *)
(***********************************************************)
INCLUDE 'SNAPI.axi'

#WARN 'READ ME!'
(***********************************************************)
/*
 * THIS CODE USES EACH PREVIEW WINDOW TO SHOW STREAMING
 * VIDEO. IF YOU WANT TO USE A SEPARATE VIDEO WINDOW TO
 * DISPLAY THE STERAM, UNCOMMENT #DEFINE USE_VIDEO_WINDOW
*/
(***********************************************************)
//#DEFINE USE_VIDEO_WINDOW
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

vdvAPI = DYNAMIC_VIRTUAL_DEVICE


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

//-- Version ----------------------------------------------
MDL_VERS[] = '1.08'
MDL_NAME[] = 'MXA_MPx'


//-- Settings -----------------------------------------------
PVW_WIN_CNT             = 16     // How many pantastic windows are viewable on screen
SRC_CNT                 = 32    	// How many sources are connected to the switcher (NOT to exceed 32)

SCAN_DELAY_MIN_SWT      = 10    // Minimum delay time (in .1S) allowed for switching
SCAN_DELAY_MIN_SYN      = 5     // Minimum delay time (in .1S) allowed for syncing


//-- Debug Levels -------------------------------------------
DEBUG_OFF               = 0
DEBUG_ERROR             = 1
DEBUG_WARN              = 2
DEBUG_INFO              = 3


//-- Switcher Types -----------------------------------------
SWT_TYPE_SNAPI          = 0
SWT_TYPE_DVX            = 1
SWT_TYPE_DGX            = 2


//-- Timelines ----------------------------------------------
TL_SCAN                 = 1     // Scan through the sequences (1=MP unblank,2=MP snapshot, 3=MP blank/switch)
TL_POLL_SWT_VIDIN       = 2     // Poll switcher for video input status


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE

//-- Module Properties --------------------------------------
STRUCTURE _uPropSrc
{
  INTEGER nSwtInp               // Switcher input for this source
  CHAR    cText[50]             // Friendly name for this source
  CHAR    cSubPage[50]          // SubPage name for this source
  CHAR    cImg[50]              // Default image for this source
}

STRUCTURE _uProp
{
  INTEGER nDebugLvl             // Debug level (Off,Error,Warn,Info)
  INTEGER nPvwOut               // Switcher output for this MXA-MPx
  INTEGER nDelaySwt             // Delay following switching
  INTEGER nDelaySyn             // Delay following signal sync
  CHAR    bCanStream            // True if MPL
  INTEGER nPvwWinCount		// How many Preview Windows to show
  INTEGER nSynchronousMode      // 0=Asynchronous; 1=Synchronous
  _uPropSrc uSrc[SRC_CNT]       // Source properties
}


//-- Switcher -----------------------------------------------
STRUCTURE _uSwt
{
  INTEGER nType                 // Type of switcher (DVX, DGX, or SNAPI)
  INTEGER nInpCnt               // Number of inputs to poll vidin status
  INTEGER nPollInp              // Last vidin status polling
  INTEGER nInput;		// Current Input
  INTEGER nOutput;		// Current Output
}


//-- Source State -------------------------------------------
STRUCTURE _uSrcState
{
  CHAR     cImg[50]             // Current image
  CHAR     bOnscreen            // True when this source is onscreen
  CHAR     bVidInStatus         // True when video input signal is present
}


//-- Pantastic Scanning Preview Windows ---------------------
STRUCTURE _uPvwWin
{
  INTEGER  nSource              // Source index for this preview window
  INTEGER  nSwtInp              // Switcher input for this preview window
  CHAR     bImgInit             // Image needs first refresh (with completion code)
}

STRUCTURE _uScan
{
  INTEGER  nCurrent             // Now scanning this preview window index
  INTEGER  nSeq                 // Scanning sequence (1=MP unblank,2=MP snapshot,3=MP blank/switch)
  _uPvwWin uPvwWin[16] 		// Preview window properties - Max is 16 widnows
}

STRUCTURE _uStream
{
  CHAR     bOn                  // True when streaming
  INTEGER  nSource              // Source index that is streaming
  INTEGER  nJustStopped
  CHAR     bStartingStream
  CHAR     bStoppingStream
}

STRUCTURE _uPnl
{
  INTEGER   nAnchorSource       // Source index for anchored preview window (1-SRC_CNT)
  INTEGER   nAnchorIdx          // Preview window index for anchored preview window (1-PVW_WIN_CNT)
  _uScan    uScan               // Scanning state
  _uStream  uStream             // Streaming state
}


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile		integer		nJeffScanStart
volatile		integer		tl_scan_active
volatile		integer		tl_poll_swt_vidin_active

VOLATILE INTEGER nAnchorPrev

//-- Properties ---------------------------------------------
VOLATILE _uProp uProp


//-- Source Preview Properties ------------------------------
VOLATILE _uSrcState uSrcState[SRC_CNT]


//-- Pantastic Scanning Preview Windows ---------------------
VOLATILE _uPnl uPnl


//-- Switcher -----------------------------------------------
VOLATILE _uSwt uSwt


//-- GUI ----------------------------------------------------
CONSTANT INTEGER nVT_VIEWER        = 100    // This is the sub-page viewer for previewing.
CONSTANT CHAR    cVT_VIEWER_PAGE[] = 'Main' // The sub-page viewer is on this page.


//-- Note: btn/vt arrays not to exceed SRC_CNT!!
CONSTANT INTEGER nBTN_SRC_SELECT[]    = { 201, 202, 203, 204,     // Source selections along the bottom.
                                          205, 206, 207, 208,
                                          209, 210, 211, 212,
                                          213, 214, 215, 216,
                                          217, 218, 219, 220,
                                          221, 222, 223, 224,
                                          225, 226, 227, 228,
                                          229, 230, 231, 232 }

CONSTANT INTEGER nBTN_PVW_CLOSE[]     = { 251, 252, 253, 254,     // Preview window subpage close.
                                          255, 256, 257, 258,
                                          259, 260, 261, 262,
                                          263, 264, 265, 266,
                                          267, 268, 269, 270,
                                          271, 272, 273, 274,
                                          275, 276, 277, 278,
                                          279, 280, 281, 282 }

CONSTANT INTEGER nVT_PVW_NAME[]       = { 251, 252, 253, 254,     // Preview window subpage titles.
                                          255, 256, 257, 258,
                                          259, 260, 261, 262,
                                          263, 264, 265, 266,
                                          267, 268, 269, 270,
                                          271, 272, 273, 274,
                                          275, 276, 277, 278,
                                          279, 280, 281, 282 }

CONSTANT INTEGER nBTN_SRC_STREAM[]    = { 301, 302, 303, 304,     // Source selection streaming on subpage.
                                          305, 306, 307, 308,
                                          309, 310, 311, 312,
                                          313, 314, 315, 316,
                                          317, 318, 319, 320,
                                          321, 322, 323, 324,
                                          325, 326, 327, 328,
                                          329, 330, 331, 332 }

CONSTANT INTEGER nVT_PVW_WIN[]        = { 301, 302, 303, 304,     // Preview window subpage images.
                                          305, 306, 307, 308,
                                          309, 310, 311, 312,
                                          313, 314, 315, 316,
                                          317, 318, 319, 320,
                                          321, 322, 323, 324,
                                          325, 326, 327, 328,
                                          329, 330, 331, 332 }

#IF_DEFINED USE_VIDEO_WINDOW

CONSTANT INTEGER nBTN_VID_WINDOW 			 = 401;

CONSTANT INTEGER nBTN_VID_WINDOW_CLOSE = 400;

#END_IF

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

//--------------------------------------------------------------------------------------------------------------------
// MP/MPL scan helpers:
//--------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------
// Viewer has landed, reload the scanning routine.
//-----------------------------------------------------
DEFINE_FUNCTION mxaScanRestart (INTEGER nIdx)
STACK_VAR
  INTEGER nLoop
{
//-- Debug Info --
  debugMsg (DEBUG_INFO, "'MXA_MPx|mxaScanRestart()|Restart scanning.'")


//-- Is our MXA connected to the switcher? --
  IF(!uProp.nPvwOut) {
    debugMsg (DEBUG_ERROR, "'MXA_MPx|mxaScanRestart()|nPvwOut=0|No video output assigned for preview!'")
    RETURN;
  }

//-- Re-assign current so that mxaScanGetNext() hits on this nIdx --
  IF(nIdx <= 1)  {
		uPnl.uScan.nCurrent = PVW_WIN_CNT
	}
  ELSE           uPnl.uScan.nCurrent = nIdx - 1

  IF(!mxaScanGetNext()) {
    debugMsg (DEBUG_ERROR, "'MXA_MPx|mxaScanRestart()|mxaScanGetNext()=false|Cannot continue scanning, have to stop!'")
    mxaScanStop ()
    RETURN;
  }

//-- Stop streaming --
  IF(uPnl.uStream.bOn)
    mxaStreamStop ()

//-- Stop scanning --
  mxaScanStop  ()

//-- Start scanning --
  mxaScanStart ()
}

//-----------------------------------------------------
// Start scanning.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR mxaScanStart ()
STACK_VAR
  LONG    lTlTimes[3]
  LONG    lTimer
{
  IF(!TIMELINE_ACTIVE(TL_SCAN)) {
  //-- Debug Info --
    debugMsg (DEBUG_INFO, "'MXA_MPx|mxaScanStart()|Start scanning.'")

    SEND_COMMAND vdvAPI,"'SCAN-START'"

  //-- Start it --
    //lTlTimes[1] = 500                                                    // MP UnBlank
    lTlTimes[1] = MAX_VALUE(SCAN_DELAY_MIN_SYN*100, uProp.nDelaySyn*100) // MP snapshot
    lTlTimes[2] = MAX_VALUE(SCAN_DELAY_MIN_SWT*100, uProp.nDelaySwt*100) // MP Blank / switch the input
    TIMELINE_CREATE(TL_SCAN, lTlTimes, 2, TIMELINE_RELATIVE, TIMELINE_REPEAT)

  //-- Advance to sequence #3 --
    //lTimer = lTlTimes[1] + lTlTimes[2] + lTlTimes[3] - 100
    //TIMELINE_SET(TL_SCAN, lTimer)
	//-- Advance to sequence #1 --
		TIMELINE_SET(TL_SCAN, lTlTimes[1]);

    RETURN(TRUE)
  }

  RETURN(FALSE)
}

//-----------------------------------------------------
// Stop scanning.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR mxaScanStop ()
{
  IF(TIMELINE_ACTIVE(TL_SCAN)) {
  //-- Debug Info --
    debugMsg (DEBUG_INFO, "'MXA_MPx|mxaScanStop()|Stop scanning.'")

    SEND_COMMAND vdvAPI,"'SCAN-STOP'"

    TIMELINE_KILL(TL_SCAN)
    RETURN(TRUE)
  }

  RETURN(FALSE)
}

//-----------------------------------------------------
// Get next valid scan (has vidInp) and assign as nCurrent.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR mxaScanGetNext ()
STACK_VAR
  INTEGER nLoop
  INTEGER nSource
{
//-- Look up to the end --
  FOR(nLoop=uPnl.uScan.nCurrent+1; nLoop<=PVW_WIN_CNT; nLoop++) {
    nSource = uPnl.uScan.uPvwWin[nLoop].nSource
    IF(nSource) {
      IF(uPnl.uScan.uPvwWin[nLoop].nSwtInp && uSrcState[nSource].bVidInStatus) {
        uPnl.uScan.nCurrent = nLoop
        RETURN(TRUE)
      }
    }
  }


//-- Look up to the current (current should hit again) --
  FOR(nLoop=1; nLoop<=uPnl.uScan.nCurrent; nLoop++) {
    nSource = uPnl.uScan.uPvwWin[nLoop].nSource
    IF(nSource) {
      IF(uPnl.uScan.uPvwWin[nLoop].nSwtInp && uSrcState[nSource].bVidInStatus) {
        uPnl.uScan.nCurrent = nLoop
        RETURN(TRUE)
      }
    }
  }

//-- Nothing found --
  RETURN(FALSE)
}

//-----------------------------------------------------
// Switch step: route inp to out.
//-----------------------------------------------------
DEFINE_FUNCTION mxaScanStepSwitch ()
STACK_VAR
  INTEGER nCurrent
  INTEGER nSwtInp
{
//-- Is this panel's MXA connected to the switcher? --
  IF(!uProp.nPvwOut) {
    debugMsg (DEBUG_ERROR, "'MXA_MPx|mxaScanStepSwitch()|nVidOut=0|No video output assigned for preview!'")
    RETURN;
  }

//-- We've got to be pointing into the uPvwWin list! --
  IF(!uPnl.uScan.nCurrent) {
    debugMsg (DEBUG_ERROR, "'MXA_MPx|mxaScanStepSwitch()|nCurrent=0|Current scan should be indexing a preview window!'")
    RETURN;
  }

//-- Convenience --
  nCurrent = uPnl.uScan.nCurrent
  nSwtInp  = uPnl.uScan.uPvwWin[nCurrent].nSwtInp
  IF(!nSwtInp) {
    debugMsg (DEBUG_ERROR, "'MXA_MPx|mxaScanStepSwitch()|nCurrent=',ITOA(nCurrent),', nSwtInp=0|No video input assigned for preview!'")
    RETURN;
  }

//-- Make the switch --	
	IF (uPnl.uStream.bOn == TRUE) {
				
		//IF (nSwtInp <> uProp.uSrc[uPnl.uStream.nSource].nSwtInp) {
			swtVidIn (uPnl.uStream.nSource)
		//ELSE
		//	swtVidIn (nSwtInp)
			IF (uPnl.uStream.nJustStopped == TRUE)
				uPnl.uStream.nJustStopped = FALSE;
		//}
	}
	ELSE {
		swtVidIn (nSwtInp)
	}
}

//-----------------------------------------------------
// Snapshot step: take a snapshot.
//-----------------------------------------------------
DEFINE_FUNCTION mxaScanStepSnap ()
STACK_VAR
  INTEGER nCurrent
  INTEGER nSource
  CHAR    cImg[50]
{
//-- Is this panel's MXA connected to the switcher? --
  IF(!uProp.nPvwOut) {
    debugMsg (DEBUG_ERROR, "'MXA_MPx|mxaScanStepSnap()|nVidOut=0|No video output assigned for preview!'")
    RETURN;
  }

//-- We've got to be pointing into the uPvwWin list! --
  IF(!uPnl.uScan.nCurrent) {
    debugMsg (DEBUG_ERROR, "'MXA_MPx|mxaScanStepSnap()|nCurrent=0|Current scan should be indexing a preview window!'")
    RETURN;
  }

//-- Convenience --
  nCurrent = uPnl.uScan.nCurrent
  nSource  = uPnl.uScan.uPvwWin[nCurrent].nSource
  //cImg     = "'MXA_PVW_',ITOA(nCurrent)"
	cImg     = "'MXA_PVW_',ITOA(nSource)"

  IF(!nSource) {
    debugMsg (DEBUG_ERROR, "'MXA_MPx|mxaScanStepSnap()|nCurrent=',ITOA(nCurrent),', nSource=0|Source not assigned to preview window!'")
    RETURN;
  }

//-- Refresh the snapshot --
	/*
  IF(uPnl.uScan.uPvwWin[nCurrent].bImgInit) {
    SEND_COMMAND dvPNL,"'^RFRP-',cImg,',once'"
		uPnl.uScan.uPvwWin[nCurrent].bImgInit = FALSE;
  }
  ELSE 
	*/
	IF (uPnl.uStream.bOn == FALSE) {
	
		IF (uPnl.uStream.nJustStopped == FALSE) {
		
			IF (uProp.uSrc[nSource].nSwtInp == uSwt.nInput) {
				SEND_COMMAND dvPNL,"'^RMF-MXA_PVW_',ITOA(nSource),',%V0'"
				IF (uProp.nSynchronousMode > 0)
				{
				    //Pause the timeline, then refresh the snapshot.  Timeline will
				    //resume upon snapshot completion (when we receive custom event 1400)
				    TIMELINE_PAUSE(TL_SCAN)
				    SEND_COMMAND dvPNL,"'^RFRP-MXA_PVW_',ITOA(nSource),',once'"
				}
				ELSE
				{
				    //Asynchronous mode; refresh the snapshot with the assumption that
				    //it will be complete prior to the next timeline event
				    SEND_COMMAND dvPNL,"'^BBR-',ITOA(nVT_PVW_WIN[nSource]),',1,',cImg"
				    SEND_COMMAND dvPNL,"'^RMF-MXA_PVW_',ITOA(nSource),',%V1'"
				}
			}
		}
		ELSE
		{
			uPnl.uScan.nCurrent = uPnl.nAnchorSource;		
			uPnl.uScan.nSeq = uPnl.nAnchorIdx;
			uPnl.uScan.uPvwWin[uPnl.uScan.nCurrent].nSource = uPnl.nAnchorSource;
			
			nCurrent = uPnl.uScan.nCurrent;
			nSource  = uPnl.uScan.uPvwWin[nCurrent].nSource;
			//cImg     = "'MXA_PVW_',ITOA(nCurrent)"
			cImg     = "'MXA_PVW_',ITOA(nSource)"
			
			IF (uProp.uSrc[nSource].nSwtInp == uSwt.nInput) {
				SEND_COMMAND dvPNL,"'^RMF-MXA_PVW_',ITOA(nSource),',%V0'"
				IF (uProp.nSynchronousMode > 0)
				{
				    //Pause the timeline, then refresh the snapshot.  Timeline will
				    //resume upon snapshot completion (when we receive custom event 1400)
				    TIMELINE_PAUSE(TL_SCAN)
				    SEND_COMMAND dvPNL,"'^RFRP-MXA_PVW_',ITOA(nSource),',once'"
				}
				ELSE
				{
				    //Asynchronous mode; refresh the snapshot with the assumption that
				    //it will be complete prior to the next timeline event
				    SEND_COMMAND dvPNL,"'^BBR-',ITOA(nVT_PVW_WIN[nSource]),',1,',cImg"
				    SEND_COMMAND dvPNL,"'^RMF-MXA_PVW_',ITOA(nSource),',%V1'"
				}
			}
		}
		IF (uPnl.uStream.nJustStopped == TRUE)
			uPnl.uStream.nJustStopped = FALSE;
  }
}

//-----------------------------------------------------
// Reset scanning.
//-----------------------------------------------------
DEFINE_FUNCTION mxaScanReset ()
STACK_VAR
  INTEGER nLoop
{
  uPnl.nAnchorSource  = 0
  uPnl.nAnchorIdx     = 0

  uPnl.uScan.nCurrent = 0
  uPnl.uScan.nSeq     = 0
	
  FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
    uPnl.uScan.uPvwWin[nLoop].nSource = 0
    uPnl.uScan.uPvwWin[nLoop].nSwtInp = 0
    uPnl.uScan.uPvwWin[nLoop].bImgInit= FALSE
  }
}


//-----------------------------------------------------
// Reset source's image.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR[50] mxaImgReset (INTEGER nSource)
{
//-- Reset value (offscreen) --
  uSrcState[nSource].cImg = 'icon-video-loading.png'

//-- No video input status --
  IF(uSrcState[nSource].bVidInStatus = FALSE)
    uSrcState[nSource].cImg = 'icon-novideo.png'

//-- No video input, then default it --
  IF(LENGTH_STRING(uProp.uSrc[nSource].cImg) && (uProp.uSrc[nSource].nSwtInp = 0))
    uSrcState[nSource].cImg = uProp.uSrc[nSource].cImg

  RETURN(uSrcState[nSource].cImg)
}


//-----------------------------------------------------
// Assign a source's image.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR[50] mxaImgAssign (INTEGER nSource, CHAR cImg[])
{
  uSrcState[nSource].cImg = cImg
  RETURN(uSrcState[nSource].cImg)
}


//-----------------------------------------------------
// Return index for this subpage.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR mxaGetSubpageIndex (CHAR cSubPage[])
{
  IF(LENGTH_STRING(cSubPage)) {
    STACK_VAR CHAR cLoop

    FOR(cLoop=1; cLoop<=SRC_CNT; cLoop++) {
      IF(uProp.uSrc[cLoop].cSubPage = cSubPage)
        RETURN(cLoop)
    }
  }

  RETURN(FALSE)
}



//--------------------------------------------------------------------------------------------------------------------
// MPL stream helpers:
//--------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------
// Start streaming.
//-----------------------------------------------------
DEFINE_FUNCTION mxaStreamStart (INTEGER nSource)
LOCAL_VAR
  INTEGER nLoop
  INTEGER nSwtDly
{
//-- Ensure that scanning is stopped --
    mxaScanStop ()

//-- Debug Info --
    debugMsg (DEBUG_INFO, "'MXA_MPx|mxaStreamStart',ITOA(nSource),')|Start streaming this source.'")

//-- Show a "loading" image (for stream) --
    SEND_COMMAND dvPNL,"'^BMP-',ITOA(nVT_PVW_WIN[nSource]),',2,icon-video-loading-filled.png'"

//-- Cache these --
    uPnl.uStream.nSource = nSource
    uPnl.uStream.nJustStopped = FALSE;
    uPnl.uStream.bStartingStream = TRUE;
    uPnl.uStream.bStoppingStream = FALSE;

//-- Have to turn button on for streaming to start
#IF_NOT_DEFINED USE_VIDEO_WINDOW
    FOR(nLoop=1; nLoop<=SRC_CNT; nLoop++)
	[dvPNL,nBTN_SRC_STREAM[nLoop]] = (uPnl.uStream.nSource = nLoop)
#ELSE
    // TURN VIDEO ON
    [dvPNL,nBTN_VID_WINDOW] = (1);
    // Ensure the video window is visible
    SEND_COMMAND dvPNL,"'@PPN-VIDEO_WINDOW'";
#END_IF
	
//-- Start streaming process --
    swtVidin (uProp.uSrc[nSource].nSwtInp)

    nSwtDly = MAX_VALUE(SCAN_DELAY_MIN_SWT, uProp.nDelaySwt)
    WAIT nSwtDly 'STREAM-START'
    {
	SEND_COMMAND dvPNL,"'^SDM-',ITOA(nVT_PVW_WIN[nSource]),',2,udp://169.254.11.12:5700'"
	// Once started, panel will send custom event 768
    }
}

//-----------------------------------------------------
// Stop streaming.
//-----------------------------------------------------
DEFINE_FUNCTION mxaStreamStop  ()
STACK_VAR
  INTEGER nLoop
{
//-- Debug Info --
    debugMsg (DEBUG_INFO, "'MXA_MPx|mxaStreamStop()|Stop streaming.'")

//-- Stop streaming --
    CANCEL_WAIT 'STREAM-START'
    uPnl.uStream.bStoppingStream = TRUE
    uPnl.uStream.bStartingStream = FALSE

//-- Show "loading" image (for scan) --
    IF(uSrcState[uPnl.uStream.nSource].bVidInStatus)
	SEND_COMMAND dvPNL,"'^BMP-',ITOA(nVT_PVW_WIN[uPnl.uStream.nSource]),',1,',mxaImgAssign(uPnl.uStream.nSource,'icon-video-loading.png')"
    ELSE
	SEND_COMMAND dvPNL,"'^BMP-',ITOA(nVT_PVW_WIN[uPnl.uStream.nSource]),',1,',mxaImgAssign(uPnl.uStream.nSource,'icon-novideo-filled.png')"

#IF_NOT_DEFINED USE_VIDEO_WINDOW
    FOR(nLoop=1; nLoop<=SRC_CNT; nLoop++)
    {
	[dvPNL,nBTN_SRC_STREAM[nLoop]] = (0);
	SEND_COMMAND DATA.DEVICE,"'^SDM-',ITOA(nVT_PVW_WIN[nLoop]),',2,'"
    }
#ELSE
    // TURN VIDEO OFF
    [dvPNL,nBTN_VID_WINDOW] = (0);
#END_IF
	
//-- Cache these --
    uPnl.uStream.bOn = FALSE
    uPnl.uStream.nJustStopped = TRUE;

//-- Should we keep scanning? --
    IF(uPnl.uScan.nCurrent)
	mxaScanStart ()
}


//--------------------------------------------------------------------------------------------------------------------
// Debug helpers:
//--------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------
// Set debug level.
//-----------------------------------------------------
DEFINE_FUNCTION debugSetLvl (CHAR cType[])
{
  SWITCH(cType)
  {
    CASE 'INFO'  : { uProp.nDebugLvl = DEBUG_INFO   debugMsg (uProp.nDebugLvl, "'DEBUG|debugSetLvl()|Level is: INFO' ")  }
    CASE 'WARN'  : { uProp.nDebugLvl = DEBUG_WARN   debugMsg (uProp.nDebugLvl, "'DEBUG|debugSetLvl()|Level is: WARN' ")  }
    CASE 'ERROR' : { uProp.nDebugLvl = DEBUG_ERROR  debugMsg (uProp.nDebugLvl, "'DEBUG|debugSetLvl()|Level is: ERROR'")  }
    DEFAULT      : { uProp.nDebugLvl = DEBUG_OFF    debugMsg (uProp.nDebugLvl, "'DEBUG|debugSetLvl()|Level is: OFF'  ")  }
  }
}

//-----------------------------------------------------
// Debug echo.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR debugMsg (INTEGER nLvl, CHAR cData[])
{
  IF(nLvl && (nLvl <= uProp.nDebugLvl)) {
    debugEcho ('ASCII', cData)
    RETURN(TRUE)
  }

  RETURN(FALSE)
}

//-----------------------------------------------------
// Debug echo to terminal.
//-----------------------------------------------------
DEFINE_FUNCTION debugEcho (CHAR cType[], CHAR cData[])
{
  IF(uProp.nDebugLvl < DEBUG_INFO)
    RETURN;

  SWITCH(UPPER_STRING(cType) )
  {
    CASE 'HEX' : {
      STACK_VAR INTEGER nLoop
      STACK_VAR INTEGER nCount
      STACK_VAR CHAR    strTXT1[100]
      STACK_VAR CHAR    strTXT2[100]
      STACK_VAR CHAR    strTXT3[100]

      strTXT1 = ""
      strTXT2 = ""
      strTXT3 = ""
      nLoop   = 1
      nCount  = 1
      WHILE (nLoop <= LENGTH_STRING(cData))
      {
        strTXT1 = "strTXT1,RIGHT_STRING("'   ',ITOA(cData[nLoop])",3),'/'"          (* DECIMAL *)
        strTXT2 = "strTXT2,'$',RIGHT_STRING("'00',ITOHEX(cData[nLoop])",2),'/'"     (* HEX *)
        IF ((cData[nLoop] >= 33) && (cData[nLoop] <= 126))
          strTXT3 = "strTXT3,'  ',cData[nLoop],' '"
        ELSE
          strTXT3 = "strTXT3,'    '"

        nLoop = nLoop + 1

        IF(nCount = 10)
        {
          nCount = 1
          SEND_STRING 0,"strTXT1"
          SEND_STRING 0,"strTXT2"
          SEND_STRING 0,"strTXT3"
          strTXT1 = ""
          strTXT2 = ""
          strTXT3 = ""
        }
        ELSE
          nCount = nCount + 1
      }

      SEND_STRING 0,"strTXT1"
      SEND_STRING 0,"strTXT2"
      SEND_STRING 0,"strTXT3"
    }
    CASE 'ASCII' : {
      STACK_VAR INTEGER nLoop

    //-- Echo in chunks of 131 bytes (that's what works) --
      FOR(nLoop=1; nLoop<=LENGTH_STRING(cData); nLoop=nLoop+131) {
        IF(LENGTH_STRING(cData) > (nLoop-1+131))
          SEND_STRING 0,"MID_STRING(cData,nLoop,131)"
        ELSE
          SEND_STRING 0,"MID_STRING(cData,nLoop,LENGTH_STRING(cData)-nLoop+1)"
      }
    }
  }
}


//--------------------------------------------------------------------------------------------------------------------
// Switcher helpers:
//--------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------
// Make video switch to MP/MPL.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR swtVidin (INTEGER nSwtInp)
{
	// In case a switch makes it here while we are streaming
	IF (uPnl.uStream.bOn == FALSE)
	{
		SWITCH(uSwt.nType)
		{
			CASE SWT_TYPE_DVX   :
			CASE SWT_TYPE_SNAPI : {
				uSwt.nInput = nSwtInp;
				uSwt.nOutput= uProp.nPvwOut;
				
				SEND_COMMAND dvSWT[1], "'CLVIDEOI',ITOA(nSwtInp),'O',ITOA(uProp.nPvwOut)"
			}
			CASE SWT_TYPE_DGX   : {
				uSwt.nInput = nSwtInp;
				uSwt.nOutput= uProp.nPvwOut;
				SEND_COMMAND dvSWT[1], "'CL1I',ITOA(nSwtInp),'O',ITOA(uProp.nPvwOut),'T'"
			}
		}
	}
}

//-----------------------------------------------------
// Assign switcher properties.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR swtTypeAssign (DEV dvDEV)
STACK_VAR
  CHAR    cValue[30]
{
  cValue = devInfo (dvDEV, 'DEVICE_ID_STRING')

  SELECT
  {
    ACTIVE(FIND_STRING(cValue,'DW-SWTCH',1)) : { uSwt.nType = SWT_TYPE_DVX    uSwt.nInpCnt = 6  }
    ACTIVE(FIND_STRING(cValue,'DVX-2100',1)) : { uSwt.nType = SWT_TYPE_DVX    uSwt.nInpCnt = 6  }
    ACTIVE(FIND_STRING(cValue,'DVX-2150',1)) : { uSwt.nType = SWT_TYPE_DVX    uSwt.nInpCnt = 6  }
    ACTIVE(FIND_STRING(cValue,'DVX-2155',1)) : { uSwt.nType = SWT_TYPE_DVX    uSwt.nInpCnt = 6  }
    ACTIVE(FIND_STRING(cValue,'DVX-3150',1)) : { uSwt.nType = SWT_TYPE_DVX    uSwt.nInpCnt = 10 }
    ACTIVE(FIND_STRING(cValue,'DVX-3155',1)) : { uSwt.nType = SWT_TYPE_DVX    uSwt.nInpCnt = 10 }
		ACTIVE(FIND_STRING(cValue,'DVX-3156',1)) : { uSwt.nType = SWT_TYPE_DVX    uSwt.nInpCnt = 10 }
		
		// 1.08: Add DGX 8 and DGX 64 device types
		ACTIVE(FIND_STRING(cValue,'DGX 8'  ,1)) :  { uSwt.nType = SWT_TYPE_DGX    uSwt.nInpCnt = 0  }
		ACTIVE(FIND_STRING(cValue,'DGX 64' ,1)) :  { uSwt.nType = SWT_TYPE_DGX    uSwt.nInpCnt = 0  }
    ACTIVE(FIND_STRING(cValue,'DGX 16'  ,1)) : { uSwt.nType = SWT_TYPE_DGX    uSwt.nInpCnt = 0  }
    ACTIVE(FIND_STRING(cValue,'DGX 32'  ,1)) : { uSwt.nType = SWT_TYPE_DGX    uSwt.nInpCnt = 0  }
		
    ACTIVE(1)                                : { uSwt.nType = SWT_TYPE_SNAPI  uSwt.nInpCnt = 0  }
  }
}

//-----------------------------------------------------
// Start switcher video input status polling (DVX only).
//-----------------------------------------------------
DEFINE_FUNCTION CHAR swtVidinPollStart ()
STACK_VAR
  LONG    lTlTimes[1]
{
  IF(!TIMELINE_ACTIVE(TL_POLL_SWT_VIDIN)) {
    lTlTimes[1] = 300
    TIMELINE_CREATE(TL_POLL_SWT_VIDIN, lTlTimes, 1, TIMELINE_RELATIVE, TIMELINE_REPEAT)
    uSwt.nPollInp = 0

    RETURN(TRUE)
  }

  RETURN(FALSE)
}

//-----------------------------------------------------
// Stop switcher video input status polling.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR swtVidinPollStop ()
{
  IF(TIMELINE_ACTIVE(TL_POLL_SWT_VIDIN)) {
    TIMELINE_KILL(TL_POLL_SWT_VIDIN)
    uSwt.nPollInp = 0
    RETURN(TRUE)
  }

  RETURN(FALSE)
}


//--------------------------------------------------------------------------------------------------------------------
// Misc helpers:
//--------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------
// Helper to return DEVICE_INFO values.
//-----------------------------------------------------
DEFINE_FUNCTION CHAR[128] devInfo (DEV dvDEV, CHAR cKey[])
STACK_VAR
  DEV_INFO_STRUCT uDevInfo
{
  DEVICE_INFO (dvDEV, uDevInfo)

  IF(uDevInfo.DEVICE_ID = 0)
    RETURN ('')

  SWITCH(cKey)
  {
    CASE 'MANUFACTURER_STRING'  : RETURN(uDevInfo.MANUFACTURER_STRING)
    CASE 'MANUFACTURER '        : RETURN(ITOA(uDevInfo.MANUFACTURER) )
    CASE 'DEVICE_ID_STRING'     : RETURN(uDevInfo.DEVICE_ID_STRING   )
    CASE 'DEVICE_ID'            : RETURN(ITOA(uDevInfo.DEVICE_ID)    )
    CASE 'VERSION'              : RETURN(uDevInfo.VERSION            )
    CASE 'FIRMWARE_ID'          : RETURN(ITOA(uDevInfo.FIRMWARE_ID)  )
    CASE 'SOURCE_STRING'        : RETURN(uDevInfo.SOURCE_STRING      )
    CASE 'SERIAL_NUMBER'        :
    {
      IF(FIND_STRING(uDevInfo.SERIAL_NUMBER,"0",1)) {
        uDevInfo.SERIAL_NUMBER = REMOVE_STRING(uDevInfo.SERIAL_NUMBER,"0",1)
        SET_LENGTH_STRING(uDevInfo.SERIAL_NUMBER,LENGTH_STRING(uDevInfo.SERIAL_NUMBER)-1)
      }
      RETURN(uDevInfo.SERIAL_NUMBER)
    }
    CASE 'SOURCE_TYPE'          :
    {
      SWITCH(uDevInfo.SOURCE_TYPE)
      {
        CASE $00 : RETURN('SOURCE_TYPE_NO_ADDRESS'         )
        CASE $01 : RETURN('SOURCE_TYPE_NEURON_ID'          )
        CASE $02 : RETURN('SOURCE_TYPE_IP_ADDRESS'         )
        CASE $03 : RETURN('SOURCE_TYPE_AXLINK'             )
        CASE $10 : RETURN('SOURCE_TYPE_NEURON_SUBNODE_ICSP')
        CASE $11 : RETURN('SOURCE_TYPE_NEURON_SUBNODE_PL'  )
        CASE $12 : RETURN('SOURCE_TYPE_IP_SOCKET_ADDRESS'  )
        CASE $13 : RETURN('SOURCE_TYPE_RS232'              )
        CASE $14 : RETURN('SOURCE_TYPE_INTERNAL'           )
      }
    }
  }
}

//-----------------------------------------------------
// Get next value from an enumerated list (destructive).
//-----------------------------------------------------
DEFINE_FUNCTION CHAR[50] enumGetNext(CHAR cList[])
STACK_VAR
  CHAR cValue[50]
{
  cValue = REMOVE_STRING(cList,"'|'",1)

  IF(LENGTH_STRING(cValue)) {
    SET_LENGTH_STRING(cValue,LENGTH_STRING(cValue)-1)
  }
  ELSE {
    cValue = cList
    cList  = ""
  }

  RETURN(cValue)
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

//-- No echo ----------------------------------------------
TRANSLATE_DEVICE (vdvMXA, vdvAPI)


(***********************************************************)
(*                THE MODULES GO BELOW                     *)
(***********************************************************)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

//--------------------------------------------------------------------------------------------------------------------
// Device Listeners:
//--------------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------
// My API.
//---------------------------------------------------------
DATA_EVENT[vdvAPI]
{
  COMMAND :
  {
    STACK_VAR CHAR    cCmd[DUET_MAX_CMD_LEN]
    STACK_VAR CHAR    cHeader[DUET_MAX_HDR_LEN]
    STACK_VAR CHAR    cValue[DUET_MAX_PARAM_LEN]

    cCmd    = DATA.TEXT
    cHeader = DuetParseCmdHeader(cCmd)
    cValue  = DuetParseCmdParam(cCmd)
    IF(cValue = '-2147483648')
      cValue = '0'

    SWITCH(UPPER_STRING(cHeader))
    {
    //----------------------
    // Version
    //----------------------
      CASE '?VERSION' :
      {
        SEND_STRING 0,"'VERSION-',MDL_VERS,' (',MDL_NAME,')'"
      }
      CASE 'DEBUG'    : {
        cValue = UPPER_STRING(cValue)
        SELECT
        {
          ACTIVE((cValue='0') || (cValue='OFF'  )) : debugSetLvl ('OFF'  )
          ACTIVE((cValue='1') || (cValue='ERROR')) : debugSetLvl ('ERROR')
          ACTIVE((cValue='2') || (cValue='WARN' )) : debugSetLvl ('WARN' )
          ACTIVE((cValue='3') || (cValue='INFO' )) : debugSetLvl ('INFO' )
        }
      }
    //----------------------
    // Properties
    //----------------------
      CASE 'PROPERTY' :
      {
        SWITCH(UPPER_STRING(cValue))
        {
          CASE 'SCAN_DELAY'   : {  // 'PROPERTY-SCAN_DELAY,<valSwt>,<valSync>'
            uProp.nDelaySwt = ATOI(DuetParseCmdParam(cCmd))
            uProp.nDelaySyn = ATOI(DuetParseCmdParam(cCmd))
          }
          CASE 'SLOT'         : { // 'PROPERTY-SLOT,<slotX>,<swtInp>,<friendlyName>'
            STACK_VAR INTEGER nSource
            STACK_VAR INTEGER nSwtInp
            STACK_VAR CHAR    cText[50]
            STACK_VAR CHAR    cPage[50]
            STACK_VAR CHAR    cImg[50]
						STACK_VAR INTEGER nCount;

            nSource  = ATOI(DuetParseCmdParam(cCmd))
            nSwtInp  = ATOI(DuetParseCmdParam(cCmd))
            cText    = DuetParseCmdParam(cCmd)
            cPage    = DuetParseCmdParam(cCmd)
            cImg     = DuetParseCmdParam(cCmd)

            IF(nSource && (nSource <= SRC_CNT)) {
              uProp.uSrc[nSource].nSwtInp  = nSwtInp
              uProp.uSrc[nSource].cText    = cText
              uProp.uSrc[nSource].cSubPage = cPage
              uProp.uSrc[nSource].cImg     = cImg
              mxaImgReset (nSource)
							uProp.nPvwWinCount = 0;
							FOR(nCount=1; nCount<=SRC_CNT; nCount++)
							{
								IF (uProp.uSrc[nCount].nSwtInp)
									uProp.nPvwWinCount++;
							}
            }
            ELSE {
              debugMsg (DEBUG_ERROR, "'MXA_MPx|PROPERTY-SLOT,',ITOA(nSource),',',ITOA(nSwtInp),',',cText,',',cPage,',',cImg,'|Slot is out of range (1-',ITOA(SRC_CNT),')!'")
            }
          }
          CASE 'SWT_PVW_OUT'  : {  // 'PROPERTY-SWT_PVW_OUT,<Value>'
            uProp.nPvwOut = ATOI(DuetParseCmdParam(cCmd))
            uProp.nPvwOut  = uProp.nPvwOut
          }
          CASE 'TYPE'         : {  // PROPERTY-TYPE,<MP or MPL>'
            SWITCH(UPPER_STRING(DuetParseCmdParam(cCmd)))
            {
              CASE 'MP'  : uProp.bCanStream = FALSE
              CASE 'MPL' : uProp.bCanStream = TRUE
            }
          }
	  CASE 'SYNCHRONOUS_MODE'   : {  // 'PROPERTY-SYNCHRONOUS_MODE,<0:Asynchronous,1:Synchronous>'
            uProp.nSynchronousMode = ATOI(DuetParseCmdParam(cCmd))
          }
        }
      }
    }
  }
}

//-----------------------------------------------------
// My Panel.
//-----------------------------------------------------
DATA_EVENT[dvPNL]
{
  ONLINE :
  {
    STACK_VAR INTEGER nLoop

  //-- Add dynamo images --
    FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
      SEND_COMMAND DATA.DEVICE,"'^RAF-MXA_PVW_',ITOA(nLoop),',%V1%P0%Hmxamp%Asnapit%Fslot',ITOA(nLoop),'.jpg'"
    }

  //-- Default window properties --
    FOR(nLoop=1; nLoop<=SRC_CNT; nLoop++) {
      SEND_COMMAND DATA.DEVICE,"'^BMP-',ITOA(nVT_PVW_WIN[nLoop]),',1,',mxaImgReset(nLoop)"
    }

	//-- Disable Video Streaming --
	FOR(nLoop=1; nLoop<=SRC_CNT; nLoop++) {
		SEND_COMMAND DATA.DEVICE,"'^SDM-',ITOA(nVT_PVW_WIN[nLoop]),',2,'";
	}
	
	
	//-- Remove Video Fill --
	FOR(nLoop=1; nLoop<=SRC_CNT; nLoop++) {
		SEND_COMMAND DATA.DEVICE,"'^BOS-',ITOA(nVT_PVW_WIN[nLoop]),',2,0'";
	}

  //-- Enable custom events (anchor, onscreen, offscreen, reorder) --
    SEND_COMMAND DATA.DEVICE,"'^SCE-',ITOA(nVT_VIEWER),',32001,32002,0,0'"
    // Hide any subpages that may be open on the panel
    SEND_COMMAND DATA.DEVICE,"'^SHA-',ITOA(nVT_VIEWER)"
  }
  OFFLINE :
  {
    STACK_VAR INTEGER nLoop

    uPnl.uStream.bOn = FALSE
    uPnl.uStream.bStartingStream = FALSE
    uPnl.uStream.bStoppingStream = FALSE

  //-- Stop scanning --
    mxaScanStop ()

  //-- Reset scanning properties --
    mxaScanReset ()

  //-- Reset window images --
    FOR(nLoop=1; nLoop<=SRC_CNT; nLoop++) {
      mxaImgReset (nLoop)
    }
  }
  STRING :
  {
    STACK_VAR CHAR    cCmd[DUET_MAX_CMD_LEN]
    STACK_VAR CHAR    cHeader[DUET_MAX_HDR_LEN]
    STACK_VAR CHAR    cValue [DUET_MAX_PARAM_LEN]

    cCmd    = DATA.TEXT
    cHeader = DuetParseCmdHeader(cCmd)
    cValue  = DuetParseCmdParam(cCmd)

    SWITCH(cHeader)
    {
    //-----------------
    //-- Pageflips ----
    //-----------------
      CASE 'PAGE'      :
      {
        SWITCH(cValue)
        {
          CASE cVT_VIEWER_PAGE : {
            STACK_VAR INTEGER nLoop

          //-- Reset macro preview windows --
            FOR(nLoop=1; nLoop<=SRC_CNT; nLoop++) {
              SEND_COMMAND DATA.DEVICE,"'^BMP-',ITOA(nVT_PVW_WIN[nLoop]),',1,',mxaImgReset(nLoop)"
            }
          }
          DEFAULT : {
            IF(mxaScanStop()) {
              STACK_VAR INTEGER nLoop
              STACK_VAR INTEGER nSource

            //-- Reset macro preview windows --
              FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
                nSource = uPnl.uScan.uPvwWin[nLoop].nSource

                IF(nSource) {
                  SEND_COMMAND DATA.DEVICE,"'^BMP-',ITOA(nVT_PVW_WIN[nLoop]),',1,',mxaImgReset(nSource)"
                }
              }

            //-- Clear history --
              mxaScanReset ()
            }
          }
        }
      }
    //-----------------
    //-- Popups    ----
    //-----------------
      CASE 'PPON'      : // On
      CASE '@PPN'      :
      {
      }
      CASE 'PPOF'      : // Off
      CASE '@PPF'      :
      {
      }
    }
  }
}

//-----------------------------------------------------
// My Switcher.
//-----------------------------------------------------
DATA_EVENT[dvSWT]
{
  ONLINE :
  {
  //-- Sniff the switcher type --
    IF(DATA.DEVICE = dvSWT[1])
      swtTypeAssign(DATA.DEVICE)

  //-- Video input status (where supported) --
    SWITCH(uSwt.nType)
    {
    //-- DVX: Query for initial status --
      CASE SWT_TYPE_DVX   : {
        SEND_COMMAND DATA.DEVICE,'?VIDIN_STATUS'

//-- NOTE: Polling not implemented.  A switch command replies --
//--       with VIDIN_STATUS and that is be good enough.      --
//      IF(DATA.DEVICE = dvSWT[1])
//        swtVidinPollStart ()
      }
    //-- DGX/SNAPI: Not supported, so fake it --
      CASE SWT_TYPE_DGX   :
      CASE SWT_TYPE_SNAPI : {
        STACK_VAR INTEGER nLoop

        FOR(nLoop=1; nLoop<=SRC_CNT; nLoop++)
          uSrcState[nLoop].bVidInStatus = TRUE
      }
    }
  }
  OFFLINE :
  {
    STACK_VAR INTEGER nLoop

    FOR(nLoop=1; nLoop<=SRC_CNT; nLoop++)
      uSrcState[nLoop].bVidInStatus = FALSE

    swtVidinPollStop ()
  }
  COMMAND :
  {
  //-- DVX: Video input status --
    IF(uSwt.nType = SWT_TYPE_DVX) {
      IF(FIND_STRING(DATA.TEXT,'VIDIN_STATUS',1)) {
        STACK_VAR CHAR    cCmd[DUET_MAX_CMD_LEN]
        STACK_VAR CHAR    cHeader[DUET_MAX_HDR_LEN]
        STACK_VAR CHAR    cValue[DUET_MAX_PARAM_LEN]
        STACK_VAR INTEGER nDevIdx
        STACK_VAR INTEGER nLoop
        STACK_VAR INTEGER nSource

        cCmd    = DATA.TEXT
        cHeader = DuetParseCmdHeader(cCmd)
        cValue  = DuetParseCmdParam(cCmd)

        nDevIdx = GET_LAST(dvSWT)

        FOR(nLoop=1; nLoop<=SRC_CNT; nLoop++) {
          IF(uProp.uSrc[nLoop].nSwtInp = nDevIdx) {
            nSource = nLoop
            BREAK;
          }
        }

        IF(nSource) {
          STACK_VAR CHAR    bPrev

          bPrev = uSrcState[nSource].bVidInStatus

          SWITCH(UPPER_STRING(cValue))
          {
            CASE 'VALID SIGNAL'   :
            CASE 'SIGNAL IS OK'   : uSrcState[nSource].bVidInStatus = TRUE
            CASE 'NO SIGNAL'      :
            CASE 'UNKNOWN'        :
            CASE 'UNKNOWN SIGNAL' : uSrcState[nSource].bVidInStatus = FALSE
          }

        //---------------------
        //-- Change in status
        //---------------------
          IF(uSrcState[nSource].bVidInStatus <> bPrev)
          {
          //--------------
          //-- VidIn: On
          //--------------
            IF(uSrcState[nSource].bVidInStatus = TRUE) {
            //-- Reset image --
              FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
                IF(uPnl.uScan.uPvwWin[nLoop].nSource = nSource) {
                  uPnl.uScan.uPvwWin[nLoop].bImgInit = TRUE
                  BREAK
                }
              }
              mxaImgReset(nSource)

            //-- Let's restart scanning --
              IF(!uPnl.uStream.bOn) {
								FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++)  {
                  IF(uPnl.uScan.uPvwWin[nLoop].nSource = nSource) {
                    mxaScanRestart (nLoop)
                    BREAK;
                  }
                }
              }
            }

          //--------------
          //-- VidIn: Off
          //--------------
            IF(uSrcState[nSource].bVidInStatus = FALSE) {
              SEND_COMMAND dvPNL,"'^BMP-',ITOA(nVT_PVW_WIN[nSource]),',1,',mxaImgAssign(nSource,'icon-novideo.png')"

            //-- Let's stop streaming this --
              IF(uPnl.uStream.bOn && (uPnl.uStream.nSource = nSource)) {
                SEND_COMMAND dvPNL,"'^BMP-',ITOA(nVT_PVW_WIN[nSource]),',0,',mxaImgAssign(nSource,'icon-novideo-filled.png')"
                mxaStreamStop ()
              }

            //-- Let's advance scanning --
              IF(!uPnl.uStream.bOn) {
								FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
                  IF(uPnl.uScan.uPvwWin[nLoop].nSource = nSource) {
                    mxaScanRestart (0)
                    BREAK;
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}


//--------------------------------------------------------------------------------------------------------------------
// Custom events:
//--------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------
// ModeroX Pantastic (Streaming)
//-----------------------------------------------------
CUSTOM_EVENT[dvPNL,0,768]    // Streaming start/stop
{
    SWITCH(CUSTOM.FLAG)
    {
    //-- Start --
    CASE 1 :
    {
	IF (uPnl.uStream.bStartingStream)
	{
	    debugMsg (DEBUG_INFO, "'MXA_MPx|ModeroX Streaming|Panel custom event (EventID=768:Streaming Start)'")
	    uPnl.uStream.bOn = TRUE
	    uPnl.uStream.nJustStopped = FALSE;
#IF_NOT_DEFINED USE_VIDEO_WINDOW
	    //-- Stop showing "loading" image (for stream) and button will fill with video --
	    SEND_COMMAND dvPNL,"'^BMP-',ITOA(nVT_PVW_WIN[uPnl.uStream.nSource]),',2'"
#END_IF
	    //-- Callback --
	    IF(uPnl.uStream.nSource)
		SEND_COMMAND vdvAPI,"'STREAM-START,',ITOA(uPnl.uStream.nSource),',',ITOA(uProp.uSrc[uPnl.uStream.nSource].nSwtInp)"
	    ELSE
		SEND_COMMAND vdvAPI,"'STREAM-START,UNKNOWN,UNKNOWN'"
	    uPnl.uStream.bStartingStream = FALSE
	}
    }
    //-- Stop ---
    CASE 2 :
    {
	IF(uPnl.uStream.bStoppingStream)
	{
	    debugMsg (DEBUG_INFO, "'MXA_MPx|ModeroX Streaming|Panel custom event (EventID=768:Streaming Stop)'")
	    // Update
#IF_DEFINED USE_VIDEO_WINDOW
	    // HIDE VIDEO WINDOW
	    SEND_COMMAND dvPNL,"'@PPF-VIDEO_WINDOW'";
#END_IF
	    SEND_COMMAND vdvAPI,"'STREAM-STOP'"
	    uPnl.uStream.bStoppingStream = FALSE
	}
    }
  //-- Unknown --
    CASE 8  :    // Error
    DEFAULT : {  // Unknown
      IF(debugMsg (DEBUG_INFO, "'MXA_MPx|ModeroX Streaming|Panel custom event (EventID=768:Streaming Flag Unknown)'")) {
        debugEcho ('ASCII', "'  CUSTOM_FLAG  : ',CUSTOM.FLAG  ")
        debugEcho ('ASCII', "'  CUSTOM_VALUE1: ',CUSTOM.VALUE1")
        debugEcho ('ASCII', "'  CUSTOM_VALUE2: ',CUSTOM.VALUE2")
        debugEcho ('ASCII', "'  CUSTOM_TEXT  : ',CUSTOM.TEXT  ")
      }
    }
  }
}

//-----------------------------------------------------
// ModeroX Pantastic (Dynamo has loaded)
//-----------------------------------------------------
CUSTOM_EVENT[dvPNL,0,1400]   // Dynamo loaded
{
    IF(FIND_STRING(CUSTOM.TEXT,'MXA_PVW_',1)) {
      STACK_VAR
	INTEGER nCurrent
	INTEGER nSource

    nCurrent = uPnl.uScan.nCurrent
    nSource = ATOI(CUSTOM.TEXT)

    IF(debugMsg (DEBUG_INFO, "'MXA_MPx|ModeroX Dynamo Loaded|Panel custom event (EventID=1400:Dynamo Loaded)'")) {
      debugEcho ('ASCII', "'  Resource Name: ',CUSTOM.TEXT")
      debugEcho ('ASCII', "'         PvwWin: ',ITOA(nCurrent)")
      debugEcho ('ASCII', "'         Source: ',ITOA(uPnl.uScan.uPvwWin[nCurrent].nSource)")
      debugEcho ('ASCII', "'         VidInp: ',ITOA(uPnl.uScan.uPvwWin[nCurrent].nSwtInp)")
    }

  //-- When dynamo image has finished loading, show it in the assigned preview window --
    IF( uPnl.uScan.uPvwWin[nCurrent].nSource &&
	uPnl.uScan.uPvwWin[nCurrent].nSwtInp)
    {
    //-- State --
	uPnl.uScan.uPvwWin[nCurrent].bImgInit = FALSE

    //-- Show the dynamic resource & restart the timeline --
	IF (uProp.uSrc[nSource].nSwtInp == uSwt.nInput) {
	    SEND_COMMAND dvPNL,"'^BBR-',ITOA(nVT_PVW_WIN[nSource]),',1,','MXA_PVW_',ITOA(nSource)"
	    SEND_COMMAND dvPNL,"'^RMF-MXA_PVW_',ITOA(nSource),',%V1'"
	    TIMELINE_RESTART(TL_SCAN)
	}
    }
  }
}


//-----------------------------------------------------
// ModeroX Pantastic (Preview Viewer - Anchor)
//-----------------------------------------------------
CUSTOM_EVENT[dvPNL,nVT_VIEWER,32001] // Anchor
{
  IF(debugMsg (DEBUG_INFO, "'MXA_MPx|ModeroX Pantastic Viewer|Preview viewer custom event (EventID=32001:Anchor   )|',ITOA(CUSTOM.VALUE1),' of ',ITOA(CUSTOM.VALUE2)"))
    debugEcho ('ASCII', "'  Message3: ',CUSTOM.TEXT")
//-- Where: CUSTOM.TEXT=[somePreview]SOME_SRC_SUBPAGE --

//-- Here's our anchor macro (hold until onscreen, when we can assign idx) --
  uPnl.nAnchorSource = mxaGetSubpageIndex (CUSTOM.TEXT)
  uPnl.nAnchorIdx    = 0

//-- Callback --
  IF(uPnl.nAnchorSource)
    SEND_COMMAND vdvAPI,"'ANCHOR-',ITOA(uPnl.nAnchorSource),',',ITOA(uProp.uSrc[uPnl.nAnchorSource].nSwtInp)"
  ELSE
    SEND_COMMAND vdvAPI,"'ANCHOR-ERROR'"
}


//-----------------------------------------------------
// ModeroX Pantastic (Preview Viewer - Onscreen)
//-----------------------------------------------------
CUSTOM_EVENT[dvPNL,nVT_VIEWER,32002] // Onscreen
{
  STACK_VAR INTEGER nLoop
  STACK_VAR CHAR    cListNew[PVW_WIN_CNT]
  STACK_VAR CHAR    cListOld[PVW_WIN_CNT]
  STACK_VAR CHAR    cListRpl[PVW_WIN_CNT]
  STACK_VAR CHAR    cListRp2[PVW_WIN_CNT]
  STACK_VAR CHAR    cListFnl[PVW_WIN_CNT]
  STACK_VAR INTEGER nFound
  STACK_VAR INTEGER nSource

  IF(debugMsg (DEBUG_INFO, "'MXA_MPx|ModeroX Pantastic Viewer|Preview viewer custom event (EventID=32002:OnScreen )|',ITOA(CUSTOM.VALUE1),' of ',ITOA(CUSTOM.VALUE2)"))
    debugEcho ('ASCII', "'  Message3: ',CUSTOM.TEXT")
//-- Where: CUSTOM.TEXT=[somePreview]SOME_SRC_SUBPAGE1|[somePreview]SOME_SRC_SUBPAGE2|[somePreview]SOME_SRC_SUBPAGE3 --

//-- Create a temp list with these onscreen subpages (in view) --
  SET_LENGTH_STRING(cListNew, PVW_WIN_CNT)
  FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
    cListNew[nLoop] = mxaGetSubpageIndex (enumGetNext(CUSTOM.TEXT))
  }

//-------------------------------------------------
//-- Reset any in the old list (now offscreen) --
//-------------------------------------------------
  FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
    nSource = uPnl.uScan.uPvwWin[nLoop].nSource
    nFound  = FIND_STRING(cListNew, "nSource", 1)

    IF(!nFound) {
    //-- Offscreen, reset dynamo properties (we'll reuse this dynamo in the replace) --
      uPnl.uScan.uPvwWin[nLoop].nSource  = 0
      uPnl.uScan.uPvwWin[nLoop].nSwtInp  = 0
      uPnl.uScan.uPvwWin[nLoop].bImgInit = FALSE

    //-- Offscreen, reset source state --
      IF(nSource) {
        uSrcState[nSource].bOnscreen     = FALSE
        //SEND_COMMAND dvPNL,"'^BMP-',ITOA(nVT_PVW_WIN[nSource]),',1,',mxaImgReset(nSource)"
      }
    }

    cListOld = "cListOld, uPnl.uScan.uPvwWin[nLoop].nSource"
  }

//---------------------------------------------
//-- Create a replace list (now onscreen) --
//---------------------------------------------
  FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
    IF(!FIND_STRING(cListOld,"cListNew[nLoop]",1))
      cListRpl = "cListRpl,cListNew[nLoop]"
  }
  cListRp2 = cListRpl // Hold for debug

//-- Any that were reset are replaced here (now onscreen) --
  FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
    IF(cListOld[nLoop] = 0) {
      nSource = GET_BUFFER_CHAR(cListRpl)
      cListFnl = "cListFnl, nSource"

      IF(nSource) {
      //-- Assign dynamo properties --
        uPnl.uScan.uPvwWin[nLoop].nSource  = nSource
        uPnl.uScan.uPvwWin[nLoop].nSwtInp  = uProp.uSrc[nSource].nSwtInp
        uPnl.uScan.uPvwWin[nLoop].bImgInit = TRUE

      //-- Assign source state --
        uSrcState[nSource].bOnscreen       = TRUE
      }
    }
    ELSE
      cListFnl = "cListFnl, cListOld[nLoop]"
  }

//-------------------------
//-- Assign anchor index --
//-------------------------
  IF(uPnl.nAnchorSource) {
    FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
      IF(uPnl.uScan.uPvwWin[nLoop].nSource = uPnl.nAnchorSource) {
        uPnl.nAnchorIdx = nLoop
        BREAK;
      }
    }
  }

//-----------------------------------
//-- Head spinning? Check results! --
//-----------------------------------
  IF(debugMsg (DEBUG_INFO, "'MXA_MPx|Pantastic Preview Viewer|Search/Replace Results'")) {
    STACK_VAR CHAR cText[5][100]

    FOR(nLoop=1; nLoop<=LENGTH_STRING(cListNew); nLoop++)  cText[1] = "cText[1],ITOA(cListNew[nLoop]),'-'"
    FOR(nLoop=1; nLoop<=LENGTH_STRING(cListOld); nLoop++)  cText[2] = "cText[2],ITOA(cListOld[nLoop]),'-'"
    FOR(nLoop=1; nLoop<=LENGTH_STRING(cListRpl); nLoop++)  cText[3] = "cText[3],ITOA(cListRpl[nLoop]),'-'"
    FOR(nLoop=1; nLoop<=LENGTH_STRING(cListRp2); nLoop++)  cText[4] = "cText[4],ITOA(cListRp2[nLoop]),'-'"
    FOR(nLoop=1; nLoop<=LENGTH_STRING(cListFnl); nLoop++)  cText[5] = "cText[5],ITOA(cListFnl[nLoop]),'-'"

    IF(LENGTH_STRING(cText[1]))  SET_LENGTH_STRING(cText[1], LENGTH_STRING(cText[1])-1)
    IF(LENGTH_STRING(cText[2]))  SET_LENGTH_STRING(cText[2], LENGTH_STRING(cText[2])-1)
    IF(LENGTH_STRING(cText[3]))  SET_LENGTH_STRING(cText[3], LENGTH_STRING(cText[3])-1)
    IF(LENGTH_STRING(cText[4]))  SET_LENGTH_STRING(cText[4], LENGTH_STRING(cText[4])-1)
    IF(LENGTH_STRING(cText[5]))  SET_LENGTH_STRING(cText[5], LENGTH_STRING(cText[5])-1)

    debugEcho ('ASCII', "'  cListNew[',ITOA(LENGTH_STRING(cListNew)),']: ',cText[1]")
    debugEcho ('ASCII', "'  cListOld[',ITOA(LENGTH_STRING(cListOld)),']: ',cText[2]")
    debugEcho ('ASCII', "'  cListRpl[',ITOA(LENGTH_STRING(cListRpl)),']: ',cText[3]")
    debugEcho ('ASCII', "'  cListRp2[',ITOA(LENGTH_STRING(cListRp2)),']: ',cText[4]")
    debugEcho ('ASCII', "'  cListFnl[',ITOA(LENGTH_STRING(cListFnl)),']: ',cText[5]")

    debugEcho ('ASCII', "'  nAnchorSource: ',ITOA(uPnl.nAnchorSource)")
    debugEcho ('ASCII', "'  nAnchorIdx: ',ITOA(uPnl.nAnchorIdx)")
  }

    //-- Our list is updated, we can restart --
    // Anchor and onscreen events should only be received whenever there is an
    // anchor change.  Given this, if we were streaming it should stop
    if (uPnl.uStream.bOn)
    {
	mxaStreamStop()
    }
    mxaScanRestart (uPnl.nAnchorIdx)
}


//--------------------------------------------------------------------------------------------------------------------
// Timeline events:
//--------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------
// MXA preview scanning.
//-----------------------------------------------------
TIMELINE_EVENT[TL_SCAN]
{
  uPnl.uScan.nSeq = TIMELINE.SEQUENCE

  SWITCH(TIMELINE.SEQUENCE)
  {
		/*
    CASE 1 : { // MP UnBlank
      //SEND_COMMAND dvPNL,'^SLT-1,VIDEOINPUT=ON'
    }
		*/
    CASE 1 : { // MP Blank / Switch the input
      //SEND_COMMAND dvPNL,'^SLT-1,VIDEOINPUT=OFF'
      mxaScanStepSwitch ()
    }
		
    CASE 2 : { // MP snapshot
		
      mxaScanStepSnap   ()

      IF(!mxaScanGetNext()) {
        debugMsg (DEBUG_ERROR, "'MXA_MPx|TIMELINE_EVENT|mxaScanGetNext()=false|Cannot continue scanning, have to stop!'")
        mxaScanStop ()
      }
    }
  }
}

//-----------------------------------------------------
// Switcher video input status polling.
//-----------------------------------------------------
TIMELINE_EVENT[TL_POLL_SWT_VIDIN]
{
  uSwt.nPollInp++
  IF(uSwt.nPollInp > uSwt.nInpCnt)
    uSwt.nPollInp = 1


  SWITCH(uSwt.nType)
  {
    CASE SWT_TYPE_DVX   : {
      IF(uSwt.nPollInp <= LENGTH_ARRAY(dvSWT))
        SEND_COMMAND dvSWT[uSwt.nPollInp],'?VIDIN_STATUS'
    }
    CASE SWT_TYPE_DGX   :
    CASE SWT_TYPE_SNAPI : {
      swtVidinPollStop ()
    }
  }
}


//--------------------------------------------------------------------------------------------------------------------
// Button events:
//--------------------------------------------------------------------------------------------------------------------

//-----------------------------------------------------
// Source selection for preview.
// This button event is triggered whenever the user selects one of the preview
// buttons at the bottom of the example pages.
// 1. A command is sent to the preview window source name button to match the
//    value defined when this module is initialized.
// 2. A callback command is issued.
// 3. No activation of the actual preview window is performed here since it
//    is programmed into the example pages.
//-----------------------------------------------------
BUTTON_EVENT[dvPNL,nBTN_SRC_SELECT]
{
    PUSH:
    {
	STACK_VAR INTEGER nSource
	nSource = GET_LAST(nBTN_SRC_SELECT)
	debugMsg (DEBUG_INFO, "'MXA_MPx|nBTN_SRC_SELECT[',ITOA(nSource),']|Select this preview window.'")
	// -- Update preview window name --
	IF(LENGTH_STRING(uProp.uSrc[nSource].cText))
	{
	    SEND_COMMAND dvPNL,"'^TXT-',ITOA(nVT_PVW_NAME[nSource]),',0,',uProp.uSrc[nSource].cText"
	}
	//-- Callback --
	SEND_COMMAND vdvAPI,"'SELECT-',ITOA(nSource),',',ITOA(uProp.uSrc[nSource].nSwtInp)"
    }
}

//-----------------------------------------------------
// Source selection for streaming.
// This button event is triggered whenever the user touches one of the preview
// subpages.  There are several possibilities:
// 1. The user touched the anchor subpage.
// 2. The user touched a non-anchor subpage.
// 3. The panel was streaming when the subpage was touched.
// 4. The panel was scanning when the subpage was touched.
// If the user touched a non-anchor subpage, then a command will be sent
// to anchor it.  If the panel was streaming when the non-anchor was
// touched, streaming will be stopped on the the old anchor
// and scanning is restarted.  If the panel was scanning
// when the non-anchor was touched, nothing changes.  Scanning will continue.
// If the user touched the anchor subpage, then a simple flip from scanning
// to streaming or vice versa is performed.
//-----------------------------------------------------
BUTTON_EVENT[dvPNL,nBTN_SRC_STREAM]
{
    // Process on release only
    RELEASE:
    {
	STACK_VAR INTEGER nSource
	nSource = GET_LAST(nBTN_SRC_STREAM)
	// Determine whether or not the anchor was touched
	IF (uPnl.nAnchorSource = nSource)
	{
	    // Anchor was touched, now determine whether or not to toggle
	    // streaming.  The first check is whether or not streaming is on.
	    // If streaming is on, it should be stopped and scanning restarted.
	    IF (uPnl.uStream.bOn)
	    {			    
		mxaStreamStop()
	    }
	    ELSE
	    {
		// Streaming was off, can we turn it on?
		IF (uProp.bCanStream && uProp.uSrc[nSource].nSwtInp && uSrcState[nSource].bVidInStatus)
		{
		    // Yes can stream
		    debugMsg (DEBUG_INFO, "'MXA_MPx|nBTN_SRC_STREAM[',ITOA(nSource),']|Toggle streaming for this source.'")
		    // Switch to the correct input
		    uSwt.nInput = uProp.uSrc[nSource].nSwtInp;
		    SEND_COMMAND dvSWT[1], "'CLVIDEOI',ITOA(uProp.uSrc[nSource].nSwtInp),'O',ITOA(uProp.nPvwOut)"
		    // And start streaming
		    mxaStreamStart (nSource)
		}
		ELSE
		{
		    // No, can't stream so inform the user
		    SEND_COMMAND dvPNL,'ADBEEP'
		}
	    }
	}
	ELSE
	{
	    // User touched a non-anchor so make it the new anchor
	    SEND_COMMAND dvPNL,"'^SSH-',ITOA(nVT_VIEWER),',',uProp.uSrc[nSource].cSubPage"
	    debugMsg (DEBUG_INFO, "'MXA_MPx|nBTN_SRC_STREAM[',ITOA(nSource),']|Anchor this source in center.'")
	}
    }
}

#IF_DEFINED USE_VIDEO_WINDOW
//-----------------------------------------------------
// Close Video Window - Restart Scanning
//-----------------------------------------------------
BUTTON_EVENT[dvPNL,nBTN_VID_WINDOW_CLOSE]
{
	PUSH:
	{
		IF(uPnl.uStream.bOn)
			mxaStreamStop  ()
	}
}
#END_IF

//-----------------------------------------------------
// Close preview window.
//-----------------------------------------------------
BUTTON_EVENT[dvPNL,nBTN_PVW_CLOSE]
{
  RELEASE :
  {
    STACK_VAR INTEGER nSource
    STACK_VAR INTEGER nPvwWinIdx
    STACK_VAR INTEGER nLoop
    STACK_VAR CHAR    bKeepScanning
    STACK_VAR CHAR    bAnchorClosing

    nSource = GET_LAST(nBTN_PVW_CLOSE)
    debugMsg (DEBUG_INFO, "'MXA_MPx|nBTN_PVW_CLOSE[',ITOA(nSource),']|Close this preview window.'")

  //-- Reset this preview window just closed (NOTE: we don't get CUSTOM_EVENT[OffScreen]) --
    FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
      IF(uPnl.uScan.uPvwWin[nLoop].nSource = nSource) {
      //-- Look for anchor to close --
        IF(uPnl.nAnchorSource = nSource)
          bAnchorClosing = TRUE

      //-- Closed, reset dynamo properties --
        uPnl.uScan.uPvwWin[nLoop].nSource  = 0
        uPnl.uScan.uPvwWin[nLoop].nSwtInp  = 0
        uPnl.uScan.uPvwWin[nLoop].bImgInit = FALSE

      //-- Closed, reset source state --
        uSrcState[nSource].bOnscreen       = FALSE
        SEND_COMMAND dvPNL,"'^BMP-',ITOA(nVT_PVW_WIN[nSource]),',1,',mxaImgReset(nSource)"

        BREAK
      }
    }

  //-- Do we need to keep scanning? --
    FOR(nLoop=1; nLoop<=PVW_WIN_CNT; nLoop++) {
      IF(uPnl.uScan.uPvwWin[nLoop].nSource > 0) {
        bKeepScanning = TRUE
        BREAK
      }
    }

  //-- Look for last anchor to close --
    IF(bAnchorClosing && !bKeepScanning) {
      SEND_COMMAND vdvAPI,"'ANCHOR-0'"
    }

  //-- Stop Scanning --
    IF(!bKeepScanning) {
      mxaScanStop ()
    }

  //-- Stop Streaming --
    IF(uPnl.uStream.bOn && (uPnl.uStream.nSource = nSource)) {
      mxaStreamStop ()
    }
  }
}


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM
tl_scan_active=timeline_active(tl_scan)
tl_poll_swt_vidin_active=timeline_active(tl_poll_swt_vidin)

if(nJeffScanStart)
{
	off[nJeffScanStart]
	mxaScanStart()
}
(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
