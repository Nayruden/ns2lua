--=============================================================================
--
-- lua/ServerBrowser.lua
-- 
-- Created by Henry Kropf and Charlie Cleveland
-- Copyright 2010, Unknown Worlds Entertainment
--
--=============================================================================
Script.Load("lua/Utility.lua")

package.path  = ".\\ns2\\lua\\?.lua"
package.cpath = ".\\ns2\\lua\\?.dll"
http = require("socket.http")

local hasNewData = true
local updateStatus = ""

-- List of server records - { {servername, gametype, map, playercount, ping, ipAddress}, {servername, gametype, map, playercount, ping, ipAddress}, etc. }
local serverRecords = {}

-- Data to return to flash. Single-dimensional array like:
-- {servername, gametype, map, playercount, ping, ipAddress, servername, gametype, map, playercount, ping, ipAddress, ...)
local returnServerList = {}

local kNumColumns = 6

local kSortTypeName = 1
local kSortTypeGame = 2
local kSortTypeMap = 3
local kSortTypePlayers = 4
local kSortTypePing = 5

local sortType = kSortTypePing
local ascending = true
local justSorted = false

numServers = tonumber(http.request("http://serverlist.devicenull.org/serverlist.php?get=servercount"), 10)

--
-- Sort option for the name field in order specified by ascending boolean
--/
function MainMenu_SBSortByName(newAscending)
    sortType = kSortTypeName
    ascending = newAscending
    justSorted = true
end

--
-- Sort option for the game field in order specified by ascending boolean
--/
function MainMenu_SBSortByGame(newAscending) 
    sortType = kSortTypeGame
    ascending = newAscending
    justSorted = true
end

--
-- Sort option for the map field in order specified by ascending boolean
--/
function MainMenu_SBSortByMap(newAscending) 
    sortType = kSortTypeMap
    ascending = newAscending
    justSorted = true
end

--
-- Sort option for the players field in order specified by ascending boolean
--/
function MainMenu_SBSortByPlayers(newAscending) 
    sortType = kSortTypePlayers
    ascending = newAscending
    justSorted = true
end

--
-- Sort option for the ping field in order specified by ascending boolean
--/
function MainMenu_SBSortByPing(newAscending) 
    sortType = kSortTypePing
    ascending = newAscending
    justSorted = true
end

function MainMenu_SBRefreshServerList()
    updateStatus = "Retrieving server list..."
    RefreshServerList()
    updateStatus = ""
end

--
-- Return a string saying what the browser is doing...
--/
function MainMenu_SBGetUpdateStatus()
    return updateStatus
end

function GetNumServers()
    return numServers + Main.GetNumServers()
end

--
-- Return a boolean indicating if new data is available since last GetServerList() call. Updates hasNewData as well.
--/
function MainMenu_SBHasNewData()

    local numServers = GetNumServers()
    hasNewData = (numServers ~= table.maxn(serverRecords))
    if(numServers < table.maxn(serverRecords)) then
        --returnServerList = {}
        --serverRecords = {}
    end
    
    if(not hasNewData) then
        updateStatus = string.format("Found %d servers.", numServers)
    end
    
    if(justSorted) then
        hasNewData = true
        justSorted = false
    end
       
    return hasNewData
    
end

-- Sort current server list according to sortType and ascending
function SortReturnServerList()

    function sortString(e1, e2)    
        if(ascending) then
            return string.lower(e1[sortType]) < string.lower(e2[sortType])
        else
            return string.lower(e2[sortType]) < string.lower(e1[sortType])
        end
    end

    function sortNumber(e1, e2)    
        if(ascending) then
            return e1[sortType] < e2[sortType]
        else
            return e2[sortType] < e1[sortType]
        end
    end

    if(sortType == kSortTypePlayers or sortType == kSortTypePing) then
        table.sort(serverRecords, sortNumber)
    else
        table.sort(serverRecords, sortString)
    end
end
local refresh = true
function RefreshServerList()
    refresh = true
    MainMenu_SBGetServerList()
end

-- Trim off unnecessary path and extension
function GetTrimmedMapName(mapName)

    for trimmedName in string.gmatch(mapName, "\/(.+)\.level") do
        return trimmedName
    end
    
    return mapName
end

function GetServerRecord(serverIndex)
    return {Main.GetServerName(serverIndex), Main.GetServerGameDesc(serverIndex), GetTrimmedMapName(Main.GetServerMapName(serverIndex)), Main.GetServerNumPlayers(serverIndex), Main.GetServerPing(serverIndex), Main.GetServerAddress(serverIndex)}
end

--
-- Return a linear array of all servers, in 
-- {servername, gametype, map, playercount, ping, serverUID}
-- order
--/


function split(str, delim)
    fields = {}
    str:gsub("([^"..delim.."]*)"..delim, function(c) table.insert(fields, c) end)
    return fields;
end

function MainMenu_SBGetServerList()
    
    if(refresh) then
        refresh = false
        --serverRecords = {}
        --local numServers = GetNumServers()
        updateStatus = string.format("Retrieving %d %s...", numServers, ConditionalValue(numServers == 1, "server", "servers"))
        local servers, headers, code = http.request("http://serverlist.devicenull.org/serverlist.php")
        numServers = tonumber(servers:sub(1,2))
        lines = split(servers,"\n")
        for key1,value1 in pairs(lines) do
            if (key1 ~= 1) then
                
                rows = split(value1,"\t")
                name = ""
                ip = ""
                map = ""
                players = ""
                gametype = ""
                for key,value in pairs(rows) do
                    if (key == 1) then
                        ip = value
                    end
                    if (key == 2) then
                        port = value
                    end
                    if (key == 3) then
                        name = value
                    end
                    if (key == 4) then
                        players = value
                    end
                    if (key == 6) then
                        map = value
                    end
                    if (key == 7) then
                        gametype = value
                    end
                end
                table.insert(serverRecords, {name, gametype, map, players, "10", ip})
            end
        end

        Main.RebuildServerList()
        --hasNewData = true
        local numServer = Main.GetNumServers()
        for serverIndex = 1, numServer - 1 do
        
            local serverRecord = GetServerRecord(serverIndex)
            
            -- Build master list so we don't re-retrieve later
            table.insert(serverRecords, serverRecord)

        end

        
        SortReturnServerList()
        
        -- Create return server list as linear array
        returnServerList = {}
        
        for index, serverRecord in ipairs(serverRecords) do
        
            for j=1, table.maxn(serverRecord) do
                table.insert(returnServerList, serverRecord[j])
            end
            
        end
        serverRecords = {}
    else
        updateStatus = ""
    end 
   
    return returnServerList
    
end

--
-- Join the server specified by UID
--/
function MainMenu_SBJoinServer(uid) 
    LeaveMenu()
    Main.ConnectServer(uid)
end

--
-- Return linear array of server uids and texture reference strings
--/
function MainMenu_SBGetRecommendedList()
    local a = {}
    return a
end

-- Uncomment to use test data in browser
--Script.Load("lua/ServerBrowser_Test.lua")
