
local aCoroutines = {}

local _addEventHandler = addEventHandler
function addEventHandler(event, element, handler, ...)
	local add = _addEventHandler(event, element, corouteHandler(handler), ...)
	if not add then
		local info = debug.getinfo(2, "nS")
		outputDebugString(info.short_src..":"..info.linedefined..": addEventHandler('"..tostring(event).."') call failed", 1)
   	end
   	-- onElementDestroy/onClientElementDestroy -> removeEventHandler ???
   	return add
end

local _removeEventHandler = removeEventHandler
function removeEventHandler(event, element, handler)
	if not aCoroutines[handler] then
		return _removeEventHandler(event, element, handler)
	end
	local remove = false
	for i, wrapper in ipairs(aCoroutines[handler]) do
		remove = _removeEventHandler(event, element, wrapper)
	end
	aCoroutines[handler] = {}
	return remove
end

function corouteHandler(handler)
	local wrapper = function(...)
		local c = coroutine.create(handler)
		local result, errormsg = coroutine.resume(c, ...)
		if not result then
			outputDebugString(tostring(errormsg), 1)
		end
	end
	if not aCoroutines[handler] then
		aCoroutines[handler] = {}
	end
	table.insert(aCoroutines[handler], wrapper)
	return wrapper
end

function coroutine.sleep(ms)
	local c = coroutine.running()
	setTimer(
		function()
			if coroutine.status(c) ~= "suspended" then return end
			coroutine.resume(c)
		end, math.max(ms, 50), 1
	)
	coroutine.yield()
end

--[[
setTimer(
	function()
		local count = 0
		for k, handler in pairs(aCoroutines) do
			for i, wrapper in ipairs(handler) do
				count = count + 1
			end
		end
		if localPlayer then
			outputChatBox("client wrappers: "..count)
		else
			outputChatBox("server wrappers: "..count)
		end
	end,
	1000, 0
)
]]--