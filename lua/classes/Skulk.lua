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
SkulkPlayer.walkStepDelay       = 150
SkulkPlayer.sprintStepDelay     = 300
SkulkPlayer.walkStickLength     = 1
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

function SkulkPlayer:OnInit()
	DebugMessage("Entering SkulkPlayer:OnInit()")
    Player.OnInit(self)
	
    self:SetBaseAnimation("run", true)
	DebugMessage("Exiting SkulkPlayer:OnInit()")
end

function SkulkPlayer:MovementTrace(start, offset, capsuleradius, moveGroupMask)
    local trace = Shared.TraceCapsule(start, start+offset, capsuleRadius, 0, moveGroupMask)
    tracesPerformed = tracesPerformed + 1
    
    return trace
end

function SkulkPlayer:PerformMovement(offset, maxTraces)--HURRHURRThisAintFinishedYet_ExclamationMark_ExclamationMark(offset, maxTraces)
    local capsuleRadius = self.extents.x
    local center = Vector(0, capsuleHeight * 0.5 + capsuleRadius, 0)
    local origin = Vector(self:GetOrigin())
    local tracesPerformed = 0
    local moveAngleCoords = self:GetViewAngles():GetCoords()
    while (offset:GetLengthSquared() > 0.0 and tracesPerformed < maxTraces) do
        local traceStart = origin + center
        local traceEnd = traceStart + offset
        local avgDir = Vector(0, 0, 0) -- we can use this later to calculate what angle the model should be at
        local bestDist, bestTrace = 1
        -- trace in all directions and calculate the closest and the average angle
        local traceL = self:MovementTrace(traceStart, traceStart+moveAngleCoords:TransformPoint(Vector(walkStickLength, 0, 0)))
        avgDir = avgDir+traceL:GetCoords().zAxis
        if traceL.fraction < bestDist then bestDist, bestTrace = traceL.fraction, traceL end
        local traceR = self:MovementTrace(traceStart, traceStart+moveAngleCoords:TransformPoint(Vector(-walkStickLength, 0, 0)))
        avgDir = avgDir+traceR:GetCoords().zAxis
        if traceR.fraction < bestDist then bestDist, bestTrace = traceR.fraction, traceL end
        local traceF = self:MovementTrace(traceStart, traceStart+moveAngleCoords:TransformPoint(Vector(0, 0, walkStickLength)))
        avgDir = avgDir+traceF:GetCoords().zAxis
        if traceF.fraction < bestDist then bestDist, bestTrace = traceF.fraction, traceF end
        local traceB = self:MovementTrace(traceStart, traceStart+moveAngleCoords:TransformPoint(Vector(0, 0, -walkStickLength)))
        avgDir = avgDir+traceB:GetCoords().zAxis
        if traceB.fraction < bestDist then bestDist, bestTrace = traceB.fraction, traceB end
        local traceU = self:MovementTrace(traceStart, traceStart+moveAngleCoords:TransformPoint(Vector(0, walkStickLength, 0)))
        avgDir = avgDir+traceU:GetCoords().zAxis
        if traceU.fraction < bestDist then bestDist, bestTrace = traceU.fraction, traceU end
        -- don't bother sticking downwards!
        
        -- standard movement
        local trace = Shared.TraceCapsule(traceStart, traceEnd, capsuleRadius, 0, self.noclip and 0 or self.moveGroupMask)

        if (trace.fraction < 1) then
			
			--DMsg("collide")

            -- Remove the amount of the offset we've already moved.
            offset = offset * (1 - trace.fraction)

            -- Make the motion perpendicular to the surface we collided with so we slide.
            offset = offset - offset:GetProjection(trace.normal)

            completedSweep = false
            capsuleSweepHit = true

        else
            offset = Vector(0, 0, 0)
        end

        origin = trace.endPoint - center
        tracesPerformed = tracesPerformed + 1

    end

    self:SetOrigin(origin)
    return origin
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

SkulkPlayer.mapName = "skulkplayer"
Shared.LinkClassToMap("SkulkPlayer", "skulkplayer", SkulkPlayer.networkVars )