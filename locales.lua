local name, ravMounts = ...

local L = {}
ravMounts.L = L

setmetatable(L, { __index = function(t, k)
    local v = tostring(k)
    t[k] = v
    return v
end })

-- Default (English)
L.Version = "%s is the current version." -- ravMounts.version
L.OutOfDate = "There is an update available for |cff%s%s|r! Please go to GitHub, WoWInterface, or Curse to download the latest version." -- ravMounts.color, ravMounts.name
L.Install = "Thanks for installing |cff%s%s|r!" -- ravMounts.color, ravMounts.name
L.Update = "Thanks for updating to |cff%sv%s|r!" -- ravMounts.color, ravMounts.version
L.Support1 = "This AddOn creates and maintains a macro called |r%s|cffffffff for you under |rGeneral Macros|cffffffff." -- ravMounts.name
L.Support2 = "Check out the AddOn on |rGitHub|cffffffff, |rWoWInterface|cffffffff, or |rCurse|cffffffff for more info and support!"
L.Support3 = "You can also get help directly from the author on Discord: |r%s|cffffffff" -- ravMounts.discord
L.NoMounts = "Unfortunately, you don't have any mounts that can be called at this time!"
L.NoMacroSpace = "Unfortunately, you don't have enough global macro space for the macro to be created!"
L.Force = "Mount Journal data collected, sorted, and ready to go!"
L.Total = "Total"
L.Ground = "Ground"
L.Flying = "Flying"
L.Swimming = "Swimming"
L.Vendor = "Vendor"
L.PassengerGround = "Passenger (Ground)"
L.PassengerFlying = "Passenger (Flying)"
L.AhnQiraj = "Ahn'Qiraj"
L.Vashjir = "Vashj'ir"
L.Maw = "The Maw"
L.OptionsHeading = "Configuration:"
L.Macro = "Automatically create/maintain macro"
L.MacroTooltip = "When enabled, a macro called |cffffffff%s|r will be automatically created and managed for you under |cffffffffGeneral Macros|r." -- ravMounts.name
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
L.SupportHeading = "Help and Support:"
L.DataHeading = "Collected Data:"

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

-- Swedish
if CURRENT_LOCALE == "svSE" then return end
