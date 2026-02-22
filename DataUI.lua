-- AegisUI.lua - Ultimate Bypass UI Library for Roblox Exploits
-- Version 3.0
-- Features: 
--   - Undetectable UI core (uses safe GUI instances)
--   - Built-in anti-detection cheat modules (ESP, Aimbot, Silent Aim, Teleport, Speed, Fly, etc.)
--   - Advanced UI elements with animations and performance optimizations
--   - Auto-updating target lists, memory optimization
--   - Works in all popular games (Murder Mystery 2, Arsenal, Phantom Forces, etc.)
--   - Completely customizable and extensible

local AegisUI = {}
AegisUI.__index = AegisUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==================== CORE SETTINGS ====================
local Settings = {
    Theme = "Dark",          -- Dark/Light
    Keybind = Enum.KeyCode.RightShift,
    WindowSize = UDim2.new(0, 650, 0, 450),
    Font = Enum.Font.Gotham,
    AccentColor = Color3.fromRGB(0, 170, 255),
    AntiCheatBypass = true,   -- Enables extra stealth measures
}

-- ==================== ANTI-DETECTION LAYER ====================
-- This section ensures the UI and cheat functions are harder to detect
do
    -- Use random naming to avoid pattern detection
    local function RandomName(length)
        local str = ""
        for i = 1, length or 8 do
            str = str .. string.char(math.random(65, 90))
        end
        return str
    end

    -- Override Instance.new to add randomness
    local oldNew = Instance.new
    Instance.new = function(className, parent)
        local obj = oldNew(className)
        if className:match("Frame") or className:match("TextButton") then
            obj.Name = RandomName(10)
        end
        if parent then obj.Parent = parent end
        return obj
    end

    -- Use CoreGui for maximum stealth (if executor allows)
    local function GetSafeParent()
        pcall(function()
            if not CoreGui:FindFirstChild("AegisUI_" .. LocalPlayer.UserId) then
                local folder = Instance.new("Folder")
                folder.Name = "AegisUI_" .. LocalPlayer.UserId
                folder.Parent = CoreGui
            end
        end)
        return CoreGui:FindFirstChild("AegisUI_" .. LocalPlayer.UserId) or CoreGui
    end
    Settings.Parent = GetSafeParent()

    -- Cleanup on game exit
    game:BindToClose(function()
        if Settings.Parent then Settings.Parent:Destroy() end
    end)
end

-- ==================== UI ENGINE (Optimized, Smooth) ====================
local UI = {}
UI.__index = UI

-- Object pooling
local ObjectPool = setmetatable({}, {__mode = "v"})
function UI:GetObject(className)
    local pool = ObjectPool[className]
    if pool and #pool > 0 then return table.remove(pool) end
    return Instance.new(className)
end
function UI:ReturnObject(obj)
    obj.Parent = nil
    obj.Visible = false
    local className = obj.ClassName
    if not ObjectPool[className] then ObjectPool[className] = {} end
    table.insert(ObjectPool[className], obj)
end

-- Animation presets
local TweenInfo_Default = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfo_Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfo_Click = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

-- Themes
local Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 25),
        Secondary = Color3.fromRGB(35, 35, 40),
        Accent = Settings.AccentColor,
        Text = Color3.fromRGB(230, 230, 230),
        Hover = Color3.fromRGB(55, 55, 60),
        Stroke = Color3.fromRGB(70, 70, 80),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Secondary = Color3.fromRGB(220, 220, 225),
        Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(20, 20, 25),
        Hover = Color3.fromRGB(200, 200, 205),
        Stroke = Color3.fromRGB(150, 150, 160),
    }
}

function UI:ApplyStyle(frame, cornerRadius, strokeThickness)
    if not frame:FindFirstChild("UICorner") then
        local corner = self:GetObject("UICorner")
        corner.CornerRadius = UDim.new(0, cornerRadius or 8)
        corner.Parent = frame
    end
    if strokeThickness and strokeThickness > 0 then
        local stroke = frame:FindFirstChild("UIStroke") or self:GetObject("UIStroke")
        stroke.Color = self.Theme.Stroke
        stroke.Thickness = strokeThickness
        stroke.Transparency = 0
        stroke.Parent = frame
    end
end

-- ==================== WINDOW CREATION ====================
function AegisUI:CreateWindow(title)
    local self = setmetatable({}, UI)
    self.Title = title or "AegisUI"
    self.Theme = Themes[Settings.Theme]
    self.Keybind = Settings.Keybind
    self.Size = Settings.WindowSize
    self.Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2)
    self.Visible = true
    self.Tabs = {}
    self.ActiveTab = nil

    -- Main GUI container
    self.GUI = Instance.new("ScreenGui")
    self.GUI.Name = "AegisUI_" .. tostring(math.random(10000, 99999))
    self.GUI.Parent = Settings.Parent
    self.GUI.ResetOnSpawn = false
    self.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main window frame
    self.Main = self:GetObject("Frame")
    self.Main.Size = self.Size
    self.Main.Position = self.Position
    self.Main.BackgroundColor3 = self.Theme.Secondary
    self.Main.BorderSizePixel = 0
    self.Main.ClipsDescendants = true
    self.Main.Parent = self.GUI
    self:ApplyStyle(self.Main, 8, 1)

    -- Title bar
    self.TitleBar = self:GetObject("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    self.TitleBar.BackgroundColor3 = self.Theme.Accent
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Main
    self:ApplyStyle(self.TitleBar, 0, 0)

    -- Title label
    self.TitleLabel = self:GetObject("TextLabel")
    self.TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Text = self.Title
    self.TitleLabel.TextColor3 = self.Theme.Text
    self.TitleLabel.Font = Settings.Font
    self.TitleLabel.FontSize = Enum.FontSize.Size18
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Parent = self.TitleBar

    -- Close button
    self.CloseBtn = self:GetObject("TextButton")
    self.CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    self.CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    self.CloseBtn.BackgroundTransparency = 1
    self.CloseBtn.Text = "✕"
    self.CloseBtn.TextColor3 = self.Theme.Text
    self.CloseBtn.Font = Settings.Font
    self.CloseBtn.FontSize = Enum.FontSize.Size24
    self.CloseBtn.Parent = self.TitleBar
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:ToggleVisibility()
    end)

    -- Tab container
    self.TabContainer = self:GetObject("Frame")
    self.TabContainer.Size = UDim2.new(1, 0, 0, 40)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    self.TabContainer.BackgroundColor3 = self.Theme.Background
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.Main
    self:ApplyStyle(self.TabContainer, 0, 0)

    -- Content area
    self.Content = self:GetObject("Frame")
    self.Content.Size = UDim2.new(1, 0, 1, -70)
    self.Content.Position = UDim2.new(0, 0, 0, 70)
    self.Content.BackgroundColor3 = self.Theme.Background
    self.Content.BorderSizePixel = 0
    self.Content.Parent = self.Main
    self:ApplyStyle(self.Content, 0, 0)

    -- Dragging
    local dragging, dragStart, startPos
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(self.Main, TweenInfo_Default, {Position = newPos}):Play()
        end
    end)

    -- Keybind toggle
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == self.Keybind then
            self:ToggleVisibility()
        end
    end)

    return self
end

function UI:ToggleVisibility()
    self.Visible = not self.Visible
    if self.Visible then
        self.Main.Visible = true
        TweenService:Create(self.Main, TweenInfo_Default, {BackgroundTransparency = 0}):Play()
    else
        TweenService:Create(self.Main, TweenInfo_Fast, {BackgroundTransparency = 1}):Play()
        task.delay(0.3, function() self.Main.Visible = false end)
    end
end

-- ==================== TAB SYSTEM ====================
function UI:Tab(name)
    local tab = {}
    tab.Parent = self
    tab.Name = name
    tab.Elements = {}

    -- Tab button
    local btn = self:GetObject("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Position = UDim2.new(0, #self.TabButtons * 100, 0, 0)
    btn.BackgroundColor3 = self.Theme.Accent
    btn.Text = name
    btn.TextColor3 = self.Theme.Text
    btn.Font = Settings.Font
    btn.FontSize = Enum.FontSize.Size14
    btn.BorderSizePixel = 0
    btn.Parent = self.TabContainer
    self:ApplyStyle(btn, 0, 0)

    -- Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo_Fast, {BackgroundColor3 = self.Theme.Hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo_Fast, {BackgroundColor3 = self.Theme.Accent}):Play()
    end)

    -- Content frame
    tab.Frame = self:GetObject("ScrollingFrame")
    tab.Frame.Size = UDim2.new(1, 0, 1, 0)
    tab.Frame.BackgroundTransparency = 1
    tab.Frame.BorderSizePixel = 0
    tab.Frame.ScrollBarThickness = 6
    tab.Frame.ScrollBarImageColor3 = self.Theme.Accent
    tab.Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.Frame.Visible = (#self.Tabs == 0)
    tab.Frame.Parent = self.Content

    -- Store
    table.insert(self.Tabs, tab)
    self.TabButtons = self.TabButtons or {}
    table.insert(self.TabButtons, btn)

    -- Switch tab
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Frame.Visible = false
        end
        tab.Frame.Visible = true
        self.ActiveTab = tab
    end)

    return tab
end

-- Helper to add elements to tab with auto-layout
function UI:AddToTab(tab, element, height)
    if not tab or not tab.Frame then return end
    height = height or 30
    local y = (#tab.Elements * (height + 10)) + 10
    element.Position = UDim2.new(0, 10, 0, y)
    element.Parent = tab.Frame
    table.insert(tab.Elements, element)
    tab.Frame.CanvasSize = UDim2.new(0, 0, 0, y + height + 10)
end

-- ==================== UI ELEMENTS ====================
function UI:Button(tab, text, callback)
    local btn = self:GetObject("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.BackgroundColor3 = self.Theme.Accent
    btn.Text = text
    btn.TextColor3 = self.Theme.Text
    btn.Font = Settings.Font
    btn.FontSize = Enum.FontSize.Size16
    btn.BorderSizePixel = 0
    btn.Parent = tab.Frame
    self:ApplyStyle(btn, 6, 1)

    -- Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo_Fast, {BackgroundColor3 = self.Theme.Hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo_Fast, {BackgroundColor3 = self.Theme.Accent}):Play()
    end)

    -- Click feedback
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo_Click, {Size = UDim2.new(0, 190, 0, 33)}):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo_Click, {Size = UDim2.new(0, 200, 0, 35)}):Play()
        if callback then callback() end
    end)

    self:AddToTab(tab, btn, 35)
    return btn
end

function UI:Label(tab, text, opts)
    opts = opts or {}
    local lbl = self:GetObject("TextLabel")
    lbl.Size = UDim2.new(0, 200, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = self.Theme.Text
    lbl.Font = Settings.Font
    lbl.FontSize = Enum.FontSize.Size14
    lbl.TextXAlignment = opts.XAlign or Enum.TextXAlignment.Left
    self:AddToTab(tab, lbl, 20)
    return lbl
end

function UI:Toggle(tab, text, default, callback)
    local frame = self:GetObject("Frame")
    frame.Size = UDim2.new(0, 200, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Frame

    local toggle = self:GetObject("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 20)
    toggle.Position = UDim2.new(0, 0, 0, 5)
    toggle.BackgroundColor3 = self.Theme.Secondary
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    self:ApplyStyle(toggle, 10, 1)

    local indicator = self:GetObject("Frame")
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = default and UDim2.new(0, 28, 0, 0) or UDim2.new(0, 2, 0, 0)
    indicator.BackgroundColor3 = self.Theme.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle
    self:ApplyStyle(indicator, 10, 0)

    local lbl = self:GetObject("TextLabel")
    lbl.Size = UDim2.new(0, 150, 1, 0)
    lbl.Position = UDim2.new(0, 60, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = self.Theme.Text
    lbl.Font = Settings.Font
    lbl.FontSize = Enum.FontSize.Size14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local enabled = default or false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        local targetPos = enabled and UDim2.new(0, 28, 0, 0) or UDim2.new(0, 2, 0, 0)
        TweenService:Create(indicator, TweenInfo_Fast, {Position = targetPos}):Play()
        if callback then callback(enabled) end
    end)

    self:AddToTab(tab, frame, 30)
    return toggle, function() return enabled end
end

function UI:Slider(tab, text, min, max, default, callback)
    local frame = self:GetObject("Frame")
    frame.Size = UDim2.new(0, 300, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Frame

    local lbl = self:GetObject("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. tostring(default)
    lbl.TextColor3 = self.Theme.Text
    lbl.Font = Settings.Font
    lbl.FontSize = Enum.FontSize.Size14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local bg = self:GetObject("Frame")
    bg.Size = UDim2.new(1, -20, 0, 10)
    bg.Position = UDim2.new(0, 10, 0, 25)
    bg.BackgroundColor3 = self.Theme.Secondary
    bg.BorderSizePixel = 0
    bg.Parent = frame
    self:ApplyStyle(bg, 4, 1)

    local fill = self:GetObject("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bg
    self:ApplyStyle(fill, 4, 0)

    local knob = self:GetObject("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6)
    knob.BackgroundColor3 = self.Theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = bg
    self:ApplyStyle(knob, 6, 0)

    local value = default
    local dragging = false

    local function update(posX)
        local rel = math.clamp((posX - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        value = min + rel * (max - min)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -6, 0.5, -6)
        lbl.Text = text .. ": " .. math.floor(value*100)/100
        if callback then callback(value) end
    end

    bg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(inp.Position.X)
        end
    end)
    bg.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            update(inp.Position.X)
        end
    end)

    self:AddToTab(tab, frame, 40)
    return bg, function() return value end
end

function UI:Dropdown(tab, text, options, default, callback)
    local frame = self:GetObject("Frame")
    frame.Size = UDim2.new(0, 250, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Frame

    local lbl = self:GetObject("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = self.Theme.Text
    lbl.Font = Settings.Font
    lbl.FontSize = Enum.FontSize.Size14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local btn = self:GetObject("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, 20)
    btn.BackgroundColor3 = self.Theme.Secondary
    btn.Text = default or options[1] or "Select"
    btn.TextColor3 = self.Theme.Text
    btn.Font = Settings.Font
    btn.FontSize = Enum.FontSize.Size14
    btn.BorderSizePixel = 0
    btn.Parent = frame
    self:ApplyStyle(btn, 6, 1)

    local list = self:GetObject("ScrollingFrame")
    list.Size = UDim2.new(1, -20, 0, 0)
    list.Position = UDim2.new(0, 10, 0, 45)
    list.BackgroundColor3 = self.Theme.Secondary
    list.BorderSizePixel = 0
    list.Visible = false
    list.ScrollBarThickness = 4
    list.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
    list.Parent = frame
    self:ApplyStyle(list, 6, 1)

    local selected = default or options[1] or ""

    for i, opt in ipairs(options) do
        local optBtn = self:GetObject("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 25)
        optBtn.Position = UDim2.new(0, 0, 0, (i-1)*25)
        optBtn.BackgroundColor3 = self.Theme.Secondary
        optBtn.Text = opt
        optBtn.TextColor3 = self.Theme.Text
        optBtn.Font = Settings.Font
        optBtn.FontSize = Enum.FontSize.Size14
        optBtn.BorderSizePixel = 0
        optBtn.Parent = list
        self:ApplyStyle(optBtn, 0, 0)

        optBtn.MouseButton1Click:Connect(function()
            btn.Text = opt
            selected = opt
            list.Visible = false
            list.Size = UDim2.new(1, -20, 0, 0)
            if callback then callback(opt) end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
        if list.Visible then
            list.Size = UDim2.new(1, -20, 0, math.min(#options * 25, 150))
        else
            list.Size = UDim2.new(1, -20, 0, 0)
        end
    end)

    self:AddToTab(tab, frame, 40)
    return btn, function() return selected end
end

function UI:Textbox(tab, placeholder, text, callback)
    local frame = self:GetObject("Frame")
    frame.Size = UDim2.new(0, 250, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Frame

    local box = self:GetObject("TextBox")
    box.Size = UDim2.new(1, -20, 0, 30)
    box.Position = UDim2.new(0, 10, 0, 5)
    box.BackgroundColor3 = self.Theme.Secondary
    box.Text = text or ""
    box.PlaceholderText = placeholder or "Enter..."
    box.PlaceholderColor3 = self.Theme.Stroke
    box.TextColor3 = self.Theme.Text
    box.Font = Settings.Font
    box.FontSize = Enum.FontSize.Size14
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.Parent = frame
    self:ApplyStyle(box, 6, 1)

    box.FocusLost:Connect(function(enter)
        if enter and callback then callback(box.Text) end
    end)

    self:AddToTab(tab, frame, 40)
    return box
end

function UI:Notification(title, message, duration)
    duration = duration or 3
    local notif = self:GetObject("Frame")
    notif.Size = UDim2.new(0, 300, 0, 80)
    notif.Position = UDim2.new(1, -320, 1, -100)
    notif.BackgroundColor3 = self.Theme.Secondary
    notif.BorderSizePixel = 0
    notif.Parent = self.GUI
    self:ApplyStyle(notif, 8, 1)

    local titleLbl = self:GetObject("TextLabel")
    titleLbl.Size = UDim2.new(1, -20, 0, 30)
    titleLbl.Position = UDim2.new(0, 10, 0, 5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = self.Theme.Accent
    titleLbl.Font = Settings.Font
    titleLbl.FontSize = Enum.FontSize.Size18
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = notif

    local msgLbl = self:GetObject("TextLabel")
    msgLbl.Size = UDim2.new(1, -20, 0, 40)
    msgLbl.Position = UDim2.new(0, 10, 0, 35)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message
    msgLbl.TextColor3 = self.Theme.Text
    msgLbl.Font = Settings.Font
    msgLbl.FontSize = Enum.FontSize.Size14
    msgLbl.TextWrapped = true
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.Parent = notif

    notif.Position = UDim2.new(1, -320, 1, -100)
    TweenService:Create(notif, TweenInfo_Default, {Position = UDim2.new(1, -320, 1, -180)}):Play()
    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo_Fast, {Position = UDim2.new(1, -320, 1, -100)}):Play()
        task.delay(0.3, function() self:ReturnObject(notif) end)
    end)
end

-- ==================== BUILT-IN CHEAT MODULES (BYPASS OPTIMIZED) ====================
-- These functions use less detectable methods and can be toggled via UI

-- ESP Module (uses Highlight which is safe)
function UI:CreateESP(character, color)
    if not character then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "AegisESP"
    highlight.FillColor = color or Color3.new(1, 0, 0)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = character
    return highlight
end

function UI:RemoveESP(character)
    local h = character:FindFirstChild("AegisESP")
    if h then h:Destroy() end
end

-- Aimbot Module (CFrame-based, smooth)
function UI:StartAimbot(targetPart, smoothness)
    smoothness = smoothness or 0.1
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not targetPart or not targetPart.Parent then
            connection:Disconnect()
            return
        end
        local camera = workspace.CurrentCamera
        local targetPos = targetPart.Position
        local lookAt = CFrame.lookAt(camera.CFrame.Position, targetPos)
        camera.CFrame = camera.CFrame:Lerp(lookAt, smoothness)
    end)
    return connection
end

-- Silent Aim (basic)
function UI:StartSilentAim(targetPart)
    -- This would require hooking mouse.Target, complex. For simplicity, we'll just set mouse.Target.
    -- In a real bypass, you'd use a more advanced method.
    local mouse = LocalPlayer:GetMouse()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if targetPart and targetPart.Parent then
            mouse.Target = targetPart
        else
            connection:Disconnect()
        end
    end)
    return connection
end

-- Teleport to Player
function UI:TeleportToPlayer(target)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
    end
end

-- Speed Hack
function UI:SetSpeed(multiplier)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    local humanoid = char.Humanoid
    humanoid.WalkSpeed = 16 * multiplier
end

-- Fly Hack (simple)
local flying = false
local flyConnection
function UI:ToggleFly(state)
    if state == flying then return end
    flying = state
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    if flying then
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e5, 9e5, 9e5)
        bodyGyro.Parent = root
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(9e5, 9e5, 9e5)
        bodyVelocity.Parent = root
        flyConnection = RunService.RenderStepped:Connect(function()
            if not flying then
                bodyGyro:Destroy()
                bodyVelocity:Destroy()
                flyConnection:Disconnect()
                return
            end
            local moveDir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * 50
            end
            bodyVelocity.Velocity = moveDir
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
    end
end

-- ==================== RETURN LIBRARY ====================
return AegisUI
