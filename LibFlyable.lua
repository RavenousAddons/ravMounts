-- LibFlyable.lua
-- Written by Phanx <addons@phanx.net>
-- This file provides a single function addons can call to determine
-- whether the player can actually use a flying mount at present, since
-- the game API function IsFlyableArea is unusable for this purpose.
-- This is free and unencumbered software released into the public domain.
-- Feel free to include this file or code from it in your own addons.

local _, ravMounts = ...
-- TODO: Find out when Wintergrasp isn't flyable? Or too old to bother with?

local spellForContinent = {
    -- Continents/instances requiring a spell to fly:
    -- Draenor Pathfinder
    [1116] = 191645, -- Draenor
    [1464] = 191645, -- Tanaan Jungle
    [1152] = 191645, -- FW Horde Garrison Level 1
    [1330] = 191645, -- FW Horde Garrison Level 2
    [1153] = 191645, -- FW Horde Garrison Level 3
    [1154] = 191645, -- FW Horde Garrison Level 4
    [1158] = 191645, -- SMV Alliance Garrison Level 1
    [1331] = 191645, -- SMV Alliance Garrison Level 2
    [1159] = 191645, -- SMV Alliance Garrison Level 3
    [1160] = 191645, -- SMV Alliance Garrison Level 4
    -- Broken Isles Pathfinder
    [1220] = 233368, -- Broken Isles

    -- Unflyable continents/instances where IsFlyableArea returns true:
    [1191] = -1, -- Ashran (PvP)
    [1265] = -1, -- Tanaan Jungle Intro
    [1463] = -1, -- Helheim Exterior Area
    [1500] = -1, -- Broken Shore (scenario for DH Vengeance artifact)
    [1669] = -1, -- Argus (mostly OK, few spots are bugged)

    -- Unflyable class halls where IsFlyableArea returns true:
    -- Note some are flyable at the entrance, but not inside;
    -- flying serves no purpose here, so we'll just say no.
    [1519] = -1, -- The Fel Hammer (Demon Hunter)
    [1514] = -1, -- The Wandering Isle (Monk)
    [1469] = -1, -- The Heart of Azeroth (Shaman)
    [1107] = -1, -- Dreadscar Rift (Warlock)
    [1479] = -1, -- Skyhold (Warrior)

    -- Unflyable island expeditions where IsFlyableArea returns true:
    -- flying serves no purpose here, so we'll just say no.
    [1813] = -1, -- Un'gol Ruins
    [1814] = -1, -- Havenswood
    [1892] = -1, -- Rotting Mire
    [1893] = -1, -- The Dread Chain
    [1883] = -1, -- Whispering Reef
    [1897] = -1, -- Molten Clay
    [1882] = -1, -- Verdant Wilds
    [1879] = -1, -- Jorundall
    [1907] = -1, -- Snowblossom Village
    [2124] = -1, -- Crestfall

    -- Unflyable dungeons where IsFlyableArea returns true:
    -- flying serves no purpose here, so we'll just say no.
    [1763] = -1, -- Atal'dazar

    -- Unflyable Warfronts where IsFlyableArea returns true:
    -- flying serves no purpose here, so we'll just say no.
    [1943] = -1, -- The Battle of Stormgarde

    -- Unflyable Raids where IsFlyableArea returns true:
    -- flying serves no purpose here, so we'll just say no.
    [2169] = -1, -- Uldir: The Oblivion Door

    -- Unflyable Scenarios where IsFlyableArea returns true:
    -- flying serves no purpose here, so we'll just say no.
    [1662] = -1, -- Assault of the Sanctum of Order
}

local noFlySubzones = {
    -- Unflyable subzones where IsFlyableArea() returns true:
    ["Nespirah"] = true, ["Неспира"] = true, ["네스피라"] = true, ["奈瑟匹拉"] = true, ["奈斯畢拉"] = true,
}

----------------------------------------
-- Logic
----------------------------------------

local GetInstanceInfo = GetInstanceInfo
local GetSubZoneText = GetSubZoneText
local IsFlyableArea = IsFlyableArea
local IsSpellKnown = IsSpellKnown

function ravMounts.IsFlyableArea()
    if not IsFlyableArea()
    or noFlySubzones[GetSubZoneText() or ""] then
        return false
    end

    local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
    local reqSpell = spellForContinent[instanceMapID]
    if reqSpell then
        return reqSpell > 0 and IsSpellKnown(reqSpell)
    end

    return IsSpellKnown(34090) or IsSpellKnown(34091) or IsSpellKnown(90265)
end
