local name, ravMounts = ...
ravMounts.name = "Ravenous Mounts"
ravMounts.version = GetAddOnMetadata(name, "Version")
ravMounts.github = "https://github.com/waldenp0nd/ravMounts"
ravMounts.curseforge = "https://www.curseforge.com/wow/addons/ravmounts"
ravMounts.wowinterface = "https://www.wowinterface.com/downloads/info24005-RavenousMounts.html"
ravMounts.discord = "https://discord.gg/dNfqnRf2fq"
ravMounts.color = "9eb8c9"
ravMounts.locales = {
    ["enUS"] = {
        ["help"] = {
            "This AddOn creates and maintains a macro called |cff" .. ravMounts.color .. "%s|r for you under General Macros.", -- ravMounts.name
            "Check your config: |cff" .. ravMounts.color .. "/%s config|r", -- defaults.COMMAND
            "To toggle settings from your configuration, e.g.",
            "|cff" .. ravMounts.color .. "/%s toggle vendor|r or |cff" .. ravMounts.color .. "/%s toggle flex|r or |cff" .. ravMounts.color .. "/%s toggle clone|r", -- defaults.COMMAND, defaults.COMMAND, defaults.COMMAND
            "To force a recache or see what the AddOn has found: |cff" .. ravMounts.color .. "/%s data|r", -- defaults.COMMAND
            "Check out |cff" .. ravMounts.color .. "%s|r on GitHub, WoWInterface, or Curse for more info and support!", -- ravMounts.name
            "You can also get help directly from the author on Discord: %s" -- ravMounts.discord
        },
        ["load"] = {
            ["outofdate"] = "There is an update available for |cff" .. ravMounts.color .. "%s|r! Please go to GitHub, WoWInterface, or Curse to download.", -- ravMounts.name
            ["install"] = "Thanks for installing |cff" .. ravMounts.color .. "%s|r!", -- ravMounts.name
            ["update"] = "Thanks for updating to |cff" .. ravMounts.color .. "v%s|r!", -- ravMounts.version
            ["both"] = "Type |cff" .. ravMounts.color .. "/%s help|r to familiarize yourself with the addon." -- defaults.COMMAND
        },
        ["notice"] = {
            ["version"] = "%s is the current version.", -- ravMounts.version
            ["config"] = "Configuration",
            ["force"] = "Mount Journal data collected, sorted, and ready to go.",
            ["nomounts"] = "Unfortunately, you don't have any mounts that can be called at this time!",
            ["nospace"] = "Unfortunately, you don't have enough global macro space for the macro to be created!",
            ["help"] = "Information and How to Use"
        },
        ["type"] = {
            ["total"] = "Total Usable",
            ["ground"] = "Ground",
            ["flying"] = "Flying",
            ["groundpassenger"] = "Ground Passenger",
            ["flyingpassenger"] = "Flying Passenger",
            ["vendor"] = "Vendor",
            ["swimming"] = "Swimming",
            ["vashjir"] = "Vash'jir",
            ["ahnqiraj"] = "Ahn'Qiraj",
            ["chauffer"] = "Chauffer"
        },
        ["config"] = {
            ["normal"] = "Normal Mounts",
            ["vendor"] = "Vendor Mounts",
            ["passenger"] = "Passenger Mounts",
            ["swimming"] = "Swimming Mounts",
            ["flex"] = "Flexible Mounts",
            ["clone"] = "Clone Target/Focus Mounts",
            ["macro"] = "Automatic Macro",
            ["auto"] = "Automatically chosen",
            ["manual"] = "Favorite manually",
            ["flexboth"] = "Treated as Flying & Ground",
            ["flexone"] = "Treated a Flying-only",
            ["on"] = "ON",
            ["off"] = "OFF"
        },
        ["automation"] = {
            ["normal"] = {
                "Flying/Ground Mounts will be called randomly, regardless of Favorite status.",
                "Flying/Ground will only be summoned if they are marked as a Favorite."
            },
            ["vendor"] = {
                "Vendor Mounts will be called automatically, and if they are marked as a Favorite, they will be |cff" .. ravMounts.color .. "included|r in the Ground/Flying Mount summoning list.",
                "Vendor Mounts will only be summoned if they are marked as a Favorite."
            },
            ["passenger"] = {
                "Passenger Mounts will be summoned automatically, and if they are marked as a Favorite, they will be |cff" .. ravMounts.color .. "included|r in the Ground/Flying Mount summoning list.",
                "Passenger Mounts will only be summoned if they are marked as a Favorite."
            },
            ["swimming"] = {
                "Swimming Mounts will be called automatically, regardless of Favorite status.",
                "Swimming Mounts will only be summoned if they are marked as a Favorite."
            },
            ["flex"] = {
                "Flex Mounts will be included in the Ground Mount summoning list.",
                "Flex Mounts will be excluded from the Ground Mount summoning list."
            },
            ["clone"] = {
                "Your target/focus' mount with be called instead of following your Favorites.",
                "The addon will stop cloning your target/focus' mount."
            },
            ["macro"] = {
                "The addon will automatically create/maintain a macro for you.",
                "The addon will not create/maintain a macro for you."
            },
            ["missing"] = "You need to specify which type of automation to toggle: normal, vendor, passenger, swimming, flex, clone. If you need help: |cff" .. ravMounts.color .. "/%s help" -- defaults.COMMAND
        }
    }
}
