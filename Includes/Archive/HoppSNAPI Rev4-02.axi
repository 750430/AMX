PROGRAM_NAME='HoppSNAPI Rev4-02'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 11/19/2008  AT: 14:49:55        *)
(***********************************************************)
(*{{PS_SOURCE_INFO(PROGRAM STATS)                          *)
(***********************************************************)
(*  ORPHAN_FILE_PLATFORM: 0                                *)
(***********************************************************)
(*}}PS_SOURCE_INFO                                         *)
(***********************************************************)

DEFINE_TYPE


(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

(***********************************************************)
(*                     Device Channels                     *)
(***********************************************************)

// Video Display Channels
VD_PWR_ON      		=	1  	//Momentary: Set lamp power on
VD_PWR_OFF     		=	2  	//Momentary: Set lamp power off
VD_PWR_TOG			=	3 	//Toggle: Power On/Off
VD_SRC_VGA1			=	4	//Momentary: VGA 1 source select
VD_SRC_VGA2			=	5	//Momentary: VGA 2 source select
VD_SRC_VGA3			=	6	//Momentary: VGA 3 source select
VD_SRC_DVI1			=	7	//Momentary: DVI 1 source select
VD_SRC_DVI2			=	8	//Momentary: DVI 2 source select
VD_SRC_DVI3			=	9	//Momentary: DVI 3 source select
VD_SRC_RGB1 		=	10  //Momentary: RGB 1 source select
VD_SRC_RGB2			=	11  //Momentary: RGB 2 source select
VD_SRC_RGB3			=	12  //Momentary: RGB 3 source select
VD_SRC_VID1	   		=	13  //Momentary: Composite Video source select
VD_SRC_VID2			=	14	//Momentary: Composite Video 2 source select
VD_SRC_SVID			=	15  //Momentary: S-Video source select
VD_SRC_CMPNT1		=	16  //Momentary: Component Video source select
VD_SRC_CMPNT2		=	17	//Momentary: Component Video 2 source select
VD_SRC_AUX1    		=	18  //Momentary: Aux 1 source select
VD_SRC_AUX2			=	19 	//Momentary: Aux 2 source select
VD_SRC_AUX3			=	20 	//Momentary: Aux 3 source select
VD_SRC_AUX4			=	21 	//Momentary: Aux 4 source select
VD_SRC_AUX5			=	22	//Momentary: Aux 5 source select
VD_ASPECT1     		=	23 	//Momentary: Aspect Ratio 1
VD_ASPECT2     		=	24 	//Momentary: Aspect Ratio 2
VD_ASPECT3     		=	25 	//Momentary: Aspect Ratio 3
VD_ASPECT4     		=	26 	//Momentary: Aspect Ratio 4
VD_ASPECT5     		=	27 	//Momentary: Aspect Ratio 5
VD_ASPECT6     		=	28 	//Momentary: Aspect Ratio 6
VD_ASPECT7     		=	29 	//Momentary: Aspect Ratio 7
VD_ASPECT8     		=	30 	//Momentary: Aspect Ratio 8
VD_MUTE_TOG    		=	31 	//Toggle: Video Mute On/Off
VD_MUTE_ON			=	32 	//Momentary: Video Mute On
VD_MUTE_OFF    		=	33 	//Momentary: Video Mute Off
VD_PCADJ			=	34 	//Momentary: Image adjust
VD_ZOOM_IN			=	35 	//Ramping: Zoom In
VD_ZOOM_OUT			=	36 	//Ramping: Zoom Out
VD_LENS_UP			=	37 	//Ramping: Lens Shift Up
VD_LENS_DN			=	38 	//Ramping: Lens Shift Down
VD_SRC_VGA1_ADJ		=	39	//Momentary: VGA1 w/PC Adjust
VD_SRC_VGA2_ADJ		=	40	//Momentary: VGA2 w/PC Adjust
VD_SRC_VGA3_ADJ		=	41	//Momentary: VGA3 w/PC Adjust
VD_SRC_DVI1_ADJ		=	42	//Momentary: DVI1 w/PC Adjust
VD_SRC_DVI2_ADJ		=	43	//Momentary: DVI2 w/PC Adjust
VD_SRC_DVI3_ADJ		=	44	//Momentary: DVI3 w/PC Adjust
VD_SRC_RGB1_ADJ		=	45	//Momentary: RGB1 w/PC Adjust
VD_SRC_RGB2_ADJ		=	46	//Momentary: RGB2 w/PC Adjust
VD_SRC_RGB3_ADJ		=	47	//Momentary: RGB3 w/PC Adjust
VD_SPLIT_SCREEN		=	48	//Momentary: Change display to Split Screens
VD_SINGLE_SCREEN	=	49	//Momentary: Change display back to Single Screen
VD_COOLING			=	50
VD_WARMING			=	51
VD_VOL_UP			=	52
VD_VOL_DOWN			=	53
VD_VOL_MUTE			=	54
VD_VOL_MUTE_ON		=	55
VD_VOL_MUTE_OFF		=	56

VD_POLL_BEGIN		=	200	//Momentary: Start Polling


VD_ASPECT1_FB		=	256	//Feedback: aspect1
VD_ASPECT2_FB		=	257	//Feedback: aspect2
VD_ASPECT3_FB		=	258	//Feedback: aspect3
VD_ASPECT4_FB		=	259	//Feedback: aspect4
VD_ASPECT5_FB		=	260	//Feedback: aspect5
VD_ASPECT6_FB		=	261	//Feedback: aspect6
VD_ASPECT7_FB		=	262	//Feedback: aspect7
VD_ASPECT8_FB		=	263	//Feedback: aspect8
VD_PWR_ON_FB		=	264	//Feedback: power on
VD_PWR_OFF_FB 		=	265	//Feedback: power off
VD_WARMING_FB		=	266	//Feedback: warming up
VD_COOLING_FB		=	267	//Feedback: cooling down
VD_ERROR_FB			=	268	//Feedback: power error
VD_OTHER_FB 		=	269	//Feedback: user specified
VD_SRC_RGB1_FB 		=	270	//Feedback: rgb1 input
VD_SRC_RGB2_FB		=	271	//Feedback: rgb2 input
VD_SRC_RGB3_FB		=	272	//Feedback: rgb3 or dvi input
VD_SRC_VGA1_FB		=	273	//Feedback: vga1 input
VD_SRC_VGA2_FB		=	274	//Feedback: vga2 input
VD_SRC_VGA3_FB		=	275	//Feedback: vga3 input
VD_SRC_DVI1_FB		=	276	//Feedback: dvi1 input
VD_SRC_DVI2_FB		=	277	//Feedback: dvi2 input
VD_SRC_DVI3_FB		=	278	//Feedback: dvi3 input
VD_SRC_VID1_FB	    =	279	//Feedback: video input
VD_SRC_VID2_FB		=	280	//Feedback: video 2 input
VD_SRC_SVID_FB		=	281	//Feedback: svideo input
VD_SRC_CMPNT1_FB	=	282	//Feedback: component input 
VD_SRC_CMPNT2_FB	=	283	//Feedback: component 2 input
VD_SRC_AUX1_FB  	=	284	//Feedback: user specified
VD_SRC_AUX2_FB		=	285	//Feedback: user specified
VD_SRC_AUX3_FB		=	286	//Feedback: user specified
VD_SRC_AUX4_FB		=	287	//Feedback: user specified
VD_SRC_AUX5_FB		=	288	//Feedback: user specified
VD_MUTE_ON_FB 		=	289	//Feedback: display mute on
VD_MUTE_OFF_FB		=	290	//Feedback: display mute off
VD_VOL_MUTE_ON_FB	=	291
VD_VOL_MUTE_OFF_FB	=	292

//ATC Channels
ATC_DIGIT_0			=	10  // Momentary: Press menu button digit 0
ATC_DIGIT_1			=	11  // Momentary: Press menu button digit 1
ATC_DIGIT_2			=	12  // Momentary: Press menu button digit 2
ATC_DIGIT_3			=	13  // Momentary: Press menu button digit 3
ATC_DIGIT_4			=	14  // Momentary: Press menu button digit 4
ATC_DIGIT_5			=	15  // Momentary: Press menu button digit 5
ATC_DIGIT_6			=	16  // Momentary: Press menu button digit 6
ATC_DIGIT_7			=	17 	// Momentary: Press menu button digit 7
ATC_DIGIT_8			=	18  // Momentary: Press menu button digit 8
ATC_DIGIT_9			=	19  // Momentary: Press menu button digit 9
ATC_STAR_KEY		=	20 	// Momentary: Press menu button *
ATC_POUND_KEY		=	21 	// Momentary: Press menu button #
ATC_PAUSE			=	22 	// Momentary: Press menu button ,
ATC_CLEAR			=	23 	// Momentary: clear readout
ATC_BACKSPACE		=	24 	// Momentary: remove digit from readout
ATC_ANSWER			=	25 	// Momentary: pick up line
ATC_HANGUP			=	26 	// Momentary: disconnect line
ATC_PRIVACY_TOG		=	27 	// Toggle: privacy on/off
ATC_PRIVACY_ON		=	28 	// Momentary: Press privacy on
ATC_PRIVACY_OFF		=	29 	// Momentary: Press privacy off
ATC_QUERY			=	30 	// Momentary: get hook status
ATC_DIAL			=	31	// Momentary: dial number
ATC_FLASH			=	32	// Momentary: flash hook
ATC_SPEEDDIAL1		=	33
ATC_SPEEDDIAL2		=	34
ATC_SPEEDDIAL3		=	35
ATC_SPEEDDIAL4		=	36
ATC_SPEEDDIAL5		=	37
ATC_SPEEDDIAL6		=	38
ATC_SPEEDDIAL7		=	39
ATC_SPEEDDIAL8		=	40


ATC_ON_HOOK_FB		=	256 // Feedback: on hook
ATC_OFF_HOOK_FB		=	257 // Feedback: off hook
ATC_PRIVACY_ON_FB 	=	258 // Feedback: privacy on
ATC_PRIVACY_OFF_FB	=	259 // Feedback: privacy off
ATC_RINGING_FB		=	260	// Feedback: telco line ringing

//VTC Channels
VTC_KEY_0				=	10
VTC_KEY_1				=	11
VTC_KEY_2				=	12
VTC_KEY_3				=	13
VTC_KEY_4				=	14
VTC_KEY_5				=	15
VTC_KEY_6				=	16
VTC_KEY_7				=	17
VTC_KEY_8				=	18
VTC_KEY_9				=	19
VTC_KEY_STAR			=	20
VTC_KEY_POUND			=	21
VTC_KEY_KEYBRD			=	22
VTC_KEY_PERIOD			=	23
VTC_DELETE				=	24
VTC_CONNECT				=	25
VTC_DISCONNECT			=	26
VTC_CALLHANGUP			=	27
VTC_PIP					=	28
VTC_ADDRESSBOOK			=	29
VTC_PRIVACY_TOG			=	30
VTC_PRIVACY_ON			=	31
VTC_PRIVACY_OFF 		=	32
VTC_PIP_TOG				=	33
VTC_PIP_ON				=	34
VTC_PIP_OFF				=	35
VTC_WAKE				=	36
VTC_MENU				=	37
VTC_UP					=	38
VTC_DOWN				=	39
VTC_LEFT				=	40
VTC_RIGHT				=	41
VTC_CANCEL				=	42
VTC_OK					=	43
VTC_ZOOM_IN				=	44
VTC_ZOOM_OUT			=	45
VTC_CAM_UP				=	46
VTC_CAM_DOWN			=	47
VTC_CAM_LEFT			=	48
VTC_CAM_RIGHT			=	49
VTC_CAM_PRESET1			=	50
VTC_CAM_PRESET2			=	51
VTC_CAM_PRESET3			=	52
VTC_CAM_PRESET4			=	53
VTC_CAM_PRESET5			=	54
VTC_CAM_PRESET6			=	55
VTC_CAM_STORE1			=	56
VTC_CAM_STORE2			=	57
VTC_CAM_STORE3			=	58
VTC_CAM_STORE4			=	59
VTC_CAM_STORE5			=	60
VTC_CAM_STORE6			=	61
VTC_NR_VID1				=	62
VTC_NR_VID2				=	63
VTC_NR_VID3				=	64
VTC_NR_VID4				=	65
VTC_NR_VID5				=	66
integer VTC_NR_VID[]	=	{62,63,64,65,66}
VTC_NEAR				=	67
VTC_FAR					=	68
VTC_SEND_PC				=	69
VTC_STOP_PC				=	70
VTC_INFO				=	71
VTC_GRAPHICS			=	72
VTC_CONTENT_ON			=	73
VTC_CONTENT_OFF     	=	74
VTC_USER1				=	75
VTC_USER2				=	76
VTC_USER3				=	77
VTC_FAR_CAM_UP			=	78
VTC_FAR_CAM_DN		 	=	79
VTC_FAR_CAM_LEFT		=	80
VTC_FAR_CAM_RIGHT		=	81
VTC_FAR_CAM_ZOOM_IN		=	82
VTC_FAR_CAM_ZOOM_OUT	=	83
VTC_FAR_CAM_PRESET1		=	84
VTC_FAR_CAM_PRESET2		=	85
VTC_FAR_CAM_PRESET3		=	86
VTC_FAR_CAM_PRESET4		=	87
VTC_FAR_CAM_PRESET5		=	88
VTC_FAR_CAM_PRESET6		=	89
VTC_FAR_CAM_STORE1		=	90
VTC_FAR_CAM_STORE2		=	91
VTC_FAR_CAM_STORE3		=	92
VTC_FAR_CAM_STORE4		=	93
VTC_FAR_CAM_STORE5		=	94
VTC_FAR_CAM_STORE6		=	95
VTC_SELFVIEW_ON			=	96
VTC_SELFVIEW_OFF		=	97
VTC_SELFVIEW_TOG		=	98
VTC_DUO_VID_1			=	99
VTC_DUO_VID_2			=	100
VTC_DUO_VID_3			=	101
VTC_DUO_VID_4			=	102
VTC_DUO_VID_5			=	103
VTC_DUO_ON				=	104
VTC_DUO_OFF				=	105
VTC_DUO_TOG				=	106
VTC_MON2_43				=	107
VTC_MON2_169			=	108
VTC_MON2_OFF			=	109
VTC_HOME				=	110
VTC_CLEAR				=	111
VTC_F1					=	112
VTC_F2					=	113
VTC_F3					=	114
VTC_F4					=	115
VTC_F5					=	116

VTC_DUO_ON_FB			=	256
VTC_DUO_OFF_FB			=	257
VTC_SELFVIEW_OFF_FB		=	258
VTC_SELFVIEW_ON_FB		=	259
VTC_CONTENT_OFF_FB		=	260
VTC_CONTENT_ON_FB		=	261
VTC_PIP_ON_FB			=	262
VTC_PIP_OFF_FB			=	263
VTC_PRIVACY_ON_FB 		=	264
VTC_PRIVACY_OFF_FB 		=	265
VTC_NR_VID1_FB			=	266
VTC_NR_VID2_FB			=	267
VTC_NR_VID3_FB			=	268
VTC_NR_VID4_FB			=	269
VTC_NR_VID5_FB			=	270
integer VTC_NR_VID_FB[]	=	{266,267,268,269,270}

//Camera Channels
CAM_UP				=	1		//Momentary:
CAM_DOWN			=	2		//Momentary:
CAM_LEFT			=	3		//Momentary:
CAM_RIGHT			=	4		//Momentary:
CAM_PRESET1			=	5		//Momentary:
CAM_PRESET2			=	6		//Momentary:
CAM_PRESET3			=	7		//Momentary:
CAM_PRESET4			=	8		//Momentary:
CAM_PRESET5			=	9		//Momentary:
CAM_PRESET6			=	10		//Momentary:
CAM_STORE1			=	11		//Momentary:
CAM_STORE2			=	12		//Momentary:
CAM_STORE3			=	13		//Momentary:
CAM_STORE4			=	14		//Momentary:
CAM_STORE5			=	15		//Momentary:
CAM_STORE6 			=	16		//Momentary:
CAM_HOME			=	17		//Momentary:
CAM_AUTO			=	18		//Momentary:
CAM_MANUAL			=	19		//Momentary:
CAM_FOCUS_IN		=	20		//Momentary:
CAM_FOCUS_OUT		=	21		//Momentary:
CAM_ZOOM_IN			=	22		//Momentary:
CAM_ZOOM_OUT		=	23		//Momentary:
CAM_PWR_ON			=	24		//Momentary:
CAM_PWR_OFF			=	25		//Momentary:

//Tuner Channels 
TUNER_DIGIT_0		=	10	//Momentary: Press digit 0
TUNER_DIGIT_1		=	11	//Momentary: Press digit 1
TUNER_DIGIT_2		=	12	//Momentary: Press digit 2
TUNER_DIGIT_3		=	13	//Momentary: Press digit 3
TUNER_DIGIT_4		=	14	//Momentary: Press digit 4
TUNER_DIGIT_5		=	15	//Momentary: Press digit 5
TUNER_DIGIT_6		=	16	//Momentary: Press digit 6
TUNER_DIGIT_7		=	17	//Momentary: Press digit 7
TUNER_DIGIT_8		=	18	//Momentary: Press digit 8
TUNER_DIGIT_9		=	19	//Momentary: Press digit 9
TUNER_CHAN_UP		=	20	//Momentary: channel up  
TUNER_CHAN_DN		=	21	//Momentary: channel down
TUNER_CLEAR 		=	22	//Momentary: clear                                      
TUNER_BACK 			=	23	//Momentary: backspace
TUNER_ENTER     	=	24	//Momentary: set channel
TUNER_QUERY     	=	25	//Momentary: get channel
TUNER_DASH			=	26	//Momentary: - for digital
TUNER_PWR_ON		=	27	//Momentary: turn power on	
TUNER_PWR_OFF   	=	28	//Momentary: turn power off
TUNER_PWR_TOG		=	29	//Toggle: power on/off
TUNER_CAPTION_ON	=	30	//Momenary: Captions on
TUNER_CAPTION_OFF 	=	31	//Momentary: Captions off
TUNER_CAPTION_TOG 	=	32	//Toggle: caption on/off
TUNER_OK			=	33
TUNER_EXIT        	=	34
TUNER_GUIDE			=	35
TUNER_MENU			=	36
TUNER_UP			=	37
TUNER_DN      		=	38
TUNER_LEFT			=	39
TUNER_RIGHT			=	40
TUNER_RATIO			=	41
TUNER_ERROR			=	256	//Feedback: channel input error
TUNER_PWR_OFF_FB	=	257	//Feedback: power off status
TUNER_PWR_ON_FB		=	258	//Feedback: power on status

//Mixer Channels
MIX_VOL_UP 			=	1	//Ramping: Vol Up
MIX_VOL_DN 			=	2 	//Ramping: Vol Dn 
MIX_MUTE_TOG 		=	3	//Toggle:  Vol Mute
MIX_QUERY 			=	4	//Momentary: Get Vol/Mute Status
MIX_MUTE_OFF		=	5	//Momentary: Mute off
MIX_MUTE_ON 		=	6	//Momentary: Mute On
MIX_MUTE_ON_FB		=	256	//Feedback: Mute is On
MIX_MUTE_OFF_FB		=	257	//feedback: Mute is Off

//DVD, VCR, DVR
DVR_PLAY			=	1	//Momentary:
DVR_STOP			=	2	//Momentary:
DVR_PAUSE			=	3	//Momentary:
DVR_NEXT			=	4	//Momentary:
DVR_BACK			=	5	//Momentary:
DVR_FWD				=	6	//Momentary:
DVR_REW				=	7	//Momentary:
DVR_PWR_ON			=	8	//Momentary:
DVR_PWR_OFF 		=	9	//Momentary:
DVR_REC				=	10	//Momentary:
DVR_UP 				=	45	//Momentary:
DVR_DN 				=	46	//Momentary:
DVR_LEFT			=	47	//Momentary:
DVR_RIGHT			=	48	//Momentary:
DVR_OK 				=	49	//Momentary:
DVR_DVD 			=	112	//Momentary:
DVR_VCR 			=	113	//Momentary:
DVR_HDD				=	114 //Momentary:
DVR_MiniDV			=	115 //Momentary:
DVR_DISC_MENU 		=	116	//Momentary:
DVR_AUDIO			=	117	//Momentary:
DVR_SETUP			=	118 //Momentary:
DVR_NAVI			=	119	//Momentary:	
DVR_POPUP_MENU		=	120 //Momentary: Popup Menu
DVR_COUNTER_TXT		=	254	//Address: Display counter
DVR_TRACK_TXT		=	255	//Address: Display Track
DVR_REC_ON_FB		=	256	//Feedback: Record Status on
DVR_REC_OFF_FB		=	257	//Feedback: Record Status off

//Preamp
PRE_VOL_UP 			=	1	// Ramping: Vol Up
PRE_VOL_DN 			=	2 	// Ramping: Vol Dn 
PRE_MUTE_TOG 		=	3	// Toggle:  Vol Mute
PRE_MUTE_OFF		=	4	// Momentary: Mute off
PRE_MUTE_ON 		=	5	// Momentary: Mute On

PRE_SRC_DVD 		=	6  	// Momentary: DVD source select
PRE_SRC_DVD2		=	7	// Momentary: DVD2 source select
PRE_SRC_CBL		 	=	8  	// Momentary: Cable source select
PRE_SRC_SAT		 	=	9  	// Momentary: Satellite source select
PRE_SRC_GAME 	   	=	10  	// Momentary: Game System source select
PRE_SRC_TV			=	11	// Momentary: TV source select
PRE_SRC_DVR			=	12  	// Momentary: DVR source select
PRE_SRC_VCR			=	13  // Momentary: VCR source select
PRE_SRC_AUX1    	=	14  // Momentary: Aux 1 source select
PRE_SRC_AUX2		=	15 	// Momentary: Aux 2 source select
PRE_SRC_AUX3		=	16 	// Momentary: Aux 3 source select
PRE_SRC_AUX4		=	17 	// Momentary: Aux 4 source select
PRE_SRC_CD			=	18 	// Momentary: CD source select
PRE_SRC_TAPE        =   19 	// Momentary: Tape source select 
PRE_SRC_PHONO       =   20 	// Momentary: Phono source select
PRE_SRC_XM          =   21 	// Momentary: XM Radio source select
PRE_SRC_SIR         =   22 	// Momentary: Sirius source select
PRE_SRC_FM			=	23
PRE_SRC_AM			=	24
PRE_SRC_LD			=	25	// Momentary: Laserdisc Source Select
PRE_SRC2_DVD 		=	26  // Momentary: DVD source select
PRE_SRC2_DVD2		=	27	// Momentary: DVD2 source select
PRE_SRC2_CBL		=	28  // Momentary: Cable source select
PRE_SRC2_SAT		=	29  // Momentary: Satellite source select
PRE_SRC2_GAME 	   	=	30  // Momentary: Game System source select
PRE_SRC2_TV			=	31	// Momentary: TV source select
PRE_SRC2_DVR		=	32  // Momentary: DVR source select
PRE_SRC2_VCR		=	33  // Momentary: VCR source select
PRE_SRC2_AUX1    	=	34  // Momentary: Aux 1 source select
PRE_SRC2_AUX2		=	35 	// Momentary: Aux 2 source select
PRE_SRC2_AUX3		=	36 	// Momentary: Aux 3 source select
PRE_SRC2_AUX4		=	37 	// Momentary: Aux 4 source select
PRE_SRC2_CD			=	38 	// Momentary: CD source select
PRE_SRC2_TAPE       =   39 	// Momentary: Tape source select 
PRE_SRC2_PHONO      =   40 	// Momentary: Phono source select
PRE_SRC2_XM         =   41 	// Momentary: XM Radio source select
PRE_SRC2_SIR        =   42 	// Momentary: Sirius source select
PRE_SRC2_FM			=	43
PRE_SRC2_AM			=	44
PRE_SRC2_LD			=	45	// Momentary: Laserdisc Source Select
PRE_SRC3_DVD 		=	46  // Momentary: DVD source select
PRE_SRC3_DVD2		=	47	// Momentary: DVD2 source select
PRE_SRC3_CBL		=	48  // Momentary: Cable source select
PRE_SRC3_SAT		=	49  // Momentary: Satellite source select
PRE_SRC3_GAME 	   	=	50  // Momentary: Game System source select
PRE_SRC3_TV			=	51	// Momentary: TV source select
PRE_SRC3_DVR		=	52  // Momentary: DVR source select
PRE_SRC3_VCR		=	53  // Momentary: VCR source select
PRE_SRC3_AUX1    	=	54  // Momentary: Aux 1 source select
PRE_SRC3_AUX2		=	55 	// Momentary: Aux 2 source select
PRE_SRC3_AUX3		=	56 	// Momentary: Aux 3 source select
PRE_SRC3_AUX4		=	57 	// Momentary: Aux 4 source select
PRE_SRC3_CD			=	58 	// Momentary: CD source select
PRE_SRC3_TAPE       =   59 	// Momentary: Tape source select 
PRE_SRC3_PHONO      =   60 	// Momentary: Phono source select
PRE_SRC3_XM         =   61 	// Momentary: XM Radio source select
PRE_SRC3_SIR        =   62 	// Momentary: Sirius source select
PRE_SRC3_FM			=	63
PRE_SRC3_AM			=	64
PRE_SRC3_LD			=	65	// Momentary: Laserdisc Source Select

PRE_MUTE_ON_FB		=	256	// Feedback: Mute is On
PRE_MUTE_OFF_FB		=	257	// Feedback: Mute is Off
PRE_SRC3_DVD_FB 	=	258 
PRE_SRC3_DVD2_FB	=	259
PRE_SRC3_CBL_FB	 	=	260 
PRE_SRC3_SAT_FB	 	=	261 
PRE_SRC3_GAME_FB    =	262 
PRE_SRC3_TV_FB		=	263
PRE_SRC3_DVR_FB		=	264 
PRE_SRC3_VCR_FB		=	265 
PRE_SRC3_AUX1_FB  	=	266 
PRE_SRC3_AUX2_FB	=	267
PRE_SRC3_AUX3_FB	=	268
PRE_SRC3_AUX4_FB	=	269
PRE_SRC3_CD_FB		=	270
PRE_SRC3_TAPE_FB    =   271
PRE_SRC3_PHONO_FB   =   272
PRE_SRC3_XM_FB      =   273
PRE_SRC3_SIR_FB     =   274
PRE_SRC3_FM_FB		=	275
PRE_SRC3_AM_FB		=	276
PRE_SRC3_LD_FB		=	277
PRE_SRC2_DVD_FB 	=	278 
PRE_SRC2_DVD2_FB	=	279
PRE_SRC2_CBL_FB	 	=	280 
PRE_SRC2_SAT_FB	 	=	281 
PRE_SRC2_GAME_FB    =	282 
PRE_SRC2_TV_FB		=	283
PRE_SRC2_DVR_FB		=	284 
PRE_SRC2_VCR_FB		=	285 
PRE_SRC2_AUX1_FB  	=	286 
PRE_SRC2_AUX2_FB	=	287
PRE_SRC2_AUX3_FB	=	288
PRE_SRC2_AUX4_FB	=	289
PRE_SRC2_CD_FB		=	290
PRE_SRC2_TAPE_FB    =   291
PRE_SRC2_PHONO_FB   =   292
PRE_SRC2_XM_FB      =   293
PRE_SRC2_SIR_FB     =   294
PRE_SRC2_FM_FB		=	295
PRE_SRC2_AM_FB		=	296
PRE_SRC2_LD_FB		=	297
PRE_SRC_DVD_FB 		=	298 
PRE_SRC_DVD2_FB		=	299
PRE_SRC_CBL_FB	 	=	300 
PRE_SRC_SAT_FB	 	=	301 
PRE_SRC_GAME_FB    	=	302 
PRE_SRC_TV_FB		=	303
PRE_SRC_DVR_FB		=	304 
PRE_SRC_VCR_FB		=	305 
PRE_SRC_AUX1_FB  	=	306 
PRE_SRC_AUX2_FB		=	307
PRE_SRC_AUX3_FB		=	308
PRE_SRC_AUX4_FB		=	309
PRE_SRC_CD_FB		=	310
PRE_SRC_TAPE_FB     =   311
PRE_SRC_PHONO_FB    =   312
PRE_SRC_XM_FB       =   313
PRE_SRC_SIR_FB      =   314
PRE_SRC_FM_FB		=	315
PRE_SRC_AM_FB		=	316
PRE_SRC_LD_FB		=	317
                      

PRE_VOL_LVL			=	1	// Level: Master Volume (0-100)


//DMR Buttons

DMR_SRC_VID1		=	1
DMR_SRC_VID2		=	2
DMR_SRC_RGB1		=	3
DMR_SRC_RGB2		=	4
DMR_SRC_RGB3		=	5
DMR_MENU			=	6
DMR_UP				=	7
DMR_DOWN			=	8
DMR_LEFT			=	9
DMR_RIGHT			=	10
DMR_SELECT			=	11
DMR_REC_START		=	12
DMR_REC_STOP		=	13


(***********************************************************)
(*                     Type Constants                      *)
(***********************************************************)

//Signal Types
RGB_TYPE	= 1
VID_TYPE	= 2
SVD_TYPE	= 3
CPT_TYPE	= 4
DVI_TYPE	= 5
SDI_TYPE	= 6
AUD_TYPE	= 7
USR1_TYPE	= 8
USR2_TYPE	= 9
USR3_TYPE	= 10

//Biamp Types
MUTE_TYPE 		= 'MB'
FADER_TYPE 		= 'FDR'
RMCMB_TYPE 		= 'RMCMB'
AUTOMIX_TYPE	= 'AM'
MATRIX_TYPE 	= 'MM'
STDMIX_TYPE		= 'SM'

//Clearone XAP/Converge Types
PROCESS_TYPE 	= 'P'
INPUT_TYPE		= 'I'
OUTPUT_TYPE 	= 'O'
EXPANSION_TYPE 	= 'E'
TRANSMIT_TYPE	= 'T'
RECEIVE_TYPE 	= 'R'
LINE_TYPE		= 'L'
MIC_TYPE		= 'M'

//Clearone XAP/Converge Device Types
CLEARONE_880		=	'1'
CLEARONE_TH20		=	'2'
CLEARONE_840T		=	'3'
CLEARONE_PSR1212	=	'4'
CLEARONE_XAP800		=	'5'
CLEARONE_TH2		=	'6'
CLEARONE_XAP400		=	'7'
CLEARONE_8i			=	'A'
CLEARONE_590		=	'B'
CLEARONE_560		=	'C'
CLEARONE_880T		=	'D'
CLEARONE_SR1212		=	'G'

(***********************************************************)
(*                     Video Display                       *)
(***********************************************************)

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE



(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)