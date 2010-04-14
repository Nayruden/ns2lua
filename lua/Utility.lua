-- ======= Copyright © 2003-2010, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Utility.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http:--www.unknownworlds.com =====================

Script.Load("lua/Constants.lua")
Script.Load("lua/Table.lua")
Script.Load("lua/ns2devslib.lua")
  
-- Splits string into array, along whitespace boundaries. First element indexed at 1.
function StringToArray(instring)

    local thearray = {}
    local index = 1

    for word in instring:gmatch("%S+") do
        thearray[index] = word
        index = index + 1
    end
    
    return thearray

end

function GetAspectRatio()
    
    return Client.GetScreenWidth() / Client.GetScreenHeight()

end

function AdvanceValByRate(startVal, endVal, rate)

    local diff = endVal - startVal
    local val = 0
    
    if(math.abs(diff) < math.abs(rate)) then
        val = endVal
    else
        val = startVal + GetSign(diff)*rate
    end
    
    return val

end

function GetSurfaceFromTrace(trace)

    if((trace.entity ~= nil and trace.entity:isa("BuildableStructure") and trace.entity:GetTeamType() == kAlienTeamType)) then
        return "organic"
    elseif((trace.entity ~= nil and trace.entity:isa("BuildableStructure") and trace.entity:GetTeamType() == kMarineTeamType)) then
        return "thin_metal"
    end

    return trace.surface
    
end

-- Returns nil if it doesn't hit
function GetLinePlaneIntersection(planePoint, planeNormal, lineOrigin, lineDirection)

    local p = lineDirection:DotProduct(planeNormal)
    
    if p < 0  then

        local d = -planePoint:DotProduct(planeNormal)
        local t = -(planeNormal:DotProduct(lineOrigin) + d) / p

        if t >= 0 then
        
            return lineOrigin + lineDirection * t
            
        end
        
    end
    
    return nil
    
end

-- Returns the sign of a number (1, 0, -1)
function signum(num)

    local sign = 1

    if (num < 0) then
        sign = -1
    elseif(num == 0) then
        sign = 0
    end

    return sign

end

function Hump(x)
    return 0.5 - math.cos(x * math.pi) * 0.5
end

function DebugBox(minPoint, maxPoint, lifetime, r, g, b, a)
    -- Bottom of cube
    DebugLine(Vector(minPoint.x, minPoint.y, minPoint.z), Vector(minPoint.x, minPoint.y, maxPoint.z), lifetime, r, g, b, a)
    DebugLine(Vector(minPoint.x, minPoint.y, minPoint.z), Vector(maxPoint.x, minPoint.y, minPoint.z), lifetime, r, g, b, a)
    DebugLine(Vector(maxPoint.x, minPoint.y, minPoint.z), Vector(maxPoint.x, minPoint.y, maxPoint.z), lifetime, r, g, b, a)
    DebugLine(Vector(minPoint.x, minPoint.y, maxPoint.z), Vector(maxPoint.x, minPoint.y, maxPoint.z), lifetime, r, g, b, a)
    
    -- Top of cube
    DebugLine(Vector(minPoint.x, maxPoint.y, minPoint.z), Vector(minPoint.x, maxPoint.y, maxPoint.z), lifetime, r, g, b, a)
    DebugLine(Vector(minPoint.x, maxPoint.y, minPoint.z), Vector(maxPoint.x, maxPoint.y, minPoint.z), lifetime, r, g, b, a)
    DebugLine(Vector(maxPoint.x, maxPoint.y, minPoint.z), Vector(maxPoint.x, maxPoint.y, maxPoint.z), lifetime, r, g, b, a)
    DebugLine(Vector(minPoint.x, maxPoint.y, maxPoint.z), Vector(maxPoint.x, maxPoint.y, maxPoint.z), lifetime, r, g, b, a)
    
    -- Sides
    DebugLine(Vector(minPoint.x, maxPoint.y, minPoint.z), Vector(minPoint.x, minPoint.y, minPoint.z), lifetime, r, g, b, a)
    DebugLine(Vector(maxPoint.x, maxPoint.y, minPoint.z), Vector(maxPoint.x, minPoint.y, minPoint.z), lifetime, r, g, b, a)
    DebugLine(Vector(maxPoint.x, maxPoint.y, maxPoint.z), Vector(maxPoint.x, minPoint.y, maxPoint.z), lifetime, r, g, b, a)
    DebugLine(Vector(minPoint.x, maxPoint.y, maxPoint.z), Vector(minPoint.x, minPoint.y, maxPoint.z), lifetime, r, g, b, a)
    
end

-- rgba are normalized values (0-1)
function DebugLine(startPoint, endPoint, lifetime, r, g, b, a)
    if (Client and not Client.GetIsRunningPrediction()) then
        Client.DebugColor(r, g, b, a)
        Client.DebugLine(startPoint, endPoint, lifetime)
    end
end

function DebugPoint(point, size, lifetime, r, g, b, a)
    if (Client and not Client.GetIsRunningPrediction()) then
        Client.DebugColor(r, g, b, a)
        Client.DebugPoint(point, size, lifetime)
    end
end

function DebugCapsule(sweepStart, sweepEnd, capsuleRadius, capsuleHeight, lifetime)
    if (Client and not Client.GetIsRunningPrediction()) then    
        Client.DebugCapsule(sweepStart, sweepEnd, capsuleRadius, capsuleHeight, lifetime)        
    end
end

-- Can print one argument (string or not), or a string and variable list of parameters passed to string.format()
-- Print formatted message to console:
-- Print("%s %.2f", "Animation fraction:", .5)
-- Print(intValue)
-- Doesn't print when predicting.
function Print(formatString, ...)

    local result = string.format(formatString, ...)

    if(Client == nil or not Client.GetIsRunningPrediction()) then
        if(Client) then
            Shared.Message(result .. " - Client")
            printed = true
        else
            Shared.Message(result .. " - Server")
        end
    end
    
    print(result)    
    
    return result
    
end

-- Print message with stamp showing if it is on client or server, along with timestamp. Good for time-sensitive
-- or client/server logging.
-- Print(4.5)
-- Print("%s", "testing")
function PrintDetailed(formatString, ...)

    local result = string.format(formatString, ...)
    
    local timestampedMessage = result .. " (at " .. Shared.GetTime() .. ")"

    if(Server) then
        Server.Broadcast(player, timestampedMessage .. " (Server)")
    elseif(Client and not Client.GetIsRunningPrediction()) then
        Client.DebugMessage(timestampedMessage .. " (Client)")
    end    
    
    return result
    
end

function ConditionalValue(expression, value1, value2) 

    if(expression) then
        return value1
    else
        return value2
    end
    
end

function CreatePickRay(player, xRes, yRes)

    local pickVec = Client.CreatePickingRayXY(xRes, yRes)
       
    return pickVec
    
end

-- Trace until we hit the "inside" of the level or hit nothing. Returns nil if we hit nothing,
-- returns the world point of the surface we hit otherwise. Only hit surfaces that are facing 
-- towards us.
function GetCommanderPickTarget(player, pickVec)

    local done = false
    local startPoint = player:GetOrigin()
    local trace = nil
    
    while not done do
    
        trace = Shared.TraceRay(startPoint, pickVec * 1000, EntityFilterOne(player))
        local hitDistance = (startPoint - trace.endPoint):GetLength()
        
        -- Try again if we're inside the surface
        if(trace.fraction == 0 or hitDistance < .1) then
        
            startPoint = startPoint + pickVec
        
        elseif(trace.fraction == 1) then
        
            done = true

        -- Only hit a target that's facing us (skip surfaces facing away from us)            
        elseif(trace.normal:DotProduct(pickVec) < 0) then
        
            done = true
            
        else
        
            if(startPoint == trace.endPoint) then
            
                done = true
                
            else
            
                -- Trace again from what we hit
                startPoint = trace.endPoint
                
            end
            
        end
        
    end
    
    return trace
    
end

function GetInfestationAtPoint(teamNumber, point)

    local infestEntities = GetEntitiesIsaInRadius("Infestation", teamNumber, point, kInfestationSize/2)
    local numInfestionEntities = table.maxn(infestEntities)
    return numInfestionEntities > 0

end

function GetEnemyTeamNumber(entityTeamNumber)

    if(entityTeamNumber == kTeam1Index) then
        return kTeam2Index
    elseif(entityTeamNumber == kTeam2Index) then
        return kTeam1Index
    else
        return kTeamInvalid
    end    
    
end

-- Returns true or false along with location (on ground, inside level) that has space for entity. 
-- Last parameter is length of box size that is used to make sure location is big enough (can be nil).
-- Returns point sitting on ground.
function GetRandomSpaceForEntity(basePoint, radius, boxSize)
   
    -- Find clear space at radius 
    for i = 0, 30 do
    
        local randomRadians = NetworkRandom()*2*math.pi
        local distance = NetworkRandom() * radius
        local offset = Vector( math.cos(randomRadians) * distance, 0, math.sin(randomRadians) * distance )
        local testLocation = basePoint + offset
        local finalLocation = Vector()
        VectorCopy(testLocation, finalLocation)
        DropToFloor(finalLocation)

        -- Make sure we don't drop out of the world
        if((finalLocation - testLocation):GetLength() < 20) then
        
            finalLocation.y = finalLocation.y + .01
        
            if(boxSize == nil) then
            
                return true, finalLocation
                
            else
            
                -- If extents specified, make sure there's enough room for object
                local boxOrigin = Vector(finalLocation.x, finalLocation.y + boxSize + kEpsilon, finalLocation.z)
                local trace = Shared.TraceBox(Vector(boxSize, boxSize, boxSize), boxOrigin, Vector(boxOrigin.x, boxOrigin.y + .1, boxOrigin.z))
                
                if(trace.entity == nil and trace.fraction == 1) then

                    return true, finalLocation
                    
                end
                
            end
            
        end

    end

    return false, nil
    
end

-- Assumes input angles are in radians and will move angle towards target the shortest direction (CW or CCW). Speed must be positive.
function InterpolateAngle(currentAngle, desiredAngle, speed)

    -- current 1, desired 4, speed 2 => angleDiff 3, sign = +1, moveAmount = 2, return 1 + 2 = 3
    -- current -1, desired -3, speed 1 => angleDiff -2, sign = -1, moveAmount = -1, return -1 - 1 = -2
    local angleDiff = desiredAngle - currentAngle
    
    local angleDiffSign = GetSign(angleDiff)
    
    -- Don't move past angle
    local moveAmount = math.min(math.abs(angleDiff), math.abs(speed))*angleDiffSign
    
    --return currentAngle + moveAmount
    
    return desiredAngle

end

-- Moves value towards target by rate, regardless of sign of rate
function Slerp(current, target, rate)

    if(rate < 0) then
        rate = -rate
    end
    
    if(math.abs(target - current) < rate) then
        return target
    end
    
    return current + GetSign(target - current)*rate
    
end

-- Trace position down to ground
function DropToFloor(point)

    local done = false
    local numTraces = 0
    
    -- Keep tracing until we hit something, that's not an entity (world geometry)
    local ignoreEntity = nil
    
    while not done do
    
        local trace
        
        if(ignoreEntity == nil) then
            trace = Shared.TraceRayNoFilter(point, Vector(point.x, point.y - 1000, point.z))
        else
            trace = Shared.TraceRay(point, Vector(point.x, point.y - 1000, point.z), EntityFilterOne(ignoreEntity))
        end
        
        numTraces = numTraces + 1
        
        -- Backup the end point by a small amount to avoid interpenetration.AcquireTarget
        local newPoint = trace.endPoint - trace.normal * 0.01
        VectorCopy(newPoint, point)
        
        if(trace.entity == nil or numTraces > 10) then        
            done = true
        else
            ignoreEntity = trace.entity
        end
        
    end

end

function GetNearestAvailableTechPoint(origin, teamType)

    -- Look for nearest empty tech point to use instead
    local nearestTechPoint = nil
    local nearestTechPointDistance = 0

    local techPoints = GetEntitiesIsa("TechPoint", -1)
    for index, techPoint in pairs(techPoints) do
    
        -- Only use unoccupied tech points that are neutral or marked for use with our team
        local techPointTeamNumber = techPoint:GetTeamNumber()
        if( (techPoint:GetAttached() == nil) and ((techPointTeamNumber == kNeutralTeamType) or (teamType == techPointTeamNumber)) ) then
    
            local distance = (techPoint:GetOrigin() - origin):GetLength()
            if(nearestTechPoint == nil or distance < nearestTechPointDistance) then
            
                nearestTechPoint = techPoint
                nearestTechPointDistance = distance
                
            end
        
        end
        
    end
    
    return nearestTechPoint
    
end

-- Computes line of sight to entity
function GetCanSeeEntity(seeingEntity, targetEntity)

    local seen = false
    
    -- See if line is in our view cone
    if(targetEntity:GetIsVisible()) then
    
        local eyePos = seeingEntity:GetEyePos()
        local toEntity = targetEntity:GetOrigin() - eyePos
        local normToEntityVec = GetNormalizedVector(toEntity)
        local normViewVec = seeingEntity:GetViewAngles():GetCoords().zAxis
       
        local dotProduct = normToEntityVec:DotProduct(normViewVec)
        local halfFov = math.rad(seeingEntity:GetFov()/2)
        local s = math.acos(dotProduct)
        if(s < halfFov) then

            -- See if there's something blocking our view of entity
            local trace = Shared.TraceRay(eyePos, targetEntity:GetModelOrigin(), EntityFilterTwo(seeingEntity, targetEntity))
            if(trace.fraction == 1) then                
                seen = true
            end
            
        end

        -- Draw red or green line
        if(Client and Shared.GetDevMode()) then
            DebugLine(eyePos, targetEntity:GetOrigin(), 1, ConditionalValue(seen, 0, 1), ConditionalValue(seen, 1, 0), 0, 1)
        end
        
    end
    
    return seen
    
end

function GetClientServerString()
    return ConditionalValue(Client, "Client", "Server")
end

function CoordsToString(coords, coordsName)
    local name = ConditionalValue(coordsName ~= nil, tostring(coordsName), "Coord: ")
    return string.format("%s origin: (%0.2f, %0.2f, %0.2f) xAxis: (%0.2f, %0.2f, %0.2f) yAxis: (%0.2f, %0.2f, %0.2f) zAxis: (%0.2f, %0.2f, %0.2f)",
                            name, coords.origin.x, coords.origin.y, coords.origin.z, 
                            coords.xAxis.x, coords.xAxis.y, coords.xAxis.z, 
                            coords.yAxis.x, coords.yAxis.y, coords.yAxis.z, 
                            coords.zAxis.x, coords.zAxis.y, coords.zAxis.z)
end

function GetAnglesDifference(startAngle, endAngle)

    local tolerance = 0.1
    local diff = endAngle - startAngle
    
    if(math.abs(diff) > 100) then
        Shared.Message(string.format("Warning - GetAnglesDiff(%.2f, %.2f) called with large numbers, should be optimized.", startAngle, endAngle))
    end
    
    while(math.abs(diff) > (2*math.pi - tolerance)) do
        diff = diff - GetSign(diff)*2*math.pi
    end
    
    -- Return shortest path around circle
    if(math.abs(diff) > math.pi) then
        diff = diff - GetSign(diff)*2*math.pi
    end
    
    return diff
    
end

-- Takes a normalized vector
function SetAnglesFromVector(entity, vec)

    local angles = Angles(entity:GetAngles())
    
    local dx = vec.x
    local dz = vec.z
    
    angles.yaw = math.atan2(dx, dz)
    entity:SetAngles(angles)
    
end

function GetYawFromVector(vec)

    local dx = vec.x
    local dz = vec.z
    
    return math.atan2(dx, dz)

end

function GetPitchFromVector(vec)
    return math.asin(vec.y)    
end

function SetViewAnglesFromVector(entity, vec)

    local angles = entity:GetAngles()
    
    local dx = vec.x
    local dz = vec.z
    
    angles.yaw = math.atan2(dx, dz)
    entity:SetViewAngles(angles)

end

-- Returns degrees between -360 and 360
function DegreesTo360(degrees)

    while(degrees < -360) do
        degrees = degrees + 360
    end
    
    while(degrees > 360) do
        degrees = degrees - 360
    end
    
    return degrees

end

function DrawEntityAxes(entity)

    -- Draw x red, y green, z blue (like 3ds Max)
    local lineLength = 2
    local coords = entity:GetAngles():GetCoords()
    local p0 = entity:GetOrigin()
    
    DebugLine(p0, p0 + coords.xAxis*lineLength, .1, 1, 0, 0, 1)
    DebugLine(p0, p0 + coords.yAxis*lineLength, .1, 0, 1, 0, 1)
    DebugLine(p0, p0 + coords.zAxis*lineLength, .1, 0, 0, 1, 1)
    
end

function GetIsDebugging()
    return (decoda_output ~= nil)
end

function GetSign(number)

    if(number > 0) then
        return 1
    elseif(number < 0) then
        return -1
    end
    
    return 0
    
end

-- Pass no parameters for 0-1 random value, otherwise pass integers for random number between those numbers (inclusive).
function NetworkRandom(minValue, maxValue)

    local random = 0
    
    if(minValue == nil or maxValue == nil) then
    
        random = Shared.GetRandomFloat()
    
    else
    
        random = Shared.GetRandomInt( math.min(minValue, maxValue), math.max(minValue, maxValue) )

    end
    
    return random
    
end

function EncodePointInString(point)
    return string.format("%0.2f_%0.2f_%0.2f_", point.x, point.y, point.z)
end

function DecodePointFromString(string)

    local numParsed = 0
    local point = Vector()
    
    for stringCoord in string.gmatch(string, "[0-9.\-]+") do 
    
        local coord = tonumber(stringCoord)
        numParsed = numParsed + 1
        
        if(numParsed == 1) then
            point.x = coord
        elseif(numParsed == 2) then
            point.y = coord
        else
            point.z = coord
        end
        
        if(numParsed == 3) then
            return true, point
        end
        
    end
    
    return false, nil
    
end

-- Allows us to send/receive strings without @ symbols
-- Convert @ to spaces
-- Make better later if needed
function EncodeStringForNetwork(inputString)

    -- Don't allow strings with @ in them
    if(string.find(inputString, "@") ~= nil) then
        Shared.Message(string.format("EncodeStringForNetwork(%s) error - Strings can't contain '@' characters.", inputString))
    end
    
    -- Convert spaces to @
    return string.gsub(inputString, " ", "@")
    
end

-- Convert @ to space
function DecodeStringFromNetwork(inputString)
    if(inputString == nil) then
        return nil
    end
    return string.gsub(inputString, "@", " ")
end

function GetColorForPlayer(player)

    if(player ~= nil) then
        if(player:isa("Marine")) then
            return kMarineTeamColor
        elseif(player:isa("Alien")) then
            return kAlienTeamColor
        end
    end
    
    return kNeutralTeamColor   
    
end

-- Generate unique name that isn't taken by another player on the server. If it is,
-- return number variant "NsPlayer (2)". Optionally pass a list of names for testing.
-- If not passing a list of names, this is on the server only.
function GetUniqueNameForPlayer(name, nameList)
    -- Make sure name isn't in use
    if(nameList == nil) then
    
        nameList = {}
        
        local players = GetEntitiesIsa("Player", -1)
        
        for index, player in ipairs(players) do
            local name = player:GetName()
            if(name ~= nil and name ~= "") then
                table.insert(nameList, string.lower(name))
            end
        end

    end
    
    -- Case-insensitive check for specified name in nameList
    function nameInTable(name)
    
        for index, entryName in ipairs(nameList) do
        
            if(string.lower(entryName) == string.lower(name)) then
                return true
            end
            
        end
        
        return false
        
    end
    
    local returnName = name
    
    if(nameInTable(name)) then
    
        for i = 1, kMaxPlayers do
        
            -- NsPlayer (2)
            local newName = string.format("%s (%d)", name, i+1)
            
            if(not nameInTable(newName)) then
            
                returnName = newName
                break
                
            end
            
        end

    end
    
    return returnName
    
end

-- http:--lua-users.org/wiki/InfAndNanComparisons
function IsValidValue(value)

    if(type(value) == "number") then
        return (not (value ~= value) and (value < math.huge) and (value > -math.huge))
    end
    
    return true

end

function Clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

function Assert(condition, message)

    if(not condition) then
        Shared.Message(message)
        return false
    end
    
    return true
end

function ValidateValue(value, logMessage)

    if(value:isa("Vector")) then
    
        local xValid = Assert(IsValidValue(value.x), string.format("Vector.x not valid/finite (%s)", logMessage))
        local yValid = Assert(IsValidValue(value.y), string.format("Vector.y not valid/finite (%s)", logMessage))
        local zValid = Assert(IsValidValue(value.z), string.format("Vector.z not valid/finite (%s)", logMessage))
        return xValid and yValid and zValid
        
    elseif(type(value) == "number") then
    
        return Assert(IsValidValue(value), string.format("Value is not valid/finite (%s)", logMessage))
        
    end
    
    return true
    
end

-- Calls entity:SetTeamNumber(teamNumber) (if team number passed) and SetOrigin().
function InitEntity(entity, className, origin, teamNumber)

    if(entity:isa("ScriptActor")) then

        if(teamNumber ~= nil) then
            entity:SetTeamNumber(teamNumber)
        end
        
        entity:SetOrigin(origin)
        entity:OnSpawn()
        
    end
    
end

-- teamNumber optional. Make sure to pass the mapName, not className.
function CreateEntity(mapName, origin, teamNumber)

    local entity = nil
    
    if(origin == nil) then
        origin = Vector(0, 0, 0)
    end
    
    if(teamNumber == nil) then
        teamNumber = kNeutralTeamType
    end

    if(Server) then
        entity = Server.CreateEntity(mapName, origin)
    elseif(Client) then
        entity = Client.CreateEntity(mapName, origin)
    end
    
    if(entity ~= nil) then
        InitEntity(entity, mapName, origin, teamNumber)
    else
        Shared.Message(string.format("CreateEntity(%s) returned nil.", mapName))
    end
    
    return entity
    
end

-- Here for completeness/orthogonality
function DestroyEntity(entity)
    if(Server) then
        Server.DestroyEntity(entity)
    else
        Shared.Message(string.format("DestroyEntity(%s) called on client, ignoring.", entity:GetMapName()))
    end
end

function Round(num,dp)
  local mult = 10^(dp or 0)
  return math.floor(num * mult + 0.5) / mult
end
