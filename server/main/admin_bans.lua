
local aBans = {}
local PERMISSION = "general.tab_bans"

addEventHandler("onBan", root,
	function(ban)
		syncGlobal(PERMISSION, SYNC_BAN, SYNC_ADD, aBans.GetID(ban), aBans.GetData(ban))
	end
)

addEventHandler("onUnban", root,
	function(ban)
		syncGlobal(PERMISSION, SYNC_BAN, SYNC_REMOVE, aBans.GetID(ban))
	end
)

addEventHandler("onBanNickChange", root,
	function(ban)
		syncGlobal(PERMISSION, SYNC_BAN, SYNC_SINGLE, aBans.GetID(ban), {nick = getBanNick(ban)})
	end
)

addEventHandler("onBanReasonChange", root,
	function(ban)
		syncGlobal(PERMISSION, SYNC_BAN, SYNC_SINGLE, aBans.GetID(ban), {reason = getBanReason(ban)})
	end
)

function aBans.GetID(ban)
	return string.match(tostring(ban), "%x+$")
end

function aBans.GetFromID(id)
	for i, ban in ipairs(getBans()) do
		if aBans.GetID(ban) == id then return ban end
	end
	return nil
end

function aBans.GetData(ban)
	data = {}
	data.nick = getBanNick(ban) or nil
	data.ip = getBanIP(ban) or nil
	data.serial = getBanSerial(ban) or nil
	data.admin = getBanAdmin(ban) or nil
	data.reason = getBanReason(ban) or nil
	data.time = getBanTime(ban) or nil
	data.unban = getUnbanTime(ban) or nil
	return data
end

aBans.SyncFunctions = {
	[SYNC_LIST] = function()
		local data = {}
		for i, ban in ipairs(getBans()) do
			data[aBans.GetID(ban)] = aBans.GetData(ban)
		end
		sync(source, SYNC_BAN, SYNC_LIST, data)
	end,
	[SYNC_SINGLE] = function(id)
		local ban = aBans.GetFromID(id)
		if not ban then return end
		sync(source, SYNC_BAN, SYNC_SINGLE, id, aBans.GetData(ban))
	end,
}
addEventHandler(
	EVENT_SYNC,
	root,
	function(dataType, syncType, ...)
		if dataType ~= SYNC_BAN then return end
		if not hasObjectPermissionTo(source, PERMISSION) then
			outputDebugString("Access denied for '"..PERMISSION.."' (player: "..getPlayerName(source)..")", 2)
			return
		end
		aBans.SyncFunctions[syncType](...)
	end
)

function getBanBySerial(serial)
	for i, ban in ipairs(getBans()) do
		if getBanSerial(ban) == serial then return ban end
	end
	return nil
end

function getBanByIP(ip)
	for i, ban in ipairs(getBans()) do
		if getBanIP(ban) == ip then return ban end
	end
	return nil
end

function getBan(serialIP)
	for i, ban in ipairs(getBans()) do
		if getBanIP(ban) == serialIP then return ban end
		if getBanSerial(ban) == serialIP then return ban end
	end
	return nil
end

function getBanSeconds(ban)
	local time = getBanTime(ban)
	local unban = getUnbanTime(ban)
	if (not unban) or (not time) or (unban <= time) then return 0 end
	return unban - time
end