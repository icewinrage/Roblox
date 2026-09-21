local Shared = _G.Venture.Shared
local Config = _G.Venture.Config

local TweenService = Shared.TweenService

local Theme = {}

Theme.Registry = {
    Buttons = {},
    Toggles = {},
    Sliders = {},
    Tabs = {},
    Sections = {},
    Dropdowns = {},
    Misc = {},
    MainFrame = nil,
}

function Theme.Register(kind, data)
    if not Theme.Registry[kind] then return end
    table.insert(Theme.Registry[kind], data)
end

function Theme.RegisterMain(mainFrame)
    Theme.Registry.MainFrame = mainFrame
end

function Theme.Get()
    return Config.Themes[Config.Settings.Theme] or Config.Themes.Dark
end

function Theme.Load()
    Config.LoadTheme()
end

function Theme.Save()
    Config.SaveTheme()
end

function Theme.Apply(name, save)
    if name and Config.Themes[name] then
        Config.Settings.Theme = name
    end
    local T = Theme.Get()
    local R = Theme.Registry

    if R.MainFrame then
        pcall(function()
            R.MainFrame.BackgroundColor3 = T.MainBg
            local grad = R.MainFrame:FindFirstChildOfClass("UIGradient")
            if grad then
                grad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, T.MainGradientA),
                    ColorSequenceKeypoint.new(0.5, T.MainGradientB),
                    ColorSequenceKeypoint.new(1, T.MainGradientC),
                })
            end
            for _, c in ipairs(R.MainFrame:GetChildren()) do
                if c:IsA("UIStroke") then c.Color = T.Accent end
            end
        end)
    end

    for _, d in ipairs(R.Buttons) do
        pcall(function()
            d.Btn.BackgroundColor3 = T.BtnBg
            d.Label.TextColor3 = T.BtnText
            if d.Sub then d.Sub.TextColor3 = T.SubText end
            if d.Stroke then d.Stroke.Color = T.BtnStroke end
        end)
    end

    for _, d in ipairs(R.Toggles) do
        pcall(function()
            d.Btn.BackgroundColor3 = T.BtnBg
            d.Label.TextColor3 = T.BtnText
            d.Pill.BackgroundColor3 = d.State and T.ToggleOn or T.ToggleOff
            d.Knob.BackgroundColor3 = T.ToggleKnob
        end)
    end

    for _, d in ipairs(R.Sliders) do
        pcall(function()
            d.Frame.BackgroundColor3 = T.BtnBg
            d.Label.TextColor3 = T.BtnText
            d.Val.TextColor3 = T.TabTextActive
            d.Fill.BackgroundColor3 = T.SliderFill
            d.BarBG.BackgroundColor3 = T.SliderBg
        end)
    end

    for _, d in ipairs(R.Tabs) do
        pcall(function()
            d.Btn.BackgroundColor3 = d.IsActive and T.TabBgActive or T.TabBg
            d.Btn.TextColor3 = d.IsActive and T.TabTextActive or T.TabText
            for _, c in ipairs(d.Btn:GetChildren()) do
                if c:IsA("UIStroke") then
                    c.Color = d.IsActive and T.Accent or T.TabStroke
                    c.Transparency = d.IsActive and 0 or 0.4
                end
            end
        end)
    end

    for _, d in ipairs(R.Sections) do
        pcall(function()
            d.Label.TextColor3 = T.SectionText
        end)
    end

    for _, d in ipairs(R.Dropdowns) do
        pcall(function()
            d.Frame.BackgroundColor3 = T.BtnBg
            d.Label.TextColor3 = T.BtnText
            d.Btn.BackgroundColor3 = T.BtnBgHover
            d.Btn.TextColor3 = T.TabTextActive
        end)
    end

    for _, d in ipairs(R.Misc) do
        pcall(function()
            for _, key in ipairs(d.Keys) do
                if T[key] then d.Obj[key] = T[key] end
            end
        end)
    end

    if save ~= false then Theme.Save() end
end

function Theme.SetActiveTab(index)
    for i, d in ipairs(Theme.Registry.Tabs) do
        d.IsActive = (i == index)
    end
    Theme.Apply(nil, false)
end

function Theme.UpdateToggle(toggleData, state)
    toggleData.State = state
    local T = Theme.Get()
    pcall(function()
        toggleData.Pill.BackgroundColor3 = state and T.ToggleOn or T.ToggleOff
    end)
end

_G.Venture = _G.Venture or {}
_G.Venture.Theme = Theme

return Theme
