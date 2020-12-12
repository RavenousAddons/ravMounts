> Now looking for translators! If you speak a language other than English and would like to help, I'd be honoured if you got in touch!

# Ravenous Mounts

*Chooses the best Mount for the job without any set-up; it’s all based on your Mount Journal Favorites. Minimal in-game configuration to customise your summoning experience. Can even clone your target's mount (if you have the mount too)!*

## How does Ravenous Mounts work?

By default, the AddOn will create and maintain a macro for you under General Macros called Ravenous Mounts. The macro will pull icons from your available mounts and updates whenever you change zone (like going into Ahn'Qiraj), when you change Favorites in your Mount Journal, and even if you politely ask it to do so!

This AddOn is meant as a replacement for the default in-game "Summon Random Favorite Mount" button by expanding what mounts can be summoned, and when used with a keybind can be combined with modifier keys to summon special mount types, like vendor or passenger mounts.

`/ravmounts`

When using that command, Ravenous Mounts will loop through your Mount Journal collecting and sorting your mounts into different lists, organised by type, then, depending on the situation your character is in, summon the optimal mount based on your Favorites in the Mount Journal.

## Why?

The default button in the Mount Journal isn't sufficient or smart enough. Ravenous Mounts fixes issues with Blizzard's code like flying detection and adds checks for things like if your character is underwater, and if so, summon a swimming mount. It also does fun things like check when you're in Ahn'Qiraj and can summon your Qiraji Battle Tanks or clone your target/focus' mount for fast-paced mount-offs or just to flex on someone.

## Usage

Ravenous Mounts comes with a small handful of commands available for you to check configuration, toggle settings, and see data about your mount lists. Here's a couple of commands illustrated:

`/ravmounts help`

*Prints out a usage guide much like this one!*

`/ravmounts data`

*Shows you data about your mount lists.*

`/ravmounts config`

*Shows you your configuration settings.*

`/ravmounts toggle vendor`

*Toggles your configuration settings between their two states. Available configuration settings:*

- normal
- vendor
- passenger
- swimming
- flex
- clone

`/ravmounts passenger`

*Forces Ravenous Mounts to call a specific type of mount, regardless of the situation you're in. Available types:*

- flying
- ground
- swimming
- vendor
- flying passenger
- ground passenger
- vash'jir
- ahn'qiraj
- chauffeur

As mentioned above, Ravenous Mounts also checks for modifier keys being pressed when the command is run—these keys change what type of mount will be summoned:

- SHIFT — *Vendor Mounts*
- CONTROL - *Passenger Mounts*
- ALT - *Opposite Mounts (if in flying zone, ground mounts, and vice versa)*
- ALT + SHIFT — *Mount Special*

## Get in touch

If you wish to get in touch with me, hit me up in-game; my BattleTag is WaldenPond#11608.

## Special thanks

[Phanx](https://www.wowinterface.com/forums/member.php?userid=28751) for their immensely useful API_CanFly from [AnyFavoriteMount](https://www.wowinterface.com/downloads/info23261-AnyFavoriteMount.html).

[yj368413](https://www.wowinterface.com/forums/member.php?u=319392%22) for helping me realise that the AddOn should be language-agnostic.

[DJharris71](https://www.curseforge.com/members/djharris71) for loads of bugfixes, mount cloning functionality, and helping greatly in preparing for 9.0.0.

## License

Public Domain
