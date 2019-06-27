
addEvent(EVENT_PROXY, true)
addEventHandler(EVENT_PROXY, root,
	function(action, data, value)
		if action == PROXY_ALL then
			if data[PROXY_BLUR] then setBlurLevel(data[PROXY_BLUR]) end
			for k, v in pairs(data[PROXY_SPECIAL]) do
				setWorldSpecialPropertyEnabled(k, v)
			end

		elseif action == PROXY_BLUR then
			if data then setBlurLevel(data) end

		elseif action == PROXY_SPECIAL then
			if value ~= nil then setWorldSpecialPropertyEnabled(data, value) end
			
		end
	end
)
