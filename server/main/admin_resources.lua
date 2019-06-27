
local aResources = {}
local PERMISSION = "general.tab_resources"

addEventHandler("onResourceStart", root,
	function(tresource)
		if source == resourceRoot then return end
		for i, admin in ipairs(aGetAdmins(PERMISSION)) do
			triggerClientEvent(admin, EVENT_RESOURCE_START, root, getResourceName(tresource))
		end
	end
)

addEventHandler("onResourceStop", root,
	function(tresource)
		if source == resourceRoot then return end
		for i, player in ipairs(aGetAdmins(PERMISSION)) do
			triggerClientEvent(player, EVENT_RESOURCE_STOP, root, getResourceName(tresource))
		end
	end
)

addEventHandler("onSettingChange", root,
	function(setting, oldValue, newValue)
		requestSyncGlobal(PERMISSION, SYNC_RESOURCE, SYNC_SINGLE, getResourceNameFromSetting(setting))
	end
)

aResources.SyncFunctions = {
	[SYNC_SINGLE] = function(name)
		local tresource = getResourceFromName(name)
		if not tresource then return end
		sync(source, SYNC_RESOURCE, SYNC_SINGLE, name, getResourceData(tresource))
	end,

	[SYNC_LIST] = function()
		local list = {}
		for i, tresource in ipairs(getResources()) do
			local group = getResourceInfo(tresource, "type") or "misc"
			local data = {
				name = getResourceName(tresource),
				state = getResourceState(tresource)
			}
			if not list[group] then
				list[group] = {}
			end
			list[group][#list[group] + 1] = data
		end
		sync(source, SYNC_RESOURCE, SYNC_LIST, list)
	end,
}
addEventHandler(EVENT_SYNC, root,
	function(dataType, syncType, ...)
		if dataType ~= SYNC_RESOURCE then return end
		if not hasObjectPermissionTo(source, PERMISSION) then
			outputDebugString("Access denied for '"..PERMISSION.."' (player: "..getPlayerName(source)..")", 2)
			return
		end
		aResources.SyncFunctions[syncType](...)
	end
)

function getResourceData(tresource)
	data = {}
	data.name = getResourceInfo(tresource, "name") or nil
	data.type = getResourceInfo(tresource, "type") or nil
	data.author = getResourceInfo(tresource, "author") or nil
	data.version = getResourceInfo(tresource, "version") or nil
	data.description = getResourceInfo(tresource, "description") or nil
	data.settings = getResourceSettings(getResourceName(tresource), false)
	return data
end

function getResourceSettings(resourceName)
	local rawsettings = get(resourceName..".")
	if not rawsettings then return {} end

	local allowedAccess = {["*"] = true, ["#"] = true, ["@"] = true}
	local allowedTypes = {["boolean"] = true, ["number"] = true, ["string"] = true, ["table"] = true}
	
	local settings = {}
	for rawname, value in pairs(rawsettings) do
		local access = string.sub(rawname, 1, 1)
		if allowedTypes[type(value)] and allowedAccess[access] then
			local temp = string.gsub(rawname, "[%*%#%@](.*)", "%1")
			local name = string.gsub(temp, resourceName.."%.(.*)", "%1")
			local bIsDefault = (temp == name)
			if not settings[name] then
				settings[name] = {}
			end
			if bIsDefault then
				settings[name].default = value
			else
				settings[name].current = value
			end
		end
	end

	local data = {}
	for name, value in pairs(settings) do
		if value.default then
			data[name] = {}
			data[name].default = value.default
			data[name].current = value.current or value.default
			data[name].friendlyname = get(resourceName.."."..name..".friendlyname")
			data[name].group = get(resourceName.."."..name..".group")
			data[name].accept = get(resourceName.."."..name..".accept")
			data[name].examples = get(resourceName.."."..name..".examples")
			data[name].desc = get(resourceName.."."..name..".desc")
		end
	end
	return data
end

function getResourceNameFromSetting(setting)
	return string.match(setting, "^[%*%#%@]?(.+)%..+")
end