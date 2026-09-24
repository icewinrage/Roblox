local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils
local Funcs  = _G.Venture.Functions
local Theme  = _G.Venture.Theme
local LocalPlayer = Shared.LocalPlayer
local PlayerGui = Shared.PlayerGui
local HttpService = Shared.HttpService
local Notify = Utils.Notify

local FluentUI = {}

FluentUI.Library = nil
FluentUI.Window = nil
FluentUI.Loaded = false
FluentUI.Tabs = {}

local LIB_URL = "https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"

local function httpGet(url)
    if syn and syn.request then
        local ok, res = pcall(syn.request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    if request then
        local ok, res = pcall(request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    if http_request then
        local ok, res = pcall(http_request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    local ok, res = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if ok then return res end
    return nil
end

function FluentUI.LoadLibrary()
    if FluentUI.Library then return FluentUI.Library end

    local code = httpGet(LIB_URL)
    if not code or #code == 0 then
        Notify("Fluent UI", "Failed to fetch library", 5)
        return nil
    end

    local fn, err = loadstring(code)
    if not fn then
        Notify("Fluent UI", "Syntax error: " .. tostring(err), 5)
        return nil
    end

    local ok, result = pcall(fn)
    if not ok or not result then
        Notify("Fluent UI", "Library error: " .. tostring(result), 5)
        return nil
    end

    FluentUI.Library = result
    return result
end

function FluentUI.Build()
    if FluentUI.Loaded then return end

    local Lib = FluentUI.LoadLibrary()
    if not Lib then return end

    local Settings = Config.Settings

    local Window = Lib:Window({
        Title = "Venture AOT",
        Desc = "v1.5 | by __TheDark",
        Icon = 105059922903197,
        Theme = Settings.Theme or "Dark",
        Config = {
            Keybind = Enum.KeyCode.LeftControl,
            Size = UDim2.new(0, 560, 0, 460),
        },
        CloseUIButton = {
            Enabled = true,
            Text = "Close",
        },
    })
    FluentUI.Window = Window

    -- ====== TAB: MAIN ======
    local MainTab = Window:Tab({Title = "Main", Icon = "home"})
    MainTab:Section({Title = "Titan Control"})
    MainTab:Button({
        Title = "Find Nearest Titan",
        Desc = "Lock onto nearest target",
        Callback = function()
            local t = Funcs.GetTitans()
            if #t > 0 then Funcs.StickToTitan(t[1]) end
        end,
    })
    MainTab:Button({
        Title = "Safe Release",
        Desc = "Detach and boost",
        Callback = function()
            Funcs.CleanupStick(true)
            Funcs.State.currentTarget = nil
        end,
    })
    MainTab:Button({
        Title = "Force Reset",
        Desc = "Clear state",
        Callback = function() Funcs.ForceResetState() end,
    })

    -- ====== TAB: TITAN ======
    local TitanTab = Window:Tab({Title = "Titan", Icon = "target"})

    TitanTab:Section({Title = "Hitbox Expander"})
    TitanTab:Toggle({
        Title = "Expand Hitbox",
        Desc = "Multi-part expander",
        Value = Settings.HitboxExpand,
        Callback = function(v)
            Settings.HitboxExpand = v
            if v then Funcs.ApplyHitboxToAll() else Funcs.ResetAllHitboxes() end
        end,
    })
    TitanTab:Slider({
        Title = "Size X",
        Min = 50, Max = 500, Rounding = 0,
        Value = Settings.HitboxSize.X,
        Callback = function(v)
            Settings.HitboxSize = Vector3.new(v, Settings.HitboxSize.Y, Settings.HitboxSize.Z)
            Funcs.ApplyHitboxToAll()
        end,
    })
    TitanTab:Slider({
        Title = "Size Y",
        Min = 50, Max = 500, Rounding = 0,
        Value = Settings.HitboxSize.Y,
        Callback = function(v)
            Settings.HitboxSize = Vector3.new(Settings.HitboxSize.X, v, Settings.HitboxSize.Z)
            Funcs.ApplyHitboxToAll()
        end,
    })
    TitanTab:Slider({
        Title = "Size Z",
        Min = 50, Max = 500, Rounding = 0,
        Value = Settings.HitboxSize.Z,
        Callback = function(v)
            Settings.HitboxSize = Vector3.new(Settings.HitboxSize.X, Settings.HitboxSize.Y, v)
            Funcs.ApplyHitboxToAll()
        end,
    })
    TitanTab:Button({
        Title = "Reset Hitboxes",
        Callback = function() Funcs.ResetAllHitboxes() end,
    })

    TitanTab:Section({Title = "ESP"})
    TitanTab:Toggle({
        Title = "Titan + Refill ESP",
        Value = Settings.ESP,
        Callback = function(v) Settings.ESP = v end,
    })
    TitanTab:Toggle({
        Title = "Player ESP",
        Value = Settings.PlayerESP,
        Callback = function(v) Settings.PlayerESP = v end,
    })
    TitanTab:Toggle({
        Title = "Shifter ESP",
        Value = Settings.ShifterESP,
        Callback = function(v) Settings.ShifterESP = v end,
    })

    TitanTab:Section({Title = "Movement"})
    TitanTab:Toggle({
        Title = "Noclip",
        Value = Settings.Noclip,
        Callback = function(v)
            Settings.Noclip = v
            if v then Funcs.StartNoclip() else Funcs.StopNoclip() end
        end,
    })
    TitanTab:Toggle({
        Title = "FPS Booster",
        Value = Settings.FPSBoosterEnabled,
        Callback = function(v)
            Settings.FPSBoosterEnabled = v
            if v then Funcs.EnableFPSBooster() else Funcs.DisableFPSBooster() end
        end,
    })

    -- ====== TAB: AUTO ======
    local AutoTab = Window:Tab({Title = "Auto", Icon = "zap"})

    AutoTab:Section({Title = "AutoFarm"})
    AutoTab:Toggle({
        Title = "Enable AutoFarm",
        Value = Settings.AutoFarmEnabled,
        Callback = function(v)
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
        end,
    })
    AutoTab:Slider({
        Title = "Orbit Speed",
        Min = 100, Max = 500,
        Value = Settings.AutoFarmOrbitSpeed,
        Callback = function(v) Settings.AutoFarmOrbitSpeed = v end,
    })
    AutoTab:Slider({
        Title = "Hover Height",
        Min = 30, Max = 150,
        Value = Settings.AutoFarmHoverHeight,
        Callback = function(v) Settings.AutoFarmHoverHeight = v end,
    })
    AutoTab:Slider({
        Title = "Orbit Radius",
        Min = 30, Max = 150,
        Value = Settings.AutoFarmOrbitRadius,
        Callback = function(v) Settings.AutoFarmOrbitRadius = v end,
    })
    AutoTab:Slider({
        Title = "Safe Distance",
        Min = 50, Max = 200,
        Value = Settings.AutoFarmSafeDistance,
        Callback = function(v) Settings.AutoFarmSafeDistance = v end,
    })

    AutoTab:Section({Title = "Blade Refill"})
    AutoTab:Button({
        Title = "TP to Refill",
        Desc = "Teleport to closest refill",
        Callback = function()
            local r = Funcs.GetRefills()
            if #r > 0 then Funcs.TeleportToRefill(r[1]) end
        end,
    })
    AutoTab:Toggle({
        Title = "Enable Auto Refill",
        Value = Settings.AutoRefillEnabled,
        Callback = function(v) Settings.AutoRefillEnabled = v end,
    })
    AutoTab:Slider({
        Title = "Blade Threshold",
        Min = 0, Max = 100,
        Value = Settings.AutoBladeRefillThreshold,
        Callback = function(v) Settings.AutoBladeRefillThreshold = v end,
    })

    AutoTab:Section({Title = "Auto Heal"})
    AutoTab:Toggle({
        Title = "Enable Auto Heal",
        Value = Settings.AutoHealEnabled,
        Callback = function(v) Settings.AutoHealEnabled = v end,
    })
    AutoTab:Slider({
        Title = "HP Threshold",
        Min = 10, Max = 90,
        Value = Settings.AutoHealThreshold,
        Callback = function(v) Settings.AutoHealThreshold = v end,
    })
    AutoTab:Button({
        Title = "Heal Now",
        Callback = function() Funcs.TriggerAutoHeal() end,
    })

    -- ====== TAB: STREAMER ======
    local StreamerTab = Window:Tab({Title = "Streamer", Icon = "eye"})
    local Streamer = _G.Venture.Streamer

    StreamerTab:Section({Title = "Streamer Mode"})
    StreamerTab:Toggle({
        Title = "Enable Streamer Mode",
        Desc = "Hides your identity",
        Value = Streamer and Streamer.Enabled or false,
        Callback = function(v)
            if Streamer then
                if v then Streamer.Enable() else Streamer.Disable() end
            end
        end,
    })

    StreamerTab:Section({Title = "Fake Name"})
    StreamerTab:Textbox({
        Title = "Fake Name",
        Placeholder = "Enter fake name...",
        Value = Streamer and Streamer.FakeName or "Streamer",
        Callback = function(text)
            if Streamer then
                Streamer.FakeName = text
                Streamer.Save()
                if Streamer.Enabled then Streamer.ApplyName() end
            end
        end,
    })

    StreamerTab:Section({Title = "Fake Stats"})
    StreamerTab:Textbox({
        Title = "Fake XP",
        Value = tostring(Streamer and Streamer.FakeXP or 1000000),
        Callback = function(text)
            if Streamer then
                Streamer.FakeXP = tonumber(text) or 1000000
                Streamer.Save()
            end
        end,
    })
    StreamerTab:Textbox({
        Title = "Fake Level",
        Value = tostring(Streamer and Streamer.FakeLevel or 1000),
        Callback = function(text)
            if Streamer then
                Streamer.FakeLevel = tonumber(text) or 1000
                Streamer.Save()
            end
        end,
    })
    StreamerTab:Textbox({
        Title = "Fake Money",
        Value = tostring(Streamer and Streamer.FakeMoney or 1000000),
        Callback = function(text)
            if Streamer then
                Streamer.FakeMoney = tonumber(text) or 1000000
                Streamer.Save()
            end
        end,
    })
    StreamerTab:Button({
        Title = "Apply Stats",
        Callback = function()
            if Streamer then
                Streamer.ApplyStats()
                Notify("Streamer", "Stats applied", 3)
            end
        end,
    })

    StreamerTab:Section({Title = "Hide"})
    StreamerTab:Toggle({
        Title = "Hide Kill Feed",
        Value = Streamer and Streamer.HideKillFeed or false,
        Callback = function(v)
            if Streamer then
                Streamer.HideKillFeed = v
                Streamer.Save()
                Streamer.ApplyKillFeed()
            end
        end,
    })

    -- ====== TAB: MISC ======
    local MiscTab = Window:Tab({Title = "Misc", Icon = "settings"})

    MiscTab:Section({Title = "Interface"})
    MiscTab:Dropdown({
        Title = "Theme",
        List = {"Dark", "Purple", "Red", "White"},
        Value = Settings.Theme,
        Callback = function(v)
            Settings.Theme = v
            if Theme then Theme.Apply(v, true) end
        end,
    })

    MiscTab:Section({Title = "Anti-AFK"})
    local AntiAFK = _G.Venture.AntiAFK
    MiscTab:Toggle({
        Title = "Enable Anti-AFK",
        Value = AntiAFK and AntiAFK.Enabled or false,
        Callback = function(v)
            if AntiAFK then
                if v then AntiAFK.Enable() else AntiAFK.Disable() end
            end
        end,
    })
    MiscTab:Dropdown({
        Title = "Anti-AFK Mode",
        List = {"Jump", "Move", "Both"},
        Value = AntiAFK and AntiAFK.Mode or "Jump",
        Callback = function(v)
            if AntiAFK then AntiAFK.Mode = v end
        end,
    })
    MiscTab:Slider({
        Title = "Anti-AFK Interval",
        Min = 5, Max = 60,
        Value = AntiAFK and AntiAFK.Interval or 20,
        Callback = function(v)
            if AntiAFK then AntiAFK.Interval = v end
        end,
    })

    MiscTab:Section({Title = "Server"})
    MiscTab:Button({
        Title = "Rejoin Same Server",
        Callback = function()
            pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
        end,
    })
    MiscTab:Button({
        Title = "Join New Server",
        Callback = function()
            pcall(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId)
            end)
        end,
    })
    MiscTab:Button({
        Title = "Copy Discord Link",
        Desc = "discord.gg/UHCwX78Npc",
        Callback = function()
            if setclipboard then
                setclipboard("discord.gg/UHCwX78Npc")
                Notify("Copied", "Discord link copied", 3)
            elseif toclipboard then
                toclipboard("discord.gg/UHCwX78Npc")
                Notify("Copied", "Discord link copied", 3)
            else
                Notify("No clipboard", "discord.gg/UHCwX78Npc", 5)
            end
        end,
    })

    MiscTab:Section({Title = "Switch Interface"})
    MiscTab:Button({
        Title = "Back to Venture Classic",
        Callback = function()
            local GUI = _G.Venture.GUI
            if GUI and GUI.SwitchInterface then
                GUI.SwitchInterface("classic")
            end
        end,
    })

    FluentUI.Loaded = true
    Notify("Fluent UI", "Interface loaded!", 4)
end

function FluentUI.Destroy()
    if FluentUI.Window then
        pcall(function()
            FluentUI.Window:Close()
        end)
        FluentUI.Window = nil
    end
    FluentUI.Loaded = false
end

function FluentUI.Toggle()
    if FluentUI.Loaded then
        FluentUI.Destroy()
    else
        FluentUI.Build()
    end
end

function FluentUI.Init()
    -- Не запускаем автоматически, только по кнопке
end

_G.Venture = _G.Venture or {}
_G.Venture.FluentUI = FluentUI

return FluentUI
