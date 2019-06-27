
aBansTab = {
	gui = {},
	List = {}
}

function aBansTab.Create(tab)
	if aBansTab.gui.tab then return end
	
	aBansTab.gui.tab = tab

	aBansTab.gui.srch = guiCreateSearchEdit(0.01, 0.02, 0.80, 0.04, "", true, aBansTab.gui.tab)
	aBansTab.gui.list = guiCreateGridList(0.01, 0.07, 0.80, 0.91, true, aBansTab.gui.tab)
	guiGridListSetSortingEnabled(aBansTab.gui.list, false)
	aBansTab.gui.listMsg = guiCreateElementMessageLabel(aBansTab.gui.list)
	aBansTab.gui.nickListClm = guiGridListAddColumn(aBansTab.gui.list, "Name", 0.2)
	aBansTab.gui.serialListClm = guiGridListAddColumn(aBansTab.gui.list, "Serial", 0.1)
	aBansTab.gui.ipListClm = guiGridListAddColumn(aBansTab.gui.list, "IP", 0.1)
	aBansTab.gui.timeListClm = guiGridListAddColumn(aBansTab.gui.list, "Ban date", 0.25)
	aBansTab.gui.durationListClm = guiGridListAddColumn(aBansTab.gui.list, "Duration", 0.15)
	aBansTab.gui.unbanListClm = guiGridListAddColumn(aBansTab.gui.list, "Unban date", 0.25)
	aBansTab.gui.adminListClm = guiGridListAddColumn(aBansTab.gui.list, "Bant by", 0.15)
	aBansTab.gui.reasonListClm = guiGridListAddColumn(aBansTab.gui.list, "Reason", 0.7)
	guiGridListRegisterArrowScroll(aBansTab.gui.list)
	guiGridListRegisterSearch(aBansTab.gui.list, aBansTab.gui.srch)

	aBansTab.gui.ctext = guiCreateContextMenu()
	aBansTab.gui.copyCtextItem = guiContextMenuAddItem(aBansTab.gui.ctext, "Copy row")
	aBansTab.gui.copySerialCtextItem = guiContextMenuAddItem(aBansTab.gui.ctext, "Copy serial")
	aBansTab.gui.copyIPCtextItem = guiContextMenuAddItem(aBansTab.gui.ctext, "Copy IP")
	guiSetContextMenu(aBansTab.gui.list, aBansTab.gui.ctext)

	aBansTab.gui.unbanBtn = guiCreateButton(0.82, 0.07, 0.17, 0.04, "Unban", true, aBansTab.gui.tab, "unban")
	aBansTab.gui.setNickBtn = guiCreateButton(0.82, 0.12, 0.17, 0.04, "Set nick", true, aBansTab.gui.tab, "setbannick")
	aBansTab.gui.setReasonBtn = guiCreateButton(0.82, 0.17, 0.17, 0.04, "Set reason", true, aBansTab.gui.tab, "setbanreason")
	aBansTab.gui.addBanBtn = guiCreateButton(0.82, 0.27, 0.17, 0.04, "Add ban", true, aBansTab.gui.tab, "banserial")
	aBansTab.gui.refreshBtn = guiCreateButton(0.82, 0.94, 0.17, 0.04, "Refresh", true, aBansTab.gui.tab, "listbans")

	addEventHandler("onClientGUIClick", aBansTab.gui.tab, aBansTab.onClickHandler)
	addEventHandler("onClientGUIChanged", aBansTab.gui.srch, aBansTab.Refresh, false)
	addEventHandler("onClientGUIClick", aBansTab.gui.ctext, aBansTab.onContextClickHandler)
	
	addEventHandler(EVENT_SYNC, localPlayer, aBansTab.onSyncHandler)

	sync(SYNC_BAN, SYNC_LIST)
end

function aBansTab.Destroy()
	removeEventHandler(EVENT_SYNC, localPlayer, aBansTab.onSyncHandler)
	aBansTab.gui = {}
	aBansTab.List = {}
end

function aBansTab.onClickHandler(button)
	if button ~= "left" then return end

	if source == aBansTab.gui.refreshBtn then
		aBansTab.List = {}
		aBansTab.Refresh()
		guiSetText(aBansTab.gui.listMsg, "Loading...")
		sync(SYNC_BAN, SYNC_LIST)

	elseif source == aBansTab.gui.unbanBtn then
		local id = aBansTab.GetSelected()
		if not id then return messageBox("No ban selected!", MB_ERROR) end

		local serialIP = aBansTab.List[id].serial or aBansTab.List[id].ip
		if not messageBox("Unban "..serialIP.."?", MB_QUESTION, MB_YESNO) then return end

		triggerServerEvent(EVENT_COMMAND, localPlayer, "unban", serialIP)

	elseif source == aBansTab.gui.setNickBtn then
		local id = aBansTab.GetSelected()
		if not id then return messageBox("No ban selected!", MB_ERROR) end

		local nick = inputBox("Change ban nick", "Enter new nick for ban", aBansTab.List[id].nick, true)
		if not nick then return end
		if nick == aBansTab.List[id].nick then return end

		local serialIP = aBansTab.List[id].serial or aBansTab.List[id].ip
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setbannick", serialIP, nick)

	elseif source == aBansTab.gui.setReasonBtn then
		local id = aBansTab.GetSelected()
		if not id then return messageBox("No ban selected!", MB_ERROR) end

		local reason = inputBox("Change ban reason", "Enter new reason for ban", aBansTab.List[id].reason, true)
		if not reason then return end
		if reason == aBansTab.List[id].reason then return end

		local serialIP = aBansTab.List[id].serial or aBansTab.List[id].ip
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setbanreason", serialIP, reason)

	elseif source == aBansTab.gui.addBanBtn then
		local serial, ip, nick, duration, reason = aBan.Open()
		if not serial then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "banserial", serial, ip, nick, duration, reason)

	end
end

function aBansTab.onContextClickHandler(button)
	local row = guiGridListGetSelectedItem(aBansTab.gui.list)
	if row == -1 then return end

	if source == aBansTab.gui.copyCtextItem then
		local text = ""
		for col = 1, guiGridListGetColumnCount(aBansTab.gui.list) do
			text = text..guiGridListGetItemText(aBansTab.gui.list, row, col).." "
		end
		setClipboard(text)
	
	elseif source == aBansTab.gui.copySerialCtextItem then
		setClipboard(guiGridListGetItemText(aBansTab.gui.list, row, aBansTab.gui.serialListClm))

	elseif source == aBansTab.gui.copyIPCtextItem then
		setClipboard(guiGridListGetItemText(aBansTab.gui.list, row, aBansTab.gui.ipListClm))

	end
end

aBansTab.SyncFunctions = {
	[SYNC_LIST] = function(data)
		aBansTab.List = data
		guiSetText(aBansTab.gui.listMsg, "")
		aBansTab.Refresh()
	end,
	[SYNC_SINGLE] = function(id, data)
		if not aBansTab.List[id] then return end
		for k, v in pairs(data) do
			aBansTab.List[id][k] = v
		end
		aBansTab.RefreshRow(id)
	end,
	[SYNC_ADD] = function(id, data)
		if aBansTab.List[id] then return end
		aBansTab.List[id] = data
		aBansTab.AddRow(id)
	end,
	[SYNC_REMOVE] = function(id)
		aBansTab.List[id] = nil
		aBansTab.RemoveRow(id)
	end,
}
function aBansTab.onSyncHandler(dataType, syncType, ...)
	if dataType ~= SYNC_BAN then return end
	aBansTab.SyncFunctions[syncType](...)
end

function aBansTab.GetDataString(id)
	local data = aBansTab.List[id]
	return
		(data.nick or "")..
		(data.serial or "")..
		(data.ip or "")..
		(data.admin or "")..
		(data.time and formatDate(data.time) or "")..
		(data.unban ~= 0 and formatDate(data.unban) or "None")..
		(data.unban ~= 0 and formatDuration(data.unban - data.time) or "Permanent")
end

function aBansTab.GetSorted()
	local ids = {}
	local sortedList = {}
	for id, data in pairs(aBansTab.List) do
		sortedList[#sortedList + 1] = {id, data.time}
	end
	table.sort(sortedList, function(a, b) return a[2] < b[2] end)
	for i, data in ipairs(sortedList) do
		ids[#ids + 1] = data[1]
	end
	return ids
end

function aBansTab.GetSelected()
	local row = guiGridListGetSelectedItem(aBansTab.gui.list)
	if row == -1 then return nil end
	return guiGridListGetItemData(aBansTab.gui.list, row, 1)
end

function aBansTab.Refresh()
	guiGridListClear(aBansTab.gui.list)

	local search = string.lower(guiGetText(aBansTab.gui.srch))
	for i, id in ipairs(aBansTab.GetSorted()) do
		if string.find(string.lower(aBansTab.GetDataString(id)), search, 1, true) then
			aBansTab.AddRow(id)
		end
	end
	if guiGridListGetRowCount(aBansTab.gui.list) > 0 then
		guiGridListSetSelectedItem(aBansTab.gui.list, 0, 1)
	end
end

function aBansTab.GetRow(id)
	for row = 0, guiGridListGetRowCount(aBansTab.gui.list) - 1 do
		if guiGridListGetItemData(aBansTab.gui.list, row, 1) == id then return row end
	end
	return nil
end

function aBansTab.AddRow(id)
	if aBansTab.GetRow(id) then return end

	local data = aBansTab.List[id]
	local list = aBansTab.gui.list
	local row = guiGridListInsertRowAfter(list, -1)
	guiGridListSetItemText(list, row, aBansTab.gui.nickListClm, data.nick or "N/A", false, false)
	guiGridListSetItemText(list, row, aBansTab.gui.ipListClm, data.ip or "N/A", false, false)
	guiGridListSetItemText(list, row, aBansTab.gui.serialListClm, data.serial or "N/A", false, false)
	guiGridListSetItemText(list, row, aBansTab.gui.timeListClm, formatDate(data.time), false, false)
	if data.unban == 0 then
		guiGridListSetItemText(list, row, aBansTab.gui.durationListClm, "Permanent", false, false)
		guiGridListSetItemText(list, row, aBansTab.gui.unbanListClm, "None", false, false)
	else
		guiGridListSetItemText(list, row, aBansTab.gui.durationListClm, formatDuration(data.unban - data.time), false, false)
		guiGridListSetItemText(list, row, aBansTab.gui.unbanListClm, formatDate(data.unban), false, false)
	end
	guiGridListSetItemText(list, row, aBansTab.gui.adminListClm, data.admin or "N/A", false, false)
	guiGridListSetItemText(list, row, aBansTab.gui.reasonListClm, data.reason or "N/A", false, false)
	guiGridListSetItemData(list, row, 1, id)
end

function aBansTab.RemoveRow(id)
	local row = aBansTab.GetRow(id)
	if not row then return end

	local selected = guiGridListGetSelectedItem(aBansTab.gui.list)
	guiGridListRemoveRow(aBansTab.gui.list, row)

	if selected ~= row then return end
	selected = math.clamp(selected + 1, 0, guiGridListGetRowCount(aBansTab.gui.list)) - 1
	guiGridListSetSelectedItem(aBansTab.gui.list, selected, 1) 
end

function aBansTab.RefreshRow(id)
	local row = aBansTab.GetRow(id)
	if not row then return end

	local data = aBansTab.List[id]
	guiGridListSetItemText(aBansTab.gui.list, row, aBansTab.gui.nickListClm, data.nick or "N/A", false, false)
	guiGridListSetItemText(aBansTab.gui.list, row, aBansTab.gui.adminListClm, data.admin or "N/A", false, false)
	guiGridListSetItemText(aBansTab.gui.list, row, aBansTab.gui.reasonListClm, data.reason or "N/A", false, false)
end