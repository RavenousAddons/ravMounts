local name, ravMounts = ...

ravMounts.name = "Ravenous Mounts"
ravMounts.title = GetAddOnMetadata(name, "Title")
ravMounts.notes = GetAddOnMetadata(name, "Notes")
ravMounts.version = GetAddOnMetadata(name, "Version")
ravMounts.color = "9eb8c9"
ravMounts.command = "ravm"
ravMounts.github = "https://github.com/waldenp0nd/ravMounts"
ravMounts.curseforge = "https://www.curseforge.com/wow/addons/ravmounts"
ravMounts.wowinterface = "https://www.wowinterface.com/downloads/info24005-RavenousMounts.html"
ravMounts.discord = "https://discord.gg/dNfqnRf2fq"
ravMounts.defaults = {
    ["macro"] = true,
    ["clone"] = true,
    ["flexMounts"] = true,
    ["normalMounts"] = true,
    ["swimmingMounts"] = true,
    ["vendorMounts"] = true,
    ["passengerMounts"] = true
}
