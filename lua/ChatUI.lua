function ChatUI_SendMessage(message)
    Shared.ConsoleCommand("say " .. message)
end

function ChatUI_IsNewMessageAvailable()
    return Chat.instance:IsNewMessageAvailable()
end

function ChatUI_GetLatestMessage()
    return Chat.instance:GetMessage()
end


function ChatUI_GetMessage(messageID)
    return Chat.instance:GetMessageFromLog(messageID)
end

function ChatUI_GetNumberOfMessagesInLog()
    return Chat.instance:GetNumberOfMessagesInLog()
end
