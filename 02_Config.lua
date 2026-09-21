--// Venture | 02_Config.lua
-- Все настройки, темы, ключи и константы

local HttpService = game:GetService("HttpService")

local Config = {}

--====================================================
-- ГЛАВНЫЕ НАСТРОЙКИ
--====================================================
Config.Settings = {
    -- TP / Release
    BackOffset = 100, UpOffset = 2, SideOffset = 0, MaxDistance = 2000,
    ReleaseUpVelocity = 150, ReleaseSideVelocity = 100,

    -- ESP
    ESP = false,
    ESPColor = Color3.fromRGB(255, 60, 60),
    NapeColor = Color3.fromRGB(80, 255, 120),
    TargetColor = Color3.fromRGB(255, 210, 60),
    RefillColor = Color3.fromRGB(60, 180, 255),
    PlayerESP = false,
    ShifterESP = false,

    -- Hitbox
    HitboxExpand = false,
    HitboxSize = Vector3.new(300, 200, 300),
    HitboxShape = "Block",
    HitboxShowVisual = false,
    HitboxColor = Color3.fromRGB(255, 100, 200),
    HitboxTransparency = 0.7,
    HitboxParts = {Nape=true, Eyes=false, LeftArm=false, LeftLeg=false, RightArm=false, RightLeg=false},

    -- Noclip
    Noclip = false,

    -- AutoFarm
    AutoFarmEnabled = false,
    AutoFarmOrbitSpeed = 300,
    AutoFarmHoverHeight = 80,
    AutoFarmOrbitRadius = 80,
    AutoFarmSafeDistance = 100,
    AutoFarmDelay = 0.5,
    AutoFarmResponsiveness = 25,

    -- AutoHeal
    AutoHealEnabled = false,
    AutoHealThreshold = 50,

    -- AutoQuest
    AutoQuestEnabled = false,
    AutoQuestSelected = nil,

    -- AutoRefill
    AutoRefillEnabled = false,
    AutoBladeRefillThreshold = 1,
    AutoBladeRefillReturnDelay = 5,
    BladeStateValue = nil,

    -- Прочее
    FPSBoosterEnabled = false,
    AutoKickOnMod = false,

    -- Тема интерфейса
    Theme = "Dark",
}

--====================================================
-- БИНДЫ ПО УМОЛЧАНИЮ
--====================================================
Config.DefaultBinds = {
    TPTitan = nil,
    SafeRelease = nil,
    ForceReset = nil,
    RefillTP = nil,
    ToggleGUI = Enum.KeyCode.K,
    AutoFarmToggle = nil,
    NoclipToggle = nil,
    AutoHealToggle = nil,
    FPSBoosterToggle = nil,
    AutoQuestToggle = nil,
    AutoRefillToggle = nil,
}

--====================================================
-- КОНСТАНТЫ
--====================================================
Config.MOD_GROUP_ID = 853580851
Config.OWNER_NAME = "eru_bleu"

-- Supabase
Config.SUPABASE_URL = "https://ilbxpnyeyhimlyxnmibx.supabase.co"
Config.SUPABASE_KEY = "sb_publishable_5U3FsKotLEcidCucVDGVPw_LTDeNYEt"
Config.SUPABASE_TABLE = "venture_beacons"

-- Интервалы (сек)
Config.BEACON_INTERVAL = 15
Config.FETCH_INTERVAL = 10
Config.TIMEOUT_SECONDS = 60
Config.CLEANUP_INTERVAL = 300

--====================================================
-- 4 ТЕМЫ ИНТЕРФЕЙСА
--====================================================
Config.Themes = {
    Dark = {
        Name = "Dark",
        MainBg = Color3.fromRGB(10, 12, 20),
        MainGradientA = Color3.fromRGB(24, 24, 42),
        MainGradientB = Color3.fromRGB(11, 13, 22),
        MainGradientC = Color3.fromRGB(7, 8, 14),
        Accent = Color3.fromRGB(125, 92, 255),
        AccentSoft = Color3.fromRGB(80, 60, 160),
        AccentDim = Color3.fromRGB(50, 42, 90),
        TabBg = Color3.fromRGB(22, 24, 36),
        TabBgActive = Color3.fromRGB(50, 42, 90),
        TabStroke = Color3.fromRGB(60, 62, 88),
        TabText = Color3.fromRGB(170, 172, 190),
        TabTextActive = Color3.fromRGB(212, 175, 55),
        BtnBg = Color3.fromRGB(21, 23, 36),
        BtnBgHover = Color3.fromRGB(32, 34, 52),
        BtnStroke = Color3.fromRGB(52, 55, 80),
        BtnText = Color3.fromRGB(220, 222, 240),
        SubText = Color3.fromRGB(140, 143, 165),
        SectionText = Color3.fromRGB(140, 120, 60),
        TitleText = Color3.fromRGB(248, 247, 255),
        SubtitleText = Color3.fromRGB(153, 157, 178),
        SliderFill = Color3.fromRGB(125, 92, 255),
        SliderBg = Color3.fromRGB(40, 42, 58),
        ToggleOn = Color3.fromRGB(80, 60, 160),
        ToggleOff = Color3.fromRGB(40, 42, 58),
        ToggleKnob = Color3.fromRGB(240, 240, 245),
        CloseBtnBg = Color3.fromRGB(28, 30, 44),
        CloseBtnText = Color3.fromRGB(185, 187, 205),
        KeybindBg = Color3.fromRGB(10, 12, 20),
        KeybindGradientA = Color3.fromRGB(22, 22, 40),
        KeybindGradientB = Color3.fromRGB(10, 12, 20),
        KeybindGradientC = Color3.fromRGB(6, 7, 13),
    },
    Purple = {
        Name = "Purple",
        MainBg = Color3.fromRGB(22, 8, 40),
        MainGradientA = Color3.fromRGB(50, 20, 80),
        MainGradientB = Color3.fromRGB(28, 12, 48),
        MainGradientC = Color3.fromRGB(15, 6, 30),
        Accent = Color3.fromRGB(200, 100, 255),
        AccentSoft = Color3.fromRGB(150, 70, 220),
        AccentDim = Color3.fromRGB(110, 50, 180),
        TabBg = Color3.fromRGB(38, 14, 65),
        TabBgActive = Color3.fromRGB(120, 50, 200),
        TabStroke = Color3.fromRGB(140, 70, 200),
        TabText = Color3.fromRGB(210, 180, 255),
        TabTextActive = Color3.fromRGB(255, 220, 255),
        BtnBg = Color3.fromRGB(40, 15, 70),
        BtnBgHover = Color3.fromRGB(70, 30, 110),
        BtnStroke = Color3.fromRGB(130, 60, 200),
        BtnText = Color3.fromRGB(230, 210, 255),
        SubText = Color3.fromRGB(190, 160, 240),
        SectionText = Color3.fromRGB(220, 140, 255),
        TitleText = Color3.fromRGB(255, 240, 255),
        SubtitleText = Color3.fromRGB(200, 170, 240),
        SliderFill = Color3.fromRGB(200, 100, 255),
        SliderBg = Color3.fromRGB(60, 25, 95),
        ToggleOn = Color3.fromRGB(180, 80, 255),
        ToggleOff = Color3.fromRGB(60, 25, 95),
        ToggleKnob = Color3.fromRGB(255, 240, 255),
        CloseBtnBg = Color3.fromRGB(60, 20, 100),
        CloseBtnText = Color3.fromRGB(230, 200, 255),
        KeybindBg = Color3.fromRGB(22, 8, 40),
        KeybindGradientA = Color3.fromRGB(50, 20, 80),
        KeybindGradientB = Color3.fromRGB(28, 12, 48),
        KeybindGradientC = Color3.fromRGB(15, 6, 30),
    },
    Red = {
        Name = "Red",
        MainBg = Color3.fromRGB(25, 5, 5),
        MainGradientA = Color3.fromRGB(60, 15, 15),
        MainGradientB = Color3.fromRGB(35, 8, 8),
        MainGradientC = Color3.fromRGB(20, 3, 3),
        Accent = Color3.fromRGB(255, 60, 60),
        AccentSoft = Color3.fromRGB(200, 40, 40),
        AccentDim = Color3.fromRGB(140, 30, 30),
        TabBg = Color3.fromRGB(45, 10, 10),
        TabBgActive = Color3.fromRGB(180, 40, 40),
        TabStroke = Color3.fromRGB(180, 50, 50),
        TabText = Color3.fromRGB(255, 180, 180),
        TabTextActive = Color3.fromRGB(255, 255, 255),
        BtnBg = Color3.fromRGB(45, 10, 10),
        BtnBgHover = Color3.fromRGB(80, 20, 20),
        BtnStroke = Color3.fromRGB(160, 45, 45),
        BtnText = Color3.fromRGB(255, 220, 220),
        SubText = Color3.fromRGB(220, 160, 160),
        SectionText = Color3.fromRGB(255, 120, 120),
        TitleText = Color3.fromRGB(255, 240, 240),
        SubtitleText = Color3.fromRGB(220, 170, 170),
        SliderFill = Color3.fromRGB(255, 60, 60),
        SliderBg = Color3.fromRGB(70, 15, 15),
        ToggleOn = Color3.fromRGB(220, 50, 50),
        ToggleOff = Color3.fromRGB(70, 15, 15),
        ToggleKnob = Color3.fromRGB(255, 240, 240),
        CloseBtnBg = Color3.fromRGB(70, 15, 15),
        CloseBtnText = Color3.fromRGB(255, 200, 200),
        KeybindBg = Color3.fromRGB(25, 5, 5),
        KeybindGradientA = Color3.fromRGB(60, 15, 15),
        KeybindGradientB = Color3.fromRGB(35, 8, 8),
        KeybindGradientC = Color3.fromRGB(20, 3, 3),
    },
    White = {
        Name = "White",
        MainBg = Color3.fromRGB(235, 235, 240),
        MainGradientA = Color3.fromRGB(255, 255, 255),
        MainGradientB = Color3.fromRGB(240, 240, 245),
        MainGradientC = Color3.fromRGB(225, 225, 232),
        Accent = Color3.fromRGB(80, 90, 220),
        AccentSoft = Color3.fromRGB(100, 110, 230),
        AccentDim = Color3.fromRGB(140, 150, 240),
        TabBg = Color3.fromRGB(220, 220, 228),
        TabBgActive = Color3.fromRGB(80, 90, 220),
        TabStroke = Color3.fromRGB(180, 180, 195),
        TabText = Color3.fromRGB(60, 60, 80),
        TabTextActive = Color3.fromRGB(255, 255, 255),
        BtnBg = Color3.fromRGB(245, 245, 250),
        BtnBgHover = Color3.fromRGB(220, 220, 235),
        BtnStroke = Color3.fromRGB(190, 190, 205),
        BtnText = Color3.fromRGB(40, 40, 60),
        SubText = Color3.fromRGB(110, 110, 130),
        SectionText = Color3.fromRGB(80, 90, 220),
        TitleText = Color3.fromRGB(30, 30, 50),
        SubtitleText = Color3.fromRGB(90, 90, 110),
        SliderFill = Color3.fromRGB(80, 90, 220),
        SliderBg = Color3.fromRGB(210, 210, 220),
        ToggleOn = Color3.fromRGB(80, 90, 220),
        ToggleOff = Color3.fromRGB(200, 200, 210),
        ToggleKnob = Color3.fromRGB(255, 255, 255),
        CloseBtnBg = Color3.fromRGB(220, 220, 228),
        CloseBtnText = Color3.fromRGB(60, 60, 80),
        KeybindBg = Color3.fromRGB(235, 235, 240),
        KeybindGradientA = Color3.fromRGB(255, 255, 255),
        KeybindGradientB = Color3.fromRGB(240, 240, 245),
        KeybindGradientC = Color3.fromRGB(225, 225, 232),
    },
}

--====================================================
-- ЗАГРУЗКА СОХРАНЁННЫХ НАСТРОЕК
--====================================================
function Config.LoadTheme()
    if not (isfile and readfile) then return end
    if not isfile("VentureAOT_Theme.json") then return end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile("VentureAOT_Theme.json"))
    end)
    if ok and data and data.Theme and Config.Themes[data.Theme] then
        Config.Settings.Theme = data.Theme
    end
end

function Config.SaveTheme()
    if not writefile then return end
    pcall(function()
        writefile("VentureAOT_Theme.json", HttpService:JSONEncode({Theme = Config.Settings.Theme}))
    end)
end

function Config.LoadSecurity()
    if not (isfile and readfile) then return end
    if not isfile("VentureAOT_Security.json") then return end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile("VentureAOT_Security.json"))
    end)
    if ok and data then
        Config.Settings.AutoKickOnMod = data.AutoKick or false
    end
end

function Config.SaveSecurity()
    if not writefile then return end
    pcall(function()
        writefile("VentureAOT_Security.json", HttpService:JSONEncode({AutoKick = Config.Settings.AutoKickOnMod}))
    end)
end

function Config.LoadKeybinds()
    if not (isfile and readfile) then return end
    if not isfile("VentureAOT_Keybinds.json") then return end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile("VentureAOT_Keybinds.json"))
    end)
    if ok and data then
        Config.SavedKeybinds = data
    end
end

function Config.SaveKeybinds(keybinds)
    if not writefile then return end
    local data = {}
    for k, v in pairs(keybinds) do
        data[k] = v and v.Name or ""
    end
    pcall(function()
        writefile("VentureAOT_Keybinds.json", HttpService:JSONEncode(data))
    end)
end

-- Автозагрузка при первом обращении
Config.LoadTheme()
Config.LoadSecurity()

_G.Venture = _G.Venture or {}
_G.Venture.Config = Config

return Config
