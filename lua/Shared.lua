--=============================================================================
--
-- RifleRange/Shared.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
--
--=============================================================================

Script.Load("lua/Actor.lua")
Script.Load("lua/weapons/ViewModel.lua")
Script.Load("lua/Game.lua")
Script.Load("lua/Weapon.lua")
Script.Load("lua/Rifle.lua")
Script.Load("lua/Bite.lua")
Script.Load("lua/PeaShooter.lua")

PlayerClasses = {}

Script.Load("lua/Player.lua")
Script.Load("lua/Target.lua")
Script.Load("lua/Turret.lua")
Script.Load("lua/PropDynamic.lua")
--Script.Load("lua/Chat.lua")
--Script.Load("lua/Effect.lua")
--Script.Load("lua/AmbientSound.lua")

Script.Load("lua/classes/Skulk.lua")
Script.Load("lua/classes/Marine.lua")
Script.Load("lua/classes/BuildBot.lua")

function GetContextString()
	if (Server) then
		return "Server"
	elseif (Client) then
		return "Client"
	else
		return "Unknown"
	end
end

Shared.enableDebugMessages = false

function DebugMessage(message)
	if (Shared.enableDebugMessages) then
		Shared.Message("<" .. GetContextString() .. "> " .. message)
	end
end

function debug.getparams(f)
	local co = coroutine.create(f)
	local params = {}
	debug.sethook(co, function(event, line)
		local i, k, v = 1, debug.getlocal(co, 2, 1)
		while k do
			if k ~= "(*temporary)" then
				table.insert(params, k)
			end
			i = i+1
			k, v = debug.getlocal(co, 2, i)
		end
		error("~~end~~")
	end, "c")
	local res = {coroutine.resume(co)}
	if res[1] then
		error("The function provided defys the laws of the universe.", 2)
	elseif string.sub(tostring(res[2]), -7) ~= "~~end~~" then
		error("The function failed with the error: "..tostring(res[2]), 2)
	end
	return params
end

function Msg(...) -- example usage: Msg("The values are ", a, " and ", b, "!")
    local arg = arg or {...} -- use of auto-arg is deprecated, but we need arg.n
    local s = ""
    for i = 1, arg.n or #arg do
        local v = arg[i]
        if type(v) == "table" then
            s = s..tostring(v).."[# = "..#v.."]"
        elseif type(v) == "userdata" then
            if v.mapName then
                if v.mapName == "player" then
                    s = s.."<player: "..tostring(v.GetNick and v:GetNick() or "unamed")..">"
                    s = s.."<userdata: "..tostring(v.mapName)..">"
                end
            else
                s = s.."<userdata: unknown>"
            end
        elseif type(v) == "function" then
            local what = debug.getinfo(v, "S").what
            if what == "Lua" then
                s = s..tostring(v).."<Lua>("..table.concat(debug.getparams(v))..")"
            else
                s = s..tostring(v).."<"..what..">(?)"
            end
        else -- string, number, boolean, nil
            s = s..tostring(v)
        end
    end
    Shared.Message("<" .. GetContextString() .. "> " .. s)
end

function DMsg(...) -- example usage: Msg("The values are ", a, " and ", b, "!")
	if (Shared.enableDebugMessages) then
        local arg = arg or {...} -- use of auto-arg is deprecated, but we need arg.n
        local s = ""
        for i = 1, arg.n or #arg do
            local v = arg[i]
            if type(v) == "table" then
                s = s..tostring(v).."[# = "..#v.."]"
            elseif type(v) == "userdata" then
                if v.mapName then
                    if v.mapName == "player" then
                        s = s.."<player: "..tostring(v.GetNick and v:GetNick() or "unamed")..">"
                        s = s.."<userdata: "..tostring(v.mapName)..">"
                    end
                else
                    s = s.."<userdata: unknown>"
                end
            elseif type(v) == "function" then
                local what = debug.getinfo(v, "S").what
                if what == "Lua" then
                    s = s..tostring(v).."<Lua>("..table.concat(debug.getparams(v))..")"
                else
                    s = s..tostring(v).."<"..what..">(?)"
                end
            else -- string, number, boolean, nil
                s = s..tostring(v)
            end
        end
        Shared.Message("<" .. GetContextString() .. "> " .. s)
    end
    return true -- so_we_can_use_it and DMsg('LOL') and "like this." or "no?"
end

function OnConsoleDebugMode()
	Shared.enableDebugMessages = not Shared.enableDebugMessages
    Shared.Message("<" .. GetContextString() .. "> Debug mode " .. (Shared.enableDebugMessages and "enabled." or "disabled."))
end

Event.Hook("Console_debug", OnConsoleDebugMode)