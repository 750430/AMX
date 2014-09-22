PROGRAM_NAME='HoppSNAPI Rev5-11'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/25/2012  AT: 04:55:36        *)
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
VD_COOLING			=	50	//Feedback: Cooling
VD_WARMING			=	51	//Feedback: Warming
VD_ERROR			=	52	//Feedback: Erro
VD_VOL_UP			=	53	//Ramping: Volume Up
VD_VOL_DOWN			=	54	//Ramping: Volume Down
VD_VOL_MUTE_TOG		=	55	//Momentary: Mute Toggle
VD_VOL_MUTE_ON		=	56	//Momentary: Mute On
VD_VOL_MUTE_OFF		=	57	//Momentary: Mute Off
VD_CHAN_UP			=	58	//Momentary: Channel Up
VD_CHAN_DOWN		=	59	//Momentary: Channel Down
VD_CHAN_ENTER		=	60	//Momentary: Channel Enter
VD_CHAN_DIGIT_0		=	61	//Momentary: Digit 0
VD_CHAN_DIGIT_1		=	62	//Momentary: Digit 1
VD_CHAN_DIGIT_2		=	63	//Momentary: Digit 2
VD_CHAN_DIGIT_3		=	64	//Momentary: Digit 3
VD_CHAN_DIGIT_4		=	65	//Momentary: Digit 4
VD_CHAN_DIGIT_5		=	66	//Momentary: Digit 5
VD_CHAN_DIGIT_6		=	67	//Momentary: Digit 6
VD_CHAN_DIGIT_7		=	68	//Momentary: Digit 7
VD_CHAN_DIGIT_8		=	69	//Momentary: Digit 8
VD_CHAN_DIGIT_9		=	70	//Momentary: Digit 9
VD_SRC_HDMI1		=	71  //Momentary: HDMI 1 Source Select
VD_SRC_HDMI2		=	72  //Momentary: HDMI 2 Source Select
VD_SRC_HDMI3		=	73  //Momentary: HDMI 3 Source Select
VD_SRC_HDMI4		=	74  //Momentary: HDMI 3 Source Select
VD_SRC_CATV			=	75	//Momentary: Coax Cable Source Select
VD_MENU				=	76
VD_CURSOR_UP		=	77
VD_CURSOR_DOWN		=	78
VD_CURSOR_LEFT		=	79
VD_CURSOR_RIGHT		=	80
VD_SELECT			=	81
VD_BACK				=	82
VD_EXIT				=	83

VD_PRESET_1			=	101
VD_PRESET_2			=	102
VD_PRESET_3			=	103
VD_PRESET_4			=	104
VD_PRESET_5			=	105
VD_PRESET_6			=	106
VD_PRESET_7			=	107
VD_PRESET_8			=	108
VD_PRESET_9			=	109
VD_PRESET_10		=	110


VD_POLL_BEGIN		=	200	//Momentary: Start Polling


//ATC Channels
ATC_DIGIT_0			=	10  //Momentary: Press menu button digit 0
ATC_DIGIT_1			=	11  //Momentary: Press menu button digit 1
ATC_DIGIT_2			=	12  //Momentary: Press menu button digit 2
ATC_DIGIT_3			=	13  //Momentary: Press menu button digit 3
ATC_DIGIT_4			=	14  //Momentary: Press menu button digit 4
ATC_DIGIT_5			=	15  //Momentary: Press menu button digit 5
ATC_DIGIT_6			=	16  //Momentary: Press menu button digit 6
ATC_DIGIT_7			=	17 	//Momentary: Press menu button digit 7
ATC_DIGIT_8			=	18  //Momentary: Press menu button digit 8
ATC_DIGIT_9			=	19  //Momentary: Press menu button digit 9
ATC_STAR_KEY		=	20 	//Momentary: Press menu button *
ATC_POUND_KEY		=	21 	//Momentary: Press menu button #
ATC_PAUSE			=	22 	//Momentary: Press menu button ,
ATC_CLEAR			=	23 	//Momentary: clear readout
ATC_BACKSPACE		=	24 	//Momentary: remove digit from readout
ATC_ANSWER			=	25 	//Momentary: pick up line
ATC_HANGUP			=	26 	//Momentary: disconnect line
ATC_PRIVACY_TOG		=	27 	//Toggle: privacy on/off
ATC_PRIVACY_ON		=	28 	//Momentary: Press privacy on
ATC_PRIVACY_OFF		=	29 	//Momentary: Press privacy off
ATC_QUERY			=	30 	//Momentary: get hook status
ATC_DIAL			=	31	//Momentary: dial number
ATC_FLASH			=	32	//Momentary: flash hook
ATC_ON_HOOK			=	33	//Feedback: on hook
ATC_OFF_HOOK		=	34	//Feedback: off hook
ATC_RINGING			=	35	//Feedback: telco line ringing
ATC_SPEEDDIAL_QUERY	=	36  //Momentary: Query Speed Dials
                      

ATC_SPEEDDIAL1		=	101	//Momentary: Speed Dial 1
ATC_SPEEDDIAL2		=	102	//Momentary: Speed Dial 2
ATC_SPEEDDIAL3		=	103	//Momentary: Speed Dial 3
ATC_SPEEDDIAL4		=	104	//Momentary: Speed Dial 4
ATC_SPEEDDIAL5		=	105	//Momentary: Speed Dial 5
ATC_SPEEDDIAL6		=	106	//Momentary: Speed Dial 6
ATC_SPEEDDIAL7		=	107	//Momentary: Speed Dial 7
ATC_SPEEDDIAL8		=	108	//Momentary: Speed Dial 8
ATC_SPEEDDIAL9		=	109	//Momentary: Speed Dial 8
ATC_SPEEDDIAL10		=	110	//Momentary: Speed Dial 8
integer ATC_SPEEDDIAL[]	=	{101,102,103,104,105,106,107,108,109,110}

ATC_SPEEDDIALNUM1	=	121	//Feedback: Speed Dial Number
ATC_SPEEDDIALNUM2	=	122	//Feedback: Speed Dial Number
ATC_SPEEDDIALNUM3	=	123	//Feedback: Speed Dial Number
ATC_SPEEDDIALNUM4	=	124	//Feedback: Speed Dial Number
ATC_SPEEDDIALNUM5	=	125	//Feedback: Speed Dial Number
ATC_SPEEDDIALNUM6	=	126	//Feedback: Speed Dial Number
ATC_SPEEDDIALNUM7	=	127	//Feedback: Speed Dial Number
ATC_SPEEDDIALNUM8	=	128	//Feedback: Speed Dial Number
ATC_SPEEDDIALNUM9	=	129	//Feedback: Speed Dial Number
ATC_SPEEDDIALNUM10	=	130	//Feedback: Speed Dial Number
integer ATC_SPEEDDIALNUM[]	=	{121,122,123,124,125,126,127,128,129,130}



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
VTC_DISPLAY				=	117
VTC_SWITCH_1			=	118
VTC_SWITCH_2			=	119
VTC_SWITCH_3			=	120
VTC_SWITCH_4			=	121
VTC_SWITCH_5			=	122
VTC_SWITCH_6			=	123
VTC_SWITCH_7			=	124
VTC_SWITCH_8			=	125
VTC_PB_DISPLAY			=	126
VTC_PB_UP				=	127
VTC_PB_DOWN				=	128
VTC_PB_REFRESH			=	129
VTC_PB_1				=	130
VTC_PB_2				=	131
VTC_PB_3				=	132
VTC_PB_4				=	133
VTC_PB_5				=	134
VTC_PB_6				=	135
VTC_PB_7				=	136
integer VTC_PB_ENTRIES[]=	{130,131,132,133,134,135,136}
VTC_PB_LOADING			=	137
VTC_PB_LOCAL			=	138
VTC_PB_CORPORATE		=	139
VTC_PB_SEARCH			=	140
VTC_PRES_1				=	141
VTC_PRES_2				=	142
VTC_PRES_3				=	143
VTC_PRES_4				=	144
VTC_PRES_5				=	145 
integer VTC_PRES[]		=	{141,142,143,144,145}
VTC_OPTION				=	146
VTC_VOL_UP				=	147	//Ramping: Volume Up
VTC_VOL_DOWN			=	148	//Ramping: Volume Down
VTC_VOL_MUTE_TOG		=	149	//Momentary: Mute Toggle
VTC_VOL_MUTE_ON			=	150	//Momentary: Mute On
VTC_VOL_MUTE_OFF		=	151	//Momentary: Mute Off

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
integer CAM_PRESETS[]		=	{5,6,7,8,9,19}
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
CAM_LAMP			=	26
CAM_FREEZE			=	27

CAM_PAN_LVL_ON		=	31
CAM_TILT_LVL_ON		=	32
CAM_ZOOM_LVL_ON		=	33

//Camera Levels
CAM_PAN_LVL			=	1
CAM_TILT_LVL		=	2
CAM_ZOOM_LVL		=	3

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

//Radio Channels

RADIO_DIGIT_1		=	1
RADIO_DIGIT_2		=	2
RADIO_DIGIT_3		=	3
RADIO_DIGIT_4		=	4
RADIO_DIGIT_5		=	5
RADIO_DIGIT_6		=	6
RADIO_DIGIT_7		=	7
RADIO_DIGIT_8		=	8
RADIO_DIGIT_9		=	9
RADIO_DIGIT_0		=	10
RADIO_PRESET_1		=	11
RADIO_PRESET_2		=	12
RADIO_PRESET_3		=	13
RADIO_PRESET_4		=	14
RADIO_PRESET_5		=	15
RADIO_PRESET_6		=	16
RADIO_AM			=	17
RADIO_FM			=	18
RADIO_SELECT		=	19
RADIO_SEEK_UP		=	20
RADIO_SEEK_DOWN		=	21
RADIO_STEP_UP		=	22
RADIO_STEP_DOWN		=	23

//Mixer Channels
MIX_VOL_UP 			=	1	//Ramping: Vol Up
MIX_VOL_DN 			=	2 	//Ramping: Vol Dn 
MIX_MUTE_TOG 		=	3	//Toggle:  Vol Mute
MIX_QUERY 			=	4	//Momentary: Get Vol/Mute Status
MIX_MUTE_OFF		=	5	//Momentary: Mute off
MIX_MUTE_ON 		=	6	//Momentary: Mute On

MIX_MUTE_OFF_FB		=	7	//Feedback: Mute Off
MIX_MUTE_ON_FB 		=	8	//Feedback: Mute On

MIX_UPDATE			=	9	//Used to tell the module to READ_MIXER again

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
DVR_REC_ON			=	11	//Feedback: Record Status on
DVR_REC_OFF			=	12	//Feedback: Record Status off
DVR_UP 				=	45	//Momentary:
DVR_DN 				=	46	//Momentary:
DVR_LEFT			=	47	//Momentary:
DVR_RIGHT			=	48	//Momentary:
DVR_OK 				=	49	//Momentary:
DVR_EXIT			=	50
DVR_HOME			=	51
DVR_DVD 			=	112	//Momentary:
DVR_VCR 			=	113	//Momentary:
DVR_HDD				=	114 //Momentary:
DVR_MiniDV			=	115 //Momentary:
DVR_DISC_MENU 		=	116	//Momentary:
DVR_AUDIO			=	117	//Momentary:
DVR_SETUP			=	118 //Momentary:
DVR_NAVI			=	119	//Momentary:	
DVR_POPUP_MENU		=	120 //Momentary: Popup Menu
DVR_COUNTER_TXT		=	201	//Address: Display counter
DVR_TRACK_TXT		=	202	//Address: Display Track
DVR_FB_ON			=	240
DVR_FB_OFF			=	241


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

PRE_VOL_LVL			=	1	// Level: Master Volume (0-100)


//DMR Buttons

DMR_SRC_VID1		=	1
DMR_SRC_VID2		=	2
DMR_SRC_RGB1		=	3
DMR_SRC_RGB2		=	4
DMR_SRC_RGB3		=	5
DMR_SRC_RGB1_PIP	=	6
DMR_MENU			=	7
DMR_UP				=	8
DMR_DOWN			=	9
DMR_LEFT			=	10
DMR_RIGHT			=	11
DMR_SELECT			=	12
DMR_REC_START		=	13
DMR_REC_STOP		=	14
DMR_REC_PAUSE		=	15

DMR_CURRENT_PRESENTATION	=	17
DMR_GET_PRESENTATIONS		=	18

DMR_SELECT_PRE_UP		=	19
DMR_SELECT_PRE_DOWN		=	20

integer DMR_SELECT_PRE[]	=	{21,22,23,24,25,26,27,28}
DMR_SELECT_PRE_1		=	21
DMR_SELECT_PRE_2		=	22
DMR_SELECT_PRE_3		=	23
DMR_SELECT_PRE_4		=	24
DMR_SELECT_PRE_5		=	25
DMR_SELECT_PRE_6		=	26
DMR_SELECT_PRE_7		=	27
DMR_SELECT_PRE_8		=	28

DMR_AUTO_IMAGE			=	31
DMR_STATUS				=	32

DMR_USERNAME		=	51
DMR_PASSWORD		=	52
DMR_IP				=	53
DMR_FOLDER			=	54

DMR_IDLE				=	247
DMR_RECORDING			=	248
DMR_PAUSED				=	249

//Lights

LIGHTS_PRESET_1		=	1
LIGHTS_PRESET_2		=	2
LIGHTS_PRESET_3		=	3
LIGHTS_PRESET_4		=	4
LIGHTS_PRESET_5		=	5
LIGHTS_PRESET_6		=	6
LIGHTS_PRESET_7		=	7
LIGHTS_PRESET_8		=	8
LIGHTS_OFF			=	9
LIGHTS_SHADE1_UP	=	10
LIGHTS_SHADE1_DOWN	=	11
LIGHTS_SHADE2_UP	=	12
LIGHTS_SHADE2_DOWN	=	13
LIGHTS_SHADE3_UP	=	14
LIGHTS_SHADE3_DOWN	=	15
LIGHTS_SHADE4_UP	=	16
LIGHTS_SHADE4_DOWN	=	17

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
HDMI_TYPE	= 8
USR1_TYPE	= 9
USR2_TYPE	= 10
CATV_TYPE	= 11

//Biamp Types
MUTE_TYPE 		= 'MB'
FADER_TYPE 		= 'FDR'
RMCMB_TYPE 		= 'RMCMB'
AUTOMIX_TYPE	= 'AM'
MATRIX_TYPE 	= 'MM'
STDMIX_TYPE		= 'SM'
LOGIC_TYPE		= 'LGSTATE'

//Clearone XAP/Converge Types
PROCESS_TYPE 	= 'P'
INPUT_TYPE		= 'I'
OUTPUT_TYPE 	= 'O'
EXPANSION_TYPE 	= 'E'
TRANSMIT_TYPE	= 'T'
RECEIVE_TYPE 	= 'R'
LINE_TYPE		= 'L'
MIC_TYPE		= 'M'

//Mackie Types

GROUP_M_TYPE	=	'9'
INPUT_M_TYPE	=	'8'
OUTPUT_M_TYPE	=	'5'

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

//IP Device Types

EXTRON_TYPE			=	1
BIAMP_TYPE			=	2
CLEARONE_TYPE		=	3

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

