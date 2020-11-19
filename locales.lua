local _, ravMounts = ...

ravMounts.locales = {
    ["enUS"] = {
        ["help"] = {
            "Type \124cff9eb8c9/ravm help\124r to familiarize yourself with \124cff9eb8c9Ravenous Mounts\124r.",
            "Type \124cff9eb8c9/ravm\124r to call a Mount, or even better—add it to a macro.",
            "Check your config: \124cff9eb8c9/ravm config",
            "To toggle automation of special mounts from your Mount lists:",
            "e.g. \124cff9eb8c9/ravm auto vendor\124r or \124cff9eb8c9/ravm auto flex\124r or \124cff9eb8c9/ravm auto clone",
            "Force a recache: \124cff9eb8c9/ravm force",
            "Check out \124cff9eb8c9Ravenous Mounts\124r on GitHub, WoWInterface, or Curse for more info and support: http://bit.ly/2hZTsAR"
        },
        ["load"] = {
            ["install"] = "Thanks for installing Ravenous Mounts!",
            ["update"] = "Thanks for updating Ravenous Mounts!"
        },
        ["notice"] = {
            ["config"] = "Automation Settings",
            ["force"] = "Mount Journal data collected, sorted, and ready to go.",
            ["nomounts"] = "Unfortunately you don't have any mounts that can be called at this time!",
            ["info"] = "Information and How to Use"
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
            ["vendor"] = {
                "Vendor Mounts will be called automatically, and if they are marked as a Favorite, they will be \124cff9eb8c9included\124r in the Ground/Flying Mount summoning list.",
                "Vendor Mounts will only be summoned if they are marked as a Favorite."
            },
            ["passenger"] = {
                "Passenger Mounts will be summoned automatically, and if they are marked as a Favorite, they will be \124cff9eb8c9included\124r in the Ground/Flying Mount summoning list.",
                "Passenger Mounts will only be summoned if they are marked as a Favorite."
            },
            ["swimming"] = {
                "Swimming Mounts will be \124cff9eb8c9included\124r in their summoning list, regardless of Favorite status.",
                "Swimming Mounts will only be summoned if they are marked as a Favorite."
            },
            ["flex"] = {
                "Flex Mounts will be included in the Ground Mount summoning list.",
                "Flex Mounts will be excluded from the Ground Mount summoning list."
            },
            ["clone"] = {
                "Your target/focus's mount, if they are using one and you own it too, will be summoned instead of following your Favorites.",
                "The addon will stop cloning your target/focus's mount."
            },
            ["missing"] = "You need to specify which type of automation to toggle: vendor, passenger, swimming, flex, clone. If you need help: \124cff9eb8c9/ravm help"
        }
    }
}
