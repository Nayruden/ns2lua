class 'TeamJoin' (Entity)

Script.Load("lua/utility/Utility.lua")

TeamJoin.thinkInterval = 0.25

function TeamJoin:OnCreate()
	Entity.OnCreate(self)
	if (Server) then
		self:SetPropagate(Entity.Propagate_Always)
		self:SetNextThink(TeamJoin.thinkInterval)
	end 
end

function TeamJoin:OnLoad()
	 self.teamNumber = tonumber(self.teamNumber)
	 self.touchRadius = tonumber(self.touchRadius)
end

if (Server) then
	function TeamJoin:OnThink()
		Entity.OnThink(self)
		local player
		for key, value in pairs(PlayerClasses) do
			player = Server.FindEntityWithClassnameInRadius(value.mapName, self:GetOrigin(), self.touchRadius, nil)
			if (player ~= nil) then
				if(self.teamNumber == 1 or self.teamNumber == 3 and math.random(2) == 1) then
					player = player:ChangeClass("marine", GetSpawnPos(player.extents) or Vector())
					player:ChangeTeam(Player.Teams.Marines)
				elseif (self.teamNumber == 2) then
					player = player:ChangeClass("skulk", GetSpawnPos(player.extents) or Vector())
					player:ChangeTeam(Player.Teams.Aliens)
				end
			end
		end
		
		self:SetNextThink(TeamJoin.thinkInterval)

    end
end

Shared.LinkClassToMap("TeamJoin", "team_join")