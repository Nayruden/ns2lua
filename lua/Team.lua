class 'Team' (Entity)

Team.thinkInterval = 0.25

Team.networkVars =
{

}

Team.Teams = enum { "Unknown", "Marines", "Kharra" }

function Team:OnInit()
	Entity.OnInit(self)
	
	if (Server) then
		self:SetPropagate(Entity.Propagate_Always)
		self:SetNextThink(Team.thinkInterval)
	end
end

function Team:JoinTeam(player)
	Shared.Message(player .. " is joining team " .. self.team)
end

Shared.LinkClassToMap("TeamJoin","team_location")