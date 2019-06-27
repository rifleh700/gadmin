
local worldSpecialProperties = {}
local blur = nil

addEvent("onWorldSpecialPropertyChange", false)

function isValidWorldSpecialProperty(property)
	if aWorldProperties[property] then return true end
	return false
end

function isWorldSpecialPropertyEnabled(property)
	if worldSpecialProperties[property] == nil then return nil end
	return worldSpecialProperties[property] == true
end

function setWorldSpecialPropertyEnabled(property, enabled)
	if not isValidWorldSpecialProperty(property) then return false end
	worldSpecialProperties[property] = enabled
	triggerClientEvent(EVENT_PROXY, root, PROXY_SPECIAL, property, enabled)
	triggerEvent("onWorldSpecialPropertyChange", root, property)
	return true
end

function setBlurLevel(level)
	blur = level
	triggerClientEvent(EVENT_PROXY, root, PROXY_BLUR, blur)
	return true
end

function getBlurLevel()
	return blur
end

addEventHandler(EVENT_SESSION, root,
	function()
		triggerClientEvent(client, EVENT_PROXY, client, PROXY_ALL,
			{
				[PROXY_BLUR] = blur,
				[PROXY_SPECIAL] = worldSpecialProperties
			}
		)
	end
)
