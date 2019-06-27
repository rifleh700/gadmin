
local aCommands = {
	Data = {},
	List = {}
}

addEvent(EVENT_COMMAND, true)

function aSetupCommands()
	local node = xmlLoadFile("conf/commands.xml", true)
	if not node then return end

	for i, subnode in ipairs(xmlNodeGetChildren(node)) do
		if xmlNodeGetName(subnode) == "command" then
			local command = xmlNodeGetAttribute(subnode, "name")
			local args = xmlNodeGetAttribute(subnode, "args")
			local argnames = xmlNodeGetAttribute(subnode, "argnames")
			local player = xmlNodeGetAttribute(subnode, "player") == "true" or false
	
			local types, otypes = split2(args, "[")
			types = split(types, ",")
			otypes = otypes and split(otypes, ",") or {}
	
			local optpos = #types + 1
			table.iadd(types, otypes)
	
			argnames = split(argnames, ",")

			aCommands.List[#aCommands.List + 1] = command 
			aCommands.Data[command] = {
				args = types,
				optpos = optpos,
				argnames = argnames,
				player = player
			}
			addCommandHandler(command, aCommands.Execute, true)
		end
	end
	xmlUnloadFile(node)

	addCommandHandler("ahelp", aCommands.Help)
end

function aCommands.Help(admin)
	if get("consolecommands") ~= true then return end
	if not hasObjectPermissionTo(admin, "general.adminpanel") then return end

	for i, command in ipairs(aCommands.List) do
		if hasObjectPermissionTo(admin, "command."..command) then
			outputAdminConsole(admin, command)
		end
	end
end

function aCommands.Execute(admin, command, ...)
	if get("consolecommands") ~= true then return end

	if not hasObjectPermissionTo(admin, "command."..command) then
		outputAdmin(admin, "ACL: Access denied for '"..command.."'", unpack(aColors.acl))
		return
	end

	local args, errormsg = aCommands.PrepareArgs(command, {...})
	if not args then return outputAdmin(admin, LOG_PREFIX..": "..errormsg, unpack(aColors.red)) end

	triggerEvent(EVENT_COMMAND, admin, command, unpack(args))
end

addEventHandler(EVENT_COMMAND, root,
	function(command, ...)
		if not hasObjectPermissionTo(source, "command."..command) then
			outputServerLog(LOG_PREFIX..": access denied for 'command."..command.."' (player: "..getPlayerName(source)..")")
			return
		end

		local func = aFunctions[command]
		if not func then return end

		local success, data = func(...)
		if not success then
			local errormsg = data or "command failed"
			if client then
				messageBox(string.upperf(errormsg), MB_ERROR)
			else
				outputAdmin(source, LOG_PREFIX..": "..command..": "..errormsg, unpack(aColors.red))
			end
			return
		end

		-- arg1 is not always player
		local args = {...}
		local player = args[1]
		aCommands.Log(command, source, player, data)
	end
)

function aCommands.Log(command, admin, player, data)
	local messages = aLogMessages[command]
	if not messages then return end
   
	local color = aColors[messages.color or "yellow"]
	if messages.all then
		outputChatBox("* "..aCommands.PrepareLog(messages.all, admin, player, data, true), root, unpack(color))
	end
	if messages.admin and admin ~= player and admin ~= console then
	--if messages.admin then
		outputAdmin(admin, LOG_PREFIX..": "..aCommands.PrepareLog(messages.admin, admin, player, data, true), unpack(aColors.yellow))
	end
	if messages.player then
		outputChatBox("* "..aCommands.PrepareLog(messages.player, admin, player, data, true), player, unpack(color))
	end
	if messages.log then
		outputServerLog(LOG_PREFIX..": "..aCommands.PrepareLog(messages.log, admin, player, data))
	end
end

function aCommands.PrepareLog(message, admin, player, data, stripNameColorCodes)
	for varstring in string.gmatch(message, "%$%[[%w_]+[%w%,%)%(_]*%]") do
		local vardata = string.match(varstring, "%$%[([%w_]+[%w%,%)%(_]*)%]")
		local var = string.match(vardata, "[%w_]+")
		local options = string.match(vardata, "%(([%w%,_]+)%)")
		options = options and split(options, ",") or {}
		local value = nil
		if	 var == "admin" then value = getAdminAccountName(admin)
		elseif var == "admin_4log" then value = getAdminNameForLog(admin)
		elseif var == "admin_4all" then value = stripColorCodes(aGetAdminNameForAll(admin))
		elseif var == "by_admin_4all" then value = " by "..stripColorCodes(aGetAdminNameForAll(admin))
		elseif var == "player" and player then
			value = getPlayerName(player)
			if stripNameColorCodes then
				value = stripColorCodes(value)
			end
		elseif var == string.match(var, "data%d?") then
			local number = tonumber(string.match(var, "%d+")) or 1
			value = data[number]
		end
		if value then
			for i, option in ipairs(options) do
				if option == "strip_codes" then value = stripColorCodes(value)
				elseif option == "brackets" then value = " ("..value..")"
				end
			end
		else
			value = "[NONE]"
		end
		message = string.gsub(message, string.literalize(varstring), value)
	end
	return message 
end

function aCommands.GetSyntax(command)
	local syntax = command.." "
	for i, name in ipairs(aCommands.Data[command].argnames) do
		if i == aCommands.Data[command].optpos then
			syntax = syntax.."["
		end
		syntax = syntax.."<"..name..">"

		if (i == #(aCommands.Data[command].argnames)) and
		   (i >= aCommands.Data[command].optpos) then
			syntax = syntax.."]"
		end
		syntax = syntax.." "
	end
	return syntax
end

function aCommands.PrepareArgs(command, args)
	local prepared = {}
	local commandData = aCommands.Data[command]
	for i, at in ipairs(commandData.args) do
		local arg = args[i]
		if not arg then
			if i >= commandData.optpos then
				return prepared
			end
			return false, "* Syntax: "..aCommands.GetSyntax(command)
		end

		if string.match(at, "-$") then
			i = #(commandData.args)
			arg = {}
			for ia = i, #args do
				table.insert(arg, args[ia])
			end
		end

		local pa, errormsg = nil, false
		local isFalse = false
		for i, orat in ipairs(split(at, "|")) do
			if (orat == "b" and arg == "no") or
			(orat == "n" and arg == "none") then
				isFalse = true
				break
			end
			pa, errormsg = aCommands.PrepareArgFunctions[orat](arg)
			if pa then break end
		end

		errormsg = command..": invalid "..commandData.argnames[i]..(errormsg and " ("..errormsg..")" or "")
		if not isFalse and not pa then return false, errormsg end
		table.insert(prepared, pa)
	end
	return prepared
end

aCommands.PrepareArgFunctions = {
	["P"] = function(arg)
		local players = getPlayersByPartialName(arg)
		if not players then return false end
		if #players == 0 then return false end
		if #players > 1 then
			return false, #players.." players found"
		end
		return players[1]
	end,
	["T"] = function(arg) return getTeamFromName(arg) end,
	["R"] = function(arg) return getResourceFromName(arg) end,
	
	["ve"] = function(arg)
		arg = tonumber(arg)
		if not arg then return false end
		return isValidVehicleModel(arg) and arg
	end,
	["ven"] = function(arg) return getVehicleModelFromPartialName(string.gsub(arg, "_", " ")) end,
	["we"] = function(arg)
		arg = tonumber(arg)
		if not arg then return false end
		return isValidWeaponID(arg) and arg
	end,
	["wen"] = function(arg) return getWeaponIDFromPartialName(string.gsub(arg, "_", " ")) end,
	["skn"] = function(arg) return aGetSkinIDFromPartialName(string.gsub(arg, "_", " ")) end,
	["fin"] = function(arg) return aGetFightingStyleFromPartialName(string.gsub(arg, "_", " ")) end,
	["wan"] = function(arg) return aGetWalkingStyleFromPartialName(string.gsub(arg, "_", " ")) end,
	["stn"] = function(arg) return aGetStatFromPartialName(string.gsub(arg, "_", " ")) end,
	["inn"] = function(arg) return aGetInteriorNameFromPartialName(string.gsub(arg, "_", " ")) end,

	["se"] = function(arg) return isValidSerial(arg) and string.upper(arg) end,
	["ip"] = function(arg) return isValidIP(arg) and arg end,
	["du"] = function(arg) return parseDuration(arg) end,
	["co"] = function(arg)
		arg = tonumber(arg)
		if not arg then return false end
		return arg >= 0 and arg <= 255 and arg
	end,
	
	["s"] = function(arg) return arg end,
	["i"] = function(arg) return tonumber(arg) end,
	["b"] = function(arg) return arg == "yes" end,
	["n"] = function(arg) return false end,
	["s-"] = function(args) return table.concat(args, " ") end,
	["ts-"] = function(args) return args end,
	["ti-"] = function(args)
		for i, arg in ipairs(args) do
			args[i] = tonumber(arg)
			if not args[i] then return false end
		end
		return args
	end,
}