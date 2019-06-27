
aReports = {
	gui = {},
	List = {},
	RequestedScreenShots = {}
}

function aReports.Create()
	aReports.gui.form = guiCreateWindow(0, 0, 560, 350, "View reports", false)

	aReports.gui.list = guiCreateGridList(0.02, 0.07, 0.40, 0.83, true, aReports.gui.form)
	guiGridListSetSortingEnabled(aReports.gui.list, false)
	guiGridListAddColumn(aReports.gui.list, "Author", 0.5)
	guiGridListAddColumn(aReports.gui.list, "Date", 0.3)
	aReports.gui.listMsg = guiCreateElementMessageLabel(aReports.gui.list)
	aReports.gui.hideReadChk = guiCreateCheckBox(0.02, 0.92, 0.20, 0.05, "Hide read", false, true, aReports.gui.form)
	aReports.gui.soundChk = guiCreateCheckBox(0.21, 0.92, 0.20, 0.05, "Play Sound", false, true, aReports.gui.form)
	aReports.gui.outputChatChk = guiCreateCheckBox(0.42, 0.92, 0.20, 0.05, "Output", false, true, aReports.gui.form)
	guiCheckBoxSetSelected(aReports.gui.hideReadChk, aGetSetting("reportHideRead") == true)
	guiCheckBoxSetSelected(aReports.gui.soundChk, aGetSetting("reportSound") ~= false)
	guiCheckBoxSetSelected(aReports.gui.outputChatChk, aGetSetting("reportOutput") ~= false)

	aReports.gui.chatBtn = guiCreateButton(0.84, 0.14, 0.15, 0.055, "Chat history", true, aReports.gui.form)
	aReports.gui.authorLbl = guiCreateLabel(0.43, 0.10, 0.4, 0.54, "Author:", true, aReports.gui.form)
	aReports.gui.dateLbl = guiCreateLabel(0.43, 0.15, 0.4, 0.54, "Date:", true, aReports.gui.form)
	aReports.gui.textMemo = guiCreateMemo(0.43, 0.21, 0.53, 0.35, "", true, aReports.gui.form)
	aReports.gui.textMsg = guiCreateElementMessageLabel(aReports.gui.textMemo)

	aReports.gui.screensPane = guiCreateScrollPane(0.43, 0.57, 0.53, 0.32, true, aReports.gui.form)
	guiSetProperty(aReports.gui.screensPane, "ForceVertScrollbar", "True")
	guiSetVisible(aReports.gui.screensPane, false)
	aReports.gui.screens = {}
	aReports.gui.screensBtn = guiCreateButton(0.43, 0.57, 0.53, 0.32, "Screenshots...", true, aReports.gui.form)

	aReports.gui.deleteBtn = guiCreateButton(0.84, 0.07, 0.15, 0.055, "Delete", true, aReports.gui.form, "deletereport")
	aReports.gui.closeBtn = guiCreateButton(0.84, 0.92, 0.15, 0.055, "Close", true, aReports.gui.form)

	addEventHandler("onClientGUIClick", aReports.gui.form, aReports.onClickHandler)
	addEventHandler("onClientResourceStop", resourceRoot, aReports.ClearCache)
	addEventHandler("onClientResourceStop", resourceRoot, aReports.SaveSettings)
	
	addEventHandler(EVENT_SYNC, localPlayer, aReports.onSyncHandler)

	aReports.SetContentMessage("N/A")
	guiSetText(aReports.gui.listMsg, "Loading...")
	sync(SYNC_REPORT, SYNC_LIST)

	aRegister("Reports", aReports.gui.form, aReports.Open, aReports.Close)
end

function aReports.Destroy()
	removeEventHandler(EVENT_SYNC, localPlayer, aReports.onSyncHandler)
	removeEventHandler("onClientResourceStop", resourceRoot, aReports.SaveSettings)
	removeEventHandler("onClientResourceStop", resourceRoot, aReports.ClearCache)
	aReports.SaveSettings()
	destroyElement(aReports.gui.form)
	aReports.gui = {}
	aReports.ClearCache()
end

function aReports.Open()
	if not aReports.gui.form then
		aReports.Create()
	end
	guiSetVisible(aReports.gui.form, true)
end

function aReports.Close(destroy)
	if not aReports.gui.form then return end
	if destroy then
		aReports.Destroy()
	else
		guiSetVisible(aReports.gui.form, false)
	end
end

aReports.SyncFunctions = {
	[SYNC_LIST] = function(list)		
		aReports.List = list
		guiSetText(aReports.gui.listMsg, "")
		aReports.Refresh()
		aPlayersTab.RefreshReports()
	end,
	[SYNC_SINGLE] = function(id, data)
		if not aReports.List[id] then return end
		for k, v in pairs(data) do
			aReports.List[id][k] = v
		end
		aReports.RefreshRow(id)
		aPlayersTab.RefreshReports()
	end,
	[SYNC_ADD] = function(id, data)
		if aReports.List[id] then return end 
		aReports.List[id] = data
		aReports.AddRow(id)
		aPlayersTab.RefreshReports()
		if guiCheckBoxGetSelected(aReports.gui.outputChatChk) then
			aReports.OutputNewReportMessage(data)
		end
	end,
	[SYNC_REMOVE] = function(id)
		aReports.DeleteScreenShots(id)
		aReports.List[id] = nil
		aReports.RemoveRow(id)
		aPlayersTab.RefreshReports()
	end,
	[SYNC_BIGDATA] = function(id, number, screenshot)
		for i, data in ipairs(aReports.RequestedScreenShots) do
			if data.id == id and data.number == number then
				table.remove(aReports.RequestedScreenShots, i)
				break
			end
		end
		if not aReports.List[id] then return end

		aReports.SaveScreenShot(id, number, screenshot)
		if aReports.GetSelected() == id then
			aReports.RefreshReportScreenShot(number)
		end
	end
}
function aReports.onSyncHandler(dataType, syncType, ...)
	if dataType ~= SYNC_REPORT then return end
	aReports.SyncFunctions[syncType](...)
end

function aReports.onClickHandler(key)
	if key ~= "left" then return end

	if source == aReports.gui.list then
		aReports.RefreshReport()
		aReports.RefreshRead()
		local id = aReports.GetSelected()
		if not id then return end
		if not aReports.List[id].read and hasPermissionTo("command.readreport") then
			triggerServerEvent(EVENT_COMMAND, localPlayer, "readreport", id)
		end

	elseif source == aReports.gui.hideReadChk then
		aReports.Refresh()

	elseif source == aReports.gui.deleteBtn then
		local id = aReports.GetSelected()
		if not id then return messageBox("No message selected!", MB_ERROR) end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "deletereport", id)

	elseif source == aReports.gui.screensBtn then
		local id = aReports.GetSelected()
		aReports.RequestScreenShots(id)
		aReports.RefreshReportScreenShots()

	--[[
	elseif source == aReports.gui.chatBtn then
		local id = aReports.GetSelected()
		if not id then return messageBox("No message selected!", MB_ERROR) end
		aReports.ShowChat(aReports.List[id].chat)
	]]--

	elseif getElementData(source, "type") == "view" then
		local id = aReports.GetSelected()
		local number = getElementData(source, "number")
		aViewScreenShot.Open(aReports.GetScreenShot(id, number))

	elseif source == aReports.gui.closeBtn then
		aReports.Close()

	end
end

function aReports.OutputNewReportMessage(data)
	-- aColors
	outputChatBox(LOG_PREFIX..": new report from "..stripColorCodes(data.author), 255, 127, 63)
	if guiCheckBoxGetSelected(aReports.gui.soundChk) then
		playSoundFrontEnd(18)
	end
end

function aReports.ClearCache()
	aReports.RequestedScreenShots = {}
	for id, data in pairs(aReports.List) do
		aReports.DeleteScreenShots(id)
	end
end

function aReports.IsScreenShotRequested(id, number)
	for i, data in ipairs(aReports.RequestedScreenShots) do
		if data.id == id and data.number == number then return true end
	end
	return false
end

function aReports.RequestScreenShot(id, number)
	if aReports.IsScreenShotRequested(id, number) then return end

	local data = {}
	data.id = id
	data.number = number
	table.insert(aReports.RequestedScreenShots, data)
	sync(SYNC_REPORT, SYNC_BIGDATA, id, number)
end

function aReports.RequestScreenShots(id)
	for number = 1, aReports.List[id].screenshots do
		aReports.RequestScreenShot(id, number)
	end
end

function aReports.GetScreenShot(id, number)
	local data = aReports.List[id]
	if not data then return false end
	if not (data.screenshots and data.screenshots > 0) then return false end
	if number > data.screenshots then return false end
	
	local hash = crc32(data.serial..data.time..data.text)
	local path = "report_screenshots/"..hash.."_"..number..".jpg"
	if not fileExists(path) then return nil end

	return path
end

function aReports.SaveScreenShot(id, number, screenshot)
	local data = aReports.List[id]
	if not data then return end

	local hash = crc32(data.serial..data.time..data.text)
	local path = "report_screenshots/"..hash.."_"..number..".jpg"
	if fileExists(path) then
		fileDelete(path)
	end
	local file = fileCreate(path)
	if not file then return end

	fileWrite(file, screenshot)
	fileClose(file)

	--local fileNode = xmlLoadFile("report_screenshots/list.xml")
	--if not fileNode then fileNode = xmlCreateFile("report_screenshots/list.xml", "screenshots") end
end

function aReports.DeleteScreenShots(id)
	local data = aReports.List[id]
	if not data then return end
	if not (data.screenshots and data.screenshots > 0) then return end

	local hash = crc32(data.serial..data.time..data.text)
	for number = 1, data.screenshots do
		local path = "report_screenshots/"..hash.."_"..number..".jpg"
		if fileExists(path) then
			fileDelete(path)
		end
	end
end

function aReports.IsAnyScreenShotLoadedOrRequested(id)
	for number = 1, aReports.List[id].screenshots do
		if aReports.GetScreenShot(id, number) then return true end
	end
	for i, data in ipairs(aReports.RequestedScreenShots) do
		if data.id == id then return true end
	end
	return false
end

function aReports.GetSorted()
	local ids = {}
	local sortedList = {}
	for id, data in pairs(aReports.List) do
		sortedList[#sortedList + 1] = {id, data.time}
	end
	table.sort(sortedList, function(a, b) return a[2] < b[2] end)
	for i, data in ipairs(sortedList) do
		ids[#ids + 1] = data[1]
	end
	return ids
end

function aReports.GetSelected()
	local row = guiGridListGetSelectedItem(aReports.gui.list)
	if row == -1 then return nil end
	return guiGridListGetItemData(aReports.gui.list, row, 1)
end

function aReports.GetRow(id)
	for row = 0, guiGridListGetRowCount(aReports.gui.list) - 1 do
		if guiGridListGetItemData(aReports.gui.list, row, 1) == id then return row end
	end
	return nil
end

function aReports.SetContentMessage(message)
	message = message or ""
	guiSetText(aReports.gui.authorLbl, "Author: "..message)
	guiSetText(aReports.gui.dateLbl, "Date: "..message)
	guiSetText(aReports.gui.textMsg, message)
end

function aReports.Refresh()
	guiGridListClear(aReports.gui.list)

	local hideRead = guiCheckBoxGetSelected(aReports.gui.hideReadChk)
	for i, id in ipairs(aReports.GetSorted()) do
		if (not hideRead) or (hideRead and not aReports.List[id].read) then
			aReports.AddRow(id)
		end
	end
	aReports.RefreshReport()
end

function aReports.RefreshRead()
	if not guiCheckBoxGetSelected(aReports.gui.hideReadChk) then return end
	local selected = aReports.GetSelected()
	for row = guiGridListGetRowCount(aReports.gui.list) - 1, 0, -1  do
		local id = guiGridListGetItemData(aReports.gui.list, row, 1)
		if id ~= selected and aReports.List[id].read then
			guiGridListRemoveRow(aReports.gui.list, row)
		end
	end
end

function aReports.RefreshReport()
	aReports.RefreshReportScreenShots()

	guiSetText(aReports.gui.textMemo, "")
	aReports.SetContentMessage("N/A")

	local id = aReports.GetSelected()
	if not id then return end

	aReports.SetContentMessage()
	local data = aReports.List[id]
	local ago = formatDurationSimple(getRealTime().timestamp - data.time)

	local player = data.serial and aGetPlayerBySerial(data.serial)
	if player then
		local nick = stripColorCodes(getPlayerName(player))
		guiSetText(aReports.gui.authorLbl, "Author: "..stripColorCodes(data.author).." (online: "..nick..")")
	else
		guiSetText(aReports.gui.authorLbl, "Author: "..stripColorCodes(data.author))
	end
	guiSetText(aReports.gui.dateLbl, "Date: "..formatDate(data.time).." ("..ago.." ago)")
	guiSetText(aReports.gui.textMemo, data.text)
end

function aReports.RefreshReportScreenShots()
	for number, data in ipairs(aReports.gui.screens) do
		destroyElement(data.image)
	end
	aReports.gui.screens = {}
	guiScrollPaneSetVerticalScrollPosition(aReports.gui.screensPane, 0)

	guiSetVisible(aReports.gui.screensBtn, false)
	guiSetVisible(aReports.gui.screensPane, false)
	guiSetSize(aReports.gui.textMemo, 0.5, 0.61, true)

	local id = aReports.GetSelected()
	if not id then return end

	local data = aReports.List[id]
	if not data.screenshots then return end
	if data.screenshots < 1 then return end

	guiSetText(aReports.gui.screensBtn, "Screenshots("..data.screenshots..")...")
	guiSetVisible(aReports.gui.screensBtn, true)
	guiSetSize(aReports.gui.textMemo, 0.5, 0.35, true)

	if not aReports.IsAnyScreenShotLoadedOrRequested(id) then return end

	guiSetVisible(aReports.gui.screensBtn, false)
	guiSetVisible(aReports.gui.screensPane, true)

	local width = 128
	for number = 1, data.screenshots do
		local img = guiCreateStaticImage(0, 0, width, width*0.5625, "client/images/white.png", false, aReports.gui.screensPane)
		guiStaticImageSetColor(img, 92, 92, 92)
		local lbl = guiCreateLabel(5, 5, 50, 20, "#"..number, false, img)
		local msg = guiCreateElementMessageLabel(img, "N/A")
		local view = guiCreateButton(5, 25, 60, 18, "View", false, img)
		setElementData(view, "type", "view")
		setElementData(view, "number", number)
		guiSetEnabled(view, false)
		guiSetVisible(view, false)

		aReports.gui.screens[number] = {
			number = number,
			image = img,
			message = msg,
			view = view
		}

		aReports.RefreshReportScreenShot(number)
	end
end

function aReports.RefreshReportScreenShot(number)
	local data = aReports.gui.screens[number]
	local id = aReports.GetSelected()

	local path = aReports.GetScreenShot(id, number)
	if path and guiStaticImageLoadImage(data.image, path) then
		guiStaticImageSetColor(data.image, 255, 255, 255)
		guiSetText(data.message, "")
		
		local nw, nh = guiStaticImageGetNativeSize(data.image)
		local w, h = 128, 128*(nh/nw)
		guiSetSize(data.image, w, h, false)
		guiSetEnabled(data.view, true)
		guiSetVisible(data.view, true)
	else
		guiStaticImageLoadImage(data.image, "client/images/white.png")
		guiStaticImageSetColor(data.image, 92, 92, 92)
		guiSetSize(data.image, 128, 128*0.5625, false)
		guiSetEnabled(data.view, false)
		guiSetVisible(data.view, false)
		if path then
			guiSetText(data.message, "Couldn't load")
		else
			if aReports.IsScreenShotRequested(id, number) then
				guiSetText(data.message, "Loading...")
			else
				guiSetText(data.message, "N/A")
			end
		end
	end
	aReports.AlignReportScreenShots()
end

function aReports.AlignReportScreenShots()
	if not guiGetVisible(aReports.gui.screensPane) then return end

	local columns = 2
	local rows = math.ceil(#aReports.gui.screens/columns)
	local y = 0
	for row = 0, rows - 1 do

		local numbers = {}
		for number = row * columns + 1, (row + 1) * columns do
			if number > #aReports.gui.screens then break end
			numbers[#numbers + 1] = number
		end

		local maxh = 0
		for column, number in ipairs(numbers) do
			local _, sh = guiGetSize(aReports.gui.screens[number].image, false)
			if sh > maxh then maxh = sh end
		end

		for column, number in ipairs(numbers) do
			local x = (column - 1) * (128 + 10)
			local _, h = guiGetSize(aReports.gui.screens[number].image, false)
			guiSetPosition(aReports.gui.screens[number].image, x, y + (maxh - h)/2, false)
		end

		y = y + maxh + 10
	end
end

function aReports.AddRow(id)
	if aReports.GetRow(id) then return end

	local data = aReports.List[id]
	local list = aReports.gui.list
	local date = aReports.FormatDateToTime(data.time)
	if getRealTime().timestamp - data.time > 60*60*24 then
		date = aReports.FormatDateSimple(data.time)
	end
	local row = guiGridListInsertRowAfter(list, -1, stripColorCodes(data.author), date)
	guiGridListSetItemData(list, row, 1, id)
	if data.read then
		guiGridListSetItemColor(list, row, 1, 75, 75, 75)
		guiGridListSetItemColor(list, row, 2, 75, 75, 75)
	end
end

function aReports.RemoveRow(id)
	local row = aReports.GetRow(id)
	if not row then return end
	local selected = guiGridListGetSelectedItem(aReports.gui.list)
	guiGridListRemoveRow(aReports.gui.list, row)

	if selected ~= row then return end
	selected = math.clamp(selected + 1, 0, guiGridListGetRowCount(aReports.gui.list)) - 1
	guiGridListSetSelectedItem(aReports.gui.list, selected, 1)
	aReports.RefreshReport() 
end

function aReports.RefreshRow(id)
	local row = aReports.GetRow(id)
	if not row then return end

	local data = aReports.List[id]
	local list = aReports.gui.list
	if data.read then
		guiGridListSetItemColor(list, row, 1, 75, 75, 75)
		guiGridListSetItemColor(list, row, 2, 75, 75, 75)
		if guiCheckBoxGetSelected(aReports.gui.hideReadChk) and
		aReports.GetSelected() ~= id then
			guiGridListRemoveRow(list, row)
		end
	end
end

function aReports.ShowChat(chat)
	local window = guiCreateWindow(0, 0, 400, 300, "Chat history", false)
	local memo = guiCreateMemo(0.05, 0.05, 0.90, 0.90, "", true, window)
	local close = guiCreateButton(0.05, 0.95, 0.20, 0.05, "Ok", true, window)
	addEventHandler("onClientGUIClick", close,
		function(key)
			if key ~= "left" then return end
			destroyElement(window)
		end,
		false
	)

	local text = ""
	for i, data in ipairs(chat) do
		local date = getRealTime(data.time)
		local time = string.format("%02d:%02d:%02d", date.hour, date.minute, date.second)
		text = text.."["..time.."] "..data.text.."\n"
	end
	guiSetText(memo, text)

	guiSetVisible(window, true)
end

function aReports.SaveSettings()
	aSetSetting("reportHideRead", guiCheckBoxGetSelected(aReports.gui.hideReadChk))
	aSetSetting("reportSound", guiCheckBoxGetSelected(aReports.gui.soundChk))
	aSetSetting("reportOutput", guiCheckBoxGetSelected(aReports.gui.outputChatChk))
end

function aReports.FormatDateToTime(timestamp)
	local date = getRealTime(timestamp)
	return string.format("%02d:%02d", date.hour, date.minute)
end

function aReports.FormatDateSimple(timestamp)
	local date = getRealTime(timestamp)
	return string.format("%02d.%02d.%04d", date.monthday, date.month+1, date.year+1900)
end