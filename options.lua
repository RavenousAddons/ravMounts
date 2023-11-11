local ADDON_NAME, ns = ...
local L = ns.L

-- Reference default values and data tables.
local defaults = ns.data.defaults

local function CreateCheckBox(category, variable, name, tooltip)
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaults[variable]), RAV_data.options[variable])
    Settings.SetOnValueChangedCallback(variable, function(event)
        RAV_data.options[variable] = setting:GetValue()
        ns:MountListHandler()
        ns:EnsureMacro()
    end)
    Settings.CreateCheckBox(category, setting, tooltip)
end

local function CreateDropDown(category, variable, name, options, tooltip)
    local setting = Settings.RegisterAddOnSetting(category, name, variable, type(defaults[variable]), RAV_data.options[variable])
    Settings.SetOnValueChangedCallback(variable, function(event)
        RAV_data.options[variable] = setting:GetValue()
        ns:MountListHandler()
        ns:EnsureMacro()
    end)
    Settings.CreateDropDown(category, setting, options, tooltip)
end

function ns:CreateOpenSettingsButton()
    local OpenSettingsButton = CreateFrame("Button", ADDON_NAME .. "OpenSettingsButtonButton", MountJournal, "UIPanelButtonTemplate")
    OpenSettingsButton:SetPoint("BOTTOMRIGHT", MountJournal, "BOTTOMRIGHT", -4, 4)
    local OpenSettingsButtonLabel = OpenSettingsButton:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    OpenSettingsButtonLabel:SetPoint("CENTER", OpenSettingsButton, "CENTER")
    OpenSettingsButtonLabel:SetText(ns.name)
    OpenSettingsButton:SetWidth(OpenSettingsButtonLabel:GetWidth() + 32)
    OpenSettingsButton:RegisterForClicks("AnyUp")
    OpenSettingsButton:SetScript("OnMouseUp", function(self)
        ns:OpenSettings()
    end)
    OpenSettingsButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self or UIParent)
        GameTooltip:SetText("|cffffffff" .. ns.name .. "|r")
        GameTooltip:AddLine("Open AddOn options.")
        GameTooltip:Show()
    end)
    OpenSettingsButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

function ns:CreateSettingsPanel()
    local category, layout = Settings.RegisterVerticalLayoutCategory(ns.name)

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(_G.GAMEOPTIONS_MENU .. ":"))

    do
        CreateCheckBox(category, "macro", L.Macro, L.MacroTooltip:format(ns.name))
    end

    do
        local variable = "normalMountModifier"
        local name = L.Alternate .. " " .. _G.MOUNTS .. " " .. L.Modifier
        local tooltip = L.NormalModifierTooltip

        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, "None")

            if RAV_data.options[variable] == 2 or (RAV_data.options.vendorMountModifier ~= 2 and RAV_data.options.passengerMountModifier ~= 2) then
                container:Add(2, "ALT key")
            end

            if RAV_data.options[variable] == 3 or (RAV_data.options.vendorMountModifier ~= 3 and RAV_data.options.passengerMountModifier ~= 3) then
                container:Add(3, "CTRL key")
            end

            if RAV_data.options[variable] == 4 or (RAV_data.options.vendorMountModifier ~= 4 and RAV_data.options.passengerMountModifier ~= 4) then
                container:Add(4, "SHIFT key")
            end

            return container:GetData()
        end

        CreateDropDown(category, variable, name, GetOptions, tooltip)
    end

    do
        local variable = "vendorMountModifier"
        local name = _G.BATTLE_PET_SOURCE_3 .. " " .. _G.MOUNTS .. " " .. L.Modifier
        local tooltip = L.ModifierTooltip:format(_G.BATTLE_PET_SOURCE_3 .. " " .. _G.MOUNTS)

        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, "None")

            if RAV_data.options[variable] == 2 or (RAV_data.options.normalMountModifier ~= 2 and RAV_data.options.passengerMountModifier ~= 2) then
                container:Add(2, "ALT key")
            end

            if RAV_data.options[variable] == 3 or (RAV_data.options.normalMountModifier ~= 3 and RAV_data.options.passengerMountModifier ~= 3) then
                container:Add(3, "CTRL key")
            end

            if RAV_data.options[variable] == 4 or (RAV_data.options.normalMountModifier ~= 4 and RAV_data.options.passengerMountModifier ~= 4) then
                container:Add(4, "SHIFT key")
            end

            return container:GetData()
        end

        CreateDropDown(category, variable, name, GetOptions, tooltip)
    end

    do
        local variable = "passengerMountModifier"
        local name = L.Passenger .. " " .. _G.MOUNTS .. " " .. L.Modifier
        local tooltip = L.ModifierTooltip:format(L.Passenger .. " " .. _G.MOUNTS)

        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, "None")

            if RAV_data.options[variable] == 2 or (RAV_data.options.normalMountModifier ~= 2 and RAV_data.options.vendorMountModifier ~= 2) then
                container:Add(2, "ALT key")
            end

            if RAV_data.options[variable] == 3 or (RAV_data.options.normalMountModifier ~= 3 and RAV_data.options.vendorMountModifier ~= 3) then
                container:Add(3, "CTRL key")
            end

            if RAV_data.options[variable] == 4 or (RAV_data.options.normalMountModifier ~= 4 and RAV_data.options.vendorMountModifier ~= 4) then
                container:Add(4, "SHIFT key")
            end

            return container:GetData()
        end

        CreateDropDown(category, variable, name, GetOptions, tooltip)
    end

    do
        local variable = "preferDragonRiding"
        local name = L.PreferDragonRiding
        local tooltip = L.PreferDragonRidingTooltip

        CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "travelForm"
        local name = L.TravelForm
        local tooltip = L.TravelFormTooltip

        CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "normalSwimmingMounts"
        local name = L.NormalSwimming
        local tooltip = L.NormalSwimmingTooltip

        CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "clone"
        local name = L.Cloneable .. " " .. _G.MOUNTS
        local tooltip = L.CloneableTooltip

        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, _G.LFG_TYPE_NONE)
            container:Add(2, _G.MINIMAP_TRACKING_TARGET)
            container:Add(3, _G.MINIMAP_TRACKING_FOCUS)
            container:Add(4, _G.MINIMAP_TRACKING_TARGET .. " / " .. _G.MINIMAP_TRACKING_FOCUS)
            return container:GetData()
        end

        CreateDropDown(category, variable, name, GetOptions, tooltip)
    end

    do
        local variable = "flexMounts"
        local name = _G.PLAYER_DIFFICULTY4 .. " " .. _G.MOUNTS
        local tooltip = L.FlexibleTooltip

        local function GetOptions()
            local container = Settings.CreateControlTextContainer()
            container:Add(1, L.Ground)
            container:Add(2, _G.BATTLE_PET_NAME_3)
            container:Add(3, L.Ground .. " / " .. _G.BATTLE_PET_NAME_3)
            return container:GetData()
        end

        CreateDropDown(category, variable, name, GetOptions, tooltip)
    end

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.FavoritesHeading))

    do
        local variable = "normalMounts"
        local name = L.Ground .. "/" .. _G.BATTLE_PET_NAME_3 .. " " .. _G.MOUNTS
        local tooltip = L.MountsTooltip:format(L.Ground .. "/" .. _G.BATTLE_PET_NAME_3 .. " " .. _G.MOUNTS)

        CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "vendorMounts"
        local name = _G.BATTLE_PET_SOURCE_3 .. " " .. _G.MOUNTS
        local tooltip = L.MountsTooltip:format(_G.BATTLE_PET_SOURCE_3 .. " " .. _G.MOUNTS)

        CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "passengerMounts"
        local name = L.Passenger .. " " .. _G.MOUNTS
        local tooltip = L.MountsTooltip:format(L.Passenger .. " " .. _G.MOUNTS)

        CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "swimmingMounts"
        local name = _G.TUTORIAL_TITLE28 .. " " .. _G.MOUNTS
        local tooltip = L.MountsTooltip:format(_G.TUTORIAL_TITLE28 .. " " .. _G.MOUNTS)

        CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "zoneSpecificMounts"
        local name = L.ZoneSpecific .. " " .. _G.MOUNTS
        local tooltip = L.ZoneSpecificMountsTooltip

        CreateCheckBox(category, variable, name, tooltip)
    end

    Settings.RegisterAddOnCategory(category)

    ns.Settings = category
end
