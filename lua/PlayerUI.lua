--=============================================================================
--
-- TestMod/PlayerUI.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
--
--=============================================================================

function PlayerUI_GetAuxWeaponClip()
    return 0
end

--
-- Called by Flash to get the number of bullets left in the reserve for 
-- the active weapon.
--/
function PlayerUI_GetWeaponClip()
    
local player = Client.GetLocalPlayer()
    return player:GetWeaponClip()

end

--
-- Called by Flash to get the number of bullets in the active weapon.
--/
function PlayerUI_GetWeaponAmmo()
    
    local player = Client.GetLocalPlayer()
    return PlayerUI_GetEnergy()/(player.maxEnergy or 1)*120--player:GetWeaponAmmo()
    
end

function PlayerUI_GetScore()

    local player = Client.GetLocalPlayer()
	if (player) then
		return "K/D: " .. player.kills .. "/".. player.deaths
	else
		return "local player is nil"
	end
    
end

function PlayerUI_GetGameTime()
    return Game.instance:GetGameTime()
end

function PlayerUI_GetStatus()
    if Main.GetDevMode() then
        local player = Client.GetLocalPlayer()
        local origin = Vector(player:GetOrigin())
        local view = Angles(player:GetViewAngles())
        local ground, groundnrml = player:GetIsOnGround()
        local vel = player:GetVelocity()
        return "xyz " .. Round(origin.x,3) .. " " .. Round(origin.y,3) .. " " .. Round(origin.z,3) .. "\r"
                .. "vel " .. Round(vel.x,3) .. " " .. Round(vel.y,3) .. " " .. Round(vel.z,3) .. "\r"
                .. "pyr " .. Round(view.pitch,3) .. " " .. Round(view.yaw,3) .. " " .. Round(view.roll,3) .. "\r" 
                .. "canmove " .. tostring(player:GetCanMove()) .. " onground " .. tostring(ground)
    else
        return ""
    end
end

-- 23 BEGIN
displystring = ""
stringID = 0

function PlayerUI_GetHealth()
    local player = Client.GetLocalPlayer()
	if (player) then
		return player.health
	else
		return 0
	end
end

function PlayerUI_GetEnergy()
    local player = Client.GetLocalPlayer()
	if (player) then
		return player.energy or 0 -- 0 to 100
	else
		return 0
	end
end

function PlayerUI_GetStringID()
    return stringID
end

function PlayerUI_SetDisplayString( eingabe )
    stringID = stringID + 1
    displystring = eingabe
end

function PlayerUI_GetDisplayString()
    return displystring
end
-- 23 END