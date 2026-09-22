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
local VersionLabel = New("TextLabel", {AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.66), Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = "v1.7 Modular", TextColor3 = Color3.fromRGB(180,180,200), TextSize = 12, Font = Enum.Font.Gotham, TextTransparency = 1, ZIndex = 103}, CutscenePanel)

GUI.Loading = Loading

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

-- 10 tabs
local tabs = {"MAIN", "VISUAL", "AUTOFARM", "ONLINE", "CHAT", "ANNOUNCE", "KEYBINDS", "SECURITY", "DEBUG", "SETTINGS"}
local tabButtons = {}
local tabPanels = {}
local tabStates = {}
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
        Font = Enum.Font.GothamBold, TextSize = 7,
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
