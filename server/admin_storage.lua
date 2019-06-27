
function aSetupStorage()
	--local query = db.query ( "SELECT name FROM sqlite_master WHERE name='admin_alias'" )

	db.exec("CREATE TABLE IF NOT EXISTS alias ( ip TEXT, serial TEXT, name TEXT, time INTEGER )")
	db.exec("CREATE TABLE IF NOT EXISTS warnings ( ip TEXT, serial TEXT, name TEXT, time INTEGER )")

	local node = xmlLoadFile("conf/interiors.xml")
	if node then
		for i, subnode in ipairs(xmlNodeGetChildren(node)) do
			local name = xmlNodeGetAttribute(subnode, "name")
			local data = {}
			data.x = tonumber(xmlNodeGetAttribute(subnode, "posX"))
			data.y = tonumber(xmlNodeGetAttribute(subnode, "posY"))
			data.z = tonumber(xmlNodeGetAttribute(subnode, "posZ"))
			data.interior = tonumber(xmlNodeGetAttribute(subnode, "interior"))
			aInteriors[name] = data
		end
		xmlUnloadFile(node)
	end

	local node = xmlLoadFile("conf/skins.xml")
	if node then
		for i, groupNode in ipairs(xmlNodeGetChildren(node)) do
			for i2, skinNode in ipairs(xmlNodeGetChildren(groupNode)) do
				local id = tonumber(xmlNodeGetAttribute(skinNode, "model"))
				local name = xmlNodeGetAttribute(skinNode, "name")
				aSkins[id] = name
			end
		end
		xmlUnloadFile(node)
	end

	local node = xmlLoadFile("conf/stats.xml")
	if node then
		for i, groupNode in ipairs(xmlNodeGetChildren(node)) do
			for i2, statNode in ipairs(xmlNodeGetChildren(groupNode)) do
				local id = tonumber(xmlNodeGetAttribute(statNode, "id"))
				local name = xmlNodeGetAttribute(statNode, "name")
				aStats[id] = name
			end
		end
		xmlUnloadFile(node)
	end

	local node = xmlLoadFile("conf/fightingstyles.xml")
	if node then
		for i, subnode in ipairs(xmlNodeGetChildren(node)) do
			if xmlNodeGetName(subnode) == "style" then
				local id = tonumber(xmlNodeGetAttribute(subnode, "id"))
				local name = xmlNodeGetAttribute(subnode, "name")
				aFightingStyles[id] = name
			end
		end
		xmlUnloadFile(node)
	end

	local node = xmlLoadFile("conf/walkingstyles.xml")
	if node then
		for i, subnode in ipairs(xmlNodeGetChildren(node)) do
			if xmlNodeGetName(subnode) == "style" then
				local id = tonumber(xmlNodeGetAttribute(subnode, "id"))
				local name = xmlNodeGetAttribute(subnode, "name")
				aWalkingStyles[id] = name
			end
		end
		xmlUnloadFile(node)
	end

	local node = xmlLoadFile("conf/weathers.xml")
	if node then
		local weathers = 0
		while (xmlFindChild(node, "weather", weathers) ~= false) do
			local weather = xmlFindChild(node, "weather", weathers)
			local id = tonumber(xmlNodeGetAttribute(weather, "id"))
			local name = xmlNodeGetAttribute(weather, "name")
			aWeathers[id] = name
			weathers = weathers + 1
		end
		xmlUnloadFile(node)
	end

	local node = xmlLoadFile("conf/upgrades.xml")
	if node then
		for i, subnode in ipairs(xmlNodeGetChildren(node)) do
			local id = tonumber(xmlNodeGetAttribute(subnode, "id"))
			aUpgrades[id] = xmlNodeGetAttribute(subnode, "name")
		end
		xmlUnloadFile(node)
	end

	local node = xmlLoadFile("conf/glitches.xml")
	if node then
		for i, subnode in ipairs(xmlNodeGetChildren(node)) do
			if xmlNodeGetName(subnode) == "glitch" then
				local nid = xmlNodeGetAttribute(subnode, "nid")
				aGlitches[nid] = {}
				aGlitches[nid].name = xmlNodeGetAttribute(subnode, "name")
			end
		end
		xmlUnloadFile(node)
	end

	local node = xmlLoadFile("conf/worldproperties.xml")
	if node then
		for i, subnode in ipairs(xmlNodeGetChildren(node)) do
			if xmlNodeGetName(subnode) == "property" then
				local nid = xmlNodeGetAttribute(subnode, "nid")
				aWorldProperties[nid] = {}
				aWorldProperties[nid].name = xmlNodeGetAttribute(subnode, "name")
				aWorldProperties[nid].default = xmlNodeGetAttribute(subnode, "default") == "true"
			end
		end
		xmlUnloadFile(node)
	end

	local node = xmlLoadFile("conf/colors.xml")
	if node then
		for i, subnode in ipairs(xmlNodeGetChildren(node)) do
			if xmlNodeGetName(subnode) == "color" then
				local name = xmlNodeGetAttribute(subnode, "name")
				local r = tonumber(xmlNodeGetAttribute(subnode, "r"))
				local g = tonumber(xmlNodeGetAttribute(subnode, "g"))
				local b = tonumber(xmlNodeGetAttribute(subnode, "b"))
				aColors[name] = {r, g, b}
			end
		end
		xmlUnloadFile(node)
	end

	local node = xmlLoadFile("conf/messages.xml")
	if node then
		for i, groupNode in ipairs(xmlNodeGetChildren(node)) do
			local action = xmlNodeGetAttribute(groupNode, "action")
			local color = xmlNodeGetAttribute(groupNode, "color") or nil
			aLogMessages[action] = {}
			aLogMessages[action].color = color

			for im, messageNode in ipairs(xmlNodeGetChildren(groupNode)) do
				aLogMessages[action][xmlNodeGetName(messageNode)] = xmlNodeGetValue(messageNode)
			end
		end
		xmlUnloadFile(node)
	end
end

function aReleaseStorage()
end
