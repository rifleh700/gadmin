
local aMutes = {
	List = {}
}
local PERMISSION = "general.tab_mutes"

addEvent("onMute", false)
addEvent("onUnmute", false)
addEvent("onMuteNickChange", false)
addEvent("onMuteReasonChange", false)

addEventHandler("onResourceStart", resourceRoot,
	function()
		aMutes.Load()
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		aMutes.Save()
	end
)

addEventHandler("onPlayerJoin",root,
	function()
		local mute = aMutes.ApplyToPlayer(source)
		if not mute then return end
		aMutes.OutputAutomaticallyMutedLog(source, mute)
	end,
	true,
	"low"
)

addEventHandler("onMute", root,
	function(id)
		syncGlobal(PERMISSION, SYNC_MUTE, SYNC_ADD, id, aMutes.GetData(aMutes.GetFromID(id)))
	end
)

addEventHandler("onUnmute", root,
	function(id)
		syncGlobal(PERMISSION, SYNC_MUTE, SYNC_REMOVE, id)
	end
)

addEventHandler("onMuteNickChange", root,
	function(id)
		syncGlobal(PERMISSION, SYNC_MUTE, SYNC_SINGLE, id, {nick = aMutes.GetFromID(id).nick})
	end
)

addEventHandler("onMuteReasonChange", root,
	function(id)
		syncGlobal(PERMISSION, SYNC_MUTE, SYNC_SINGLE, id, {reason = aMutes.GetFromID(id).reason})
	end
)

aMutes.SyncFunctions = {
	[SYNC_LIST] = function()
		local list = {}
		for i, mute in ipairs(aMutes.List) do
			list[aMutes.GetID(mute)] = aMutes.GetData(mute)
		end
		sync(source, SYNC_MUTE, SYNC_LIST, list)
	end,
	[SYNC_SINGLE] = function(id)
		local mute = aMutes.GetFromID(id)
		if not mute then return end
		sync(source, SYNC_MUTE, SYNC_SINGLE, id, aMutes.GetData(mute))
	end,
}
addEventHandler(
	EVENT_SYNC,
	root,
	function(dataType, syncType, ...)
		if dataType ~= SYNC_MUTE then return end
		if not hasObjectPermissionTo(source, PERMISSION) then
			outputDebugString("Access denied for '"..PERMISSION.."' (player: "..getPlayerName(source)..")", 2)
			return
		end
		aMutes.SyncFunctions[syncType](...)
	end
)

function aMutes.Load()
	aMutes.List = {}

	local fileNode = xmlLoadFile("data/mutelist.xml")
	if not fileNode then return end

	for i, subnode in ipairs(xmlNodeGetChildren(fileNode)) do
		if xmlNodeGetName(subnode) == "mute" then

			local serialNode = xmlFindChild(subnode, "serial", 0)
			if serialNode then

				local serial = xmlNodeGetValue(serialNode)
				if serial and isValidSerial(serial) then

					local mute = {}

					local nickNode = xmlFindChild(subnode, "nick", 0)
					mute.nick = nickNode and xmlNodeGetValue(nickNode) or nil
			
					mute.serial = serial

					local adminNode = xmlFindChild(subnode, "admin", 0)
					mute.admin = adminNode and xmlNodeGetValue(adminNode) or nil
	
					local reasonNode = xmlFindChild(subnode, "reason", 0)
					mute.reason = reasonNode and xmlNodeGetValue(reasonNode) or nil
	
					local timeNode = xmlFindChild(subnode, "time", 0)
					mute.time = timeNode and tonumber(xmlNodeGetValue(timeNode)) or 0

					local unmuteNode = xmlFindChild(subnode, "unmute", 0)
					mute.unmute = unmuteNode and tonumber(xmlNodeGetValue(unmuteNode)) or 0

					aMutes.Add(mute)
					aMutes.Accept(mute)
					aMutes.CreateTimer(mute)

				end
			end
		end
	end
	xmlUnloadFile(fileNode)
end

function aMutes.Save()
	local fileNode = xmlLoadFile ( "data/mutelist.xml" )
	if not fileNode then fileNode = xmlCreateFile ( "data/mutelist.xml", "mutelist" ) end
	
	while xmlFindChild(fileNode, "mute", 0) ~= false do
		xmlDestroyNode(xmlFindChild(fileNode, "mute", 0))
	end

	for i, mute in ipairs(aMutes.List) do
		local subnode = xmlCreateChild(fileNode, "mute")
		xmlNodeSetValue(xmlCreateChild(subnode, "serial"), mute.serial)
		if mute.nick then xmlNodeSetValue(xmlCreateChild(subnode, "nick"), mute.nick) end
		if mute.admin then xmlNodeSetValue(xmlCreateChild(subnode, "admin"), mute.admin) end
		if mute.reason then xmlNodeSetValue(xmlCreateChild(subnode, "reason"), mute.reason) end
		xmlNodeSetValue(xmlCreateChild(subnode, "time"), mute.time)
		xmlNodeSetValue(xmlCreateChild(subnode, "unmute"), mute.unmute)
	end
	xmlSaveFile(fileNode)
	xmlUnloadFile(fileNode)
end

function aMutes.Exists(mute)
	for i, m in ipairs(aMutes.List) do
		if m == mute then return true end
	end
	return false
end

function aMutes.GetID(mute)
	return string.match(tostring(mute), "%x+$")
end

function aMutes.GetFromID(id)
	for i, mute in ipairs(aMutes.List) do
		if aMutes.GetID(mute) == id then return mute end
	end
	return nil
end

function aMutes.GetData(mute)
	return {
		serial = mute.serial,
		nick = mute.nick,
		admin = mute.admin,
		reason = mute.reason,
		time = mute.time,
		unmute = mute.unmute,
		--seconds = aMutes.GetSeconds(mute)
	}
end

function aMutes.GetSeconds(mute)
	if not mute.unmute then return 0 end
	if not mute.time then return 0 end
	if mute.unmute == 0 then return 0 end
	if mute.unmute < mute.time then return 0 end
	return mute.unmute - mute.time
end

function aMutes.Add(data)
	return table.insert(aMutes.List, data)
end

function aMutes.Remove(mute)
	return table.vremove(aMutes.List, mute)
end

function aMutes.GetBySerial(serial)
	for i, mute in ipairs(aMutes.List) do
		if mute.serial == serial then return mute end
	end
	return nil
end

function aMutes.ApplyToPlayer(source)
	local mute = aMutes.GetBySerial(getPlayerSerial(source))
	if not mute then return false end

	setPlayerMuted(source, true)
	return mute
end

function aMutes.Accept(mute)
	local player = getPlayerBySerial(mute.serial)
	if not player then return false end

	setPlayerMuted(player, true)
	return player
end

function aMutes.Cancel(mute)
	local player = getPlayerBySerial(mute.serial)
	if not player then return false end

	setPlayerMuted(player, false)
	return player
end

function aMutes.Create(serial, nick, admin, reason, seconds)
	if not admin then admin = root end
	if admin == console then admin = root end
	if not seconds then seconds = 0 end

	local mute = {}
	mute.serial = serial
	mute.nick = nick
	mute.admin = getAdminAccountName(admin)
	mute.reason = reason
	mute.time = getRealTime().timestamp
	if seconds == 0 then
		mute.unmute = 0
	else
		mute.unmute = mute.time + math.floor(seconds)
	end

	aMutes.Add(mute)
	aMutes.Accept(mute)
	aMutes.CreateTimer(mute)

	triggerEvent("onMute", root, aMutes.GetID(mute))

	return mute
end

function aMutes.Destroy(mute)
	aMutes.DestroyTimer(mute)
	aMutes.Cancel(mute)
	aMutes.Remove(mute)

	triggerEvent("onUnmute", root, aMutes.GetID(mute))
	
	return true
end

function aMutes.CreateTimer(mute)
	if mute.unmute == 0 then return nil end

	local interval = mute.unmute - getRealTime().timestamp
	if interval <= 0 then interval = 1 end

	mute.timer = setTimer(
		function()
			if not aMutes.Exists(mute) then return end

			aMutes.Destroy(mute)
			local player = getPlayerBySerial(mute.serial)
			if player then
				aMutes.OutputAutomaticallyUnmutedLog(player, mute)
			end
		end,
	interval * 1000, 1)

	return mute.timer
end

function aMutes.DestroyTimer(mute)
	if not mute.timer then return end
	if isTimer(mute.timer) then
		killTimer(mute.timer)
	end
	mute.timer = nil
end

function aMutes.OutputAutomaticallyMutedLog(player, mute)
	local info = "("..formatDuration(aMutes.GetSeconds(mute))..")"
	if mute.reason then
		info = info.." ("..mute.reason..")"
	end
	outputChatBox("* "..stripColorCodes(getPlayerName(player)).." has been muted automatically "..info, root, unpack(aColors.red))
	outputServerLog(LOG_PREFIX..": "..getPlayerName(player).." has been muted automatically "..info)
end

function aMutes.OutputAutomaticallyUnmutedLog(player, mute)
	local info = "("..formatDuration(aMutes.GetSeconds(mute))..")"
	if mute.reason then
		info = info.." ("..mute.reason..")"
	end
	outputChatBox("* "..stripColorCodes(getPlayerName(player)).." has been unmuted "..info.." automatically", root, unpack(aColors.green))
	outputServerLog(LOG_PREFIX..": "..getPlayerName(player).." has been unmuted "..info.." automatically")
end

function aMutePlayer(player, admin, reason, seconds)
	if not isElement(player) then return false end
	if isPlayerMuted(player) then return false end
	return aAddMute(getPlayerSerial(player), getPlayerName(player), admin, reason, seconds)
end

function aUnmutePlayer(player, admin)
	if not isElement(player) then return false end
	if not isPlayerMuted(player) then return false end

	local id = aGetPlayerMute(player)
	if not id then return setPlayerMuted(player, false) end

	return aRemoveMute(id, admin)
end

function aAddMute(serial, nick, admin, reason, seconds)
	if not isValidSerial(serial) then return false end

	if seconds and seconds < 0 then return false end

	if admin then
		if not isElement(admin) then return false end
		if admin ~= root and admin ~= console and getElementType(admin) ~= "player" then return false end
	end

	if aMutes.GetBySerial(serial) then return false end

	return aMutes.GetID(aMutes.Create(serial, nick, admin, reason, seconds))
end

function aRemoveMute(id, admin)
	local mute = aMutes.GetFromID(id)
	if not mute then return false end

	if admin then
		if not isElement(admin) then return false end
		if admin ~= root and admin ~= console and getElementType(admin) ~= "player" then return false end
	end

	return aMutes.Destroy(mute)
end

function aGetMuteBySerial(serial)
	local mute = aMutes.GetBySerial(serial)
	if not mute then return nil end
	return aMutes.GetID(mute)
end

function aGetPlayerMute(player)
	return aGetMuteBySerial(getPlayerSerial(player))
end

function aGetMuteData(id)
	local mute = aMutes.GetFromID(id)
	if not mute then return false end
	return aMutes.GetData(mute)
end

function aGetMuteNick(id)
	local mute = aMutes.GetFromID(id)
	if not mute then return false end
	return mute.nick
end

function aGetMuteReason(id)
	local mute = aMutes.GetFromID(id)
	if not mute then return false end
	return mute.reason
end

function aGetMuteSeconds(id)
	local mute = aMutes.GetFromID(id)
	if not mute then return false end
	return aMutes.GetSeconds(mute)
end

function aSetMuteNick(id, nick)
	local mute = aMutes.GetFromID(id)
	if not mute then return false end
	mute.nick = nick
	triggerEvent("onMuteNickChange", root, id)
	return true
end

function aSetMuteReason(id, reason)
	local mute = aMutes.GetFromID(id)
	if not mute then return false end
	mute.reason = reason
	triggerEvent("onMuteReasonChange", root, id)
	return true
end