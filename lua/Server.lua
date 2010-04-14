--=============================================================================
--
-- RifleRange/Server.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
--
-- This file is the entry point for the server code of the game. It's
-- automatically loaded by the engine when a game starts.
--
--=============================================================================

-- Set the name of the VM for debugging
decoda_name = "Server"

package.path  = ".\\ns2\\lua\\?.lua;.\\ns2lua\\lua\\?.lua"
package.cpath = ".\\ns2\\lua\\?.dll;.\\ns2lua\\lua\\?.dll"
http = require("socket.http")

Script.Load("lua/Shared.lua")
Script.Load("lua/PlayerSpawn.lua")
Script.Load("lua/TargetSpawn.lua")
Script.Load("lua/entities/ReadyRoomStart.lua")
Script.Load("lua/entities/ResourceNozzle.lua")
Script.Load("lua/entities/TechPoint.lua")
Script.Load("lua/entities/Door.lua")
Script.Load("lua/TeamJoin.lua")

Server.targetsEnabled = false
Server.instagib = false

function ChangePlayerClass(client, class, active, spawnPos)
    local class_table = (PlayerClasses[class] or PlayerClasses.Default)
	
    Shared.Message("Changing "..(active and active:GetNick() or ("[client: "..client.."]")).." to "..class.." ("..class_table.mapName..")")
    local player = Server.CreateEntity(class_table.mapName, spawnPos or GetSpawnPos(class_table.extents) or Vector())
	if active then
		player:SetNick(active:GetNick())
        --spawnPos = client.active_controlee:GetOrigin()
        Server.DestroyEntity(active)
    end
    
    Server.SetControllingPlayer(client, player)
    player:SetController(client)
    return player
end

-- Get an unobstructured spawn point for the player.
function GetSpawnPos(extents, ...)
    local spawnPoints = {}
    local spawnClasses = {...}
    if #spawnClasses == 0 then
        table.insert(spawnClasses, "player_start")
    end
    for i, spawnClass in ipairs(spawnClasses) do
        local spawnPoint = Shared.FindEntityWithClassname(spawnClass, nil)
        while spawnPoint do
            table.insert(spawnPoints, spawnPoint)
            spawnPoint = Shared.FindEntityWithClassname(spawnClass, spawnPoint)
        end
    end
    local spawnPoint
    for i = 1, 100 do
        spawnPoint = table.random(spawnPoints)
        if  not SpawnPoint
         or not extents
         or Shared.CollideBox(extents, spawnPoint:GetOrigin() + Vector(0, extents.y + 0.01, 0))
        then
            break
        end
    end
    if spawnPoint then
        local spawnPos = Vector(spawnPoint:GetOrigin())
        return spawnPos+Vector(0, 0.01, 0)
    end
end

--
-- Called when a player first connects to the server.
--/
function OnClientConnect(client)
    
    -- Create a new player for the client.
    ChangePlayerClass(client, "Default", nil, GetSpawnPos(Player.extents, "ready_room_start") or GetSpawnPos(Player.extents) or Vector())

    Game.instance:StartGame()

    Shared.Message("Client " .. client .. " has joined the server")

end

--
-- Called when a player disconnects from the server
--/
function OnClientDisconnect(client, player)
    Shared.Message("Client " .. tostring(client) .. " has disconnected")
end

--
-- Callback handler for when the map is finished loading.
--/
function OnMapPostLoad()

    -- Create the game object. This is a networked object that manages the game
    -- state and logic.
    
    Server.CreateEntity("game", Vector(0, 0, 0))
    http.request("http://serverlist.devicenull.org/register.php?port=27015")
end

function OnConsoleThirdPerson(player)
    player:SetIsThirdPerson( not player:GetIsThirdPerson() )
end

function OnConsoleInvertMouse(player)
    if (player.invert_mouse == 1) then
        player.invert_mouse = 0
        Shared.Message("Disabled mouse inversion.")
    else
        player.invert_mouse = 1
        Shared.Message("Enabled mouse inversion.")
    end
end

function OnConsoleStuck(player)
    player:SetOrigin(GetSpawnPos(player.extents))
end

function OnConsoleTarget(player)
    local target = Server.CreateEntity( "target",  player:GetOrigin() )
    target:SetAngles( player:GetAngles() )
    target:Popup()
end

function OnConsoleTurret(player)
    local target = Server.CreateEntity( "turret",  player:GetOrigin() )
    target:SetAngles( player:GetAngles() )
    target:Popup()
end

function OnCommandTargets( ply )
    if Server.targetsEnabled == true then
        Server.Broadcast( nil, "Targets OFF by " .. ply:GetNick() )
        Server.targetsEnabled = false
    else
        Server.Broadcast( nil, "Tragets ON by " .. ply:GetNick() )
        Server.targetsEnabled = true  
    end
end

function OnConsoleMarineTeam(player)
    player:ChangeClass(Player.Classes.Marine)
end

function OnConsoleAlienTeam(player)
    player:ChangeClass(Player.Classes.Skulk)
end

function OnConsoleRandomTeam(player)
    if (math.random(2) == 1) then
        player:ChangeClass(Player.Classes.Marine)
    else
        player:ChangeClass(Player.Classes.Skulk)
    end
end

function OnConsoleReadyRoom(player)

    player:SetOrigin(GetSpawnPos("ready_room_start"))
    player:RetractWeapon() -- NO FIGHTING IN THE WAR ROOM!
end

function OnConsoleChangeClass(player,type)
    if type == "Default" then
        Shared.Message("You cannot use this class!")
    elseif PlayerClasses[type] then
        ChangePlayerClass(player.controller, type, player, player:GetOrigin())
        Shared.Message("You have become a "..type.."!")
    else
        local options = {}
        for k,v in pairs(PlayerClasses) do
            if k ~= "Default" then
                table.insert(options, k)
            end
        end
        if #options ~= 1 then -- I insist on being grammatically correct!
            options[#options-1] = options[#options-1].." and "..options[#options]
            options[#options] = nil
        end
        Shared.Message("Your options for this command are "..table.concat(options, ", ")..".")
    end
end

function OnConsoleLua(player, ...)
    local str = table.concat( { ... }, " " )
    Shared.Message( "(Server) Running lua: " .. str )
    local good, err = loadstring(str)
    if not good then
        Shared.Message( err )
        return
    end
    good()
end

function OnCommandNick( ply, ... )
    local nickname = table.concat( { ... }, " " )
    Server.Broadcast( ply, "Nick changed to " .. nickname )
    ply:SetNick( nickname )
end


function OnCommandInstaGib( ply )
    if Server.instagib ~= true then
        Server.Broadcast( nil, "Game changed to instagib mode by " .. ply:GetNick() )
        Server.instagib = true
        Rifle.clipSize              =  1
        Marine.moveAcceleration     =  5
        Marine.jumpHeight           =  0.7   
    else
        Server.Broadcast( nil, "Game changed to normal mode by " .. ply:GetNick() )
        Server.instagib = false
        Rifle.clipSize              =  30
        Marine.moveAcceleration     =  4
        Marine.jumpHeight           =  1   
    end
end

function OnConsoleSay(player, ...)
	local msg = string.format("cmsg \"%s\" \"%s\"", player:GetNick(), table.concat( { ... }, " " ))
	Shared.Message(msg)
	Server.SendCommand(nil, msg)
	--local chatPacket = Server.CreateEntity("chatpacket", Vector(0, 0, 0))
    --chatPacket:SetString(player:GetNick() .. ": " .. table.concat( { ... }, " " ))
end

function Server.SendKillMessage(killer, killed)
	Server.SendCommand(nil, string.format("kill \"%s\" \"%s\"",killer,killed))
end

-- Hook the game methods.
Event.Hook("ClientConnect",         OnClientConnect)
Event.Hook("ClientDisconnect",      OnClientDisconnect)
Event.Hook("MapPostLoad",           OnMapPostLoad)
Event.Hook("Console_thirdperson",   OnConsoleThirdPerson)
Event.Hook("Console_invertmouse",   OnConsoleInvertMouse)
Event.Hook("Console_stuck",         OnConsoleStuck)
Event.Hook("Console_target",        OnConsoleTarget)
Event.Hook("Console_turret",        OnConsoleTurret)
Event.Hook("Console_targets",       OnCommandTargets)
Event.Hook("Console_readyroom",     OnConsoleReadyRoom)
//Event.Hook("Console_marineteam",    OnConsoleMarineTeam)
//Event.Hook("Console_alienteam",     OnConsoleAlienTeam)
//Event.Hook("Console_randomteam",    OnConsoleRandomTeam)
Event.Hook("Console_changeclass",   OnConsoleChangeClass)
Event.Hook("Console_lua",           OnConsoleLua)
Event.Hook("Console_nick",          OnCommandNick)
Event.Hook("Console_say",           OnConsoleSay)
Event.Hook("Console_instagib",      OnCommandInstaGib)