---
--  Ravenous Mounts
--  Copyright (c) 2016–2018 waldenp0nd
--    Chooses the best Mount for the job, with no configuration or set-up; it's
--    all based on your Mount Journal Favorites. Includes any and all available
--    Ground, Flying, Swimming, Vendor, Passenger, and Special Zone Mounts!
--  https://github.com/waldenp0nd/ravMounts
--  http://www.wowinterface.com/downloads/info24005-RavenousMounts.html
--  https://mods.curse.com/addons/wow/ravmounts
---
local _, ravMounts = ...
ravMounts.version = "1.8.6"

-- DEFAULTS
-- These are only applied when the AddOn is first loaded.
-- From there values are loaded from RAV_ values stored in your WTF folder.
local defaults = {
    INCLUDE_VENDOR_MOUNTS =       true,
    INCLUDE_PASSENGER_MOUNTS =    true,
    INCLUDE_WATERWALKING_MOUNTS = true,
    INCLUDE_CLASS_MOUNTS =        true,
    INCLUDE_SWIMMING_MOUNTS =     true
}

-- Special formatting for messages
function ravMounts.prettyPrint(message, full)
    if not full then
        full = false
    else
        message = message..":"
    end
    local prefix = "\124cff5f8aa6Ravenous Mounts "..ravMounts.version..(full and " " or ":\124r ")
    DEFAULT_CHAT_FRAME:AddMessage(prefix..message)
end

-- Simplify mount summoning syntax
local function mountSummon(list)
    C_MountJournal.SummonByID(list[random(#list)])
end

---
-- Collect Data and Sort it
---
function ravMounts.mountListHandler()
    -- Reset the global variables to be populated later
    RAV_flyingMounts = {}
    RAV_groundMounts = {}
    RAV_vendorMounts = {}
    RAV_passengerFlyingMounts = {}
    RAV_passengerGroundMounts = {}
    RAV_waterwalkingMounts = {}
    RAV_classMounts = {}
    RAV_swimmingMounts = {}
    RAV_vashjirMounts = {}
    RAV_ahnQirajMounts = {}
    RAV_chauffeurMounts = {}
    RAV_includeVendorMounts = (RAV_includeVendorMounts == nil and defaults.INCLUDE_VENDOR_MOUNTS or RAV_includeVendorMounts)
    RAV_includePassengerMounts = (RAV_includePassengerMounts == nil and defaults.INCLUDE_PASSENGER_MOUNTS or RAV_includePassengerMounts)
    RAV_includeWaterwalkingMounts = (RAV_includeWaterwalkingMounts == nil and defaults.INCLUDE_WATERWALKING_MOUNTS or RAV_includeWaterwalkingMounts)
    RAV_includeClassMounts = (RAV_includeClassMounts == nil and defaults.INCLUDE_CLASS_MOUNTS or RAV_includeClassMounts)
    RAV_includeSwimmingMounts = (RAV_includeSwimmingMounts == nil and defaults.INCLUDE_SWIMMING_MOUNTS or RAV_includeSwimmingMounts)

    -- Let's start looping over our Mount Journal adding Mounts to their
    -- respective groups
    local isFlyingMount, isGroundMount, isVendorMount, isPassengerFlyingMount, isPassengerGroundMount, isWaterwalkingMount, isSwimmingMount, isVashjirMount, isAhnQirajMount, isChauffeurMount
    for mountIndex, mountID in pairs(C_MountJournal.GetMountIDs()) do
        local _, spellID, _, _, isUsable, _, isFavorite, _, _, hiddenOnCharacter, isCollected = C_MountJournal.GetMountInfoByID(mountID)
        local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
        isFlyingMount = (mountType == 247 or mountType == 248)
        isGroundMount = (mountType == 230)
        isVendorMount = (spellID == 61425 or spellID == 61447 or spellID == 122708)
        isPassengerFlyingMount = (spellID == 93326 or spellID == 121820 or spellID == 75973 or spellID == 245723 or spellID == 245725)
        isPassengerGroundMount = (spellID == 60424 or spellID == 55531 or spellID == 61465 or spellID == 61467 or spellID == 61469 or spellID == 61470)
        isWaterwalkingMount = (mountType == 269)
        isSwimmingMount = (mountType == 231 or mountType == 254 or spellID == 214791 or spellID == 228919)
        isVashjirMount = (mountType == 232)
        isAhnQirajMount = (mountType == 241)
        isChauffeurMount = (mountType == 284)
        isSpecialType = (isVendorMount or isPassengerFlyingMount or isPassengerGroundMount or isWaterwalkingMount)
        if isCollected and isUsable and not hiddenOnCharacter then
            if isFlyingMount and not isSpecialType and isFavorite then
                table.insert(RAV_flyingMounts, mountID)
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

---
-- Check a plethora of conditions and choose the appropriate Mount from the
-- Mount Journal, and do nothing if conditions are not met
---
function ravMounts.mountUpHandler(specificType)
    -- Simplify the appearance of the logic later by casting our checks to
    -- simple variables
    local mounted = IsMounted()
    local inVehicle = UnitInVehicle("player")
    local flyable = ravMounts.CanFly()
    local submerged = IsSubmerged()
    local mapID = GetCurrentMapAreaID()
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
    local haveClassMounts = (next(RAV_classMounts) ~= nil and true or false)
    local haveSwimmingMounts = (next(RAV_swimmingMounts) ~= nil and true or false)
    local haveVashjirMounts = (next(RAV_vashjirMounts) ~= nil and true or false)
    local haveAhnQirajMounts = (next(RAV_ahnQirajMounts) ~= nil and true or false)
    local haveChauffeurMounts = (next(RAV_chauffeurMounts) ~= nil and true or false)

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
    -- elseif specificType == "class" and haveClassMounts then
        -- mountSummon(RAV_classMounts)
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
        elseif (altKey or controlKey) and haveGroundMounts then
            mountSummon(RAV_groundMounts)
        elseif inVashjir and haveVashjirMounts then
            mountSummon(RAV_vashjirMounts)
        elseif haveSwimmingMounts then
            mountSummon(RAV_swimmingMounts)
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
    -- Chauffeur Mount
    else
        mountSummon(RAV_chauffeurMounts)
    end
end

---
-- Set up the slash command and variations
---
local inclusionMessages = {
    ["vendor"] = {
        "Vendor Mounts marked as a Favorite will be \124cff5f8aa6included\124r in the Ground/Flying Mount summoning list.",
        "Vendor Mounts will be \124cff5f8aa6excluded\124r from their summoning list unless they are a Favorite."
    },
    ["passenger"] = {
        "Passenger Mounts marked as a Favorite will be \124cff5f8aa6included\124r in the Ground/Flying Mount summoning list.",
        "Passenger Mounts will be \124cff5f8aa6excluded\124r from their summoning list unless they are a Favorite."
    },
    ["waterwalking"] = {
        "Waterwalking Mounts marked as a Favorite will be \124cff5f8aa6included\124r in the Ground Mount summoning list.",
        "Waterwalking Mounts will be \124cff5f8aa6excluded\124r from their summoning list unless they are a Favorite."
    },
    ["class"] = {
        "Class Mounts marked as a Favorite will be \124cff5f8aa6included\124r in the Ground Mount summoning list.",
        "Class Mounts will be \124cff5f8aa6excluded\124r from their summoning list unless they are a Favorite."
    },
    ["swimming"] = {
        "Swimming Mounts will be \124cff5f8aa6included\124r in their summoning list, regardless of Favorite status.",
        "Swimming Mounts will be \124cff5f8aa6excluded\124r from their summoning list unless they are a Favorite."
    },
    ["missing"] = "You need to specify which type of mount to include/exclude: vendor, passenger, swimming, or waterwalking."
}
SLASH_RAVMOUNTS1 = "/ravmounts"
SLASH_RAVMOUNTS2 = "/ravm"
local function slashHandler(message, editbox)
    if message == "version" or message == "v" then
        print("You are running: \124cff5f8aa6Ravenous Mounts "..ravMounts.version)
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
        elseif string.match(message, "class") then
            RAV_includeClassMounts = true
            ravMounts.prettyPrint(inclusionMessages.class[1])
        elseif string.match(message, "swim") then
            RAV_includeSwimmingMounts = true
            ravMounts.prettyPrint(inclusionMessages.swimming[1])
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
        elseif string.match(message, "class") then
            RAV_includeClassMounts = false
            ravMounts.prettyPrint(inclusionMessages.class[2])
        elseif string.match(message, "swim") then
            RAV_includeSwimmingMounts = false
            ravMounts.prettyPrint(inclusionMessages.swimming[2])
        else
            ravMounts.prettyPrint(inclusionMessages.missing)
        end
        ravMounts.mountListHandler()
    elseif message == "settings" or message == "s" then
        ravMounts.prettyPrint("Inclusions and Exclusions", true)
        print("\124cff5f8aa6Vendor Mounts:\124r "..(RAV_includeVendorMounts and "INCLUDE" or "EXCLUDE"))
        print("\124cff5f8aa6Passenger Mounts:\124r "..(RAV_includePassengerMounts and "INCLUDE" or "EXCLUDE"))
        print("\124cff5f8aa6Waterwalking Mounts:\124r "..(RAV_includeWaterwalkingMounts and "INCLUDE" or "EXCLUDE"))
        print("\124cff5f8aa6Class Mounts:\124r "..(RAV_includeClassMounts and "INCLUDE" or "EXCLUDE"))
        print("\124cff5f8aa6Swimming Mounts:\124r "..(RAV_includeSwimmingMounts and "INCLUDE" or "EXCLUDE"))
    elseif message == "force" or message == "f" then
        ravMounts.mountListHandler()
        ravMounts.prettyPrint("Mount Journal data collected, sorted, and ready to rock.")
    elseif message == "help" or message == "h" then
        ravMounts.prettyPrint("Information and How to Use", true)
        print("Type \124cff5f8aa6/ravmounts\124r to call a mount, or even better—add it to a macro. To include/exclude special mounts from your mount calls:")
        print("e.g. \124cff5f8aa6/ravmounts include vendor\124r or \124cff5f8aa6/ravmounts exclude passenger\124r or \124cff5f8aa6/ravmounts include waterwalking")
        print("Check your settings: \124cff5f8aa6/ravmounts settings")
        print("Force a recache: \124cff5f8aa6/ravmounts force")
        print("Check out Ravenous Mounts on GitHub, WoWInterface, or Curse for more info and support: http://bit.ly/2hZTsAR")
    else
        ravMounts.mountListHandler()
        ravMounts.mountUpHandler(message)
    end
end
SlashCmdList["RAVMOUNTS"] = slashHandler

---
-- Check Installation and Updates on AddOn Load, Cache Mounts
---
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg)
    if arg == "ravMounts" then
        if not RAV_version then
            ravMounts.prettyPrint("Thanks for installing Ravenous Mounts!")
            print("Type \124cff5f8aa6/ravmounts help\124r to familiarize yourself with the AddOn!")
        elseif RAV_version ~= ravMounts.version then
            ravMounts.prettyPrint("Thanks for updating Ravenous Mounts!")
            print("Type \124cff5f8aa6/ravmounts help\124r to familiarize yourself with the AddOn!")
        end
        RAV_version = ravMounts.version
        ravMounts.mountListHandler()
    end
end)
