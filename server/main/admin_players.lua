
local aPlayers = {
	List = {}
}
local PERMISSION = "general.tab_players"

addEvent("onPlayerMoneyChange", false)

addEventHandler("onResourceStart", resourceRoot,
	function(resource)
		for i, player in ipairs(getElementsByType("player")) do
			aPlayers.Initialize(player)
		end
		aPlayers.StartCheckMoneyTimer()
	end
)

addEventHandler("onPlayerJoin", root,
	function()
		aPlayers.Initialize(source)
		for i, player in ipairs(aGetAdmins(PERMISSION)) do
			triggerClientEvent(
				player,
				EVENT_PLAYER_JOIN,
				source,
				getPlayerIP(source),
				getPlayerSerial(source),
				getPlayerVersion(source),
				aPlayers.List[source].country,
				aPlayers.List[source].countryname
			)
		end
		setPedGravity(source, getGravity())
	end
)

addEventHandler(EVENT_IP2C, resourceRoot,
	function()
		for player, data in pairs(aPlayers.List) do
			data.country = getPlayerCountry(player)
			data.countryname = getCountryName(data.country)
		end
		requestSyncGlobal(PERMISSION, SYNC_PLAYER, SYNC_LIST)
	end
)

addEventHandler(EVENT_SESSION, root,
	function()
		aPlayers.List[source].loaded = true
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		aPlayers.List[source] = nil
	end
)

addEventHandler("onPlayerLogin", root,
	function()
		local data = {
			account = getAccountName(getPlayerAccount(source)),
			groups = aPlayers.GetGroups(source),
		}
		syncGlobal(PERMISSION, SYNC_PLAYER, SYNC_SINGLE, source, data)
	end
)

addEventHandler("onPlayerLogout", root,
	function()
		local data = {
			account = getAccountName(getPlayerAccount(source)),
			groups = aPlayers.GetGroups(source),
		}
		syncGlobal(PERMISSION, SYNC_PLAYER, SYNC_SINGLE, source, data)
	end
)

addEventHandler("onPlayerMute", root,
	function()
		syncGlobal(PERMISSION, SYNC_PLAYER, SYNC_SINGLE, source, {mute = true})
	end
)

addEventHandler("onPlayerUnmute", root,
	function()
		syncGlobal(PERMISSION, SYNC_PLAYER, SYNC_SINGLE, source, {mute = false})
	end
)

addEventHandler("onPlayerMoneyChange", root,
	function(money)
		for i, admin in ipairs(aGetAdmins(PERMISSION)) do
			if aPlayers.List[admin].sync == source then
				sync(admin, SYNC_PLAYER, SYNC_SINGLE, source, {money = money})
			end
		end
	end
)

addEventHandler(EVENT_FPS, root,
	function(fps)
		for i, admin in ipairs(aGetAdmins(PERMISSION)) do
			if aPlayers.List[admin].sync == source then
				sync(admin, SYNC_PLAYER, SYNC_SINGLE, source, {fps = fps})
			end
		end
	end
)

function aPlayers.onAdminGroupsChangeHandler()
	syncGlobal(PERMISSION, SYNC_ADMIN_GROUP, SYNC_LIST, aPlayers.GetAdminGroups())
end

addEventHandler("onAclDestroy", root, aPlayers.onAdminGroupsChangeHandler)
addEventHandler("onAclGroupDestroy", root, aPlayers.onAdminGroupsChangeHandler)
addEventHandler("onAclGroupACLAdd", root, aPlayers.onAdminGroupsChangeHandler)
addEventHandler("onAclGroupACLRemove", root, aPlayers.onAdminGroupsChangeHandler)
addEventHandler("onAclRightChange", root, aPlayers.onAdminGroupsChangeHandler)
addEventHandler("onAclRightRemove", root, aPlayers.onAdminGroupsChangeHandler)
addEventHandler("onAclReload", root, aPlayers.onAdminGroupsChangeHandler)

function aPlayers.StartCheckMoneyTimer()
	setTimer(function()
		for player, data in pairs(aPlayers.List) do
			local money = getPlayerMoney(player)
			if money ~= data.money then
				data.money = money
				triggerEvent("onPlayerMoneyChange", player, money)
			end
		end
	end, 1500, 0)
end

function aPlayers.Initialize(player)
	local data = {}
	data.country = getPlayerCountry(player)
	data.countryname = getCountryName(data.country)
	data.money = getPlayerMoney(player)
	aPlayers.List[player] = data
end

function aPlayers.GetAdminGroups()
	local groups = {}
	for i, group in ipairs(aACLGroupList()) do
		groups[i] = aclGroupGetName(group)
	end
	return groups
end

function aPlayers.GetGroups(player)
	local groups = {}
	for i, group in ipairs(getObjectACLGroups(player)) do
		groups[i] = aclGroupGetName(group)
	end
	return groups
end

aPlayers.SyncFunctions = {
	[SYNC_PLAYER] = {
		[SYNC_SINGLE] = function(player)
			if not isElement(player) then return end
	
			aPlayers.List[source].sync = player
	
			local data = {
				account = getAccountName(getPlayerAccount(player)),
				groups = aPlayers.GetGroups(player),
				mute = isPlayerMuted(player),
				money = getPlayerMoney(player),
				fps = aGetPlayerFPS(player)
			}
	
			sync(source, SYNC_PLAYER, SYNC_SINGLE, player, data)
		end,
	
		[SYNC_LIST] = function()
			local list = {}
			for i, player in ipairs(getElementsByType("player")) do
				list[player] = {
					ip = getPlayerIP(player),
					serial = getPlayerSerial(player),
					version = getPlayerVersion(player),
					country = aPlayers.List[player].country,
					countryname = aPlayers.List[player].countryname
				}	
			end
			sync(source, SYNC_PLAYER, SYNC_LIST, list)
		end
	},

	[SYNC_ADMIN_GROUP] = {
		[SYNC_LIST] = function()
			sync(source, SYNC_ADMIN_GROUP, SYNC_LIST, aPlayers.GetAdminGroups())
		end
	}
	
}

addEventHandler(
	EVENT_SYNC,
	root,
	function(dataType, syncType, ...)
		if dataType ~= SYNC_PLAYER and dataType ~= SYNC_ADMIN_GROUP then return end
		if not hasObjectPermissionTo(source, PERMISSION) then
			outputDebugString("Access denied for '"..PERMISSION.."' (player: "..getPlayerName(source)..")", 2)
			return
		end
		aPlayers.SyncFunctions[dataType][syncType](...)
	end
)

function aIsPlayerLoaded(player)
	if not aPlayers.List[player] then return false end
	return aPlayers.List[player].loaded
end

function aSetPlayerVehicleInterior(player, interior)
	if not setElementInterior(player, interior) then return false end
	local vehicle = getPedOccupiedVehicle(player)
	if vehicle then
		for seat, occupant in pairs(getVehicleOccupants(vehicle)) do
			setElementInterior(occupant, interior)
		end
		setElementInterior(vehicle, interior)
	end
	return true
end

function aSetPlayerVehicleDimension(player, dimension)
	if not setElementDimension(player, dimension) then return false end
	local vehicle = getPedOccupiedVehicle(player)
	if vehicle then
		for seat, occupant in pairs(getVehicleOccupants(vehicle)) do
			setElementDimension(occupant, dimension)
		end
		setElementDimension(vehicle, dimension)
	end
	return true
end

function aWarpPlayerToPoint(player, x, y, z, rot, dim, int)
	local vehicle = getPedOccupiedVehicle(player)
	local isDriver = vehicle and (getVehicleOccupant(vehicle) == player)
	local element = (isDriver and vehicle) or player

	if isDriver then
		for seat, occupant in pairs(getVehicleOccupants(vehicle)) do
			setElementDimension(occupant, dim)
			setElementInterior(occupant, int)
		end
	else
		removePedFromVehicle(player)
	end

	setElementDimension(element, dim)
	setElementInterior(element, int)
	setElementPosition(element, x, y, z)
	setElementRotation(element, 0, 0, rot)

	return true
end

function aWarpPlayerToPlayer(player, toPlayer)

	local toVehicle = getPedOccupiedVehicle(toPlayer)
	local toSeat = toVehicle and getVehicleFreePassengerSeat(toVehicle)

	local vehicle = getPedOccupiedVehicle(player)
	local isDriver = vehicle and (getVehicleOccupant(vehicle) == player)

	local element = (isDriver and vehicle) or player
	local toElement = toVehicle or toPlayer
	local int, dim = getElementInterior(toElement), getElementDimension(toElement)

	if isDriver then
		for seat, occupant in pairs(getVehicleOccupants(vehicle)) do
			setElementDimension(occupant, dim)
			setElementInterior(occupant, int)
		end
	else
		removePedFromVehicle(player)
	end
	setElementDimension(element, dim)
	setElementInterior(element, int)

	if toSeat and (not isDriver) then
		return warpPedIntoVehicle(player, toVehicle, toSeat)
	end

	local offX, offY, offZ = 2, 0, 0.2
	if isDriver then
		offX, offZ = 3, 0.5
	end
	local x, y, z = getPositionFromElementOffset(toElement, offX, offY, offZ)
	local rx, ry, rz = getElementRotation(toElement)
	setElementRotation(element, rx, ry, rz)
	setElementPosition(element, x, y, z)

	--setTimer(
	--	function()
	--		setCameraTarget(player)
	--	end,
	--200, 1)


	return true
end

function aGivePlayerVehicle(player, vehicleID)
	local pvehicle = getPedOccupiedVehicle(player)
	local element = pvehicle or player

	local x, y, z = getElementPosition(element)
	local rx, ry, rz = getElementRotation(element)
	local vx, vy, vz = getElementVelocity(element)
	
	if pvehicle then
		removePedFromVehicle(player)
		z = z+2
	end

	vehicle = createVehicle(vehicleID, x, y, z, rx, ry, rz)
	setElementDimension(vehicle, getElementDimension(player))
	setElementInterior(vehicle, getElementInterior(player))
	warpPedIntoVehicle(player, vehicle)
	setElementVelocity(vehicle, vx, vy, vz)
	return vehicle
end

function aShoutPlayer(player, text)
	local textDisplay = textCreateDisplay()
	if not textDisplay then return false end
	local textItem =
		textCreateTextItem(
		"(ADMIN) "..stripColorCodes(aGetAdminNameForAll(source))..":\n\n" .. text,
		0.5, 0.5,
		2,
		aColors.orange[1],
		aColors.orange[2],
		aColors.orange[3],
		255,
		4,
		"center", "center",
		255
	)
	textDisplayAddText(textDisplay, textItem)
	textDisplayAddObserver(textDisplay, player)
	setTimer(
		function()
			textDestroyTextItem(textItem)
			textDestroyDisplay(textDisplay)
		end,
		5000, 1
	)
	return true
end

function aFlipVehicle(vehicle)
	local rx, ry, rz = getVehicleRotation(vehicle)
	if not ((rx > 110) and (rx < 250)) then return false end
	local x, y, z = getElementPosition(vehicle)
	setVehicleRotation(vehicle, rx + 180, ry, rz)
	setElementPosition(vehicle, x, y, z + 2)
	return true
end