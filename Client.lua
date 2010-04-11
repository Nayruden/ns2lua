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
Script.Load("lua/ChatUI.lua")

Client.SetMouseVisible(false)
Client.SetMouseCaptured(true)
Client.SetMouseClipped(false)

function ShowInGameMenu()

    Client.SetMouseVisible(true)
    Client.SetMouseCaptured(false)

    Shared.SetMenu("ui/main_menu.swf")

end

function OnCommandNick( data, nickname )
	Main.SetOptionString( kNicknameOptionsKey, nickname )
	Shared.Message( "Nick changed to " .. nickname )
end

Event.Hook( "Console_nick", OnCommandNick )


function OnCommandHelp(userdata, ...)
    local args = { ... }
    if (args[1] == "commands") then
        Shared.Message("this should be a list of commands");
    elseif (args[1] == "features") then
    

        Shared.Message("Gameplay Changes")

        Shared.Message("  * Added “changeclass” command for changing your class to “buildbot”, “marine”, or “skulk”")
        Shared.Message("  * Basic deathmatch functionality. You can kill other players, and get teleported back to spawn when dead.")
        Shared.Message("  * K/D ratio will be shown in the hud")
        Shared.Message("  * View height will be adjusted depending on which class (marine/skulk) you choose")
        Shared.Message("  * Very, very experimental skulk “bite” and buildbot ‘peashooter’ weapons added")
        Shared.Message("  * Added rifle autoreload")
        Shared.Message("  * Added crouch ability (only slows you down since there’s no animation)")
        Shared.Message("  * Skulk moves 2x as fast as marines, Buildbot has 1/2 gravity")

        Shared.Message("General Changes and Fixes")

        Shared.Message("  * Fixed permajump (holding jump made you keep jumping whenever you touched the ground)")
        Shared.Message("  * Fixed ammo count changing before reload anim finished")
        Shared.Message("  * Fix 5 second delay when a player joins a server")
        Shared.Message("  * Added “nick” command for changing your name.")
        Shared.Message("  * Added “stuck” command")
        Shared.Message("  * Added an “invertmouse” console command")


    else
        Shared.Message("For more specific help, type help catagory-name")
        Shared.Message("commands")
        Shared.Message("features")
    end
end


Event.Hook("Console_help", OnCommandHelp)