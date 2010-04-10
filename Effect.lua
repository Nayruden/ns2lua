// ======= Copyright © 2003-2010, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\Effect.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'Effect' (Actor)

Effect.mapName = "effect"
Effect.networkVars = 
    {
        radius = "float",
        offOnExit = "boolean",
        startsOn = "boolean"
    }

function Effect:OnLoad()

    Actor.OnLoad(self)

    self.radius    = self:GetAndCheckValue(self.radius, 0, 1000, "radius", 0)
    self.offOnExit = self:GetAndCheckBoolean(self.offOnExit, "offOnExit", false)
    self.startsOn  = self:GetAndCheckBoolean(self.startsOn, "startsOn", false)
    
    self.playing = false
    self.triggered = false
    self.startedOn = false
        
end

// Parse number value from editor_setup and emit error if outside expected range
function Effect:GetAndCheckValue(valueString, min, max, valueName, defaultValue)

    local numValue = tonumber(valueString)
    
    if(numValue == nil) then
    
        Shared.Message(string.format("%s:GetAndCheckValue(%s): Value is nil, returning default of %s.", self:GetMapName(), valueName, tostring(defaultValue)))
        numValue = defaultValue
        
    elseif(numValue < min or numValue > max) then
    
        numValue = math.max(math.min(numValue, max), min)
        Shared.Message(string.format("%s.%s - Value is outside expected range (%.2f, %.2f), clamping to %.2f: ", self:GetClassName(), valueName, min, max, numValue))
        
    end
    
    return numValue
    
end

function Effect:GetAndCheckBoolean(valueString, valueName, defaultValue)

    local returnValue = false
    
    if(valueString == nil) then
        Shared.Message(string.format("%s:GetAndCheckBoolean(%s): Value is nil, returning default of %s.", self:GetMapName(), valueName, tostring(defaultValue)))
        returnValue = defaultValue
    elseif(type(valueString) == "string") then
        returnValue = ConditionalValue(string.find(valueString, "true") ~= nil, true, false)
    elseif(type(valueString) == "boolean") then
        returnValue = valueString
    end  
    
    return returnValue
    
end

function Effect:GetRadius()
    return self.radius
end

function Effect:GetOffOnExit()
    return self.offOnExit
end

function Effect:GetStartsOn()
    return self.startsOn
end

if (Client) then

    /**
     * Updates the entity.
     */
    function Effect:UpdateClientEffects(deltaTime)
    
        Actor.UpdateClientEffects(self, deltaTime)

        local player = Client.GetLocalPlayer()
        local origin = player:GetOrigin()
        
        self:Update(origin)        
        
    end

    // Check if effect should be turned on or of
    function Effect:Update(origin)

        if(Client and self:GetStartsOn() and not self.startedOn) then    
        
            self:StartPlaying()
            self.startedOn = true
            
        else

            local distance = (origin - self:GetOrigin()):GetLength()
            
            if(distance < self:GetRadius()) then
            
                self:StartPlaying()
                self.triggered = true
                
            elseif(self:GetOffOnExit() and self.triggered) then
            
                self:StopPlaying()
                
            end
            
        end
        
    end

end

Shared.LinkClassToMap("Effect", Effect.mapName, Effect.networkVars)