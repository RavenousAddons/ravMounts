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
L.Version = "%s is the current version." -- ns.version
L.Install = "Thanks for installing |cff%1$sv%2$s|r!" -- ns.color, ns.version
L.Update = "Thanks for updating to |cff%1$sv%2$s|r!" -- ns.color, ns.version
L.UpdateFound = "v%s is now available for download. Please update!" -- sentVersion
L.Support = "Check out the Addon on |rGitHub|cffffffff, |rWoWInterface|cffffffff, or |rCurse|cffffffff for more info and support!"
L.NoMacroSpace = "Unfortunately, you don't have enough global macro space for the macro to be created!"
L.Macro = "Generate Macro"
L.MacroTooltip = "When enabled, a macro called |cffffffff%s|r will be automatically created and managed for you under |cffffffffGeneral Macros|r." -- ns.name
L.NormalSwimming = "Expanded Swimming Mounts"
L.NormalSwimmingTooltip = "When enabled, Swimming mounts will also count as Ground/Flying mounts."
L.TravelForm = "Use Travel Forms"
L.TravelFormTooltip = "When enabled, Class Travel Forms, if available, will be utilised as a priority over Ground/Flying mounts."
L.FavoritesHeading = "Types which use Favorites:"
L.MountsTooltip = "When enabled, only %s marked as favorites will be summoned." -- type
L.CountHeading = "Collected Data:"
L.Force = "Mount Journal data collected, sorted, and ready to go!"
L.Cloneable = "Cloneable"
L.CloneableTooltip = "When enabled, allows cloning of players' mounts you see around you."
L.FlexibleTooltip = "Choose how Flying mounts that look like Ground mounts should be catalogued."
L.Ground = "Ground"
L.Passenger = "Passenger"
L.Chauffeur = "Chauffeur"
L.Modifier = "Modifier"
L.ModifierTooltip = "Choose which modifier key to use to call %s." -- type
L.ZoneSpecific = "Zone-Specific"
L.AddonCompartmentTooltip1 = "|cff" .. ns.color .. "Left-Click:|r Open Settings"
L.AddonCompartmentTooltip2 = "|cff" .. ns.color .. "Middle-Click:|r Open Mount Journal"
L.AddonCompartmentTooltip3 = "|cff" .. ns.color .. "Right-Click:|r Summon Mount"

-- Check locale and assign appropriate
local CURRENT_LOCALE = GetLocale()

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
if CURRENT_LOCALE == "zhCN" then
	L.Version = "当前版本：%s" -- ns.version
	L.Install = "感谢使用 |cff%1$sv%2$s|r！" -- ns.color, ns.version
	L.Update = "感谢更新 |cff%1$sv%2$s|r！" -- ns.color, ns.version
	L.UpdateFound = "v%s 可用，请更新！" -- sentVersion
	L.Support = "请至 |rGitHub|cffffffff、|rWoWInterface|cffffffff 或 |rCurse|cffffffff 获取更多信息与插件支持！"
	L.NoMacroSpace = "你的通用宏已满，无法座骑宏！"
	L.Macro = "创建宏"
	L.MacroTooltip = "在你的通用宏自动创建一个叫做 |cffffffff%s|r 的座骑宏。 " -- ns.name
	L.NormalSwimming = "扩展游泳座骑"
	L.NormalSwimmingTooltip = "启用后，游泳座骑也会被当作地面或飞行座骑。"
	L.TravelForm = "使用旅行形态"
	L.TravelFormTooltip = "启用此选项后，地面与飞行座骑将优先使用旅行行态。"
	L.FavoritesHeading = "使用偏好座骑的类型："
	L.MountsTooltip = "启用此选项后，只会召唤被标记为偏好座骑的 %s。" -- type
	L.CountHeading = "Collected Data:"
	L.Force = "Mount Journal data collected, sorted, and ready to go!"
	L.Cloneable = "可模仿"
	L.CloneableTooltip = "启用此选项后，当你附近的玩家召唤了什么座骑，就召唤和该玩家相同的座骑。"
	L.FlexibleTooltip = "对于那些可以当成地面座骑使用的飞行座骑，请选择要将它们作为哪种类型来召唤。"
	L.Ground = "地面"
	L.Passenger = "载人"
	L.Chauffeur = "Chauffeur"
	L.Modifier = "组合键"
	L.ModifierTooltip = "选择指定召唤 %s 的组合键。" -- type
	L.ZoneSpecific = "区域限定"
	L.AddonCompartmentTooltip1 = "|cff" .. ns.color .. "左键点击：|r开启设置"
	L.AddonCompartmentTooltip2 = "|cff" .. ns.color .. "中键点击：|r开启座骑列表"
	L.AddonCompartmentTooltip3 = "|cff" .. ns.color .. "右键点击：|r召唤座骑"
 end

-- Traditional Chinese
if CURRENT_LOCALE == "zhTW" then 
	L.Version = "目前版本：%s" -- ns.version
	L.Install = "感謝使用 |cff%1$sv%2$s|r！" -- ns.color, ns.version
	L.Update = "感謝更新 |cff%1$sv%2$s|r！" -- ns.color, ns.version
	L.UpdateFound = "v%s 可用，請更新！" -- sentVersion
	L.Support = "請至 |rGitHub|cffffffff、|rWoWInterface|cffffffff 或 |rCurse|cffffffff 獲取插件的詳細資訊與支援！"
	L.NoMacroSpace = "你的一般巨集已滿，無法創建巨集！"
	L.Macro = "創建巨集"
	L.MacroTooltip = "在你的一般巨集自動創建一個叫做 |cffffffff%s|r 的座騎巨集。" -- ns.name
	L.NormalSwimming = "拓展游泳座騎"
	L.NormalSwimmingTooltip = "啟用後，游泳座騎也會被當作地面或飛行座騎。"
	L.TravelForm = "使用旅行形態"
	L.TravelFormTooltip = "啟用此選項後，地面與飛行座騎將優先使用旅行行態。"
	L.FavoritesHeading = "使用最愛座騎的類型："
	L.MountsTooltip = "啟用此選項後，只會召喚被標記為最愛座騎的 %s。" -- type
	L.CountHeading = "Collected Data:"
	L.Force = "Mount Journal data collected, sorted, and ready to go!"
	L.Cloneable = "可模仿"
	L.CloneableTooltip = "啟用此選項後，當你附近的玩家召喚了什麼座騎，就召喚和該玩家相同的座騎。"
	L.FlexibleTooltip = "對於那些可以當成地面座騎使用的飛行座騎，請選擇要將它們作為哪種類型來召喚。"
	L.Ground = "地面"
	L.Passenger = "載人"
	L.Chauffeur = "Chauffeur"
	L.Modifier = "組合鍵"
	L.ModifierTooltip = "選擇指定召喚 %s 的組合鍵。" -- type
	L.ZoneSpecific = "區域限定"
	L.AddonCompartmentTooltip1 = "|cff" .. ns.color .. "左鍵點擊：|r開啟設定"
	L.AddonCompartmentTooltip2 = "|cff" .. ns.color .. "中鍵點擊：|r開啟座騎列表"
	L.AddonCompartmentTooltip3 = "|cff" .. ns.color .. "右鍵點擊：|r召喚座騎"
return end

-- Swedish
if CURRENT_LOCALE == "svSE" then return end

-- Automatic
L.PassengerGround = L.Passenger .. " (" .. L.Ground .. ")"
L.PassengerFlying = L.Passenger .. " (" .. _G.BATTLE_PET_NAME_3 .. ")"
local mapIDs = ns.data.mapIDs
L.AhnQiraj = CM.GetMapInfo(321).name
L.Vashjir = CM.GetMapInfo(203).name
L.Maw = CM.GetMapInfo(1543).name
L.DragonIsles = CM.GetMapInfo(2057).name
