class 'Kill' (Entity)

Kill.updateInterval = 0.1
Kill.networkVars = 
{
    latestKillID  = "integer",
    killer0       = "integer",
    killer1       = "integer",
    killer2       = "integer",
    killer3       = "integer",
    killer4       = "integer",
    killed0       = "integer",
    killed1       = "integer",
    killed2       = "integer",
    killed3       = "integer",
    killed4       = "integer"
}

function Kill:OnInit()

    Entity.OnInit(self)

    Kill.instance = self
    self.killer0 = 0
    self.killer1 = 0
    self.killer2 = 0
    self.killer3 = 0
    self.killer4 = 0
    self.killed0 = 0
    self.killed1 = 0
    self.killed2 = 0
    self.killed3 = 0
    self.killed4 = 0
    self.latestKillID = 0
    self.lastIDProcessed = 0
    self.KillerLog = { }
    self.KilledLog = { }
    
    if (Server) then
        // Make the game always propagate to all clients (no visibility checks).
        self:SetPropagate(Entity.Propagate_Always)
    end
    
    self:SetNextThink(self.updateInterval)
end

function Kill:OnThink()
    if ( self.lastIDProcessed ~= self.latestKillID ) then
        table.insert(self.KillerLog, 1, self:GetKiller() )
        table.insert(self.KilledLog, 1, self:GetKilled() )
        self.lastIDProcessed = self.latestKillID
    end
    
    self:SetNextThink(self.updateInterval)
end

function Kill:AddKill(killer, killed)
    for i=0,4 do
        self[ "killer" .. i ] = StringPacket.StringToInt(killer:sub((i*4)+1, (i*4)+5))
    end
    for i=0,4 do
        self[ "killed" .. i ] = StringPacket.StringToInt(killed:sub((i*4)+1, (i*4)+5))
    end
    
    self.latestKillID = self.latestKillID + 1;
end

function Kill:GetKiller()
    local killer = ""
    for i=0,4 do
        killer = killer .. StringPacket.IntToString(self[ "killer" .. i ])
    end
    return killer;
end

function Kill:GetKilled()
    local killed = ""
    for i=0,4 do
        killed = killed .. StringPacket.IntToString(self[ "killed" .. i ])
    end
    return killed;
end

function Kill:GetKillerFromLog(ID)
    return self.KillerLog[ID]
end

function Kill:GetKilledFromLog(ID)
    return self.KilledLog[ID]
end

function Kill:GetNumberOfKillsInLog()
    return table.getn(self.KillerLog)
end

Shared.LinkClassToMap("Kill", "kill", Kill.networkVars )