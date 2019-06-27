
local function getACLConfigFileData(path)
	local fileNode = xmlLoadFile(path, true)
	if not fileNode then return false end

	local data = {}
	data.groups = {}
	data.acls = {}

	for i, node in ipairs(xmlNodeGetChildren(fileNode)) do
		local nodeName = xmlNodeGetName(node)
		local nodeChildren = xmlNodeGetChildren(node)
		local name = xmlNodeGetAttribute(node, "name")

		if nodeName == "group" then
			local groupData = {}
			groupData.name = name
			groupData.acls = {}
			groupData.objects = {}

			for i, childNode in ipairs(nodeChildren) do
				local childNodeName = xmlNodeGetName(childNode)
				local name = xmlNodeGetAttribute(childNode, "name")
				if childNodeName == "acl" then
					table.insert(groupData.acls, name)
				elseif childNodeName == "object" then
					table.insert(groupData.objects, name)
				end
			end
			table.insert(data.groups, groupData)

		elseif nodeName == "acl" then
			local aclData = {}
			aclData.name = name
			aclData.rights = {}

			for i, childNode in ipairs(nodeChildren) do
				if xmlNodeGetName(childNode) == "right" then
					local rightData = {}
					rightData.name = xmlNodeGetAttribute(childNode, "name")
					rightData.access = xmlNodeGetAttribute(childNode, "access") == "true"
					table.insert(aclData.rights, rightData)
				end
			end
			table.insert(data.acls, aclData)

		end
	end

	xmlUnloadFile(fileNode)

	return data
end

function aSetupACL()
	outputDebugString(LOG_PREFIX..": Verifying ACL...", 3)

	local fileData = getACLConfigFileData("conf/ACL.xml")
	if not fileData then
		outputDebugString(LOG_PREFIX..": Couldn't load vanila ACL! Please use 'restoreadminacl' command or reinstall the resource", 3)
		return false
	end

	local adminACLs = {}
	local adminDefaultRights = {}
	for i, aclData in ipairs(fileData.acls) do
		adminACLs[aclData.name] = {}
		for i, rightData in ipairs(aclData.rights) do
			adminACLs[aclData.name][rightData.name] = rightData.access
			if aclData.name == "Default" then
				table.insert(adminDefaultRights, rightData.name)
			end
		end
	end

	if not adminACLs["Default"] then
		outputDebugString(LOG_PREFIX..": Couldn't find 'Default' ACL! Please use 'restoreadminacl' command or reinstall the resource", 3)
		return false
	end

	setCustomEventsEnabled(false)

	local new = false
	local admins = false

	for i, acl in ipairs(aclList()) do
		if not aclIsAuto(acl) then

			local updated = 0
			local aclName = aclGetName(acl)
			local adminACLRights = adminACLs[aclName] or {}

			for i, right in ipairs(adminDefaultRights) do
				local access = aclGetRight(acl, right)
				if not isACLRightExist(acl, right) then access = nil end

				if adminACLRights[right] ~= access then
					if adminACLRights[right] == nil then
						aclRemoveRight(acl, right)
					else
						aclSetRight(acl, right, adminACLRights[right])
					end
					updated = updated + 1
				end
			end
	
			if not admins then
				admins = aclGetRight(acl, "general.adminpanel")
			end
	
			if updated > 0 then
				new = true
				outputDebugString(LOG_PREFIX..": Updated "..updated.." entries in ACL '"..aclName.."'", 3)
			end
		end
	end

	if not admins then
		outputDebugString(LOG_PREFIX..": No ACL groups are able to use admin panel", 3)
	end
	if not new then
		outputDebugString(LOG_PREFIX..": No ACL changes required", 3)
	end

	aclSave()
	setCustomEventsEnabled(true)

	return true
end

function aRestoreACL()
	local backupNode = xmlLoadFile("conf/ACL_default.xml")
	if not backupNode then
		outputDebugString(LOG_PREFIX..": Couldn't load vanila ACL backup! Please reinstall the resource", 3)
		return false
	end

	local fileNode = xmlCopyFile(backupNode, "conf/ACL.xml")
	xmlUnloadFile(backupNode)
	if not fileNode then
		outputDebugString(LOG_PREFIX..": Couldn't restore vanila ACL!", 3)
		return false
	end

	xmlSaveFile(fileNode)
	xmlUnloadFile(fileNode)
	
	aSetupACL()
	triggerEvent("onAclReload", root)

	outputDebugString(LOG_PREFIX..": Vanila ACL successfully restored", 3)
	
	return true
end

function aRestoreServerACL()

	local fileData = getACLConfigFileData("conf/server_ACL_default.xml")
	if not fileData then
		outputDebugString(LOG_PREFIX..": Couldn't load default server ACL! Please reinstall the resource", 3)
		return false
	end

	local defaultACLData = nil
	for i, aclData in ipairs(fileData.acls) do
		if aclData.name == "Default" then
			defaultACLData = aclData
			break
		end
	end
	if not defaultACLData then
		outputDebugString(LOG_PREFIX..": Couldn't find 'Default' ACL in default server ACL! Please reinstall the resource", 3)
		return false
	end

	-- anti event flood
	setCustomEventsEnabled(false)

	-- temporary rights
	local tempAdminGroup = aclGetGroup("temp_Admin") or aclCreateGroup("temp_Admin")
	local tempAdminACL = aclGet("temp_Admin") or aclCreate("temp_Admin")
	aclSetRight(tempAdminACL, "function.aclReload", true)
	aclSetRight(tempAdminACL, "function.aclSave", true)
	aclSetRight(tempAdminACL, "function.aclCreate", true)
	aclSetRight(tempAdminACL, "function.aclDestroy", true)
	aclSetRight(tempAdminACL, "function.aclSetRight", true)
	aclSetRight(tempAdminACL, "function.aclRemoveRight", true)
	aclSetRight(tempAdminACL, "function.aclCreateGroup", true)
	aclSetRight(tempAdminACL, "function.aclDestroyGroup", true)
	aclSetRight(tempAdminACL, "function.aclGroupAddACL", true)
	aclSetRight(tempAdminACL, "function.aclGroupRemoveACL", true)
	aclSetRight(tempAdminACL, "function.aclGroupAddObject", true)
	aclSetRight(tempAdminACL, "function.aclGroupRemoveObject", true)
	aclGroupAddACL(tempAdminGroup, tempAdminACL)
	aclGroupAddObject(tempAdminGroup, "resource."..getResourceName(resource))

	for i, aclData in ipairs(fileData.acls) do
		local acl = aclGet(aclData.name) or aclCreate(aclData.name)
		for ir, rightData in ipairs(defaultACLData.rights) do
			if rightData.access then
				aclSetRight(acl, true)
			else
				aclRemoveRight(acl, rightData.name)
			end
		end
		for ir, rightData in ipairs(aclData.rights) do
			aclSetRight(acl, rightData.name, rightData.access)
		end
	end

	for i, groupData in ipairs(fileData.groups) do
		local group = aclGetGroup(groupData.name) or aclCreateGroup(groupData.name)
		aclGroupRemoveObject(group, "user.*")
		aclGroupRemoveObject(group, "resource.*")
		-- remove all default acls from default groups
		for ia, aclData in ipairs(fileData.acls) do
			aclGroupRemoveACL(group, aclGet(aclData.name))
		end
		for ia, aclName in ipairs(groupData.acls) do
			aclGroupAddACL(group, aclGet(aclName))
		end
		for iobj, object in ipairs(groupData.objects) do
			aclGroupAddObject(group, object)
		end
	end

	aclDestroyGroup(tempAdminGroup)
	aclDestroy(tempAdminACL)
	setCustomEventsEnabled(true)

	outputDebugString(LOG_PREFIX..": Server ACL successfully restored", 3)
	aRestoreACL()
	
	return true
end

function aACLSetRight(acl, right, access)
	local fileNode = xmlLoadFile("conf/ACL.xml")
	if not fileNode then
		outputDebugString(LOG_PREFIX..": Couldn't load vanila ACL! Please use 'restoreadminacl' command or reinstall the resource", 3)
		return false
	end

	local result = false
	for i, aclNode in ipairs(xmlNodeGetChildren(fileNode)) do
		if xmlNodeGetName(aclNode) == "acl" and xmlNodeGetAttribute(aclNode, "name") == acl then
			for ir, rightNode in ipairs(xmlNodeGetChildren(aclNode)) do
				if xmlNodeGetName(rightNode) == "right" and xmlNodeGetAttribute(rightNode, "name") == right then
					result = xmlNodeSetAttribute(rightNode, "access", tostring(access == true)) 
					break
				end
			end
			break
		end
	end
	xmlSaveFile(fileNode)
	xmlUnloadFile(fileNode)

	return result
end

function aACLRemoveRight(acl, right)
	local fileNode = xmlLoadFile("conf/ACL.xml")
	if not fileNode then
		outputDebugString(LOG_PREFIX..": Couldn't load vanila ACL! Please use 'restoreadminacl' command or reinstall the resource", 3)
		return false
	end

	local result = false
	for i, aclNode in ipairs(xmlNodeGetChildren(fileNode)) do
		if xmlNodeGetName(aclNode) == "acl" and xmlNodeGetAttribute(aclNode, "name") == acl then
			for ir, rightNode in ipairs(xmlNodeGetChildren(aclNode)) do
				if xmlNodeGetName(rightNode) == "right" and xmlNodeGetAttribute(rightNode, "name") == right then
					result = xmlDestroyNode(rightNode)
					break
				end
			end
			break
		end
	end
	xmlSaveFile(fileNode)
	xmlUnloadFile(fileNode)
	
	return result
end

function aACLDestroy(acl)
	local fileNode = xmlLoadFile("conf/ACL.xml")
	if not fileNode then
		outputDebugString(LOG_PREFIX..": Couldn't load vanila ACL! Please use 'restoreadminacl' command or reinstall the resource", 3)
		return false
	end

	local result = false
	for i, aclNode in ipairs(xmlNodeGetChildren(fileNode)) do
		if xmlNodeGetName(aclNode) == "acl" and xmlNodeGetAttribute(aclNode, "name") == acl then
			result = xmlDestroyNode(aclNode)
			break
		end
	end
	xmlSaveFile(fileNode)
	xmlUnloadFile(fileNode)
	
	return result
end

function aACLGroupList()
	local groups = {}
	for i, group in ipairs(aclGroupList()) do
		if hasGroupPermissionTo(group, "general.adminpanel") then
			groups[#groups + 1] = group
		end
	end
	return groups
end

------------------------------------------

function aclIsAuto(acl)
	if string.match(aclGetName(acl), "^autoACL_") then return true end
	return false
end

function aclGroupIsAuto(group)
	if string.match(aclGroupGetName(group), "^autoGroup_") then return true end
	return false
end

function isACLInGroup(acl, group)
	for i, groupACL in ipairs(aclGroupListACL(group)) do
		if groupACL == acl then return true end
	end
	return false
end

function isACLRightExist(acl, right)
	for i, r in ipairs(aclListRights(acl)) do
		if r == right then return true end
	end
	return false
end

function hasGroupPermissionTo(group, permission)
	for i, acl in ipairs(aclGroupListACL(group)) do
		if aclGetRight(acl, permission) then return true end
	end
	return false
end

function getObjectACLName(object)
	if type(object) ~= "userdata" then return false end
	if object == console then return "user.Console" end
	if getUserdataType(object) == "resource-data" then
		return "resource."..getResourceName(object)
	else
		if not isElement(object) then return false end
		if getElementType(object) ~= "player" then return false end 
		return "user."..(getPlayerAccountName(object) or "*")
	end 
end

function getObjectACLGroups(object)
	if type(object) ~= "string" then
		object = getObjectACLName(object)
	end
	local groups = {}
	for i, group in ipairs(aclGroupList()) do
		if isObjectInACLGroup(object, group) then
			groups[#groups + 1] = group 
		end
	end
	return groups
end

function getObjectPermissions(object)
	if type(object) ~= "string" then
		object = getObjectACLName(object)
	end
	local permissions = {}
	for gi, group in ipairs(getObjectACLGroups(object)) do
		for ai, acl in ipairs(aclGroupListACL(group)) do
			local rights = aclListRights(acl, "general")
			table.iadd(rights, aclListRights(acl, "command"))
			for ri, right in ipairs(rights) do
				if aclGetRight(acl, right) then
					permissions[right] = true
				end
			end
		end
	end
	return permissions
end