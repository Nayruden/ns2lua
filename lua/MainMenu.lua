//=============================================================================
//
// lua/MainMenu.lua
// 
// Created by Max McGuire (max@unknownworlds.com)
// Copyright 2010, Unknown Worlds Entertainment
//
// This script is loaded when the game first starts. It handles creation of
// the main menu.
//=============================================================================

Script.Load("lua/InterfaceSounds_Client.lua")
Script.Load("lua/ServerBrowser.lua")
Script.Load("lua/CreateServer.lua")
Script.Load("lua/OptionsDialog.lua")
Script.Load("lua/BindingsDialog.lua")
Script.Load("lua/Update.lua")
Script.Load("lua/Interfaces.lua")

local mainMenuMusic = "sound/ns2.fev/music/main_menu"

function MainMenu_GetNumMaps()
    return table.maxn( maps )
end

function MainMenu_GetMapName(mapIndex)
    return maps[mapIndex].name
end

function MainMenu_GetMapFileName(mapIndex)
    return maps[mapIndex].fileName
end

function MainMenu_GetNumServers()
    return Main.GetNumServers()
end

function MainMenu_GetServerName(serverIndex)
    return Main.GetServerName(serverIndex - 1)
end

function MainMenu_GetServerAddress(serverIndex)
    return Main.GetServerAddress(serverIndex - 1)
end

function LeaveMenu()

    Main.SetMenu("")
    Main.SetMenuCinematic("")
    Main.StopSound(mainMenuMusic)

end

/**
 * Called when the user selects the "Host Game" button in the main menu.
 */
function MainMenu_HostGame(mapFileName, modName)

    LeaveMenu()
    
    local modName = GetModName(mapFileName)
    if(modName ~= nil) then
        Main.SetModName(modName)
    end
    
    Main.StartServer( mapFileName )

end

function GetModName(mapFileName)

    for index, mapEntry in ipairs(maps) do
        if(mapEntry.fileName == mapFileName) then
            return mapEntry.modName
        end
    end
    
    return nil
    
end

/**
 * Called when the user selects the "Join Game" button in the main menu.
 */
function MainMenu_JoinGame(serverAddress)
    
    LeaveMenu()
    
    Main.ConnectServer( serverAddress )

end

function MainMenu_RefreshServerList()

    Main.RebuildServerList()

end

/**
 * Returns true if we hit ESC while playing to display menu, false otherwise. 
 * Indicates to display the "Back to game" button.
 */
function MainMenu_IsInGame()
    return Main.GetInGame()
end

/**
 * Called when button clicked to return to game.
 */
function MainMenu_ReturnToGame()

    LeaveMenu()
    
    Client.SetMouseVisible(false)
    Client.SetMouseCaptured(true)
    
    Main.SetMenu("")

end

function MainMenu_Loaded()

    // Don't load anything unnecessary during development
    if(not Main.GetDevMode() and not MainMenu_IsInGame()) then
    
        Main.SetMenuCinematic("cinematics/main_menu.cinematic")
        Main.PlayMusic(mainMenuMusic)
        
    end
    
end

/**
 * Called when the user selects the "Quit" button in the main menu.
 */
function MainMenu_Quit()
    Main.Exit()
end