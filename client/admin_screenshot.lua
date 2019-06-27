
local aScreenShot = {
	Requested =  false,
	ScreenSource = nil,
	Count = nil,
	MaxAmount = nil
}

addEvent(EVENT_SCREEN_SHOT, true)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		aScreenShot.Count = aGetSetting("screenshotCount", true, true) or 0
		-- need get resource setting
		aScreenShot.MaxAmount = 10
		aScreenShot.DeleteUnwanted()
	end
)

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		aSetSetting("screenshotCount", aScreenShot.Count)
	end
)

addEventHandler("onClientKey", root,
	function(button, press)
		if not press then return end
		if button ~= getKeyBoundToCommand("screenshot") then return end
		aScreenShot.Requested = true
	end
)

addEventHandler("onClientPreRender", root,
	function()
		if not aScreenShot.Requested then return end
		if not aScreenShot.ScreenSource then
			aScreenShot.ScreenSource = dxCreateScreenSource(guiGetScreenSize())
		end
		if not aScreenShot.ScreenSource then return end
		if not dxUpdateScreenSource(aScreenShot.ScreenSource, true) then return end

		aScreenShot.Requested = false
		aScreenShot.Save(aScreenShot.Take())
	end
)

addEventHandler(EVENT_SCREEN_SHOT, localPlayer,
	function(tag, quality)
		triggerServerEvent(EVENT_SCREEN_SHOT, localPlayer, aScreenShot.Take(quality), tag)
	end
)

function aScreenShot.Take(quality)
	return dxConvertPixels(dxGetTexturePixels(aScreenShot.ScreenSource), "jpeg", quality or 85)
end

function aScreenShot.DeleteUnwanted()
	local ids = aGetScreenShotIDList()
	while #ids > aScreenShot.MaxAmount do
		fileDelete("screenshots/"..table.remove(ids, 1)..".jpg")
	end
end

function aScreenShot.Save(pixels)
	local id = aScreenShot.Count + 1
	local path = "screenshots/"..id..".jpg"
	while fileExists(path) do
		id = id + 1
		path = "screenshots/"..id..".jpg"
	end
	aScreenShot.Count = id

	local file = fileCreate(path)
	if not file then return end

	fileWrite(file, pixels)
	fileClose(file)
end

function aScreenShot.UpdateThumbnail(id)
	local path = "screenshots/"..id..".jpg"
	if not fileExists(path) then return end

	local file = fileOpen(path, true)
	if not file then return end
	
	local pixels = fileRead(file, fileGetSize(file))
	fileClose(file)

	local w, h = dxGetPixelsSize(pixels)
	local tw, th = 256, 256*(h/w)
	local thumbnail = dxCreateRenderTarget(tw, th)
	dxSetRenderTarget(thumbnail)
	dxDrawImage(0, 0, tw, th, path)
	dxSetRenderTarget()

	pixels = dxConvertPixels(dxGetTexturePixels(thumbnail), "jpeg", 85)
	destroyElement(thumbnail)

	path = "screenshots/thumbnails/"..id..".jpg"
	if fileExists(path) then
		fileDelete(path)
	end
	file = fileCreate(path)
	if not file then return end

	fileWrite(file, pixels)
	fileClose(file)
end

function aGetScreenShotIDList()
	local list = {}
	for id = 1, aScreenShot.Count do
		if fileExists("screenshots/"..id..".jpg") then
			list[#list + 1] = id
		end
	end
	return list
end

function aGetScreenShotPath(id)
	if not fileExists("screenshots/"..id..".jpg") then return false end
	return "screenshots/"..id..".jpg"
end

function aGetScreenShot(id)
	local path = "screenshots/"..id..".jpg"
	if not fileExists("screenshots/"..id..".jpg") then return false end

	local file = fileOpen(path, true)
	if not file then return false end
	if fileGetSize(file) > 1000000 then
		fileClose(file)
		return false
	end

	local pixels = fileRead(file, fileGetSize(file))
	fileClose(file)

	return pixels
end

function aTakeScreenShot()
	return aScreenShot.Take()
end