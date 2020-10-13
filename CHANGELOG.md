## Version 1.9.5

- Expand checks for LibFlyable
- Add copy/clone target mount functionality, thanks to DJharris71 (http://www.wowinterface.com/forums/member.php?userid=301959)


## Version 1.9.4

- Make more checks for viable Mounts before summoning Chauffeur Mounts


## Version 1.9.3

- Add Hivemind to Passenger Flying Mounts
- Add new Flex Mounts
- Fix LibFlyable to check for Island Expeditions


## Version 1.9.2

- Make distinction for "floating"


## Version 1.9.1

- Update LibFlyable


## Version 1.9.0

- Updated for 8.0.1
- Made submerged check include floating check, thanks to DJharris71 (http://www.wowinterface.com/forums/member.php?userid=301959)


## Version 1.8.9

- Updated Phanx’s CanFly → LibFlyable code from https://github.com/phanx-wow/LibFlyable.


## Version 1.8.8

- Add Flex mounts inclusion setting.
- Updated Phanx’s CanFly code from https://github.com/phanx-wow/LibFlyable.
- Changed license.


## Version 1.8.7

- Fix error in Mount Summon function.


## Version 1.8.6

- Remove Flight Master's License as well. Oops.


## Version 1.8.5

- Make the slash command code more terse and remove Northrend and Pandaria flight requirement checks from API_CanFly.


## Version 1.8.4

- Change which ## Version of Phanx’s API_CanFly is used.


## Version 1.8.3

- Add multiple inclusion checks.


## Version 1.8.2

- Clean up redundant code.


## Version 1.8.1

- Clean up and pare down code significantly.


## Version 1.8.0

- Added stronger flight ability checking, thanks for Phanx's AnyFavoriteMount: http://www.wowinterface.com/downloads/info23261-AnyFavoriteMount.html


## Version 1.7.3

- Added ability to summon a custom mount type (e.g. /ravmounts waterwalking)


## Version 1.7.2

- Tighten up slash commands. Add "## Version" command.


## Version 1.7.1

- Fixes bugs introduced in 1.7.0 :)


## Version 1.7.0

- Introduces the inclusion/exclusion feature.


## Version 1.6.5

- Added BlizzCon mounts.


## Version 1.6.4

- Updated for 7.3 and small fixes.


## Version 1.6.3

- Changed how water mounts work by adding a water-walking type. Now, [i]alt[uii]-key will activate your water-walking mount(s) when you're submerged.


## Version 1.6.1

- Fixed broken Extra Ground/Water Mount check.


## Version 1.6.0

- Updated to include Legion's changed C_MountJournal functions.


## Version 1.5.0

- Split multi-person mounts into Ground and Flying—both still called by the Control key.


## Version 1.4.0

- Updated for Legion: renamed C_MountJournal function calls (:rolleyes:), prioritise Yak over Mammoths


## Version 1.3.0

- Overhaul to caching mechanism.
- Fixes for characters without any riding training.


## Version 1.2.1

- Cleaned up faction availability flag for mounts when parsing Mount Journal.
- Cleaned up and fixed Vendor mount logic when parsing Mount Journal.
- Added ## Version tracking for installation and upgrade messages.


## Version 1.2.0

- Minor changes throughout to make the code clearer.. in case anyone wants to read it...
- Merged the two Vendor mount calls. In a couple of months the Transmog mount won't matter much any more will it.


## Version 1.1.2

- Changed elseifs to plain ifs.
- Changed creatureName checks to spellID checks for x-language support.


## Version 1.1.0

- Added caching of data. Maybe it's faster now?
