
aMutesTab = {
	gui = {},
	List = {}
}

function aMutesTab.Create(tab)
	if aMutesTab.gui.tab then return end
	
	aMutesTab.gui.tab = tab

	aMutesTab.gui.srch = guiCreateSearchEdit(0.01, 0.02, 0.80, 0.04, "", true, aMutesTab.gui.tab)
	aMutesTab.gui.list = guiCreateGridList(0.01, 0.07, 0.80, 0.91, true, aMutesTab.gui.tab)
	guiGridListSetSortingEnabled(aMutesTab.gui.list, false)
	aMutesTab.gui.listMsg = guiCreateElementMessageLabel(aMutesTab.gui.list)
	aMutesTab.gui.nickListClm = guiGridListAddColumn(aMutesTab.gui.list, "Name", 0.2)
	aMutesTab.gui.serialListClm = guiGridListAddColumn(aMutesTab.gui.list, "Serial", 0.1)
	aMutesTab.gui.timeListClm = guiGridListAddColumn(aMutesTab.gui.list, "Mute date", 0.25)
	aMutesTab.gui.durationListClm = guiGridListAddColumn(aMutesTab.gui.list, "Duration", 0.15)
	aMutesTab.gui.unmuteListClm = guiGridListAddColumn(aMutesTab.gui.list, "Unmute date", 0.25)
	aMutesTab.gui.adminListClm = guiGridListAddColumn(aMutesTab.gui.list, "Muted by", 0.15)
	aMutesTab.gui.reasonListClm = guiGridListAddColumn(aMutesTab.gui.list, "Reason", 0.7)
	guiGridListRegisterArrowScroll(aMutesTab.gui.list)
	guiGridListRegisterSearch(aMutesTab.gui.list, aMutesTab.gui.srch)

	aMutesTab.gui.ctext = guiCreateContextMenu()
	aMutesTab.gui.copyCtextItem = guiContextMenuAddItem(aMutesTab.gui.ctext, "Copy row")
	aMutesTab.gui.copySerialCtextItem = guiContextMenuAddItem(aMutesTab.gui.ctext, "Copy serial")
	guiSetContextMenu(aMutesTab.gui.list, aMutesTab.gui.ctext)

	aMutesTab.gui.unmuteBtn = guiCreateButton(0.82, 0.07, 0.17, 0.04, "Unmute", true, aMutesTab.gui.tab, "unmuteserial")
	aMutesTab.gui.setNickBtn = guiCreateButton(0.82, 0.12, 0.17, 0.04, "Set nick", true, aMutesTab.gui.tab, "setmutenick")
	aMutesTab.gui.setReasonBtn = guiCreateButton(0.82, 0.17, 0.17, 0.04, "Set reason", true, aMutesTab.gui.tab, "setmutereason")
	aMutesTab.gui.addMuteBtn = guiCreateButton(0.82, 0.27, 0.17, 0.04, "Add mute", true, aMutesTab.gui.tab, "muteserial")
	aMutesTab.gui.refreshBtn = guiCreateButton(0.82, 0.94, 0.17, 0.04, "Refresh", true, aMutesTab.gui.tab, "listmutes")

	addEventHandler("onClientGUIClick", aMutesTab.gui.tab, aMutesTab.onClickHandler)
	addEventHandler("onClientGUIChanged", aMutesTab.gui.srch, aMutesTab.Refresh, false)
	addEventHandler("onClientGUIClick", aMutesTab.gui.ctext, aMutesTab.onContextClickHandler)
	
	addEventHandler(EVENT_SYNC, localPlayer, aMutesTab.onSyncHandler)

	sync(SYNC_MUTE, SYNC_LIST)
end

function aMutesTab.Destroy()
	removeEventHandler(EVENT_SYNC, localPlayer, aMutesTab.onSyncHandler)
	aMutesTab.gui = {}
	aMutesTab.List = {}
end

function aMutesTab.onClickHandler(button)
	if button ~= "left" then return end

	if source == aMutesTab.gui.refreshBtn then
		aMutesTab.List = {}
		aMutesTab.Refresh()
		guiSetText(aMutesTab.gui.listMsg, "Loading...")
		sync(SYNC_MUTE, SYNC_LIST)

	elseif source == aMutesTab.gui.unmuteBtn then
		local id = aMutesTab.GetSelected()
		if not id then return messageBox("No mute row selected!", MB_ERROR) end
		local serial = aMutesTab.List[id].serial
		if not messageBox("Unmute "..serial.."?", MB_QUESTION, MB_YESNO) then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "unmuteserial", serial)

	elseif source == aMutesTab.gui.setNickBtn then
		local id = aMutesTab.GetSelected()
		if not id then return messageBox("No mute row selected!", MB_ERROR) end

		local nick = inputBox("Change mute nick", "Enter new nick for mute", aMutesTab.List[id].nick, true)
		if not nick then return end
		if nick == aMutesTab.List[id].nick then return end

		local serial = aMutesTab.List[id].serial
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setmutenick", serial, nick)

	elseif source == aMutesTab.gui.setReasonBtn then
		local id = aMutesTab.GetSelected()
		if not id then return messageBox("No mute row selected!", MB_ERROR) end

		local reason = inputBox("Change mute reason", "Enter new reason for mute", aMutesTab.List[id].reason, true)
		if not reason then return end
		if reason == aMutesTab.List[id].reason then return end

		local serial = aMutesTab.List[id].serial
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setmutereason", serial, reason)

	elseif source == aMutesTab.gui.addMuteBtn then
		local serial, nick, duration, reason = aMute.Open()
		if not serial then return end
		
		triggerServerEvent(EVENT_COMMAND, localPlayer, "muteserial", serial, nick, duration, reason)

	end
end

function aMutesTab.onContextClickHandler(button)
	local row = guiGridListGetSelectedItem(aMutesTab.gui.list)
	if row == -1 then return end

	if source == aMutesTab.gui.copyCtextItem then
		local text = ""
		for col = 1, guiGridListGetColumnCount(aMutesTab.gui.list) do
			text = text..guiGridListGetItemText(aMutesTab.gui.list, row, col).." "
		end
		setClipboard(text)
	
	elseif source == aMutesTab.gui.copySerialCtextItem then
		setClipboard(guiGridListGetItemText(aMutesTab.gui.list, row, aMutesTab.gui.serialListClm))

	end
end

aMutesTab.SyncFunctions = {
	[SYNC_LIST] = function(data)
		aMutesTab.List = data
		guiSetText(aMutesTab.gui.listMsg, "")
		aMutesTab.Refresh()
	end,
	[SYNC_SINGLE] = function(id, data)
		if not aMutesTab.List[id] then return end
		for k, v in pairs(data) do
			aMutesTab.List[id][k] = v
		end
		aMutesTab.RefreshRow(id)
	end,
	[SYNC_ADD] = function(id, data)
		if aMutesTab.List[id] then return end
		aMutesTab.List[id] = data
		aMutesTab.AddRow(id)
	end,
	[SYNC_REMOVE] = function(id)
		aMutesTab.List[id] = nil
		aMutesTab.RemoveRow(id)
	end,
}
function aMutesTab.onSyncHandler(dataType, syncType, ...)
	if dataType ~= SYNC_MUTE then return end
	aMutesTab.SyncFunctions[syncType](...)
end

function aMutesTab.GetDataString(id)
	local data = aMutesTab.List[id]
	return
		(data.nick or "")..
		(data.serial or "")..
		(data.admin or "")..
		(data.time and formatDate(data.time) or "")..
		(data.unmute ~= 0 and formatDate(data.unban) or "None")..
		(data.unmute ~= 0 and formatDuration(data.unban - data.time) or "Permanent")
end

function aMutesTab.GetSorted()
	local ids = {}
	local sortedList = {}
	for id, data in pairs(aMutesTab.List) do
		sortedList[#sortedList + 1] = {id, data.time}
	end
	table.sort(sortedList, function(a, b) return a[2] < b[2] end)
	for i, data in ipairs(sortedList) do
		ids[#ids + 1] = data[1]
	end
	return ids
end

function aMutesTab.GetSelected()
	local row = guiGridListGetSelectedItem(aMutesTab.gui.list)
	if row == -1 then return nil end
	return guiGridListGetItemData(aMutesTab.gui.list, row, 1)
end

function aMutesTab.Refresh()
	guiGridListClear(aMutesTab.gui.list)
	
	local search = string.lower(guiGetText(aMutesTab.gui.srch))
	for i, id in ipairs(aMutesTab.GetSorted()) do
		if string.find(string.lower(aMutesTab.GetDataString(id)), search, 1, true) then
			aMutesTab.AddRow(id)
		end
	end
	if guiGridListGetRowCount(aMutesTab.gui.list) > 0 then
		guiGridListSetSelectedItem(aMutesTab.gui.list, 0, 1)
	end
end

function aMutesTab.GetRow(id)
	for row = 0, guiGridListGetRowCount(aMutesTab.gui.list) - 1 do
		if guiGridListGetItemData(aMutesTab.gui.list, row, 1) == id then return row end
	end
	return nil
end

function aMutesTab.AddRow(id)
	if aMutesTab.GetRow(id) then return end

	local data = aMutesTab.List[id]
	local list = aMutesTab.gui.list
	local row = guiGridListInsertRowAfter(list, -1)
	guiGridListSetItemText(list, row, aMutesTab.gui.nickListClm, data.nick or "N/A", false, false)
	guiGridListSetItemText(list, row, aMutesTab.gui.serialListClm, data.serial or "N/A", false, false)
	guiGridListSetItemText(list, row, aMutesTab.gui.timeListClm, formatDate(data.time), false, false)
	if data.unmute == 0 then
		guiGridListSetItemText(list, row, aMutesTab.gui.durationListClm, "Permanent", false, false)
		guiGridListSetItemText(list, row, aMutesTab.gui.unmuteListClm, "None", false, false)
	else
		guiGridListSetItemText(list, row, aMutesTab.gui.durationListClm, formatDuration(data.unmute - data.time), false, false)
		guiGridListSetItemText(list, row, aMutesTab.gui.unmuteListClm, formatDate(data.unmute), false, false)
	end
	guiGridListSetItemText(list, row, aMutesTab.gui.adminListClm, data.admin or "N/A", false, false)
	guiGridListSetItemText(list, row, aMutesTab.gui.reasonListClm, data.reason or "N/A", false, false)
	guiGridListSetItemData(list, row, 1, id)
end

function aMutesTab.RemoveRow(id)
	local row = aMutesTab.GetRow(id)
	if not row then return end
	
	local selected = guiGridListGetSelectedItem(aMutesTab.gui.list)
	guiGridListRemoveRow(aMutesTab.gui.list, row)

	if selected ~= row then return end
	selected = math.clamp(selected + 1, 0, guiGridListGetRowCount(aMutesTab.gui.list)) - 1
	guiGridListSetSelectedItem(aMutesTab.gui.list, selected, 1) 
end

function aMutesTab.RefreshRow(id)
	local row = aMutesTab.GetRow(id)
	if not row then return end

	local data = aMutesTab.List[id]
	guiGridListSetItemText(aMutesTab.gui.list, row, aMutesTab.gui.nickListClm, data.nick or "N/A", false, false)
	guiGridListSetItemText(aMutesTab.gui.list, row, aMutesTab.gui.adminListClm, data.admin or "N/A", false, false)
	guiGridListSetItemText(aMutesTab.gui.list, row, aMutesTab.gui.reasonListClm, data.reason or "N/A", false, false)
end