local ADDON_NAME, ns = ...
local L = ns.L

local defaults = ns.data.defaults
local mountTypes = ns.data.mountTypes
local mountIDs = ns.data.mountIDs
local mapIDs = ns.data.mapIDs

local _, className = UnitClass("player")
local faction, _ = UnitFactionGroup("player")
local flyable, cloneMountID, mapID, inAhnQiraj, inVashjir, inMaw, haveGroundMounts, haveFlyingMounts, havePassengerGroundMounts, havePassengerFlyingMounts, haveVendorMounts, haveSwimmingMounts, haveAhnQirajMounts, haveVashjirMounts, haveMawMounts, haveChauffeurMounts, normalMountModifier, vendorMountModifier, passengerMountModifier
local prevControl
local dropdowns = {}
local mountModifiers = {
    "normalMountModifier",
    "vendorMountModifier",
    "passengerMountModifier",
}
local tooltipLabels = {
    ["vendor"] = _G.BATTLE_PET_SOURCE_3,
    ["passengerGround"] = L.PassengerGround,
    ["passengerFlying"] = L.PassengerFlying,
    ["flex"] = _G.PLAYER_DIFFICULTY4,
}

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

local function addLabelsFromSpell(target, spellID, showCloneable)
    if showCloneable == nil then showCloneable = true end
    local type, cloneable
    for mountType, label in pairs(tooltipLabels) do
        for _, mountID in ipairs(ns.data.mountIDs[mountType]) do
            local _, lookup, _ = CMJ.GetMountInfoByID(mountID)
            if tonumber(lookup) == tonumber(spellID) then
                type = label
                break
            end
        end
        if type then
            break
        end
    end
    if showCloneable then
        for _, mountID in ipairs(RAV_data.mounts.allByID) do
            local _, lookup, _ = CMJ.GetMountInfoByID(mountID)
            if lookup == spellID then
                cloneable = true
                break
            end
        end
    end
    if type or (showCloneable and cloneable) then
        target:AddLine("|cff" .. ns.color .. ns.name .. ":|r " .. (type and type or "") .. ((type and showCloneable and cloneable) and ", " or "") .. ((showCloneable and cloneable) and L.Cloneable or ""), 1, 1, 1)
    end
    target:Show()
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
    haveGroundMounts = next(RAV_data.mounts.ground) ~= nil and true or false
    haveFlyingMounts = next(RAV_data.mounts.flying) ~= nil and true or false
    havePassengerGroundMounts = next(RAV_data.mounts.passengerGround) ~= nil and true or false
    havePassengerFlyingMounts = next(RAV_data.mounts.passengerFlying) ~= nil and true or false
    haveVendorMounts = next(RAV_data.mounts.vendor) ~= nil and true or false
    haveSwimmingMounts = next(RAV_data.mounts.swimming) ~= nil and true or false
    haveAhnQirajMounts = next(RAV_data.mounts.ahnqiraj) ~= nil and true or false
    haveVashjirMounts = next(RAV_data.mounts.vashjir) ~= nil and true or false
    haveMawMounts = next(RAV_data.mounts.maw) ~= nil and true or false
    haveTravelForm = next(RAV_data.mounts.travelForm) ~= nil and true or false
    haveChauffeurMounts = next(RAV_data.mounts.chauffeur) ~= nil and true or false
    normalMountModifier = RAV_data.options.normalMountModifier == "alt" and IsAltKeyDown() or RAV_data.options.normalMountModifier == "ctrl" and IsControlKeyDown() or RAV_data.options.normalMountModifier == "shift" and IsShiftKeyDown() or false
    vendorMountModifier = RAV_data.options.vendorMountModifier == "alt" and IsAltKeyDown() or RAV_data.options.vendorMountModifier == "ctrl" and IsControlKeyDown() or RAV_data.options.vendorMountModifier == "shift" and IsShiftKeyDown() or false
    passengerMountModifier = RAV_data.options.passengerMountModifier == "alt" and IsAltKeyDown() or RAV_data.options.passengerMountModifier == "ctrl" and IsControlKeyDown() or RAV_data.options.passengerMountModifier == "shift" and IsShiftKeyDown() or false
end

local hasSeenNoSpaceMessage = false
function ns:EnsureMacro()
    if not UnitAffectingCombat("player") and RAV_data.options.macro then
        ns:AssignVariables()
        local icon = "INV_Misc_QuestionMark"
        local travelForm = haveTravelForm and RAV_data.mounts.travelForm or nil
        local flying = haveFlyingMounts and RAV_data.mounts.flying or nil
        local ground = (inAhnQiraj and haveAhnQirajMounts) and RAV_data.mounts.ahnqiraj or haveGroundMounts and RAV_data.mounts.ground or nil
        local chauffeur = haveChauffeurMounts and RAV_data.mounts.chauffeur or nil
        local vendor = haveVendorMounts and RAV_data.mounts.vendor or nil
        local passenger = (flyable and havePassengerFlyingMounts) and RAV_data.mounts.passengerFlying or havePassengerGroundMounts and RAV_data.mounts.passengerGround or nil
        local swimming = (inVashjir and haveVashjirMounts) and RAV_data.mounts.vashjir or haveSwimmingMounts and RAV_data.mounts.swimming or nil
        local body = "/ravm"
        if (RAV_data.options.travelForm and travelForm) or flying or ground or chauffeur or vendor or passenger or swimming then
            body = "\n" .. body
            if (RAV_data.options.travelForm and travelForm) then
                local travelFormName, _ = GetSpellInfo(travelForm[1])
                if RAV_data.options.normalMountModifier ~= "none" then
                    body = "[nomod:" .. RAV_data.options.normalMountModifier .. "] " .. travelFormName .. "\n" .. "/use [nomod:" .. RAV_data.options.normalMountModifier .. "] " .. travelFormName .. "\n" .. "/stopmacro [nomod]" .. body
                    local mountName
                    if flying then
                        mountName, _ = CMJ.GetMountInfoByID(flying[random(#flying)])
                    elseif ground then
                        mountName, _ = CMJ.GetMountInfoByID(ground[random(#ground)])
                    elseif chauffeur then
                        mountName, _ = CMJ.GetMountInfoByID(chauffeur[random(#chauffeur)])
                    end
                    if mountName then
                        body = "[mod:" .. RAV_data.options.normalMountModifier .. "] " .. mountName .. "; " .. body
                    end
                else
                    body = travelFormName .. "\n" .. "/use " .. travelFormName
                end
            else
                if ground then
                    local mountName, _ = CMJ.GetMountInfoByID(ground[random(#ground)])
                    body = mountName .. body
                end
                if flying then
                    local mountName, _ = CMJ.GetMountInfoByID(flying[random(#flying)])
                    if flyable and ground then
                        if RAV_data.options.normalMountModifier ~= "none" then
                            body = "[swimming,mod:" .. RAV_data.options.normalMountModifier .. "][nomod:" .. RAV_data.options.normalMountModifier .. "] " .. mountName .. "; " .. body
                        else
                            body = "[] " .. mountName .. "; " .. body
                        end
                    elseif ground and RAV_data.options.normalMountModifier ~= "none" then
                        body = "[noswimming,mod:" .. RAV_data.options.normalMountModifier .. "] " .. mountName .. "; " .. body
                    else
                        body = mountName .. body
                    end
                end
                if chauffeur and ground == nil and flying == nil then
                    icon = "inv_misc_key_06"
                    local mountName, _ = CMJ.GetMountInfoByID(chauffeur[random(#chauffeur)])
                    body = mountName .. body
                end
            end
            if swimming and travelForm == nil then
                local mountName, _ = CMJ.GetMountInfoByID(swimming[random(#swimming)])
                if RAV_data.options.normalMountModifier ~= "none" then
                    body = "[swimming,nomod:" .. RAV_data.options.normalMountModifier .. "] " .. mountName .. ((flying or ground or chauffeur) and "; " or "") .. body
                else
                    body = "[swimming] " .. mountName .. ((flying or ground or chauffeur) and "; " or "") .. body
                end
            end
            if vendor and RAV_data.options.vendorMountModifier ~= "none" then
                local mountName, _ = CMJ.GetMountInfoByID(vendor[random(#vendor)])
                body = "[mod:" .. RAV_data.options.vendorMountModifier .. "] " .. mountName .. ((flying or ground or chauffeur or swimming) and "; " or "") .. body
            end
            if passenger and RAV_data.options.passengerMountModifier ~= "none" then
                local mountName, _ = CMJ.GetMountInfoByID(passenger[random(#passenger)])
                body = "[mod:" .. RAV_data.options.passengerMountModifier .. "] " .. mountName .. ((flying or ground or chauffeur or swimming or vendor) and "; " or "") .. body
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

function ns:RegisterDefaultOption(key, value)
    if RAV_data.options[key] == nil then
        RAV_data.options[key] = value
    end
end

function ns:SetDefaultOptions()
    if RAV_data == nil then
        RAV_data = {}
    end
    if RAV_data.options == nil then
        RAV_data.options = {}
    end
    if RAV_data.options.flexMounts == true or RAV_data.options.flexMounts == false then
        RAV_data.options.flexMounts = nil
    end
    if RAV_data.options.clone == true or RAV_data.options.clone == false then
        RAV_data.options.clone = nil
    end
    for k, v in pairs(defaults) do
        ns:RegisterDefaultOption(k, v)
    end
end

function ns:RegisterControl(control, parentFrame)
    if (not parentFrame) or (not control) then
        return
    end
    parentFrame.controls = parentFrame.controls or {}
    table.insert(parentFrame.controls, control)
end

function ns:CreateLabel(cfg)
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -16
    cfg.relativeTo = cfg.relativeTo or prevControl
    cfg.fontObject = cfg.fontObject or "GameFontNormalLarge"

    local label = cfg.parent:CreateFontString(cfg.name, "ARTWORK", cfg.fontObject)
    label.label = cfg.label
    label.type = cfg.type
    label:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    if cfg.width then
        label:SetWidth(cfg.width)
    end
    label:SetJustifyH("LEFT")
    if cfg.haveMounts then
        label.haveMounts = cfg.haveMounts
        if table.maxn(RAV_data.mounts[cfg.haveMounts]) > 0 then
            label:SetText(string.format(cfg.label, _G.AVAILABLE))
        else
            label:SetText(string.format(cfg.label, _G.UNAVAILABLE))
        end
    elseif cfg.countMounts then
        label.countMounts = cfg.countMounts
        label:SetText(string.format(cfg.label, table.maxn(RAV_data.mounts[cfg.countMounts])))
    else
        label:SetText(cfg.label)
    end

    ns:RegisterControl(label, cfg.parent)
    if not cfg.ignorePlacement then
        prevControl = label
    end

    return label
end

function ns:CreateCheckBox(cfg)
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -6
    cfg.relativeTo = cfg.relativeTo or prevControl

    local checkBox = CreateFrame("CheckButton", cfg.name, cfg.parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox.var = cfg.var
    checkBox.label = cfg.label
    checkBox.type = cfg.type
    checkBox:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    checkBox.Text:SetJustifyH("LEFT")
    checkBox.Text:SetText(cfg.label)
    if cfg.tooltip then
        checkBox.tooltipText = cfg.tooltip
    end

    checkBox.GetValue = function()
        return checkBox:GetChecked()
    end
    checkBox.SetValue = function()
        checkBox:SetChecked(RAV_data.options[cfg.var])
    end

    checkBox:SetScript("OnClick", function(self)
        checkBox.value = self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        RAV_data.options[checkBox.var] = checkBox:GetChecked()
        ns:MountListHandler()
        ns:EnsureMacro()
        ns:RefreshControls(ns.Options.controls)
    end)

    ns:RegisterControl(checkBox, cfg.parent)
    if not cfg.ignorePlacement then
        prevControl = checkBox
    end
    return checkBox
end

function ns:CreateDropDown(cfg)
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -6
    cfg.relativeTo = cfg.relativeTo or prevControl
    cfg.width = cfg.width or 130

    dropdowns[cfg.var] = CreateFrame("Frame", cfg.name, cfg.parent, "UIDropDownMenuTemplate")
    dropdowns[cfg.var].var = cfg.var
    dropdowns[cfg.var].label = cfg.label
    dropdowns[cfg.var].type = cfg.type
    dropdowns[cfg.var]:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    UIDropDownMenu_SetWidth(dropdowns[cfg.var], cfg.width)
    UIDropDownMenu_SetText(dropdowns[cfg.var], cfg.label)
    UIDropDownMenu_Initialize(dropdowns[cfg.var], function()
        for _, value in ipairs(cfg.options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = value:gsub("^%l", string.upper)
            info.checked = RAV_data.options[cfg.var] == value and true or false
            if not info.checked and value ~= "none" and cfg.group == "mountModifier" then
                for _, mountModifier in ipairs(mountModifiers) do
                    if RAV_data.options[mountModifier] == value then
                        info.disabled = true
                    end
                end
            end
            info.func = function(option)
                RAV_data.options[cfg.var] = option.value:lower()
                info.checked = true
                ns:RefreshControls(ns.Options.controls)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    ns:RegisterControl(dropdowns[cfg.var], cfg.parent)
    if not cfg.ignorePlacement then
        prevControl = dropdowns[cfg.var]
    end
    return dropdowns[cfg.var]
end

function ns:RefreshControls(controls)
    ns:MountListHandler()
    ns:EnsureMacro()
    for _, control in pairs(controls) do
        if control.type == "CheckBox" then
            control:SetValue(control)
            control.oldValue = control:GetValue()
        elseif control.type == "DropDown" then
            UIDropDownMenu_SetText(dropdowns[control.var], control.label .. ": " .. RAV_data.options[control.var]:gsub("^%l", string.upper))
        elseif control.haveMounts then
            if table.maxn(RAV_data.mounts[control.haveMounts]) > 0 then
                control:SetText(string.format(control.label, _G.AVAILABLE))
            else
                control:SetText(string.format(control.label, _G.UNAVAILABLE))
            end
            control.oldValue = control:GetText()
        elseif control.countMounts then
            control:SetText(string.format(control.label, table.maxn(RAV_data.mounts[control.countMounts])))
            control.oldValue = control:GetText()
        end
    end
    CloseDropDownMenus()
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
    if RAV_data.options.clone == "both" then
        clone = UnitIsPlayer("target") and "target" or UnitIsPlayer("focus") and "focus" or false
    elseif RAV_data.options.clone == "target" then
        clone = UnitIsPlayer("target") and "target" or false
    elseif RAV_data.options.clone == "focus" then
        clone = UnitIsPlayer("focus") and "focus" or false
    end
    if clone then
        for buffIndex = 1, 40 do
            local mountIndex = contains(RAV_data.mounts.allByName, UnitBuff(clone, buffIndex))
            if mountIndex then
                return RAV_data.mounts.allByID[mountIndex]
            end
        end
    end
    return false
end

function ns:MountListHandler()
    RAV_data.mounts = {}
    RAV_data.mounts.allByName = {}
    RAV_data.mounts.allByID = {}
    RAV_data.mounts.ground = {}
    RAV_data.mounts.flying = {}
    RAV_data.mounts.vendor = {}
    RAV_data.mounts.passengerGround = {}
    RAV_data.mounts.passengerFlying = {}
    RAV_data.mounts.swimming = {}
    RAV_data.mounts.ahnqiraj = {}
    RAV_data.mounts.vashjir = {}
    RAV_data.mounts.maw = {}
    RAV_data.mounts.chauffeur = {}
    mapID = CM.GetBestMapForUnit("player")
    inNazjatar = contains(mapIDs.nazjatar, mapID)
    for _, mountID in pairs(CMJ.GetMountIDs()) do
        local mountName, _, _, _, isUsable, _, isFavorite, _, mountFaction, _, isCollected = CMJ.GetMountInfoByID(mountID)
        local _, _, _, _, mountType = CMJ.GetMountInfoExtraByID(mountID)
        local isGroundMount = contains(mountTypes.ground, mountType)
        local isFlyingMount = contains(mountTypes.flying, mountType)
        local isVendorMount = contains(mountIDs.vendor, mountID)
        local isPassengerGroundMount = contains(mountIDs.passengerGround, mountID)
        local isPassengerFlyingMount = contains(mountIDs.passengerFlying, mountID)
        local isSwimmingMount = contains(mountTypes.swimming, mountType)
        local isAhnQirajMount = contains(mountTypes.ahnqiraj, mountType)
        local isVashjirMount = contains(mountTypes.vashjir, mountType)
        local isMawMount = contains(mountIDs.maw, mountID)
        local isChauffeurMount = contains(mountTypes.chauffeur, mountType)
        local isFlexMount = contains(mountIDs.flex, mountID)
        local hasGroundRiding = hasGroundRiding()
        local hasFlyingRiding = hasFlyingRiding()
        -- 0 = Horde, 1 = Alliance
        if isCollected and not (mountFaction == 0 and faction ~= "Horde") and not (mountFaction == 1 and faction ~= "Alliance") then
            if hasGroundRiding then
                table.insert(RAV_data.mounts.allByName, mountName)
                table.insert(RAV_data.mounts.allByID, mountID)
                if isFlyingMount and (not RAV_data.options.normalMounts or isFavorite) and not isVendorMount and not isPassengerFlyingMount and not isPassengerGroundMount then
                    if isFlexMount then
                        if RAV_data.options.flexMounts == "both" or RAV_data.options.flexMounts == "ground" then
                            table.insert(RAV_data.mounts.ground, mountID)
                        end
                        if hasFlyingRiding and RAV_data.options.flexMounts == "both" or RAV_data.options.flexMounts == "flying" then
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
                if isAhnQirajMount then
                    table.insert(RAV_data.mounts.ahnqiraj, mountID)
                end
                if isVashjirMount then
                    table.insert(RAV_data.mounts.vashjir, mountID)
                end
                if isMawMount then
                    table.insert(RAV_data.mounts.maw, mountID)
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
    elseif className == "SHAMAN" and IsPlayerSpell(ns.data.travelForms["Ghost Wolf"]) then
        table.insert(RAV_data.mounts.travelForm, ns.data.travelForms["Ghost Wolf"])
    end
end

function ns:MountUpHandler(specificType)
    if IsFlying() then
        return
    end
    ns:AssignVariables()
    if (string.match(specificType, "vend") or string.match(specificType, "repair") or string.match(specificType, "trans") or string.match(specificType, "mog")) and haveVendorMounts then
        ns:MountSummon(RAV_data.mounts.vendor)
    elseif (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "multi") or string.match(specificType, "passenger")) and havePassengerFlyingMounts and flyable then
        ns:MountSummon(RAV_data.mounts.passengerFlying)
    elseif string.match(specificType, "fly") and (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "multi") or string.match(specificType, "passenger")) and havePassengerFlyingMounts then
        ns:MountSummon(RAV_data.mounts.passengerFlying)
    elseif (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "multi") or string.match(specificType, "passenger")) and havePassengerGroundMounts then
        ns:MountSummon(RAV_data.mounts.passengerGround)
    elseif string.match(specificType, "swim") and haveSwimmingMounts then
        ns:MountSummon(RAV_data.mounts.swimming)
    elseif (specificType == "vj" or string.match(specificType, "vash") or string.match(specificType, "jir")) and haveVashjirMounts then
        ns:MountSummon(RAV_data.mounts.vashjir)
    elseif string.match(specificType, "fly") and haveFlyingMounts then
        ns:MountSummon(RAV_data.mounts.flying)
    elseif (specificType == "aq" or string.match(specificType, "ahn") or string.match(specificType, "qiraj")) and haveAhnQirajMounts then
        ns:MountSummon(RAV_data.mounts.ahnqiraj)
    elseif specificType == "ground" and haveGroundMounts then
        ns:MountSummon(RAV_data.mounts.ground)
    elseif specificType == "chauffeur" and haveChauffeurMounts then
        ns:MountSummon(RAV_data.mounts.chauffeur)
    elseif (specificType == "copy" or specificType == "clone" or RAV_data.options.clone ~= "none") and cloneMountID then
        CMJ.SummonByID(cloneMountID)
        return
    elseif vendorMountModifier and passengerMountModifier and (IsMounted() or UnitInVehicle("player")) then
        DoEmote(EMOTE171_TOKEN)
        return
    elseif IsMounted() or UnitInVehicle("player") then
        Dismount()
        VehicleExit()
        CancelShapeshiftForm()
        UIErrorsFrame:Clear()
        return
    elseif haveVendorMounts and vendorMountModifier then
        ns:MountSummon(RAV_data.mounts.vendor)
    elseif havePassengerFlyingMounts and flyable and passengerMountModifier and not normalMountModifier then
        ns:MountSummon(RAV_data.mounts.passengerFlying)
    elseif havePassengerGroundMounts and passengerMountModifier and (not flyable or (flyable and normalMountModifier)) then
        ns:MountSummon(RAV_data.mounts.passengerGround)
    elseif haveVashjirMounts and IsSwimming() and not normalMountModifier and inVashjir then
        ns:MountSummon(RAV_data.mounts.vashjir)
    elseif haveSwimmingMounts and IsSwimming() and not normalMountModifier then
        ns:MountSummon(RAV_data.mounts.swimming)
    elseif haveFlyingMounts and ((IsSwimming() and flyable and normalMountModifier) or (flyable and not normalMountModifier) or (not IsSwimming() and not flyable and normalMountModifier)) then
        ns:MountSummon(RAV_data.mounts.flying)
    elseif inAhnQiraj and haveAhnQirajMounts then
        ns:MountSummon(RAV_data.mounts.ahnqiraj)
    elseif haveGroundMounts then
        ns:MountSummon(RAV_data.mounts.ground)
    elseif haveFlyingMounts then
        ns:MountSummon(RAV_data.mounts.flying)
    elseif haveChauffeurMounts then
        ns:MountSummon(RAV_data.mounts.chauffeur)
    else
        ns:PrettyPrint(_G.MOUNT_JOURNAL_NO_VALID_FAVORITES)
        return
    end
end

function ns:TooltipLabels()
    hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
        local unit = select(1, ...)
        local spellID = select(10, UnitAura(...))
        if unit ~= "player" and spellID then
            addLabelsFromSpell(self, spellID)
        end
    end)

    hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, ...)
        local unit = select(1, ...)
        local spellID = select(10, UnitBuff(...))
        if unit ~= "player" and spellID then
            addLabelsFromSpell(self, spellID)
        end
    end)

    hooksecurefunc("SetItemRef", function(link)
        if string.find(link, "^spell:") then
            local spellID, _ = strsplit(":", string.sub(link, 7))
            addLabelsFromSpell(ItemRefTooltip, spellID, false)
        end
    end)

    GameTooltip:HookScript("OnTooltipSetSpell", function(self)
        local spellID = select(2, self:GetSpell())
        if spellID then
            for i = 1, self:NumLines() do
                if string.match(_G["GameTooltipTextLeft"..i]:GetText(), ns.name) then
                    return
                end
            end
            addLabelsFromSpell(self, spellID, false)
        end
    end)
end

function ns:CreateOpenOptionsButton(parent)
    local OpenOptions = CreateFrame("Button", ADDON_NAME .. "OpenOptionsButton", MountJournal, "UIPanelButtonTemplate")
    OpenOptions:SetPoint("BOTTOMRIGHT", MountJournal, "BOTTOMRIGHT", -4, 4)
    local OpenOptionsLabel = OpenOptions:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    OpenOptionsLabel:SetPoint("CENTER", OpenOptions, "CENTER")
    OpenOptionsLabel:SetText(ns.name)
    OpenOptions:SetWidth(OpenOptionsLabel:GetWidth() + 16)
    OpenOptions:RegisterForClicks("AnyUp")
    OpenOptions:SetScript("OnMouseUp", function(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
        InterfaceOptionsFrame_OpenToCategory(ns.Options)
        InterfaceOptionsFrame_OpenToCategory(ns.Options)
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
