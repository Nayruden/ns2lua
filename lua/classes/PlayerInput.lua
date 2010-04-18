Player.Keys = { -- "n" postfix means they are networked and predicted
    Exit                = "press",
    ToggleFlashlight    = "pressn",
    Buy                 = "press",
    Taunt               = "press",
    ToggleSayings1      = "press",
    ToggleSayings2      = "press",
    Drop                = "press",
    Weapon1             = "press",
    Weapon2             = "press",
    Weapon3             = "press",
    Weapon4             = "press",
    Weapon5             = "press",
    Use                 = "hold",
    Scoreboard          = "holdn",
    NextWeapon          = "hold",
    PrevWeapon          = "hold",
    Jump                = "holdn",
    Crouch              = "holdn",
    MovementModifier    = "holdn",
    Reload              = "holdn",
    PrimaryAttack       = "holdn",
    SecondaryAttack     = "holdn",
    ScrollLeft          = "holdn",
    ScrollRight         = "holdn",
    ScrollForward       = "holdn",
    ScrollBackward      = "holdn",
    Minimap             = "holdn",
}
for k,v in pairs(Player.Keys) do
    if v == "holdn" or v == "pressn" then
        Player.networkVars["key_"..k] = "predicted boolean"
    end
end
function Player:ProcessMoveKeys(input,angles,forwardAxis,sideAxis)
    for key, keyType in pairs(self.Keys) do
        local bval = Move[key]
        if keyType == "hold" or keyType == "holdn" then
            local canHold = self["CanHold"..key] -- safe to use this as an "OnHold" hook
            if bit.band(input.commands, bval) ~= 0 and (not canHold or canHold(self, input, angles, forwardAxis, sideAxis)) then
                --Msg(self["key_"..key],":CanHold"..key)
                local canPress = self["CanPress"..key]
                if not self["key_"..key] and (not canPress or canPress(self, input, angles, forwardAxis, sideAxis)) then
                    --Msg(self["key_"..key],":CanPress"..key)
                    self["key_"..key] = true
                    local func = self["OnPress"..key]
                    --Msg(self["key_"..key],":OnPress"..key)
                    if func then
                        func(self, input, angles, forwardAxis, sideAxis)
                    end
                end
            elseif self["key_"..key] then
                self["key_"..key] = false
                local func = self["OnRelease"..key]
                --Msg(self["key_"..key],":OnRelease"..key)
                if func then
                    func(self, input, angles, forwardAxis, sideAxis)
                end
            else
                local notHeld = self["OnNotHeld"..key]
                if notHeld then -- I only added this for a primary/secondary attack bug, be cautious
                    notHeld(self, input, angles, forwardAxis, sideAxis)
                end
            end
        elseif keyType == "press" or keyType == "pressn" then
            if self["key_"..key] and bit.band(input.commands, bval) == 0 then
                self["key_"..key] = false
                local func = self["OnRelease"..key]
                --Msg("OnRelease"..key)
                if func then
                    func(self, input, angles, forwardAxis, sideAxis)
                end
            elseif not self["key_"..key] and bit.band(input.commands, bval) ~= 0 then
                local canPress = self["CanPress"..key]
                if not self["key_"..key] and (not canPress or canPress(self, input, angles, forwardAxis, sideAxis)) then
                    --Msg("CanPress"..key)
                    self["key_"..key] = true
                    local func = self["OnPress"..key]
                    --Msg("OnPress"..key)
                    if func then
                        func(self, input, angles, forwardAxis, sideAxis)
                    end
                end
            end
        end
	end
end

function Player:OnLand(input, forwardAxis, sideAxis)
    
end

function Player:OnPressExit(input)
    if Client then
        ShowInGameMenu()
    end
end
function Player:OnPressTaunt(input)
    local sound = table.random(self.TauntSounds)
    if sound then
        self:PlaySound(sound)
    end
end
function Player:CanPressJump(input)
    return self.ground
end
function Player:OnPressJump(input)
    self.velocity.y = math.sqrt(-2 * self.jumpHeight * self.gravity)
    self.ground = false
end
function Player:OnPressCrouch(input)
    --self:SetAnimation( "" ) -- Needs a crouch animation (pose param manually tweened for now)
    self.crouching = true
    self.crouchStartTime = Shared.GetTime()-self.crouchAnimationTime*self.crouchFade
end
function Player:OnReleaseCrouch(input)
    self.crouching = false
    self.crouchStartTime = Shared.GetTime()-self.crouchAnimationTime*(1-self.crouchFade)
end
function Player:OnPressMovementModifier(input)
    self.sprinting = true
    self.sprintStartTime = Shared.GetTime()-self.sprintAnimationTime*self.sprintFade
end
function Player:OnReleaseMovementModifier(input)
    self.sprinting = false
    self.sprintStartTime = Shared.GetTime()-self.sprintAnimationTime*(1-self.sprintFade)
end
function Player:OnPressReload(input)
    if self.activity == Player.Activity.Shooting then
        self:StopPrimaryAttack()
    end
    if self.activity == Player.Activity.AltShooting then
        self:StopSecondaryAttack()
    end
    self:Reload()
end
function Player:CanPressPrimaryAttack(input)
    return self.activity ~= Player.Activity.Reloading
end
function Player:OnPressPrimaryAttack(input)
    self:PrimaryAttack()
end
function Player:CanHoldPrimaryAttack(input)
    if self.activity == Player.Activity.Reloading then
        return false
    end
    self:PrimaryAttack()
    return true
end
function Player:OnReleasePrimaryAttack(input)
    self:StopPrimaryAttack()
end
function Player:OnNotHeldPrimaryAttack(input)
    if self.activity == Player.Activity.Shooting then
        self:StopPrimaryAttack()
    end
end
function Player:CanPressSecondaryAttack(input)
    return self.activity ~= Player.Activity.Reloading
end
function Player:OnPressSecondaryAttack(input)
    self:SecondaryAttack()
end
function Player:CanHoldSecondaryAttack(input)
    if self.activity ~= Player.Activity.Reloading then
        return false
    end
    self:SecondaryAttack()
    return true
end
function Player:OnReleaseSecondaryAttack(input)
    self:StopSecondaryAttack()
end
function Player:OnNotHeldSecondaryAttack(input)
    if self.activity == Player.Activity.AltShooting then
        self:StopSecondaryAttack()
    end
end
function Player:OnPressDrop(input)
    self.noclip = not self.noclip
end

