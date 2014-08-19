(*********************************************************************)
(*  AMX Corporation                                                  *)
(*  Copyright (c) 2004-2006 AMX Corporation. All rights reserved.    *)
(*********************************************************************)
(* Copyright Notice :                                                *)
(* Copyright, AMX, Inc., 2004-2007                                   *)
(*    Private, proprietary information, the sole property of AMX.    *)
(*    The contents, ideas, and concepts expressed herein are not to  *)
(*    be disclosed except within the confines of a confidential      *)
(*    relationship and only then on a need to know basis.            *)
(*********************************************************************)
MODULE_NAME = 'Polycom EagleEye CameraComponent' (dev vdvDev[], dev dvTP, dev dvTPMain, INTEGER nDevice, INTEGER nPages[])
(***********************************************************)
(* System Type : NetLinx                                   *)
(* Creation Date: 6/18/2007 3:14:31 PM                    *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

#include 'Polycom EagleEye MainInclude.axi'

#include 'SNAPI.axi'
#include 'G4API.axi'

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

// Channels
BTN_QUERY_CAMERA_PRESET         = 1125  // Button: Query Camera Preset
BTN_ZOOM_LVL_RELEASE            = 3125  // Button: setZoom Lvl Release btn
BTN_FOCUS_LVL_RELEASE           = 3126  // Button: setFocus Lvl Release Btn
BTN_IRIS_LVL_RELEASE            = 3127  // Button: setIris Lvl Release Btn
BTN_ZOOM_SPEED_LVL_RELEASE      = 3128  // Button: setZoomSpeed Lvl Release Btn
BTN_FOCUS_SPEED_LVL_RELEASE     = 3129  // Button: setFocusSpeed Lvl Release Btn
BTN_IRIS_SPEED_LVL_RELEASE      = 3130  // Button: setIrisSpeed Lvl Release Btn
BTN_PAN_SPEED_LVL_RELEASE       = 3131  // Button: setPanSpeed Lvl Release Btn
BTN_TILT_LVL_RELEASE            = 3132  // Button: setTilt Lvl Release Btn
BTN_TILT_SPEED_LVL_RELEASE      = 3133  // Button: setTiltSpeed Lvl Release Btn
BTN_PAN_LVL_RELEASE             = 3134  // Button: setPan Lvl Release Btn

// Levels

// Variable Text Addresses

/* G4 CHANNELS
BTN_AUTO_FOCUS                  = 172   // Button: Auto Focus
BTN_AUTO_IRIS                   = 173   // Button: Auto Iris
BTN_CAM_PRESET_SAVE             = 260   // Button: Save Camera Preset

#IF_NOT_DEFINED BTN_CAM_PRESET
INTEGER BTN_CAM_PRESET[]        =       // Button: Camera Preset
{
  261,  262,  263,  264,  265,
  266,  267,  268,  269,  270,
  271,  272,  273,  274,  275,
  276,  277,  278,  279,  280
}
#END_IF // BTN_CAM_PRESET

BTN_FOCUS_FAR                   = 161   // Button: Focus Far
BTN_FOCUS_NEAR                  = 160   // Button: Focus Near
BTN_IRIS_CLOSE                  = 175   // Button: Iris Close
BTN_IRIS_OPEN                   = 174   // Button: Iris Open
BTN_PAN_RT                      = 135   // Button: Pan Right
BTN_PAN_LT                      = 134   // Button: Pan Left
BTN_TILT_DN                     = 133   // Button: Tilt Down
BTN_TILT_UP                     = 132   // Button: Tilt Up
BTN_ZOOM_IN                     = 159   // Button: Zoom In
BTN_ZOOM_OUT                    = 158   // Button: Zoom Out
*/

/* SNAPI CHANNELS
CAM_PRESET                      = 177   // Button: Cycle Camera Preset
AUTO_FOCUS_ON                   = 162   // Button: setAutoFocusOn
AUTO_IRIS_ON                    = 163   // Button: setAutoIrisOn
*/

/* SNAPI LEVELS
FOCUS_LVL                       = 16    // Level: setFocus
FOCUS_SPEED_LVL                 = 19    // Level: setFocusSpeed
IRIS_LVL                        = 17    // Level: setIris
IRIS_SPEED_LVL                  = 20    // Level: setIrisSpeed
PAN_LVL                         = 27    // Level: setPan
PAN_SPEED_LVL                   = 29    // Level: setPanSpeed
TILT_LVL                        = 28    // Level: setTilt
TILT_SPEED_LVL                  = 30    // Level: setTiltSpeed
ZOOM_LVL                        = 15    // Level: setZoom
ZOOM_SPEED_LVL                  = 18    // Level: setZoomSpeed
*/

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT


(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE


(***********************************************************)
(*              DATA TYPE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_TYPE


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

integer nZOOM_SPEED_LVL[MAX_ZONE] // Stores level values for ZOOM_SPEED_LVL
integer nZOOM_LVL[MAX_ZONE] // Stores level values for ZOOM_LVL
integer nTILT_SPEED_LVL[MAX_ZONE] // Stores level values for TILT_SPEED_LVL
integer nTILT_LVL[MAX_ZONE] // Stores level values for TILT_LVL
integer nPAN_SPEED_LVL[MAX_ZONE] // Stores level values for PAN_SPEED_LVL
integer nFOCUS_LVL[MAX_ZONE] // Stores level values for BTN_FOCUS_LVL_RELEASE
integer nIRIS_SPEED_LVL[MAX_ZONE] // Stores level values for IRIS_SPEED_LVL
integer nIRIS_LVL[MAX_ZONE] // Stores level values for BTN_IRIS_LVL_RELEASE
integer nFOCUS_SPEED_LVL[MAX_ZONE] // Stores level values for FOCUS_SPEED_LVL
integer nPAN_LVL[MAX_ZONE] // Stores level values for PAN_LVL

VOLATILE INTEGER bBTN_CAM_PRESET_SAVE = 0


//---------------------------------------------------------------------------------
//
// FUNCTION NAME:    OnDeviceChanged
//
// PURPOSE:          This function is used by the device selection BUTTON_EVENT
//                   to notify the module that a device change has occurred
//                   allowing updates to the touch panel user interface.
//
//---------------------------------------------------------------------------------
DEFINE_FUNCTION OnDeviceChanged()
{

    println ("'OnDeviceChanged'")
}

//---------------------------------------------------------------------------------
//
// FUNCTION NAME:    OnPageChanged
//
// PURPOSE:          This function is used by the page selection BUTTON_EVENT
//                   to notify the module that a component change may have occurred
//                   allowing updates to the touch panel user interface.
//
//---------------------------------------------------------------------------------
DEFINE_FUNCTION OnPageChanged()
{

    println ("'OnPageChanged'")
}

//---------------------------------------------------------------------------------
//
// FUNCTION NAME:    OnZoneChange
//
// PURPOSE:          This function is used by the zone selection BUTTON_EVENT
//                   to notify the module that a zone change has occurred
//                   allowing updates to the touch panel user interface.
//
//---------------------------------------------------------------------------------
DEFINE_FUNCTION OnZoneChange()
{

    send_level dvTP, TILT_LVL, nTILT_LVL[nCurrentZone]
    send_level dvTP, TILT_SPEED_LVL, nTILT_SPEED_LVL[nCurrentZone]
    send_level dvTP, ZOOM_LVL, nZOOM_LVL[nCurrentZone]
    send_level dvTP, PAN_SPEED_LVL, nPAN_SPEED_LVL[nCurrentZone]
    send_level dvTP, ZOOM_SPEED_LVL, nZOOM_SPEED_LVL[nCurrentZone]
    send_level dvTP, IRIS_SPEED_LVL, nIRIS_SPEED_LVL[nCurrentZone]
    send_level dvTP, IRIS_LVL, nIRIS_LVL[nCurrentZone]
    send_level dvTP, FOCUS_SPEED_LVL, nFOCUS_SPEED_LVL[nCurrentZone]
    send_level dvTP, FOCUS_LVL, nFOCUS_LVL[nCurrentZone]
    send_level dvTP, PAN_LVL, nPAN_LVL[nCurrentZone]

    println ("'OnZoneChange'")
}

DEFINE_MUTUALLY_EXCLUSIVE
([dvTp,BTN_CAM_PRESET[1]]..[dvTp,BTN_CAM_PRESET[LENGTH_ARRAY(BTN_CAM_PRESET)]])


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

strCompName = 'CameraComponent'



(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT


(***********************************************************)
(*             TOUCHPANEL EVENTS GO BELOW                  *)
(***********************************************************)
DATA_EVENT [dvTP]
{

    ONLINE:
    {
        bActiveComponent = FALSE
        nActiveDevice = 1
        nActivePage = 0
        nActiveDeviceID = nNavigationBtns[1]
        nActivePageID = 0
        nCurrentZone = 1
        bNoLevelReset = 0
	OnZoneChange()
    }
    OFFLINE:
    {
        bNoLevelReset = 1
    }

}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       DATA_EVENT for vdvDev
//                   CameraComponent: data event 
//
// PURPOSE:          This data event is used to listen for SNAPI component
//                   commands and track feedback for the CameraComponent.
//
// LOCAL VARIABLES:  cHeader     :  SNAPI command header
//                   cParameter  :  SNAPI command parameter
//                   nParameter  :  SNAPI command parameter value
//                   cCmd        :  received SNAPI command
//
//---------------------------------------------------------------------------------
DATA_EVENT[vdvDev]
{
    COMMAND :
    {
        // local variables
        STACK_VAR CHAR    cCmd[DUET_MAX_CMD_LEN]
        STACK_VAR CHAR    cHeader[DUET_MAX_HDR_LEN]
        STACK_VAR CHAR    cParameter[DUET_MAX_PARAM_LEN]
        STACK_VAR INTEGER nParameter
        STACK_VAR CHAR    cTrash[20]
        STACK_VAR INTEGER nZone
        
        nZone = getFeedbackZone(data.device)
        
        // get received SNAPI command
        cCmd = DATA.TEXT
        
        // parse command header
        cHeader = DuetParseCmdHeader(cCmd)
        SWITCH (cHeader)
        {
            // SNAPI::DEBUG-<state>
            CASE 'DEBUG' :
            {
                // This will toggle debug printing
                nDbg = ATOI(DuetParseCmdParam(cCmd))
            }

        }
    }
}


//----------------------------------------------------------
// CHANNEL_EVENTs For CameraComponent
//
// The following channel events are used in conjunction
// with the CameraComponent code-block.
//----------------------------------------------------------


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - ramping channel
//                   on BTN_IRIS_OPEN
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_IRIS_OPEN]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], IRIS_OPEN]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(IRIS_OPEN),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], IRIS_OPEN]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(IRIS_OPEN),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: momentary button - momentary channel
//                   on BTN_AUTO_FOCUS
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_AUTO_FOCUS]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], AUTO_FOCUS]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(AUTO_FOCUS),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - ramping channel
//                   on BTN_ZOOM_OUT
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_ZOOM_OUT]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], ZOOM_OUT]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(ZOOM_OUT),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], ZOOM_OUT]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(ZOOM_OUT),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - ramping channel
//                   on BTN_ZOOM_IN
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_ZOOM_IN]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], ZOOM_IN]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(ZOOM_IN),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], ZOOM_IN]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(ZOOM_IN),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - ramping channel
//                   on BTN_TILT_UP
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TILT_UP]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], TILT_UP]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TILT_UP),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], TILT_UP]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TILT_UP),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - ramping channel
//                   on BTN_TILT_DN
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TILT_DN]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], TILT_DN]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TILT_DN),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], TILT_DN]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TILT_DN),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - ramping channel
//                   on BTN_PAN_LT
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_PAN_LT]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], PAN_LT]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(PAN_LT),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], PAN_LT]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(PAN_LT),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - ramping channel
//                   on BTN_PAN_RT
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_PAN_RT]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], PAN_RT]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(PAN_RT),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], PAN_RT]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(PAN_RT),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - level
//                   on BTN_FOCUS_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_FOCUS_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], FOCUS_LVL, nFOCUS_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(FOCUS_LVL),', ',itoa(nFOCUS_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - level
//                   on BTN_IRIS_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_IRIS_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], IRIS_LVL, nIRIS_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(IRIS_LVL),', ',itoa(nIRIS_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - ramping channel
//                   on BTN_IRIS_CLOSE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_IRIS_CLOSE]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], IRIS_CLOSE]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(IRIS_CLOSE),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], IRIS_CLOSE]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(IRIS_CLOSE),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - ramping channel
//                   on BTN_FOCUS_NEAR
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_FOCUS_NEAR]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], FOCUS_NEAR]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(FOCUS_NEAR),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], FOCUS_NEAR]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(FOCUS_NEAR),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - ramping channel
//                   on BTN_FOCUS_FAR
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_FOCUS_FAR]
{
    push:
    {
        if (bActiveComponent)
        {
            on[vdvDev[nCurrentZone], FOCUS_FAR]
            println (" 'on[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(FOCUS_FAR),']'")
        }
    }
    release:
    {
        if (bActiveComponent)
        {
            off[vdvDev[nCurrentZone], FOCUS_FAR]
            println (" 'off[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(FOCUS_FAR),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - discrete channel
//                   on AUTO_IRIS_ON
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, AUTO_IRIS_ON]
{
    push:
    {
        if (bActiveComponent)
        {
            [vdvDev[nCurrentZone],AUTO_IRIS_ON] = ![vdvDev[nCurrentZone],AUTO_IRIS_ON]
            println (" '[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(AUTO_IRIS_ON),'] = ![',dpstoa(vdvDev[nCurrentZone]),', ',itoa(AUTO_IRIS_ON),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - discrete channel
//                   on AUTO_FOCUS_ON
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, AUTO_FOCUS_ON]
{
    push:
    {
        if (bActiveComponent)
        {
            [vdvDev[nCurrentZone],AUTO_FOCUS_ON] = ![vdvDev[nCurrentZone],AUTO_FOCUS_ON]
            println (" '[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(AUTO_FOCUS_ON),'] = ![',dpstoa(vdvDev[nCurrentZone]),', ',itoa(AUTO_FOCUS_ON),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - command
//                   on BTN_QUERY_CAMERA_PRESET
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_QUERY_CAMERA_PRESET]
{
    push:
    {
        if (bActiveComponent)
        {
            send_command vdvDev[nCurrentZone], '?CAMERAPRESET'
            println ("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'?CAMERAPRESET',39")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: momentary button - momentary channel
//                   on CAM_PRESET
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, CAM_PRESET]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], CAM_PRESET]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(CAM_PRESET),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: momentary button - momentary channel
//                   on BTN_AUTO_IRIS
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_AUTO_IRIS]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], AUTO_IRIS]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(AUTO_IRIS),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - level
//                   on BTN_ZOOM_SPEED_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_ZOOM_SPEED_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], ZOOM_SPEED_LVL, nZOOM_SPEED_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(ZOOM_SPEED_LVL),', ',itoa(nZOOM_SPEED_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - level
//                   on BTN_FOCUS_SPEED_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_FOCUS_SPEED_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], FOCUS_SPEED_LVL, nFOCUS_SPEED_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(FOCUS_SPEED_LVL),', ',itoa(nFOCUS_SPEED_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - level
//                   on BTN_IRIS_SPEED_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_IRIS_SPEED_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], IRIS_SPEED_LVL, nIRIS_SPEED_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(IRIS_SPEED_LVL),', ',itoa(nIRIS_SPEED_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - level
//                   on BTN_PAN_SPEED_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_PAN_SPEED_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], PAN_SPEED_LVL, nPAN_SPEED_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(PAN_SPEED_LVL),', ',itoa(nPAN_SPEED_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - level
//                   on BTN_TILT_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TILT_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], TILT_LVL, nTILT_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TILT_LVL),', ',itoa(nTILT_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - level
//                   on BTN_TILT_SPEED_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_TILT_SPEED_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], TILT_SPEED_LVL, nTILT_SPEED_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(TILT_SPEED_LVL),', ',itoa(nTILT_SPEED_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - level
//                   on BTN_PAN_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_PAN_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], PAN_LVL, nPAN_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(PAN_LVL),', ',itoa(nPAN_LVL[nCurrentZone])")
            }
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - level
//                   on BTN_ZOOM_LVL_RELEASE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the CameraComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_ZOOM_LVL_RELEASE]
{
    release:
    {
        if (bActiveComponent)
        {
            if (!bNoLevelReset)
            {
                send_level vdvDev[nCurrentZone], ZOOM_LVL, nZOOM_LVL[nCurrentZone]
                println (" 'send_level ',dpstoa(vdvDev[nCurrentZone]),', ',itoa(ZOOM_LVL),', ',itoa(nZOOM_LVL[nCurrentZone])")
            }
        }
    }
}


//----------------------------------------------------------
// LEVEL_EVENTs For CameraComponent
//
// The following level events are used in conjunction
// with the CameraComponent code-block.
//----------------------------------------------------------


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   CameraComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the CameraComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, ZOOM_SPEED_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nZOOM_SPEED_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   CameraComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the CameraComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, ZOOM_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nZOOM_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   CameraComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the CameraComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, TILT_SPEED_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nTILT_SPEED_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   CameraComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the CameraComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, TILT_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nTILT_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   CameraComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the CameraComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, PAN_SPEED_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nPAN_SPEED_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   CameraComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the CameraComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, IRIS_SPEED_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nIRIS_SPEED_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   CameraComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the CameraComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, IRIS_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nIRIS_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   CameraComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the CameraComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, FOCUS_SPEED_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nFOCUS_SPEED_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   CameraComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the CameraComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, FOCUS_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nFOCUS_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for dvTP
//                   CameraComponent: level event for dvTP
//
// PURPOSE:          This level event is used to listen for touch panel changes 
//                   and update the CameraComponent
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[dvTP, PAN_LVL]
{
    if (bActiveComponent)
    {
        if (!bNoLevelReset)
        {
            nPAN_LVL[nCurrentZone] = Level.value
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   CameraComponent: level event for CameraComponent
//
// PURPOSE:          This level event is used to listen for SNAPI CameraComponent changes
//                   on the CameraComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, TILT_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nTILT_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, TILT_LVL, nTILT_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(TILT_LVL),', ',itoa(nTILT_LVL[nCurrentZone])")
        }
    }
}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   CameraComponent: level event for CameraComponent
//
// PURPOSE:          This level event is used to listen for SNAPI CameraComponent changes
//                   on the CameraComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, TILT_SPEED_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nTILT_SPEED_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, TILT_SPEED_LVL, nTILT_SPEED_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(TILT_SPEED_LVL),', ',itoa(nTILT_SPEED_LVL[nCurrentZone])")
        }
    }
}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   CameraComponent: level event for CameraComponent
//
// PURPOSE:          This level event is used to listen for SNAPI CameraComponent changes
//                   on the CameraComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, ZOOM_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nZOOM_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, ZOOM_LVL, nZOOM_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(ZOOM_LVL),', ',itoa(nZOOM_LVL[nCurrentZone])")
        }
    }
}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   CameraComponent: level event for CameraComponent
//
// PURPOSE:          This level event is used to listen for SNAPI CameraComponent changes
//                   on the CameraComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, PAN_SPEED_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nPAN_SPEED_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, PAN_SPEED_LVL, nPAN_SPEED_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(PAN_SPEED_LVL),', ',itoa(nPAN_SPEED_LVL[nCurrentZone])")
        }
    }
}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   CameraComponent: level event for CameraComponent
//
// PURPOSE:          This level event is used to listen for SNAPI CameraComponent changes
//                   on the CameraComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, ZOOM_SPEED_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nZOOM_SPEED_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, ZOOM_SPEED_LVL, nZOOM_SPEED_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(ZOOM_SPEED_LVL),', ',itoa(nZOOM_SPEED_LVL[nCurrentZone])")
        }
    }
}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   CameraComponent: level event for CameraComponent
//
// PURPOSE:          This level event is used to listen for SNAPI CameraComponent changes
//                   on the CameraComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, IRIS_SPEED_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nIRIS_SPEED_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, IRIS_SPEED_LVL, nIRIS_SPEED_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(IRIS_SPEED_LVL),', ',itoa(nIRIS_SPEED_LVL[nCurrentZone])")
        }
    }
}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   CameraComponent: level event for CameraComponent
//
// PURPOSE:          This level event is used to listen for SNAPI CameraComponent changes
//                   on the CameraComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, IRIS_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nIRIS_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, IRIS_LVL, nIRIS_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(IRIS_LVL),', ',itoa(nIRIS_LVL[nCurrentZone])")
        }
    }
}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   CameraComponent: level event for CameraComponent
//
// PURPOSE:          This level event is used to listen for SNAPI CameraComponent changes
//                   on the CameraComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, FOCUS_SPEED_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nFOCUS_SPEED_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, FOCUS_SPEED_LVL, nFOCUS_SPEED_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(FOCUS_SPEED_LVL),', ',itoa(nFOCUS_SPEED_LVL[nCurrentZone])")
        }
    }
}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   CameraComponent: level event for CameraComponent
//
// PURPOSE:          This level event is used to listen for SNAPI CameraComponent changes
//                   on the CameraComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, FOCUS_LVL]
{
    if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
        
        nFOCUS_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, FOCUS_LVL, nFOCUS_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(FOCUS_LVL),', ',itoa(nFOCUS_LVL[nCurrentZone])")
        }
    }
}


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       LEVEL_EVENT for vdvDev
//                   CameraComponent: level event for CameraComponent
//
// PURPOSE:          This level event is used to listen for SNAPI CameraComponent changes
//                   on the CameraComponent and update the touch panel user
//                   interface feedback.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
LEVEL_EVENT[vdvDev, PAN_LVL]
{
   if (!bNoLevelReset)
    {
        stack_var integer zone
        zone = getFeedbackZone(Level.input.device)
	
        nPAN_LVL[zone] = level.value
        if (zone == nCurrentZone)
        {
            send_level dvTP, PAN_LVL, nPAN_LVL[nCurrentZone]
            println (" 'send_level ',dpstoa(dvTP),', ',itoa(PAN_LVL),', ',itoa(nPAN_LVL[nCurrentZone])")
        }
    }
}



//----------------------------------------------------------
// EXTENDED EVENTS For CameraComponent
//
// The following events are used in conjunction
// with the CameraComponent code-block.
//----------------------------------------------------------


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel range button - command
//                   on BTN_CAM_PRESET
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the .
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
button_event[dvTP, BTN_CAM_PRESET]
{
    push:
    {
        if (bActiveComponent)
		{
			stack_var integer btn
			btn = get_last(BTN_CAM_PRESET)
			
			IF (bBTN_CAM_PRESET_SAVE = TRUE)
			{
				send_command vdvDev[nCurrentZone], "'CAMERAPRESETSAVE-',itoa(btn)"
				println("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'CAMERAPRESETSAVE-',itoa(btn),39")
				
				// reset the button state
				bBTN_CAM_PRESET_SAVE = FALSE
				[dvTP, BTN_CAM_PRESET_SAVE] = bBTN_CAM_PRESET_SAVE
			}
			ELSE
			{
				send_command vdvDev[nCurrentZone], "'CAMERAPRESET-',itoa(btn)"
				println("'send_command ',dpstoa(vdvDev[nCurrentZone]),', ',39,'CAMERAPRESET-',itoa(btn),39")
			}
		}
    }
}
//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   CameraComponent: channel button - command
//                   on BTN_CAM_PRESET_SAVE
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the .
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
button_event[dvTP, BTN_CAM_PRESET_SAVE]
{
    push:
    {
        if (bActiveComponent)
		{
			bBTN_CAM_PRESET_SAVE = !(bBTN_CAM_PRESET_SAVE)
			[dvTP, BTN_CAM_PRESET_SAVE] = bBTN_CAM_PRESET_SAVE
		}
    }
}


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvTP,AUTO_FOCUS_ON] = [vdvDev[nCurrentZone],AUTO_FOCUS_FB]
[dvTP,BTN_TILT_UP] = [vdvDev[nCurrentZone],TILT_UP_FB]
[dvTP,BTN_TILT_DN] = [vdvDev[nCurrentZone],TILT_DN_FB]
[dvTP,BTN_ZOOM_OUT] = [vdvDev[nCurrentZone],ZOOM_OUT_FB]
[dvTP,BTN_IRIS_CLOSE] = [vdvDev[nCurrentZone],IRIS_CLOSE_FB]
[dvTP,BTN_ZOOM_IN] = [vdvDev[nCurrentZone],ZOOM_IN_FB]
[dvTP,BTN_PAN_LT] = [vdvDev[nCurrentZone],PAN_LT_FB]
[dvTP,BTN_PAN_RT] = [vdvDev[nCurrentZone],PAN_RT_FB]
[dvTP,AUTO_IRIS_ON] = [vdvDev[nCurrentZone],AUTO_IRIS_FB]
[dvTP,BTN_IRIS_OPEN] = [vdvDev[nCurrentZone],IRIS_OPEN_FB]
[dvTP,BTN_FOCUS_NEAR] = [vdvDev[nCurrentZone],FOCUS_NEAR_FB]
[dvTP,BTN_FOCUS_FAR] = [vdvDev[nCurrentZone],FOCUS_FAR_FB]

wait 10
{
    if (bBTN_CAM_PRESET_SAVE)
    {
		// blink the button
		[dvTP, BTN_CAM_PRESET_SAVE] = ![dvTP, BTN_CAM_PRESET_SAVE]
    }
}

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

