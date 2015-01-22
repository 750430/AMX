MODULE_NAME='MXA-MPL Live Rev6-00' (dev dvTP[], dev vdvDevice, dev vdvDevice_FB, dev dvTPMXA, dev dvSwitcher, nMXAOutput, nMXASwitchType)

//THIS MODULE IS NOT COMPLETE AND FUNCTIONAL
//IT'S STORED FOR REFERENCE IF LIVE PREVIEW IS EVER REQUIRED


#INCLUDE 'HoppSTRUCT Rev6-00.axi'
#INCLUDE 'HoppSNAPI Rev6-00.axi'

define_constant

tlScan			=	1

define_constant //Buttons

integer			btnPreview[]	=	{1,2,3,4,5,6,7,8,9,10}
integer 		btnLoading[]	=	{11,12,13,14,15,16,17,18,19,20}
integer			subPages[]		=	{21,22,23,24,25,26,27,28,29,30}

integer			btnStatus[]		=	{31,32,33,34,35,36,37,38,39,40}


define_constant //Channels

integer			chStatic[]		=	{1,2,3,4,5,6,7,8,9,10}
integer			chLive[]		=	{11,12,13,14,15,16,17,18,19,20}

define_constant //Status

prvOff		=	0
prvStatic	=	1
prvLive		=	2

lvlOff		=	0
lvlPaused	=	1
lvlStatic	=	2
lvlLive		=	3

define_variable

//long		lScanTimes[]	=	{1000,1500,100}
long		lScanTimes[]	=	{200,700,100}

integer		nScanSequence	=	1

integer		nLiveEnabled	=	0
integer		nStaticEnabled	=	0

preview		prvModule[10]

integer		nScanActive
integer 	nScanNext

define_variable //Binary File Variables

volatile		long		lPos
volatile		slong		slReturn
volatile		slong		slFile
volatile		slong		slResult
volatile		char		sBINString[10000]

define_function tp_fb()
{
	for(x=1;x<=length_array(btnPreview);x++) [dvTP,btnPreview[x]]=prvModule[x].livestatus
	
	off[nLiveEnabled]

	for(x=1;x<=length_array(btnStatus);x++)
	{
		if(prvModule[x].livestatus)
		{
			on[nLiveEnabled]
			break
		}
	}
	for(x=1;x<=length_array(btnStatus);x++)
	{
		if(nLiveEnabled and prvModule[x].livestatus) send_level dvTP,btnStatus[x],lvlLive
		else if(nLiveEnabled and !prvModule[x].livestatus) send_level dvTP,btnStatus[x],lvlPaused
		else if(!nLiveEnabled and prvModule[x].staticstatus) send_level dvTP,btnStatus[x],lvlStatic
		else send_level dvTP,btnStatus[x],lvlOff
	}
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
	//AMX Enova DGX Style
	if(i=0) send_command dvSwitcher,"'DO',itoa(o),'T'"
	else send_command dvSwitcher,"'CI',itoa(i),'O',itoa(o),'T'"
}

define_function verify_timeline()
{
	off[nLiveEnabled]
	off[nStaticEnabled]

	for(x=1;x<=length_array(btnPreview);x++)
	{
		if(prvModule[x].livestatus)
		{
			on[nLiveEnabled]
			break
		}
	}
	
	for(x=1;x<=length_array(btnPreview);x++)
	{
		if(prvModule[x].staticstatus)
		{
			on[nStaticEnabled]
			break
		}
	}
	
	if(nLiveEnabled and timeline_active(tlScan)) timeline_kill(tlScan)
	else if(!timeline_active(tlScan) and nStaticEnabled) timeline_create(tlScan, lScanTimes, max_length_array(lScanTimes), TIMELINE_RELATIVE, TIMELINE_REPEAT) 
	else if(timeline_active(tlScan) and !nStaticEnabled) timeline_kill(tlScan)
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
				if(prvModule[nActiveSlot].livestatus) switchvideo(prvModule[nActiveSlot].input,nMXAOutput)
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

//data_event[dvTP]
//{
//	online:
//	{
//		for(x=1;x<=length_array(subPages);x++)
//		{
//			send_command dvTP, "'^SCE-',itoa(subPages[x]),',0,',itoa(32000+x),',',itoa(32010+x),',0'"
//		}
//	}
//}

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
		if(!prvModule[get_last(chLive)].livestatus) send_command dvTP,"'^SHO-',ITOA(btnLoading[get_last(chStatic)]),',1'" //SHOW THE LOADING BUTTON
		verify_timeline()
	}
}

channel_event[vdvDevice,chLive]
{
	on:
	{
		on[prvModule[get_last(chLive)].livestatus]
		for(x=1;x<=length_array(chLive);x++) if(x<>get_last(chLive)) off[prvModule[x].livestatus]
		switchvideo(prvModule[get_last(chLive)].input,nMXAOutput)
		
		send_command dvTP,"'^SHO-',ITOA(btnLoading[get_last(chLive)]),',0'" //HIDE THE LOADING BUTTON
		verify_timeline()
	}
	off:
	{
		off[prvModule[get_last(chLive)].livestatus]
		verify_timeline()
	}
}

button_event[dvTP,btnPreview]
{
	push:
	{
		prvModule[get_last(btnPreview)].livestatus=!prvModule[get_last(btnPreview)].livestatus
		switch(prvModule[get_last(btnPreview)].livestatus)
		{
			case 1: //Turn It On
			{
				for(x=1;x<=length_array(btnPreview);x++) if(x<>get_last(btnPreview)) off[prvModule[x].livestatus]
				verify_timeline()
				switchvideo(prvModule[get_last(btnPreview)].input,nMXAOutput)
			}
			case 0: //Turn It Off
			{
				nScanNext=get_last(btnPreview)
				
				verify_timeline()
			}
		}
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

nScanActive=timeline_active(tlScan)