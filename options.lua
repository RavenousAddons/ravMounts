local ADDON_NAME, ns = ...
local L = ns.L

local small = 6
local medium = 12
local large = 16

local Options = CreateFrame("Frame", ADDON_NAME .. "Options", InterfaceOptionsFramePanelContainer)
Options.name = ns.name
Options.controlTable = {}
Options.okay = function(self)
    for _, control in pairs(self.controls) do
        RAV_data.options[control.var] = control:GetValue()
    end
end
Options.default = function(self)
    for _, control in pairs(self.controls) do
        RAV_data.options[control.var] = true
    end
end
Options.cancel = function(self)
    for _, control in pairs(self.controls) do
        if control.oldValue and control.oldValue ~= control.getValue() then
            control:SetValue()
        end
    end
end
Options.refresh = function(self)
    ns:RefreshControls(self.controls)
end

Options:Hide()
Options:SetScript("OnShow", function()
    local fullWidth = Options:GetWidth() - (large * 2)

    local HeaderPanel = CreateFrame("Frame", "HeaderPanel", Options)
    HeaderPanel:SetPoint("TOPLEFT", Options, "TOPLEFT", large, -large)
    HeaderPanel:SetWidth(fullWidth)
    HeaderPanel:SetHeight(large * 3)

    local LeftPanel = CreateFrame("Frame", "LeftPanel", Options)
    LeftPanel:SetPoint("TOPLEFT", HeaderPanel, "BOTTOMLEFT", 0, -large)
    LeftPanel:SetWidth(fullWidth / 5 * 3 - large)
    LeftPanel:SetHeight(Options:GetHeight() - HeaderPanel:GetHeight() - (large * 2))

    local RightPanel = CreateFrame("Frame", "RightPanel", Options)
    RightPanel:SetPoint("TOPRIGHT", HeaderPanel, "BOTTOMRIGHT", 0, -large)
    RightPanel:SetWidth(fullWidth / 5 * 2 - large)
    RightPanel:SetHeight(Options:GetHeight() - HeaderPanel:GetHeight() - (large * 2))

    local UIControls = {
        {
            type = "Label",
            name = "Heading",
            parent = Options,
            label = ns.name .. " v" .. ns.version,
            relativeTo = HeaderPanel,
            relativePoint = "TOPLEFT",
            offsetY = 0,
        },
        {
            type = "Label",
            name = "SubHeading",
            parent = Options,
            label = "|cffffffff" .. ns.notes .. "|r",
            fontObject = "GameFontNormal"
        },
        {
            type = "Label",
            name = "OptionsHeading",
            parent = Options,
            label = _G.GAMEOPTIONS_MENU .. ":",
            relativeTo = LeftPanel,
            relativePoint = "TOPLEFT",
        },
        {
            type = "CheckBox",
            name = "Macro",
            parent = Options,
            label = L.Macro,
            tooltip = string.format(L.MacroTooltip, ns.name),
            var = "macro",
            offsetY = -medium,
        },
        {
            type = "DropDown",
            name = "Clone",
            parent = Options,
            label = L.Cloneable .. " " .. _G.MOUNTS,
            var = "clone",
            options = {
                _G.STATUS_TEXT_BOTH:lower(),
                _G.MINIMAP_TRACKING_TARGET:lower(),
                _G.FOCUS:lower(),
                _G.LFG_TYPE_NONE:lower(),
            },
            width = 180,
            offsetX = -large,
        },
        {
            type = "DropDown",
            name = "FlexMounts",
            parent = Options,
            label = _G.PLAYER_DIFFICULTY4 .. " " .. _G.MOUNTS,
            var = "flexMounts",
            options = {
                _G.STATUS_TEXT_BOTH:lower(),
                L.Ground:lower(),
                _G.BATTLE_PET_NAME_3:lower(),
            },
            width = 180,
            offsetX = 0,
        },
        {
            type = "CheckBox",
            name = "TravelForm",
            parent = Options,
            label = L.TravelForm,
            tooltip = L.TravelFormTooltip,
            var = "travelForm",
            offsetX = large,
        },
        {
            type = "Label",
            name = "FavoritesHeading",
            parent = Options,
            label = L.FavoritesHeading,
        },
        {
            type = "CheckBox",
            name = "NormalMounts",
            parent = Options,
            label = L.Ground .. "/" .. _G.BATTLE_PET_NAME_3 .. " " .. _G.MOUNTS,
            tooltip = string.format(L.MountsTooltip, L.Ground .. "/" .. _G.BATTLE_PET_NAME_3 .. " " .. _G.MOUNTS),
            var = "normalMounts",
            offsetY = -medium,
        },
        {
            type = "DropDown",
            name = "NormalMountModifier",
            parent = Options,
            initialPoint = "TOPLEFT",
            relativePoint = "TOPRIGHT",
            offsetX = 140,
            offsetY = 0,
            ignorePlacement = true,
            label = L.Modifier,
            group = "mountModifier",
            var = "normalMountModifier",
            options = {
                "none",
                "alt",
                "ctrl",
                "shift",
            },
        },
        {
            type = "CheckBox",
            name = "VendorMounts",
            parent = Options,
            label = _G.BATTLE_PET_SOURCE_3 .. " " .. _G.MOUNTS,
            tooltip = string.format(L.MountsTooltip, _G.BATTLE_PET_SOURCE_3 .. " " .. _G.MOUNTS),
            var = "vendorMounts",
        },
        {
            type = "DropDown",
            name = "VendorMountModifier",
            parent = Options,
            initialPoint = "TOPLEFT",
            relativePoint = "TOPRIGHT",
            offsetX = 140,
            offsetY = 0,
            ignorePlacement = true,
            label = L.Modifier,
            group = "mountModifier",
            var = "vendorMountModifier",
            options = {
                "none",
                "alt",
                "ctrl",
                "shift",
            },
        },
        {
            type = "CheckBox",
            name = "PassengerMounts",
            parent = Options,
            label = L.Passenger .. " " .. _G.MOUNTS,
            tooltip = string.format(L.MountsTooltip, L.Passenger .. " " .. _G.MOUNTS),
            var = "passengerMounts",
        },
        {
            type = "DropDown",
            name = "PassengerMountModifier",
            parent = Options,
            initialPoint = "TOPLEFT",
            relativePoint = "TOPRIGHT",
            offsetX = 140,
            offsetY = 0,
            ignorePlacement = true,
            label = L.Modifier,
            group = "mountModifier",
            var = "passengerMountModifier",
            options = {
                "none",
                "alt",
                "ctrl",
                "shift",
            },
        },
        {
            type = "CheckBox",
            name = "SwimmingMounts",
            parent = Options,
            label = _G.TUTORIAL_TITLE28 .. " " .. _G.MOUNTS,
            tooltip = string.format(L.MountsTooltip, _G.TUTORIAL_TITLE28 .. " " .. _G.MOUNTS),
            var = "swimmingMounts",
        },
        {
            type = "Label",
            name = "SupportHeading",
            parent = Options,
            label = _G.GAMEMENU_HELP .. ":",
        },
        {
            type = "Label",
            name = "SubHeadingSupport1",
            parent = Options,
            label = "|cffffffff" .. string.format(L.Support1, ns.name, _G.GENERAL_MACROS) .. "|r",
            fontObject = "GameFontNormal",
        },
        {
            type = "Label",
            name = "SubHeadingSupport2",
            parent = Options,
            label = "|cffffffff" .. L.Support2 .. "|r",
            fontObject = "GameFontNormal",
        },
        {
            type = "Label",
            name = "SubHeadingSupport3",
            parent = Options,
            label = "|cffffffff" .. string.format(L.Support3, ns.discord) .. "|r",
            fontObject = "GameFontNormal",
        },
        {
            type = "Label",
            name = "CountHeading",
            parent = Options,
            label = L.CountHeading,
            relativeTo = RightPanel,
            relativePoint = "TOPLEFT",
        },
        {
            type = "Label",
            name = "CountTotal",
            parent = Options,
            label = _G.TOTAL .. ": |cffffffff%s|r",
            countMounts = "allByName",
            fontObject = "GameFontNormal",
        },
        {
            type = "Label",
            name = "CountGround",
            parent = Options,
            label = L.Ground .. ": |cffffffff%s|r",
            countMounts = "ground",
            fontObject = "GameFontNormal",
        },
        {
            type = "Label",
            name = "CountFlying",
            parent = Options,
            label = _G.BATTLE_PET_NAME_3 .. ": |cffffffff%s|r",
            countMounts = "flying",
            fontObject = "GameFontNormal",
            offsetY = -small,
        },
        {
            type = "Label",
            name = "CountSwimming",
            parent = Options,
            label = _G.TUTORIAL_TITLE28 .. ": |cffffffff%s|r",
            countMounts = "swimming",
            fontObject = "GameFontNormal",
            offsetY = -small,
        },
        {
            type = "Label",
            name = "CountVendor",
            parent = Options,
            label = _G.BATTLE_PET_SOURCE_3 .. ": |cffffffff%s|r",
            countMounts = "vendor",
            fontObject = "GameFontNormal",
            offsetY = -small,
        },
        {
            type = "Label",
            name = "CountPassengerGround",
            parent = Options,
            label = L.PassengerGround .. ": |cffffffff%s|r",
            countMounts = "passengerGround",
            fontObject = "GameFontNormal",
            offsetY = -small,
        },
        {
            type = "Label",
            name = "CountPassengerFlying",
            parent = Options,
            label = L.PassengerFlying .. ": |cffffffff%s|r",
            countMounts = "passengerFlying",
            fontObject = "GameFontNormal",
            offsetY = -small,
        },
        {
            type = "Label",
            name = "CountAhnQiraj",
            parent = Options,
            label = L.AhnQiraj .. ": |cffffffff%s|r",
            countMounts = "ahnqiraj",
            fontObject = "GameFontNormal",
        },
        {
            type = "Label",
            name = "CountVashjir",
            parent = Options,
            label = L.Vashjir .. ": |cffffffff%s|r",
            countMounts = "vashjir",
            fontObject = "GameFontNormal",
            offsetY = -small,
        },
        -- {
        --     type = "Label",
        --     name = "CountMaw",
        --     parent = Options,
        --     label = L.Maw .. ": |cffffffff%s|r",
        --     countMounts = "maw",
        --     maps = {1543, 1648},
        --     fontObject = "GameFontNormal",
        --     offsetY = -small,
        -- },
        {
            type = "Label",
            name = "CountChauffeur",
            parent = Options,
            label = L.Chauffeur .. ": |cffffffff%s|r",
            haveMounts = "chauffeur",
            fontObject = "GameFontNormal",
        },
        {
            type = "Label",
            name = "CountTravelForm",
            parent = Options,
            label = "Travel Form" .. ": |cffffffff%s|r",
            haveMounts = "travelForm",
            fontObject = "GameFontNormal",
            offsetY = -small,
        },
    }

    for _, control in pairs(UIControls) do
        if control.type == "Label" then
            ns:CreateLabel(control)
        elseif control.type == "CheckBox" then
            ns:CreateCheckBox(control)
        elseif control.type == "DropDown" then
            ns:CreateDropDown(control)
        end
    end

    ns:RefreshControls(Options.controls)
    Options:SetScript("OnShow", nil)
end)
ns.Options = Options
