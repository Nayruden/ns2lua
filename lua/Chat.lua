Script.Load("lua/StringPacket.lua")

class 'ChatPacket' (StringPacket64)


ChatPacket.networkVars = {}
ChatPacket.messageLog = {
	messages = {},
	untickedMessages = 0
}

function ChatPacket:OnInit()
    StringPacket64.OnInit(self)
end

function ChatPacket:ProcessPacket()
	local message = self:GetString()
	if (Client) then
		Shared.Message(message)
	end
	ChatPacket.messageLog:Insert(message)
end

function ChatPacket.messageLog:Insert(message)
	table.insert(self.messages, 1, message)
	self.untickedMessages = self.untickedMessages + 1
end

function ChatPacket.messageLog:GetMessage(messageID)
	return self.messages[messageID]
end

function ChatPacket.messageLog:GetSize()
	return table.getn(self.messages)
end

function ChatPacket.messageLog:TickMessage()
	if (self.untickedMessages > 0) then
		self.untickedMessages = self.untickedMessages - 1
		return true
	else
		return false
	end
end

Shared.LinkClassToMap("ChatPacket", "chatpacket", ChatPacket.networkVars)