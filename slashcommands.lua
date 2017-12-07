

local addonName, addonTable = ... -- Pull back the AddOn-Local Variables and store them locally.
-- addonName = "ravMounts"
-- addonTable = {}
addonTable.Version = "1.7.3"


-- Special formatting for 'Ravenous' messages
local function prettyPrint(message, full)
    if not full then
        full = false
    else
        message = message..":"
    end
    local prefix = "\124cff5f8aa6ravMounts"..(RAV_version ~= nil and " v"..RAV_version or "")..(full and " " or ":\124r ")

    DEFAULT_CHAT_FRAME:AddMessage(prefix..message)
end


SLASH_RAVMOUNTS1 = "/ravmounts"


local function slashHandler(message, editbox)
    if message == "version" or message == "v" then
        print("You are running: \124cff5f8aa6ravMounts v"..RAV_version)
    elseif message == "include" or message == "i" then
        RAV_includeSpecials = true
        prettyPrint("Special Mounts will be included in the normal summoning lists.")
        mountListHandler(true, false) -- force recache, do not announce recache
    elseif message == "exclude" or message == "e" then
        RAV_includeSpecials = false
        prettyPrint("Special Mounts will be excluded from the normal summoning lists.")
        mountListHandler(true, false) -- force recache, do not announce recache
    elseif message == "force" or message == "f" then
        mountListHandler(true, true) -- force recache, announce recache
    else
        mountListHandler(false, false) -- do not force recache, do not announce recache
        mountUpHandler(message)
    end
end


SlashCmdList["RAVMOUNTS"] = slashHandler
