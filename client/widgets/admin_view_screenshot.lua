
aViewScreenShot = {
	gui = {}
}

function aViewScreenShot.Create()
	aViewScreenShot.gui.form = guiCreateWindow(0, 0, 640+10, 480+30, "Screen shot", false)
	aViewScreenShot.gui.img = guiCreateStaticImage(5, 20+5, 640, 480, "client/images/white.png", false, aViewScreenShot.gui.form)
	guiStaticImageSetColor(aViewScreenShot.gui.img, 92, 92, 92)
	aViewScreenShot.gui.msg = guiCreateElementMessageLabel(aViewScreenShot.gui.img, "N/A")
	aViewScreenShot.gui.okBtn = guiCreateButton(640-60-10, 480+30-20-5, 60, 20, "Ok", false, aViewScreenShot.gui.img)

	addEventHandler("onClientGUIClick", aViewScreenShot.gui.form, aViewScreenShot.onClickHandler)

	aRegister("ScreenShot", aViewScreenShot.gui.form, aViewScreenShot.Open, aViewScreenShot.Close)
end

function aViewScreenShot.Destroy()
	destroyElement(aViewScreenShot.gui.form)
	aViewScreenShot.gui = {}
end

function aViewScreenShot.Open(path, number)
	if not aViewScreenShot.gui.form then
		aViewScreenShot.Create()
	end

	if number then
		guiSetText(aViewScreenShot.gui.form, "Screen shot #"..number)
	else
		guiSetText(aViewScreenShot.gui.form, "Screen shot")
	end

	aViewScreenShot.Set(path)
	guiSetVisible(aViewScreenShot.gui.form, true)
end

function aViewScreenShot.Close(destroy)
	if not aViewScreenShot.gui.form then return end
	if destroy then
		aViewScreenShot.Destroy()
	else
		guiSetVisible(aViewScreenShot.gui.form, false)
	end
end

function aViewScreenShot.onClickHandler(key)
	if key ~= "left" then return end

	if source == aViewScreenShot.gui.okBtn then
		aViewScreenShot.Close()

	end
end

function aViewScreenShot.Set(path)
	if path and fileExists(path) and guiStaticImageLoadImage(aViewScreenShot.gui.img, path) then
		guiStaticImageSetColor(aViewScreenShot.gui.img)
		guiSetText(aViewScreenShot.gui.msg, "")
	else
		guiStaticImageLoadImage(aViewScreenShot.gui.img, "client/images/white.png")
		guiStaticImageSetColor(aViewScreenShot.gui.img, 92, 92, 92)
		if path then
			guiSetText(aViewScreenShot.gui.msg, "Couldn't load")
		else
			guiSetText(aViewScreenShot.gui.msg, "N/A")
		end
	end
	aViewScreenShot.CalculateSize()
end

function aViewScreenShot.CalculateSize()
	local sw, sh = guiGetScreenSize()
	local w, h = guiStaticImageGetNativeSize(aViewScreenShot.gui.img)
	if w == 1 then
		w, h = 640, 480
	end
	local maxh = sh - 60
	if h > maxh then
		w, h = w*(maxh/h), maxh
	end
	guiSetSize(aViewScreenShot.gui.form, w + 10, h + 30, false)
	guiCenter(aViewScreenShot.gui.form)
	guiSetPosition(aViewScreenShot.gui.okBtn, w-60-10, h-20-10, false)
	guiSetSize(aViewScreenShot.gui.img, w, h, false)
	guiCenter(aViewScreenShot.gui.msg)
end