function ChatUI_SendMessage(message)
    Shared.ConsoleCommand("say " .. message)
end

function ChatUI_IsNewMessageAvailable()
    return Chat.instance:IsNewMessageAvailable()
end

function ChatUI_GetLatestMessage()
    return Chat.instance:GetMessage()
end

//this makes it so that nothing is pritned to the console
function ChatUI_Enable()
    Chat.instance:EnableUI()
end

