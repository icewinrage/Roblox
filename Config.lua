--// Venture | 1_Config.lua
local Config = {}

Config.Settings = {
    BackOffset = 100, UpOffset = 2, SideOffset = 0, MaxDistance = 2000,
    ReleaseUpVelocity = 150, ReleaseSideVelocity = 100,
    ESP = false,
    ESPColor = Color3.fromRGB(255, 60, 60),
    NapeColor = Color3.fromRGB(80, 255, 120),
    TargetColor = Color3.fromRGB(255, 210, 60),
    RefillColor = Color3.fromRGB(60, 180, 255),
    PlayerESP = false,
    ShifterESP = false,

    HitboxExpand = false,
    HitboxSize = Vector3.new(300, 200, 300),
    HitboxShape = "Block",
    HitboxShowVisual = false,
    HitboxColor = Color3.fromRGB(255, 100, 200),
    HitboxTransparency = 0.7,
    HitboxParts = {Nape=true, Eyes=false, LeftArm=false, LeftLeg=false, RightArm=false, RightLeg=false},

    Noclip = false,

    AutoFarmEnabled = false,
    AutoFarmOrbitSpeed = 300,
    AutoFarmHoverHeight = 80,
    AutoFarmOrbitRadius = 80,
    AutoFarmSafeDistance = 100,
    AutoFarmDelay = 0.5,
    AutoFarmResponsiveness = 25,

    AutoHealEnabled = false,
    AutoHealThreshold = 50,

    AutoQuestEnabled = false,
    AutoQuestSelected = nil,

    AutoRefillEnabled = false,
    AutoBladeRefillThreshold = 1,
    AutoBladeRefillReturnDelay = 5,
    BladeStateValue = nil,

    FPSBoosterEnabled = false,
    AutoKickOnMod = false,

    Theme = "Dark",
}

Config.DefaultBinds = {
    TPTitan = nil, SafeRelease = nil, ForceReset = nil, RefillTP = nil,
    ToggleGUI = Enum.KeyCode.K, AutoFarmToggle = nil, NoclipToggle = nil,
    AutoHealToggle = nil, FPSBoosterToggle = nil, AutoQuestToggle = nil, AutoRefillToggle = nil
}

Config.MOD_GROUP_ID = 853580851
Config.SUPABASE_URL = "https://ilbxpnyeyhimlyxnmibx.supabase.co"
Config.SUPABASE_KEY = "sb_publishable_5U3FsKotLEcidCucVDGVPw_LTDeNYEt"
Config.OWNER_NAME = "eru_bleu"

return Config
