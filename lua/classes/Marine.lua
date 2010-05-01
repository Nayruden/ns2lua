class 'MarinePlayer' (Player)

PlayerClasses.marine = MarinePlayer

MarinePlayer.modelName                  = "models/marine/male/male.model"
Shared.PrecacheModel(MarinePlayer.modelName)
MarinePlayer.extents                    = Vector(0.4064, 0.7874, 0.4064)
MarinePlayer.jumpHeight                 = 1
MarinePlayer.gravity                    = -9.81
MarinePlayer.normal_walkSpeed           = 7
MarinePlayer.normal_sprintSpeedScale    = 2
MarinePlayer.normal_moveAcceleration    = 5
MarinePlayer.normal_jumpHeight          = 0.7
MarinePlayer.instagib_walkSpeed         = 12
MarinePlayer.instagib_sprintSpeedScale  = 2
MarinePlayer.instagib_moveAcceleration  = 4
MarinePlayer.instagib_jumpHeight        = 1
MarinePlayer.backSpeedScale             = 0.5
MarinePlayer.defaultHealth              = 100
MarinePlayer.stoodViewOffset            = Vector(0, 1.6256, 0)
MarinePlayer.crouchedViewOffset         = Vector(0, 0.9, 0)
MarinePlayer.WeaponLoadout              = { "weapon_rifle" }
MarinePlayer.TauntSounds                = { "sound/ns2.fev/marine/voiceovers/taunt" }
for i = 1, #MarinePlayer.TauntSounds do
    Shared.PrecacheSound(MarinePlayer.TauntSounds[i])
end
MarinePlayer.flashlightColor            = Color(200, 200, 255, 255)
MarinePlayer.flashlightRadius           = 10
MarinePlayer.flashlightInnerCone        = 0
MarinePlayer.flashlightOuterCone        = 0.6
MarinePlayer.flashlightIntensity        = 0.2

MarinePlayer.maxEnergy                  = 100
MarinePlayer.energyGainPerSecond        = 10
MarinePlayer.flashlightEnergyDrainPerSecond = 12
MarinePlayer.sprintEnergyDrainPerSecond     = 20

MarinePlayer.networkVars = {
    flashlightState              = "predicted boolean",
    energy                       = "predicted integer (0 to "..MarinePlayer.maxEnergy..")",
}

function MarinePlayer:OnInit()
	DebugMessage("Entering MarinePlayer:OnInit()")
    
    Player.OnInit(self)
	
    self:SetBaseAnimation("run", true)
	DebugMessage("Exiting MarinePlayer:OnInit()")
    self.flashlightState = false
    MarinePlayer:SuperchargeWithInstagibMagic(Game.instance.instagib)
    
    self.energy = self.maxEnergy
    
    self.lastDrainTime = Shared.GetTime()
end

function MarinePlayer:SuperchargeWithInstagibMagic(instagib)
    if instagib then
        self.moveAcceleration   = self.instagib_moveAcceleration
        self.jumpHeight         = self.instagib_jumpHeight
        self.walkSpeed          = self.instagib_walkSpeed
        self.sprintSpeedScale   = self.instagib_sprintSpeedScale
    else
        self.moveAcceleration   = self.normal_walkSpeed
        self.jumpHeight         = self.normal_jumpHeight
        self.walkSpeed          = self.normal_walkSpeed
        self.sprintSpeedScale   = self.normal_sprintSpeedScale
    end
end

function MarinePlayer:OnDestroy()
	DebugMessage("Entering MarinePlayer:OnDestroy()")
	if (Client) then
		Client.DestroyRenderLight(self.flashlightObject)
	end
    Player.OnDestroy(self)
	DebugMessage("Exiting MarinePlayer:OnDestroy()")
end

function MarinePlayer:Respawn(overridePosition)
    Player.Respawn(self, overridePosition)
    
    self.energy = self.maxEnergy
end

function MarinePlayer:OnPressToggleFlashlight(input)
    self.flashlightState = not self.flashlightState
    DebugMessage(self.flashlightState and "FL on!" or "FL off!")
end

function MarinePlayer:OnChangeWeapon(weapon)
    weapon:SetAttachPoint("RHand_Weapon")
end

function MarinePlayer:OnReleasePrimaryAttack(input)
    if (Shared.GetTime() > self.activityEnd) then
        self:StopPrimaryAttack()
    end
end

function MarinePlayer:CanPressMovementModifier(input, ground, groundNormal)
    return self.energy > 35
end

function MarinePlayer:CanHoldMovementModifier(input, ground, groundNormal)
    return self.energy > 5
end

function MarinePlayer:OnUpdatePoseParameters(viewAngles, horizontalVelocity, x, z, pitch, moveYaw)
    local dt = Shared.GetTime()-self.lastDrainTime
    Player.OnUpdatePoseParameters(self, viewAngles, horizontalVelocity, x, z, pitch, moveYaw)
    
    self:SetPoseParam("body_pitch", pitch)
    
    if self.flashlightState then -- this should probably be somewhere else.. but this is good enough
        if Client then
            if not self.flashlightObject then
                self.flashlightObject = Client.CreateRenderLight()
                self.flashlightObject:SetColor      (self.flashlightColor    )
                self.flashlightObject:SetRadius     (self.flashlightRadius   )
                self.flashlightObject:SetInnerCone  (self.flashlightInnerCone)
                self.flashlightObject:SetOuterCone  (self.flashlightOuterCone)
                self.flashlightObject:SetIntensity  (self.flashlightIntensity)
            end
            --local coords = self:GetViewAngles():GetCoords()
            --coords.origin = self:GetOrigin() + self.viewOffset + coords.zAxis * 0.5
            --local coords = self:GetAttachPointCoords( self:GetAttachPointIndex("RHand_Weapon") )
            local coords = self:GetActiveWeapon():GetAttachPointCoords( 0 )
            coords = coords * Coords.GetRotation( Vector(0,1,0), math.pi/2 )
            self.flashlightObject:SetCoords(coords)
        end
        self.energy = math.max(self.energy-self.flashlightEnergyDrainPerSecond*dt, 0)
        if self.energy == 0 then
            self.flashlightState = false
        end
    elseif Client and self.flashlightObject then
        Client.DestroyRenderLight(self.flashlightObject)
        self.flashlightObject = nil
    end
    -- this /definately/ shouldn't go here, but meh
    self.energy = math.max(
        self.energy-self.sprintEnergyDrainPerSecond*dt*self.sprintFade,
        0
    )
    self.energy = math.min(self.energy+self.energyGainPerSecond*dt, self.maxEnergy)
    self.lastDrainTime = Shared.GetTime()
end

function MarinePlayer:SecondaryAttack()
    local weapon = self:GetActiveWeapon()
    if (weapon ~= nil) then
        local time = Shared.GetTime()
        if (time > self.activityEnd) then
           if (weapon:Melee(self)) then
                -- self:SetOverlayAnimation( weapon:GetAnimationPrefix() .. "_alt" ) -- Melee animation for thirdperson
                self.activityEnd = time + weapon:GetMeleeDelay()
                self.activity    = Player.Activity.AltShooting
            else
                -- The weapon can't fire anymore (out of bullets, etc.)
                if (self.activity == Player.Activity.AltShooting) then
                    self:StopSecondaryAttack()
                end
                self:Idle()
            end
        end

    end
end

MarinePlayer.mapName = "marineplayer"
Shared.LinkClassToMap("MarinePlayer", "marineplayer", MarinePlayer.networkVars )
