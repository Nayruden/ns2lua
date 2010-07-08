
ChatUI = {
	NewMessages = {},
	UsedMessageTable = {},
	ChatOpened = false,
	
	LineSpacing = 16,
	FontSize = 16,
	TextFadeLength = 2,
	TextFadeDelay = 7,
	MaxLineWidth = 500,
	HistoryBufferSize = 60,
	MaxVisibleLines = 10,
	PosX = 20,
	PosY = 300,
}



local qtrm = "^\"?(.-)\"?$"

function OnChatMessage(src, teamcolour, name, msg)	-- Should test if this message is coming from server
	name = name:match(qtrm)
	msg = msg:match(qtrm)
	
	ChatUI:AddPlayerMessage(teamcolour, name, msg)
end

Event.Hook("Console_cmsg",  OnChatMessage)

function ChatUI:AddPlayerMessage(teamcolour, player, message)
	local i = #self.NewMessages
	
	self.NewMessages[i+1] = teamcolour
	self.NewMessages[i+2] = player
	self.NewMessages[i+3] = message
end

function ChatUI:OpenChat()
	self.ChatOpened = true
	Client.SetMouseVisible(true)
  Client.SetMouseCaptured(false)
end

KeybindMapper:LinkBindToSelfFunction("TextChat", ChatUI, "OpenChat")

function ChatUI:OnChatClosed()
	self.ChatOpened = false
	Client.SetMouseVisible(false)
  Client.SetMouseCaptured(true)
end

function ChatUI:OnEnterPressed()

	if(self.ChatOpened) then
		
	end
end

--KeybindMapper:LinkKeyToSelfFunction("Enter", "OnEnterPressed", ChatUI)


function ChatUI_GetNewMessages()
	
	if(#ChatUI.NewMessages == 0) then
		return nil
	end
	
	local messages = ChatUI.NewMessages
	
	ChatUI.NewMessages = ChatUI.UsedMessageTable
	table.clear(ChatUI.NewMessages)
	ChatUI.UsedMessageTable = messages
	
	return messages
end

function ChatUI_SendMessage(msg)
	if(msg ~= "") then
		Shared.ConsoleCommand("say "..msg)
	end
end

function ChatUI_IsOpen(currentstate)
	return ChatUI.ChatOpened
end

function ChatUI_ChatClosed()
 	ChatUI:OnChatClosed()
end

function ChatUI_GetLineSpacing()
	return ChatUI.LineSpacing
end

function ChatUI_GetPosition()
	return {ChatUI.PosX, ChatUI.PosY}
end


--can't realy change this value yet, still some hardcode values based on this size
function ChatUI_GetFontSize()
	return ChatUI.FontSize
end

function ChatUI_GetMaxLineCount()
	return ChatUI.MaxVisibleLines
end

function ChatUI_GetTextFadeLength()
	return ChatUI.TextFadeLength
end

function ChatUI_GetTextFadeDelay()
	return ChatUI.TextFadeDelay
end

function ChatUI_GetMaxLineWidth()
	return ChatUI.MaxLineWidth
end

function ChatUI_GetHistorySize()
	return ChatUI.HistoryBufferSize
end

function ReloadChatFlash(DoOnClose)
	
	if(ChatFlash ~= nil) then
		Shared.Message("ReloadChatFlash")
		 Client.DestroyFlashPlayer(ChatFlash)
		 ChatFlash = nil
	end
	
	ChatFlash = Client.CreateFlashPlayer()

	Client.AddFlashPlayerToDisplay(ChatFlash)
	ChatFlash:Load("/ui/chat.swf")
	ChatFlash:SetBackgroundOpacity(0)
	
	if(DoOnClose and ChatUI.ChatOpened) then
		ChatUI:OnChatClosed()
	end
	

	if(KeybindMapper) then
		KeybindMapper.ConsoleOpen = true
	end
end

Event.Hook("MapPostLoad", function() ReloadChatFlash() end )


Event.Hook("Console_reloadchat",  ReloadChatFlash)