local _, ns = ...

ns.data = {
    defaults = {
        macro = true,
        clone = "none",
        flexMounts = "both",
        normalMounts = true,
        normalMountModifier = "alt",
        vendorMounts = true,
        vendorMountModifier = "shift",
        passengerMounts = true,
        passengerMountModifier = "ctrl",
        swimmingMounts = true,
    },
    mountTypes = {
        ground = {230},
        flying = {247, 248},
        swimming = {231, 254},
        ahnqiraj = {241},
        vashjir = {232},
        chauffeur = {284},
    },
    mountIDs = {
        vendor = {
            280, -- Traveler's Tundra Mammoth
            284, -- Traveler's Tundra Mammoth
            460, -- Grand Expedition Yak
            1039, -- Mighty Caravan Brutosaur
        },
        passengerGround = {
            240, -- Mechano-Hog (Horde)
            254, -- Black War Mammoth (Alliance)
            255, -- Black War Mammoth (Horde)
            275, -- Mekgineer's Chopper (Alliance)
            286, -- Grand Black War Mammoth (Alliance)
            287, -- Grand Black War Mammoth (Horde)
            288, -- Grand Ice Mammoth (Horde)
            289, -- Grand Ice Mammoth (Alliance)
            1288, -- Explorer's Dunetrekker
        },
        passengerFlying = {
            382, -- X-53 Touring Rocket
            407, -- Sandstone Drake
            455, -- Obsidian Nightwing
            959, -- Stormwind Skychaser (Alliance)
            960, -- Orgrimmar Interceptor (Horde)
        },
        flex = {
            219, -- Headless Horseman's Mount
            363, -- Invincible
            376, -- Celestial Steed
            421, -- Winged Guardian
            439, -- Tyrael's Charger
            451, -- Jeweled Onyx Panther
            455, -- Obsidian Nightwing
            456, -- Sapphire Panther
            457, -- Jade Panther
            458, -- Ruby Panther
            459, -- Sunstone Panther
            468, -- Imperial Quilen
            522, -- Sky Golem
            523, -- Swift Windsteed
            532, -- Ghastly Charger
            594, -- Grinning Reaver
            547, -- Hearthsteed
            593, -- Warforged Nightmare
            764, -- Grove Warden
            779, -- Spirit of Eche'ro
            826, -- Prestigious Bronze Courser
            831, -- Prestigious Royal Courser
            832, -- Prestigious Forest Courser
            833, -- Prestigious Ivory Courser
            834, -- Prestigious Azure Courser
            836, -- Prestigious Midnight Courser
            1222, -- Vulpine Familiar
            1290, -- Squeakers, the Trickster
            1404, -- Silverwind Larion
        },
        maw = {
            1304, -- Mawsworn Soulhunter
            1442, -- Corridor Creeper
            1441, -- Bound Shadehound
        },
    },
    mapIDs = {
        ahnqiraj = {
            247, -- Ruins of Ahn'Qiraj
            319, -- Ahn'Qiraj - The Hive Undergrounds
            320, -- Ahn'Qiraj - The Temple Gates
            321, -- Ahn'Qiraj - Vault of C'Thun
        },
        vashjir = {
            201, -- Kelp'thar Forest
            203, -- Vashj'ir
            204, -- Abyssal Depths
            205, -- Shimmering Expanse
            1272, -- Vashj'ir
        },
        maw = {
            1543, -- The Maw
            1648, -- The Maw
        },
    },
}
