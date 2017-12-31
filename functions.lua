

local _, ravMounts = ... -- Pull back the AddOn-Local Variables and store them locally.
ravMounts.Version = "1.8.0"


-- Special formatting for 'Ravenous' messages
function ravMounts.prettyPrint(message, full)
    if not full then
        full = false
    else
        message = message..":"
    end
    local prefix = "\124cff5f8aa6Ravenous Mounts"..(RAV_version ~= nil and " v"..RAV_version or "")..(full and " " or ":\124r ")

    DEFAULT_CHAT_FRAME:AddMessage(prefix..message)
end


---
-- Collect Data and Sort it
-- Can be forced to re-collect, though default is false
-- Cache data and only update cache if any new Mounts or Favorites change
---
function ravMounts.mountListHandler(force, announce)
    -- Compare list of cached Favorites to Current list of Favorites
    -- If they differ, then force a recache
    local mountsFavorited = {}
    for mountIndex, mountID in pairs(C_MountJournal.GetMountIDs()) do
        local _, id, _, _, _, _, isFavorite = C_MountJournal.GetMountInfoByID(mountID)
        if isFavorite == true then
            table.insert(mountsFavorited, id)
        end
    end
    -- Assume they will match. When we find a mismatch, stop looping and mark
    -- the Favorites as different. This will trigger a recache by ravMounts.mountUpHandler.
    local favoritesMatch = true
    if RAV_mountsFavorited then
        local maxFavoritesLength = (#mountsFavorited > #RAV_mountsFavorited and #mountsFavorited or #RAV_mountsFavorited)
        for i = 1, maxFavoritesLength, 1 do
            if mountsFavorited[i] ~= RAV_mountsFavorited[i] then
                favoritesMatch = false
                break
            end
        end
    end

    local mapID = GetCurrentMapAreaID()

    -- Only if we haven't set our lists yet should we build out our variables,
    -- or if we have a new mount!
    if RAV_numMountsCollected ~= GetNumCompanions("MOUNT") or favoritesMatch == false or force == true or RAV_location ~= mapID then

        if announce == true then
            ravMounts.prettyPrint("Mount Journal data collected, sorted, and ready to rock.")
        end

        ---
        -- Instantiate our Global Variables
        -- And if we haven't set a list yet, let's make sure we can know that we
        -- have after this session is closed by setting RAV_numMountsCollected.
        ---
        RAV_location = mapID
        RAV_numMountsCollected = GetNumCompanions("MOUNT")
        RAV_mountsFavorited = mountsFavorited
        RAV_groundMounts = {}
        RAV_flyingMounts = {}
        RAV_waterwalkingMounts = {}
        RAV_swimmingMounts = {}
        RAV_vendorMounts = {}
        RAV_multiFlyingMounts = {}
        RAV_multiGroundMounts = {}
        RAV_vashjirMounts = {}
        RAV_aqMounts = {}
        RAV_chauffeurMounts = {}
        RAV_includeSpecials = (RAV_includeSpecials == nil and true or RAV_includeSpecials)

        -- Let's start looping over our Mount Journal adding Mounts to
        -- their respective groups. Basic Ground and Flying Mounts are checked
        -- to be Favorites, making them 'required' and the other types not.
        for mountIndex, mountID in pairs(C_MountJournal.GetMountIDs()) do
            local _, spellID, _, _, isUsable, _, isFavorite, _, _, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID)
            local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
            local isGroundMount = (mountType == 230)
            local isFlyingMount = (mountType == 247 or mountType == 248)
            local isWaterwalkingMount = (mountType == 269)
            local isSwimmingMount = (mountType == 231 or spellID == 214791 or spellID == 228919)
            local isVendorMount = (spellID == 61425 or spellID == 61447 or spellID == 122708)
            local isTwoPersonFlyingMount = (spellID == 93326 or spellID == 121820 or spellID == 75973 or spellID == 245723 or spellID == 245725)
            local isTwoPersonGroundMount = (spellID == 60424 or spellID == 55531 or spellID == 61465 or spellID == 61467 or spellID == 61469 or spellID == 61470)
            local isVashjirMount = (mountType == 232 or mountType == 254)
            local isAhnQirajMount = (mountType == 241)
            local isChauffeurMount = (mountType == 284)
            local isSpecialMount = (isVendorMount or isTwoPersonFlyingMount or isTwoPersonGroundMount)
            if isCollected and isUsable and not hideOnChar then
                -- Ground Mounts
                -- Includes Special Ground/Water Type
                if isGroundMount and isFavorite then
                    if RAV_includeSpecials then
                        table.insert(RAV_groundMounts, mountID)
                    elseif (not RAV_includeSpecials and not isSpecialMount) then
                        table.insert(RAV_groundMounts, mountID)
                    end
                end
                -- Flying Mounts
                -- Come in "slow" and "fast" types
                if isFlyingMount and isFavorite then
                    if RAV_includeSpecials then
                        table.insert(RAV_flyingMounts, mountID)
                    elseif (not RAV_includeSpecials and not isSpecialMount) then
                        table.insert(RAV_flyingMounts, mountID)
                    end
                end
                -- Waterwalking Mounts
                if isWaterwalkingMount then
                    if RAV_includeSpecials then
                        table.insert(RAV_waterwalkingMounts, mountID)
                    elseif (not RAV_includeSpecials and isFavorite) then
                        table.insert(RAV_waterwalkingMounts, mountID)
                    end
                end
                -- Swimming Mounts
                -- Added regardless of Favorite status
                -- Come in a variety of swimming types, like turtles!
                -- Includes Special Ground/Water Type
                if isSwimmingMount then
                    if RAV_includeSpecials then
                        table.insert(RAV_swimmingMounts, mountID)
                    elseif (not RAV_includeSpecials and isFavorite) then
                        table.insert(RAV_swimmingMounts, mountID)
                    end
                end
                -- Vendor Mounts
                -- Added regardless of Favorite status
                -- Traveler's Tundra Mammoth (A/H), Grand Expedition Yak
                if isVendorMount then
                    if RAV_includeSpecials then
                        table.insert(RAV_vendorMounts, mountID)
                    elseif (not RAV_includeSpecials and isFavorite) then
                        table.insert(RAV_vendorMounts, mountID)
                    end
                end
                -- Two-Person Flying Mounts
                -- Added regardless of Favorite status
                -- Sandstone Drake, Obsidian Nightwing, X-53 Touring Rocket
                -- Stormwind Skychaser, Orgrimmar Interceptor
                if isTwoPersonFlyingMount then
                    if RAV_includeSpecials then
                        table.insert(RAV_multiFlyingMounts, mountID)
                    elseif (not RAV_includeSpecials and isFavorite) then
                        table.insert(RAV_multiFlyingMounts, mountID)
                    end
                end
                -- Two-Person Ground Mounts
                -- Added regardless of Favorite status
                -- Mekgineer's Chopper (A), Mechano-hog (H), Grand Black War
                -- Mammoth (A/H), Grand Ice Mammoth (A/H)
                if isTwoPersonGroundMount then
                    if RAV_includeSpecials then
                        table.insert(RAV_multiGroundMounts, mountID)
                    elseif (not RAV_includeSpecials and isFavorite) then
                        table.insert(RAV_multiGroundMounts, mountID)
                    end
                end
                -- Vashj'ir Mounts
                -- Added regardless of Favorite status
                if isVashjirMount then
                    table.insert(RAV_vashjirMounts, mountID)
                end
                -- Ahn'Qiraj Mounts
                -- Added regardless of Favorite status
                if isAhnQirajMount then
                    table.insert(RAV_aqMounts, mountID)
                end
                -- Chauffeur Mounts
                -- Added regardless of Favorite status
                -- Chauffeured Mekgineer's Chopper (A), Chauffeured Mechano Hog (H)
                if isChauffeurMount then
                    table.insert(RAV_chauffeurMounts, mountID)
                end
            end
        end
    end
end


---
-- Simplify mount summoning syntax
---
local function mountSummon(list)
    C_MountJournal.SummonByID(list[random(#list)])
end


---
-- Check a plethora of conditions and choose the appropriate Mount from the
-- Mount Journal, and do nothing if conditions are not met.
---
function ravMounts.mountUpHandler(specificType)
    -- Simplify the appearance of the logic later by casting our checks to
    -- simple variables.
    local mounted = IsMounted()
    local inVehicle = UnitInVehicle("player")
    local flyable = CanFly()
    local submerged = IsSubmerged()
    local mapID = GetCurrentMapAreaID()
    -- Vash'jir and Co.
    local inVashjir = ((mapID == 610 or mapID == 613 or mapID == 614 or mapID == 615) and true or false)
    -- Ahn'Qiraj and Co.
    local inAQ = ((mapID == 717 or mapID == 766) and true or false)
    local shiftKey = IsShiftKeyDown()
    local controlKey = IsControlKeyDown()
    local altKey = IsAltKeyDown()
    local haveGroundMounts = (next(RAV_groundMounts) ~= nil and true or false)
    local haveFlyingMounts = (next(RAV_flyingMounts) ~= nil and true or false)
    local haveWaterwalkingMounts = (next(RAV_waterwalkingMounts) ~= nil and true or false)
    local haveSwimmingMounts = (next(RAV_swimmingMounts) ~= nil and true or false)
    local haveVendorMounts = (next(RAV_vendorMounts) ~= nil and true or false)
    local haveMultiGroundMounts = (next(RAV_multiGroundMounts) ~= nil and true or false)
    local haveMultiFlyingMounts = (next(RAV_multiFlyingMounts) ~= nil and true or false)
    local haveVashjirMounts = (next(RAV_vashjirMounts) ~= nil and true or false)
    local haveAqMounts = (next(RAV_aqMounts) ~= nil and true or false)
    local haveChauffeurMounts = (next(RAV_chauffeurMounts) ~= nil and true or false)

    -- Summon Specific Mount Types
    if specificType == "vendor" and haveVendorMounts then
        mountSummon(RAV_vendorMounts)
    elseif string.match(specificType, "flying") and (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "passenger")) and haveMultiFlyingMounts then
        mountSummon(RAV_multiFlyingMounts)
    elseif (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "passenger")) and haveMultiGroundMounts then
        mountSummon(RAV_multiGroundMounts)
    elseif specificType == "swimming" and haveSwimmingMounts then
        mountSummon(RAV_swimmingMounts)
    elseif specificType == "waterwalking" and haveWaterwalkingMounts then
        mountSummon(RAV_waterwalkingMounts)
    elseif specificType == "flying" and haveFlyingMounts then
        mountSummon(RAV_flyingMounts)
    elseif specificType == "ground" and haveGroundMounts then
        mountSummon(RAV_groundMounts)
    elseif specificType == "chauffeur" and haveChauffeurMounts then
        mountSummon(RAV_chauffeurMounts)
    elseif (specificType == "aq" or string.match(specificType, "ahn") or string.match(specificType, "qiraj")) and haveAqMounts then
        mountSummon(RAV_aqMounts)
    elseif (specificType == "vj" or string.match(specificType, "vash") or string.match(specificType, "jir")) and haveVashjirMounts then
        mountSummon(RAV_vashjirMounts)
    -- Mount Special
    elseif ((shiftKey and altKey) or (shiftKey and controlKey) or (altKey and controlKey)) and (mounted or inVehicle) then
        DoEmote(EMOTE171_TOKEN)
    -- Dismount / Exit Vehicle
    elseif mounted or inVehicle then
        Dismount()
        VehicleExit()
        UIErrorsFrame:Clear()
    -- Vendor Mounts
    elseif shiftKey and haveVendorMounts then
        mountSummon(RAV_vendorMounts)
    -- Two-Person Flying Mounts
    elseif controlKey and flyable and haveMultiFlyingMounts then
        mountSummon(RAV_multiFlyingMounts)
    -- Two-Person Ground Mounts
    elseif controlKey and haveMultiGroundMounts then
        mountSummon(RAV_multiGroundMounts)
    -- Swimming and Waterwalking Mounts
    elseif submerged and (haveVashjirMounts or haveSwimmingMounts or haveWaterwalkingMounts) then
        if altKey then
            if haveWaterwalkingMounts then
                mountSummon(RAV_waterwalkingMounts)
            elseif flyable and haveFlyingMounts then
                mountSummon(RAV_flyingMounts)
            elseif haveGroundMounts then
                mountSummon(RAV_groundMounts)
            elseif haveChauffeurMounts then
                mountSummon(RAV_chauffeurMounts)
            end
        elseif inVashjir and haveVashjirMounts then
            mountSummon(RAV_vashjirMounts)
        elseif haveSwimmingMounts then
            mountSummon(RAV_swimmingMounts)
        elseif flyable and haveFlyingMounts then
            mountSummon(RAV_flyingMounts)
        elseif haveGroundMounts then
            mountSummon(RAV_groundMounts)
        elseif haveChauffeurMounts then
            mountSummon(RAV_chauffeurMounts)
        end
    -- Flying Mounts
    elseif flyable and haveFlyingMounts then
        if altKey then
            if haveGroundMounts then
                mountSummon(RAV_groundMounts)
            elseif haveChauffeurMounts then
                mountSummon(RAV_chauffeurMounts)
            end
        else
            mountSummon(RAV_flyingMounts)
        end
    -- Ground Mounts
    else
        if altKey and haveFlyingMounts then
            mountSummon(RAV_flyingMounts)
        elseif inAQ and haveAqMounts then
            mountSummon(RAV_aqMounts)
        elseif haveGroundMounts then
            mountSummon(RAV_groundMounts)
        elseif haveChauffeurMounts then
            mountSummon(RAV_chauffeurMounts)
        end
    end
end


---
-- Check Installation and Updates on AddOn Load
---
local frame, events = CreateFrame("Frame"), {}
function events:ADDON_LOADED(name)
    if name == "ravMounts" then
        if not RAV_version then
            RAV_version = ravMounts.Version
            ravMounts.prettyPrint("Thanks for installing Ravenous Mounts! Appreciate ya! Check out Ravenous Mounts on WoWInterface or GitHub for info and support.")
            ravMounts.mountListHandler(true, false) -- force recache, do not announce recache
        elseif RAV_version ~= nil and RAV_version ~= ravMounts.Version and ravMounts.Version > RAV_version then
            RAV_version = ravMounts.Version
            ravMounts.prettyPrint("Thanks for updating Ravenous Mounts! Appreciate ya! Check out Ravenous Mounts on WoWInterface or GitHub for info and support.")
            ravMounts.mountListHandler(true, false) -- force recache, do not announce recache
        end
    end
end
frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...) -- call the event functions above
end)
for k, v in pairs(events) do
    frame:RegisterEvent(k) -- Register all events for which handlers have been defined
end
