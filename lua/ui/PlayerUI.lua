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
    return player:GetWeaponAmmo()--PlayerUI_GetEnergy()/(player.maxEnergy or 1)*120
    
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
    local s, t = "", Shared.GetTime()
    local i = 1
    while i <= #PlayerUI_Notifications do
        local notification = PlayerUI_Notifications[i]
        if #notification.text == 0 then
            table.remove(PlayerUI_Notifications, i)
            i = i-1
            if #PlayerUI_Notifications > 0 then
                PlayerUI_Notifications[1].startTime = Shared.GetTime()
            end
        else
            if notification.time < t then
                notification.text = notification.text:sub(2) -- cool little (untimed) fade away thing
            end
            s = s..notification.text.."    "
        end
        i = i+1
    end
    return s
end

PlayerUI_Notifications = {}

function PlayerUI_AddNotification(text, time)
    table.insert(PlayerUI_Notifications, {
        text = string.upper(tostring(text)),
        time = (time or 4)+Shared.GetTime()
    })
    DMsg("Adding notification \"",text,"\" for ",time or 4)
end

local qtrm = "^\"?(.-)\"?$"
function OnNotification(src, text, time)
	PlayerUI_AddNotification(text:match(qtrm):gsub("\3", '"'), tonumber(time))
end Event.Hook("Console_notify",  OnNotification)

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
