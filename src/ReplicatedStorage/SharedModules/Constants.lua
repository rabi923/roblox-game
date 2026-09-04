--[[
    Hotel Hermes - Core Constants Module
    File: ReplicatedStorage/SharedModules/Constants.lua
    Description: Centralized game constants, physics values, floor themes, audio cues,
                 and networking identifiers for Hotel Hermes.
--]]

local Constants = {}

-- ============================================================================
-- 1. PLAYER LOCOMOTION & STAMINA
-- ============================================================================
Constants.Movement = {
    WalkSpeed = 13,
    CrouchSpeed = 6.5,
    SprintSpeed = 22,
    JumpPower = 0,               -- Horror design: Jumping disabled to prevent physics cheese & preserve claustrophobia
    
    -- Hitbox scaling
    StandingHipHeight = 2.0,
    CrouchingHipHeight = 1.0,
    
    -- Stamina Mechanics
    MaxStamina = 100,
    StaminaSprintDrainRate = 18,  -- Points per second when actively sprinting
    StaminaRegenRate = 14,        -- Points per second after delay
    StaminaRegenDelay = 1.5,      -- Seconds to wait after sprinting before regen starts
    ExhaustionThreshold = 10,     -- Below this stamina, sprinting is disabled until 25% recovered
    RecoveryThreshold = 25,

    -- Audio/Acoustic Noise Radius (Studs for Entity Hearing)
    NoiseRadius = {
        Crouch = 4,
        Walk = 14,
        Sprint = 42,
        DoorInteract = 12,
        ItemDrop = 25,
        ScreamOrTrip = 60,
    }
}

-- ============================================================================
-- 2. FLASHLIGHT SPECIFICATIONS
-- ============================================================================
Constants.Flashlight = {
    MaxBattery = 100,             -- Battery percentage (100 = full)
    DrainRatePerSecond = 0.5,     -- Drains full battery in ~200 seconds of continuous use
    RechargeStationAmount = 50,
    
    -- Light properties
    Color = Color3.fromRGB(245, 235, 205), -- Warm incandescent hotel beam
    Brightness = 2.4,
    Range = 48,                            -- Studs reach
    Angle = 55,                            -- Spread in degrees
    
    -- Flickering thresholds
    LowBatteryThreshold = 20,              -- Starts random micro-flickers
    CriticalBatteryThreshold = 5,          -- Frequent severe cutouts
}

-- ============================================================================
-- 3. FLOOR ARCHITECTURE & PROCEDURAL GENERATION
-- ============================================================================
Constants.Architecture = {
    -- Unit Grid Sizing (in Roblox Studs)
    CellSize = 32,                -- Standard room footprint (32x32 studs)
    WallHeight = 16,              -- Height from floor to ceiling
    DoorwayWidth = 6,
    DoorwayHeight = 10,
    CorridorWidth = 10,
    
    -- Procedural Grid Limits
    MinRoomsPerFloor = 4,
    MaxRoomsPerFloor = 9,
    MaxDeadEnds = 3,
    
    -- Floor Progression
    FreeFloorCeiling = 3,         -- Floors 1 through 3 are 100% Free
    MaxStandardFloors = 50,       -- Story climax at floor 50
    InfiniteAtticStartFloor = 51, -- Endless procedural prestige floors
}

-- ============================================================================
-- 4. FLOOR ATMOSPHERIC & LIGHTING PRESETS
-- ============================================================================
Constants.FloorThemes = {
    [1] = {
        Name = "Grand Vintage",
        Floors = {1, 3},
        Ambient = Color3.fromRGB(15, 12, 10),
        OutdoorAmbient = Color3.fromRGB(10, 8, 7),
        FogColor = Color3.fromRGB(22, 18, 14),
        FogStart = 15,
        FogEnd = 90,
        ColorShift_Top = Color3.fromRGB(255, 230, 180),
        ColorCorrection = {
            Brightness = -0.04,
            Contrast = 0.12,
            Saturation = -0.15,
            TintColor = Color3.fromRGB(255, 245, 230),
        }
    },
    [2] = {
        Name = "Abandoned Service Wing",
        Floors = {4, 10},
        Ambient = Color3.fromRGB(8, 10, 12),
        OutdoorAmbient = Color3.fromRGB(5, 7, 8),
        FogColor = Color3.fromRGB(12, 16, 18),
        FogStart = 10,
        FogEnd = 70,
        ColorShift_Top = Color3.fromRGB(180, 200, 215),
        ColorCorrection = {
            Brightness = -0.06,
            Contrast = 0.18,
            Saturation = -0.35,
            TintColor = Color3.fromRGB(210, 225, 235),
        }
    },
    [3] = {
        Name = "Submerged Basement",
        Floors = {11, 20},
        Ambient = Color3.fromRGB(4, 12, 12),
        OutdoorAmbient = Color3.fromRGB(2, 6, 8),
        FogColor = Color3.fromRGB(6, 18, 20),
        FogStart = 5,
        FogEnd = 55,
        ColorShift_Top = Color3.fromRGB(120, 220, 210),
        ColorCorrection = {
            Brightness = -0.08,
            Contrast = 0.22,
            Saturation = -0.20,
            TintColor = Color3.fromRGB(170, 230, 220),
        }
    },
    [4] = {
        Name = "Mirror Labyrinth",
        Floors = {21, 35},
        Ambient = Color3.fromRGB(10, 5, 14),
        OutdoorAmbient = Color3.fromRGB(6, 3, 9),
        FogColor = Color3.fromRGB(18, 10, 24),
        FogStart = 8,
        FogEnd = 60,
        ColorShift_Top = Color3.fromRGB(210, 150, 240),
        ColorCorrection = {
            Brightness = -0.05,
            Contrast = 0.25,
            Saturation = -0.10,
            TintColor = Color3.fromRGB(230, 190, 255),
        }
    },
    [5] = {
        Name = "The Penthouse Void",
        Floors = {36, 50},
        Ambient = Color3.fromRGB(5, 5, 6),
        OutdoorAmbient = Color3.fromRGB(2, 2, 3),
        FogColor = Color3.fromRGB(8, 7, 9),
        FogStart = 4,
        FogEnd = 45,
        ColorShift_Top = Color3.fromRGB(240, 200, 120),
        ColorCorrection = {
            Brightness = -0.10,
            Contrast = 0.30,
            Saturation = -0.40,
            TintColor = Color3.fromRGB(255, 230, 180),
        }
    }
}

-- ============================================================================
-- 5. ENTITY COMBAT & DETECTION PARAMETERS
-- ============================================================================
Constants.Entity = {
    CatchRadius = 3.8,             -- Studs distance to initiate kill/capture
    SightAngleDeg = 110,           -- Cone of vision angle
    SightDistanceMax = 65,         -- Studs unobstructed line-of-sight
    LoseAggroDistance = 85,        -- Distance to break pursuit
    SearchPatienceSeconds = 12,    -- Time spent searching last known sound/sight location
    JumpscareDuration = 2.4,       -- Camera clamp length before respawn screen
    PatrolSpeed = 8.5,
    ChaseSpeed = 19.5,
}

-- ============================================================================
-- 6. MONETIZATION & DEVELOPER PRODUCTS
-- ============================================================================
Constants.Monetization = {
    -- Developer Product: Re-purchasable check-in pass
    CheckInProductId = 0,          -- Replace with real Developer Product ID in Studio
    CheckInRobuxPrice = 5,
    CheckInSessionTimeoutHours = 1.0, -- Grace period: Re-connecting within 1hr does not re-charge
    
    -- GamePasses (One-time persistent perks)
    GamePasses = {
        VIPRoomKey = {
            Id = 0,                -- Replace with Studio GamePass ID
            RobuxPrice = 10,
            Name = "VIP Room Key",
            Description = "Unlocks the luxury suite in the lobby to decorate & display trophies."
        },
        NightShiftPass = {
            Id = 0,
            RobuxPrice = 25,
            Name = "Night Shift Pass",
            Description = "Enables playing as Hotel Entities in private co-op / PvP mode."
        },
        ConciergeBadge = {
            Id = 0,
            RobuxPrice = 50,
            Name = "Concierge Badge",
            Description = "Early access to new floor themes, 1.25x Hotel Coin multiplier."
        }
    },
    
    -- Daily Room Service Wheel Drop Probabilities (Must sum to 1.0)
    RoomServiceWheelOdds = {
        { ItemType = "Coins", Amount = 50,  Weight = 0.50, DisplayName = "50 Hotel Coins" },
        { ItemType = "Coins", Amount = 150, Weight = 0.30, DisplayName = "150 Hotel Coins" },
        { ItemType = "Cosmetic", ItemId = "skin_worn_brass", Weight = 0.15, DisplayName = "Brass Flashlight Skin" },
        { ItemType = "Coins", Amount = 500, Weight = 0.05, DisplayName = "Grand Jackpot: 500 Coins" }
    }
}

-- ============================================================================
-- 7. DATA PERSISTENCE & SYSTEM PERFORMANCE
-- ============================================================================
Constants.Data = {
    CurrentSchemaVersion = 1,
    DataStoreKeyPrefix = "HotelHermes_v1_",
    AutoSaveIntervalSeconds = 30,
    MaxSaveRetries = 4,
    RetryBaseDelay = 2.0,          -- Exponential backoff base
    SessionLockDuration = 120,     -- Seconds before orphaned lock expires
}

-- ============================================================================
-- 8. COLLECTION SERVICE TAGS & COLLISION GROUPS
-- ============================================================================
Constants.Tags = {
    Interactable = "Hermes_Interactable",
    HidingSpot = "Hermes_HidingSpot",
    LootContainer = "Hermes_LootContainer",
    Door = "Hermes_Door",
    PuzzleComponent = "Hermes_PuzzleComponent",
    Entity = "Hermes_Entity",
    RoomTrigger = "Hermes_RoomTrigger",
    NoiseEmitter = "Hermes_NoiseEmitter",
}

return Constants
