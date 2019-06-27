
aInterior = {
	gui = {},
	List = {},
	Thread = nil,
	Result = false
}

function aInterior.Load()
	local node = xmlLoadFile("conf/interiors.xml")
	if not node then return end

	local list = {}
	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		list[i] = {
			name = xmlNodeGetAttribute(subnode, "name"),
			x = tonumber(xmlNodeGetAttribute(subnode, "posX")),
			y = tonumber(xmlNodeGetAttribute(subnode, "posY")),
			z = tonumber(xmlNodeGetAttribute(subnode, "posZ")),
			interior = tonumber(xmlNodeGetAttribute(subnode, "interior"))
		}
	end
	xmlUnloadFile(node)
	aInterior.List = list
end

function aInterior.Create()
	aInterior.gui.form = guiCreateWindow(0, 0, 220, 300, "Select interior", false)
	
	aInterior.gui.list = guiCreateGridList(0.03, 0.08, 0.94, 0.73, true, aInterior.gui.form)
	guiGridListAddColumn(aInterior.gui.list, "World", 0.2)
	guiGridListAddColumn(aInterior.gui.list, "Description", 0.75)
	aInterior.gui.acceptBtn = guiCreateButton(0.03, 0.82, 0.94, 0.075, "Accept", true, aInterior.gui.form)
	aInterior.gui.cancelBtn = guiCreateButton(0.03, 0.90, 0.94, 0.075, "Cancel", true, aInterior.gui.form)

	aInterior.Load()
	for i, data in ipairs(aInterior.List) do
		local row = guiGridListAddRow(aInterior.gui.list)
		guiGridListSetItemText(aInterior.gui.list, row, 1, data.interior, false, true)
		guiGridListSetItemText(aInterior.gui.list, row, 2, data.name, false, false)
	end

	addEventHandler("onClientGUIClick", aInterior.gui.form, aInterior.onClickHandler)
	addEventHandler("onClientGUIDoubleClick", aInterior.gui.form, aInterior.onDoubleClickHandler)

	aRegister("PlayerInterior", aInterior.gui.form, aInterior.Open, aInterior.Close)
end

function aInterior.Destroy()
	destroyElement(aInterior.gui.form)
	aInterior.gui = {}
end

function aInterior.Open()
	if not aInterior.gui.form then
		aInterior.Create()
	end

	guiSetVisible(aInterior.gui.form, true)

	aInterior.Result = false
	aInterior.Thread = coroutine.running()
	coroutine.yield()

	aInterior.Thread = nil
	return aInterior.Result
end

function aInterior.Close(destroy)
	if not aInterior.gui.form then return end
	if destroy then
		aInterior.Destroy()
	else
		guiSetVisible(aInterior.gui.form, false)
	end
	if aInterior.Thread then
		coroutine.resume(aInterior.Thread)
	end
end

function aInterior.onDoubleClickHandler(key)
	if key ~= "left" then return end

	if source == aInterior.gui.list then
		aInterior.Accept()
	end
end

function aInterior.onClickHandler(key)
	if key ~= "left" then return end

	if source == aInterior.gui.acceptBtn then
		aInterior.Accept()

	elseif source == aInterior.gui.cancelBtn then
		aInterior.Close()

	end
end

function aInterior.GetSelected()
	local selected = guiGridListGetSelectedItem(aInterior.gui.list)
	if selected == -1 then return nil end
	return guiGridListGetItemText(aInterior.gui.list, selected, 2)
end

function aInterior.Accept()
	local name = aInterior.GetSelected()
	if not name then return end

	aInterior.Result = name
	aInterior.Close()
end