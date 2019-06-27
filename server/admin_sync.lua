
addEvent(EVENT_SYNC, true)

function sync(player, ...)
    triggerClientEvent(player, EVENT_SYNC, player, ...)
end

function syncBigData(player, ...)
    triggerLatentClientEvent(player, EVENT_SYNC, 50000, player, ...)
end

function syncGlobal(permission, ...)
	for i, player in ipairs(aGetAdmins(permission)) do
		triggerClientEvent(player, EVENT_SYNC, player, ...)
	end
end

function requestSync(player, ...)
	triggerEvent(EVENT_SYNC, player, ...)
end

function requestSyncGlobal(permission, ...)
	for i, player in ipairs(aGetAdmins(permission)) do
		triggerEvent(EVENT_SYNC, player, ...)
	end
end