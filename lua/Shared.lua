--=============================================================================
--
-- RifleRange/Shared.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
--
--=============================================================================

Script.Load("lua/Globals.lua")

Script.Load("lua/Actor.lua")
Script.Load("lua/weapons/ViewModel.lua")
Script.Load("lua/Game.lua")
Script.Load("lua/weapons/Weapon.lua")
Script.Load("lua/weapons/Rifle.lua")
Script.Load("lua/weapons/Bite.lua")
Script.Load("lua/weapons/PeaShooter.lua")

PlayerClasses = {}
function GetPlayerClassMapNames()
	local t = {}
	for k,v in pairs(PlayerClasses) do
		table.insert(t, v.mapName)
	end
	return t
end
function GetAllPlayers()
    return Shared.FindEntities(GetPlayerClassMapNames())
end

Script.Load("lua/classes/Player.lua")
Script.Load("lua/entities/Target.lua")
Script.Load("lua/entities/Elevator.lua")
Script.Load("lua/entities/Turret.lua")
Script.Load("lua/PropDynamic.lua")
--Script.Load("lua/Effect.lua")
--Script.Load("lua/entities/AmbientSound.lua")

Script.Load("lua/classes/Skulk.lua")
Script.Load("lua/classes/Marine.lua")
Script.Load("lua/classes/BuildBot.lua")
Script.Load("lua/classes/Lerk.lua")

Script.Load("lua/entities/PlayerSpawn.lua")
Script.Load("lua/entities/TargetSpawn.lua")
Script.Load("lua/entities/ReadyRoomStart.lua")
Script.Load("lua/entities/ResourceNozzle.lua")
Script.Load("lua/entities/TechPoint.lua")
Script.Load("lua/entities/Door.lua")
Script.Load("lua/entities/TeamJoin.lua")

function Shared.FindEntities(classes, origin, radius, store_distance_and_sort) -- origin and radius can be left nil
	if type(classes) == "string" then classes = {classes} end
	local entities = {}
	for k, mapName in ipairs(classes) do
		local ent = Shared.FindEntityWithClassname(mapName, nil)
        while ent do
			if not (origin and radius) or (ent:GetOrigin()-origin):GetLength() < radius then
				table.insert(entities,
					store_distance_and_sort and {
						dist = (ent:GetOrigin()-origin):GetLength(),
						ent = ent
					}
					or ent
				)
			end
			ent = Shared.FindEntityWithClassname(mapName, ent)
        end
	end
	if store_distance_and_sort then
		table.sort(entities, function(a, b) return a.dist < b.dist end)
	end
	return entities
end

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
                else
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
                    else
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
function SMsg(...)
    if Server then
        Msg(...)
    end
end

if Client then
    function OnConsoleAddDebugElement(kind, ...)
        local a = {...}
        if kind == "line" then
            DebugLine(
                Vector(tonumber(a[1]) or 0, tonumber(a[2]) or 0, tonumber(a[3]) or 0),
                Vector(tonumber(a[4]) or 0, tonumber(a[5]) or 0, tonumber(a[6]) or 0),
                tonumber(a[7]) or 0,
                tonumber(a[8]) or 0, tonumber(a[9]) or 0, tonumber(a[10]) or 0, tonumber(a[11]) or 0
            )
        elseif kind == "point" then
            -- blah
        end
    end Event.Hook("Console_dbg_e", OnConsoleAddDebugElement)
    function AddDebugElement(ply, kind, ...)
        -- just declare it to prevent errors
    end
elseif Server then
    function AddDebugElement(plys, kind, ...) -- only accepts numbers, vectors and strings as args!
        -- plys can be a player, a table of players or nil (for all players)
        if Shared.enableDebugMessages then
            local s = "dbg_e "..kind
            for i, a in ipairs{...} do
                if type(a) == "userdata" then -- vector
                    s = s..' "'..a.x ..'" "'..a.y..'" "'..a.z..'"'
                elseif type(a) == "number" then
                    s = s..' "'..tostring(a)..'"'
                else
                    s = s..' "'..string.gsub(a, '"', "\3")..'"'
                end
            end
            plys = type(plys) == "userdata" and {plys} or plys or GetAllPlayers()
            for k,ply in ipairs(plys) do
                Server.ClientCommand(ply, s)
            end
        end
    end
end

function OnConsoleDebugMode()
	Shared.enableDebugMessages = not Shared.enableDebugMessages
    Shared.Message("<" .. GetContextString() .. "> Debug mode " .. (Shared.enableDebugMessages and "enabled." or "disabled."))
end

Event.Hook("Console_debug", OnConsoleDebugMode)
