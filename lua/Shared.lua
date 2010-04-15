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
		return "<Server>"
	elseif (Client) then
		return "<Client>"
	else
		return "<Unknown>"
	end
end