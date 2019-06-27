
local aChat = {}
local PERMISSION = "general.tab_adminchat"

aChat.SyncFunctions = {
	[SYNC_LIST] = function()
		sync(source, SYNC_CHAT, SYNC_LIST, aGetAdmins(PERMISSION))
	end
}
addEventHandler(EVENT_SYNC, root,
	function(dataType, syncType, ...)
		if dataType ~= SYNC_CHAT then return end
		if not hasObjectPermissionTo(source, PERMISSION) then
			outputDebugString("Access denied for '"..PERMISSION.."' (player: "..getPlayerName(source)..")", 2)
			return
		end
		aChat.SyncFunctions[syncType](...)
	end
)

addEventHandler(EVENT_SESSION_UPDATE, root,
	function(isAdmin)
		requestSyncGlobal(PERMISSION, SYNC_CHAT, SYNC_LIST)
	end
)

function aOutputAdminChat(player, message)
	if player == console then player = root end
	local timestamp = getRealTime().timestamp
	for i, admin in ipairs(aGetAdmins(PERMISSION)) do
		triggerClientEvent(admin, EVENT_ADMIN_CHAT, player, message, timestamp)
	end
	return true
end