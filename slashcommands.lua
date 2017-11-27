

local addonName, addonTable = ... -- Pull back the AddOn-Local Variables and store them locally.
-- addonName = "ravMounts"
-- addonTable = {}


SLASH_RAVMOUNTS1 = "/ravmounts"


local function slashHandler(message, editbox)
    if string.match(message, "include") or message == "i" then
        RAV_includeSpecials = true
        mountListHandler(true, false) -- force recache, do not announce recache
        prettyPrint("Special Mounts will be included in the normal summoning lists.")
    elseif string.match(message, "exclude") or message == "e" then
        RAV_includeSpecials = false
        mountListHandler(true, false) -- force recache, do not announce recache
        prettyPrint("Special Mounts will be excluded from the normal summoning lists.")
    elseif string.match(message, "force") or message == "f" then
        mountListHandler(true, true) -- force recache, announce recache
    else
        mountListHandler(false, false) -- do not force recache, do not announce recache
        mountUpHandler()
    end
end


SlashCmdList["RAVMOUNTS"] = slashHandler
