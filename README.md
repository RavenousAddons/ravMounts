# Ravenous Mounts

[![Buy me a coffee](https://img.shields.io/badge/help%20out-Buy%20me%20a%20coffee-81b3a0)](https://www.buymeacoffee.com/waldenpond)

> Now looking for translators! If you speak a language other than English and would like to help, I'd be honoured if you got in touch!

*Chooses the best Mount for the job without any set-up; it’s all based on your Mount Journal Favorites. Minimal in-game configuration to customise your summoning experience. Can even clone your target's mount (if you have the mount too)!*

![Interface Options Window](https://cdn-wow.mmoui.com/preview/pvw74778.png)

## How does Ravenous Mounts work?

1. The Addon creates a macro for you under General Macros called "Ravenous Mounts". Put the macro on your bars!

2. Mark your favourite mounts in your Mount Journal as your normally would and use the macro. The Addon will act like the built-in "Summon Random Favorite Mount" button but will respond more intelligently:
    - it can more accurately detect when a zone is flyable
    - it can summon a swimming mount when you're underwater
    - it can summon Dragonriding mounts you've learned when in Dragon Isles (likewise for Ahn'Qiraj and Vashj'ir and The Maw)
    - using key-modifiers (alt, control, shift) with the macro can summon specific types of mounts (e.g. vendor mounts, passenger mounts)
    - it can even clone your target/focus' active mount if you have learned it too (great for mount-off competitions!)

*If you'd rather manage your own macro, you can use the following slash-command: `/ravm`*

## Why?

The default button in the Mount Journal isn't sufficient or smart enough. Ravenous Mounts fixes issues with Blizzard's code like flying detection and adds checks for things like if your character is underwater, and if so, summon a swimming mount. It also does fun things like check when you're in Ahn'Qiraj and can summon your Qiraji Battle Tanks or clone your target/focus' mount for fast-paced mount-offs or just to flex on someone.

## Usage

Ravenous Mounts comes with a small handful of commands available for you to check configuration, toggle settings, and see data about your mount lists. Here's a couple of commands illustrated:

`/ravm help`

*Prints out a usage guide much like this one!*

`/ravm config`

*Shows you your configuration settings.*

`/ravm passenger`

*Forces Ravenous Mounts to call a specific type of mount, regardless of the situation you're in. Available types:*

- ground
- flying
- swimming
- vendor
- ground passenger
- flying passenger
- ahnqiraj
- vashjir
- maw
- chauffeur

## Special thanks

[Phanx](https://www.wowinterface.com/forums/member.php?userid=28751) for their immensely useful API_CanFly from [AnyFavoriteMount](https://www.wowinterface.com/downloads/info23261-AnyFavoriteMount.html).

[yj368413](https://www.wowinterface.com/forums/member.php?u=319392%22) for helping me realise that the Addon should be language-agnostic.

[DJharris71](https://www.curseforge.com/members/djharris71) for loads of bugfixes, mount cloning functionality, and helping greatly in preparing for 9.0.0.

[Killashandra](https://www.wowinterface.com/forums/member.php?u=350162) for the idea to add an IsFlying() check!

## License

Public Domain
