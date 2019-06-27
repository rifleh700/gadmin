
local aSettings = {
	File = nil,
	Cache = {}
}

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		aSettings.Initialize()
	end
)

function aSettings.Initialize()
	aSettings.File = xmlLoadFile("settings.xml")
	if not aSettings.File then
		aSettings.File = xmlCreateFile("settings.xml", "settings")
		xmlSaveFile(aSettings.File)
	end
end

function aGetSetting(setting, number, integer)
	if aSettings.Cache[setting] ~= nil then return aSettings.Cache[setting] end

	local node = xmlFindChild(aSettings.File, setting, 0)
	if not node then return nil end

	local value = xmlNodeGetValue(node)
	if not value then return nil end

	if number then
		value = tonumber(value)
		if not value then return nil end
		if integer then value = math.floor(value) end
	else
		if value == "true" then return true end
		if value == "false" then return false end
		if tonumber(value) then return tonumber(value) end
	end
	return value
end

function aSetSetting(setting, value)
	aSettings.Cache[setting] = value
	local node = xmlFindChild(aSettings.File, setting, 0)
	if not node then
		node = xmlCreateChild(aSettings.File, setting)
	end
	if value == nil then value = false end
	xmlNodeSetValue(node, tostring(value))
	xmlSaveFile(aSettings.File)
end

function aRemoveSetting(setting)
	aSettings.Cache[setting] = nil
	
	local node = xmlFindChild(aSettings.File, tostring(setting), 0)
	if not node then return end

	xmlDestroyNode(node)
	xmlSaveFile(aSettings.File)
end
