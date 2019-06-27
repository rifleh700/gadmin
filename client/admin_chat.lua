
local aChatHistory = {
	List = {},
	Max = nil
}

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		aChatHistory.Max = 50

		addEventHandler("onClientChatMessage", root,
			function(message)
				aChatHistory.List[#aChatHistory.List + 1] = {
					time = getRealTime().timestamp,
					text = message
				}
				while #aChatHistory.List > aChatHistory.Max do
					table.remove(aChatHistory.List, 1)
				end
			end
		)
	end
)

function aGetChatHistory()
	return aChatHistory.List
end