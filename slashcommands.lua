

local _, ravMounts = ... -- Pull back the AddOn-Local Variables and store them locally.
ravMounts.Version = "1.8.0"


SLASH_RAVMOUNTS1 = "/ravmounts"


local function slashHandler(message, editbox)
    if message == "version" or message == "v" then
        print("You are running: \124cff5f8aa6Ravenous Mounts v"..RAV_version)
    elseif message == "include" or message == "i" then
        RAV_includeSpecials = true
        ravMounts.prettyPrint("Special Mounts will be included in the normal summoning lists.")
        ravMounts.mountListHandler(true, false) -- force recache, do not announce recache
    elseif message == "exclude" or message == "e" then
        RAV_includeSpecials = false
        ravMounts.prettyPrint("Special Mounts will be excluded from the normal summoning lists.")
        ravMounts.mountListHandler(true, false) -- force recache, do not announce recache
    elseif message == "force" or message == "f" then
        ravMounts.mountListHandler(true, true) -- force recache, announce recache
    else
        ravMounts.mountListHandler(false, false) -- do not force recache, do not announce recache
        ravMounts.mountUpHandler(message)
    end
end


SlashCmdList["RAVMOUNTS"] = slashHandler
