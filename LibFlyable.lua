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
    [1669] = -1, -- Argus (mostly OK, few spots are bugged)

    -- Unflyable class halls where IsFlyableArea returns true:
    -- Note some are flyable at the entrance, but not inside;
    -- flying serves no purpose here, so we'll just say no.
    [1519] = -1, -- The Fel Hammer (Demon Hunter)
    [1514] = -1, -- The Wandering Isle (Monk)
    [1469] = -1, -- The Heart of Azeroth (Shaman)
    [1107] = -1, -- Dreadscar Rift (Warlock)
    [1479] = -1, -- Skyhold (Warrior)
}

-- Workaround for bug in patch 7.3.5
local flyableContinents = {
    -- These continents previously required special spells to fly in.
    -- All such spells were removed from the game in patch 7.3.5, but
    -- the IsFlyableArea() API function was not updated accordingly,
    -- and incorrectly returns false on these continents for characters
    -- who did not know the appropriate spell before the patch.
    [  0] = true, -- Eastern Kingdoms (Flight Master's License)
    [  1] = true, -- Kalimdor (Flight Master's License)
    [646] = true, -- Deepholm (Flight Master's License)
    [571] = true, -- Northrend (Cold Weather Flying)
    [870] = true, -- Pandaria (Wisdom of the Four Winds)
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
    -- if not IsFlyableArea() -- Workaround for bug in patch 7.3.5
    if noFlySubzones[GetSubZoneText() or ""] then
        return false
    end

    local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
    local reqSpell = spellForContinent[instanceMapID]
    if reqSpell then
        return reqSpell > 0 and IsSpellKnown(reqSpell)
    end

    -- Workaround for bug in patch 7.3.5
    -- IsFlyableArea() incorrectly reports false in many locations for
    -- characters who did not have a zone-specific flying spell before
    -- the patch (which removed all such spells from the game).
    if not IsFlyableArea() and not flyableContinents[instanceMapID] then
        -- Continent is not affected by the bug. API is correct.
        return false
    end

    return IsSpellKnown(34090) or IsSpellKnown(34091) or IsSpellKnown(90265)
end
