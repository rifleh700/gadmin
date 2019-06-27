
local aSession = {
	Permissions = {}
}

addEvent(EVENT_SESSION, true)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		triggerServerEvent(EVENT_SESSION, localPlayer)
	end
)

addEventHandler(EVENT_SESSION, localPlayer,
	function(permissions)

		local wasadmin = hasPermissionTo("general.adminpanel")
		local changed = not table.compare(aSession.Permissions, permissions)
		aSession.Permissions = permissions

		if wasadmin then
			if hasPermissionTo("general.adminpanel") then
				if changed then
					local wasopen = aAdminMain.gui.form and guiGetVisible(aAdminMain.gui.form)
					aAdminMain.Close(true)
					if wasopen then aAdminMain.Open() end
					outputChatBox("Your administration rights have been updated")
				end
			else
				outputChatBox("Your administration rights have been revoked")
				aAdminMain.Close(true)
				unbindKey("p", "down", "adminpanel")
			end
		else
			if hasPermissionTo("general.adminpanel") then
				outputChatBox("Press 'P' to open your admin panel", player)
				bindKey("p", "down", "adminpanel")
			end
		end
	end
)

function hasPermissionTo(right)
	if aSession.Permissions[right] then return true end
	return false
end

function sync(dataType, syncType, ...)
	triggerServerEvent(EVENT_SYNC, localPlayer, dataType, syncType, ...)
end
