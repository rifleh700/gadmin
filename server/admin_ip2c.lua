
local aIP2C = {
	Data = nil
}

addEvent(EVENT_IP2C, false)

local countryNames = { 
    ["AF"] = "Afghanistan", 
    ["AX"] = "Aland Islands", 
    ["AL"] = "Albania", 
    ["DZ"] = "Algeria", 
    ["AS"] = "American Samoa", 
    ["AD"] = "Andorra", 
    ["AO"] = "Angola", 
    ["AI"] = "Anguilla", 
    ["AQ"] = "Antarctica", 
    ["AG"] = "Antigua And Barbuda", 
    ["AR"] = "Argentina", 
    ["AM"] = "Armenia", 
    ["AW"] = "Aruba", 
    ["AU"] = "Australia", 
    ["AT"] = "Austria", 
    ["AZ"] = "Azerbaijan", 
    ["BS"] = "Bahamas", 
    ["BH"] = "Bahrain", 
    ["BD"] = "Bangladesh", 
    ["BB"] = "Barbados", 
    ["BY"] = "Belarus", 
    ["BE"] = "Belgium", 
    ["BZ"] = "Belize", 
    ["BJ"] = "Benin", 
    ["BM"] = "Bermuda", 
    ["BT"] = "Bhutan", 
    ["BO"] = "Bolivia", 
    ["BA"] = "Bosnia And Herzegovina", 
    ["BW"] = "Botswana", 
    ["BV"] = "Bouvet Island", 
    ["BR"] = "Brazil", 
    ["IO"] = "British Indian Ocean Territory", 
    ["BN"] = "Brunei Darussalam", 
    ["BG"] = "Bulgaria", 
    ["BF"] = "Burkina Faso", 
    ["BI"] = "Burundi", 
    ["KH"] = "Cambodia", 
    ["CM"] = "Cameroon", 
    ["CA"] = "Canada", 
    ["CV"] = "Cape Verde", 
    ["KY"] = "Cayman Islands", 
    ["CF"] = "Central African Republic", 
    ["TD"] = "Chad", 
    ["CL"] = "Chile", 
    ["CN"] = "China", 
    ["CX"] = "Christmas Island", 
    ["CC"] = "Cocos (Keeling) Islands", 
    ["CO"] = "Colombia", 
    ["KM"] = "Comoros", 
    ["CG"] = "Congo", 
    ["CD"] = "Congo, Democratic Republic", 
    ["CK"] = "Cook Islands", 
    ["CR"] = "Costa Rica", 
    ["CI"] = "Cote D'Ivoire", 
    ["HR"] = "Croatia", 
    ["CU"] = "Cuba", 
    ["CY"] = "Cyprus", 
    ["CZ"] = "Czech Republic", 
    ["DK"] = "Denmark", 
    ["DJ"] = "Djibouti", 
    ["DM"] = "Dominica", 
    ["DO"] = "Dominican Republic", 
    ["EC"] = "Ecuador", 
    ["EG"] = "Egypt", 
    ["SV"] = "El Salvador", 
    ["GQ"] = "Equatorial Guinea", 
    ["ER"] = "Eritrea", 
    ["EE"] = "Estonia", 
    ["ET"] = "Ethiopia", 
    ["FK"] = "Falkland Islands (Malvinas)", 
    ["FO"] = "Faroe Islands", 
    ["FJ"] = "Fiji", 
    ["FI"] = "Finland", 
    ["FR"] = "France", 
    ["GF"] = "French Guiana", 
    ["PF"] = "French Polynesia", 
    ["TF"] = "French Southern Territories", 
    ["GA"] = "Gabon", 
    ["GM"] = "Gambia", 
    ["GE"] = "Georgia", 
    ["DE"] = "Germany", 
    ["GH"] = "Ghana", 
    ["GI"] = "Gibraltar", 
    ["GR"] = "Greece", 
    ["GL"] = "Greenland", 
    ["GD"] = "Grenada", 
    ["GP"] = "Guadeloupe", 
    ["GU"] = "Guam", 
    ["GT"] = "Guatemala", 
    ["GG"] = "Guernsey", 
    ["GN"] = "Guinea", 
    ["GW"] = "Guinea-Bissau", 
    ["GY"] = "Guyana", 
    ["HT"] = "Haiti", 
    ["HM"] = "Heard Island & Mcdonald Islands", 
    ["VA"] = "Holy See (Vatican City State)", 
    ["HN"] = "Honduras", 
    ["HK"] = "Hong Kong", 
    ["HU"] = "Hungary", 
    ["IS"] = "Iceland", 
    ["IN"] = "India", 
    ["ID"] = "Indonesia", 
    ["IR"] = "Iran, Islamic Republic Of", 
    ["IQ"] = "Iraq", 
    ["IE"] = "Ireland", 
    ["IM"] = "Isle Of Man", 
    ["IL"] = "Israel", 
    ["IT"] = "Italy", 
    ["JM"] = "Jamaica", 
    ["JP"] = "Japan", 
    ["JE"] = "Jersey", 
    ["JO"] = "Jordan", 
    ["KZ"] = "Kazakhstan", 
    ["KE"] = "Kenya", 
    ["KI"] = "Kiribati", 
    ["KR"] = "Korea", 
    ["KW"] = "Kuwait", 
    ["KG"] = "Kyrgyzstan", 
    ["LA"] = "Lao People's Democratic Republic", 
    ["LV"] = "Latvia", 
    ["LB"] = "Lebanon", 
    ["LS"] = "Lesotho", 
    ["LR"] = "Liberia", 
    ["LY"] = "Libyan Arab Jamahiriya", 
    ["LI"] = "Liechtenstein", 
    ["LT"] = "Lithuania", 
    ["LU"] = "Luxembourg", 
    ["MO"] = "Macao", 
    ["MK"] = "Macedonia", 
    ["MG"] = "Madagascar", 
    ["MW"] = "Malawi", 
    ["MY"] = "Malaysia", 
    ["MV"] = "Maldives", 
    ["ML"] = "Mali", 
    ["MT"] = "Malta", 
    ["MH"] = "Marshall Islands", 
    ["MQ"] = "Martinique", 
    ["MR"] = "Mauritania", 
    ["MU"] = "Mauritius", 
    ["YT"] = "Mayotte", 
    ["MX"] = "Mexico", 
    ["FM"] = "Micronesia, Federated States Of", 
    ["MD"] = "Moldova", 
    ["MC"] = "Monaco", 
    ["MN"] = "Mongolia", 
    ["ME"] = "Montenegro", 
    ["MS"] = "Montserrat", 
    ["MA"] = "Morocco", 
    ["MZ"] = "Mozambique", 
    ["MM"] = "Myanmar", 
    ["NA"] = "Namibia", 
    ["NR"] = "Nauru", 
    ["NP"] = "Nepal", 
    ["NL"] = "Netherlands", 
    ["AN"] = "Netherlands Antilles", 
    ["NC"] = "New Caledonia", 
    ["NZ"] = "New Zealand", 
    ["NI"] = "Nicaragua", 
    ["NE"] = "Niger", 
    ["NG"] = "Nigeria", 
    ["NU"] = "Niue", 
    ["NF"] = "Norfolk Island", 
    ["MP"] = "Northern Mariana Islands", 
    ["NO"] = "Norway", 
    ["OM"] = "Oman", 
    ["PK"] = "Pakistan", 
    ["PW"] = "Palau", 
    ["PS"] = "Palestinian Territory, Occupied", 
    ["PA"] = "Panama", 
    ["PG"] = "Papua New Guinea", 
    ["PY"] = "Paraguay", 
    ["PE"] = "Peru", 
    ["PH"] = "Philippines", 
    ["PN"] = "Pitcairn", 
    ["PL"] = "Poland", 
    ["PT"] = "Portugal", 
    ["PR"] = "Puerto Rico", 
    ["QA"] = "Qatar", 
    ["RE"] = "Reunion", 
    ["RO"] = "Romania", 
    ["RU"] = "Russian Federation", 
    ["RW"] = "Rwanda", 
    ["BL"] = "Saint Barthelemy", 
    ["SH"] = "Saint Helena", 
    ["KN"] = "Saint Kitts And Nevis", 
    ["LC"] = "Saint Lucia", 
    ["MF"] = "Saint Martin", 
    ["PM"] = "Saint Pierre And Miquelon", 
    ["VC"] = "Saint Vincent And Grenadines", 
    ["WS"] = "Samoa", 
    ["SM"] = "San Marino", 
    ["ST"] = "Sao Tome And Principe", 
    ["SA"] = "Saudi Arabia", 
    ["SN"] = "Senegal", 
    ["RS"] = "Serbia", 
    ["SC"] = "Seychelles", 
    ["SL"] = "Sierra Leone", 
    ["SG"] = "Singapore", 
    ["SK"] = "Slovakia", 
    ["SI"] = "Slovenia", 
    ["SB"] = "Solomon Islands", 
    ["SO"] = "Somalia", 
    ["ZA"] = "South Africa", 
    ["GS"] = "South Georgia And Sandwich Isl.", 
    ["ES"] = "Spain", 
    ["LK"] = "Sri Lanka", 
    ["SD"] = "Sudan", 
    ["SR"] = "Suriname", 
    ["SJ"] = "Svalbard And Jan Mayen", 
    ["SZ"] = "Swaziland", 
    ["SE"] = "Sweden", 
    ["CH"] = "Switzerland", 
    ["SY"] = "Syrian Arab Republic", 
    ["TW"] = "Taiwan", 
    ["TJ"] = "Tajikistan", 
    ["TZ"] = "Tanzania", 
    ["TH"] = "Thailand", 
    ["TL"] = "Timor-Leste", 
    ["TG"] = "Togo", 
    ["TK"] = "Tokelau", 
    ["TO"] = "Tonga", 
    ["TT"] = "Trinidad And Tobago", 
    ["TN"] = "Tunisia", 
    ["TR"] = "Turkey", 
    ["TM"] = "Turkmenistan", 
    ["TC"] = "Turks And Caicos Islands", 
    ["TV"] = "Tuvalu", 
    ["UG"] = "Uganda", 
    ["UA"] = "Ukraine", 
    ["AE"] = "United Arab Emirates", 
    ["GB"] = "United Kingdom", 
    ["US"] = "United States", 
    ["UM"] = "United States Outlying Islands", 
    ["UY"] = "Uruguay", 
    ["UZ"] = "Uzbekistan", 
    ["VU"] = "Vanuatu", 
    ["VE"] = "Venezuela", 
    ["VN"] = "Viet Nam", 
    ["VG"] = "Virgin Islands, British", 
    ["VI"] = "Virgin Islands, U.S.", 
    ["WF"] = "Wallis And Futuna", 
    ["EH"] = "Western Sahara", 
    ["YE"] = "Yemen", 
    ["ZM"] = "Zambia", 
    ["ZW"] = "Zimbabwe", 
    ["ZZ"] = "Unknown"
}

addEventHandler("onResourceStart", resourceRoot,
	function()
		aIP2C.Load()
	end
)

function aIP2C.Load()
	aIP2C.Data = nil

	local file = fileOpen("conf/IpToCountryCompact.csv", true)
	if not file then return false end

	local groups = {}
	local pos = 0

	local ticks = getTickCount()
	while not fileIsEOF(file) do

		if getTickCount() > ticks + 50 then
			coroutine.sleep(50)
			ticks = getTickCount()
		end

		local line = fileReadLine(file)
		if not line or line == "" then break end

		-- parse line
		local parts = split(line, ",")
		local rstart = tonumber(parts[1])
		local rend = tonumber(parts[2])
		local country = parts[3]

		-- relative to absolute numbers
		rstart = pos + rstart
		rend = rstart + rend
		pos = rend

		-- top byte is group
		local group = math.floor(rstart / 0x1000000)

		-- remove top byte from ranges
		rstart = rstart - group * 0x1000000
		rend = rend - group * 0x1000000

		if not groups[group] then groups[group] = {} end
		table.insert(groups[group], {
			rstart,
			rend,
			country
		})

	end

	fileClose(file)
	aIP2C.Data = groups

	collectgarbage()

	triggerEvent(EVENT_IP2C, resourceRoot)
end

function getPlayerCountry(player)
   return getIPCountry(getPlayerIP(player))
end

function getCountryName(code)
	if not code then return nil end
    return countryNames[code]
end

function getIPCountry(ip)
	if not isValidIP(ip) then return false end
	if not aIP2C.Data then return false end

	local ipg = tonumber(gettok(ip, 1, "."))
	if not aIP2C.Data[ipg] then return "ZZ" end

	local ipc = gettok(ip, 2, ".") * 65536 + gettok(ip, 3, ".") * 256 + gettok(ip, 4, ".")
	
	for i, data in ipairs(aIP2C.Data[ipg]) do
		if ipc >= data[1] and ipc <= data[2] then return data[3] end
	end
	return "ZZ"
end