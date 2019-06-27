
aTeam = {
	gui = {}
}

function aTeam.Create()
	aTeam.gui.form = guiCreateWindow(0, 0, 300, 250, "Player Team Management", false)
	
	aTeam.gui.infoLbl =
		guiCreateLabel(0.03, 0.09, 0.94, 0.07, "Select a team from the list or create a new one", true, aTeam.gui.form)
	guiLabelSetHorizontalAlign(aTeam.gui.infoLbl, "center")
	
	aTeam.gui.list = guiCreateGridList(0.03, 0.18, 0.50, 0.71, true, aTeam.gui.form)
	guiGridListAddColumn(aTeam.gui.list, "Name", 0.85)

	aTeam.gui.refreshBtn = guiCreateButton(0.03, 0.90, 0.50, 0.08, "Refresh", true, aTeam.gui.form)
	aTeam.gui.newBtn = guiCreateButton(0.55, 0.18, 0.42, 0.09, "New Team", true, aTeam.gui.form, "createteam")
	aTeam.gui.deleteBtn = guiCreateButton(0.55, 0.28, 0.42, 0.09, "Delete Team", true, aTeam.gui.form, "destroyteam")
	
	aTeam.gui.nameLbl = guiCreateLabel(0.55, 0.19, 0.42, 0.07, "Team Name:", true, aTeam.gui.form)
	aTeam.gui.nameEdit = guiCreateEdit(0.55, 0.26, 0.42, 0.10, "", true, aTeam.gui.form)

	aTeam.gui.colorLbl = guiCreateLabel(0.55, 0.37, 0.42, 0.11, "Color:", true, aTeam.gui.form)
	guiCreateColorPicker(0.70, 0.37, 0.27, 0.11, 255, 0, 0, true, aTeam.gui.form)
	aTeam.gui.redLbl = guiCreateLabel(0.70, 0.37, 0.42, 0.11, "R:", true, aTeam.gui.form)
	aTeam.gui.greenLbl = guiCreateLabel(0.70, 0.48, 0.42, 0.11, "G:", true, aTeam.gui.form)
	aTeam.gui.blueLbl = guiCreateLabel(0.70, 0.59, 0.42, 0.11, "B:", true, aTeam.gui.form)
	aTeam.gui.redEdit = guiCreateEdit(0.80, 0.36, 0.15, 0.10, "0", true, aTeam.gui.form)
	aTeam.gui.greenEdit = guiCreateEdit(0.80, 0.47, 0.15, 0.10, "0", true, aTeam.gui.form)
	aTeam.gui.blueEdit = guiCreateEdit(0.80, 0.58, 0.15, 0.10, "0", true, aTeam.gui.form)

	aTeam.gui.createBtn = guiCreateButton(0.55, 0.73, 0.20, 0.09, "Create", true, aTeam.gui.form, "createteam")
	aTeam.gui.cancelBtn = guiCreateButton(0.77, 0.73, 0.20, 0.09, "Cancel", true, aTeam.gui.form)
	aTeam.gui.acceptBtn = guiCreateButton(0.55, 0.88, 0.20, 0.09, "Select", true, aTeam.gui.form)
	aTeam.gui.closeBtn = guiCreateButton(0.77, 0.88, 0.20, 0.09, "Close", true, aTeam.gui.form)

	addEventHandler("onClientGUIClick", aTeam.gui.form, aTeam.gui.onClickHandler)
	addEventHandler("onClientGUIDoubleClick", aTeam.gui.form, aTeam.gui.onDoubleClickHandler)
	
	aRegister("PlayerTeam", aTeam.gui.form, aTeam.Open, aTeam.Close)
end

function aTeam.Destroy()
	destroyElement(aTeam.gui.form)
	aTeam.gui = {}
end

function aTeam.Open()
	if not aTeam.gui.form then
		aTeam.Create()
	end
	aTeam.Refresh()
	aTeam.ShowNew(false)
	guiSetVisible(aTeam.gui.form, true)
end

function aTeam.Close(destroy)
	if not aTeam.gui.form then return end
	if destroy then
		aTeam.Destroy()
	else
		guiSetVisible(aTeam.gui.form, false)
	end
end

function aTeam.onClickHandler(key)
	if key ~= "left" then return end

	if (source == aTeam.gui.newBtn) then
		aTeam.ShowNew(true)
	elseif (source == aTeam.gui.refreshBtn) then
		aTeam.Refresh()
	elseif (source == aTeam.gui.deleteBtn) then
		if (guiGridListGetSelectedItem(aTeam.gui.list) == -1) then
			messageBox("No team selected!", MB_WARNING)
		else
			local team = guiGridListGetItemData(aTeam.gui.list, guiGridListGetSelectedItem(aTeam.gui.list), 1)
			if (messageBox('Are you sure to delete "' .. getTeamName(team) .. '"?', MB_QUESTION, MB_YESNO)) then
				triggerServerEvent("aTeam", localPlayer, "destroyteam", team)
			end
		end
		setTimer(aTeam.Refresh, 2000, 1)
	elseif (source == aTeam.gui.createBtn) then
		local team = guiGetText(aTeam.gui.nameEdit)
		if ((team == nil) or (team == false) or (team == "")) then
			messageBox("Enter the team name!", MB_WARNING)
		elseif (getTeamFromName(team)) then
			messageBox("A team with this name already exists", MB_ERROR)
		else
			triggerServerEvent(
				"aTeam",
				localPlayer,
				"createteam",
				team,
				guiGetText(aTeam.gui.redEdit),
				guiGetText(aTeam.gui.greenEdit),
				guiGetText(aTeam.gui.blueEdit)
			)
			aTeam.ShowNew(false)
		end
		setTimer(aTeam.Refresh, 2000, 1)
	elseif (source == aTeam.gui.nameEdit) then
		guiSetInputEnabled(true)
	elseif (source == aTeam.gui.cancelBtn) then
		aTeam.ShowNew(false)
	elseif (source == aTeam.gui.acceptBtn) then
		if (guiGridListGetSelectedItem(aTeam.gui.list) == -1) then
			messageBox("No team selected!", MB_WARNING)
		else
			local team = guiGridListGetItemData(aTeam.gui.list, guiGridListGetSelectedItem(aTeam.gui.list), 1)
			triggerServerEvent("aPlayer", localPlayer, getSelectedPlayer(), "setteam", team)
			guiSetVisible(aTeam.gui.form, false)
		end
	elseif (source == aTeam.gui.closeBtn) then
		aTeam.Close(false)
	end
end

function aTeam.onDoubleClickHandler(button)
	if button ~= "left" then return end
	
	if (source == aTeam.gui.list) then
		if (guiGridListGetSelectedItem(aTeam.gui.list) ~= -1) then
			local team = guiGridListGetItemText(aTeam.gui.list, guiGridListGetSelectedItem(aTeam.gui.list), 1)
			triggerServerEvent("aPlayer", localPlayer, getSelectedPlayer(), "setteam", getTeamFromName(team))
			aPlayerTeamClose(false)
		end
	end
end

function aTeam.ShowNew(bool)
	guiSetVisible(aTeam.gui.newBtn, not bool)
	guiSetVisible(aTeam.gui.deleteBtn, not bool)
	guiSetVisible(aTeam.gui.nameLbl, bool)
	guiSetVisible(aTeam.gui.nameEdit, bool)
	guiSetVisible(aTeam.gui.colorLbl, bool)
	guiSetVisible(aTeam.gui.redLbl, bool)
	guiSetVisible(aTeam.gui.greenLbl, bool)
	guiSetVisible(aTeam.gui.blueLbl, bool)
	guiSetVisible(aTeam.gui.redEdit, bool)
	guiSetVisible(aTeam.gui.greenEdit, bool)
	guiSetVisible(aTeam.gui.blueEdit, bool)
	guiSetVisible(aTeam.gui.createBtn, bool)
	guiSetVisible(aTeam.gui.cancelBtn, bool)
end

function aTeam.Refresh()
	if (aTeam.gui.list) then
		guiGridListClear(aTeam.gui.list)
		for id, team in ipairs(getElementsByType("team")) do
			local row = guiGridListAddRow(aTeam.gui.list)
			local r, g, b = getTeamColor(team)
			guiGridListSetItemText(aTeam.gui.list, row, 1, getTeamName(team), false, false)
			guiGridListSetItemColor(aTeam.gui.list, row, 1, r, g, b)
			guiGridListSetItemData(aTeam.gui.list, row, 1, team)
		end
	end
end
