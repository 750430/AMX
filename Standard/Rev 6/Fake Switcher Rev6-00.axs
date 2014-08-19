MODULE_NAME='Fake Switcher Rev6-00'(DEV dvTP[], DEV vdvSwitcher, dev vdvSwitcher_FB, DEV dvSwitcher)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 01/20/2008  AT: 16:42:25        *)
(***********************************************************)
(***********************************************************)
(* System Type : NetLinx                                   *)
(***********************************************************)
(* REV HISTORY:                                            *)
(***********************************************************)
(*
define_module 'Fake Switcher Rev6-00' sw1(dvTP_SWITCH[1],vdvSWITCH1,vdvSWITCH1_FB,dvSwitcher)


*)

#INCLUDE 'HoppSNAPI Rev6-00.axi'
#INCLUDE 'HoppDEBUG Rev6-00.axi'
(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

(***********************************************************)
(*               CONSTANT DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_CONSTANT

define_type

structure switcher
{
	integer audio[32]
	integer video[32]
}

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

volatile		integer		nActiveInput
volatile		integer		nAudioSelect=1
volatile		integer		nVideoSelect=1
volatile		integer		nCurrentSwitcherStatus[32][32]

volatile		switcher	swtMain[32]
volatile		switcher	swtCurrent


define_variable //Other Variables

volatile		integer		x
volatile		integer		y
volatile		integer		nBlink


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
define_function tp_fb()
{
	[dvTP,SWITCHER_AUDIO]=nAudioSelect
	[dvTP,SWITCHER_VIDEO]=nVideoSelect
	for(x=1;x<=length_array(SWITCHER_INPUTS);x++) [dvTP,SWITCHER_INPUTS[x]]=nActiveInput=x
	
	
	if(nActiveInput) 
	{
		select
		{
			active(nAudioSelect and nVideoSelect): for(x=1;x<=length_array(SWITCHER_OUTPUTS);x++) [dvTP,SWITCHER_OUTPUTS[x]]=(swtCurrent.audio[x] or swtCurrent.video[x])
			active(!nAudioSelect and nVideoSelect): for(x=1;x<=length_array(SWITCHER_OUTPUTS);x++) [dvTP,SWITCHER_OUTPUTS[x]]=swtCurrent.video[x]
			active(nAudioSelect and !nVideoSelect): for(x=1;x<=length_array(SWITCHER_OUTPUTS);x++) [dvTP,SWITCHER_OUTPUTS[x]]=swtCurrent.audio[x]
		}
	}
	else for(x=1;x<=length_array(SWITCHER_OUTPUTS);x++) off[dvTP,SWITCHER_OUTPUTS[x]]
	
}

define_function parse(char cResponse[30])
{

}

define_function enable_button(dev tp[],integer btn)
{
	send_command tp,"'^BMF-',itoa(btn),',0,%OP255%EN1'"
}

define_function disable_button(dev tp[],integer btn)
{
	send_command tp,"'^BMF-',itoa(btn),',0,%OP80%EN0'"
}

define_function update_button_colors()
{
	select
	{
		active(nAudioSelect and !nVideoSelect): send_command dvTP,"'^BMF-',itoa(SWITCHER_INPUTS[nActiveInput]),',2,%CFVeryLightRed'"
		active(!nAudioSelect and nVideoSelect): send_command dvTP,"'^BMF-',itoa(SWITCHER_INPUTS[nActiveInput]),',2,%CFLightGreen'"
		active(nAudioSelect and nVideoSelect): send_command dvTP,"'^BMF-',itoa(SWITCHER_INPUTS[nActiveInput]),',2,%CFVeryLightOrange'"
	}
	
	for(x=1;x<=32;x++)
	{
		select
		{
			active(swtCurrent.audio[x] and !swtCurrent.video[x]): send_command dvTP,"'^BMF-',itoa(SWITCHER_OUTPUTS[x]),',2,%CFVeryLightRed'"
			active(!swtCurrent.audio[x] and swtCurrent.video[x]): send_command dvTP,"'^BMF-',itoa(SWITCHER_OUTPUTS[x]),',2,%CFLightGreen'"
			active(swtCurrent.audio[x] and swtCurrent.video[x]): 
			{
				select
				{
					active(nAudioSelect and !nVideoSelect): send_command dvTP,"'^BMF-',itoa(SWITCHER_OUTPUTS[x]),',2,%CFVeryLightRed'"
					active(!nAudioSelect and nVideoSelect): send_command dvTP,"'^BMF-',itoa(SWITCHER_OUTPUTS[x]),',2,%CFLightGreen'"
					active(nAudioSelect and nVideoSelect): send_command dvTP,"'^BMF-',itoa(SWITCHER_OUTPUTS[x]),',2,%CFVeryLightOrange'"
				}
			}
		}
	}
}


(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START


#INCLUDE 'HoppFB Rev6-00'
(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[dvTP]
{
	online:
	{
		for(x=1;x<=length_array(SWITCHER_PLANES);x++) disable_button(dvTP,SWITCHER_PLANES[x])
	}
}

data_event[dvSwitcher]
{
	string:
	{
		add_to_debug(data.text,strFrom)
	}
}

data_event[vdvSwitcher]
{
	string:
	{
		
	}
}

button_event[dvTP,SWITCHER_INPUTS]
{
	push:
	{
		if(nAudioSelect or nVideoSelect)
		{
			nActiveInput=get_last(SWITCHER_INPUTS)
			for(x=1;x<=32;x++) 
			{
				swtCurrent.audio[x]=swtMain[nActiveInput].audio[x]
				swtCurrent.video[x]=swtMain[nActiveInput].video[x]
			}
		}
		update_button_colors()
	}
}

button_event[dvTP,SWITCHER_OUTPUTS]
{
	push:
	{
		if(nActiveInput)
		{
			if(nAudioSelect) swtCurrent.audio[get_last(SWITCHER_OUTPUTS)]=!swtCurrent.audio[get_last(SWITCHER_OUTPUTS)]
			if(nVideoSelect) swtCurrent.video[get_last(SWITCHER_OUTPUTS)]=!swtCurrent.video[get_last(SWITCHER_OUTPUTS)]
		}
		
		update_button_colors()
	}
}

button_event[dvTP,SWITCHER_AUDIO]
button_event[dvTP,SWITCHER_VIDEO]
{
	push:
	{
		switch(button.input.channel)
		{
			case SWITCHER_AUDIO: nAudioSelect=!nAudioSelect
			case SWITCHER_VIDEO: nVideoSelect=!nVideoSelect
		}
		if(!nAudioSelect and !nVideoSelect) off[nActiveInput]
		update_button_colors()
	}
}

button_event[dvTP,SWITCHER_TAKE]
{
	push:
	{
		to[button.input]
		
		for(x=1;x<=32;x++) 
		{
			if(swtMain[nActiveInput].audio[x]=!swtCurrent.audio[x])
			{
				if(swtCurrent.audio[x]) send_str(dvSwitcher,"itoa(nActiveInput),'*',itoa(x),'%'")
				else send_str(dvSwitcher,"'0*',itoa(x),'%'")
			}
			swtMain[nActiveInput].audio[x]=swtCurrent.audio[x]
			
			if(swtMain[nActiveInput].video[x]=!swtCurrent.video[x])
			{
				if(swtCurrent.video[x]) send_str(dvSwitcher,"itoa(nActiveInput),'*',itoa(x),'$'")
				else send_str(dvSwitcher,"'0*',itoa(x),'$'")
			}
			swtMain[nActiveInput].video[x]=swtCurrent.video[x]
			
			for(y=1;y<=32;y++)
			{
				if(nActiveInput<>y)
				{
					if(swtMain[nActiveInput].audio[x]) off[swtMain[y].audio[x]]
					if(swtMain[nActiveInput].video[x]) off[swtMain[y].video[x]]
				}
			}
			
			off[swtCurrent.audio[x]]
			off[swtCurrent.video[x]]
		}
		
		off[nActiveInput]
		update_button_colors()
	}
}

(***********************************************************)
(*            THE ACTUAL PROGRAM GOES BELOW                *)
(***********************************************************)
DEFINE_PROGRAM


(***********************************************************)
(*                     END OF PROGRAM                      *)
(*        DO NOT PUT ANY CODE BELOW THIS COMMENT           *)
(***********************************************************)
