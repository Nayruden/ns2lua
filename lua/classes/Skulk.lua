class 'SkulkPlayer' (Player)

PlayerClasses.skulk = SkulkPlayer

SkulkPlayer.networkVars = {
    
}

SkulkPlayer.modelName           = "models/alien/skulk/skulk.model"
Shared.PrecacheModel(SkulkPlayer.modelName)
SkulkPlayer.extents             = Vector(0.4064, 0.4064, 0.4064)
SkulkPlayer.maxAirWishSpeed		= 3.5
SkulkPlayer.maxSpeed			= 8
SkulkPlayer.jumpHeight          = 1
SkulkPlayer.gravity             = -9.81
SkulkPlayer.walkSpeed           = 14
SkulkPlayer.sprintSpeedScale    = 2
SkulkPlayer.backSpeedScale      = 1
SkulkPlayer.crouchSpeedScale    = 1
SkulkPlayer.defaultHealth       = 75
SkulkPlayer.WeaponLoadout       = { "weapon_bite" }
SkulkPlayer.TauntSounds         = { "sound/ns2.fev/alien/voiceovers/chuckle" }
SkulkPlayer.StepLeftSound       = "sound/ns2.fev/alien/skulk/footstep_left"
SkulkPlayer.StepRightSound      = "sound/ns2.fev/alien/skulk/footstep_right"
SkulkPlayer.stoodViewOffset          = Vector(0, 0.6, 0)
SkulkPlayer.crouchedViewOffset       = Vector(0, 0.6, 0)
for i = 1, #SkulkPlayer.TauntSounds do
    Shared.PrecacheSound(SkulkPlayer.TauntSounds[i])
end

Shared.PrecacheSound(SkulkPlayer.StepLeftSound)
Shared.PrecacheSound(SkulkPlayer.StepRightSound)

function SkulkPlayer:OnCreate()
	DebugMessage("Entering SkulkPlayer:OnCreate()")
    Player.OnCreate(self)
	
    self:SetBaseAnimation("run", true)
	DebugMessage("Exiting SkulkPlayer:OnCreate()")
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

function SkulkPlayer:OnReleasePrimaryAttack(input)
    if (Shared.GetTime() > self.activityEnd) then
        self:StopPrimaryAttack()
    end
end

function SkulkPlayer:UpdateStepSound()
	if(self.stepSoundTime > 0) then
		self.stepSoundTime = self.stepSoundTime - 1000.0 * (Shared.GetTime() - self.lastFrameTime)
		if(self.stepSoundTime < 0) then
			self.stepSoundTime = 0
		end
	end
    self.lastFrameTime = Shared.GetTime()
	if(self.stepSoundTime > 0) then
		return
	end
	local velocity = Vector(self.velocity)
	velocity.y = 0
	local speed = velocity:GetLength()
	
	if(speed < (self.walkSpeed * 0.3)) then
		return
	end
	
	if(not self.ground) then
		return
	end
	
	if(self.sprinting) then
		self.stepSoundTime = 150.0
	else
	    self.stepSoundTime = 300.0
	end
	self:PlayStepSound()
end

SkulkPlayer.mapName = "skulkplayer"
Shared.LinkClassToMap("SkulkPlayer", "skulkplayer", SkulkPlayer.networkVars )