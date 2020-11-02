---
-- Ravenous Mounts
--   Chooses the best Mount for the job, with no configuration or set-up; it's
--   all based on your Mount Journal Favorites. Includes any and all available
--   Ground, Flying, Swimming, Vendor, Passenger, and Special Zone Mounts!
-- Author: waldenp0nd
-- License: Public Domain
-- https://github.com/waldenp0nd/ravMounts
-- https://www.wowinterface.com/downloads/info24005-RavenousMounts.html
-- https://www.curseforge.com/wow/addons/ravmounts
---
local _, ravMounts = ...
ravMounts.version = "2.0.4"

-- DEFAULTS
-- These are only applied when the AddOn is first loaded.
-- From there values are loaded from RAV_ values stored in your WTF folder.
local defaults = {
    AUTO_VENDOR_MOUNTS =       true,
    AUTO_PASSENGER_MOUNTS =    true,
    AUTO_SWIMMING_MOUNTS =     true,
    AUTO_FLEX_MOUNTS =         true,
    AUTO_CLONE =               true
}

-- Special formatting for messages
function ravMounts.prettyPrint(message, full)
    if not full then
        full = false
    else
        message = message..":"
    end
    local prefix = "\124cff9eb8c9Ravenous Mounts v"..ravMounts.version..(full and " " or ":\124r ")
    DEFAULT_CHAT_FRAME:AddMessage(prefix..message)
end

-- Simplify mount summoning syntax
local function mountSummon(list)
    if not UnitAffectingCombat("player") and #list > 0 then
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
    RAV_flyingPassengerMounts = {}
    RAV_groundPassengerMounts = {}
    RAV_swimmingMounts = {}
    RAV_vashjirMounts = {}
    RAV_ahnQirajMounts = {}
    RAV_chauffeurMounts = {}
    RAV_allMountsByName = {}
    RAV_allMountsByID = {}
    RAV_autoVendorMounts = (RAV_autoVendorMounts == nil and defaults.AUTO_VENDOR_MOUNTS or RAV_autoVendorMounts)
    RAV_autoPassengerMounts = (RAV_autoPassengerMounts == nil and defaults.AUTO_PASSENGER_MOUNTS or RAV_autoPassengerMounts)
    RAV_autoSwimmingMounts = (RAV_autoSwimmingMounts == nil and defaults.AUTO_SWIMMING_MOUNTS or RAV_autoSwimmingMounts)
    RAV_autoFlexMounts = (RAV_autoFlexMounts == nil and defaults.AUTO_FLEX_MOUNTS or RAV_autoFlexMounts)
    RAV_autoClone = (RAV_autoClone == nil and defaults.AUTO_CLONE or RAV_autoClone)

    -- Let's start looping over our Mount Journal adding Mounts to their
    -- respective groups
    local isFlyingMount, isGroundMount, isVendorMount, isFlyingPassengerMount, isGroundPassengerMount, isSwimmingMount, isVashjirMount, isAhnQirajMount, isChauffeurMount, isSpecialType, isFlexMount
    for mountIndex, mountID in pairs(C_MountJournal.GetMountIDs()) do
        local mountName, spellID, _, _, isUsable, _, isFavorite, _, _, hiddenOnCharacter, isCollected = C_MountJournal.GetMountInfoByID(mountID)
        local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
        isFlyingMount = (mountType == 247 or mountType == 248)
        isGroundMount = (mountType == 230)
        isSwimmingMount = (mountType == 231 or mountType == 254)
        isVashjirMount = (mountType == 232)
        isAhnQirajMount = (mountType == 241)
        isChauffeurMount = (mountType == 284)
        isVendorMount = (mountID == 280 or mountID == 284 or mountID == 460 or mountID == 1039)
        isFlyingPassengerMount = (mountID == 407 or mountID == 455 or mountID == 382 or mountID == 959 or mountID == 960)
        isGroundPassengerMount = (mountID == 275 or mountID == 240 or mountID == 286 or mountID == 287 or mountID == 288 or mountID == 289)
        isSpecialType = (isVendorMount or isFlyingPassengerMount or isGroundPassengerMount)
        isFlexMount = (mountID == 376 or mountID == 532 or mountID == 594 or mountID == 219 or mountID == 547 or mountID == 468 or mountID == 363 or mountID == 457 or mountID == 451 or mountID == 455 or mountID == 458 or mountID == 456 or mountID == 522 or mountID == 459 or mountID == 523 or mountID == 439 or mountID == 593 or mountID == 421 or mountID == 764 or mountID == 1222 or mountID == 1290)
        if isCollected and isUsable and not hiddenOnCharacter then
            table.insert(RAV_allMountsByName, mountName)
            table.insert(RAV_allMountsByID, mountID)
            if isFlyingMount and not isSpecialType and isFavorite then
                if RAV_autoFlexMounts and isFlexMount then
                    table.insert(RAV_groundMounts, mountID)
                else
                    table.insert(RAV_flyingMounts, mountID)
                end
            end
            if isGroundMount and not isSpecialType and isFavorite then
                table.insert(RAV_groundMounts, mountID)
            end
            if isVendorMount then
                if RAV_autoVendorMounts then
                    table.insert(RAV_vendorMounts, mountID)
                    if isFavorite then
                        table.insert(RAV_groundMounts, mountID)
                    end
                elseif not RAV_autoVendorMounts and isFavorite then
                    table.insert(RAV_vendorMounts, mountID)
                end
            end
            if isFlyingPassengerMount then
                if RAV_autoPassengerMounts then
                    table.insert(RAV_flyingPassengerMounts, mountID)
                    if isFavorite then
                        table.insert(RAV_flyingMounts, mountID)
                    end
                elseif not RAV_autoPassengerMounts and isFavorite then
                    table.insert(RAV_flyingPassengerMounts, mountID)
                end
            end
            if isGroundPassengerMount then
                if RAV_autoPassengerMounts then
                    table.insert(RAV_groundPassengerMounts, mountID)
                    if isFavorite then
                        table.insert(RAV_groundMounts, mountID)
                    end
                elseif not RAV_autoPassengerMounts and isFavorite then
                    table.insert(RAV_groundPassengerMounts, mountID)
                end
            end
            if isSwimmingMount then
                if RAV_autoSwimmingMounts
                or not RAV_autoSwimmingMounts and isFavorite then
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
    local haveFlyingPassengerMounts = (next(RAV_flyingPassengerMounts) ~= nil and true or false)
    local haveGroundPassengerMounts = (next(RAV_groundPassengerMounts) ~= nil and true or false)
    local haveSwimmingMounts = (next(RAV_swimmingMounts) ~= nil and true or false)
    local haveVashjirMounts = (next(RAV_vashjirMounts) ~= nil and true or false)
    local haveAhnQirajMounts = (next(RAV_ahnQirajMounts) ~= nil and true or false)
    local haveChauffeurMounts = (next(RAV_chauffeurMounts) ~= nil and true or false)
    local targetMountID = GetTargetMount()

    -- Specific Mounts
    if (string.match(specificType, "vend") or string.match(specificType, "repair") or string.match(specificType, "trans") or string.match(specificType, "mog")) and haveVendorMounts then
        mountSummon(RAV_vendorMounts)
    elseif (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "multi") or string.match(specificType, "passenger")) and haveFlyingPassengerMounts and flyable then
        mountSummon(RAV_flyingPassengerMounts)
    elseif string.match(specificType, "fly") and (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "multi") or string.match(specificType, "passenger")) and haveFlyingPassengerMounts then
        mountSummon(RAV_flyingPassengerMounts)
    elseif (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "multi") or string.match(specificType, "passenger")) and haveGroundPassengerMounts then
        mountSummon(RAV_groundPassengerMounts)
    elseif string.match(specificType, "swim") and haveSwimmingMounts then
        mountSummon(RAV_swimmingMounts)
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
    elseif UnitIsPlayer("target") and targetMountID and RAV_autoClone then
        C_MountJournal.SummonByID(targetMountID)
    -- Mount Special
    elseif ((shiftKey and altKey) or (shiftKey and controlKey)) and (mounted or inVehicle) then
        DoEmote(EMOTE171_TOKEN)
    -- Vendor Mounts
    elseif shiftKey and haveVendorMounts then
        mountSummon(RAV_vendorMounts)
    -- Vash'jir and Swimming Mounts
    elseif submerged and (haveVashjirMounts or haveSwimmingMounts) then
        if altKey and flyable and haveFlyingMounts then
            mountSummon(RAV_flyingMounts)
        elseif inVashjir and haveVashjirMounts then
            mountSummon(RAV_vashjirMounts)
        elseif haveSwimmingMounts then
            mountSummon(RAV_swimmingMounts)
        end
    -- Two-Person Flying Mounts
    elseif controlKey and flyable and haveFlyingPassengerMounts then
        if altKey then
            mountSummon(RAV_groundPassengerMounts)
        else
            mountSummon(RAV_flyingPassengerMounts)
        end
    -- Two-Person Ground Mounts
    elseif controlKey and haveGroundPassengerMounts then
        if altKey then
            mountSummon(RAV_flyingPassengerMounts)
        else
            mountSummon(RAV_groundPassengerMounts)
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
local automationMessages = {
    ["vendor"] = {
        "Vendor Mounts will be called automatically, and if they are marked as a Favorite, they will be \124cff9eb8c9included\124r in the Ground/Flying Mount summoning list.",
        "Vendor Mounts will only be summoned if they are marked as a Favorite."
    },
    ["passenger"] = {
        "Passenger Mounts will be summoned automatically, and if they are marked as a Favorite, they will be \124cff9eb8c9included\124r in the Ground/Flying Mount summoning list.",
        "Passenger Mounts will only be summoned if they are marked as a Favorite."
    },
    ["swimming"] = {
        "Swimming Mounts will be \124cff9eb8c9included\124r in their summoning list, regardless of Favorite status.",
        "Swimming Mounts will only be summoned if they are marked as a Favorite."
    },
    ["flex"] = {
        "Flex Mounts will be included in the Ground Mount summoning list.",
        "Flex Mounts will be excluded from the Ground Mount summoning list."
    },
    ["clone"] = {
        "Your target's mount, if they are using one and you own it too, will be summoned instead of following your Favorites.",
        "The addon will stop cloning your target's mount."
    },
    ["missing"] = "You need to specify which type of automation to toggle: vendor, passenger, swimming, flex, clone. If you need help: \124cff9eb8c9/ravm help"
}
SLASH_RAVMOUNTS1 = "/ravmounts"
SLASH_RAVMOUNTS2 = "/ravm"
local function slashHandler(message, editbox)
    if message == "version" or message == "v" then
        print("You are running: \124cff9eb8c9Ravenous Mounts "..ravMounts.version)
    elseif string.match(message, "auto") then
        if string.match(message, "vend") or string.match(message, "repair") or string.match(message, "trans") or string.match(message, "mog") then
            RAV_autoVendorMounts = not RAV_autoVendorMounts
            if RAV_autoVendorMounts then
                ravMounts.prettyPrint(automationMessages.vendor[1])
            else
                ravMounts.prettyPrint(automationMessages.vendor[2])
            end
        elseif string.match(message, "2") or string.match(message, "two") or string.match(message, "multi") or string.match(message, "passenger") then
            RAV_autoPassengerMounts = not RAV_autoPassengerMounts
            if RAV_autoPassengerMounts then
                ravMounts.prettyPrint(automationMessages.passenger[1])
            else
                ravMounts.prettyPrint(automationMessages.passenger[2])
            end
        elseif string.match(message, "swim") then
            RAV_autoSwimmingMounts = not RAV_autoSwimmingMounts
            if RAV_autoSwimmingMounts then
                ravMounts.prettyPrint(automationMessages.swimming[1])
            else
                ravMounts.prettyPrint(automationMessages.swimming[2])
            end
        elseif string.match(message, "flex") then
            RAV_autoFlexMounts = not RAV_autoFlexMounts
            if RAV_autoFlexMounts then
                ravMounts.prettyPrint(automationMessages.flex[1])
            else
                ravMounts.prettyPrint(automationMessages.flex[2])
            end
        elseif string.match(message, "clone") or string.match(message, "copy") then
            RAV_autoClone = not RAV_autoClone
            if RAV_autoClone then
                ravMounts.prettyPrint(automationMessages.clone[1])
            else
                ravMounts.prettyPrint(automationMessages.clone[2])
            end
        else
            ravMounts.prettyPrint(automationMessages.missing)
        end
        ravMounts.mountListHandler()
    elseif message == "settings" or message == "s" or message == "config" or message == "c" then
        ravMounts.mountListHandler()
        ravMounts.prettyPrint("Automation", true)
        print("\124cff9eb8c9Vendor Mounts:\124r "..(RAV_autoVendorMounts and "Automatically chosen" or "Favorite manually"))
        print("\124cff9eb8c9Passenger Mounts:\124r "..(RAV_autoPassengerMounts and "Automatically chosen" or "Favorite manually"))
        print("\124cff9eb8c9Swimming Mounts:\124r "..(RAV_autoSwimmingMounts and "Automatically chosen" or "Favorite manually"))
        print("\124cff9eb8c9Flexible Mounts:\124r "..(RAV_autoFlexMounts and "Treated as Flying & Ground" or "Treated as Flying-only"))
        print("\124cff9eb8c9Clone Target Mount:\124r "..(RAV_autoClone and "ON" or "OFF"))
    elseif message == "force" or message == "f" then
        ravMounts.mountListHandler()
        ravMounts.prettyPrint("Mount Journal data collected, sorted, and ready to rock.")
        print("There are: "..table.maxn(RAV_allMountsByName).." total usable, "..table.maxn(RAV_groundMounts).." ground, "..table.maxn(RAV_flyingMounts).." flying, "..table.maxn(RAV_vendorMounts).." vendor, "..table.maxn(RAV_groundPassengerMounts) + table.maxn(RAV_flyingPassengerMounts).." passenger, and "..table.maxn(RAV_swimmingMounts).." swimming.");
    elseif message == "help" or message == "h" then
        ravMounts.prettyPrint("Information and How to Use", true)
        print("Type \124cff9eb8c9/ravm\124r to call a Mount, or even better—add it to a macro.")
        print("Check your config: \124cff9eb8c9/ravm config")
        print("To toggle automation of special mounts from your Mount lists:")
        print("e.g. \124cff9eb8c9/ravm auto vendor\124r or \124cff9eb8c9/ravm auto flex\124r or \124cff9eb8c9/ravm auto clone")
        print("Force a recache: \124cff9eb8c9/ravm force")
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
        ravMounts.mountListHandler()
        if not RAV_version then
            ravMounts.prettyPrint("Thanks for installing Ravenous Mounts!")
            print("Type \124cff9eb8c9/ravm help\124r to familiarize yourself with the AddOn!")
            print("There are: "..table.maxn(RAV_allMountsByName).." total usable, "..table.maxn(RAV_groundMounts).." ground, "..table.maxn(RAV_flyingMounts).." flying, "..table.maxn(RAV_vendorMounts).." vendor, "..table.maxn(RAV_groundPassengerMounts) + table.maxn(RAV_flyingPassengerMounts).." passenger, and "..table.maxn(RAV_swimmingMounts).." swimming.");
        elseif RAV_version ~= ravMounts.version then
            ravMounts.prettyPrint("Thanks for updating Ravenous Mounts!")
            print("Type \124cff9eb8c9/ravm help\124r to familiarize yourself with the AddOn!")
            print("There are: "..table.maxn(RAV_allMountsByName).." total usable, "..table.maxn(RAV_groundMounts).." ground, "..table.maxn(RAV_flyingMounts).." flying, "..table.maxn(RAV_vendorMounts).." vendor, "..table.maxn(RAV_groundPassengerMounts) + table.maxn(RAV_flyingPassengerMounts).." passenger, and "..table.maxn(RAV_swimmingMounts).." swimming.");
        end
        RAV_version = ravMounts.version
    end
end)
