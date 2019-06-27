
function string.trim(s)
   return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

function string.literalize(s)
	return string.gsub(s, "[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0")
end

function string.upperf(s)
    return string.gsub(s, "^%l", string.upper)
end

function math.clamp(v, a, b)
	if a and b and a > b then return false end
	if a and v < a then
		v = a
	end
	if b and v > b then
		v = b
	end
	return v
end

function math.round(v, decimals)
	local mult = 10^(decimals or 0)
	return math.floor(v * mult + 0.5) / mult
end

function table.find(t, v)
	for i, tv in ipairs(t) do
		if tv == v then return i end
	end
	return nil
end

function table.vremove(t, v)
	for i, tv in ipairs(t) do
		if tv == v then return table.remove(t, i) end
	end
	return false
end

function table.reverse(t)
	local rt = {}
	for i, v in ipairs(t) do
		rt[#t - i + 1] = v
	end
	return rt
end

function table.iadd(t, ...)
	for ti, tn in ipairs({...}) do
		for i, v in ipairs(tn) do
			table.insert(t, v)
		end
	end
end

function table.compare(t1, t2)
	if t1 == t2 then return true end
	if not t1 or not t2 then return false end
	for k, v in pairs(t1) do
		if v ~= t2[k] then return false end
	end
	for k, v in pairs(t2) do
		if v ~= t1[k] then return false end
	end
	return true
end

function table.copydeep(t)
    if type(t) ~= "table" then return t end
    local result = {}
    for k, v in next, t, nil do
        result[table.copydeep(k)] = table.copydeep(v)
    end
    setmetatable(result, table.copydeep(getmetatable(t)))
    return result
end

function pack(...)
	return {n = select("#", ...), ...}
end

function split2(s, char)
	local index = string.find(s, char, 1, true)
	if not index then return s, nil end
	return string.sub(s, 1, index-1), string.sub(s, index+1)
end

------------------------------------------

function rgb2hex(r, g, b, a)
	if a then return string.format("#%.2X%.2X%.2X%.2X", r, g, b, a) end
	return string.format("#%.2X%.2X%.2X", r, g, b)
end

-- tiny hash
function crc32(data)
	local crc = 0xFFFFFFFF
	local byte = 0
	local mask = 0

	for i = 1, #data do
		byte = string.byte(data, i)
		crc  = bitXor(crc, byte)
		for j = 1, 8 do
			mask = bitAnd(crc, 1) * (-1)
			crc  = bitXor(bitRShift(crc, 1), bitAnd(0xEDB88320, mask))
		end
	end
	crc = bitNot(crc)
	return string.format("%08X", crc)
end

-- increment hash string
function crc32inc(crc)
	return string.upper(string.format("%08x", tonumber(crc, 16) + 1))
end

function stripColorCodes(text)
	return string.gsub(text, "#%x%x%x%x%x%x", "")
end

function isInsideArea(x, y, minX, minY, maxX, maxY)
	if x < minX or x > maxX or
	y < minY or y > maxY then
		return false
	end
	return true
end

function isInsideRectangle(x, y, rx, ry, width, height)
	return isInsideArea(x, y, rx, ry, rx + width, ry + height)
end

------------------------------------------

function parseDuration(duration)
	duration = string.lower(duration)
	if duration == "perm" or duration == "permanent" then return 0 end
	if not string.match(duration, "^%d+[smhdw]$") then return false end

	local sbyt = {s = 1, m = 60, h = 60*60, d = 60*60*24, w = 60*60*24*7}
	local n, t = string.match(duration, "(%d+)([smhdw])")
	return tonumber(n) * sbyt[t]
end

function formatDate(timestamp)
	local date = getRealTime(timestamp)
	return string.format("%02d.%02d.%04d / %02d:%02d", date.monthday, date.month+1, date.year+1900, date.hour, date.minute)
end

function formatDuration(seconds)
	if seconds == 0 then return "Permanent" end
	local duration = ""
	local ts = { {"day", 60*60*24}, {"hour", 60*60}, {"min", 60}, {"sec", 1} }
	for i, data in ipairs(ts) do
		local t = math.floor(seconds/data[2])
		if t > 0 then
			seconds = seconds - t*data[2]
			if string.len(duration) > 0 then duration = duration.." " end
			duration = duration..t.." "..data[1]..(t > 1 and "s" or "")
		end
	end
	return string.trim(duration)
end

function formatDurationSimple(seconds)
	if seconds == 0 then return "Permanent" end
	local tab = { {"day", 60*60*24},  {"hour", 60*60},  {"min", 60},  {"sec", 1} }
	for i, item in ipairs(tab) do
		local t = math.floor(seconds/item[2])
		if t > 0 or i == #tab then
			return tostring(t) .. " " .. item[1] .. (t~=1 and "s" or "")
		end
	end
end

function formatGameTime(hours, minutes)
	return string.format("%02d:%02d", hours, minutes)
end

function formatIDName(id, name)
	return id.." ("..(name or "Unknown")..")"
end

function isValidSerial(serial)
	if string.len(serial) ~= 32 then return false end
	if not string.match(serial, "^%x+$") then return false end
	return true
end

function isValidIPv4(ip)
	if not string.match(ip, "^%d+%.%d+%.%d+%.%d+$") then return false end
	for chunk in string.gmatch(ip, "%d+") do
		if tonumber(chunk) > 255 then return false end
	end
	return true
end

function isValidIPv6(ip)
	if not string.match(ip, "^%x+:%x+:%x+:%x+:%x+:%x+:%x+:%x+$") then return false end
	for chunk in string.gmatch(ip, "%x+") do
		if tonumber(chunk, 16) > 65535 then return false end
	end
	return true
end

function isValidIP(ip)
	return isValidIPv4(ip) or isValidIPv6(ip)
end

function fileReadLine(file)
	if fileIsEOF(file) then return false end
	
	local line = ""
	local char = ""
	while not (string.byte(char) == 10 or fileIsEOF(file)) do
		line = line..char
		char = fileRead(file, 1)
	end
	return line
end

------------------------------------------

function getPlayerFromPartialName(partialName)
	if partialName == "" then return false end

	local player = getPlayerFromName(partialName)
	if player then return player end

	partialName = stripColorCodes(partialName)
	local ignoreCasePartialName = string.lower(partialName)

	for i, p in ipairs(getElementsByType("player")) do
		local playerName = stripColorCodes(getPlayerName(p))
		if playerName == partialName then return p end
		if string.find(playerName, partialName, 1, true) then return p end

		local ignoreCasePlayerName = string.lower(playerName)
		if ignoreCasePlayerName == ignoreCasePartialName then return p end
		if string.find(ignoreCasePlayerName, ignoreCasePartialName, 1, true) then return p end
	end
	return nil
end

function getPlayersByPartialName(partialName)
	if partialName == "" then return false end

	local players = {}
	partialName = string.lower(stripColorCodes(partialName))
	for i, p in ipairs(getElementsByType("player")) do
		local playerName = string.lower(stripColorCodes(getPlayerName(p)))
		if string.find(playerName, partialName, 1, true) then
			players[#players + 1] = p
		end
	end
	return players
end

function getPositionFromElementOffset(element, offX, offY, offZ)
	local m = getElementMatrix(element, false)
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z
end

local validVehicleModels = {
	400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415,
	416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433,
	434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451,
	452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469,
	470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487,
	488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505,
	506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523,
	524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541,
	542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559,
	560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577,
	578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595,
	596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611
}
function getValidVehicleModels()
	return validVehicleModels
end

function isValidVehicleModel(model)
	for i, valid in ipairs(validVehicleModels) do
		if valid == model then return true end
	end
	return false
end

function getVehicleModelFromPartialName(name)
	local model = getVehicleModelFromName(name)
	if model then return model end

	name = string.lower(name)
	for i, vm in ipairs(validVehicleModels) do
		local vn = string.lower(getVehicleNameFromModel(vm))
		if string.find(vn, name, 1, true) then return vm end
	end
end

local compatibleVehiclePaintjobs = {
	[483] = {0},		-- camper
	[534] = {0,1,2},	-- remington
	[535] = {0,1,2},	-- slamvan
	[536] = {0,1,2},	-- blade
	[558] = {0,1,2},	-- uranus
	[559] = {0,1,2},	-- jester
	[560] = {0,1,2},	-- sultan
	[561] = {0,1,2},	-- stratum
	[562] = {0,1,2},	-- elegy
	[565] = {0,1,2},	-- flash
	[567] = {0,1,2},	-- savanna
	[575] = {0,1},	  -- broadway
	[576] = {0,1,2}	 -- tornado
}
function getVehicleCompatiblePaintjobs(model)
	if type(model) == "userdata" then model = getElementModel(model) end
	return compatibleVehiclePaintjobs[model] or {}
end

function getVehicleOneColor(vehicle, number)
	local colors = {getVehicleColor(vehicle, true)}
	return colors[(number-1)*3+1], colors[(number-1)*3+2], colors[(number-1)*3+3]
end

function getVehicleFreePassengerSeat(vehicle)
	local lastSeat = getVehicleMaxPassengers(vehicle)
	if lastSeat == 0 then return nil end

	local seatsState = {}
	for seat, occupant in pairs(getVehicleOccupants(vehicle)) do
		seatsState[seat] = true
	end
	
	for seat = 1, lastSeat do
		if not seatsState[seat] then return seat end
	end
	return nil
end

function getVehicleOneOccupant(vehicle)
	for i = 0, getVehicleMaxPassengers(vehicle) do
		local occupant = getVehicleOccupant(vehicle, i)
		if occupant then return occupant end
	end
	return nil
end

local validWeaponIDs = {
	1, 2, 3, 4, 5, 6, 7, 8, 9,
	22, 23, 24,
	25, 26, 27,
	28, 29, 32,
	30, 31,
	33, 34,
	35, 36, 37, 38,
	16, 17, 18, 39,
	41, 42, 43,
	10, 11, 12, 14, 15,
	44, 45, 46
}
function getValidWeaponIDs()
	return validWeaponIDs
end

function isValidWeaponID(id)
	for i, vid in ipairs(validWeaponIDs) do
		if vid == id then return true end
	end
	return false
end

function getWeaponIDFromPartialName(name)
	local id = getWeaponIDFromName(name)
	if id then return id end

	name = string.lower(name)
	for i, vid in ipairs(validWeaponIDs) do
		local vname = string.lower(getWeaponNameFromID(vid))
		if string.find(vname, name, 1, true) then return vid end
	end
	return nil
end

local modelWalkingStyles = {
    [0]     = 54,   
    [1]     = 118,    
    [2]     = 118,    
    [7]     = 118,
    [9]     = 129,
    [10]    = 137,
    [11]    = 129,
    [12]    = 132,
    [13]    = 129,
    [14]    = 118,
    [15]    = 118,
    [16]    = 118,
    [17]    = 118,
    [18]    = 118,
    [19]    = 121,
    [20]    = 118,
    [21]    = 121,
    [22]    = 122,
    [23]    = 118,
    [24]    = 118,
    [25]    = 118,
    [26]    = 118,
    [27]    = 118,
    [28]    = 122,
    [29]    = 118,
    [30]    = 118,
    [31]    = 137,
    [32]    = 118,
    [33]    = 118,
    [34]    = 118,
    [35]    = 118,
    [36]    = 118,
    [37]    = 118,
    [38]    = 129,
    [39]    = 137,
    [40]    = 132,
    [41]    = 129,
    [43]    = 118,
    [44]    = 118,
    [45]    = 118,
    [46]    = 118,
    [47]    = 118,
    [48]    = 118,
    [49]    = 120,
    [50]    = 118,
    [51]    = 118,
    [52]    = 118,
    [53]    = 134,
    [54]    = 134,
    [55]    = 129,
    [56]    = 129,
    [57]    = 118,
    [58]    = 118,
    [59]    = 118,
    [60]    = 118,
    [61]    = 118,
    [62]    = 120,
    [63]    = 133,
    [64]    = 133,
    [66]    = 118,
    [67]    = 118,
    [68]    = 118,
    [69]    = 129,
    [70]    = 118,
    [71]    = 118,
    [72]    = 118,
    [73]    = 118,
    [75]    = 133,
    [76]    = 132,
    [77]    = 118,
    [78]    = 118,
    [79]    = 118,
    [80]    = 118,
    [81]    = 118,
    [82]    = 118,
    [83]    = 118,
    [84]    = 118,
    [85]    = 133,
    [87]    = 132,
    [88]    = 134,
    [89]    = 137,
    [90]    = 136,
    [91]    = 132,
    [92]    = 138,
    [93]    = 132,
    [94]    = 118,
    [95]    = 118,
    [96]    = 125,
    [97]    = 125,
    [98]    = 118,
    [99]    = 138,
    [100]   = 118,
    [101]   = 118,
    [102]   = 121,
    [103]   = 122,
    [104]   = 121,
    [105]   = 122,
    [106]   = 121,
    [107]   = 122,
    [108]   = 121,
    [109]   = 122,
    [110]   = 121,
    [111]   = 118,
    [112]   = 118,
    [113]   = 118,
    [114]   = 121,
    [115]   = 122,
    [116]   = 121,
    [117]   = 118,
    [118]   = 118,
    [120]   = 118,
    [121]   = 121,
    [122]   = 122,
    [123]   = 121,
    [124]   = 121,
    [125]   = 118,
    [126]   = 118,
    [127]   = 118,
    [128]   = 118,
    [129]   = 134,
    [130]   = 134,
    [131]   = 132,
    [132]   = 118,
    [133]   = 118,
    [134]   = 120,
    [135]   = 118,
    [136]   = 118,
    [137]   = 118,
    [138]   = 129,
    [139]   = 129,
    [140]   = 129,
    [141]   = 131,
    [142]   = 118,
    [143]   = 121,
    [144]   = 122,
    [145]   = 129,
    [146]   = 118,
    [147]   = 118,
    [148]   = 131,
    [150]   = 131,
    [151]   = 132,
    [152]   = 133,
    [153]   = 118,
    [154]   = 118,
    [155]   = 118,
    [156]   = 118,
    [157]   = 129,
    [158]   = 118,
    [159]   = 118,
    [160]   = 120,
    [161]   = 118,
    [162]   = 120,
    [163]   = 118,
    [164]   = 118,
    [165]   = 118,
    [166]   = 118,
    [167]   = 118,
    [168]   = 118,
    [169]   = 132,
    [170]   = 118,
    [171]   = 118,
    [172]   = 131,
    [173]   = 121,
    [174]   = 122,
    [175]   = 121,
    [176]   = 118,
    [177]   = 118,
    [178]   = 132,
    [179]   = 118,
    [180]   = 118,
    [181]   = 118,
    [182]   = 118,
    [183]   = 118,
    [184]   = 118,
    [185]   = 118,
    [186]   = 118,
    [187]   = 118,
    [188]   = 118,
    [189]   = 118,
    [190]   = 131,
    [191]   = 129,
    [192]   = 132,
    [193]   = 132,
    [194]   = 132,
    [195]   = 129,
    [196]   = 134,
    [197]   = 134,
    [198]   = 129,
    [199]   = 129,
    [200]   = 118,
    [201]   = 129,
    [202]   = 118,
    [203]   = 118,
    [204]   = 118,
    [205]   = 129,
    [206]   = 118,
    [207]   = 133,
    [209]   = 120,
    [210]   = 120,
    [211]   = 129,
    [212]   = 118,
    [213]   = 118,
    [214]   = 129,
    [215]   = 129,
    [216]   = 129,
    [217]   = 118,
    [218]   = 129,
    [219]   = 129,
    [220]   = 118,
    [221]   = 118,
    [222]   = 118,
    [223]   = 118,
    [224]   = 129,
    [225]   = 129,
    [226]   = 129,
    [227]   = 118,
    [228]   = 118,
    [229]   = 118,
    [230]   = 118,
    [231]   = 129,
    [232]   = 129,
    [233]   = 129,
    [234]   = 118,
    [235]   = 118,
    [236]   = 118,
    [237]   = 133,
    [238]   = 133,
    [239]   = 118,
    [240]   = 118,
    [241]   = 118,
    [242]   = 118,
    [243]   = 133,
    [244]   = 132,
    [245]   = 133,
    [246]   = 132,
    [247]   = 118,
    [248]   = 118,
    [249]   = 118,
    [250]   = 118,
    [251]   = 129,
    [252]   = 118,
    [253]   = 118,
    [254]   = 118,
    [255]   = 118,
    [256]   = 132,
    [257]   = 132,
    [258]   = 118,
    [259]   = 118,
    [260]   = 118,
    [261]   = 118,
    [262]   = 118,
    [263]   = 129,
    [264]   = 118,
    [274]   = 128,
    [275]   = 128,
    [276]   = 128,
    [277]   = 128,
    [278]   = 128,
    [279]   = 128,
    [280]   = 128,
    [281]   = 128,
    [282]   = 128,
    [283]   = 128,
    [284]   = 128,
    [285]   = 128,
    [286]   = 128,
    [287]   = 128,
    [288]   = 128,
    -- special skins
    [265]   = 118,
    [266]   = 118,
    [267]   = 118,
    [268]   = 118,
    [269]   = 124,
    [270]   = 122,
    [271]   = 121,
    [272]   = 118,
    [290]   = 118,
    [291]   = 118,
    [292]   = 118,
    [293]   = 122,
    [294]   = 127,
    [295]   = 118,
    [296]   = 118,
    [297]   = 118,
    [298]   = 129,
    [299]   = 118,
    [300]   = 121,
    [301]   = 121,
    [302]   = 118,
    [303]   = 118,
    [304]   = 129,
    [305]   = 118,
    [306]   = 118,
    [307]   = 118,
    [308]   = 118,
    [309]   = 118,
    [310]   = 118,
    [311]   = 124,
    [312]   = 118,
}
function getModelWalkingStyle(model)
	return modelWalkingStyles[model] or 0
end