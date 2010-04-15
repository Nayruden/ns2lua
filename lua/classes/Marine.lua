class 'MarinePlayer' (Player)

PlayerClasses.marine = MarinePlayer

MarinePlayer.networkVars = {
    flashlightState              = "integer (0 or 1)",
}

MarinePlayer.modelName                  = "models/marine/male/male.model"
Shared.PrecacheModel(MarinePlayer.modelName)
MarinePlayer.extents                    = Vector(0.4064, 0.7874, 0.4064)
MarinePlayer.jumpHeight                 = 1
MarinePlayer.gravity                    = -9.81
MarinePlayer.normal_walkSpeed           = 7
MarinePlayer.normal_sprintSpeedScale    = 2
MarinePlayer.instagib_walkSpeed         = 12
MarinePlayer.instagib_sprintSpeedScale  = 24
MarinePlayer.backSpeedScale             = 0.5
MarinePlayer.defaultHealth              = 100
MarinePlayer.stoodViewOffset            = Vector(0, 1.6256, 0)
MarinePlayer.crouchedViewOffset         = Vector(0, 0.9, 0)
MarinePlayer.WeaponLoadout              = { "weapon_rifle" }
MarinePlayer.TauntSounds                = { "sound/ns2.fev/marine/voiceovers/taunt" }
for i = 1, #MarinePlayer.TauntSounds do
    Shared.PrecacheSound(MarinePlayer.TauntSounds[i])
end

function MarinePlayer:OnInit()
	DebugMessage("Entering MarinePlayer:OnInit()")
    if (Server) then
        if Server.instagib then
            self.walkSpeed = self.instagib_walkSpeed
            self.sprintSpeedScale = self.instagib_sprintSpeedScale
        else
            self.walkSpeed = self.normal_walkSpeed
            self.sprintSpeedScale = self.normal_sprintSpeedScale
        end
    end
    
    Player.OnInit(self)
	
    self:SetBaseAnimation("run", true)
	DebugMessage("Exiting MarinePlayer:OnInit()")
    self.flashlightState = 0
    if (Client) then
        self.flashlightObject = Client.CreateRenderLight()
        self.flashlightObject:SetIntensity(0)
        self.flashlightObject:SetColor(Color(200, 200, 255, 255))
        self.flashlightObject:SetRadius(10)
        self.flashlightObject:SetInnerCone(0)
        self.flashlightObject:SetOuterCone(0.6)
        self.flashlightActive = false
        self.localFlashlightState = nil
    end
end

function MarinePlayer:OnDestroy()
	DebugMessage("Entering MarinePlayer:OnDestroy()")
    self.flashlightObject:SetIntensity(0)
    self.flashlightObject = nil-- Unfortunately, this is lost memory!
    Player.OnDestroy(self)
	DebugMessage("Exiting MarinePlayer:OnDestroy()")
end

function MarinePlayer:OnStartTaunt(input)
    if (bit.band(input.commands, Move.MovementModifier) ~= 0) then
        self.flashlightState = 1-self.flashlightState
        if not Client or Client.GetIsRunningPrediction() then
            DebugMessage(self.flashlightState == 1 and "FL on!" or "FL off!")
        else
            self.localFlashlightState = self.flashlightState
        end
        return false
    end
    return Player.OnStartTaunt(self, input)
end

function MarinePlayer:OnChangeWeapon(weapon)
    weapon:SetAttachPoint("RHand_Weapon")
end

function MarinePlayer:OnStopPrimaryAttack(input)
    if (Shared.GetTime() > self.activityEnd) then
        self:StopPrimaryAttack()
    end
end

function MarinePlayer:OnUpdatePoseParameters(viewAngles, horizontalVelocity, x, z, pitch, moveYaw)
    Player.OnUpdatePoseParameters(self, viewAngles, horizontalVelocity, x, z, pitch, moveYaw)
    
    self:SetPoseParam("body_pitch", pitch)
    
    if Client and self.flashlightObject then -- this should probably be somewhere else.. but this is good enough
        if (not Client.GetIsRunningPrediction() and self.localFlashlightState or self.flashlightState) == 1 then
            if self.flashlightActive == 0 then
                self.flashlightObject:SetIntensity(0.2)
                self.flashlightActive = true
            end
            local coords =self:GetViewAngles():GetCoords()
            coords.origin = self:GetOrigin() + self.viewOffset + coords.zAxis * 1
            self.flashlightObject:SetCoords(coords)
            --DebugMessage("FL moving!")
        elseif self.flashlightActive == 1 then
            self.flashlightObject:SetIntensity(0)
            self.flashlightActive = false
        elseif self.flashlightState == self.localFlashlightState then
            self.localFlashlightState = nil
        end
    end
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
