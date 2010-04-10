class 'Bite' (Weapon)

Bite.networkVars =
    {
        firingState                 = "integer (0 to 2)",
    }

Bite.viewModelName         = "models/alien/skulk/skulk_view.model"
Bite.worldModelName        = "models/alien/skulk/skulk.model"
Bite.drawSound             = "sound/ns2.fev/marine/rifle/draw"
Bite.fireSound             = "sound/ns2.fev/marine/rifle/fire_single"
Bite.fireLoopSound         = "sound/ns2.fev/marine/rifle/fire_14_sec_loop"
Bite.fireEndSound          = "sound/ns2.fev/marine/rifle/fire_14_sec_end"
Bite.reloadSound           = "sound/ns2.fev/marine/rifle/reload"
Bite.muzzleFlashCinematic  = "cinematics/marine/rifle/muzzle_flash.cinematic"
Bite.shellCinematic        = "cinematics/marine/rifle/shell.cinematic"
Bite.hitCinematic          = "cinematics/marine/hit.cinematic"

Bite.range                 = 3
Bite.penetration           = 0
Bite.fireDelay             = 1   // Time between shots
Bite.reloadTime            = 3     // Time it takes to reload
Bite.drawTime              = 1.3   // Time it takes to draw the weapon
Bite.animationPrefix       = "rifle"

Shared.PrecacheModel(Bite.viewModelName)
Shared.PrecacheModel(Bite.worldModelName)

Shared.PrecacheCinematic(Bite.hitCinematic)
Shared.PrecacheCinematic(Bite.muzzleFlashCinematic)
Shared.PrecacheCinematic(Bite.shellCinematic)

Shared.PrecacheSound(Bite.drawSound)
Shared.PrecacheSound(Bite.reloadSound)
Shared.PrecacheSound(Bite.fireSound)
Shared.PrecacheSound(Bite.fireLoopSound)
Shared.PrecacheSound(Bite.fireEndSound)

function Bite:OnInit()

    Weapon.OnInit(self)

    self:SetModel(Bite.worldModelName)

    self.overlayAnimationSequence   = -1
    self.overlayAnimationStart      = 0

    self.prevAnimationSequence      = -1
    self.prevAnimationStart         = 0
    self.blendLength                = 0.0

    self.firingState                = 0 // Not firing

end

function Bite:GetViewModelName()
    return Bite.viewModelName
end

/**
 * Returns then amount of time it takes to reload the weapon.
 */
function Bite:GetReloadTime()
    return Bite.reloadTime
end

/**
 * Returns then amount of time it takes to draw (unholster) the weapon.
 */
function Bite:GetDrawTime()
    return Bite.drawTime
end

/**
 * Returns the text that's prepended on the activity name to get the name of the
 * animation that the player should play.
 */
function Bite:GetAnimationPrefix()
    return Bite.animationPrefix
end

/**
 * Unholsters the weapon.
 */
function Bite:Draw(player)
    local viewModel = player:GetViewModelEntity()
    //viewModel:SetAnimation( "draw" )
    player:PlaySound(self.drawSound)
end

function Bite:StopPrimaryAttack(player)

    if (self.firingState > 0) then

        self:Idle(player)

        self.firingState = 0

    end

end

function Bite:Idle(player)

    local viewModel = player:GetViewModelEntity()

    viewModel:SetAnimationWithBlending( "bite_idle", 0.25 )
    // There's more idle animations, not sure if we want to use them here though
    viewModel:SetOverlayAnimation( nil )

end

/**
 * Fires the specified number of bullets in a cone from the player's current view.
 */
function Bite:FireBullets(player)

    local viewModel = player:GetViewModelEntity()

    if (not self.firing) then
        local suffix = tostring( math.random( 4 ) ):gsub( "1", "" ) -- Nothing, 2, 3, or 4
        viewModel:SetAnimationWithBlending( "bite_attack" .. suffix, 0.01 )
        player:SetAnimation( "bite" )
        // viewModel:SetOverlayAnimation( "attack_gun_loop" )
    end

     local viewCoords = player:GetCameraViewCoords()
    local startPoint = viewCoords.origin

    // Filter ourself out of the trace so that we don't hit the weapon or the
    // player using it.
    local filter = EntityFilterTwo(player, self)



    local spreadDirection = viewCoords.zAxis

    local endPoint = startPoint + spreadDirection * self.range
    local trace = Shared.TraceRay(startPoint, endPoint, filter)

    if (trace.fraction < 1) then

        self:CreateHitEffect(player, trace)

        local target = trace.entity

        if (target ~= nil and target.TakeDamage ~= nil) then
            local direction = (trace.endPoint - startPoint):GetUnit()
            target:TakeDamage(player, 50, self, trace.endPoint, direction)
        end

    end

    // Create the muzzle flash effect.
    player:CreateWeaponEffect("RHand_Weapon", "fxnode_riflemuzzle", Bite.muzzleFlashCinematic)

    if (self.firingState < 2) then
        self.firingState = self.firingState + 1
    end

    return true

end

/**
 * Returns true if the weapon successfully started a reload.
 */
function Bite:Reload(player)
    return false
end

/**
 * Creates the hit effect from firing the weapon.
 */
function Bite:CreateHitEffect(player, trace)

    // Create a coordinate frame where "up" is the normal of the surface we hit.
    local coords = Coords.GetOrthonormal(trace.normal)
    coords.origin = trace.endPoint

    Shared.CreateEffect(player, Bite.hitCinematic, nil, coords )

end

/**
 * Returns the time between shots for the weapon.
 */
function Bite:GetFireDelay()
    return self.fireDelay
end

/**
 * Returns the total amount of ammo in the weapon's reserve ammo.
 */
function Bite:GetAmmo()
    return self.numBulletsInReserve
end

/**
 * Retursn the amount of ammo in the clip for the weapon.
 */
function Bite:GetClip()
    return self.numBulletsInClip
end

function Bite:GetSwingAmount()
    return 20
end

Shared.LinkClassToMap( "Bite", "weapon_bite", Bite.networkVars )
