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

-- ОРИГИНАЛЬНЫЙ FLUENT от dawid-scripts
local LIB_URL = "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Release.lua"

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
        Notify("Fluent UI", "Failed to fetch library (size=0)", 5)
        return nil
    end
    if #code < 200 then
        Notify("Fluent UI", "Library too small: " .. #code .. " bytes", 5)
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
        SubTitle = "v1.5 | by __TheDark",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Theme = "Dark",
        Acrylic = true,
        MinimizeKey = Enum.KeyCode.LeftControl,
    })
    FluentUI.Window = Window

    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "home" }),
        Titan = Window:AddTab({ Title = "Titan", Icon = "crosshair" }),
        Auto = Window:AddTab({ Title = "Auto", Icon = "zap" }),
        Streamer = Window:AddTab({ Title = "Streamer", Icon = "eye-off" }),
        Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    }
    FluentUI.Tabs = Tabs

    -- ===== MAIN =====
    local MainGroup = Tabs.Main:AddGroup("Titan Control")
    MainGroup:AddButton({
        Title = "Find Nearest Titan",
        Description = "Lock onto nearest target",
        Callback = function()
            local t = Funcs.GetTitans()
            if #t > 0 then Funcs.StickToTitan(t[1]) end
        end,
    })
    MainGroup:AddButton({
        Title = "Safe Release",
        Description = "Detach and boost",
        Callback = function()
            Funcs.CleanupStick(true)
            Funcs.State.currentTarget = nil
        end,
    })
    MainGroup:AddButton({
        Title = "Force Reset",
        Description = "Clear state",
        Callback = function() Funcs.ForceResetState() end,
    })

    -- ===== TITAN =====
    local HitboxGroup = Tabs.Titan:AddGroup("Hitbox Expander")
    HitboxGroup:AddToggle("HitboxExpand", {
        Title = "Expand Hitbox",
        Default = Settings.HitboxExpand,
        Callback = function(v)
            Settings.HitboxExpand = v
            if v then Funcs.ApplyHitboxToAll() else Funcs.ResetAllHitboxes() end
        end,
    })
    HitboxGroup:AddSlider("HitboxX", {
        Title = "Size X",
        Default = Settings.HitboxSize.X,
        Min = 50, Max = 500, Rounding = 0,
        Callback = function(v)
            Settings.HitboxSize = Vector3.new(v, Settings.HitboxSize.Y, Settings.HitboxSize.Z)
            Funcs.ApplyHitboxToAll()
        end,
    })
    HitboxGroup:AddSlider("HitboxY", {
        Title = "Size Y",
        Default = Settings.HitboxSize.Y,
        Min = 50, Max = 500, Rounding = 0,
        Callback = function(v)
            Settings.HitboxSize = Vector3.new(Settings.HitboxSize.X, v, Settings.HitboxSize.Z)
            Funcs.ApplyHitboxToAll()
        end,
    })
    HitboxGroup:AddSlider("HitboxZ", {
        Title = "Size Z",
        Default = Settings.HitboxSize.Z,
        Min = 50, Max = 500, Rounding = 0,
        Callback = function(v)
            Settings.HitboxSize = Vector3.new(Settings.HitboxSize.X, Settings.HitboxSize.Y, v)
            Funcs.ApplyHitboxToAll()
        end,
    })

    local ESPGroup = Tabs.Titan:AddGroup("ESP")
    ESPGroup:AddToggle("ESP", {
        Title = "Titan + Refill ESP",
        Default = Settings.ESP,
        Callback = function(v) Settings.ESP = v end,
    })
    ESPGroup:AddToggle("PlayerESP", {
        Title = "Player ESP",
        Default = Settings.PlayerESP,
        Callback = function(v) Settings.PlayerESP = v end,
    })

    local MoveGroup = Tabs.Titan:AddGroup("Movement")
    MoveGroup:AddToggle("Noclip", {
        Title = "Noclip",
        Default = Settings.Noclip,
        Callback = function(v)
            Settings.Noclip = v
            if v then Funcs.StartNoclip() else Funcs.StopNoclip() end
        end,
    })
    MoveGroup:AddToggle("FPSBoost", {
        Title = "FPS Booster",
        Default = Settings.FPSBoosterEnabled,
        Callback = function(v)
            Settings.FPSBoosterEnabled = v
            if v then Funcs.EnableFPSBooster() else Funcs.DisableFPSBooster() end
        end,
    })

    -- ===== AUTO =====
    local AutoGroup = Tabs.Auto:AddGroup("AutoFarm")
    AutoGroup:AddToggle("AutoFarm", {
        Title = "Enable AutoFarm",
        Default = Settings.AutoFarmEnabled,
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
    AutoGroup:AddSlider("OrbitSpeed", {
        Title = "Orbit Speed",
        Default = Settings.AutoFarmOrbitSpeed,
        Min = 100, Max = 500,
        Callback = function(v) Settings.AutoFarmOrbitSpeed = v end,
    })
    AutoGroup:AddSlider("HoverHeight", {
        Title = "Hover Height",
        Default = Settings.AutoFarmHoverHeight,
        Min = 30, Max = 150,
        Callback = function(v) Settings.AutoFarmHoverHeight = v end,
    })

    local RefillGroup = Tabs.Auto:AddGroup("Blade Refill")
    RefillGroup:AddButton({
        Title = "TP to Refill",
        Callback = function()
            local r = Funcs.GetRefills()
            if #r > 0 then Funcs.TeleportToRefill(r[1]) end
        end,
    })
    RefillGroup:AddToggle("AutoRefill", {
        Title = "Enable Auto Refill",
        Default = Settings.AutoRefillEnabled,
        Callback = function(v) Settings.AutoRefillEnabled = v end,
    })

    -- ===== STREAMER =====
    local Streamer = _G.Venture.Streamer
    local SGroup = Tabs.Streamer:AddGroup("Streamer Mode")
    SGroup:AddToggle("StreamerMode", {
        Title = "Enable Streamer Mode",
        Default = Streamer and Streamer.Enabled or false,
        Callback = function(v)
            if Streamer then
                if v then Streamer.Enable() else Streamer.Disable() end
            end
        end,
    })
    SGroup:AddInput("FakeName", {
        Title = "Fake Name",
        Default = Streamer and Streamer.FakeName or "Streamer",
        Placeholder = "Enter fake name...",
        Callback = function(text)
            if Streamer then
                Streamer.FakeName = text
                Streamer.Save()
                if Streamer.Enabled then Streamer.ApplyName() end
            end
        end,
    })
    SGroup:AddInput("FakeXP", {
        Title = "Fake XP",
        Default = tostring(Streamer and Streamer.FakeXP or 1000000),
        Callback = function(text)
            if Streamer then
                Streamer.FakeXP = tonumber(text) or 1000000
                Streamer.Save()
            end
        end,
    })
    SGroup:AddInput("FakeLevel", {
        Title = "Fake Level",
        Default = tostring(Streamer and Streamer.FakeLevel or 1000),
        Callback = function(text)
            if Streamer then
                Streamer.FakeLevel = tonumber(text) or 1000
                Streamer.Save()
            end
        end,
    })
    SGroup:AddInput("FakeMoney", {
        Title = "Fake Money",
        Default = tostring(Streamer and Streamer.FakeMoney or 1000000),
        Callback = function(text)
            if Streamer then
                Streamer.FakeMoney = tonumber(text) or 1000000
                Streamer.Save()
            end
        end,
    })
    SGroup:AddToggle("HideKillFeed", {
        Title = "Hide Kill Feed",
        Default = Streamer and Streamer.HideKillFeed or false,
        Callback = function(v)
            if Streamer then
                Streamer.HideKillFeed = v
                Streamer.Save()
                Streamer.ApplyKillFeed()
            end
        end,
    })

    -- ===== MISC =====
    local ThemeGroup = Tabs.Misc:AddGroup("Interface")
    ThemeGroup:AddDropdown("Theme", {
        Title = "Theme",
        Values = {"Dark", "Purple", "Red", "White"},
        Default = Settings.Theme,
        Callback = function(v)
            Settings.Theme = v
            if Theme then Theme.Apply(v, true) end
        end,
    })

    local AFKGroup = Tabs.Misc:AddGroup("Anti-AFK")
    local AntiAFK = _G.Venture.AntiAFK
    AFKGroup:AddToggle("AntiAFK", {
        Title = "Enable Anti-AFK",
        Default = AntiAFK and AntiAFK.Enabled or false,
        Callback = function(v)
            if AntiAFK then
                if v then AntiAFK.Enable() else AntiAFK.Disable() end
            end
        end,
    })
    AFKGroup:AddDropdown("AntiAFKMode", {
        Title = "Mode",
        Values = {"Jump", "Move", "Both"},
        Default = AntiAFK and AntiAFK.Mode or "Jump",
        Callback = function(v)
            if AntiAFK then AntiAFK.Mode = v end
        end,
    })

    local ServerGroup = Tabs.Misc:AddGroup("Server")
    ServerGroup:AddButton({
        Title = "Rejoin Same Server",
        Callback = function()
            pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
        end,
    })
    ServerGroup:AddButton({
        Title = "Join New Server",
        Callback = function()
            pcall(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId)
            end)
        end,
    })
    ServerGroup:AddButton({
        Title = "Copy Discord Link",
        Description = "discord.gg/UHCwX78Npc",
        Callback = function()
            if setclipboard then
                setclipboard("discord.gg/UHCwX78Npc")
                Notify("Copied", "Discord link copied", 3)
            elseif toclipboard then
                toclipboard("discord.gg/UHCwX78Npc")
                Notify("Copied", "Discord link copied", 3)
            end
        end,
    })

    local SwitchGroup = Tabs.Misc:AddGroup("Switch Interface")
    SwitchGroup:AddButton({
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
            FluentUI.Window:Destroy()
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
    -- Не запускаем автоматически
end

_G.Venture = _G.Venture or {}
_G.Venture.FluentUI = FluentUI

return FluentUI
