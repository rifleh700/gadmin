
aFunctions = {
	-- PLAYER
	["mute"] = function(player, seconds, reason)
		if isPlayerMuted(player) then return false, "player is already muted" end
		if not aMutePlayer(player, source, reason, seconds) then return false end
		local serial = getPlayerSerial(player)

		local info = "("..formatDuration(seconds or 0)..")"
		if reason then
			info = info.." ("..reason..")"
		end
		return true, pack(serial, info)
	end,

	["unmute"] = function(player)
		if not isPlayerMuted(player) then return false, "player is already unmuted" end

		local serial = getPlayerSerial(player)
		local reason = nil
		local seconds = nil
		local id = aGetPlayerMute(player)
		if id then
			local data = aGetMuteData(id)
			reason = data.reason
			seconds = aGetMuteSeconds(id)
		end

		if not aUnmutePlayer(player, source) then return false end

		local info = "("..formatDuration(seconds or 0)..")"
		if reason then
			info = info.." ("..reason..")"
		end
		return true, pack(serial, info)
	end,

	["freeze"] = function(player)
		if isElementFrozen(player) then return false, "player is already frozen" end
		if not setElementFrozen(player, true) then return false end
		local vehicle = getPedOccupiedVehicle(player)
		if vehicle then
			setElementFrozen(vehicle, true)
		end
		return true
	end,

	["unfreeze"] = function(player)
		if not isElementFrozen(player) then return false, "player is already unfrozen" end
		if not setElementFrozen(player, false) then return false end
		local vehicle = getPedOccupiedVehicle(player)
		if vehicle then
			setElementFrozen(vehicle, false)
		end
		return true
	end,

	["shout"] = function(player, text)
		if not aShoutPlayer(player, text) then return false end
		return true, pack(text)
	end,

	["slap"] = function(player, slap)
		if isPedDead(player) or getElementHealth(player) == 0 then return false, "player is dead" end
		if slap < 0 then return false end
		if slap > getElementHealth(player) then
			if not killPed(player) then return false end
		else
			if not setElementHealth(player, getElementHealth(player) - slap) then return false end
			local x, y, z = getElementVelocity(player)
			setElementVelocity(player, x, y, z + 0.2)
		end
		return true, pack(slap)
	end,

	["setadmingroup"] = function(player, groupName)
		local account = getPlayerAccount(player)
		if isGuestAccount(account) then return false, "player is not logged in" end

		local newGroup = aclGetGroup(groupName)
		if not newGroup then return false, "group doesn't exist" end
		if not hasGroupPermissionTo(newGroup, "general.adminpanel") then return false, "group doesn't have admin panel permission" end

		local accountName = getAccountName(account)
		local object = "user."..accountName
		if isObjectInACLGroup(object, newGroup) then return false, "player is already in '"..groupName.."' ACL group" end

		for i, group in ipairs(aACLGroupList()) do
			if isObjectInACLGroup(object, group) then
				aclGroupRemoveObject(group, object)
			end
		end
		
		if not aclGroupAddObject(newGroup, object) then return false end
		return true, pack(accountName, groupName)
	end,

	["resetadmingroup"] = function(player)
		local account = getPlayerAccount(player)
		if isGuestAccount(account) then return false, "player is not logged in" end

		local accountName = getAccountName(account)
		local object = "user."..accountName

		local removed = {}
		for i, group in ipairs(aACLGroupList()) do
			if isObjectInACLGroup(object, group) then
				aclGroupRemoveObject(group, object)
				table.insert(removed, aclGroupGetName(group))
			end
		end
		if not removed then return false, "player doesn't have admin rights" end
		return true, pack(accountName, table.concat(removed, ", "))
	end,

	["sethealth"] = function(player, health)
		if isPedDead(player) or getElementHealth(player) == 0 then return false, "player is dead" end
		health = math.clamp(health, 0, 200)
		if not setElementHealth(player, health) then return false end
		return true, pack(health)
	end,

	["setarmour"] = function(player, armour)
		armour = math.clamp(armour, 0, 200)
		if not setPedArmor(player, armour) then return false end
		return true, pack(armour)
	end,

	["setmoney"] = function(player, money)
		if not setPlayerMoney(player, money) then return false end
		return true, pack(money)
	end,

	["setskin"] = function(player, skin, walking)
		if skin < 0 or skin > 312 then return false, "skin must be 0-312" end
		if getElementModel(player) == skin then return false, "player skin is already "..skin end
		if not setElementModel(player, skin) then return false end
		if walking then setPedWalkingStyle(player, getModelWalkingStyle(getElementModel(player))) end
		return true, pack(formatIDName(skin, aSkins[skin]))
	end,

	["setfighting"] = function(player, style)
		if (style < 4 or style > 7) and style ~= 15 and style ~= 16 then return false, "fighting style must be 4-7, 15 or 16" end
		if getPedFightingStyle(player) == style then return false, "player fighting style is already "..style end
		if not setPedFightingStyle(player, style) then return false end
		return true, pack(formatIDName(style, aFightingStyles[style]))
	end,

	["setwalking"] = function(player, style)
		if not (style == 0 or (style >= 54 and style <= 70) or (style >= 118 or style <= 138)) then
			return false, "walking style must be 0, 54-70 or 118-138"
		end
		if getPedWalkingStyle(player) == style then return false, "player fighting style is already "..style end
		if not setPedWalkingStyle(player, style) then return false end
		return true, pack(formatIDName(style, aWalkingStyles[style]))
	end,

	["setstat"] = function(player, stat, value)
		if not (stat >= 69 and stat <= 79 or stat >= 21 and stat <= 24) then return false, "stat ID must be 21-24 or 69-79" end
		value = math.clamp(value, 0, 1000)
		if (stat == 21 or stat == 23) and getElementModel(player) ~= 0 then return false, "stats 21 and 23 can only be used on the CJ skin" end 
		if not setPedStat(player, stat, value) then return false end
		return true, pack(aStats[stat], value)
	end,

	["setnick"] = function(player, name)
		local oldName = getPlayerName(player)
		if oldName == name then return false, "player already has nick '"..name.."'" end
		if not setPlayerName(player, name) then return false end
		return true, pack(oldName, name)
	end,

	["setteam"] = function(player, team)
		if getPlayerTeam(player) == team then return false, "player team is already '"..getTeamName(team).."'" end
		if not setPlayerTeam(player, team) then return false end
		return true, pack(getTeamName(team))
	end,

	["removefromteam"] = function(player)
		local team = getPlayerTeam(player) 
		if not team then return false, "player is already removed from team" end
		if not setPlayerTeam(player, nil) then return false end
		return true, pack(getTeamName(team))
	end,

	["givejetpack"] = function(player)
		if doesPedHaveJetPack(player) then return false, "player already has jetpack" end
		if getPedOccupiedVehicle(player) then return false, "player has a vehicle" end
		return givePedJetPack(player)
	end,

	["removejetpack"] = function(player)
		if not doesPedHaveJetPack(player) then return false, "player doesn't have jetpack" end
		return removePedJetPack(player)
	end,

	["givevehicle"] = function(player, vehicleID)
		if not aGivePlayerVehicle(player, vehicleID) then return false end
		return true, pack(getVehicleNameFromModel(vehicleID))
	end,

	["giveweapon"] = function(player, weapon, ammo)
		if not giveWeapon(player, weapon, ammo, true) then return false end
		return true, pack(getWeaponNameFromID(weapon), ammo)
	end,

	["takeweapon"] = function(player, weapon)
		if not takeWeapon(player, weapon) then return false end
		return true, pack(getWeaponNameFromID(weapon))
	end,

	["takeallweapon"] = function(player)
		return takeAllWeapons(player)
	end,

	["getscreen"] = function(player)
		return aGetPlayerScreen(source, player)
	end,

	["warp"] = function(player, toPlayer)
		if not aWarpPlayerToPlayer(player, toPlayer) then return false end
		return true, pack(getPlayerName(toPlayer))
	end,

	["warptointerior"] = function(player, name)
		local interior = aInteriors[name]
		if not interior then return false end
		local x, y, z = interior.x or 0, interior.y or 0, interior.z or 0
		local rot = interior.rot or 0
		local int = interior.interior or 0
		if not aWarpPlayerToPoint(player, x, y, z, rot, 0, int) then return false end
		return true, pack(name)
	end,

	["setinterior"] = function(player, interior)
		if interior < 0 or interior > 255 then return false, "interior must be between 0 and 255" end
		if getElementInterior(player) == interior then return false, "player interior is already "..interior end
		if not aSetPlayerVehicleInterior(player, interior) then return false end
		return true, pack(interior)
	end,

	["setdimension"] = function(player, dimension)
		if dimension < 0 or dimension > 65535 then return false, "dimension must be between 0 and 65535" end
		if getElementDimension(player) == dimension then return false, "player dimension is already "..dimension end
		if not aSetPlayerVehicleDimension(player, dimension) then return false end
		return true, pack(dimension)
	end,

	-- TEAM
	["createteam"] = function(name, r, g, b)
		if not createTeam(name, r, g, b) then return false end
		return true, pack(name)
	end,

	["destroyteam"] = function(team)
		if getElementType(team) ~= "team" then return false end
		local name = getTeamName(team)
		if not destroyElement(team) then return false end
		return true, pack(name)
	end,

	-- VEHICLE
	["repair"] = function(player)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		if not fixVehicle(vehicle) then return false end
		aFlipVehicle(vehicle)
		return true
	end,

	["addupgrades"] = function(player, upgrades)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		for i, upgrade in ipairs(upgrades) do
			if upgrade < 1000 or upgrade > 1193 then return false, "upgrade ID must be between 1000 and 1193" end
		end
		local added = {}
		local addedNames = {}
		for i, upgrade in ipairs(upgrades) do
			local add = addVehicleUpgrade(vehicle, upgrade)
			if add then
				table.insert(added, upgrade)
				table.insert(addedNames, aUpgrades[upgrade])
			end
		end
		if #added == 0 then return false, "incompatible upgrades" end
		return true, pack(table.concat(added, ", "), table.concat(addedNames, ", "))
	end,

	["removeupgrades"] = function(player, upgrades)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		if not upgrades then
			upgrades = getVehicleUpgrades(vehicle)
			if #upgrades == 0 then return false, "vehicle doesn't have upgrades" end
		end
		for i, upgrade in ipairs(upgrades) do
			if upgrade < 1000 or upgrade > 1193 then return false, "upgrade ID must be between 1000 and 1193" end
		end
		local removed = {}
		local removedNames = {}
		for i, upgrade in ipairs(upgrades) do
			local remove = removeVehicleUpgrade(vehicle, upgrade)
			if remove then
				table.insert(removed, upgrade)
				table.insert(removedNames, aUpgrades[upgrade])
			end
		end
		if #removed == 0 then return false, "vehicle doesn't have these upgrades" end
		return true, pack(table.concat(removed, ", "), table.concat(removedNames, ", "))
	end,

	["setpaintjob"] = function(player, id)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		if id < 0 or id > 3 then return false, "paint job ID must be between 0 and 3" end
		if getVehiclePaintjob(vehicle) == id then return false, "player's vehicle paintjob is already "..id end
		if not setVehiclePaintjob(vehicle, id) then return false end
		if id == 3 then id = "None" end
		return true, pack(id)
	end,

	["setcolor"] = function(player, number, r, g, b)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		if number < 1 or number > 4 then return false, "color number must be between 1 and 4" end
		if not setVehicleOneColor(vehicle, number, r, g, b) then return false end
		return true, pack(number, "("..r..", "..g..", "..b..")")
	end,

	["setlightcolor"] = function(player, r, g, b)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		if not setVehicleHeadLightColor(vehicle, r, g, b) then return false end
		return true, pack("("..r..", "..g..", "..b..")")
	end,

	["blowvehicle"] = function(player)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		if isVehicleBlown(vehicle) then return false, "vehicle is already blown" end
		return blowVehicle(vehicle)
	end,

	["destroyvehicle"] = function(player)
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return false, "player doesn't have vehicle" end
		return destroyElement(vehicle)
	end,

	["eject"] = function(player)
		if not getPedOccupiedVehicle(player) then return false, "player doesn't have vehicle" end
		if not removePedFromVehicle(player) then return false end
		local x, y, z = getElementPosition(player)
		setElementPosition(player, x, y, z + 2)
		return true
	end,

	-- RESOURCE
	["start"] = function(resourceName)
		local resource = getResourceFromName(resourceName)
		if not resource then return false, "resource "..resourceName.." does not exist" end
		if getResourceState(resource) == "running" then return false, "resource "..resourceName.." is already running" end
		if not startResource(resource, true) then return false end
		return true, pack(resourceName)
	end,

	["restart"] = function(resourceName)
		local resource = getResourceFromName(resourceName)
		if not resource then return false, "resource "..resourceName.." does not exist" end
		if getResourceState(resource) ~= "running" then return false, "resource "..resourceName.." is not running" end
		if not restartResource(resource) then return false end
		return true, pack(resourceName)
	end,

	["stop"] = function(resourceName)
		local resource = getResourceFromName(resourceName)
		if not resource then return false, "resource "..resourceName.." does not exist" end
		if getResourceState(resource) ~= "running" then return false, "resource "..resourceName.." is not running" end
		if not stopResource(resource) then return false end
		return true, pack(resourceName)
	end,

	["setsetting"] = function(resourceName, setting, value)
		local resource = getResourceFromName(resourceName)
		if not resource then return false, "resource "..resourceName.." does not exist" end
		if not (setting and value) then return false end
		if not set("*"..resourceName..".".. setting, value) then return false end
		return true, pack(resourceName, setting, tostring(value))
	end,

	-- SERVER
	["setpassword"] = function(password)
		if password == "" then return false, "1 character min" end
		if string.len(password) > 32 then return false, "32 characters max" end
		if not setServerPassword(password) then return false end
		return true, pack(password)
	end,

	["resetpassword"] = function()
		if not setServerPassword(nil) then return false end
		return true
	end,

	["setgametype"] = function(gameType)
		if not setGameType(gameType) then return false end
		return true, pack(gameType)
	end,

	["setmapname"] = function(mapName)
		if not setMapName(mapName) then return false end
		return true, pack(mapName)
	end,

	["setfpslimit"] = function(limit)
		if not limit then limit = 36 end
		if (limit < 25 or limit > 100) and limit ~= 0 then return false, "limit must be 0 or between 25 and 100" end
		if not setFPSLimit(limit) then return false end
		return true, pack(limit)
	end,

	["setglitch"] = function(glitch, enabled)
		if isGlitchEnabled(glitch) == enabled then return false, "glitch is already "..(enabled and "enabled" or "disabled") end
		if not setGlitchEnabled(glitch, enabled) then return false end
		return true, pack(aGlitches[glitch].name, enabled and "enabled" or "disabled")
	end,

	["setworldproperty"] = function(property, enabled)
		if isWorldSpecialPropertyEnabled(property) == enabled then return false, "property is already "..(enabled and "enabled" or "disabled") end
		if not setWorldSpecialPropertyEnabled(property, enabled) then return false end
		return true, pack(aWorldProperties[property].name, enabled and "enabled" or "disabled")
	end,

	["settime"] = function(hours, minutes)
		if not hours then hours = 12 end
		if not minutes then minutes = 0 end
		if not setTime(hours, minutes) then return false end
		return true, pack(formatGameTime(hours, minutes))
	end,

	["setminuteduration"] = function(seconds)
		if not seconds then seconds = 0 end
		seconds = tonumber(string.format("%.3f", seconds))
		if getMinuteDuration() / 1000 == seconds then return false, "minute duration is already "..seconds end
		if not setMinuteDuration(seconds*1000) then return false end
		return true, pack(seconds)
	end,

	["setweather"] = function(id)
		if id < 0 then return false, "weather id must be positive" end
		if not setWeather(id) then return false end
		return true, pack(formatIDName(id, aWeathers[id]))
	end,

	["blendweather"] = function(id)
		if id < 0 then return false, "weather id must be positive" end
		if not setWeatherBlended(id) then return false end
		return true, pack(formatIDName(id, aWeathers[id]))
	end,

	["setblurlevel"] = function(level)
		if not level then level = 36 end
		if level < 0 or level > 255 then return false, "blur must be between 0 and 255" end
		if not setBlurLevel(level) then return false end
		return true, pack(level)
	end,

	["setheathazelevel"] = function(level)
		if level and (level < 0 or level > 255) then return false, "haze must be between 0 and 255" end
		if level then
			if not setHeatHaze(level) then return false end
			return true, pack(level)
		else
			if not resetHeatHaze() then return false end
			return true, pack("default")
		end
	end,

	["setwaveheight"] = function(height)
		if not height then height = 0 end
		if height < 0 or height > 100 then return false, "height must be between 0 and 100" end
		if not setWaveHeight(height) then return false end
		return true, pack(height)
	end,

	["setgamespeed"] = function(speed)
		if not speed then speed = 1 end
		if speed < 0 or speed > 10 then return false, "speed must be between 0 and 10" end
		if not setGameSpeed(speed) then return false end
		return true, pack(speed)
	end,

	["setgravity"] = function(gravity)
		if not gravity then gravity = 0.008 end
		if gravity < -1 or gravity > 1 then return false, "gravity must be between -1 and 1" end
		gravity = tonumber(string.format("%.6f", gravity))
		if not setGravity(gravity) then return false end
		for i, player in ipairs(getElementsByType("player")) do
			setPedGravity(player, gravity)
		end
		return true, pack(gravity)
	end,

	["shutdown"] = function(reason)
		setTimer(
			function()
				shutdown(reason)
			end,
			500, 1
		)
		return true, pack(reason)
	end,

	-- ADMIN PANEL

	
	-- ADMIN
	["achat"] = function(message)
		if not aOutputAdminChat(source, message) then return false end
		return true, pack(message)
	end,

	["warpme"] = function(player)
		if source == console or source == root then return false, "console can't be warped :(" end
		if not aWarpPlayerToPlayer(source, player) then return false end
		return true, pack(getPlayerName(player))
	end,

	["asay"] = function(message)
		outputChatBox(
			rgb2hex(unpack(aColors.orange)).."Admin #FFFFFF"..aGetAdminNameForAll(source)..": "..rgb2hex(unpack(aColors.orange))..message,
			root,
			255, 255, 255,
			true
		)
		return true, pack(message)
	end,

	["execute"] = function(code)
		local func, errorMsg = loadstring("return "..code)
		if errorMsg then
			func, errorMsg = loadstring(code)
		end
		if errorMsg then
			return false, errorMsg
		end
		local results = pack(pcall(func))
		if not results[1] then
			return false, results[2]
		end
		local outputresults = {}
		for i = 2, results.n do
			outputresults[i-1] = results[i]
		end
		return true, pack(code, inspect(outputresults))
	end,

	-- BAN
	["kick"] = function(player, reason)
		local nick = getPlayerName(player)
		local serial = getPlayerSerial(player)
		local ip = getPlayerIP(player)
		local kick = false
		if source == console or source == root then
			kick = kickPlayer(player, reason)
		else
			kick = kickPlayer(player, source, reason)
		end
		if not kick then return false end
		local info = reason and "("..reason..")" or ""
		return true, pack(serial, ip, nick, info)
	end,

	["ban"] = function(player, includeIP, seconds, reason)
		local nick = getPlayerName(player)
		local serial = getPlayerSerial(player)
		local ip = includeIP and getPlayerIP(player) or nil
		local ban = banPlayer(player, includeIP, false, true, source, reason, seconds)
		if not ban then return false end

		setBanAdmin(ban, getAdminAccountName(source))
		local info = "("..formatDuration(seconds or 0)..")"
		if reason then
			info = info.." ("..reason..")"
		end
		return true, pack(serial, ip, nick, info)
	end,

	["banserial"] = function(serial, ip, nick, seconds, reason)
		if getBanBySerial(serial) then return false, "serial is already banned" end
		if ip and getBanByIP(ip) then return false, "ip is already banned" end

		local ban = addBan(ip or nil, nil, serial, source, reason, seconds)
		if not ban then return false end

		if nick then setBanNick(ban, nick) end
		setBanAdmin(ban, getAdminAccountName(source))

		local info = "("..formatDuration(seconds or 0)..")"
		if reason then
			info = info.." ("..reason..")"
		end
		return true, pack(serial, ip, nick or "unknown player", info)
	end,

	--[[
	["banserial"] = function(serial, nick, seconds, reason)
		if getBanBySerial(serial) then return false, "serial is already banned" end

		local ban = addBan(nil, nil, serial, source, reason, seconds)
		if not ban then return false end

		if nick then setBanNick(ban, nick) end
		setBanAdmin(ban, getAdminAccountName(source))

		local info = "("..formatDuration(seconds or 0)..")"
		if reason then
			info = info.." ("..reason..")"
		end
		return true, pack(serial, nick or "unknown player", info)
	end,
	
	["banip"] = function(ip, nick, seconds, reason)
		if getBanByIP(ip) then return false, "IP is already banned" end

		local ban = addBan(ip, nil, nil, source, reason, seconds)
		if not ban then return false end

		if nick then setBanNick(ban, nick) end
		setBanAdmin(ban, getAdminAccountName(source))

		local info = "("..formatDuration(seconds or 0)..")"
		if reason then
			info = info.." ("..reason..")"
		end
		return true, pack(ip, nick or "unknown player", info)
	end,

	["banserialip"] = function(serial, ip, nick, seconds, reason)
		if getBanBySerial(serial) then return false, "serial is already banned" end
		if getBanByIP(ip) then return false, "IP is already banned" end

		local ban = addBan(ip, nil, serial, source, reason, seconds)
		if not ban then return false end

		if nick then setBanNick(ban, nick) end
		setBanAdmin(ban, getAdminAccountName(source))

		local info = "("..formatDuration(seconds or 0)..")"
		if reason then
			info = info.." ("..reason..")"
		end
		return true, pack(serial, ip, nick or "unknown player", info)
	end,
	]]--

	["unban"] = function(serialIP)
		local ban = getBan(serialIP)
		if not ban then return false, "serial/IP is not banned" end

		local serial = getBanSerial(ban)
		local ip = getBanIP(ban)
		local nick = getBanNick(ban)
		local reason = getBanReason(ban)
		local seconds = getBanSeconds(ban)

		local unban = removeBan(ban, source)
		if not unban then return false end

		local info = "("..formatDuration(seconds or 0)..")"
		if reason then
			info = info.." ("..reason..")"
		end
		return true, pack(serial, ip, nick or "unknown player", info)
	end,

	["setbannick"] = function(serialIP, nick)
		local ban = getBan(serialIP)
		if not ban then return false, "serial/IP is not banned" end

		local oldNick = getBanNick(ban)
		if oldNick == nick then return false, "ban nick is already '"..(nick or "[NONE]").."'" end

		local serial = getBanSerial(ban)
		local ip = getBanIP(ban)
		
		if not setBanNick(ban, nick) then return false end
	   
		return true, pack(serial, ip, oldNick, nick)
	end,

	["setbanreason"] = function(serialIP, reason)
		local ban = getBan(serialIP)
		if not ban then return false, "serial/IP is not banned" end

		local oldReason = getBanReason(ban)
		if oldReason == reason then return false, "ban reason is already '"..(reason or "[NONE]").."'" end

		local serial = getBanSerial(ban)
		local ip = getBanIP(ban)

		if not setBanReason(ban, reason) then return false end
	   
		return true, pack(serial, ip, oldReason, reason)
	end,

	-- MUTE
	["muteserial"] = function(serial, nick, seconds, reason)
		if aGetMuteBySerial(serial) then return false, "serial is already muted" end

		local id = aAddMute(serial, nick, source, reason, seconds)
		if not id then return false end

		local info = "("..formatDuration(seconds or 0)..")"
		if reason then
			info = info.." ("..reason..")"
		end
		return true, pack(serial, nick or "unknown player", info)
	end,

	["unmuteserial"] = function(serial)
		local id = aGetMuteBySerial(serial)
		if not id then return false, "serial is already unmuted" end

		local data = aGetMuteData(id)
		local nick = data.nick
		local reason = data.reason
		local seconds = aGetMuteSeconds(id)

		local unmute = aRemoveMute(id, source)
		if not unmute then return false end

		local info = "("..formatDuration(seconds or 0)..")"
		if reason then
			info = info.." ("..reason..")"
		end
		return true, pack(serial, nick or "unknown player", info)
	end,

	["setmutenick"] = function(serial, nick)
		local id = aGetMuteBySerial(serial)
		if not id then return false, "serial is not muted" end

		local oldNick = aGetMuteNick(id)
		if oldNick == nick then return false, "mute nick is already '"..(nick or "[NONE]").."'" end

		if not aSetMuteNick(id, nick) then return false end
	   
		return true, pack(serial, oldNick, nick)
	end,

	["setmutereason"] = function(serial, reason)
		local id = aGetMuteBySerial(serial)
		if not id then return false, "serial is not muted" end

		local oldReason = aGetMuteReason(id)
		if oldReason == reason then return false, "mute reason is already '"..(reason or "[NONE]").."'" end

		if not aSetMuteReason(id, reason) then return false end
	   
		return true, pack(serial, oldReason, reason)
	end,

	-- REPORT
	["readreport"] = function(id)
		return aReadReport(id)
	end,

	["deletereport"] = function(id)
		return aDeleteReport(id)
	end,

	-- ACL
	["aclcreate"] = function(aclName)
		if aclGet(aclName) then return false, "ACL '"..aclName.."' is already exist" end
		if not aclCreate(aclName) then return false end
		return true, pack(aclName)
	end,

	["acldestroy"] = function(aclName)
		local acl = aclGet(aclName)
		if not acl then return false, "ACL '"..aclName.."' does not exist" end
		if not aclDestroy(acl) then return false end
		return true, pack(aclName)
	end,

	["aclcreategroup"] = function(groupName)
		if aclGetGroup(groupName) then return false, "ACL group '"..groupName.."' is already exist" end
		if not aclCreateGroup(groupName) then return false end
		return true, pack(groupName)
	end,

	["acldestroygroup"] = function(groupName)
		local group = aclGetGroup(groupName)
		if not group then return false, "ACL group '"..groupName.."' does not exist" end
		if not aclDestroyGroup(group) then return false end
		return true, pack(groupName)
	end,

	["aclgroupaddacl"] = function(groupName, aclName)
		local group = aclGetGroup(groupName)
		if not group then return false, "ACL group '"..groupName.."' does not exist" end
		local acl = aclGet(aclName)
		if not acl then return false, "ACL '"..aclName.."' does not exist" end
		if aclInGroup(acl, group) then return false, "ACL '"..aclName.."' is already in group '"..groupName.."'" end
		if not aclGroupAddACL(group, acl) then return false end
		return true, pack(groupName, aclName)
	end,

	["aclgroupremoveacl"] = function(groupName, aclName)
		local group = aclGetGroup(groupName)
		if not group then return false, "ACL group '"..groupName.."' does not exist" end
		local acl = aclGet(aclName)
		if not acl then return false, "ACL '"..aclName.."' does not exist" end
		if not aclInGroup(acl, group) then return false, "ACL '"..aclName.."' is not in group '"..groupName.."'" end
		if not aclGroupRemoveACL(group, acl) then return false end
		return true, pack(groupName, aclName)
	end,

	["aclgroupaddobject"] = function(groupName, object)
		local group = aclGetGroup(groupName)
		if not group then return false, "ACL group '"..groupName.."' does not exist" end
		if isObjectInACLGroup(object, group) then return false, "object '"..object.."' is already in group '"..groupName.."'" end
		if not aclGroupAddObject(group, object) then return false end
		return true, pack(groupName, object)
	end,

	["aclgroupremoveobject"] = function(groupName, object)
		local group = aclGetGroup(groupName)
		if not group then return false, "ACL group '"..groupName.."' does not exist" end
		if not isObjectInACLGroup(object, group) then return false, "object '"..object.."' is not in group '"..groupName.."'" end
		if not aclGroupRemoveObject(group, object) then return false end
		return true, pack(groupName, object)
	end,

	["aclsetright"] = function(aclName, right, access)
		if not access then access = false end
		local acl = aclGet(aclName)
		if not acl then return false, "ACL '"..aclName.."' does not exist" end
		if not aclSetRight(acl, right, access) then return false end
		return true, pack(aclName, right, tostring(access))
	end,

	["aclremoveright"] = function(aclName, right)
		local acl = aclGet(aclName)
		if not acl then return false, "ACL '"..aclName.."' does not exist" end
		if aclGetRight(acl, right) == nil then return false, "right '"..right.."' does not exist in ACL '"..aclName.."'" end
		if not aclRemoveRight(acl, right) then return false end
		return true, pack(aclName, right)
	end,

	["restoreadminacl"] = function()
		if not aRestoreACL() then return false end
		return true
	end,

	["restoreacl"] = function()
		if not aRestoreServerACL() then return false end
		return true
	end,

	["reloadacl"] = function()
		return aclReload()
	end,

}
