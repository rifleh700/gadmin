
aReport = {
	gui = {},
	ScreenShots = {}
}

function aReport.Create()
	aReport.gui.form = guiCreateWindow(0, 0, 300, 300, "Contact admin", false)

	aReport.gui.messageMemo = guiCreateMemo(0.05, 0.1, 0.90, 0.45, "", true, aReport.gui.form)
	aReport.gui.attechedLbl = guiCreateLabel(0.05, 0.56, 0.40, 0.06, "", true, aReport.gui.form)
	aReport.gui.attachBtn = guiCreateButton(0.45, 0.56, 0.50, 0.06, "Attach screenshots...", true, aReport.gui.form)

	aReport.gui.acceptBtn = guiCreateButton(0.40, 0.88, 0.25, 0.06, "Send", true, aReport.gui.form)
	aReport.gui.cancelBtn = guiCreateButton(0.70, 0.88, 0.25, 0.06, "Cancel", true, aReport.gui.form)

	addEventHandler("onClientGUIClick", aReport.gui.form, aReport.onClickHandler)
end

function aReport.Destroy()
	destroyElement(aReport.gui.form)
	aReport.gui = {}
end

function aReport.Open()
	if not aReport.gui.form then
		aReport.Create()
	end

	aReport.ScreenShots = {}
	guiSetText(aReport.gui.messageMemo, "")
	guiSetText(aReport.gui.attechedLbl, "")

	if #aGetScreenShotIDList() > 0 then
		guiSetEnabled(aReport.gui.attachBtn, true)
	else
		guiSetEnabled(aReport.gui.attachBtn, false)
	end

	guiSetVisible(aReport.gui.form, true)
	showCursor(true)
end
addCommandHandler("report", aReport.Open)

function aReport.Close()
	if not aReport.gui.form then return end
	guiSetVisible(aReport.gui.form, false)
	showCursor(false)
end

function aReport.onClickHandler(key)
	if key ~= "left" then return end

	if source == aReport.gui.attachBtn then
		local screens = aSelectScreenShots.Open(aReport.ScreenShots)
		if not screens then return end

		aReport.ScreenShots = screens
		if #aReport.ScreenShots > 0 then
			guiSetText(aReport.gui.attechedLbl, "attached: "..#aReport.ScreenShots)
		end 

	elseif source == aReport.gui.acceptBtn then
		local message = guiGetText(aReport.gui.messageMemo)
		if string.len(message) < 5 then
			messageBox("Message too short", MB_ERROR)
			return
		end

		aReport.Close()

		local chat = aGetChatHistory()
		local screenshots = {}
		if #aReport.ScreenShots > 0 then
			for i, id in ipairs(aReport.ScreenShots) do
				screenshots[i] = aGetScreenShot(id)
			end
			triggerLatentServerEvent(EVENT_REPORT, 50000, localPlayer, message, screenshots, chat)
		else
			triggerServerEvent(EVENT_REPORT, localPlayer, message, screenshots, chat)
		end

		messageBox("Your message has been submited and will be processed as soon as possible", MB_INFO, MB_NOTIFY)

	elseif source == aReport.gui.cancelBtn then
		aReport.Close()

	end
end