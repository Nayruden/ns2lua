--=============================================================================
--
-- lua/Main.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright 2010, Unknown Worlds Entertainment
--
-- This script is loaded when the game first starts. It handles creation of
-- the main menu.
--=============================================================================

-- Set the name of the VM for debugging
decoda_name = "Main"

Script.Load("lua/Globals.lua")
Script.Load("lua/MainMenu.lua")

mods = { "ns2lua" }
maps =
    {
        { name = "Range #1",    fileName = "ns2_dm1.level"  },
        { name = "Range #2",    fileName = "ns2_dm2.level"  },
        { name = "Test Level",  fileName = "test.level"     },
    }

--
-- Called when the user types the "map" command at the console.
--/
function OnCommandMap(mapFileName)
    MainMenu_HostGame(mapFileName)
end

--
-- Called when the user types the "connect" command at the console.
--/
function OnCommandConnect(serverAddress)
    MainMenu_JoinGame(serverAddress)
end

--
-- Called when the user types the "exit" command at the console or clicks the exit button.
--/
function OnCommandExit()
    Main.Exit()
end

Event.Hook("Console_connect",  OnCommandConnect)
Event.Hook("Console_map",  OnCommandMap)
Event.Hook("Console_exit", OnCommandExit)
Event.Hook("Console_quit", OnCommandExit)

Main.SetMenu( kMainMenuFlash )
