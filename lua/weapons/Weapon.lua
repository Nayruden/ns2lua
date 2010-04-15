--=============================================================================
--
-- RifleRange/Weapon.lua
--
-- Created by Max McGuire (max@unknownworlds.com)
-- Copyright (c) 2010, Unknown Worlds Entertainment, Inc.
--
-- This class is the base class for all weapons the player can hold.
--
--=============================================================================

class 'Weapon' (Actor)

Weapon.networkVars =
    {
    }

Shared.LinkClassToMap( "Weapon", "weapon", Weapon.networkVars )    