MODULE_NAME='MXA-MPL Static Rev6-00' (dev dvTP[], dev vdvDevice, dev vdvDevice_FB, dev dvTPMXA, dev dvSwitcher, nMXAOutput, nMXASwitchType)

(*

define_variable //Camera Preview

volatile		preview		prvMain[10]
volatile		integer		nPreviewOutput=7
volatile		integer		nPreviewSwitchType=1 //DGX=1 DVX=2

*)

#INCLUDE 'HoppSTRUCT Rev6-00.axi'
#INCLUDE 'HoppSNAPI Rev6-00.axi'

define_constant

tlScan			=	1

define_constant //Buttons

integer			btnPreview[]	=	{1,2,3,4,5,6,7,8,9,10}
integer 		btnLoading[]	=	{11,12,13,14,15,16,17,18,19,20}

define_constant //Channels

integer			chStatic[]		=	{1,2,3,4,5,6,7,8,9,10}

define_constant //Status

prvOff		=	0
prvOn		=	1

define_variable

long		lScanTimes[]	=	{200,700,100}

integer		nScanSequence	=	1

preview		prvModule[10]

integer 	nScanNext

define_variable //Binary File Variables

volatile		long		lPos
volatile		slong		slReturn
volatile		slong		slFile
volatile		slong		slResult
volatile		char		sBINString[10000]

define_function tp_fb()
{

}

define_function read_preview()
{
	// Read Binary File
	slFile = FILE_OPEN('BinaryPRVEncode.xml',1)
	slResult = FILE_READ(slFile, sBINString, MAX_LENGTH_STRING(sBINString))
	slResult = FILE_CLOSE (slFile)
	// Convert To Binary
	lPos = 1
	slReturn = STRING_TO_VARIABLE(prvModule, sBINString, lPos)	
}

define_function switchvideo(i,o) //Extron Crosspoint
{  
	switch(nMXASwitchType)
	{
		case 1: //DGX
		{
			if(i=0) send_command dvSwitcher,"'DO',itoa(o),'T'"
			else send_command dvSwitcher,"'CI',itoa(i),'O',itoa(o),'T'"
		}
		case 2: //DVX
		{
			send_command dvSwitcher,"'CLVIDEOI',itoa(i),'O',itoa(o)"
		}
	}
}

define_function verify_timeline()
{
	stack_var integer nPreviewActive
	off[nPreviewActive]

	for(x=1;x<=length_array(btnPreview);x++)
	{
		if(prvModule[x].staticstatus)
		{
			on[nPreviewActive]
			break
		}
	}

	if(!timeline_active(tlScan) and nPreviewActive) timeline_create(tlScan, lScanTimes, max_length_array(lScanTimes), TIMELINE_RELATIVE, TIMELINE_REPEAT) 
	else if(timeline_active(tlScan) and !nPreviewActive) timeline_kill(tlScan)
}

define_start

wait 20
{
	read_preview()
	timeline_create(tlScan, lScanTimes, max_length_array(lScanTimes), TIMELINE_RELATIVE, TIMELINE_REPEAT)
}

#INCLUDE 'HoppFB Rev6-00'

define_event

data_event[dvTP]
{
	online:
	{
		send_command data.device,"'^SLT-1,VIDEOMODE=HDMI,640x480p@30'"
		send_command data.device,"'^SLT-1,audiovideoenable=video'"
		for(x=1;x<=length_array(btnLoading);x++) send_command dvTP,"'^SHO-',ITOA(btnLoading[x]),',1'" //SHOW THE LOADING BUTTON
	}
}

data_event[vdvDevice]
{
	command:
	{
		stack_var integer nActiveSlot
		//String Expected to be formatted 'SLOT:1 INPUT:1' or 'SLOT1 NAME:ASCII'
	
		select
		{
			active(find_string(data.text,'INPUT',1)):
			{
				remove_string(data.text,'SLOT:',1)
				nActiveSlot=atoi(left_string(data.text,find_string(data.text,' ',1)-1))
				remove_string(data.text,'INPUT:',1)
				prvModule[nActiveSlot].input=atoi(data.text)
				
				if(prvModule[nActiveSlot].staticstatus)	nScanNext=nActiveSlot
			}
			active(find_string(data.text,'NAME',1)):
			{
				remove_string(data.text,'SLOT:',1)
				nActiveSlot=atoi(left_string(data.text,find_string(data.text,' ',1)-1))
				remove_string(data.text,'NAME:',1)
				prvModule[nActiveSlot].name=data.text
				
				if(prvModule[nActiveSlot].staticstatus)	nScanNext=nActiveSlot
			}
		}
	}
}


channel_event[vdvDevice,chStatic]
{
	on:
	{
		on[prvModule[get_last(chStatic)].staticstatus]
		verify_timeline()
	}
	off:
	{
		off[prvModule[get_last(chStatic)].staticstatus]
		send_command dvTP,"'^SHO-',ITOA(btnLoading[get_last(chStatic)]),',1'" //SHOW THE LOADING BUTTON
		verify_timeline()
	}
}


timeline_event[tlScan]
{
	stack_var integer nWhileBreakout
	switch(timeline.sequence)
	{
		case 1: //Switch
		{
			if(nScanNext) 
			{
				nScanSequence=nScanNext
				off[nScanNext]
			}
			else
			{
				nScanSequence++
				if(nScanSequence>10) nScanSequence=1
				
				nWhileBreakout=0
				while(prvModule[nScanSequence].staticstatus=0)
				{
					nScanSequence++
					if(nScanSequence>10) nScanSequence=1
					nWhileBreakout++
					if(nWhileBreakout>10) break
				}
			}
			
			switchvideo(prvModule[nScanSequence].input,nMXAOutput)
		}
		case 2: //Snapshot
		{
			send_command dvTPMXA,"'^RMF-MXA_MPL_',ITOA(nScanSequence),',%P0%Hmxamp%Asnapit%Fslot',ITOA(nScanSequence),'.jpg'"
		}
		case 3: 
		{
			send_command dvTP,"'^SHO-',ITOA(btnLoading[nScanSequence]),',0'" //HIDE THE LOADING BUTTON
		}
	}
}

define_program
