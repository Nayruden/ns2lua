class 'Chat' (Entity)

Chat.networkVars = 
{
    latestMessageID = "integer",
    message0       = "integer",
    message1       = "integer",
    message2       = "integer",
    message3       = "integer",
    message4       = "integer",
    message5       = "integer",
    message6       = "integer",
    message7       = "integer",
    message8       = "integer",
    message9       = "integer",
    message10       = "integer",
    message11       = "integer",
    message12       = "integer",

}
Chat.updateInterval = 0.1
function Chat:OnInit()

    Entity.OnInit(self)

    Chat.instance = self
    self.message0 = 0
    self.message1 = 0
    self.message2 = 0
    self.message3 = 0
    self.message4 = 0
    self.message5 = 0
    self.message6 = 0
    self.message7 = 0
    self.message8 = 0
    self.message9 = 0
    self.message10 = 0
    self.message11 = 0
    self.message12 = 0
    self.latestMessageID = 0;
    self.UIEnabled = false
    if (Server) then
        // Make the game always propagate to all clients (no visibility checks).
        self:SetPropagate(Entity.Propagate_Always)

    end
    
    self.lastIDProcessed = 0;
    
    self:SetNextThink(self.updateInterval)


end

function Chat:EnableUI()
    self.UIEnabled = true
    Chat.updateInterval = 1
end


function Chat:OnThink()
    if (not UIEnabled) then
        if (self.lastIDProcessed ~= self.latestMessageID) then
            
            Shared.Message(GetMessage())
            
        end
    end
    self:SetNextThink(self.updateInterval)

end

function Chat::IsNewMessageAvailable()
    if (self.lastIDProcessed ~= self.latestMessageID) then
        return true
    else
        return false
    end
end

function Chat:GetMessage()
    self.lastIDProcessed = self.latestMessageID
    local message = ""
    for i=0,12 do
        message = message .. self:IntToString(self[ "message" .. i ])
    end
    return message;

end

function Chat:SetMessage(message)

    message = message;
    for i=0,12 do
        self[ "message" .. i ] = self:StringToInt(message:sub((i*4)+1, (i*4)+5))
    end
    self.latestMessageID = self.latestMessageID + 1;

end

function Chat:IntToString(message)
    local result = ""
    byte0 = bit.rshift(message, 24)
    byte1 = bit.rshift(bit.lshift(message, 8), 24)
    byte2 = bit.rshift(bit.lshift(message, 16), 24)
    byte3 = bit.rshift(bit.lshift(message, 24), 24)
    
    result = string.char(byte0,byte1,byte2,byte3)
    return result;
end

function Chat:StringToInt(message)
    local result = 0
    for i=0, 4-string.len(message) do
        message = message .. "\0"
    end
    byte0 = bit.lshift(string.byte(message, 1), 24);
    byte1 = bit.lshift(string.byte(message, 2), 16);
    byte2 = bit.lshift(string.byte(message, 3), 8);
    byte3 = string.byte(message, 4);
    result = bit.bor(byte0, byte1, byte2, byte3);
    
    return result;
end

Shared.LinkClassToMap("Chat", "chat", Chat.networkVars )