
aPlayer = {
	gui = {},
	Thread = nil,
	Result = false
}

function aPlayer.Create()
	aPlayer.gui.form = guiCreateWindow(0, 0, 200, 300, "Select player", false)
	
	aPlayer.gui.srch = guiCreateSearchEdit(0.03, 0.08, 0.94, 0.075, "", true, aPlayer.gui.form)
	aPlayer.gui.list = guiCreateGridList(0.03, 0.16, 0.94, 0.73, true, aPlayer.gui.form)
	guiGridListSetSortingEnabled(aPlayer.gui.list, false)
	guiGridListAddColumn(aPlayer.gui.list, "Name", 1)
	guiGridListAdjustColumnWidth(aPlayer.gui.list)
	
	aPlayer.gui.acceptBtn = guiCreateButton(0.03, 0.90, 0.94, 0.075, "Accept", true, aPlayer.gui.form)
	aPlayer.gui.cancelBtn = guiCreateButton(0.03, 0.98, 0.94, 0.075, "Cancel", true, aPlayer.gui.form)

	addEventHandler("onClientGUIClick", aPlayer.gui.form, aPlayer.onClickHandler)
	addEventHandler("onClientGUIDoubleClick", aPlayer.gui.form, aPlayer.onDoubleClickHandler)
	addEventHandler("onClientGUIChanged", aPlayer.gui.srch, aPlayer.Refresh, false)
	 
	aRegister("Player", aPlayer.gui.form, aPlayer.Open, aPlayer.Close)
end

function aPlayer.Destroy()
	destroyElement(aPlayer.gui.form)
	aPlayer.gui = {}
end

function aPlayer.Open(player)
	if not aPlayer.gui.form then
		aPlayer.Create()
	end

	aPlayer.Refresh()
	guiSetVisible(aPlayer.gui.form, true)

	aPlayer.Result = false
	aPlayer.Thread = coroutine.running()
	coroutine.yield()

	aPlayer.Thread = nil
	return aPlayer.Result
end

function aPlayer.Close(destroy)
	if not aPlayer.gui.form then return end
	if destroy then
		aPlayer.Destroy()
	else
		guiSetVisible(aPlayer.gui.form, false)
	end
	if aPlayer.Thread then
		coroutine.resume(aPlayer.Thread)
	end
end

function aPlayer.onClickHandler(key)
	if key ~= "left" then return end

	if source == aPlayer.gui.acceptBtn then
		aPlayer.Accept()

	elseif source == aPlayer.gui.cancelBtn then
		aPlayer.Close()

	end
end

function aPlayer.onDoubleClickHandler(key)
	if key ~= "left" then return end

	if source == aPlayer.gui.list then
		aPlayer.Accept()

	end
end

function aPlayer.Refresh()
	guiGridListClear(aPlayer.gui.list)

	local search = string.lower(guiGetText(aPlayer.gui.srch))
	for i, player in ipairs(getElementsByType("player")) do
		local name = stripColorCodes(getPlayerName(player))
		if string.find(string.lower(name), search, 1, true) then
			local row = guiGridListAddRow(aPlayer.gui.list, name)
			guiGridListSetItemData(aPlayer.gui.list, row, 1, player)
		end
	end
	if guiGridListGetRowCount(aPlayer.gui.list) > 0 then
		guiGridListSetSelectedItem(aPlayer.gui.list, 0, 1)
	end
end

function aPlayer.GetSelected()
	local selected = guiGridListGetSelectedItem(aPlayer.gui.list)
	if selected == -1 then return nil end
	return guiGridListGetItemData(aPlayer.gui.list, selected, 1)
end

function aPlayer.Accept()
	local player = aPlayer.GetSelected()
	if not player then return end

	if not isElement(player) then
		messageBox("Selected player has left the server. List has been updated", MB_ERROR)
		aPlayer.Refresh()
		return
	end

	aPlayer.Result = player
	aPlayer.Close()
end