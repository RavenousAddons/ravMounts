-- API_CanFly.lua
-- Written by Phanx <addons@phanx.net>
-- This file provides a single function addons can call to determine
-- whether the player can actually use a flying mount at present, since
-- the game API function IsFlyableArea is unusable for this purpose.
-- This is free and unencumbered software released into the public domain.
-- Feel free to include this file or code from it in your own addons.

local _, ravMounts = ...
-- TODO: Find out when Wintergrasp isn't flyable? Or too old to bother with?

local flyingSpells = {
    [0]    =  90267, -- Eastern Kingdoms = Flight Master's License
    [1]    =  90267, -- Kalimdor         = Flight Master's License
    [646]  =  90267, -- Deepholm         = Flight Master's License
    [571]  =  54197, -- Northrend        = Cold Weather Flying
    [870]  = 115913, -- Pandaria         = Wisdom of the Four Winds
    [1116] = 191645, -- Draenor          = Draenor Pathfinder
    [1464] = 191645, -- Tanaan Jungle    = Draenor Pathfinder
    [1191] = -1, -- Ashran - World PvP
    [1265] = -1, -- Tanaan Jungle Intro
}

local noFlySubzones = {
    ["Nespirah"] = true, ["Неспира"] = true, ["네스피라"] = true, ["奈瑟匹拉"] = true, ["奈斯畢拉"] = true,
}

local GetInstanceInfo = GetInstanceInfo
local GetSubZoneText = GetSubZoneText
local IsFlyableArea = IsFlyableArea
local IsSpellKnown = IsSpellKnown
local IsOnGarrisonMap = C_Garrison.IsOnGarrisonMap
local IsOnShipyardMap = C_Garrison.IsOnShipyardMap
local IsPlayerInGarrison = C_Garrison.IsPlayerInGarrison

function ravMounts.CanFly()
    if not IsFlyableArea()
    or IsPlayerInGarrison(LE_GARRISON_TYPE_7_0) -- Legion class order hall
    or IsOnGarrisonMap() or IsOnShipyardMap() -- Warlords garrison
    or noFlySubzones[GetSubZoneText() or ""] then
        return false
    end

    local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
    local reqSpell = flyingSpells[instanceMapID]
    if reqSpell then
        return reqSpell > 0 and IsSpellKnown(reqSpell)
    else
        return IsSpellKnown(34090) or IsSpellKnown(34091) or IsSpellKnown(90265)
    end
end
