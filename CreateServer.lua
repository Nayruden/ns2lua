//=============================================================================
//
// lua/CreateServer.lua
// 
// Created by Henry Kropf
// Copyright 2010, Unknown Worlds Entertainment
//
//=============================================================================

local kDefaultGameMod = "ns2"

local kServerNameKey    = "serverName"
local kMapNameKey       = "mapName"
local kGameModKey       = "gameMod"
local kPlayerLimitKey   = "playerLimit"
local kLanGameKey       = "lanGame"

/**
 * Get server name
 */
function CreateServerUI_GetServerName()
    return Main.GetOptionString( kServerNameKey, "NS2 Server" )
end

/**
 * Get linear array of map names (strings)
 */
function CreateServerUI_GetMapName()

    // Convert to a simple table
    
    local mapNames = { }
    
    for index, mapEntry in ipairs(maps) do
        mapNames[index] = mapEntry.name
    end    

    return mapNames
    
end

/**
 * Get current index for map choice (assuming lua indexing for script convenience)
 */
function CreateServerUI_GetMapNameIndex()

    // Get saved map name and return index
    local mapName = Main.GetOptionString( kMapNameKey, "" )
    
    if (mapName ~= "") then
        
        for i = 1, table.maxn(maps) do
            if (maps[i].fileName == mapName) then
                return i
            end
        end
    
    end    
    
    return 1
    
end

/**
 * Get linear array of game mods (strings)
 */
function CreateServerUI_GetGameModes()
    return mods
end

/**
 * Get current index for game mods (assuming lua indexing for script convenience)
 */
function CreateServerUI_GetGameModesIndex()

    // Get saved map name and return index
    local modName = Main.GetOptionString( kGameModKey, kDefaultGameMod )
    
    for i = 1, table.maxn(mods) do
        if (mods[i] == modName) then
            return i
        end
    end
    
    return 1

end

/**
 * Get player limit
 */
function CreateServerUI_GetPlayerLimit()
    return Main.GetOptionInteger(kPlayerLimitKey, 16)
end


/**
 * Get lan game value (boolean)
 */
function CreateServerUI_GetLanGame()
    return Main.GetOptionBoolean(kLanGameKey, false)
end


/**
 * Get all the values from the form
 * serverName - string for server
 * mapIdx - 1 - ? index of choice
 * gameModIdx - 1 - ? index of choice
 * playerLimit - 2 - 32
 * lanGame - boolean
 */
function CreateServerUI_SetValues(serverName, mapIdx, gameModIdx, playerLimit, lanGame)
    
    // Set options
    Main.SetOptionString( kServerNameKey, serverName )
    Main.SetOptionString( kMapNameKey, maps[mapIdx].fileName )
    Main.SetOptionString( kGameModKey, mods[gameModIdx] )
    Main.SetOptionInteger(kPlayerLimitKey, playerLimit)
    Main.SetOptionBoolean( kLanGameKey, lanGame )
    
end

/**
 * Called when player presses the Create Game button with the set values.
 */
function CreateServerUI_CreateServer()

    local modName = CreateServerUI_GetGameModes()[CreateServerUI_GetGameModesIndex()]
    if(modName ~= kDefaultGameMod) then
        Main.SetModName(modName)
    end
   
    local mapName = Main.GetOptionString( kMapNameKey, "" )
    
    if(mapName ~= "" and Main.StartServer( mapName )) then
        LeaveMenu()
    end

end