class 'SkulkPlayer' (Player)

PlayerClasses.skulk = SkulkPlayer

SkulkPlayer.modelName           = "models/alien/skulk/skulk.model"
Shared.PrecacheModel(SkulkPlayer.modelName)
Shared.PrecacheModel(SkulkPlayer.modelName)
SkulkPlayer.extents             = Vector(0.4064, 0.4064, 0.4064)
SkulkPlayer.jumpHeight          = 1.25
SkulkPlayer.gravity             = -9.81
SkulkPlayer.walkSpeed           = 14
SkulkPlayer.sprintSpeedScale    = 2
SkulkPlayer.backSpeedScale      = 1
SkulkPlayer.defaultHealth       = 75
SkulkPlayer.WeaponLoadout       = { "weapon_bite" }
SkulkPlayer.TauntSounds         = { "sound/ns2.fev/alien/voiceovers/chuckle" }
SkulkPlayer.stoodViewOffset          = Vector(0, 0.6, 0)
SkulkPlayer.crouchedViewOffset       = Vector(0, 0.6, 0)
for i = 1, #SkulkPlayer.TauntSounds do
    Shared.PrecacheSound(SkulkPlayer.TauntSounds[i])
end

function SkulkPlayer:OnInit()
	Shared.Message("Entering SkulkPlayer:OnInit()")
    Player.OnInit(self)
	
    self:SetBaseAnimation("run", true)
	Shared.Message("Exiting SkulkPlayer:OnInit()")
end

function SkulkPlayer:OnSetBaseAnimation(activity)
    return  nil,
            false
end

function SkulkPlayer:OnUpdatePoseParameters(viewAngles, horizontalVelocity, x, z, pitch, moveYaw)
    Player.OnUpdatePoseParameters(self, viewAngles, horizontalVelocity, x, z, pitch, moveYaw)
    
    self:SetPoseParam("look_pitch", pitch)
    
    local yaw = -Math.Wrap( Math.Degrees(viewAngles.yaw), -180, 180 )
    self:SetPoseParam("look_yaw", yaw)
end

function SkulkPlayer:OnStopPrimaryAttack(input)
    if (Shared.GetTime() > self.activityEnd) then
        self:StopPrimaryAttack()
    end
end

SkulkPlayer.mapName = "skulkplayer"
Shared.LinkClassToMap("SkulkPlayer", "skulkplayer", SkulkPlayer.networkVars )