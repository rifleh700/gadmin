
local protected = {}
local function isProtected(event)
	for i, e in ipairs(protected) do
		if e == event then return true end
	end
	return false
end

local _addEvent = addEvent
function addEvent(event, ...)
	if not _addEvent(event, ...) then return false end
	protected[#protected + 1] = event
end

local _addEventHandler = addEventHandler
function addEventHandler(event, element, handler, propagated, priority)
	_addEventHandler(event, element,
		function(...)
			if isProtected(event) and sourceResource and sourceResource ~= resource then
				outputDebugString(
					"resource '"..getResourceName(sourceResource).."' tried to access admin event '"..event.."'", 2
				)
				return
			end
			handler(...)
		end,
		propagated,
		priority
	)
end
