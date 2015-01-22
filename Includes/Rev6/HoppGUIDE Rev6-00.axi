PROGRAM_NAME='HoppGUIDE Rev6-00'

define_event

button_event[dvTP_GUIDE,GUIDE_START]
{
	push:
	{
		to[button.input]
		nActiveTP=get_last(dvTP)
		nActiveGuidePage[nActiveTP]=1
		guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage=1
		
		send_command button.input.device,"'^TXT-',itoa(GUIDE_PAGE_NUM),',0,',itoa(guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage),'/',itoa(guideMain[nActiveGuidePage[nActiveTP]].nSubPages)"
		send_command button.input.device,"'^TXT-',itoa(GUIDE_PAGE_NAME),',0,',guideMain[nActiveGuidePage[nActiveTP]].name"
		
		for(x=1;x<=10;x++) 
		{
			if(x<=guidePages) send_command button.input.device,"'^TXT-',itoa(GUIDE_STEPS[x]),',0,',guideMain[x].name"
			else send_command button.input.device,"'^TXT-',itoa(GUIDE_STEPS[x]),',0,'"
		}
		for(y=1;y<=10;y++) 
		{
			
			for(x=1;x<=5;x++) 
			{
				if(y>guidePages) hide_button(dvTP_GUIDE,GUIDE_STEP_DOTS[y][x])
				else if(x<=guideMain[y].nSubPages) show_button(dvTP_GUIDE,GUIDE_STEP_DOTS[y][x])
				else hide_button(dvTP_GUIDE,GUIDE_STEP_DOTS[y][x])
			}
		}
		for(y=1;y<=10;y++) 
		{
			if(y<=guidePages) show_button(dvTP_GUIDE,GUIDE_DIVIDERS[y])
			else hide_button(dvTP_GUIDE,GUIDE_DIVIDERS[y])
		}
		
		if(guideMain[1].guidepopup) show_button(dvTP_GUIDE,GUIDE_SHOW_ME)
		else hide_button(dvTP_GUIDE,GUIDE_SHOW_ME)
		
		disable_button(dvTP_GUIDE,GUIDE_BACK)
	}
	release:
	{
		send_command button.input.device,"'@PPX'"
		send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].popup[1],';Help Page'"
		send_command button.input.device,"'PAGE-Help Page'"
	}
}

button_event[dvTP_GUIDE,GUIDE_STEPS]
{
	push:
	{
		nActiveTP=get_last(dvTP)
		if(nActiveGuidePage[nActiveTP]=get_last(GUIDE_STEPS) and guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage<guideMain[nActiveGuidePage[nActiveTP]].nSubPages)
		{
			guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage++
		}
		else
		{
			nActiveGuidePage[nActiveTP]=get_last(GUIDE_STEPS)
			guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage=1
		}
		send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].popup[guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage],';Help Page'"
		send_command button.input.device,"'^TXT-',itoa(GUIDE_PAGE_NUM),',0,',itoa(guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage),'/',itoa(guideMain[nActiveGuidePage[nActiveTP]].nSubPages)"
		send_command button.input.device,"'^TXT-',itoa(GUIDE_PAGE_NAME),',0,',guideMain[nActiveGuidePage[nActiveTP]].name"
		if(guideMain[nActiveGuidePage[nActiveTP]].guidepopup) show_button(dvTP_GUIDE,GUIDE_SHOW_ME)
		else hide_button(dvTP_GUIDE,GUIDE_SHOW_ME)
		if(nActiveGuidePage[nActiveTP]<guidePages) 
		{
			enable_button(dvTP_GUIDE,GUIDE_NEXT)
			show_button(dvTP_GUIDE,GUIDE_PAGE_NUM)
		}
		else 
		{
			disable_button(dvTP_GUIDE,GUIDE_NEXT)
			hide_button(dvTP_GUIDE,GUIDE_PAGE_NUM)
		}
		
		if(nActiveGuidePage[nActiveTP]=1 and guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage=1) disable_button(dvTP_GUIDE,GUIDE_BACK)
		else enable_button (dvTP_GUIDE,GUIDE_BACK)
	}
}

button_event[dvTP_GUIDE,GUIDE_NEXT]
{
	push:
	{
		to[button.input]
	}
	release:
	{
		nActiveTP=get_last(dvTP)
		
		if(nActiveGuidePage[nActiveTP]<max_length_array(guideMain))
		{
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
			send_command button.input.device,"'^TXT-',itoa(GUIDE_PAGE_NUM),',0,',itoa(guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage),'/',itoa(guideMain[nActiveGuidePage[nActiveTP]].nSubPages)"
			send_command button.input.device,"'^TXT-',itoa(GUIDE_PAGE_NAME),',0,',guideMain[nActiveGuidePage[nActiveTP]].name"
			
			if(guideMain[nActiveGuidePage[nActiveTP]].guidepopup) show_button(dvTP_GUIDE,GUIDE_SHOW_ME)
			else hide_button(dvTP_GUIDE,GUIDE_SHOW_ME)
			
			if(nActiveGuidePage[nActiveTP]<guidePages) 
			{
				enable_button(dvTP_GUIDE,GUIDE_NEXT)
				show_button(dvTP_GUIDE,GUIDE_PAGE_NUM)
			}
			else 
			{
				disable_button(dvTP_GUIDE,GUIDE_NEXT)
				hide_button(dvTP_GUIDE,GUIDE_PAGE_NUM)
			}
			
			if(nActiveGuidePage[nActiveTP]=1 and guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage=1) disable_button(dvTP_GUIDE,GUIDE_BACK)
			else enable_button (dvTP_GUIDE,GUIDE_BACK)
		}
	}
}

button_event[dvTP_GUIDE,GUIDE_BACK]
{
	push:
	{
		to[button.input]
	}
	release:
	{
		nActiveTP=get_last(dvTP)
		
		if(nActiveGuidePage[nActiveTP]>1 or (nActiveGuidePage[nActiveTP]=1 and guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage>1))
		{
			if(guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage>1)
			{
				guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage--
				send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].popup[guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage]"
			}
			else
			{
				nActiveGuidePage[get_last(dvTP)]--
				guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage=guideMain[nActiveGuidePage[nActiveTP]].nSubPages
				send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].popup[guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage]"
			}
			send_command button.input.device,"'^TXT-',itoa(GUIDE_PAGE_NUM),',0,',itoa(guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage),'/',itoa(guideMain[nActiveGuidePage[nActiveTP]].nSubPages)"
			send_command button.input.device,"'^TXT-',itoa(GUIDE_PAGE_NAME),',0,',guideMain[nActiveGuidePage[nActiveTP]].name"
			
			if(guideMain[nActiveGuidePage[nActiveTP]].guidepopup) show_button(dvTP_GUIDE,GUIDE_SHOW_ME)
			else hide_button(dvTP_GUIDE,GUIDE_SHOW_ME)
			
			if(nActiveGuidePage[nActiveTP]<guidePages) 
			{
				enable_button(dvTP_GUIDE,GUIDE_NEXT)
				show_button(dvTP_GUIDE,GUIDE_PAGE_NUM)
			}
			else 
			{
				disable_button(dvTP_GUIDE,GUIDE_NEXT)
				hide_button(dvTP_GUIDE,GUIDE_PAGE_NUM)
			}
			
			if(nActiveGuidePage[nActiveTP]=1 and guideMain[nActiveGuidePage[nActiveTP]].nCurrentSubPage=1) disable_button(dvTP_GUIDE,GUIDE_BACK)
			else enable_button (dvTP_GUIDE,GUIDE_BACK)
		}
	}
}

button_event[dvTP_GUIDE,GUIDE_SHOW_ME]
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
		#IF_DEFINED nDisplaySource
		nDisplaySource[nActiveTP]=guideMain[nActiveGuidePage[nActiveTP]].nActiveSource
		if(nActiveSource[nActiveTP]) srcMain[nDisplaySource[nActiveTP]].activesubmenu[nActiveTP]=guideMain[nActiveGuidePage[nActiveTP]].nActiveSubMenu
		#END_IF
		if(nActiveMenu[nActiveTP]) mnuMain[nActiveMenu[nActiveTP]].activesubmenu[nActiveTP]=guideMain[nActiveGuidePage[nActiveTP]].nActiveSubMenu
		
		send_command dvTP,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].guidepopup,';Main Page'"
		send_command dvTp,"'PAGE-Main Page'"
	}
}

button_event[dvTP_GUIDE,GUIDE_RETURN]
{
	push:
	{
		send_command button.input.device,"'PAGE-Help Page'"
	}
}

button_event[dvTP_GUIDE,GUIDE_EXIT]
{
	push:
	{
		nActiveTP=get_last(dvTP)
		off[nActiveGuidePage[nActiveTP]]
		off[nActiveSource[nActiveTP]]
		off[nActiveMenu[nActiveTP]]
		send_command button.input.device,"'@PPX'"
		
		#IF_DEFINED btnRoomConfig
		do_push(dvTP[nActiveTP],btnRoomConfig[nActiveRoomConfig])
		#ELSE
		#IF_DEFINED btnStart
		do_push(dvTP[nActiveTP],btnStart)
		#ELSE
		send_command button.input.device,"'PAGE-Main Page'"
		#END_IF
		#END_IF

	}
}