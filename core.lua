local name, ravMounts = ...
local L = ravMounts.L

function ravMounts_OnLoad(self)
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterEvent("MOUNT_JOURNAL_SEARCH_UPDATED")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

function ravMounts_OnEvent(self, event, arg, ...)
    if arg == name then
        if event == "ADDON_LOADED" then
            ravMounts:SetDefaultOptions()
            if not RAV_version then
                ravMounts:PrettyPrint(L.Install)
            elseif RAV_version ~= ravMounts.version then
                ravMounts:PrettyPrint(L.Update)
            end
            if not RAV_version or RAV_version ~= ravMounts.version then
                RAV_seenUpdate = false
            end
            RAV_version = ravMounts.version
            C_ChatInfo.RegisterAddonMessagePrefix(name)
            ravMounts:SendVersion()
            ravMounts:MountListHandler()
        elseif event == "CHAT_MSG_ADDON" and RAV_seenUpdate == false then
            local message, _ = ...
            local a, b, c = strsplit(".", ravMounts.version)
            local d, e, f = strsplit(".", message)
            if (d > a) or (d == a and e > b) or (d == a and e == b and f > c) then
                ravMounts:PrettyPrint(L.OutOfDate)
                RAV_seenUpdate = true
            end
        end
    elseif event == "MOUNT_JOURNAL_SEARCH_UPDATED" then
        ravMounts:MountListHandler()
        ravMounts:EnsureMacro()
    elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
        ravMounts:MountListHandler()
        ravMounts:EnsureMacro()
    end
end

SlashCmdList["RAVMOUNTS"] = function(message, editbox)
    local command, argument = strsplit(" ", message)
    if command == "version" or command == "v" then
        ravMounts:PrettyPrint(L.Version)
        ravMounts:SendVersion()
    elseif command == "c" or string.match(command, "con") or command == "o" or string.match(command, "opt") or command == "s" or string.match(command, "sett") or string.match(command, "togg") then
        InterfaceOptionsFrame_OpenToCategory(ravMounts.Options)
        InterfaceOptionsFrame_OpenToCategory(ravMounts.Options)
    elseif command == "h" or string.match(command, "help") then
        ravMounts:PrettyPrint(L.Help)
    elseif command == "f" or string.match(command, "force") then
        ravMounts:PrettyPrint(L.Force)
        ravMounts:MountListHandler()
        ravMounts:EnsureMacro()
    else
        ravMounts:MountUpHandler(command)
    end
end
SLASH_RAVMOUNTS1 = "/" .. ravMounts.command
SLASH_RAVMOUNTS2 = "/ravmounts"
SLASH_RAVMOUNTS3 = "/ravenousmounts"