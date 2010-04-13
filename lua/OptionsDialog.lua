--=============================================================================
--
-- lua/OptionsDialog.lua
-- 
-- Created by Henry Kropf and Charlie Cleveland
-- Copyright 2010, Unknown Worlds Entertainment
--
--=============================================================================

function BuildDisplayModesList()

    local modes = { }
    local numModes = Main.GetNumDisplayModes()
    
    for modeIndex = 1, numModes do
    
        local xResolution, yResolution = Main.GetDisplayMode(modeIndex)
        modes[modeIndex] = { xResolution = xResolution, yResolution = yResolution }
        
    end

    return modes
    
end

--
-- Get player nickname. Use previously set name if available, otherwise use Steam name, otherwise use "NSPlayer"
--/
function OptionsDialogUI_GetNickname()

    local playerName = Main.GetDefaultPlayerName()
    
    if(playerName == "") then
        playerName = "NsPlayer"
    end
    
    return Main.GetOptionString( kNicknameOptionsKey, playerName )
    
end

--
-- Get mouse sensitivity
-- 0 = min sensitivity
-- 100 = max sensitivity
--/
function OptionsDialogUI_GetMouseSensitivity()
    return Main.GetMouseSensitivity() * kMouseSensitivityScalar
end

--
-- Get linear array of screen resolutions (strings)
--/
function OptionsDialogUI_GetScreenResolutions()

    -- Determine the aspect ratio of the monitor based on the startup resolution.
    -- We use this to flag modes that have the same aspect ratio.
    
    local xResolution, yResolution = Main.GetStartupDisplayMode()
    local nativeAspect = xResolution / yResolution

    local resolutions = { }
    
    for modeIndex = 1, table.maxn(displayModes) do
    
        local mode = displayModes[modeIndex]
        local aspect = mode.xResolution / mode.yResolution
        
        local resolution = string.format('%dx%d', mode.xResolution, mode.yResolution)
        
        if (aspect == nativeAspect) then
            resolution = resolution .. " *"
        end
        
        resolutions[modeIndex] = resolution
        
    end

    return resolutions
    
end

--
-- Get current index for screen res (assuming lua indexing for script convenience)
--/
function OptionsDialogUI_GetScreenResolutionsIndex()

    local xResolution = Main.GetOptionInteger( kGraphicsXResolutionOptionsKey, 1280 )
    local yResolution = Main.GetOptionInteger( kGraphicsYResolutionOptionsKey, 800 )

    for modeIndex = 1, table.maxn(displayModes) do
    
        local mode = displayModes[modeIndex]
        
        if (mode.xResolution == xResolution and mode.yResolution == yResolution) then
            return modeIndex
        end
    
    end
    
    return 1

end

--
-- Get linear array of visual detail settings (strings)
--/
function OptionsDialogUI_GetVisualDetailSettings()
    return { "Ridiculously Awful", "Medium", "High" }
end

--
-- Get current index for detail settings (assuming lua indexing for script convenience)
--/
function OptionsDialogUI_GetVisualDetailSettingsIndex()
    return 1 + Main.GetOptionInteger(kDisplayQualityOptionsKey, 0);
end


--
-- Get sound volume
-- 0 = min volume
-- 100 = max volume
--/
function OptionsDialogUI_GetSoundVolume()
    -- Don't return 100%, sometimes will knock your socks off
    return Main.GetOptionInteger( kSoundVolumeOptionsKey, 75 )
end

--
-- Get music volume
-- 0 = min volume
-- 100 = max volume
--/
function OptionsDialogUI_GetMusicVolume()
    return Main.GetOptionInteger( kMusicVolumeOptionsKey, 65 )
end

--
-- Get all the values from the form
-- nickname - string for nick
-- mouseSens - 0 - 100
-- screenResIdx - 1 - ? index of choice
-- visualDetailIdx - 1 - ? index of choice
-- soundVol - 0 - 100 - sound volume
-- musicVol - 0 - 100 - music volume
-- windowed - true/false run in windowed mode
--/
function OptionsDialogUI_SetValues(nickname, mouseSens, screenResIdx, visualDetailIdx, soundVol, musicVol, windowed)

    Main.SetOptionString( kNicknameOptionsKey, nickname )
    
    Main.SetMouseSensitivity( mouseSens / kMouseSensitivityScalar )
    
    -- Save screen res and visual detail
    Main.SetOptionInteger( kGraphicsXResolutionOptionsKey, displayModes[screenResIdx].xResolution )
    Main.SetOptionInteger( kGraphicsYResolutionOptionsKey, displayModes[screenResIdx].yResolution )
    Main.SetOptionInteger( kDisplayQualityOptionsKey, visualDetailIdx - 1 );  -- set the value as 0-based index;

    -- Save sound and music options 
    Main.SetOptionInteger( kSoundVolumeOptionsKey, soundVol )
    Main.SetOptionInteger( kMusicVolumeOptionsKey, musicVol )
    
    -- Set current levels (0-1)
    Main.SetSoundVolume( soundVol/100 )
    Main.SetMusicVolume( musicVol/100 )
    
    Main.SetOptionBoolean ( kFullscreenOptionsKey, not windowed )
    
    
end

function OptionsDialogUI_OnInit()

    local soundVol = OptionsDialogUI_GetSoundVolume()
    local musicVol = OptionsDialogUI_GetMusicVolume()
    
    -- Set current levels (0-1)
    Main.SetSoundVolume( soundVol/100 )
    Main.SetMusicVolume( musicVol/100 )

end


--
-- Get windowed or not
--/
function OptionsDialogUI_GetWindowed()
    return not Main.GetOptionBoolean( kFullscreenOptionsKey, false )    
end


displayModes = BuildDisplayModesList()

-- Load and set default sound levels
OptionsDialogUI_OnInit()

