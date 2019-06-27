
local enabled = true
function setCustomEventsEnabled(e)
	enabled = e == true
end

local _triggerEvent = triggerEvent
local function triggerEvent(...)
	if not enabled then return false end
	return _triggerEvent(...)
end

-- SERVER
addEvent("onServerPasswordChange", false)
local _setServerPassword = setServerPassword
function setServerPassword(...)
	local result = _setServerPassword(...)
	if result then triggerEvent("onServerPasswordChange", root) end
	return result
end

addEvent("onGameTypeChange", false)
local _setGameType = setGameType
function setGameType(...)
	local result = _setGameType(...)
	if result then triggerEvent("onGameTypeChange", root) end
	return result
end

addEvent("onMapNameChange", false)
local _setMapName = setMapName
function setMapName(...)
	local result = _setMapName(...)
	if result then triggerEvent("onMapNameChange", root) end
	return result
end

addEvent("onFPSLimitChange", false)
local _setFPSLimit = setFPSLimit
function setFPSLimit(...)
	local result = _setFPSLimit(...)
	if result then triggerEvent("onFPSLimitChange", root) end
	return result
end

addEvent("onGlitchChange", false)
local _setGlitchEnabled = setGlitchEnabled
function setGlitchEnabled(glitch, ...)
	local result = _setGlitchEnabled(glitch, ...)
	if result then triggerEvent("onGlitchChange", root, glitch) end
	return result
end

-- BAN
addEvent("onBanNickChange", false)
local _setBanNick = setBanNick
function setBanNick(ban, ...)
	local result = _setBanNick(ban, ...)
	if result then triggerEvent("onBanNickChange", root, ban) end
	return result
end

addEvent("onBanReasonChange", false)
local _setBanReason = setBanReason
function setBanReason(ban, ...)
	local result = _setBanReason(ban, ...)
	if result then triggerEvent("onBanReasonChange", root, ban) end
	return result
end

-- ACL
addEvent("onAclCreate", false)
local _aclCreate = aclCreate
function aclCreate(...)
	local result = _aclCreate(...)
	if result then triggerEvent("onAclCreate", root, result) end
	return result
end

addEvent("onAclDestroy", false)
local _aclDestroy = aclDestroy
function aclDestroy(acl, ...)
	local result = _aclDestroy(acl, ...)
	if result then triggerEvent("onAclDestroy", root, acl) end
	return result
end

addEvent("onAclGroupCreate", false)
local _aclCreateGroup = aclCreateGroup
function aclCreateGroup(...)
	local result = _aclCreateGroup(...)
	if result then triggerEvent("onAclGroupCreate", root, result) end
	return result
end

addEvent("onAclGroupDestroy", false)
local _aclDestroyGroup = aclDestroyGroup
function aclDestroyGroup(group, ...)
	local result = _aclDestroyGroup(group, ...)
	if result then triggerEvent("onAclGroupDestroy", root, group) end
	return result
end

addEvent("onAclGroupACLAdd", false)
local _aclGroupAddACL = aclGroupAddACL
function aclGroupAddACL(group, acl, ...)
	local result = _aclGroupAddACL(group, acl, ...)
	if result then triggerEvent("onAclGroupACLAdd", root, group, acl) end
	return result
end

addEvent("onAclGroupACLRemove", false)
local _aclGroupRemoveACL = aclGroupRemoveACL
function aclGroupRemoveACL(group, acl, ...)
	local result = _aclGroupRemoveACL(group, acl, ...)
	if result then triggerEvent("onAclGroupACLRemove", root, group, acl) end
	return result
end

addEvent("onAclGroupObjectAdd", false)
local _aclGroupAddObject = aclGroupAddObject
function aclGroupAddObject(group, object, ...)
	local result = _aclGroupAddObject(group, object, ...)
	if result then triggerEvent("onAclGroupObjectAdd", root, group, object) end
	return result
end

addEvent("onAclGroupObjectRemove", false)
local _aclGroupRemoveObject = aclGroupRemoveObject
function aclGroupRemoveObject(group, object, ...)
	local result = _aclGroupRemoveObject(group, object, ...)
	if result then triggerEvent("onAclGroupObjectRemove", root, group, object) end
	return result
end

addEvent("onAclRightChange", false)
local _aclSetRight = aclSetRight
function aclSetRight(acl, right, ...)
	local result = _aclSetRight(acl, right, ...)
	if result then triggerEvent("onAclRightChange", root, acl, right) end
	return result
end

addEvent("onAclRightRemove", false)
local _aclRemoveRight = aclRemoveRight
function aclRemoveRight(acl, right, ...)
	local result = _aclRemoveRight(acl, right, ...)
	if result then triggerEvent("onAclRightRemove", root, acl, right) end
	return result
end

addEvent("onAclReload", false)
local _aclReload = aclReload
function aclReload()
	local result = _aclReload()
	if result then triggerEvent("onAclReload", root) end
	return result
end
