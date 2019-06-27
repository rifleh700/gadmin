
local aSessions = {
	List = {},
	Permissions = {}
}

addEvent(EVENT_SESSION_UPDATE, false)

addCommandHandler("adminpanel",
	function(player)
		if not hasObjectPermissionTo(player, "general.adminpanel") then return end
		triggerClientEvent(player, EVENT_ADMIN_MENU, player)
	end
)

addEventHandler("onPlayerLogin", root,
	function(previous, current, auto)
		if not aIsPlayerLoaded(source) then return end
		aSessions.Update(source)
	end
)

addEventHandler("onPlayerLogout", root,
	function(previous, current)
		if not aIsPlayerLoaded(source) then return end
		aSessions.Update(source)
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		aSessions.Remove(source)
		aSessions.Permissions[source] = nil
	end
)

function aSessions.Add(player)
	for i, admin in ipairs(aSessions.List) do
		if admin == player then return false end
	end
	aSessions.List[#aSessions.List + 1] = player
	return true
end

function aSessions.Remove(player)
	return table.vremove(aSessions.List, player)
end

function aSessions.UpdateCurrent()
	for i, player in ipairs(aGetAdmins()) do
		aSessions.Update(player)
	end
end

function aSessions.UpdateAll()
	for i, player in ipairs(getElementsByType("player")) do
		if aIsPlayerLoaded(player) then
			aSessions.Update(player)
		end
	end
end

function aSessions.Update(player)
	local wasadmin = aIsAdmin(player)
	local oldpermissions = aSessions.Permissions[player]

	local admin = hasObjectPermissionTo(player, "general.adminpanel")
	local permissions = getObjectPermissions(player)
	if admin then
		aSessions.Add(player)
		aSessions.Permissions[player] = permissions
	else
		aSessions.Remove(player)
		aSessions.Permissions[player] = nil
	end

	if not wasadmin and not admin then return end
	if table.compare(oldpermissions, permissions) then return end

	triggerEvent(EVENT_SESSION_UPDATE, player, admin)
	triggerClientEvent(player, EVENT_SESSION, player, permissions)
end

addEvent(EVENT_SESSION, true)
addEventHandler(EVENT_SESSION, root,
	function()
		aSessions.Update(source)
	end
)

addEventHandler("onAclDestroy", root, aSessions.UpdateCurrent)
addEventHandler("onAclGroupDestroy", root, aSessions.UpdateCurrent)
addEventHandler("onAclGroupACLAdd", root, aSessions.UpdateAll)
addEventHandler("onAclGroupACLRemove", root, aSessions.UpdateCurrent)
addEventHandler("onAclGroupObjectAdd", root, aSessions.UpdateAll)
addEventHandler("onAclGroupObjectRemove", root, aSessions.UpdateCurrent)
addEventHandler("onAclRightChange", root, aSessions.UpdateAll)
addEventHandler("onAclRightRemove", root, aSessions.UpdateCurrent)
addEventHandler("onAclReload", root, aSessions.UpdateAll)

function aIsAdmin(player)
	for i, admin in ipairs(aSessions.List) do
		if admin == player then return true end
	end
	return false
end

function aGetAdmins(permission)
	local admins = {}
	for i, admin in ipairs(aSessions.List) do
		if
			not permission or 
			permission and aSessions.Permissions[admin][permission]
		then
			admins[#admins + 1] = admin
		end
	end
	return admins
end