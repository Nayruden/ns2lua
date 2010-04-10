//=============================================================================
//
// RifleRange/Server.lua
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
//
// This file is the entry point for the server code of the game. It's
// automatically loaded by the engine when a game starts.
//
//=============================================================================

// Set the name of the VM for debugging
decoda_name = "Server"

Script.Load("lua/Shared.lua")
Script.Load("lua/PlayerSpawn.lua")
Script.Load("lua/TargetSpawn.lua")

/**
 * Called when a player first connects to the server.
 */
function OnClientConnect(client)

    // Get an unobstructured spawn point for the player.
    
    local extents = Player.extents
    local offset  = Vector(0, extents.y + 0.01, 0)
    
    repeat
        spawnPoint = Shared.FindEntityWithClassname("player_start", spawnPoint)
    until spawnPoint == nil or not Shared.CollideBox(extents, spawnPoint:GetOrigin() + offset)

    local spawnPos = Vector(0, 0, 0)

    if (spawnPoint ~= nil) then
        spawnPos = Vector(spawnPoint:GetOrigin())
        // Move the spawn position up a little bit so the player won't start
        // embedded in the ground if the spawn point is positioned on the floor
        spawnPos.y = spawnPos.y + 0.01
    end

    // Create a new player for the client.
    local player = Server.CreateEntity("player", spawnPos)
    Server.SetControllingPlayer(client, player)
    
    Game.instance:StartGame()
    
    Shared.Message("Client " .. client .. " has joined the server")
   
end

/**
 * Called when a player disconnects from the server
 */
function OnClientDisconnect(client, player)   
	Shared.Message("Client " .. client .. " has disconnected") 
end

/**
 * Callback handler for when the map is finished loading.
 */
function OnMapPostLoad()

    // Create the game object. This is a networked object that manages the game
    // state and logic.
    Server.CreateEntity("game", Vector(0, 0, 0))

end

function OnConsoleThirdPerson(player)
    player:SetIsThirdPerson( not player:GetIsThirdPerson() )
end

function OnConsoleBuildBot(player)
	player:SetModel("models/marine/build_bot/build_bot.model")
end

function OnConsoleSkulk(player)
	player:SetModel("models/alien/skulk/skulk.model")
	player:SetViewModel("models/alien/skulk/skulk_view.model")
	player:GiveWeapon("weapon_bite")
end

function OnConsoleMarine(player)
	player:SetModel("models/marine/male/male.model")
	player:SetViewModel("models/marine/rifle/rifle_view.model")
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
        // Move the spawn position up a little bit so the player won't start
        // embedded in the ground if the spawn point is positioned on the floor
        spawnPos.y = spawnPos.y + 0.01
    end
    
    player:SetOrigin(spawnPos)
end


// Hook the game methods.
Event.Hook("ClientConnect",         OnClientConnect)
Event.Hook("ClientDisconnect",      OnClientDisconnect)
Event.Hook("MapPostLoad",           OnMapPostLoad)

Event.Hook("Console_thirdperson",   OnConsoleThirdPerson)
Event.Hook("Console_buildbot", 		OnConsoleBuildBot)
Event.Hook("Console_skulk", 		OnConsoleSkulk)
Event.Hook("Console_marine",		OnConsoleMarine)
Event.Hook("Console_stuck",			OnConsoleStuck)
