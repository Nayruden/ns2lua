Script.Load("lua/Utility.lua")

class 'Skulk' (Player)

Skulk.networkVars =
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
  
Skulk.modelName = "models/alien/skulk/skulk.model"
Skulk.extents   = Vector(0.4064, 0.4064, 0.4064)

Skulk.moveAcceleration     =  4
Skulk.stepHeight           =  0.2
Skulk.jumpHeight           =  1
Skulk.friction				=  6
Skulk.maxWalkableNormal    =  math.cos(math.pi * 0.25)

Skulk.Activity             = enum { 'None', 'Drawing', 'Reloading', 'Shooting', 'AltShooting' }
Skulk.Classes              = enum { 'Marine', 'Skulk', 'BuildBot' }
Skulk.Teams				= enum { 'Marines', 'Aliens' }

Skulk.alienTauntSound = "sound/ns2.fev/alien/voiceovers/chuckle"

Shared.PrecacheModel("models/alien/skulk/skulk.model")
Shared.PrecacheModel("models/alien/skulk/skulk_view.model")
Shared.PrecacheModel("models/marine/rifle/rifle_view_shell.model")

Shared.PrecacheSound(Skulk.alienTauntSound)

function Skulk:OnInit()

    Actor.OnInit(self)

    self:SetModel(Skulk.modelName)

    self.canJump                    = 1
    self.viewPitch                  = 0
    self.viewRoll                   = 0

    self.velocity                   = Vector(0, 0, 0)

    self.activeWeaponId             = 0
    self.activity                   = Skulk.Activity.None
    self.activityEnd                = 0

    self.viewOffset                 = Vector(0, 0.6, 0)

    self.thirdPerson                = false
    self.sprinting					= false

    self.overlayAnimationSequence   = Model.invalidSequence
    self.overlayAnimationStart      = 0

    self.health                     = 100
    self.score                      = 0
    self.kills                      = 0
    self.deaths                     = 0
    self.class                      = Skulk.Classes.Skulk
    self.gravity                    = -9.81
    self.moveSpeed                  = 14
    self.origSpeed					= self.moveSpeed
    self.moveSpeedBackwards         = 4
    self.origSpeed					= self.moveSpeed
    self.invert_mouse               = 0
    self.team						= Skulk.Teams.Skulks

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
    --self:ChangeClass(Skulk.Classes.Skulk)

end



--
-- Called to handle user input for the player.
--
function Skulk:OnProcessMove(input)

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
            self.velocity.y = math.sqrt(-2 * Skulk.jumpHeight * self.gravity)
            
            if (self.class == Skulk.Classes.BuildBot) then
            	self.velocity.x = self.velocity.x + forwardAxis.x*10
            	self.velocity.z = self.velocity.z + forwardAxis.z*10
			end
            ground = false
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
        if (self.class == Skulk.Classes.Skulk) then
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
            local accelSpeed = math.min(addSpeed, Skulk.moveAcceleration * input.time * wishSpeed)
            self.velocity = self.velocity + wishDirection * accelSpeed
        end

        local offset = nil

        if (ground) then
            -- First move the character upwards to allow them to go up stairs and
            -- over small obstacles.
            local start = Vector(self:GetOrigin())
            offset = self:PerformMovement( Vector(0, Skulk.stepHeight, 0), 1 ) - start
        end

        -- Move the player with collision detection.
        self:PerformMovement( self.velocity * input.time, 5 )

        if (ground) then
            -- Finally, move the player back down to compensate for moving them up.
            -- We add in an additional step height for moving down steps/ramps.
            offset.y = offset.y + Skulk.stepHeight
            self:PerformMovement( -offset, 1 )
        end

        -- Handle the buttons.

        if (self.activity ~= Skulk.Activity.Reloading) then
            if (bit.band(input.commands, Move.Reload) ~= 0) then

                if (self.activity == Skulk.Activity.Shooting) then
                    self:StopPrimaryAttack()
                end
                if (self.activity == Skulk.Activity.AltShooting) then
                    self:StopSecondaryAttack()
                end

                self:Reload()

            else

                -- Process attack
                if (bit.band(input.commands, Move.PrimaryAttack) ~= 0) then
                    self:PrimaryAttack()
                elseif (self.activity == Skulk.Activity.Shooting) then
                    self:StopPrimaryAttack()
                    if(self.class ~= Skulk.Classes.Skulk or Shared.GetTime() > self.activityEnd) then
                       self:StopPrimaryAttack()
                    end
                end
                if (bit.band(input.commands, Move.SecondaryAttack) ~= 0) then
                    self:SecondaryAttack()
                elseif (self.activity == Skulk.Activity.AltShooting and Shared.GetTime() > self.activityEnd) then
                    self:StopSecondaryAttack()
                end

            end
        end

    end

    -- Transition to the idle animation if the current activity has finished.

    local time = Shared.GetTime()
    
    if (time > self.activityEnd and self.activity == Skulk.Activity.PrimaryAttack) then
        player:SetOverlayAnimation(nil)
    end

    if (time > self.activityEnd and self.activity == Skulk.Activity.Reloading) then
        local weapon = self:GetActiveWeapon()
        if (weapon ~= nil) then
            weapon:ReloadFinish()
        end
    end

    if (time > self.activityEnd and self.activity ~= Skulk.Activity.None) then
        self:Idle()
    end

    if (not Shared.GetIsRunningPrediction()) then
        self:UpdatePoseParameters()
    end

end


Shared.LinkClassToMap("Skulk", "skulk", Skulk.networkVars )
