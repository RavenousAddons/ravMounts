local name, ravMounts = ...
local L = ravMounts.L
local mountTypes = ravMounts.data.mountTypes
local mountIDs = ravMounts.data.mountIDs
local mapIDs = ravMounts.data.mapIDs

local faction, _ = UnitFactionGroup("player")
local flyable, cloneMountID, submerged, mapID, inAhnQiraj, inVashjir, inMaw, haveGroundMounts, haveFlyingMounts, haveGroundPassengerMounts, haveFlyingPassengerMounts, haveVendorMounts, haveSwimmingMounts, haveAhnQirajMounts, haveVashjirMounts, haveMawMounts, haveChauffeurMounts
local prevControl
local dropDown
local options = {}

local function contains(table, input)
    for index, value in ipairs(table) do
        if value == input then
            return index
        end
    end
    return false
end

function ravMounts:PrettyPrint(message, full)
    if full == false then
        message = message .. ":"
    end
    local prefix = "|cff" .. ravMounts.color .. ravMounts.name .. (full and " " or ":|r ")
    DEFAULT_CHAT_FRAME:AddMessage(prefix .. message)
end

function ravMounts:SendVersion()
    local inInstance, _ = IsInInstance()
    if inInstance then
        C_ChatInfo.SendAddonMessage(name, RAV_version, "INSTANCE_CHAT")
    elseif IsInGroup() then
        if GetNumGroupMembers() > 5 then
            C_ChatInfo.SendAddonMessage(name, RAV_version, "RAID")
        end
        C_ChatInfo.SendAddonMessage(name, RAV_version, "PARTY")
    end
    local guildName, _, _, _ = GetGuildInfo("player")
    if guildName then
        C_ChatInfo.SendAddonMessage(name, RAV_version, "GUILD")
    end
end

function ravMounts:AssignVariables()
    flyable = ravMounts:IsFlyableArea()
    cloneMountID = ravMounts:GetCloneMount()
    submerged = IsSwimming()
    mapID = C_Map.GetBestMapForUnit("player")
    inAhnQiraj = contains(mapIDs.ahnqiraj, mapID)
    inVashjir = contains(mapIDs.vashjir, mapID)
    inMaw = contains(mapIDs.maw, mapID)
    haveGroundMounts = next(RAV_data.mounts.ground) ~= nil and true or false
    haveFlyingMounts = next(RAV_data.mounts.flying) ~= nil and true or false
    haveGroundPassengerMounts = next(RAV_data.mounts.groundPassenger) ~= nil and true or false
    haveFlyingPassengerMounts = next(RAV_data.mounts.flyingPassenger) ~= nil and true or false
    haveVendorMounts = next(RAV_data.mounts.vendor) ~= nil and true or false
    haveSwimmingMounts = next(RAV_data.mounts.swimming) ~= nil and true or false
    haveAhnQirajMounts = next(RAV_data.mounts.ahnqiraj) ~= nil and true or false
    haveVashjirMounts = next(RAV_data.mounts.vashjir) ~= nil and true or false
    haveMawMounts = next(RAV_data.mounts.maw) ~= nil and true or false
    haveChauffeurMounts = next(RAV_data.mounts.chauffeur) ~= nil and true or false
end

function ravMounts:EnsureMacro()
    if not UnitAffectingCombat("player") and RAV_data.options.macro then
        ravMounts:AssignVariables()
        local flying = haveFlyingMounts and RAV_data.mounts.flying or nil
        local ground = (inAhnQiraj and haveAhnQirajMounts) and RAV_data.mounts.ahnqiraj or (inMaw and haveMawMounts) and RAV_data.mounts.maw or haveGroundMounts and RAV_data.mounts.ground or nil
        local vendor = haveVendorMounts and RAV_data.mounts.vendor or nil
        local passenger = (flyable and haveFlyingPassengerMounts) and RAV_data.mounts.flyingPassenger or haveGroundPassengerMounts and RAV_data.mounts.groundPassenger or nil
        local swimming = (inVashjir and haveVashjirMounts) and RAV_data.mounts.vashjir or haveSwimmingMounts and RAV_data.mounts.swimming or nil
        local body = "/" .. ravMounts.command
        if ground or flying or vendor or passenger or swimming then
            body = "\n" .. body
            if ground then
                local mountName, _ = C_MountJournal.GetMountInfoByID(ground[random(#ground)])
                body = mountName .. body
            end
            if flying then
                local mountName, _ = C_MountJournal.GetMountInfoByID(flying[random(#flying)])
                if ground then
                    body = "[flyable,nomod:alt][noflyable,mod:alt] " .. mountName .. "; " .. body
                else
                    body = mountName .. body
                end
            end
            if swimming then
                local mountName, _ = C_MountJournal.GetMountInfoByID(swimming[random(#swimming)])
                if ground or flying then
                    body = "[swimming,nomod:alt] " .. mountName .. "; " .. body
                else
                    body = "[swimming] " .. mountName .. body
                end
            end
            if passenger then
                local mountName, _ = C_MountJournal.GetMountInfoByID(passenger[random(#passenger)])
                if ground or flying then
                    body = "[mod:ctrl] " .. mountName .. "; " .. body
                else
                    body = "[mod:ctrl] " .. mountName .. body
                end
            end
            if vendor then
                local mountName, _ = C_MountJournal.GetMountInfoByID(vendor[random(#vendor)])
                if ground or flying then
                    body = "[mod:shift] " .. mountName .. "; " .. body
                else
                    body = "[mod:shift] " .. mountName .. body
                end
            end
            body = "#showtooltip " .. body
        end
        -- Max: 120 Global, 18 Character (so we'll make ours global)
        local numberOfMacros, _ = GetNumMacros()
        -- Edit if it exists, create if not
        if body == RAV_macroBody then
            -- Do nothing
        elseif GetMacroIndexByName(ravMounts.name) > 0 then
            EditMacro(GetMacroIndexByName(ravMounts.name), ravMounts.name, "INV_Misc_QuestionMark", body)
            RAV_macroBody = body
        elseif numberOfMacros < 120 then
            CreateMacro(ravMounts.name, "INV_Misc_QuestionMark", body)
            RAV_macroBody = body
        elseif not hasSeenNoSpaceMessage then
            -- This isn't saved to remind the player on each load
            hasSeenNoSpaceMessage = true
            ravMounts:PrettyPrint(L.NoMacroSpace)
        end
    end
end

function ravMounts:RegisterDefaultOption(key, value)
    if RAV_data == nil then
        RAV_data = {}
    end
    if RAV_data.options == nil then
        RAV_data.options = {}
    end
    if RAV_data.options[key] == nil then
        RAV_data.options[key] = value
    end
    if RAV_data.options.flexMounts == true or RAV_data.options.flexMounts == false then
        RAV_data.options.flexMounts = nil
    end
end

function ravMounts:SetDefaultOptions()
    for k, v in pairs(ravMounts.data.defaults) do
        ravMounts:RegisterDefaultOption(k, v)
    end
end

function ravMounts:RegisterControl(control, parentFrame)
    if (not parentFrame) or (not control) then
        return
    end
    parentFrame.controls = parentFrame.controls or {}
    tinsert(parentFrame.controls, control)
end

function ravMounts:CreateLabel(cfg)
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -16
    cfg.relativeTo = cfg.relativeTo or prevControl
    cfg.fontObject = cfg.fontObject or "GameFontNormalLarge"

    local label = cfg.parent:CreateFontString(cfg.name, "ARTWORK", cfg.fontObject)
    label:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    if cfg.countMounts then
        label.countMounts = cfg.countMounts
        label:SetText(string.format(cfg.label, table.maxn(RAV_data.mounts[cfg.countMounts])))
    else
        label:SetText(cfg.label)
    end
    if cfg.width then
        label:SetWidth(cfg.width)
    end
    label.label = cfg.label
    label.type = cfg.type

    ravMounts:RegisterControl(label, cfg.parent)
    prevControl = label
    return label
end

function ravMounts:CreateCheckBox(cfg)
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -6
    cfg.relativeTo = cfg.relativeTo or prevControl

    local checkBox = CreateFrame("CheckButton", cfg.name, cfg.parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    checkBox.Text:SetText(cfg.label)
    checkBox.GetValue = function(self)
        return checkBox:GetChecked()
    end
    checkBox.SetValue = function(self)
        checkBox:SetChecked(RAV_data.options[cfg.var])
    end
    checkBox.var = cfg.var
    checkBox.label = cfg.label
    checkBox.type = cfg.type

    if cfg.needsRestart then
        checkBox.restart = false
    end

    if cfg.tooltip then
        if cfg.needsRestart then
            cfg.tooltip = cfg.tooltip .. "\n" .. RED_FONT_COLOR:WrapTextInColorCode(REQUIRES_RELOAD)
        end
        checkBox.tooltipText = cfg.tooltip
    end

    checkBox:SetScript("OnClick", function(self)
        checkBox.value = self:GetChecked()
        if cfg.needsRestart then
            checkBox.restart = not checkBox.restart
        end
        RAV_data.options[checkBox.var] = checkBox:GetChecked()
        ravMounts:MountListHandler()
        ravMounts:EnsureMacro()
        ravMounts:RefreshControls(ravMounts.Options.controls)
    end)

    ravMounts:RegisterControl(checkBox, cfg.parent)
    prevControl = checkBox
    return checkBox
end

function ravMounts:CreateDropDown(cfg)
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -6
    cfg.relativeTo = cfg.relativeTo or prevControl

    dropDown = CreateFrame("Frame", cfg.name, cfg.parent, "UIDropDownMenuTemplate")
    dropDown:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    UIDropDownMenu_SetWidth(dropDown, 180)
    UIDropDownMenu_SetText(dropDown, cfg.label)
    dropDown.var = cfg.var
    dropDown.label = cfg.label
    dropDown.type = cfg.type

    UIDropDownMenu_Initialize(dropDown, function(self)
        for _, value in ipairs(cfg.options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = value:gsub("^%l", string.upper)
            info.checked = RAV_data.options[dropDown.var] == value and true or false
            info.func = function(option)
                RAV_data.options[dropDown.var] = option.value:lower()
                info.checked = true
                CloseDropDownMenus()
                ravMounts:MountListHandler()
                ravMounts:EnsureMacro()
                ravMounts:RefreshControls(ravMounts.Options.controls)
            end
            UIDropDownMenu_AddButton(info)
            options[value] = info
        end
    end)

    ravMounts:RegisterControl(dropDown, cfg.parent)
    prevControl = dropDown
    return dropDown
end

function ravMounts:RefreshControls(controls)
    for i, control in pairs(controls) do
        if control.type == "CheckBox" then
            control:SetValue(control)
            control.oldValue = control:GetValue()
        elseif control.type == "DropDown" then
            UIDropDownMenu_SetText(dropDown, control.label .. ": " .. RAV_data.options[control.var]:gsub("^%l", string.upper))
            -- for _, option in pairs(options) do
            --     print(option.text)
            -- end
        elseif control.countMounts then
            control:SetText(string.format(control.label, table.maxn(RAV_data.mounts[control.countMounts])))
            control.oldValue = control:GetText()
        end
    end
end

function ravMounts:MountSummon(list)
    if not UnitAffectingCombat("player") and #list > 0 then
        local iter = 10 -- magic number (can random fail us so much?)
        local n = random(#list)
        while not select(5, C_MountJournal.GetMountInfoByID(list[n])) and iter > 0 do
            n = random(#list)
            iter = iter - 1
        end
        C_MountJournal.SummonByID(list[n])
    end
end

function ravMounts:GetCloneMount()
    local clone = UnitIsPlayer("target") and "target" or UnitIsPlayer("focus") and "focus" or false
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

-- Collect Data and Sort it
function ravMounts:MountListHandler()
    -- Reset the mount data to be repopulated
    RAV_data.mounts = {}
    RAV_data.mounts.allByName = {}
    RAV_data.mounts.allByID = {}
    RAV_data.mounts.ground = {}
    RAV_data.mounts.flying = {}
    RAV_data.mounts.groundPassenger = {}
    RAV_data.mounts.flyingPassenger = {}
    RAV_data.mounts.vendor = {}
    RAV_data.mounts.swimming = {}
    RAV_data.mounts.ahnqiraj = {}
    RAV_data.mounts.vashjir = {}
    RAV_data.mounts.maw = {}
    RAV_data.mounts.chauffeur = {}
    -- Let's start looping over our Mount Journal adding Mounts to their
    -- respective groups
    for _, mountID in pairs(C_MountJournal.GetMountIDs()) do
        local mountName, spellID, _, _, isUsable, _, isFavorite, _, mountFaction, hiddenOnCharacter, isCollected = C_MountJournal.GetMountInfoByID(mountID)
        local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
        local isGroundMount = contains(mountTypes.ground, mountType)
        local isFlyingMount = contains(mountTypes.flying, mountType)
        local isSwimmingMount = contains(mountTypes.swimming, mountType)
        local isAhnQirajMount = contains(mountTypes.ahnqiraj, mountType)
        local isVashjirMount = contains(mountTypes.vashjir, mountType)
        local isChauffeurMount = contains(mountTypes.chauffeur, mountType)
        local isVendorMount = contains(mountIDs.vendor, mountID)
        local isMawMount = contains(mountIDs.maw, mountID)
        local isFlyingPassengerMount = contains(mountIDs.flyingPassenger, mountID)
        local isGroundPassengerMount = contains(mountIDs.groundPassenger, mountID)
        local isFlexMount = contains(mountIDs.flex, mountID)
        if isCollected then
            -- 0 = Horde, 1 = Alliance
            -- Check for mismatch, means not available
            if mountFaction == 0 and faction ~= "Horde" then
                -- skip
            elseif mountFaction == 1 and faction ~= "Alliance" then
                -- skip
            else
                table.insert(RAV_data.mounts.allByName, mountName)
                table.insert(RAV_data.mounts.allByID, mountID)
                if isFlyingMount and (not RAV_data.options.normalMounts or isFavorite) and not isVendorMount and not isFlyingPassengerMount and not isGroundPassengerMount then
                    if isFlexMount then
                        if RAV_data.options.flexMounts == "both" or RAV_data.options.flexMounts == "ground" then
                            table.insert(RAV_data.mounts.ground, mountID)
                        end
                        if RAV_data.options.flexMounts == "both" or RAV_data.options.flexMounts == "flying" then
                            table.insert(RAV_data.mounts.flying, mountID)
                        end
                    else
                        table.insert(RAV_data.mounts.flying, mountID)
                    end
                end
                if isGroundMount and (isFavorite or not RAV_data.options.normalMounts) and not isVendorMount and not isFlyingPassengerMount and not isGroundPassengerMount then
                    table.insert(RAV_data.mounts.ground, mountID)
                end
                if isVendorMount and (isFavorite or not RAV_data.options.vendorMounts) then
                    table.insert(RAV_data.mounts.vendor, mountID)
                end
                if isFlyingPassengerMount and (isFavorite or not RAV_data.options.passengerMounts) then
                    table.insert(RAV_data.mounts.flyingPassenger, mountID)
                end
                if isGroundPassengerMount and (isFavorite or not RAV_data.options.passengerMounts) then
                    table.insert(RAV_data.mounts.groundPassenger, mountID)
                end
                if isSwimmingMount and (isFavorite or not RAV_data.options.swimmingMounts) then
                    table.insert(RAV_data.mounts.swimming, mountID)
                end
                if isChauffeurMount then
                    table.insert(RAV_data.mounts.chauffeur, mountID)
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
        end
    end
end

-- Check a plethora of conditions and choose the appropriate Mount from the
-- Mount Journal, and do nothing if conditions are not met
function ravMounts:MountUpHandler(specificType)
    -- If we're flying, end here!
    if IsFlying() then
        return
    end
    ravMounts:AssignVariables()
    if ((IsShiftKeyDown() and IsAltKeyDown()) or (IsShiftKeyDown() and IsControlKeyDown())) and (IsMounted() or UnitInVehicle("player")) then
        DoEmote(EMOTE171_TOKEN)
    elseif IsShiftKeyDown() and haveVendorMounts then
        ravMounts:MountSummon(RAV_data.mounts.vendor)
    elseif IsControlKeyDown() and flyable and not IsAltKeyDown() and haveFlyingPassengerMounts then
        ravMounts:MountSummon(RAV_data.mounts.flyingPassenger)
    elseif IsControlKeyDown() and (not flyable or (flyable and IsAltKeyDown())) and haveGroundPassengerMounts then
        ravMounts:MountSummon(RAV_data.mounts.groundPassenger)
    elseif (string.match(specificType, "vend") or string.match(specificType, "repair") or string.match(specificType, "trans") or string.match(specificType, "mog")) and haveVendorMounts then
        ravMounts:MountSummon(RAV_data.mounts.vendor)
    elseif (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "multi") or string.match(specificType, "passenger")) and haveFlyingPassengerMounts and flyable then
        ravMounts:MountSummon(RAV_data.mounts.flyingPassenger)
    elseif string.match(specificType, "fly") and (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "multi") or string.match(specificType, "passenger")) and haveFlyingPassengerMounts then
        ravMounts:MountSummon(RAV_data.mounts.flyingPassenger)
    elseif (string.match(specificType, "2") or string.match(specificType, "two") or string.match(specificType, "multi") or string.match(specificType, "passenger")) and haveGroundPassengerMounts then
        ravMounts:MountSummon(RAV_data.mounts.groundPassenger)
    elseif string.match(specificType, "swim") and haveSwimmingMounts then
        ravMounts:MountSummon(RAV_data.mounts.swimming)
    elseif (specificType == "vj" or string.match(specificType, "vash") or string.match(specificType, "jir")) and haveVashjirMounts then
        ravMounts:MountSummon(RAV_data.mounts.vashjir)
    elseif string.match(specificType, "fly") and haveFlyingMounts then
        ravMounts:MountSummon(RAV_data.mounts.flying)
    elseif (specificType == "aq" or string.match(specificType, "ahn") or string.match(specificType, "qiraj")) and haveAhnQirajMounts then
        ravMounts:MountSummon(RAV_data.mounts.ahnqiraj)
    elseif specificType == "ground" and haveGroundMounts then
        ravMounts:MountSummon(RAV_data.mounts.ground)
    elseif specificType == "chauffeur" and haveChauffeurMounts then
        ravMounts:MountSummon(RAV_data.mounts.chauffeur)
    elseif (specificType == "copy" or specificType == "clone" or RAV_data.options.clone) and cloneMountID then
        C_MountJournal.SummonByID(cloneMountID)
    elseif IsMounted() or UnitInVehicle("player") then
        Dismount()
        VehicleExit()
        CancelShapeshiftForm()
        UIErrorsFrame:Clear()
    elseif haveFlyingMounts and ((flyable and not IsAltKeyDown() and not submerged) or (not flyable and IsAltKeyDown())) then
        ravMounts:MountSummon(RAV_data.mounts.flying)
    elseif inVashjir and submerged and haveVashjirMounts then
        ravMounts:MountSummon(RAV_data.mounts.vashjir)
    elseif submerged and haveSwimmingMounts then
        ravMounts:MountSummon(RAV_data.mounts.swimming)
    elseif inAhnQiraj and haveAhnQirajMounts then
        ravMounts:MountSummon(RAV_data.mounts.ahnqiraj)
    elseif inMaw and haveMawMounts then
        ravMounts:MountSummon(RAV_data.mounts.maw)
    elseif haveGroundMounts then
        ravMounts:MountSummon(RAV_data.mounts.ground)
    elseif haveFlyingMounts then
        ravMounts:MountSummon(RAV_data.mounts.flying)
    elseif haveChauffeurMounts then
        ravMounts:MountSummon(RAV_data.mounts.chauffeur)
    else
        ravMounts:PrettyPrint(L.NoMounts)
    end
end
