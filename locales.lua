local _, ravMounts = ...

ravMounts.locales = {
    ["enUS"] = {
        ["help"] = {
            "Type \124cff9eb8c9/%s\124r to call a Mount, or even better: add it to a macro.", -- defaults.COMMAND
            "Check your config: \124cff9eb8c9/%s config", -- defaults.COMMAND
            "To toggle settings from your configuration, e.g.",
            "\124cff9eb8c9/%s toggle vendor\124r or \124cff9eb8c9/%s toggle flex\124r or \124cff9eb8c9/%s toggle clone", -- defaults.COMMAND, defaults.COMMAND, defaults.COMMAND
            "To force a recache or see what the AddOn has found: \124cff9eb8c9/%s data", -- defaults.COMMAND
            "Check out \124cff9eb8c9%s\124r on GitHub, WoWInterface, or Curse for more info and support: http://bit.ly/2hZTsAR" -- ravMounts.name
        },
        ["load"] = {
            ["install"] = "Thanks for installing \124cff9eb8c9%s\124r!", -- ravMounts.name
            ["update"] = "Thanks for updating \124cff9eb8c9%s\124r!", -- ravMounts.name
            ["both"] = "Type \124cff9eb8c9/%s help\124r to familiarize yourself with \124cff9eb8c9%s\124r." -- defaults.COMMAND, ravMounts.name
        },
        ["notice"] = {
            ["version"] = "%s is the current version.", -- ravMounts.version
            ["config"] = "Configuration",
            ["force"] = "Mount Journal data collected, sorted, and ready to go.",
            ["nomounts"] = "Unfortunately you don't have any mounts that can be called at this time!",
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
            ["normal"] = "Flying/Ground Mounts",
            ["vendor"] = "Vendor Mounts",
            ["passenger"] = "Passenger Mounts",
            ["swimming"] = "Swimming Mounts",
            ["flex"] = "Flexible Mounts",
            ["clone"] = "Clone Mounts",
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
                "Vendor Mounts will be called automatically, and if they are marked as a Favorite, they will be \124cff9eb8c9included\124r in the Ground/Flying Mount summoning list.",
                "Vendor Mounts will only be summoned if they are marked as a Favorite."
            },
            ["passenger"] = {
                "Passenger Mounts will be summoned automatically, and if they are marked as a Favorite, they will be \124cff9eb8c9included\124r in the Ground/Flying Mount summoning list.",
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
            ["missing"] = "You need to specify which type of automation to toggle: normal, vendor, passenger, swimming, flex, clone. If you need help: \124cff9eb8c9/%s help" -- defaults.COMMAND
        }
    }
}
