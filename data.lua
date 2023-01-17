local _, ns = ...

ns.data = {
    defaults = {
        macro = true,
        clone = 4,
        flexMounts = 2,
        normalMounts = true,
        normalMountModifier = 2,
        vendorMounts = true,
        vendorMountModifier = 4,
        passengerMounts = true,
        passengerMountModifier = 3,
        swimmingMounts = true,
        normalSwimmingMounts = false,
        zoneSpecificMounts = true,
        travelForm = true,
    },
    mountTypes = {
        ground = {230, 398, 408},
        flying = {247, 248, 407},
        swimming = {231, 254, 407},
        ahnqiraj = {241},
        vashjir = {232},
        chauffeur = {284},
    },
    travelForms = {
        ["Cat Form"] = 768,
        ["Travel Form"] = 783,
        ["Ghost Wolf"] = 2645,
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
        noFlyingSwimming = {
            125, -- Riding Turtle
            312, -- Sea Turtle
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
            961, -- Lucid Nightmare
            1222, -- Vulpine Familiar
            1290, -- Squeakers, the Trickster
            1291, -- Lucky Yun
            1306, -- Swift Gloomhoof
            1307, -- Sundancer
            1330, -- Sunwarmed Furline
            1360, -- Shimmermist Runner
            1404, -- Silverwind Larion
            1413, -- Dauntless Duskrunner
            1414, -- Sinrunner Blanchy
            1426, -- Ascended Skymane
            1511, -- Wandering Arden Doe
        },
        maw = {
            1304, -- Mawsworn Soulhunter
            1442, -- Corridor Creeper
            1441, -- Bound Shadehound
        },
        dragonisles = {
            1589, -- Renewed Proto-Drake
            1590, -- Windborne Velocidrake
            1563, -- Highland Drake
            1591, -- Cliffside Wylderdrake
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
            201,  -- Kelp'thar Forest
            203,  -- Vashj'ir
            204,  -- Abyssal Depths
            205,  -- Shimmering Expanse
            1272, -- Vashj'ir
        },
        nazjatar = {
            1355, -- Nazjatar
        },
        maw = {
            1543, -- The Maw
            1648, -- The Maw
        },
        dragonisles = {
            2022, -- The Waking Shores
            2023, -- Ohn'ahran Plains
            2024, -- The Azure Span
            2025, -- Thaldraszus
            2026, -- The Forbidden Reach
            2085, -- The Primalist Future
            2093, -- The Nokhud Offensive
            2112, -- Valdrakken
        },
    },
    partyMembers = 0,
    raidMembers = 0,
    updateFound = false,
    updateTimeout = 5,
}
