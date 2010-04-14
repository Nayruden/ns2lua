Script.Load("lua/Utility.lua")

class 'Marine' (Player)

Marine.networkVars =
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
        class                       = "integer (0 to 3)",
        moveSpeed                   = "integer",
        moveSpeedBackwards          = "integer",
        invert_mouse                = "integer (0 to 1)",
        gravity						= "float",
        sprinting					= "boolean"
    }

Marine.modelName = "models/marine/male/male.model"
Marine.extents   = Vector(0.4064, 0.7874, 0.4064)

Marine.moveAcceleration     =  4
Marine.stepHeight           =  0.2
Marine.jumpHeight           =  1
Marine.friction				=  6
Marine.maxWalkableNormal    =  math.cos(math.pi * 0.25)

Marine.Activity             = enum { 'None', 'Drawing', 'Reloading', 'Shooting', 'AltShooting' }
Marine.Classes              = enum { 'Marine', 'Skulk', 'BuildBot' }
Marine.Teams				= enum { 'Marines', 'Aliens' }

Marine.marineTauntSound = "sound/ns2.fev/marine/voiceovers/taunt"

Shared.PrecacheModel("models/marine/male/male.model")

Shared.PrecacheModel("models/alien/skulk/skulk.model")

Shared.PrecacheModel("models/marine/rifle/rifle_view_shell.model")
Shared.PrecacheSound(Marine.marineTauntSound)

function Player:OnInit()

    Actor.OnInit(self)

    self:SetModel(Marine.modelName)

    self.canJump                    = 1
    self.viewPitch                  = 0
    self.viewRoll                   = 0

    self.velocity                   = Vector(0, 0, 0)

    self.activeWeaponId             = 0
    self.activity                   = Marine.Activity.None
    self.activityEnd                = 0

    self.viewOffset                 = Vector(0, 1.6256, 0)

    self.thirdPerson                = false
    self.sprinting					= false

    self.overlayAnimationSequence   = Model.invalidSequence
    self.overlayAnimationStart      = 0

    self.health                     = 100
    self.score                      = 0
    self.kills                      = 0
    self.deaths                     = 0
    self.class                      = Marine.Classes.Marine
    self.gravity                    = -9.81
    self.moveSpeed                  = 7
    self.moveSpeedBackwards         = 4
    self.origSpeed					= self.moveSpeed
    self.invert_mouse               = 0
    self.team						= Marine.Teams.Marines
    self.controller					= 0

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

        self:SetHud("ui/hud.swf")
		self:SetHud("ui/chat.swf")
        
        --23begin
        self:SetHud("ui/health.swf")
        --12end  
        
        self.horizontalSwing = 0
        self.verticalSwing   = 0
        self.fov = math.atan(math.tan(math.pi / 4.0) * (GetAspectRatio() / (4.0 / 3.0))) * 2
    end

    self:SetBaseAnimation("run")
    --self:ChangeClass(Marine.Classes.Marine)

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

	if(bit.band(input.commands, Move.Taunt) ~= 0) then
			self:PlaySound(self.marineTauntSound)
	end
	
    local canMove = self:GetCanMove()

    -- Update the view angles based on the input.
    local angles
    if (self.invert_mouse == 1) then
        angles = Angles(-1 * input.pitch, input.yaw, 0.0)
    else
        angles = Angles(input.pitch, input.yaw, 0.0)
    end
    self:SetViewAngles(angles)

    local viewCoords = angles:GetCoords()

    local ground, groundNormal = self:GetIsOnGround()

    local fowardAxis = nil
    local sideAxis   = nil
    
    -- Compute the forward and side axis aligned with the world xz plane.
    forwardAxis = Vector(viewCoords.zAxis.x, 0, viewCoords.zAxis.z)
    sideAxis    = Vector(viewCoords.xAxis.x, 0, viewCoords.xAxis.z)

    forwardAxis:Normalize()
    sideAxis:Normalize()

    -- Handle jumping
    if (canMove and ground) then
        if (self.canJump == 0 and bit.band(input.commands, Move.Jump) == 0) then
            self.canJump = 1
        elseif (self.canJump == 1 and bit.band(input.commands, Move.Jump) ~= 0) then
            self.canJump = 0

            -- Compute the initial velocity to give us the desired jump
            -- height under the force of gravity.
            self.velocity.y = math.sqrt(-2 * Marine.jumpHeight * self.gravity)
            
            if (self.class == Marine.Classes.BuildBot) then
            	self.velocity.x = self.velocity.x + forwardAxis.x*10
            	self.velocity.z = self.velocity.z + forwardAxis.z*10
			end
            ground = false
        end
    end

    -- Handle crouching
    -- From my tests, it seems that the server doesn't always recognize that crouch is pressed, so we have a countdown to uncrouch as well
    if (bit.band(input.commands, Move.Crouch) ~= 0) then
        if (not self.crouching) then
            --self:SetAnimation( "" ) -- Needs a crouch animation
            self.moveSpeed = math.floor( self.origSpeed * 0.5 )
			self:SetPoseParam("crouch", 1.0)
            if not Client then -- Since viewOffset is a network var it looks very odd to execute this on both client and server
                self.viewOffset = Vector(0, 0.9, 0)
            end
        end
        self.crouching = 3
        self.sprinting = false
    elseif (self.crouching) then
        self.crouching = self.crouching - 1
        if (self.crouching <= 0) then
            self.crouching = nil
            self.moveSpeed = self.origSpeed
			self:SetPoseParam("crouch", 0.0)
            if not Client then
                self.viewOffset = Vector(0, 1.6256, 0)
            end
        end
    end

    if (bit.band(input.commands, Move.MovementModifier) ~= 0) and (not self.sprinting) then
    	self.sprinting = true
    	self.moveSpeed = 2 * self.origSpeed
    	self:SetPoseParam("sprint", 1.0)
    elseif (self.sprinting) then
    	self.sprinting = false
    	self.moveSpeed = self.origSpeed
    	self:SetPoseParam("sprint", 0.0)
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
        
        local wishSpeed = nil
        if (self.class == Marine.Classes.Marine) then
           if (input.move.z >= 0) then
              wishSpeed = math.min(wishDirection:Normalize(), 1) * self.moveSpeed
           else
              wishSpeed = math.min(wishDirection:Normalize(), 1) * self.moveSpeedBackwards
           end
        else
           wishSpeed = math.min(wishDirection:Normalize(), 1) * self.moveSpeed
        end
           

        -- Accelerate in the desired direction, ala Quake/Half-Life

        local currentSpeed = Math.DotProduct(self.velocity, wishDirection)
        local addSpeed     = wishSpeed - currentSpeed

        if (addSpeed > 0) then
            local accelSpeed = math.min(addSpeed, Marine.moveAcceleration * input.time * wishSpeed)
            self.velocity = self.velocity + wishDirection * accelSpeed
        end

        local offset = nil

        if (ground) then
            -- First move the character upwards to allow them to go up stairs and
            -- over small obstacles.
            local start = Vector(self:GetOrigin())
            offset = self:PerformMovement( Vector(0, Marine.stepHeight, 0), 1 ) - start
        end

        -- Move the player with collision detection.
        self:PerformMovement( self.velocity * input.time, 5 )

        if (ground) then
            -- Finally, move the player back down to compensate for moving them up.
            -- We add in an additional step height for moving down steps/ramps.
            offset.y = offset.y + Marine.stepHeight
            self:PerformMovement( -offset, 1 )
        end

        -- Handle the buttons.

        if (self.activity ~= Marine.Activity.Reloading) then
            if (bit.band(input.commands, Move.Reload) ~= 0) then

                if (self.activity == Marine.Activity.Shooting) then
                    self:StopPrimaryAttack()
                end
                if (self.activity == Marine.Activity.AltShooting) then
                    self:StopSecondaryAttack()
                end

                self:Reload()

            else

                -- Process attack
                if (bit.band(input.commands, Move.PrimaryAttack) ~= 0) then
                    self:PrimaryAttack()
                elseif (self.activity == Marine.Activity.Shooting) then
                    self:StopPrimaryAttack()
                    if(self.class ~= Marine.Classes.Skulk or Shared.GetTime() > self.activityEnd) then
                       self:StopPrimaryAttack()
                    end
                end
                if (bit.band(input.commands, Move.SecondaryAttack) ~= 0) then
                    self:SecondaryAttack()
                elseif (self.activity == Marine.Activity.AltShooting and Shared.GetTime() > self.activityEnd) then
                    self:StopSecondaryAttack()
                end

            end
        end

    end

    -- Transition to the idle animation if the current activity has finished.

    local time = Shared.GetTime()
    
    if (time > self.activityEnd and self.activity == Marine.Activity.PrimaryAttack) then
        player:SetOverlayAnimation(nil)
    end

    if (time > self.activityEnd and self.activity == Marine.Activity.Reloading) then
        local weapon = self:GetActiveWeapon()
        if (weapon ~= nil) then
            weapon:ReloadFinish()
        end
    end

    if (time > self.activityEnd and self.activity ~= Marine.Activity.None) then
        self:Idle()
    end

    if (not Shared.GetIsRunningPrediction()) then
        self:UpdatePoseParameters()
    end

end


Shared.LinkClassToMap("Player", "player", Marine.networkVars )
