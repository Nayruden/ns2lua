class 'SkulkPlayer' (Player)

PlayerClasses.Skulk = SkulkPlayer

SkulkPlayer.modelName           = "models/alien/skulk/skulk.model"
Shared.PrecacheModel(SkulkPlayer.modelName)
SkulkPlayer.extents             = Vector(0.4064, 0.4064, 0.4064)
SkulkPlayer.jumpHeight          = 1.25
SkulkPlayer.gravity             = -9.81
SkulkPlayer.walkSpeed           = 14
SkulkPlayer.sprintSpeed         = 28
SkulkPlayer.backSpeedScale      = 1
SkulkPlayer.defaultHealth       = 75
SkulkPlayer.WeaponLoadout       = { "weapon_bite" }
SkulkPlayer.TauntSounds         = { "sound/ns2.fev/alien/voiceovers/chuckle" }
Player.stoodViewOffset          = Vector(0, 0.6, 0)
Player.crouchedViewOffset       = Vector(0, 0.6, 0)
for i = 1, #SkulkPlayer.TauntSounds do
    Shared.PrecacheSound(SkulkPlayer.TauntSounds[i])
end

function SkulkPlayer:OnInit()
    Player.OnInit(self)

    self:SetModel(SkulkPlayer.modelName)
	
    self:SetBaseAnimation("run", true)
end

function SkulkPlayer:OnStopPrimaryAttack(input)
    if (Shared.GetTime() > self.activityEnd) then
        self:StopPrimaryAttack()
    end
end

Shared.LinkClassToMap("SkulkPlayer", "skulkplayer", SkulkPlayer.networkVars )
