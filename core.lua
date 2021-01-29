local name, ravMounts = ...
local L = ravMounts.L

function ravMounts_OnLoad(self)
    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("MOUNT_JOURNAL_SEARCH_UPDATED")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_INDOORS")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

function ravMounts_OnEvent(self, event, arg, ...)
    if arg == name then
        if event == "ADDON_LOADED" then
            ravMounts:SetDefaultOptions()
            InterfaceOptions_AddCategory(ravMounts.Options)
            if not RAV_version then
                ravMounts:PrettyPrint(string.format(L.Install, ravMounts.color, ravMounts.version))
            elseif RAV_version ~= ravMounts.version then
                ravMounts:PrettyPrint(string.format(L.Update, ravMounts.color, ravMounts.version))
            end
            RAV_version = ravMounts.version
            ravMounts:MountListHandler()
            ravMounts:TooltipLabels()
        end
    elseif event == "MOUNT_JOURNAL_SEARCH_UPDATED" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
        ravMounts:MountListHandler()
        ravMounts:EnsureMacro()
        if ravMounts.Options and ravMounts.Options.controls then
            ravMounts:RefreshControls(ravMounts.Options.controls)
        end
    end
end

SlashCmdList["RAVMOUNTS"] = function(message, editbox)
    local command, argument = strsplit(" ", message)
    if command == "version" or command == "v" then
        ravMounts:PrettyPrint(string.format(L.Version, ravMounts.version))
    elseif command == "c" or string.match(command, "con") or command == "h" or string.match(command, "help") or command == "o" or string.match(command, "opt") or command == "s" or string.match(command, "sett") or string.match(command, "togg") then
        InterfaceOptionsFrame_OpenToCategory(ravMounts.Options)
        InterfaceOptionsFrame_OpenToCategory(ravMounts.Options)
    elseif command == "f" or string.match(command, "force") then
        ravMounts:PrettyPrint(L.Force)
        ravMounts:MountListHandler()
        ravMounts:EnsureMacro()
        if ravMounts.Options and ravMounts.Options.controls then
            ravMounts:RefreshControls(ravMounts.Options.controls)
        end
    else
        ravMounts:MountUpHandler(command)
    end
end
SLASH_RAVMOUNTS1 = "/" .. ravMounts.command
SLASH_RAVMOUNTS2 = "/ravmounts"
SLASH_RAVMOUNTS3 = "/ravenousmounts"
