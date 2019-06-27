
aSelectScreenShots = {
	gui = {},
	SelectedMax = 4,
	Thread = nil,
	Result = nil,
}

function aSelectScreenShots.Create()
	local width, height = 256*2 + 20 + 10*4, 400
	aSelectScreenShots.gui.form = guiCreateWindow(0, 0, width, height, "Attach screenshots", false)

	aSelectScreenShots.gui.pane = guiCreateScrollPane(0, 20+10, width-(10*2), height-(20+20+10*3), false, aSelectScreenShots.gui.form)
	guiSetProperty(aSelectScreenShots.gui.pane, "ForceVertScrollbar", "True")
	aSelectScreenShots.gui.columns = 2
	aSelectScreenShots.gui.screens = {}

	aSelectScreenShots.gui.acceptBtn = guiCreateButton(10, 370, 60, 18, "Attach", false, aSelectScreenShots.gui.form)
	aSelectScreenShots.gui.cancelBtn = guiCreateButton(80, 370, 60, 18, "Cancel", false, aSelectScreenShots.gui.form)

	addEventHandler("onClientGUIClick", aSelectScreenShots.gui.form, aSelectScreenShots.onClickHandler)
	addEventHandler("onClientMouseMove", aSelectScreenShots.gui.pane, aSelectScreenShots.LoadImages, false)
	addEventHandler("onClientGUICheckStaticImageChecked", aSelectScreenShots.gui.form, aSelectScreenShots.onCheckedHandler)
end

function aSelectScreenShots.Destroy()
	destroyElement(aSelectScreenShots.gui.form)
	aSelectScreenShots.gui = {}
end

function aSelectScreenShots.Open(selected)
	if #aGetScreenShotIDList() == 0 then
		messageBox("Screenshots not found", MB_ERROR)
		return false
	end

	if not aSelectScreenShots.gui.form then
		aSelectScreenShots.Create()
	end

	aSelectScreenShots.Refresh()
	for i, id in ipairs(selected) do
		aSelectScreenShots.SetSelected(id, true)
	end

	guiSetVisible(aSelectScreenShots.gui.form, true)
	
	aSelectScreenShots.Result = nil
	aSelectScreenShots.Thread = coroutine.running()
	coroutine.yield()

	aSelectScreenShots.Thread = nil

	return aSelectScreenShots.Result
end

function aSelectScreenShots.Close()
	if not aSelectScreenShots.gui.form then return end
	guiSetVisible(aSelectScreenShots.gui.form, false)
	if aSelectScreenShots.Thread then
		coroutine.resume(aSelectScreenShots.Thread)
	end
end

function aSelectScreenShots.onClickHandler(key)
	if key ~= "left" then return end

	if getElementData(source, "type") == "view" then
		local id = getElementData(source, "id")
		local path = aGetScreenShotPath(id)
		if not path then
			return messageBox("Couldn't load screenshot", MB_ERROR)
		end
		aViewScreenShot.Open(path, id)

	elseif source == aSelectScreenShots.gui.acceptBtn then
		aSelectScreenShots.Result = aSelectScreenShots.GetSelected()
		aSelectScreenShots.Close()

	elseif source == aSelectScreenShots.gui.cancelBtn then
		aSelectScreenShots.Close()

	end
end

function aSelectScreenShots.onCheckedHandler()
	local nonselected = {}
	local selected = {}
	for i, data in ipairs(aSelectScreenShots.gui.screens) do
		if guiCheckStaticImageGetSelected(data.image) then
			selected[#selected + 1] = i
		else
			nonselected[#nonselected + 1] = i
		end
	end

	local enabled = #selected < aSelectScreenShots.SelectedMax
	for i, number in ipairs(nonselected) do
		guiSetEnabled(aSelectScreenShots.gui.screens[number].image, enabled)
	end
end

function aSelectScreenShots.GetSelected()
	local selected = {}
	for i, data in ipairs(aSelectScreenShots.gui.screens) do
		if guiCheckStaticImageGetSelected(data.image) then
			selected[#selected + 1] = data.id
		end
	end
	return selected
end

function aSelectScreenShots.SetSelected(id, state)
	for i, data in ipairs(aSelectScreenShots.gui.screens) do
		if data.id == id then
			guiCheckStaticImageSetSelected(data.image, state)
			break
		end
	end
end

function aSelectScreenShots.Refresh()
	for i, data in ipairs(aSelectScreenShots.gui.screens) do
		destroyElement(data.image)
	end
	aSelectScreenShots.gui.screens = {}
	guiScrollPaneSetVerticalScrollPosition(aSelectScreenShots.gui.pane, 0)

	
	local width = 256
	for i, id in ipairs(table.reverse(aGetScreenShotIDList())) do
	
		local image = guiCreateCheckStaticImage(0, 0, width, width*0.5625, "client/images/white.png", false, aSelectScreenShots.gui.pane)
		guiStaticImageSetColor(image, 92, 92, 92)
		local lbl = guiCreateLabel(25, 5, 50, 20, "#"..id, false, image)
		local message = guiCreateElementMessageLabel(image, "Loading...")

		aSelectScreenShots.gui.screens[i] = {
			id = id,
			image = image,
			message = message,
			loaded = false
		}
	end

	aSelectScreenShots.LoadImages()
end

function aSelectScreenShots.LoadImages()
	if #aSelectScreenShots.gui.screens == 0 then return end

	local scroll = guiScrollPaneGetVerticalScrollPosition(aSelectScreenShots.gui.pane)
	local columns = aSelectScreenShots.gui.columns
	local rows = math.ceil(#aSelectScreenShots.gui.screens/columns)
	local row = math.floor(rows * scroll/100)

	for number = row * columns + 1, (row + 2) * columns do
		local data = aSelectScreenShots.gui.screens[number]
		if data and (not data.loaded) then
			local path = aGetScreenShotPath(data.id)
			--[[
			local path = "screenshots/thumbnails/"..data.id..".jpg"
			if not fileExists(path) then
				aSelectScreenShots.UpdateThumbnail(data.id)
			end
			]]--
			if path and guiStaticImageLoadImage(data.image, path) then
				guiStaticImageSetColor(data.image, 255, 255, 255)
				guiSetText(data.message, "")
				
				local nw, nh = guiStaticImageGetNativeSize(data.image)
				local height = 256*(nh/nw)
				guiSetSize(data.image, 256, height, false)

				data.view = guiCreateButton(5, 25, 60, 18, "View", false, data.image)
				setElementData(data.view, "type", "view")
				setElementData(data.view, "id", data.id)
			else
				guiSetEnabled(data.image, false)
				guiSetText(data.message, "Couldn't load")
			end
			data.loaded = true
		end 
	end

	aSelectScreenShots.Align()
end

function aSelectScreenShots.Align()
	
	local width = 256
	local columns = 2
	local rows = math.ceil(#aSelectScreenShots.gui.screens/columns)
	local y = 0
	for row = 0, rows - 1 do

		local numbers = {}
		for number = row * columns + 1, (row + 1) * columns do
			if number > #aSelectScreenShots.gui.screens then break end
			numbers[#numbers + 1] = number
		end

		local maxh = 0
		for column, number in ipairs(numbers) do
			local _, sh = guiGetSize(aSelectScreenShots.gui.screens[number].image, false)
			if sh > maxh then maxh = sh end
		end

		for column, number in ipairs(numbers) do
			local x = (column - 1) * (width + 10)
			local _, h = guiGetSize(aSelectScreenShots.gui.screens[number].image, false)
			guiSetPosition(aSelectScreenShots.gui.screens[number].image, x, y + (maxh - h)/2, false)
		end

		y = y + maxh + 10
	end
end