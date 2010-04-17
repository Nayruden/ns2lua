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
local http
local http_worked, http_res = pcall(require, "socket.http")
if http_worked then
    http = http_res
end

Script.Load("lua/Shared.lua")

Server.targetsEnabled = false
Server.instagib = false

function ChangePlayerClass(client, class, active, spawnPos)
	DebugMessage("Entering ChangePlayerClass(client, class, active, spawnPos)")
    local class_table = (PlayerClasses[class] or PlayerClasses.Default)
	
    DebugMessage("Changing "..(active and active:GetNick() or ("[client: "..client.."]")).." to "..class.." ("..class_table.mapName..")")
    local player = Server.CreateEntity(class_table.mapName, spawnPos or GetSpawnPos(class_table.extents) or Vector())
	if active then
		player:SetNick(active:GetNick())
		active:ClearInventory()
	end
	
    Server.SetControllingPlayer(client, player)
	player:SetController(client)
	
	if active then	
        Server.DestroyEntity(active)
    end

	DebugMessage("Exiting ChangePlayerClass(client, class, active, spawnPos)")
    return player
end

function Server.DestroyEntityTimed(entity, delay)
	entity:SetIsVisible(false)
	entity.moveGroupMask = 0
	table.insert(Game.instance.delete_queue, {Entity = entity, DeleteTime = Shared.GetTime() + delay})
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
	local offset = extents and Vector(0, extents.y + 0.01, 0)
    local spawnPoint
    for i = 1, 100 do
        spawnPoint = table.random(spawnPoints)
        if  not SpawnPoint
         or not extents
         or Shared.CollideBox(extents, spawnPoint:GetOrigin() + offset)
        then
            break
        end
    end
    if spawnPoint then
        local spawnPos = Vector(spawnPoint:GetOrigin())
        return spawnPos+Vector(0, 0.01, 0)--, spawnPoint:GetAngles()
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
	if http then
		http.request("http://serverlist.devicenull.org/register.php?port=27015")
	end
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
	local player = ChangePlayerClass(player.controller, "Default", player, GetSpawnPos(Player.extents, "ready_room_start") or GetSpawnPos(Player.extents) or Vector())
	player.godMode = true
end

function OnConsoleChangeClass(player, type)
	DebugMessage("Entering OnConsoleChangeClass(player, type)")
    if type == "Default" then
      --ChangePlayerClass(player.controller, type, player, player:GetOrigin())	
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
	DebugMessage("Exiting OnConsoleChangeClass(player, type)")
end

function OnConsoleLua(player, ...)
    ME = player
    local str = table.concat( { ... }, " " )
    Shared.Message( "(Server) Running lua: " .. str )
    local good, err = loadstring(str)
    if not good then
        Shared.Message( err )
        return
    end
    local worked, err = pcall(good)
    ME = nil
    if not worked then
        error(err)
    end
end

function OnCommandNick( ply, ... )
    local nickname = table.concat( { ... }, " " )
    Server.Broadcast( ply, "Nick changed to " .. nickname )
    ply:SetNick( nickname )
end

function OnCommandInstaGib( ply )
    if Game.instagib then
        Server.Broadcast( nil, "Game changed to normal mode by " .. ply:GetNick() )
        Game.instagib = false
        Rifle.clipSize              =  30
    else
        Server.Broadcast( nil, "Game changed to instagib mode by " .. ply:GetNick() )
        Game.instagib = true
        Rifle.clipSize              =  1
    end
	for k, class in pairs(PlayerClasses) do
		for k2, player in ipairs(GetEntitiesWithClassname(class.mapName)) do
            player:Respawn()
        end
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
--Event.Hook("Console_marineteam",    OnConsoleMarineTeam)
--Event.Hook("Console_alienteam",     OnConsoleAlienTeam)
--Event.Hook("Console_randomteam",    OnConsoleRandomTeam)
Event.Hook("Console_changeclass",   OnConsoleChangeClass)
Event.Hook("Console_lua",           OnConsoleLua)
Event.Hook("Console_nick",          OnCommandNick)
Event.Hook("Console_say",           OnConsoleSay)
Event.Hook("Console_instagib",      OnCommandInstaGib)
