ChatUI_MessageLog = { }

function ChatUI_AddMessage(msg)
	table.insert(ChatUI_MessageLog, 1, msg)
	for i = 4, #ChatUI_MessageLog do
		ChatUI_MessageLog[i] = nil
	end	
end

function ChatUI_IsNewMessageAvailable()
    return ChatPacket.messageLog:TickMessage()
end

function ChatUI_GetMessage(ID)
    return ChatUI_MessageLog[ID]
end

function ChatUI_GetNumberOfMessagesInLog()
    return #ChatUI_MessageLog
end