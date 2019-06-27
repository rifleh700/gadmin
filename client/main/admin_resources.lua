
aResourcesTab = {
	gui = {},
	List = {},
	Data = {}
}

addEvent(EVENT_RESOURCE_START, true)
addEvent(EVENT_RESOURCE_STOP, true)

function aResourcesTab.Create(tab)
	if aResourcesTab.gui.tab then return end
	
	aResourcesTab.gui.tab = tab

	aResourcesTab.gui.panel = guiCreateTabPanel(0.01, 0.02, 0.98, 0.96, true, tab)
	aResourcesTab.gui.mainTab = guiCreateTab("Main", aResourcesTab.gui.panel, "resources")

	aResourcesTab.gui.resourceSrch = guiCreateSearchEdit(0.01, 0.07, 0.35, 0.045, "", true, aResourcesTab.gui.mainTab)
	aResourcesTab.gui.resourcesList = guiCreateGridList(0.01, 0.13, 0.35, 0.80, true, aResourcesTab.gui.mainTab)
	guiGridListAddColumn(aResourcesTab.gui.resourcesList, "Resource", 0.60)
	guiGridListAddColumn(aResourcesTab.gui.resourcesList, "State", 0.25)
	aResourcesTab.gui.resourcesListMsg = guiCreateElementMessageLabel(aResourcesTab.gui.resourcesList)
	guiGridListRegisterArrowScroll(aResourcesTab.gui.resourcesList)
	guiGridListRegisterSearch(aResourcesTab.gui.resourcesList, aResourcesTab.gui.resourceSrch)

	-- after main list for arrow keys support
	guiCreateLabel(0.02, 0.02, 0.14, 0.04, "View type:", true, aResourcesTab.gui.mainTab)
	aResourcesTab.gui.viewCmb, aResourcesTab.gui.viewList =
		guiCreateAdvancedComboBox(0.16, 0.02, 0.20, 0.04, "all", true, aResourcesTab.gui.mainTab)
	guiGridListAddRow(aResourcesTab.gui.viewList, "all")
	guiAdvancedComboBoxSetSelected(aResourcesTab.gui.viewCmb, 0)
	guiGridListAdjustHeight(aResourcesTab.gui.viewList)

	aResourcesTab.gui.refreshBtn =
		guiCreateButton(0.01, 0.94, 0.35, 0.04, "Refresh", true, aResourcesTab.gui.mainTab, "listresources")
	aResourcesTab.gui.startBtn = guiCreateButton(0.79, 0.02, 0.20, 0.04, "Start", true, aResourcesTab.gui.mainTab, "start")
	aResourcesTab.gui.restartBtn =
		guiCreateButton(0.79, 0.07, 0.20, 0.04, "Restart", true, aResourcesTab.gui.mainTab, "restart")
	aResourcesTab.gui.stopBtn = guiCreateButton(0.79, 0.12, 0.20, 0.04, "Stop", true, aResourcesTab.gui.mainTab, "stop")
	
	guiCreateHeader(0.38, 0.03, 0.20, 0.04, "Resource info:", true, aResourcesTab.gui.mainTab)
	aResourcesTab.gui.nameLbl = guiCreateLabel(0.39, 0.07, 0.40, 0.04, "Name: N/A", true, aResourcesTab.gui.mainTab)
	aResourcesTab.gui.typeLbl = guiCreateLabel(0.39, 0.11, 0.40, 0.04, "Type: N/A", true, aResourcesTab.gui.mainTab)
	aResourcesTab.gui.authorLbl = guiCreateLabel(0.39, 0.15, 0.40, 0.04, "Author: N/A", true, aResourcesTab.gui.mainTab)
	aResourcesTab.gui.versionLbl = guiCreateLabel(0.39, 0.19, 0.40, 0.04, "Version: N/A", true, aResourcesTab.gui.mainTab)
	aResourcesTab.gui.descriptionLbl = guiCreateLabel(0.39, 0.23, 0.60, 0.10, "Description: N/A", true, aResourcesTab.gui.mainTab)
	guiLabelSetHorizontalAlign(aResourcesTab.gui.descriptionLbl, "left", true)
	
	guiCreateHeader(0.38, 0.32, 0.20, 0.04, "Resource settings:", true, aResourcesTab.gui.mainTab)
	aResourcesTab.gui.settingsList = guiCreateGridList(0.38, 0.36, 0.61, 0.62, true, aResourcesTab.gui.mainTab)
	guiGridListAddColumn(aResourcesTab.gui.settingsList, "Name", 0.44)
	guiGridListAddColumn(aResourcesTab.gui.settingsList, "Current", 0.24)
	guiGridListAddColumn(aResourcesTab.gui.settingsList, "Default", 0.20)
	guiGridListSetSortingEnabled(aResourcesTab.gui.settingsList, false)
	aResourcesTab.gui.settingsListMsg = guiCreateElementMessageLabel(aResourcesTab.gui.settingsList)

	---------------------------------

	aResourcesTab.gui.runTab = guiCreateTab("Run Code", aResourcesTab.gui.panel, "execute")

	guiCreateHeader(0.38, 0.75, 0.20, 0.04, "Execute code:", true, aResourcesTab.gui.runTab)
	aResourcesTab.gui.codeMemo = guiCreateMemo(0.38, 0.80, 0.50, 0.18, "", true, aResourcesTab.gui.runTab)
	aResourcesTab.gui.runClientBtn =
		guiCreateButton(0.89, 0.80, 0.10, 0.04, "Client", true, aResourcesTab.gui.runTab, "execute")
	aResourcesTab.gui.runServerBtn =
		guiCreateButton(0.89, 0.85, 0.10, 0.04, "Server", true, aResourcesTab.gui.runTab, "execute")

	---------------------------------

	addEventHandler("onClientGUIClick", aResourcesTab.gui.tab, aResourcesTab.onClickHandler)
	addEventHandler("onClientGUIDoubleClick", aResourcesTab.gui.tab, aResourcesTab.onDoubleClickHandler)
	addEventHandler("onClientGUIAdvancedComboBoxAccepted", aResourcesTab.gui.viewCmb, aResourcesTab.RefreshResources, false)
	addEventHandler("onClientGUIChanged", aResourcesTab.gui.resourceSrch, aResourcesTab.RefreshResources, false)

	addEventHandler(EVENT_RESOURCE_START, localPlayer, aResourcesTab.onResourceStartHandler)
	addEventHandler(EVENT_RESOURCE_STOP, localPlayer, aResourcesTab.onResourceStopHandler)
	addEventHandler(EVENT_SYNC, localPlayer, aResourcesTab.onSyncHandler)

	guiSetText(aResourcesTab.gui.resourcesListMsg, "Loading...")
	sync(SYNC_RESOURCE, SYNC_LIST)
end

function aResourcesTab.Destroy()
	removeEventHandler(EVENT_RESOURCE_START, localPlayer, aResourcesTab.onResourceStartHandler)
	removeEventHandler(EVENT_RESOURCE_STOP, localPlayer, aResourcesTab.onResourceStopHandler)
	removeEventHandler(EVENT_SYNC, localPlayer, aResourcesTab.onSyncHandler)
	--destroyElement(aResourcesTab.gui.tab)
	aResourcesTab.gui = {}
	aResourcesTab.List = {}
	aResourcesTab.Data = {}
end

aResourcesTab.SyncFunctions = {
	[SYNC_LIST] = function(data)
		aResourcesTab.List = data
		guiSetText(aResourcesTab.gui.resourcesListMsg, "")
		aResourcesTab.RefreshViewList()
		aResourcesTab.RefreshResources()
	end,
	[SYNC_SINGLE] = function(tresource, data)
		aResourcesTab.Data[tresource] = data
		if aResourcesTab.GetSelectedResource() == tresource then
			aResourcesTab.RefreshResource()
		end
	end
}
function aResourcesTab.onSyncHandler(dataType, syncType, ...)
	if dataType ~= SYNC_RESOURCE then return end
	aResourcesTab.SyncFunctions[syncType](...)
end

function aResourcesTab.onResourceStartHandler(tresource)
	local id = 0
	while (id <= guiGridListGetRowCount(aResourcesTab.gui.resourcesList)) do
		if (guiGridListGetItemText(aResourcesTab.gui.resourcesList, id, 1) == tresource) then
			guiGridListSetItemText(aResourcesTab.gui.resourcesList, id, 2, "running", false, false)
		end
		id = id + 1
	end
end

function aResourcesTab.onResourceStopHandler(tresource)
	local id = 0
	while (id <= guiGridListGetRowCount(aResourcesTab.gui.resourcesList)) do
		if (guiGridListGetItemText(aResourcesTab.gui.resourcesList, id, 1) == tresource) then
			guiGridListSetItemText(aResourcesTab.gui.resourcesList, id, 2, "loaded", false, false)
		end
		id = id + 1
	end
end

function aResourcesTab.onClickHandler(key)
	if key ~= "left" then return end

	if source == aResourcesTab.gui.resourcesList then
		aResourcesTab.RefreshResource()

	elseif source == aResourcesTab.gui.refreshBtn then
		aResourcesTab.List = {}
		aResourcesTab.Data = {}
		aResourcesTab.RefreshResources()
		guiSetText(aResourcesTab.gui.resourcesListMsg, "Loading...")
		sync(SYNC_RESOURCE, SYNC_LIST)

	elseif source == aResourcesTab.gui.startBtn then
		local tresource = aResourcesTab.GetSelectedResource()
		if not tresource then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "start", tresource)

	elseif source == aResourcesTab.gui.restartBtn then
		local tresource = aResourcesTab.GetSelectedResource()
		if not tresource then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "restart", tresource)

	elseif source == aResourcesTab.gui.stopBtn then
		local tresource = aResourcesTab.GetSelectedResource()
		if not tresource then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "stop", tresource)

	elseif source == aResourcesTab.gui.runClientBtn then
		local code = guiGetText(aResourcesTab.gui.codeMemo)
		if code == "" then return messageBox("Invalid code!", MB_ERROR) end
		aResourcesTab.RunClientCode(code)

	elseif source == aResourcesTab.gui.runServerBtn then
		local code = guiGetText(aResourcesTab.gui.codeMemo)
		if code == "" then return messageBox("Invalid code!", MB_ERROR) end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "execute", code)

	end
end

function aResourcesTab.onDoubleClickHandler(key)
	if key ~= "left" then return end

	if source == aResourcesTab.gui.settingsList then
		local tresource = aResourcesTab.GetSelectedResource()
		if not tresource then return end
	
		local setting = aResourcesTab.GetSelectedSetting()
		if not setting then return end
	
		local data = aResourcesTab.Data[tresource].settings[setting]
		local name = data.friendlyname or setting
		local value = inputBox("Change setting", "Enter new value for '"..name.."'", data.current or "")
		if not value then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setsetting", tresource, setting, value)
	end
end

function aResourcesTab.RefreshViewList()
	guiGridListClear(aResourcesTab.gui.viewList)
	guiGridListAddRow(aResourcesTab.gui.viewList, "all")
	guiAdvancedComboBoxSetSelected(aResourcesTab.gui.viewCmb, 0)
	for group, resources in pairs(aResourcesTab.List) do
		guiGridListAddRow(aResourcesTab.gui.viewList, group)
	end
	guiGridListAdjustHeight(aResourcesTab.gui.viewList)
end

function aResourcesTab.RefreshResources()
	local selected = aResourcesTab.GetSelectedResource()
	guiGridListClear(aResourcesTab.gui.resourcesList)

	local view = guiGetText(aResourcesTab.gui.viewCmb)
	local resources = {}
	if view == "all" then
		for group, list in pairs(aResourcesTab.List) do
			table.iadd(resources, list)
		end
	else
		resources = aResourcesTab.List[view]
	end

	local search = string.lower(guiGetText(aResourcesTab.gui.resourceSrch))
	for i, data in ipairs(resources) do
		if string.find(data.name, search, 1, true) then
			guiGridListAddRow(aResourcesTab.gui.resourcesList, data.name, data.state)
			if selected == data.name then
				guiGridListSetSelectedItem(aResourcesTab.gui.resourcesList, i-1, 1)
			end
		end
	end
	if guiGridListGetSelectedItem(aResourcesTab.gui.resourcesList) == -1 then
		guiGridListSetSelectedItem(aResourcesTab.gui.resourcesList, 0, 1)
	end

	aResourcesTab.RefreshResource()
end

function aResourcesTab.GetSelectedResource()
	local row = guiGridListGetSelectedItem(aResourcesTab.gui.resourcesList)
	if row == -1 then return nil end
	return guiGridListGetItemText(aResourcesTab.gui.resourcesList, row, 1)
end

function aResourcesTab.SetContentMessage(message)
	message = message or ""
	guiSetText(aResourcesTab.gui.nameLbl, "Name: "..message)
	guiSetText(aResourcesTab.gui.typeLbl, "Type: "..message)
	guiSetText(aResourcesTab.gui.authorLbl, "Author: "..message)
	guiSetText(aResourcesTab.gui.versionLbl, "Version: "..message)
	guiSetText(aResourcesTab.gui.descriptionLbl, "Description: "..message)
	guiSetText(aResourcesTab.gui.settingsListMsg, message)
end

function aResourcesTab.RefreshResource()
	aResourcesTab.RefreshSettings()

	aResourcesTab.SetContentMessage("N/A")
	local tresource = aResourcesTab.GetSelectedResource()
	if not tresource then return end

	local info = aResourcesTab.Data[tresource]
	if not info then
		aResourcesTab.SetContentMessage("Loading...")
		sync(SYNC_RESOURCE, SYNC_SINGLE, tresource)
		return
	end

	aResourcesTab.SetContentMessage()
	guiSetText(aResourcesTab.gui.nameLbl, "Name: "..(info.name or tresource))
	guiSetText(aResourcesTab.gui.typeLbl, "Type: "..(info.type or "None"))
	guiSetText(aResourcesTab.gui.authorLbl, "Author: "..(info.author or "None"))
	guiSetText(aResourcesTab.gui.versionLbl, "Version: "..(info.version or "None"))
	guiSetText(aResourcesTab.gui.descriptionLbl, "Description: "..(info.description or "None"))
end

function aResourcesTab.RefreshSettings()
	local list = aResourcesTab.gui.settingsList
	local selected = guiGridListGetSelectedItem(list)
	guiGridListClear(list)

	local tresource = aResourcesTab.GetSelectedResource()
	if not tresource then return end
	if not aResourcesTab.Data[tresource] then return end
	if not aResourcesTab.Data[tresource].settings then return end

	local settings = aResourcesTab.Data[tresource].settings

	local misc = {}
	local groups = {}
	local bygroups = {}
	for name, data in pairs(settings) do
		if data.group then
			if not bygroups[data.group] then
				groups[#groups + 1] = data.group
				bygroups[data.group] = {}
			end
			bygroups[data.group][#bygroups[data.group] + 1] = name
		else
			misc[#misc + 1] = name
		end
	end
	
	table.sort(groups, function(a, b) return (a < b) end)
	if #misc > 0 then
		groups[#groups + 1] = "Misc"
		bygroups["Misc"] = misc
	end
	if #groups == 0 then return end 

	for i, group in ipairs(groups) do
		local names = bygroups[group]
		table.sort(names, function(a, b) return (a < b) end)

		local row = guiGridListAddRow(list)
		guiGridListSetItemText(list, row, 1, group, true, false)
		for is, name in ipairs(names) do
			local value = settings[name]
			row = guiGridListAddRow(list)
			guiGridListSetItemText(list, row, 1, tostring(value.friendlyname or name), false, false)
			guiGridListSetItemText(list, row, 2, tostring(value.current), false, false)
			guiGridListSetItemText(list, row, 3, tostring(value.default), false, false)
			guiGridListSetItemData(list, row, 1, tostring(name))
			if row == selected then
				guiGridListSetSelectedItem(list, row, 1)
			end
		end
	end
end

function aResourcesTab.GetSelectedSetting()
	local row = guiGridListGetSelectedItem(aResourcesTab.gui.settingsList)
	if row == -1 then return nil end
	return guiGridListGetItemData(aResourcesTab.gui.settingsList, row, 1)
end

function aResourcesTab.RunClientCode(code)
	local func, errorMsg = loadstring("return "..code)
	if errorMsg then
		func, errorMsg = loadstring(code)
	end
	if errorMsg then
		return false, errorMsg
	end
	local results = pack(pcall(func))
	if not results[1] then
		return false, results[2]
	end
	local outputresults = {}
	for i = 2, results.n do
		outputresults[i-1] = results[i]
	end
	
	outputChatBox(LOG_PREFIX..": Client code executed with result: "..inspect(outputresults), 255, 127, 63)
end
