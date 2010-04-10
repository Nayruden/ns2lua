//=============================================================================
//
// RifleRange/PlayerSpawn.lua
//
// Created by Max McGuire (max@unknownworlds.com)
// Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
//
//=============================================================================

class 'PlayerSpawn' (Entity)

function PlayerSpawn:OnInit()
    self:SetIsVisible(false)
end

Shared.LinkClassToMap("PlayerSpawn", "player_start")
