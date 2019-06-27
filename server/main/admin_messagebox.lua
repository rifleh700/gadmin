
MB_WARNING = 1
MB_ERROR = 2
MB_QUESTION = 3
MB_INFO = 4

MB_YESNO = 1
MB_OK = 2

function messageBox(message, icon, messageType)
    triggerClientEvent(client, EVENT_MESSAGE_BOX, client, message, icon, messageType)
end
