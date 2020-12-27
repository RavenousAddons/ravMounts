local name, ravMounts = ...
local L = ravMounts.L

local Options = CreateFrame("Frame", name .. "Options", InterfaceOptionsFramePanelContainer)
Options.name = ravMounts.name
Options.controlTable = {}
ravMounts.Options = Options
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
        control:SetValue()
        control.oldValue = control:GetValue()
    end
end
InterfaceOptions_AddCategory(Options)

Options:Hide()
Options:SetScript("OnShow", function()
    local panelWidth = Options:GetWidth() / 2

    local LeftSide = CreateFrame("Frame", "LeftSide", Options)
    LeftSide:SetWidth(panelWidth)
    LeftSide:SetHeight(Options:GetHeight())
    LeftSide:SetPoint("TOPLEFT", Options)

    local RightSide = CreateFrame("Frame", "RightSide", Options)
    RightSide:SetWidth(panelWidth)
    RightSide:SetHeight(Options:GetHeight())
    RightSide:SetPoint("TOPRIGHT", Options)

    local UIControls = {
        {
            type = "Label",
            name = "Heading",
            parent = Options,
            label = ravMounts.name .. " v" .. ravMounts.version,
            relativeTo = LeftSide,
            relativePoint = "TOPLEFT",
            offsetX = 16,
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
        },
        {
            type = "CheckBox",
            name = "Macro",
            parent = Options,
            label = L.Macro,
            tooltip = string.format(L.MacroTooltip, ravMounts.name),
            var = "macro",
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
            relativeTo = RightSide,
            relativePoint = "TOPLEFT",
            offsetX = 16,
            offsetY = -77,
        },
        {
            type = "Label",
            name = "SubHeadingTotal",
            parent = Options,
            label = L.Total .. ": |cffffffff%s|r",
            labelInsert = "allByName",
            fontObject = "GameFontNormal",
        },
        {
            type = "Label",
            name = "SubHeadingGround",
            parent = Options,
            label = L.Ground .. ": |cffffffff%s|r",
            labelInsert = "ground",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingFlying",
            parent = Options,
            label = L.Flying .. ": |cffffffff%s|r",
            labelInsert = "flying",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingSwimming",
            parent = Options,
            label = L.Swimming .. ": |cffffffff%s|r",
            labelInsert = "swimming",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingVendor",
            parent = Options,
            label = L.Vendor .. ": |cffffffff%s|r",
            labelInsert = "vendor",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingPassengerGround",
            parent = Options,
            label = L.PassengerGround .. ": |cffffffff%s|r",
            labelInsert = "groundPassenger",
            fontObject = "GameFontNormal",
            offsetY = -6,
        },
        {
            type = "Label",
            name = "SubHeadingPassengerFlying",
            parent = Options,
            label = L.PassengerFlying .. ": |cffffffff%s|r",
            labelInsert = "flyingPassenger",
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

    function Options:Refresh()
        for _, control in pairs(self.controls) do
            if control.Text then
                control:SetValue(control)
                control.oldValue = control:GetValue()
            elseif control.labelInsert then
                control:SetText(string.format(control.label, table.maxn(RAV_data.mounts[control.labelInsert])))
                control.oldValue = control:GetText()
            end
        end
    end

    Options:Refresh()
    Options:SetScript("OnShow", nil)
end)
