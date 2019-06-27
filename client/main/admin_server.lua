
aServerTab = {
	gui = {},
	Settings = {},
	Weathers = {},
	Glitches = {},
	WorldProperties = {},
}

function aServerTab.LoadWeathers()
	local node = xmlLoadFile("conf/weathers.xml")
	if not node then return end

	local weathers = {}
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		local data = {}
		data.id = tonumber(xmlNodeGetAttribute(subnode, "id"))
		data.name = xmlNodeGetAttribute(subnode, "name")
		weathers[#weathers + 1] = data
	end
	aServerTab.Weathers = weathers
	xmlUnloadFile(node)
end

function aServerTab.LoadGlitches()
	local node = xmlLoadFile("conf/glitches.xml")
	if not node then return end

	local glitches = {}
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		local data = {}
		data.nid = xmlNodeGetAttribute(subnode, "nid")
		data.name = xmlNodeGetAttribute(subnode, "name")
		glitches[#glitches + 1] = data
	end
	aServerTab.Glitches = glitches
	xmlUnloadFile(node)
end

function aServerTab.LoadWorldProperties()
	local node = xmlLoadFile("conf/worldproperties.xml")
	if not node then return end

	local properties = {}
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		local nid = xmlNodeGetAttribute(subnode, "nid")
		local data = {}
		data.nid = xmlNodeGetAttribute(subnode, "nid")
		data.name = xmlNodeGetAttribute(subnode, "name")
		data.default = xmlNodeGetAttribute(subnode, "default") == "true"
		properties[#properties + 1] = data
	end
	aServerTab.WorldProperties = properties
	xmlUnloadFile(node)
end

function aServerTab.Create(tab)
	if aServerTab.gui.tab then return end

	aServerTab.LoadWeathers()
	aServerTab.LoadGlitches()
	aServerTab.LoadWorldProperties()

	aServerTab.gui.tab = tab
	
	guiCreateHeader(0.02, 0.015, 0.30, 0.035, "Server info:", true, aServerTab.gui.tab)
	aServerTab.gui.serverLbl = guiCreateLabel(0.03, 0.060, 0.40, 0.035, "Server: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.passwordLbl = guiCreateLabel(0.03, 0.105, 0.40, 0.035, "Password: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.gameTypeLbl = guiCreateLabel(0.03, 0.150, 0.40, 0.035, "Game Type: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.mapNameLbl = guiCreateLabel(0.03, 0.195, 0.40, 0.035, "Map Name: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.playersLbl = guiCreateLabel(0.03, 0.240, 0.20, 0.035, "Players: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.passwordSetBtn = guiCreateButton(0.42, 0.060, 0.18, 0.04, "Set Password", true, aServerTab.gui.tab, "setpassword")
	aServerTab.gui.passwordResetBtn = guiCreateButton(0.42, 0.105, 0.18, 0.04, "Reset Password", true, aServerTab.gui.tab, "setpassword")
	aServerTab.gui.gameTypeBtn = guiCreateButton(0.42, 0.150, 0.18, 0.04, "Set Game Type", true, aServerTab.gui.tab, "setgametype")
	aServerTab.gui.mapNameBtn = guiCreateButton(0.42, 0.195, 0.18, 0.04, "Set Map Name", true, aServerTab.gui.tab, "setmapname")
	aServerTab.gui.shutdownBtn = guiCreateButton(0.42, 0.240, 0.18, 0.04, "Shutdown", true, aServerTab.gui.tab, "shutdown")
	

	guiCreateHeader(0.02, 0.285, 0.30, 0.035, "Server properties:", true, aServerTab.gui.tab)
	
	aServerTab.gui.weatherLbl = guiCreateLabel(0.03, 0.330, 0.45, 0.035, "Current Weather: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.weatherCmb, aServerTab.gui.weatherList = guiCreateAdvancedComboBox(0.35, 0.330, 0.25, 0.04, "", true, aServerTab.gui.tab)
	for i, data in ipairs(aServerTab.Weathers) do
		local row = guiGridListAddRow(aServerTab.gui.weatherList, "("..data.id..") "..data.name)
		guiGridListSetItemData(aServerTab.gui.weatherList, row, 1, data.id)
	end
	guiAdvancedComboBoxSetSelected(aServerTab.gui.weatherCmb, 0)
	guiGridListAdjustHeight(aServerTab.gui.weatherList)
	aServerTab.gui.weatherSetBtn = guiCreateButton(0.50, 0.375, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "setweather")
	aServerTab.gui.weatherBlendBtn = guiCreateButton(0.35, 0.375, 0.135, 0.04, "Blend", true, aServerTab.gui.tab, "blendweather")

	aServerTab.gui.timeLbl = guiCreateLabel(0.03, 0.420, 0.25, 0.035, "Time: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.timeHEdit = guiCreateAdvancedEdit(0.35, 0.420, 0.06, 0.04, "12", true, aServerTab.gui.tab, true, true, true, 0, 23, "settime")
	aServerTab.gui.timeMEdit = guiCreateAdvancedEdit(0.42, 0.420, 0.06, 0.04, "00", true, aServerTab.gui.tab, true, true, true, 0, 59, "settime")
	guiCreateLabel(0.4125, 0.420, 0.05, 0.04, ":", true, aServerTab.gui.tab)
	aServerTab.gui.timeBtn = guiCreateButton(0.50, 0.420, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "settime")

	aServerTab.gui.minuteDurationLbl =
		guiCreateLabel(0.03, 0.465, 0.28, 0.035, "Minute dur(sec): N/A", true, aServerTab.gui.tab)
	aServerTab.gui.minuteDurationIntervalLbl = guiCreateLabel(0.22, 0.465, 0.12, 0.04, "(1ms - 1day)", true, aServerTab.gui.tab)
	guiLabelSetHorizontalAlign(aServerTab.gui.minuteDurationIntervalLbl, "right")
	aServerTab.gui.minuteDurationEdit = guiCreateAdvancedEdit(0.35, 0.465, 0.135, 0.04, "1", true, aServerTab.gui.tab, true, true, false, 0.001, 86400, "setminuteduration")
	aServerTab.gui.minuteDurationBtn = guiCreateButton(0.50, 0.465, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "setminuteduration")

	aServerTab.gui.gravityLbl =
		guiCreateLabel(0.03, 0.510, 0.28, 0.035, "Gravitation: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.gravityIntervalLbl = guiCreateLabel(0.24, 0.510, 0.10, 0.04, "(-1 - 1)", true, aServerTab.gui.tab)
	guiLabelSetHorizontalAlign(aServerTab.gui.gravityIntervalLbl, "right")
	aServerTab.gui.gravityEdit = guiCreateAdvancedEdit(0.35, 0.510, 0.135, 0.04, "0.008", true, aServerTab.gui.tab, true, true, false, -1, 1, "setgravity")
	aServerTab.gui.gravityBtn = guiCreateButton(0.50, 0.510, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "setgravity")
  
	aServerTab.gui.speedLbl = guiCreateLabel(0.03, 0.555, 0.30, 0.035, "Game Speed: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.speedIntervalLbl = guiCreateLabel(0.24, 0.555, 0.10, 0.04, "(0 - 10)", true, aServerTab.gui.tab)
	guiLabelSetHorizontalAlign(aServerTab.gui.speedIntervalLbl, "right")
	aServerTab.gui.speedEdit = guiCreateAdvancedEdit(0.35, 0.555, 0.135, 0.04, "1", true, aServerTab.gui.tab, true, true, false, 0, 10, "setgamespeed")
	aServerTab.gui.speedBtn = guiCreateButton(0.50, 0.555, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "setgamespeed")
	
	aServerTab.gui.blurLbl = guiCreateLabel(0.03, 0.600, 0.25, 0.035, "Blur Level: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.blurIntervalLbl = guiCreateLabel(0.24, 0.600, 0.10, 0.04, "(0 - 255)", true, aServerTab.gui.tab)
	guiLabelSetHorizontalAlign(aServerTab.gui.blurIntervalLbl, "right")
	aServerTab.gui.blurEdit = guiCreateAdvancedEdit(0.35, 0.600, 0.135, 0.04, "36", true, aServerTab.gui.tab, true, true, true, 0, 255, "setblurlevel")
	aServerTab.gui.blurBtn = guiCreateButton(0.50, 0.600, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "setblurlevel")

	aServerTab.gui.heatHazeLbl =
		guiCreateLabel(0.03, 0.645, 0.25, 0.035, "Heat Haze Level: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.heatHazeIntervalLbl = guiCreateLabel(0.24, 0.645, 0.10, 0.04, "(0 - 255)", true, aServerTab.gui.tab)
	guiLabelSetHorizontalAlign(aServerTab.gui.heatHazeIntervalLbl, "right")
	aServerTab.gui.heatHazeEdit = guiCreateAdvancedEdit(0.35, 0.645, 0.135, 0.04, "80", true, aServerTab.gui.tab, true, true, true, 0, 255, "setheathazelevel")
	aServerTab.gui.heatHazeBtn = guiCreateButton(0.50, 0.645, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "setheathazelevel")
	
	aServerTab.gui.wavesLbl = guiCreateLabel(0.03, 0.690, 0.25, 0.035, "Wave Height: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.wavesIntervalLbl = guiCreateLabel(0.24, 0.690, 0.10, 0.04, "(0 - 100)", true, aServerTab.gui.tab)
	guiLabelSetHorizontalAlign(aServerTab.gui.wavesIntervalLbl, "right")
	aServerTab.gui.wavesEdit = guiCreateAdvancedEdit(0.35, 0.690, 0.135, 0.04, "0", true, aServerTab.gui.tab, true, true, true, 0, 100, "setwaveheight")
	aServerTab.gui.wavesBtn = guiCreateButton(0.50, 0.690, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "setwaveheight")
   
	aServerTab.gui.fpsLbl = guiCreateLabel(0.03, 0.735, 0.25, 0.035, "FPS Limit: N/A", true, aServerTab.gui.tab)
	aServerTab.gui.fpsIntervalLbl = guiCreateLabel(0.24, 0.735, 0.10, 0.04, "(25 - 100)", true, aServerTab.gui.tab)
	guiLabelSetHorizontalAlign(aServerTab.gui.fpsIntervalLbl, "right")
	aServerTab.gui.fpsEdit = guiCreateAdvancedEdit(0.35, 0.735, 0.135, 0.04, "36", true, aServerTab.gui.tab, true, true, true, 25, 100, "setfpslimit")
	aServerTab.gui.fpsBtn = guiCreateButton(0.50, 0.735, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "setfpslimit")

	guiCreateHeader(0.02, 0.780, 0.30, 0.035, "Automatic scripts:", true, aServerTab.gui.tab)
	aServerTab.gui.pingKickerChk =
		guiCreateCheckBox(0.03, 0.825, 0.30, 0.04, "Ping Kicker", false, true, aServerTab.gui.tab, "setpingkicker")
	aServerTab.gui.pingKickerEdit = guiCreateEdit(0.35, 0.825, 0.135, 0.04, "300", true, aServerTab.gui.tab, "setpingkicker")
	aServerTab.gui.pingKickerBtn = guiCreateButton(0.50, 0.825, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "setpingkicker")
	guiSetEnabled(aServerTab.gui.pingKickerEdit, false)
	guiSetEnabled(aServerTab.gui.pingKickerBtn, false)

	aServerTab.gui.fpsKickerChk =
		guiCreateCheckBox(0.03, 0.870, 0.30, 0.04, "FPS Kicker", false, true, aServerTab.gui.tab, "setfpskicker")
	aServerTab.gui.fpsKickerEdit = guiCreateEdit(0.35, 0.870, 0.135, 0.04, "5", true, aServerTab.gui.tab, "setfpskicker")
	aServerTab.gui.fpsKickerBtn = guiCreateButton(0.50, 0.870, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "setfpskicker")
	guiSetEnabled(aServerTab.gui.fpsKickerEdit, false)
	guiSetEnabled(aServerTab.gui.fpsKickerBtn, false)

	aServerTab.gui.idleKickerChk =
		guiCreateCheckBox(0.03, 0.915, 0.30, 0.04, "Idle Kicker", false, true, aServerTab.gui.tab, "setidlekicker")
	aServerTab.gui.idleKickerEdit = guiCreateEdit(0.35, 0.915, 0.135, 0.04, "10", true, aServerTab.gui.tab, "setidlekicker")
	aServerTab.gui.idleKickerBtn = guiCreateButton(0.50, 0.915, 0.10, 0.04, "Set", true, aServerTab.gui.tab, "setidlekicker")
	guiSetEnabled(aServerTab.gui.idleKickerEdit, false)
	guiSetEnabled(aServerTab.gui.idleKickerBtn, false)

	local y = 0.015
	guiCreateHeader(0.65, y, 0.30, 0.035, "Allowed glitches:", true, aServerTab.gui.tab)

	y = y + 0.045
	aServerTab.gui.glitchChks = {}
	for i, data in ipairs(aServerTab.Glitches) do
		aServerTab.gui.glitchChks[data.nid] = guiCreateCheckBox(0.66, y, 0.40, 0.04, data.name, false, true, aServerTab.gui.tab, "setglitch")
		setElementData(aServerTab.gui.glitchChks[data.nid], "glitch", data.nid)
		addEventHandler("onClientGUIClick", aServerTab.gui.glitchChks[data.nid], aServerTab.onClickGlitchHandler, false)
		y = y + 0.045
	end

	y = y + 0.01
	guiCreateHeader(0.65, y, 0.30, 0.035, "Special world properties:", true, aServerTab.gui.tab)

	y = y + 0.045
	aServerTab.gui.propertyChks = {}
	for i, data in pairs(aServerTab.WorldProperties) do
		aServerTab.gui.propertyChks[data.nid] = guiCreateCheckBox(0.66, y, 0.40, 0.04, data.name, false, true, aServerTab.gui.tab, "setworldproperty")
		setElementData(aServerTab.gui.propertyChks[data.nid], "property", data.nid)
		addEventHandler("onClientGUIClick", aServerTab.gui.propertyChks[data.nid], aServerTab.onClickWorldPropertyHandler, false)
		y = y + 0.045
	end

	addEventHandler("onClientGUIClick", aServerTab.gui.tab, aServerTab.onClickHandler)

	addEventHandler("onAdminRefresh", aServerTab.gui.tab, aServerTab.onRefreshHandler)
	addEventHandler(EVENT_SYNC, root, aServerTab.onSyncHandler)
	
	sync(SYNC_SERVER, SYNC_LIST)
	
	aServerTab.onRefreshHandler()
end

function aServerTab.Destroy()
	removeEventHandler(EVENT_SYNC, root, aServerTab.onSyncHandler)
	--destroyElement(aServerTab.gui.tab)
	aServerTab.gui = {}
	aServerTab.Settings = {}
end

function aServerTab.GetWeatherNameFromID(weather)
	for i, data in ipairs(aServerTab.Weathers) do
		if data.id == weather then return data.name end
	end
	return "Unknown"
end

function aServerTab.GetSelectedWeather()
	local row = guiGridListGetSelectedItem(aServerTab.gui.weatherList)
	if row == -1 then return nil end
	return guiGridListGetItemData(aServerTab.gui.weatherList, row, 1)
end

function aServerTab.onClickHandler(key)
	if key ~= "left" then return end

	if source == aServerTab.gui.gameTypeBtn then
		local gameType = inputBox("Game Type", "Enter game type:", aServerTab.GameType)
		if not gameType then return end
		if gameType == "" then gameType = nil end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setgametype", gameType)
	
	elseif source == aServerTab.gui.mapNameBtn then
		local mapName = inputBox("Map Name", "Enter map name:", aServerTab.MapName)
		if not mapName then return end
		if mapName == "" then mapName = nil end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setmapname", mapName)

	elseif source == aServerTab.gui.passwordSetBtn then
		local password = inputBox("Server password", "Enter server password: (32 characters max)", aServerTab.Password)
		if not password then return end
		if string.len(password) == 0 then
			if messageBox("Reset password?", MB_QUESTION, MB_YESNO) then
				return triggerServerEvent(EVENT_COMMAND, localPlayer, "resetpassword")
			end
		end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setpassword", password)

	elseif source == aServerTab.gui.passwordResetBtn then
		if not messageBox("Reset password?", MB_QUESTION, MB_YESNO) then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "resetpassword")

	elseif source == aServerTab.gui.shutdownBtn then
		local reason = inputBox("Shutdown", "Enter shut down reason:")
		if not reason then return end
		if not messageBox("Server will be shut down. Continue?", MB_WARNING, MB_YESNO) then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "shutdown", reason)

	elseif source == aServerTab.gui.weatherSetBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setweather", aServerTab.GetSelectedWeather())

	elseif source == aServerTab.gui.weatherBlendBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "blendweather", aServerTab.GetSelectedWeather())

	elseif source == aServerTab.gui.timeBtn then
		local h = tonumber(guiGetText(aServerTab.gui.timeHEdit))
		local m = tonumber(guiGetText(aServerTab.gui.timeMEdit))
		triggerServerEvent(EVENT_COMMAND, localPlayer, "settime", h, m)

	elseif source == aServerTab.gui.minuteDurationBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setminuteduration", tonumber(guiGetText(aServerTab.gui.minuteDurationEdit)))

	elseif source == aServerTab.gui.speedBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setgamespeed", tonumber(guiGetText(aServerTab.gui.speedEdit)))

	elseif source == aServerTab.gui.gravityBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setgravity", tonumber(guiGetText(aServerTab.gui.gravityEdit)))

	elseif source == aServerTab.gui.wavesBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setwaveheight", tonumber(guiGetText(aServerTab.gui.wavesEdit)))

	elseif source == aServerTab.gui.blurBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setblurlevel", tonumber(guiGetText(aServerTab.gui.blurEdit)))

	elseif source == aServerTab.gui.heatHazeBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setheathazelevel", tonumber(guiGetText(aServerTab.gui.heatHazeEdit)))

	elseif source == aServerTab.gui.fpsBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setfpslimit", tonumber(guiGetText(aServerTab.gui.fpsEdit)))
	
	end
end

function aServerTab.onClickGlitchHandler(key)
	if key ~= "left" then return end

	local glitch = getElementData(source, "glitch")
	triggerServerEvent(
		EVENT_COMMAND,
		localPlayer,
		"setglitch",
		glitch,
		guiCheckBoxGetSelected(source)
	)
end

function aServerTab.onClickWorldPropertyHandler(key)
	if key ~= "left" then return end

	local property = getElementData(source, "property")
	triggerServerEvent(
		EVENT_COMMAND,
		localPlayer,
		"setworldproperty",
		property,
		guiCheckBoxGetSelected(source)
	)
end

function aServerTab.onRefreshHandler()
	if aServerTab.Settings.players then
		guiSetText(aServerTab.gui.playersLbl,
			"Players: "..#getElementsByType("player").."/"..aServerTab.Settings.players)
	else
		guiSetText(aServerTab.gui.playersLbl, "Players: "..#getElementsByType("player"))
	end
	guiSetText(aServerTab.gui.timeLbl, "Time: "..formatGameTime(getTime()))
	guiSetText(aServerTab.gui.minuteDurationLbl, "Minute dur: "..string.format("%.3f", getMinuteDuration()/1000).."s")
	guiSetText(aServerTab.gui.gravityLbl, "Gravitation: "..string.format("%.6f", getGravity()))
	guiSetText(aServerTab.gui.speedLbl, "Game Speed: "..getGameSpeed())
	guiSetText(
		aServerTab.gui.weatherLbl,
		"Weather: ("..getWeather()..") "..aServerTab.GetWeatherNameFromID(getWeather())
	)
	guiSetText(aServerTab.gui.blurLbl, "Blur Level: "..getBlurLevel())
	guiSetText(aServerTab.gui.heatHazeLbl, "Heat Haze Level: "..getHeatHaze())
	guiSetText(aServerTab.gui.wavesLbl, "Wave Height: "..getWaveHeight())
	
	-- if not changed by server then set client value
	for property, chk in pairs(aServerTab.gui.propertyChks) do
		local value = nil
		if aServerTab.Settings.properties and aServerTab.Settings.properties[property] then
			value = aServerTab.Settings.properties[property]
		end
		if value == nil then value = isWorldSpecialPropertyEnabled(property) end
		guiCheckBoxSetSelected(chk, value)
	end
end

function aServerTab.Refresh()
	guiSetText(aServerTab.gui.serverLbl, "Server: "..aServerTab.Settings.name)
	guiSetText(aServerTab.gui.passwordLbl, "Password: "..(aServerTab.Settings.password or "None"))
	guiSetText(aServerTab.gui.gameTypeLbl, "Game Type: "..(aServerTab.Settings.game or "None"))
	guiSetText(aServerTab.gui.mapNameLbl, "Map Name: "..(aServerTab.Settings.map or "None"))
	guiSetText(aServerTab.gui.fpsLbl, "FPS Limit: "..(aServerTab.Settings.fps or "None"))
	for glitch, chk in pairs(aServerTab.gui.glitchChks) do
		guiCheckBoxSetSelected(chk, aServerTab.Settings.glitches[glitch])
	end
	aServerTab.onRefreshHandler()
end

aServerTab.SyncFunctions = {
	[SYNC_LIST] = function(data)
		aServerTab.Settings = data
		aServerTab.Refresh()
	end,
	[SYNC_SINGLE] = function(setting, data)
		aServerTab.Settings[setting] = data
		aServerTab.Refresh()
	end
}
function aServerTab.onSyncHandler(dataType, syncType, ...)
	if dataType ~= SYNC_SERVER then return end
	aServerTab.SyncFunctions[syncType](...)
end
