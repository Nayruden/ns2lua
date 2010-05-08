class 'PeaShooter' (Weapon)

PeaShooter.networkVars =
    {
        firingState                 = "integer (0 to 2)",
        numBulletsInReserve         = "integer (0 to 1000)",
        numBulletsInClip            = "integer (0 to 60)",
    }

PeaShooter.viewModelName         = "models/marine/rifle/rifle_view_shell.model"
PeaShooter.worldModelName        = "models/marine/rifle/rifle.model"
PeaShooter.drawSound             = "sound/ns2.fev/marine/rifle/draw"
PeaShooter.fireSound             = "sound/ns2.fev/marine/rifle/fire_single"
PeaShooter.fireLoopSound         = "sound/ns2.fev/marine/rifle/fire_14_sec_loop"
PeaShooter.fireEndSound          = "sound/ns2.fev/marine/rifle/fire_14_sec_end"
PeaShooter.reloadSound           = "sound/ns2.fev/marine/rifle/reload"
PeaShooter.muzzleFlashCinematic  = "cinematics/marine/rifle/muzzle_flash.cinematic"
PeaShooter.shellCinematic        = "cinematics/marine/rifle/shell.cinematic"
PeaShooter.hitCinematic          = "cinematics/marine/hit.cinematic"

PeaShooter.bulletsToShoot        = 1
PeaShooter.damage				 = 4
PeaShooter.spread                = 0
PeaShooter.range                 = 50
PeaShooter.penetration           = 0
PeaShooter.fireDelay             = 0.1   -- Time between shots
PeaShooter.reloadTime            = 1     -- Time it takes to reload
PeaShooter.drawTime              = 1.3   -- Time it takes to draw the weapon
PeaShooter.clipSize              = 60    -- Number of bullets the clip holds
PeaShooter.animationPrefix       = "rifle"

Shared.PrecacheModel(PeaShooter.viewModelName)
Shared.PrecacheModel(PeaShooter.worldModelName)

Shared.PrecacheCinematic(PeaShooter.hitCinematic)
Shared.PrecacheCinematic(PeaShooter.muzzleFlashCinematic)
Shared.PrecacheCinematic(PeaShooter.shellCinematic)

Shared.PrecacheSound(PeaShooter.drawSound)
Shared.PrecacheSound(PeaShooter.reloadSound)
Shared.PrecacheSound(PeaShooter.fireSound)
Shared.PrecacheSound(PeaShooter.fireLoopSound)
Shared.PrecacheSound(PeaShooter.fireEndSound)

function PeaShooter:OnCreate()

    Weapon.OnCreate(self)

    self:SetModel(PeaShooter.worldModelName)

    self.overlayAnimationSequence   = -1
    self.overlayAnimationStart      = 0

    self.prevAnimationSequence      = -1
    self.prevAnimationStart         = 0
    self.blendLength                = 0.0

    self.numBulletsInReserve        = 1000
    self.numBulletsInClip           = self.clipSize

    self.firingState                = 0 -- Not firing

end

function PeaShooter:GetViewModelName()
    return PeaShooter.viewModelName
end

--
-- Returns then amount of time it takes to reload the weapon.
--/
function PeaShooter:GetReloadTime()
    return PeaShooter.reloadTime
end

--
-- Returns then amount of time it takes to draw (unholster) the weapon.
--/
function PeaShooter:GetDrawTime()
    return PeaShooter.drawTime
end

--
-- Returns the text that's prepended on the activity name to get the name of the
-- animation that the player should play.
--/
function PeaShooter:GetAnimationPrefix()
    return PeaShooter.animationPrefix
end

--
-- Unholsters the weapon.
--/
function PeaShooter:Draw(player)
    local viewModel = player:GetViewModelEntity()
    viewModel:SetAnimation( "draw" )
    player:PlaySound(self.drawSound)
end

function PeaShooter:StopPrimaryAttack(player)

    if (self.firingState > 0) then

        self:Idle(player)

        if (self.firingState > 1) then
            player:StopSound(self.fireLoopSound)
            player:PlaySound(self.fireEndSound)
        end

        self.firingState = 0

    end

end

function PeaShooter:Idle(player)

    local viewModel = player:GetViewModelEntity()

    viewModel:SetAnimationWithBlending( "idle", 0.25 )
    viewModel:SetOverlayAnimation( nil )

end

--
-- Fires the specified number of bullets in a cone from the player's current view.
--/
function PeaShooter:FireBullets(player)

    local viewModel = player:GetViewModelEntity()

    if (not self.firing) then
        viewModel:SetAnimationWithBlending( "attack_arms_loop", 0.01 )
        viewModel:SetOverlayAnimation( "attack_gun_loop" )
    end

    local viewCoords = player:GetCameraViewCoords()
    local startPoint = viewCoords.origin

    -- Filter ourself out of the trace so that we don't hit the weapon or the
    -- player using it.
    local filter = EntityFilterTwo(player, self)

    local spreadDirection = viewCoords.zAxis

    if (self.spread > 0) then

        local xSpread = ((NetworkRandom() * 2 * spread) - spread) + ((NetworkRandom() * 2 * spread) - spread)
        local ySpread = ((NetworkRandom() * 2 * spread) - spread) + ((NetworkRandom() * 2 * spread) - spread)

        spreadDirection = viewCoords.zAxis + viewCoords.xAxis * xSpread + viewCoords.yAxis * ySpread

    end

    local endPoint = startPoint + spreadDirection * self.range
    local trace = Shared.TraceRay(startPoint, endPoint, filter)

    if (trace.fraction < 1) then

        self:CreateHitEffect(player, trace)

        local target = trace.entity

        if (target ~= nil and target.TakeDamage ~= nil) then
            local direction = (trace.endPoint - startPoint):GetUnit()
            target:TakeDamage(player, PeaShooter.damage, self, trace.endPoint, direction)
        end

    end

 
    -- Create the muzzle flash effect.
    player:CreateWeaponEffect("RHand_Weapon", "fxnode_riflemuzzle", PeaShooter.muzzleFlashCinematic)

    -- Create the shell casing ejecting effect.
    player:CreateWeaponEffect("RHand_Weapon", "fxnode_riflecasing", PeaShooter.shellCinematic)

    -- Play the sound effect. One the first bullet we fire we play the single
    -- shot sound effect. After that we start the looping firing sound effect.
    -- This gives us a clear sound if fire a single shot, but allows better sound
    -- quality and variation if we hold the trigger.
    if (self.firingState == 0) then
        player:PlaySound(self.fireSound)
    elseif (self.firingState == 1) then
        player:PlaySound(self.fireLoopSound)
    end

    if (self.firingState < 2) then
        self.firingState = self.firingState + 1
    end

    return true

end

--
-- Returns true if the weapon successfully started a reload.
--/
function PeaShooter:Reload(player)
    return false
end

function PeaShooter:ReloadFinish(player)
        return true
end

--
-- Creates the hit effect from firing the weapon.
--/
function PeaShooter:CreateHitEffect(player, trace)

    -- Create a coordinate frame where "up" is the normal of the surface we hit.
    local coords = Coords.GetOrthonormal(trace.normal)
    coords.origin = trace.endPoint

    Shared.CreateEffect(player, PeaShooter.hitCinematic, nil, coords )

end

--
-- Returns the time between shots for the weapon.
--/
function PeaShooter:GetFireDelay()
    return self.fireDelay
end

--
-- Returns the total amount of ammo in the weapon's reserve ammo.
--/
function PeaShooter:GetAmmo()
    return self.numBulletsInReserve
end

--
-- Retursn the amount of ammo in the clip for the weapon.
--/
function PeaShooter:GetClip()
    return self.numBulletsInClip
end

function PeaShooter:GetSwingAmount()
    return 20
end

Shared.LinkClassToMap( "PeaShooter", "weapon_peashooter", PeaShooter.networkVars )
