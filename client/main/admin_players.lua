
aPlayersTab = {
	gui = {},
	List = {},
	SelectedAmmo = nil,
}

addEvent(EVENT_PLAYER_JOIN, true)

function aPlayersTab.Create(tab)
	if aPlayersTab.gui.tab then return end

	aPlayersTab.gui.tab = tab

	aPlayersTab.gui.reportsBtn = guiCreateButton(0.71, 0.02, 0.27, 0.04, "Reports...", true, tab, "listreports")

	aPlayersTab.gui.srch = guiCreateSearchEdit(0.01, 0.02, 0.20, 0.04, "", true, tab)
	aPlayersTab.gui.list = guiCreateGridList(0.01, 0.07, 0.20, 0.83, true, tab)
	guiGridListAddColumn(aPlayersTab.gui.list, "Name", 0.85)
	guiGridListRegisterArrowScroll(aPlayersTab.gui.list)
	guiGridListRegisterSearch(aPlayersTab.gui.list, aPlayersTab.gui.srch)

	aPlayersTab.gui.outputConsoleChk = guiCreateCheckBox(0.02, 0.905, 0.20, 0.04, "Output console", true, true, tab)
	guiCheckBoxSetSelected(aPlayersTab.gui.outputConsoleChk, aGetSetting("outputConsole") ~= false)
	aPlayersTab.gui.colorCodesChk = guiCreateCheckBox(0.02, 0.95, 0.20, 0.04, "Hide color codes", true, true, tab)
	guiCheckBoxSetSelected(aPlayersTab.gui.colorCodesChk, aGetSetting("stripColorCodes") ~= false)

	aPlayersTab.gui.screenShotBtn = guiCreateButton(0.71, 0.08, 0.27, 0.04, "Screen shots...", true, tab, "getscreen")
	aPlayersTab.gui.kickBtn = guiCreateButton(0.71, 0.125, 0.13, 0.04, "Kick", true, tab, "kick")
	aPlayersTab.gui.banBtn = guiCreateButton(0.85, 0.125, 0.13, 0.04, "Ban", true, tab, "ban")
	aPlayersTab.gui.muteBtn = guiCreateButton(0.71, 0.170, 0.13, 0.04, "Mute", true, tab, "mute")
	aPlayersTab.gui.freezeBtn = guiCreateButton(0.85, 0.170, 0.13, 0.04, "Freeze", true, tab, "freeze")
	aPlayersTab.gui.spectateBtn = guiCreateButton(0.71, 0.215, 0.13, 0.04, "Spectate", true, tab, "spectate")
	
	local slapSetting = aGetSetting("slap")
	aPlayersTab.gui.slapBtn, aPlayersTab.gui.slapList =
		guiCreateComboBoxButton(0.85, 0.215, 0.13, 0.04, "Slap", true, tab, "slap")
	for i = 1, 5 do
		local slap = i * 20
		guiGridListAddRow(aPlayersTab.gui.slapList, tostring(slap))
		if slapSetting == slap then
			guiComboBoxButtonSetSelected(aPlayersTab.gui.slapBtn, i-1)
		end
	end
	if guiGridListGetSelectedItem(aPlayersTab.gui.slapList) == -1 then
		guiComboBoxButtonSetSelected(aPlayersTab.gui.slapBtn, 0)
	end
	guiGridListAdjustHeight(aPlayersTab.gui.slapList)
	

	aPlayersTab.gui.setNickBtn = guiCreateButton(0.71, 0.260, 0.13, 0.04, "Set nick", true, tab, "setnick")
	aPlayersTab.gui.shoutBtn = guiCreateButton(0.85, 0.260, 0.13, 0.04, "Shout!", true, tab, "shout")
	aPlayersTab.gui.setGroupBtn, aPlayersTab.gui.setGroupList =
		guiCreateComboBoxButton(0.71, 0.305, 0.27, 0.04, "Set", true, tab, "setadmingroup")
	guiGridListAddRow(aPlayersTab.gui.setGroupList, "None")
	guiComboBoxButtonSetSelected(aPlayersTab.gui.setGroupBtn, 0)
	
	-----------------------------
	guiCreateHeader(0.23, 0.035, 0.20, 0.04, "Player:", true, tab)

	aPlayersTab.gui.dataCtext = guiCreateContextMenu()
	aPlayersTab.gui.dataCopyCtextItem = guiContextMenuAddItem(aPlayersTab.gui.dataCtext, "Copy")

	aPlayersTab.gui.nameLbl = guiCreateLabel(0.24, 0.080, 0.45, 0.035, "Name: N/A", true, tab)
	guiSetContextMenu(aPlayersTab.gui.nameLbl, aPlayersTab.gui.dataCtext)
	aPlayersTab.gui.IPLbl = guiCreateLabel(0.24, 0.125, 0.45, 0.035, "IP: N/A", true, tab)
	guiSetContextMenu(aPlayersTab.gui.IPLbl, aPlayersTab.gui.dataCtext)
	aPlayersTab.gui.versionLbl = guiCreateLabel(0.45, 0.125, 0.45, 0.035, "Version: N/A", true, tab)
	guiSetContextMenu(aPlayersTab.gui.versionLbl, aPlayersTab.gui.dataCtext)
	aPlayersTab.gui.serialLbl = guiCreateLabel(0.24, 0.170, 0.45, 0.035, "Serial: N/A", true, tab)
	guiSetContextMenu(aPlayersTab.gui.serialLbl, aPlayersTab.gui.dataCtext)
	aPlayersTab.gui.countryLbl = guiCreateLabel(0.24, 0.215, 0.45, 0.035, "Country: N/A", true, tab)
	aPlayersTab.gui.accountLbl = guiCreateLabel(0.24, 0.260, 0.45, 0.035, "Account: N/A", true, tab)
	guiSetContextMenu(aPlayersTab.gui.accountLbl, aPlayersTab.gui.dataCtext)
	aPlayersTab.gui.groupsLbl = guiCreateLabel(0.24, 0.305, 0.45, 0.035, "Groups: N/A", true, tab)
	aPlayersTab.gui.flagImg = guiCreateStaticImage(0.40, 0.125, 0.025806, 0.021154, "client/images/empty.png", true, tab)
	guiSetVisible(aPlayersTab.gui.flagImg, false)

	-----------------------------
	guiCreateHeader(0.23, 0.350, 0.20, 0.04, "Game:", true, tab)

	aPlayersTab.gui.healthLbl = guiCreateLabel(0.24, 0.395, 0.20, 0.04, "Health: N/A", true, tab)
	aPlayersTab.gui.armourLbl = guiCreateLabel(0.45, 0.395, 0.20, 0.04, "Armour: N/A", true, tab)
	aPlayersTab.gui.skinLbl = guiCreateLabel(0.24, 0.440, 0.20, 0.04, "Skin: N/A", true, tab)
	aPlayersTab.gui.teamLbl = guiCreateLabel(0.45, 0.440, 0.20, 0.04, "Team: N/A", true, tab)
	aPlayersTab.gui.weaponLbl = guiCreateLabel(0.24, 0.485, 0.35, 0.04, "Weapon: N/A", true, tab)
	aPlayersTab.gui.pingLbl = guiCreateLabel(0.24, 0.530, 0.20, 0.04, "Ping: N/A", true, tab)
	aPlayersTab.gui.fpsLbl = guiCreateLabel(0.45, 0.530, 0.20, 0.04, "FPS: N/A", true, tab)
	aPlayersTab.gui.moneyLbl = guiCreateLabel(0.24, 0.575, 0.20, 0.04, "Money: N/A", true, tab)

	aPlayersTab.gui.areaLbl = guiCreateLabel(0.24, 0.620, 0.44, 0.04, "Area: N/A", true, tab)
	guiSetContextMenu(aPlayersTab.gui.areaLbl, aPlayersTab.gui.dataCtext)
	aPlayersTab.gui.posXLbl = guiCreateLabel(0.24, 0.665, 0.30, 0.04, "X: N/A", true, tab)
	aPlayersTab.gui.posYLbl = guiCreateLabel(0.45, 0.665, 0.30, 0.04, "Y: N/A", true, tab)
	aPlayersTab.gui.posZLbl = guiCreateLabel(0.24, 0.710, 0.30, 0.04, "Z: N/A", true, tab)
	guiSetContextMenu(aPlayersTab.gui.posXLbl, aPlayersTab.gui.dataCtext)
	guiSetContextMenu(aPlayersTab.gui.posYLbl, aPlayersTab.gui.dataCtext)
	guiSetContextMenu(aPlayersTab.gui.posZLbl, aPlayersTab.gui.dataCtext)
	aPlayersTab.gui.dimensionLbl = guiCreateLabel(0.24, 0.755, 0.20, 0.04, "Dimension: N/A", true, tab)
	aPlayersTab.gui.interiorLbl = guiCreateLabel(0.45, 0.755, 0.20, 0.04, "Interior: N/A", true, tab)

	aPlayersTab.gui.setHealthBtn = guiCreateButton(0.71, 0.395, 0.13, 0.04, "Set Health", true, tab, "sethealth")
	aPlayersTab.gui.setArmourBtn = guiCreateButton(0.85, 0.395, 0.13, 0.04, "Set Armour", true, tab, "setarmour")
	aPlayersTab.gui.setSkinBtn = guiCreateButton(0.71, 0.440, 0.13, 0.04, "Set Skin", true, tab, "setskin")
	aPlayersTab.gui.setTeamBtn = guiCreateButton(0.85, 0.440, 0.13, 0.04, "Set Team", true, tab, "setteam")
	aPlayersTab.gui.setDimensionBtn = guiCreateButton(0.71, 0.755, 0.13, 0.04, "Set Dimens.", true, tab, "setdimension")
	aPlayersTab.gui.setInteriorBtn = guiCreateButton(0.85, 0.755, 0.13, 0.04, "Set Interior", true, tab, "setinterior")
	
	aPlayersTab.gui.giveWeaponBtn, aPlayersTab.gui.giveWeaponList =
		guiCreateComboBoxButton(0.71, 0.485, 0.27, 0.04, "Give", true, tab, "giveweapon")
	guiGridListAdjustHeight(aPlayersTab.gui.giveWeaponList, 12)
	aPlayersTab.gui.giveWeaponSrch = guiCreateSearchEdit(5, 3, 135, 18, "", false, aPlayersTab.gui.giveWeaponList)
	guiSetProperty(aPlayersTab.gui.giveWeaponSrch, "AlwaysOnTop", "True")
	guiGridListRegisterSearch(aPlayersTab.gui.giveWeaponList, aPlayersTab.gui.giveWeaponSrch)
	aPlayersTab.RefreshGiveWeapon()
	if not aPlayersTab.SetSelectedWeapon(aGetSetting("weapon")) then
		aPlayersTab.SetSelectedWeapon(30) -- AK-47
	end
	aPlayersTab.SelectedAmmo = aGetSetting("ammo") or 30
	guiCreateToolTip("Right click to set ammo", aPlayersTab.gui.giveWeaponBtn)

	aPlayersTab.gui.takeWeaponBtn, aPlayersTab.gui.takeWeaponList =
		guiCreateComboBoxButton(0.71, 0.53, 0.27, 0.04, "Take", true, tab, "takeweapon")
	guiGridListAdjustHeight(aPlayersTab.gui.takeWeaponList, 12)
	aPlayersTab.gui.takeWeaponSrch = guiCreateSearchEdit(5, 3, 135, 18, "", false, aPlayersTab.gui.takeWeaponList)
	guiSetProperty(aPlayersTab.gui.takeWeaponSrch, "AlwaysOnTop", "True")
	guiGridListRegisterSearch(aPlayersTab.gui.takeWeaponList, aPlayersTab.gui.takeWeaponSrch)
	aPlayersTab.RefreshTakeWeapon()	

	aPlayersTab.gui.setMoneyBtn = guiCreateButton(0.71, 0.575, 0.13, 0.04, "Set Money", true, tab, "setmoney")
	aPlayersTab.gui.setStatsBtn = guiCreateButton(0.85, 0.575, 0.13, 0.04, "Set Stats", true, tab, "setstat")
	aPlayersTab.gui.jetPackBtn = guiCreateButton(0.71, 0.62, 0.27, 0.04, "Give JetPack", true, tab, "givejetpack")
	
	aPlayersTab.gui.warpBtn = guiCreateButton(0.71, 0.665, 0.13, 0.04, "Warp", true, tab, "warp")
	aPlayersTab.gui.warpMeBtn = guiCreateButton(0.85, 0.665, 0.13, 0.04, "Warp me", true, tab, "warpme")

	aPlayersTab.gui.warpToInteriorBtn = guiCreateButton(0.71, 0.71, 0.27, 0.04, "Warp to interior", true, tab, "warptointerior")
   
	-----------------------------
	guiCreateHeader(0.23, 0.805, 0.20, 0.04, "Vehicle:", true, tab)

	aPlayersTab.gui.vehicleLbl = guiCreateLabel(0.24, 0.850, 0.35, 0.04, "Vehicle: N/A", true, tab)
	aPlayersTab.gui.vehicleHealthLbl = guiCreateLabel(0.24, 0.895, 0.25, 0.04, "Health: N/A", true, tab)
	aPlayersTab.gui.vehicleDriverLbl = guiCreateLabel(0.24, 0.940, 0.25, 0.04, "Driver: N/A", true, tab)

	aPlayersTab.gui.fixVehicleBtn = guiCreateButton(0.71, 0.90, 0.13, 0.04, "Fix", true, tab, "repair")
	aPlayersTab.gui.destroyVehicleBtn = guiCreateButton(0.71, 0.95, 0.13, 0.04, "Destroy", true, tab, "destroyvehicle")
	aPlayersTab.gui.blowVehicleBtn = guiCreateButton(0.85, 0.90, 0.13, 0.04, "Blow", true, tab, "blowvehicle")
	aPlayersTab.gui.customizeVehicleBtn = guiCreateButton(0.85, 0.95, 0.13, 0.04, "Customize", true, tab, "addupgrades")

	aPlayersTab.gui.ejectBtn = guiCreateButton(0.57, 0.85, 0.13, 0.04, "Eject", true, tab, "eject")
	aPlayersTab.gui.giveVehicleBtn, aPlayersTab.gui.giveVehicleList =
		guiCreateComboBoxButton(0.71, 0.85, 0.27, 0.04, "Give", true, tab, "givevehicle")
	guiGridListAdjustHeight(aPlayersTab.gui.giveVehicleList, 10)
	aPlayersTab.gui.giveVehicleSrch = guiCreateSearchEdit(5, 3, 135, 18, "", false, aPlayersTab.gui.giveVehicleList)
	guiSetProperty(aPlayersTab.gui.giveVehicleSrch, "AlwaysOnTop", "True")
	guiGridListRegisterSearch(aPlayersTab.gui.giveVehicleList, aPlayersTab.gui.giveVehicleSrch)
	aPlayersTab.RefreshGiveVehicle()
	if not aPlayersTab.SetSelectedVehicle(aGetSetting("vehicle")) then
		aPlayersTab.SetSelectedVehicle(411) -- infernus
	end

	-----------------------------

	addEventHandler("onClientGUIClick", aPlayersTab.gui.dataCtext, aPlayersTab.onDataContextClickHandler)
	addEventHandler("onClientGUIClick", aPlayersTab.gui.tab, aPlayersTab.onClickHandler)
	addEventHandler("onClientGUIClick", aPlayersTab.gui.tab, aPlayersTab.onRightClickHandler)
	addEventHandler("onClientGUIChanged", aPlayersTab.gui.srch, aPlayersTab.Refresh, false)
	addEventHandler("onClientGUIChanged", aPlayersTab.gui.giveWeaponSrch, aPlayersTab.RefreshGiveWeapon, false)
	addEventHandler("onClientGUIChanged", aPlayersTab.gui.takeWeaponSrch, aPlayersTab.RefreshTakeWeapon, false)
	addEventHandler("onClientGUIChanged", aPlayersTab.gui.giveVehicleSrch, aPlayersTab.RefreshGiveVehicle, false)
	
	addEventHandler(EVENT_PLAYER_JOIN, root, aPlayersTab.onPlayerJoinHandler)
	addEventHandler("onClientPlayerChangeNick", root, aPlayersTab.onPlayerChangeNickHandler)
	addEventHandler("onClientPlayerQuit", root, aPlayersTab.onPlayerQuitHandler)
	addEventHandler("onClientResourceStop", resourceRoot, aPlayersTab.SaveSettings)

	addEventHandler(EVENT_SYNC, localPlayer, aPlayersTab.onSyncHandler)
	addEventHandler("onAdminRefresh", aPlayersTab.gui.tab, aPlayersTab.onRefreshHandler)

	sync(SYNC_PLAYER, SYNC_LIST)
	sync(SYNC_ADMIN_GROUP, SYNC_LIST)

	--if (hasPermissionTo("command.listreports")) then
	--	sync(SYNC_MESSAGES)
	--end

end

function aPlayersTab.Destroy()
	if not aPlayersTab.gui.tab then return end

	removeEventHandler(EVENT_SYNC, localPlayer, aPlayersTab.onSyncHandler)
	removeEventHandler("onClientResourceStop", resourceRoot, aPlayersTab.SaveSettings)
	removeEventHandler("onClientPlayerQuit", root, aPlayersTab.onPlayerQuitHandler)
	removeEventHandler("onClientPlayerChangeNick", root, aPlayersTab.onPlayerChangeNickHandler)
	removeEventHandler(EVENT_PLAYER_JOIN, root, aPlayersTab.onPlayerJoinHandler)
	aPlayersTab.SaveSettings()
	aPlayersTab.gui = {}
	aPlayersTab.List = {}
end

function aPlayersTab.onDataContextClickHandler(button)
	if source == aPlayersTab.gui.dataCopyCtextItem then
		local copy = string.match(guiGetText(contextSource), "%a+:%s(.+)")
		if not copy then return end
		setClipboard(copy)
	end
end

function aPlayersTab.onClickHandler(button)
	if button ~= "left" then return end

	if source == aPlayersTab.gui.reportsBtn then
		return aReports.Open()

	elseif source == aPlayersTab.gui.colorCodesChk then
		return aPlayersTab.Refresh()

	elseif source == aPlayersTab.gui.list then
		aPlayersTab.RefreshPlayer()
		if guiCheckBoxGetSelected(aPlayersTab.gui.outputConsoleChk) then
			aPlayersTab.OutputConsoleInfo()
		end
		return

	end

	if getElementType(source) ~= "gui-button" then return end

	local player = aPlayersTab.GetSelected()
	if not player then
		messageBox("No player selected!", MB_ERROR)
		return
	end

	local name = stripColorCodes(getPlayerName(player))
	if source == aPlayersTab.gui.kickBtn then
		local reason = inputBox("Kick player "..name, "Enter the kick reason")
		if not reason then return end
		if reason == "" then reason = nil end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "kick", player, reason)

	elseif source == aPlayersTab.gui.banBtn then
		local name = stripColorCodes(getPlayerName(player))
		local serial, ip = aPlayersTab.List[player].serial, aPlayersTab.List[player].ip
		local duration, includeIP, reason = aBan.Open(true, serial, ip, name)
		if not duration then return end
		if isElement(player) then
			triggerServerEvent(EVENT_COMMAND, localPlayer, "ban", player, ip, duration, reason)
		else
			if not hasPermissionTo("command.banserial") then return messageBox("Player left the server", MB_ERROR) end
			if not messageBox("Player left the server. Ban serial?", MB_QUESTION, MB_YESNO) then return end
			
			local serial, ip, nick, duration, reason = aBan.Open(false, serial, includeIP and ip, name, duration, reason)
			if not serial then return end

			triggerServerEvent(EVENT_COMMAND, localPlayer, "banserial", serial, ip, nick, duration, reason)
		end

	elseif source == aPlayersTab.gui.muteBtn then
		if aPlayersTab.List[player].mute then
			triggerServerEvent(EVENT_COMMAND, localPlayer, "unmute", player)
		else
			local name = stripColorCodes(getPlayerName(player))
			local serial = aPlayersTab.List[player].serial
			local duration, reason = aMute.Open(true, serial, name)
			if not duration then return end
			if isElement(player) then
				triggerServerEvent(EVENT_COMMAND, localPlayer, "mute", player, duration, reason)
			else
				if not hasPermissionTo("command.muteserial") then return messageBox("Player left the server", MB_ERROR) end
				if not messageBox("Player left the server. Mute serial?", MB_QUESTION, MB_YESNO) then return end
				
				local serial, nick, duration, reason = aMute.Open(false, serial, name, duration, reason)
				if not serial then return end
				
				triggerServerEvent(EVENT_COMMAND, localPlayer, "muteserial", serial, nick, duration, reason)
			end
		end
	  
	elseif source == aPlayersTab.gui.freezeBtn then
		triggerServerEvent(
			EVENT_COMMAND,
			localPlayer,
			isElementFrozen(player) and "unfreeze" or "freeze",
			player
		)

	elseif source == aPlayersTab.gui.spectateBtn then
		aSpectate(player)

	elseif source == aPlayersTab.gui.slapBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "slap", player, aPlayersTab.GetSelectedSlap())

	elseif source == aPlayersTab.gui.setNickBtn then
		local nick = inputBox("Set nick", "Enter new nickname for "..name, getPlayerName(player), true)
		if not nick then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setnick", player, nick)

	elseif source == aPlayersTab.gui.shoutBtn then
		local text = inputBox("Shout", "Enter text to be shown on player's screen", nil, true)
		if not text then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "shout", player, text)

	elseif source == aPlayersTab.gui.setGroupBtn then
		local group = aPlayersTab.GetSelectedAdminGroup()
		if group == "None" then
			if not messageBox("Player admin rights will be revoked. Continue?", MB_WARNING, MB_YESNO) then return end
			triggerServerEvent(EVENT_COMMAND, localPlayer, "resetadmingroup", player)
		else
			if not messageBox("Player admin rights will be set to '"..group.."' group. Continue?", MB_WARNING, MB_YESNO) then return end
			triggerServerEvent(EVENT_COMMAND, localPlayer, "setadmingroup", player, group)
		end

	elseif source == aPlayersTab.gui.setHealthBtn then
		local health = inputBox("Set health", "Enter the health value", "100", true, true)
		if not health then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "sethealth", player, health)

	elseif source == aPlayersTab.gui.setArmourBtn then
		local armour = inputBox("Set armour", "Enter the armour value", "100", true, true)
		if not armour then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setarmour", player, armour)

	elseif source == aPlayersTab.gui.setSkinBtn then
		aSkin.Show(player)

	elseif source == aPlayersTab.gui.setTeamBtn then
		--aTeam.Show()

	elseif source == aPlayersTab.gui.giveWeaponBtn then
		triggerServerEvent(
			EVENT_COMMAND,
			localPlayer,
			"giveweapon",
			player,
			aPlayersTab.GetSelectedWeapon(),
			aPlayersTab.SelectedAmmo
		)

	elseif source == aPlayersTab.gui.takeWeaponBtn then
		local selected = aPlayersTab.GetSelectedTakeWeapon()
		if selected == -1 then
			triggerServerEvent(EVENT_COMMAND, localPlayer, "takeallweapon", player)
		else
			triggerServerEvent(EVENT_COMMAND, localPlayer, "takeweapon", player, selected)
		end

	elseif source == aPlayersTab.gui.setMoneyBtn then
		local money = inputBox("Set money", "Enter the money value", aPlayersTab.List[player].money, true, true)
		if not money then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setmoney", player, money)

	elseif source == aPlayersTab.gui.setStatsBtn then
		aStats.Open(player)

	elseif source == aPlayersTab.gui.jetPackBtn then
		if doesPedHaveJetPack(player) then
			triggerServerEvent(EVENT_COMMAND, localPlayer, "removejetpack", player)
		else
			triggerServerEvent(EVENT_COMMAND, localPlayer, "givejetpack", player)
		end

	elseif source == aPlayersTab.gui.warpBtn then
		local toplayer = aPlayer.Open()
		if not toplayer then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "warp", player, toplayer)

	elseif source == aPlayersTab.gui.warpMeBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "warpme", player)

	elseif source == aPlayersTab.gui.warpToInteriorBtn then
		local interior = aInterior.Open()
		if not interior then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "warptointerior", player, interior)

	elseif source == aPlayersTab.gui.setDimensionBtn then
		local dimension = inputBox("Set dimension", "Enter dimension ID between 0 and 65535", getElementDimension(player), true, true)
		if not dimension then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setdimension", player, dimension)
	
	elseif source == aPlayersTab.gui.setInteriorBtn then
		local interior = inputBox("Set interior", "Enter interior ID between 0 and 255", getElementInterior(player), true, true)
		if not interior then return end
		triggerServerEvent(EVENT_COMMAND, localPlayer, "setinterior", player, interior)

	elseif source == aPlayersTab.gui.giveVehicleBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "givevehicle", player, aPlayersTab.GetSelectedVehicle())

	elseif source == aPlayersTab.gui.ejectBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "eject", player)

	elseif source == aPlayersTab.gui.fixVehicleBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "repair", player)

	elseif source == aPlayersTab.gui.blowVehicleBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "blowvehicle", player)

	elseif source == aPlayersTab.gui.destroyVehicleBtn then
		triggerServerEvent(EVENT_COMMAND, localPlayer, "destroyvehicle", player)

	elseif source == aPlayersTab.gui.customizeVehicleBtn then
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle then return messageBox("Player doesn't have vehicle", MB_ERROR) end
		aVehicle.Open(player, vehicle)

	--elseif source == aPlayersTab.gui.giveAdminBtn then
	--	if (
	--		aPlayersTab.List[player]["admin"] and
	--		messageBox("Revoke admin rights from "..name.."?", MB_WARNING, MB_YESNO)
	--	) then
	--		triggerServerEvent(EVENT_COMMAND, localPlayer, player, "setgroup", "Admin", true)
	--	elseif (messageBox("Give admin rights to "..name.."?", MB_WARNING, MB_YESNO)) then
	--		triggerServerEvent(EVENT_COMMAND, localPlayer, player, "setgroup", "Admin", false)
	--	end
	end
end

function aPlayersTab.onRightClickHandler(key)
	if key ~= "right" then return end

	if source == aPlayersTab.gui.giveWeaponBtn then
		local ammo = inputBox("Weapon Ammo", "Enter ammo value", aPlayersTab.SelectedAmmo, true, true)
		if not ammo then return end

		ammo = math.clamp(ammo, 1, 10000)
		aPlayersTab.SelectedAmmo = ammo
	end
end

function aPlayersTab.onPlayerListScrollHandler(key, state, inc)
	if (not guiGetVisible(aAdminMain.Form)) then
		return
	end
	local max = guiGridListGetRowCount(aPlayersTab.gui.list)
	if (max <= 0) then
		return
	end
	local current = guiGridListGetSelectedItem(aPlayersTab.gui.list)
	local next = current + inc
	max = max - 1
	if (current == -1) then
		guiGridListSetSelectedItem(aPlayersTab.gui.list, 0, 1)
	elseif (next > max) then
		return
	elseif (next < 0) then
		return
	else
		guiGridListSetSelectedItem(aPlayersTab.gui.list, next, 1)
	end
end

function aPlayersTab.onPlayerChangeNickHandler(oldNick, newNick)
	local list = aPlayersTab.gui.list
	for row = 0, guiGridListGetRowCount(list)-1 do
		if guiGridListGetItemData(list, row, 1) == source then
			if guiCheckBoxGetSelected(aPlayersTab.gui.colorCodesChk) then
				guiGridListSetItemText(list, row, 1, stripColorCodes(newNick), false, false)
			else
				guiGridListSetItemText(list, row, 1, newNick, false, false)
			end
			break
		end
	end
end

function aPlayersTab.onPlayerJoinHandler(ip, serial, version, country, countryname)
	aPlayersTab.List[source] = {
		name = getPlayerName(source),
		ip = ip,
		serial = serial,
		version = version,
		country = country,
		countryname = countryname
	}

	local list = aPlayersTab.gui.list
	local row = guiGridListAddRow(list)
	local name = getPlayerName(source)
	if guiCheckBoxGetSelected(aPlayersTab.gui.colorCodesChk) then
		name = stripColorCodes(name)
	end
	guiGridListSetItemText(list, row, 1, name, false, false)
	guiGridListSetItemData(list, row, 1, source)
	--if (aSpecPlayerList) then
	--	local row = guiGridListAddRow(aSpecPlayerList)
	--	guiGridListSetItemText(aSpecPlayerList, row, 1, getPlayerName(source), false, false)
	--end
end

function aPlayersTab.onPlayerQuitHandler()
	local list = aPlayersTab.gui.list
	for row = 0, guiGridListGetRowCount(list)-1 do
		if guiGridListGetItemData(list, row, 1) == source then
			guiGridListRemoveRow(list, row)
			break
		end
	end
	--if (aSpecPlayerList) then
	--	local id = 0
	--	while (id <= guiGridListGetRowCount(aSpecPlayerList)) do
	--		if (guiGridListGetItemText(aSpecPlayerList, id, 1) == getPlayerName(source)) then
	--			guiGridListRemoveRow(aSpecPlayerList, id)
	--		end
	--		id = id + 1
	--	end
	--end
	aPlayersTab.List[source] = nil
	aPlayersTab.RefreshPlayer()
end

aPlayersTab.SyncFunctions = {
	[SYNC_PLAYER] = {
		[SYNC_SINGLE] = function(player, data)
			if not aPlayersTab.List[player] then return end
			for k, v in pairs(data) do
				aPlayersTab.List[player][k] = v
			end
		end,
		[SYNC_LIST] = function(data)
			aPlayersTab.List = data
			aPlayersTab.Refresh()
		end
	},

	[SYNC_ADMIN_GROUP] = {
		[SYNC_LIST] = function(data)
			aPlayersTab.SetAdminGroups(data)
		end
	}
	
}
function aPlayersTab.onSyncHandler(dataType, syncType, ...)
	if dataType ~= SYNC_PLAYER and dataType ~= SYNC_ADMIN_GROUP then return end
	aPlayersTab.SyncFunctions[dataType][syncType](...)
end

function aPlayersTab.onRefreshHandler()
	local player = aPlayersTab.GetSelected()
	if not player then return end

	local data = aPlayersTab.List[player]
	if not data then return end

	guiSetText(aPlayersTab.gui.accountLbl, "Account: "..(aPlayersTab.List[player].account or "N/A"))
	guiSetText(aPlayersTab.gui.groupsLbl, "Groups: "..(aPlayersTab.List[player].groups and table.concat(aPlayersTab.List[player].groups, ", ") or "N/A"))
	guiSetText(aPlayersTab.gui.nameLbl, "Name: "..getPlayerName(player))
	
	guiSetText(aPlayersTab.gui.muteBtn, aPlayersTab.List[player].mute and "Unmute" or "Mute")
	guiSetText(aPlayersTab.gui.freezeBtn, isElementFrozen(player) and "Unfreeze" or "Freeze")
	guiSetText(aPlayersTab.gui.healthLbl, "Health: "..(isPedDead(player) and "Dead" or math.ceil(getElementHealth(player))))
	guiSetText(aPlayersTab.gui.armourLbl, "Armour: "..math.ceil(getPedArmor(player)))
	guiSetText(aPlayersTab.gui.skinLbl, "Skin: "..(getElementModel(player) or "N/A"))

	local team = getPlayerTeam(player)
	if team then
		guiSetText(aPlayersTab.gui.teamLbl, "Team: "..getTeamName(team))
	else
		guiSetText(aPlayersTab.gui.teamLbl, "Team: None")
	end

	guiSetText(aPlayersTab.gui.pingLbl, "Ping: "..(getPlayerPing(player) or "N/A"))
	guiSetText(aPlayersTab.gui.fpsLbl, "FPS: "..(aPlayersTab.List[player].fps or "N/A"))
	guiSetText(aPlayersTab.gui.moneyLbl, "Money: "..(aPlayersTab.List[player].money or "N/A"))
	guiSetText(aPlayersTab.gui.dimensionLbl, "Dimension: "..(getElementDimension(player) or "N/A"))
	guiSetText(aPlayersTab.gui.interiorLbl, "Interior: "..(getElementInterior(player) or "N/A"))
	guiSetText(aPlayersTab.gui.jetPackBtn, doesPedHaveJetPack(player) and "Remove JetPack" or "Give JetPack")

	local weapon = getPedWeapon(player)
	if weapon then
		guiSetText(aPlayersTab.gui.weaponLbl, "Weapon: "..getWeaponNameFromID(weapon).." (ID: "..weapon..")")
	else
		guiSetText(aPlayersTab.gui.weaponLbl, "Weapon: N/A")
	end

	local x, y, z = getElementPosition(player)
	local area = getZoneName(x, y, z, false)
	local city = getZoneName(x, y, z, true)
	if area == city then area = "None" end
	guiSetText(aPlayersTab.gui.areaLbl, "Area: "..area.." ("..city..")")
	guiSetText(aPlayersTab.gui.posXLbl, "X: "..math.round(x, 6))
	guiSetText(aPlayersTab.gui.posYLbl, "Y: "..math.round(y, 6))
	guiSetText(aPlayersTab.gui.posZLbl, "Z: "..math.round(z, 6))

	local vehicle = getPedOccupiedVehicle(player)
	if vehicle then
		guiSetText(
			aPlayersTab.gui.vehicleLbl,
			"Vehicle: "..getVehicleName(vehicle).." (ID: "..getElementModel(vehicle)..")"
		)
		guiSetText(aPlayersTab.gui.vehicleHealthLbl, "Health: "..math.ceil(getElementHealth(vehicle)))
		local driver = getVehicleOccupant(vehicle)
		if driver then
			guiSetText(aPlayersTab.gui.vehicleDriverLbl, "Driver: "..getPlayerName(driver))
		else
			guiSetText(aPlayersTab.gui.vehicleDriverLbl, "Driver: None")
		end
	else
		guiSetText(aPlayersTab.gui.vehicleLbl, "Vehicle: Foot")
		guiSetText(aPlayersTab.gui.vehicleHealthLbl, "Health: N/A")
		guiSetText(aPlayersTab.gui.vehicleDriverLbl, "Driver: N/A")
	end
end

function aPlayersTab.SaveSettings()
	aSetSetting("vehicle", aPlayersTab.GetSelectedVehicle())
	aSetSetting("weapon", aPlayersTab.GetSelectedWeapon())
	aSetSetting("takeWeapon", aPlayersTab.GetSelectedTakeWeapon())
	aSetSetting("ammo", aPlayersTab.SelectedAmmo)
	aSetSetting("slap", aPlayersTab.GetSelectedSlap())
	aSetSetting("outputConsole", guiCheckBoxGetSelected(aPlayersTab.gui.outputConsoleChk))
	aSetSetting("stripColorCodes", guiCheckBoxGetSelected(aPlayersTab.gui.colorCodesChk))
end

function aPlayersTab.GetStripColorCodesState()
	guiCheckBoxGetSelected(aPlayersTab.gui.colorCodesChk)
end

function aPlayersTab.GetSelected()
	local list = aPlayersTab.gui.list
	local item = guiGridListGetSelectedItem(list)
	if item == -1 then return nil end
	return guiGridListGetItemData(list, item, 1)
end

function aPlayersTab.RefreshReports()
	if not aPlayersTab.gui.tab then return end

	local new = 0
	for id, data in pairs(aReports.List) do
		if not data.read then new = new + 1 end
	end
	if new > 0 then
		guiSetText(aPlayersTab.gui.reportsBtn, "Reports("..new..")...")
		-- aColors ???
		--guiButtonSetTextColor(aPlayersTab.gui.reportsBtn, 255, 127, 63)
	else
		guiSetText(aPlayersTab.gui.reportsBtn, "Reports...")
	end

	--local prev = tonumber(string.sub(guiGetText(aPlayersTab.gui.reportsBtn), 1, 1))
	--if (prev < table["unread"]) then
	--	playSoundFrontEnd(18)
	--end
	--guiSetText(aPlayersTab.gui.reportsBtn, table["unread"].."/"..table["total"].." unread messages")
	--if (table["unread"] > 0) then
	--	guiSetProperty(aPlayersTab.gui.reportsBtn, "NormalTextColour", "FFFF6432")
	--else
	--	guiSetProperty(aPlayersTab.gui.reportsBtn, "NormalTextColour", "FF7C7C7C")
	--end
end

function aPlayersTab.Refresh()
	local selected = aPlayersTab.GetSelected()
	local list = aPlayersTab.gui.list
	guiGridListClear(list)

	local strip = guiCheckBoxGetSelected(aPlayersTab.gui.colorCodesChk)
	local search = string.lower(guiGetText(aPlayersTab.gui.srch))
	
	for id, player in ipairs(getElementsByType("player")) do
		local n = getPlayerName(player)
		local name = strip and stripColorCodes(n) or n
		local pstr = string.lower(
			n..
			(aPlayersTab.List[player].serial or "")..
			(aPlayersTab.List[player].ip or "")..
			(aPlayersTab.List[player].account or "")
		)
		if string.find(pstr, search, 1, true) then
			local row = guiGridListAddRow(list, name)
			guiGridListSetItemData(list, row, 1, player)
			if selected == player then
				guiGridListSetSelectedItem(list, row, 1)
			end
		end
	end
	if guiGridListGetSelectedItem(list) == -1 and guiGridListGetRowCount(list) > 0 then
		guiGridListSetSelectedItem(list, 0, 1)
	end
	aPlayersTab.RefreshPlayer()
end

function aPlayersTab.SetContentMessage(message)
	if not message then message = "" end
	guiSetText(aPlayersTab.gui.nameLbl, "Name: "..message)
	guiSetText(aPlayersTab.gui.IPLbl, "IP: "..message)
	guiSetText(aPlayersTab.gui.serialLbl, "Serial: "..message)
	guiSetText(aPlayersTab.gui.versionLbl, "Version: "..message)
	guiSetText(aPlayersTab.gui.accountLbl, "Account: "..message)
	guiSetText(aPlayersTab.gui.countryLbl, "Country: "..message)
	guiSetVisible(aPlayersTab.gui.flagImg, false)
	guiSetText(aPlayersTab.gui.groupsLbl, "Groups: "..message)
	guiSetText(aPlayersTab.gui.healthLbl, "Health: "..message)
	guiSetText(aPlayersTab.gui.armourLbl, "Armour: "..message)
	guiSetText(aPlayersTab.gui.skinLbl, "Skin: "..message)
	guiSetText(aPlayersTab.gui.teamLbl, "Team: "..message)
	guiSetText(aPlayersTab.gui.pingLbl, "Ping: "..message)
	guiSetText(aPlayersTab.gui.fpsLbl, "FPS: "..message)
	guiSetText(aPlayersTab.gui.moneyLbl, "Money: "..message)
	guiSetText(aPlayersTab.gui.dimensionLbl, "Dimension: "..message)
	guiSetText(aPlayersTab.gui.interiorLbl, "Interior: "..message)
	guiSetText(aPlayersTab.gui.weaponLbl, "Weapon: "..message)
	guiSetText(aPlayersTab.gui.areaLbl, "Area: "..message)
	guiSetText(aPlayersTab.gui.posXLbl, "X: "..message)
	guiSetText(aPlayersTab.gui.posYLbl, "Y: "..message)
	guiSetText(aPlayersTab.gui.posZLbl, "Z: "..message)
	guiSetText(aPlayersTab.gui.vehicleLbl, "Vehicle: "..message)
	guiSetText(aPlayersTab.gui.vehicleHealthLbl, "Health: "..message)
	guiSetText(aPlayersTab.gui.vehicleDriverLbl, "Driver: "..message)
end

function aPlayersTab.RefreshFlag(country)
	if not country then return guiSetVisible(aPlayersTab.gui.flagImg, false) end
	if not fileExists("client/images/flags/"..string.lower(country)..".png") then return end
	
	local x, y = guiGetPosition(aPlayersTab.gui.countryLbl, false)
	local width = guiLabelGetTextExtent(aPlayersTab.gui.countryLbl)
	guiSetPosition(aPlayersTab.gui.flagImg, x + width + 3, y + 4, false)
	guiSetVisible(aPlayersTab.gui.flagImg, guiStaticImageLoadImage(
		aPlayersTab.gui.flagImg,
		"client/images/flags/"..string.lower(country)..".png"
	))
end

function aPlayersTab.RefreshPlayer()
	local player = aPlayersTab.GetSelected()
	if not player then
		guiSetVisible(aPlayersTab.gui.flagImg, false)
		guiSetText(aPlayersTab.gui.muteBtn, "Mute")
		guiSetText(aPlayersTab.gui.freezeBtn, "Freeze")
		--guiSetText(aPlayersTab.gui.giveAdminBtn, "Give admin rights")
		guiSetText(aPlayersTab.gui.jetPackBtn, "Give JetPack")
		aPlayersTab.SetContentMessage("N/A")
		return
	end

	aPlayersTab.onRefreshHandler()
	sync(SYNC_PLAYER, SYNC_SINGLE, player)

	guiSetText(aPlayersTab.gui.IPLbl, "IP: "..(aPlayersTab.List[player].ip or "N/A"))
	guiSetText(aPlayersTab.gui.versionLbl, "Version: "..(aPlayersTab.List[player].version or "N/A"))
	guiSetText(aPlayersTab.gui.serialLbl, "Serial: "..(aPlayersTab.List[player].serial or "N/A"))
	guiSetText(aPlayersTab.gui.countryLbl, "Country: "..(aPlayersTab.List[player].countryname or "N/A"))
	aPlayersTab.RefreshFlag(aPlayersTab.List[player].country)
end

function aPlayersTab.OutputConsoleInfo()
	local player = aPlayersTab.GetSelected()
	if not player then return end

	local x, y, z = getElementPosition(player)
	outputConsole(LOG_PREFIX..": player info:")
	outputConsole("    name: "..getPlayerName(player))
	outputConsole("    simple name: "..stripColorCodes(getPlayerName(player)))
	outputConsole("    account: "..aPlayersTab.List[player].account)
	outputConsole("    serial: "..aPlayersTab.List[player].serial)
	outputConsole("    version: "..aPlayersTab.List[player].version)
	outputConsole("    IP: "..aPlayersTab.List[player].ip)
	outputConsole("    country: "..(aPlayersTab.List[player].countryname or "N/A"))
	outputConsole("    position: X: "..x.." Y: "..y.." Z: "..z)
end

function aPlayersTab.SetAdminGroups(groups)
	local selected = aPlayersTab.GetSelectedAdminGroup()
	guiGridListClear(aPlayersTab.gui.setGroupList)
	guiGridListAddRow(aPlayersTab.gui.setGroupList, "None")
	guiComboBoxButtonSetSelected(aPlayersTab.gui.setGroupBtn, 0)
	for i, group in ipairs(groups) do
		guiGridListAddRow(aPlayersTab.gui.setGroupList, group)
		if selected == i then
			guiComboBoxButtonSetSelected(aPlayersTab.gui.setGroupBtn, i)
		end
	end
	guiGridListAdjustHeight(aPlayersTab.gui.setGroupList)
end

function aPlayersTab.GetSelectedAdminGroup()
	return guiGridListGetItemText(aPlayersTab.gui.setGroupList, guiGridListGetSelectedItem(aPlayersTab.gui.setGroupList), 1)
end

function aPlayersTab.GetSelectedSlap()
	return tonumber(guiGridListGetItemText(aPlayersTab.gui.slapList, guiGridListGetSelectedItem(aPlayersTab.gui.slapList), 1))
end

function aPlayersTab.GetSelectedWeapon()
	return guiGridListGetItemData(aPlayersTab.gui.giveWeaponList, guiGridListGetSelectedItem(aPlayersTab.gui.giveWeaponList), 1)
end

function aPlayersTab.SetSelectedWeapon(id)
	for row = 0, guiGridListGetRowCount(aPlayersTab.gui.giveWeaponList) do
		if guiGridListGetItemData(aPlayersTab.gui.giveWeaponList, row, 1) == id then
			return guiComboBoxButtonSetSelected(aPlayersTab.gui.giveWeaponBtn, row)
		end
	end
	return false
end

function aPlayersTab.RefreshGiveWeapon()
	local selected = aPlayersTab.GetSelectedWeapon()
	guiGridListClear(aPlayersTab.gui.giveWeaponList)

	local search = string.lower(guiGetText(aPlayersTab.gui.giveWeaponSrch))
	for i, id in ipairs(getValidWeaponIDs()) do
		local name = getWeaponNameFromID(id)
		if string.find(string.lower(name), search, 1, true) then
			local row = guiGridListAddRow(aPlayersTab.gui.giveWeaponList, name)
			guiGridListSetItemData(aPlayersTab.gui.giveWeaponList, row, 1, id)
			if id == selected then
				guiComboBoxButtonSetSelected(aPlayersTab.gui.giveWeaponBtn, row)
			end
		end
	end
	if guiGridListGetRowCount(aPlayersTab.gui.giveWeaponList) == 0 then
		guiGridListAddRow(aPlayersTab.gui.giveWeaponList, getWeaponNameFromID(selected))
		guiGridListSetItemData(aPlayersTab.gui.giveWeaponList, 0, 1, selected)
	end
	if guiGridListGetSelectedItem(aPlayersTab.gui.giveWeaponList) == -1 then
		guiComboBoxButtonSetSelected(aPlayersTab.gui.giveWeaponBtn, 0)
	end
end

function aPlayersTab.GetSelectedTakeWeapon()
	return guiGridListGetItemData(aPlayersTab.gui.takeWeaponList, guiGridListGetSelectedItem(aPlayersTab.gui.takeWeaponList), 1)
end

function aPlayersTab.RefreshTakeWeapon()
	guiGridListClear(aPlayersTab.gui.takeWeaponList)

	guiGridListAddRow(aPlayersTab.gui.takeWeaponList, "All")
	guiGridListSetItemData(aPlayersTab.gui.takeWeaponList, 0, 1, -1)

	local search = string.lower(guiGetText(aPlayersTab.gui.takeWeaponSrch))
	for i, id in ipairs(getValidWeaponIDs()) do
		local name = getWeaponNameFromID(id)
		if string.find(string.lower(name), search, 1, true) then
			local row = guiGridListAddRow(aPlayersTab.gui.takeWeaponList, name)
			guiGridListSetItemData(aPlayersTab.gui.takeWeaponList, row, 1, id)
		end
	end
	if guiGridListGetRowCount(aPlayersTab.gui.takeWeaponList) > 1 and search ~= "" then
		guiComboBoxButtonSetSelected(aPlayersTab.gui.takeWeaponBtn, 1)
	else
		guiComboBoxButtonSetSelected(aPlayersTab.gui.takeWeaponBtn, 0)
	end
end

function aPlayersTab.GetSelectedVehicle()
	return guiGridListGetItemData(aPlayersTab.gui.giveVehicleList, guiGridListGetSelectedItem(aPlayersTab.gui.giveVehicleList), 1)
end

function aPlayersTab.SetSelectedVehicle(model)
	for row = 0, guiGridListGetRowCount(aPlayersTab.gui.giveVehicleList) do
		if guiGridListGetItemData(aPlayersTab.gui.giveVehicleList, row, 1) == model then
			return guiComboBoxButtonSetSelected(aPlayersTab.gui.giveVehicleBtn, row)
		end
	end
	return false
end

function aPlayersTab.RefreshGiveVehicle()
	local sortedVehicleIDs = {}
	for i, id in ipairs(getValidVehicleModels()) do
		table.insert(sortedVehicleIDs, {id, getVehicleNameFromModel(id)})
	end
	table.sort(sortedVehicleIDs, function(a, b) return a[2] < b[2] end)

	local selected = aPlayersTab.GetSelectedVehicle()
	guiGridListClear(aPlayersTab.gui.giveVehicleList)

	local search = string.lower(guiGetText(aPlayersTab.gui.giveVehicleSrch))
	for i, data in ipairs(sortedVehicleIDs) do
		if string.find(string.lower(data[2]), search, 1, true) then
			local row = guiGridListAddRow(aPlayersTab.gui.giveVehicleList, data[2])
			guiGridListSetItemData(aPlayersTab.gui.giveVehicleList, row, 1, data[1])
			if data[1] == selected then
				guiComboBoxButtonSetSelected(aPlayersTab.gui.giveVehicleBtn, row)
			end
		end
	end
	if guiGridListGetRowCount(aPlayersTab.gui.giveVehicleList) == 0 then
		guiGridListAddRow(aPlayersTab.gui.giveVehicleList, getVehicleNameFromModel(selected))
		guiGridListSetItemData(aPlayersTab.gui.giveVehicleList, 0, 1, selected)
	end
	if guiGridListGetSelectedItem(aPlayersTab.gui.giveVehicleList) == -1 then
		guiComboBoxButtonSetSelected(aPlayersTab.gui.giveVehicleBtn, 0)
	end
end

function aGetPlayerSerial(player)
	if not aPlayersTab.List[player] then return false end
	return aPlayersTab.List[player].serial
end

function aGetPlayerBySerial(serial)
	for player, data in pairs(aPlayersTab.List) do
		if data.serial and data.serial == serial then return player end
	end
	return nil
end