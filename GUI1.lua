--[[
    ═══════════════════════════════════════════════════════════════════════════
    VENTURE AOT v3.0 — Universal GUI Engine (GUI1.lua)
    ═══════════════════════════════════════════════════════════════════════════
    Автор: Data Hub Team
    Совместимость: Xeno / Delta / Solara / Wave / Arceus X / Codex / Oxygen /
                   Krnl / Fluxus / Synapse / SirHurt / Hydrogen / AWP
    Возможности:
        • 5 тем + кастомный акцент
        • Mobile-friendly (touch + scale)
        • Поиск по настройкам
        • Тултипы при наведении
        • Watermark (FPS / Ping / Time / Executor)
        • Множество конфигов (Save/Load/Delete)
        • Keybind-система (GUI toggle + функции)
        • Уведомления с иконками
        • Плавные анимации (TweenService)
        • Без внешних зависимостей
    ═══════════════════════════════════════════════════════════════════════════
--]]

-- ═══════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")
local Stats            = game:GetService("Stats")
local LocalPlayer      = Players.LocalPlayer
local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")
local Camera           = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════════
-- GLOBAL HOOK
-- ═══════════════════════════════════════════════════════════════
_G.Venture = _G.Venture or {}
local F = _G.Venture.F or { Settings = {}, State = {} }
local S = F.Settings or {}
_G.Venture.F = F

-- ═══════════════════════════════════════════════════════════════
-- UTILS
-- ═══════════════════════════════════════════════════════════════
local UI = {}
UI.__index = UI

local function New(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function Tween(obj, time, props, style, dir)
    local info = TweenInfo.new(time or 0.2,
        style or Enum.EasingStyle.Quart,
        dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function Round(obj, r)
    return New("UICorner", { CornerRadius = UDim.new(0, r or 6) }, obj)
end

local function Stroke(obj, color, thickness, transparency)
    return New("UIStroke", {
        Color = color or Color3.fromRGB(60, 60, 80),
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
end

local function Gradient(obj, c1, c2, rot)
    return New("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rot or 90,
    }, obj)
end

local function Pad(obj, px, py)
    return New("UIPadding", {
        PaddingTop = UDim.new(0, py or 0),
        PaddingBottom = UDim.new(0, py or 0),
        PaddingLeft = UDim.new(0, px or 0),
        PaddingRight = UDim.new(0, px or 0),
    }, obj)
end

local function IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function IsSafeExecutor()
    return pcall(function() return game:GetService("CoreGui").Name end)
end

-- ═══════════════════════════════════════════════════════════════
-- THEMES
-- ═══════════════════════════════════════════════════════════════
local Themes = {
    Dark = {
        Background = Color3.fromRGB(14, 14, 20),
        Secondary  = Color3.fromRGB(22, 22, 32),
        Accent     = Color3.fromRGB(125, 92, 255),
        Text       = Color3.fromRGB(235, 235, 245),
        SubText    = Color3.fromRGB(150, 150, 170),
        Hover      = Color3.fromRGB(38, 38, 52),
        Stroke     = Color3.fromRGB(60, 60, 80),
        Element    = Color3.fromRGB(30, 30, 44),
        Success    = Color3.fromRGB(80, 220, 120),
        Warning    = Color3.fromRGB(255, 190, 60),
        Danger     = Color3.fromRGB(255, 80, 80),
    },
    Purple = {
        Background = Color3.fromRGB(20, 8, 40),
        Secondary  = Color3.fromRGB(32, 14, 58),
        Accent     = Color3.fromRGB(200, 100, 255),
        Text       = Color3.fromRGB(245, 225, 255),
        SubText    = Color3.fromRGB(180, 150, 210),
        Hover      = Color3.fromRGB(55, 25, 90),
        Stroke     = Color3.fromRGB(90, 50, 140),
        Element    = Color3.fromRGB(45, 20, 75),
        Success    = Color3.fromRGB(120, 220, 180),
        Warning    = Color3.fromRGB(255, 200, 120),
        Danger     = Color3.fromRGB(255, 100, 140),
    },
    Red = {
        Background = Color3.fromRGB(22, 5, 8),
        Secondary  = Color3.fromRGB(38, 10, 14),
        Accent     = Color3.fromRGB(255, 60, 80),
        Text       = Color3.fromRGB(255, 225, 225),
        SubText    = Color3.fromRGB(200, 150, 150),
        Hover      = Color3.fromRGB(60, 15, 20),
        Stroke     = Color3.fromRGB(100, 30, 40),
        Element    = Color3.fromRGB(50, 14, 18),
        Success    = Color3.fromRGB(120, 220, 120),
        Warning    = Color3.fromRGB(255, 200, 80),
        Danger     = Color3.fromRGB(255, 60, 60),
    },
    White = {
        Background = Color3.fromRGB(245, 245, 250),
        Secondary  = Color3.fromRGB(232, 232, 240),
        Accent     = Color3.fromRGB(80, 100, 220),
        Text       = Color3.fromRGB(30, 30, 50),
        SubText    = Color3.fromRGB(100, 100, 120),
        Hover      = Color3.fromRGB(220, 220, 235),
        Stroke     = Color3.fromRGB(200, 200, 215),
        Element    = Color3.fromRGB(220, 220, 232),
        Success    = Color3.fromRGB(60, 180, 100),
        Warning    = Color3.fromRGB(220, 160, 40),
        Danger     = Color3.fromRGB(220, 60, 60),
    },
    Ocean = {
        Background = Color3.fromRGB(8, 20, 30),
        Secondary  = Color3.fromRGB(14, 32, 48),
        Accent     = Color3.fromRGB(60, 200, 220),
        Text       = Color3.fromRGB(220, 240, 250),
        SubText    = Color3.fromRGB(140, 170, 190),
        Hover      = Color3.fromRGB(25, 55, 80),
        Stroke     = Color3.fromRGB(40, 90, 120),
        Element    = Color3.fromRGB(20, 45, 68),
        Success    = Color3.fromRGB(80, 220, 180),
        Warning    = Color3.fromRGB(255, 200, 100),
        Danger     = Color3.fromRGB(255, 90, 100),
    },
}

-- ═══════════════════════════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════════════════════════
local CONFIG_FOLDER = "VentureAOT_Configs"
local Config = {
    Theme = "Dark",
    Keybind = "RightShift",
    Size = {640, 460},
    Position = {0.5, 0.5},
    Opacity = 1,
    AutoSave = true,
    Minimized = false,
    Watermark = true,
    Animations = true,
    MobileScale = 1,
}

local HAS_FILEIO = (writefile and readfile and isfile and listfiles)
local HAS_CORE_ACCESS = pcall(function() CoreGui.Name end)

local function EnsureFolder()
    if not HAS_FILEIO then return end
    pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
    end)
end

local function SaveConfig(name)
    name = name or "default"
    if not HAS_FILEIO then return false end
    EnsureFolder()
    pcall(function()
        writefile(CONFIG_FOLDER .. "/" .. name .. ".json",
            HttpService:JSONEncode(Config))
    end)
    return true
end

local function LoadConfig(name)
    name = name or "default"
    if not HAS_FILEIO then return false end
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    local ok, raw = pcall(readfile, path)
    if not ok or not raw then return false end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if ok2 and type(data) == "table" then
        for k, v in pairs(data) do Config[k] = v end
        return true
    end
    return false
end

local function ListConfigs()
    if not HAS_FILEIO then return {} end
    EnsureFolder()
    local out = {}
    pcall(function()
        for _, f in ipairs(listfiles(CONFIG_FOLDER)) do
            local name = f:match("([^/\\]+)%.json$")
            if name then table.insert(out, name) end
        end
    end)
    return out
end

local function DeleteConfig(name)
    if not HAS_FILEIO then return false end
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    if isfile(path) and delfile then pcall(delfile, path) return true end
    return false
end

LoadConfig("default")

-- ═══════════════════════════════════════════════════════════════
-- THEME STATE
-- ═══════════════════════════════════════════════════════════════
local CurrentTheme = Themes[Config.Theme] or Themes.Dark

-- ═══════════════════════════════════════════════════════════════
-- LIBRARY OBJECT
-- ═══════════════════════════════════════════════════════════════
local Library = {
    Theme = CurrentTheme,
    Themes = Themes,
    Config = Config,
    Tabs = {},
    Elements = {},
    Notifications = {},
    Tooltips = {},
    Configs = ListConfigs,
    ToggleKey = Enum.KeyCode[Config.Keybind] or Enum.KeyCode.RightShift,
    Visible = true,
    WatermarkVisible = Config.Watermark,
    Animations = Config.Animations,
}
UI.__index = Library

function Library:Register(el)
    table.insert(self.Elements, el)
    return el
end

function Library:SetTheme(name)
    local t = Themes[name]
    if not t then return end
    self.Theme = t
    Config.Theme = name
    if Config.AutoSave then SaveConfig("default") end
    self:RefreshTheme()
end

function Library:RefreshTheme()
    local t = self.Theme
    if self.MainFrame then Tween(self.MainFrame, 0.25, { BackgroundColor3 = t.Secondary }) end
    if self.Header then Tween(self.Header, 0.25, { BackgroundColor3 = t.Background }) end
    if self.Sidebar then Tween(self.Sidebar, 0.25, { BackgroundColor3 = t.Background }) end
    if self.Content then Tween(self.Content, 0.25, { BackgroundColor3 = t.Secondary }) end
    if self.Footer then Tween(self.Footer, 0.25, { BackgroundColor3 = t.Background }) end
    for _, el in ipairs(self.Elements) do
        if el.Refresh then pcall(el.Refresh, el, t) end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════
function Library:Notify(opts)
    opts = opts or {}
    local title = opts.Title or "Venture"
    local text  = opts.Content or opts.Text or ""
    local dur   = opts.Duration or 4
    local kind  = opts.Type or "info" -- info | success | warning | danger

    local accent = self.Theme.Accent
    if kind == "success" then accent = self.Theme.Success
    elseif kind == "warning" then accent = self.Theme.Warning
    elseif kind == "danger" then accent = self.Theme.Danger end

    local isMobile = IsMobile()
    local w = isMobile and 260 or 300

    local n = New("Frame", {
        Size = UDim2.new(0, w, 0, 72),
        Position = UDim2.new(1, w + 20, 1, -90 - (#self.Notifications * 82)),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = self.ScreenGui,
    })
    Round(n, 10)
    Stroke(n, accent, 1.5, 0.2)

    -- Accent bar
    local bar = New("Frame", {
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Parent = n,
    })
    Round(bar, 10)

    -- Icon
    local icon = New("TextLabel", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, 14, 0, 12),
        BackgroundTransparency = 1,
        Text = kind == "success" and "✓"
            or kind == "warning" and "!"
            or kind == "danger" and "✕"
            or "ℹ",
        TextColor3 = accent,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = n,
    })

    New("TextLabel", {
        Size = UDim2.new(1, -48, 0, 20),
        Position = UDim2.new(0, 40, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = n,
    })

    New("TextLabel", {
        Size = UDim2.new(1, -48, 0, 34),
        Position = UDim2.new(0, 40, 0, 30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.SubText,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = n,
    })

    table.insert(self.Notifications, n)
    local targetY = -90 - (#self.Notifications - 1) * 82
    if self.Animations then
        Tween(n, 0.35, { Position = UDim2.new(1, -w - 20, 1, targetY) }, Enum.EasingStyle.Back)
    else
        n.Position = UDim2.new(1, -w - 20, 1, targetY)
    end

    task.delay(dur, function()
        if self.Animations then
            Tween(n, 0.3, { Position = UDim2.new(1, w + 20, 1, n.Position.Y.Offset) })
            task.wait(0.35)
        end
        if n.Parent then n:Destroy() end
        for i, x in ipairs(self.Notifications) do
            if x == n then table.remove(self.Notifications, i) break end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- TOOLTIP
-- ═══════════════════════════════════════════════════════════════
local function AttachTooltip(element, text)
    if not text or text == "" then return end
    local tooltip
    element.MouseEnter:Connect(function()
        if tooltip then return end
        local isMobile = IsMobile()
        if isMobile then return end -- tooltip on mobile is annoying
        tooltip = New("TextLabel", {
            Size = UDim2.new(0, 0, 0, 24),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Library.Theme.Background,
            Text = "  " .. text .. "  ",
            TextColor3 = Library.Theme.Text,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            BorderSizePixel = 0,
            ZIndex = 999,
            Parent = Library.ScreenGui,
        })
        Round(tooltip, 6)
        Stroke(tooltip, Library.Theme.Accent, 1, 0.4)
        local mouse = UserInputService:GetMouseLocation()
        tooltip.Position = UDim2.fromOffset(mouse.X + 12, mouse.Y + 20)
    end)
    element.MouseLeave:Connect(function()
        if tooltip and tooltip.Parent then tooltip:Destroy() end
        tooltip = nil
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- SEARCH
-- ═══════════════════════════════════════════════════════════════
function Library:Search(query)
    query = (query or ""):lower()
    for _, tab in ipairs(self.Tabs) do
        for _, el in ipairs(tab.Elements or {}) do
            if el.Name then
                local matches = query == "" or el.Name:lower():find(query, 1, true) ~= nil
                if el.Row then el.Row.Visible = matches end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- WATERMARK
-- ═══════════════════════════════════════════════════════════════
function Library:MakeWatermark(text)
    local wm = New("Frame", {
        Size = UDim2.new(0, 200, 0, 24),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = self.ScreenGui,
    })
    Round(wm, 6)
    Stroke(wm, self.Theme.Accent, 1, 0.3)

    local label = New("TextLabel", {
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text = text or "VENTURE AOT",
        TextColor3 = self.Theme.Text,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = wm,
    })

    self.Watermark = wm
    self.WatermarkLabel = label

    task.spawn(function()
        while wm.Parent do
            task.wait(0.5)
            if not self.WatermarkVisible then
                wm.Visible = false
            else
                wm.Visible = true
                local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 0.001))
                -- better FPS calc
                local frames, t0 = 0, tick()
                local conn
                conn = RunService.RenderStepped:Connect(function()
                    frames = frames + 1
                end)
                task.wait(1)
                if conn then conn:Disconnect() end
                fps = frames
                local ping = 0
                pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                local time = os.date("%H:%M:%S")
                label.Text = string.format("%s | %d FPS | %dms | %s",
                    text or "VENTURE AOT", fps, ping, time)
            end
        end
    end)

    return wm
end

-- ═══════════════════════════════════════════════════════════════
-- DRAG (mouse + touch)
-- ═══════════════════════════════════════════════════════════════
function Library:MakeDraggable(handle, frame)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    Config.Position = {frame.Position.X.Scale, frame.Position.Y.Scale}
                    if Config.AutoSave then SaveConfig("default") end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- WINDOW
-- ═══════════════════════════════════════════════════════════════
function Library:MakeWindow(opts)
    opts = opts or {}
    local title = opts.Title or "VENTURE AOT"
    local subtitle = opts.Subtitle or ""

    local gui = New("ScreenGui", {
        Name = "VentureAOT_GUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    local ok = pcall(function() gui.Parent = CoreGui end)
    if not ok or not gui.Parent then gui.Parent = PlayerGui end
    self.ScreenGui = gui

    -- Mobile scale
    local isMobile = IsMobile()
    local scale = isMobile and 0.85 or 1
    local w = Config.Size[1] * scale * (isMobile and Config.MobileScale or 1)
    local h = Config.Size[2] * scale * (isMobile and Config.MobileScale or 1)

    local main = New("Frame", {
        Name = "Main",
        Size = UDim2.new(0, w, 0, h),
        Position = UDim2.new(Config.Position[1], 0, Config.Position[2], 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Secondary,
        BackgroundTransparency = 1 - Config.Opacity,
        BorderSizePixel = 0,
        Parent = gui,
    })
    Round(main, 12)
    Stroke(main, self.Theme.Stroke, 1, 0.4)
    self.MainFrame = main

    -- Drop shadow (image, works everywhere)
    local shadow = New("ImageLabel", {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        ZIndex = -1,
        Parent = main,
    })
    self.Shadow = shadow

    -- ═══ HEADER ═══
    local header = New("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = main,
    })
    Round(header, 12)
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = header,
    })
    self.Header = header

    New("TextLabel", {
        Size = UDim2.new(0, 300, 0, 20),
        Position = UDim2.new(0, 16, 0, 6),
        BackgroundTransparency = 1,
        Text = title, TextColor3 = self.Theme.Text, TextSize = 17,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    New("TextLabel", {
        Size = UDim2.new(0, 300, 0, 14),
        Position = UDim2.new(0, 16, 0, 25),
        BackgroundTransparency = 1,
        Text = subtitle, TextColor3 = self.Theme.SubText, TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    -- Search
    local searchBox = New("TextBox", {
        Size = UDim2.new(0, 160, 0, 26),
        Position = UDim2.new(1, -290, 0.5, -13),
        BackgroundColor3 = self.Theme.Element,
        PlaceholderText = "Search...",
        PlaceholderColor3 = self.Theme.SubText,
        Text = "", TextColor3 = self.Theme.Text,
        TextSize = 12, Font = Enum.Font.Gotham,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        Parent = header,
    })
    Round(searchBox, 6)
    Pad(searchBox, 8, 0)
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:Search(searchBox.Text)
    end)
    self.SearchBox = searchBox

    -- Minimize
    local minBtn = New("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -70, 0.5, -14),
        BackgroundColor3 = self.Theme.Element,
        Text = "—", TextColor3 = self.Theme.Text, TextSize = 16,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false, BorderSizePixel = 0,
        Parent = header,
    })
    Round(minBtn, 6)
    minBtn.MouseEnter:Connect(function() Tween(minBtn, 0.15, { BackgroundColor3 = self.Theme.Hover }) end)
    minBtn.MouseLeave:Connect(function() Tween(minBtn, 0.15, { BackgroundColor3 = self.Theme.Element }) end)
    minBtn.MouseButton1Click:Connect(function() self:ToggleMinimize() end)
    self.MinBtn = minBtn

    -- Close
    local closeBtn = New("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0.5, -14),
        BackgroundColor3 = self.Theme.Element,
        Text = "✕", TextColor3 = self.Theme.Text, TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false, BorderSizePixel = 0,
        Parent = header,
    })
    Round(closeBtn, 6)
    closeBtn.MouseEnter:Connect(function() Tween(closeBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(200, 50, 50) }) end)
    closeBtn.MouseLeave:Connect(function() Tween(closeBtn, 0.15, { BackgroundColor3 = self.Theme.Element }) end)
    closeBtn.MouseButton1Click:Connect(function() self:Hide() end)

    -- ═══ SIDEBAR ═══
    local sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, -66),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = main,
    })
    local sideScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = sidebar,
    })
    Pad(sideScroll, 8, 8)
    local sideLayout = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = sideScroll,
    })
    sideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sideScroll.CanvasSize = UDim2.new(0, 0, 0, sideLayout.AbsoluteContentSize.Y + 16)
    end)
    self.Sidebar = sidebar
    self.SideScroll = sideScroll

    -- ═══ CONTENT ═══
    local content = New("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -150, 1, -66),
        Position = UDim2.new(0, 150, 0, 44),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = main,
    })
    self.Content = content

    local scroll = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = content,
    })
    Pad(scroll, 12, 10)
    local layout = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = scroll,
    })
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)
    self.Scroll = scroll
    self.ScrollLayout = layout

    -- ═══ FOOTER ═══
    local footer = New("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 1, -22),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = main,
    })
    Round(footer, 12)
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = footer,
    })
    New("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "Venture AOT v3.0  |  " .. (_G.Venture.ExecutorName or "Executor"),
        TextColor3 = self.Theme.SubText, TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = footer,
    })
    self.Footer = footer

    self:MakeDraggable(header, main)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == self.ToggleKey then self:Toggle() end
    end)

    -- Watermark
    if self.WatermarkVisible then
        self:MakeWatermark("VENTURE AOT")
    end

    return self
end

function Library:Toggle()
    self.Visible = not self.Visible
    if self.Visible then
        self.MainFrame.Visible = true
        if self.Animations then
            self.MainFrame.Size = UDim2.new(0, self.MainFrame.Size.X.Offset * 0.9,
                0, self.MainFrame.Size.Y.Offset * 0.9)
            Tween(self.MainFrame, 0.3, {
                Size = UDim2.new(0, Config.Size[1], 0, Config.Size[2]),
                BackgroundTransparency = 1 - Config.Opacity
            }, Enum.EasingStyle.Back)
        else
            self.MainFrame.BackgroundTransparency = 1 - Config.Opacity
        end
    else
        if self.Animations then
            Tween(self.MainFrame, 0.25, { BackgroundTransparency = 1 })
            task.delay(0.28, function() self.MainFrame.Visible = false end)
        else
            self.MainFrame.Visible = false
        end
    end
end

function Library:Hide()
    self.Visible = false
    if self.Animations then
        Tween(self.MainFrame, 0.25, { BackgroundTransparency = 1 })
        task.delay(0.28, function() self.MainFrame.Visible = false end)
    else
        self.MainFrame.Visible = false
    end
end

function Library:Show()
    self.Visible = true
    self.MainFrame.Visible = true
    Tween(self.MainFrame, 0.25, { BackgroundTransparency = 1 - Config.Opacity })
end

function Library:ToggleMinimize()
    Config.Minimized = not Config.Minimized
    if Config.AutoSave then SaveConfig("default") end
    if Config.Minimized then
        self.Sidebar.Visible = false
        self.Content.Visible = false
        self.Footer.Visible = false
        self.SearchBox.Visible = false
        Tween(self.MainFrame, 0.3, { Size = UDim2.new(0, Config.Size[1], 0, 44) })
    else
        Tween(self.MainFrame, 0.3, { Size = UDim2.new(0, Config.Size[1], 0, Config.Size[2]) })
        task.delay(0.2, function()
            self.Sidebar.Visible = true
            self.Content.Visible = true
            self.Footer.Visible = true
            self.SearchBox.Visible = true
        end)
    end
end

function Library:Destroy()
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

-- ═══════════════════════════════════════════════════════════════
-- TAB
-- ═══════════════════════════════════════════════════════════════
function Library:MakeTab(name)
    local tab = {
        Name = name, Elements = {}, _active = false,
        _btn = nil, _frame = nil, Library = self,
    }

    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Theme.Element,
        BackgroundTransparency = 0.3,
        Text = name, TextColor3 = self.Theme.Text, TextSize = 13,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false, BorderSizePixel = 0,
        Parent = self.SideScroll,
    })
    Round(btn, 6)

    btn.MouseEnter:Connect(function()
        if not tab._active then
            Tween(btn, 0.15, { BackgroundColor3 = self.Theme.Hover, BackgroundTransparency = 0.1 })
        end
    end)
    btn.MouseLeave:Connect(function()
        if not tab._active then
            Tween(btn, 0.15, { BackgroundColor3 = self.Theme.Element, BackgroundTransparency = 0.3 })
        end
    end)

    local frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Visible = false,
        Parent = self.Scroll,
    })
    local layout = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8), Parent = frame,
    })

    tab._btn = btn
    tab._frame = frame
    tab._layout = layout

    function tab:Activate()
        for _, t in ipairs(self.Library.Tabs) do
            t._active = false
            t._frame.Visible = false
            if t._btn then
                Tween(t._btn, 0.15, {
                    BackgroundColor3 = self.Library.Theme.Element,
                    BackgroundTransparency = 0.3
                })
            end
        end
        self._active = true
        self._frame.Visible = true
        Tween(self._btn, 0.2, {
            BackgroundColor3 = self.Library.Theme.Accent,
            BackgroundTransparency = 0
        })
    end

    btn.MouseButton1Click:Connect(function() tab:Activate() end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then tab:Activate() end
    return tab
end

-- ═══════════════════════════════════════════════════════════════
-- SECTION (collapsible)
-- ═══════════════════════════════════════════════════════════════
function Library:MakeSection(tab, name)
    local section = New("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0, Parent = tab._frame,
    })
    Round(section, 8)
    Stroke(section, self.Theme.Stroke, 1, 0.5)

    local arrow = New("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1, Text = "▼",
        TextColor3 = self.Theme.Accent, TextSize = 12,
        Font = Enum.Font.GothamBold, Parent = section,
    })
    New("TextLabel", {
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1, Text = name or "Section",
        TextColor3 = self.Theme.Accent, TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = section,
    })

    local container = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, Parent = tab._frame,
    })
    local cLayout = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6), Parent = container,
    })

    local collapsed = false
    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, Text = "", Parent = section,
    })
    btn.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        Tween(arrow, 0.2, { Rotation = collapsed and -90 or 0 })
        if self.Animations then
            if collapsed then
                Tween(container, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                task.delay(0.2, function() container.Visible = false end)
            else
                container.Visible = true
                Tween(container, 0.2, { Size = UDim2.new(1, 0, 0, cLayout.AbsoluteContentSize.Y) })
            end
        else
            container.Visible = not collapsed
        end
    end)

    cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not collapsed then
            container.Size = UDim2.new(1, 0, 0, cLayout.AbsoluteContentSize.Y)
        end
    end)

    local element = {
        Container = container,
        Collapsed = function() return collapsed end,
        Refresh = function(_, t)
            Tween(section, 0.2, { BackgroundColor3 = t.Background })
            arrow.TextColor3 = t.Accent
        end,
    }
    self:Register(element)
    table.insert(tab.Elements, element)
    return container
end

-- ═══════════════════════════════════════════════════════════════
-- ELEMENTS
-- ═══════════════════════════════════════════════════════════════

-- ░░░ TOGGLE ░░░
function Library:MakeToggle(parent, opts)
    opts = opts or {}
    local name = opts.Name or "Toggle"
    local default = opts.Default or false
    local callback = opts.Callback or function() end
    local tooltip = opts.Tooltip

    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = self.Theme.Element,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0, Parent = parent,
    })
    Round(row, 6)

    local label = New("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = name,
        TextColor3 = self.Theme.Text, TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })

    local switch = New("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -52, 0.5, -10),
        BackgroundColor3 = default and self.Theme.Accent or self.Theme.Stroke,
        BorderSizePixel = 0, Parent = row,
    })
    Round(switch, 10)

    local dot = New("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, Parent = switch,
    })
    Round(dot, 8)

    local state = default
    local function setState(v, fire)
        state = v
        Tween(switch, 0.2, { BackgroundColor3 = v and self.Theme.Accent or self.Theme.Stroke })
        Tween(dot, 0.2, { Position = v and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2) })
        if fire then pcall(callback, v) end
    end

    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, Text = "", Parent = row,
    })
    btn.MouseEnter:Connect(function() Tween(row, 0.15, { BackgroundTransparency = 0.3 }) end)
    btn.MouseLeave:Connect(function() Tween(row, 0.15, { BackgroundTransparency = 0.5 }) end)
    btn.MouseButton1Click:Connect(function() setState(not state, true) end)

    local el = {
        Name = name, Row = row, Type = "Toggle",
        Set = function(v) setState(v, true) end,
        Get = function() return state end,
        Refresh = function(_, t)
            label.TextColor3 = t.Text
            Tween(row, 0.2, { BackgroundColor3 = t.Element })
            Tween(switch, 0.2, { BackgroundColor3 = state and t.Accent or t.Stroke })
        end,
    }
    if tooltip then AttachTooltip(row, tooltip) end
    self:Register(el)
    return el
end

-- ░░░ BUTTON ░░░
function Library:MakeButton(parent, opts)
    opts = opts or {}
    local name = opts.Name or "Button"
    local subtext = opts.Subtext or ""
    local callback = opts.Callback or function() end
    local danger = opts.Danger or false
    local tooltip = opts.Tooltip

    local base = danger and Color3.fromRGB(120, 30, 30) or self.Theme.Element
    local hover = danger and Color3.fromRGB(150, 40, 40) or self.Theme.Hover

    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, subtext ~= "" and 44 or 34),
        BackgroundColor3 = base,
        BackgroundTransparency = 0.4,
        Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, Parent = parent,
    })
    Round(btn, 6)
    Stroke(btn, danger and Color3.fromRGB(255, 80, 80) or self.Theme.Accent, 1, 0.6)

    local label = New("TextLabel", {
        Size = UDim2.new(1, -20, subtext ~= "" and 0.55 or 1, 0),
        Position = UDim2.new(0, 12, 0, subtext ~= "" and 4 or 0),
        BackgroundTransparency = 1, Text = name,
        TextColor3 = self.Theme.Text, TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
    })

    if subtext ~= "" then
        New("TextLabel", {
            Size = UDim2.new(1, -20, 0, 16),
            Position = UDim2.new(0, 12, 0, 24),
            BackgroundTransparency = 1, Text = subtext,
            TextColor3 = self.Theme.SubText, TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = btn,
        })
    end

    btn.MouseEnter:Connect(function()
        Tween(btn, 0.15, { BackgroundTransparency = 0.15, BackgroundColor3 = hover })
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, 0.15, { BackgroundTransparency = 0.4, BackgroundColor3 = base })
    end)
    btn.MouseButton1Click:Connect(function()
        if self.Animations then
            Tween(btn, 0.1, { Size = UDim2.new(1, -4, 0, btn.Size.Y.Offset - 2) })
            task.delay(0.1, function() Tween(btn, 0.1, { Size = UDim2.new(1, 0, 0, btn.Size.Y.Offset + 2) }) end)
        end
        pcall(callback)
    end)

    local el = {
        Name = name, Row = btn, Type = "Button",
        Refresh = function(_, t)
            Tween(btn, 0.2, { BackgroundColor3 = danger and Color3.fromRGB(120, 30, 30) or t.Element })
            label.TextColor3 = t.Text
        end,
    }
    if tooltip then AttachTooltip(btn, tooltip) end
    self:Register(el)
    return el
end

-- ░░░ SLIDER ░░░
function Library:MakeSlider(parent, opts)
    opts = opts or {}
    local name = opts.Name or "Slider"
    local min = opts.Min or 0
    local max = opts.Max or 100
    local default = opts.Default or min
    local step = opts.Step or 1
    local suffix = opts.Suffix or ""
    local callback = opts.Callback or function() end
    local tooltip = opts.Tooltip

    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = self.Theme.Element,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0, Parent = parent,
    })
    Round(row, 6)

    local label = New("TextLabel", {
        Size = UDim2.new(1, -110, 0, 20),
        Position = UDim2.new(0, 12, 0, 4),
        BackgroundTransparency = 1, Text = name,
        TextColor3 = self.Theme.Text, TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })

    local valueLabel = New("TextLabel", {
        Size = UDim2.new(0, 90, 0, 20),
        Position = UDim2.new(1, -100, 0, 4),
        BackgroundTransparency = 1,
        Text = tostring(default) .. suffix,
        TextColor3 = self.Theme.Accent, TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
    })

    local track = New("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 34),
        BackgroundColor3 = self.Theme.Stroke,
        BorderSizePixel = 0, Parent = row,
    })
    Round(track, 3)

    local fill = New("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0, Parent = track,
    })
    Round(fill, 3)

    local knob = New("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, Parent = track,
    })
    Round(knob, 7)

    local value = default
    local dragging = false

    local function setValue(v, fire)
        value = math.clamp(v, min, max)
        value = math.floor(value / step + 0.5) * step
        local pct = (value - min) / (max - min)
        Tween(fill, 0.08, { Size = UDim2.new(pct, 0, 1, 0) })
        Tween(knob, 0.08, { Position = UDim2.new(pct, -7, 0.5, -7) })
        local show = (step < 1) and (math.floor(value * 100) / 100) or math.floor(value)
        valueLabel.Text = tostring(show) .. suffix
        if fire then pcall(callback, value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            setValue(min + pct * (max - min), true)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            setValue(min + pct * (max - min), true)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    local el = {
        Name = name, Row = row, Type = "Slider",
        Set = function(v) setValue(v, true) end,
        Get = function() return value end,
        Refresh = function(_, t)
            label.TextColor3 = t.Text
            valueLabel.TextColor3 = t.Accent
            Tween(row, 0.2, { BackgroundColor3 = t.Element })
            track.BackgroundColor3 = t.Stroke
            fill.BackgroundColor3 = t.Accent
        end,
    }
    if tooltip then AttachTooltip(row, tooltip) end
    self:Register(el)
    return el
end

-- ░░░ DROPDOWN ░░░
function Library:MakeDropdown(parent, opts)
    opts = opts or {}
    local name = opts.Name or "Dropdown"
    local options = opts.Options or {}
    local default = opts.Default or (options[1] or "")
    local callback = opts.Callback or function() end
    local tooltip = opts.Tooltip

    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = self.Theme.Element,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0, Parent = parent,
    })
    Round(row, 6)

    local label = New("TextLabel", {
        Size = UDim2.new(1, -100, 0, 20),
        Position = UDim2.new(0, 12, 0, 4),
        BackgroundTransparency = 1, Text = name,
        TextColor3 = self.Theme.Text, TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })

    local arrow = New("TextLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0, 4),
        BackgroundTransparency = 1, Text = "▼",
        TextColor3 = self.Theme.Accent, TextSize = 12,
        Font = Enum.Font.GothamBold, Parent = row,
    })

    local selected = New("TextButton", {
        Size = UDim2.new(1, -24, 0, 20),
        Position = UDim2.new(0, 12, 0, 24),
        BackgroundTransparency = 1, Text = default,
        TextColor3 = self.Theme.SubText, TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false, Parent = row,
    })

    local container = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 6),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0, Visible = false,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 20, Parent = row,
    })
    Round(container, 6)
    Stroke(container, self.Theme.Accent, 1, 0.5)
    Pad(container, 4, 4)
    local listLayout = New("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3), Parent = container,
    })

    local isOpen = false

    local function buildList()
        for _, c in ipairs(container:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, opt in ipairs(options) do
            local optBtn = New("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = self.Theme.Element,
                BackgroundTransparency = 0.6,
                Text = opt, TextColor3 = self.Theme.Text, TextSize = 12,
                Font = Enum.Font.Gotham,
                AutoButtonColor = false, BorderSizePixel = 0, Parent = container,
            })
            Round(optBtn, 4)
            optBtn.MouseEnter:Connect(function()
                Tween(optBtn, 0.15, { BackgroundColor3 = self.Theme.Hover, BackgroundTransparency = 0.2 })
            end)
            optBtn.MouseLeave:Connect(function()
                Tween(optBtn, 0.15, { BackgroundColor3 = self.Theme.Element, BackgroundTransparency = 0.6 })
            end)
            optBtn.MouseButton1Click:Connect(function()
                selected.Text = opt
                isOpen = false
                Tween(container, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
                task.delay(0.2, function() container.Visible = false end)
                Tween(arrow, 0.15, { Rotation = 0 })
                pcall(callback, opt)
            end)
        end
        container.CanvasSize = UDim2.new(0, 0, 0, #options * 29 + 8)
    end
    buildList()

    selected.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            container.Visible = true
            local h = math.min(#options * 29 + 8, 160)
            Tween(container, 0.2, { Size = UDim2.new(1, 0, 0, h) })
            Tween(arrow, 0.15, { Rotation = 180 })
        else
            Tween(container, 0.2, { Size = UDim2.new(1, 0, 0, 0) })
            Tween(arrow, 0.15, { Rotation = 0 })
            task.delay(0.2, function() container.Visible = false end)
        end
    end)

    local el = {
        Name = name, Row = row, Type = "Dropdown",
        Set = function(v) selected.Text = v; callback(v) end,
        Get = function() return selected.Text end,
        SetOptions = function(newOpts)
            options = newOpts
            buildList()
        end,
        Refresh = function(_, t)
            label.TextColor3 = t.Text
            Tween(row, 0.2, { BackgroundColor3 = t.Element })
            container.BackgroundColor3 = t.Background
        end,
    }
    if tooltip then AttachTooltip(row, tooltip) end
    self:Register(el)
    return el
end

-- ░░░ TEXTBOX ░░░
function Library:MakeTextbox(parent, opts)
    opts = opts or {}
    local name = opts.Name or "Input"
    local placeholder = opts.Placeholder or "Введите..."
    local default = opts.Default or ""
    local callback = opts.Callback or function() end
    local tooltip = opts.Tooltip

    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = self.Theme.Element,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0, Parent = parent,
    })
    Round(row, 6)

    local label = New("TextLabel", {
        Size = UDim2.new(1, -20, 0, 18),
        Position = UDim2.new(0, 12, 0, 4),
        BackgroundTransparency = 1, Text = name,
        TextColor3 = self.Theme.Text, TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })

    local box = New("TextBox", {
        Size = UDim2.new(1, -24, 0, 24),
        Position = UDim2.new(0, 12, 0, 24),
        BackgroundColor3 = self.Theme.Background,
        Text = default, PlaceholderText = placeholder,
        PlaceholderColor3 = self.Theme.SubText,
        TextColor3 = self.Theme.Text, TextSize = 12,
        Font = Enum.Font.Gotham,
        BorderSizePixel = 0, ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })
    Round(box, 4)
    Pad(box, 6, 0)
    box.FocusLost:Connect(function(enter) pcall(callback, box.Text, enter) end)

    local el = {
        Name = name, Row = row, Type = "Textbox",
        Set = function(v) box.Text = v; callback(v) end,
        Get = function() return box.Text end,
        Refresh = function(_, t)
            label.TextColor3 = t.Text
            Tween(row, 0.2, { BackgroundColor3 = t.Element })
            box.BackgroundColor3 = t.Background
            box.TextColor3 = t.Text
        end,
    }
    if tooltip then AttachTooltip(row, tooltip) end
    self:Register(el)
    return el
end

-- ░░░ KEYBIND ░░░
function Library:MakeKeybind(parent, opts)
    opts = opts or {}
    local name = opts.Name or "Keybind"
    local default = opts.Default or "K"
    local callback = opts.Callback or function() end
    local tooltip = opts.Tooltip

    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = self.Theme.Element,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0, Parent = parent,
    })
    Round(row, 6)

    local label = New("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = name,
        TextColor3 = self.Theme.Text, TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })

    local keyBtn = New("TextButton", {
        Size = UDim2.new(0, 70, 0, 22),
        Position = UDim2.new(1, -80, 0.5, -11),
        BackgroundColor3 = self.Theme.Background,
        Text = default, TextColor3 = self.Theme.Accent, TextSize = 12,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false, BorderSizePixel = 0, Parent = row,
    })
    Round(keyBtn, 4)
    Stroke(keyBtn, self.Theme.Accent, 1, 0.5)

    local currentKey = default
    local listening = false

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode.Name
                keyBtn.Text = currentKey
                listening = false
                conn:Disconnect()
                pcall(callback, currentKey)
            end
        end)
    end)

    local el = {
        Name = name, Row = row, Type = "Keybind",
        Set = function(v) currentKey = v; keyBtn.Text = v; callback(v) end,
        Get = function() return currentKey end,
        Refresh = function(_, t)
            label.TextColor3 = t.Text
            Tween(row, 0.2, { BackgroundColor3 = t.Element })
            keyBtn.BackgroundColor3 = t.Background
            keyBtn.TextColor3 = t.Accent
        end,
    }
    if tooltip then AttachTooltip(row, tooltip) end
    self:Register(el)
    return el
end

-- ░░░ COLORPICKER ░░░
function Library:MakeColorpicker(parent, opts)
    opts = opts or {}
    local name = opts.Name or "Color"
    local default = opts.Default or Color3.fromRGB(255, 80, 80)
    local callback = opts.Callback or function() end
    local tooltip = opts.Tooltip

    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = self.Theme.Element,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0, Parent = parent,
    })
    Round(row, 6)

    local label = New("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, Text = name,
        TextColor3 = self.Theme.Text, TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    })

    local swatch = New("TextButton", {
        Size = UDim2.new(0, 34, 0, 22),
        Position = UDim2.new(1, -46, 0.5, -11),
        BackgroundColor3 = default, Text = "",
        AutoButtonColor = false, BorderSizePixel = 0, Parent = row,
    })
    Round(swatch, 4)
    Stroke(swatch, Color3.fromRGB(255, 255, 255), 1, 0.5)

    local current = default
    local popup = nil

    local function closePopup()
        if popup then popup:Destroy(); popup = nil end
    end

    local function openPopup()
        if popup then closePopup(); return end
        local p = New("Frame", {
            Size = UDim2.new(0, 220, 0, 180),
            Position = UDim2.new(1, 10, 0, 0),
            BackgroundColor3 = self.Theme.Background,
            BorderSizePixel = 0, ZIndex = 50, Parent = row,
        })
        Round(p, 8)
        Stroke(p, self.Theme.Accent, 1.5, 0.3)

        local preview = New("Frame", {
            Size = UDim2.new(1, -20, 0, 28),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundColor3 = current,
            BorderSizePixel = 0, Parent = p,
        })
        Round(preview, 4)

        local vals = {current.R, current.G, current.B}
        local names = {"R", "G", "B"}

        local function apply()
            current = Color3.new(vals[1], vals[2], vals[3])
            swatch.BackgroundColor3 = current
            preview.BackgroundColor3 = current
            pcall(callback, current)
        end

        for i = 1, 3 do
            local sy = 50 + (i - 1) * 30
            New("TextLabel", {
                Size = UDim2.new(0, 16, 0, 20),
                Position = UDim2.new(0, 10, 0, sy),
                BackgroundTransparency = 1, Text = names[i],
                TextColor3 = self.Theme.Accent, TextSize = 12,
                Font = Enum.Font.GothamBold, Parent = p,
            })
            local track = New("Frame", {
                Size = UDim2.new(1, -60, 0, 8),
                Position = UDim2.new(0, 30, 0, sy + 6),
                BackgroundColor3 = self.Theme.Stroke,
                BorderSizePixel = 0, Parent = p,
            })
            Round(track, 4)
            local fill = New("Frame", {
                Size = UDim2.new(vals[i], 0, 1, 0),
                BackgroundColor3 = self.Theme.Accent,
                BorderSizePixel = 0, Parent = track,
            })
            Round(fill, 4)
            local valLbl = New("TextLabel", {
                Size = UDim2.new(0, 30, 0, 20),
                Position = UDim2.new(1, -32, 0, sy),
                BackgroundTransparency = 1,
                Text = tostring(math.floor(vals[i] * 255)),
                TextColor3 = self.Theme.Text, TextSize = 11,
                Font = Enum.Font.Gotham, Parent = p,
            })
            local dragging = false
            local function update(x)
                local pct = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                vals[i] = pct
                valLbl.Text = tostring(math.floor(pct * 255))
                apply()
            end
            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(inp.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch) then
                    update(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
        end

        local close = New("TextButton", {
            Size = UDim2.new(1, -20, 0, 24),
            Position = UDim2.new(0, 10, 0, 150),
            BackgroundColor3 = self.Theme.Accent,
            Text = "OK", TextColor3 = Color3.fromRGB(255,255,255),
            TextSize = 12, Font = Enum.Font.GothamBold,
            AutoButtonColor = false, BorderSizePixel = 0, Parent = p,
        })
        Round(close, 4)
        close.MouseButton1Click:Connect(closePopup)
        popup = p
    end

    swatch.MouseButton1Click:Connect(openPopup)

    local el = {
        Name = name, Row = row, Type = "Colorpicker",
        Set = function(c) current = c; swatch.BackgroundColor3 = c; callback(c) end,
        Get = function() return current end,
        Refresh = function(_, t)
            label.TextColor3 = t.Text
            Tween(row, 0.2, { BackgroundColor3 = t.Element })
        end,
    }
    if tooltip then AttachTooltip(row, tooltip) end
    self:Register(el)
    return el
end

-- ░░░ LABEL ░░░
function Library:MakeLabel(parent, text)
    local lbl = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = self.Theme.Text, TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = parent,
    })
    local el = {
        Name = "Label", Row = lbl, Type = "Label",
        Refresh = function(_, t) lbl.TextColor3 = t.Text end,
        Set = function(txt) lbl.Text = txt end,
    }
    self:Register(el)
    return el
end

-- ░░░ DIVIDER ░░░
function Library:MakeDivider(parent)
    local div = New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = self.Theme.Stroke,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0, Parent = parent,
    })
    local el = { Refresh = function(_, t) div.BackgroundColor3 = t.Stroke end }
    self:Register(el)
    return div
end

-- ░░░ CONFIG UI (готовая секция) ░░░
function Library:BuildConfigSection(tab)
    local section = self:MakeSection(tab, "💾 Configs")
    local currentName = "default"

    local nameBox = self:MakeTextbox(section, {
        Name = "Config Name", Default = "default",
        Placeholder = "имя конфига",
        Callback = function(v) currentName = v end,
    })

    local listDropdown
    listDropdown = self:MakeDropdown(section, {
        Name = "Load Config",
        Options = self.Configs(),
        Default = "default",
        Callback = function(v)
            if LoadConfig(v) then
                self:SetTheme(Config.Theme)
                self:Notify({Title = "Config", Content = "Loaded: " .. v, Type = "success"})
            end
        end,
    })

    self:MakeButton(section, {
        Name = "💾 Save",
        Callback = function()
            if SaveConfig(currentName) then
                listDropdown:SetOptions(self.Configs())
                self:Notify({Title = "Config", Content = "Saved: " .. currentName, Type = "success"})
            else
                self:Notify({Title = "Config", Content = "FileIO недоступен", Type = "warning"})
            end
        end,
    })

    self:MakeButton(section, {
        Name = "🗑️ Delete",
        Danger = true,
        Callback = function()
            if DeleteConfig(currentName) then
                listDropdown:SetOptions(self.Configs())
                self:Notify({Title = "Config", Content = "Deleted: " .. currentName, Type = "success"})
            else
                self:Notify({Title = "Config", Content = "Не найдено", Type = "warning"})
            end
        end,
    })

    self:MakeButton(section, {
        Name = "🔄 Refresh List",
        Callback = function() listDropdown:SetOptions(self.Configs()) end,
    })
end

-- ═══════════════════════════════════════════════════════════════
-- EXPORT
-- ═══════════════════════════════════════════════════════════════
_G.Venture.GUI = Library
_G.Venture.UI = UI

-- Если Functions.lua уже загружен — создаём окно и табы
if F.Settings then
    S = F.Settings
end

print("[Venture GUI1] Loaded | Mobile: " .. tostring(IsMobile())
    .. " | FileIO: " .. tostring(HAS_FILEIO)
    .. " | CoreGui: " .. tostring(HAS_CORE_ACCESS))

return Library
