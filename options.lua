local name, ravMounts = ...
local L = ravMounts.L

local small = 6
local medium = 12
local large = 16

local Options = CreateFrame("Frame", name .. "Options", InterfaceOptionsFramePanelContainer)
Options.name = ravMounts.name
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
    ravMounts:RefreshControls(self.controls)
end

Options:Hide()
Options:SetScript("OnShow", function()
    local fullWidth = Options:GetWidth() - (large * 2)

    local HeaderPanel = CreateFrame("Frame", "HeaderPanel", Options)
    HeaderPanel:SetPoint("TOPLEFT", Options, "TOPLEFT", large, large * -1)
    HeaderPanel:SetWidth(fullWidth)
    HeaderPanel:SetHeight(large * 3)

    local LeftPanel = CreateFrame("Frame", "LeftPanel", Options)
    LeftPanel:SetPoint("TOPLEFT", HeaderPanel, "BOTTOMLEFT", 0, large * -1)
    LeftPanel:SetWidth(fullWidth / 5 * 3 - large)
    LeftPanel:SetHeight(Options:GetHeight() - HeaderPanel:GetHeight() - (large * 2))

    local RightPanel = CreateFrame("Frame", "RightPanel", Options)
    RightPanel:SetPoint("TOPRIGHT", HeaderPanel, "BOTTOMRIGHT", 0, large * -1)
    RightPanel:SetWidth(fullWidth / 5 * 2 - large)
    RightPanel:SetHeight(Options:GetHeight() - HeaderPanel:GetHeight() - (large * 2))

    local UIControls = {
        {
            type = "Label",
            name = "Heading",
            parent = Options,
            label = ravMounts.name .. " v" .. ravMounts.version,
            relativeTo = HeaderPanel,
            relativePoint = "TOPLEFT",
            offsetY = 0,
        },
        {
            type = "Label",
            name = "SubHeading",
            parent = Options,
            label = "|cffffffff" .. ravMounts.notes .. "|r",
            fontObject = "GameFontNormal"
        },
        {
            type = "Label",
            name = "OptionsHeading",
            parent = Options,
            label = L.OptionsHeading,
            relativeTo = LeftPanel,
            relativePoint = "TOPLEFT",
            offsetY = 0,
        },
        {
            type = "CheckBox",
            name = "Macro",
            parent = Options,
            label = L.Macro,
            tooltip = string.format(L.MacroTooltip, ravMounts.name),
            var = "macro",
            offsetY = medium * -1,
        },
        {
            type = "CheckBox",
            name = "Clone",
            parent = Options,
            label = L.Clone,
            tooltip = L.CloneTooltip,
            var = "clone",
        },
        {
            type = "DropDown",
            name = "FlexMounts",
            parent = Options,
            label = L.Flex .. " " .. L.Mounts,
            var = "flexMounts",
            options = {
                "both",
                "ground",
                "flying",
            },
            width = 180,
            offsetX = large * -1,
        },
        {
            type = "Label",
            name = "FavoritesHeading",
            parent = Options,
            label = L.FavoritesHeading,
            offsetX = large,
        },
        {
            type = "CheckBox",
            name = "NormalMounts",
            parent = Options,
            label = L.Ground .. "/" .. L.Flying .. " " .. L.Mounts,
            tooltip = string.format(L.MountsTooltip, L.Ground .. "/" .. L.Flying .. " " .. L.Mounts),
            var = "normalMounts",
            offsetY = medium * -1,
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
            label = L.Vendor .. " " .. L.Mounts,
            tooltip = string.format(L.MountsTooltip, L.Vendor .. " " .. L.Mounts),
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
            label = L.Passenger .. " " .. L.Mounts,
            tooltip = string.format(L.MountsTooltip, L.Passenger .. " " .. L.Mounts),
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
            label = L.Swimming .. " " .. L.Mounts,
            tooltip = string.format(L.MountsTooltip, L.Swimming .. " " .. L.Mounts),
            var = "swimmingMounts",
        },
        {
            type = "Label",
            name = "SupportHeading",
            parent = Options,
            label = L.SupportHeading,
        },
        {
            type = "Label",
            name = "SubHeadingSupport1",
            parent = Options,
            label = "|cffffffff" .. string.format(L.Support1, ravMounts.name) .. "|r",
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
            label = "|cffffffff" .. string.format(L.Support3, ravMounts.discord) .. "|r",
            fontObject = "GameFontNormal",
        },
        {
            type = "Label",
            name = "DataHeading",
            parent = Options,
            label = L.DataHeading,
            relativeTo = RightPanel,
            relativePoint = "TOPLEFT",
            offsetY = 0,
        },
        {
            type = "Label",
            name = "SubHeadingTotal",
            parent = Options,
            label = L.Total .. ": |cffffffff%s|r",
            countMounts = "allByName",
            fontObject = "GameFontNormal",
        },
        {
            type = "Label",
            name = "SubHeadingGround",
            parent = Options,
            label = L.Ground .. ": |cffffffff%s|r",
            countMounts = "ground",
            fontObject = "GameFontNormal",
            offsetY = small * -1,
        },
        {
            type = "Label",
            name = "SubHeadingFlying",
            parent = Options,
            label = L.Flying .. ": |cffffffff%s|r",
            countMounts = "flying",
            fontObject = "GameFontNormal",
            offsetY = small * -1,
        },
        {
            type = "Label",
            name = "SubHeadingSwimming",
            parent = Options,
            label = L.Swimming .. ": |cffffffff%s|r",
            countMounts = "swimming",
            fontObject = "GameFontNormal",
            offsetY = small * -1,
        },
        {
            type = "Label",
            name = "SubHeadingVendor",
            parent = Options,
            label = L.Vendor .. ": |cffffffff%s|r",
            countMounts = "vendor",
            fontObject = "GameFontNormal",
            offsetY = small * -1,
        },
        {
            type = "Label",
            name = "SubHeadingPassengerGround",
            parent = Options,
            label = L.PassengerGround .. ": |cffffffff%s|r",
            countMounts = "passengerGround",
            fontObject = "GameFontNormal",
            offsetY = small * -1,
        },
        {
            type = "Label",
            name = "SubHeadingPassengerFlying",
            parent = Options,
            label = L.PassengerFlying .. ": |cffffffff%s|r",
            countMounts = "passengerFlying",
            fontObject = "GameFontNormal",
            offsetY = small * -1,
        },
        {
            type = "Label",
            name = "SubHeadingAhnQiraj",
            parent = Options,
            label = L.AhnQiraj .. ": |cffffffff%s|r",
            countMounts = "ahnqiraj",
            fontObject = "GameFontNormal",
            offsetY = small * -1,
        },
        {
            type = "Label",
            name = "SubHeadingVashjir",
            parent = Options,
            label = L.Vashjir .. ": |cffffffff%s|r",
            countMounts = "vashjir",
            fontObject = "GameFontNormal",
            offsetY = small * -1,
        },
        {
            type = "Label",
            name = "SubHeadingMaw",
            parent = Options,
            label = L.Maw .. ": |cffffffff%s|r",
            countMounts = "maw",
            maps = {1543, 1648},
            fontObject = "GameFontNormal",
            offsetY = small * -1,
        },
    }

    for _, control in pairs(UIControls) do
        if control.type == "Label" then
            ravMounts:CreateLabel(control)
        elseif control.type == "CheckBox" then
            ravMounts:CreateCheckBox(control)
        elseif control.type == "DropDown" then
            ravMounts:CreateDropDown(control)
        end
    end

    ravMounts:RefreshControls(Options.controls)
    Options:SetScript("OnShow", nil)
end)
ravMounts.Options = Options
