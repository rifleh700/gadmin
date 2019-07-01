
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
		outputDebugString(LOG_PREFIX..": Couldn't load vanila ACL! Please reinstall the resource", 3)
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
		outputDebugString(LOG_PREFIX..": Couldn't find 'Default' ACL! Please reinstall the resource", 3)
		return false
	end

	local defaultACL = aclGet("Default")
	if not defaultACL then
		outputDebugString(LOG_PREFIX..": Couldn't find server 'Default' ACL! Please use 'restoreacl' command or reinstall server ACL config", 3)
		return false
	end

	local setupRights = {}
	for i, right in ipairs(adminDefaultRights) do
		if not aclRightExists(defaultACL, right) then
			setupRights[#setupRights + 1] = right
		end
	end
	if #setupRights == 0 then
		outputDebugString(LOG_PREFIX..": No ACL changes required", 3)
		return true
	end

	setCustomEventsEnabled(false)

	for aclName, aclRights in pairs(adminACLs) do
		local acl = aclGet(aclName)
		if acl then
			local updated = 0
			for i, right in ipairs(setupRights) do
				if aclRights[right] ~= nil and not aclRightExists(acl, right) then
					aclSetRight(acl, right, aclRights[right])
					updated = updated + 1
				end
			end
			if updated > 0 then
				outputDebugString(LOG_PREFIX..": Updated "..updated.." rights in ACL '"..aclName.."'", 3)
			end
		end
	end

	setCustomEventsEnabled(true)

	return true
end

function aRestoreACL()
	local fileData = getACLConfigFileData("conf/ACL.xml")
	if not fileData then
		outputDebugString(LOG_PREFIX..": Couldn't load vanila ACL! Please reinstall the resource", 3)
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
		outputDebugString(LOG_PREFIX..": Couldn't find 'Default' ACL! Please reinstall the resource", 3)
		return false
	end

	setCustomEventsEnabled(false)

	for aclName, aclRights in pairs(adminACLs) do
		local acl = aclGet(aclName) or aclCreate(aclName)
		for ir, right in ipairs(adminDefaultRights) do
			local access = aclGetRight(acl, right)
			if not aclRightExists(acl, right) then
				access = nil
			end

			if access ~= aclRights[right] then
				if aclRights[right] == nil then
					aclRemoveRight(acl, right)
				else
					aclSetRight(acl, right, aclRights[right])
				end
			end
		end
	end

	setCustomEventsEnabled(true)
	
	triggerEvent("onAclReload", root)
	outputDebugString(LOG_PREFIX..": Admin panel rights successfully restored", 3)
	
	return true
end

function aRestoreServerACL()

	local fileData = getACLConfigFileData("conf/serverACL.xml")
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
	aRestoreACL()

	outputDebugString(LOG_PREFIX..": Server ACL successfully restored", 3)
	
	return true
end

function aACLGroupList()
	local groups = {}
	for i, group in ipairs(aclGroupList()) do
		if not aclGroupIsAuto(group) and hasGroupPermissionTo(group, "general.adminpanel") then
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

function aclInGroup(acl, group)
	for i, groupACL in ipairs(aclGroupListACL(group)) do
		if groupACL == acl then return true end
	end
	return false
end

function aclRightExists(acl, right)
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