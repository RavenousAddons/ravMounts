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
    -- Shadowlands
    [2363] = -1, -- Queen's Conservatory (Night Fae)

    -- Battle for Azeroth Pathfinder
    [1642] = 278833, -- Zandalar
    [1643] = 278833, -- Kul Tiras
    [1718] = 278833, -- Nazjatar

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
    [1879] = -1, -- Jorundall
    [1882] = -1, -- Verdant Wilds
    [1883] = -1, -- Whispering Reef
    [1892] = -1, -- Rotting Mire
    [1893] = -1, -- The Dread Chain
    [1897] = -1, -- Molten Clay
    [1898] = -1, -- Skittering Hollow
    [1907] = -1, -- Snowblossom Village
    [2124] = -1, -- Crestfall

    -- Unflyable Dungeons where IsFlyableArea returns true:
    [1763] = -1, -- Atal'dazar

    -- Unflyable Warfronts where IsFlyableArea returns true:
    [1943] = -1, -- The Battle of Stormgarde
    [1876] = -1, -- Warfronts Arathi - Horde

    -- Unflyable Raids where IsFlyableArea returns true:
    [2169] = -1, -- Uldir: The Oblivion Door

    -- Unflyable Scenarios where IsFlyableArea returns true:
    [1662] = -1, -- Assault of the Sanctum of Order
    [1906] = -1, -- Zandalar Continent Finale
    [1917] = -1, -- Mag'har Scenario

    -- Unflyable Lesser Visions where IsFlyableArea returns true:
    [2275] = -1, -- Vale of Eternal Twilight
}

local noFlySubzones = {
    -- Unflyable subzones where IsFlyableArea() returns true:
    ["Nespirah"] = true,
    ["Неспира"] = true,
    ["네스피라"] = true,
    ["奈瑟匹拉"] = true,
    ["奈斯畢拉"] = true,
}


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
