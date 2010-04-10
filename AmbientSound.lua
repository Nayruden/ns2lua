// ======= Copyright © 2003-2010, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\AmbientSound.lua
//
//    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'AmbientSound' (Effect)

// Have some network variables here so ents are propagated to client
local networkVars =
{
    eventNameIndex = "integer",
    minFalloff = "float",
    maxFalloff = "float",
    falloffType = "integer (1 to 2)",
    positioning = "integer (1 to 2)",
    volume = "float (0 to 1)",
    pitch = "float"
}

// Read trigger radius and FMOD event name
function AmbientSound:OnLoad()

    Effect.OnLoad(self)

    // Precache sound name and lookup index for it
    Shared.PrecacheSound(self.eventName)
    self.eventNameIndex = Server.GetSoundIndex(self.eventName)
    
    self.minFalloff = self:GetAndCheckValue(self.minFalloff, 0, 1000, "minFalloff", 0)
    self.maxFalloff = self:GetAndCheckValue(self.maxFalloff, 0, 1000, "maxFalloff", 0)
    self.falloffType = self:GetAndCheckValue(self.falloffType, 1, 2, "falloffType", 1)
    self.positioning = self:GetAndCheckValue(self.positioning, 1, 2, "positioning", 1)
    self.volume = self:GetAndCheckValue(self.volume, 0, 1, "volume", 1)
    self.pitch = self:GetAndCheckValue(self.pitch, -4, 4, "pitch", 0)

end

if (Client) then

    // From fmod_event.h and fmod.h
    local kFmod3DSound = 16
    local kFmodLogarithmicRolloff = 1048576
    local kFmodLinearRolloff = 2097152

    local kFmodVolumePropertyIndex = 1
    local kFmodPitchPropertyIndex = 4
    local kFmodRolloffPropertyIndex = 16
    local kFmodMinDistancePropertyIndex = 17
    local kFmodMaxDistancePropertyIndex = 18

    local kFmodPositioningPropertyIndex = 19
    local kFmodWorldRelative = 524288
    local kFmodHeadRelative = 262144

    function AmbientSound:StartPlaying()

        if(not self.playing) then

            // Start playing sound locally only    
            Client.PlayLocalSoundWithIndex(self.eventNameIndex, self:GetOrigin())
            
            local listenerOrigin = self:GetOrigin()
            if(self.positioning == 2) then
                listenerOrigin = Vector(0, 0, 0)
            end
            
            local positioningType = ConditionalValue(self.positioning == 1, kFmodWorldRelative, kFmodHeadRelative)
            Client.SetSoundPropertyInt(listenerOrigin, self.eventNameIndex, kFmodPositioningPropertyIndex, positioningType, true)
           
            // Set extended FMOD property values according to values in ambient sound entity
            Client.SetSoundPropertyInt(listenerOrigin, self.eventNameIndex, kFmodRolloffPropertyIndex, kFmod3DSound, true)
            
            local rolloffType = ConditionalValue(self.falloffType == 1, kFmodLogarithmicRolloff, kFmodLinearRolloff)
            Client.SetSoundPropertyInt(listenerOrigin, self.eventNameIndex, kFmodRolloffPropertyIndex, rolloffType, true)
            
            Client.SetSoundPropertyFloat(listenerOrigin, self.eventNameIndex, kFmodMinDistancePropertyIndex, self.minFalloff, true)
            Client.SetSoundPropertyFloat(listenerOrigin, self.eventNameIndex, kFmodMaxDistancePropertyIndex, self.maxFalloff, true)
            
            Client.SetSoundPropertyFloat(listenerOrigin, self.eventNameIndex, kFmodVolumePropertyIndex, self.volume, true)
            Client.SetSoundPropertyFloat(listenerOrigin, self.eventNameIndex, kFmodPitchPropertyIndex, self.pitch, true)
                
            self.playing = true
            
        end
        
    end

    function AmbientSound:StopPlaying()

        if(self.playing) then
        
            Client.StopLocalSoundWithIndex(self.eventNameIndex, self:GetOrigin())
            self.playing = false
            
        end
        
    end

end

Shared.LinkClassToMap("AmbientSound", "ambient_sound", networkVars)
