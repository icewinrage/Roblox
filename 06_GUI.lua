--// Venture | 06_GUI.lua
-- Весь интерфейс: Main, TabBar, элементы, вкладка SETTINGS

local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils
local Theme  = _G.Venture.Theme
local Funcs  = _G.Venture.Functions

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

--====================================================
-- КОРНЕВОЙ SCREENGUI
--====================================================
local ScreenGui = New("ScreenGui", {
    Name = "VentureAOT_GUI", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true, DisplayOrder = 999999,
}, PlayerGui)

GUI.ScreenGui = ScreenGui

--====================================================
-- ЗАГРУЗКА (интро)
--====================================================
local Loading = New("Frame", {Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 100}, ScreenGui)
local LoadingGlass = New("Frame", {Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(8,6,16), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 100}, Loading)
local CutscenePanel = New("Frame", {
    AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5),
    Size = UDim2.fromOffset(460,260),
    BackgroundColor3 = Color3.fromRGB(10,12,20), BackgroundTransparency = 1,
    BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 101
}, Loading)
New("UICorner", {CornerRadius = UDim.new(0,20)}, CutscenePanel)
local CutsceneStroke = New("UIStroke", {Color = Color3.fromRGB(125,92,255), Thickness = 1.4, Transparency = 1}, CutscenePanel)
New("UIGradient", {Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22,22,40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,12,20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6,7,13)),
}), Rotation = 135}, CutscenePanel)

local Logo = New("TextLabel", {AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.22), Size = UDim2.new(1,0,0,46), BackgroundTransparency = 1, Text = "V E N T U R E", TextColor3 = Color3.fromRGB(212,175,55), TextSize = 36, Font = Enum.Font.GothamBold, TextTransparency = 1, ZIndex = 103}, CutscenePanel)
local LogoSub = New("TextLabel", {AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.35), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = "Executor: " .. GUI.ExecutorName, TextColor3 = Color3.fromRGB(180,180,200), TextSize = 12, Font = Enum.Font.Gotham, TextTransparency = 1, ZIndex = 103}, CutscenePanel)
local AuthorLabel = New("TextLabel", {AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = "by __TheDark", TextColor3 = Color3.fromRGB(212,175,55), TextSize = 15, Font = Enum.Font.GothamBold, TextTransparency = 1, ZIndex = 103}, CutscenePanel)
local DiscordLabel = New("TextLabel", {AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.58), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = "discord.gg/UHCwX78Npc", TextColor3 = Color3.fromRGB(125,160,255), TextSize = 13, Font = Enum.Font.Gotham, TextTransparency = 1, ZIndex = 103}, CutscenePanel)
local VersionLabel = New("TextLabel", {AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.66), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = "v1.7 | Modular", TextColor3 = Color3.fromRGB(180,180,200), TextSize = 12, Font = Enum.Font.Gotham, TextTransparency = 1, ZIndex = 103}, CutscenePanel)

GUI.Loading = Loading

--====================================================
-- KEYBIND LIST GUI (слева)
--====================================================
local KeybindListGui = New("ScreenGui", {
    Name = "VentureKeybindList", ResetOnSpawn = false,
    IgnoreGuiInset = true, DisplayOrder = 999998,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)
GUI.KeybindListGui = KeybindListGui

local KeybindListFrame = New("Frame", {
    Name = "KeybindList",
    AnchorPoint = Vector2.new(0,0.5), Position = UDim2.new(0,20,0.5,0),
    Size = UDim2.fromOffset(200,300),
    BackgroundColor3 = Config.Themes.Dark.KeybindBg,
    BackgroundTransparency = 0.15, BorderSizePixel = 0,
    Active = true, Draggable = true,
}, KeybindListGui)
New("UICorner", {CornerRadius = UDim.new(0,14)}, KeybindListFrame)
local KBListStroke = New("UIStroke", {Color = Color3.fromRGB(125,92,255), Thickness = 1.2, Transparency = 0.25}, KeybindListFrame)
local KBListGrad = New("UIGradient", {Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22,22,40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,12,20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6,7,13)),
}), Rotation = 135}, KeybindListFrame)
New("Frame", {Position = UDim2.new(0,30,0,0), Size = UDim2.new(1,-60,0,2), BackgroundColor3 = Color3.fromRGB(125,92,255), BorderSizePixel = 0}, KeybindListFrame)
New("TextLabel", {Position = UDim2.new(0,14,0,12), Size = UDim2.new(1,-28,0,20), BackgroundTransparency = 1, Text = "  KEYBINDS", TextColor3 = Color3.fromRGB(212,175,55), TextSize = 13, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left}, KeybindListFrame)
local KBContainer = New("Frame", {Position = UDim2.new(0,14,0,40), Size = UDim2.new(1,-28,1,-52), BackgroundTransparency = 1}, KeybindListFrame)

GUI.KeybindListFrame = KeybindListFrame
GUI.KBListStroke = KBListStroke
GUI.KBListGrad = KBListGrad
GUI.KBContainer = KBContainer

--====================================================
-- MAIN WINDOW
--====================================================
local Main = New("Frame", {
    Name = "Main", AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.53),
    Size = IsMobile and UDim2.fromOffset(480,400) or UDim2.fromOffset(620,480),
    BackgroundColor3 = Config.Themes.Dark.MainBg,
    BackgroundTransparency = 0.06, BorderSizePixel = 0,
    ClipsDescendants = true, Active = true, Visible = false, ZIndex = 5,
}, ScreenGui)
New("UICorner", {CornerRadius = UDim.new(0,22)}, Main)
local MainStroke = New("UIStroke", {Color = Color3.fromRGB(125,92,255), Thickness = 1.5, Transparency = 0.2}, Main)
local MainGrad = New("UIGradient", {Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24,24,42)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(11,13,22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(7,8,14)),
}), Rotation = 135}, Main)
local Glow = New("Frame", {Position = UDim2.new(0,55,0,0), Size = UDim2.new(1,-110,0,3), BackgroundColor3 = Color3.fromRGB(125,92,255), BorderSizePixel = 0, ZIndex = 6}, Main)
New("UICorner", {CornerRadius = UDim.new(1,0)}, Glow)

GUI.Main = Main
GUI.MainStroke = MainStroke
GUI.Glow = Glow

Theme.RegisterMain(Main)
Theme.Register("Misc", {Obj = MainStroke, Keys = {"Accent"}})
Theme.Register("Misc", {Obj = Glow, Keys = {"Accent"}})

-- Close / Hide / Open
local CloseBtn = New("TextButton", {AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-18,0,18), Size = UDim2.fromOffset(36,36), BackgroundColor3 = Color3.fromRGB(28,30,44), BackgroundTransparency = 0.15, BorderSizePixel = 0, AutoButtonColor = false, Text = "x", TextColor3 = Color3.fromRGB(185,187,205), TextSize = 20, Font = Enum.Font.GothamBold, ZIndex = 10}, Main)
New("UICorner", {CornerRadius = UDim.new(0,11)}, CloseBtn)
New("UIStroke", {Color = Color3.fromRGB(70,72,95), Thickness = 1, Transparency = 0.25}, CloseBtn)

local HideBtn = New("TextButton", {AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-60,0,18), Size = UDim2.fromOffset(36,36), BackgroundColor3 = Color3.fromRGB(28,30,44), BackgroundTransparency = 0.15, BorderSizePixel = 0, AutoButtonColor = false, Text = "_", TextColor3 = Color3.fromRGB(185,187,205), TextSize = 20, Font = Enum.Font.GothamBold, ZIndex = 10}, Main)
New("UICorner", {CornerRadius = UDim.new(0,11)}, HideBtn)
New("UIStroke", {Color = Color3.fromRGB(70,72,95), Thickness = 1, Transparency = 0.25}, HideBtn)

local OpenBtn = New("TextButton", {AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-20,0,20), Size = UDim2.fromOffset(54,54), BackgroundColor3 = Color3.fromRGB(20,22,36), BackgroundTransparency = 0.1, BorderSizePixel = 0, AutoButtonColor = false, Text = "*", TextColor3 = Color3.fromRGB(212,175,55), TextSize = 24, Font = Enum.Font.GothamBold, Visible = false, ZIndex = 10}, ScreenGui)
New("UICorner", {CornerRadius = UDim.new(0,14)}, OpenBtn)
New("UIStroke", {Color = Color3.fromRGB(125,92,255), Thickness = 1.4, Transparency = 0.15}, OpenBtn)

GUI.CloseBtn = CloseBtn
GUI.HideBtn = HideBtn
GUI.OpenBtn = OpenBtn

Theme.Register("Misc", {Obj = CloseBtn, Keys = {"CloseBtnBg"}})
Theme.Register("Misc", {Obj = HideBtn, Keys = {"CloseBtnBg"}})

local Title = New("TextLabel", {Position = UDim2.new(0,32,0,22), Size = UDim2.new(1,-140,0,30), BackgroundTransparency = 1, Text = "VENTURE  AOT", TextColor3 = Color3.fromRGB(248,247,255), TextSize = 22, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, Main)
local Subtitle = New("TextLabel", {Position = UDim2.new(0,32,0,48), Size = UDim2.new(1,-140,0,18), BackgroundTransparency = 1, Text = "by __TheDark  |  discord.gg/UHCwX78Npc  |  v1.7  |  " .. GUI.ExecutorName, TextColor3 = Color3.fromRGB(153,157,178), TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, Main)
GUI.Title = Title
GUI.Subtitle = Subtitle

Theme.Register("Misc", {Obj = Title, Keys = {"TitleText"}})
Theme.Register("Misc", {Obj = Subtitle, Keys = {"SubtitleText"}})

--====================================================
-- TAB BAR (6 вкладок: MAIN, VISUAL, AUTOFARM, KEYBINDS, SECURITY, DEBUG, SETTINGS)
--====================================================
local tabs = {"MAIN", "VISUAL", "AUTOFARM", "KEYBINDS", "SECURITY", "DEBUG", "SETTINGS"}
local tabButtons = {}
local tabPanels = {}
local tabStates = {}  -- храним активна ли вкладка (для фикса бага)
local tabCount = #tabs

local TabBar = New("Frame", {Position = UDim2.new(0,32,0,76), Size = UDim2.new(1,-64,0,32), BackgroundTransparency = 1, ZIndex = 6}, Main)
local ContentFrame = New("Frame", {Position = UDim2.new(0,32,0,124), Size = UDim2.new(1,-64,1,-170), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 6}, Main)

GUI.TabBar = TabBar
GUI.ContentFrame = ContentFrame
GUI.TabButtons = tabButtons
GUI.TabPanels = tabPanels

local function RefreshTabVisuals()
    local T = Theme.Get()
    for i, btn in ipairs(tabButtons) do
        local active = tabStates[i]
        btn.BackgroundColor3 = active and T.TabBgActive or T.TabBg
        btn.BackgroundTransparency = active and 0.1 or 0.3
        btn.TextColor3 = active and T.TabTextActive or T.TabText
        btn.TextTransparency = 0
        for _, c in ipairs(btn:GetChildren()) do
            if c:IsA("UIStroke") then
                c.Color = active and T.Accent or T.TabStroke
                c.Transparency = active and 0 or 0.4
            end
        end
        if tabPanels[i] then
            tabPanels[i].Visible = active
        end
    end
end
GUI.RefreshTabVisuals = RefreshTabVisuals

local function MakeTabButton(name, index)
    local btn = New("TextButton", {
        Name = name .. "Tab",
        Position = UDim2.new((index-1)/tabCount, 0, 0, 0),
        Size = UDim2.new(1/tabCount, -3, 1, 0),
        BackgroundColor3 = Color3.fromRGB(22,24,36),
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0, Text = name,
        TextColor3 = Color3.fromRGB(170,172,190),
        Font = Enum.Font.GothamBold, TextSize = 9,
        AutoButtonColor = false, ZIndex = 7,
    }, TabBar)
    New("UICorner", {CornerRadius = UDim.new(0,8)}, btn)
    New("UIStroke", {Color = Color3.fromRGB(60,62,88), Thickness = 1, Transparency = 0.4}, btn)

    btn.MouseButton1Click:Connect(function()
        for i = 1, tabCount do
            tabStates[i] = (i == index)
        end
        RefreshTabVisuals()
    end)

    Theme.Register("Tabs", {Btn = btn, IsActive = false})
    return btn
end

local function MakePanel()
    return New("ScrollingFrame", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = IsMobile and 5 or 3,
        ScrollBarImageColor3 = Color3.fromRGB(125,92,255),
        ScrollBarImageTransparency = 0.3,
        CanvasSize = UDim2.new(0,0,0,0),
        Visible = false, ZIndex = 7,
    }, ContentFrame)
end

for i, name in ipairs(tabs) do
    tabButtons[i] = MakeTabButton(name, i)
    tabPanels[i] = MakePanel()
    tabStates[i] = false
end
tabStates[1] = true
RefreshTabVisuals()

--====================================================
-- ЭЛЕМЕНТЫ
--====================================================
local function MakeSectionLabel(parent, text, y)
    local T = Theme.Get()
    local lbl = New("TextLabel", {
        Position = UDim2.new(0,4,0,y), Size = UDim2.new(1,-8,0,18),
        BackgroundTransparency = 1, Text = "  " .. string.upper(text),
        TextColor3 = T.SectionText,
        Font = Enum.Font.GothamBold, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, parent)
    Theme.Register("Sections", {Label = lbl})
    return y + 22
end

local function MakeButton(parent, text, subtext, y, callback)
    local h = subtext and (IsMobile and 60 or 54) or (IsMobile and 44 or 38)
    local T = Theme.Get()
    local btn = New("TextButton", {
        Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,-8,0,h),
        BackgroundColor3 = T.BtnBg, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, btn)
    local stroke = New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, btn)
    local mainLabel = New("TextLabel", {
        Position = UDim2.new(0,16,0, subtext and 8 or 0),
        Size = UDim2.new(1,-80,0, subtext and 20 or h),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = T.BtnText,
        Font = Enum.Font.GothamBold, TextSize = IsMobile and 12 or 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, btn)
    local subLabel = nil
    if subtext then
        subLabel = New("TextLabel", {
            Position = UDim2.new(0,16,0,30), Size = UDim2.new(1,-60,0,16),
            BackgroundTransparency = 1, Text = subtext,
            TextColor3 = T.SubText,
            Font = Enum.Font.Gotham, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
        }, btn)
    end
    btn.MouseEnter:Connect(function()
        Tween(btn, 0.18, {BackgroundColor3 = Theme.Get().BtnBgHover, BackgroundTransparency = 0})
        Tween(stroke, 0.18, {Color = Theme.Get().Accent, Transparency = 0, Thickness = 1.5})
    end)
    btn.MouseLeave:Connect(function()
        local t = Theme.Get()
        Tween(btn, 0.2, {BackgroundColor3 = t.BtnBg, BackgroundTransparency = 0.05})
        Tween(stroke, 0.2, {Color = t.BtnStroke, Transparency = 0.2, Thickness = 1})
    end)
    btn.MouseButton1Click:Connect(callback)
    Theme.Register("Buttons", {Btn = btn, Stroke = stroke, Label = mainLabel, Sub = subLabel})
    return y + h + 8
end

local function MakeToggle(parent, text, y, default, callback)
    local h = IsMobile and 44 or 38
    local T = Theme.Get()
    local btn = New("TextButton", {
        Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,-8,0,h),
        BackgroundColor3 = T.BtnBg, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, btn)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, btn)
    local mainLabel = New("TextLabel", {
        Position = UDim2.new(0,16,0,0), Size = UDim2.new(1,-90,1,0),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = T.BtnText,
        Font = Enum.Font.GothamBold, TextSize = IsMobile and 12 or 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, btn)
    local pill = New("Frame", {
        AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-16,0.5,0),
        Size = UDim2.fromOffset(46,22),
        BackgroundColor3 = default and T.ToggleOn or T.ToggleOff,
        BorderSizePixel = 0, ZIndex = 9,
    }, btn)
    New("UICorner", {CornerRadius = UDim.new(1,0)}, pill)
    local knob = New("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = default and UDim2.new(1,-11,0.5,0) or UDim2.new(0,11,0.5,0),
        Size = UDim2.fromOffset(16,16),
        BackgroundColor3 = T.ToggleKnob,
        BorderSizePixel = 0, ZIndex = 10,
    }, pill)
    New("UICorner", {CornerRadius = UDim.new(1,0)}, knob)

    local state = default
    local toggleData = {Btn = btn, Pill = pill, Knob = knob, Label = mainLabel, State = state}
    Theme.Register("Toggles", toggleData)

    btn.MouseButton1Click:Connect(function()
        state = not state
        toggleData.State = state
        local t = Theme.Get()
        Tween(pill, 0.2, {BackgroundColor3 = state and t.ToggleOn or t.ToggleOff})
        Tween(knob, 0.2, {Position = state and UDim2.new(1,-11,0.5,0) or UDim2.new(0,11,0.5,0)})
        callback(state)
    end)
    return y + h + 8
end

local function MakeSlider(parent, text, y, min, max, default, suffix, callback)
    local h = IsMobile and 54 or 48
    local T = Theme.Get()
    local frame = New("Frame", {
        Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,-8,0,h),
        BackgroundColor3 = T.BtnBg, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, frame)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, frame)
    local mainLabel = New("TextLabel", {
        Position = UDim2.new(0,16,0,6), Size = UDim2.new(1,-100,0,16),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = T.BtnText,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, frame)
    local valLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-16,0,6),
        Size = UDim2.fromOffset(80,16), BackgroundTransparency = 1,
        Text = tostring(default) .. (suffix or ""),
        TextColor3 = T.TabTextActive,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 9,
    }, frame)
    local barBG = New("Frame", {
        Position = UDim2.new(0,16,0,32), Size = UDim2.new(1,-32,0, IsMobile and 8 or 5),
        BackgroundColor3 = T.SliderBg, BorderSizePixel = 0, ZIndex = 9,
    }, frame)
    New("UICorner", {CornerRadius = UDim.new(1,0)}, barBG)
    local fill = New("Frame", {
        Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
        BackgroundColor3 = T.SliderFill, BorderSizePixel = 0, ZIndex = 10,
    }, barBG)
    New("UICorner", {CornerRadius = UDim.new(1,0)}, fill)

    Theme.Register("Sliders", {Frame = frame, Label = mainLabel, Val = valLabel, BarBG = barBG, Fill = fill})

    local dragging = false
    local function update(x)
        local rel = math.clamp((x - barBG.AbsolutePosition.X) / barBG.AbsoluteSize.X, 0, 1)
        local v = min + (max-min) * rel
        v = math.round(v * 100) / 100
        v = math.clamp(v, min, max)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valLabel.Text = tostring(v) .. (suffix or "")
        callback(v)
    end
    barBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    return y + h + 6
end

local function MakeMultiSelect(parent, text, options, y, onChange)
    local oh = 28
    local total = 30 + (#options * oh) + 8
    local T = Theme.Get()
    local frame = New("Frame", {
        Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,-8,0,total),
        BackgroundColor3 = T.BtnBg, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, frame)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, frame)
    New("TextLabel", {
        Position = UDim2.new(0,16,0,6), Size = UDim2.new(1,-32,0,20),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = T.TabTextActive,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, frame)
    local states = {}
    for _, o in ipairs(options) do states[o] = Settings.HitboxParts[o] or false end
    for i, opt in ipairs(options) do
        local ry = 30 + (i-1) * oh
        local row = New("TextButton", {
            Position = UDim2.new(0,12,0,ry), Size = UDim2.new(1,-24,0,oh-2),
            BackgroundColor3 = states[opt] and Color3.fromRGB(40,42,60) or Color3.fromRGB(15,17,28),
            BackgroundTransparency = 0.2, BorderSizePixel = 0,
            AutoButtonColor = false, Text = "", ZIndex = 9,
        }, frame)
        New("UICorner", {CornerRadius = UDim.new(0,6)}, row)
        local cb = New("TextLabel", {
            Position = UDim2.new(0,8,0,0), Size = UDim2.fromOffset(24,oh-2),
            BackgroundTransparency = 1, Text = states[opt] and "[X]" or "[  ]",
            TextColor3 = states[opt] and Color3.fromRGB(212,175,55) or Color3.fromRGB(120,120,140),
            Font = Enum.Font.Code, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        }, row)
        New("TextLabel", {
            Position = UDim2.new(0,36,0,0), Size = UDim2.new(1,-40,1,0),
            BackgroundTransparency = 1, Text = opt,
            TextColor3 = T.BtnText,
            Font = Enum.Font.Gotham, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        }, row)
        row.MouseButton1Click:Connect(function()
            states[opt] = not states[opt]
            Settings.HitboxParts[opt] = states[opt]
            cb.Text = states[opt] and "[X]" or "[  ]"
            cb.TextColor3 = states[opt] and Color3.fromRGB(212,175,55) or Color3.fromRGB(120,120,140)
            row.BackgroundColor3 = states[opt] and Color3.fromRGB(40,42,60) or Color3.fromRGB(15,17,28)
            if onChange then onChange() end
            Funcs.ApplyHitboxToAll()
        end)
    end
    return y + total + 8
end

local function MakeDropdown(parent, text, options, y, default, callback)
    local h = IsMobile and 48 or 44
    local T = Theme.Get()
    local frame = New("Frame", {
        Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,-8,0,h),
        BackgroundColor3 = T.BtnBg, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, frame)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, frame)
    local mainLabel = New("TextLabel", {
        Position = UDim2.new(0,16,0,0), Size = UDim2.new(0.5,0,1,0),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = T.BtnText,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, frame)
    local btn = New("TextButton", {
        AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-16,0.5,0),
        Size = UDim2.fromOffset(IsMobile and 150 or 180, 30),
        BackgroundColor3 = T.BtnBgHover, BorderSizePixel = 0,
        AutoButtonColor = false, Text = default or "None",
        TextColor3 = T.TabTextActive,
        Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 9,
    }, frame)
    New("UICorner", {CornerRadius = UDim.new(0,8)}, btn)
    Theme.Register("Dropdowns", {Frame = frame, Label = mainLabel, Btn = btn})

    local opened, dropdown = false, nil
    btn.MouseButton1Click:Connect(function()
        if opened and dropdown then dropdown:Destroy(); dropdown = nil; opened = false; return end
        dropdown = New("Frame", {
            Position = UDim2.new(1, IsMobile and -166 or -196, 1, 4),
            Size = UDim2.fromOffset(IsMobile and 150 or 180, #options * 26),
            BackgroundColor3 = Theme.Get().MainBg, BorderSizePixel = 0, ZIndex = 20,
        }, frame)
        New("UICorner", {CornerRadius = UDim.new(0,8)}, dropdown)
        New("UIStroke", {Color = Theme.Get().Accent, Thickness = 1, Transparency = 0.2}, dropdown)
        for i, opt in ipairs(options) do
            local o = New("TextButton", {
                Position = UDim2.new(0,0,0,(i-1)*26), Size = UDim2.new(1,0,0,26),
                BackgroundColor3 = Theme.Get().MainBg, BackgroundTransparency = 0.9,
                BorderSizePixel = 0, AutoButtonColor = false, Text = opt,
                TextColor3 = Theme.Get().BtnText,
                Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 21,
            }, dropdown)
            o.MouseButton1Click:Connect(function()
                btn.Text = opt
                callback(opt)
                if dropdown then dropdown:Destroy(); dropdown = nil; opened = false end
            end)
        end
        opened = true
    end)
    return y + h + 8
end

-- Экспортируем для других модулей
GUI.MakeSectionLabel = MakeSectionLabel
GUI.MakeButton = MakeButton
GUI.MakeToggle = MakeToggle
GUI.MakeSlider = MakeSlider
GUI.MakeMultiSelect = MakeMultiSelect
GUI.MakeDropdown = MakeDropdown
GUI.tabPanels = tabPanels
GUI.tabs = tabs

--====================================================
-- ЗАПОЛНЕНИЕ ВКЛАДОК
--====================================================
-- MAIN
do
    local y = 0
    y = MakeSectionLabel(tabPanels[1], "TITAN CONTROL", y)
    y = MakeButton(tabPanels[1], "Find Nearest Titan", "Lock onto the nearest available target", y, function()
        local t = Funcs.GetTitans()
        if #t == 0 then return end
        Funcs.StickToTitan(t[1])
    end)
    y = MakeButton(tabPanels[1], "Safe Release", "Detach and boost upward + sideways", y, function()
        Funcs.CleanupStick(true); Funcs.State.currentTarget = nil
    end)
    y = MakeButton(tabPanels[1], "Force Reset", "Clear current TP / camera state", y, function()
        Funcs.ForceResetState()
    end)
    y = y + 6
    y = MakeSectionLabel(tabPanels[1], "BLADE REFILL", y)
    y = MakeButton(tabPanels[1], "Teleport to Nearest Refill", "TP to closest BladeRefill", y, function()
        local r = Funcs.GetRefills()
        if #r == 0 then return end
        Funcs.TeleportToRefill(r[1])
    end)
    y = MakeButton(tabPanels[1], "Trigger Auto Refill", "TP + pause + wait + return", y, function()
        Funcs.TriggerAutoRefill()
    end)
    tabPanels[1].CanvasSize = UDim2.new(0,0,0,y+20)
end

-- VISUAL
do
    local vy = 0
    vy = MakeSectionLabel(tabPanels[2], "ESP", vy)
    vy = MakeToggle(tabPanels[2], "Titan + Refill ESP", vy, false, function(v) Settings.ESP = v end)
    vy = MakeToggle(tabPanels[2], "Player ESP (HP + Name + PvP)", vy, false, function(v) Settings.PlayerESP = v end)
    vy = MakeToggle(tabPanels[2], "Shifter ESP", vy, false, function(v) Settings.ShifterESP = v end)
    vy = vy + 6
    vy = MakeSectionLabel(tabPanels[2], "HITBOX EXPANDER", vy)
    vy = MakeToggle(tabPanels[2], "Expand Hitbox", vy, false, function(v)
        Settings.HitboxExpand = v
        if v then Funcs.ApplyHitboxToAll() else Funcs.ResetAllHitboxes() end
    end)
    vy = MakeSlider(tabPanels[2], "Size X", vy, 50, 500, 300, " studs", function(v)
        Settings.HitboxSize = Vector3.new(v, Settings.HitboxSize.Y, Settings.HitboxSize.Z)
        Funcs.ApplyHitboxToAll()
    end)
    vy = MakeSlider(tabPanels[2], "Size Y", vy, 50, 500, 200, " studs", function(v)
        Settings.HitboxSize = Vector3.new(Settings.HitboxSize.X, v, Settings.HitboxSize.Z)
        Funcs.ApplyHitboxToAll()
    end)
    vy = MakeSlider(tabPanels[2], "Size Z", vy, 50, 500, 300, " studs", function(v)
        Settings.HitboxSize = Vector3.new(Settings.HitboxSize.X, Settings.HitboxSize.Y, v)
        Funcs.ApplyHitboxToAll()
    end)
    vy = MakeMultiSelect(tabPanels[2], "TARGET PARTS", {"Nape","Eyes","LeftArm","LeftLeg","RightArm","RightLeg"}, vy)
    vy = MakeDropdown(tabPanels[2], "Shape", {"Block","Ball","Cylinder"}, vy, "Block", function(v)
        Settings.HitboxShape = v
        Funcs.ApplyHitboxToAll()
    end)
    vy = MakeToggle(tabPanels[2], "Show Hitbox Visual", vy, false, function(v)
        Settings.HitboxShowVisual = v
        Funcs.ApplyHitboxToAll()
    end)
    vy = MakeButton(tabPanels[2], "Reset All Hitboxes", "Restore original sizes", vy, function()
        Funcs.ResetAllHitboxes()
    end)
    vy = vy + 6
    vy = MakeSectionLabel(tabPanels[2], "NOCLIP", vy)
    vy = MakeToggle(tabPanels[2], "Noclip (walk through walls)", vy, false, function(v)
        Settings.Noclip = v
        if v then Funcs.StartNoclip() else Funcs.StopNoclip() end
    end)
    vy = vy + 6
    vy = MakeSectionLabel(tabPanels[2], "FPS BOOSTER", vy)
    vy = MakeToggle(tabPanels[2], "FPS Booster (aggressive)", vy, false, function(v)
        Settings.FPSBoosterEnabled = v
        if v then Funcs.EnableFPSBooster() else Funcs.DisableFPSBooster() end
    end)
    tabPanels[2].CanvasSize = UDim2.new(0,0,0,vy+20)
end

-- AUTOFARM
do
    local fy = 0
    fy = MakeSectionLabel(tabPanels[3], "AUTO FARM (SMOOTH ORBIT)", fy)
    fy = MakeToggle(tabPanels[3], "Enable AutoFarm", fy, false, function(v)
        Settings.AutoFarmEnabled = v
        if v then
            if not Settings.HitboxExpand then Settings.HitboxExpand = true; Funcs.ApplyHitboxToAll() end
            if not Settings.Noclip then Settings.Noclip = true; Funcs.StartNoclip() end
        else
            Funcs.ResetAllHitboxes(); Funcs.StopNoclip(); Funcs.CleanupFarm()
            Funcs.State.FarmState.IsAttacking = false
            Funcs.State.FarmState.CurrentTitan = nil
        end
    end)
    fy = MakeSlider(tabPanels[3], "Orbit Speed", fy, 100, 500, 300, " s/s", function(v) Settings.AutoFarmOrbitSpeed = v end)
    fy = MakeSlider(tabPanels[3], "Hover Height", fy, 30, 150, 80, " studs", function(v) Settings.AutoFarmHoverHeight = v end)
    fy = MakeSlider(tabPanels[3], "Orbit Radius", fy, 30, 150, 80, " studs", function(v) Settings.AutoFarmOrbitRadius = v end)
    fy = MakeSlider(tabPanels[3], "Safe Distance", fy, 50, 200, 100, " studs", function(v) Settings.AutoFarmSafeDistance = v end)
    fy = MakeSlider(tabPanels[3], "Responsiveness", fy, 5, 100, 25, "", function(v) Settings.AutoFarmResponsiveness = v end)
    fy = fy + 6
    fy = MakeSectionLabel(tabPanels[3], "AUTO HEAL", fy)
    fy = MakeToggle(tabPanels[3], "Enable Auto Heal", fy, false, function(v) Settings.AutoHealEnabled = v end)
    fy = MakeSlider(tabPanels[3], "HP Threshold %", fy, 10, 90, 50, "%", function(v) Settings.AutoHealThreshold = v end)
    fy = MakeButton(tabPanels[3], "Heal Now", "Manual trigger", fy, function() Funcs.TriggerAutoHeal() end)
    fy = fy + 6
    fy = MakeSectionLabel(tabPanels[3], "AUTO QUEST", fy)
    fy = MakeToggle(tabPanels[3], "Enable Auto Quest", fy, false, function(v) Settings.AutoQuestEnabled = v end)
    fy = MakeDropdown(tabPanels[3], "Quest Type", {"Slay Titans","Save Players","Auto (first)"}, fy, "Auto (first)", function(v)
        Settings.AutoQuestSelected = v
    end)
    fy = fy + 6
    fy = MakeSectionLabel(tabPanels[3], "AUTO BLADE REFILL", fy)
    fy = MakeToggle(tabPanels[3], "Enable Auto Refill", fy, false, function(v) Settings.AutoRefillEnabled = v end)
    fy = MakeSlider(tabPanels[3], "Blade Threshold", fy, 0, 100, 1, "%", function(v) Settings.AutoBladeRefillThreshold = v end)
    fy = MakeSlider(tabPanels[3], "Refill Wait Time", fy, 1, 15, 5, " sec", function(v) Settings.AutoBladeRefillReturnDelay = v end)
    fy = MakeButton(tabPanels[3], "Trigger Refill Now", "Manual trigger", fy, function() Funcs.TriggerAutoRefill() end)
    tabPanels[3].CanvasSize = UDim2.new(0,0,0,fy+20)
end

--====================================================
-- KEYBINDS (заполнит 07_Keybinds.lua через GUI API)
--====================================================
GUI.KeybindTabPanel = tabPanels[4]

--====================================================
-- SECURITY (заполнит 08_Security.lua)
--====================================================
GUI.SecurityTabPanel = tabPanels[5]

--====================================================
-- DEBUG
--====================================================
do
    local dy = 0
    dy = MakeSectionLabel(tabPanels[6], "DEBUG", dy)
    dy = MakeButton(tabPanels[6], "List Titans", "Print", dy, function()
        local t = Funcs.GetTitans()
        print("Titans:", #t)
        for i, x in ipairs(t) do if i > 15 then break end; print(i..". "..x.Model.Name.." | "..math.floor(x.Distance)) end
    end)
    dy = MakeButton(tabPanels[6], "List Refills", "Print", dy, function()
        local r = Funcs.GetRefills()
        print("Refills:", #r)
        for i, x in ipairs(r) do if i > 15 then break end; print(i..". "..x.Model.Name.." | "..math.floor(x.Distance)) end
    end)
    dy = MakeButton(tabPanels[6], "Executor Info", "Print", dy, function()
        print("Executor:", GUI.ExecutorName)
        print("Mod Group:", Config.MOD_GROUP_ID)
    end)
    dy = MakeButton(tabPanels[6], "Find Blade State", "Auto-detect", dy, function()
        local f = Funcs.FindBladeState()
        if f then print("Found:", f:GetFullName(), "=", f.Value)
        else print("Not found") end
    end)
    tabPanels[6].CanvasSize = UDim2.new(0,0,0,dy+20)
end

--====================================================
-- SETTINGS (ВЫБОР ТЕМЫ)
--====================================================
do
    local sy = 0
    sy = MakeSectionLabel(tabPanels[7], "INTERFACE THEME", sy)

    local themeDescriptions = {
        Dark = "Dark — классическая тёмная тема",
        Purple = "Purple — фиолетовая неоновая",
        Red = "Red — агрессивная красная",
        White = "White — светлая минималистичная",
    }

    -- Заголовок текущей темы
    local currentLabel = New("TextLabel", {
        Position = UDim2.new(0,4,0,sy), Size = UDim2.new(1,-8,0,26),
        BackgroundTransparency = 1,
        Text = "Текущая тема: " .. Settings.Theme,
        TextColor3 = Theme.Get().SectionText,
        Font = Enum.Font.GothamBold, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, tabPanels[7])
    sy = sy + 32

    -- 4 кнопки тем
    local themeNames = {"Dark", "Purple", "Red", "White"}
    for _, tname in ipairs(themeNames) do
        sy = MakeButton(tabPanels[7], tname, themeDescriptions[tname], sy, function()
            Theme.Apply(tname, true)
            currentLabel.Text = "Текущая тема: " .. tname
        end)
    end

    sy = sy + 10
    sy = MakeSectionLabel(tabPanels[7], "INFO", sy)
    New("TextLabel", {
        Position = UDim2.new(0,4,0,sy), Size = UDim2.new(1,-8,0,60),
        BackgroundTransparency = 1,
        Text = "Тема сохраняется автоматически\nв файл VentureAOT_Theme.json\nи применяется при следующем запуске.",
        TextColor3 = Theme.Get().SubText,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true, ZIndex = 8,
    }, tabPanels[7])
    sy = sy + 70

    tabPanels[7].CanvasSize = UDim2.new(0,0,0,sy+20)
end

--====================================================
-- DRAG (перетаскивание окна)
--====================================================
do
    local dragging, dragStart, startPos = false, nil, nil
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Main.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

--====================================================
-- INTRO / SHOW HIDE / CLOSE
--====================================================
local function FadeOutIntro()
    Tween(LoadingGlass, 0.8, {BackgroundTransparency = 0.4})
    CutscenePanel.Size = UDim2.fromOffset(360, 200)
    Tween(CutscenePanel, 0.8, {Size = UDim2.fromOffset(460, 260), BackgroundTransparency = 0.08}, Enum.EasingStyle.Back)
    Tween(CutsceneStroke, 0.8, {Transparency = 0.15})
    task.wait(0.4)
    Tween(Logo, 0.9, {TextTransparency = 0})
    task.wait(0.3)
    Tween(LogoSub, 0.8, {TextTransparency = 0})
    task.wait(0.3)
    Tween(AuthorLabel, 0.8, {TextTransparency = 0})
    task.wait(0.2)
    Tween(DiscordLabel, 0.8, {TextTransparency = 0})
    task.wait(0.2)
    Tween(VersionLabel, 0.8, {TextTransparency = 0})
    task.wait(2.0)
    Tween(CutscenePanel, 0.8, {BackgroundTransparency = 1})
    Tween(CutsceneStroke, 0.6, {Transparency = 1})
    for _, l in ipairs({Logo, LogoSub, AuthorLabel, DiscordLabel, VersionLabel}) do
        Tween(l, 0.5, {TextTransparency = 1})
    end
    Tween(LoadingGlass, 0.9, {BackgroundTransparency = 1})
    task.wait(1)
    Loading:Destroy()
end

GUI.ShowMain = function()
    Main.Visible = true
    Main.Size = UDim2.fromOffset(400, 300)
    Main.Position = UDim2.fromScale(0.5, 0.56)
    Main.BackgroundTransparency = 1
    MainStroke.Transparency = 1
    Glow.BackgroundTransparency = 1
    Tween(Main, 0.9, {
        Size = IsMobile and UDim2.fromOffset(480,400) or UDim2.fromOffset(620,480),
        Position = UDim2.fromScale(0.5,0.5),
        BackgroundTransparency = 0.06,
    }, Enum.EasingStyle.Back)
    Tween(MainStroke, 0.85, {Transparency = 0.2})
    Tween(Glow, 0.55, {BackgroundTransparency = 0})
    RefreshTabVisuals()
end

GUI.HideToIcon = function()
    Tween(Main, 0.4, {Size = UDim2.fromOffset(300,200), BackgroundTransparency = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Tween(MainStroke, 0.35, {Transparency = 1})
    Tween(Glow, 0.35, {BackgroundTransparency = 1})
    task.delay(0.4, function()
        Main.Visible = false
        OpenBtn.Visible = true
        OpenBtn.BackgroundTransparency = 1
        OpenBtn.TextTransparency = 1
        Tween(OpenBtn, 0.35, {BackgroundTransparency = 0.1, TextTransparency = 0}, Enum.EasingStyle.Back)
    end)
end

GUI.OpenFromIcon = function()
    Tween(OpenBtn, 0.25, {BackgroundTransparency = 1, TextTransparency = 1})
    task.delay(0.2, function()
        OpenBtn.Visible = false
        Main.Visible = true
        Main.Size = UDim2.fromOffset(300, 200)
        Main.Position = UDim2.fromScale(0.5, 0.5)
        Main.BackgroundTransparency = 1
        MainStroke.Transparency = 1
        Glow.BackgroundTransparency = 1
        Tween(Main, 0.6, {
            Size = IsMobile and UDim2.fromOffset(480,400) or UDim2.fromOffset(620,480),
            BackgroundTransparency = 0.06,
        }, Enum.EasingStyle.Back)
        Tween(MainStroke, 0.6, {Transparency = 0.2})
        Tween(Glow, 0.4, {BackgroundTransparency = 0})
        RefreshTabVisuals()
    end)
end

HideBtn.MouseButton1Click:Connect(GUI.HideToIcon)
OpenBtn.MouseButton1Click:Connect(GUI.OpenFromIcon)

CloseBtn.MouseButton1Click:Connect(function()
    Funcs.ResetAllHitboxes()
    Funcs.StopNoclip()
    Settings.AutoFarmEnabled = false
    Settings.Noclip = false
    Settings.HitboxExpand = false
    Tween(Main, 0.6, {Size = UDim2.fromOffset(280,170), Position = UDim2.fromScale(0.5,0.47), BackgroundTransparency = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Tween(MainStroke, 0.5, {Transparency = 1, Thickness = 4})
    Tween(Glow, 0.35, {BackgroundTransparency = 1})
    task.wait(0.6)
    ScreenGui:Destroy()
    KeybindListGui:Destroy()
    if not UserInputService.TouchEnabled then UserInputService.MouseIconEnabled = true end
end)

-- Кнопки ховер
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(52,39,65)}); Tween(CloseBtn, 0.18, {TextColor3 = Color3.fromRGB(255,125,170)}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, 0.18, {BackgroundColor3 = Theme.Get().CloseBtnBg}); Tween(CloseBtn, 0.18, {TextColor3 = Theme.Get().CloseBtnText}) end)
HideBtn.MouseEnter:Connect(function() Tween(HideBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(39,45,65)}); Tween(HideBtn, 0.18, {TextColor3 = Color3.fromRGB(150,180,255)}) end)
HideBtn.MouseLeave:Connect(function() Tween(HideBtn, 0.18, {BackgroundColor3 = Theme.Get().CloseBtnBg}); Tween(HideBtn, 0.18, {TextColor3 = Theme.Get().CloseBtnText}) end)
OpenBtn.MouseEnter:Connect(function() Tween(OpenBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(35,32,55)}) end)
OpenBtn.MouseLeave:Connect(function() Tween(OpenBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(20,22,36)}) end)

--====================================================
-- ФИНАЛЬНЫЙ ЗАПУСК GUI
--====================================================
GUI.Boot = function()
    task.spawn(FadeOutIntro)
    task.spawn(function()
        task.wait(4)
        GUI.ShowMain()
    end)
end

_G.Venture = _G.Venture or {}
_G.Venture.GUI = GUI

return GUI
