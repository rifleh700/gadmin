
local aReports = {
	List = {}
}
local PERMISSION = "command.listreports"

addEvent(EVENT_REPORT, true)

addEventHandler("onResourceStart", resourceRoot,
	function()
		aReports.Load()
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		aReports.Save()
	end
)

function aReports.Load()
	local fileNode = xmlLoadFile("data/reports.xml")
	if not fileNode then return end

	local reports = {}
	for i, reportNode in ipairs(xmlNodeGetChildren(fileNode)) do
		if xmlNodeGetName(reportNode) == "report" then
			local data = {}
			
			local author = xmlFindChild(reportNode, "author", 0)
			data.author = author and xmlNodeGetValue(author) or "unknown"

			local serial = xmlFindChild(reportNode, "serial", 0)
			data.serial = serial and xmlNodeGetValue(serial) or nil

			local text = xmlFindChild(reportNode, "text", 0)
			data.text = text and xmlNodeGetValue(text) or ""

			local screenshots = xmlFindChild(reportNode, "screenshots", 0)
			data.screenshots = screenshots and tonumber(xmlNodeGetValue(screenshots)) or 0

			local chat = xmlFindChild(reportNode, "chat", 0)
			data.chat = chat and fromJSON(xmlNodeGetValue(chat)) or {}

			local time = xmlFindChild(reportNode, "time", 0)
			data.time = time and tonumber(xmlNodeGetValue(time)) or 0

			local read = xmlFindChild(reportNode, "read", 0)
			data.read = read and xmlNodeGetValue(read) == "true"

			reports[#reports + 1] = data

		end
	end
	xmlUnloadFile(fileNode)

	aReports.List = reports
end

function aReports.Save()
	local fileNode = xmlLoadFile("data/reports.xml")
	if not fileNode then fileNode = xmlCreateFile("data/reports.xml", "reports") end

	while xmlFindChild(fileNode, "report", 0) ~= false do
		xmlDestroyNode(xmlFindChild(fileNode, "report", 0))
	end
	
	for i, data in ipairs(aReports.List) do
		local reportNode = xmlCreateChild(fileNode, "report")
		xmlNodeSetValue(xmlCreateChild(reportNode, "author"), tostring(data.author))
		xmlNodeSetValue(xmlCreateChild(reportNode, "serial"), data.serial)
		xmlNodeSetValue(xmlCreateChild(reportNode, "text"), tostring(data.text))
		xmlNodeSetValue(xmlCreateChild(reportNode, "screenshots"), tostring(data.screenshots))
		xmlNodeSetValue(xmlCreateChild(reportNode, "chat"), toJSON(data.chat))
		xmlNodeSetValue(xmlCreateChild(reportNode, "time"), tostring(data.time))
		xmlNodeSetValue(xmlCreateChild(reportNode, "read"), tostring(data.read))
	end
	xmlSaveFile(fileNode)
	xmlUnloadFile(fileNode)
end

function aReports.GetID(report)
	return string.match(tostring(report), "%x+$")
end

function aReports.GetFromID(id)
	for i, report in ipairs(aReports.List) do
		if aReports.GetID(report) == id then return report end
	end
	return nil
end

function aReports.Remove(report)
	if not table.vremove(aReports.List, report) then return false end
	aReports.DeleteScreenShots(report)
	aReports.onReportDeleteHandler(aReports.GetID(report))
	return true
end

function aReports.Add(player, message, screenshots, chat)
	local report = {}
	report.author = getPlayerName(player)
	report.serial = getPlayerSerial(player)
	report.text = message
	report.screenshots = #screenshots
	report.chat = chat
	report.time = getRealTime().timestamp
	report.read = false

	table.insert(aReports.List, report)
	aReports.SaveScreenShots(report, screenshots)
	return report
end

function aReports.SaveScreenShots(report, screenshots)
	local hash = crc32(report.serial..report.time..report.text)
	for number, report in ipairs(screenshots) do
		local path = "data/report_screenshots/"..hash.."_"..number..".jpg"
		if fileExists(path) then
			fileDelete(path)
		end
		local file = fileCreate(path)
		if file then
			fileWrite(file, report)
			fileClose(file)
		end
	end
end

function aReports.DeleteScreenShots(report)
	local hash = crc32(report.serial..report.time..report.text)
	for number = 1, report.screenshots do
		local path = "data/report_screenshots/"..hash.."_"..number..".jpg"
		if fileExists(path) then
			fileDelete(path)
		end
	end
end

function aReports.GetScreenShots(report)
	if report.screenshots < 1 then return {} end 

	local screenshots = {}
	local hash = crc32(report.serial..report.time..report.text)
	for number = 1, report.screenshots do
		local path = "data/report_screenshots/"..hash.."_"..number..".jpg"
		local file = fileOpen(path, true)
		if file then
			local screenshot = fileRead(file, fileGetSize(file))
			fileClose(file)
			screenshots[number] = screenshot
		end
	end
	return screenshots
end

function aReports.GetScreenShot(report, number)
	if report.screenshots < 1 then return nil end

	local hash = crc32(report.serial..report.time..report.text)
	local path = "data/report_screenshots/"..hash.."_"..number..".jpg"
	local file = fileOpen(path, true)
	if not file then return nil end

	local screenshot = fileRead(file, fileGetSize(file))
	fileClose(file)
	return screenshot
end

aReports.SyncFunctions = {
	[SYNC_LIST] = function()
		local list = {}
		for i, report in ipairs(aReports.List) do
			list[aReports.GetID(report)] = report
		end
		sync(source, SYNC_REPORT, SYNC_LIST, list)
	end,
	[SYNC_SINGLE] = function(id)
		local report = aReports.GetFromID(id)
		if not report then return end
		sync(source, SYNC_REPORT, SYNC_SINGLE, id, report)
	end,
	[SYNC_BIGDATA] = function(id, number)
		local report = aReports.GetFromID(id)
		if not report then return end
		syncBigData(source, SYNC_REPORT, SYNC_BIGDATA, id, number, aReports.GetScreenShot(report, number))
	end
}
addEventHandler(
	EVENT_SYNC,
	root,
	function(dataType, syncType, ...)
		if dataType ~= SYNC_REPORT then return end
		if not hasObjectPermissionTo(source, PERMISSION) then
			outputDebugString("Access denied for '"..PERMISSION.."' (player: "..getPlayerName(source)..")", 2)
			return
		end
		aReports.SyncFunctions[syncType](...)
	end
)

addEventHandler(EVENT_REPORT, root,
	function(message, screenshots, chat)
		if client ~= source then return end

		local report = aReports.Add(source, message, screenshots, chat)
		syncGlobal(PERMISSION, SYNC_REPORT, SYNC_ADD, aReports.GetID(report), report)
	end
)

function aReports.onReportReadHandler(id)
	syncGlobal(PERMISSION, SYNC_REPORT, SYNC_SINGLE, id, {read = true})
end

function aReports.onReportDeleteHandler(id)
	syncGlobal(PERMISSION, SYNC_REPORT, SYNC_REMOVE, id)
end

function aReadReport(id)
	local report = aReports.GetFromID(id)
	if not report then return false end
	if report.read then return false end
	report.read = true
	aReports.onReportReadHandler(id)
	return true
end

function aDeleteReport(id)
	local report = aReports.GetFromID(id)
	if not report then return false end
	if not aReports.Remove(report) then return false end
	return true
end

function aGetReportRead(id)
	local report = aReports.GetFromID(id)
	if not report then return false end
	return report.read
end