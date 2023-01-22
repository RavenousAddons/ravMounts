local ADDON_NAME, ns = ...
local L = ns.L

local defaults = ns.data.defaults
local mountTypes = ns.data.mountTypes
local mountIDs = ns.data.mountIDs
local mapIDs = ns.data.mapIDs

local _, className = UnitClass("player")
local faction, _ = UnitFactionGroup("player")
local flyable, cloneMountID, mapID, inAhnQiraj, inVashjir, inMaw, inDragonIsles, haveGroundMounts, haveFlyingMounts, havePassengerGroundMounts, havePassengerFlyingMounts, haveVendorMounts, haveSwimmingMounts, haveAhnQirajMounts, haveVashjirMounts, haveMawMounts, haveDragonIslesMounts, haveChauffeurMounts, haveBroom, haveMoonfang, normalMountModifier, vendorMountModifier, passengerMountModifier

local modifiers = {"none", "alt", "ctrl", "shift"}

local CM = C_Map
local CMJ = C_MountJournal

local function contains(table, input)
    for index, value in ipairs(table) do
        if value == input then
            return index
        end
    end
    return false
end

local function hasFlyingRiding()
    for _, spell in ipairs({34090, 34091, 90265}) do
        if IsSpellKnown(spell) then return true end
    end
    return false
end

local function hasGroundRiding()
    if hasFlyingRiding() then return true end
    for _, spell in ipairs({33388, 33391}) do
        if IsSpellKnown(spell) then return true end
    end
    return false
end

local function hasItemInBags()
    for bag=0, NUM_BAG_SLOTS do
        for slot=1, GetContainerNumSlots(bag) do
            if 37011 == GetContainerItemID(bag, slot) then return true end
        end
    end
    return false
end

local function GetMountName(mountID)
    if not mountID then return nil end

    local _, spellID = CMJ.GetMountInfoByID(mountID)
    local mountName, _ = GetSpellInfo(spellID)

    return mountName
end

function ns:PrettyPrint(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff" .. ns.color .. ns.name .. ":|r " .. message)
end

function ns:AssignVariables()
    flyable = ns:IsFlyableArea()
    cloneMountID = ns:GetCloneMount()
    mapID = CM.GetBestMapForUnit("player")
    inAhnQiraj = contains(mapIDs.ahnqiraj, mapID)
    inVashjir = contains(mapIDs.vashjir, mapID)
    inMaw = contains(mapIDs.maw, mapID)
    inDragonIsles = contains(mapIDs.dragonisles, mapID)
    haveGroundMounts = next(RAV_data.mounts.ground) ~= nil and true or false
    haveFlyingMounts = next(RAV_data.mounts.flying) ~= nil and true or false
    havePassengerGroundMounts = next(RAV_data.mounts.passengerGround) ~= nil and true or false
    havePassengerFlyingMounts = next(RAV_data.mounts.passengerFlying) ~= nil and true or false
    haveVendorMounts = next(RAV_data.mounts.vendor) ~= nil and true or false
    haveSwimmingMounts = next(RAV_data.mounts.swimming) ~= nil and true or false
    haveAhnQirajMounts = next(RAV_data.mounts.ahnqiraj) ~= nil and true or false
    haveVashjirMounts = next(RAV_data.mounts.vashjir) ~= nil and true or false
    haveMawMounts = next(RAV_data.mounts.maw) ~= nil and true or false
    haveDragonIslesMounts = next(RAV_data.mounts.dragonisles) ~= nil and true or false
    haveChauffeurMounts = next(RAV_data.mounts.chauffeur) ~= nil and true or false
    haveTravelForm = next(RAV_data.mounts.travelForm) ~= nil and true or false
    haveBroom = RAV_data.mounts.broom.slot ~= nil and true or false
    haveMoonfang = RAV_data.mounts.moonfang.slot ~= nil and true or false
    normalMountModifier = RAV_data.options.normalMountModifier == 2 and IsAltKeyDown() or RAV_data.options.normalMountModifier == 3 and IsControlKeyDown() or RAV_data.options.normalMountModifier == 4 and IsShiftKeyDown() or false
    vendorMountModifier = RAV_data.options.vendorMountModifier == 2 and IsAltKeyDown() or RAV_data.options.vendorMountModifier == 3 and IsControlKeyDown() or RAV_data.options.vendorMountModifier == 4 and IsShiftKeyDown() or false
    passengerMountModifier = RAV_data.options.passengerMountModifier == 2 and IsAltKeyDown() or RAV_data.options.passengerMountModifier == 3 and IsControlKeyDown() or RAV_data.options.passengerMountModifier == 4 and IsShiftKeyDown() or false
end

local hasSeenNoSpaceMessage = false
function ns:EnsureMacro()
    if RAV_data.options.macro and not UnitAffectingCombat("player") then
        ns:AssignVariables()
        local icon = "INV_Misc_QuestionMark"
        local flying = (inDragonIsles and haveDragonIslesMounts) and RAV_data.mounts.dragonisles or haveFlyingMounts and RAV_data.mounts.flying or nil
        local ground = (inAhnQiraj and haveAhnQirajMounts) and RAV_data.mounts.ahnqiraj or haveGroundMounts and RAV_data.mounts.ground or nil
        local vendor = haveVendorMounts and RAV_data.mounts.vendor or nil
        local passenger = (flyable and havePassengerFlyingMounts) and RAV_data.mounts.passengerFlying or havePassengerGroundMounts and RAV_data.mounts.passengerGround or nil
        local swimming = (inVashjir and haveVashjirMounts) and RAV_data.mounts.vashjir or haveSwimmingMounts and RAV_data.mounts.swimming or nil
        local chauffeur = haveChauffeurMounts and RAV_data.mounts.chauffeur or nil
        local travelForm = haveTravelForm and RAV_data.mounts.travelForm or nil
        local dragonisles = (inDragonIsles and haveDragonIslesMounts) and RAV_data.mounts.dragonisles or nil
        local broom = haveBroom and RAV_data.mounts.broom or nil
        local moonfang = haveMoonfang and RAV_data.mounts.moonfang or nil
        local body = "/ravm"
        if className == "DRUID" or className == "SHAMAN" then
            body = "/cancelform\n" .. body
        end
        local mountName
        if flying or broom or ground or moonfang or chauffeur or vendor or passenger or swimming or (RAV_data.options.travelForm and travelForm) then
            body = "\n" .. body
            if (RAV_data.options.travelForm and travelForm) then
                local travelFormName, _ = GetSpellInfo(travelForm[1])
                if RAV_data.options.normalMountModifier ~= 1 then
                    if inDragonIsles and haveDragonIslesMounts then
                        mountName = GetMountName(dragonisles[random(#dragonisles)])
                        body = "[mod:" .. modifiers[RAV_data.options.normalMountModifier] .. "] " .. travelFormName .. "; " .. mountName .. "\n" .. "/use [mod:" .. modifiers[RAV_data.options.normalMountModifier] .. "] " .. travelFormName .. "\n" .. "/stopmacro [mod:" .. modifiers[RAV_data.options.normalMountModifier] .. "]" .. body
                    else
                        body = travelFormName .. "\n" .. "/use [nomod] " .. travelFormName .. "\n" .. "/stopmacro [nomod]" .. body
                        if broom or flying or moonfang or ground or chauffeur then
                            mountName = broom and broom.name or flying and GetMountName(flying[random(#flying)]) or moonfang and moonfang.name or ground and GetMountName(ground[random(#ground)]) or chauffeur and GetMountName(chauffeur[random(#chauffeur)]) or nil
                            if not mountName then
                                ns:EnsureMacro()
                                return
                            end
                        end
                        if mountName then
                            body = "[mod:" .. modifiers[RAV_data.options.normalMountModifier] .. "] " .. mountName .. "; " .. body
                        end
                    end
                else
                    body = travelFormName .. "\n" .. "/use " .. travelFormName
                end
            else
                if moonfang or ground then
                    mountName = moonfang and moonfang.name or GetMountName(ground[random(#ground)])
                    if not mountName then
                        ns:EnsureMacro()
                        return
                    end
                    body = mountName .. body
                end
                if broom or flying then
                    mountName = broom and broom.name or GetMountName(flying[random(#flying)])
                    if not mountName then
                        ns:EnsureMacro()
                        return
                    end
                    if (broom or flyable) and (moonfang or ground) then
                        if RAV_data.options.normalMountModifier ~= 1 then -- none
                            body = "[swimming,mod:" .. modifiers[RAV_data.options.normalMountModifier] .. "][nomod:" .. modifiers[RAV_data.options.normalMountModifier] .. "] " .. mountName .. "; " .. body
                        else
                            body = "[] " .. mountName .. "; " .. body
                        end
                    elseif (moonfang or ground) and RAV_data.options.normalMountModifier ~= 1 then -- none
                        body = "[noswimming,mod:" .. modifiers[RAV_data.options.normalMountModifier] .. "] " .. mountName .. "; " .. body
                    else
                        body = mountName .. body
                    end
                end
                if chauffeur and ground == nil and flying == nil then
                    icon = "inv_misc_key_06"
                    mountName, _ = CMJ.GetMountInfoByID(chauffeur[1])
                    body = mountName .. body
                end
            end
            if swimming and travelForm == nil then
                _, spellID = CMJ.GetMountInfoByID(swimming[random(#swimming)])
                mountName, _ = GetSpellInfo(spellID)
                if RAV_data.options.normalMountModifier ~= 1 then -- none
                    body = "[swimming,nomod:" .. modifiers[RAV_data.options.normalMountModifier] .. "] " .. mountName .. ((flying or ground or chauffeur) and "; " or "") .. body
                else
                    body = "[swimming] " .. mountName .. ((flying or ground or chauffeur) and "; " or "") .. body
                end
            end
            if vendor and RAV_data.options.vendorMountModifier ~= 1 then -- none
                _, spellID = CMJ.GetMountInfoByID(vendor[random(#vendor)])
                mountName, _ = GetSpellInfo(spellID)
                body = "[mod:" .. modifiers[RAV_data.options.vendorMountModifier] .. "] " .. mountName .. ((flying or ground or chauffeur or swimming) and "; " or "") .. body
            end
            if passenger and RAV_data.options.passengerMountModifier ~= 1 then -- none
                _, spellID = CMJ.GetMountInfoByID(passenger[random(#passenger)])
                mountName, _ = GetSpellInfo(spellID)
                body = "[mod:" .. modifiers[RAV_data.options.passengerMountModifier] .. "] " .. mountName .. ((flying or ground or chauffeur or swimming or vendor) and "; " or "") .. body
            end
            body = "#showtooltip " .. body
        end
        local numberOfMacros, _ = GetNumMacros()
        if GetMacroIndexByName(ns.name) > 0 then
            if body ~= RAV_macroBody then
                EditMacro(GetMacroIndexByName(ns.name), ns.name, icon, body)
                RAV_macroBody = body
            end
        elseif numberOfMacros < 120 then
            CreateMacro(ns.name, icon, body)
            RAV_macroBody = body
        elseif not hasSeenNoSpaceMessage then
            hasSeenNoSpaceMessage = true
            ns:PrettyPrint(L.NoMacroSpace)
        end
    end
end

function ns:MountSummon(list)
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

function ns:GetCloneMount()
    local clone = false
    if RAV_data.options.clone == 4 then -- both
        clone = UnitIsPlayer("target") and "target" or UnitIsPlayer("focus") and "focus" or false
    elseif RAV_data.options.clone == 2 then -- target
        clone = UnitIsPlayer("target") and "target" or false
    elseif RAV_data.options.clone == 3 then -- focus
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

function ns:MountListHandler()
    RAV_data.mounts = {}
    RAV_data.mounts.ground = {}
    RAV_data.mounts.flying = {}
    RAV_data.mounts.vendor = {}
    RAV_data.mounts.passengerGround = {}
    RAV_data.mounts.passengerFlying = {}
    RAV_data.mounts.swimming = {}
    RAV_data.mounts.ahnqiraj = {}
    RAV_data.mounts.vashjir = {}
    RAV_data.mounts.maw = {}
    RAV_data.mounts.dragonisles = {}
    RAV_data.mounts.chauffeur = {}
    mapID = CM.GetBestMapForUnit("player")
    inNazjatar = contains(mapIDs.nazjatar, mapID)
    for _, mountID in pairs(CMJ.GetMountIDs()) do
        local mountName, _, _, _, isUsable, _, isFavorite, _, mountFaction, _, isCollected = CMJ.GetMountInfoByID(mountID)
        local _, _, _, _, mountType = CMJ.GetMountInfoExtraByID(mountID)
        local isSwimmingMount = contains(mountTypes.swimming, mountType)
        local isGroundMount = (contains(mountTypes.ground, mountType) and not isSwimmingMount) or (contains(mountTypes.ground, mountType) and isSwimmingMount and RAV_data.options.normalSwimmingMounts)
        local isFlyingMount = (contains(mountTypes.flying, mountType) and not isSwimmingMount) or (contains(mountTypes.flying, mountType) and isSwimmingMount and RAV_data.options.normalSwimmingMounts)
        local isVendorMount = contains(mountIDs.vendor, mountID)
        local isPassengerGroundMount = contains(mountIDs.passengerGround, mountID)
        local isPassengerFlyingMount = contains(mountIDs.passengerFlying, mountID)
        local isAhnQirajMount = contains(mountTypes.ahnqiraj, mountType)
        local isVashjirMount = contains(mountTypes.vashjir, mountType)
        local isMawMount = contains(mountIDs.maw, mountID)
        local isDragonIslesMount = contains(mountIDs.dragonisles, mountID)
        local isChauffeurMount = contains(mountTypes.chauffeur, mountType)
        local isFlexMount = contains(mountIDs.flex, mountID)
        local hasGroundRiding = hasGroundRiding()
        local hasFlyingRiding = hasFlyingRiding()
        -- 0 = Horde, 1 = Alliance
        if isCollected and not (mountFaction == 0 and faction ~= "Horde") and not (mountFaction == 1 and faction ~= "Alliance") then
            if hasGroundRiding then
                if isFlyingMount and (not RAV_data.options.normalMounts or isFavorite) and not isVendorMount and not isPassengerFlyingMount and not isPassengerGroundMount then
                    if isFlexMount then
                        if RAV_data.options.flexMounts == 3 or RAV_data.options.flexMounts == 1 then -- both or target
                            table.insert(RAV_data.mounts.ground, mountID)
                        end
                        if hasFlyingRiding and RAV_data.options.flexMounts == 3 or RAV_data.options.flexMounts == 2 then -- both or focus
                            table.insert(RAV_data.mounts.flying, mountID)
                        end
                    elseif hasFlyingRiding then
                        table.insert(RAV_data.mounts.flying, mountID)
                    end
                end
                if isGroundMount and (isFavorite or not RAV_data.options.normalMounts) and not isVendorMount and not isPassengerFlyingMount and not isPassengerGroundMount then
                    table.insert(RAV_data.mounts.ground, mountID)
                end
                if isVendorMount and (isFavorite or not RAV_data.options.vendorMounts) then
                    table.insert(RAV_data.mounts.vendor, mountID)
                end
                if hasFlyingRiding and isPassengerFlyingMount and (isFavorite or not RAV_data.options.passengerMounts) then
                    table.insert(RAV_data.mounts.passengerFlying, mountID)
                end
                if isPassengerGroundMount and (isFavorite or not RAV_data.options.passengerMounts) then
                    table.insert(RAV_data.mounts.passengerGround, mountID)
                end
                if isSwimmingMount and (isFavorite or not RAV_data.options.swimmingMounts) then
                    table.insert(RAV_data.mounts.swimming, mountID)
                    if inNazjatar and not contains(mountIDs.noFlyingSwimming, mountID) then
                        table.insert(RAV_data.mounts.flying, mountID)
                    end
                end
                if isAhnQirajMount and (isFavorite or not RAV_data.options.zoneSpecificMounts) then
                    table.insert(RAV_data.mounts.ahnqiraj, mountID)
                end
                if isVashjirMount and (isFavorite or not RAV_data.options.zoneSpecificMounts) then
                    table.insert(RAV_data.mounts.vashjir, mountID)
                end
                if isMawMount and (isFavorite or not RAV_data.options.zoneSpecificMounts) then
                    table.insert(RAV_data.mounts.maw, mountID)
                end
                if isDragonIslesMount and (isFavorite or not RAV_data.options.zoneSpecificMounts) then
                    table.insert(RAV_data.mounts.dragonisles, mountID)
                end
            end
            if isChauffeurMount then
                table.insert(RAV_data.mounts.chauffeur, mountID)
            end
        end
    end
    RAV_data.mounts.travelForm = {}
    if className == "DRUID" then
        if IsPlayerSpell(ns.data.travelForms["Travel Form"]) and (IsOutdoors() or IsSubmerged()) then
            table.insert(RAV_data.mounts.travelForm, ns.data.travelForms["Travel Form"])
        elseif IsPlayerSpell(ns.data.travelForms["Cat Form"]) then
            table.insert(RAV_data.mounts.travelForm, ns.data.travelForms["Cat Form"])
        end
    elseif className == "SHAMAN" then
        if IsPlayerSpell(ns.data.travelForms["Ghost Wolf"]) then
            table.insert(RAV_data.mounts.travelForm, ns.data.travelForms["Ghost Wolf"])
        end
    end
    RAV_data.mounts.broom = {}
    -- local broomName, broomID = GetItemSpell(37011)
    -- if (IsUsableSpell(broomID)) then
    --     RAV_data.mounts.broom.name = broomName
    --     for bag=0, NUM_BAG_SLOTS do
    --         for slot=1, GetContainerNumSlots(bag) do
    --             if 37011 == GetContainerItemID(bag, slot) then
    --                 RAV_data.mounts.broom.bag = bag
    --                 RAV_data.mounts.broom.slot = slot
    --             end
    --         end
    --     end
    -- end
    RAV_data.mounts.moonfang = {}
    -- local moonfangName, moonfangID = GetItemSpell(37011)
    -- if (IsUsableSpell(moonfangID)) then
    --     RAV_data.mounts.moonfang.name = moonfangName
    --     for bag=0, NUM_BAG_SLOTS do
    --         for slot=1, GetContainerNumSlots(bag) do
    --             if 105898 == GetContainerItemID(bag, slot) then
    --                 RAV_data.mounts.moonfang.bag = bag
    --                 RAV_data.mounts.moonfang.slot = slot
    --             end
    --         end
    --     end
    -- end
end

function ns:MountUpHandler(specificType)
    -- Uses the in-game Interface Setting "Controls" → "Auto Dismount in Flight"
    if IsFlying() and GetCVar("autoDismountFlying") == "0" then
        return
    end
    ns:AssignVariables()
    -- Check for specific types
    if (specificType:match("vend") or specificType:match("repair") or specificType:match("trans") or specificType:match("mog")) and haveVendorMounts then
        ns:MountSummon(RAV_data.mounts.vendor)
    elseif (specificType:match("2") or specificType:match("two") or specificType:match("multi") or specificType:match("passenger")) and havePassengerFlyingMounts and flyable then
        ns:MountSummon(RAV_data.mounts.passengerFlying)
    elseif specificType:match("fly") and (specificType:match("2") or specificType:match("two") or specificType:match("multi") or specificType:match("passenger")) and havePassengerFlyingMounts then
        ns:MountSummon(RAV_data.mounts.passengerFlying)
    elseif (specificType:match("2") or specificType:match("two") or specificType:match("multi") or specificType:match("passenger")) and havePassengerGroundMounts then
        ns:MountSummon(RAV_data.mounts.passengerGround)
    elseif specificType:match("swim") and haveSwimmingMounts then
        ns:MountSummon(RAV_data.mounts.swimming)
    elseif (specificType == "vj" or specificType:match("vash") or specificType:match("jir")) and haveVashjirMounts then
        ns:MountSummon(RAV_data.mounts.vashjir)
    elseif specificType:match("fly") and haveFlyingMounts then
        ns:MountSummon(RAV_data.mounts.flying)
    elseif (specificType == "aq" or specificType:match("ahn") or specificType:match("qiraj")) and haveAhnQirajMounts then
        ns:MountSummon(RAV_data.mounts.ahnqiraj)
    elseif specificType:match("maw") and haveMawMounts then
        ns:MountSummon(RAV_data.mounts.maw)
    elseif (specificType == "df" or specificType == "di" or specificType == "dr" or specificType:match("dragon")) and haveDragonIslesMounts then
        ns:MountSummon(RAV_data.mounts.dragonisles)
    elseif specificType == "ground" and haveGroundMounts then
        ns:MountSummon(RAV_data.mounts.ground)
    elseif specificType == "chauffeur" and haveChauffeurMounts then
        ns:MountSummon(RAV_data.mounts.chauffeur)
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
    elseif RAV_data.options.travelForm == true and ((className == "DRUID" and GetShapeshiftForm() == 3) or (className == "SHAMAN" and GetShapeshiftForm() == 16)) then
        CancelShapeshiftForm()
        UIErrorsFrame:Clear()
    -- Clone
    elseif RAV_data.options.clone ~= 1 and cloneMountID and not normalMountModifier and not vendorMountModifier and not passengerMountModifier then
        CMJ.SummonByID(cloneMountID)
    -- Modifier Keys
    elseif haveVendorMounts and vendorMountModifier then
        ns:MountSummon(RAV_data.mounts.vendor)
    elseif havePassengerFlyingMounts and flyable and passengerMountModifier and not normalMountModifier then
        ns:MountSummon(RAV_data.mounts.passengerFlying)
    elseif havePassengerGroundMounts and passengerMountModifier and (not flyable or (flyable and normalMountModifier)) then
        ns:MountSummon(RAV_data.mounts.passengerGround)
    -- The Rest...
    elseif haveVashjirMounts and IsSwimming() and not normalMountModifier and inVashjir then
        ns:MountSummon(RAV_data.mounts.vashjir)
    elseif haveSwimmingMounts and IsSwimming() and not normalMountModifier then
        ns:MountSummon(RAV_data.mounts.swimming)
    elseif ((inDragonIsles and haveDragonIslesMounts) or haveBroom or haveFlyingMounts) and (flyable and (not normalMountModifier or (normalMountModifier and (IsSwimming() or (className == "DRUID" or className == "SHAMAN") and not inDragonIsles)))) or (not flyable and not IsSwimming() and normalMountModifier) then
        if (haveDragonIslesMounts and inDragonIsles) then
            ns:MountSummon(RAV_data.mounts.dragonisles)
        elseif (haveBroom) then
            UseContainerItem(RAV_data.mounts.broom.bag, RAV_data.mounts.broom.slot, true)
        else
            ns:MountSummon(RAV_data.mounts.flying)
        end
    elseif inAhnQiraj and haveAhnQirajMounts then
        ns:MountSummon(RAV_data.mounts.ahnqiraj)
    elseif haveMoonfang or haveGroundMounts then
        if (haveMoonfang) then
            UseContainerItem(RAV_data.mounts.moonfang.bag, RAV_data.mounts.moonfang.slot, true)
        else
            ns:MountSummon(RAV_data.mounts.ground)
        end
    elseif haveFlyingMounts then
        ns:MountSummon(RAV_data.mounts.flying)
    elseif haveChauffeurMounts then
        ns:MountSummon(RAV_data.mounts.chauffeur)
    else
        ns:PrettyPrint(_G.MOUNT_JOURNAL_NO_VALID_FAVORITES)
    end
end

function ns:RegisterDefaultOption(key, value)
    -- Temporary shim to fix old options
    if type(RAV_data.options[key]) == "string" then
        RAV_data.options[key] = value
    end
    if RAV_data.options[key] == nil then
        RAV_data.options[key] = value
    end
end

function ns:SetDefaultSettings()
    if RAV_data == nil then
        RAV_data = {}
    end
    if RAV_data.options == nil then
        RAV_data.options = {}
    end
    for k, v in pairs(defaults) do
        ns:RegisterDefaultOption(k, v)
    end
end

function ns:CreateCheckBox(category, variable, name, tooltip)
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaults[variable]), RAV_data.options[variable])
    Settings.SetOnValueChangedCallback(variable, function(event)
        RAV_data.options[variable] = setting:GetValue()
        ns:MountListHandler()
        ns:EnsureMacro()
    end)
    Settings.CreateCheckBox(category, setting, tooltip)
end

function ns:CreateDropDown(category, variable, name, options, tooltip)
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaults[variable]), RAV_data.options[variable])
    Settings.SetOnValueChangedCallback(variable, function(event)
        RAV_data.options[variable] = setting:GetValue()
        ns:MountListHandler()
        ns:EnsureMacro()
    end)
    Settings.CreateDropDown(category, setting, options, tooltip)
end

function ns:CreateOpenSettingsButton()
    local OpenOptions = CreateFrame("Button", ADDON_NAME .. "OpenOptionsButton", MountJournal, "UIPanelButtonTemplate")
    OpenOptions:SetPoint("BOTTOMRIGHT", MountJournal, "BOTTOMRIGHT", -4, 4)
    local OpenOptionsLabel = OpenOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    OpenOptionsLabel:SetPoint("CENTER", OpenOptions, "CENTER")
    OpenOptionsLabel:SetText(ns.name)
    OpenOptions:SetWidth(OpenOptionsLabel:GetWidth() + 16)
    OpenOptions:RegisterForClicks("AnyUp")
    OpenOptions:SetScript("OnMouseUp", function(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        Settings.OpenToCategory(ns.name)
    end)
end

function ns:SendUpdate(type)
    local currentTime = GetTime()
    if (RAV_data.updateTimeoutTime) then
        if (currentTime < RAV_data.updateTimeoutTime) then
            return
        end
    end
    RAV_data.updateTimeoutTime = currentTime + ns.data.updateTimeout
    C_ChatInfo.SendAddonMessage(ADDON_NAME, "V:" .. ns.version, type)
end
