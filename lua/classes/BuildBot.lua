class 'BuildBotPlayer' (Player)

PlayerClasses.buildbot = BuildBotPlayer
BuildBotPlayer.networkVars = {
    gliding = "predicted boolean"
}

BuildBotPlayer.modelName = "models/marine/build_bot/build_bot.model"
Shared.PrecacheModel(BuildBotPlayer.modelName)
Shared.PrecacheModel(BuildBotPlayer.modelName)
BuildBotPlayer.extents = Vector(0.4064, 0.7874, 0.4064)

BuildBotPlayer.walkSpeed = 7
BuildBotPlayer.sprintSpeedScale = 2
BuildBotPlayer.backSpeedScale = 1
BuildBotPlayer.crouchSpeedScale = 1
BuildBotPlayer.defaultHealth = 100
BuildBotPlayer.WeaponLoadout = { "weapon_peashooter" }
BuildBotPlayer.TauntSounds = { "sound/ns2.fev/marine/voiceovers/robot_taunt" }
BuildBotPlayer.stoodViewOffset = Vector(0, 0.6, 0)
BuildBotPlayer.crouchedViewOffset = Vector(0, 0.6, 0)

-- gliding controls
BuildBotPlayer.jumpHeight = 1.5
BuildBotPlayer.forwardFlapStrength = 5
BuildBotPlayer.minGravity = 0 -- -4.4
BuildBotPlayer.maxGravity = -9.81
BuildBotPlayer.maxSpeed = 7
BuildBotPlayer.liftScale = 2 -- speed between 0..liftScale determines amount of lift.
BuildBotPlayer.glideScale = 5 -- speed between 0..glideScale determines amount of glide.
BuildBotPlayer.maxGlide = .2

for i = 1, #BuildBotPlayer.TauntSounds do
    Shared.PrecacheSound(BuildBotPlayer.TauntSounds[i])
end

function BuildBotPlayer:OnCreate()
    DebugMessage("Entering BuildBotPlayer:OnCreate()")
    Player.OnCreate(self)

    self:SetBaseAnimation("fly", true)
DebugMessage("Exiting BuildBotPlayer:OnCreate()")

gliding = false
end

function BuildBotPlayer:OnSetBaseAnimation(activity)
    return nil,
            false
end

function BuildBotPlayer:CanPressJump(input)
    return true
end
function BuildBotPlayer:OnPressJump(input, angles, forwardAxis, sideAxis)
local forwardVelo = forwardAxis * (self.forwardFlapStrength)
self.velocity = self.velocity + forwardVelo
self.velocity.y = self.velocity.y + math.sqrt(-2 * self.jumpHeight * self.gravity)

self.ground = false
self.gliding = true
end

function BuildBotPlayer:CanHoldJump(input, angles, forwardAxis, sideAxis)
-- Calculate Lift
local viewCoords = angles:GetCoords()
local speed = self:GetHorizontalSpeed()
local lift = speed / self.liftScale * (viewCoords.zAxis.y + 0.5) / 1.5
lift = math.max(0,math.min(1,lift))

self.gravity = self.minGravity + (1 - lift) * (self.maxGravity - self.minGravity)

return true -- OnPressJump is allowed.
end

function BuildBotPlayer:OnReleaseJump(input, angles, forwardAxis, sideAxis)
self.gravity = self.maxGravity
self.gliding = false
end

function BuildBotPlayer:ApplyAirMove(input, viewCoords, forwardAxis, sideAxis)
self:ApplyMove(input, viewCoords, forwardAxis, sideAxis)
end
function BuildBotPlayer:ApplyMove(input, viewCoords, forwardAxis, sideAxis)
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


function BuildBotPlayer:UpdateStepSound()
    return
end

BuildBotPlayer.mapName = "buildbotplayer"
Shared.LinkClassToMap("BuildBotPlayer", "buildbotplayer", BuildBotPlayer.networkVars )


