
local aServer = {}
local PERMISSION = "general.tab_server"

addEventHandler("onServerPasswordChange", root,
    function()
        requestSyncGlobal(PERMISSION, SYNC_SERVER, SYNC_SINGLE, "password")
    end
)

addEventHandler("onGameTypeChange", root,
    function()
        requestSyncGlobal(PERMISSION, SYNC_SERVER, SYNC_SINGLE, "game")
    end
)

addEventHandler("onMapNameChange", root,
    function()
        requestSyncGlobal(PERMISSION, SYNC_SERVER, SYNC_SINGLE, "map")
    end
)

addEventHandler("onFPSLimitChange", root,
    function()
        requestSyncGlobal(PERMISSION, SYNC_SERVER, SYNC_SINGLE, "fps")
    end
)

addEventHandler("onGlitchChange", root,
    function(glitch)
        requestSyncGlobal(PERMISSION, SYNC_SERVER, SYNC_SINGLE, "glitches")
    end
)

addEventHandler("onWorldSpecialPropertyChange", root,
    function(property)
        requestSyncGlobal(PERMISSION, SYNC_SERVER, SYNC_SINGLE, "properties")
    end
)

function aServer.GetSetting(setting)
    if setting == "name" then
        return getServerName()
    elseif setting == "players" then
        return getMaxPlayers()
    elseif setting == "game" then
        return getGameType()
    elseif setting == "map" then
        return getMapName()
    elseif setting == "password" then
        return getServerPassword() 
    elseif setting == "fps" then
        return getFPSLimit()
    elseif setting == "glitches" then
        local data = {}
        for glitch, gdata in pairs(aGlitches) do
            data[glitch] = isGlitchEnabled(glitch)
        end
        return data
    elseif setting == "properties" then
        local data = {}
        for property, pdata in pairs(aWorldProperties) do
            data[property] = isWorldSpecialPropertyEnabled(property)
        end
        return data
    end
    return nil
end

function aServer.GetSettings()
    local settings = {}
    settings.name = getServerName()
    settings.players = getMaxPlayers()
    settings.game = getGameType()
    settings.map = getMapName()
    settings.password = getServerPassword() 
    settings.fps = getFPSLimit() 
    settings.glitches = {}
    for glitch, gdata in pairs(aGlitches) do
        settings.glitches[glitch] = isGlitchEnabled(glitch)
    end
    settings.properties = {}
    for property, pdata in pairs(aWorldProperties) do
        settings.properties[property] = isWorldSpecialPropertyEnabled(property)
    end
    return settings
end

aServer.SyncFunctions = {
    [SYNC_LIST] = function()
        sync(source, SYNC_SERVER, SYNC_LIST, aServer.GetSettings())
    end,
    [SYNC_SINGLE] = function(setting)
        sync(source, SYNC_SERVER, SYNC_SINGLE, setting, aServer.GetSetting(setting))
    end,
}
addEventHandler(
    EVENT_SYNC,
    root,
    function(dataType, syncType, ...)
        if dataType ~= SYNC_SERVER then return end
        if not hasObjectPermissionTo(source, PERMISSION) then
            outputDebugString("Access denied for '"..PERMISSION.."' (player: "..getPlayerName(source)..")", 2)
            return
        end
        aServer.SyncFunctions[syncType](...)
    end
)