

local addonName, addonTable = ... -- Pull back the AddOn-Local Variables and store them locally.
-- addonName = "ravMounts"
-- addonTable = {}


SLASH_RAVMOUNTS1 = "/ravmounts"


local function slashHandler(message, editbox)
    if string.match(message, "force") or message == "f" then
        mountListHandler(true, true) -- force recache, announce recache
    else
        mountListHandler(false, false) -- do not force recache, do not announce recache
        mountUpHandler()
    end
end


SlashCmdList["RAVMOUNTS"] = slashHandler
