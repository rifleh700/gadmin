
aVehicle = {
	gui = {},
	Upgrades = {}
}

function aVehicle.LoadUpgrades()
	local node = xmlLoadFile("conf/upgrades.xml")
	if not node then return end

	local data = {}
	for i, node in ipairs(xmlNodeGetChildren(node)) do
		data[i] = {
			id = tonumber(xmlNodeGetAttribute(node, "id")),
			name = xmlNodeGetAttribute(node, "name")
		}
	end
	xmlUnloadFile(node)
	aVehicle.Upgrades = data
end

function aVehicle.Create()
	aVehicle.gui.form = guiCreateWindow(0, 0, 600, 450, "Vehicle customizations", false)
	
	aVehicle.LoadUpgrades()
	aVehicle.gui.upgrades = {}
	for slot = 0, 16 do
		aVehicle.gui.upgrades[slot] = {}
		guiCreateLabel(
			0.05,
			0.05 * (slot + 1),
			0.15,
			0.05,
			getVehicleUpgradeSlotName(slot) .. ":",
			true,
			aVehicle.gui.form
		)
		aVehicle.gui.upgrades[slot].cmb, aVehicle.gui.upgrades[slot].list = 
			guiCreateAdvancedComboBox(0.25, 0.05 * (slot + 1), 0.27, 0.048, "None", true, aVehicle.gui.form)
		aVehicle.gui.upgrades[slot].incompatibleLbl = 
			guiCreateLabel(0.25, 0.05 * (slot + 1), 0.27, 0.048, "Incompatible", true, aVehicle.gui.form)
		guiLabelSetColor(aVehicle.gui.upgrades[slot].incompatibleLbl, 127, 127, 127)
		--aVehicle.gui.upgrades[slot].lbl =
		--	guiCreateLabel(0.54, 0.05 * (slot + 1), 0.05, 0.07, "(0)", true, aVehicle.gui.form)
		setElementData(aVehicle.gui.upgrades[slot].cmb, "slot", slot)
	end

	aVehicle.gui.upgradeAllBtn = guiCreateButton(0.04, 0.92, 0.15, 0.05, "Total pimp", true, aVehicle.gui.form, "addupgrades")
	aVehicle.gui.removeAllBtn = guiCreateButton(0.20, 0.92, 0.15, 0.05, "Remove All", true, aVehicle.gui.form, "removeupgrades")
	aVehicle.gui.upgradeBtn = guiCreateButton(0.375, 0.92, 0.20, 0.05, "Pimp", true, aVehicle.gui.form, "addupgrades")
	
	guiCreateSeparator(0.60, 0.10, 0.002, 0.80, 200, 0, 0, true, aVehicle.gui.form)

	guiCreateLabel(0.63, 0.10, 0.15, 0.05, "Paint job:", true, aVehicle.gui.form)
	aVehicle.gui.paintjobCmb, aVehicle.gui.paintjobList =
		guiCreateAdvancedComboBox(0.75, 0.10, 0.15, 0.048, "None", true, aVehicle.gui.form)
	aVehicle.gui.setPaintjobBtn = guiCreateButton(0.90, 0.10, 0.07, 0.048, "Set", true, aVehicle.gui.form, "setpaintjob")
	aVehicle.gui.paintJobIncompatibleLbl = guiCreateLabel(0.75, 0.10, 0.27, 0.248, "Incompatible", true, aVehicle.gui.form)
	guiLabelSetColor(aVehicle.gui.paintJobIncompatibleLbl, 127, 127, 127)

	guiCreateLabel(0.63, 0.15, 0.15, 0.05, "Vehicle colors:", true, aVehicle.gui.form)
	aVehicle.gui.colors = {}
	for i = 1, 4 do
		aVehicle.gui.colors[i] = guiCreateColorPicker(0, 0, 50, 50, 255, 255, 255, false, aVehicle.gui.form, "setcolor")
		setElementData(aVehicle.gui.colors[i], "number", i)
	end
	guiSetPosition(aVehicle.gui.colors[1], 0.75, 0.20, true)
	guiSetPosition(aVehicle.gui.colors[2], 0.86, 0.20, true)
	guiSetPosition(aVehicle.gui.colors[3], 0.75, 0.31, true)
	guiSetPosition(aVehicle.gui.colors[4], 0.86, 0.31, true)

	guiCreateLabel(0.63, 0.40, 0.15, 0.05, "Light Color:", true, aVehicle.gui.form)
	aVehicle.gui.lightColorPicker = guiCreateColorPicker(0.75, 0.40, 0.15, 0.04, 255, 255, 255, true, aVehicle.gui.form, "setlightcolor")
	
	aVehicle.gui.resetBtn = guiCreateButton(0.60, 0.92, 0.15, 0.05, "Reset", true, aVehicle.gui.form)
	aVehicle.gui.closeBtn = guiCreateButton(0.86, 0.92, 0.19, 0.05, "Close", true, aVehicle.gui.form)

	addEventHandler("onClientGUIClick", aVehicle.gui.form, aVehicle.onClickHandler)
	addEventHandler("onClientGUIColorPickerAccepted", aVehicle.gui.form, aVehicle.onColorAcceptedHandler)
 
	aRegister("VehicleCustomize", aVehicle.gui.form, aVehicle.Open, aVehicle.Close)
end

function aVehicle.Destroy()
	destroyElement(aVehicle.gui.form)
	aVehicle.gui = {}
end

function aVehicle.Open(player, vehicle)
	if not vehicle then return end
	if not aVehicle.gui.form then
		aVehicle.Create()
	end
	aVehicle.Player = player
	aVehicle.Vehicle = vehicle
	
	aVehicle.Refresh()

	guiSetVisible(aVehicle.gui.form, true)
end

function aVehicle.Close()
	if not aVehicle.gui.form then return end
	if destroy then
		aVehicle.Destroy()
	else
		guiSetVisible(aVehicle.gui.form, false)
	end
end

function aVehicle.CheckPlayerVehicle()
	if not isElement(aVehicle.Player) then
		messageBox("Player has left the server", MB_ERROR)
		aVehicle.Close()
		return false
	end
	local currentVehicle = getPedOccupiedVehicle(aVehicle.Player)
	if not currentVehicle then
		messageBox("Player has left the vehicle", MB_ERROR)
		aVehicle.Close()
		return false
	end
	if currentVehicle ~= aVehicle.Vehicle then
		if not messageBox("Player changed his vehicle. Upgrade new vehicle?", MB_QUESTION, MB_YESNO) then
			aVehicle.Close()
			return false
		end
		aVehicle.Vehicle = currentVehicle
		aVehicle.Refresh()
		return false
	end
	return true
end

function aVehicle.onClickHandler(key)
	if key ~= "left" then return end
	if getElementType(source) ~= "gui-button" then return end

	if not aVehicle.CheckPlayerVehicle() then return end

	if source == aVehicle.gui.upgradeBtn then
		local selected = aVehicle.GetSelectedUpgrades()
		local removed = aVehicle.GetRemovedUpgrades()
		if #selected == 0 and #removed == 0 then
			messageBox("Vehicle already has these upgrades", MB_ERROR)
			return
		end
		if #removed > 0 then
			triggerServerEvent(EVENT_COMMAND, localPlayer, "removeupgrades", aVehicle.Player, removed)
		end
		if #selected > 0 then 
			triggerServerEvent(EVENT_COMMAND, localPlayer, "addupgrades", aVehicle.Player,selected)
		end

	elseif source == aVehicle.gui.removeAllBtn then
		local upgrades = getVehicleUpgrades(aVehicle.Vehicle)
		if #upgrades == 0 then
			messageBox("Vehicle doesn't have upgrades", MB_ERROR)
			return
		end
		aVehicle.SelectNoneUpgrades()
		triggerServerEvent(EVENT_COMMAND, localPlayer, "removeupgrades", aVehicle.Player)

	elseif source == aVehicle.gui.upgradeAllBtn then
		aVehicle.SelectRandomUpgrades()
		triggerServerEvent(EVENT_COMMAND, localPlayer, "addupgrades", aVehicle.Player, aVehicle.GetSelectedUpgrades())

	elseif source == aVehicle.gui.resetBtn then
		aVehicle.RefreshCurrent()

	elseif source == aVehicle.gui.setPaintjobBtn then
		local selected = aVehicle.GetPaintjob()
		if getVehiclePaintjob(aVehicle.Vehicle) == selected then
			messageBox("Vehicle paintjob is already "..(selected == 3 and "None" or selected), MB_ERROR)
			return
		end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setpaintjob", aVehicle.Player, selected)
	
	elseif source == aVehicle.gui.closeBtn then
		aVehicle.Close()

	end
end

function aVehicle.onColorAcceptedHandler()
	if not aVehicle.CheckPlayerVehicle() then return end

	if source == aVehicle.gui.lightColorPicker then
		local r, g, b = guiColorPickerGetSelectedColor(source)
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setlightcolor", aVehicle.Player, r, g, b)

	else
		local number = getElementData(source, "number")
		local r, g, b = guiColorPickerGetSelectedColor(source)
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setcolor", aVehicle.Player, number, r, g, b)

	end
end

function aVehicle.Refresh()
	guiSetText(aVehicle.gui.form, "Vehicle Customizations ("..getVehicleName(aVehicle.Vehicle)..")")
	
	for slot, slotGUI in pairs(aVehicle.gui.upgrades) do
		guiGridListClear(slotGUI.list)
		guiGridListAddRow(slotGUI.list, "None")
		guiGridListSetItemData(slotGUI.list, 0, 1, 0)
		guiAdvancedComboBoxSetSelected(slotGUI.cmb, 0)

		local upgrades = getVehicleCompatibleUpgrades(aVehicle.Vehicle, slot)
		if #upgrades == 0 then
			guiSetEnabled(slotGUI.cmb, false)
			guiSetVisible(slotGUI.cmb, false)
			guiSetVisible(slotGUI.incompatibleLbl, true)
		else
			for i, upgrade in ipairs(upgrades) do
				guiGridListAddRow(slotGUI.list, aVehicle.GetUpgradeName(upgrade))
				guiGridListSetItemData(slotGUI.list, i, 1, upgrade)
			end
			guiSetEnabled(slotGUI.cmb, true)
			guiSetVisible(slotGUI.cmb, true)
			guiSetVisible(slotGUI.incompatibleLbl, false)
		end
		guiGridListAdjustHeight(slotGUI.list, math.min(#upgrades + 1, 10))

		setElementData(slotGUI.cmb, "itemsData", itemsData)
	end

	guiGridListClear(aVehicle.gui.paintjobList)
	guiGridListAddRow(aVehicle.gui.paintjobList, "None")
	guiGridListSetItemData(aVehicle.gui.paintjobList, 0, 1, 3)
	guiAdvancedComboBoxSetSelected(aVehicle.gui.paintjobCmb, 0)

	local paintjobs = getVehicleCompatiblePaintjobs(aVehicle.Vehicle)
	if #paintjobs > 0 then
		for i, paintjob in ipairs(paintjobs) do
			guiGridListAddRow(aVehicle.gui.paintjobList, tostring(paintjob))
			guiGridListSetItemData(aVehicle.gui.paintjobList, i, 1, paintjob)
		end
		guiSetVisible(aVehicle.gui.paintJobIncompatibleLbl, false)
		guiSetVisible(aVehicle.gui.paintjobCmb, true)
		guiSetVisible(aVehicle.gui.setPaintjobBtn, true)
	else
		guiSetVisible(aVehicle.gui.setPaintjobBtn, false)
		guiSetVisible(aVehicle.gui.paintjobCmb, false)
		guiSetVisible(aVehicle.gui.paintJobIncompatibleLbl, true)
	end
	guiGridListAdjustHeight(aVehicle.gui.paintjobList)

	aVehicle.RefreshCurrent()
end

function aVehicle.RefreshCurrent()
	for slot, slotGUI in pairs(aVehicle.gui.upgrades) do
		local current = getVehicleUpgradeOnSlot(aVehicle.Vehicle, slot)
		local item = 0
		for i = 0, guiGridListGetRowCount(slotGUI.list) do
			if guiGridListGetItemData(slotGUI.list, i, 1) == current then
				guiAdvancedComboBoxSetSelected(slotGUI.cmb, i)
				break
			end
		end
	end

	local paintjob = getVehiclePaintjob(aVehicle.Vehicle)
	if paintjob == 3 then
		guiAdvancedComboBoxSetSelected(aVehicle.gui.paintjobCmb, 0)
	else
		guiAdvancedComboBoxSetSelected(aVehicle.gui.paintjobCmb, paintjob + 1)
	end

	for number, picker in ipairs(aVehicle.gui.colors) do
		guiColorPickerSetSelectedColor(picker, getVehicleOneColor(aVehicle.Vehicle, number))
	end
	guiColorPickerSetSelectedColor(aVehicle.gui.lightColorPicker, getVehicleHeadLightColor(aVehicle.Vehicle))
end

function aVehicle.SelectNoneUpgrades()
	for slot, slotGUI in pairs(aVehicle.gui.upgrades) do
		guiAdvancedComboBoxSetSelected(slotGUI.cmb, 0)
	end
end

function aVehicle.SelectRandomUpgrades()
	for slot, slotGUI in pairs(aVehicle.gui.upgrades) do
		if guiGetEnabled(slotGUI.cmb) then
			if slot == 8 then -- nitro? set 10x
				guiAdvancedComboBoxSetSelected(slotGUI.cmb, guiGridListGetRowCount(slotGUI.list) - 1)
			else
				guiAdvancedComboBoxSetSelected(slotGUI.cmb, math.random(guiGridListGetRowCount(slotGUI.list) - 1))
			end
		end
	end
end

function aVehicle.GetSelectedUpgrades()
	local selected = {}
	for slot, slotGUI in pairs(aVehicle.gui.upgrades) do
		local upgrade = guiGridListGetItemData(slotGUI.list, guiGridListGetSelectedItem(slotGUI.list), 1)
		if upgrade ~= 0 then
			selected[#selected + 1] = upgrade
		end
	end
	local installed = getVehicleUpgrades(aVehicle.Vehicle)
	for i, upgrade in ipairs(installed) do
		for is, su in ipairs(selected) do
			if su == upgrade then
				table.remove(selected, is)
				break
			end
		end
	end
	return selected
end

function aVehicle.GetRemovedUpgrades()
	local cleared = {}
	for slot, slotGUI in pairs(aVehicle.gui.upgrades) do
		local upgrade = guiGridListGetItemData(slotGUI.list, guiGridListGetSelectedItem(slotGUI.list), 1)
		if upgrade == 0 then
			cleared[#cleared + 1] = slot
		end
	end
	local removed = {}
	for i, slot in ipairs(cleared) do
		local installed = getVehicleUpgradeOnSlot(aVehicle.Vehicle, slot)
		if installed ~= 0 then
			removed[#removed + 1] = installed
		end
	end
	return removed
end

function aVehicle.GetPaintjob()
	local item = guiGridListGetSelectedItem(aVehicle.gui.paintjobList)
	if item == -1 then
		guiAdvancedComboBoxSetSelected(aVehicle.gui.paintjobCmb, 0)
		item = 0
	end
	return guiGridListGetItemData(aVehicle.gui.paintjobList, item, 1)
end

function aVehicle.GetUpgradeName(upgrade)
	for i, data in ipairs(aVehicle.Upgrades) do
		if data.id == upgrade then return data.name end
	end
	return nil
end
