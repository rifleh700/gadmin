
aSkin = {
	gui = {},
	List = {},
	Groups = {}
}

function aSkin.Load()
	local node = xmlLoadFile("conf/skins.xml")
	if not node then return end

	local list = {}
	local groups = {}
	for gi, groupNode in ipairs(xmlNodeGetChildren(node)) do
		if xmlNodeGetName(groupNode) == "group" then
			local groupName = xmlNodeGetAttribute(groupNode, "name")
			groups[groupName] = {}
			for si, skinNode in ipairs(xmlNodeGetChildren(groupNode)) do
				local skinData = {}
				skinData.id = tonumber(xmlNodeGetAttribute(skinNode, "model"))
				skinData.name = xmlNodeGetAttribute(skinNode, "name")
				groups[groupName][#groups[groupName] + 1] = skinData

				local contain = false
				for li, lsd in ipairs(list) do
					if lsd.id == skinData.id then
						contain = true
						break
					end
				end
				if not contain then
					list[#list + 1] = skinData
				end
			end
		end
	end
	xmlUnloadFile(node)

	table.sort(list, function(a, b) return a.id < b.id end)
	aSkin.List = list
	aSkin.Groups = groups
end

function aSkin.Create()
	aSkin.gui.form = guiCreateWindow(0, 0, 280, 320, "Player Skin Select", false)
	
	aSkin.gui.srch = guiCreateSearchEdit(0.03, 0.09, 0.70, 0.08, "", true, aSkin.gui.form)
	aSkin.gui.list = guiCreateGridList(0.03, 0.18, 0.70, 0.61, true, aSkin.gui.form)
	guiGridListAddColumn(aSkin.gui.list, "ID", 0.20)
	guiGridListAddColumn(aSkin.gui.list, "Name", 0.75)
	guiGridListSetSortingEnabled(aSkin.gui.list, false)

	aSkin.gui.byGroupChk = guiCreateCheckBox(0.03, 0.80, 0.70, 0.09, "Sort by groups", aGetSetting("skinsGroup"), true, aSkin.gui.form)
	aSkin.gui.applyWalkingChk = guiCreateCheckBox(0.03, 0.90, 0.70, 0.09, "Apply walking style", true, true, aSkin.gui.form)

	aSkin.gui.cancelBtn = guiCreateButton(0.75, 0.88, 0.27, 0.09, "Close", true, aSkin.gui.form)

	aSkin.Load()
	aSkin.Refresh()

	addEventHandler("onClientGUIClick", aSkin.gui.form, aSkin.onClickHandler)
	addEventHandler("onClientGUIDoubleClick", aSkin.gui.form, aSkin.onDoubleClickHandler)
	addEventHandler("onClientGUIChanged", aSkin.gui.srch, aSkin.Refresh, false)

	aRegister("PlayerSkin", aSkin.gui.form, aSkin.Show, aSkin.Hide)
end

function aSkin.Destroy()
	destroyElement(aSkin.gui.form)
	aSkin.gui = {}
end

function aSkin.Show(player)
	if not aSkin.gui.form then
		aSkin.Create()
	end
	aSkin.Player = player
	guiSetVisible(aSkin.gui.form, true)
end

function aSkin.Hide(destroy)
	if not aSkin.gui.form then return end
	if destroy then
		aSkin.Destroy()
	else
		guiSetVisible(aSkin.gui.form, false)
	end
end

function aSkin.onClickHandler(key)
	if key ~= "left" then return end
	if source == aSkin.gui.byGroupChk then
		aSkin.Refresh()

	elseif source == aSkin.gui.cancelBtn then
		aSkin.Hide()

	end
end

function aSkin.onDoubleClickHandler(key)
	if key ~= "left" then return end
	if source == aSkin.gui.list then
		aSkin.Accept()
	end
end

function aSkin.Refresh()
	guiGridListClear(aSkin.gui.list)

	local search = string.lower(guiGetText(aSkin.gui.srch))
	if search == "" then search = false end

	if (not search) and guiCheckBoxGetSelected(aSkin.gui.byGroupChk) then
		for groupName, skins in pairs(aSkin.Groups) do
			local row = guiGridListAddRow(aSkin.gui.list)
			guiGridListSetItemText(aSkin.gui.list, row, 2, groupName, true, false)
			for i, skinData in ipairs(aSkin.Groups[groupName]) do
				row = guiGridListAddRow(aSkin.gui.list)
				guiGridListSetItemText(aSkin.gui.list, row, 1, skinData.id, false, true)
				guiGridListSetItemText(aSkin.gui.list, row, 2, skinData.name, false, false)
				guiGridListSetItemData(aSkin.gui.list, row, 1, skinData.id)
			end
		end
	else
		for i, skinData in ipairs(aSkin.List) do
			if (not search) or (search and string.find(string.lower(skinData.id..skinData.name), search, 1, true)) then
				local row = guiGridListAddRow(aSkin.gui.list)
				guiGridListSetItemText(aSkin.gui.list, row, 1, skinData.id, false, true)
				guiGridListSetItemText(aSkin.gui.list, row, 2, skinData.name, false, false)
				guiGridListSetItemData(aSkin.gui.list, row, 1, skinData.id)
			end
		end
	end
end

function aSkin.GetSelected()
	local selected = guiGridListGetSelectedItem(aSkin.gui.list)
	if selected == -1 then return nil end
	return guiGridListGetItemData(aSkin.gui.list, selected, 1)
end

function aSkin.Accept()
	local id = aSkin.GetSelected()
	if not id then return end
	triggerServerEvent(EVENT_COMMAND, localPlayer, "setskin", aSkin.Player, id, guiCheckBoxGetSelected(aSkin.gui.applyWalkingChk))
end

