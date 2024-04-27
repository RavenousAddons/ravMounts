local ADDON_NAME, ns = ...
local L = ns.L

-- Reference default values and data tables.
local defaults = ns.data.defaults
local mountTypes = ns.data.mountTypes
local mountIDs = ns.data.mountIDs
local mapIDs = ns.data.mapIDs

-- Set up variables for mount types, conditions, etc.
local flyable, cloneMountID, mapID, inAhnQiraj, inVashjir, inMaw, haveGroundMounts, haveFlyingMounts, havePassengerGroundMounts, havePassengerFlyingMounts, haveVendorMounts, haveSwimmingMounts, haveAhnQirajMounts, haveVashjirMounts, haveMawMounts, haveDragonridingMounts, haveChauffeurMounts, haveBroom, normalMountModifier, vendorMountModifier, passengerMountModifier
local hasSeenNoSpaceMessage = false
local MountListHandlerTimeout = false

-- Key Modifiers.
local modifiers = {"none", "alt", "ctrl", "shift"}

-- Shorten API references.
local CM = C_Map
local CMJ = C_MountJournal

---
--- Helper Functions
---

-- Check if an element exists in the table.
local function contains(table, input)
    for index, value in ipairs(table) do
        if value == input then
            return index
        end
    end
    return false
end

-- Set default values for options which are not yet set.
local function RegisterDefaultOption(key, value)
    if RAV_data.options[key] == nil then
        RAV_data.options[key] = value
    end
end

-- Check if the Player has the appropriate flying training.
local function hasFlyingRiding()
    for _, spell in ipairs({34090, 34091, 90265}) do
        if IsSpellKnown(spell) then return true end
    end
    return false
end

-- Check if the Player has the appropriate mount training.
local function hasGroundRiding()
    if hasFlyingRiding() then return true end
    for _, spell in ipairs({33388, 33391}) do
        if IsSpellKnown(spell) then return true end
    end
    return false
end

-- Check if an item is in the Player's bags.
local function hasItemInBags()
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, GetContainerNumSlots(bag) do
            if 37011 == GetContainerItemID(bag, slot) then return true end
        end
    end
    return false
end

-- Retrive the name of a Mount given its ID.
local function GetMountName(mountID)
    if not mountID then return nil end

    if mountID == 1727 then
        return C_Item.GetItemNameByID(71086)
    end

    local _, spellID = CMJ.GetMountInfoByID(mountID)
    local mountName, _ = GetSpellInfo(spellID)

    return mountName
end

-- Convert a phrase to Titlecase.
local function TitleCase(phrase)
    local result = string.gsub(phrase, "(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
    return result
end

-- Retrive the Mount ID of the Player's target/focus, based on options.
local function GetCloneMountID()
    -- Simplify references
    local options = RAV_data.options

    if options.clone == 1 or (not UnitIsPlayer("target") and not UnitIsPlayer("focus")) then
        return false
    end

    local clone = false
    if options.clone == 4 then -- both
        clone = UnitIsPlayer("target") and "target" or UnitIsPlayer("focus") and "focus" or false
    elseif options.clone == 2 then -- target
        clone = UnitIsPlayer("target") and "target" or false
    elseif options.clone == 3 then -- focus
        clone = UnitIsPlayer("focus") and "focus" or false
    end

    if clone then
        local i, spellID, mountID
        for i = 1, 40 do
            spellID = select(10, UnitBuff(clone, i, "HELPFUL"))
            if spellID then
                mountID = CMJ.GetMountFromSpell(spellID)
                if mountID then
                    return CMJ.GetMountUsabilityByID(mountID, IsIndoors()) and mountID or false
                end
            end
        end
    end
    return false
end

-- Check a list of mounts for non-emptiness
local function ListCheck(list)
    if list == nil then
        return false
    elseif type(list) == "table" and #list == 0 then
        return false
    end
    return true
end

-- Assign values to global variables. This function fires everytime the values
-- are likely to change.
local function AssignVariables()
    -- Simplify references
    local options = RAV_data.options

    flyable = ns:IsFlyableArea()
    cloneMountID = GetCloneMountID()
    mapID = CM.GetBestMapForUnit("player")
    inAhnQiraj = contains(mapIDs.ahnqiraj, mapID)
    inVashjir = contains(mapIDs.vashjir, mapID)
    inMaw = contains(mapIDs.maw, mapID)
    inDragonIsles = contains(mapIDs.dragonisles, mapID)
    haveGroundMounts = next(RAV_data.mounts.ground) ~= nil and true or false
    haveDragonridingMounts = next(RAV_data.mounts.dragonriding) ~= nil and true or false
    haveFlyingMounts = next(RAV_data.mounts.flying) ~= nil and true or false
    havePassengerGroundMounts = next(RAV_data.mounts.passengerGround) ~= nil and true or false
    havePassengerFlyingMounts = next(RAV_data.mounts.passengerFlying) ~= nil and true or false
    haveVendorMounts = next(RAV_data.mounts.vendor) ~= nil and true or false
    haveSwimmingMounts = next(RAV_data.mounts.swimming) ~= nil and true or false
    haveAhnQirajMounts = next(RAV_data.mounts.ahnqiraj) ~= nil and true or false
    haveVashjirMounts = next(RAV_data.mounts.vashjir) ~= nil and true or false
    haveMawMounts = next(RAV_data.mounts.maw) ~= nil and true or false
    haveChauffeurMounts = next(RAV_data.mounts.chauffeur) ~= nil and true or false
    haveTravelForm = next(RAV_data.mounts.travelForm) ~= nil and true or false
    haveBroom = (RAV_data.mounts.broom ~= nil and RAV_data.mounts.broom.slot ~= nil) and true or false
    normalMountModifier = options.normalMountModifier == 2 and IsAltKeyDown() or options.normalMountModifier == 3 and IsControlKeyDown() or options.normalMountModifier == 4 and IsShiftKeyDown() or false
    vendorMountModifier = options.vendorMountModifier == 2 and IsAltKeyDown() or options.vendorMountModifier == 3 and IsControlKeyDown() or options.vendorMountModifier == 4 and IsShiftKeyDown() or false
    passengerMountModifier = options.passengerMountModifier == 2 and IsAltKeyDown() or options.passengerMountModifier == 3 and IsControlKeyDown() or options.passengerMountModifier == 4 and IsShiftKeyDown() or false
end

-- Summons a random mount from a given list of mounts.
local function MountSummon(list)
    if not UnitAffectingCombat("player") and #list > 0 then
        CMJ.SummonByID(list[random(#list)])
    end
end

---
--- Global Functions
---

-- Format AddOn messages.
function ns:PrettyMessage(message)
    return "|cff" .. ns.color .. ns.name .. ":|r " .. message
end

-- Print an AddOn message.
function ns:PrettyPrint(message)
    DEFAULT_CHAT_FRAME:AddMessage(ns:PrettyMessage(message))
end

-- Set up a data object to keep track of AddOn information.
function ns:SetDefaultSettings()
    if RAV_data == nil then
        RAV_data = {}
    end
    if RAV_data.options == nil then
        RAV_data.options = {}
    end
    if RAV_data.mounts == nil then
        RAV_data.mounts = {}
        RAV_data.mounts.count = 0
    end
    if RAV_data.player == nil then
        RAV_data.player = {}
        local _, className = UnitClass("player")
        RAV_data.player.class = className
        local factionName, _ = UnitFactionGroup("player")
        RAV_data.player.faction = factionName
    end
    for k, v in pairs(defaults) do
        RegisterDefaultOption(k, v)
    end
    RAV_data.data = ns.data
end

-- Open the AddOn Settings page
function ns:OpenSettings()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
    Settings.OpenToCategory(ns.Settings:GetID())
end

-- Send the version to other Players.
function ns:SendVersionUpdate(type)
    local currentTime = GetTime()
    if (RAV_data.updateTimeoutTime) then
        if (currentTime < RAV_data.updateTimeoutTime) then
            return
        end
    end
    RAV_data.updateTimeoutTime = currentTime + ns.data.updateTimeout
    C_ChatInfo.SendAddonMessage(ADDON_NAME, "V:" .. ns.version, type)
end

---
--- Mount-Related Functions
---

-- Builds a list of chosen mounts and sorts them into categories.
function ns:MountListHandler()
    -- Check that we have created the AddOn data object and that we're not
    -- awaiting the timeout
    if RAV_data == nil or MountListHandlerTimeout then
        return
    end

    -- If the above passes, set the timeout
    MountListHandlerTimeout = true
    -- Wait then unset the timeout
    C_Timer.After(1, function()
        MountListHandlerTimeout = false
    end)

    -- Simplify references
    local options = RAV_data.options

    -- Cache the result of these functions
    local hasGroundRiding = hasGroundRiding()
    local hasFlyingRiding = hasFlyingRiding()

    -- Determine the Player's location as a Map ID
    mapID = CM.GetBestMapForUnit("player")

    -- Nazjatar allows some swimming mounts to function as flying mounts
    inNazjatar = contains(mapIDs.nazjatar, mapID)

    -- Build a list of chosen mounts
    local dragonriding = {}
    local flying = {}
    local ground = {}
    local vendor = {}
    local passengerGround = {}
    local passengerFlying = {}
    local swimming = {}
    local aquaticGround = {}
    local aquaticFlying = {}
    local ahnqiraj = {}
    local vashjir = {}
    local maw = {}
    local chauffeur = {}
    local travelForm = {}
    local broom = {}
    -- Loop through the Mount Journal as a series of Mount IDs
    for _, mountID in pairs(CMJ.GetMountIDs()) do
        -- Grab data about the Mount
        local mountName, _, _, _, isUsable, _, isFavorite, _, mountFaction, _, isCollected = CMJ.GetMountInfoByID(mountID)
        local _, _, _, _, mountType = CMJ.GetMountInfoExtraByID(mountID)
        -- Set up some checks that return boolean values about the mount
        local isSwimmingMount = contains(mountTypes.swimming, mountType)
        local isSwimmingFlyingMount = contains(mountTypes.aquaticflying, mountType)
        local isSwimmingGroundMount = contains(mountTypes.aquaticground, mountType)
        local isFlyingMount = (contains(mountTypes.flying, mountType) and not isSwimmingMount) or (contains(mountTypes.flying, mountType) and isSwimmingMount and options.normalSwimmingMounts)
        local isGroundMount = (contains(mountTypes.ground, mountType) and not isSwimmingMount) or (contains(mountTypes.ground, mountType) and isSwimmingMount and options.normalSwimmingMounts)
        local isChauffeurMount = contains(mountTypes.chauffeur, mountType)
        -- Begin performing conditional checks against the mount information and
        -- the booleans created above.
        -- Check that the Player has both collected the Mount and that it's
        -- not unavailable to their faction. (0 = Horde & 1 = Alliance)
        if isCollected and not (mountFaction == 0 and (RAV_data.player and RAV_data.player.faction ~= "Horde")) and not (mountFaction == 1 and (RAV_data.player and RAV_data.player.faction ~= "Alliance")) then
            -- Check that the Player has Ground mount training
            if hasGroundRiding then
                -- Dragonriding Mount
                if contains(mountIDs.dragonriding, mountID) and (isFavorite or not options.normalMounts) then
                    table.insert(dragonriding, mountID)
                end
                -- Flying Mount (excl. Passenger & Vendor)
                if (isFlyingMount or (isSwimmingFlyingMount and options.normalSwimmingMounts)) and (isFavorite or not options.normalMounts) and not contains(mountIDs.vendor, mountID) and not contains(mountIDs.passengerFlying, mountID) and not isPassengerGroundMount then
                    if contains(mountIDs.flex, mountID) then
                        -- Flex: both or ground
                        if options.flexMounts == 3 or options.flexMounts == 1 then
                            table.insert(ground, mountID)
                        end
                        -- Flex: both or flying
                        if hasFlyingRiding and options.flexMounts == 3 or options.flexMounts == 2 then
                            table.insert(flying, mountID)
                        end
                    elseif hasFlyingRiding then
                        table.insert(flying, mountID)
                    end
                end
                -- Ground Mount (excl. Passenger & Vendor)
                if (isGroundMount or (isSwimmingGroundMount and options.normalSwimmingMounts)) and (isFavorite or not options.normalMounts) and not contains(mountIDs.vendor, mountID) and not contains(mountIDs.passengerFlying, mountID) and not contains(mountIDs.passengerGround, mountID) then
                    table.insert(ground, mountID)
                end
                -- Vendor Mount
                if contains(mountIDs.vendor, mountID) and (isFavorite or not options.vendorMounts) then
                    table.insert(vendor, mountID)
                end
                -- Passenger Mount (Flying)
                if hasFlyingRiding and contains(mountIDs.passengerFlying, mountID) and (isFavorite or not options.passengerMounts) then
                    table.insert(passengerFlying, mountID)
                end
                -- Passenger Mount (Ground)
                if contains(mountIDs.passengerGround, mountID) and (isFavorite or not options.passengerMounts) then
                    table.insert(passengerGround, mountID)
                end
                -- Swimming Mount
                if isSwimmingMount and (isFavorite or not options.swimmingMounts) then
                    table.insert(swimming, mountID)
                    if inNazjatar and (isSwimmingMount or isSwimmingFlyingMount) and not contains(mountIDs.noFlyingSwimming, mountID) then
                        table.insert(flying, mountID)
                    end
                end
                -- Aquatic (Flying/Swimming) Mount
                if isSwimmingFlyingMount and (isFavorite or not options.swimmingMounts) then
                    table.insert(swimming, mountID)
                    table.insert(aquaticFlying, mountID)
                end
                -- Aquatic (Ground/Swimming) Mount
                if isSwimmingGroundMount and (isFavorite or not options.swimmingMounts) then
                    table.insert(swimming, mountID)
                    table.insert(aquaticGround, mountID)
                end
                -- Ahn'Qiraj (Zone-Specific)
                if contains(mountTypes.ahnqiraj, mountType) and (isFavorite or not options.zoneSpecificMounts) then
                    table.insert(ahnqiraj, mountID)
                end
                -- Vashj'ir (Zone-Specific)
                if contains(mountTypes.vashjir, mountType) and (isFavorite or not options.zoneSpecificMounts) then
                    table.insert(vashjir, mountID)
                end
                -- The Maw (Zone-Specific)
                if contains(mountIDs.maw, mountID) and (isFavorite or not options.zoneSpecificMounts) then
                    table.insert(maw, mountID)
                end
            end
            -- Chauffeur
            if isChauffeurMount then
                table.insert(chauffeur, mountID)
            end
        end
    end
    -- Treat Passenger (Ground) Mounts as Ground Mounts if none are captured.
    if hasGroundRiding and #ground == 0 and #passengerGround > 0 then
        ground = passengerGround
    end
    -- Treat Passenger (Flying) Mounts as Flying Mounts if none are captured.
    if hasFlyingRiding and #flying == 0 and #passengerFlying > 0 then
        flying = passengerFlying
    end
    -- Check for Druid forms
    if RAV_data.player and RAV_data.player.class == "DRUID" then
        if IsPlayerSpell(ns.data.travelForms["Travel Form"]) and (IsOutdoors() or IsSubmerged()) then
            table.insert(travelForm, ns.data.travelForms["Travel Form"])
        elseif IsPlayerSpell(ns.data.travelForms["Cat Form"]) then
            table.insert(travelForm, ns.data.travelForms["Cat Form"])
        end
    end
    -- Check for Shaman forms
    if RAV_data.player and RAV_data.player.class == "SHAMAN" then
        if IsPlayerSpell(ns.data.travelForms["Ghost Wolf"]) then
            table.insert(travelForm, ns.data.travelForms["Ghost Wolf"])
        end
    end
    -- Check if the Player has the Hallow's End broom in their inventory and
    -- can be used as an instant-cast flying mount.
    local broomName, broomID = GetItemSpell(37011)
    local broomUsable, _ = IsUsableSpell(broomID)
    if (broomUsable) then
        broom.name = broomName
        for bag=0, NUM_BAG_SLOTS do
            for slot=0, C_Container.GetContainerNumSlots(bag) do
                if 37011 == C_Container.GetContainerItemID(bag, slot) then
                    broom.bag = bag
                    broom.slot = slot
                end
            end
        end
    end
    -- Tidy up ground mount by removing Flying/Aquatic and Ground/Aquatic types
    -- if others exist in Flying or Ground lists
    if #flying == 0 and #aquaticFlying > 0 then
        flying = aquaticFlying
    end
    if #ground == 0 and #aquaticGround > 1 then
        ground = aquaticGround
    end

    -- Update the player cache
    RAV_data.mounts.dragonriding = dragonriding
    RAV_data.mounts.flying = flying
    RAV_data.mounts.ground = ground
    RAV_data.mounts.vendor = vendor
    RAV_data.mounts.passengerGround = passengerGround
    RAV_data.mounts.passengerFlying = passengerFlying
    RAV_data.mounts.swimming = swimming
    RAV_data.mounts.ahnqiraj = ahnqiraj
    RAV_data.mounts.vashjir = vashjir
    RAV_data.mounts.maw = maw
    RAV_data.mounts.chauffeur = chauffeur
    RAV_data.mounts.travelForm = travelForm
    RAV_data.mounts.broom = broom
    RAV_data.mounts.count = #dragonriding + #flying + #ground + #vendor + #passengerGround + #passengerFlying + #swimming + #ahnqiraj + #vashjir + #maw + #chauffeur + #travelForm + #broom
end

-- Summon a mount from a particular list based on world and/or Player conditions.
function ns:MountUpHandler(specificType)
    -- Simplify references
    local mounts = RAV_data.mounts
    local options = RAV_data.options

    -- Uses the in-game Interface Setting "Controls" → "Auto Dismount in Flight"
    if IsFlying() and GetCVar("autoDismountFlying") == "0" then
        return
    end

    AssignVariables()

    -- Check for specific types
    if (specificType:match("vend") or specificType:match("repair") or specificType:match("trans") or specificType:match("mog")) and haveVendorMounts then
        MountSummon(mounts.vendor)
    elseif (specificType:match("2") or specificType:match("two") or specificType:match("multi") or specificType:match("passenger")) and havePassengerFlyingMounts and flyable then
        MountSummon(mounts.passengerFlying)
    elseif specificType:match("fly") and (specificType:match("2") or specificType:match("two") or specificType:match("multi") or specificType:match("passenger")) and havePassengerFlyingMounts then
        MountSummon(mounts.passengerFlying)
    elseif (specificType:match("2") or specificType:match("two") or specificType:match("multi") or specificType:match("passenger")) and havePassengerGroundMounts then
        MountSummon(mounts.passengerGround)
    elseif specificType:match("swim") and haveSwimmingMounts then
        MountSummon(mounts.swimming)
    elseif (specificType == "vj" or specificType:match("vash") or specificType:match("jir")) and haveVashjirMounts then
        MountSummon(mounts.vashjir)
    elseif specificType:match("fly") and haveFlyingMounts then
        MountSummon(mounts.flying)
    elseif (specificType == "aq" or specificType:match("ahn") or specificType:match("qiraj")) and haveAhnQirajMounts then
        MountSummon(mounts.ahnqiraj)
    elseif specificType:match("maw") and haveMawMounts then
        MountSummon(mounts.maw)
    elseif (specificType == "df" or specificType == "di" or specificType == "dr" or specificType:match("dragon")) and haveDragonridingMounts then
        MountSummon(mounts.dragonriding)
    elseif specificType == "ground" and haveGroundMounts then
        MountSummon(mounts.ground)
    elseif specificType == "chauffeur" and haveChauffeurMounts then
        MountSummon(mounts.chauffeur)
    elseif (specificType == "copy" or specificType == "clone") and cloneMountID then
        CMJ.SummonByID(cloneMountID)
    -- Check for /mountspecial modifiers
    elseif vendorMountModifier and passengerMountModifier and (IsMounted() or UnitInVehicle("player")) then
        DoEmote(EMOTE171_TOKEN)
    -- If mounted, then dismount
    elseif IsMounted() then
        Dismount()
        UIErrorsFrame:Clear()
        ns:MountListHandler()
    -- If in a vehicle, then exit the vehicle
    elseif UnitInVehicle("player") then
        VehicleExit()
        UIErrorsFrame:Clear()
    -- If in travel form, then cancel form
    elseif options.travelForm and ((RAV_data.player.class == "DRUID" and GetShapeshiftForm() == 3) or (RAV_data.player.class == "SHAMAN" and GetShapeshiftForm() == 16)) then
        CancelShapeshiftForm()
        UIErrorsFrame:Clear()
    -- Clone
    elseif options.clone ~= 1 and cloneMountID and not normalMountModifier and not vendorMountModifier and not passengerMountModifier then
        CMJ.SummonByID(cloneMountID)
    -- Vendor Mounts through Modifier Key
    elseif vendorMountModifier and haveVendorMounts then
        MountSummon(mounts.vendor)
    -- Passenger Mounts through Modifier Key
    elseif havePassengerFlyingMounts and flyable and passengerMountModifier and not normalMountModifier then
        MountSummon(mounts.passengerFlying)
    elseif havePassengerGroundMounts and passengerMountModifier and (not flyable or (flyable and normalMountModifier)) then
        MountSummon(mounts.passengerGround)
    -- Vashj'ir
    elseif inVashjir and haveVashjirMounts and IsSwimming() and not normalMountModifier then
        MountSummon(mounts.vashjir)
    -- Swimming
    elseif haveSwimmingMounts and IsSwimming() and not normalMountModifier then
        MountSummon(mounts.swimming)
    -- Dragonriding
    elseif flyable and haveDragonridingMounts then
        -- normalMountModifier is implied by hitting IsSwimming() here
        if IsSwimming() then
            if options.preferDragonRiding or (not haveBroom and not haveFlyingMounts) then
                MountSummon(mounts.dragonriding)
            else
                MountSummon(mounts.flying)
            end
        else
            if (options.preferDragonRiding and not normalMountModifier) or (not options.preferDragonRiding and normalMountModifier) or (not haveBroom and not haveFlyingMounts) then
                MountSummon(mounts.dragonriding)
            else
                MountSummon(mounts.flying)
            end
        end
    -- Flying
    elseif (haveBroom or haveFlyingMounts) and ((flyable and not normalMountModifier) or ((not flyable or IsSwimming()) and normalMountModifier)) then
        MountSummon(mounts.flying)
    -- Ahn'Qiraj
    elseif inAhnQiraj and haveAhnQirajMounts then
        MountSummon(mounts.ahnqiraj)
    -- Ground
    elseif haveGroundMounts then
        MountSummon(mounts.ground)
    -- Flying (checked again in case there are neither Ground nor Passenger (Ground) Mounts)
    elseif haveFlyingMounts then
        MountSummon(mounts.flying)
    -- Chauffeur
    elseif haveChauffeurMounts then
        MountSummon(mounts.chauffeur)
    -- Error out by providing a message to the user about adding Favorites.
    else
        ns:PrettyPrint(_G.MOUNT_JOURNAL_NO_VALID_FAVORITES)
    end
end

function ns:EnsureMacro()
    -- Simplify references
    local icon = "INV_Misc_QuestionMark"
    local mounts = RAV_data.mounts
    local options = RAV_data.options

    -- Unable to create/modify the macro without data or whilst the Player is in combat
    if not RAV_data or not RAV_data.mounts.count or not options.macro or UnitAffectingCombat("player") then
        return
    end

    -- Reset global variables
    AssignVariables()

    -- Prepare Mount lists based on conditions
    local dragonriding = (flyable and haveDragonridingMounts) and mounts.dragonriding or nil
    local flying = haveFlyingMounts and mounts.flying or nil
    local ground = (inAhnQiraj and haveAhnQirajMounts) and mounts.ahnqiraj or haveGroundMounts and mounts.ground or nil
    local vendor = haveVendorMounts and mounts.vendor or nil
    local passenger = (flyable and havePassengerFlyingMounts) and mounts.passengerFlying or havePassengerGroundMounts and mounts.passengerGround or nil
    local swimming = (inVashjir and haveVashjirMounts) and mounts.vashjir or haveSwimmingMounts and mounts.swimming or nil
    local chauffeur = haveChauffeurMounts and mounts.chauffeur or nil
    local travelForm = haveTravelForm and mounts.travelForm or nil
    local broom = haveBroom and mounts.broom or nil

    -- This part is tricky because we build the macro backwards
    local body = "/" .. ns.command
    if broom and RAV_data.player.class ~= "DRUID" then
        body = "/use [swimming,mod:" .. modifiers[options.normalMountModifier] .. "][nomod,nomounted] " .. broom.name .. "\n/stopmacro [swimming,mod:" .. modifiers[options.normalMountModifier] .. "][nomod,nomounted]\n" .. body
    end
    if RAV_data.player and (RAV_data.player.class == "DRUID" or RAV_data.player.class == "SHAMAN") then
        body = "/cancelform\n" .. body
    end
    local mountName
    if dragonriding or flying or broom or ground or chauffeur or vendor or passenger or swimming or (options.travelForm and travelForm) then
        body = "\n" .. body
        if (options.travelForm and travelForm) then
            local travelFormName, _ = GetSpellInfo(travelForm[1])
            if options.normalMountModifier ~= 1 then -- none
                if flyable and haveDragonridingMounts and options.preferDragonRiding then
                    mountName = GetMountName(dragonriding[random(#dragonriding)])
                    body = "[mod:" .. modifiers[options.normalMountModifier] .. "] " .. travelFormName .. "; " .. mountName .. "\n" .. "/use [mod:" .. modifiers[options.normalMountModifier] .. "] " .. travelFormName .. "\n" .. "/stopmacro [mod:" .. modifiers[options.normalMountModifier] .. "]" .. body
                else
                    body = travelFormName .. "\n" .. "/use [nomod] " .. travelFormName .. "\n" .. "/stopmacro [nomod]" .. body
                    if broom or flying or ground or chauffeur then
                        mountName = broom and broom.name or flying and GetMountName(flying[random(#flying)]) or ground and GetMountName(ground[random(#ground)]) or chauffeur and GetMountName(chauffeur[random(#chauffeur)]) or nil
                        if not mountName then
                            ns:EnsureMacro()
                            return
                        end
                    end
                    if mountName then
                        body = "[mod:" .. modifiers[options.normalMountModifier] .. "] " .. mountName .. "; " .. body
                    end
                end
            else
                body = travelFormName .. "\n" .. "/use " .. travelFormName
            end
        else
            if not broom and ground then
                mountName = (flyable and haveDragonridingMounts) and (options.preferDragonRiding and GetMountName(flying[random(#flying)]) or GetMountName(dragonriding[random(#dragonriding)])) or GetMountName(ground[random(#ground)])
                if not mountName then
                    ns:EnsureMacro()
                    return
                end
                body = mountName .. body
            end
            if broom or dragonriding or flying then
                mountName = broom and broom.name or dragonriding and GetMountName(dragonriding[random(#dragonriding)]) or GetMountName(flying[random(#flying)])
                if not mountName then
                    ns:EnsureMacro()
                    return
                end
                if broom then
                    body = broom.name .. "; " .. body
                elseif flyable and ground then
                    if options.normalMountModifier ~= 1 then -- none
                        body = "[swimming,mod:" .. modifiers[options.normalMountModifier] .. "][nomod:" .. modifiers[options.normalMountModifier] .. "] " .. mountName .. "; " .. body
                    else
                        body = "[] " .. mountName .. "; " .. body
                    end
                elseif ((flyable and haveDragonridingMounts) or ground) and options.normalMountModifier ~= 1 then -- none
                    body = "[noswimming,mod:" .. modifiers[options.normalMountModifier] .. "] " .. mountName .. "; " .. body
                else
                    body = mountName .. body
                end
            end
            if chauffeur and ground == nil and dragonriding == nil and flying == nil then
                icon = "inv_misc_key_06"
                mountName, _ = CMJ.GetMountInfoByID(chauffeur[1])
                body = mountName .. body
            end
        end
        if swimming and travelForm == nil then
            _, spellID = CMJ.GetMountInfoByID(swimming[random(#swimming)])
            mountName, _ = GetSpellInfo(spellID)
            if options.normalMountModifier ~= 1 then -- none
                body = "[swimming,nomod:" .. modifiers[options.normalMountModifier] .. "] " .. mountName .. ((dragonriding or flying or ground or chauffeur) and "; " or "") .. body
            else
                body = "[swimming] " .. mountName .. ((dragonriding or flying or ground or chauffeur) and "; " or "") .. body
            end
        end
        if vendor and options.vendorMountModifier ~= 1 then -- none
            _, spellID = CMJ.GetMountInfoByID(vendor[random(#vendor)])
            mountName, _ = GetSpellInfo(spellID)
            body = "[mod:" .. modifiers[options.vendorMountModifier] .. "] " .. mountName .. ((dragonriding or flying or ground or chauffeur or swimming) and "; " or "") .. body
        end
        if passenger and options.passengerMountModifier ~= 1 then -- none
            _, spellID = CMJ.GetMountInfoByID(passenger[random(#passenger)])
            mountName, _ = GetSpellInfo(spellID)
            body = "[mod:" .. modifiers[options.passengerMountModifier] .. "] " .. mountName .. ((dragonriding or flying or ground or chauffeur or swimming or vendor) and "; " or "") .. body
        end
        body = "#showtooltip " .. body
    end

    local numberOfMacros, _ = GetNumMacros()
    if GetMacroIndexByName(ns.name) > 0 then
        EditMacro(GetMacroIndexByName(ns.name), ns.name, icon, body)
        RAV_macroBody = body
    elseif numberOfMacros < 120 then
        CreateMacro(ns.name, icon, body)
        RAV_macroBody = body
    elseif not hasSeenNoSpaceMessage then
        hasSeenNoSpaceMessage = true
        ns:PrettyPrint(L.NoMacroSpace)
    end
end

function ns:AttachTooltipLabels()
    -- Simplify references
    local options = RAV_data.options

    local function callback(tooltip, data)
        if tooltip == GameTooltip then
            -- type 10 yields mount IDs, from the mount journal
            if data.type == 10 then
                local identified = false
                for type, mountIDs in pairs(mountIDs) do
                    if contains(mountIDs, data.id) then
                        tooltip:AddLine(ns:PrettyMessage(TitleCase(type):gsub("Ahnqiraj", "Ahn'Qiraj"):gsub("Vashjir", "Vash'jir"):gsub("Passengerground", "Passenger (Ground)"):gsub("Passengerflying", "Passenger (Flying)"):gsub("Noflyingswimming", "Swimming"):gsub("Flex", options.flexMounts == 3 and "Flex (Ground & Flying)" or options.flexMounts == 2 and "Flex (Flying)" or "Flex (Ground)"):gsub("Maw", "The Maw"):gsub("Dragonisles", "Dragonriding")))
                        identified = true
                    end
                end
                if not identified then
                    local _, _, _, _, mountType = CMJ.GetMountInfoExtraByID(data.id)
                    for type, mountTypes in pairs(mountTypes) do
                        if contains(mountTypes, mountType) then
                            tooltip:AddLine(ns:PrettyMessage(TitleCase(type)))
                        end
                    end
                end
            end
        end
    end

    TooltipDataProcessor.AddTooltipPostCall("ALL", callback)
end

function ns:MountIdentifier()
    local i, spellID, mountID
    for i = 1, 40 do
        spellID = select(10, UnitBuff("player", i, "HELPFUL"))
        if spellID then
            mountID = CMJ.GetMountFromSpell(spellID)
            if mountID then
                local mountTypeString
                for type, mountIDs in pairs(ns.data.mountIDs) do
                    if contains(mountIDs, mountID) then
                        mountTypeString = type
                    end
                end
                if not mountTypeString then
                    local _, _, _, _, mountType = CMJ.GetMountInfoExtraByID(mountID)
                    for type, mountTypes in pairs(mountTypes) do
                        if contains(mountTypes, mountType) then
                            mountTypeString = type
                        end
                    end
                end
                ns:PrettyPrint("Mount ID: " .. mountID .. " | Type: " .. mountTypeString .. " | Spell ID: " .. spellID)
                return
            end
        end
    end
end