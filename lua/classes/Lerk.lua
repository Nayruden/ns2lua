class 'LerkPlayer' (Player)

PlayerClasses.Lerk = LerkPlayer
LerkPlayer.networkVars = {
    gliding = "predicted boolean"
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

	gliding = false
end

function LerkPlayer:OnSetBaseAnimation(activity)
    return  nil,
            false
end

function LerkPlayer:CanPressJump(input)
    return true
end
function LerkPlayer:OnPressJump(input, angles, forwardAxis, sideAxis)
	local forwardVelo = forwardAxis * (self.forwardFlapStrength)
	self.velocity = self.velocity + forwardVelo
	self.velocity.y = self.velocity.y + math.sqrt(-2 * self.jumpHeight * self.gravity)

	self.ground = false
	self.gliding = true
end

function LerkPlayer:CanHoldJump(input, angles, forwardAxis, sideAxis)
	-- Calculate Lift
	local viewCoords = angles:GetCoords()
	local speed = self:GetHorizontalSpeed()
	local lift = speed / self.liftScale * (viewCoords.zAxis.y + 0.5) / 1.5
	lift = math.max(0,math.min(1,lift))

	self.gravity = self.minGravity + (1 - lift) * (self.maxGravity - self.minGravity)

	return true -- OnPressJump is allowed.
end

function LerkPlayer:OnReleaseJump(input, angles, forwardAxis, sideAxis)
	self.gravity = self.maxGravity
	self.gliding = false
end

function LerkPlayer:ApplyAirMove(input, viewCoords, forwardAxis, sideAxis)
	self:ApplyMove(input, viewCoords, forwardAxis, sideAxis)
end
function LerkPlayer:ApplyMove(input, viewCoords, forwardAxis, sideAxis)
	-- Decide glide amount
	if ( self.gliding ) then
		local glide = math.min(self:GetHorizontalSpeed() / self.glideScale, self.maxGlide)

		-- Find direction player is looking
		local eye_dir = Vector(viewCoords.zAxis.x, viewCoords.zAxis.y, viewCoords.zAxis.z)

		-- Calculate move
		local speed = self.velocity:GetLength()
		local projectedSpeed = Math.DotProduct(self.velocity, eye_dir)
		if (projectedSpeed < 0) then
			speed = speed * -1
		end
		local glideVelo = eye_dir * speed
		local veerVelo = (self.velocity - glideVelo) * self.maxGlide

		self.velocity = self.velocity - veerVelo
	end

	self:CapHorizontalSpeed()

	-- Move the player with collision detection.
	self:PerformMovement( self.velocity * input.time, 5 )

end


function LerkPlayer:UpdateStepSound()
    return
end

LerkPlayer.mapName = "LerkPlayer"
Shared.LinkClassToMap("LerkPlayer", "LerkPlayer", LerkPlayer.networkVars )

