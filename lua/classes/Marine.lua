class 'MarinePlayer' (Player)

PlayerClasses.Marine = MarinePlayer

MarinePlayer.modelName              = "models/alien/skulk/skulk.model"
Shared.PrecacheModel(MarinePlayer.modelName)
MarinePlayer.extents                = Vector(0.4064, 0.7874, 0.4064)
MarinePlayer.jumpHeight             = 1
MarinePlayer.gravity                = -9.81
MarinePlayer.normal_walkSpeed       = 7
MarinePlayer.normal_sprintSpeed     = 14
MarinePlayer.instagib_walkSpeed     = 12
MarinePlayer.instagib_sprintSpeed   = 24
MarinePlayer.backSpeedScale         = 0.5
MarinePlayer.defaultHealth          = 100
Player.stoodViewOffset              = Vector(0, 1.6256, 0)
Player.crouchedViewOffset           = Vector(0, 0.9, 0)
MarinePlayer.WeaponLoadout          = { "weapon_rifle" }
MarinePlayer.TauntSounds            = { "sound/ns2.fev/marine/voiceovers/taunt" }
for i = 1, #MarinePlayer.TauntSounds do
    Shared.PrecacheSound(MarinePlayer.TauntSounds[i])
end

function MarinePlayer:OnInit()
    if Server.instagib then
        self.walkSpeed = self.instagib_walkSpeed
        self.sprintSpeed = self.instagib_sprintSpeed
    else
        self.walkSpeed = self.normal_walkSpeed
        self.sprintSpeed = self.normal_sprintSpeed
    end
    
    Player.OnInit(self)

    self:SetModel(MarinePlayer.modelName)
	
    self:SetBaseAnimation("run", true)
end

function MarinePlayer:OnStopPrimaryAttack(input)
    if (Shared.GetTime() > self.activityEnd) then
        self:StopPrimaryAttack()
    end
end

Shared.LinkClassToMap("MarinePlayer", "marineplayer", MarinePlayer.networkVars )
