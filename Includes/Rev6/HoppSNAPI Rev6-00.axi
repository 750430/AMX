PROGRAM_NAME='HoppSNAPI Rev6-00'
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 05/25/2012  AT: 04:55:36        *)
(***********************************************************)
(*{{PS_SOURCE_INFO(PROGRAM STATS)                          *)
(***********************************************************)
(*  ORPHAN_FILE_PLATFORM: 0                                *)
(***********************************************************)
(*}}PS_SOURCE_INFO                                         *)
(***********************************************************)

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
define_constant //GUIDE

GUIDE_START				=	1
GUIDE_NEXT				=	2
GUIDE_EXIT				=	3
GUIDE_SHOW_ME			=	4
GUIDE_RETURN			=	5
GUIDE_BACK				=	6

GUIDE_PAGE_NUM			=	11
GUIDE_PAGE_NAME			=	12

integer GUIDE_STEPS[]		=	{21,22,23,24,25,26,27,28,29,30}
integer GUIDE_STEP_DOTS[][]=	{{101,102,103,104,105},
								{111,112,113,114,115},
								{121,122,123,124,125},
								{131,132,133,134,135},
								{141,142,143,144,145},
								{151,152,153,154,155},
								{161,162,163,164,165},
								{171,172,173,174,175},
								{181,182,183,184,185},
								{191,192,193,194,195}}
								
integer GUIDE_DIVIDERS[]	=	{201,202,203,204,205,206,207,208,209,210}

define_constant //Video Display Channels
VD_NAME_TEXT		=	1
VD_LAMP_TEXT		=	2
VD_SOURCE_TEXT		=	3
VD_INPUT_TEXT		=	4

VD_PWR_ON      		=	1  	//Momentary: Set lamp power on
VD_PWR_OFF     		=	2  	//Momentary: Set lamp power off
VD_COOLING			=	3	//Feedback: Cooling
VD_WARMING			=	4	//Feedback: Warming
VD_PWR_TOG			=	5 	//Toggle: Power On/Off
VD_LAMP_ON			=	6
VD_LAMP_OFF			=	7
integer VD_PWR[]	=	{1,2,3,4,5,6,7}

VD_SRC_VGA1			=	11	//Momentary: VGA 1 source select
VD_SRC_VGA2			=	12	//Momentary: VGA 2 source select
VD_SRC_VGA3			=	13	//Momentary: VGA 3 source select
VD_SRC_DVI1			=	14	//Momentary: DVI 1 source select
VD_SRC_DVI2			=	15	//Momentary: DVI 2 source select
VD_SRC_DVI3			=	16	//Momentary: DVI 3 source select
VD_SRC_RGB1 		=	17  //Momentary: RGB 1 source select
VD_SRC_RGB2			=	18  //Momentary: RGB 2 source select
VD_SRC_RGB3			=	19  //Momentary: RGB 3 source select
VD_SRC_HDMI1		=	20  //Momentary: HDMI 1 Source Select
VD_SRC_HDMI2		=	21  //Momentary: HDMI 2 Source Select
VD_SRC_HDMI3		=	22  //Momentary: HDMI 3 Source Select
VD_SRC_HDMI4		=	23  //Momentary: HDMI 3 Source Select
VD_SRC_VID	   		=	24  //Momentary: Composite Video source select
VD_SRC_SVID			=	25  //Momentary: S-Video source select
VD_SRC_CMPNT		=	26  //Momentary: Component Video source select
VD_SRC_CATV			=	27	//Momentary: Coax Cable Source Select
VD_SRC_AUX1    		=	28  //Momentary: Aux 1 source select
VD_SRC_AUX2			=	29 	//Momentary: Aux 2 source select
VD_SRC_AUX3			=	30 	//Momentary: Aux 3 source select
VD_SRC_AUX4			=	31 	//Momentary: Aux 4 source select
integer VD_SRC[]	=	{11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31}

VD_SCREEN_UP		=	41
VD_SCREEN_DOWN		=	42
VD_LIFT_UP			=	43
VD_LIFT_DOWN		=	44
VD_ASPECT1     		=	45 	//Momentary: Aspect Ratio 1
VD_ASPECT2     		=	46 	//Momentary: Aspect Ratio 2
VD_ASPECT3     		=	47 	//Momentary: Aspect Ratio 3
VD_ASPECT4     		=	48 	//Momentary: Aspect Ratio 4
VD_MUTE_TOG    		=	49 	//Toggle: Video Mute On/Off
VD_MUTE_ON			=	50 	//Momentary: Video Mute On
VD_MUTE_OFF    		=	51 	//Momentary: Video Mute Off
VD_PCADJ			=	52 	//Momentary: Image adjust
VD_ZOOM_IN			=	53 	//Ramping: Zoom In
VD_ZOOM_OUT			=	54 	//Ramping: Zoom Out
VD_LENS_UP			=	55 	//Ramping: Lens Shift Up
VD_LENS_DN			=	56 	//Ramping: Lens Shift Down
VD_SPLIT_SCREEN		=	57	//Momentary: Change display to Split Screens
VD_SINGLE_SCREEN	=	58	//Momentary: Change display back to Single Screen
VD_ERROR			=	59	//Feedback: Error
VD_VOL_UP			=	60	//Ramping: Volume Up
VD_VOL_DOWN			=	61	//Ramping: Volume Down
VD_VOL_MUTE_TOG		=	62	//Momentary: Mute Toggle
VD_VOL_MUTE_ON		=	63	//Momentary: Mute On
VD_VOL_MUTE_OFF		=	64	//Momentary: Mute Off
VD_CHAN_UP			=	65	//Momentary: Channel Up
VD_CHAN_DOWN		=	66	//Momentary: Channel Down
VD_CHAN_ENTER		=	67	//Momentary: Channel Enter
VD_CHAN_DIGIT_0		=	68	//Momentary: Digit 0
VD_CHAN_DIGIT_1		=	69	//Momentary: Digit 1
VD_CHAN_DIGIT_2		=	70	//Momentary: Digit 2
VD_CHAN_DIGIT_3		=	71	//Momentary: Digit 3
VD_CHAN_DIGIT_4		=	72	//Momentary: Digit 4
VD_CHAN_DIGIT_5		=	73	//Momentary: Digit 5
VD_CHAN_DIGIT_6		=	74	//Momentary: Digit 6
VD_CHAN_DIGIT_7		=	75	//Momentary: Digit 7
VD_CHAN_DIGIT_8		=	76	//Momentary: Digit 8
VD_CHAN_DIGIT_9		=	77	//Momentary: Digit 9
VD_MENU				=	78
VD_CURSOR_UP		=	79
VD_CURSOR_DOWN		=	80
VD_CURSOR_LEFT		=	81
VD_CURSOR_RIGHT		=	82
VD_SELECT			=	83
VD_BACK				=	84
VD_EXIT				=	85

VD_CHAN_1_NAME		=	91
VD_CHAN_2_NAME		=	92
VD_CHAN_3_NAME		=	93
VD_CHAN_4_NAME		=	94
        
integer VD_CHAN_NAME[]		=	{91,92,93,94}

VD_CHAN_1_NUMBER	=	96
VD_CHAN_2_NUMBER	=	97
VD_CHAN_3_NUMBER	=	98
VD_CHAN_4_NUMBER	=	99
        
integer VD_CHAN_NUMBER[]		=	{96,97,98,99}

VD_CHAN_1			=	101
VD_CHAN_2			=	102
VD_CHAN_3			=	103
VD_CHAN_4			=	104

integer VD_CHAN[]	=	{101,102,103,104}

define_constant //ATC Channels
ATC_ON_HOOK			=	1	//Feedback: on hook
ATC_OFF_HOOK		=	2	//Feedback: off hook
ATC_QUERY			=	3 	//Momentary: get hook status
ATC_RINGING			=	4	//Feedback: telco line ringing

ATC_PRIVACY_TOG		=	7 	//Toggle: privacy on/off
ATC_PRIVACY_ON		=	8 	//Momentary: Press privacy on
ATC_PRIVACY_OFF		=	9 	//Momentary: Press privacy off

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
ATC_BACKSPACE		=	22 	//Momentary: remove digit from readout
ATC_DIAL			=	23	//Momentary: dial number
ATC_HANGUP			=	24 	//Momentary: disconnect line

ATC_FLASH			=	31	//Momentary: flash hook
ATC_PAUSE			=	32 	//Momentary: Press menu button ,
ATC_CLEAR			=	33 	//Momentary: clear readout

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


define_constant //VTC Channels

VTC_WAKE				=	1

//Channels 6-24 are the same as the ATC Channels for the same things
VTC_PRIVACY_TOG			=	7
VTC_PRIVACY_ON			=	8
VTC_PRIVACY_OFF 		=	9

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
VTC_BACKSPACE			=	22
VTC_DIAL				=	23
VTC_HANGUP				=	24

VTC_KEY_KEYBRD			=	25
VTC_KEY_PERIOD			=	26
VTC_CLEAR				=	27

VTC_F1					=	31
VTC_F2					=	32
VTC_F3					=	33
VTC_F4					=	34
VTC_F5					=	35

//Channels 44-50 are the same as typical IR or DEV channels for Menus
VTC_MENU				=	44
VTC_UP					=	45
VTC_DOWN				=	46
VTC_LEFT				=	47
VTC_RIGHT				=	48
VTC_OK					=	49
VTC_CANCEL				=	50


//Channels 51-66 are the same as the CAM channels for the same things
VTC_CAM_UP				=	51
VTC_CAM_DOWN			=	52
VTC_CAM_LEFT			=	53
VTC_CAM_RIGHT			=	54
VTC_ZOOM_IN				=	55
VTC_ZOOM_OUT			=	56
VTC_CAM_PRESET1			=	61
VTC_CAM_PRESET2			=	62
VTC_CAM_PRESET3			=	63
VTC_CAM_PRESET4			=	64
VTC_CAM_PRESET5			=	65
VTC_CAM_PRESET6			=	66

VTC_NR_VID1				=	71
VTC_NR_VID2				=	72
VTC_NR_VID3				=	73
VTC_NR_VID4				=	74
VTC_NR_VID5				=	75
integer VTC_NR_VID[]	=	{71,72,73,74,75}

VTC_PRES_1				=	76
VTC_PRES_2				=	77
VTC_PRES_3				=	78
VTC_PRES_4				=	79
VTC_PRES_5				=	80 
integer VTC_PRES[]		=	{76,77,78,79,80}

VTC_CONTENT_TOG			=	81
VTC_CONTENT_ON			=	82
VTC_CONTENT_OFF     	=	83
VTC_SELFVIEW_TOG		=	84
VTC_SELFVIEW_ON			=	85
VTC_SELFVIEW_OFF		=	86
VTC_PIP_TOG				=	87
VTC_PIP_ON				=	88
VTC_PIP_OFF				=	89

VTC_HOME				=	101
VTC_BACK				=	102
VTC_INFO				=	103
VTC_ADDRESSBOOK			=	104
VTC_NEAR				=	105
VTC_FAR					=	106
VTC_OPTION				=	107
VTC_LAYOUT				=	108
                         

define_constant //Camera Channels
CAM_PWR_ON			=	1		//Momentary:
CAM_PWR_OFF			=	2		//Momentary:
CAM_HOME			=	3		//Momentary:
CAM_AUTO_FOCUS		=	4		//Momentary:
CAM_MANUAL_FOCUS	=	5		//Momentary:
CAM_FOCUS_IN		=	6		//Momentary:
CAM_FOCUS_OUT		=	7		//Momentary:

//Channels 51-66 are the same as the VTC Camera Channels
CAM_UP				=	51		//Momentary:
CAM_DOWN			=	52		//Momentary:
CAM_LEFT			=	53		//Momentary:
CAM_RIGHT			=	54		//Momentary:
CAM_ZOOM_IN			=	55		//Momentary:
CAM_ZOOM_OUT		=	56		//Momentary:

CAM_PRESET1			=	61		//Momentary:
CAM_PRESET2			=	62		//Momentary:
CAM_PRESET3			=	63		//Momentary:
CAM_PRESET4			=	64		//Momentary:
CAM_PRESET5			=	65		//Momentary:
CAM_PRESET6			=	66		//Momentary:
integer CAM_PRESETS[]		=	{61,62,63,64,65,66}

//Camera Levels
CAM_PAN_LVL			=	1
CAM_TILT_LVL		=	2
CAM_ZOOM_LVL		=	3

define_constant //Tuner Channels 
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
TUNER_DASH			=	20	//Momentary: - for digital
TUNER_ENTER     	=	21	//Momentary: set channel
TUNER_BACK 			=	22	//Momentary: backspace
TUNER_CLEAR 		=	23	//Momentary: clear                                      

TUNER_GUIDE			=	25
TUNER_CHAN_UP		=	26	//Momentary: channel up  
TUNER_CHAN_DN		=	27	//Momentary: channel down

TUNER_CAPTION_ON	=	31	//Momenary: Captions on
TUNER_CAPTION_OFF 	=	32	//Momentary: Captions off
TUNER_CAPTION_TOG 	=	33	//Toggle: caption on/off
TUNER_EXIT        	=	34
TUNER_ASPECT		=	35

TUNER_MENU			=	44
TUNER_UP			=	45
TUNER_DN      		=	46
TUNER_LEFT			=	47
TUNER_RIGHT			=	48
TUNER_OK			=	49


define_constant //Mixer Channels
MIX_NAME			=	1

MIX_VOL_UP 			=	1	//Ramping: Vol Up
MIX_VOL_DN 			=	2 	//Ramping: Vol Dn 
MIX_MUTE_TOG 		=	3	//Toggle:  Vol Mute
MIX_QUERY 			=	4	//Momentary: Get Vol/Mute Status
MIX_MUTE_OFF		=	5	//Momentary: Mute off
MIX_MUTE_ON 		=	6	//Momentary: Mute On
MIX_UPDATE_ALL		=	7	//Momentary: Updates the Touchpanel for all Levels, regardless of the level that was pulsed

MIX2_VOL_UP 		=	101	//Ramping: Vol Up
MIX2_VOL_DN 		=	102 	//Ramping: Vol Dn 
MIX2_MUTE_TOG 		=	103	//Toggle:  Vol Mute
MIX2_QUERY 			=	104	//Momentary: Get Vol/Mute Status
MIX2_MUTE_OFF		=	105	//Momentary: Mute off
MIX2_MUTE_ON 		=	106	//Momentary: Mute On
                      
MIX3_VOL_UP 		=	201	//Ramping: Vol Up
MIX3_VOL_DN 		=	202 	//Ramping: Vol Dn 
MIX3_MUTE_TOG 		=	203	//Toggle:  Vol Mute
MIX3_QUERY 			=	204	//Momentary: Get Vol/Mute Status
MIX3_MUTE_OFF		=	205	//Momentary: Mute off
MIX3_MUTE_ON 		=	206	//Momentary: Mute On
                      
define_constant //DVD, VCR, DVR
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

DVR_HOME			=	21
DVR_EXIT			=	22
DVR_DISC_MENU 		=	23	//Momentary:
DVR_POPUP_MENU		=	24 //Momentary: Popup Menu
DVR_AUDIO			=	25	//Momentary:
DVR_SETUP			=	26 //Momentary:
DVR_RETURN			=	27
DVR_TOP_MENU		=	28

DVR_MENU			=	44
DVR_UP 				=	45	//Momentary:
DVR_DN 				=	46	//Momentary:
DVR_LEFT			=	47	//Momentary:
DVR_RIGHT			=	48	//Momentary:
DVR_OK 				=	49	//Momentary:

DVR_ENABLE_FB		=	50
DVR_DISABLE_FB		=	51

DVR_MEDIA_IN		=	60

//Addresses for Text Boxes
DVR_TRACK_TXT		=	1	//Address: Display Track
DVR_COUNTER_TXT		=	2	//Address: Display counter
DVR_STATUS_TXT		=	3


define_constant //Lights

LIGHTS_PRESET_1		=	1
LIGHTS_PRESET_2		=	2
LIGHTS_PRESET_3		=	3
LIGHTS_PRESET_4		=	4
LIGHTS_PRESET_5		=	5
LIGHTS_PRESET_6		=	6
LIGHTS_PRESET_7		=	7
LIGHTS_PRESET_8		=	8
integer LIGHTS_PRESETS[]	=	{1,2,3,4,5,6,7,8}
LIGHTS_OFF			=	9
LIGHTS_SHADE1_UP	=	10
LIGHTS_SHADE1_DOWN	=	11
LIGHTS_SHADE2_UP	=	12
LIGHTS_SHADE2_DOWN	=	13
LIGHTS_SHADE3_UP	=	14
LIGHTS_SHADE3_DOWN	=	15
LIGHTS_SHADE4_UP	=	16
LIGHTS_SHADE4_DOWN	=	17

LIGHTS_DEBUG_ON			=	101
LIGHTS_DEBUG_OFF		=	102
LIGHTS_DEBUG_CLEAR		=	103

LIGHTS_DEBUG_ASCII		=	104
LIGHTS_DEBUG_MIX		=	105
LIGHTS_DEBUG_HEX		=	106
integer LIGHTS_DEBUG_MODE[]	=	{104,105,106}

LIGHTS_DEBUG_LINE1		=	201
LIGHTS_DEBUG_LINE2		=	202
LIGHTS_DEBUG_LINE3		=	203
LIGHTS_DEBUG_LINE4		=	204
LIGHTS_DEBUG_LINE5		=	205
LIGHTS_DEBUG_LINE6		=	206
LIGHTS_DEBUG_LINE7		=	207
LIGHTS_DEBUG_LINE8		=	208
LIGHTS_DEBUG_LINE9		=	209
LIGHTS_DEBUG_LINE10		=	210
LIGHTS_DEBUG_LINE11		=	211
LIGHTS_DEBUG_LINE12		=	212
LIGHTS_DEBUG_LINE13		=	213
LIGHTS_DEBUG_LINE14		=	214
LIGHTS_DEBUG_LINE15		=	215
LIGHTS_DEBUG_LINE16		=	216
LIGHTS_DEBUG_LINE17		=	217
LIGHTS_DEBUG_LINE18		=	218
LIGHTS_DEBUG_LINE19		=	219
LIGHTS_DEBUG_LINE20		=	220
LIGHTS_DEBUG_LINE21		=	221
LIGHTS_DEBUG_LINE22		=	222
LIGHTS_DEBUG_LINE23		=	223
LIGHTS_DEBUG_LINE24		=	224
LIGHTS_DEBUG_LINE25		=	225
LIGHTS_DEBUG_LINE26		=	226

define_constant //Renaming Channels

RNM_ABORT			=	1
RNM_KEYPAD_RCVD		=	2
RNM_KEYBRD_RCVD		=	3

define_constant //Signal Types
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

define_constant //Mixer Types
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

define_constant //IP Device Types

EXTRON_TYPE			=	1
BIAMP_TYPE			=	2
CLEARONE_TYPE		=	3

define_constant //IR Types

CARON_TYPE			=	1
CAROFF_TYPE			=	2

IR_TYPE				=	1
SERIAL_TYPE			=	2
DATA_TYPE			=	3

define_constant //Volume Types

PROG_VOL_TYPE		=	1
CONF_VOL_TYPE		=	2

(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)

