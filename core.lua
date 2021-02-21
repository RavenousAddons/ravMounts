local ADDON_NAME, ns = ...
local L = ns.L

function ravMounts_OnLoad(self)
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("MOUNT_JOURNAL_SEARCH_UPDATED")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

function ravMounts_OnEvent(self, event, arg, ...)
    if event == "PLAYER_LOGIN" then
        ns:SetDefaultOptions()
        InterfaceOptions_AddCategory(ns.Options)
        if not RAV_version then
            ns:PrettyPrint(string.format(L.Install, ns.color, ns.version))
        elseif RAV_version ~= ns.version then
            ns:PrettyPrint(string.format(L.Update, ns.color, ns.version))
        end
        RAV_version = ns.version
        ns:MountListHandler()
        ns:TooltipLabels()
        self:UnregisterEvent("PLAYER_LOGIN")
    elseif event == "ADDON_LOADED" and arg == "Blizzard_Collections" then
        ns:CreateOpenOptionsButton(MountJournal)
        self:UnregisterEvent("ADDON_LOADED")
    elseif event == "MOUNT_JOURNAL_SEARCH_UPDATED" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
        ns:SetDefaultOptions()
        ns:MountListHandler()
        ns:EnsureMacro()
        if ns.Options and ns.Options.controls then
            ns:RefreshControls(ns.Options.controls)
        end
    end
end

SlashCmdList["RAVMOUNTS"] = function(message)
    if message == "version" or message == "v" then
        ns:PrettyPrint(string.format(L.Version, ns.version))
    elseif message == "c" or string.match(message, "con") or message == "h" or string.match(message, "help") or message == "o" or string.match(message, "opt") or message == "s" or string.match(message, "sett") or string.match(message, "togg") then
        InterfaceOptionsFrame_OpenToCategory(ns.Options)
        InterfaceOptionsFrame_OpenToCategory(ns.Options)
    elseif message == "f" or string.match(message, "force") then
        ns:PrettyPrint(L.Force)
        ns:MountListHandler()
        ns:EnsureMacro()
        if ns.Options and ns.Options.controls then
            ns:RefreshControls(ns.Options.controls)
        end
    else
        ns:MountUpHandler(message)
    end
end
SLASH_RAVMOUNTS1 = "/ravm"
SLASH_RAVMOUNTS2 = "/ravmounts"
SLASH_RAVMOUNTS3 = "/ravenousmounts"
