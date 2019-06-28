
aBan = {
	gui = {},
	Thread = nil,
	Result = nil,
	Player = false
}

function aBan.Create()
	aBan.gui.form = guiCreateWindow(0, 0, 340, 230, "Ban player", false)
	--guiSetProperty(aBan.gui.form, "AlwaysOnTop", "True")

	aBan.gui.serialLbl = guiCreateLabel(20, 30, 60, 18, "Serial: ", false, aBan.gui.form)
	guiLabelSetHorizontalAlign(aBan.gui.serialLbl, "right")
	aBan.gui.serialVLbl = guiCreateLabel(90, 30, 230, 18, "", false, aBan.gui.form)
	aBan.gui.serialEdit = guiCreateEdit(90, 30, 230, 18, "", false, aBan.gui.form)

	aBan.gui.ipChk = guiCreateCheckBox(40, 50, 18, 18, "", true, false, aBan.gui.form)
	aBan.gui.ipLbl = guiCreateLabel(60, 50, 20, 18, "IP: ", false, aBan.gui.form)
	guiLabelSetHorizontalAlign(aBan.gui.serialLbl, "right")
	aBan.gui.ipVLbl = guiCreateLabel(90, 50, 230, 18, "", false, aBan.gui.form)
	aBan.gui.ipEdit = guiCreateEdit(90, 50, 230, 18, "", false, aBan.gui.form)
	aBan.gui.ipDisLbl = guiCreateLabel(90, 50, 230, 18, "disabled", false, aBan.gui.form)
	aBan.SetIPState(true)

	guiCreateSeparator(20, 80, 300, 1, 255, 0, 0, false, aBan.gui.form)

	aBan.gui.nickLbl = guiCreateLabel(20, 90, 60, 18, "Nick: ", false, aBan.gui.form)
	guiLabelSetHorizontalAlign(aBan.gui.nickLbl, "right")
	aBan.gui.nickVLbl = guiCreateLabel(90, 90, 190, 18, "", false, aBan.gui.form)
	aBan.gui.nickEdit = guiCreateEdit(90, 90, 190, 18, "", false, aBan.gui.form)

	aBan.gui.durationLbl = guiCreateLabel(20, 110, 60, 18, "Duration: ", false, aBan.gui.form)
	guiLabelSetHorizontalAlign(aBan.gui.durationLbl, "right")
	aBan.gui.durationEdit = guiCreateAdvancedEdit(90, 110, 50, 18, "0", false, aBan.gui.form, true, true, true, 0)
	aBan.gui.durationCmb, aBan.gui.durationList =
		guiCreateAdvancedComboBox(145, 110, 100, 18, "", false, aBan.gui.form)
	guiGridListAddRow(aBan.gui.durationList, "Seconds")
	guiGridListAddRow(aBan.gui.durationList, "Minutes")
	guiGridListAddRow(aBan.gui.durationList, "Hours")
	guiGridListAddRow(aBan.gui.durationList, "Days")
	guiGridListAddRow(aBan.gui.durationList, "Weeks")
	guiGridListAddRow(aBan.gui.durationList, "Permanent")
	guiAdvancedComboBoxSetSelected(aBan.gui.durationCmb, 5)
	guiGridListAdjustHeight(aBan.gui.durationList)

	aBan.gui.reasonLbl = guiCreateLabel(20, 130, 60, 18, "Reason: ", false, aBan.gui.form)
	guiLabelSetHorizontalAlign(aBan.gui.reasonLbl, "right")
	aBan.gui.reasonEdit = guiCreateEdit(90, 130, 230, 18, "", false, aBan.gui.form)

	aBan.gui.okBtn = guiCreateButton(90, 200, 55, 17, "Ban", false, aBan.gui.form)
	aBan.gui.cancelBtn = guiCreateButton(150, 200, 55, 17, "Cancel", false, aBan.gui.form)
	
	addEventHandler("onClientGUIClick", aBan.gui.form, aBan.onClickHandler)
	addEventHandler("onClientGUIAccepted", aBan.gui.form, aBan.Accept)
	
	aRegister("Ban", aBan.gui.form, aBan.Show, aBan.Close)
end

function aBan.Destroy()
	destroyElement(aBan.gui.form)
	aBan.gui.form = nil
end

function aBan.Open(player, serial, ip, nick, duration, reason)
	if not aBan.gui.form then aBan.Create() end
	if guiGetVisible(aBan.gui.form) then aBan.Close() end

	aBan.Player = player

	guiSetText(aBan.gui.serialVLbl, serial or "")
	guiSetText(aBan.gui.serialEdit, serial or "")
	guiSetText(aBan.gui.ipVLbl, ip or "")
	guiSetText(aBan.gui.ipEdit, ip or "")
	guiSetText(aBan.gui.nickVLbl, nick or "")
	guiSetText(aBan.gui.nickEdit, nick or "")
	guiSetText(aBan.gui.reasonEdit, reason or "")
	if duration then aBan.SetDuration(duration) end

	if player then
		guiSetText(aBan.gui.form, "Ban player "..nick)
		guiSetVisible(aBan.gui.serialEdit, false)
		guiSetVisible(aBan.gui.nickEdit, false)
		guiSetVisible(aBan.gui.serialVLbl, true)
		guiSetVisible(aBan.gui.nickVLbl, true)
	else
		guiSetText(aBan.gui.form, "Add ban")
		guiSetVisible(aBan.gui.serialEdit, true)
		guiSetVisible(aBan.gui.nickEdit, true)
		guiSetVisible(aBan.gui.serialVLbl, false)
		guiSetVisible(aBan.gui.nickVLbl, false)
	end

	guiSetVisible(aBan.gui.form, true)

	aBan.Thread = coroutine.running()
	coroutine.yield()

	aBan.Thread = nil
	if not aBan.Result then return false end
	
	return aBan.GetResult()
end

function aBan.Close(destroy)
	if not aBan.gui.form then return end
	if destroy then
		aBan.Destroy()
	else
		guiSetVisible(aBan.gui.form, false)
	end
	if aBan.Thread then
		coroutine.resume(aBan.Thread)
	end
end

function aBan.Accept()
	if not aBan.CheckArguments() then return end
	aBan.Result = true
	aBan.Close()
end

function aBan.Cancel()
	aBan.Result = false
	aBan.Close()
end

function aBan.onClickHandler(key)
	if key ~= "left" then return end

	if source == aBan.gui.ipChk then
		aBan.SetIPState(guiCheckBoxGetSelected(source))

	elseif source == aBan.gui.okBtn then
		aBan.Accept()

	elseif source == aBan.gui.cancelBtn then
		aBan.Cancel()

	end
end

function aBan.GetDuration()
	local dtype = string.lower(string.sub(guiGetText(aBan.gui.durationCmb), 1, 1))
	if dtype == "p" then return 0 end
	return parseDuration(guiGetText(aBan.gui.durationEdit)..dtype)
end

function aBan.SetDuration(seconds)
	guiSetText(aBan.gui.durationEdit, "0")
	guiAdvancedComboBoxSetSelected(aBan.gui.durationCmb, 5)
	if seconds == 0 then return end
	
	for i, s in ipairs({60*60*24*7, 60*60*24, 60*60, 60, 1}) do
		local value = seconds/s
		if math.floor(value) == value then
			guiSetText(aBan.gui.durationEdit, tostring(value))
			guiAdvancedComboBoxSetSelected(aBan.gui.durationCmb, 5-i)
			break
		end
	end
end

function aBan.SetIPState(state)
	guiCheckBoxSetSelected(aBan.gui.ipChk, state)
	guiSetVisible(aBan.gui.ipDisLbl, not state)
	guiSetVisible(aBan.gui.ipEdit, state and not aBan.Player)
	guiSetVisible(aBan.gui.ipVLbl, state and aBan.Player or false)
end

function aBan.GetResult()
	local includeIP = guiCheckBoxGetSelected(aBan.gui.ipChk)
	local duration = aBan.GetDuration()
	local reason = guiGetText(aBan.gui.reasonEdit)
	if reason == "" then reason = nil end

	if aBan.Player then return duration, includeIP, reason end

	local serial = string.upper(guiGetText(aBan.gui.serialEdit))
	local ip = includeIP and guiGetText(aBan.gui.ipEdit) or nil
	local nick = guiGetText(aBan.gui.nickEdit)
	if nick == "" then nick = nil end

	return serial, ip, nick, duration, reason
end

function aBan.CheckArguments()
	if aBan.Player then return true end

	if not isValidSerial(guiGetText(aBan.gui.serialEdit)) then
		messageBox("Invalid serial!", MB_ERROR)
		return false
	end

	if guiCheckBoxGetSelected(aBan.gui.ipChk) and (not isValidIP(guiGetText(aBan.gui.ipEdit))) then
		messageBox("Invalid IP!", MB_ERROR)
		return false
	end
	return true
end