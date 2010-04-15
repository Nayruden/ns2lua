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

function OnConsoleDebugMode()
	Shared.enableDebugMessages = not Shared.enableDebugMessages
    Shared.Message("<" .. GetContextString() .. "> Debug mode " .. (Shared.enableDebugMessages and "enabled." or "disabled."))
end

Event.Hook("Console_debug", OnConsoleDebugMode)