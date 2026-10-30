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

-- ==========================================
-- ДЕФОЛТНЫЕ НАСТРОЙКИ (Как ты просил)
-- ==========================================
Settings.HitboxSize = Vector3.new(100, 100, 100)
Settings.HitboxShape = "Ball"
Settings.HitboxShowVisual = true
Settings.AutoFarmOrbitRadius = 30      -- Урезали в 2 раза
Settings.AutoFarmHoverHeight = 20      -- Урезали в 2 раза
Settings.AutoFarmSafeDistance = 50
Settings.AutoFarmResponsiveness = 60

local ScreenGui = New("ScreenGui", {
    Name = "VentureAOT_GUI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    DisplayOrder = 999999,
}, PlayerGui)
GUI.ScreenGui = ScreenGui

-- ==========================================
-- INTRO (Твоя анимация)
-- ==========================================
local Loading = New("Frame", {
    Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 100
}, ScreenGui)

local LoadingGlass = New("Frame", {
    Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(8,6,16), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 100
}, Loading)

local CutscenePanel = New("Frame", {
    AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.fromOffset(460,260),
    BackgroundColor3 = Color3.fromRGB(10,12,20), BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 101
}, Loading)
New("UICorner", {CornerRadius = UDim.new(0,20)}, CutscenePanel)
local CutsceneStroke = New("UIStroke", {Color = Color3.fromRGB(125,92,255), Thickness = 1.4, Transparency = 1}, CutscenePanel)
New("UIGradient", {Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22,22,40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,12,20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6,7,13)),
}), Rotation = 135}, CutscenePanel)

New("TextLabel", {AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.22), Size = UDim2.new(1,0,0,46),
    BackgroundTransparency = 1, Text = "V E N T U R E", TextColor3 = Color3.fromRGB(212,175,55), TextSize = 36,
    Font = Enum.Font.GothamBold, TextTransparency = 1, ZIndex = 103}, CutscenePanel)
New("TextLabel", {AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.35), Size = UDim2.new(1,0,0,20),
    BackgroundTransparency = 1, Text = "Executor: " .. GUI.ExecutorName, TextColor3 = Color3.fromRGB(180,180,200), TextSize = 12,
    Font = Enum.Font.Gotham, TextTransparency = 1, ZIndex = 103}, CutscenePanel)
New("TextLabel", {AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.new(1,0,0,20),
    BackgroundTransparency = 1, Text = "by __TheDark", TextColor3 = Color3.fromRGB(212,175,55), TextSize = 15,
    Font = Enum.Font.GothamBold, TextTransparency = 1, ZIndex = 103}, CutscenePanel)

task.spawn(function()
    Tween(LoadingGlass, 0.5, {BackgroundTransparency = 0.4})
    Tween(CutscenePanel, 0.5, {BackgroundTransparency = 0.05})
    Tween(CutsceneStroke, 0.5, {Transparency = 0.2})
    for _, v in ipairs(CutscenePanel:GetChildren()) do
        if v:IsA("TextLabel") then Tween(v, 0.5, {TextTransparency = 0}) end
    end
    task.wait(2.5)
    Tween(LoadingGlass, 0.5, {BackgroundTransparency = 1})
    Tween(CutscenePanel, 0.5, {BackgroundTransparency = 1})
    Tween(CutsceneStroke, 0.5, {Transparency = 1})
    for _, v in ipairs(CutscenePanel:GetChildren()) do
        if v:IsA("TextLabel") then Tween(v, 0.5, {TextTransparency = 1}) end
    end
    task.wait(0.6)
    Loading:Destroy()
    GUI.MainFrame.Visible = true
    Tween(GUI.MainFrame, 0.4, {BackgroundTransparency = 0}, Enum.EasingStyle.Quart)
    if GUI.MainStroke then Tween(GUI.MainStroke, 0.4, {Transparency = 0.15}) end
    for _, v in ipairs(GUI.MainFrame:GetChildren()) do
        if v:IsA("Frame") then Tween(v, 0.4, {BackgroundTransparency = 0}) end
    end
end)

-- ==========================================
-- UI LIBRARY (Твои функции создания)
-- ==========================================
local function MakeSectionLabel(parent, text, y)
    local lbl = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, y),
        BackgroundTransparency = 1, Text = text, TextColor3 = Color3.fromRGB(212,175,55),
        TextSize = 11, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left
    }, parent)
    New("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(125,92,255), BackgroundTransparency = 0.7}, lbl)
    return y + 28
end

local function MakeToggle(parent, label, y, default, cb)
    local frame = New("Frame", {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, y), BackgroundColor3 = Color3.fromRGB(18,18,26), BorderSizePixel = 0}, parent)
    New("UICorner", {CornerRadius = UDim.new(0, 6)}, frame)
    New("TextLabel", {Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(220,220,230), TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left}, frame)
    
    local swBg = New("Frame", {Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = default and Color3.fromRGB(125,92,255) or Color3.fromRGB(50,50,65), BorderSizePixel = 0}, frame)
    New("UICorner", {CornerRadius = UDim.new(1, 0)}, swBg)
    local dot = New("Frame", {Size = UDim2.new(0, 14, 0, 14), Position = default and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2), BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0}, swBg)
    New("UICorner", {CornerRadius = UDim.new(1, 0)}, dot)
    
    local state = default
    local btn = New("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = ""}, frame)
    btn.MouseButton1Click:Connect(function()
        state = not state
        Tween(swBg, 0.2, {BackgroundColor3 = state and Color3.fromRGB(125,92,255) or Color3.fromRGB(50,50,65)})
        Tween(dot, 0.2, {Position = state and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)})
        if cb then cb(state) end
    end)
    return y + 36
end

local function MakeSlider(parent, label, y, min, max, default, suffix, cb)
    local frame = New("Frame", {Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, y), BackgroundColor3 = Color3.fromRGB(18,18,26), BorderSizePixel = 0}, parent)
    New("UICorner", {CornerRadius = UDim.new(0, 6)}, frame)
    New("TextLabel", {Size = UDim2.new(1, -50, 0, 15), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(220,220,230), TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left}, frame)
    local valText = New("TextLabel", {Size = UDim2.new(0, 40, 0, 15), Position = UDim2.new(1, -50, 0, 5), BackgroundTransparency = 1, Text = tostring(default)..suffix, TextColor3 = Color3.fromRGB(125,92,255), TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right}, frame)
    
    local track = New("Frame", {Size = UDim2.new(1, -20, 0, 4), Position = UDim2.new(0, 10, 0, 25), BackgroundColor3 = Color3.fromRGB(50,50,65), BorderSizePixel = 0}, frame)
    New("UICorner", {CornerRadius = UDim.new(1, 0)}, track)
    local fill = New("Frame", {Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = Color3.fromRGB(125,92,255), BorderSizePixel = 0}, track)
    New("UICorner", {CornerRadius = UDim.new(1, 0)}, fill)
    
    local dragging = false
    local function update(x)
        local pct = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor((min + pct * (max - min)) + 0.5)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        valText.Text = tostring(val)..suffix
        if cb then cb(val) end
    end
    
    track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i.Position.X) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    return y + 46
end

local function MakeDropdown(parent, label, options, y, default, cb)
    local frame = New("Frame", {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, y), BackgroundColor3 = Color3.fromRGB(18,18,26), BorderSizePixel = 0}, parent)
    New("UICorner", {CornerRadius = UDim.new(0, 6)}, frame)
    New("TextLabel", {Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = label, TextColor3 = Color3.fromRGB(220,220,230), TextSize = 12, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left}, frame)
    local selBtn = New("TextButton", {Size = UDim2.new(0, 60, 0, 20), Position = UDim2.new(1, -70, 0.5, -10), BackgroundColor3 = Color3.fromRGB(35,35,50), Text = default, TextColor3 = Color3.fromRGB(255,255,255), TextSize = 11, Font = Enum.Font.Gotham, BorderSizePixel = 0}, frame)
    New("UICorner", {CornerRadius = UDim.new(0, 4)}, selBtn)
    
    local isOpen = false
    local list = New("Frame", {Size = UDim2.new(1, 0, 0, #options * 24 + 8), Position = UDim2.new(0, 0, 1, 4), BackgroundColor3 = Color3.fromRGB(12,12,18), Visible = false, ZIndex = 10}, frame)
    New("UICorner", {CornerRadius = UDim.new(0, 6)}, list)
    local layout = New("UIListLayout", {Padding = UDim.new(0, 4)}, list)
    New("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)}, list)
    
    for _, opt in ipairs(options) do
        local btn = New("TextButton", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = opt, TextColor3 = Color3.fromRGB(200,200,200), TextSize = 11, Font = Enum.Font.Gotham, ZIndex = 11}, list)
        btn.MouseButton1Click:Connect(function()
            selBtn.Text = opt; isOpen = false; list.Visible = false
            if cb then cb(opt) end
        end)
    end
    
    selBtn.MouseButton1Click:Connect(function() isOpen = not isOpen; list.Visible = isOpen end)
    return y + 36
end

-- ==========================================
-- MAIN WINDOW (Каркас)
-- ==========================================
local MainFrame = New("Frame", {
    Name = "MainFrame", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(560, 380), BackgroundColor3 = Color3.fromRGB(10,12,20), BackgroundTransparency = 1,
    BorderSizePixel = 0, Visible = false, ClipsDescendants = true, Active = true, Draggable = true
}, ScreenGui)
New("UICorner", {CornerRadius = UDim.new(0,14)}, MainFrame)
GUI.MainFrame = MainFrame
GUI.MainStroke = New("UIStroke", {Color = Color3.fromRGB(125,92,255), Thickness = 1.2, Transparency = 1}, MainFrame)

New("UIGradient", {Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22,22,40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,12,20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6,7,13)),
}), Rotation = 135}, MainFrame)

-- Header
local Header = New("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(14,16,26), BackgroundTransparency = 1, BorderSizePixel = 0}, MainFrame)
New("UICorner", {CornerRadius = UDim.new(0,14)}, Header)
New("Frame", {Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -20), BackgroundColor3 = Color3.fromRGB(14,16,26), BackgroundTransparency = 1, BorderSizePixel = 0}, Header)
New("TextLabel", {Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 16, 0, 0), BackgroundTransparency = 1, Text = "V E N T U R E   A O T", TextColor3 = Color3.fromRGB(212,175,55), TextSize = 16, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left}, Header)
local CloseBtn = New("TextButton", {Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, -32, 0.5, -12), BackgroundColor3 = Color3.fromRGB(50,20,25), Text = "X", TextColor3 = Color3.fromRGB(255,100,100), TextSize = 12, Font = Enum.Font.GothamBold, BorderSizePixel = 0}, Header)
New("UICorner", {CornerRadius = UDim.new(0, 6)}, CloseBtn)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Sidebar
local Sidebar = New("Frame", {Size = UDim2.new(0, 130, 1, -40), Position = UDim2.new(0, 0, 0, 40), BackgroundColor3 = Color3.fromRGB(12,12,20), BackgroundTransparency = 1, BorderSizePixel = 0}, MainFrame)
New("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, Sidebar)
New("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, Sidebar)

-- Content
local Content = New("Frame", {Size = UDim2.new(1, -130, 1, -40), Position = UDim2.new(0, 130, 0, 40), BackgroundColor3 = Color3.fromRGB(15,16,25), BackgroundTransparency = 1, BorderSizePixel = 0}, MainFrame)

-- ==========================================
-- TABS SYSTEM
-- ==========================================
local tabPanels = {}
local tabButtons = {}
local activeTab = 0

local tabs = {
    {Name = "MAIN", Icon = "🏠"},
    {Name = "ESP", Icon = "👁️"},
    {Name = "MISC", Icon = "⚙️"},
    {Name = "CONFIG", Icon = "💾"}
}

local function switchTab(idx)
    activeTab = idx
    for i, panel in ipairs(tabPanels) do panel.Visible = (i == idx) end
    for i, btn in ipairs(tabButtons) do
        Tween(btn, 0.2, {BackgroundColor3 = (i == idx) and Color3.fromRGB(125,92,255) or Color3.fromRGB(20,22,30)})
        btn.TextColor3 = (i == idx) and Color3.fromRGB(255,255,255) or Color3.fromRGB(180,180,200)
    end
end

for i, tab in ipairs(tabs) do
    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Color3.fromRGB(20,22,30),
        Text = " " .. tab.Icon .. "  " .. tab.Name, TextColor3 = Color3.fromRGB(180,180,200),
        TextSize = 12, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0
    }, Sidebar)
    New("UICorner", {CornerRadius = UDim.new(0, 6)}, btn)
    table.insert(tabButtons, btn)
    
    local panel = New("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(125,92,255),
        CanvasSize = UDim2.new(0, 0, 0, 0), Visible = (i == 1)
    }, Content)
    New("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, panel)
    local layout = New("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, panel)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        panel.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    
    table.insert(tabPanels, panel)
    btn.MouseButton1Click:Connect(function() switchTab(i) end)
end
switchTab(1)

-- ==========================================
-- НАПОЛНЕНИЕ ВКЛАДОК
-- ==========================================

-- 1. MAIN
do
    local panel = tabPanels[1]
    local y = 0

    y = MakeSectionLabel(panel, "AUTO FARM", y)
    y = MakeToggle(panel, "Enable Auto Farm", y, Settings.AutoFarmEnabled or false, function(v)
        Settings.AutoFarmEnabled = v
        if v then
            if not Settings.HitboxExpand then Settings.HitboxExpand = true; Funcs.ApplyHitboxToAll() end
            if not Settings.Noclip then Settings.Noclip = true; Funcs.StartNoclip() end
        else
            Funcs.ResetAllHitboxes()
            Funcs.StopNoclip()
            Funcs.CleanupFarm()
            Funcs.State.FarmState.IsAttacking = false
            Funcs.State.FarmState.CurrentTitan = nil
        end
    end)

    y = MakeSectionLabel(panel, "AUTO HEAL", y)
    y = MakeToggle(panel, "Enable Auto Heal", y, Settings.AutoHealEnabled or false, function(v) Settings.AutoHealEnabled = v end)
    y = MakeSlider(panel, "Heal Threshold", y, 10, 100, Settings.AutoHealThreshold or 80, "%", function(v) Settings.AutoHealThreshold = v end)

    y = MakeSectionLabel(panel, "HITBOX EXPANDER", y)
    y = MakeToggle(panel, "Enable Hitbox", y, Settings.HitboxExpand or false, function(v)
        Settings.HitboxExpand = v
        if v then Funcs.ApplyHitboxToAll() else Funcs.ResetAllHitboxes() end
    end)
    y = MakeToggle(panel, "Show Visual", y, Settings.HitboxShowVisual or true, function(v)
        Settings.HitboxShowVisual = v
        if Funcs.ApplyHitboxToAll then Funcs.ApplyHitboxToAll() end
    end)
    y = MakeSlider(panel, "Size", y, 50, 500, 100, " studs", function(v)
        Settings.HitboxSize = Vector3.new(v, v, v)
        if Funcs.ApplyHitboxToAll then Funcs.ApplyHitboxToAll() end
    end)
    y = MakeDropdown(panel, "Shape", {"Block", "Ball", "Cylinder"}, y, "Ball", function(v)
        Settings.HitboxShape = v
        Funcs.ApplyHitboxToAll()
    end)

    y = MakeSectionLabel(panel, "PERFORMANCE & EXPLOITS", y)
    y = MakeToggle(panel, "FPS Booster", y, Settings.FPSBoosterEnabled or false, function(v)
        Settings.FPSBoosterEnabled = v
        if v then Funcs.EnableFPSBooster() else Funcs.DisableFPSBooster() end
    end)
    y = MakeToggle(panel, "Infinite Gas & Blades", y, false, function(v)
        Funcs.ToggleInfiniteSupplies(v)
    end)
    y = MakeToggle(panel, "Noclip", y, Settings.Noclip or false, function(v)
        Settings.Noclip = v
        if v then Funcs.StartNoclip() else Funcs.StopNoclip() end
    end)
end

-- 2. ESP
do
    local panel = tabPanels[2]
    local y = 0

    y = MakeSectionLabel(panel, "VISUALS", y)
    y = MakeToggle(panel, "Titan ESP", y, Settings.ESP or false, function(v) Settings.ESP = v end)
    y = MakeToggle(panel, "Player ESP", y, Settings.PlayerESP or false, function(v) Settings.PlayerESP = v end)
    y = MakeToggle(panel, "Shifter ESP", y, Settings.ShifterESP or false, function(v) Settings.ShifterESP = v end)
end

-- 3. MISC
do
    local panel = tabPanels[3]
    local y = 0

    y = MakeSectionLabel(panel, "PLAYER", y)
    y = MakeSlider(panel, "WalkSpeed", y, 16, 200, 16, " spd", function(v)
        local c = LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then c.Humanoid.WalkSpeed = v end
    end)
    y = MakeSlider(panel, "JumpPower", y, 50, 300, 50, " jp", function(v)
        local c = LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then c.Humanoid.JumpPower = v end
    end)

    y = MakeSectionLabel(panel, "ANTI-AFK", y)
    y = MakeToggle(panel, "Enable Anti-AFK", y, Settings.AntiAFKEnabled or false, function(v)
        Settings.AntiAFKEnabled = v
        if v and Funcs.AntiAFKEnable then Funcs.AntiAFKEnable() end
        if not v and Funcs.AntiAFKDisable then Funcs.AntiAFKDisable() end
    end)
end

-- 4. CONFIG
do
    local panel = tabPanels[4]
    local y = 0
    y = MakeSectionLabel(panel, "CONFIGURATION", y)
    y = MakeToggle(panel, "Hide Keybind List", y, false, function(v)
        if GUI.KeybindListFrame then
            GUI.KeybindListFrame.Visible = not v
        end
    end)
end

print("[Venture GUI] Loaded successfully")
