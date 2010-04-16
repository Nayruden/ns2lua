class 'Turret' (Actor)

Turret.modelName  = "models/temp/sentry/sentry.model"
Turret.spawnSound = "sound/ns2.fev/marine/structures/armory_open"
Turret.dieSound   = "sound/ns2.fev/marine/common/health"
Turret.fireSound             = "sound/ns2.fev/marine/rifle/fire_single"
Turret.muzzleFlashCinematic  = "cinematics/marine/rifle/muzzle_flash.cinematic"
Turret.shellCinematic        = "cinematics/marine/rifle/shell.cinematic"
Turret.hitCinematic          = "cinematics/marine/hit.cinematic"

Shared.PrecacheModel(Turret.modelName)

Shared.PrecacheSound(Turret.spawnSound)
Shared.PrecacheSound(Turret.dieSound)
Shared.PrecacheSound(Turret.fireSound)

Turret.State = enum { 'Idle', 'Firing' }

Turret.thinkInterval    = 0.05 -- this is a live entity
Turret.attackRadius     = 10
Turret.fireDelay        = 0.2
Turret.fireDamage       = 2
Turret.fireOffset       = Vector(0, 0.5, 0)

function Turret:OnInit()
    Actor.OnInit(self)
    
    if (Client) then    
        -- Don't collide with the player (once we're physically simulated)
        -- since the simulation is different on the server and client.
        self.physicsGroup = 1
    end
    
    if (Server) then      
        self:SetNextThink(self.thinkInterval)
    end
    
    self.attackRadius = tonumber(self.attackRadius) or 10
    self.nextFireTime = 0
end

function Turret:OnLoad()
    Actor.OnLoad(self)
    self.attackRadius = tonumber(self.attackRadius) or 10
    self:SetModel(self.modelName)
    self:SetAnimation( "popup" )
end

function Turret:Popup()
    self:SetModel(self.modelName)
    self:SetAnimation( "popup" )
    
    self:PlaySound(self.spawnSound)
  
end

function Turret:GetNick()
    return "Turret"
end

function Turret:OnThink()
    Actor.OnThink(self)
    
    local player_info = Shared.FindEntities(GetPlayerClassMapNames(), self:GetOrigin(), self.attackRadius, true)[1]
    
    if (player_info ~= nil) then
        local player = player_info.ent
        -- Trigger a popup in the future (with the mean being the specfied delay).
        --self.popupTime = time + Shared.GetRandomFloat(0, self.popupDelay * 2)
        
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
        if (Server and Shared.GetTime() > self.nextFireTime) then
            --Msg("delay passed")
            local startPoint, endPoint = self:GetOrigin()+self.fireOffset, player:GetOrigin()+player:GetViewOffset()
            --Msg("tracing")
            local trace = Shared.TraceRay(startPoint, endPoint, EntityFilterOne(self))
            --Msg("traced")
            if trace.entity == player then
                --Msg("have target")
                do -- CreateHitEffect
                    local coords = Coords.GetOrthonormal(trace.normal)
                    --Msg("have hit coords")
                    coords.origin = trace.endPoint
                    Shared.CreateEffect(player, self.hitCinematic, nil, coords)
                   -- Msg("hit effect done")
                end
                local direction = (trace.endPoint - startPoint):GetUnit()
                --Msg("have direction")
                player:TakeDamage(self, self.fireDamage, self, trace.endPoint, direction)
                --Msg("damage taken")
                do -- CreateMuzzleEffect
                    --local coords = self:GetObjectToWorldCoords():TransformPoint(self.fireOffset+Vector(0, 0, .5))
                    local coords = self:GetAngles():GetCoords()
                    coords.origin = self:GetObjectToWorldCoords():TransformPoint(self.fireOffset+Vector(.5, 0, 0))
                    --Msg("muzzle coords obtained")
                    Shared.CreateEffect(self, self.muzzleFlashCinematic, nil, coords)
                    --Msg("muzzle effect created")
                end
                self:PlaySound(self.fireSound)
            end
            self.nextFireTime = Shared.GetTime()+self.fireDelay
            --Msg("fire complete!")
        end
    end
    
    self:SetNextThink(Turret.thinkInterval)
end


Shared.LinkClassToMap("Turret", "turret")
