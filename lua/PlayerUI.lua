//=============================================================================
//
// TestMod/PlayerUI.lua
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

function PlayerUI_GetAuxWeaponClip()
    return 0
end

/**
 * Called by Flash to get the number of bullets left in the reserve for 
 * the active weapon.
 */
function PlayerUI_GetWeaponClip()
    
local player = Client.GetLocalPlayer()
    return player:GetWeaponClip()

end

/**
 * Called by Flash to get the number of bullets in the active weapon.
 */
function PlayerUI_GetWeaponAmmo()
    
    local player = Client.GetLocalPlayer()
    return player:GetWeaponAmmo()
    
end

function PlayerUI_GetScore()

    local player = Client.GetLocalPlayer()
    return "K/D: " .. player.kills .. "/".. player.deaths .. "\rHP: " .. player.health
    
end

function PlayerUI_GetGameTime()
    return Game.instance:GetGameTime()
end

function PlayerUI_GetStatus()
	if Main.GetDevMode() then
		local player = Client.GetLocalPlayer()
		local origin = Vector(player:GetOrigin())
		local ground, groundnrml = player:GetIsOnGround()
		return "xyz " .. Round(origin.x,3) .. " " .. Round(origin.y,3) .. " " .. Round(origin.z,3) .. "\r" 
				.. "canmove " .. tostring(player:GetCanMove()) .. " onground " .. tostring(ground)
	else
		return ""
	end
end