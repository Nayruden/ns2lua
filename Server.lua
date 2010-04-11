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
Script.Load("lua/ReadyRoomStart.lua")
Script.Load("lua/TeamJoin.lua")

/**
 * Called when a player first connects to the server.
 */
function OnClientConnect(client)

    // Get an unobstructured spawn point for the player.
    
    local extents = Player.extents
    local offset  = Vector(0, extents.y + 0.01, 0)
    
    repeat
        spawnPoint = Shared.FindEntityWithClassname("ready_room_start", spawnPoint)
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
    Server.CreateEntity("chat", Vector(0, 0, 0))

end

function OnConsoleThirdPerson(player)
    player:SetIsThirdPerson( not player:GetIsThirdPerson() )
end

function OnConsoleChangeClass(player,type) 
	if (type == "buildbot") then
		player:ChangeClass(Player.Classes.BuildBot)
		Shared.Message("You have become a BuildBot!");
	elseif (type == "skulk") then
		player:ChangeClass(Player.Classes.Skulk)
		Shared.Message("You have become a Skulk!");
	else
		player:ChangeClass(Player.Classes.Marine)
		Shared.Message("You have become a Marine!");
	end
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
        // Move the spawn position up a little bit so the player won't start
        // embedded in the ground if the spawn point is positioned on the floor
        spawnPos.y = spawnPos.y + 0.01
    end
    
    player:SetOrigin(spawnPos)
end

function OnConsoleSay(player, ...)
    local args = table.concat( { ... }, " " )
    Chat.instance:SetMessage(args)
end

function OnConsoleTurret(player)
    local turret = Server.CreateEntity( "turret",  player:GetOrigin() )
    player:SetAngles( player:GetAngles() )
end

function OnConsoleDumpCmds(player)
	Shared.Message("Server:")
	for k,v in pairs(Server) do 
		Shared.Message(k)
		//for k1,v1 in debug.getinfo(v) do 
		//	Shared.Message(tostring(k1) .. " " .. tostring(v1))
		//end
		
	end
	Shared.Message("Shared:")
	for k,v in pairs(Shared) do Shared.Message(k .. " " .. tostring(v)) end
	Shared.Message("Event:")
	for k,v in pairs(Event) do Shared.Message(k .. " " .. tostring(v)) end
	//Shared.Message("Game:")
	//for k,v in pairs(Game) do Shared.Message(k .. " " .. tostring(v)) end
	Shared.Message("Player:")
	for k,v in pairs(Player) do Shared.Message(k .. " " .. tostring(v)) end
end


// Hook the game methods.
Event.Hook("ClientConnect",         OnClientConnect)
Event.Hook("ClientDisconnect",      OnClientDisconnect)
Event.Hook("MapPostLoad",           OnMapPostLoad)

Event.Hook("Console_thirdperson",   OnConsoleThirdPerson)

Event.Hook("Console_invertmouse",	OnConsoleInvertMouse)
Event.Hook("Console_changeclass",	OnConsoleChangeClass)

Event.Hook("Console_stuck",			OnConsoleStuck)

Event.Hook("Console_say",			OnConsoleSay)

Event.Hook("Console_turret",		OnConsoleTurret)

Event.Hook("Console_dumpcmds", 		OnConsoleDumpCmds)