class 'Turret' (Actor)

Turret.modelName  = "models/temp/sentry/sentry.model"
Turret.spawnSound = "sound/ns2.fev/marine/structures/armory_open"
Turret.dieSound   = "sound/ns2.fev/marine/common/health"

Shared.PrecacheModel(Turret.modelName)

Shared.PrecacheSound(Turret.spawnSound)
Shared.PrecacheSound(Turret.dieSound)

Turret.State = enum { 'Idle', 'Firing' }

Turret.thinkInterval = 0.25
Turret.attackRadius = 393.7

function Turret:OnInit()
    Actor.OnInit(self)
       
    if (Client) then    
        // Don't collide with the player (once we're physically simulated)
        // since the simulation is different on the server and client.
        self.physicsGroup = 1
    end
    
    if (Server) then      
        self:SetNextThink(Turret.thinkInterval)
    end
    
end

function Turret:OnLoad()
    Actor.OnLoad(self)
end

function Turret:Popup()
    self:SetModel(self.modelName)
    self:SetAnimation( "popup" )
    
    self:PlaySound(self.spawnSound)
  
end

if (Server) then

    function Turret:OnThink()
        Actor.OnThink(self)
        
        local player = Server.FindEntityWithClassnameInRadius("player", self:GetOrigin(), self.attackRadius, nil)
        
        if (player ~= nil) then
        	// Trigger a popup in the future (with the mean being the specfied delay).
            //self.popupTime = time + Shared.GetRandomFloat(0, self.popupDelay * 2)
            
            local target = Vector(player:GetOrigin())
            local mypos = Vector(self:GetOrigin())
            
            local x1 = target.x - mypos.x
            local y1 = target.y - mypos.y
            local z1 = target.z - mypos.z

			local horizHypSqr = (x1*x1+z1*z1)
			local horizHyp = math.sqrt(horizHypSqr)
			local vertHyp = math.sqrt(horizHypSqr+y1*y1)

			local yaw = math.acos(x1 / horizHyp)
			if (z1 > 0) then
				yaw = math.pi*2 - yaw
			end
			local pitch = math.asin(y1 / vertHyp)

            self:SetAngles(Angles(0, yaw, pitch))
        end
        
        self:SetNextThink(Turret.thinkInterval)
    end
    
end


Shared.LinkClassToMap("Turret", "turret")
