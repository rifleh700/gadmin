
aColors = {}

addEventHandler("onClientResourceStart", resourceRoot,
	function(resource)
		aLoadColors()
	end
)

function aLoadColors()
	aColors = {}
	local node = xmlLoadFile("conf/colors.xml")
	if not node then return end

	for i, childNode in ipairs(xmlNodeGetChildren(node)) do
		local name = xmlNodeGetAttribute(childNode, "name")
		local r = tonumber(xmlNodeGetAttribute(childNode, "r"))
		local g = tonumber(xmlNodeGetAttribute(childNode, "g"))
		local b = tonumber(xmlNodeGetAttribute(childNode, "b"))
		aColors[name] = {r, g, b}
	end
	xmlUnloadFile(node)
end