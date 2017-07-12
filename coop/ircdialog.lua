require "iuplua"

function ircdialog()
	-- Creates frame 1
	frm_1 = iup.frame
	{
		iup.hbox
		{
			iup.fill {},
			iup.vbox
			{
				iup.button {title = "1", size = "20x30", action = ""},
				iup.button {title = "2", size = "30x30", action = ""},
				iup.button {title = "3", size = "40x30", action = ""} ;
				-- Sets alignment and gap of vbox
				alignment = "ALEFT", gap = 10
			},
			iup.fill {}
		} ;
		-- Sets title of frame 1
		title = "ALIGNMENT = ALEFT, GAP = 10"
	}

	-- Creates frame 2
	frm_2 = iup.frame
	{
		iup.hbox
		{
			iup.fill {},
			iup.vbox
			{
				iup.button {title = "1", size = "20x30", action = ""},
				iup.button {title = "2", size = "30x30", action = ""},
				iup.button {title = "3", size = "40x30", action = ""} ;
				-- Sets alignment and margin of vbox
				alignment = "ACENTER",
			},
			iup.fill {}
		} ;
		-- Sets title of frame 1
		title = "ALIGNMENT = ACENTER"
	}

	-- Creates frame 3
	frm_3 = iup.frame
	{
		iup.hbox
		{
			iup.fill {},
			iup.vbox
			{
				iup.button {title = "1", size = "20x30", action = ""},
				iup.button {title = "2", size = "30x30", action = ""},
				iup.button {title = "3", size = "40x30", action = ""} ;
				-- Sets alignment and size of vbox
				alignment = "ARIGHT"
			},
			iup.fill {}
		} ;
		-- Sets title of frame 3
		title = "ALIGNMENT = ARIGHT"
	}

	dlg = iup.dialog
	{
		iup.vbox
		{
			frm_1,
			frm_2,
			frm_3
		} ;
		title = "IupVbox Example", size = "QUARTER"
	}

	dlg:popup()

	frm_3:destroy()
	dlg:destroy()
end
