
local aFPS = {
	List = {}
}

addEvent(EVENT_FPS, true)

addEventHandler("onPlayerQuit", root,
	function()
		aFPS.List[source] = nil
	end
)

addEventHandler(EVENT_FPS, root,
	function(fps)
		if not isElement(source) then return end
		aFPS.List[source] = fps
	end,
	true, "high"
)

function aGetPlayerFPS(player)
	return aFPS.List[player]
end