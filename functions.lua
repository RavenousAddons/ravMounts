

local addonName, addonTable = ... -- Pull back the AddOn-Local Variables and store them locally.
-- addonName = "ravMounts"
-- addonTable = {}
addonTable.Version = "1.6.0"


-- Special formatting for 'Ravenous' messages
local function prettyPrint(message, full)
    if not full then
        full = false
    else
        message = message..":"
    end
    local prefix = "\124cff5f8aa6ravMounts"..(RAV_version ~= nil and " v"..RAV_version or "")..(full and " " or ":\124r ")

    DEFAULT_CHAT_FRAME:AddMessage(prefix..message)
end


---
-- Collect Data and Sort it
-- Can be forced to re-collect, though default is false
-- Cache data and only update cache if any new mounts or Favorites change
---
function mountListHandler(force, announce)
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
    -- the Favorites as different. This will trigger a recache by mountUpHandler.
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

        if announce ~= false then
            prettyPrint("Mount Journal data collected, sorted, and ready to rock.")
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
        RAV_swimmingMounts = {}
        RAV_vendorMounts = {}
        RAV_multiGroundMounts = {}
        RAV_multiFlyingMounts = {}
        RAV_vashjirMounts = {}
        RAV_aqMounts = {}
        RAV_lowbieMounts = {}

        -- Also set a check we'll reuse for the Special Ground/Water Mounts,
        -- which includes the following: Azure Water Strider,
        -- Crimson Water Strider, Brinedeep Bottom-Feeder
        local isSpecialGroundWaterType = (spellID == 118089 or spellID == 127271 or spellID == 214791)
        -- Let's start looping over our Mount Journal and collecting data about
        -- each Mount as we iterate over it.
        for mountIndex, mountID in pairs(C_MountJournal.GetMountIDs()) do
            local name, spellID, _, _, isUsable, _, isFavorite, _, _, hideOnChar, isCollected = C_MountJournal.GetMountInfoByID(mountID)
            local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
            if isCollected and isUsable and not hideOnChar then
                -- Ground Mounts
                -- Includes Special Ground/Water Type
                if (mountType == 230 or isSpecialGroundWaterType) and isFavorite then
                    table.insert(RAV_groundMounts, mountID)
                end
                -- Flying Mounts
                -- Come in "slow" and "fast" types
                if (mountType == 247 or mountType == 248) and isFavorite then
                    table.insert(RAV_flyingMounts, mountID)
                end
                -- Swimming Mounts
                -- Added regardless of Favorite status
                -- Come in a variety of swimming types, like turtles!
                -- Includes Special Ground/Water Type
                if mountType == 231 or mountType == 254
                or isSpecialGroundWaterType then
                    table.insert(RAV_swimmingMounts, mountID)
                end
                -- Vendor Mounts
                -- Added regardless of Favorite status
                -- Traveler's Tundra Mammoth (A/H),  Grand Expedition Yak
                if spellID == 61425 or spellID == 61447
                or spellID == 122708 then
                    if (spellID == 61425 or spellID == 61447) and #RAV_vendorMounts == 0 then
                        table.insert(RAV_vendorMounts, mountID)
                    elseif spellID == 122708 then
                        table.remove(RAV_vendorMounts)
                        table.insert(RAV_vendorMounts, mountID)
                    end
                end
                -- Two-Person Flying Mounts
                -- Added regardless of Favorite status
                -- Sandstone Drake, Obsidian Nightwing, X-53 Touring Rocket
                if spellID == 93326
                or spellID == 121820
                or spellID == 75973 then
                    table.insert(RAV_multiFlyingMounts, mountID)
                end
                -- Two-Person Ground Mounts
                -- Added regardless of Favorite status
                -- Mekgineer's Chopper (A), Mechano-hog (H), Grand Black War
                -- Mammoth (A/H), Grand Ice Mammoth (A/H)
                if spellID == 60424
                or spellID == 55531
                or spellID == 61465 or spellID == 61467
                or spellID == 61469 or spellID == 61470 then
                    table.insert(RAV_multiGroundMounts, mountID)
                end
                -- Vashj'ir Mounts
                -- Added regardless of Favorite status
                if mountType == 232 then
                    table.insert(RAV_vashjirMounts, mountID)
                end
                -- Ahn'Qiraj Mounts
                -- Added regardless of Favorite status
                if mountType == 241 then
                    table.insert(RAV_aqMounts, mountID)
                end
                -- Lowbie Mounts
                -- Added regardless of Favorite status
                -- Chauffeured Mekgineer's Chopper (A), Chauffeured Mechano Hog (H)
                if spellID == 179245 or spellID == 179244 then
                    table.insert(RAV_lowbieMounts, mountID)
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
-- Check a plethora of conditions and choose the appropriate mount from the
-- Mount Journal, and do nothing if conditions are not met.
---
function mountUpHandler()
    -- Simplify the appearance of the logic later by casting our checks to
    -- simple variables.
    local mounted = IsMounted()
    local inVehicle = UnitInVehicle("player")
    local flyable = IsFlyableArea()
    local submerged = IsSubmerged()
    local mapID = GetCurrentMapAreaID()
    -- Kelp'thar Forest, Shimmering Expanse, Abyssal Depths
    local inVashjir = ((mapID == 610 or mapID == 615 or mapID == 614) and true or false)
    -- Ruins of Ahn'Qiraj, Temple of Ahn'Qiraj
    local inAQ = ((mapID == 717 or mapID == 766) and true or false)
    local shiftKey = IsShiftKeyDown()
    local controlKey = IsControlKeyDown()
    local altKey = IsAltKeyDown()
    local haveGroundMounts = (next(RAV_groundMounts) ~= nil and true or false)
    local haveFlyingMounts = (next(RAV_flyingMounts) ~= nil and true or false)
    local haveSwimmingMounts = (next(RAV_swimmingMounts) ~= nil and true or false)
    local haveVendorMounts = (next(RAV_vendorMounts) ~= nil and true or false)
    local haveMultiGroundMounts = (next(RAV_multiGroundMounts) ~= nil and true or false)
    local haveMultiFlyingMounts = (next(RAV_multiFlyingMounts) ~= nil and true or false)
    local haveVashjirMounts = (next(RAV_vashjirMounts) ~= nil and true or false)
    local haveAqMounts = (next(RAV_aqMounts) ~= nil and true or false)
    local haveLowbieMounts = (next(RAV_lowbieMounts) ~= nil and true or false)

    -- Mount Special
    if ((shiftKey and altKey) or (shiftKey and controlKey) or (altKey and controlKey))  and (mounted or inVehicle) then
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
    -- Swimming Mounts
    elseif submerged and (haveVashjirMounts or haveSwimmingMounts) then
        if altKey then
            if flyable and haveFlyingMounts then
                mountSummon(RAV_flyingMounts)
            elseif inAQ and haveAqMounts then
                mountSummon(RAV_aqMounts)
            elseif haveGroundMounts then
                mountSummon(RAV_groundMounts)
            elseif haveLowbieMounts then
                mountSummon(RAV_lowbieMounts)
            end
        elseif inVashjir and haveVashjirMounts then
            mountSummon(RAV_vashjirMounts)
        elseif haveSwimmingMounts then
            mountSummon(RAV_swimmingMounts)
        elseif flyable and haveFlyingMounts then
            mountSummon(RAV_flyingMounts)
        elseif inAQ and haveAqMounts then
            mountSummon(RAV_aqMounts)
        elseif haveGroundMounts then
            mountSummon(RAV_groundMounts)
        elseif haveLowbieMounts then
            mountSummon(RAV_lowbieMounts)
        end
    -- Flying Mounts
    elseif flyable and haveFlyingMounts then
        if altKey then
            if inAq and haveAqMounts then
                mountSummon(RAV_aqMounts)
            elseif haveGroundMounts then
                mountSummon(RAV_groundMounts)
            elseif haveLowbieMounts then
                mountSummon(RAV_lowbieMounts)
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
        elseif haveLowbieMounts then
            mountSummon(RAV_lowbieMounts)
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
            RAV_version = addonTable.Version
            prettyPrint("Thanks for installing Ravenous Mounts! Appreciate ya!")
            mountListHandler(true, false)
        elseif RAV_version ~= nil and RAV_version ~= addonTable.Version and addonTable.Version > RAV_version then
            RAV_version = addonTable.Version
            prettyPrint("Thanks for updating Ravenous Mounts! Appreciate ya!")
            mountListHandler(true, false)
        end
    end
end
frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...) -- call the event functions above
end)
for k, v in pairs(events) do
    frame:RegisterEvent(k) -- Register all events for which handlers have been defined
end
