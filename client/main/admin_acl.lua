
aAclTab = {
	gui = {},
	Groups = {
		List = {},
		Data = {}
	},
	ACL = {
		List = {},
		Data = {},
		Requested = {}
	}
}

function aAclTab.Create(tab)
	if aAclTab.gui.tab then return end
	
	aAclTab.gui.tab = tab

	--aAclTab.gui.updPanelChk = guiCreateCheckBox(0.25, 0.02, 0.20, 0.04, "Update panel", true, true, tab)
	--guiSetProperty(aAclTab.gui.updPanelChk, "AlwaysOnTop", "True")

	aAclTab.gui.refreshBtn = guiCreateButton(0.25, 0.02, 0.15, 0.04, "Refresh", true, tab)
	guiSetProperty(aAclTab.gui.refreshBtn, "AlwaysOnTop", "True")
	aAclTab.gui.restoreAdminBtn = guiCreateButton(0.41, 0.02, 0.25, 0.04, "Restore panel rights", true, tab, "restoreadminacl")
	guiSetProperty(aAclTab.gui.restoreAdminBtn, "AlwaysOnTop", "True")
	aAclTab.gui.restoreBtn = guiCreateButton(0.67, 0.02, 0.15, 0.04, "Restore ACL", true, tab, "restoreacl")
	guiSetProperty(aAclTab.gui.restoreBtn, "AlwaysOnTop", "True")
	aAclTab.gui.reloadBtn = guiCreateButton(0.83, 0.02, 0.15, 0.04, "Reload ACL", true, tab, "reloadacl")
	guiSetProperty(aAclTab.gui.reloadBtn, "AlwaysOnTop", "True")

	aAclTab.gui.panel = guiCreateTabPanel(0.01, 0.02, 0.98, 0.96, true, tab)

	-----------------------------
	aAclTab.gui.group = {}
	aAclTab.gui.group.tab = guiCreateTab("Groups", aAclTab.gui.panel)

	aAclTab.gui.group.list = guiCreateGridList(0.01, 0.02, 0.20, 0.96, true, aAclTab.gui.group.tab)
	guiGridListSetSortingEnabled(aAclTab.gui.group.list, false)
	guiGridListAddColumn(aAclTab.gui.group.list, "Name", 0.85)
	aAclTab.gui.group.listMsg = guiCreateElementMessageLabel(aAclTab.gui.group.list)
	guiGridListRegisterArrowScroll(aAclTab.gui.group.list)

	aAclTab.gui.group.panel = guiCreateTabPanel(0.22, 0.02, 0.76, 0.96, true, aAclTab.gui.group.tab)
	aAclTab.gui.group.mainTab = guiCreateTab("Main", aAclTab.gui.group.panel)
	aAclTab.gui.group.objectsList = guiCreateGridList(0.01, 0.02, 0.33, 0.96, true, aAclTab.gui.group.mainTab)
	guiGridListAddColumn(aAclTab.gui.group.objectsList, "Object", 0.75)
	aAclTab.gui.group.objectsListMsg = guiCreateElementMessageLabel(aAclTab.gui.group.objectsList)
	aAclTab.gui.group.aclList = guiCreateGridList(0.35, 0.02, 0.33, 0.96, true, aAclTab.gui.group.mainTab)
	guiGridListAddColumn(aAclTab.gui.group.aclList, "ACL", 0.75)
	aAclTab.gui.group.aclListMsg = guiCreateElementMessageLabel(aAclTab.gui.group.aclList)

	aAclTab.gui.group.addObjectBtn = guiCreateButton(0.71, 0.02, 0.27, 0.05, "Add object" ,true, aAclTab.gui.group.mainTab, "aclgroupaddobject")
	aAclTab.gui.group.removeObjectBtn = guiCreateButton(0.71, 0.08, 0.27, 0.05, "Remove object", true, aAclTab.gui.group.mainTab, "aclgroupremoveobject")
	aAclTab.gui.group.addACLBtn = guiCreateButton(0.71, 0.14, 0.27, 0.05, "Add ACL" ,true, aAclTab.gui.group.mainTab, "aclgroupaddacl")
	aAclTab.gui.group.removeACLBtn = guiCreateButton(0.71, 0.20, 0.27, 0.05, "Remove ACL", true, aAclTab.gui.group.mainTab, "aclgroupremoveacl")
	aAclTab.gui.group.destroyBtn = guiCreateButton(0.71, 0.26, 0.27, 0.05, "Destroy group", true, aAclTab.gui.group.mainTab, "acldestroygroup")
	aAclTab.gui.group.createBtn = guiCreateButton(0.71, 0.38, 0.27, 0.05, "Create group" ,true, aAclTab.gui.group.mainTab, "aclcreategroup")
	
	aAclTab.gui.group.accessTab = guiCreateTab("Access Matrix", aAclTab.gui.group.panel)
	aAclTab.gui.group.accessSrch = guiCreateSearchEdit(0.01, 0.02, 0.35, 0.045, "", true, aAclTab.gui.group.accessTab)
	aAclTab.gui.group.accessViewCmb, aAclTab.gui.group.accessViewList =
		guiCreateAdvancedComboBox(0.38, 0.02, 0.23, 0.045, "", true, aAclTab.gui.group.accessTab)
	guiGridListAddRow(aAclTab.gui.group.accessViewList, "all")
	guiGridListAddRow(aAclTab.gui.group.accessViewList, "general")
	guiGridListAddRow(aAclTab.gui.group.accessViewList, "function")
	guiGridListAddRow(aAclTab.gui.group.accessViewList, "command")
	guiGridListAddRow(aAclTab.gui.group.accessViewList, "resource")
	guiGridListAdjustHeight(aAclTab.gui.group.accessViewList)
	guiAdvancedComboBoxSetSelected(aAclTab.gui.group.accessViewCmb, 0)

	aAclTab.gui.group.accessList = guiCreateGridList(0.01, 0.07, 0.98, 0.91, true, aAclTab.gui.group.accessTab)
	guiGridListAddColumn(aAclTab.gui.group.accessList, "Right", 0.35)
	guiGridListSetSelectionMode(aAclTab.gui.group.accessList, 2)
	guiGridListSetSortingEnabled(aAclTab.gui.group.accessList, false)
	aAclTab.gui.group.accessListMsg = guiCreateElementMessageLabel(aAclTab.gui.group.accessList)
	aAclTab.gui.removeRightTip = guiCreateToolTip("Right click to remove right", aAclTab.gui.group.accessList)

	aAclTab.SetGroupContentMessage("N/A")

	-----------------------------
	aAclTab.gui.acl = {}
	aAclTab.gui.acl.tab = guiCreateTab("ACL", aAclTab.gui.panel)

	aAclTab.gui.acl.list = guiCreateGridList(0.01, 0.02, 0.20, 0.96, true, aAclTab.gui.acl.tab)
	guiGridListSetSortingEnabled(aAclTab.gui.acl.list, false)
	guiGridListAddColumn(aAclTab.gui.acl.list, "Name", 0.85)
	aAclTab.gui.acl.listMsg = guiCreateElementMessageLabel(aAclTab.gui.acl.list)
	guiGridListRegisterArrowScroll(aAclTab.gui.acl.list)

	aAclTab.gui.acl.panel = guiCreateTabPanel(0.22, 0.02, 0.76, 0.96, true, aAclTab.gui.acl.tab)
	aAclTab.gui.acl.mainTab = guiCreateTab("Main", aAclTab.gui.acl.panel)
	aAclTab.gui.acl.rightSrch = guiCreateSearchEdit(0.01, 0.02, 0.41, 0.05, "", true, aAclTab.gui.acl.mainTab)
	aAclTab.gui.acl.rightViewCmb, aAclTab.gui.acl.rightViewList =
		guiCreateAdvancedComboBox(0.43, 0.02, 0.22, 0.05, "", true, aAclTab.gui.acl.mainTab)
	guiGridListAddRow(aAclTab.gui.acl.rightViewList, "all")
	guiGridListAddRow(aAclTab.gui.acl.rightViewList, "general")
	guiGridListAddRow(aAclTab.gui.acl.rightViewList, "function")
	guiGridListAddRow(aAclTab.gui.acl.rightViewList, "command")
	guiGridListAddRow(aAclTab.gui.acl.rightViewList, "resource")
	guiGridListAdjustHeight(aAclTab.gui.acl.rightViewList)
	guiAdvancedComboBoxSetSelected(aAclTab.gui.acl.rightViewCmb, 0)
	aAclTab.gui.acl.rightsList = guiCreateGridList(0.01, 0.08, 0.67, 0.90, true, aAclTab.gui.acl.mainTab)
	guiGridListSetSortingEnabled(aAclTab.gui.acl.rightsList, false)
	guiGridListAddColumn(aAclTab.gui.acl.rightsList, "Right", 0.65)
	guiGridListAddColumn(aAclTab.gui.acl.rightsList, "Access", 0.20)
	aAclTab.gui.acl.rightsListMsg = guiCreateElementMessageLabel(aAclTab.gui.acl.rightsList)
	guiSetToolTip(aAclTab.gui.acl.rightsList, aAclTab.gui.removeRightTip)

	aAclTab.gui.acl.addRightBtn = guiCreateButton(0.71, 0.08, 0.27, 0.05, "Add right" ,true, aAclTab.gui.acl.mainTab, "aclsetright")
	aAclTab.gui.acl.switchRightBtn = guiCreateButton(0.71, 0.14, 0.27, 0.05, "Switch right" ,true, aAclTab.gui.acl.mainTab, "aclsetright")
	aAclTab.gui.acl.removeRightBtn = guiCreateButton(0.71, 0.20, 0.27, 0.05, "Remove right", true, aAclTab.gui.acl.mainTab, "aclremoveright")
	aAclTab.gui.acl.destroyBtn = guiCreateButton(0.71, 0.26, 0.27, 0.05, "Destroy acl", true, aAclTab.gui.acl.mainTab, "acldestroy")
	aAclTab.gui.acl.createBtn = guiCreateButton(0.71, 0.38, 0.27, 0.05, "Create acl" ,true, aAclTab.gui.acl.mainTab, "aclcreate")

	--aAclTab.gui.acl.showDefaultChk = guiCreateCheckBox(0.71, 0.92, 0.27, 0.05, "Show Default ACL", false, true, aAclTab.gui.acl.mainTab)

	-----------------------------

	addEventHandler("onClientGUIClick", aAclTab.gui.tab, aAclTab.onClickHandler)
	addEventHandler("onClientGUIDoubleClick", aAclTab.gui.tab, aAclTab.onDoubleClickHandler)
	addEventHandler("onClientGUIChanged", aAclTab.gui.group.accessSrch, function() aAclTab.RefreshGroupAccess() end, false)
	addEventHandler("onClientGUIAdvancedComboBoxAccepted", aAclTab.gui.group.accessViewCmb, aAclTab.RefreshGroupAccess, false)
	
	addEventHandler("onClientGUIChanged", aAclTab.gui.acl.rightSrch, function() aAclTab.RefreshACL() end, false)
	addEventHandler("onClientGUIAdvancedComboBoxAccepted", aAclTab.gui.acl.rightViewCmb, aAclTab.RefreshACL, false)
	addEventHandler("onClientResourceStop", resourceRoot, aAclTab.SaveSettings)

	addEventHandler(EVENT_SYNC, localPlayer, aAclTab.onSyncHandler)

	guiSetText(aAclTab.gui.group.listMsg, "Loading...")
	guiSetText(aAclTab.gui.acl.listMsg, "Loading...")
	sync(SYNC_ACL, SYNC_LIST, ACL_GROUP)
	sync(SYNC_ACL, SYNC_LIST, ACL_ACL)
end

function aAclTab.Destroy()
	removeEventHandler(EVENT_SYNC, localPlayer, aAclTab.onSyncHandler)
	removeEventHandler("onClientResourceStop", resourceRoot, aAclTab.SaveSettings)
	aAclTab.SaveSettings()
	aAclTab.gui = {}
	aAclTab.Groups = {List = {}, Data = {}}
	aAclTab.ACL = {List = {}, Data = {}, Requested = {}}
end

aAclTab.SyncFunctions = {
	[SYNC_LIST] = {
		[ACL_GROUP] = function(groups)
			aAclTab.Groups.Data = {}
			aAclTab.Groups.List = groups
			guiSetText(aAclTab.gui.group.listMsg, "")
			aAclTab.RefreshGroups()
		end,
		[ACL_ACL] = function(acls)
			aAclTab.ACL.Data = {}
			aAclTab.ACL.List = acls
			guiSetText(aAclTab.gui.acl.listMsg, "")
			aAclTab.RefreshACLs()
		end,
	},
	[SYNC_SINGLE] = {
		[ACL_GROUP] = function(group, data)
			aAclTab.Groups.Data[group] = data
			aAclTab.RefreshGroup(group)
		end,
		[ACL_ACL] = function(acl, rights)
			aAclTab.ACL.Data[acl] = rights
			aAclTab.ACL.Requested[acl] = nil
			aAclTab.RefreshACL(acl)
			aAclTab.RefreshGroupAccess(acl)
		end,
	}
}
function aAclTab.onSyncHandler(dataType, syncType, aclType, ...)
	if dataType ~= SYNC_ACL then return end
	aAclTab.SyncFunctions[syncType][aclType](...)
end

function aAclTab.onClickHandler(key)

	if key == "right" then

		if source == aAclTab.gui.group.accessList then
			local acl, right, access = aAclTab.GetAccessSelectedACLRight()
			if not acl then return end
			if access == nil then return end
			if not messageBox("Right '"..right.."' will be removed from ACL '"..acl.."'. Continue?", MB_QUESTION, MB_YESNO) then return end
			if acl == "Default" then
				if not messageBox("Warning! Highly recommended do not remove any rights from 'Default' ACL. Delete it only, if you know what you are doing. Continue?", MB_WARNING, MB_YESNO) then return end
			end
			triggerServerEvent(EVENT_COMMAND, localPlayer, "aclremoveright", acl, right)

		elseif source == aAclTab.gui.acl.rightsList then
			local right = aAclTab.GetACLSelectedRight()
			if not right then return end
			triggerEvent("onClientGUIClick", aAclTab.gui.acl.removeRightBtn, "left")

		end
	end

	if key ~= "left" then return end

	if source == aAclTab.gui.refreshBtn then
		aAclTab.Groups = {List = {}, Data = {}}
		aAclTab.ACL = {List = {}, Data = {}, Requested = {}}
		aAclTab.RefreshGroups()
		aAclTab.RefreshACLs()
		guiSetText(aAclTab.gui.group.listMsg, "Loading...")
		guiSetText(aAclTab.gui.acl.listMsg, "Loading...")
		sync(SYNC_ACL, SYNC_LIST, ACL_GROUP)
		sync(SYNC_ACL, SYNC_LIST, ACL_ACL)

	elseif source == aAclTab.gui.restoreAdminBtn then
		if not messageBox("Admin panel rights will be restored. Continue?", MB_QUESTION, MB_YESNO) then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "restoreadminacl")

	elseif source == aAclTab.gui.restoreBtn then
		if not messageBox("Server default rights and admin panel rights will be restored. Added objects, custom groups and rights will NOT be changed, except 'Everyone' group. Continue?", MB_QUESTION, MB_YESNO) then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "restoreacl")

	elseif source == aAclTab.gui.reloadBtn then
		if not messageBox("Server ACL will be reloaded. Continue?", MB_QUESTION, MB_YESNO) then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "reloadacl")

	elseif source == aAclTab.gui.group.list then
		aAclTab.RefreshGroup()

	elseif source == aAclTab.gui.group.createBtn then
		local group = inputBox("Add group", "Enter the group name", nil, true)
		if not group then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "aclcreategroup", group)

	elseif source == aAclTab.gui.group.destroyBtn then
		local group = aAclTab.GetSelectedGroup()
		if not group then return messageBox("No group selected!", MB_ERROR) end
		if not messageBox("Group '"..group.."' will be destroyed! Are you sure?", MB_WARNING, MB_YESNO) then return end
		if group == "Everyone" then
			if not messageBox("Warning! Highly recommended do not delete group 'Everyone'. Delete it only, if you know what you are doing. Continue?", MB_WARNING, MB_YESNO) then return end
		end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "acldestroygroup", group)
	
	elseif source == aAclTab.gui.group.addObjectBtn then
		local group = aAclTab.GetSelectedGroup()
		if not group then return messageBox("No group selected!", MB_ERROR) end
		local object = inputBox("Add object", "Enter the object name", nil, true)
		if not object then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "aclgroupaddobject", group, object)

	elseif source == aAclTab.gui.group.removeObjectBtn then
		local group = aAclTab.GetSelectedGroup()
		if not group then return messageBox("No group selected!", MB_ERROR) end
		local object = aAclTab.GetGroupSelectedObject()
		if not object then return messageBox("No object selected!", MB_ERROR) end
		if not messageBox("Object '"..object.."' will be removed from group '"..group.."'. Continue?", MB_QUESTION, MB_YESNO) then return end
		if group == "Everyone" then
			if not messageBox("Warning! Highly recommended do not remove any objects from 'Everyone' group. Delete it only, if you know what you are doing. Continue?", MB_WARNING, MB_YESNO) then return end
		end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "aclgroupremoveobject", group, object)

	elseif source == aAclTab.gui.group.addACLBtn then
		local group = aAclTab.GetSelectedGroup()
		if not group then return messageBox("No group selected!", MB_ERROR) end
		local acl = inputBox("Add ACL", "Enter the ACL name", nil, true)
		if not acl then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "aclgroupaddacl", group, acl)

	elseif source == aAclTab.gui.group.removeACLBtn then
		local group = aAclTab.GetSelectedGroup()
		if not group then return messageBox("No group selected!", MB_ERROR) end
		local acl = aAclTab.GetGroupSelectedACL()
		if not acl then return messageBox("No ACL selected!", MB_ERROR) end
		if not messageBox("ACL '"..acl.."' will be removed from group '"..group.."'. Continue?", MB_QUESTION, MB_YESNO) then return end
		if group == "Everyone" then
			if not messageBox("Warning! Highly recommended do not remove any ACL from 'Everyone' group. Delete it only, if you know what you are doing. Continue?", MB_WARNING, MB_YESNO) then return end
		end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "aclgroupremoveacl", group, acl)


	--------------- ACL -------------------
	elseif source == aAclTab.gui.acl.list then
		aAclTab.RefreshACL()

	elseif source == aAclTab.gui.acl.createBtn then
		local acl = inputBox("Add ACL", "Enter the ACL name", nil, true)
		if not acl then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "aclcreate", acl)

	elseif source == aAclTab.gui.acl.destroyBtn then
		local acl = aAclTab.GetSelectedACL()
		if not acl then return messageBox("No ACL selected!", MB_ERROR) end
		if not messageBox("ACL '"..acl.."' will be destroyed! Are you sure?", MB_WARNING, MB_YESNO) then return end
		if acl == "Default" then
			if not messageBox("Warning! Highly recommended do not delete ACL 'Default'. Delete it only, if you know what you are doing. Continue?", MB_WARNING, MB_YESNO) then return end
		end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "acldestroy", acl)

	elseif source == aAclTab.gui.acl.addRightBtn then
		local acl = aAclTab.GetSelectedACL()
		if not acl then return messageBox("No ACL selected!", MB_ERROR) end
		local right = inputBox("Add right", "Enter the right name", nil, true)
		if not right then return end
		if aAclTab.GetACLRight(acl, right) ~= nil then return messageBox("Right '"..right.."' is already added!", MB_ERROR) end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "aclsetright", acl, right, false)

	elseif source == aAclTab.gui.acl.switchRightBtn then
		local acl = aAclTab.GetSelectedACL()
		if not acl then return messageBox("No ACL selected!", MB_ERROR) end
		local right = aAclTab.GetACLSelectedRight()
		if not right then return messageBox("No right selected!", MB_ERROR) end
		local access = not aAclTab.GetACLRight(acl, right)
		if not messageBox("Set right '"..right.."' to '"..tostring(access).."'?", MB_QUESTION, MB_YESNO) then return end
		if acl == "Default" then
			if not messageBox("Warning! Highly recommended do not change any rights in 'Default' ACL. Change it only, if you know what you are doing. Continue?", MB_WARNING, MB_YESNO) then return end
		end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "aclsetright", acl, right, access)

	elseif source == aAclTab.gui.acl.removeRightBtn then
		local acl = aAclTab.GetSelectedACL()
		if not acl then return messageBox("No ACL selected!", MB_ERROR) end
		local right = aAclTab.GetACLSelectedRight()
		if not right then return messageBox("No right selected!", MB_ERROR) end
		if not messageBox("Right '"..right.."' will be removed from ACL '"..acl.."'. Continue?", MB_QUESTION, MB_YESNO) then return end
		if acl == "Default" then
			if not messageBox("Warning! Highly recommended do not remove any rights from 'Default' ACL. Delete it only, if you know what you are doing. Continue?", MB_WARNING, MB_YESNO) then return end
		end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "aclremoveright", acl, right)

	end
end

function aAclTab.onDoubleClickHandler(key)
	if key ~= "left" then return end

	if source == aAclTab.gui.group.accessList then
		local acl, right, access = aAclTab.GetAccessSelectedACLRight()
		if not acl then return end
		if access == nil then
			access = false
		else
			access = not access
		end
		if not messageBox("Set '"..acl.."' ACL right '"..right.."' to '"..tostring(access).."'?", MB_QUESTION, MB_YESNO) then return end
		if acl == "Default" then
			if not messageBox("Warning! Highly recommended do not change any rights in 'Default' ACL. Change it only, if you know what you are doing. Continue?", MB_WARNING, MB_YESNO) then return end
		end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "aclsetright", acl, right, access)

	elseif source == aAclTab.gui.acl.rightsList then
		local selectedRight = aAclTab.GetACLSelectedRight()
		if not selectedRight then return end
		triggerEvent("onClientGUIClick", aAclTab.gui.acl.switchRightBtn, key)
	end
end

function aAclTab.SaveSettings()
end

function aAclTab.RequestGroupACLs(group)
	for i, acl in ipairs(aAclTab.Groups.Data[group].acls) do
		if not aAclTab.ACL.Data[acl] and not aAclTab.ACL.Requested[acl] then
			aAclTab.ACL.Requested[acl] = true
			sync(SYNC_ACL, SYNC_SINGLE, ACL_ACL, acl)
		end
	end
end

function aAclTab.IsACLInGroup(acl, group)
	if not aAclTab.Groups.Data[group] then return false end
	for i, groupACL in ipairs(aAclTab.Groups.Data[group].acls) do
		if groupACL == acl then return true end
	end
	return false
end

function aAclTab.GetSelectedGroup()
	local item = guiGridListGetSelectedItem(aAclTab.gui.group.list, 1)
	if item == -1 then return nil end
	return guiGridListGetItemText(aAclTab.gui.group.list, item, 1)
end

function aAclTab.GetGroupSelectedObject()
	local item = guiGridListGetSelectedItem(aAclTab.gui.group.objectsList, 1)
	if item == -1 then return nil end
	return guiGridListGetItemText(aAclTab.gui.group.objectsList, item, 1)
end

function aAclTab.GetGroupSelectedACL()
	local item = guiGridListGetSelectedItem(aAclTab.gui.group.aclList, 1)
	if item == -1 then return nil end
	return guiGridListGetItemText(aAclTab.gui.group.aclList, item, 1)
end

function aAclTab.GetAccessSelectedACLRight()
	local item, column = guiGridListGetSelectedItem(aAclTab.gui.group.accessList, 1)
	if item == -1 then return nil end
	if column == 1 then return nil end

	local acl = guiGridListGetColumnTitle(aAclTab.gui.group.accessList, column)
	local right = guiGridListGetItemData(aAclTab.gui.group.accessList, item, 1)
	local access = guiGridListGetItemData(aAclTab.gui.group.accessList, item, column)
	return acl, right, access
end

function aAclTab.RefreshGroups()
	local selected = aAclTab.GetSelectedGroup()
	guiGridListClear(aAclTab.gui.group.list)
	for i, group in ipairs(aAclTab.Groups.List) do
		guiGridListAddRow(aAclTab.gui.group.list, group)
		if selected and group == selected then
			guiGridListSetSelectedItem(aAclTab.gui.group.list, i-1, 1)
		end
	end
	aAclTab.RefreshGroup()
end

function aAclTab.SetGroupContentMessage(message)
	guiSetText(aAclTab.gui.group.objectsListMsg, message or "")
	guiSetText(aAclTab.gui.group.aclListMsg, message or "")
	guiSetText(aAclTab.gui.group.accessListMsg, message or "")
end

function aAclTab.RefreshGroup(group)
	local selected = aAclTab.GetSelectedGroup()
	if group and group ~= selected then return end

	aAclTab.RefreshGroupAccess()

	local selectedObject = aAclTab.GetGroupSelectedObject()
	local selectedACL = aAclTab.GetGroupSelectedACL()
	guiGridListClear(aAclTab.gui.group.objectsList)
	guiGridListClear(aAclTab.gui.group.aclList)
	
	if not selected then
		aAclTab.SetGroupContentMessage("N/A")
		return
	end

	if not aAclTab.Groups.Data[selected] then
		aAclTab.SetGroupContentMessage("Loading...")
		sync(SYNC_ACL, SYNC_SINGLE, ACL_GROUP, selected)
		return
	end

	aAclTab.SetGroupContentMessage()

	for i, object in ipairs(aAclTab.Groups.Data[selected].objects) do
		guiGridListAddRow(aAclTab.gui.group.objectsList, object)
		if selectedObject and object == selectedObject then
			guiGridListSetSelectedItem(aAclTab.gui.group.objectsList, i-1, 1)
		end
	end

	for i, acl in ipairs(aAclTab.Groups.Data[selected].acls) do
		guiGridListAddRow(aAclTab.gui.group.aclList, acl)
		if selectedACL and acl == selectedACL then
			guiGridListSetSelectedItem(aAclTab.gui.group.aclList, i-1, 1)
		end
	end

end

function aAclTab.RefreshGroupAccess(acl)
	local group = aAclTab.GetSelectedGroup()
	if acl then
		if not group then return end
		if not aAclTab.IsACLInGroup(acl, group) then return end
	end

	local list = aAclTab.gui.group.accessList
	local selected, selectedColumn = guiGridListGetSelectedItem(list)
	local scroll = guiGridListGetVerticalScrollPosition(list)

	guiGridListClear(list)
	for i = 2, guiGridListGetColumnCount(list) do
		guiGridListRemoveColumn(list, 2)
	end

	if not group then return end

	local data = aAclTab.Groups.Data[group]
	if not data then return end

	for i, acl in ipairs(data.acls) do
		if not aAclTab.ACL.Data[acl] then
			aAclTab.RequestGroupACLs(group)
			guiSetText(aAclTab.gui.group.accessListMsg, "Loading...")
			return
		end
	end
	
	guiSetText(aAclTab.gui.group.accessListMsg, "")

	local viewType = guiGetText(aAclTab.gui.group.accessViewCmb)
	if viewType == "all" then viewType = ".*" end
	local search = string.lower(guiGetText(aAclTab.gui.group.accessSrch))

	local rightrows = {}
	for i, acl in ipairs(data.acls) do
		guiGridListAddColumn(list, acl, 0.10)
		for ir, right in ipairs(aAclTab.ACL.Data[acl]) do
			local cutted = string.gsub(right.name, "^.-%.", "")
			if (string.match(right.name, "^"..viewType)) and
			(string.find(string.lower(cutted), search, 1, true)) then
				local row = rightrows[right.name]
				if not row then
					row = guiGridListAddRow(list)
					if viewType == ".*" then
						guiGridListSetItemText(list, row, 1, right.name, false, false)
					else
						guiGridListSetItemText(list, row, 1, cutted, false, false)
					end
					guiGridListSetItemData(list, row, 1, right.name)
					rightrows[right.name] = row
				end
				guiGridListSetItemText(list, row, i+1, tostring(right.access), false, false)
				guiGridListSetItemData(list, row, i+1, right.access)
			end
		end
	end

	local columns = guiGridListGetColumnCount(list)
	for i = 0, guiGridListGetRowCount(list) do
		local access = false
		for j = 2, columns do
			local text = guiGridListGetItemText(list, i, j)
			if text == "" then
				guiGridListSetItemText(list, i, j, "  n", false, false)
				guiGridListSetItemColor(list, i, j, 75, 75, 75)
			else
				if text == "true" then
					access = true
					guiGridListSetItemColor(list, i, j, 255, 255, 255)
				else
					guiGridListSetItemColor(list, i, j, 75, 75, 75)
				end
			end
		end
		if access then
			guiGridListSetItemColor(list, i, 1, 255, 255, 255)
		else
			guiGridListSetItemColor(list, i, 1, 75, 75, 75)
		end
	end

	local slct = math.clamp(selected, -1, guiGridListGetRowCount(list) - 1)
	local slctColumn = math.clamp(selectedColumn, 0, columns)
	guiGridListSetSelectedItem(list, slct, slctColumn)
	guiGridListSetVerticalScrollPosition(list, scroll)
	setTimer(guiGridListSetVerticalScrollPosition, 50, 1, list, scroll)

end
---------------------------------------
--------------- ACL -------------------
---------------------------------------

function aAclTab.GetACLRight(acl, right)
	for i, data in ipairs(aAclTab.ACL.Data[acl]) do
		if data.name == right then return data.access end
	end
	return nil
end

function aAclTab.GetSelectedACL()
	local item = guiGridListGetSelectedItem(aAclTab.gui.acl.list, 1)
	if item == -1 then return end
	return guiGridListGetItemText(aAclTab.gui.acl.list, item, 1)
end

function aAclTab.RefreshACLs()
	local selected = aAclTab.GetSelectedACL()
	guiGridListClear(aAclTab.gui.acl.list)
	for i, acl in ipairs(aAclTab.ACL.List) do
		guiGridListAddRow(aAclTab.gui.acl.list, acl)
		if selected and acl == selected then
			guiGridListSetSelectedItem(aAclTab.gui.acl.list, i-1, 1)
		end
	end
	aAclTab.RefreshACL()
end

function aAclTab.GetACLSelectedRight()
	local item = guiGridListGetSelectedItem(aAclTab.gui.acl.rightsList, 1)
	if item == -1 then return end
	local right = guiGridListGetItemText(aAclTab.gui.acl.rightsList, item, 1)
	local viewType = guiGetText(aAclTab.gui.acl.rightViewCmb)
	if viewType ~= "all" then
		right = viewType.."."..right
	end
	return right
end

function aAclTab.SetACLContentMessage(message)
	guiSetText(aAclTab.gui.acl.rightsListMsg, message or "")
end

function aAclTab.RefreshACL(acl)
	local selectedACL = aAclTab.GetSelectedACL()
	if acl and acl ~= selectedACL then return end

	local list = aAclTab.gui.acl.rightsList
	local selected = guiGridListGetSelectedItem(list)
	local scroll = guiGridListGetVerticalScrollPosition(list)
	guiGridListClear(list)

	if not selectedACL then
		aAclTab.SetACLContentMessage("N/A")
		return
	end

	if not aAclTab.ACL.Data[selectedACL] then
		aAclTab.SetACLContentMessage("Loading...")
		if not aAclTab.ACL.Requested[selectedACL] then
			sync(SYNC_ACL, SYNC_SINGLE, ACL_ACL, selectedACL)
		end
		return
	end
	aAclTab.SetACLContentMessage()

	local viewType = guiGetText(aAclTab.gui.acl.rightViewCmb)
	if viewType == "all" then viewType = ".*" end
	local search = string.lower(guiGetText(aAclTab.gui.acl.rightSrch))

	for i, right in ipairs(aAclTab.ACL.Data[selectedACL]) do
		local cutted = string.gsub(right.name, "^.-%.", "")
		if (string.match(right.name, "^"..viewType)) and
		(string.find(string.lower(cutted), search, 1, true)) then
			local row = guiGridListAddRow(list, cutted, tostring(right.access))
			if viewType == ".*" then
				guiGridListSetItemText(list, row, 1, right.name, false, false)
			end
			if selectedRight and right.name == selectedRight then
				guiGridListSetSelectedItem(list, i-1, 1)
			end
			if not right.access then
				guiGridListSetItemColor(list, row, 1, 75, 75, 75)
				guiGridListSetItemColor(list, row, 2, 75, 75, 75)
			end
		end
	end

	local slct = math.clamp(selected, -1, guiGridListGetRowCount(list) - 1)
	guiGridListSetSelectedItem(list, slct, 1)
	guiGridListSetVerticalScrollPosition(list, scroll)
	setTimer(guiGridListSetVerticalScrollPosition, 50, 1, list, scroll)
end