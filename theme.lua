--// Venture | 2_Theme.lua
local HttpService = game:GetService("HttpService")

local Theme = {}

Theme.Themes = {
    Dark = {
        Name = "Dark",
        MainBg = Color3.fromRGB(10, 12, 20),
        MainGradientA = Color3.fromRGB(24, 24, 42),
        MainGradientB = Color3.fromRGB(11, 13, 22),
        MainGradientC = Color3.fromRGB(7, 8, 14),
        Accent = Color3.fromRGB(125, 92, 255),
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
    },
    Purple = {
        Name = "Purple",
        MainBg = Color3.fromRGB(22, 8, 40),
        MainGradientA = Color3.fromRGB(50, 20, 80),
        MainGradientB = Color3.fromRGB(28, 12, 48),
        MainGradientC = Color3.fromRGB(15, 6, 30),
        Accent = Color3.fromRGB(200, 100, 255),
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
    },
    Red = {
        Name = "Red",
        MainBg = Color3.fromRGB(25, 5, 5),
        MainGradientA = Color3.fromRGB(60, 15, 15),
        MainGradientB = Color3.fromRGB(35, 8, 8),
        MainGradientC = Color3.fromRGB(20, 3, 3),
        Accent = Color3.fromRGB(255, 60, 60),
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
    },
    White = {
        Name = "White",
        MainBg = Color3.fromRGB(235, 235, 240),
        MainGradientA = Color3.fromRGB(255, 255, 255),
        MainGradientB = Color3.fromRGB(240, 240, 245),
        MainGradientC = Color3.fromRGB(225, 225, 232),
        Accent = Color3.fromRGB(80, 90, 220),
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
    }
}

-- Реестр элементов GUI для смены темы
Theme.Registry = {
    Buttons = {},   -- {btn, stroke, label, sub}
    Toggles = {},   -- {btn, pill, knob, label, state}
    Sliders = {},   -- {frame, fill, barBG, label, val}
    Tabs = {},      -- {btn, isActive}
    Sections = {},  -- {label}
    Dropdowns = {}, -- {frame, label, btn}
    Misc = {},      -- {obj, keys}
}

function Theme.Register(kind, data)
    if not Theme.Registry[kind] then return end
    table.insert(Theme.Registry[kind], data)
end

function Theme.Get()
    return Theme.Themes[Config.Settings.Theme] or Theme.Themes.Dark
end

function Theme.Load()
    if not (isfile and readfile) then return end
    if not isfile("VentureAOT_Theme.json") then return end
    local s, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile("VentureAOT_Theme.json"))
    end)
    if s and data and data.Theme and Theme.Themes[data.Theme] then
        Config.Settings.Theme = data.Theme
    end
end

function Theme.Save()
    if not writefile then return end
    pcall(function()
        writefile("VentureAOT_Theme.json", game:GetService("HttpService"):JSONEncode({Theme = Config.Settings.Theme}))
    end)
end

function Theme.Apply(name, save)
    if name and Theme.Themes[name] then
        Config.Settings.Theme = name
    end
    local T = Theme.Get()
    local R = Theme.Registry
    local TweenService = game:GetService("TweenService")

    for _, d in ipairs(R.Buttons) do
        d.Btn.BackgroundColor3 = T.BtnBg
        d.Label.TextColor3 = T.BtnText
        if d.Sub then d.Sub.TextColor3 = T.SubText end
        if d.Stroke then d.Stroke.Color = T.BtnStroke end
    end
    for _, d in ipairs(R.Toggles) do
        d.Btn.BackgroundColor3 = T.BtnBg
        d.Label.TextColor3 = T.BtnText
        d.Pill.BackgroundColor3 = d.State and T.ToggleOn or T.ToggleOff
        d.Knob.BackgroundColor3 = T.ToggleKnob
    end
    for _, d in ipairs(R.Sliders) do
        d.Frame.BackgroundColor3 = T.BtnBg
        d.Label.TextColor3 = T.BtnText
        d.Val.TextColor3 = T.TabTextActive
        d.Fill.BackgroundColor3 = T.SliderFill
        d.BarBG.BackgroundColor3 = T.SliderBg
    end
    for _, d in ipairs(R.Tabs) do
        d.Btn.BackgroundColor3 = d.IsActive and T.TabBgActive or T.TabBg
        d.Btn.TextColor3 = d.IsActive and T.TabTextActive or T.TabText
        for _, c in ipairs(d.Btn:GetChildren()) do
            if c:IsA("UIStroke") then c.Color = d.IsActive and T.Accent or T.TabStroke end
        end
    end
    for _, d in ipairs(R.Sections) do
        d.Label.TextColor3 = T.SectionText
    end
    for _, d in ipairs(R.Dropdowns) do
        d.Frame.BackgroundColor3 = T.BtnBg
        d.Label.TextColor3 = T.BtnText
        d.Btn.BackgroundColor3 = T.BtnBgHover
        d.Btn.TextColor3 = T.TabTextActive
    end
    for _, d in ipairs(R.Misc) do
        for _, key in ipairs(d.Keys) do
            pcall(function() d.Obj[key] = T[key] end)
        end
    end

    -- Main
    pcall(function()
        if _G.VentureMain then
            local M = _G.VentureMain
            M.BackgroundColor3 = T.MainBg
            local grad = M:FindFirstChildOfClass("UIGradient")
            if grad then
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, T.MainGradientA),
                    ColorSequenceKeypoint.new(0.5, T.MainGradientB),
                    ColorSequenceKeypoint.new(1, T.MainGradientC),
                })
            end
        end
    end)

    if save ~= false then Theme.Save() end
end

return Theme
