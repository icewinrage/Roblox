-- EasyUI.lua - A powerful and user-friendly UI library for Roblox exploit scripts
-- Version: 2.1
-- Author: Community-driven
-- Features: Window with drag & keybind, tabs, buttons, toggles, sliders, dropdowns,
--           textboxes, notifications, themes (Dark/Light), object pooling, smooth animations.
-- Usage: 
--   local EasyUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/your/repo/main/EasyUI.lua"))()
--   local ui = EasyUI:CreateWindow({Title = "My Menu", Keybind = Enum.KeyCode.RightShift})
--   local tab = ui:Tab("Main")
--   tab:Button("Click", function() print("Clicked") end)

local EasyUI = {}
EasyUI.__index = EasyUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Animation presets
local TweenInfo_Default = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfo_Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TweenInfo_Click = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

-- Object pooling for better performance
local ObjectPool = setmetatable({}, {__mode = "v"})
local function GetObject(className)
    local pool = ObjectPool[className]
    if pool and #pool > 0 then
        return table.remove(pool)
    end
    return Instance.new(className)
end
local function ReturnObject(obj)
    obj.Parent = nil
    obj.Visible = false
    local className = obj.ClassName
    if not ObjectPool[className] then ObjectPool[className] = {} end
    table.insert(ObjectPool[className], obj)
end

-- Themes
local Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(40, 40, 45),
        Accent = Color3.fromRGB(0, 160, 255),
        Text = Color3.fromRGB(235, 235, 235),
        Hover = Color3.fromRGB(55, 55, 60),
        Stroke = Color3.fromRGB(70, 70, 80),
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Secondary = Color3.fromRGB(225, 225, 225),
        Accent = Color3.fromRGB(0, 120, 215),
        Text = Color3.fromRGB(20, 20, 20),
        Hover = Color3.fromRGB(200, 200, 200),
        Stroke = Color3.fromRGB(150, 150, 150),
    }
}

-- Helper: apply rounded corners and stroke to a GUI element
local function ApplyStyle(frame, theme, cornerRadius, strokeThickness)
    if not frame:FindFirstChild("UICorner") then
        local corner = GetObject("UICorner")
        corner.CornerRadius = UDim.new(0, cornerRadius or 8)
        corner.Parent = frame
    end
    if strokeThickness and strokeThickness > 0 then
        local stroke = frame:FindFirstChild("UIStroke") or GetObject("UIStroke")
        stroke.Color = theme.Stroke
        stroke.Thickness = strokeThickness
        stroke.Transparency = 0
        stroke.Parent = frame
    end
end

-- ========================== WINDOW CLASS ==========================
function EasyUI:CreateWindow(config)
    config = config or {}
    local window = setmetatable({}, EasyUI)
    window.Title = config.Title or "EasyUI"
    window.Theme = Themes[config.Theme] or Themes.Dark
    window.Keybind = config.Keybind or Enum.KeyCode.RightShift
    window.Size = config.Size or UDim2.new(0, 600, 0, 400)
    window.Position = config.Position or UDim2.new(0.5, -300, 0.5, -200)
    window.Visible = true
    window.Tabs = {}
    window.ActiveTab = nil
    window.Parent = config.Parent or (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") or game:GetService("CoreGui"))

    -- Main GUI
    window.GUI = Instance.new("ScreenGui")
    window.GUI.Name = "EasyUI_" .. tostring(math.random(1000, 9999))
    window.GUI.Parent = window.Parent
    window.GUI.ResetOnSpawn = false
    window.GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main frame
    window.Main = GetObject("Frame")
    window.Main.Size = window.Size
    window.Main.Position = window.Position
    window.Main.BackgroundColor3 = window.Theme.Secondary
    window.Main.BorderSizePixel = 0
    window.Main.ClipsDescendants = true
    window.Main.Parent = window.GUI
    ApplyStyle(window.Main, window.Theme, 8, 1)

    -- Title bar (for dragging)
    window.TitleBar = GetObject("Frame")
    window.TitleBar.Size = UDim2.new(1, 0, 0, 30)
    window.TitleBar.BackgroundColor3 = window.Theme.Accent
    window.TitleBar.BorderSizePixel = 0
    window.TitleBar.Parent = window.Main
    ApplyStyle(window.TitleBar, window.Theme, 0, 0)

    -- Title label
    window.TitleLabel = GetObject("TextLabel")
    window.TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    window.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    window.TitleLabel.BackgroundTransparency = 1
    window.TitleLabel.Text = window.Title
    window.TitleLabel.TextColor3 = window.Theme.Text
    window.TitleLabel.Font = Enum.Font.GothamBold
    window.TitleLabel.TextSize = 16
    window.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    window.TitleLabel.Parent = window.TitleBar

    -- Close button
    window.CloseBtn = GetObject("TextButton")
    window.CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    window.CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    window.CloseBtn.BackgroundTransparency = 1
    window.CloseBtn.Text = "✕"
    window.CloseBtn.TextColor3 = window.Theme.Text
    window.CloseBtn.Font = Enum.Font.Gotham
    window.CloseBtn.TextSize = 20
    window.CloseBtn.Parent = window.TitleBar
    window.CloseBtn.MouseButton1Click:Connect(function()
        window:ToggleVisibility()
    end)

    -- Tab container
    window.TabContainer = GetObject("Frame")
    window.TabContainer.Size = UDim2.new(1, 0, 0, 40)
    window.TabContainer.Position = UDim2.new(0, 0, 0, 30)
    window.TabContainer.BackgroundColor3 = window.Theme.Background
    window.TabContainer.BorderSizePixel = 0
    window.TabContainer.Parent = window.Main
    ApplyStyle(window.TabContainer, window.Theme, 0, 0)

    -- Tab buttons will be placed here
    window.TabButtons = {}

    -- Content container
    window.Content = GetObject("Frame")
    window.Content.Size = UDim2.new(1, 0, 1, -70)
    window.Content.Position = UDim2.new(0, 0, 0, 70)
    window.Content.BackgroundColor3 = window.Theme.Background
    window.Content.BorderSizePixel = 0
    window.Content.Parent = window.Main
    ApplyStyle(window.Content, window.Theme, 0, 0)

    -- Dragging functionality
    local dragging, dragInput, dragStart, startPos
    window.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    window.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            TweenService:Create(window.Main, TweenInfo_Default, {Position = newPos}):Play()
        end
    end)

    -- Keybind toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == window.Keybind then
            window:ToggleVisibility()
        end
    end)

    return window
end

-- Toggle window visibility
function EasyUI:ToggleVisibility()
    self.Visible = not self.Visible
    if self.Visible then
        self.Main.Visible = true
        TweenService:Create(self.Main, TweenInfo_Default, {BackgroundTransparency = 0}):Play()
    else
        TweenService:Create(self.Main, TweenInfo_Fast, {BackgroundTransparency = 1}):Play()
        task.delay(0.3, function() self.Main.Visible = false end)
    end
end

-- ========================== TAB SYSTEM ==========================
function EasyUI:Tab(name)
    local tab = {}
    tab.Window = self
    tab.Name = name
    tab.Elements = {}

    -- Create tab button
    local btn = GetObject("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Position = UDim2.new(0, (#self.TabButtons * 100), 0, 0)
    btn.BackgroundColor3 = self.Theme.Accent
    btn.Text = name
    btn.TextColor3 = self.Theme.Text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.Parent = self.TabContainer
    ApplyStyle(btn, self.Theme, 0, 0)

    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo_Fast, {BackgroundColor3 = self.Theme.Hover}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo_Fast, {BackgroundColor3 = self.Theme.Accent}):Play()
    end)

    -- Content frame for this tab
    tab.Frame = GetObject("ScrollingFrame")
    tab.Frame.Size = UDim2.new(1, 0, 1, 0)
    tab.Frame.BackgroundTransparency = 1
    tab.Frame.BorderSizePixel = 0
    tab.Frame.ScrollBarThickness = 6
    tab.Frame.ScrollBarImageColor3 = self.Theme.Accent
    tab.Frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tab.Frame.Visible = (#self.Tabs == 0) -- first tab visible
    tab.Frame.Parent = self.Content

    -- Store for switching
    self.Tabs[#self.Tabs + 1] = tab
    self.TabButtons[#self.TabButtons + 1] = btn

    -- Switch on click
    btn.MouseButton1Click:Connect(function()
        for _, otherTab in ipairs(self.Tabs) do
            otherTab.Frame.Visible = false
        end
        tab.Frame.Visible = true
        self.ActiveTab = tab
    end)

    return tab
end

-- Helper to add an element to a tab (automatically positions)
function EasyUI:AddToTab(tab, element, height)
    if not tab or not tab.Frame then return end
    height = height or 30
    local y = (#tab.Elements * (height + 10)) + 10
    element.Position = UDim2.new(0, 10, 0, y)
    element.Parent = tab.Frame
    table.insert(tab.Elements, element)
    -- Update canvas size
    tab.Frame.CanvasSize = UDim2.new(0, 0, 0, y + height + 10)
end

-- ========================== UI ELEMENTS ==========================
function EasyUI:Button(tab, text, callback)
    local btn = GetObject("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.BackgroundColor3 = self.Theme.Accent
    btn.Text = text
    btn.TextColor3 = self.Theme.Text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    ApplyStyle(btn, self.Theme, 6, 1)

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

function EasyUI:Label(tab, text, options)
    options = options or {}
    local label = GetObject("TextLabel")
    label.Size = UDim2.new(0, 200, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = options.TextSize or 14
    label.TextXAlignment = options.XAlignment or Enum.TextXAlignment.Left
    self:AddToTab(tab, label, 20)
    return label
end

function EasyUI:Toggle(tab, text, default, callback)
    local frame = GetObject("Frame")
    frame.Size = UDim2.new(0, 200, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Frame

    local toggle = GetObject("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 20)
    toggle.Position = UDim2.new(0, 0, 0, 5)
    toggle.BackgroundColor3 = self.Theme.Secondary
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.Parent = frame
    ApplyStyle(toggle, self.Theme, 10, 1)

    local indicator = GetObject("Frame")
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = default and UDim2.new(0, 28, 0, 0) or UDim2.new(0, 2, 0, 0)
    indicator.BackgroundColor3 = self.Theme.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle
    ApplyStyle(indicator, self.Theme, 10, 0)

    local label = GetObject("TextLabel")
    label.Size = UDim2.new(0, 150, 1, 0)
    label.Position = UDim2.new(0, 60, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

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

function EasyUI:Slider(tab, text, min, max, default, callback)
    local frame = GetObject("Frame")
    frame.Size = UDim2.new(0, 300, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Frame

    local label = GetObject("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = self.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBg = GetObject("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 10)
    sliderBg.Position = UDim2.new(0, 10, 0, 25)
    sliderBg.BackgroundColor3 = self.Theme.Secondary
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    ApplyStyle(sliderBg, self.Theme, 4, 1)

    local fill = GetObject("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    ApplyStyle(fill, self.Theme, 4, 0)

    local knob = GetObject("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = self.Theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    ApplyStyle(knob, self.Theme, 6, 0)

    local value = default
    local dragging = false

    local function update(posX)
        local relative = math.clamp((posX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        value = min + relative * (max - min)
        fill.Size = UDim2.new(relative, 0, 1, 0)
        knob.Position = UDim2.new(relative, -6, 0.5, -6)
        label.Text = text .. ": " .. math.floor(value * 100) / 100
        if callback then callback(value) end
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input.Position.X)
        end
    end)
    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input.Position.X)
        end
    end)

    self:AddToTab(tab, frame, 40)
    return sliderBg, function() return value end
end

function EasyUI:Dropdown(tab, text, options, default, callback)
    local frame = GetObject("Frame")
    frame.Size = UDim2.new(0, 250, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Frame

    local label = GetObject("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = self.Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local dropdownBtn = GetObject("TextButton")
    dropdownBtn.Size = UDim2.new(1, -20, 0, 25)
    dropdownBtn.Position = UDim2.new(0, 10, 0, 20)
    dropdownBtn.BackgroundColor3 = self.Theme.Secondary
    dropdownBtn.Text = default or options[1] or "Select"
    dropdownBtn.TextColor3 = self.Theme.Text
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextSize = 14
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.Parent = frame
    ApplyStyle(dropdownBtn, self.Theme, 6, 1)

    local dropdownList = GetObject("ScrollingFrame")
    dropdownList.Size = UDim2.new(1, -20, 0, 0)
    dropdownList.Position = UDim2.new(0, 10, 0, 45)
    dropdownList.BackgroundColor3 = self.Theme.Secondary
    dropdownList.BorderSizePixel = 0
    dropdownList.Visible = false
    dropdownList.ScrollBarThickness = 4
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
    dropdownList.Parent = frame
    ApplyStyle(dropdownList, self.Theme, 6, 1)

    local selected = default or options[1] or ""

    for i, opt in ipairs(options) do
        local optBtn = GetObject("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 25)
        optBtn.Position = UDim2.new(0, 0, 0, (i-1) * 25)
        optBtn.BackgroundColor3 = self.Theme.Secondary
        optBtn.Text = opt
        optBtn.TextColor3 = self.Theme.Text
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 14
        optBtn.BorderSizePixel = 0
        optBtn.Parent = dropdownList
        ApplyStyle(optBtn, self.Theme, 0, 0)

        optBtn.MouseButton1Click:Connect(function()
            dropdownBtn.Text = opt
            selected = opt
            dropdownList.Visible = false
            dropdownList.Size = UDim2.new(1, -20, 0, 0)
            if callback then callback(opt) end
        end)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        dropdownList.Visible = not dropdownList.Visible
        if dropdownList.Visible then
            dropdownList.Size = UDim2.new(1, -20, 0, math.min(#options * 25, 150))
        else
            dropdownList.Size = UDim2.new(1, -20, 0, 0)
        end
    end)

    self:AddToTab(tab, frame, 40)
    return dropdownBtn, function() return selected end
end

function EasyUI:Textbox(tab, placeholder, text, callback)
    local frame = GetObject("Frame")
    frame.Size = UDim2.new(0, 250, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Frame

    local box = GetObject("TextBox")
    box.Size = UDim2.new(1, -20, 0, 30)
    box.Position = UDim2.new(0, 10, 0, 5)
    box.BackgroundColor3 = self.Theme.Secondary
    box.Text = text or ""
    box.PlaceholderText = placeholder or "Enter text..."
    box.PlaceholderColor3 = self.Theme.Stroke
    box.TextColor3 = self.Theme.Text
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.Parent = frame
    ApplyStyle(box, self.Theme, 6, 1)

    box.FocusLost:Connect(function(enter)
        if enter and callback then
            callback(box.Text)
        end
    end)

    self:AddToTab(tab, frame, 40)
    return box
end

-- ========================== NOTIFICATIONS ==========================
function EasyUI:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local message = config.Message or ""
    local duration = config.Duration or 3
    local theme = self.Theme

    local notif = GetObject("Frame")
    notif.Size = UDim2.new(0, 300, 0, 80)
    notif.Position = UDim2.new(1, -320, 1, -100)
    notif.BackgroundColor3 = theme.Secondary
    notif.BorderSizePixel = 0
    notif.Parent = self.GUI or (self.Main and self.Main.Parent) or game:GetService("CoreGui")
    ApplyStyle(notif, theme, 8, 1)

    local titleLabel = GetObject("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.Accent
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif

    local msgLabel = GetObject("TextLabel")
    msgLabel.Size = UDim2.new(1, -20, 0, 40)
    msgLabel.Position = UDim2.new(0, 10, 0, 35)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = theme.Text
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 14
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = notif

    -- Slide in animation
    notif.Position = UDim2.new(1, -320, 1, -100)
    TweenService:Create(notif, TweenInfo_Default, {Position = UDim2.new(1, -320, 1, -180)}):Play()

    task.wait(duration)
    TweenService:Create(notif, TweenInfo_Fast, {Position = UDim2.new(1, -320, 1, -100)}):Play()
    task.wait(0.3)
    ReturnObject(notif)
end

-- ========================== THEME CHANGE ==========================
function EasyUI:SetTheme(themeName)
    local newTheme = Themes[themeName]
    if not newTheme then return end
    self.Theme = newTheme

    -- Update main window
    self.Main.BackgroundColor3 = newTheme.Secondary
    self.TitleBar.BackgroundColor3 = newTheme.Accent
    self.TitleLabel.TextColor3 = newTheme.Text
    self.CloseBtn.TextColor3 = newTheme.Text
    self.TabContainer.BackgroundColor3 = newTheme.Background
    self.Content.BackgroundColor3 = newTheme.Background

    -- Update all elements (simplified, would need to iterate through all created elements)
    -- For a complete library, we'd store references and update them. We'll keep it simple here.
end

-- Return the library
return EasyUI
