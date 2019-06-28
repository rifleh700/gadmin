
aMute = {
	gui = {},
	Thread = nil,
	Result = nil,
	Player = false
}

function aMute.Create()
	aMute.gui.form = guiCreateWindow(0, 0, 340, 170, "Ban player", false)
	--guiSetProperty(aMute.gui.form, "AlwaysOnTop", "True")

	aMute.gui.serialLbl = guiCreateLabel(20, 30, 60, 18, "Serial: ", false, aMute.gui.form)
	guiLabelSetHorizontalAlign(aMute.gui.serialLbl, "right")
	aMute.gui.serialVLbl = guiCreateLabel(90, 30, 230, 18, "", false, aMute.gui.form)
	aMute.gui.serialEdit = guiCreateEdit(90, 30, 230, 18, "", false, aMute.gui.form)

	guiCreateSeparator(20, 60, 300, 1, 255, 0, 0, false, aMute.gui.form)

	aMute.gui.nickLbl = guiCreateLabel(20, 70, 60, 18, "Nick: ", false, aMute.gui.form)
	guiLabelSetHorizontalAlign(aMute.gui.nickLbl, "right")
	aMute.gui.nickVLbl = guiCreateLabel(90, 70, 190, 18, "", false, aMute.gui.form)
	aMute.gui.nickEdit = guiCreateEdit(90, 70, 190, 18, "", false, aMute.gui.form)

	aMute.gui.durationLbl = guiCreateLabel(20, 90, 60, 18, "Duration: ", false, aMute.gui.form)
	guiLabelSetHorizontalAlign(aMute.gui.durationLbl, "right")
	aMute.gui.durationEdit = guiCreateAdvancedEdit(90, 90, 50, 18, "0", false, aMute.gui.form, true, true, true, 0)
	aMute.gui.durationCmb, aMute.gui.durationList =
		guiCreateAdvancedComboBox(145, 90, 100, 18, "", false, aMute.gui.form)
	guiGridListAddRow(aMute.gui.durationList, "Seconds")
	guiGridListAddRow(aMute.gui.durationList, "Minutes")
	guiGridListAddRow(aMute.gui.durationList, "Hours")
	guiGridListAddRow(aMute.gui.durationList, "Days")
	guiGridListAddRow(aMute.gui.durationList, "Weeks")
	guiGridListAddRow(aMute.gui.durationList, "Permanent")
	guiAdvancedComboBoxSetSelected(aMute.gui.durationCmb, 5)
	guiGridListAdjustHeight(aMute.gui.durationList)

	aMute.gui.reasonLbl = guiCreateLabel(20, 110, 60, 18, "Reason: ", false, aMute.gui.form)
	guiLabelSetHorizontalAlign(aMute.gui.reasonLbl, "right")
	aMute.gui.reasonEdit = guiCreateEdit(90, 110, 230, 18, "", false, aMute.gui.form)

	aMute.gui.okBtn = guiCreateButton(90, 140, 55, 17, "Mute", false, aMute.gui.form)
	aMute.gui.cancelBtn = guiCreateButton(150, 140, 55, 17, "Cancel", false, aMute.gui.form)
	
	addEventHandler("onClientGUIClick", aMute.gui.form, aMute.onClickHandler)
	addEventHandler("onClientGUIAccepted", aMute.gui.form, aMute.Accept)
	
	aRegister("Mute", aMute.gui.form, aMute.Show, aMute.Close)
end

function aMute.Destroy()
	destroyElement(aMute.gui.form)
	aMute.gui.form = nil
end

function aMute.Open(player, serial, nick, duration, reason)
	if not aMute.gui.form then aMute.Create() end
	if guiGetVisible(aMute.gui.form) then aMute.Close() end

	aMute.Player = player

	guiSetText(aMute.gui.serialVLbl, serial or "")
	guiSetText(aMute.gui.serialEdit, serial or "")
	guiSetText(aMute.gui.nickVLbl, nick or "")
	guiSetText(aMute.gui.nickEdit, nick or "")
	guiSetText(aMute.gui.reasonEdit, reason or "")
	if duration then aMute.SetDuration(duration) end

	if player then
		guiSetText(aMute.gui.form, "Mute player "..nick)
		guiSetVisible(aMute.gui.serialEdit, false)
		guiSetVisible(aMute.gui.nickEdit, false)
		guiSetVisible(aMute.gui.serialVLbl, true)
		guiSetVisible(aMute.gui.nickVLbl, true)
	else
		guiSetText(aMute.gui.form, "Mute serial")
		guiSetVisible(aMute.gui.serialEdit, true)
		guiSetVisible(aMute.gui.nickEdit, true)
		guiSetVisible(aMute.gui.serialVLbl, false)
		guiSetVisible(aMute.gui.nickVLbl, false)
	end

	guiSetVisible(aMute.gui.form, true)

	aMute.Thread = coroutine.running()
	coroutine.yield()

	aMute.Thread = nil
	if not aMute.Result then return false end
	
	return aMute.GetResult()
end

function aMute.Close(destroy)
	if not aMute.gui.form then return end
	if destroy then
		aMute.Destroy()
	else
		guiSetVisible(aMute.gui.form, false)
	end
	if aMute.Thread then
		coroutine.resume(aMute.Thread)
	end
end

function aMute.Accept()
	if not aMute.CheckArguments() then return end
	aMute.Result = true
	aMute.Close()
end

function aMute.Cancel()
	aMute.Result = false
	aMute.Close()
end

function aMute.onClickHandler(key)
	if key ~= "left" then return end

	if source == aMute.gui.okBtn then
		aMute.Accept()

	elseif source == aMute.gui.cancelBtn then
		aMute.Cancel()

	end
end

function aMute.GetDuration()
	local dtype = string.lower(string.sub(guiGetText(aMute.gui.durationCmb), 1, 1))
	if dtype == "p" then return 0 end
	return parseDuration(guiGetText(aMute.gui.durationEdit)..dtype)
end

function aMute.SetDuration(seconds)
	guiSetText(aMute.gui.durationEdit, "0")
	guiAdvancedComboBoxSetSelected(aMute.gui.durationCmb, 5)
	if seconds == 0 then return end
	
	for i, s in ipairs({60*60*24*7, 60*60*24, 60*60, 60, 1}) do
		local value = seconds/s
		if math.floor(value) == value then
			guiSetText(aMute.gui.durationEdit, tostring(value))
			guiAdvancedComboBoxSetSelected(aMute.gui.durationCmb, 5-i)
			break
		end
	end
end

function aMute.GetResult()
	local duration = aMute.GetDuration()
	local reason = guiGetText(aMute.gui.reasonEdit)
	if reason == "" then reason = nil end

	if aMute.Player then return duration, reason end

	local serial = string.upper(guiGetText(aMute.gui.serialEdit))
	local nick = guiGetText(aMute.gui.nickEdit)
	if nick == "" then nick = nil end

	return serial, nick, duration, reason
end

function aMute.CheckArguments()
	if aMute.Player then return true end
	if not isValidSerial(guiGetText(aMute.gui.serialEdit)) then
		messageBox("Invalid serial!", MB_ERROR)
		return false
	end
	return true
end