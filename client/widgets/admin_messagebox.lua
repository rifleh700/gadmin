
MB_WARNING = 1
MB_ERROR = 2
MB_QUESTION = 3
MB_INFO = 4

MB_YESNO = 1
MB_OK = 2
MB_NOTIFY = 3

aMessageBox = {
	gui = {},
	type = {"Warning", "Error", "Question", "Info"},
	Thread = nil,
	Result = false
}

addEvent(EVENT_MESSAGE_BOX, true)

function messageBox(message, icon, messageType)
	if not message then return false end
	return aMessageBox.Show(message, icon or MB_INFO, messageType or MB_OK)
end

addEventHandler(EVENT_MESSAGE_BOX, localPlayer, messageBox)

function aMessageBox.Create()
	aMessageBox.gui.form = guiCreateWindow(0, 0, 300, 80, "", false)
	guiSetProperty(aMessageBox.gui.form, "AlwaysOnTop", "True")

	aMessageBox.gui.img = guiCreateStaticImage(0, 0, 42, 42, "client/images/empty.png", false, aMessageBox.gui.form)
	aMessageBox.gui.infoImg = guiCreateStaticImage(0, 0, 42, 42, "client/images/info.png", false, aMessageBox.gui.img)
	aMessageBox.gui.questionImg =
		guiCreateStaticImage(0, 0, 42, 42, "client/images/question.png", false, aMessageBox.gui.img)
	aMessageBox.gui.warningImg = guiCreateStaticImage(0, 0, 42, 42, "client/images/warning.png", false, aMessageBox.gui.img)
	aMessageBox.gui.errorImg = guiCreateStaticImage(0, 0, 42, 42, "client/images/error.png", false, aMessageBox.gui.img)
	
	aMessageBox.gui.lbl = guiCreateLabel(100, 32, 180, 16, "", false, aMessageBox.gui.form)
	guiLabelSetHorizontalAlign(aMessageBox.gui.lbl, "center", true)
	guiLabelSetVerticalAlign(aMessageBox.gui.lbl, "center")
	
	aMessageBox.gui.yesBtn = guiCreateButton(120, -30, 55, 17, "Yes", false, aMessageBox.gui.form)
	aMessageBox.gui.noBtn = guiCreateButton(180, -30, 55, 17, "No", false, aMessageBox.gui.form)
	aMessageBox.gui.okBtn = guiCreateButton(160, -30, 55, 17, "Ok", false, aMessageBox.gui.form)

	bindKey("enter", "down", aMessageBox.Accept, true)
	bindKey("y", "down", aMessageBox.Accept, true)
	bindKey("n", "down", aMessageBox.Cancel, false)

	addEventHandler("onClientGUIClick", aMessageBox.gui.form, aMessageBox.onClickHandler)

	aRegister("MessageBox", aMessageBox.gui.form, aMessageBox.Show, aMessageBox.Hide)
end

function aMessageBox.Show(message, icon, messageType)
	if not aMessageBox.gui.form then aMessageBox.Create() end

	guiSetText(aMessageBox.gui.form, aMessageBox.type[icon])
	guiSetText(aMessageBox.gui.lbl, tostring(message))
	aMessageBox.Align()

	guiCenter(aMessageBox.gui.form)
	guiSetVisible(aMessageBox.gui.form, true)

	guiSetVisible(aMessageBox.gui.warningImg, icon == MB_WARNING)
	guiSetVisible(aMessageBox.gui.questionImg, icon == MB_QUESTION)
	guiSetVisible(aMessageBox.gui.errorImg, icon == MB_ERROR)
	guiSetVisible(aMessageBox.gui.infoImg, icon == MB_INFO)

	if messageType == MB_YESNO then
		guiSetVisible(aMessageBox.gui.yesBtn, true)
		guiSetVisible(aMessageBox.gui.noBtn, true)
		guiSetVisible(aMessageBox.gui.okBtn, false)

	elseif messageType == MB_NOTIFY then
		guiSetVisible(aMessageBox.gui.yesBtn, false)
		guiSetVisible(aMessageBox.gui.noBtn, false)
		guiSetVisible(aMessageBox.gui.okBtn, false)

	else
		guiSetVisible(aMessageBox.gui.okBtn, true)
		guiSetVisible(aMessageBox.gui.yesBtn, false)
		guiSetVisible(aMessageBox.gui.noBtn, false)
	end

	local thread = coroutine.running()

	if messageType == MB_NOTIFY then
		setTimer(function() if aMessageBox.Thread == thread then aMessageBox.Hide() end end, 4000, 1)
	end

	aMessageBox.Thread = thread
	aMessageBox.Result = false
	coroutine.yield()

	aMessageBox.Thread = nil
	return aMessageBox.Result
end

function aMessageBox.Hide(destroy)
	if not aMessageBox.gui.form then return end
	if destroy then
		unbindKey("enter", "down", aMessageBox.Accept)
		unbindKey("y", "down", aMessageBox.Accept)
		unbindKey("n", "down", aMessageBox.Cancel)
		destroyElement(aMessageBox.gui.form)
		aMessageBox.gui = {}
	else
		guiSetVisible(aMessageBox.gui.form, false)
	end
	if aMessageBox.Thread then
		coroutine.resume(aMessageBox.Thread)
	end
end

function aMessageBox.Align()
	local w, h = guiLabelCalculateHeight(aMessageBox.gui.lbl, 180)
	if w < 180 then w = 180 end

	guiSetSize(aMessageBox.gui.lbl, w, h, false)

	w, h = w + 100 + 20, h + 70
	guiSetSize(aMessageBox.gui.form, w, h, false)
	
	guiSetPosition(aMessageBox.gui.img, (100-42)/2, (h-20-30-42)/2+20, false)
	guiSetPosition(aMessageBox.gui.yesBtn, 120, h - 30, false)
	guiSetPosition(aMessageBox.gui.noBtn, 180, h - 30, false)
	guiSetPosition(aMessageBox.gui.okBtn, 160, h - 30, false)
end

function aMessageBox.Accept()
	aMessageBox.Result = true
	aMessageBox.Hide()
end

function aMessageBox.Cancel()
	aMessageBox.Result = false
	aMessageBox.Hide()
end

function aMessageBox.onClickHandler(button)
	if button ~= "left" then return end
	if source == aMessageBox.gui.noBtn then
		aMessageBox.Cancel()
	elseif (source == aMessageBox.gui.yesBtn) or (source == aMessageBox.gui.okBtn) then
		aMessageBox.Accept()
	end
end