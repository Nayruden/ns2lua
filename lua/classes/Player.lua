--=============================================================================
--
-- RifleRange/Player.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
--
--=============================================================================

Script.Load("lua/utility/Utility.lua")

class 'Player' (Actor)

PlayerClasses.Default = Player

Player.networkVars =
    {
        controller                  = "integer (0 to 127)",
        viewPitch                   = "interpolated predicted angle",
        viewRoll                    = "interpolated predicted angle",
        viewModelId                 = "entityid",
        viewOffset                  = "interpolated vector",
        velocity                    = "predicted vector",
        activeWeaponId              = "entityid",
        overlayAnimationSequence    = "integer (-1 to 60)",
        overlayAnimationStart       = "float",
        thirdPerson                 = "boolean",
        activity                    = "predicted integer (1 to 5)",
        activityEnd                 = "predicted float",
        score                       = "integer",
        health                      = "integer",
        kills                       = "integer",
        deaths                      = "integer",
        moveSpeed                   = "predicted float",
        invert_mouse                = "integer (0 to 1)",
        gravity						= "float",
        sprinting                   = "predicted boolean",
        crouching                   = "predicted boolean",
        taunting                    = "predicted boolean",
		walkSpeed                   = "float",
        sprintSpeed                 = "float",
		backSpeedScale              = "float",
        noclip                      = "predicted boolean",
    }

Script.Load("lua/classes/PlayerInput.lua")

-- Class specific variables
Player.modelName = "models/marine/male/male.model"
Shared.PrecacheModel(Player.modelName)
Player.extents   = Vector(0.4064, 0.7874, 0.4064)
Player.maxWalkableNormal    = math.cos(math.pi * 0.25)
Player.stepHeight           = 0.2
Player.friction				= 6
Player.moveAcceleration     = 4
Player.maxAirWishSpeed		= 3.5
Player.maxSpeed				= 5.6
Player.jumpHeight           = 1
Player.gravity              = -9.81
Player.walkSpeed            = 10
Player.sprintSpeedScale     = 2
Player.crouchSpeedScale     = 0.5
Player.backSpeedScale       = 1
Player.defaultHealth        = 100
Player.stoodViewOffset      = Vector(0, 1.6256, 0)
Player.crouchedViewOffset   = Vector(0, 0.9, 0)
Player.crouchAnimationTime  = 0.5
Player.sprintAnimationTime  = 0.5
Player.WeaponLoadout        = { }
Player.TauntSounds          = { }
Player.StepLeftSound		= "sound/ns2.fev/marine/common/footstep_left"
Player.StepRightSound		= "sound/ns2.fev/marine/common/footstep_right"
for i = 1, #Player.TauntSounds do
    Shared.PrecacheSound(Player.TauntSounds[i])
end

Shared.PrecacheSound(Player.StepLeftSound)
Shared.PrecacheSound(Player.StepRightSound)

Player.Activity             = enum { 'None', 'Drawing', 'Reloading', 'Shooting', 'AltShooting' }
Player.Teams				= enum { 'Marines', 'Aliens' }

function Player:OnCreate()
	DebugMessage("Entering Player:OnCreate()")
    Actor.OnCreate(self)

    self:SetModel(self.modelName)

    self.viewPitch                  = 0
    self.viewRoll                   = 0

    self.velocity                   = Vector(0, 0, 0)

    self.activeWeaponId             = 0
    self.activity                   = Player.Activity.None
    self.activityEnd                = 0

    self.thirdPerson                = false
    self.sprinting                  = false
    self.sprintFade                 = 0
    self.sprintStartTime            = 0
    self.crouching                  = false
    self.crouchFade                 = 0
    self.crouchStartTime            = 0
	self.stepSoundTime				= 0.0
	-- toggles left/right for step sounds
	self.stepSide					= false

    self.overlayAnimationSequence   = Model.invalidSequence
    self.overlayAnimationStart      = 0

    self.health                     = self.defaultHealth
    self.score                      = 0
    self.kills                      = 0
    self.deaths                     = 0
	
    self.moveSpeed					= self.walkSpeed
    self.invert_mouse               = 0
    self.team						= Player.Teams.Marines
    self.controller					= 0
    self.inAir                      = false
    self.isTaunting                 = false
    self.lastFrameTime              = Shared.GetTime()
    
    self.viewOffset                 = self.stoodViewOffset

    -- Collide with everything except group 1. That group is reserved
    -- for things we don't want to collide with.
    self.moveGroupMask              = 0xFFFFFFFD

    if (Server) then

        -- Create the view model entity which is used to display our current weapon.
        local viewModel = Server.CreateEntity(ViewModel.mapName, self:GetOrigin())
        viewModel:SetParent(self)
        self.viewModelId = viewModel:GetId()

    end

    if (Client) then
        self.hudFP = self:SetHud("ui/hud.swf")
        
        --23begin
        self.healthFP = self:SetHud("ui/health.swf")
        --12end  
        
        self.horizontalSwing = 0
        self.verticalSwing   = 0
        self.fov = math.atan(math.tan(math.pi / 4.0) * (GetAspectRatio() / (4.0 / 3.0))) * 2
    end

    self:SetBaseAnimation("run")
    
	if (Server) then
		for i, weapon in ipairs(self.WeaponLoadout) do
			DebugMessage("Giving "..(tostring(self:GetNick()) or "<unknown player>").." a "..weapon..".")
			self:GiveWeapon(weapon)
        end
	end

	DebugMessage("Exiting Player:OnCreate()")
end

function Player:SetController(client)
	self.controller = client
end

function Player:GetController()
	return self.controller
end

function Player:ChangeClass(newClass, overridePosition) -- this is just a shortcut (might keep a bit of backwards compatibility)
    return ChangePlayerClass(self.controller, newClass, self, overridePosition or self:GetOrigin())
end

function Player:ChangeTeam(newTeam)
	self.team = newTeam
end

--
-- Sets the view angles for the player. Note that setting the yaw of the
-- view will also adjust the player's yaw.
--
function Player:SetViewAngles(viewAngles)

    self.viewPitch = viewAngles.pitch
    self.viewRoll  = viewAngles.roll

    local angles = Angles(self:GetAngles())
    angles.yaw  = viewAngles.yaw
    angles.pitch = self.noclip and viewAngles.pitch or 0
    self:SetAngles(angles)

end

--
-- Gets the view angles for the player.
--
function Player:GetViewAngles(viewAngles)
    return Angles(self.viewPitch, self:GetAngles().yaw, self.viewRoll)
end

--
-- Sets the animation which is played on top of the base animation for the player.
-- The overlay animation is typically used to combine an animation like an attack
-- animation with the base movement animation.
--
function Player:SetOverlayAnimation( animationName )

    if ( animationName ~= nil ) then

        local animationSequence = self:GetAnimationIndex( animationName )

        if (self.overlayAnimationSequence ~= animationSequence) then
            self.overlayAnimationSequence = animationSequence
            self.overlayAnimationStart    = Shared.GetTime()
        end

    else
        self.overlayAnimationSequence = Model.invalidSequence
    end

end

function Player:OnSetBaseAnimation(activity)
    return  nil,    -- override player animation (false to prevent)
            nil     -- override weapon animation (false to prevent)
end

function Player:GetVelocitySquared() 
	return self.velocity.x * self.velocity.x + self.velocity.y * self.velocity.y + self.velocity.z * self.velocity.z
end

--
-- Sets the activity the player is currently performing.
--
function Player:SetBaseAnimation(activity)

    local animationPrefix = ""
    local weapon = self:GetActiveWeapon()
    
    local o_activity, o_weapon_activity = self:OnSetBaseAnimation(activity)

    if (o_weapon_activity ~= false and weapon) then
        animationPrefix =  weapon:GetAnimationPrefix() .. "_"
        weapon:SetAnimation( o_weapon_activity or activity)
    end
    
    if (o_activity ~= false) then
        self:SetAnimation(o_activity or (animationPrefix .. activity))
    end
end

--
-- Called by the engine to construct the pose of the bones for the player's model.
--
function Player:BuildPose(poses)

    Actor.BuildPose(self, poses)

    -- Apply the overlay animation if we have one.
    if (self.overlayAnimationSequence ~= Model.invalidSequence) then
        self:AccumulateAnimation(poses, self.overlayAnimationSequence, self.overlayAnimationStart)
    end

end

--
-- Called to handle user input for the player.
--
local lds
function Player:OnProcessMove(input)

    if (Client) then
        self:UpdateWeaponSwing(input)
    elseif Shared.debugKeys then
        local ds, ks = "", ""
        for i = 0, 35 do
            local v = 2^i
            local down = bit.band(input.commands, v) > 0
            ds = ds..(down and 1 or 0)
            if down then
                for k,v in pairs(self.Keys) do
                    if Move[k] == v then
                        ks = ks.." "..k
                        break
                    end
                end
            end
        end
        if ds ~= lds then
            DMsg(ds..ks)
            lds = ds
        end
    end
    
    -- Update the view angles based on the input.
    local angles
    if (self.invert_mouse == 1) then
        angles = Angles(-1 * input.pitch, input.yaw, 0.0)
    else
        angles = Angles(input.pitch, input.yaw, 0.0)
    end
    self:SetViewAngles(angles)

    local viewCoords = angles:GetCoords()

    local fowardAxis = nil
    local sideAxis   = nil
    
    -- Compute the forward and side axis aligned with the world xz plane.
    forwardAxis = Vector(viewCoords.zAxis.x, self.noclip and viewCoords.zAxis.y or 0, viewCoords.zAxis.z)
    sideAxis    = Vector(viewCoords.xAxis.x, self.noclip and viewCoords.xAxis.y or 0, viewCoords.xAxis.z)

    forwardAxis:Normalize()
    sideAxis:Normalize()
    
    local canMove = self:GetCanMove(input, angles, forwardAxis, sideAxis)
    
    self.ground, self.groundNormal = self:GetIsOnGround()
    if (self.ground and self.inAir) then
        self:OnLand(input, forwardAxis, sideAxis)
    end
    self.inAir = self.ground
    
    self.moveSpeed = self.walkSpeed
    
	-- OO handling of all Movement Keys
	self:ProcessMoveKeys(input,angles,forwardAxis,sideAxis)
    
    self.moveSpeed = self.moveSpeed*(1+((self.crouchSpeedScale or 1)-1)*self.crouchFade)
    self.moveSpeed = self.moveSpeed*(1+((self.sprintSpeedScale or 1)-1)*self.sprintFade)
    
    if (self.ground and self.velocity.y <= kEpsilon) then
        -- Since we're standing on the ground, remove any downward velocity.
        self.velocity.y = 0
		self:ApplyFriction(input)
    elseif not self.noclip then
        -- Apply the gravitational acceleration.
        self.velocity.y = self.velocity.y + self.gravity * input.time
		self:ApplyAirFriction(input)
	else
		self:ApplyFriction(input)
    end

	
	if canMove then
		if self.ground then
			self:ApplyMove(input, viewCoords, forwardAxis, sideAxis)
		else
			self:ApplyAirMove(input, viewCoords, forwardAxis, sideAxis)
		end
	end

    -- Transition to the idle animation if the current activity has finished.

    local time = Shared.GetTime()
    
    if (time > self.activityEnd and self.activity == Player.Activity.PrimaryAttack) then
        player:SetOverlayAnimation(nil)
    end

    if (time > self.activityEnd and self.activity == Player.Activity.Reloading) then
        local weapon = self:GetActiveWeapon()
        if (weapon ~= nil) then
            weapon:ReloadFinish()
        end
    end

    if (time > self.activityEnd and self.activity ~= Player.Activity.None) then
        self:Idle()
    end

    if (not Shared.GetIsRunningPrediction()) then
        self:UpdatePoseParameters()
    end
    
    if (Client) then
        local weapon = self:GetActiveWeapon()
        local viewCoords = self:GetViewAngles():GetCoords()
        viewCoords.origin = self:GetOrigin() + self.viewOffset
        local trace = Shared.TraceRay(
            viewCoords.origin,
            viewCoords.origin + viewCoords.zAxis*50,
            weapon and EntityFilterTwo(self, weapon) or EntityFilterOne(self)
        )
        if trace.entity and trace.entity.GetNick then
            self.player_looked_at = true
            PlayerUI_SetDisplayString(tostring(trace.entity:GetNick()))
        elseif self.player_looked_at then
            PlayerUI_SetDisplayString("")
        end
    end
    
end

function Player:UpdateStepSound()
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
	
	if(not self.ground or self.crouching) then
		return
	end
	
	if(self.sprinting) then
		self.stepSoundTime = 250.0
	else
	    self.stepSoundTime = 400.0
	end
	self:PlayStepSound()
end

function Player:PlayStepSound()
	local stepSoundName = self.StepLeftSound
	if(self.stepSide) then
		stepSoundName = self.StepRightSound
	end
	self.stepSide = not self.stepSide
	self:PlaySound(stepSoundName)
end

function Player:ApplyMove(input,  angles, forwardAxis, sideAxis)

	-- Compute the desired movement direction based on the input.
	local wishDirection = forwardAxis * input.move.z + sideAxis * input.move.x
	
	local wishSpeed = math.min(wishDirection:Normalize(), 1) * self.moveSpeed * (input.move.z < 0 and self.backSpeedScale or 1)

	-- Accelerate in the desired direction, ala Quake/Half-Life

	local currentSpeed = Math.DotProduct(self.velocity, wishDirection)
	local addSpeed     = wishSpeed - currentSpeed

	if (addSpeed > 0) then
		local accelSpeed = math.min(addSpeed, Player.moveAcceleration * input.time * wishSpeed)
		self.velocity = self.velocity + wishDirection * accelSpeed
	end
	self:CapHorizontalSpeed()
	
	local offset = nil

	if (self.ground) then
		-- First move the character upwards to allow them to go up stairs and
		-- over small obstacles.
		local start = Vector(self:GetOrigin())
		offset = self:PerformMovement( Vector(0, self.stepHeight, 0), 1 ) - start
	end

	-- Move the player with collision detection.
	self:PerformMovement( self.velocity * input.time, 5 )
	self:UpdateStepSound()

	if (self.ground) then
		-- Finally, move the player back down to compensate for moving them up.
		-- We add in an additional step height for moving down steps/ramps.
		offset.y = offset.y + self.stepHeight
		self:PerformMovement( -offset, 1 )
	end

end
function Player:ApplyFriction(input)	
	local velocity = Vector(self.velocity)
    
    if not self.noclip then
        velocity.y = 0
    end

    local speed = velocity:GetLength()

    if (speed > 0) then

        local drop = speed * self.friction * input.time
        
        local speedScalar = math.max(speed - drop, 0) / speed

        -- Only apply friction in the movement plane.
        self.velocity.x = self.velocity.x * speedScalar
        self.velocity.z = self.velocity.z * speedScalar
        if self.noclip then
            self.velocity.y = self.velocity.y * speedScalar
        end
    end

end

function Player:GetHorizontalSpeed()
	local horizVelo = Vector(self.velocity.x,0,self.velocity.z)
	return horizVelo:GetLength()
end

function Player:CapHorizontalSpeed()
	local horizVelo = Vector(self.velocity.x,0,self.velocity.z)
	if (horizVelo:GetLength() > self.maxSpeed) then
		horizVelo:Normalize()
		self.velocity = Vector(horizVelo.x  * self.maxSpeed, self.velocity.y, horizVelo.z * self.maxSpeed)
	end
end

function Player:ApplyAirMove(input,  angles, forwardAxis, sideAxis)

	-- Compute the desired movement direction based on the input.
	local wishDirection = forwardAxis * input.move.z + sideAxis * input.move.x
	
	local wishSpeed = math.min(wishDirection:Normalize(), 1) * self.moveSpeed * (input.move.z < 0 and self.backSpeedScale or 1)
	wishSpeed = math.min(wishSpeed,self.maxAirWishSpeed)

	-- Accelerate in the desired direction, ala Quake/Half-Life
		
	local currentSpeed = Math.DotProduct(self.velocity, wishDirection)
	local addSpeed     = wishSpeed - currentSpeed

	if (addSpeed > 0) then
		local accelSpeed = math.min(addSpeed, Player.moveAcceleration * input.time * wishSpeed)
		self.velocity = self.velocity + wishDirection * accelSpeed
	end
	self:CapHorizontalSpeed()
	
	local offset = nil

	-- Move the player with collision detection.
	self:PerformMovement( self.velocity * input.time, 5 )

end
function Player:ApplyAirFriction(input)
-- only use friction when on the ground.
end
--
-- Returns true if the player is allowed to move (this doesn't affect moving
-- the view).
--
function Player:GetCanMove(input, viewCoords, forwardAxis, sideAxis)
    return Game.instance:GetHasGameStarted()
end

function Player:GetHeightOffset(height)
    return Vector(0, self.extents.y*height*2, 0)
end
--
-- Returns true if the player is standing on the ground.
--
function Player:GetIsOnGround()

    if (self.velocity.y > 0) then
        -- If we are moving away from the ground, don't treat
        -- us as standing on it.
        return false, nil
    end

    local capsuleRadius = self.extents.x
    local capsuleHeight = (self.extents.y - capsuleRadius) * 2

    local center = Vector(0, capsuleHeight * 0.5 + capsuleRadius, 0)
    local origin = self:GetOrigin()

    local offset = Vector(0, -0.1, 0)

    local traceStart = origin + center
    local traceEnd   = traceStart + offset

    local trace = Shared.TraceCapsule(traceStart, traceEnd, capsuleRadius, capsuleHeight, self.moveGroupMask)
    
    if Shared.debugMovement then
        if Client then
            Client.DebugColor(10, 10, 255, 0)
        end
        DebugCapsule(traceStart, traceEnd, capsuleRadius, capsuleHeight, 0.05)
    end

    if (trace.fraction < 1 and trace.normal.y < Player.maxWalkableNormal) then
        return false, nil
    end

    return trace.fraction < 1 and not self.noclip, trace.normal

end

--
-- Moves by the player by the specified offset, colliding and sliding with the world.
--
function Player:PerformMovement(offset, maxTraces)

    local capsuleRadius = self.extents.x
    local capsuleHeight = (self.extents.y - capsuleRadius) * 2

    local center = Vector(0, capsuleHeight * 0.5 + capsuleRadius, 0)
    local origin = Vector(self:GetOrigin())

    local tracesPerformed = 0

    while (offset:GetLengthSquared() > 0.0 and tracesPerformed < maxTraces) do

        local traceStart = origin + center
        local traceEnd = traceStart + offset

        local trace = Shared.TraceCapsule(traceStart, traceEnd, capsuleRadius, capsuleHeight, self.noclip and 0 or self.moveGroupMask)


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

--
-- Returns the view model entity.
--
function Player:GetViewModelEntity()
    return Shared.GetEntity(self.viewModelId)
end

--
-- Sets the model currently displayed on the view model.
--
function Player:SetViewModel(viewModelName)
    local viewModel = self:GetViewModelEntity()
    viewModel:SetModel(viewModelName)
end

--
-- Returns the currently selected weapon if there is one. If there isn't,
-- returns nil.
--
function Player:GetActiveWeapon()

    if (self.activeWeaponId > 0) then
        return Shared.GetEntity(self.activeWeaponId)
    end

    return nil

end

function Player:RetractWeapon()
	local weaponID = self.activeWeaponId
	if (weaponID and weaponID > 0) then
		self:SetViewModel("")
		-- TODO: Inventory management here
		if (Server) then
			Server.DestroyEntity(Shared.GetEntity(weaponID))
		end
		self.activeWeaponId = 0
	end
end

function Player:OnChangeWeapon(weapon)
    
end

function Player:ChangeWeapon(weapon)
	local weaponID = weapon:GetId()
	if (weaponID ~= self.activeWeaponId) then
		self:RetractWeapon()

        weapon:SetParent(self)
        self:OnChangeWeapon(weapon)
	    self.activeWeaponId = weaponID
	    self:DrawWeapon()
	end
end

--
-- Unholsters the active weapon.
--
function Player:DrawWeapon()

    local weapon = self:GetActiveWeapon()

    if (weapon ~= nil) then
        -- Apply the weapon's view model.
        self:SetViewModel(weapon:GetViewModelName())
        weapon:Draw(self)

        self.activity    = Player.Activity.Drawing
        self.activityEnd = Shared.GetTime() + weapon:GetDrawTime()

    end

end

--
-- Reloads the current weapon.
--
function Player:Reload()
	if (self.activity ~= Player.Activity.Reloading) then
		local weapon = self:GetActiveWeapon()
		if (weapon ~= nil) then
			local time = Shared.GetTime()

			if (time > self.activityEnd and weapon:Reload(self)) then
				self:SetOverlayAnimation( weapon:GetAnimationPrefix() .. "_reload" )
				self.activityEnd = time + weapon:GetReloadTime()
				self.activity    = Player.Activity.Reloading
			end
		end
	end
end

function Player:OnGetPrimaryFireAnimation(weapon)
    return nil -- override overlay animation for firing (return false to prevent)
end

--
-- Performs the primary attack for the current weapon
--
function Player:PrimaryAttack()

    local weapon = self:GetActiveWeapon()

    if (weapon ~= nil) then

        local time = Shared.GetTime()

        if (time > self.activityEnd) then

            if (weapon:FireBullets(self)) then
                local o_animation = self:OnGetPrimaryFireAnimation(weapon)
                if (o_animation ~= false) then
                    self:SetOverlayAnimation(o_animation or (weapon:GetAnimationPrefix().."_fire"))
                end
                self.activityEnd = time + weapon:GetFireDelay()
                self.activity    = Player.Activity.Shooting
            else
                -- The weapon can't fire anymore (out of bullets, etc.)
                if (self.activity == Player.Activity.Shooting) then
                    self:StopPrimaryAttack()
                end
                
				self:Idle()
                
				if (self:GetWeaponClip() == 0 and self:GetWeaponAmmo() > 0) then
                    self:Reload()
                end
            end
        end

    end

end

--
-- Performs the secondary attack for the current weapon
--
function Player:SecondaryAttack()
    
end  


function Player:StopPrimaryAttack()

    local weapon = self:GetActiveWeapon()

    if (weapon ~= nil) then
        weapon:StopPrimaryAttack(self)
    end

    self.activity = Player.Activity.None

end

function Player:StopSecondaryAttack()
    local weapon = self:GetActiveWeapon()

    if (weapon ~= nil) then
        weapon:StopSecondaryAttack(self)
    end

    self.activity = Player.Activity.None

end

function Player:Idle()

    local weapon = self:GetActiveWeapon()

    if (weapon ~= nil) then
        weapon:Idle(self)
    end

    self:SetOverlayAnimation(nil)
    self.activity = Player.Activity.None

end

function Player:GetViewOffset()
    return self.viewOffset
end

function Player:GetVelocity()
	return self.velocity
end

--
-- Retursn the amount of ammo in the clip for the active weapon.
--
function Player:GetWeaponClip()

    local weapon = self:GetActiveWeapon()

    if (weapon ~= nil) then
        return weapon:GetClip()
    end

    return 0

end

--
-- Returns the total amount of ammo for the currently selected weapon.
--
function Player:GetWeaponAmmo()

    local weapon = self:GetActiveWeapon()

    if (weapon ~= nil) then
        return weapon:GetAmmo()
    end

    return 0

end

function Player:OnUpdatePoseParameters(viewAngles, horizontalVelocity, x, z, pitch, moveYaw)
    self:SetPoseParam("move_yaw",   moveYaw)
    self:SetPoseParam("move_speed", horizontalVelocity:GetLength() * 0.25)
    if self.crouching then
        self.crouchFade = math.min((Shared.GetTime()-self.crouchStartTime)/self.crouchAnimationTime, 1)
    else
        self.crouchFade = 1-math.min((Shared.GetTime()-self.crouchStartTime)/self.crouchAnimationTime, 1)
    end
    self:SetPoseParam("crouch", self.crouchFade)
    self.viewOffset = self.stoodViewOffset+(self.crouchedViewOffset-self.stoodViewOffset)*self.crouchFade
    if self.sprinting then
        self.sprintFade = math.min((Shared.GetTime()-self.sprintStartTime)/self.sprintAnimationTime, 1)
    else
        self.sprintFade = 1-math.min((Shared.GetTime()-self.sprintStartTime)/self.sprintAnimationTime, 1)
    end
    self:SetPoseParam("sprint", self.sprintFade)
end

function Player:UpdatePoseParameters()

    local viewAngles = self:GetViewAngles()
    local pitch = -Math.Wrap( Math.Degrees(viewAngles.pitch), -180, 180 )

    local viewCoords = viewAngles:GetCoords()

    local horizontalVelocity = Vector(self.velocity)
    horizontalVelocity.y = 0

    local x = Math.DotProduct(viewCoords.xAxis, horizontalVelocity)
    local z = Math.DotProduct(viewCoords.zAxis, horizontalVelocity)

    local moveYaw = math.atan2(z, x) * 180 / math.pi
    
    self:OnUpdatePoseParameters(viewAngles, horizontalVelocity, x, z, pitch, moveYaw)

end

--
-- Returns true if the player is currently being viewed in 3rd person mode.
--
function Player:GetIsThirdPerson()
    return self.thirdPerson
end

--
-- Sets whether or not the player is being viewed in 3rd person mode.
--
function Player:SetIsThirdPerson(thirdPerson)

    self.thirdPerson = thirdPerson

    -- Hide the view model when we're in third person mode.
    local viewModel = self:GetViewModelEntity()
    if (viewModel ~= nil) then
        viewModel:SetIsVisible( not self.thirdPerson )
    end

end

--
-- Called by the engine to get the object to world space transformation
-- for the camera.
--
function Player:GetCameraViewCoords()
    if Client and Client.spectateTurret then -- added this to debug their aim
        local turret_info = Shared.FindEntities("turret", self:GetOrigin(), 10, true)[1]
        if (turret_info ~= nil) then
            local turret = turret_info.ent
            self:ShowModel(true)
            local viewAngle = turret:GetAngles()
            local viewCoords = Angles(viewAngle.pitch, viewAngle.yaw+90, 0):GetCoords()
            viewCoords.origin = turret:GetOrigin()+turret.fireOffset+Vector(.5, 0, 0)
            return viewCoords
        end
    end
    
    local viewCoords = self:GetViewAngles():GetCoords()

    viewCoords.origin = self:GetOrigin() + self.viewOffset

    if (self.thirdPerson) then
        --viewCoords.origin = viewCoords.origin - viewCoords.zAxis * 0.4 - viewCoords.xAxis * 0.35 + viewCoords.yAxis * 0.1
        viewCoords.origin = viewCoords.origin - viewCoords.zAxis * 2.5
    end

    return viewCoords

end

function Player:OnDestroy()
    if Server and self.viewModel then
        Server.DestroyEntity(self.viewModel)
    elseif Client then
        Client.DestroyFlashPlayer(self.hudFP)
        Client.DestroyFlashPlayer(self.chatFP)
        Client.DestroyFlashPlayer(self.healthFP)
    end
    Actor.OnDestroy(self)
end

if (Server) then

    function Player:GiveWeapon(className)
        local weapon = Server.CreateEntity(className, self:GetOrigin())
		-- TODO: Add inventory management here
        self:ChangeWeapon(weapon)
    end

	function Player:ClearInventory()
		-- TODO: Add inventory management here
		self:RetractWeapon()
	end

    function Player:Respawn(overridePosition, overrideAngle)
		local spawnPos,spawnAng = GetSpawnPos(self.extents)
        self:SetOrigin(overridePosition or spawnPos or Vector())
		self:SetAngles(overrideAngle or spawnAng or Vector())
        self.health = self.defaultHealth
        local weapon = self:GetActiveWeapon()
        if weapon then
            weapon.numBulletsInClip = weapon.clipSize
        end
    end
	
	function Player:GetCanTakeDamage(attacker, damage, doer, point, direction)
		if self.godMode then
			return false
		end
	end
    
    function Player:TakeDamage(attacker, damage, doer, point, direction)
		local o_damage = self:GetCanTakeDamage(attacker, damage, doer, point, direction)
		if o_damage == false then
			return
		elseif o_damage then
			damage = o_damage
		end
        if Server.instagib == true then
            damage = 100
        end
        self.health = self.health - damage
        self.score = self.health
        if (self.health <= 0) then
			if attacker and type(attacker) == "userdata" and attacker.GetNick then
				attacker.kills = (attacker.kills or 0) + 1
				Server.SendKillMessage(attacker:GetNick(), self:GetNick())
			end
            self.deaths = self.deaths + 1
            self:Respawn()
        end

    end

    function Player:SetNick( nickname )
        self.nick = nickname
    end

    function Player:GetNick()
        return self.nick
    end

else
    function Player:GetNick()
        return ClientNicks[self.controller]
    end
end

--
-- Creates an effect at an attachment point for the active weapon.
--
function Player:CreateWeaponEffect(playerAttachPointName, entityAttachPointName, cinematicName)

    local viewEffect = Client and (Client.GetLocalPlayer() == self) and not self:GetIsThirdPerson()

    if (viewEffect) then

        -- Create the effect on the view model entity.
        local viewModel = self:GetViewModelEntity()
        Shared.CreateAttachedEffect(self, cinematicName, viewModel, Coords.GetTranslation(self:GetViewOffset()), entityAttachPointName, true)

    else

        -- Create the effect on the weapon entity.

        local attachPoint = self:GetAttachPointIndex(playerAttachPointName)
        local coords = Coords.GetIdentity();

        if (attachPoint ~= -1) then
            coords = self:GetCoords():GetInverse() * self:GetAttachPointCoords(attachPoint)
        end

        local weapon = self:GetActiveWeapon()
        Shared.CreateAttachedEffect(self, cinematicName, weapon, coords, entityAttachPointName, false)

    end

end


if (Client) then

    --
    -- Sets the Flash movie that's displayed for the HUD.
    --
    function Player:SetHud(hudFileName)

        local flashPlayer = Client.CreateFlashPlayer()
        Client.AddFlashPlayerToDisplay(flashPlayer)

        flashPlayer:Load(hudFileName)
        flashPlayer:SetBackgroundOpacity(0)
        
        return flashPlayer
    end

		function Player:OverrideInput(moveobj)
			--not the best place to put this call but it will do
			KeybindMapper:CheckKeybindChanges()

			moveobj.move = KeybindMapper.MovementVector
			moveobj.commands = KeybindMapper.MoveInputBitFlags
		end

    function Player:GetRenderFov()
        return self.fov
    end
    
    function Player:SetRenderFov(fov)
        self.fov = fov
    end

    function Player:UpdateClientEffects(deltaTime)

        Actor.UpdateClientEffects(self, deltaTime)

        -- Show or hide the local player model depending on whether or not
        -- we're in third person mode for the local player.
        local showModel = Client.GetLocalPlayer() ~= self or self:GetIsThirdPerson()
        self:ShowModel( showModel )

        local activeWeapon = self:GetActiveWeapon()
        if (activeWeapon ~= nil) then
            activeWeapon:ShowModel( showModel )
        end

        self:UpdatePoseParameters()

    end

    function Player:UpdateWeaponSwing(input)

        -- Look at difference between previous and current angles to add "swing" to view model
        local kSwingSensitivity = .5
        local yawDiff = GetAnglesDifference(self:GetViewAngles().yaw, input.yaw)
        self.horizontalSwing = self.horizontalSwing + yawDiff*kSwingSensitivity

        local pitchDiff = GetAnglesDifference(self:GetViewAngles().pitch, input.pitch)
        self.verticalSwing = self.verticalSwing - pitchDiff*kSwingSensitivity

        -- Decrease it non-linearly over time (the farther off center it is the faster it will return)
        local horizontalSwingDampening = 100*input.time*math.sin((math.abs(self.horizontalSwing)/45)*math.pi/2)
        local verticalSwingDampening   = 100*input.time*math.sin((math.abs(self.verticalSwing)/45)*math.pi/2)

        if (self.horizontalSwing < 0) then
            self.horizontalSwing = Math.Clamp(self.horizontalSwing + horizontalSwingDampening, -1, 0)
        elseif (self.horizontalSwing > 0) then
            self.horizontalSwing = Math.Clamp(self.horizontalSwing - horizontalSwingDampening, 0, 1)
        end

        if (self.verticalSwing < 0) then
            self.verticalSwing = Math.Clamp(self.verticalSwing + verticalSwingDampening, -1, 0)
        elseif (self.verticalSwing > 0) then
            self.verticalSwing = Math.Clamp(self.verticalSwing - verticalSwingDampening,  0, 1)
        end

        local viewModel = self:GetViewModelEntity()

        if (viewModel ~= nil) then

            local weapon      = self:GetActiveWeapon()
            local swingAmount = 0

            if (weapon ~= nil) then
                swingAmount = weapon:GetSwingAmount()
            end

            viewModel:SetPoseParam("swing_yaw", self.horizontalSwing * swingAmount)
            viewModel:SetPoseParam("swing_pitch", self.verticalSwing * swingAmount)
        end

    end

end

Player.mapName = "player"
Shared.LinkClassToMap("Player", "player", Player.networkVars )
