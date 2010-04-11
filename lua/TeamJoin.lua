
class 'TeamJoin' (Entity)

TeamJoin.thinkInterval = 0.25

function TeamJoin:OnInit()
	Entity.OnInit(self)
	if (Server) then
		self:SetPropagate(Entity.Propagate_Always)
		self:SetNextThink(TeamJoin.thinkInterval)
	end 
end


function TeamJoin:GoToGame(player)
 local extents = Player.extents
	local offset  = Vector(0, extents.y + 0.01, 0)

    repeat
        spawnPoint = Shared.FindEntityWithClassname("player_start", spawnPoint)
    until spawnPoint == nil or not Shared.CollideBox(extents, spawnPoint:GetOrigin() + offset)
	// Repeat this because you fall throught the world on the first map.
	spawnPoint = Shared.FindEntityWithClassname("player_start", spawnPoint)
    local spawnPos = Vector(0, 0, 0)

    if (spawnPoint ~= nil) then
        spawnPos = Vector(spawnPoint:GetOrigin())
        // Move the spawn position up a little bit so the player won't start
        // embedded in the ground if the spawn point is positioned on the floor
        spawnPos.y = spawnPos.y + 0.01
    end
    
    player:SetOrigin(spawnPos)

end


if (Server) then
	function TeamJoin:OnThink()
		Entity.OnThink(self)
		
		
		local player = Server.FindEntityWithClassnameInRadius("player", self:GetOrigin(), 2.5, nil)   
		if (player ~= nil) then
			// Trigger a popup in the future (with the mean being the specfied delay).
			local teamnum = Trim(self.editorTeamNumber)
			if (teamnum == "1") then
				player:ChangeClass(Player.Classes.Marine)
				player:ChangeTeam(Player.Teams.Marines)
			elseif (teamnum == "2") then
				player:ChangeClass(Player.Classes.Skulk)
				player:ChangeTeam(Player.Teams.Aliens)
			elseif (teamnum  == "3") then
				if (math.random(2) == 1) then
					player:ChangeClass(Player.Classes.Marine)
					player:ChangeTeam(Player.Teams.Marines)
				else
					player:ChangeClass(Player.Classes.Skulk)
					player:ChangeTeam(Player.Teams.Aliens)
				end
			end
			self:GoToGame(player)
		 end
        self:SetNextThink(Target.thinkInterval)

    end
end

Shared.LinkClassToMap("TeamJoin", "team_join")