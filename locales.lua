local _, ravMounts = ...

ravMounts.locales = {
    ["enUS"] = {
        ["help"] = {
            "This AddOn creates and maintains a macro called |cff9eb8c9%s|r for you under General Macros.", -- ravMounts.name
            "Check your config: |cff9eb8c9/%s config", -- defaults.COMMAND
            "To toggle settings from your configuration, e.g.",
            "|cff9eb8c9/%s toggle vendor|r or |cff9eb8c9/%s toggle flex|r or |cff9eb8c9/%s toggle clone", -- defaults.COMMAND, defaults.COMMAND, defaults.COMMAND
            "To force a recache or see what the AddOn has found: |cff9eb8c9/%s data", -- defaults.COMMAND
            "Check out |cff9eb8c9%s|r on GitHub, WoWInterface, or Curse for more info and support: http://bit.ly/2hZTsAR" -- ravMounts.name
        },
        ["load"] = {
            ["outofdate"] = "There is an update available for |cff9eb8c9%s|r! Please go to WoWInterface, Curse, or GitHub to download.", -- ravMounts.name
            ["install"] = "Thanks for installing |cff9eb8c9%s|r!", -- ravMounts.name
            ["update"] = "Thanks for updating |cff9eb8c9%s|r to |cff9eb8c9v%s|r!", -- ravMounts.name, ravMounts.version
            ["both"] = "Type |cff9eb8c9/%s help|r to familiarize yourself with |cff9eb8c9%s|r." -- defaults.COMMAND, ravMounts.name
        },
        ["notice"] = {
            ["version"] = "%s is the current version.", -- ravMounts.version
            ["config"] = "Configuration",
            ["force"] = "Mount Journal data collected, sorted, and ready to go.",
            ["nomounts"] = "Unfortunately, you don't have any mounts that can be called at this time!",
            ["nospace"] = "Unforunately, you don't have enough global macro space for the macro to be created!",
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
            ["clone"] = "Clone Mounts",
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
                "Vendor Mounts will be called automatically, and if they are marked as a Favorite, they will be |cff9eb8c9included|r in the Ground/Flying Mount summoning list.",
                "Vendor Mounts will only be summoned if they are marked as a Favorite."
            },
            ["passenger"] = {
                "Passenger Mounts will be summoned automatically, and if they are marked as a Favorite, they will be |cff9eb8c9included|r in the Ground/Flying Mount summoning list.",
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
            ["missing"] = "You need to specify which type of automation to toggle: normal, vendor, passenger, swimming, flex, clone. If you need help: |cff9eb8c9/%s help" -- defaults.COMMAND
        }
    }
}
