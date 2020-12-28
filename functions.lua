local name, ravMounts = ...
local L = ravMounts.L

local faction, _ = UnitFactionGroup("player")

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

function ravMounts:MountSummon(list)
    local inCombat = UnitAffectingCombat("player")
    if not inCombat and #list > 0 then
        C_MountJournal.SummonByID(list[random(#list)])
    end
end

function ravMounts:GetCloneMount()
    local id = false
    local clone = UnitIsPlayer("target") and "target" or UnitIsPlayer("focus") and "focus" or false
    if clone then
        for buffIndex = 1, 40 do
            for mountIndex = 1, table.maxn(RAV_data.mounts.allByName) do
                if UnitBuff(clone, buffIndex) == RAV_data.mounts.allByName[mountIndex] then
                    id = RAV_data.mounts.allByID[mountIndex]
                    break
                end
            end
            if id then
                break
            end
        end
    end
    return id
end

function ravMounts:EnsureMacro()
    if not UnitAffectingCombat("player") and RAV_data.options.macro then
        local mapID = C_Map.GetBestMapForUnit("player")
        local inAhnQiraj = (mapID == 319 or mapID == 320 or mapID == 321) and true or false
        local inVashjir = (mapID == 201 or mapID == 203 or mapID == 204 or mapID == 205 or mapID == 1272) and true or false
        local inMaw = (mapID == 1543 or mapID == 1648) and true or false
        local haveGroundMounts = next(RAV_data.mounts.ground) ~= nil and true or false
        local haveFlyingMounts = next(RAV_data.mounts.flying) ~= nil and true or false
        local haveGroundPassengerMounts = next(RAV_data.mounts.groundPassenger) ~= nil and true or false
        local haveFlyingPassengerMounts = next(RAV_data.mounts.flyingPassenger) ~= nil and true or false
        local haveVendorMounts = next(RAV_data.mounts.vendor) ~= nil and true or false
        local haveSwimmingMounts = next(RAV_data.mounts.swimming) ~= nil and true or false
        local haveAhnQirajMounts = next(RAV_data.mounts.ahnqiraj) ~= nil and true or false
        local haveVashjirMounts = next(RAV_data.mounts.vashjir) ~= nil and true or false
        local haveMawMounts = next(RAV_data.mounts.maw) ~= nil and true or false
        local flying = haveFlyingMounts and RAV_data.mounts.flying or nil
        local ground = (inAhnQiraj and haveAhnQirajMounts) and RAV_data.mounts.ahnqiraj or (inMaw and haveMawMounts) and RAV_data.mounts.maw or haveGroundMounts and RAV_data.mounts.ground or nil
        local vendor = haveVendorMounts and RAV_data.mounts.vendor or nil
        local passenger = haveFlyingPassengerMounts and RAV_data.mounts.flyingPassenger or haveGroundPassengerMounts and RAV_data.mounts.groundPassenger or nil
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
    local isFlyingMount, isGroundMount, isVendorMount, isFlyingPassengerMount, isGroundPassengerMount, isSwimmingMount, isVashjirMount, isAhnQirajMount, isChauffeurMount, isFlexMount
    -- Let's start looping over our Mount Journal adding Mounts to their
    -- respective groups
    for _, mountID in pairs(C_MountJournal.GetMountIDs()) do
        local mountName, spellID, _, _, isUsable, _, isFavorite, _, mountFaction, hiddenOnCharacter, isCollected = C_MountJournal.GetMountInfoByID(mountID)
        local _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
        isGroundMount = (mountType == 230)
        isFlyingMount = (mountType == 247 or mountType == 248)
        isSwimmingMount = (mountType == 231 or mountType == 254)
        isAhnQirajMount = (mountType == 241)
        isVashjirMount = (mountType == 232)
        isChauffeurMount = (mountType == 284)
        isMawMount = (mountID == 1304 or mountID == 1442)
        isVendorMount = (mountID == 280 or mountID == 284 or mountID == 460 or mountID == 1039)
        isFlyingPassengerMount = (mountID == 382 or mountID == 407 or mountID == 455 or mountID == 959 or mountID == 960)
        isGroundPassengerMount = (mountID == 240 or mountID == 254 or mountID == 255 or mountID == 275 or mountID == 286 or mountID == 287 or mountID == 288 or mountID == 289)
        isFlexMount = (mountID == 219 or mountID == 363 or mountID == 376 or mountID == 421 or mountID == 439 or mountID == 451 or mountID == 455 or mountID == 456 or mountID == 457 or mountID == 458 or mountID == 459 or mountID == 468 or mountID == 522 or mountID == 523 or mountID == 532 or mountID == 594 or mountID == 547 or mountID == 593 or mountID == 764 or mountID == 1222 or mountID == 1404)
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
                    if RAV_data.options.flexMounts and isFlexMount then
                        table.insert(RAV_data.mounts.ground, mountID)
                    end
                    table.insert(RAV_data.mounts.flying, mountID)
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
    -- Simplify the appearance of the logic later by casting our checks to
    -- simple variables
    local flyable = ravMounts:IsFlyableArea()
    local cloneMountID = ravMounts:GetCloneMount()
    local submerged = IsSwimming()
    local mapID = C_Map.GetBestMapForUnit("player")
    local inAhnQiraj = (mapID == 319 or mapID == 320 or mapID == 321) and true or false
    local inVashjir = (mapID == 201 or mapID == 203 or mapID == 204 or mapID == 205 or mapID == 1272) and true or false
    local inMaw = (mapID == 1543 or mapID == 1648) and true or false
    local haveGroundMounts = next(RAV_data.mounts.ground) ~= nil and true or false
    local haveFlyingMounts = next(RAV_data.mounts.flying) ~= nil and true or false
    local haveGroundPassengerMounts = next(RAV_data.mounts.groundPassenger) ~= nil and true or false
    local haveFlyingPassengerMounts = next(RAV_data.mounts.flyingPassenger) ~= nil and true or false
    local haveVendorMounts = next(RAV_data.mounts.vendor) ~= nil and true or false
    local haveSwimmingMounts = next(RAV_data.mounts.swimming) ~= nil and true or false
    local haveAhnQirajMounts = next(RAV_data.mounts.ahnqiraj) ~= nil and true or false
    local haveVashjirMounts = next(RAV_data.mounts.vashjir) ~= nil and true or false
    local haveMawMounts = next(RAV_data.mounts.maw) ~= nil and true or false
    local haveChauffeurMounts = next(RAV_data.mounts.chauffeur) ~= nil and true or false

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
end

function ravMounts:SetDefaultOptions()
    for k, v in pairs(ravMounts.defaults) do
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

local prevControl

function ravMounts:CreateLabel(cfg)
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -16
    cfg.relativeTo = cfg.relativeTo or prevControl
    cfg.fontObject = cfg.fontObject or "GameFontNormalLarge"

    local label = cfg.parent:CreateFontString(cfg.name, "ARTWORK", cfg.fontObject)
    label:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    if cfg.labelInsert then
        label.label = cfg.label
        label.labelInsert = cfg.labelInsert
        label:SetText(string.format(cfg.label, table.maxn(RAV_data.mounts[cfg.labelInsert])))
    else
        label:SetText(cfg.label)
    end
    if cfg.width then
        label:SetWidth(cfg.width)
    end

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
    checkBox.GetValue = function(self) return checkBox:GetChecked() end
    checkBox.SetValue = function(self) checkBox:SetChecked(RAV_data.options[cfg.var]) end
    checkBox.var = cfg.var

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

function ravMounts:RefreshControls(controls)
    for _, control in pairs(controls) do
        if control.Text then
            control:SetValue(control)
            control.oldValue = control:GetValue()
        elseif control.labelInsert then
            control:SetText(string.format(control.label, table.maxn(RAV_data.mounts[control.labelInsert])))
            control.oldValue = control:GetText()
        end
    end
end
