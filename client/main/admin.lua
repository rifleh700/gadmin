
aAdminMain = {
	gui = {},
	Tabs = {},
	Tab = nil,
	Widgets = {},
	RefreshTicks = 0,
}

addEvent(EVENT_SYNC, true)
addEvent(EVENT_ADMIN_MENU, true)
addEvent("onAdminInitialize", false) -- needed for exported functions
addEvent("onAdminRefresh", false)

addEventHandler(EVENT_ADMIN_MENU, localPlayer,
	function()
		if aAdminMain.gui.form and guiGetVisible(aAdminMain.gui.form) then
			aAdminMain.Close()
		else
			aAdminMain.Open()
		end
	end
)

function aAdminMain.Create()
	if aAdminMain.gui.form then return end

	aAdminMain.gui.form = guiCreateWindow(0, 0, 620, 520, "GreatAdmin v"..VERSION, false)
	aAdminMain.gui.panel = guiCreateTabPanel(0.01, 0.05, 0.98, 0.95, true, aAdminMain.gui.form)

	aAdminMain.AddTab("Players", aPlayersTab, "players")
	aAdminMain.AddTab("Resources", aResourcesTab, "resources")
	aAdminMain.AddTab("Server", aServerTab, "server")
	aAdminMain.AddTab("Bans", aBansTab, "bans")
	aAdminMain.AddTab("Mutes", aMutesTab, "mutes")
	aAdminMain.AddTab("Admin chat", aChatTab, "adminchat", true)
	aAdminMain.AddTab("Rights", aAclTab, "acl")

	addEventHandler("onClientGUITabSwitched", aAdminMain.gui.panel, aAdminMain.onTabSwitchedHandler)
	
	triggerEvent("onAdminInitialize", aAdminMain.gui.form)
end

function aAdminMain.Destroy()
	for tab, data in pairs(aAdminMain.Tabs) do
		data.Class.Destroy()
	end
	destroyElement(aAdminMain.gui.form)
	aAdminMain.gui = {}
	aAdminMain.Tabs = {}
	aAdminMain.Tab = nil
end

function aAdminMain.Open()
	if not aAdminMain.gui.form then
		aAdminMain.Create()
	end
	--guiSetAlpha(aAdminMain.gui.form, 0)
	--guiBlendElement(aAdminMain.gui.form, 0.8)
	guiSetVisible(aAdminMain.gui.form, true)
	showCursor(true)
end

function aAdminMain.Close(destroy, except)
	if not aAdminMain.gui.form then return end
	for name, widget in pairs(aAdminMain.Widgets) do
		if name ~= except then
			widget.Close(destroy)
		end
	end
	if destroy then
		aAdminMain.Destroy()
	else
		guiSetVisible(aAdminMain.gui.form, false)
		--guiBlendElement(aAdminMain.gui.form, 0, true)
	end
	showCursor(false)
	guiSetInputEnabled(false)
end

function aAdminMain.onTabSwitchedHandler(tab)
	aAdminMain.Tab = tab

	if not aAdminMain.Tabs[tab] then return end
	if aAdminMain.Tabs[tab].Loaded then return end

	aAdminMain.LoadTab(tab)
end

function aAdminMain.LoadTab(tab)
	aAdminMain.Tabs[tab].Class.Create(tab)
	aAdminMain.Tabs[tab].Loaded = true
end

function aAdminMain.AddTab(name, class, acl, loadt)
	local tab = guiCreateTab(name, aAdminMain.gui.panel, acl)
	aAdminMain.Tabs[tab] = {
		Class = class,
		Loaded = false
	}
	if loadt then aAdminMain.LoadTab(tab) end
	if not aAdminMain.Tab and guiGetEnabled(tab) then
		guiSetSelectedTab(aAdminMain.gui.panel, tab)
		aAdminMain.onTabSwitchedHandler(tab)
	end
	return tab
end

function aRegister(name, form, open, close)
	aAdminMain.Widgets[name] = {}
	aAdminMain.Widgets[name].Form = form
	aAdminMain.Widgets[name].Open = open
	aAdminMain.Widgets[name].Close = close
end

function aRegisterInitiatorEvent(event, permission)
	addEventHandler(event, root,
		function(...)
			if aAdminMain.gui.form then return end
			if not hasPermissionTo("general.adminpanel") then return end
			if not hasPermissionTo(permission) then return end
			aAdminMain.Create()
			triggerEvent(event, source, ...)
		end,
		true,
		"high"
	)
end

addEventHandler("onClientRender", root,
	function()
		if not (aAdminMain.gui.form and guiGetVisible(aAdminMain.gui.form) and aAdminMain.Tab) then return end
		if getTickCount() < aAdminMain.RefreshTicks then return end

		triggerEvent("onAdminRefresh", aAdminMain.Tab)
		aAdminMain.RefreshTicks = getTickCount() + 100
	end
)
