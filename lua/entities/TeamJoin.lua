
class 'TeamJoin' (Entity)

TeamJoin.thinkInterval = 0.25

function TeamJoin:OnInit()
	Entity.OnInit(self)
	if (Server) then
		self:SetPropagate(Entity.Propagate_Always)
		self:SetNextThink(TeamJoin.thinkInterval)
	end 
end

if (Server) then
	function TeamJoin:OnThink()
		Entity.OnThink(self)
        
		local player
		for key, value in pairs(PlayerClasses) do
			player = Server.FindEntityWithClassnameInRadius(value.mapName, self:GetOrigin(), 2.5, nil)
			if (player ~= nil) then
				-- Trigger a popup in the future (with the mean being the specfied delay).
				local teamnum = Trim(self.editorTeamNumber)
				if (teamnum == "1" or teamnum == "3" and math.random(2) == 1) then
					player = player:ChangeClass("marine", GetSpawnPos(player.extents) or Vector())
					player:ChangeTeam(Player.Teams.Marines)
				elseif (teamnum == "2") then
					player = player:ChangeClass("skulk", GetSpawnPos(player.extents) or Vector())
					player:ChangeTeam(Player.Teams.Aliens)
				end			
			end
		end
		
		self:SetNextThink(Target.thinkInterval)

    end
end

Shared.LinkClassToMap("TeamJoin", "team_join")