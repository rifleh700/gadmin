
aColor = {
	gui = {},
	Color = {
		r = 0,
		g = 0,
		b = 0,
		h = 0,
		s = 0,
		v = 0,
	},
	Thread = nil,
	Accepted = false
}

function aColor.Create()
	aColor.gui.form = guiCreateStaticImage(0, 0, 372, 84, "client/images/white.png", false)
	guiStaticImageSetColor(aColor.gui.form, 0, 0, 0)
	guiSetAlpha(aColor.gui.form, 0.8)

	aColor.gui.colors = {}

	local x, y = 10, 10
	aColor.gui.currentImg = guiCreateStaticImage(x, y, 64, 18, "client/images/white.png", false, aColor.gui.form)
	guiStaticImageSetColor(aColor.gui.currentImg, 255, 0, 0)
	guiSetProperty(aColor.gui.currentImg, "InheritsAlpha", "False")

	aColor.gui.colors.hex = {}
	aColor.gui.colors.hex.lbl = guiCreateLabel(0, -2, 64, 18, "", false, aColor.gui.currentImg)
	guiSetEnabled(aColor.gui.colors.hex.lbl, false)
	guiLabelSetVerticalAlign(aColor.gui.colors.hex.lbl, "center")
	guiLabelSetHorizontalAlign(aColor.gui.colors.hex.lbl, "center")
	aColor.gui.colors.hex.edit = guiCreateEdit(x, y, 64, 18, "", false, aColor.gui.form)
	guiSetProperty(aColor.gui.colors.hex.edit, "ValidationString", "^([A-F]|[0-9])*$")
	guiSetVisible(aColor.gui.colors.hex.edit, false)
	setElementData(aColor.gui.colors.hex.edit, "type", "hex")

	---------------------------
	y = y + 18 + 5
	aColor.gui.okBtn = guiCreateButton(x, y, 64, 18, "Ok", false, aColor.gui.form)

	y = y + 18 + 5
	aColor.gui.cancelBtn = guiCreateButton(x, y, 64, 18, "Cancel", false, aColor.gui.form)

	---------------------------
	x = x + 64 + 10
	y = 10

	for i, color in ipairs({"r", "g", "b"}) do
		aColor.gui.colors[color] = {}
		aColor.gui.colors[color].lbl = guiCreateLabel(x, y, 15, 18, string.upper(color)..":", false, aColor.gui.form)
		guiLabelSetVerticalAlign(aColor.gui.colors[color].lbl, "center")
		aColor.gui.colors[color].edit = guiCreateAdvancedEdit(x + 15, y, 50, 18, "0", false, aColor.gui.form, true, true, true, 0, 255)
		setElementData(aColor.gui.colors[color].edit, "type", color)
		y = y + 18 + 5
	end

	---------------------------
	x = x + 75
	y = 10

	for i, color in ipairs({"h", "s", "v"}) do
		aColor.gui.colors[color] = {}
		aColor.gui.colors[color].lbl = guiCreateLabel(x, y, 15, 18, string.upper(color)..":", false, aColor.gui.form)
		guiLabelSetVerticalAlign(aColor.gui.colors[color].lbl, "center")
		aColor.gui.colors[color].edit = guiCreateAdvancedEdit(x + 15, y, 50, 18, "0", false, aColor.gui.form, true, true, true, 0, color == "h" and 360 or 100)
		setElementData(aColor.gui.colors[color].edit, "type", color)
		aColor.gui.colors[color].barImg = guiCreateStaticImage(x+75, y+1, 128, 16, "client/images/"..(color == "h" and "hue" or "white")..".png", false, aColor.gui.form)
		guiSetProperty(aColor.gui.colors[color].barImg, "InheritsAlpha", "False")
		aColor.gui.colors[color].cursorImg = guiCreateStaticImage(-17, -9, 32, 32, "client/images/hsvcursor.png", false, aColor.gui.colors[color].barImg)
		guiSetProperty(aColor.gui.colors[color].cursorImg, "ClippedByParent", "False")
		y = y + 18 + 5
	end

	addEventHandler("onClientGUIChanged", aColor.gui.form, aColor.CheckEdit)
	addEventHandler("onClientGUIChanged", aColor.gui.colors.hex.edit, aColor.CheckHexEdit, false)
	addEventHandler("onClientGUIAccepted", aColor.gui.colors.hex.edit,
		function()
			guiBlur(aColor.gui.colors.hex.edit)
		end,
		false
	)

	addEventHandler("onClientGUIClick", aColor.gui.currentImg, aColor.ShowHexEdit, false)
	addEventHandler("onClientGUIBlur", aColor.gui.colors.hex.edit, aColor.HideHexEdit, false)
	
	addEventHandler("onClientGUIClick", aColor.gui.cancelBtn, aColor.Close, false)
	addEventHandler("onClientGUIClick", aColor.gui.okBtn, aColor.Accept, false)
	
	addEventHandler("onClientGUIBlur", aColor.gui.form, aColor.onBlurHandler, false)	

	aRegister("Color", aColor.gui.form, aColor.Open, aColor.Close)
end

function aColor.Destroy()
	destroyElement(aColor.gui.form)
	aColor.gui = {}
end

function aColor.Open(x, y, r, g, b)
	if (not x) or (not y) then
		x, y = getCursorAbsolutePosition()
	end
	x = x + 2
	y = y - 10

	if not aColor.gui.form then
		aColor.Create()
	end
	guiSetPosition(aColor.gui.form, x, y, false)

	aColor.Color.h, aColor.Color.s, aColor.Color.v = aColor.rgb2hsv(r, g ,b)
	aColor.Accepted = false
	aColor.Picking = false
	aColor.EditAntiRecursion = false
	aColor.Update()
	
	guiSetVisible(aColor.gui.form, true)

	addEventHandler("onClientRender", root, aColor.onRenderHandler)
	addEventHandler("onClientClick", root, aColor.onClickHandler)

	aColor.Thread = coroutine.running()
	coroutine.yield()

	aColor.Thread = nil
	if not aColor.Accepted then return false end

	return aColor.Color.r, aColor.Color.g, aColor.Color.b
end

function aColor.Close(destroy)
	if not aColor.gui.form then return end
	removeEventHandler("onClientClick", root, aColor.onClickHandler)
	removeEventHandler("onClientRender", root, aColor.onRenderHandler)
	if destroy == true then
		aColor.Destroy()
	else
		guiSetVisible(aColor.gui.form, false)
	end
	if aColor.Thread then
		coroutine.resume(aColor.Thread)
	end
end

function aColor.onClickHandler(button, state, x, y)
	if button ~= "left" then return end

	if state == "up" then
		aColor.Pick = false

	elseif state == "down" then
		for i, color in ipairs({"h", "s", "v"}) do
			if guiIsCursorInside(aColor.gui.colors[color].barImg) then
				aColor.Pick = color
				break
			end
		end
	end
end

function aColor.onRenderHandler()
	if not aColor.Pick then return end

	local cx = getCursorAbsolutePosition()
	local x = guiGetAbsolutePosition(aColor.gui.colors[aColor.Pick].barImg)
	aColor.Color[aColor.Pick] = (math.clamp(cx, x, x + 127) - x)/127
	aColor.Update()
end

function aColor.onBlurHandler()
	if not guiGetVisible(aColor.gui.form) then return end
	aColor.Close()
end

function aColor.Accept()
	aColor.Accepted = true
	aColor.Close()
end

function aColor.ShowHexEdit()
	guiSetVisible(aColor.gui.currentImg, false)
	guiSetVisible(aColor.gui.colors.hex.edit, true)
	guiFocus(aColor.gui.colors.hex.edit)
end

function aColor.HideHexEdit()
	guiSetVisible(aColor.gui.colors.hex.edit, false)
	guiSetVisible(aColor.gui.currentImg, true)
end

function aColor.CheckHexEdit()
	if aColor.EditAntiRecursion then return end

	local text = guiGetText(source)
	if not (text and text ~= "" and tonumber(text, 16)) then
		text = "0"
	end
	if #text > 6 then
		text = string.sub(text, 1, 6)
	end
	while #text < 6 do
		text = text.."0"
	end
	guiSetText(source, text)

	aColor.Color.h, aColor.Color.s, aColor.Color.v = aColor.rgb2hsv(getColorFromString("#"..text))
	aColor.Update()
end

function aColor.CheckEdit()
	if aColor.EditAntiRecursion then return end

	local text = guiGetText(source)
	if not (text and text ~= "") then return end

	local value = tonumber(text)
	if not value then return end

	local color = getElementData(source, "type")
	if color == "h" then
		value = value/360
	elseif color == "s" or color == "v" then
		value = value/100
	end

	aColor.Color[color] = value
	if color == "r" or color == "g" or color == "b" then
		aColor.Color.h, aColor.Color.s, aColor.Color.v = aColor.rgb2hsv(aColor.Color.r, aColor.Color.g, aColor.Color.b)
	end
	aColor.Update()
end

function aColor.Update()
	aColor.Color.r, aColor.Color.g, aColor.Color.b = aColor.hsv2rgb(aColor.Color.h, aColor.Color.s, aColor.Color.v)
	aColor.Color.hex = aColor.rgb2hex(aColor.Color.r, aColor.Color.g, aColor.Color.b)
	
	aColor.EditAntiRecursion = true

	guiSetText(aColor.gui.colors.h.edit, tostring(math.round(aColor.Color.h*360)))
	guiSetText(aColor.gui.colors.s.edit, tostring(math.round(aColor.Color.s*100)))
	guiSetText(aColor.gui.colors.v.edit, tostring(math.round(aColor.Color.v*100)))
	guiSetText(aColor.gui.colors.r.edit, tostring(aColor.Color.r))
	guiSetText(aColor.gui.colors.g.edit, tostring(aColor.Color.g))
	guiSetText(aColor.gui.colors.b.edit, tostring(aColor.Color.b))
	guiSetText(aColor.gui.colors.hex.edit, aColor.Color.hex)

	guiSetPosition(aColor.gui.colors.h.cursorImg, -17 + math.floor(128*aColor.Color.h), -9, false)
	guiSetPosition(aColor.gui.colors.s.cursorImg, -17 + math.floor(128*aColor.Color.s), -9, false)
	guiSetPosition(aColor.gui.colors.v.cursorImg, -17 + math.floor(128*aColor.Color.v), -9, false)

	local ceguihex = aColor.rgb2hex(255, aColor.hsv2rgb(aColor.Color.h, 1, aColor.Color.v))
	local ceguihex2 = aColor.rgb2hex(255, aColor.hsv2rgb(aColor.Color.h, 0, aColor.Color.v))
	guiSetProperty(aColor.gui.colors.s.barImg, "ImageColours", "tl:"..ceguihex2.." tr:"..ceguihex.." bl:"..ceguihex2.." br:"..ceguihex)
	

	ceguihex = aColor.rgb2hex(255, aColor.hsv2rgb(aColor.Color.h, aColor.Color.s, 1))
	guiSetProperty(aColor.gui.colors.v.barImg, "ImageColours", "tl:FF000000 tr:"..ceguihex.." bl:FF000000 br:"..ceguihex)

	guiStaticImageSetColor(aColor.gui.currentImg, aColor.Color.r, aColor.Color.g, aColor.Color.b)
	guiSetText(aColor.gui.colors.hex.lbl, "#"..aColor.Color.hex)
	if aColor.Color.v < 0.5 then
		guiLabelSetColor(aColor.gui.colors.hex.lbl, 255, 255, 255)
	else
		guiLabelSetColor(aColor.gui.colors.hex.lbl, 0, 0, 0)
	end

	aColor.EditAntiRecursion = false
end

function aColor.hsv2rgb(h, s, v)
	local r, g, b
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p = v * (1 - s)
	local q = v * (1 - f * s)
	local t = v * (1 - (1 - f) * s)
	local switch = i % 6
	if switch == 0 then
		r = v g = t b = p
	elseif switch == 1 then
		r = q g = v b = p
	elseif switch == 2 then
		r = p g = v b = t
	elseif switch == 3 then
		r = p g = q b = v
	elseif switch == 4 then
		r = t g = p b = v
	elseif switch == 5 then
		r = v g = p b = q
	end
	return math.round(r*255), math.round(g*255), math.round(b*255)
end

function aColor.rgb2hsv(r, g, b)
	r, g, b = r/255, g/255, b/255
	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s
	local v = max
	local d = max - min
	s = max == 0 and 0 or d/max
	if max == min then
		h = 0
	elseif max == r then
		h = (g - b) / d + (g < b and 6 or 0)
	elseif max == g then
		h = (b - r) / d + 2
	elseif max == b then
		h = (r - g) / d + 4
	end
	h = h/6
	return h, s, v
end

function aColor.rgb2hex(r, g, b, a)
	if a then return string.format("%.2X%.2X%.2X%.2X", r, g, b, a) end
	return string.format("%.2X%.2X%.2X", r, g, b)
end