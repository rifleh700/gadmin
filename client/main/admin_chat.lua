
aChatTab = {
	gui = {},
	Admins = {}
}

addEvent(EVENT_ADMIN_CHAT, true)

aRegisterInitiatorEvent(EVENT_ADMIN_CHAT, "general.tab_adminchat")

function aChatTab.Create(tab)
	if aChatTab.gui.tab then return end

	aChatTab.gui.tab = tab

	aChatTab.gui.memo = guiCreateMemo(0.01, 0.02, 0.78, 0.89, "", true, tab)
	guiSetProperty(aChatTab.gui.memo, "ReadOnly", "true")

	aChatTab.gui.adminsList = guiCreateGridList(0.80, 0.02, 0.19, 0.8, true, tab)
	guiGridListAddColumn(aChatTab.gui.adminsList, "Admins", 0.90)
	aChatTab.gui.edit = guiCreateEdit(0.01, 0.92, 0.78, 0.06, "", true, tab, "achat")
	aChatTab.gui.sayBtn = guiCreateButton(0.80, 0.92, 0.19, 0.06, "Say", true, tab, "achat")

	aChatTab.gui.soundChk = guiCreateCheckBox(0.81, 0.83, 0.18, 0.04, "Play Sound", false, true, tab)
	aChatTab.gui.outputChatChk = guiCreateCheckBox(0.81, 0.87, 0.18, 0.04, "Output", false, true, tab)
	guiCheckBoxSetSelected(aChatTab.gui.soundChk, aGetSetting("adminChatSound") ~= false)
	guiCheckBoxSetSelected(aChatTab.gui.outputChatChk, aGetSetting("adminChatOutput") ~= false)

	---------------------------------

	addEventHandler("onClientGUIClick", aChatTab.gui.tab, aChatTab.onClickHandler)
	addEventHandler("onClientGUIAccepted", aChatTab.gui.edit, aChatTab.Say, false)

	addEventHandler("onClientPlayerQuit", root, aChatTab.onPlayerQuitHandler)
	addEventHandler("onClientResourceStop", resourceRoot, aChatTab.SaveSettings)
	addEventHandler(EVENT_ADMIN_CHAT, root, aChatTab.onAdminChatHandler)
	addEventHandler(EVENT_SYNC, root, aChatTab.onSyncHandler)

	sync(SYNC_CHAT, SYNC_LIST)
end

function aChatTab.Destroy()
	if not aChatTab.gui.tab then return end
	
	removeEventHandler(EVENT_SYNC, root, aChatTab.onSyncHandler)
	removeEventHandler(EVENT_ADMIN_CHAT, root, aChatTab.onAdminChatHandler)
	removeEventHandler("onClientResourceStop", resourceRoot, aChatTab.SaveSettings)
	removeEventHandler("onClientPlayerQuit", root, aChatTab.onPlayerQuitHandler)
	aChatTab.SaveSettings()
	aChatTab.gui = {}
	aChatTab.Admins = {}
end

aChatTab.SyncFunctions = {
	[SYNC_LIST] = function(list)
		aChatTab.Admins = list
		aChatTab.RefreshAdmins()
	end
}
function aChatTab.onSyncHandler(dataType, syncType, ...)
	if dataType ~= SYNC_CHAT then return end
	aChatTab.SyncFunctions[syncType](...)
end

function aChatTab.onAdminChatHandler(message, timestamp)
	local name = nil
	if source == root then
		name = rgb2hex(unpack(aColors.console)).."Console"
	else
		name = getPlayerName(source)
	end
	guiSetText(aChatTab.gui.memo, guiGetText(aChatTab.gui.memo).."".."["..aChatTab.FormatDate(timestamp).."] "..stripColorCodes(name)..": "..message)
	guiSetProperty(aChatTab.gui.memo, "CaratIndex", tostring(string.len(guiGetText(aChatTab.gui.memo))))
	if guiCheckBoxGetSelected(aChatTab.gui.outputChatChk) then
		outputChatBox(
            rgb2hex(unpack(aColors.orange)).."[ADMIN] #FFFFFF"..name..": "..rgb2hex(unpack(aColors.orange))..message,
            255, 255, 255,
            true
        )
	end
	if guiCheckBoxGetSelected(aChatTab.gui.soundChk) and source ~= localPlayer then
		playSoundFrontEnd(13)
	end
end

function aChatTab.onPlayerQuitHandler()
	table.vremove(aChatTab.Admins, source)
end

function aChatTab.onClickHandler(key)
	if key ~= "left" then return end

	if source == aChatTab.gui.sayBtn then
		aChatTab.Say()
	end
end

function aChatTab.RefreshAdmins()
	guiGridListClear(aChatTab.gui.adminsList)
	for i, admin in ipairs(aChatTab.Admins) do
		guiGridListAddRow(aChatTab.gui.adminsList, stripColorCodes(getPlayerName(admin)))
	end
end

function aChatTab.Say()
	local message = guiGetText(aChatTab.gui.edit)
	if message == "" then return end

	if string.match(message, "^/clear") then
		guiSetText(aChatTab.gui.memo, "")
	else
		triggerServerEvent(EVENT_COMMAND, localPlayer, "achat", message)
	end
	guiSetText(aChatTab.gui.edit, "")
end

function aChatTab.SaveSettings()
	aSetSetting("adminChatSound", guiCheckBoxGetSelected(aChatTab.gui.soundChk))
	aSetSetting("adminChatOutput", guiCheckBoxGetSelected(aChatTab.gui.outputChatChk))
end

function aChatTab.FormatDate(timestamp)
	local date = getRealTime(timestamp)
    return string.format("%02d:%02d:%02d", date.hour, date.minute, date.second)
end