--=============================================================================
--
-- RifleRange/Player.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
--
--=============================================================================

Script.Load("lua/Utility.lua")

class 'Player' (Actor)

PlayerClasses.Default = Player

Player.networkVars =
    {
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
        canJump                     = "integer (0 to 1)",
        kills                       = "integer",
        deaths                      = "integer",
        moveSpeed                   = "integer",
        moveSpeedBackwards          = "integer",
        invert_mouse                = "integer (0 to 1)",
        gravity						= "float",
        sprinting                   = "predicted boolean",
        crouching                   = "predicted integer (0 to 3)",
        taunting                    = "predicted boolean",
		walkSpeed                   = "float",
        sprintSpeed                 = "float",
		backSpeedScale              = "float",
    }

-- Class specific variables
Player.modelName = "models/marine/male/male.model"
Shared.PrecacheModel(Player.modelName)
Player.extents   = Vector(0.4064, 0.7874, 0.4064)
Player.maxWalkableNormal    = math.cos(math.pi * 0.25)
Player.stepHeight           = 0.2
Player.friction				= 6
Player.moveAcceleration     = 4
Player.jumpHeight           = 1
Player.gravity              = -9.81
Player.walkSpeed            = 10
Player.sprintSpeedScale     = 5
Player.backSpeedScale       = 1
Player.defaultHealth        = 100
Player.stoodViewOffset      = Vector(0, 1.6256, 0)
Player.crouchedViewOffset   = Vector(0, 0.9, 0)
Player.WeaponLoadout        = { }
Player.TauntSounds          = { }
for i = 1, #Player.TauntSounds do
    Shared.PrecacheSound(Player.TauntSounds[i])
end

Player.Activity             = enum { 'None', 'Drawing', 'Reloading', 'Shooting', 'AltShooting' }
Player.Teams				= enum { 'Marines', 'Aliens' }

function Player:OnInit()
	DebugMessage("Entering Player:OnInit()")
    Actor.OnInit(self)

    self:SetModel(self.modelName)

    self.canJump                    = 1
    self.viewPitch                  = 0
    self.viewRoll                   = 0

    self.velocity                   = Vector(0, 0, 0)

    self.activeWeaponId             = 0
    self.activity                   = Player.Activity.None
    self.activityEnd                = 0

    self.thirdPerson                = false
    self.sprinting                  = false
    self.crouching                  = 0

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
		self.chatFP = self:SetHud("ui/chat.swf")
        
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

	DebugMessage("Exiting Player:OnInit()")
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

function Player:GetCanJump(input, ground, groundNormal)
    return ground
end

function Player:OnJump(input, forwardAxis, sideAxis)
    
end
function Player:OnLand(input, forwardAxis, sideAxis)
    
end

function Player:GetCanCrouch(input, ground, groundNormal)
    return true--ground
end

function Player:OnCrouch(input, forwardAxis, sideAxis)
    
end
function Player:OnStand(input, forwardAxis, sideAxis)
    
end

function Player:GetCanSprint(input, ground, groundNormal)
    return true and not self.crouching
end
function Player:GetCanStartSprint(input, ground, groundNormal)
    return true
end
function Player:OnSprint(input, forwardAxis, sideAxis)
    
end
function Player:OnWalk(input, forwardAxis, sideAxis)
    
end

function Player:GetCanPrimaryAttack(input) -- do not use this for ammo checks!
    return true
end
function Player:OnStartPrimaryAttack(input) -- do not use this for animations!
    
end
function Player:OnStopPrimaryAttack(input)
    
end

function Player:GetCanSecondaryAttack(input) -- do not use this for ammo checks!
    return true
end
function Player:OnStartSecondaryAttack(input) -- do not use this for animations!
    
end
function Player:OnStopSecondaryAttack(input)
    
end

function Player:GetCanReload(input) -- do not use this for specific weapon related checks!
    return true
end
function Player:OnStartReload(input) -- do not use this for animations!
    
end
function Player:OnStopReload(input)
    
end

function Player:GetCanTaunt(input)
    return true
end
function Player:OnStartTaunt(input)
    local sound = table.random(self.TauntSounds)
    if sound then
        self:PlaySound(sound)
    end
end
function Player:OnEndTaunt(input)
    
end

--
-- Called to handle user input for the player.
--
function Player:OnProcessMove(input)

    if (Client) then

        self:UpdateWeaponSwing(input)

        if (Client.GetIsRunningPrediction()) then

            -- When exit hit, bring up menu
            if(bit.band(input.commands, Move.Exit) ~= 0) then
                ShowInGameMenu()
            end

        end

    end

    if(bit.band(input.commands, Move.Taunt) ~= 0 and self:GetCanTaunt(input)) then
        if (not self.taunting) then
            self:OnStartTaunt(input)
        end
        self.taunting = 3
    elseif (self.taunting) then
        self.taunting = self.taunting - 1
        if (self.taunting <= 0) then
            self.taunting = nil
        self:OnEndTaunt(input)
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
    forwardAxis = Vector(viewCoords.zAxis.x, 0, viewCoords.zAxis.z)
    sideAxis    = Vector(viewCoords.xAxis.x, 0, viewCoords.xAxis.z)

    forwardAxis:Normalize()
    sideAxis:Normalize()
	
    local canMove = self:GetCanMove(input, viewCoords, forwardAxis, sideAxis)
    
    local ground, groundNormal = self:GetIsOnGround()
    if (ground and self.inAir) then
        self:OnLand(input, forwardAxis, sideAxis)
    end
    self.inAir = ground

    -- Handle jumping
    if (canMove and self:GetCanJump(input, ground, groundNormal)) then
        if (self.canJump == 0 and bit.band(input.commands, Move.Jump) == 0) then
            self.canJump = 1
        elseif (self.canJump == 1 and bit.band(input.commands, Move.Jump) ~= 0) then
            self.canJump = 0

            -- Compute the initial velocity to give us the desired jump
            -- height under the force of gravity.
            self.velocity.y = math.sqrt(-2 * self.jumpHeight * self.gravity)
            
            self:OnJump(input, forwardAxis, sideAxis)
            ground = false
        end
    end

    -- Handle crouching
    -- From my tests, it seems that the server doesn't always recognize that crouch is pressed, so we have a countdown to uncrouch as well
    if (bit.band(input.commands, Move.Crouch) ~= 0 and self:GetCanCrouch(input, ground, groundNormal)) then
        if (not self.crouching) then
            --self:SetAnimation( "" ) -- Needs a crouch animation
            self.moveSpeed = self.crouchSpeed or self.moveSpeed
			self:SetPoseParam("crouch", 1.0)
            self.viewOffset = self.crouchedViewOffset
            self:OnCrouch(input, forwardAxis, sideAxis)
        end
        self.crouching = 3
    elseif (self.crouching) then
        self.crouching = self.crouching - 1
        if (self.crouching <= 0) then
            self.crouching = nil
            self.curSpeed = self.moveSpeed
			self:SetPoseParam("crouch", 0.0)
            self.viewOffset = self.stoodViewOffset
            self:OnStand(input, forwardAxis, sideAxis)
        end
    end

    if (bit.band(input.commands, Move.MovementModifier) ~= 0 and self:GetCanSprint(input, ground, groundNormal)) then
        if (not self.sprinting and self:GetCanStartSprint(input, ground, groundNormal)) then
            self.sprinting = true
            self.moveSpeed = self.moveSpeed*self.sprintSpeedScale
            self:SetPoseParam("sprint", 1.0)
            self:OnSprint(input, forwardAxis, sideAxis)
        end
    elseif (self.sprinting) then
    	self.sprinting = false
    	self.moveSpeed = self.walkSpeed
    	self:SetPoseParam("sprint", 0.0)
        self:OnWalk(input, forwardAxis, sideAxis)
    end
    
    
    if (ground) then
        -- Since we're standing on the ground, remove any downward velocity.
        self.velocity.y = 0
    else
        -- Apply the gravitational acceleration.
        self.velocity.y = self.velocity.y + self.gravity * input.time
    end

    self:ApplyFriction(input, ground)

    if (canMove) then

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

        local offset = nil

        if (ground) then
            -- First move the character upwards to allow them to go up stairs and
            -- over small obstacles.
            local start = Vector(self:GetOrigin())
            offset = self:PerformMovement( Vector(0, self.stepHeight, 0), 1 ) - start
        end

        -- Move the player with collision detection.
        self:PerformMovement( self.velocity * input.time, 5 )

        if (ground) then
            -- Finally, move the player back down to compensate for moving them up.
            -- We add in an additional step height for moving down steps/ramps.
            offset.y = offset.y + self.stepHeight
            self:PerformMovement( -offset, 1 )
        end

        -- Handle the buttons.

        if (self.activity ~= Player.Activity.Reloading and self:GetCanReload(input)) then
            if (bit.band(input.commands, Move.Reload) ~= 0) then

                if (self.activity == Player.Activity.Shooting) then
                    self:StopPrimaryAttack()
                end
                if (self.activity == Player.Activity.AltShooting) then
                    self:StopSecondaryAttack()
                end

                self:Reload()
                self:OnStartReload(input)

            else

                -- Process attack
                if (bit.band(input.commands, Move.PrimaryAttack) ~= 0 and self:GetCanPrimaryAttack(input)) then
                    self:PrimaryAttack()
                    self:OnStartPrimaryAttack(input)
                elseif (self.activity == Player.Activity.Shooting) then
                    self:StopPrimaryAttack()
                    self:OnStopPrimaryAttack(input)
                end
                if (bit.band(input.commands, Move.SecondaryAttack) ~= 0 and self:GetCanSecondaryAttack(input)) then
                    self:SecondaryAttack()
                    self:OnStartSecondaryAttack(input)
                elseif (self.activity == Player.Activity.AltShooting and Shared.GetTime() > self.activityEnd) then
                    self:StopSecondaryAttack()
                    self:OnStopSecondaryAttack(input)
                end

            end
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
            self:OnStopReload(input)
        end
    end

    if (time > self.activityEnd and self.activity ~= Player.Activity.None) then
        self:Idle()
    end

    if (not Shared.GetIsRunningPrediction()) then
        self:UpdatePoseParameters()
    end

end

function Player:ApplyFriction(input, ground)
    local velocity = Vector(self.velocity)
  
    if (ground) then
        velocity.y = 0
    end

    local speed = velocity:GetLength()

    if (speed > 0) then

        local drop = speed * self.friction * input.time
        
        local speedScalar = math.max(speed - drop, 0) / speed

        -- Only apply friction in the movement plane.
        self.velocity.x = self.velocity.x * speedScalar
        self.velocity.z = self.velocity.z * speedScalar

    end

end

--
-- Returns true if the player is allowed to move (this doesn't affect moving
-- the view).
--
function Player:GetCanMove(input, viewCoords, forwardAxis, sideAxis)
    return Game.instance:GetHasGameStarted()
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

    if (trace.fraction < 1 and trace.normal.y < Player.maxWalkableNormal) then
        return false, nil
    end

    return trace.fraction < 1, trace.normal

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

        local trace = Shared.TraceCapsule(traceStart, traceEnd, capsuleRadius, capsuleHeight, self.moveGroupMask)

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
                if (self:GetWeaponClip() == 0 and self:GetWeaponAmmo() > 0) then
                    self:Reload()
                else
                    self:Idle()
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

    local viewCoords  = self:GetViewAngles():GetCoords()

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

    function Player:Respawn(overridePosition)
        self:SetOrigin(overridePosition or GetSpawnPos(self.extents) or Vector())
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
				attacker.kills = attacker.kills + 1
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
            coords = self:GetObjectToWorldCoords():GetInverse() * self:GetAttachPointCoords(attachPoint)
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
