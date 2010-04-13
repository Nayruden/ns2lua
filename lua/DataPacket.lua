class 'DataPacket' (Entity)

DataPacket.networkVars = {}

function DataPacket:OnInit()
	Entity.OnInit(self)
    if (Server) then
        -- Make the game always propagate to all clients (no visibility checks).
        self:SetPropagate(Entity.Propagate_Always)
    end
    self:SetNextThink(0.01)
end

function DataPacket:OnThink()
	self:ProcessPacket()
	if (Server) then
		Server.DestroyEntity(self)
	end
end

function DataPacket:ProcessPacket() end

Shared.LinkClassToMap("DataPacket", "datapacket", DataPacket.networkVars)