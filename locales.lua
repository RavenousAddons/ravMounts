local name, ravMounts = ...

local L = {}
ravMounts.L = L

setmetatable(L, { __index = function(t, k)
    local v = tostring(k)
    t[k] = v
    return v
end })

-- English
L.OptionsHeading = "Configuration:"
L.Macro = "Automatically create/maintain macro"
L.MacroTooltip = "When enabled, a macro called |cff" .. ravMounts.color .. ravMounts.name .. "|r will be automatically created and managed for you under General Macros."
L.Clone = "Clone target/focus' mount"
L.CloneTooltip = "When enabled, your target/focus' mount will be summoned, if you have it too."
L.FlexMounts = "Flexible mounts"
L.FlexMountsTooltip = "When enabled, \"flexible\" mounts will be included in the Ground Mount summoning list."
L.FavoritesHeading = "Types which use Favorites:"
L.NormalMounts = "Ground/Flying mounts"
L.NormalMountsTooltip = "When enabled, only Ground/Flying mounts marked as favorites will be summoned."
L.SwimmingMounts = "Swimming mounts"
L.SwimmingMountsTooltip = "When enabled, only Swimming mounts marked as favorites will be summoned."
L.PassengerMounts = "Passenger mounts (Ground & Flying)"
L.PassengerMountsTooltip = "When enabled, only Passenger mounts marked as favorites will be summoned."
L.VendorMounts = "Vendor mounts"
L.VendorMountsTooltip = "When enabled, only Vendor mounts marked as favorites will be summoned."
L.DataHeading = "Collected Data:"
L.Version = ravMounts.version .. " is the current version."
L.OutOfDate = "There is an update available for |cff" .. ravMounts.color .. ravMounts.name .. "|r! Please go to GitHub, WoWInterface, or Curse to download the latest version."
L.Install = "Thanks for installing |cff" .. ravMounts.color .. ravMounts.name .. "|r!"
L.Update = "Thanks for updating to |cff" .. ravMounts.color .. "v" .. ravMounts.version .. "|r!"
L.Help = "Information and How to Use|r\nThis addon creates and maintains a macro called |cff" .. ravMounts.color .. ravMounts.name .. "|r for you under General Macros.\nCheck your config: |cff" .. ravMounts.color .. "/" .. ravMounts.command .. " config|r\nCheck out the addon on GitHub, WoWInterface, or Curse for more info and support!\nYou can also get help directly from the author on Discord: " .. ravMounts.discord
L.NoMounts = "Unfortunately, you don't have any mounts that can be called at this time!"
L.NoMacroSpace = "Unfortunately, you don't have enough global macro space for the macro to be created!"
L.Force = "Mount Journal data collected, sorted, and ready to go!"
L.Reload = "* Updates when you reload."
L.Total = "Total"
L.Ground = "Ground"
L.Flying = "Flying"
L.Swimming = "Swimming"
L.Vendor = "Vendor"
L.PassengerGround = "Passenger (Ground)"
L.PassengerFlying = "Passenger (Flying)"


-- Check locale and assign appropriate
local CURRENT_LOCALE = GetLocale()

-- English
if CURRENT_LOCALE == "enUS" then return end

-- German
if CURRENT_LOCALE == "deDE" then return end

-- Spanish
if CURRENT_LOCALE == "esES" then return end

-- Latin-American Spanish
if CURRENT_LOCALE == "esMX" then return end

-- French
if CURRENT_LOCALE == "frFR" then return end

-- Italian
if CURRENT_LOCALE == "itIT" then return end

-- Brazilian Portuguese
if CURRENT_LOCALE == "ptBR" then return end

-- Russian
if CURRENT_LOCALE == "ruRU" then return end

-- Korean
if CURRENT_LOCALE == "koKR" then return end

-- Simplified Chinese
if CURRENT_LOCALE == "zhCN" then return end

-- Traditional Chinese
if CURRENT_LOCALE == "zhTW" then return end
