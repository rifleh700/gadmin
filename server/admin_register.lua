
addCommandHandler("register",
	function(player, command, username, password)
		if not username or not password then
			outputChatBox("register: Syntax is 'register <nick> <password>'", player, unpack(aColors.acl))
			return
		end

		if string.len(password) < 4 then
			outputChatBox("register: Password should be at least 4 characters long", player, unpack(aColors.acl))
			return
		end

		if not addAccount(username, password) then
			if getAccount(username) then
				outputChatBox("register: Account with this name already exists", player, unpack(aColors.acl))
			else
				outputChatBox("register: Unknown error", player, unpack(aColors.red))
			end
			return
		end

		outputChatBox("register: You have successfully registered", player, unpack(aColors.acl))
		outputServerLog(LOG_PREFIX..": "..getPlayerName(player).." registered account '"..username.."' (IP: "..getPlayerIP(player).."  Serial: "..getPlayerSerial(player)..")")
	end
)