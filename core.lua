local ADDON_NAME, ns = ...
local L = ns.L

function ravMounts_OnLoad(self)
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("MOUNT_JOURNAL_SEARCH_UPDATED")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("CHAT_MSG_ADDON")
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
    elseif event == "MOUNT_JOURNAL_SEARCH_UPDATED" or event =="PLAYER_SPECIALIZATION_CHANGED" or event == "UPDATE_SHAPESHIFT_FORMS" then
        ns:MountListHandler()
        ns:EnsureMacro()
        if ns.Options and ns.Options.controls then
            ns:RefreshControls(ns.Options.controls)
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        local partyMembers = GetNumSubgroupMembers()
        local raidMembers = IsInRaid() and GetNumGroupMembers() or 0
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and (partyMembers > ns.data.partyMembers or raidMembers > ns.data.raidMembers) then
            ns:SendUpdate("INSTANCE_CHAT");
        elseif raidMembers == 0 and partyMembers > ns.data.partyMembers then
            ns:SendUpdate("PARTY");
        elseif raidMembers > ns.data.raidMembers then
            ns:SendUpdate("RAID")
        end
        ns.data.partyMembers = partyMembers
        ns.data.raidMembers = raidMembers
    elseif event == "CHAT_MSG_ADDON" and arg == ADDON_NAME then
        local message, channel, sender, _ = ...
        if string.match(message, "V:") and not ns.updateFound then
            local version = string.gsub(message, "V:", "")
            local v1, v2, v3 = strsplit(".", version)
            local c1, c2, c3 = strsplit(".", ns.version)
            if v1 > c1 or (v1 == c1 and v2 > c2) or (v1 == c1 and v2 == c2 and v3 > c3) then
                ns:PrettyPrint(string.format(L.UpdateFound, version))
                ns.updateFound = true
            end
        end
    end
end

SlashCmdList["RAVMOUNTS"] = function(message)
    if message == "version" or message == "v" then
        ns:PrettyPrint(string.format(L.Version, ns.version))
    elseif message == "c" or string.match(message, "con") or message == "h" or string.match(message, "help") or message == "o" or string.match(message, "opt") or message == "s" or string.match(message, "sett") or string.match(message, "togg") then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
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
