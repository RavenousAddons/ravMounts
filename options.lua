local name, ravMounts = ...
local L = ravMounts.L

local Options = CreateFrame("Frame", name .. "Options", InterfaceOptionsFramePanelContainer)
Options.name = ravMounts.name
Options.controlTable = {}
Options.okay = function(self)
    for _, control in pairs(self.controls) do
        RAV_data.options[control.var] = control:GetValue()
    end
    for _, control in pairs(self.controls) do
        if control.restart then
            ReloadUI()
        end
    end
end
Options.cancel = function(self)
    for _, control in pairs(self.controls) do
        if control.oldValue and control.oldValue ~= control.getValue() then
            control:SetValue()
        end
    end
end
Options.default = function(self)
    for _, control in pairs(self.controls) do
        RAV_data.options[control.var] = true
    end
    ReloadUI()
end
Options.refresh = function(self)
    for _, control in pairs(self.controls) do
        if control.Text then
            control:SetValue(control)
            control.oldValue = control:GetValue()
        elseif control.countMounts then
            control:SetText(string.format(control.label, table.maxn(RAV_data.mounts[control.countMounts])))
            control.oldValue = control:GetText()
        end
    end
end
InterfaceOptions_AddCategory(Options)

Options:Hide()
Options:SetScript("OnShow", function()
    local fullWidth = Options:GetWidth() - 32
    local panelWidth = fullWidth / 2 - 16

    local HeaderPanel = CreateFrame("Frame", "HeaderPanel", Options)
    HeaderPanel:SetPoint("TOPLEFT", Options, "TOPLEFT", 16, -16)
    HeaderPanel:SetWidth(fullWidth)
    HeaderPanel:SetHeight(32)

    local LeftPanel = CreateFrame("Frame", "LeftPanel", Options)
    LeftPanel:SetPoint("TOPLEFT", HeaderPanel, "BOTTOMLEFT", 0, -16)
    LeftPanel:SetWidth(panelWidth)
    LeftPanel:SetHeight(Options:GetHeight() - HeaderPanel:GetHeight() - 16)

    local RightPanel = CreateFrame("Frame", "RightPanel", Options)
    RightPanel:SetPoint("TOPRIGHT", HeaderPanel, "BOTTOMRIGHT", 0, -16)
    RightPanel:SetWidth(panelWidth)
    RightPanel:SetHeight(Options:GetHeight() - HeaderPanel:GetHeight() - 16)

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
        },
        {
            type = "CheckBox",
            name = "Macro",
            parent = Options,
            label = L.Macro,
            tooltip = string.format(L.MacroTooltip, ravMounts.name),
            var = "macro",
            offsetY = -12,
        },
        {
            type = "CheckBox",
            name = "FlexMounts",
            parent = Options,
            label = L.FlexMounts,
            tooltip = L.FlexMountsTooltip,
            var = "flexMounts",
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
            type = "Label",
            name = "FavoritesHeading",
            parent = Options,
            label = L.FavoritesHeading,
        },
        {
            type = "CheckBox",
            name = "NormalMounts",
            parent = Options,
            label = L.NormalMounts,
            tooltip = L.NormalMountsTooltip,
            var = "normalMounts",
            offsetY = -12,
        },
        {
            type = "CheckBox",
            name = "SwimmingMounts",
            parent = Options,
            label = L.SwimmingMounts,
            tooltip = L.SwimmingMountsTooltip,
            var = "swimmingMounts",
        },
        {
            type = "CheckBox",
            name = "VendorMounts",
            parent = Options,
            label = L.VendorMounts,
            tooltip = L.VendorMountsTooltip,
            var = "vendorMounts",
        },
        {
            type = "CheckBox",
            name = "PassengerMounts",
            parent = Options,
            label = L.PassengerMounts,
            tooltip = L.PassengerMountsTooltip,
            var = "passengerMounts",
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
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingFlying",
            parent = Options,
            label = L.Flying .. ": |cffffffff%s|r",
            countMounts = "flying",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingSwimming",
            parent = Options,
            label = L.Swimming .. ": |cffffffff%s|r",
            countMounts = "swimming",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingVendor",
            parent = Options,
            label = L.Vendor .. ": |cffffffff%s|r",
            countMounts = "vendor",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingPassengerGround",
            parent = Options,
            label = L.PassengerGround .. ": |cffffffff%s|r",
            countMounts = "groundPassenger",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingPassengerFlying",
            parent = Options,
            label = L.PassengerFlying .. ": |cffffffff%s|r",
            countMounts = "flyingPassenger",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingAhnQiraj",
            parent = Options,
            label = L.AhnQiraj .. ": |cffffffff%s|r",
            countMounts = "ahnqiraj",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingVashjir",
            parent = Options,
            label = L.Vashjir .. ": |cffffffff%s|r",
            countMounts = "vashjir",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingMaw",
            parent = Options,
            label = L.Maw .. ": |cffffffff%s|r",
            countMounts = "maw",
            maps = {1543, 1648},
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
    }

    for _, control in pairs(UIControls) do
        if control.type == "Label" then
            ravMounts:CreateLabel(control)
        elseif control.type == "CheckBox" then
            ravMounts:CreateCheckBox(control)
        end
    end

    ravMounts:RefreshControls(Options.controls)
    Options:SetScript("OnShow", nil)
end)
ravMounts.Options = Options
