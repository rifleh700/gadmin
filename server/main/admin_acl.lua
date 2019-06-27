
local aACL = {}
local PERMISSION = "general.tab_acl"

addEventHandler("onAclCreate", root,
	function(acl)
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_LIST, ACL_ACL)
	end
)

addEventHandler("onAclDestroy", root,
	function(acl)
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_LIST, ACL_ACL)
	end
)

addEventHandler("onAclGroupCreate", root,
	function(group)
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_LIST, ACL_GROUP)
	end
)

addEventHandler("onAclGroupDestroy", root,
	function(group)
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_LIST, ACL_GROUP)
	end
)

addEventHandler("onAclGroupACLAdd", root,
	function(group)
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_SINGLE, ACL_GROUP, aclGroupGetName(group))
	end
)

addEventHandler("onAclGroupACLRemove", root,
	function(group)
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_SINGLE, ACL_GROUP, aclGroupGetName(group))
	end
)

addEventHandler("onAclGroupObjectAdd", root,
	function(group)
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_SINGLE, ACL_GROUP, aclGroupGetName(group))
	end
)

addEventHandler("onAclGroupObjectRemove", root,
	function(group)
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_SINGLE, ACL_GROUP, aclGroupGetName(group))
	end
)

addEventHandler("onAclRightChange", root,
	function(acl)
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_SINGLE, ACL_ACL, aclGetName(acl))
	end
)

addEventHandler("onAclRightRemove", root,
	function(acl)
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_SINGLE, ACL_ACL, aclGetName(acl))
	end
)

addEventHandler("onAclReload", root,
	function()
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_LIST, ACL_ACL)
		requestSyncGlobal(PERMISSION, SYNC_ACL, SYNC_LIST, ACL_GROUP)
	end
)

aACL.SyncFunctions = {
	[SYNC_LIST] = {
		[ACL_GROUP] = function()
			local groups = {}
			for i, group in ipairs(aclGroupList()) do
				if not aclGroupIsAuto(group) then
					groups[#groups + 1] = aclGroupGetName(group)
				end
			end
			sync(source, SYNC_ACL, SYNC_LIST, ACL_GROUP, groups)
		end,
		[ACL_ACL] = function()
			local acls = {}
			for i, acl in ipairs(aclList()) do
				if not aclIsAuto(acl) then
					acls[#acls + 1] = aclGetName(acl)
				end
			end
			sync(source, SYNC_ACL, SYNC_LIST, ACL_ACL, acls)
		end,
	},
	[SYNC_SINGLE] = {
		[ACL_GROUP] = function(groupName)
			local group = aclGetGroup(groupName)
			local data = {}
			data.acls = {}
			for i, acl in ipairs(aclGroupListACL(group)) do
				if not aclIsAuto(acl) then
					data.acls[#data.acls + 1] = aclGetName(acl)
				end
			end
			data.objects = {}
			for i, object in ipairs(aclGroupListObjects(group)) do
				data.objects[#data.objects + 1] = object
			end
			sync(source, SYNC_ACL, SYNC_SINGLE, ACL_GROUP, groupName, data)
		end,
		[ACL_ACL] = function(aclName)
			local acl = aclGet(aclName)
			local data = {}
			for i, right in ipairs(aclListRights(acl)) do
				data[#data + 1] = {
					name = right,
					access = aclGetRight(acl, right)
				}
			end
			sync(source, SYNC_ACL, SYNC_SINGLE, ACL_ACL, aclName, data)
		end,
	}
}

addEventHandler(EVENT_SYNC, root,
	function(dataType, syncType, aclType, ...)
		if dataType ~= SYNC_ACL then return end
		if not hasObjectPermissionTo(source, PERMISSION) then
			outputDebugString("Access denied for '"..PERMISSION.."' (player: "..getPlayerName(source)..")", 2)
			return
		end
		aACL.SyncFunctions[syncType][aclType](...)
	end
)