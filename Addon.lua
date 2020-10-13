---
-- Ravenous Mounts
--   Chooses the best Mount for the job, with no configuration or set-up; it's
--   all based on your Mount Journal Favorites. Includes any and all available
--   Ground, Flying, Swimming, Vendor, Passenger, and Special Zone Mounts!
-- Author: waldenp0nd
-- License: Public Domain
-- https://github.com/waldenp0nd/ravMounts
-- http://www.wowinterface.com/downloads/info24005-RavenousMounts.html
-- https://mods.curse.com/addons/wow/ravmounts
---
local _, ravMounts = ...
ravMounts.version = "1.9.5"

-- DEFAULTS
-- These are only applied when the AddOn is first loaded.
-- From there values are loaded from RAV_ values stored in your WTF folder.
local defaults = {
    INCLUDE_VENDOR_MOUNTS =       true,
    INCLUDE_PASSENGER_MOUNTS =    true,
    INCLUDE_WATERWALKING_MOUNTS = true,
    INCLUDE_SWIMMING_MOUNTS =     true,
    INCLUDE_FLEX_MOUNTS =         true
}

-- Special formatting for messages
function ravMounts.prettyPrint(message, full)
    if not full then
        full = false
    else
        message = message..":"
    end
    local prefix = "\124cff759ab3Ravenous Mounts "..ravMounts.version..(full and " " or ":\124r ")
    DEFAULT_CHAT_FRAME:AddMessage(prefix..message)
end

-- Simplify mount summoning syntax
local function mountSummon(list)
    if not UnitAffectingCombat("player") then
        C_MountJournal.SummonByID(list[random(#list)])
    end
end

-- Check if floating
-- Thanks to DJharris71 (http://www.wowinterface.com/forums/member.php?userid=301959)
local function IsFloating()
    local B, b, _, _, a = "BREATH", GetMirrorTimerInfo(2)
    return (IsSwimming() and (not (b==B) or (b==B and a > -1)))
end

-- Get the mount being used by the target (if they're a Player)
-- Thanks to DJharris71 (http://www.wowinterface.com/forums/member.php?userid=301959)
local function GetTargetMount()
    local id = false
    if UnitIsPlayer("target") then
        for buffIndex = 1, 40 do
            for mountIndex = 1, table.maxn(RAV_allMountsByName) do
                if UnitBuff("target", buffIndex) == RAV_allMountsByName[mountIndex] then
                    id = RAV_allMountsByID[mountIndex];
                end
            end
        end
    end
    return id
end

-- Collect Data and Sort it
function ravMounts.mountListHandler()
    -- Reset the global variables to be populated later
    RAV_flyingMounts = {}
    RAV_groundMounts = {}
    RAV_vendorMounts = {}
    RAV_passengerFlyingMounts = {}
    RAV_passengerGroundMounts = {}
    RAV_waterwalkingMounts = {}
    RAV_swimmingMounts = {}
    RAV_vashjirMounts = {}
    RAV_ahnQirajMounts = {}
    RAV_chauffeurMounts = {}
    RAV_allMountsByName = {}
    RAV_allMountsByID = {}
    RAV_includeVendorMounts = (RAV_includeVendorMounts == nil and defaults.INCLUDE_VENDOR_MOUNTS or RAV_includeVendorMounts)
    RAV_includePassengerMounts = (RAV_includePassengerMounts == nil and defaults.INCLUDE_PASSENGER_MOUNTS or RAV_includePassengerMounts)
    RAV_includeWaterwalkingMounts = (RAV_includeWaterwalkingMounts == nil and defaults.INCLUDE_WATERWALKING_MOUNTS or RAV_includeWaterwalkingMounts)
    RAV_includeSwimmingMounts = (RAV_includeSwimmingMounts == nil and defaults.INCLUDE_SWIMMING_MOUNTS or RAV_includeSwimmingMounts)
    RAV_includeFlexMounts = (RAV_includeFlexMounts == nil and defaults.INCLUDE_FLEX_MOUNTS or RAV_includeFlexMounts)

    -- Let's start looping over our Mount Journal adding Mounts to their
    -- respective groups
    local isFlyingMount, isGroundMount, isVendorMount, isPassengerFlyingMount, isPassengerGroundMount, isWaterwalkingMount, isSwimmingMount, isVashjirMount, isAhnQirajMount, isChauffeurMount, isSpecialType, isFlexMount
    for mountIndex, mountID in pairs(C_MountJournal.GetMountIDs()) do
        local mountName, spellID, _, _, isUsable, _, isFavorite, _, _, hiddenOnCharacter, isCollected = C_MountJournal.GetMountInfoByID(mountID)
        local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
        isFlyingMount = (mountType == 247 or mountType == 248)
        isGroundMount = (mountType == 230)
        isVendorMount = (spellID == 61425 or spellID == 61447 or spellID == 122708 or spellID == 264058)
        isPassengerFlyingMount = (spellID == 93326 or spellID == 121820 or spellID == 75973 or spellID == 245723 or spellID == 245725 or spellID == 261395)
        isPassengerGroundMount = (spellID == 60424 or spellID == 55531 or spellID == 61465 or spellID == 61467 or spellID == 61469 or spellID == 61470)
        isWaterwalkingMount = (mountType == 269)
        isSwimmingMount = (mountType == 231 or mountType == 254 or spellID == 214791 or spellID == 228919)
        isVashjirMount = (mountType == 232)
        isAhnQirajMount = (mountType == 241)
        isChauffeurMount = (mountType == 284)
        isSpecialType = (isVendorMount or isPassengerFlyingMount or isPassengerGroundMount or isWaterwalkingMount)
        isFlexMount = (mountID == 376 or mountID == 532 or mountID == 594 or mountID == 219 or mountID == 547 or mountID == 468 or mountID == 363 or mountID == 457 or mountID == 451 or mountID == 455 or mountID == 458 or mountID == 456 or mountID == 522 or mountID == 459 or mountID == 523 or mountID == 439 or mountID == 593 or mountID == 421 or mountID == 764 or spellID == 290133)
        if isCollected and isUsable and not hiddenOnCharacter then
            table.insert(RAV_allMountsByName, mountName)
            table.insert(RAV_allMountsByID, mountID)
            if isFlyingMount and not isSpecialType and isFavorite then
                if RAV_includeFlexMounts and isFlexMount then
                    table.insert(RAV_groundMounts, mountID)
                else
                    table.insert(RAV_flyingMounts, mountID)
                end
            end
            if isGroundMount and not isSpecialType and isFavorite then
                table.insert(RAV_groundMounts, mountID)
            end
            if isVendorMount then
                if RAV_includeVendorMounts then
                    table.insert(RAV_vendorMounts, mountID)
                    if isFavorite then
                        table.insert(RAV_groundMounts, mountID)
                    end
                elseif not RAV_includeVendorMounts and isFavorite then
                    table.insert(RAV_vendorMounts, mountID)
                end
            end
            if isPassengerFlyingMount then
                if RAV_includePassengerMounts then
                    table.insert(RAV_passengerFlyingMounts, mountID)
                    if isFavorite then
                        table.insert(RAV_flyingMounts, mountID)
                    end
                elseif not RAV_includePassengerMounts and isFavorite then
                    table.insert(RAV_passengerFlyingMounts, mountID)
                end
            end
            if isPassengerGroundMount then
                if RAV_includePassengerMounts then
                    table.insert(RAV_passengerGroundMounts, mountID)
                    if isFavorite then
                        table.insert(RAV_groundMounts, mountID)
                    end
                elseif not RAV_includePassengerMounts and isFavorite then
                    table.insert(RAV_passengerGroundMounts, mountID)
                end
            end
            if isWaterwalkingMount then
                if RAV_includeWaterwalkingMounts then
                    table.insert(RAV_waterwalkingMounts, mountID)
                    if isFavorite then
                        table.insert(RAV_groundMounts, mountID)
                    end
                elseif not RAV_includeWaterwalkingMounts and isFavorite then
                    table.insert(RAV_waterwalkingMounts, mountID)
                end
            end
            if isSwimmingMount then
                if RAV_includeSwimmingMounts
                or not RAV_includeSwimmingMounts and isFavorite then
                    table.insert(RAV_swimmingMounts, mountID)
                end
            end
            if isVashjirMount then
                table.insert(RAV_vashjirMounts, mountID)
            end
            if isAhnQirajMount then
                table.insert(RAV_ahnQirajMounts, mountID)
            end
            if isChauffeurMount then
                table.insert(RAV_chauffeurMounts, mountID)
            end
        end
    end
end

-- Check a plethora of conditions and choose the appropriate Mount from the
-- Mount Journal, and do nothing if conditions are not met
function ravMounts.mountUpHandler(specificType)
    -- Simplify the appearance of the logic later by casting our checks to
    -- simple variables
    local mounted = IsMounted()
    local inVehicle = UnitInVehicle("player")
    local flyable = ravMounts.IsFlyableArea()
    local submerged = (IsSwimming() and not IsFloating())
    local floating = (IsSwimming())
    local mapID = C_Map.GetMapInfo(1)
    local inVashjir = ((mapID == 610 or mapID == 613 or mapID == 614 or mapID == 615) and true or false)
    local inAhnQiraj = ((mapID == 717 or mapID == 766) and true or false)
    local shiftKey = IsShiftKeyDown()
    local controlKey = IsControlKeyDown()
    local altKey = IsAltKeyDown()
    local haveFlyingMounts = (next(RAV_flyingMounts) ~= nil and true or false)
    local haveGroundMounts = (next(RAV_groundMounts) ~= nil and true or false)
    local haveVendorMounts = (next(RAV_vendorMounts) ~= nil and true or false)
    local havePassengerFlyingMounts = (next(RAV_passengerFlyingMounts) ~= nil and true or false)
    local havePassengerGroundMounts = (next(RAV_passengerGroundMounts) ~= nil and true or false)
    local haveWaterwalkingMounts = (next(RAV_waterwalkingMounts) ~= nil and true or false)
    local haveSwimmingMounts = (next(RAV_swimmingMounts) ~= nil and true or false)
    local haveVashjirMounts = (next(RAV_vashjirMounts) ~= nil and true or false)
    local haveAhnQirajMounts = (next(RAV_ahnQirajMounts) ~= nil and true or false)
    local haveChauffeurMounts = (next(RAV_chauffeurMounts) ~= nil and true or false)
    local targetMountID = GetTargetMount()

    -- Specific Mounts
    if (string.match(specificType, "vend") or string.match(specificType, "repair") or string.match(specificType, "trans") or string.match(specificType, "mog")) and haveVendorMounts then
        mountSummon(RAV_vendorMounts)
    elseif string.match(specificType, "fly") and (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "multi") or string.match(specificType, "passenger")) and havePassengerFlyingMounts then
        mountSummon(RAV_passengerFlyingMounts)
    elseif (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "multi") or string.match(specificType, "passenger")) and havePassengerGroundMounts then
        mountSummon(RAV_passengerGroundMounts)
    elseif string.match(specificType, "swim") and haveSwimmingMounts then
        mountSummon(RAV_swimmingMounts)
    elseif string.match(specificType, "waterwalk") and haveWaterwalkingMounts then
        mountSummon(RAV_waterwalkingMounts)
    elseif string.match(specificType, "fly") and haveFlyingMounts then
        mountSummon(RAV_flyingMounts)
    elseif specificType == "ground" and haveGroundMounts then
        mountSummon(RAV_groundMounts)
    elseif specificType == "chauffeur" and haveChauffeurMounts then
        mountSummon(RAV_chauffeurMounts)
    elseif (specificType == "aq" or string.match(specificType, "ahn") or string.match(specificType, "qiraj")) and haveAhnQirajMounts then
        mountSummon(RAV_ahnQirajMounts)
    elseif (specificType == "vj" or string.match(specificType, "vash") or string.match(specificType, "jir")) and haveVashjirMounts then
        mountSummon(RAV_vashjirMounts)
    elseif (specificType == "copy" or specificType == "clone") and targetMountID then
        C_MountJournal.SummonByID(targetMountID)
    -- Copy / Clone
    elseif UnitIsPlayer("target") and targetMountID then
        C_MountJournal.SummonByID(targetMountID)
    -- Mount Special
    elseif ((shiftKey and altKey) or (shiftKey and controlKey)) and (mounted or inVehicle) then
        DoEmote(EMOTE171_TOKEN)
    -- Vendor Mounts
    elseif shiftKey and haveVendorMounts then
        mountSummon(RAV_vendorMounts)
    -- Vash'jir, Swimming, and Waterwalking Mounts
    elseif submerged and (haveVashjirMounts or haveSwimmingMounts or haveWaterwalkingMounts) then
        if altKey and haveWaterwalkingMounts then
            mountSummon(RAV_waterwalkingMounts)
        elseif (altKey or controlKey) and flyable and haveFlyingMounts then
            mountSummon(RAV_flyingMounts)
        elseif inVashjir and haveVashjirMounts then
            mountSummon(RAV_vashjirMounts)
        elseif haveSwimmingMounts then
            mountSummon(RAV_swimmingMounts)
        end
    -- Waterwalking Mounts
    elseif floating and haveWaterwalkingMounts then
        if (altKey or controlKey) and flyable and haveFlyingMounts then
            mountSummon(RAV_flyingMounts)
        elseif haveWaterwalkingMounts then
            mountSummon(RAV_waterwalkingMounts)
        end
    -- Two-Person Flying Mounts
    elseif controlKey and flyable and havePassengerFlyingMounts then
        if altKey then
            mountSummon(RAV_passengerGroundMounts)
        else
            mountSummon(RAV_passengerFlyingMounts)
        end
    -- Two-Person Ground Mounts
    elseif controlKey and havePassengerGroundMounts then
        if altKey then
            mountSummon(RAV_passengerFlyingMounts)
        else
            mountSummon(RAV_passengerGroundMounts)
        end
    -- Dismount / Exit Vehicle
    elseif mounted or inVehicle then
        Dismount()
        VehicleExit()
        UIErrorsFrame:Clear()
    -- Flying Mounts
    elseif flyable and haveFlyingMounts then
        if altKey and haveGroundMounts then
            mountSummon(RAV_groundMounts)
        else
            mountSummon(RAV_flyingMounts)
        end
    -- Ahn'Qiraj Mounts
    elseif inAhnQiraj and haveAhnQirajMounts then
        if altKey and haveFlyingMounts then
            mountSummon(RAV_flyingMounts)
        elseif altKey and haveGroundMounts then
            mountSummon(RAV_groundMounts)
        else
            mountSummon(RAV_ahnQirajMounts)
        end
    -- Ground Mounts
    elseif haveGroundMounts then
        if altKey and haveFlyingMounts then
            mountSummon(RAV_flyingMounts)
        else
            mountSummon(RAV_groundMounts)
        end
    -- Check for Mounts that might work before Chauffeur…
    elseif haveWaterwalkingMounts then
        mountSummon(RAV_waterwalkingMounts)
    elseif haveFlyingMounts then
        mountSummon(RAV_flyingMounts)
    elseif haveVendorMounts then
        mountSummon(RAV_vendorMounts)
    -- Chauffeur Mount
    else
        mountSummon(RAV_chauffeurMounts)
    end
end

-- Set up the slash command and variations
local inclusionMessages = {
    ["vendor"] = {
        "Vendor Mounts marked as a Favorite will be \124cff759ab3included\124r in the Ground/Flying Mount summoning list.",
        "Vendor Mounts will be \124cff759ab3excluded\124r from their summoning list unless they are a Favorite."
    },
    ["passenger"] = {
        "Passenger Mounts marked as a Favorite will be \124cff759ab3included\124r in the Ground/Flying Mount summoning list.",
        "Passenger Mounts will be \124cff759ab3excluded\124r from their summoning list unless they are a Favorite."
    },
    ["waterwalking"] = {
        "Waterwalking Mounts marked as a Favorite will be \124cff759ab3included\124r in the Ground Mount summoning list.",
        "Waterwalking Mounts will be \124cff759ab3excluded\124r from their summoning list unless they are a Favorite."
    },
    ["swimming"] = {
        "Swimming Mounts will be \124cff759ab3included\124r in their summoning list, regardless of Favorite status.",
        "Swimming Mounts will be \124cff759ab3excluded\124r from their summoning list unless they are a Favorite."
    },
    ["flex"] = {
        "Flex Mounts will be \124cff759ab3included\124r in the Ground Mount summoning list.",
        "Flex Mounts will be \124cff759ab3excluded\124r from the Ground Mount summoning list."
    },
    ["missing"] = "You need to specify which type of mount to include/exclude: vendor, passenger, waterwalking, swimming, or flex."
}
SLASH_RAVMOUNTS1 = "/ravmounts"
SLASH_RAVMOUNTS2 = "/ravm"
local function slashHandler(message, editbox)
    if message == "version" or message == "v" then
        print("You are running: \124cff759ab3Ravenous Mounts "..ravMounts.version)
    elseif string.match(message, "include") then
        if string.match(message, "vend") or string.match(message, "repair") or string.match(message, "trans") or string.match(message, "mog") then
            RAV_includeVendorMounts = true
            ravMounts.prettyPrint(inclusionMessages.vendor[1])
        elseif string.match(message, "2") or string.match(message, "two") or string.match(message, "multi") or string.match(message, "passenger") then
            RAV_includePassengerMounts = true
            ravMounts.prettyPrint(inclusionMessages.passenger[1])
        elseif string.match(message, "waterwalk") then
            RAV_includeWaterwalkingMounts = true
            ravMounts.prettyPrint(inclusionMessages.waterwalking[1])
        elseif string.match(message, "swim") then
            RAV_includeSwimmingMounts = true
            ravMounts.prettyPrint(inclusionMessages.swimming[1])
        elseif string.match(message, "flex") then
            RAV_includeFlexMounts = true
            ravMounts.prettyPrint(inclusionMessages.flex[1])
        else
            ravMounts.prettyPrint(inclusionMessages.missing)
        end
        ravMounts.mountListHandler()
    elseif string.match(message, "exclude") then
        if string.match(message, "vend") or string.match(message, "repair") or string.match(message, "trans") or string.match(message, "mog") then
            RAV_includeVendorMounts = false
            ravMounts.prettyPrint(inclusionMessages.vendor[2])
        elseif string.match(message, "2") or string.match(message, "two") or string.match(message, "multi") or string.match(message, "passenger") then
            RAV_includePassengerMounts = false
            ravMounts.prettyPrint(inclusionMessages.passenger[2])
        elseif string.match(message, "waterwalk") then
            RAV_includeWaterwalkingMounts = false
            ravMounts.prettyPrint(inclusionMessages.passenger[2])
        elseif string.match(message, "swim") then
            RAV_includeSwimmingMounts = false
            ravMounts.prettyPrint(inclusionMessages.swimming[2])
        elseif string.match(message, "flex") then
            RAV_includeFlexMounts = false
            ravMounts.prettyPrint(inclusionMessages.flex[2])
        else
            ravMounts.prettyPrint(inclusionMessages.missing)
        end
        ravMounts.mountListHandler()
    elseif message == "settings" or message == "s" then
        ravMounts.prettyPrint("Inclusions and Exclusions", true)
        print("\124cff759ab3Vendor Mounts:\124r "..(RAV_includeVendorMounts and "INCLUDE" or "EXCLUDE"))
        print("\124cff759ab3Passenger Mounts:\124r "..(RAV_includePassengerMounts and "INCLUDE" or "EXCLUDE"))
        print("\124cff759ab3Waterwalking Mounts:\124r "..(RAV_includeWaterwalkingMounts and "INCLUDE" or "EXCLUDE"))
        print("\124cff759ab3Swimming Mounts:\124r "..(RAV_includeSwimmingMounts and "INCLUDE" or "EXCLUDE"))
        print("\124cff759ab3Flex Mounts:\124r "..(RAV_includeSwimmingMounts and "INCLUDE" or "EXCLUDE"))
    elseif message == "force" or message == "f" then
        ravMounts.mountListHandler()
        ravMounts.prettyPrint("Mount Journal data collected, sorted, and ready to rock.")
    elseif message == "help" or message == "h" then
        ravMounts.prettyPrint("Information and How to Use", true)
        print("Type \124cff759ab3/ravmounts\124r to call a Mount, or even better—add it to a macro.")
        print("Check your Mount list settings: \124cff759ab3/ravmounts settings")
        print("To include/exclude special Mounts from your Mount lists:")
        print("e.g. \124cff759ab3/ravmounts include vendor\124r or \124cff759ab3/ravmounts exclude passenger\124r or \124cff759ab3/ravmounts include waterwalking")
        print("Force a recache: \124cff759ab3/ravmounts force")
        print("Check out Ravenous Mounts on GitHub, WoWInterface, or Curse for more info and support: http://bit.ly/2hZTsAR")
    else
        ravMounts.mountListHandler()
        ravMounts.mountUpHandler(message)
    end
end
SlashCmdList["RAVMOUNTS"] = slashHandler

-- Check Installation and Updates on AddOn Load
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg)
    if arg == "ravMounts" then
        if not RAV_version then
            ravMounts.prettyPrint("Thanks for installing Ravenous Mounts!")
            print("Type \124cff759ab3/ravmounts help\124r to familiarize yourself with the AddOn!")
        elseif RAV_version ~= ravMounts.version then
            ravMounts.prettyPrint("Thanks for updating Ravenous Mounts!")
            print("Type \124cff759ab3/ravmounts help\124r to familiarize yourself with the AddOn!")
        end
        RAV_version = ravMounts.version
        ravMounts.mountListHandler()
    end
end)
