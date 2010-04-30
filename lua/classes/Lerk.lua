class 'LerkPlayer' (Player)

PlayerClasses.buildbot = LerkPlayer
LerkPlayer.networkVars = {

}

LerkPlayer.modelName                = "models/alien/lerk/lerk.model"
Shared.PrecacheModel(LerkPlayer.modelName)
Shared.PrecacheModel(LerkPlayer.modelName)
LerkPlayer.extents                  = Vector(0.4064, 0.7874, 0.4064)

LerkPlayer.walkSpeed           = 14
LerkPlayer.sprintSpeedScale    = 2
LerkPlayer.backSpeedScale      = 1
LerkPlayer.crouchSpeedScale    = 1
LerkPlayer.defaultHealth       = 75
LerkPlayer.WeaponLoadout       = { "weapon_bite" }
LerkPlayer.TauntSounds         = { "sound/ns2.fev/alien/voiceovers/chuckle" }
LerkPlayer.StepLeftSound       = "sound/ns2.fev/alien/skulk/footstep_left"
LerkPlayer.StepRightSound      = "sound/ns2.fev/alien/skulk/footstep_right"
LerkPlayer.stoodViewOffset          = Vector(0, 0.6, 0)
LerkPlayer.crouchedViewOffset       = Vector(0, 0.6, 0)

-- gliding controls
LerkPlayer.jumpHeight               = 1.5
LerkPlayer.forwardFlapStrength 		= 5
LerkPlayer.minGravity 				= 0 -- -4.4
LerkPlayer.maxGravity				= -9.81
LerkPlayer.maxSpeed					= 7
LerkPlayer.liftScale				= 2 -- speed between 0..liftScale determines amount of lift.
LerkPlayer.glideScale				= 5 -- speed between 0..glideScale determines amount of glide.
LerkPlayer.maxGlide					= .2

for i = 1, #LerkPlayer.TauntSounds do
    Shared.PrecacheSound(LerkPlayer.TauntSounds[i])
end

function LerkPlayer:OnInit()
    DebugMessage("Entering LerkPlayer:OnInit()")
    Player.OnInit(self)

    self:SetBaseAnimation("fly", true)
	DebugMessage("Exiting LerkPlayer:OnInit()")
end

function LerkPlayer:OnSetBaseAnimation(activity)
    return  nil,
            false
end

function LerkPlayer:CanPressJump(input)
    return true
end
function LerkPlayer:OnPressJump(input, angles, forwardAxis, sideAxis)
    Player.OnPressJump(self, input)
    self.velocity.x = self.velocity.x + forwardAxis.x*10
    self.velocity.z = self.velocity.z + forwardAxis.z*10
end

function LerkPlayer:UpdateStepSound()
    return
end

LerkPlayer.mapName = "LerkPlayer"
Shared.LinkClassToMap("LerkPlayer", "LerkPlayer", LerkPlayer.networkVars )

