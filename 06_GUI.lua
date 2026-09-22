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

local ScreenGui = New("ScreenGui", {
    Name = "VentureAOT_GUI", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true, DisplayOrder = 999999,
}, PlayerGui)
GUI.ScreenGui = ScreenGui

-- INTRO
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
local VersionLabel = New("TextLabel", {AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.66), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = "v1.5", TextColor3 = Color3.fromRGB(180,180,200), TextSize = 12, Font = Enum.Font.Gotham, TextTransparency = 1, ZIndex = 103}, CutscenePanel)
GUI.Loading = Loading

-- KEYBIND LIST (слева снаружи)
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

-- MAIN WINDOW
local Main = New("Frame", {
    Name = "Main", AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.53),
    Size = IsMobile and UDim2.fromOffset(520,420) or UDim2.fromOffset(720,540),
    BackgroundColor3 = Config.Themes.Dark.MainBg,
    BackgroundTransparency = 0.06, BorderSizePixel = 0,
    ClipsDescendants = true, Active = true, Visible = false, ZIndex = 5,
}, ScreenGui)
New("UICorner", {CornerRadius = UDim.new(0,22)}, Main)
local MainStroke = New("UIStroke", {Color = Color3.fromRGB(125,92,255), Thickness = 1.5, Transparency = 0.2}, Main)
New("UIGradient", {Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(24,24,42)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(11,13,22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(7,8,14)),
}), Rotation = 135}, Main)
GUI.Main = Main
GUI.MainStroke = MainStroke
Theme.RegisterMain(Main)
Theme.Register("Misc", {Obj = MainStroke, Keys = {"Accent"}})

-- Header
local Header = New("Frame", {Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,0,0,58), BackgroundTransparency = 1, ZIndex = 6}, Main)

local SidebarToggle = New("TextButton", {Position = UDim2.new(0,16,0,16), Size = UDim2.fromOffset(32,32), BackgroundColor3 = Config.Themes.Dark.TabBgActive, BackgroundTransparency = 0.1, BorderSizePixel = 0, AutoButtonColor = false, Text = "≡", TextColor3 = Color3.fromRGB(255,255,255), TextSize = 20, Font = Enum.Font.GothamBold, ZIndex = 10}, Header)
New("UICorner", {CornerRadius = UDim.new(0,8)}, SidebarToggle)
local SidebarToggleStroke = New("UIStroke", {Color = Color3.fromRGB(125,92,255), Thickness = 1.2}, SidebarToggle)

local Title = New("TextLabel", {Position = UDim2.new(0,60,0,18), Size = UDim2.new(1,-200,0,24), BackgroundTransparency = 1, Text = "VENTURE  AOT", TextColor3 = Color3.fromRGB(248,247,255), TextSize = 18, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, Header)
local Subtitle = New("TextLabel", {Position = UDim2.new(0,60,0,38), Size = UDim2.new(1,-200,0,14), BackgroundTransparency = 1, Text = "by __TheDark  |  v1.5", TextColor3 = Color3.fromRGB(153,157,178), TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 6}, Header)
GUI.Title = Title
GUI.Subtitle = Subtitle
Theme.Register("Misc", {Obj = Title, Keys = {"TitleText"}})
Theme.Register("Misc", {Obj = Subtitle, Keys = {"SubtitleText"}})

local CloseBtn = New("TextButton", {AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-18,0,14), Size = UDim2.fromOffset(32,32), BackgroundColor3 = Color3.fromRGB(28,30,44), BackgroundTransparency = 0.15, BorderSizePixel = 0, AutoButtonColor = false, Text = "x", TextColor3 = Color3.fromRGB(185,187,205), TextSize = 18, Font = Enum.Font.GothamBold, ZIndex = 10}, Header)
New("UICorner", {CornerRadius = UDim.new(0,10)}, CloseBtn)

local HideBtn = New("TextButton", {AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-56,0,14), Size = UDim2.fromOffset(32,32), BackgroundColor3 = Color3.fromRGB(28,30,44), BackgroundTransparency = 0.15, BorderSizePixel = 0, AutoButtonColor = false, Text = "_", TextColor3 = Color3.fromRGB(185,187,205), TextSize = 18, Font = Enum.Font.GothamBold, ZIndex = 10}, Header)
New("UICorner", {CornerRadius = UDim.new(0,10)}, HideBtn)

local ChatBtn = New("TextButton", {AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-94,0,14), Size = UDim2.fromOffset(32,32), BackgroundColor3 = Color3.fromRGB(40,22,60), BackgroundTransparency = 0.15, BorderSizePixel = 0, AutoButtonColor = false, Text = "C", TextColor3 = Color3.fromRGB(255,200,255), TextSize = 16, Font = Enum.Font.GothamBold, ZIndex = 10}, Header)
New("UICorner", {CornerRadius = UDim.new(0,10)}, ChatBtn)

GUI.CloseBtn = CloseBtn
GUI.HideBtn = HideBtn
GUI.ChatBtn = ChatBtn
Theme.Register("Misc", {Obj = CloseBtn, Keys = {"CloseBtnBg"}})
Theme.Register("Misc", {Obj = HideBtn, Keys = {"CloseBtnBg"}})

local OpenBtn = New("TextButton", {AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-20,0,20), Size = UDim2.fromOffset(54,54), BackgroundColor3 = Color3.fromRGB(20,22,36), BackgroundTransparency = 0.1, BorderSizePixel = 0, AutoButtonColor = false, Text = "*", TextColor3 = Color3.fromRGB(212,175,55), TextSize = 24, Font = Enum.Font.GothamBold, Visible = false, ZIndex = 10}, ScreenGui)
New("UICorner", {CornerRadius = UDim.new(0,14)}, OpenBtn)
New("UIStroke", {Color = Color3.fromRGB(125,92,255), Thickness = 1.4, Transparency = 0.15}, OpenBtn)
GUI.OpenBtn = OpenBtn

-- SIDEBAR
local SIDEBAR_WIDTH_EXPANDED = 140
local SIDEBAR_WIDTH_COLLAPSED = 48

local Sidebar = New("Frame", {
    Position = UDim2.new(0,0,0,58),
    Size = UDim2.fromOffset(SIDEBAR_WIDTH_EXPANDED, 0),
    BackgroundColor3 = Color3.fromRGB(8,10,18),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 7,
}, Main)
GUI.Sidebar = Sidebar

New("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 4),
}, Sidebar)
New("UIPadding", {
    PaddingTop = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6),
}, Sidebar)

local SIDEBAR_TABS = {
    {Name = "MAIN"},
    {Name = "TITAN"},
    {Name = "AUTO"},
    {Name = "CHAT"},
    {Name = "ONLINE"},
    {Name = "ANNOUNCE"},
    {Name = "CONFIG"},
}

local tabButtons = {}
local tabPanels = {}
local tabStates = {}
local activeTabIndex = 1
local tabCount = #SIDEBAR_TABS
local sidebarExpanded = true

local ContentFrame = New("Frame", {
    Position = UDim2.new(0, SIDEBAR_WIDTH_EXPANDED + 8, 0, 62),
    Size = UDim2.new(1, -(SIDEBAR_WIDTH_EXPANDED + 20), 1, -70),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 6,
}, Main)

GUI.ContentFrame = ContentFrame
GUI.TabButtons = tabButtons
GUI.TabPanels = tabPanels

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

for i, tab in ipairs(SIDEBAR_TABS) do
    local btn = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = tab.Name,
        TextColor3 = Color3.fromRGB(220,222,240),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = i,
        ZIndex = 8,
    }, Sidebar)
    New("UICorner", {CornerRadius = UDim.new(0,8)}, btn)
    New("UIPadding", {PaddingLeft = UDim.new(0, 10)}, btn)

    btn.MouseEnter:Connect(function()
        if i ~= activeTabIndex then
            Tween(btn, 0.15, {BackgroundTransparency = 0.7, BackgroundColor3 = Color3.fromRGB(80,60,160)})
        end
    end)
    btn.MouseLeave:Connect(function()
        if i ~= activeTabIndex then
            Tween(btn, 0.15, {BackgroundTransparency = 1})
        end
    end)
    btn.MouseButton1Click:Connect(function()
        activeTabIndex = i
        for k = 1, tabCount do
            tabStates[k] = (k == i)
        end
        GUI.RefreshTabVisuals()
    end)

    tabButtons[i] = btn
    tabPanels[i] = MakePanel()
    tabStates[i] = false
end

function GUI.RefreshTabVisuals()
    local T = Theme.Get()
    for i, btn in ipairs(tabButtons) do
        local isActive = (i == activeTabIndex)
        btn.BackgroundColor3 = isActive and T.TabBgActive or Color3.fromRGB(0,0,0)
        btn.BackgroundTransparency = isActive and 0 or 1
        btn.TextColor3 = isActive and T.TabTextActive or T.TabText
        if tabPanels[i] then
            tabPanels[i].Visible = isActive
        end
    end
end

tabStates[1] = true
GUI.RefreshTabVisuals()

SidebarToggle.MouseButton1Click:Connect(function()
    sidebarExpanded = not sidebarExpanded
    local newWidth = sidebarExpanded and SIDEBAR_WIDTH_EXPANDED or SIDEBAR_WIDTH_COLLAPSED
    local newContentX = sidebarExpanded and (SIDEBAR_WIDTH_EXPANDED + 8) or (SIDEBAR_WIDTH_COLLAPSED + 8)
    local newContentW = sidebarExpanded and -(SIDEBAR_WIDTH_EXPANDED + 20) or -(SIDEBAR_WIDTH_COLLAPSED + 20)
    Tween(Sidebar, 0.35, {Size = UDim2.fromOffset(newWidth, 0)}, Enum.EasingStyle.Quart)
    Tween(ContentFrame, 0.35, {Position = UDim2.new(0, newContentX, 0, 62), Size = UDim2.new(1, newContentW, 1, -70)}, Enum.EasingStyle.Quart)
    for i, btn in ipairs(tabButtons) do
        if sidebarExpanded then
            btn.Text = SIDEBAR_TABS[i].Name
        else
            btn.Text = SIDEBAR_TABS[i].Name:sub(1, 1)
        end
    end
end)

-- ELEMENTS
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
    local h = subtext and (IsMobile and 56 or 50) or (IsMobile and 42 or 36)
    local T = Theme.Get()
    local btn = New("TextButton", {
        Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,-8,0,h),
        BackgroundColor3 = T.BtnBg, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, btn)
    local stroke = New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, btn)
    local mainLabel = New("TextLabel", {
        Position = UDim2.new(0,14,0, subtext and 6 or 0),
        Size = UDim2.new(1,-70,0, subtext and 20 or h),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = T.BtnText,
        Font = Enum.Font.GothamBold, TextSize = IsMobile and 12 or 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, btn)
    local subLabel = nil
    if subtext then
        subLabel = New("TextLabel", {
            Position = UDim2.new(0,14,0,28), Size = UDim2.new(1,-50,0,16),
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
    return y + h + 6
end

local function MakeToggle(parent, text, y, default, callback)
    local h = IsMobile and 40 or 36
    local T = Theme.Get()
    local btn = New("TextButton", {
        Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,-8,0,h),
        BackgroundColor3 = T.BtnBg, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, AutoButtonColor = false, Text = "", ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, btn)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, btn)
    local mainLabel = New("TextLabel", {
        Position = UDim2.new(0,14,0,0), Size = UDim2.new(1,-80,1,0),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = T.BtnText,
        Font = Enum.Font.GothamBold, TextSize = IsMobile and 12 or 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, btn)
    local pill = New("Frame", {
        AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-12,0.5,0),
        Size = UDim2.fromOffset(42,20),
        BackgroundColor3 = default and T.ToggleOn or T.ToggleOff,
        BorderSizePixel = 0, ZIndex = 9,
    }, btn)
    New("UICorner", {CornerRadius = UDim.new(1,0)}, pill)
    local knob = New("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = default and UDim2.new(1,-10,0.5,0) or UDim2.new(0,10,0.5,0),
        Size = UDim2.fromOffset(14,14),
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
        Tween(knob, 0.2, {Position = state and UDim2.new(1,-10,0.5,0) or UDim2.new(0,10,0.5,0)})
        callback(state)
    end)
    return y + h + 6
end

local function MakeSlider(parent, text, y, min, max, default, suffix, callback)
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
        Position = UDim2.new(0,14,0,4), Size = UDim2.new(1,-90,0,16),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = T.BtnText,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, frame)
    local valLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-14,0,4),
        Size = UDim2.fromOffset(70,16), BackgroundTransparency = 1,
        Text = tostring(default) .. (suffix or ""),
        TextColor3 = T.TabTextActive,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 9,
    }, frame)
    local barBG = New("Frame", {
        Position = UDim2.new(0,14,0,26), Size = UDim2.new(1,-28,0, IsMobile and 7 or 5),
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
    local oh = 26
    local total = 28 + (#options * oh) + 8
    local T = Theme.Get()
    local frame = New("Frame", {
        Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,-8,0,total),
        BackgroundColor3 = T.BtnBg, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, frame)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, frame)
    New("TextLabel", {
        Position = UDim2.new(0,14,0,4), Size = UDim2.new(1,-28,0,18),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = T.TabTextActive,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, frame)
    local states = {}
    for _, o in ipairs(options) do states[o] = Settings.HitboxParts[o] or false end
    for i, opt in ipairs(options) do
        local ry = 28 + (i-1) * oh
        local row = New("TextButton", {
            Position = UDim2.new(0,10,0,ry), Size = UDim2.new(1,-20,0,oh-2),
            BackgroundColor3 = states[opt] and Color3.fromRGB(40,42,60) or Color3.fromRGB(15,17,28),
            BackgroundTransparency = 0.2, BorderSizePixel = 0,
            AutoButtonColor = false, Text = "", ZIndex = 9,
        }, frame)
        New("UICorner", {CornerRadius = UDim.new(0,6)}, row)
        local cb = New("TextLabel", {
            Position = UDim2.new(0,6,0,0), Size = UDim2.fromOffset(22,oh-2),
            BackgroundTransparency = 1, Text = states[opt] and "[X]" or "[  ]",
            TextColor3 = states[opt] and Color3.fromRGB(212,175,55) or Color3.fromRGB(120,120,140),
            Font = Enum.Font.Code, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 10,
        }, row)
        New("TextLabel", {
            Position = UDim2.new(0,30,0,0), Size = UDim2.new(1,-34,1,0),
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
    local h = IsMobile and 44 or 40
    local T = Theme.Get()
    local frame = New("Frame", {
        Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,-8,0,h),
        BackgroundColor3 = T.BtnBg, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, frame)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, frame)
    local mainLabel = New("TextLabel", {
        Position = UDim2.new(0,14,0,0), Size = UDim2.new(0.5,0,1,0),
        BackgroundTransparency = 1, Text = text,
        TextColor3 = T.BtnText,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, frame)
    local btn = New("TextButton", {
        AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-14,0.5,0),
        Size = UDim2.fromOffset(IsMobile and 140 or 160, 28),
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
            Position = UDim2.new(1, IsMobile and -156 or -176, 1, 4),
            Size = UDim2.fromOffset(IsMobile and 140 or 160, #options * 24),
            BackgroundColor3 = Theme.Get().MainBg, BorderSizePixel = 0, ZIndex = 20,
        }, frame)
        New("UICorner", {CornerRadius = UDim.new(0,8)}, dropdown)
        New("UIStroke", {Color = Theme.Get().Accent, Thickness = 1, Transparency = 0.2}, dropdown)
        for i, opt in ipairs(options) do
            local o = New("TextButton", {
                Position = UDim2.new(0,0,0,(i-1)*24), Size = UDim2.new(1,0,0,24),
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
    return y + h + 6
end

GUI.MakeSectionLabel = MakeSectionLabel
GUI.MakeButton = MakeButton
GUI.MakeToggle = MakeToggle
GUI.MakeSlider = MakeSlider
GUI.MakeMultiSelect = MakeMultiSelect
GUI.MakeDropdown = MakeDropdown

-- TAB 1: MAIN
do
    local y = 0
    y = MakeSectionLabel(tabPanels[1], "TITAN CONTROL", y)
    y = MakeButton(tabPanels[1], "Find Nearest Titan", "Lock onto nearest available target", y, function()
        local t = Funcs.GetTitans()
        if #t == 0 then return end
        Funcs.StickToTitan(t[1])
    end)
    y = MakeButton(tabPanels[1], "Safe Release", "Detach and boost", y, function()
        Funcs.CleanupStick(true); Funcs.State.currentTarget = nil
    end)
    y = MakeButton(tabPanels[1], "Force Reset", "Clear current state", y, function()
        Funcs.ForceResetState()
    end)
    tabPanels[1].CanvasSize = UDim2.new(0,0,0,y+20)
end

-- TAB 2: TITAN
do
    local y = 0
    y = MakeSectionLabel(tabPanels[2], "HITBOX", y)
    y = MakeToggle(tabPanels[2], "Expand Hitbox", y, false, function(v)
        Settings.HitboxExpand = v
        if v then Funcs.ApplyHitboxToAll() else Funcs.ResetAllHitboxes() end
    end)
    y = MakeSlider(tabPanels[2], "Size X", y, 50, 500, 300, " studs", function(v)
        Settings.HitboxSize = Vector3.new(v, Settings.HitboxSize.Y, Settings.HitboxSize.Z)
        Funcs.ApplyHitboxToAll()
    end)
    y = MakeSlider(tabPanels[2], "Size Y", y, 50, 500, 200, " studs", function(v)
        Settings.HitboxSize = Vector3.new(Settings.HitboxSize.X, v, Settings.HitboxSize.Z)
        Funcs.ApplyHitboxToAll()
    end)
    y = MakeSlider(tabPanels[2], "Size Z", y, 50, 500, 300, " studs", function(v)
        Settings.HitboxSize = Vector3.new(Settings.HitboxSize.X, Settings.HitboxSize.Y, v)
        Funcs.ApplyHitboxToAll()
    end)
    y = MakeMultiSelect(tabPanels[2], "TARGET PARTS", {"Nape","Eyes","LeftArm","LeftLeg","RightArm","RightLeg"}, y)
    y = MakeDropdown(tabPanels[2], "Shape", {"Block","Ball","Cylinder"}, y, "Block", function(v)
        Settings.HitboxShape = v
        Funcs.ApplyHitboxToAll()
    end)
    y = MakeButton(tabPanels[2], "Reset Hitboxes", "Restore original", y, function()
        Funcs.ResetAllHitboxes()
    end)
    y = y + 6
    y = MakeSectionLabel(tabPanels[2], "ESP", y)
    y = MakeToggle(tabPanels[2], "Titan + Refill ESP", y, false, function(v) Settings.ESP = v end)
    y = MakeToggle(tabPanels[2], "Player ESP", y, false, function(v) Settings.PlayerESP = v end)
    y = MakeToggle(tabPanels[2], "Shifter ESP", y, false, function(v) Settings.ShifterESP = v end)
    y = y + 6
    y = MakeSectionLabel(tabPanels[2], "MOVEMENT", y)
    y = MakeToggle(tabPanels[2], "Noclip", y, false, function(v)
        Settings.Noclip = v
        if v then Funcs.StartNoclip() else Funcs.StopNoclip() end
    end)
    y = MakeToggle(tabPanels[2], "FPS Booster", y, false, function(v)
        Settings.FPSBoosterEnabled = v
        if v then Funcs.EnableFPSBooster() else Funcs.DisableFPSBooster() end
    end)
    tabPanels[2].CanvasSize = UDim2.new(0,0,0,y+20)
end

-- TAB 3: AUTO
do
    local y = 0
    y = MakeSectionLabel(tabPanels[3], "AUTO FARM", y)
    y = MakeToggle(tabPanels[3], "Enable AutoFarm", y, false, function(v)
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
    y = MakeSectionLabel(tabPanels[3], "BLADE REFILL", y)
    y = MakeButton(tabPanels[3], "TP to Refill", "Teleport to closest refill", y, function()
        local r = Funcs.GetRefills()
        if #r == 0 then return end
        Funcs.TeleportToRefill(r[1])
    end)
    y = MakeToggle(tabPanels[3], "Enable Auto Refill", y, false, function(v) Settings.AutoRefillEnabled = v end)
    y = y + 6
    y = MakeSectionLabel(tabPanels[3], "AUTO HEAL", y)
    y = MakeToggle(tabPanels[3], "Enable Auto Heal", y, false, function(v) Settings.AutoHealEnabled = v end)
    y = MakeButton(tabPanels[3], "Heal Now", "Manual trigger", y, function() Funcs.TriggerAutoHeal() end)
    y = y + 6
    y = MakeSectionLabel(tabPanels[3], "AUTO QUEST", y)
    y = MakeToggle(tabPanels[3], "Enable Auto Quest", y, false, function(v) Settings.AutoQuestEnabled = v end)
    y = y + 6
    y = MakeSectionLabel(tabPanels[3], "SETTINGS", y)
    y = MakeSlider(tabPanels[3], "Orbit Speed", y, 100, 500, 300, " s/s", function(v) Settings.AutoFarmOrbitSpeed = v end)
    y = MakeSlider(tabPanels[3], "Hover Height", y, 30, 150, 80, " studs", function(v) Settings.AutoFarmHoverHeight = v end)
    y = MakeSlider(tabPanels[3], "Orbit Radius", y, 30, 150, 80, " studs", function(v) Settings.AutoFarmOrbitRadius = v end)
    y = MakeSlider(tabPanels[3], "Safe Distance", y, 50, 200, 100, " studs", function(v) Settings.AutoFarmSafeDistance = v end)
    tabPanels[3].CanvasSize = UDim2.new(0,0,0,y+20)
end

-- TAB 4: CHAT
GUI.ChatTabPanel = tabPanels[4]

-- TAB 5: ONLINE
GUI.OnlineTabPanel = tabPanels[5]

-- TAB 6: ANNOUNCE
GUI.AnnounceTabPanel = tabPanels[6]

-- TAB 7: CONFIG
GUI.KeybindTabPanel = tabPanels[7]
GUI.SecurityTabPanel = tabPanels[7]  -- будет вставлен ниже как отдельная секция
GUI.ThemeTabPanel = nil
GUI.DebugTabPanel = nil

-- CONFIG панель с 4 секциями
do
    local panel = tabPanels[7]
    local T = Theme.Get()

    -- SECTION: KEYBINDS
    local sec1 = New("Frame", {Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,-8,0,0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 8}, panel)
    New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}, sec1)
    GUI.KeybindTabPanel = sec1

    -- SECTION: SECURITY
    local sec2 = New("Frame", {Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,-8,0,0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 2, ZIndex = 8}, panel)
    New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}, sec2)
    GUI.SecurityTabPanel = sec2

    -- SECTION: THEME
    local sec3 = New("Frame", {Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,-8,0,0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 3, ZIndex = 8}, panel)
    New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}, sec3)
    GUI.ThemeTabPanel = sec3

    -- SECTION: DEBUG
    local sec4 = New("Frame", {Position = UDim2.new(0,0,0,0), Size = UDim2.new(1,-8,0,0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = 4, ZIndex = 8}, panel)
    New("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}, sec4)
    GUI.DebugTabPanel = sec4

    -- Заполняем THEME
    do
        local y = 0
        y = MakeButton(sec3, "Dark", "Classic dark theme", y, function() Theme.Apply("Dark", true) end)
        y = MakeButton(sec3, "Purple", "Neon purple theme", y, function() Theme.Apply("Purple", true) end)
        y = MakeButton(sec3, "Red", "Aggressive red theme", y, function() Theme.Apply("Red", true) end)
        y = MakeButton(sec3, "White", "Light minimalist theme", y, function() Theme.Apply("White", true) end)
    end

    -- Заполняем DEBUG
    do
        local y = 0
        y = MakeButton(sec4, "List Titans", "Print to console", y, function()
            local t = Funcs.GetTitans()
            print("Titans:", #t)
            for i, x in ipairs(t) do if i > 15 then break end; print(i..". "..x.Model.Name.." | "..math.floor(x.Distance)) end
        end)
        y = MakeButton(sec4, "List Refills", "Print to console", y, function()
            local r = Funcs.GetRefills()
            print("Refills:", #r)
            for i, x in ipairs(r) do if i > 15 then break end; print(i..". "..x.Model.Name.." | "..math.floor(x.Distance)) end
        end)
        y = MakeButton(sec4, "Executor Info", "Print to console", y, function()
            print("Executor:", GUI.ExecutorName)
        end)
    end
end

-- DRAG
do
    local dragging, dragStart, startPos = false, nil, nil
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Header.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- INTRO
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
    Tween(Main, 0.9, {
        Size = IsMobile and UDim2.fromOffset(520,420) or UDim2.fromOffset(720,540),
        Position = UDim2.fromScale(0.5,0.5),
        BackgroundTransparency = 0.06,
    }, Enum.EasingStyle.Back)
    Tween(MainStroke, 0.85, {Transparency = 0.2})
    GUI.RefreshTabVisuals()
end

GUI.HideToIcon = function()
    Tween(Main, 0.4, {Size = UDim2.fromOffset(300,200), BackgroundTransparency = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Tween(MainStroke, 0.35, {Transparency = 1})
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
        Tween(Main, 0.6, {
            Size = IsMobile and UDim2.fromOffset(520,420) or UDim2.fromOffset(720,540),
            BackgroundTransparency = 0.06,
        }, Enum.EasingStyle.Back)
        Tween(MainStroke, 0.6, {Transparency = 0.2})
        GUI.RefreshTabVisuals()
    end)
end

HideBtn.MouseButton1Click:Connect(GUI.HideToIcon)
OpenBtn.MouseButton1Click:Connect(GUI.OpenFromIcon)

ChatBtn.MouseButton1Click:Connect(function()
    local ChatWindow = _G.Venture.ChatWindow
    if ChatWindow and ChatWindow.Toggle then
        ChatWindow.Toggle()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Funcs.ResetAllHitboxes()
    Funcs.StopNoclip()
    Settings.AutoFarmEnabled = false
    Settings.Noclip = false
    Settings.HitboxExpand = false
    Tween(Main, 0.6, {Size = UDim2.fromOffset(280,170), Position = UDim2.fromScale(0.5,0.47), BackgroundTransparency = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Tween(MainStroke, 0.5, {Transparency = 1, Thickness = 4})
    task.wait(0.6)
    ScreenGui:Destroy()
    KeybindListGui:Destroy()
    if not UserInputService.TouchEnabled then UserInputService.MouseIconEnabled = true end
end)

CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(52,39,65)}); Tween(CloseBtn, 0.18, {TextColor3 = Color3.fromRGB(255,125,170)}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, 0.18, {BackgroundColor3 = Theme.Get().CloseBtnBg}); Tween(CloseBtn, 0.18, {TextColor3 = Theme.Get().CloseBtnText}) end)
HideBtn.MouseEnter:Connect(function() Tween(HideBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(39,45,65)}); Tween(HideBtn, 0.18, {TextColor3 = Color3.fromRGB(150,180,255)}) end)
HideBtn.MouseLeave:Connect(function() Tween(HideBtn, 0.18, {BackgroundColor3 = Theme.Get().CloseBtnBg}); Tween(HideBtn, 0.18, {TextColor3 = Theme.Get().CloseBtnText}) end)
OpenBtn.MouseEnter:Connect(function() Tween(OpenBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(35,32,55)}) end)
OpenBtn.MouseLeave:Connect(function() Tween(OpenBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(20,22,36)}) end)
ChatBtn.MouseEnter:Connect(function() Tween(ChatBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(60,32,90)}) end)
ChatBtn.MouseLeave:Connect(function() Tween(ChatBtn, 0.18, {BackgroundColor3 = Color3.fromRGB(40,22,60)}) end)
SidebarToggle.MouseEnter:Connect(function() Tween(SidebarToggle, 0.18, {BackgroundColor3 = Color3.fromRGB(80,60,160)}) end)
SidebarToggle.MouseLeave:Connect(function() Tween(SidebarToggle, 0.18, {BackgroundColor3 = Theme.Get().TabBgActive}) end)

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
