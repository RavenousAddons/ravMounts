local ADDON_NAME, ns = ...
local L = ns.L

function ns:CreateSettingsPanel()
    local category, layout = Settings.RegisterVerticalLayoutCategory(ns.name)

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(_G.GAMEOPTIONS_MENU .. ":"))

    do
        ns:CreateCheckBox(category, "macro", L.Macro, L.MacroTooltip:format(ns.name))
    end

    do
        local variable = "normalMountModifier"
        local name = L.Ground .. "/" .. _G.BATTLE_PET_NAME_3 .. " " .. _G.MOUNTS .. " " .. L.Modifier
        local tooltip = L.ModifierTooltip:format(L.Ground .. "/" .. _G.BATTLE_PET_NAME_3 .. " " .. _G.MOUNTS)

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

        ns:CreateDropDown(category, variable, name, GetOptions, tooltip)
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

        ns:CreateDropDown(category, variable, name, GetOptions, tooltip)
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

        ns:CreateDropDown(category, variable, name, GetOptions, tooltip)
    end

    do
        local variable = "travelForm"
        local name = L.TravelForm
        local tooltip = L.TravelFormTooltip

        ns:CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "normalSwimmingMounts"
        local name = L.NormalSwimming
        local tooltip = L.NormalSwimmingTooltip

        ns:CreateCheckBox(category, variable, name, tooltip)
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

        ns:CreateDropDown(category, variable, name, GetOptions, tooltip)
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

        ns:CreateDropDown(category, variable, name, GetOptions, tooltip)
    end

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.FavoritesHeading))

    do
        local variable = "normalMounts"
        local name = L.Ground .. "/" .. _G.BATTLE_PET_NAME_3 .. " " .. _G.MOUNTS
        local tooltip = L.MountsTooltip:format(L.Ground .. "/" .. _G.BATTLE_PET_NAME_3 .. " " .. _G.MOUNTS)

        ns:CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "vendorMounts"
        local name = _G.BATTLE_PET_SOURCE_3 .. " " .. _G.MOUNTS
        local tooltip = L.MountsTooltip:format(_G.BATTLE_PET_SOURCE_3 .. " " .. _G.MOUNTS)

        ns:CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "passengerMounts"
        local name = L.Passenger .. " " .. _G.MOUNTS
        local tooltip = L.MountsTooltip:format(L.Passenger .. " " .. _G.MOUNTS)

        ns:CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "swimmingMounts"
        local name = _G.TUTORIAL_TITLE28 .. " " .. _G.MOUNTS
        local tooltip = L.MountsTooltip:format(_G.TUTORIAL_TITLE28 .. " " .. _G.MOUNTS)

        ns:CreateCheckBox(category, variable, name, tooltip)
    end

    do
        local variable = "zoneSpecificMounts"
        local name = L.ZoneSpecific .. " " .. _G.MOUNTS
        local tooltip = L.MountsTooltip:format(L.ZoneSpecific .. " " .. _G.MOUNTS)

        ns:CreateCheckBox(category, variable, name, tooltip)
    end

    Settings.RegisterAddOnCategory(category)

    ns.Settings = category
end
