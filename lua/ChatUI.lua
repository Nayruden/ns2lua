function ChatUI_SendMessage(message)
    Shared.ConsoleCommand("say " .. message)
end

function ChatUI_IsNewMessageAvailable()
    return ChatPacket.messageLog:TickMessage()
end

function ChatUI_GetMessage(messageID)
    return ChatPacket.messageLog:GetMessage(messageID)
end

function ChatUI_GetNumberOfMessagesInLog()
    return ChatPacket.messageLog:GetSize()
end