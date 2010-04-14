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

package.path  = ".\\ns2\\lua\\?.lua"
package.cpath = ".\\ns2\\lua\\?.dll"
http = require("socket.http")

Script.Load("lua/Shared.lua")
Script.Load("lua/PlayerSpawn.lua")
Script.Load("lua/TargetSpawn.lua")
Script.Load("lua/ReadyRoomStart.lua")
Script.Load("lua/TeamJoin.lua")

Server.targetsEnabled = false
Server.instagib = false

--
-- Called when a player first connects to the server.
--/
function OnClientConnect(client)

    -- Get an unobstructured spawn point for the player.

    local extents = Player.extents
    local offset  = Vector(0, extents.y + 0.01, 0)

    repeat
        spawnPoint = Shared.FindEntityWithClassname("ready_room_start", spawnPoint)
    until spawnPoint == nil or not Shared.CollideBox(extents, spawnPoint:GetOrigin() + offset)

    -- If there is not a ready room.
    if (spawnPoint == nil) then
        repeat
            spawnPoint = Shared.FindEntityWithClassname("player_start", spawnPoint)
        until spawnPoint == nil or not Shared.CollideBox(extents, spawnPoint:GetOrigin() + offset)
    end

    local spawnPos = Vector(0, 0, 0)

    if (spawnPoint ~= nil) then
        spawnPos = Vector(spawnPoint:GetOrigin())
        -- Move the spawn position up a little bit so the player won't start
        -- embedded in the ground if the spawn point is positioned on the floor
        spawnPos.y = spawnPos.y + 0.01
    end

    -- Create a new player for the client.
    local player = Server.CreateEntity("player", spawnPos)
    Server.SetControllingPlayer(client, player)

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
    local extents = Player.extents
    local offset  = Vector(0, extents.y + 0.01, 0)

    repeat
        spawnPoint = Shared.FindEntityWithClassname("player_start", spawnPoint)
    until spawnPoint == nil or not Shared.CollideBox(extents, spawnPoint:GetOrigin() + offset)

    local spawnPos = Vector(0, 0, 0)

    if (spawnPoint ~= nil) then
        spawnPos = Vector(spawnPoint:GetOrigin())
        -- Move the spawn position up a little bit so the player won't start
        -- embedded in the ground if the spawn point is positioned on the floor
        spawnPos.y = spawnPos.y + 0.01
    end

    player:SetOrigin(spawnPos)
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
    local extents = Player.extents
    local offset  = Vector(0, extents.y + 0.01, 0)

    repeat
        spawnPoint = Shared.FindEntityWithClassname("ready_room_start", spawnPoint)
    until spawnPoint == nil or not Shared.CollideBox(extents, spawnPoint:GetOrigin() + offset)

    local spawnPos = Vector(0, 0, 0)
    if (spawnPoint ~= nil) then
        spawnPos = Vector(spawnPoint:GetOrigin())
        -- Move the spawn position up a little bit so the player won't start
        -- embedded in the ground if the spawn point is positioned on the floor
        spawnPos.y = spawnPos.y + 0.01
    end

    player:SetOrigin(spawnPos)
    player:RetractWeapon() -- NO FIGHTING IN THE WAR ROOM!
end

function OnConsoleChangeClass(player,type)
    if (type == "buildbot") then
        player:ChangeClass(Player.Classes.BuildBot)
        Shared.Message("You have become a BuildBot!")
    elseif (type == "skulk") then
        player:ChangeClass(Player.Classes.Skulk)
        Shared.Message("You have become a Skulk!")
    elseif (type == "marine") then
        player:ChangeClass(Player.Classes.Marine)
        Shared.Message("You have become a Marine!")
    else
        Shared.Message("Your options for this command are buildbot, skulk, and marine")
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

function OnConsoleSay(player, ...)
	local chatPacket = Server.CreateEntity("chatpacket", Vector(0, 0, 0))
    chatPacket:SetString(player:GetNick() .. ": " .. table.concat( { ... }, " " ))
end

function OnCommandInstaGib( ply )
    if Server.instagib ~= true then
        Server.Broadcast( nil, "Game changed to instagib mode by " .. ply:GetNick() )
        Server.instagib = true
        Rifle.clipSize              =  1
        Player.moveAcceleration     =  5
        Player.jumpHeight           =  0.7   
    else
        Server.Broadcast( nil, "Game changed to normal mode by " .. ply:GetNick() )
        Server.instagib = false
        Rifle.clipSize              =  30
        Player.moveAcceleration     =  4
        Player.jumpHeight           =  1   
    end
end

function Server.SendKillMessage(killer, killed) 
	Shared.Message("--Server--")	
	Shared.Message("Killer: " .. killer)
	Shared.Message("Killed: " .. killed)
	Server.SendCommand(nil, string.format("kill %s %s",killer,killed))
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
Event.Hook("Console_marineteam",    OnConsoleMarineTeam)
Event.Hook("Console_alienteam",     OnConsoleAlienTeam)
Event.Hook("Console_randomteam",    OnConsoleRandomTeam)
Event.Hook("Console_changeclass",   OnConsoleChangeClass)
Event.Hook("Console_lua",           OnConsoleLua)
Event.Hook("Console_nick",          OnCommandNick)
Event.Hook("Console_say",           OnConsoleSay)
Event.Hook("Console_instagib",      OnCommandInstaGib)