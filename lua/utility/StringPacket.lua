Script.Load("lua/DataPacket.lua")

class 'StringPacket' (DataPacket)

StringPacket.networkVars = {}

-- NOTE: self.numInts must be set before this constructor is called
function StringPacket:OnInit()
	DataPacket.OnInit(self)
	self:ClearString()
end

function StringPacket:GetString()
    local str = ""
    for i = 1, self.numInts do
        str = str .. StringPacket.IntToString(self["i"..i])
    end
    return str;
end

function StringPacket:SetString(str)
	local strIndex = 1
    for i = 1, self.numInts do
		local subStart = strIndex
		strIndex = strIndex + 4
        self["i"..i] = StringPacket.StringToInt(str:sub(subStart, strIndex - 1))
    end
end

function StringPacket:ClearString()
	for i = 1, self.numInts do
		self["i"..i] = 0
	end
end

function StringPacket.IntToString(intBunch)
    local byte0 = bit.rshift(intBunch, 24)
    local byte1 = bit.rshift(bit.lshift(intBunch, 8), 24)
    local byte2 = bit.rshift(bit.lshift(intBunch, 16), 24)
    local byte3 = bit.rshift(bit.lshift(intBunch, 24), 24)
    
    return string.char(byte0,byte1,byte2,byte3)
end

function StringPacket.StringToInt(strBunch)
	-- Pad with nulls to prevent mutant tails
    for i = 1, 4 - string.len(strBunch) do
        strBunch = strBunch .. "\0"
    end
    local byte0 = bit.lshift(string.byte(strBunch, 1), 24)
    local byte1 = bit.lshift(string.byte(strBunch, 2), 16)
    local byte2 = bit.lshift(string.byte(strBunch, 3), 8)
    local byte3 = string.byte(strBunch, 4)
    
    return bit.bor(byte0, byte1, byte2, byte3)
end

Shared.LinkClassToMap("StringPacket", "stringpacket", StringPacket.networkVars)

function DefineStringPacketClass(numBytes)
	local className = "StringPacket" .. tostring(numBytes)
	local strclass = _G[className]

	local numInts = bit.rshift(numBytes, 2)
	strclass.networkVars = {}
	strclass.numInts = numInts

	for i = 1, numInts do
		strclass.networkVars["i"..i] = "integer"
	end

	function strclass:OnInit()
		self.numInts = strclass.numInts
		StringPacket.OnInit(self)
	end

	Shared.LinkClassToMap(className, className:lower(), strclass.networkVars)
end

class 'StringPacket64' (StringPacket)
DefineStringPacketClass(64)