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
		nActiveGuidePage[get_last(dvTP)]=1
		send_command button.input.device,"'@PPX'"
		send_command button.input.device,"'PAGE-Title Page'"
		send_command button.input.device,"'@PPN-',guideMain[1].guidepopup"
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
		nActiveGuidePage[get_last(dvTP)]++

		if(guideMain[nActiveGuidePage[nActiveTP]].page='Main Page')
		{	
			if(!compare_string(guideMain[nActiveGuidePage[nActiveTP]].page,guideMain[nActiveGuidePage[nActiveTP]-1].page))
			{
				send_command button.input.device,"'@PPN-',cSourcePopups[nActiveTP],';Main Page'"
				send_command button.input.device,"'@PPN-',cHeaderPopups[nActiveTP],';Main Page'"		
				send_command button.input.device,"'PAGE-Main Page'"
			}
			
			if(length_string(guideMain[nActiveGuidePage[nActiveTP]].paneLeft)>0)
			{
				send_command button.input.device,"'!!JDM - A'"
				send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].paneLeft,';Main Page'"
			}
			else 
			{
				send_command button.input.device,"'!!JDM - B'"
				send_command button.input.device,"'@PPF-[paneLeft]Tabs'"
			}
				
				
			if(length_string(guideMain[nActiveGuidePage[nActiveTP]].paneRight)>0)
			{
				send_command button.input.device,"'!!JDM - C'"
				send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].paneRight,';Main Page'"
			}
			else
			{
				send_command button.input.device,"'!!JDM - D'"
				send_command button.input.device,"'@PPF-[paneRight]Tabs'"
			}
			
			if(length_string(guideMain[nActiveGuidePage[nActiveTP]].popup)>0)
			{
				send_command button.input.device,"'!!JDM - E'"
				send_command button.input.device,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].popup,';Main Page'"
			}
			else 
			{
				send_command button.input.device,"'!!JDM - F'"
				send_command button.input.device,"'@PPF-[help]Startup'"
			}

		}
		
		send_command dvTP,"'@PPN-',guideMain[nActiveGuidePage[nActiveTP]].guidepopup,';',guideMain[nActiveGuidePage[nActiveTP]].page"

	}
}

button_event[dvTP,btnGuideExit]
{
	push:
	{
		off[nActiveGuidePage[get_last(dvTP)]]
		send_command button.input.device,"'@PPX'"
		send_command button.input.device,"'PAGE-Title Page'"
	}
}