
console = getElementByIndex("console", 0)

aLogMessages = {}
aInteriors = {}
aSkins = {}
aStats = {}
aFightingStyles = {}
aWalkingStyles = {}
aUpgrades = {}
aWeathers = {}
aGlitches = {}
aWorldProperties = {}
aColors = {}

addEventHandler("onResourceStart", resourceRoot,
	function(resource)
		aSetupACL()
		aSetupCommands()
		aSetupStorage()
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function(resource)
		aReleaseStorage()
		aclSave()
	end
)

function aIsAnonAdmin(admin)
	return false
end

function aGetAdminNameForAll(element)
	if element == root or element == console then return "Console" end
	return (aIsAnonAdmin(admin) and "Admin" or getPlayerName(element))
end

function aGetSkinIDFromPartialName(partial)
	partial = string.lower(partial)
	for id, name in pairs(aSkins) do
		if string.find(string.lower(name), partial, 1, true) then return id end
	end
	return nil
end

function aGetFightingStyleFromPartialName(partial)
	partial = string.lower(partial)
	for id, name in pairs(aFightingStyles) do
		if string.find(string.lower(name), partial, 1, true) then return id end
	end
	return nil
end

function aGetWalkingStyleFromPartialName(partial)
	partial = string.lower(partial)
	for id, name in pairs(aWalkingStyles) do
		if string.find(string.lower(name), partial, 1, true) then return id end
	end
	return nil
end

function aGetStatFromPartialName(partial)
	partial = string.lower(partial)
	for id, name in pairs(aStats) do
		if string.find(string.lower(name), partial, 1, true) then return id end
	end
	return nil
end

function aGetInteriorNameFromPartialName(partial)
	partial = string.lower(partial)
	for name, data in pairs(aInteriors) do
		if string.find(string.lower(name), partial, 1, true) then return name end
	end
	return nil
end