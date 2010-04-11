class 'Turret' (Actor)

Turret.modelName  = "models/temp/sentry/sentry.model"
Turret.spawnSound = "sound/ns2.fev/marine/structures/armory_open"
Turret.dieSound   = "sound/ns2.fev/marine/common/health"

Shared.PrecacheModel(Turret.modelName)

Shared.PrecacheSound(Turret.spawnSound)
Shared.PrecacheSound(Turret.dieSound)

Turret.State = enum { 'Idle', 'Firing' }

Turret.thinkInterval = 0.25


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
        
        self:SetNextThink(Turret.thinkInterval)
    end
    
end


Shared.LinkClassToMap("Turret", "turret")
