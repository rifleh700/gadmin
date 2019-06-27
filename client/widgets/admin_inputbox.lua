
aInputBox = {
	gui = {},
	Thread = nil,
	Result = nil,
	NotEmpty = false,
	OnlyNumbers = false,
}

function inputBox(title, message, default, notEmpty, onlyNumbers)
	if not message then return false end
	return aInputBox.Show(title, message, default, notEmpty, onlyNumbers)
end

function aInputBox.Create()
	aInputBox.gui.form = guiCreateWindow(0, 0, 300, 110, "", false)
	--guiSetProperty(aInputBox.gui.form, "AlwaysOnTop", "true")

	aInputBox.gui.messageLbl = guiCreateLabel(20, 24, 270, 15, "", false, aInputBox.gui.form)
	guiLabelSetHorizontalAlign(aInputBox.gui.messageLbl, "center")
	aInputBox.gui.valueEdit = guiCreateEdit(35, 47, 230, 24, "", false, aInputBox.gui.form)
	
	aInputBox.gui.okBtn = guiCreateButton(90, 80, 55, 17, "Ok", false, aInputBox.gui.form)
	aInputBox.gui.cancelBtn = guiCreateButton(150, 80, 55, 17, "Cancel", false, aInputBox.gui.form)
	
	addEventHandler("onClientGUIChanged", aInputBox.gui.valueEdit, aInputBox.CheckValue, false)
	addEventHandler("onClientGUIAccepted", aInputBox.gui.valueEdit, aInputBox.Accept, false)

	addEventHandler("onClientGUIClick", aInputBox.gui.form, aInputBox.onClickHandler)
	
	aRegister("InputBox", aInputBox.gui.form, aInputBox.Show, aInputBox.Close)
end

function aInputBox.Destroy()
	destroyElement(aInputBox.gui.form)
	aInputBox.gui.form = nil
end

function aInputBox.Show(title, message, default, notEmpty, onlyNumbers)
	if not aInputBox.gui.form then
		aInputBox.Create()
	end
	guiSetText(aInputBox.gui.form, title)
	guiSetText(aInputBox.gui.messageLbl, message)
	guiSetText(aInputBox.gui.valueEdit, default or "")
	guiSetVisible(aInputBox.gui.form, true)

	if aMessageBox.gui.form then
		guiSetVisible(aMessageBox.gui.form, false)
	end

	aInputBox.Result = nil
	aInputBox.NotEmpty = notEmpty
	aInputBox.OnlyNumbers = onlyNumbers
	aInputBox.Thread = coroutine.running()
	coroutine.yield()

	aInputBox.Thread = nil
	if not aInputBox.Result then return false end

	return aInputBox.FormatResult()
end

function aInputBox.Close(destroy)
	if not aInputBox.gui.form then return end
	if destroy then
		aInputBox.Destroy()
	else
		guiSetVisible(aInputBox.gui.form, false)
	end
	if aInputBox.Thread then
		coroutine.resume(aInputBox.Thread)
	end
end

function aInputBox.Accept()
	if aInputBox.NotEmpty and string.trim(guiGetText(aInputBox.gui.valueEdit)) == "" then return end

	aInputBox.Result = true
	aInputBox.Close(false)
end

function aInputBox.Cancel(button)
	aInputBox.Result = false
	aInputBox.Close(false)
end

function aInputBox.onClickHandler(button)
	if button ~= "left" then return end
	if source == aInputBox.gui.okBtn then
		aInputBox.Accept()
	elseif source == aInputBox.gui.cancelBtn then
		aInputBox.Cancel()
	end
end

function aInputBox.CheckValue()
	if not aInputBox.OnlyNumbers then return end
	guiSetText(aInputBox.gui.valueEdit, string.match(guiGetText(aInputBox.gui.valueEdit), "%-?%d*%.?%d*") or "")
end

function aInputBox.FormatResult()
	local text = guiGetText(aInputBox.gui.valueEdit)
	text = string.trim(text)
	if aInputBox.OnlyNumbers then return tonumber(text) end
	return text
end
