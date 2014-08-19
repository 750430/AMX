PROGRAM_NAME='HoppGUIDE Rev6-00'


define_event

button_event[dvTP,btnGuideStart]
{
	push:
	{
		to[button.input]
	}
	release:
	{
		nActiveTP=get_last(dvTP)
		guideLast.nActiveSource=nActiveSource[nActiveTP]
		guideLast.nActiveMenu=nActiveMenu[nActiveTP]
		send_command button.input.device,"'@PPX'"
		nActiveGuidePage[nActiveTP]=1
		guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage=1
		send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].popup[1],';Help Page'"
		send_command button.input.device,"'PAGE-Help Page'"
		send_command button.input.device,"'^TXT-',itoa(btnGuidePageNum),',0,',itoa(guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage),'/',itoa(guideMain[nActiveGuidePage[nActiveTP]].nSubPages)"
		
	}
}

button_event[dvTP,btnGuideSteps]
{
	push:
	{
		nActiveTP=get_last(dvTP)
		nActiveGuidePage[nActiveTP]=get_last(btnGuideSteps)
		guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage=1
		send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].popup[1],';Help Page'"
		send_command button.input.device,"'^TXT-',itoa(btnGuidePageNum),',0,',itoa(guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage),'/',itoa(guideMain[nActiveGuidePage[nActiveTP]].nSubPages)"
	}
}

button_event[dvTP,btnGuideNext]
{
	push:
	{
		to[button.input]
	}
	release:
	{
		nActiveTP=get_last(dvTP)
		
		if(guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage<guideMain[nActiveGuidePage[nActiveTP]].nSubPages)
		{
			guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage++
			send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].popup[guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage]"
		}
		else
		{
			nActiveGuidePage[get_last(dvTP)]++
			guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage=1
			send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].popup[1]"
		}
		send_command button.input.device,"'^TXT-',itoa(btnGuidePageNum),',0,',itoa(guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage),'/',itoa(guideMain[nActiveGuidePage[nActiveTP]].nSubPages)"
	}
}

button_event[dvTP,btnGuideSeeIt]
{
	push:
	{
		send_command button.input.device,"'@PPN-',cSourcePopups[nActiveTP],';Main Page'"
		send_command button.input.device,"'@PPN-',cHeaderPopups[nActiveTP],';Main Page'"		
		if(length_string(guideMain[nActiveGuidePage[nActiveTP]].paneLeft)>0)
		{
			send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].paneLeft,';Main Page'"
		}
		else 
		{
			send_command button.input.device,"'@PPF-[paneLeft]Tabs;Main Page'"
		}
			
			
		if(length_string(guideMain[nActiveGuidePage[nActiveTP]].paneRight)>0)
		{
			send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].paneRight,';Main Page'"
		}
		else
		{
			send_command button.input.device,"'@PPF-[paneRight]Tabs;Main Page'"
		}
		
		if(length_string(guideMain[nActiveGuidePage[nActiveTP]].paneCenter)>0)
		{
			send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].paneCenter,';Main Page'"
		}
		else 
		{
			send_command button.input.device,"'@PPF-[help]Startup;Main Page'"
		}
		
		nActiveSource[nActiveTP]=guideMain[nActiveGuidePage[nActiveTP]].nActiveSource
		nActiveMenu[nActiveTP]=guideMain[nActiveGuidePage[nActiveTP]].nActiveMenu
		if(nActiveSource[nActiveTP]) srcMain[nActiveSource[nActiveTP]].activesubmenu[nActiveTP]=guideMain[nActiveGuidePage[nActiveTP]].nActiveSubMenu
		if(nActiveMenu[nActiveTP]) mnuMain[nActiveMenu[nActiveTP]].activesubmenu[nActiveTP]=guideMain[nActiveGuidePage[nActiveTP]].nActiveSubMenu
		
		send_command dvTP,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].guidepopup,';Main Page'"
		send_command dvTp,"'PAGE-Main Page'"
	}
}

button_event[dvTP,btnGuideSeeItNext]
{
	push:
	{
		to[button.input]
	}
	release:
	{
		nActiveTP=get_last(dvTP)
		nActiveGuidePage[get_last(dvTP)]++
		if(length_string(guideMain[nActiveGuidePage[nActiveTP]].paneLeft)>0)
		{
			if(!compare_string(guideMain[nActiveGuidePage[nActiveTP]].paneLeft,guideMain[nActiveGuidePage[nActiveTP]-1].paneLeft))
			{
				send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].paneLeft,';Main Page'"
			}
		}
		else 
		{
			send_command button.input.device,"'@PPF-[paneLeft]Tabs;Main Page'"
		}
			
			
		if(length_string(guideMain[nActiveGuidePage[nActiveTP]].paneRight)>0)
		{
			if(!compare_string(guideMain[nActiveGuidePage[nActiveTP]].paneRight,guideMain[nActiveGuidePage[nActiveTP]-1].paneRight))
			{
				send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].paneRight,';Main Page'"
			}
		}
		else
		{
			send_command button.input.device,"'@PPF-[paneRight]Tabs;Main Page'"
		}
		
		if(length_string(guideMain[nActiveGuidePage[nActiveTP]].paneCenter)>0)
		{
			if(!compare_string(guideMain[nActiveGuidePage[nActiveTP]].paneCenter,guideMain[nActiveGuidePage[nActiveTP]-1].paneCenter))
			{
				send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].paneCenter,';Main Page'"
			}
		}
		else 
		{
			send_command button.input.device,"'@PPF-[help]Startup;Main Page'"
		}
		
		nActiveSource[nActiveTP]=guideMain[nActiveGuidePage[nActiveTP]].nactivesource
		nActiveMenu[nActiveTP]=guideMain[nActiveGuidePage[nActiveTP]].nactivemenu
		if(nActiveSource[nActiveTP]) srcMain[nActiveSource[nActiveTP]].activesubmenu[nActiveTP]=guideMain[nActiveGuidePage[nActiveTP]].nActiveSubMenu
		if(nActiveMenu[nActiveTP]) mnuMain[nActiveMenu[nActiveTP]].activesubmenu[nActiveTP]=guideMain[nActiveGuidePage[nActiveTP]].nActiveSubMenu
		
		send_command dvTP,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].guidepopup,';Main Page'"
	}
}

button_event[dvTP,btnGuideBack]
{
	push:
	{
		send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].popup[1],';Help Page'"
		send_command button.input.device,"'PAGE-Help Page'"
	}
}

button_event[dvTP,btnGuideExit]
{
	push:
	{
		nActiveTP=get_last(dvTP)
		off[nActiveGuidePage[nActiveTP]]
		off[nActiveSource[nActiveTP]]
		off[nActiveMenu[nActiveTP]]
		send_command button.input.device,"'@PPX'"
		send_command button.input.device,"'@PPN-',cSourcePopups[nActiveTP],';Main Page'"
		send_command button.input.device,"'@PPN-',cHeaderPopups[nActiveTP],';Main Page'"	
		show_startup_instructions(nActiveTP)
		send_command button.input.device,"'PAGE-Main Page'"
	}
}