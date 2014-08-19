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
PROGRAM_NAME = 'Polycom EagleEye Main' 
(***********************************************************)
(* System Type : NetLinx                                   *)
(* Creation Date: 6/4/2007 2:36:22 PM                    *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvTPMain = 10012:1:0 // This should be the touch panel's main port

vdvCamera = 41001:1:0  // The COMM module should use this as its duet device
dvCamera = 5001:3:0 // This device should be used as the physical device by the COMM module
dvCameraTp = 10012:17:0 // This port should match the assigned touch panel device port

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT


(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

DEV vdvDev[] = {vdvCamera}

// ----------------------------------------------------------
// CURRENT DEVICE NUMBER ON TP NAVIGATION BAR
INTEGER nCamera = 1

// ----------------------------------------------------------
// DEFINE THE PAGES THAT YOUR COMPONENTS ARE USING IN THE 
// SUB NAVIGATION BAR HERE
INTEGER nCameraPages[] = { 1,2,3 }
INTEGER nPowerPages[] = { 4 }
INTEGER nModulePages[] = { 5 }


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START


// ----------------------------------------------------------
// DEVICE MODULE GROUPS SHOULD ALL HAVE THE SAME DEVICE NUMBER
DEFINE_MODULE 'Polycom EagleEye CameraComponent' camera(vdvDev, dvCameraTp, dvTPMain, nCamera, nCameraPages)
DEFINE_MODULE 'Polycom EagleEye ModuleComponent' module(vdvDev, dvCameraTp, dvTPMain, nCamera, nModulePages)
DEFINE_MODULE 'Polycom EagleEye PowerComponent' power(vdvDev, dvCameraTp, dvTPMain, nCamera, nPowerPages)


// Define your communications module here like so:
DEFINE_MODULE 'Polycom_EagleEye_Comm_dr1_0_0' comm(vdvCamera, dvCamera)

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

