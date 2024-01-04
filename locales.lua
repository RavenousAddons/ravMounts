local _, ns = ...
local L = {}
ns.L = L

setmetatable(L, { __index = function(t, k)
    local v = tostring(k)
    t[k] = v
    return v
end })

local CM = C_Map

-- Default (English)
L.AddonCompartmentTooltip1 = "|cff" .. ns.color .. "Left-Click:|r Open Settings"
L.AddonCompartmentTooltip2 = "|cff" .. ns.color .. "Middle-Click:|r Open Mount Journal"
L.AddonCompartmentTooltip3 = "|cff" .. ns.color .. "Right-Click:|r Summon Mount"
L.Alternate = "Alternate"
L.Chauffeur = "Chauffeur"
L.Cloneable = "Cloneable"
L.CloneableTooltip = "When enabled, allows cloning of players' mounts you see around you."
L.CountHeading = "Collected Data:"
L.Dragonriding = "Dragonriding"
L.FavoritesHeading = "Types which use Favorites:"
L.FlexibleTooltip = "Choose how Flying mounts that look like Ground mounts should be catalogued."
L.Force = "Mount Journal data collected, sorted, and ready to go!"
L.Ground = "Ground"
L.Install = "Thanks for installing |cff%1$sversion %2$s|r!" -- ns.color, ns.version
L.Macro = "Generate Macro"
L.MacroTooltip = "When enabled, a macro called |cffffffff%s|r will be automatically created and managed for you under |cffffffffGeneral Macros|r." -- ns.name
L.Modifier = "Modifier"
L.ModifierTooltip = "Choose which modifier key to use to call %s." -- type
L.MountsTooltip = "When enabled, only %s marked as favorites will be summoned." -- type
L.NoMacroSpace = "Unfortunately, you don't have enough space in General Macros for the macro to be created!"
L.NormalSwimming = "Expanded Swimming Mounts"
L.NormalSwimmingTooltip = "When enabled, Swimming mounts will also count as Ground/Flying mounts."
L.Passenger = "Passenger"
L.PreferDragonRiding = "Prefer Dragonriding Mounts"
L.PreferDragonRidingTooltip = "When enabled, Dragonriding mounts will be used instead of Flying mounts in appropriate zones."
L.Support = "Check out the Addon on |rCurse|cffffffff, |rGitHub|cffffffff, or |rWoWInterface|cffffffff for more info and support!"
L.TravelForm = "Use Shapeshift Forms"
L.TravelFormTooltip = "When enabled, Class Shapeshift Forms, if available, will be utilised as a priority over Ground/Flying mounts."
L.Update = "Thanks for updating to |cff%1$sversion %2$s|r!" -- ns.color, ns.version
L.UpdateFound = "Version %s is now available for download. Please update!" -- sentVersion
L.Version = "%s is the current version." -- ns.version
L.ZoneSpecific = "Zone-Specific"
L.NormalModifierTooltip = L.ModifierTooltip:format(L.Alternate .. " " .. _G.MOUNTS) .. "|nWhere Dragonriding is possible, this alternates between Dragonriding and Flying mounts; otherwise, it alternates between Flying and Ground mounts. Additionally, when swimming, this will trigger a non-swimming mount to be summoned instead."
L.ZoneSpecificMountsTooltip = L.MountsTooltip:format(L.ZoneSpecific .. " " .. _G.MOUNTS)

-- Check locale and assign appropriate
local CURRENT_LOCALE = GetLocale()

-- German
if CURRENT_LOCALE == "deDE" then
    L.AddonCompartmentTooltip1 = "|cff" .. ns.color .. "Links-Klick:|r Einstellungen öffnen"
    L.AddonCompartmentTooltip2 = "|cff" .. ns.color .. "Mittelklick:|r Mount-Journal öffnen"
    L.AddonCompartmentTooltip3 = "|cff" .. ns.color .. "Rechtsklick:|r Reittier beschwören"
    L.Alternate = "Wechseln"
    L.Cloneable = "Klonbar"
    L.CloneableTooltip = "Wenn diese Funktion aktiviert ist, kannst du die Reittiere von Spielern klonen, die du um dich herum siehst."
    L.CountHeading = "Gesammelte Daten:"
    L.Dragonriding = "Drachenreiten"
    L.FavoritesHeading = "Typen, die Favoriten verwenden:"
    L.FlexibleTooltip = "Wähle aus, wie Fliegende Reittiere, die wie Bodenreittiere aussehen, katalogisiert werden sollen."
    L.Force = "Mount Journal-Daten sind gesammelt, sortiert und einsatzbereit!"
    L.Ground = "Reittiere"
    L.Install = "Danke für die Installation von |cff%1$sVersion %2$s|r!" -- ns.color, ns.version
    L.Macro = "Automatisch Makro erstellen/verwalten"
    L.MacroTooltip = "Wenn diese Funktion aktiviert ist, wird automatisch ein Makro mit dem Namen |cffffffff%s|r erstellt und für Sie unter |cffffffffGeneral Macros|r verwaltet." -- ns.name
    L.Modifier = "Modifikator"
    L.ModifierTooltip = "Wähle aus, welche Modifikatortaste du für den Aufruf von %s verwenden willst." -- type
    L.MountsTooltip = "Wenn diese Option aktiviert ist, werden nur %s, die als Favoriten markiert sind, aufgerufen." -- type
    L.NoMacroSpace = "Leider hast du nicht genug globalen Makroplatz, um das Makro zu erstellen!"
    L.NoMounts = "Leider hast du keine Reittiere, die du zu diesem Zeitpunkt aufrufen kannst!"
    L.NormalSwimming = "Erweiterte schwimmende Reittiere"
    L.NormalSwimmingTooltip = "Wenn diese Funktion aktiviert ist, zählen schwimmende Reittiere auch als Boden-/Flugreittiere."
    L.Passenger = "Passagiere"
    L.PreferDragonRiding = "Bevorzuge Drachenreit-Reittiere"
    L.PreferDragonRidingTooltip = "Wenn diese Option aktiviert ist, werden in den entsprechenden Zonen Drachenreittiere anstelle von fliegenden Reittieren verwendet."
    L.Support = "Schau dir das Addon auf |rCurse|cffffffff, |rGitHub|cffffffff, oder |rWoWInterface|cffffffff für weitere Informationen und Unterstützung an!"
    L.TravelForm = "Formen der Gestaltwandlung verwenden"
    L.TravelFormTooltip = "Wenn diese Funktion aktiviert ist, werden Formen der Gestaltwandlung der Klasse, sofern vorhanden, vorrangig vor Boden-/Flug-Reittieren verwendet."
    L.Update = "Danke für das Update auf |cff%1$sVersion %2$s|r!" -- ns.color, ns.version
    L.UpdateFound = "Version %s ist jetzt zum Download verfügbar. Bitte aktualisiere!" -- sentVersion
    L.Version = "%s ist die aktuelle Version." -- ns.version
    L.ZoneSpecific = "Zonenspezifisch"
    L.NormalModifierTooltip = L.ModifierTooltip:format(L.Alternate .. " " .. _G.MOUNTS) .. "|nWo Drachenreiten möglich ist, wechselt es zwischen Drachenreiten und fliegenden Reittieren; andernfalls wechselt es zwischen fliegenden und Boden-Reittieren. Wenn du schwimmst, wird stattdessen ein nicht schwimmendes Reittier beschworen."
end

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
if CURRENT_LOCALE == "zhCN" then
    L.AddonCompartmentTooltip1 = "|cff" .. ns.color .. "左键点击：|r开启设置"
    L.AddonCompartmentTooltip2 = "|cff" .. ns.color .. "中键点击：|r开启座骑列表"
    L.AddonCompartmentTooltip3 = "|cff" .. ns.color .. "右键点击：|r召唤座骑"
    L.Cloneable = "可模仿"
    L.CloneableTooltip = "启用此选项后，当你附近的玩家召唤了什么座骑，就召唤和该玩家相同的座骑。"
    L.FavoritesHeading = "使用偏好座骑的类型："
    L.FlexibleTooltip = "对于那些可以当成地面座骑使用的飞行座骑，请选择要将它们作为哪种类型来召唤。"
    L.Ground = "地面"
    L.Install = "感谢使用 |cff%1$sv%2$s|r！" -- ns.color, ns.version
    L.Macro = "创建宏"
    L.MacroTooltip = "在你的通用宏自动创建一个叫做 |cffffffff%s|r 的座骑宏。 " -- ns.name
    L.Modifier = "组合键"
    L.ModifierTooltip = "选择指定召唤 %s 的组合键。" -- type
    L.MountsTooltip = "启用此选项后，只会召唤被标记为偏好座骑的 %s。" -- type
    L.NoMacroSpace = "你的通用宏已满，无法座骑宏！"
    L.NormalSwimming = "扩展游泳座骑"
    L.NormalSwimmingTooltip = "启用后，游泳座骑也会被当作地面或飞行座骑。"
    L.Passenger = "载人"
    L.Support = "请至 |rCurse|cffffffff、|rGitHub|cffffffff 或 |rWoWInterface|cffffffff 获取更多信息与插件支持！"
    L.TravelForm = "使用旅行形态"
    L.TravelFormTooltip = "启用此选项后，地面与飞行座骑将优先使用旅行行态。"
    L.Update = "感谢更新 |cff%1$sv%2$s|r！" -- ns.color, ns.version
    L.UpdateFound = "v%s 可用，请更新！" -- sentVersion
    L.Version = "当前版本：%s" -- ns.version
    L.ZoneSpecific = "区域限定"
 end

-- Traditional Chinese
if CURRENT_LOCALE == "zhTW" then
    L.AddonCompartmentTooltip1 = "|cff" .. ns.color .. "左鍵點擊：|r開啟設定"
    L.AddonCompartmentTooltip2 = "|cff" .. ns.color .. "中鍵點擊：|r開啟座騎列表"
    L.AddonCompartmentTooltip3 = "|cff" .. ns.color .. "右鍵點擊：|r召喚座騎"
    L.Cloneable = "可模仿"
    L.CloneableTooltip = "啟用此選項後，當你附近的玩家召喚了什麼座騎，就召喚和該玩家相同的座騎。"
    L.FavoritesHeading = "使用最愛座騎的類型："
    L.FlexibleTooltip = "對於那些可以當成地面座騎使用的飛行座騎，請選擇要將它們作為哪種類型來召喚。"
    L.Ground = "地面"
    L.Install = "感謝使用 |cff%1$sv%2$s|r！" -- ns.color, ns.version
    L.Macro = "創建巨集"
    L.MacroTooltip = "在你的一般巨集自動創建一個叫做 |cffffffff%s|r 的座騎巨集。" -- ns.name
    L.Modifier = "組合鍵"
    L.ModifierTooltip = "選擇指定召喚 %s 的組合鍵。" -- type
    L.MountsTooltip = "啟用此選項後，只會召喚被標記為最愛座騎的 %s。" -- type
    L.NoMacroSpace = "你的一般巨集已滿，無法創建巨集！"
    L.NormalSwimming = "拓展游泳座騎"
    L.NormalSwimmingTooltip = "啟用後，游泳座騎也會被當作地面或飛行座騎。"
    L.Passenger = "載人"
    L.Support = "請至 |rCurse|cffffffff、|rGitHub|cffffffff 或 |rWoWInterface|cffffffff 獲取插件的詳細資訊與支援！"
    L.TravelForm = "使用旅行形態"
    L.TravelFormTooltip = "啟用此選項後，地面與飛行座騎將優先使用旅行行態。"
    L.Update = "感謝更新 |cff%1$sv%2$s|r！" -- ns.color, ns.version
    L.UpdateFound = "v%s 可用，請更新！" -- sentVersion
    L.Version = "目前版本：%s" -- ns.version
    L.ZoneSpecific = "區域限定"
return end

-- Swedish
if CURRENT_LOCALE == "svSE" then return end

-- Automatic
L.PassengerGround = L.Passenger .. " (" .. L.Ground .. ")"
L.PassengerFlying = L.Passenger .. " (" .. _G.BATTLE_PET_NAME_3 .. ")"
L.AhnQiraj = CM.GetMapInfo(321).name
L.Vashjir = CM.GetMapInfo(203).name
L.Maw = CM.GetMapInfo(1543).name
L.DragonIsles = CM.GetMapInfo(2057).name
