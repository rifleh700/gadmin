
function outputAdmin(admin, text, r, g, b, colorCoded)
	if getElementType(admin) == "player" then
		return outputChatBox(text, admin, r, g, b, colorCoded)
	elseif admin == console then
		return outputServerLog(text)
	end
	return false
end

function outputAdminConsole(admin, text)
	if getElementType(admin) == "player" then
		return outputConsole(text, admin)
	elseif admin == console then
		return outputServerLog(text)
	end
	return false
end

function getPlayerAccountName(player)
	local account = getPlayerAccount(player)
	return account and (not isGuestAccount(account)) and getAccountName(account)
end

function getAdminAccountName(element)
	if element == root or element == console then return "Console" end
	return getPlayerAccountName(element) 
end

function getAdminNameForLog(element)
	if element == root or element == console then return "Console" end
	local name = getPlayerName(element)
	local accountName = getPlayerAccountName(element)
	if accountName then
		name = name.."("..accountName..")"
	end
	return name
end

function getPlayerBySerial(serial)
	for i, player in ipairs(getElementsByType("player")) do
		if getPlayerSerial(player) == serial then return player end
	end
	return nil
end

function setVehicleOneColor(vehicle, number, r, g, b)
	local colors = {getVehicleColor(vehicle, true)}
	colors[(number-1)*3+1] = r
	colors[(number-1)*3+2] = g
	colors[(number-1)*3+3] = b
	return setVehicleColor(vehicle, unpack(colors))
end
