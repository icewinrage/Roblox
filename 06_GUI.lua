local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils = _G.Venture.Utils
local Theme = _G.Venture.Theme
local Funcs = _G.Venture.Functions
local Players = Shared.Players
local UserInputService = Shared.UserInputService
local TweenService = Shared.TweenService
local LocalPlayer = Shared.LocalPlayer
local PlayerGui = Shared.PlayerGui
local IsMobile = Shared.IsMobile
local Settings = Config.Settings
local New = Utils.New
local Tween = Utils.Tween

local GUI = {}
GUI.ExecutorName = Utils.DetectExecutor()

local ScreenGui = New("ScreenGui", {
    Name = "VentureAOT_GUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999999,
}, PlayerGui)
GUI.ScreenGui = ScreenGui

-- ==========================================
-- INTRO
-- ==========================================
local Loading = New("Frame", {
    Size = UDim2.fromScale(1,1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 100
}, ScreenGui)

local LoadingGlass = New("Frame", {
    Size = UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.fromRGB(8,6,16),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 100
}, Loading)

local CutscenePanel = New("Frame", {
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.fromScale(0.5,0.5),
    Size = UDim2.fromOffset(460,260),
    BackgroundColor3 = Color3.fromRGB(10,12,20),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 101
}, Loading)
New("UICorner", {CornerRadius = UDim.new(0,20)}, CutscenePanel)

local CutsceneStroke = New("UIStroke", {
    Color = Color3.fromRGB(125,92,255),
    Thickness = 1.4,
    Transparency = 1
}, CutscenePanel)

New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22,22,40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,12,20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6,7,13)),
    }),
    Rotation = 135
}, CutscenePanel)

local Logo = New("TextLabel", {
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.fromScale(0.5,0.22),
    Size = UDim2.new(1,0,0,46),
    BackgroundTransparency = 1,
    Text = "V E N T U R E",
    TextColor3 = Color3.fromRGB(212,175,55),
    TextSize = 36,
    Font = Enum.Font.GothamBold,
    TextTransparency = 1,
    ZIndex = 103
}, CutscenePanel)

local LogoSub = New("TextLabel", {
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.fromScale(0.5,0.35),
    Size = UDim2.new(1,0,0,20),
    BackgroundTransparency = 1,
    Text = "Executor: " .. GUI.ExecutorName,
    TextColor3 = Color3.fromRGB(180,180,200),
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextTransparency = 1,
    ZIndex = 103
}, CutscenePanel)

local AuthorLabel = New("TextLabel", {
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.fromScale(0.5,0.5),
    Size = UDim2.new(1,0,0,20),
    BackgroundTransparency = 1,
    Text = "by __TheDark",
    TextColor3 = Color3.fromRGB(212,175,55),
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextTransparency = 1,
    ZIndex = 103
}, CutscenePanel)

local DiscordLabel = New("TextLabel", {
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.fromScale(0.5,0.58),
    Size = UDim2.new(1,0,0,20),
    BackgroundTransparency = 1,
    Text = "discord.gg/UHCwX78Npc",
    TextColor3 = Color3.fromRGB(125,160,255),
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextTransparency = 1,
    ZIndex = 103
}, CutscenePanel)

local VersionLabel = New("TextLabel", {
    AnchorPoint = Vector2.new(0.5,0.5),
    Position = UDim2.fromScale(0.5,0.66),
    Size = UDim2.new(1,0,0,20),
    BackgroundTransparency = 1,
    Text = "v1.5",
    TextColor3 = Color3.fromRGB(180,180,200),
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextTransparency = 1,
    ZIndex = 103
}, CutscenePanel)

GUI.Loading = Loading

-- ==========================================
-- KEYBIND LIST
-- ==========================================
local KeybindListGui = New("ScreenGui", {
    Name = "VentureKeybindList",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999998,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)
GUI.KeybindListGui = KeybindListGui

local KeybindListFrame = New("Frame", {
    Name = "KeybindList",
    AnchorPoint = Vector2.new(0,0.5),
    Position = UDim2.new(0,20,0.5,0),
    Size = UDim2.fromOffset(200,300),
    BackgroundColor3 = Config.Themes.Dark.KeybindBg,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
}, KeybindListGui)
New("UICorner", {CornerRadius = UDim.new(0,14)}, KeybindListFrame)

local KBListStroke = New("UIStroke", {
    Color = Color3.fromRGB(125,92,255),
    Thickness = 1.2,
    Transparency = 0.25
}, KeybindListFrame)

local KBListGrad = New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22,22,40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,12,20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(6,7,13)),
    }),
    Rotation = 135
}, KeybindListFrame)

New("Frame", {
    Position = UDim2.new(0,30,0,0),
    Size = UDim2.new(1,-60,0,2),
    BackgroundColor3 = Color3.fromRGB(125,92,255),
    BorderSizePixel = 0
}, KeybindListFrame)

New("TextLabel", {
    Position = UDim2.new(0,14,0,12),
    Size = UDim2.new(1,-28,0,20),
    BackgroundTransparency = 1,
    Text = " KEYBINDS",
    TextColor3 = Color3.fromRGB(212,175,55),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, KeybindListFrame)

local KBContainer = New("Frame", {
    Position = UDim2.new(0,14,0,40),
    Size = UDim2.new(1,-28,1,-52),
    BackgroundTransparency = 1
}, KeybindListFrame)
GUI.KeybindListFrame = KeybindListFrame

-- ==========================================
-- MAIN WINDOW (создаем каркас)
-- ==========================================
-- (Здесь должен быть код создания MainFrame, Header, Sidebar, TabPanels, 
-- который у вас уже есть. Я оставляю его без изменений, чтобы не ломать стиль,
-- и перехожу сразу к наполнению вкладок, так как это основная часть запроса.)
-- Предполагаем, что переменные tabPanels и функции Make* уже определены.

-- ==========================================
-- УСТАНАВЛИВАЕМ ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ
-- ==========================================
-- Хитбокс: 100 studs, форма Шар
Settings.HitboxSize = Vector3.new(100, 100, 100)
Settings.HitboxShape = "Ball"
Settings.HitboxShowVisual = true -- Включаем визуал сразу

-- Автофарм: уменьшаем дистанцию в 2 раза
Settings.AutoFarmOrbitRadius = 30
Settings.AutoFarmHoverHeight = 20
Settings.AutoFarmSafeDistance = 50
Settings.AutoFarmResponsiveness = 60

-- ==========================================
-- ВКЛАДКА 1: MAIN
-- ==========================================
do
    local panel = tabPanels[1]
    local y = 0

    y = MakeSectionLabel(panel, "AUTO FARM", y)
    y = MakeToggle(panel, "Enable Auto Farm", y, Settings.AutoFarmEnabled or false, function(v)
        Settings.AutoFarmEnabled = v
        if v then
            if not Settings.HitboxExpand then
                Settings.HitboxExpand = true
                Funcs.ApplyHitboxToAll()
            end
            if not Settings.Noclip then
                Settings.Noclip = true
                Funcs.StartNoclip()
            end
        else
            Funcs.ResetAllHitboxes()
            Funcs.StopNoclip()
            Funcs.CleanupFarm()
            Funcs.State.FarmState.IsAttacking = false
            Funcs.State.FarmState.CurrentTitan = nil
        end
    end)

    y = MakeSectionLabel(panel, "AUTO HEAL", y)
    y = MakeToggle(panel, "Enable Auto Heal", y, Settings.AutoHealEnabled or false, function(v)
        Settings.AutoHealEnabled = v
    end)
    y = MakeSlider(panel, "Heal Threshold", y, 10, 100, Settings.AutoHealThreshold or 80, "%", function(v)
        Settings.AutoHealThreshold = v
    end)

    y = MakeSectionLabel(panel, "HITBOX EXPANDER", y)
    y = MakeToggle(panel, "Enable Hitbox", y, Settings.HitboxExpand or false, function(v)
        Settings.HitboxExpand = v
        if v then
            Funcs.ApplyHitboxToAll()
        else
            Funcs.ResetAllHitboxes()
        end
    end)
    y = MakeToggle(panel, "Show Visual", y, Settings.HitboxShowVisual or true, function(v)
        Settings.HitboxShowVisual = v
        if Funcs.ApplyHitboxToAll then
            Funcs.ApplyHitboxToAll()
        end
    end)
    y = MakeSlider(panel, "Size", y, 50, 500, 100, " studs", function(v)
        Settings.HitboxSize = Vector3.new(v, v, v)
        if Funcs.ApplyHitboxToAll then
            Funcs.ApplyHitboxToAll()
        end
    end)
    y = MakeDropdown(panel, "Shape", {"Block", "Ball", "Cylinder"}, y, "Ball", function(v)
        Settings.HitboxShape = v
        Funcs.ApplyHitboxToAll()
    end)

    y = MakeSectionLabel(panel, "PERFORMANCE & EXPLOITS", y)
    y = MakeToggle(panel, "FPS Booster", y, Settings.FPSBoosterEnabled or false, function(v)
        Settings.FPSBoosterEnabled = v
        if v then
            Funcs.EnableFPSBooster()
        else
            Funcs.DisableFPSBooster()
        end
    end)
    y = MakeToggle(panel, "Infinite Gas & Blades", y, false, function(v)
        -- Включаем StressTest для бесконечных ресурсов
        Funcs.ToggleInfiniteSupplies(v)
    end)
    y = MakeToggle(panel, "Noclip", y, Settings.Noclip or false, function(v)
        Settings.Noclip = v
        if v then
            Funcs.StartNoclip()
        else
            Funcs.StopNoclip()
        end
    end)
end

-- ==========================================
-- ВКЛАДКА 2: ESP
-- ==========================================
do
    local panel = tabPanels[2]
    local y = 0

    y = MakeSectionLabel(panel, "VISUALS", y)
    y = MakeToggle(panel, "Titan ESP", y, Settings.ESP or false, function(v)
        Settings.ESP = v
    end)
    y = MakeToggle(panel, "Player ESP", y, Settings.PlayerESP or false, function(v)
        Settings.PlayerESP = v
    end)
    y = MakeToggle(panel, "Shifter ESP", y, Settings.ShifterESP or false, function(v)
        Settings.ShifterESP = v
    end)

    y = MakeSectionLabel(panel, "COLORS", y)
    -- Если у вас есть MakeColorPicker, можно добавить его сюда.
    -- В текущем коде используется просто установка цвета через настройки.
    y = MakeButton(panel, "Set Red ESP", "Fast red color", y, function()
        Settings.ESPColor = Color3.fromRGB(255, 60, 60)
        Settings.NapeColor = Color3.fromRGB(80, 255, 120)
        Settings.TargetColor = Color3.fromRGB(255, 210, 60)
    end)
    y = MakeButton(panel, "Set Green ESP", "Fast green color", y, function()
        Settings.ESPColor = Color3.fromRGB(60, 255, 60)
    end)
end

-- ==========================================
-- ВКЛАДКА 3: MISC
-- ==========================================
do
    local panel = tabPanels[3]
    local y = 0

    y = MakeSectionLabel(panel, "PLAYER", y)
    y = MakeSlider(panel, "WalkSpeed", y, 16, 200, 16, " spd", function(v)
        local c = LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then
            c.Humanoid.WalkSpeed = v
        end
    end)
    y = MakeSlider(panel, "JumpPower", y, 50, 300, 50, " jp", function(v)
        local c = LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then
            c.Humanoid.JumpPower = v
        end
    end)

    y = MakeSectionLabel(panel, "ANTI-AFK", y)
    y = MakeToggle(panel, "Enable Anti-AFK", y, Settings.AntiAFKEnabled or false, function(v)
        Settings.AntiAFKEnabled = v
        if v and Funcs.AntiAFKEnable then
            Funcs.AntiAFKEnable()
        elseif not v and Funcs.AntiAFKDisable then
            Funcs.AntiAFKDisable()
        end
    end)
end

-- ==========================================
-- ВКЛАДКА 4: CONFIG / SETTINGS (ОСТАВЛЯЕМ ПУСТОЙ ИЛИ ДОБАВЛЯЕМ СВОЕ)
-- ==========================================
do
    local panel = tabPanels[4]
    local y = 0
    y = MakeSectionLabel(panel, "CONFIG", y)
    y = MakeButton(panel, "Save Config", "Save current settings", y, function()
        -- Ваша логика сохранения
    end)
    y = MakeButton(panel, "Load Config", "Load saved settings", y, function()
        -- Ваша логика загрузки
    end)
end

print("[Venture GUI] Loaded | Optimized & Cleaned")
