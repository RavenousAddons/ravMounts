local ADDON_NAME, ns = ...
local L = ns.L

-- Reference default values and data tables.
local defaults = ns.data.defaults
local mountTypes = ns.data.mountTypes
local mountIDs = ns.data.mountIDs
local mapIDs = ns.data.mapIDs

-- Retrieve Player information.
local _, className = UnitClass("player")
local faction, _ = UnitFactionGroup("player")

-- Set up variables for mount types, conditions, etc.
local flyable, cloneMountID, mapID, inAhnQiraj, inVashjir, inMaw, inDragonIsles, haveGroundMounts, haveFlyingMounts, havePassengerGroundMounts, havePassengerFlyingMounts, haveVendorMounts, haveSwimmingMounts, haveAhnQirajMounts, haveVashjirMounts, haveMawMounts, haveDragonridingMounts, haveChauffeurMounts, haveBroom, normalMountModifier, vendorMountModifier, passengerMountModifier
local ensuredMacroTimeout = 0
local hasSeenNoSpaceMessage = false
local MountListHandlerTimeout = false

-- Key Modifiers.
local modifiers = {"none", "alt", "ctrl", "shift"}

-- Icon Replacement
local tarecgosaMount, _ = GetSpellInfo(407555)
local tarecgosaStaff = C_Item.GetItemNameByID(71086)

-- Shoten API references.
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
        local iter = 10 -- "magic" number
        local n = random(#list)
        while not select(5, CMJ.GetMountInfoByID(list[n])) and iter > 0 do
            n = random(#list)
            iter = iter - 1
        end
        CMJ.SummonByID(list[n])
    end
end

local function GetRandomMountFromList(list)
    local _, spellID = CMJ.GetMountInfoByID(list[random(#list)])
    local mountName, _ = GetSpellInfo(spellID)
    if mountName == tarecgosaMount then
        return tarecgosaStaff
    end
    return mountName
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
    -- Simplify references
    local options = RAV_data.options

    -- Check that we have created the AddOn data object and that we're not
    -- awaiting the timeout
    if RAV_data == nil or MountListHandlerTimeout then
        return
    end
    -- If the above passes, set the timeout
    MountListHandlerTimeout = true
    -- After 1 second, unset the timeout
    C_Timer.After(1, function()
        MountListHandlerTimeout = false
    end)

    -- Determine the Player's location as a Map ID
    mapID = CM.GetBestMapForUnit("player")

    -- Build a list of chosen mounts
    RAV_data.mounts = {}
    RAV_data.mounts.dragonriding = {}
    RAV_data.mounts.flying = {}
    RAV_data.mounts.ground = {}
    RAV_data.mounts.vendor = {}
    RAV_data.mounts.passengerGround = {}
    RAV_data.mounts.passengerFlying = {}
    RAV_data.mounts.swimming = {}
    RAV_data.mounts.ahnqiraj = {}
    RAV_data.mounts.vashjir = {}
    RAV_data.mounts.maw = {}
    RAV_data.mounts.chauffeur = {}
    RAV_data.mounts.travelForm = {}
    RAV_data.mounts.broom = {}
    -- Nazjatar allows some swimming mounts to function as flying mounts
    inNazjatar = contains(mapIDs.nazjatar, mapID)
    -- Loop through the Mount Journal as a series of Mount IDs
    for _, mountID in pairs(CMJ.GetMountIDs()) do
        -- Grab data about the Mount
        local mountName, _, _, _, isUsable, _, isFavorite, _, mountFaction, _, isCollected = CMJ.GetMountInfoByID(mountID)
        local _, _, _, _, mountType = CMJ.GetMountInfoExtraByID(mountID)
        -- Set up some checks that return boolean values about the mount
        local isDragonridingMount = contains(mountIDs.dragonriding, mountID)
        local isFlyingMount = (contains(mountTypes.flying, mountType) and not isSwimmingMount) or (contains(mountTypes.flying, mountType) and isSwimmingMount and options.normalSwimmingMounts)
        local isGroundMount = (contains(mountTypes.ground, mountType) and (not isSwimmingMount or mountType == 412)) or (contains(mountTypes.ground, mountType) and isSwimmingMount and options.normalSwimmingMounts)
        local isSwimmingMount = contains(mountTypes.swimming, mountType)
        local isVendorMount = contains(mountIDs.vendor, mountID)
        local isPassengerGroundMount = contains(mountIDs.passengerGround, mountID)
        local isPassengerFlyingMount = contains(mountIDs.passengerFlying, mountID)
        local isAhnQirajMount = contains(mountTypes.ahnqiraj, mountType)
        local isVashjirMount = contains(mountTypes.vashjir, mountType)
        local isMawMount = contains(mountIDs.maw, mountID)
        local isChauffeurMount = contains(mountTypes.chauffeur, mountType)
        local isFlexMount = contains(mountIDs.flex, mountID)
        -- Cache the result of these functions
        local hasGroundRiding = hasGroundRiding()
        local hasFlyingRiding = hasFlyingRiding()
        -- Begin performing conditional checks against the mount information and
        -- the booleans created above.
        -- Check that the Player has both collected the Mount and that it's
        -- not unavailable to their faction. (0 = Horde & 1 = Alliance)
        if isCollected and not (mountFaction == 0 and faction ~= "Horde") and not (mountFaction == 1 and faction ~= "Alliance") then
            -- Check that the Player has Ground mount training
            if hasGroundRiding then
                -- Dragonriding Mount
                if isDragonridingMount and (isFavorite or not options.normalMounts) then
                    table.insert(RAV_data.mounts.dragonriding, mountID)
                end
                -- Flying Mount
                if isFlyingMount and (isFavorite or not options.normalMounts) and not isVendorMount and not isPassengerFlyingMount and not isPassengerGroundMount then
                    if isFlexMount then
                        -- both or ground
                        if options.flexMounts == 3 or options.flexMounts == 1 then
                            table.insert(RAV_data.mounts.ground, mountID)
                        end
                        -- both or flying
                        if hasFlyingRiding and options.flexMounts == 3 or options.flexMounts == 2 then
                            table.insert(RAV_data.mounts.flying, mountID)
                        end
                    elseif hasFlyingRiding then
                        table.insert(RAV_data.mounts.flying, mountID)
                    end
                end
                -- Ground Mount
                if isGroundMount and (isFavorite or not options.normalMounts) and not isVendorMount and not isPassengerFlyingMount and not isPassengerGroundMount then
                    table.insert(RAV_data.mounts.ground, mountID)
                end
                -- Vendor Mount
                if isVendorMount and (isFavorite or not options.vendorMounts) then
                    table.insert(RAV_data.mounts.vendor, mountID)
                end
                -- Passenger Mount (Flying)
                if hasFlyingRiding and isPassengerFlyingMount and (isFavorite or not options.passengerMounts) then
                    table.insert(RAV_data.mounts.passengerFlying, mountID)
                end
                -- Passenger Mount (Ground)
                if isPassengerGroundMount and (isFavorite or not options.passengerMounts) then
                    table.insert(RAV_data.mounts.passengerGround, mountID)
                end
                -- Swimming Mount
                if isSwimmingMount and (isFavorite or not options.swimmingMounts) then
                    table.insert(RAV_data.mounts.swimming, mountID)
                    if inNazjatar and not contains(mountIDs.noFlyingSwimming, mountID) then
                        table.insert(RAV_data.mounts.flying, mountID)
                    end
                end
                -- Ahn'Qiraj (Zone-Specific)
                if isAhnQirajMount and (isFavorite or not options.zoneSpecificMounts) then
                    table.insert(RAV_data.mounts.ahnqiraj, mountID)
                end
                -- Vashj'ir (Zone-Specific)
                if isVashjirMount and (isFavorite or not options.zoneSpecificMounts) then
                    table.insert(RAV_data.mounts.vashjir, mountID)
                end
                -- The Maw (Zone-Specific)
                if isMawMount and (isFavorite or not options.zoneSpecificMounts) then
                    table.insert(RAV_data.mounts.maw, mountID)
                end
            end
            -- Chauffeur
            if isChauffeurMount then
                table.insert(RAV_data.mounts.chauffeur, mountID)
            end
        end
    end
    -- Treat Passenger (Ground) Mounts as Ground Mounts if none are captured.
    if hasGroundRiding and #RAV_data.mounts.ground == 0 and #RAV_data.mounts.passengerGround > 0 then
        RAV_data.mounts.ground = RAV_data.mounts.passengerGround
    end
    -- Treat Passenger (Flying) Mounts as Flying Mounts if none are captured.
    if hasFlyingRiding and #RAV_data.mounts.flying == 0 and #RAV_data.mounts.passengerFlying > 0 then
        RAV_data.mounts.flying = RAV_data.mounts.passengerFlying
    end
    -- Check for Druid forms
    if className == "DRUID" then
        if IsPlayerSpell(ns.data.travelForms["Travel Form"]) and (IsOutdoors() or IsSubmerged()) then
            table.insert(RAV_data.mounts.travelForm, ns.data.travelForms["Travel Form"])
        elseif IsPlayerSpell(ns.data.travelForms["Cat Form"]) then
            table.insert(RAV_data.mounts.travelForm, ns.data.travelForms["Cat Form"])
        end
    end
    -- Check for Shaman forms
    if className == "SHAMAN" then
        if IsPlayerSpell(ns.data.travelForms["Ghost Wolf"]) then
            table.insert(RAV_data.mounts.travelForm, ns.data.travelForms["Ghost Wolf"])
        end
    end
    -- Check if the Player has the Hallow's End broom in their inventory and
    -- can be used as an instant-cast flying mount.
    local broomName, broomID = GetItemSpell(37011)
    local broomUsable, _ = IsUsableSpell(broomID)
    if (broomUsable) then
        RAV_data.mounts.broom.name = broomName
        for bag=0, NUM_BAG_SLOTS do
            for slot=0, C_Container.GetContainerNumSlots(bag) do
                if 37011 == C_Container.GetContainerItemID(bag, slot) then
                    RAV_data.mounts.broom.bag = bag
                    RAV_data.mounts.broom.slot = slot
                end
            end
        end
    end
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
    -- If in a vehicle, then exit the vehicle
    elseif UnitInVehicle("player") then
        VehicleExit()
        UIErrorsFrame:Clear()
    -- If in travel form, then cancel form
    elseif options.travelForm and ((className == "DRUID" and GetShapeshiftForm() == 3) or (className == "SHAMAN" and GetShapeshiftForm() == 16)) then
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
    elseif inDragonIsles and haveDragonridingMounts then
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
    -- Prevent throttling
    local currentTime = GetServerTime()
    if currentTime < ensuredMacroTimeout then
        return
    end
    ensuredMacroTimeout = currentTime + 2

    -- Simplify references
    local icon = "INV_Misc_QuestionMark"
    local mounts = RAV_data.mounts
    local options = RAV_data.options

    -- Ensure there's space for the macro if it doesn't yet exist
    local numberOfMacros, _ = GetNumMacros()
    if GetMacroIndexByName(ns.name) == 0 and numberOfMacros >= 120 then
        -- Warn the Player once that there isn't space to create the macro
        if not hasSeenNoSpaceMessage then
            hasSeenNoSpaceMessage = true
            ns:PrettyPrint(L.NoMacroSpace)
        end
        return
    end

    -- Ensure the data object exists, the Macro option is enabled, and we're not in combat
    if not RAV_data or not options.macro or UnitAffectingCombat("player") then
        return
    end

    -- Reset global variables
    AssignVariables()

    -- Prepare Mount lists based on conditions
    local dragonriding = (inDragonIsles and haveDragonridingMounts) and mounts.dragonriding or nil
    local flying = haveFlyingMounts and mounts.flying or nil
    local ground = (inAhnQiraj and haveAhnQirajMounts) and mounts.ahnqiraj or haveGroundMounts and mounts.ground or nil
    local passenger = (options.passengerMountModifier ~= 1 and flyable and havePassengerFlyingMounts) and mounts.passengerFlying or (options.passengerMountModifier ~= 1 and havePassengerGroundMounts) and mounts.passengerGround or nil -- any setting except "None"
    local vendor = (options.vendorMountModifier ~= 1 and haveVendorMounts) and mounts.vendor or nil -- any setting except "None"
    local swimming = (inVashjir and haveVashjirMounts) and mounts.vashjir or haveSwimmingMounts and mounts.swimming or nil
    local chauffeur = haveChauffeurMounts and mounts.chauffeur or nil
    local broom = haveBroom and mounts.broom or nil
    local travelForm = (options.travelForm and haveTravelForm) and mounts.travelForm or {}
    local travelFormName = nil
    if travelForm then
        travelFormName, _ = GetSpellInfo(travelForm[1])
    end

    -- Build up the Macro as a string
    local body = "#showtooltip "
    local condition
    if passenger or vendor or swimming or dragonriding or travelForm or broom or flying or ground then
        -- Passenger (Ground & Flying)
        if ListCheck(passenger) then
            body = body .. "[mod:" .. modifiers[options.passengerMountModifier] .. "] " .. GetRandomMountFromList(passenger)
            condition = passenger
        end

        -- Vendor
        if ListCheck(vendor) then
            body = body .. (condition and "; ") .. "[mod:" .. modifiers[options.vendorMountModifier] .. "] " .. GetRandomMountFromList(vendor)
            condition = condition or vendor
        end

        -- Swimming
        if ListCheck(swimming) and not travelForm then
            -- Normal Mount Modifier is set
            if options.normalMountModifier ~= 1 then
                body = body .. (condition and "; ") .. "[swimming,nomod:" .. modifiers[options.normalMountModifier] .. "] " .. GetRandomMountFromList(swimming)
            else
                body = body .. (condition and "; ") .. "[swimming] " .. GetRandomMountFromList(swimming)
            end
            condition = condition or (swimming and not travelForm)
        end

        -- In Dragonriding zone
        if ListCheck(dragonriding) then
            -- Normal Mount Modifier is set
            if options.normalMountModifier ~= 1 then
                if travelForm or broom or ListCheck(flying) then
                    if options.preferDragonRiding then
                        body = body .. (condition and "; ") .. "[swimming,mod:" .. modifiers[options.normalMountModifier] .. "][nomod:" .. modifiers[options.normalMountModifier] .. "] " .. GetRandomMountFromList(dragonriding)
                        body = body .. "; " .. (travelForm and travelFormName or broom and broom or GetRandomMountFromList(flying))
                    else
                        body = body .. (condition and "; ") .. "[swimming,mod:" .. modifiers[options.normalMountModifier] .. "][nomod:" .. modifiers[options.normalMountModifier] .. "] " .. (travelForm and travelFormName or broom and broom or GetRandomMountFromList(flying))
                        body = body .. "; " .. GetRandomMountFromList(dragonriding)
                    end
                elseif ListCheck(ground) or ListCheck(chauffeur) then
                    body = body .. (condition and "; ") .. "[swimming,mod:" .. modifiers[options.normalMountModifier] .. "][nomod:" .. modifiers[options.normalMountModifier] .. "] " .. GetRandomMountFromList(dragonriding)
                    body = body .. "; " .. GetRandomMountFromList(ground or chauffeur)
                end
            else
                if options.preferDragonRiding then
                    body = body .. (condition and "; ") .. GetRandomMountFromList(dragonriding)
                elseif travelForm or broom or ListCheck(flying) then
                    body = body .. (condition and "; ") .. (travelForm and travelFormName or broom and broom or GetRandomMountFromList(flying))
                elseif ListCheck(ground) or ListCheck(chauffeur) then
                    body = body .. (condition and "; ") .. GetRandomMountFromList(ground or chauffeur)
                end
            end
        -- Outside Dragonriding zone
        else
            -- Normal Mount Modifier is set
            if options.normalMountModifier ~= 1 and (travelForm or broom or ListCheck(flying)) and (ListCheck(ground) or ListCheck(chauffeur)) then
                if flyable then
                    body = body .. (condition and "; ") .. "[swimming,mod:" .. modifiers[options.normalMountModifier] .. "][nomod:" .. modifiers[options.normalMountModifier] .. "] " .. (travelForm and travelFormName or broom and broom or GetRandomMountFromList(flying))
                    body = body .. "; " .. GetRandomMountFromList(ground or chauffeur)
                else
                    body = body .. (condition and "; ") .. "[swimming,mod:" .. modifiers[options.normalMountModifier] .. "][nomod:" .. modifiers[options.normalMountModifier] .. "] " .. GetRandomMountFromList(ground or chauffeur)
                    body = body .. "; " .. (travelForm and travelFormName or broom and broom or GetRandomMountFromList(flying))
                end
            else
                if flyable and (travelForm or broom or ListCheck(flying)) then
                    body = body .. (condition and "; ") .. (travelForm and travelFormName or broom and broom or GetRandomMountFromList(flying))
                elseif ListCheck(ground) or ListCheck(chauffeur) then
                    body = body .. (condition and "; ") .. GetRandomMountFromList(ground or chauffeur)
                end
            end
        end
    -- No mounts available, try the Chauffeur
    elseif ListCheck(chauffeur) then
        icon = "inv_misc_key_06"
        body = body .. GetRandomMountFromList(chauffeur)
    end

    -- Shapeshift Forms
    if travelFormName then
        if options.normalMountModifier ~= 1 then
            if ListCheck(dragonriding) and options.preferDragonRiding then
                body = body .. "\n/use [mod:" .. modifiers[options.normalMountModifier] .. "] " .. travelFormName .. "\n/stopmacro [mod:" .. modifiers[options.normalMountModifier] .. "]\n/cancelform"
            else
                body = body .. "\n/use [nomod:" .. modifiers[options.normalMountModifier] .. "] " .. travelFormName .. "\n/stopmacro [nomod:" .. modifiers[options.normalMountModifier] .. "]\n/cancelform"
            end
        else
            body = body .. "\n/use  " .. travelFormName .. "\n/stopmacro\n/cancelform"
        end
    end

    -- Add the AddOn command to the end
    body = body .. "\n/" .. ns.command

    -- Edit the Macro if it exists
    if GetMacroIndexByName(ns.name) > 0 then
        if body ~= RAV_macroBody then
            EditMacro(GetMacroIndexByName(ns.name), ns.name, icon, body)
            RAV_macroBody = body
        end
    -- Otherwise, create a new Macro
    else
        CreateMacro(ns.name, icon, body)
        RAV_macroBody = body
    end

    ensuringMacro = false
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