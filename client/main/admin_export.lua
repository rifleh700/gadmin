
local function checkInitialized()
	if aAdminMain.gui.form then return true end
	outputDebugString("Admin panel not initialized", 2)
	return false
end

function getWindow()
	if not checkInitialized() then return false end
	return aAdminMain.gui.form
end

function getTabPanel()
	if not checkInitialized() then return false end
	return aAdminMain.gui.panel
end

function addTab(text)
	if not checkInitialized() then return false end
	return guiCreateTab(text, aAdminMain.gui.panel)
end