
aStats = {
	gui = {},
	List = {},
	Fightings = {},
	Walkings = {}
}

function aStats.LoadStats()
	local node = xmlLoadFile("conf/stats.xml")
	if not node then return end

	data = {}
	for i, groupNode in ipairs(xmlNodeGetChildren(node)) do
		local group = xmlNodeGetAttribute(groupNode, "name")
		data[group] = {}
		for i2, statNode in ipairs(xmlNodeGetChildren(groupNode)) do
			data[group][i2] = {
				id = tonumber(xmlNodeGetAttribute(statNode, "id")),
				name = xmlNodeGetAttribute(statNode, "shortname")
			}
		end
	end
	xmlUnloadFile(node)
	aStats.List = data
end

function aStats.LoadFightings()
	local node = xmlLoadFile("conf/fightingstyles.xml")
	if not node then return end

	data = {}
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		if xmlNodeGetName(subnode) == "style" then
			data[#data + 1] = {
				id = tonumber(xmlNodeGetAttribute(subnode, "id")),
				name = xmlNodeGetAttribute(subnode, "name")
			}
		end
	end
	xmlUnloadFile(node)
	aStats.Fightings = data
end

function aStats.LoadWalkings()
	local node = xmlLoadFile("conf/walkingstyles.xml")
	if not node then return end

	data = {}
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		if xmlNodeGetName(subnode) == "style" then
			data[#data + 1] = {
				id = tonumber(xmlNodeGetAttribute(subnode, "id")),
				name = xmlNodeGetAttribute(subnode, "name")
			}
		end
	end
	xmlUnloadFile(node)
	aStats.Walkings = data
end

function aStats.Create()
	aStats.gui.form = guiCreateWindow(0, 0, 460, 400, "Player stats management", false)
	
	aStats.LoadStats()
	aStats.LoadFightings()
	aStats.LoadWalkings()

	guiCreateHeader(0.05, 0.06, 0.20, 0.05, "Weapon Skills:", true, aStats.gui.form)

	aStats.gui.stats = {}
	for i, data in ipairs(aStats.List["weapon"]) do
		aStats.gui.stats[data.id] = {}
		aStats.gui.stats[data.id].lbl =
			guiCreateLabel(0.05, 0.06 + 0.07 * i, 0.20, 0.07, data.name..":", true, aStats.gui.form)
		guiLabelSetHorizontalAlign(aStats.gui.stats[data.id].lbl, "right", false)
		aStats.gui.stats[data.id].edit = guiCreateAdvancedEdit(0.26, 0.05 + 0.07 * i, 0.11, 0.06, "0", true, aStats.gui.form, true, true, true, 0, 1000, "setstat")
		aStats.gui.stats[data.id].btn =
			guiCreateButton(0.37, 0.05 + 0.07 * i, 0.10, 0.06, "Set", true, aStats.gui.form, "setstat")
		setElementData(aStats.gui.stats[data.id].edit, "stat", data.id)
		setElementData(aStats.gui.stats[data.id].btn, "stat", data.id)
	end

	guiCreateSeparator(0.50, 0.12, 0.0025, 0.75, 200, 0, 0, true, aStats.gui.form)
	guiCreateHeader(0.60, 0.06, 0.20, 0.05, "Body:", true, aStats.gui.form)
	
	for i, data in ipairs(aStats.List["body"]) do
		aStats.gui.stats[data.id] = {}
		aStats.gui.stats[data.id].lbl =
			guiCreateLabel(0.50, 0.06 + 0.07 * i, 0.20, 0.07, data.name..":", true, aStats.gui.form)
		guiLabelSetHorizontalAlign(aStats.gui.stats[data.id].lbl, "right", false)
		aStats.gui.stats[data.id].edit = guiCreateAdvancedEdit(0.71, 0.05 + 0.07 * i, 0.11, 0.06, "0", true, aStats.gui.form, true, true, true, 0, 1000, "setstat")
		aStats.gui.stats[data.id].btn =
			guiCreateButton(0.82, 0.05 + 0.07 * i, 0.10, 0.06, "Set", true, aStats.gui.form, "setstat")
		setElementData(aStats.gui.stats[data.id].edit, "stat", data.id)
		setElementData(aStats.gui.stats[data.id].btn, "stat", data.id)
	end

	aStats.gui.fightLbl = guiCreateLabel(0.50, 0.49, 0.20, 0.06, "Fighting style:", true, aStats.gui.form)
	guiLabelSetHorizontalAlign(aStats.gui.fightLbl, "right", false)
	aStats.gui.fightCmb, aStats.gui.fightList =
		guiCreateAdvancedComboBox(0.71, 0.49, 0.21, 0.06, "", true, aStats.gui.form)
	for i, styleData in ipairs(aStats.Fightings) do
		guiGridListAddRow(aStats.gui.fightList, styleData.name)
		guiGridListSetItemData(aStats.gui.fightList, i-1, 1, styleData.id)
	end
	guiGridListAdjustHeight(aStats.gui.fightList)
	aStats.gui.fightBtn = guiCreateButton(0.82, 0.55, 0.10, 0.06, "Set", true, aStats.gui.form, "setfighting")

	aStats.gui.walkLbl = guiCreateLabel(0.50, 0.61, 0.20, 0.06, "Walking style:", true, aStats.gui.form)
	guiLabelSetHorizontalAlign(aStats.gui.walkLbl, "right", false)
	aStats.gui.walkCmb, aStats.gui.walkList =
		guiCreateAdvancedComboBox(0.71, 0.61, 0.21, 0.06, "", true, aStats.gui.form)
	for i, styleData in ipairs(aStats.Walkings) do
		guiGridListAddRow(aStats.gui.walkList, styleData.name)
		guiGridListSetItemData(aStats.gui.walkList, i-1, 1, styleData.id)
	end
	guiGridListAdjustHeight(aStats.gui.walkList, 10)
	aStats.gui.walkBtn = guiCreateButton(0.82, 0.67, 0.10, 0.06, "Set", true, aStats.gui.form, "setwalking")
	
	guiCreateLabel(0.05, 0.93, 0.60, 0.05, "* Only numerical values from 0 to 1000 accepted", true, aStats.gui.form)
	
	aStats.gui.resetBtn = guiCreateButton(0.60, 0.90, 0.14, 0.09, "Reset", true, aStats.gui.form)
	aStats.gui.closeBtn = guiCreateButton(0.80, 0.90, 0.14, 0.09, "Close", true, aStats.gui.form)

	addEventHandler("onClientGUIClick", aStats.gui.form, aStats.onClickHandler)
	addEventHandler("onClientGUIAccepted", aStats.gui.form, aStats.onAcceptedStatHandler)

	aRegister("PlayerStats", aStats.gui.form, aStats.Open, aStats.Close)
end

function aStats.Destroy()
	destroyElement(aStats.gui.form)
	aStats.gui = {}
end

function aStats.Open(player)
	if not aStats.gui.form then
		aStats.Create()
	end
	aStats.Player = player
	aStats.Refresh()
	guiSetVisible(aStats.gui.form, true)
end

function aStats.Close(destroy)
	if not aStats.gui.form then return end
	if destroy then
		aStats.Destroy()
	else
		guiSetVisible(aStats.gui.form, false)
	end
end

function aStats.onClickHandler(key)
	if key ~= "left" then return end
	if getElementType(source) ~= "gui-button" then return end

	if source == aStats.gui.fightBtn then
		local selected = guiGridListGetSelectedItem(aStats.gui.fightList)
		local style = guiGridListGetItemData(aStats.gui.fightList, selected, 1)
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setfighting", aStats.Player, style)

	elseif source == aStats.gui.walkBtn then
		local selected = guiGridListGetSelectedItem(aStats.gui.walkList)
		local style = guiGridListGetItemData(aStats.gui.walkList, selected, 1)
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setwalking", aStats.Player, style)
	
	elseif source == aStats.gui.resetBtn then
		aStats.Refresh()

	elseif source == aStats.gui.closeBtn then
		aStats.Close()
	
	else
		aStats.onAcceptedStatHandler()

	end

end

function aStats.Refresh()
	for stat, statGUI in pairs(aStats.gui.stats) do
		guiSetText(statGUI.edit, getPedStat(aStats.Player, stat))
	end

	guiAdvancedComboBoxSetSelected(aStats.gui.fightCmb, 0)
	local playerFighting = getPedFightingStyle(aStats.Player)
	for row = 0, guiGridListGetRowCount(aStats.gui.fightList) do
		if guiGridListGetItemData(aStats.gui.fightList, row, 1) == playerFighting then
			guiAdvancedComboBoxSetSelected(aStats.gui.fightCmb, row)
			break
		end
	end

	guiAdvancedComboBoxSetSelected(aStats.gui.walkCmb, 0)
	local playerWalking = getPedWalkingStyle(aStats.Player)
	for row = 0, guiGridListGetRowCount(aStats.gui.walkList) do
		if guiGridListGetItemData(aStats.gui.walkList, row, 1) == playerWalking then
			guiAdvancedComboBoxSetSelected(aStats.gui.walkCmb, row)
			break
		end
	end
end

function aStats.onAcceptedStatHandler()
	local stat = getElementData(source, "stat")
	if not stat then return end

	local value = tonumber(guiGetText(aStats.gui.stats[stat].edit))
	triggerServerEvent(EVENT_COMMAND, localPlayer, "setstat", aStats.Player, stat, value)
end