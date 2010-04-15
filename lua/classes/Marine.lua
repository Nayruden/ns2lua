class 'MarinePlayer' (Player, Actor)

PlayerClasses.marine = MarinePlayer

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
	Shared.Message("Entering MarinePlayer:OnInit()")
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
	Shared.Message("Exiting MarinePlayer:OnInit()")
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
