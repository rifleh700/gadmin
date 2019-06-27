
local aFPS = {
	fps = nil
}

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		setTimer(
			function()
				if not aFPS.fps then return end
				triggerLatentServerEvent(EVENT_FPS, localPlayer, aFPS.fps)
			end, 3000, 0
		)
	end
)

addEventHandler("onClientPreRender", root,
	function(msSinceLastFrame)
		aFPS.fps = math.floor((1 / msSinceLastFrame) * 1000)
	end
)