
local aScreenShots = {
	pending = {}
}

addEvent(EVENT_SCREEN_SHOT, true)

addEventHandler("onResourceStart", resourceRoot,
	function()
		db.exec("CREATE TABLE IF NOT EXISTS screenshots(file TEXT, player TEXT, serial TEXT, admin TEXT, time INTEGER, temp BOOL)")
		aScreenShots.RemoveTemp()
	end
)

addEventHandler(EVENT_SCREEN_SHOT, root,
	function(jpeg, tag)
		aScreenShots.CollectTimedOut()

		local data = aScreenShots.pending[tag]
		if not data then return end

		local id = 0

		-- save a local copy
		local timestamp = getRealTime().timestamp
		local fileNameDate = aScreenShots.FormatDate(timestamp)

		local fileNameCounter = 1
		local fileNamePlayer = aScreenShots.GetFileFriendlyName(stripColorCodes(data.playername))
		if fileNamePlayer == "" then
			fileNamePlayer = "screen"
		end
		local fileName = fileNamePlayer.."_"..fileNameDate..".jpg"
		while fileExists("screenshots/"..fileName) do
			fileName = fileNamePlayer.."_"..fileNameDate.."_"..fileNameCounter..".jpg"
			fileNameCounter = fileNameCounter + 1
		end

		local file = fileCreate("screenshots/"..fileName)
		if file then
			fileWrite(file, jpeg)
			fileClose(file)

			local query = "INSERT INTO screenshots(file, player, serial, admin, time, temp) VALUES (?,?,?,?,?,?)"
			db.exec(query, fileName, data.playername, data.account, time.timestamp, 0)

			id = db.last_insert_id()
		end

		-- making sure the bastard didn't leave yet
		if not isElement(data.admin) then return end 

		syncBigData(admin, SYNC_SCREEN_SHOT, admin, SYNC_SINGLE, fileName, id, jpeg)
	end
)

function aTakePlayerScreenShot(player, tag)
	triggerClientEvent(player, EVENT_SCREEN_SHOT, player, tag or "")
end

function aGetPlayerScreen(admin, player)
	local number = math.random(1, 1000)
	local tag = "a"..number
	while aScreenShots.pending[tag] do
		number = number + 1
		tag = "a"..number
	end

	aTakePlayerScreenShot(player, tag)

	local timeout = getTickCount() + 1000 * 60 * 15
	local account = getAdminAccountName(admin) or getPlayerName(admin)
	aScreenShots.pending[tag] = {
		player = player,
		--playerserial = getPlayerSerial(player),
		playername = getPlayerName(player),
		admin = admin,
		account = account,
		timeout = timeout
	}
end

function aScreenShots.CollectTimedOut()
	for tag, data in pairs(aScreenShots.pending) do
		local timeout = data.timeout
		if (not timeout) or (getTickCount() > timeout) then
			aScreenShots.pending[tag] = nil
		end
	end
end

function aScreenShots.RemoveTemp()
	local query = db.query("SELECT file FROM screenshots WHERE temp = 1")
	if not query then return end

	for i, row in ipairs(query) do
		if fileExists("screenshots/"..row.file) then
			fileDelete("screenshots/"..row.file)
		end
	end
	db.exec("DELETE FROM screenshots WHERE temp = 1")
end

function aScreenShots.GetFileFriendlyName(str)
	if not str then return "" end
	local result = ""
	for s in string.gmatch(str, "%a+") do
		result = result..s
	end
	return result
end

function aScreenShots.FormatDate(timestamp)
	local date = getRealTime(timestamp)
	return string.format("%02d-%02d-%04d_%02d-%02d-%02d", date.monthday, date.month+1, date.year+1900, date.hour, date.minute, date.second)
end
