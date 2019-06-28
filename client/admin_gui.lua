
-- unwanted maybe
guiprotected = {}

addEvent("onClientGUIShow", false)
addEvent("onClientGUIHide", false)

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		showCursor(false)
		guiSetInputEnabled(false)
	end
)

local _guiSetVisible = guiSetVisible
function guiSetVisible(element, state)
	local set = _guiSetVisible(element, state)
	if not set then return false end
	if state then
		guiBringToFront(element)
		triggerEvent("onClientGUIShow", element)
	else
		triggerEvent("onClientGUIHide", element)
	end
	return true
end

function guiCreateHeader(x, y, w, h, text, relative, parent)
	local header = guiCreateLabel(x, y, w, h, text, relative, parent)
	if not header then return false end

	guiLabelSetColor(header, 255, 0, 0)
	guiSetFont(header, "default-bold-small")
	return header
end

local _guiCreateWindow = guiCreateWindow
function guiCreateWindow(...)
	local window = _guiCreateWindow(...)
	if not window then return false end

	guiSetVisible(window, false)
	guiWindowSetSizable(window, false)
	guiCenter(window)
	return window
end

local _guiCreateTab = guiCreateTab
function guiCreateTab(name, parent, right)
	local tab = _guiCreateTab(name, parent)
	if not tab then return false end

	if right then
		right = "general.tab_"..right
		if not hasPermissionTo(right) then
			guiSetEnabled(tab, false)
		end
	end
	return tab
end

local _guiCreateButton = guiCreateButton
function guiCreateButton(x, y, w, h, text, relative, parent, right)
	local button = _guiCreateButton(x, y, w, h, text, relative, parent)
	if not button then return false end

	if right then
		right = "command."..right
		if not hasPermissionTo(right) then
			guiSetEnabled(button, false)
		end
	end
	guiSetFont(button, "default-bold-small")
	return button
end

local _guiCreateCheckBox = guiCreateCheckBox
function guiCreateCheckBox(x, y, w, h, text, checked, relative, parent, right)
	local check = _guiCreateCheckBox(x, y, w, h, text, checked, relative, parent)
	if not check then return false end

	if right then
		right = "command."..right
		if not hasPermissionTo(right) then
			guiSetEnabled(check, false)
		end
	end
	return check
end

local _guiCreateEdit = guiCreateEdit
function guiCreateEdit(x, y, w, h, text, relative, parent, right)
	local edit = _guiCreateEdit(x, y, w, h, text, relative, parent)
	if not edit then return false end

	guiHandleInput(edit)
	if right then
		right = "command."..right
		if not hasPermissionTo(right) then
			guiSetEnabled(edit, false)
		end
	end
	return edit
end

-- NEEDED!
local _guiStaticImageLoadImage = guiStaticImageLoadImage
function guiStaticImageLoadImage(image, path)
	local propagation = isElementCallPropagationEnabled(image)
	setElementCallPropagationEnabled(image, false)

	local loadImage = _guiStaticImageLoadImage(image, path)

	setElementCallPropagationEnabled(image, propagation)
	return loadImage
end

local _guiCreateMemo = guiCreateMemo
function guiCreateMemo(x, y, w, h, text, relative, parent)
	local memo = _guiCreateMemo(x, y, w, h, text, relative, parent)
	if not memo then return false end
	
	guiHandleInput(memo)
	return memo
end

local guiElementsFocus = {}
addEventHandler("onClientGUIFocus", guiRoot,
	function()
		guiElementsFocus[source] = true
	end
)
addEventHandler("onClientGUIBlur", guiRoot,
	function()
		guiElementsFocus[source] = nil
	end
)
function guiGetFocus(element)
	return guiElementsFocus[element]
end

function guiCenter(element)
	local w, h = guiGetSize(element, false)
	local pw, ph = guiGetScreenSize()
	local parent = getElementParent(element)
	if parent ~= guiRoot then
		pw, ph = guiGetSize(parent, false)
	end
	guiSetPosition(element, (pw-w)/2, (ph-h)/2, false) 
end

function guiSetColorProperty(element, property, r, g, b, a)
	if not r then r = 255 end
	if not g then g = 255 end
	if not b then b = 255 end
	if not a then a = 255 end
	local hex = string.format("%.2X%.2X%.2X%.2X", a, r, g, b)
	guiSetProperty(element, property, hex)
end

function guiSetColorsProperty(element, property, r, g, b, a)
	if not r then r = 255 end
	if not g then g = 255 end
	if not b then b = 255 end
	if not a then a = 255 end
	local hex = string.format("%.2X%.2X%.2X%.2X", a, r, g, b)
	guiSetProperty(element, property, "tl:"..hex.." tr:"..hex.." bl:"..hex.." br:"..hex)
end

function guiStaticImageSetColor(image, r, g, b, a)
	guiSetColorsProperty(image, "ImageColours", r, g, b, a)
end

local guiBlendTable = {}
function guiBlendElement(element, alpha, hide)
	local increment = (alpha - guiGetAlpha(element)) * 10
	guiBlendTable[element] = {inc = increment, hide = hide, target = alpha}
end

function guiLabelCalculateHeight(label, maxw)
	local text = guiGetText(label)
	local length = string.len(text)
	local textent = guiLabelGetTextExtent(label)
	local fheight = guiLabelGetFontHeight(label)

	if textent < maxw then return textent, fheight end 

	local words = split(text, " ")
	for i, word in ipairs(words) do
		local wextent = (string.len(word)+2)/length * textent
		if wextent > maxw then
			maxw = wextent
		end
	end

	local str = 1
	local sextent = 0
	for i, word in ipairs(words) do
		local wextent = (string.len(word)+1)/length * textent
		if sextent + wextent > maxw then
			str = str + 1
			sextent = 0
		end
		sextent = sextent + wextent
	end

	return maxw, fheight*str
end

addEventHandler("onClientRender", root,
	function()
		for element, v in pairs(guiBlendTable) do
			local a = guiGetAlpha(element) + v.inc / 40
			if (v.inc < 0 and a <= v.target) then
				a = v.target
				if (v.hide) then
					guiSetVisible(element, false)
				end
				guiBlendTable[element] = nil
			elseif (v.inc > 0 and a >= v.target) then
				a = v.target
				guiBlendTable[element] = nil
			end
			guiSetAlpha(element, a)
		end
	end
)

addEvent("onClientGUIColorPickerAccepted", false)
local guiColorPickers = {}
function guiCreateColorPicker(x, y, width, height, r, g, b, relative, parent, right)

	local button = guiCreateButton(x, y, width, height, "", relative, parent, right)
	if not button then return false end

	if not r then r = 255 end
	if not g then g = 0 end
	if not b then b = 0 end

	if relative then
		x, y = guiGetPosition(button, false)
		width, height = guiGetSize(button, false)
	end

	--local arrow = guiCreateStaticImage(width-height, 0, height, height, "client/images/dropright.png", false, button)
	--guiSetEnabled(arrow, false)

	local filler = guiCreateStaticImage(6, 6, width-12, height-12, "client/images/white.png", false, button)
	if not filler then return false end
   
	guiSetEnabled(filler, false)
	guiStaticImageSetColor(filler, r, g, b)

	guiColorPickers[button] = {
		color = {r, g, b},
		filler = filler
	}

	addEventHandler(
		"onClientGUIClick",
		button,
		function(key)
			if key ~= "left" then return end
			if not guiColorPickers[button] then return end
			if guiColorPickers[button].picking then return end

			local x, y = guiGetAbsolutePosition(button)
			local sx, sy = guiGetSize(button, false)

			guiColorPickers[button].picking = true
			local r, g, b = aColor.Open(x + sx, y, unpack(guiColorPickers[button].color))
			guiColorPickers[button].picking = false
			
			--guiBringToFront(parent)

			if not r then return end

			guiColorPickerSetSelectedColor(button, r, g, b)
			triggerEvent("onClientGUIColorPickerAccepted", button)
		end,
		false
	)
	
	addEventHandler(
		"onClientElementDestroy",
		button,
		function()
			if source ~= button then return end
			guiColorPickers[button] = nil
		end,
		false
	)

	return button
end

function guiColorPickerSetSelectedColor(picker, r, g, b)
	if not guiColorPickers[picker] then return false end
	guiStaticImageSetColor(guiColorPickers[picker].filler, r, g, b)
	guiColorPickers[picker].color = {r, g, b}
end

function guiColorPickerGetSelectedColor(picker)
	if not guiColorPickers[picker] then return false end
	return unpack(guiColorPickers[picker].color)
end

function guiCreateContextMenu(element)
	local menu = guiCreateStaticImage(0, 0, 0, 0, "client/images/white.png", false)
	guiStaticImageSetColor(menu, 0, 0, 0)
	guiSetProperty(menu, "AlwaysOnTop", "True")
	guiSetVisible(menu, false)

	local onClickHandler = function(key)
		if not guiGetVisible(menu) then return end
		if key ~= "left" then return end
		guiSetVisible(menu, false)
	end
	addEventHandler("onClientGUIClick", guiRoot, onClickHandler)

	addEventHandler("onClientElementDestroy", menu,
		function()
			if source ~= menu then return end
			removeEventHandler("onClientGUIClick", guiRoot, onClickHandler)
		end,
		false
	)

	if element then guiSetContextMenu(element, menu) end
	return menu
end

function guiSetContextMenu(element, menu)
	local onRightClickHandler = function(button, state, cursorX, cursorY)
		if button ~= "right" then return end

		if getElementType(source) == "gui-gridlist" and
		guiGridListGetSelectedItem(source) == -1 then return end

		contextSource = source
		guiSetPosition(menu, cursorX, cursorY, false)
		guiSetVisible(menu, true)
	end
	addEventHandler("onClientGUIClick", element, onRightClickHandler, false, "low")

	local onHideHandler = function()
		guiSetVisible(menu, false)
	end
	addEventHandler("onClientGUIHide", element, onHideHandler)

	addEventHandler("onClientElementDestroy", menu,
		function()
			if source ~= menu then return end
			if not isElement(element) then return end
			removeEventHandler("onClientGUIClick", element, onRightClickHandler)
			removeEventHandler("onClientGUIHide", element, onHideHandler)
		end,
		false
	)
	return true
end

function guiContextMenuAddItem(menu, text)
	local height = 18
	local n = #getElementChildren(menu)
	local bg = guiCreateStaticImage(1, n * height + 1, 0, height, "client/images/white.png", false, menu)
	guiStaticImageSetColor(bg, 0, 0, 0)
	local item = guiCreateLabel(0, 0, 0, height, "  "..text.."  ", false, bg)
	
	local width = guiGetSize(menu, false)
	local extent = guiLabelGetTextExtent(item)
	if extent > width then width = extent end
	if width < 60 then width = 80 end

	guiSetSize(menu, width + 2, (n + 1) * height + 2, false)

	for i, child in ipairs(getElementChildren(menu)) do
		guiSetSize(child, width, height, false)
		guiSetSize(getElementChildren(child)[1], width, height, false)
	end

	addEventHandler("onClientMouseEnter", item,
		function()
			guiStaticImageSetColor(bg, 78, 103, 206)
		end,
		false
	)
	addEventHandler("onClientMouseLeave", item,
		function()
			guiStaticImageSetColor(bg, 0, 0, 0)
		end,
		false
	)
	return item
end

local guiToolTips = {}
function guiCreateToolTip(text, element)
	local tooltip = guiCreateStaticImage(0, 0, 0, 0, "client/images/white.png", false)
	guiStaticImageSetColor(tooltip, 0, 0, 0)
	guiSetProperty(tooltip, "AlwaysOnTop", "True")
	guiSetVisible(tooltip, false)
	guiSetEnabled(tooltip, false)

	local lbl = guiCreateLabel(6, 3, 0, 0, text, false, tooltip)
	guiLabelSetHorizontalAlign(lbl, "left", true)
	
	local w, h = guiLabelCalculateHeight(lbl, 180)
	guiSetSize(tooltip, w + 3*2 + 5, h + 3*2, false)
	guiSetSize(lbl, w, h, false)
	
	guiToolTips[tooltip] = {
		inside = false
	}

	local onClickHandler = function(key)
		if key ~= "left" then return end
		if not guiGetVisible(tooltip) then return end
		guiSetVisible(tooltip, false)
	end
	addEventHandler("onClientGUIClick", guiRoot, onClickHandler)

	addEventHandler("onClientElementDestroy", tooltip,
		function()
			if source ~= tooltip then return end
			addEventHandler("onClientGUIClick", guiRoot, onClickHandler)
			guiToolTips[tooltip] = nil
		end,
		false
	)

	if element then guiSetToolTip(element, tooltip) end
	return tooltip
end

function guiSetToolTip(element, tooltip)
	local onEnterHandler = function()
		guiToolTips[tooltip].inside = true
	end
	local onLeaveHandler = function()
		guiToolTips[tooltip].inside = false
	end
	local onMoveHandler = function()
		if guiGetVisible(tooltip) then guiSetVisible(tooltip, false) end
		local data = guiToolTips[tooltip]
		if data.inside then
			if data.timer and isTimer(data.timer) then
				resetTimer(data.timer)
			else
				data.timer = setTimer(
					function()
						if not data.inside then return end
						local cx, cy = getCursorAbsolutePosition()
						guiSetPosition(tooltip, cx + 1, cy + 14, false)
						guiSetVisible(tooltip, true)
					end,
					1000, 1
				)
			end
		end
	end
	addEventHandler("onClientMouseEnter", element, onEnterHandler, false)
	addEventHandler("onClientMouseLeave", element, onLeaveHandler, false)
	addEventHandler("onClientMouseMove", element, onMoveHandler, false)

	local onHideHandler = function()
		guiSetVisible(tooltip, false)
	end
	addEventHandler("onClientGUIHide", element, onHideHandler)

	addEventHandler("onClientElementDestroy", tooltip,
		function()
			if source ~= tooltip then return end
			if not isElement(element) then return end
			removeEventHandler("onClientMouseMove", element, onMoveHandler)
			removeEventHandler("onClientMouseEnter", element, onEnterHandler)
			removeEventHandler("onClientMouseLeave", element, onLeaveHandler)
			removeEventHandler("onClientGUIHide", element, onHideHandler)
		end,
		false
	)

	return true
end

function guiCreateSearchEdit(x, y, width, height, text, relative, parent)

	local edit = guiCreateEdit(x, y, width, height, text, relative, parent)
	if not edit then return false end

	if relative then
		x, y = guiGetPosition(edit, false)
		width, height = guiGetSize(edit, false)
	end
	guiSetSize(edit, width - height/2, height, false)
	
	local image = guiCreateStaticImage(width - height, 0, height, height, "client/images/search.png", false, edit)
	guiSetProperty(image, "ClippedByParent", "False")

	return edit
end

function guiComboBoxAdjustHeight(comboBox, itemCount)
	if not isElement(comboBox) then return end
	if not itemCount then itemCount = 1 end
	local width = guiGetSize(comboBox, false)
	return guiSetSize(comboBox, width, itemCount * 14 + 38, false)
end

function guiGridListAdjustHeight(gridList, itemCount)
	if not itemCount then itemCount = guiGridListGetRowCount(gridList) end
	local width = guiGetSize(gridList, false)
	return guiSetSize(gridList, width, itemCount * 14 + 35 + 15, false)
end

function guiGridListAdjustColumnWidth(gridList)
	local width = guiGetSize(gridList, false)
	return guiGridListSetColumnWidth(gridList, 1, width - 30, false)
end

function guiGridListGetRowScroll(list, row)
	local rows = guiGridListGetRowCount(list)
	if rows == 0 or rows == 1 then return 0 end
	return row/(rows-1) * 100
end

addEvent("onClientGUIComboBoxButtonAccepted", false)
local guiComboBoxButtons = {}
function guiCreateComboBoxButton(x, y, width, height, text, relative, parent, right)

	local button = guiCreateButton(x, y, width, height, text, relative, parent, right)
	if not button then return false end

	if relative then
		x, y = guiGetPosition(button, false)
		width, height = guiGetSize(button, false)
	end
	guiSetSize(button, width - height/2, height, false)

	local data = {}
	data.text = text
	
	local image = guiCreateStaticImage(width - height, 0, height, height, "client/images/dropdown.png", false, button)
	guiSetProperty(image, "ClippedByParent", "False")
	
	local list = guiCreateGridList(0, height + 1, width, 0, false, button)
	guiGridListAdjustHeight(list, 0)
	guiSetProperty(list, "ClippedByParent", "False")
	--guiSetProperty(list, "AlwaysOnTop", "True")
	guiGridListSetSortingEnabled(list, false)
	guiGridListAddColumn(list, "", (width - 30)/width)
	guiSetVisible(list, false)
	guiGridListRegisterArrowScroll(list)

	data.list = list
	guiComboBoxButtons[button] = data

	addEventHandler("onClientGUIClick", list,
		function(key, state)
			if key ~= "left" then return end

			local item = guiGridListGetSelectedItem(list)
			if item == -1 then
				if guiGridListGetRowCount(list) == 0 then return end
				guiGridListSetSelectedItem(list, 0, 1)
				item = 0
			end

			local newText = guiGridListGetItemText(list, item, 1)
			if text ~= "" then
				newText = text..": "..newText
			end
			guiSetText(button, newText)
			triggerEvent("onClientGUIComboBoxButtonAccepted", button)
		end,
		false
	)

	addEventHandler("onClientGUIDoubleClick", list,
		function(key, state)
			if key ~= "left" then return end
			guiSetVisible(list, false)
		end,
		false
	)

	addEventHandler("onClientGUIClick", image,
		function(key)
			if key ~= "left" then return end
			if guiGetVisible(list) then
				guiSetVisible(list, false)
			else
				if not guiGetEnabled(button) then return end
				guiSetVisible(list, true)
			end
		end,
		false
	)

	local onClickOutsideHandler = function(key)
		if not guiGetVisible(list) then return end
		if source == list or source == image or getElementParent(source) == list then return end
		guiSetVisible(list, false)
	end
	addEventHandler("onClientGUIClick", guiRoot, onClickOutsideHandler, true, "low")

	local onEnterKey = function(key, down)
		if key ~= "enter" then return end
		if not down then return end
		if not guiGetVisible(list) then return end
		guiSetVisible(list, false)
	end
	addEventHandler("onClientKey", root, onEnterKey)

	addEventHandler("onClientElementDestroy", button,
		function()
			if source ~= button then return end
			removeEventHandler("onClientGUIClick", guiRoot, onClickOutsideHandler)
			removeEventHandler("onClientKey", root, onEnterKey)
			guiComboBoxButtons[button] = nil
		end,
		false
	)

	return button, list
end

function guiComboBoxButtonSetSelected(button, selected)
	if not guiComboBoxButtons[button] then return false end

	local list = guiComboBoxButtons[button].list
	if guiGridListGetRowCount(list) < selected + 1 then return false end
	
	guiGridListSetSelectedItem(list, selected, 1)
	local newText = guiGridListGetItemText(list, selected, 1)
	local text = guiComboBoxButtons[button].text
	if text ~= "" then
		newText = text..": "..newText
	end
	guiSetText(button, newText)
	return true
end

addEvent("onClientGUIAdvancedComboBoxAccepted", false)
local guiAdvancedComboBoxes = {}
function guiCreateAdvancedComboBox(x, y, width, height, text, relative, parent)
	
	local edit = guiCreateEdit(x, y, width, height, text, relative, parent)
	if not edit then return end

	if relative then
		x, y = guiGetPosition(edit, false)
		width, height = guiGetSize(edit, false)
	end
	guiSetSize(edit, width - height/2, height, false)
	guiEditSetReadOnly(edit, true)

	local image = guiCreateStaticImage(width - height, 0, height, height, "client/images/dropdown2.png", false, edit)
	guiSetProperty(image, "ClippedByParent", "False")

	local list = guiCreateGridList(0, height + 1, width, 0, false, edit)
	guiGridListAdjustHeight(list, 0)
	guiSetProperty(list, "ClippedByParent", "False")
	--guiSetProperty(list, "AlwaysOnTop", "True")
	guiGridListSetSortingEnabled(list, false)
	guiGridListAddColumn(list, "", (width - 30)/width)
	guiSetVisible(list, false)
	guiGridListRegisterArrowScroll(list)

	guiAdvancedComboBoxes[edit] = {
		list = list
	}

	addEventHandler("onClientGUIClick", list,
		function(key, state)
			if key ~= "left" then return end

			local item = guiGridListGetSelectedItem(list)
			if item == -1 then
				if guiGridListGetRowCount(list) == 0 then return end
				guiGridListSetSelectedItem(list, 0, 1)
				item = 0
			end

			local itemText = guiGridListGetItemText(list, item, 1)
			guiSetText(edit, itemText)
			triggerEvent("onClientGUIAdvancedComboBoxAccepted", edit)
		end,
		false
	)

	addEventHandler("onClientGUIDoubleClick", list,
		function(key, state)
			if key ~= "left" then return end
			guiSetVisible(list, false)
		end,
		false
	)

	local switch = function(key)
		if key ~= "left" then return end
		if guiGetVisible(list) then
			guiSetVisible(list, false)
		else
			guiSetVisible(list, true)
		end
	end
	addEventHandler("onClientGUIClick", image, switch, false)
	addEventHandler("onClientGUIClick", edit, switch, false)

	local onClickOutsideHandler = function(key)
		if not guiGetVisible(list) then return end
		if source == edit or source == image or source == list then return end
		guiSetVisible(list, false)
	end
	addEventHandler("onClientGUIClick", guiRoot, onClickOutsideHandler)

	local onEnterKey = function(key, down)
		if key ~= "enter" then return end
		if not down then return end
		if not guiGetVisible(list) then return end
		guiSetVisible(list, false)
	end
	addEventHandler("onClientKey", root, onEnterKey)

	addEventHandler("onClientElementDestroy", edit,
		function()
			if source ~= edit then return end
			removeEventHandler("onClientGUIClick", guiRoot, onClickOutsideHandler)
			removeEventHandler("onClientKey", root, onEnterKey)
			guiAdvancedComboBoxes[edit] = nil
		end,
		false
	)

	return edit, list
end

function guiAdvancedComboBoxSetSelected(edit, selected)
	if not guiAdvancedComboBoxes[edit] then return false end

	local list = guiAdvancedComboBoxes[edit].list
	if guiGridListGetRowCount(list) < selected + 1 then return false end
	
	guiGridListSetSelectedItem(list, selected, 1)
	guiSetText(edit, guiGridListGetItemText(list, selected, 1))
	return true
end

function guiCreateAdvancedEdit(x, y, width, height, text, relative, parent, notEmpty, numbers, integer, min, max, right)
	local edit = guiCreateEdit(x, y, width, height, text, relative, parent, right)
	if not edit then return false end

	if numbers then
		if integer then
			if min and min >= 0 then
				guiSetProperty(edit, "ValidationString", "^(\\d*)?$") 
			else
				guiSetProperty(edit, "ValidationString", "^(\\-?\\d*)?$") 
			end
		else
			if min and min >= 0 then
				guiSetProperty(edit, "ValidationString", "^(\\d*\\.?\\d{0,6})?$") 
			else
				guiSetProperty(edit, "ValidationString", "^(\\-?\\d*\\.?\\d{0,6})?$") 
			end
		end
   
		if min or max then
			addEventHandler(
				"onClientGUIChanged", edit,
				function()
					local entered = guiGetText(edit)
					if not (entered and entered ~= "") then return end
	
					local value = tonumber(entered)
					if not value then
						if integer then
							guiSetText(edit, "")
						else
							if not (string.match(entered, "%-?%.?") == entered) then
								guiSetText(edit, "")
							end
						end
						return
					end

					local clamped = math.clamp(value, min, max)
					if clamped == value then return end

					if min > 0 and value < min then return end

					guiSetText(edit, tostring(clamped))
				end,
				false,
				"high"
			)
		end
	end

	if notEmpty then
		addEventHandler(
			"onClientGUIBlur", edit,
			function()
				local entered = guiGetText(edit)
				if not(entered and entered ~= "") then
					guiSetText(edit, text)
					return
				end

				if not numbers then return end

				local value = tonumber(entered)
				if not value then
					guiSetText(edit, text)
					return
				end

				local clamped = math.clamp(value, min, max)
				guiSetText(edit, tostring(clamped))
			end,
			false
		)
	end

	addEventHandler(
		"onClientGUIAccepted", edit,
		function()
			guiBlur(edit)
		end,
		false,
		"high"
	)

	return edit
end

function guiCreateElementMessageLabel(element, text)
	local label = guiCreateLabel(0, 0, 1, 1, text or "", true, element)
	guiSetEnabled(label, false)
	guiLabelSetHorizontalAlign(label, "center")
	guiLabelSetVerticalAlign(label, "center")
	if getElementType(element) == "gui-memo" then
		guiLabelSetColor(label, 0, 0, 0)
	end
	return label
end

function guiCreateSeparator(x, y, width, height, r, g, b, relative, parent)
	local image = guiCreateStaticImage(x, y, width, height, "client/images/white.png", relative, parent)
	if not image then return false end

	if not r then r = 200 end
	if not g then g = 0 end
	if not b then b = 0 end
	
	guiStaticImageSetColor(image, r, g, b)

	return image
end

local guiCheckStaticImages = {}
addEvent("onClientGUICheckStaticImageChecked", false)
function guiCreateCheckStaticImage(x, y, width, height, path, relative, parent)
	local image = guiCreateStaticImage(x, y, width, height, path, relative, parent)
	if not image then return false end

	width, height = guiGetSize(image, false)
	local mask = guiCreateStaticImage(0, 0, 1, 1, "client/images/white.png", true, image)
	guiSetEnabled(mask, false)
	guiStaticImageSetColor(mask, 0, 0, 0, 0)

	local check = guiCreateCheckBox(5, 5, 15, 15, "", false, false, image)

	local refreshState = function()
		if guiCheckBoxGetSelected(check) then
			guiStaticImageSetColor(mask, 118, 143, 246, 153)
		else
			guiStaticImageSetColor(mask, 0, 0, 0, 0)
		end
	end
	addEventHandler("onClientGUIClick", image,
		function()
			local selected = not guiCheckBoxGetSelected(check)
			guiCheckBoxSetSelected(check, selected)
			refreshState()
			triggerEvent("onClientGUICheckStaticImageChecked", image)
		end,
		false,
		"high"
	)
	addEventHandler("onClientGUIClick", check,
		function()
			refreshState()
			triggerEvent("onClientGUICheckStaticImageChecked", image)
		end,
		false,
		"high"
	)
	addEventHandler("onClientElementDestroy", image,
		function()
			if source ~= image then return end
			guiCheckStaticImages[image] = nil
		end,
		false
	)

	guiCheckStaticImages[image] = {
		mask = mask,
		check = check
	}

	return image
end

function guiCheckStaticImageGetSelected(image)
	if not guiCheckStaticImages[image] then return false end
	return guiCheckBoxGetSelected(guiCheckStaticImages[image].check)
end

function guiCheckStaticImageSetSelected(image, selected)
	if not guiCheckStaticImages[image] then return false end
	if not guiCheckBoxSetSelected(guiCheckStaticImages[image].check, selected) then return false end
	if selected then
		guiStaticImageSetColor(guiCheckStaticImages[image].mask, 118, 143, 246, 153)
	else
		guiStaticImageSetColor(guiCheckStaticImages[image].mask, 0, 0, 0, 0)
	end
	return true
end

--[[
function guiGridListSetSearchEdit(list, edit, data, add, find)
	local onChangedHandler = function()
		local selected = guiGridListGetSelectedItem(list)
		if selected == -1 then selected = 0 end

		guiGridListClear(list)

		local text = string.lower(guiGetText(edit))
		if text == "" then text = false end

		for i, v in ipairs(data) do
			if (not text) or find(v, text) then add(list, v) end
		end
		local last = guiGridListGetRowCount(list) - 1
		if last > -1 then
			if selected > last then selected = last end 
			guiGridListSetSelectedItem(list, selected, 1)
		end
	end
	addEventHandler("onClientGUIChanged", edit, onChangedHandler, false)
	onChangedHandler()

	addEventHandler("onClientElementDestroy", list,
		function()
			if source ~= list then return end
			if not isElement(edit) then return end
			removeEventHandler("onClientGUIChanged", edit, onChangedHandler)
		end,
		false
	)

	return true
end
]]--

local guiArrowGridLists = {}
function guiGridListRegisterArrowScroll(list)
	guiArrowGridLists[#guiArrowGridLists + 1] = list
	
	addEventHandler("onClientElementDestroy", list,
		function()
			if source ~= list then return end
			table.vremove(guiArrowGridLists, list)
		end
	)

	return true
end

local guiGridListSearchEdits = {}
function guiGridListRegisterSearch(list, search)
	guiGridListSearchEdits[list] = search
	
	local onListDestroyHandler = function()
		if source ~= list then return end
		guiGridListSearchEdits[list] = nil
		removeEventHandler("onClientElementDestroy", search, onSearchDestroyHandler)
	end 
	local onSearchDestroyHandler = function()
		if source ~= search then return end
		guiGridListSearchEdits[list] = nil
		removeEventHandler("onClientElementDestroy", list, onListDestroyHandler)
	end 
	addEventHandler("onClientElementDestroy", list, onListDestroyHandler, false)
	addEventHandler("onClientElementDestroy", search, onSearchDestroyHandler, false)

	return true
end

local guiGridListArrowScroll = function(inc)
	local list = nil
	for i = #guiArrowGridLists, 1, -1 do
		if 
			guiGetEnabled(guiArrowGridLists[i]) and
			guiGetVisible(guiArrowGridLists[i])
		then
			list = guiArrowGridLists[i]
			break
		end
	end

	if not list then return end

	local selected = guiGridListGetSelectedItem(list)
	local rows = guiGridListGetRowCount(list)
	local search = guiGridListSearchEdits[list]
	local selecti = math.clamp(selected + inc, -1, rows - 1)

	local element = list
	if selecti == -1 then
		selecti = rows > 0 and 0 or -1
		if search then
			if rows == 0 and guiGetFocus(search) then
				element = list
			else
				element = search
			end
		end
	end

	guiGridListSetSelectedItem(list, selecti, 1)
	guiGridListSetVerticalScrollPosition(list, guiGridListGetRowScroll(list, selecti))
	triggerEvent("onClientGUIClick", list, "left", "up")
	if element == search then
		triggerEvent("onClientGUIClick", search, "left", "up")
	end
	guiFocus(element)
end

addEventHandler("onClientKey", root,
	function(key, press)
		if not (key == "arrow_d" or key == "arrow_u") then return end
		if not press then return end
		guiGridListArrowScroll(key == "arrow_d" and 1 or -1)
	end
)

function guiGetAbsolutePosition(element)
	local x, y = guiGetPosition(element, false)
	local parent = getElementParent(element)
	while parent ~= getResourceGUIElement() do
		local px, py = guiGetPosition(parent, false)
		x = x + px
		y = y + py
		parent = getElementParent(parent)
	end
	return x, y
end

local inputEdit = nil
function guiHandleInput(element)
	addEventHandler("onClientGUIFocus", element,
		function()
			inputEdit = element
			guiSetInputEnabled(true)
		end,
		false
	)
	addEventHandler("onClientGUIBlur", element,
		function()
			if inputEdit ~= element then return end
			guiSetInputEnabled(false)
			inputEdit = nil
		end
	)
end

function guiIsCursorInside(element)
	local x, y = guiGetAbsolutePosition(element)
	local w, h = guiGetSize(element, false)
	local cx, cy = getCursorAbsolutePosition()
	return isInsideRectangle(cx, cy, x, y, w, h)
end

function getCursorAbsolutePosition()
	local x, y = getCursorPosition()
	local sx, sy = guiGetScreenSize()
	return sx * x, sy * y
end

function guiGetAbsoluteFromRelative(x, y, width, height, parent)
	local pw, ph = guiGetScreenSize()
	if parent then
		pw, ph = guiGetSize(parent, false)
	end
	x = x * pw
	y = y * ph
	width = width * pw
	height = height * ph
	return x, y, width, height
end