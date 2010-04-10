//=============================================================================
//
// RifleRange/Client.lua
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
//
// This file is the entry point for the client code of the game. It's
// automatically loaded by the engine when a game starts.
//
//=============================================================================

// Set the name of the VM for debugging
decoda_name = "Client"

Script.Load("lua/Shared.lua")
Script.Load("lua/PlayerUI.lua")

Client.SetMouseVisible(false)
Client.SetMouseCaptured(true)
Client.SetMouseClipped(false)

function ShowInGameMenu()
    
    Client.SetMouseVisible(true)
    Client.SetMouseCaptured(false)
    
    Shared.SetMenu("ui/main_menu.swf")
    
end