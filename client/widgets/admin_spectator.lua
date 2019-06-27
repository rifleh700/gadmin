
aSpectator = {
    gui = {},
    Offset = 5,
    AngleX = 0,
    AngleZ = 30,
    Player = nil
}

function aSpectate(player)
    --if player == localPlayer then
    --	messageBox("Can not spectate yourself", MB_ERROR)
    --	return
    --end

    aSpectator.Player = player
    aSpectator.Open()
end

function aSpectator.Create()
    local x, y = guiGetScreenSize()
    aSpectator.gui.form = guiCreateWindow(x - 190, y / 2 - 200, 160, 400, "Actions", false)
    aSpectator.gui.Ban = guiCreateButton(0.10, 0.09, 0.80, 0.05, "Ban", true, aSpectator.gui.form)
    aSpectator.gui.Kick = guiCreateButton(0.10, 0.15, 0.80, 0.05, "Kick", true, aSpectator.gui.form)
    aSpectator.gui.Freeze = guiCreateButton(0.10, 0.21, 0.80, 0.05, "Freeze", true, aSpectator.gui.form)
    aSpectator.gui.SetSkin = guiCreateButton(0.10, 0.27, 0.80, 0.05, "Set Skin", true, aSpectator.gui.form)
    aSpectator.gui.SetHealth = guiCreateButton(0.10, 0.33, 0.80, 0.05, "Set Health", true, aSpectator.gui.form)
    aSpectator.gui.SetArmour = guiCreateButton(0.10, 0.39, 0.80, 0.05, "Set Armour", true, aSpectator.gui.form)
    aSpectator.gui.SetStats = guiCreateButton(0.10, 0.45, 0.80, 0.05, "Set Stats", true, aSpectator.gui.form)
    aSpectator.gui.Slap = guiCreateButton(0.10, 0.51, 0.80, 0.05, "Slap! 20hp", true, aSpectator.gui.form)
    aSpectator.gui.Slaps = guiCreateGridList(0.10, 0.51, 0.80, 0.48, true, aSpectator.gui.form)
    guiGridListAddColumn(aSpectator.gui.Slaps, "", 0.60)
    guiGridListAddColumn(aSpectator.gui.Slaps, "", 0.60)
    guiSetVisible(aSpectator.gui.Slaps, false)
    local i = 0
    while i <= 5 do
        guiGridListSetItemText(
            aSpectator.gui.Slaps,
            guiGridListAddRow(aSpectator.gui.Slaps),
            2,
            tostring(i * 20),
            false,
            false
        )
        i = i + 1
    end
    guiGridListRemoveColumn(aSpectator.gui.Slaps, 1)

    aSpectator.gui.Skip = guiCreateCheckBox(0.08, 0.85, 0.84, 0.04, "Skip dead players", true, true, aSpectator.gui.form)
    guiCreateLabel(0.08, 0.89, 0.84, 0.04, "____________________", true, aSpectator.gui.form)
    aSpectator.gui.Back = guiCreateButton(0.10, 0.93, 0.80, 0.05, "Back", true, aSpectator.gui.form)

    aSpectator.gui.Players = guiCreateWindow(30, y / 2 - 200, 160, 400, "Players", false)
    guiWindowSetSizable(aSpectator.gui.Players, false)
    aSpectator.gui.PlayerList = guiCreateGridList(0.03, 0.07, 0.94, 0.92, true, aSpectator.gui.Players)
    guiGridListAddColumn(aSpectator.gui.PlayerList, "Player Name", 0.85)
    for id, player in ipairs(getElementsByType("player")) do
        local row = guiGridListAddRow(aSpectator.gui.PlayerList)
        guiGridListSetItemText(aSpectator.gui.PlayerList, row, 1, getPlayerName(player), false, false)
        if (player == aSpectator.Player) then
            guiGridListSetSelectedItem(aSpectator.gui.PlayerList, row, 1)
        end
    end
    aSpectator.gui.Prev = guiCreateButton(x / 2 - 100, y - 50, 70, 30, "< Previous", false)
    aSpectator.gui.Next = guiCreateButton(x / 2 + 30, y - 50, 70, 30, "Next >", false)

    addEventHandler("onClientGUIClick", aSpectator.gui.form, aSpectator.onClickHandler)
    addEventHandler("onClientGUIClick", aSpectator.gui.Players, aSpectator.onClickHandler)
    addEventHandler("onClientGUIClick", aSpectator.gui.Prev, aSpectator.onClickHandler)
    addEventHandler("onClientGUIClick", aSpectator.gui.Next, aSpectator.onClickHandler)

    aRegister("Spectator", aSpectator.gui.form, aSpectator.Open, aSpectator.Close)
end

function aSpectator.Destroy()
    destroyElement(aSpectator.gui.form)
    destroyElement(aSpectator.gui.Players)
    destroyElement(aSpectator.gui.Next)
    destroyElement(aSpectator.gui.Prev)
    aSpectator.gui = {}
end

function aSpectator.Open()
    if not aSpectator.gui.form then
        aSpectator.Create()
    end

    bindKey("arrow_l", "down", aSpectator.SwitchPlayer, -1)
    bindKey("arrow_r", "down", aSpectator.SwitchPlayer, 1)
    bindKey("mouse_wheel_up", "down", aSpectator.MoveOffset, -1)
    bindKey("mouse_wheel_down", "down", aSpectator.MoveOffset, 1)
    bindKey("mouse2", "both", aSpectator.Cursor)
    addEventHandler("onClientPlayerWasted", root, aSpectator.CheckPlayer)
    addEventHandler("onClientPlayerQuit", root, aSpectator.CheckPlayer)
    addEventHandler("onClientCursorMove", root, aSpectator.onCursorMoveHandler)
    addEventHandler("onClientRender", root, aSpectator.onRenderHandler)

    guiSetVisible(aSpectator.gui.form, true)
    guiSetVisible(aSpectator.gui.Players, true)
    guiSetVisible(aSpectator.gui.Next, true)
    guiSetVisible(aSpectator.gui.Prev, true)
    aAdminMain.Close(false, "Spectator")

    showCursor(true)
end

function aSpectator.Cursor(key, state)
    local show = not isCursorShowing()
    guiSetVisible(aSpectator.gui.form, show)
    guiSetVisible(aSpectator.gui.Players, show)
    guiSetVisible(aSpectator.gui.Next, show)
    guiSetVisible(aSpectator.gui.Prev, show)
    showCursor(show)
end

function aSpectator.Close(destroy)
    if not aSpectator.gui.form then return end
    
    unbindKey("arrow_l", "down", aSpectator.SwitchPlayer, -1)
    unbindKey("arrow_r", "down", aSpectator.SwitchPlayer, 1)
    unbindKey("mouse_wheel_up", "down", aSpectator.MoveOffset, -1)
    unbindKey("mouse_wheel_down", "down", aSpectator.MoveOffset, 1)
    unbindKey("mouse2", "both", aSpectator.Cursor)
    removeEventHandler("onClientPlayerWasted", root, aSpectator.CheckPlayer)
    removeEventHandler("onClientPlayerQuit", root, aSpectator.CheckPlayer)
    removeEventHandler("onClientMouseMove", root, aSpectator.onCursorMoveHandler)
    removeEventHandler("onClientRender", root, aSpectator.onRenderHandler)

    if destroy then
        aSpectator.Destroy()
    else
        guiSetVisible(aSpectator.gui.form, false)
        guiSetVisible(aSpectator.gui.Players, false)
        guiSetVisible(aSpectator.gui.Next, false)
        guiSetVisible(aSpectator.gui.Prev, false)
    end

    setCameraTarget(localPlayer)
end

function aSpectator.onClickHandler(button)
    if (source == aSpectator.gui.Slaps) then
        return
    end
    guiSetVisible(aSpectator.gui.Slaps, false)
    if (button == "left") then
        if (source == aSpectator.gui.Back) then
            aSpectator.Close(false)
            aAdminMain.Open()
        elseif (source == aSpectator.gui.Ban) then
            triggerEvent("onClientGUIClick", aTab1.Ban, "left")
        elseif (source == aSpectator.gui.Kick) then
            triggerEvent("onClientGUIClick", aTab1.Kick, "left")
        elseif (source == aSpectator.gui.Freeze) then
            triggerEvent("onClientGUIClick", aTab1.Freeze, "left")
        elseif (source == aSpectator.gui.SetSkin) then
            triggerEvent("onClientGUIClick", aTab1.SetSkin, "left")
        elseif (source == aSpectator.gui.SetHealth) then
            triggerEvent("onClientGUIClick", aTab1.SetHealth, "left")
        elseif (source == aSpectator.gui.SetArmour) then
            triggerEvent("onClientGUIClick", aTab1.SetArmour, "left")
        elseif (source == aSpectator.gui.SetStats) then
            triggerEvent("onClientGUIClick", aTab1.SetStats, "left")
        elseif (source == aSpectator.gui.Slap) then
            triggerEvent("onClientGUIClick", aTab1.Slap, "left")
        elseif (source == aSpectator.gui.Next) then
            aSpectator.SwitchPlayer(1)
        elseif (source == aSpectator.gui.Prev) then
            aSpectator.SwitchPlayer(-1)
        elseif (source == aSpectator.gui.PlayerList) then
            if (guiGridListGetSelectedItem(source) ~= -1) then
                aSpectate(getPlayerFromNick(guiGridListGetItemText(source, guiGridListGetSelectedItem(source), 1)))
            end
        end
    end
end

function aSpectator.CheckPlayer()
    if (source == aSpectator.Player) then
        aSpectator.SwitchPlayer(1)
    end
end

function aSpectator.SwitchPlayer(inc, arg, inc2)
    if (not tonumber(inc)) then
        inc = inc2
    end
    if (not tonumber(inc)) then
        return
    end
    local players = {}
    if (guiCheckBoxGetSelected(aSpectator.gui.Skip)) then
        players = aSpectator.GetAlive()
    else
        players = getElementsByType("player")
    end
    if (#players <= 0) then
        if (messageBox("Nobody to spectate, exit spectator?", MB_QUESTION, MB_YESNO)) then
            aSpectator.Close(false)
        end
        return
    end
    local current = 1
    for id, player in ipairs(players) do
        if (player == aSpectator.Player) then
            current = id
        end
    end
    local next = ((current - 1 + inc) % #players) + 1
    if (next == current) then
        if (messageBox("Nobody else to spectate, exit spectator?", MB_QUESTION, MB_YESNO)) then
            aSpectator.Close(false)
        end
        return
    end
    aSpectator.Player = players[next]
end

function aSpectator.onCursorMoveHandler(rx, ry, x, y)
    if (not isCursorShowing()) then
        local sx, sy = guiGetScreenSize()
        aSpectator.AngleX = (aSpectator.AngleX + (x - sx / 2) / 10) % 360
        aSpectator.AngleZ = (aSpectator.AngleZ + (y - sy / 2) / 10) % 360
        if (aSpectator.AngleZ > 180) then
            if (aSpectator.AngleZ < 315) then
                aSpectator.AngleZ = 315
            end
        else
            if (aSpectator.AngleZ > 45) then
                aSpectator.AngleZ = 45
            end
        end
    end
end

function aSpectator.onRenderHandler()
    local sx, sy = guiGetScreenSize()
    if (not aSpectator.Player) then
        dxDrawText("Nobody to spectate", sx - 170, 200, sx - 170, 200, tocolor(255, 0, 0, 255), 1)
        return
    end

    local x, y, z = getElementPosition(aSpectator.Player)

    if (not x) then
        dxDrawText("Error recieving coordinates", sx - 170, 200, sx - 170, 200, tocolor(255, 0, 0, 255), 1)
        return
    end

    local ox, oy, oz
    ox = x - math.sin(math.rad(aSpectator.AngleX)) * aSpectator.Offset
    oy = y - math.cos(math.rad(aSpectator.AngleX)) * aSpectator.Offset
    oz = z + math.tan(math.rad(aSpectator.AngleZ)) * aSpectator.Offset
    setCameraMatrix(ox, oy, oz, x, y, z)

    local sx, sy = guiGetScreenSize()
    dxDrawText(
        "Player: " .. getPlayerName(aSpectator.Player),
        sx - 170,
        200,
        sx - 170,
        200,
        tocolor(255, 255, 255, 255),
        1
    )
    if DEBUG then
        dxDrawText(
            "DEBUG:\nAngleX: "..aSpectator.AngleX
            .."\nAngleZ: "..aSpectator.AngleZ
            .."\n\nOffset: "..aSpectator.Offset
            .."\nX: "..ox
            .."\nY: "..oy
            .."\nZ: "..oz
            .."\nDist: "..getDistanceBetweenPoints3D(x, y, z, ox, oy, oz),
            sx - 170,
            sy - 180,
            sx - 170,
            sy - 180,
            tocolor(255, 255, 255, 255),
            1
        )
    else
        if (isCursorShowing()) then
            dxDrawText(
                "Tip: mouse2 - toggle free camera mode",
                20,
                sy - 50,
                20,
                sy - 50,
                tocolor(255, 255, 255, 255),
                1
            )
        else
            dxDrawText("Tip: Use mouse scroll to zoom in/out", 20, sy - 50, 20, sy - 50, tocolor(255, 255, 255, 255), 1)
        end
    end
end

function aSpectator.MoveOffset(key, state, inc)
    if (not isCursorShowing()) then
        aSpectator.Offset = aSpectator.Offset + tonumber(inc)
        if (aSpectator.Offset > 70) then
            aSpectator.Offset = 70
        elseif (aSpectator.Offset < 2) then
            aSpectator.Offset = 2
        end
    end
end

function aSpectator.GetAlive()
    local alive = {}
    for id, player in ipairs(getElementsByType("player")) do
        if (not isPedDead(player)) then
            table.insert(alive, player)
        end
    end
    return alive
end
