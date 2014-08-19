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
MODULE_NAME = 'Polycom EagleEye PowerComponent' (dev vdvDev[], dev dvTP, dev dvTPMain, INTEGER nDevice, INTEGER nPages[])
(***********************************************************)
(* System Type : NetLinx                                   *)
(* Creation Date: 6/18/2007 3:15:55 PM                    *)
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
BTN_PWR_OFF_FB                  = 28    // Button: Power
BTN_PWR_ON_FB                   = 27    // Button: Power
POWER_ON_FB                     = 255   // Button: Power

// Levels

// Variable Text Addresses

/* G4 CHANNELS
BTN_POWER                       = 9     // Button: Power Toggle
*/

/* SNAPI CHANNELS
POWER_ON                        = 255   // Button: Power Set
PWR_OFF                         = 28    // Button: setPower
PWR_ON                          = 27    // Button: setPower
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


    println ("'OnZoneChange'")
}

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

strCompName = 'PowerComponent'
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
//                   PowerComponent: data event 
//
// PURPOSE:          This data event is used to listen for SNAPI component
//                   commands and track feedback for the PowerComponent.
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
// CHANNEL_EVENTs For PowerComponent
//
// The following channel events are used in conjunction
// with the PowerComponent code-block.
//----------------------------------------------------------


//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PowerComponent: momentary button - momentary channel
//                   on PWR_ON
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PowerComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, PWR_ON]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], PWR_ON]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(PWR_ON),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PowerComponent: momentary button - momentary channel
//                   on PWR_OFF
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PowerComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, PWR_OFF]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], PWR_OFF]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(PWR_OFF),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PowerComponent: channel button - discrete channel
//                   on POWER_ON
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PowerComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, POWER_ON]
{
    push:
    {
        if (bActiveComponent)
        {
            [vdvDev[nCurrentZone],POWER_ON] = ![vdvDev[nCurrentZone],POWER_ON]
            println (" '[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(POWER_ON),'] = ![',dpstoa(vdvDev[nCurrentZone]),', ',itoa(POWER_ON),']'")
        }
    }
}

//---------------------------------------------------------------------------------
//
// EVENT TYPE:       BUTTON_EVENT for dvTP
//                   PowerComponent: momentary button - momentary channel
//                   on BTN_POWER
//
// PURPOSE:          This button event is used to listen for input 
//                   on the touch panel and update the PowerComponent.
//
// LOCAL VARIABLES:  {none}
//
//---------------------------------------------------------------------------------
BUTTON_EVENT[dvTP, BTN_POWER]
{
    push:
    {
        if (bActiveComponent)
        {
            pulse[vdvDev[nCurrentZone], POWER]
            println (" 'pulse[',dpstoa(vdvDev[nCurrentZone]),', ',itoa(POWER),']'")
        }
    }
}


(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

[dvTP,POWER_ON_FB] = [vdvDev[nCurrentZone],POWER_FB]
[dvTP,BTN_PWR_ON_FB] = [vdvDev[nCurrentZone],POWER_FB]
[dvTP,BTN_PWR_OFF_FB] = ![vdvDev[nCurrentZone],POWER_FB]

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

