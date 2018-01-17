-- API_CanFly.lua
-- Written by Phanx <addons@phanx.net>
-- This file provides a single function addons can call to determine
-- whether the player can actually use a flying mount at present, since
-- the game API function IsFlyableArea is unusable for this purpose.
-- This is free and unencumbered software released into the public domain.
-- Feel free to include this file or code from it in your own addons.

local _, ravMounts = ...
-- TODO: Find out when Wintergrasp isn't flyable? Or too old to bother with?

local flyingSpell = {
    [1116] = 191645, -- Draenor          = Draenor Pathfinder
    [1464] = 191645, -- Tanaan Jungle    = Draenor Pathfinder
    [1191] = -1, -- Ashran - World PvP
    [1265] = -1, -- Tanaan Jungle Intro
}

local GetInstanceInfo, IsFlyableArea, IsSpellKnown = GetInstanceInfo, IsFlyableArea, IsSpellKnown
local IsOnGarrisonMap, IsOnShipyardMap = C_Garrison.IsOnGarrisonMap, C_Garrison.IsOnShipyardMap

function ravMounts.CanFly()
    if IsFlyableArea() then
        local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
        local reqSpell = flyingSpell[instanceMapID]
        if reqSpell then
            return reqSpell > 0 and IsSpellKnown(reqSpell)
        elseif IsOnGarrisonMap() and not IsOnShipyardMap() then
            return IsSpellKnown(191645) -- Draenor Pathfinder
        else
            return IsSpellKnown(34090) or IsSpellKnown(34091) or IsSpellKnown(90265)
        end
    end
end
