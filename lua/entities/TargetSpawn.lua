--=============================================================================
--
-- RifleRange/TargetSpawn.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
--
--=============================================================================

class 'TargetSpawn' (Entity)

function TargetSpawn:OnInit()
    self:SetIsVisible(false)
end

Shared.LinkClassToMap("TargetSpawn", "target_spawn", {} )
