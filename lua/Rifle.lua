//=============================================================================
//
// RifleRange/Rifle.lua
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

class 'Rifle' (Weapon)

Rifle.networkVars =
    {
        firingState                 = "integer (0 to 2)",
        numBulletsInReserve         = "integer (0 to 1000)",
        numBulletsInClip            = "integer (0 to 30)",
    }

Rifle.viewModelName         = "models/marine/rifle/rifle_view.model"
Rifle.worldModelName        = "models/marine/rifle/rifle.model"
Rifle.drawSound             = "sound/ns2.fev/marine/rifle/draw"
Rifle.fireSound             = "sound/ns2.fev/marine/rifle/fire_single"
Rifle.fireLoopSound         = "sound/ns2.fev/marine/rifle/fire_14_sec_loop"
Rifle.fireEndSound          = "sound/ns2.fev/marine/rifle/fire_14_sec_end"
Rifle.reloadSound           = "sound/ns2.fev/marine/rifle/reload"
Rifle.muzzleFlashCinematic  = "cinematics/marine/rifle/muzzle_flash.cinematic"
Rifle.shellCinematic        = "cinematics/marine/rifle/shell.cinematic"
Rifle.hitCinematic          = "cinematics/marine/hit.cinematic"

Rifle.bulletsToShoot        = 1
Rifle.spread                = 0.03
Rifle.range                 = 50
Rifle.meleeRange            = 3     // Range of melee attack
Rifle.penetration           = 0
Rifle.fireDelay             = 0.1   // Time between shots
Rifle.meleeDelay            = 0.6   // Time between melee
Rifle.reloadTime            = 3     // Time it takes to reload
Rifle.drawTime              = 1.3   // Time it takes to draw the weapon
Rifle.clipSize              = 30    // Number of bullets the clip holds
Rifle.animationPrefix       = "rifle"

Shared.PrecacheModel(Rifle.viewModelName)
Shared.PrecacheModel(Rifle.worldModelName)

Shared.PrecacheCinematic(Rifle.hitCinematic)
Shared.PrecacheCinematic(Rifle.muzzleFlashCinematic)
Shared.PrecacheCinematic(Rifle.shellCinematic)

Shared.PrecacheSound(Rifle.drawSound)
Shared.PrecacheSound(Rifle.reloadSound)
Shared.PrecacheSound(Rifle.fireSound)
Shared.PrecacheSound(Rifle.fireLoopSound)
Shared.PrecacheSound(Rifle.fireEndSound)

function Rifle:OnInit()

    Weapon.OnInit(self)

    self:SetModel(Rifle.worldModelName)

    self.overlayAnimationSequence   = -1
    self.overlayAnimationStart      = 0

    self.prevAnimationSequence      = -1
    self.prevAnimationStart         = 0
    self.blendLength                = 0.0

    self.numBulletsInReserve        = 1000
    self.numBulletsInClip           = self.clipSize

    self.firingState                = 0 // Not firing

end

function Rifle:GetViewModelName()
    return Rifle.viewModelName
end

/**
 * Returns then amount of time it takes to reload the weapon.
 */
function Rifle:GetReloadTime()
    return Rifle.reloadTime
end

/**
 * Returns then amount of time it takes to draw (unholster) the weapon.
 */
function Rifle:GetDrawTime()
    return Rifle.drawTime
end

/**
 * Returns the text that's prepended on the activity name to get the name of the
 * animation that the player should play.
 */
function Rifle:GetAnimationPrefix()
    return Rifle.animationPrefix
end

/**
 * Unholsters the weapon.
 */
function Rifle:Draw(player)
    local viewModel = player:GetViewModelEntity()
    viewModel:SetAnimation( "draw" )
    player:PlaySound(self.drawSound)
end

function Rifle:StopPrimaryAttack(player)

    if (self.firingState > 0) then

        self:Idle(player)

        if (self.firingState > 1) then
            player:StopSound(self.fireLoopSound)
            player:PlaySound(self.fireEndSound)
        end

        self.firingState = 0

    end

end

function Rifle:StopSecondaryAttack(player)

    if (self.firingState > 0) then

        self:Idle(player)

        self.firingState = 0

    end

end

function Rifle:Idle(player)

    local viewModel = player:GetViewModelEntity()

    viewModel:SetAnimationWithBlending( "idle", 0.25 )
    viewModel:SetOverlayAnimation( nil )

end

/**
 * Melee's from the player's current view.
 */
function Rifle:Melee(player)

    local viewModel = player:GetViewModelEntity()

    if (not self.firing) then
        local suffix = tostring( math.random( 6 ) ):gsub( "1", "" ) -- Nothing, 2, 3, 4, 5, or 6
        viewModel:SetAnimationWithBlending( "attack_secondary" .. suffix, 0.01 )
        player:SetOverlayAnimation("rifle_alt``")
    end

     local viewCoords = player:GetCameraViewCoords()
     local startPoint = viewCoords.origin

    // Filter ourself out of the trace so that we don't hit the weapon or the
    // player using it.
    local filter = EntityFilterTwo(player, self)

    local spreadDirection = viewCoords.zAxis

    local endPoint = startPoint + spreadDirection * self.meleeRange
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
 * Fires the specified number of bullets in a cone from the player's current view.
 */
function Rifle:FireBullets(player)

    local bulletsToShoot = math.min(self.bulletsToShoot, self.numBulletsInClip)

    if (bulletsToShoot == 0) then
        return false
    end

    local viewModel = player:GetViewModelEntity()

    if (not self.firing) then
        viewModel:SetAnimationWithBlending( "attack_arms_loop", 0.01 )
        viewModel:SetOverlayAnimation( "attack_gun_loop" )
    end

    self.numBulletsInClip = self.numBulletsInClip - bulletsToShoot

    local viewCoords = player:GetCameraViewCoords()
    local startPoint = viewCoords.origin

    // Filter ourself out of the trace so that we don't hit the weapon or the
    // player using it.
    local filter = EntityFilterTwo(player, self)

    for bullet = 1, self.bulletsToShoot do

        local spreadDirection = viewCoords.zAxis

        if (self.spread > 0) then

            local xSpread = ((NetworkRandom() * 2 * self.spread) - self.spread) + ((NetworkRandom() * 2 * self.spread) - self.spread)
            local ySpread = ((NetworkRandom() * 2 * self.spread) - self.spread) + ((NetworkRandom() * 2 * self.spread) - self.spread)

            spreadDirection = viewCoords.zAxis + viewCoords.xAxis * xSpread + viewCoords.yAxis * ySpread

        end

        local endPoint = startPoint + spreadDirection * self.range
        local trace = Shared.TraceRay(startPoint, endPoint, filter)

        if (trace.fraction < 1) then

            self:CreateHitEffect(player, trace)

            local target = trace.entity

            if (target ~= nil and target.TakeDamage ~= nil) then
                local direction = (trace.endPoint - startPoint):GetUnit()
                target:TakeDamage(player, 8, self, trace.endPoint, direction)
            end

        end

    end

    // Create the muzzle flash effect.
    player:CreateWeaponEffect("RHand_Weapon", "fxnode_riflemuzzle", Rifle.muzzleFlashCinematic)

    // Create the shell casing ejecting effect.
    player:CreateWeaponEffect("RHand_Weapon", "fxnode_riflecasing", Rifle.shellCinematic)

    // Play the sound effect. One the first bullet we fire we play the single
    // shot sound effect. After that we start the looping firing sound effect.
    // This gives us a clear sound if fire a single shot, but allows better sound
    // quality and variation if we hold the trigger.
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

/**
 * Returns true if the weapon successfully started a reload.
 */
function Rifle:Reload(player)

    if (self.numBulletsInReserve > 0 and self.numBulletsInClip ~= self.clipSize) then

        local viewModel = player:GetViewModelEntity()

        viewModel:SetAnimation( "reload" )
        player:PlaySound( self.reloadSound )

        return true

    end

    return false

end

function Rifle:ReloadFinish(player)

    if (self.numBulletsInReserve > 0 and self.numBulletsInClip ~= self.clipSize) then
        self.numBulletsInClip = math.min(self.numBulletsInReserve, self.clipSize)
        self.numBulletsInReserve = self.numBulletsInReserve - self.numBulletsInClip

        return true

    end

    return false

end

/**
 * Creates the hit effect from firing the weapon.
 */
function Rifle:CreateHitEffect(player, trace)

    // Create a coordinate frame where "up" is the normal of the surface we hit.
    local coords = Coords.GetOrthonormal(trace.normal)
    coords.origin = trace.endPoint

    Shared.CreateEffect(player, Rifle.hitCinematic, nil, coords )

end

/**
 * Returns the time between shots for the weapon.
 */
function Rifle:GetFireDelay()
    return self.fireDelay
end

/**
 * Returns the time between melee for the weapon.
 */
function Rifle:GetMeleeDelay()
    return self.meleeDelay
end

/**
 * Returns the total amount of ammo in the weapon's reserve ammo.
 */
function Rifle:GetAmmo()
    return self.numBulletsInReserve
end

/**
 * Retursn the amount of ammo in the clip for the weapon.
 */
function Rifle:GetClip()
    return self.numBulletsInClip
end

function Rifle:GetSwingAmount()
    return 20
end

Shared.LinkClassToMap( "Rifle", "weapon_rifle", Rifle.networkVars )
