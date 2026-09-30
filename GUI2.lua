--[[
    ═══════════════════════════════════════════════════════════════════════════
    VENTURE AOT v3.0 — Tab Builder (GUI2.lua)
    ═══════════════════════════════════════════════════════════════════════════
    Создаёт окно и все табы. Использует:
        • _G.Venture.F    — настройки и функции из Functions.lua
        • _G.Venture.GUI  — движок из GUI1.lua
    ═══════════════════════════════════════════════════════════════════════════
--]]

local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer

local F = _G.Venture and _G.Venture.F
local Library = _G.Venture and _G.Venture.GUI

if not Library then
    warn("[Venture GUI2] GUI1.lua not loaded. Aborting.")
    return
end
if not F or not F.Settings then
    warn("[Venture GUI2] Functions.lua not loaded. Aborting.")
    return
end

local S = F.Settings
local ST = F.State or {}

-- ═══════════════════════════════════════════════════════════════
-- CREATE WINDOW
-- ═══════════════════════════════════════════════════════════════
local ui = Library:MakeWindow({
    Title = "VENTURE AOT",
    Subtitle = "by __TheDark  |  " .. (_G.Venture.ExecutorName or "Executor"),
})
_G.Venture.Window = ui

-- ═══════════════════════════════════════════════════════════════
-- 1. MAIN
-- ═══════════════════════════════════════════════════════════════
local MainTab = ui:MakeTab("MAIN")

local AutoFarmSection = ui:MakeSection(MainTab, "🌾 Auto Farm")

ui:MakeToggle(AutoFarmSection, {
    Name = "Enable Auto Farm",
    Default = S.AutoFarmEnabled or false,
    Tooltip = "Автоматически атакует титанов",
    Callback = function(v) S.AutoFarmEnabled = v end,
})

ui:MakeSlider(AutoFarmSection, {
    Name = "Orbit Speed",
    Min = 50, Max = 500, Default = S.AutoFarmOrbitSpeed or 220, Step = 5,
    Tooltip = "Скорость вращения вокруг титана",
    Callback = function(v) S.AutoFarmOrbitSpeed = v end,
})

ui:MakeSlider(AutoFarmSection, {
    Name = "Hover Height",
    Min = 10, Max = 200, Default = S.AutoFarmHoverHeight or 70, Step = 1,
    Suffix = " studs",
    Tooltip = "Высота полёта над землёй",
    Callback = function(v) S.AutoFarmHoverHeight = v end,
})

ui:MakeSlider(AutoFarmSection, {
    Name = "Orbit Radius",
    Min = 20, Max = 300, Default = S.AutoFarmOrbitRadius or 70, Step = 5,
    Suffix = " r",
    Tooltip = "Радиус орбиты",
    Callback = function(v) S.AutoFarmOrbitRadius = v end,
})

ui:MakeSlider(AutoFarmSection, {
    Name = "Safe Distance",
    Min = 30, Max = 500, Default = S.AutoFarmSafeDistance or 100, Step = 10,
    Suffix = " studs",
    Tooltip = "Дистанция уклонения от других титанов",
    Callback = function(v) S.AutoFarmSafeDistance = v end,
})

ui:MakeSlider(AutoFarmSection, {
    Name = "Responsiveness",
    Min = 5, Max = 100, Default = S.AutoFarmResponsiveness or 20, Step = 1,
    Tooltip = "Плавность движения (больше = быстрее)",
    Callback = function(v) S.AutoFarmResponsiveness = v end,
})

-- ░ Auto Heal
local AutoHealSection = ui:MakeSection(MainTab, "💚 Auto Heal")

ui:MakeToggle(AutoHealSection, {
    Name = "Enable Auto Heal",
    Default = S.AutoHealEnabled or false,
    Tooltip = "Телепорт к хилеру при низком HP",
    Callback = function(v) S.AutoHealEnabled = v end,
})

ui:MakeSlider(AutoHealSection, {
    Name = "HP Threshold",
    Min = 10, Max = 100, Default = S.AutoHealThreshold or 80, Step = 5,
    Suffix = "%",
    Tooltip = "Порог срабатывания",
    Callback = function(v) S.AutoHealThreshold = v end,
})

-- ░ Hitbox
local HitboxSection = ui:MakeSection(MainTab, "📦 Hitbox Expander")

ui:MakeToggle(HitboxSection, {
    Name = "Enable Hitbox",
    Default = S.HitboxExpand or false,
    Tooltip = "Расширяет хитбоксы титанов",
    Callback = function(v)
        S.HitboxExpand = v
        if not v and F.ResetAllHitboxes then F.ResetAllHitboxes() end
    end,
})

ui:MakeDropdown(HitboxSection, {
    Name = "Shape",
    Options = {"Block", "Ball", "Cylinder"},
    Default = S.HitboxShape or "Block",
    Callback = function(v) S.HitboxShape = v end,
})

ui:MakeSlider(HitboxSection, {
    Name = "Size X",
    Min = 5, Max = 500, Default = (S.HitboxSize and S.HitboxSize.X) or 300, Step = 5,
    Callback = function(v)
        S.HitboxSize = Vector3.new(v, S.HitboxSize.Y, S.HitboxSize.Z)
    end,
})

ui:MakeSlider(HitboxSection, {
    Name = "Size Y",
    Min = 5, Max = 500, Default = (S.HitboxSize and S.HitboxSize.Y) or 200, Step = 5,
    Callback = function(v)
        S.HitboxSize = Vector3.new(S.HitboxSize.X, v, S.HitboxSize.Z)
    end,
})

ui:MakeSlider(HitboxSection, {
    Name = "Size Z",
    Min = 5, Max = 500, Default = (S.HitboxSize and S.HitboxSize.Z) or 300, Step = 5,
    Callback = function(v)
        S.HitboxSize = Vector3.new(S.HitboxSize.X, S.HitboxSize.Y, v)
    end,
})

ui:MakeLabel(HitboxSection, "🎯 Hitbox Parts")

local function PartToggle(name, key)
    ui:MakeToggle(HitboxSection, {
        Name = name,
        Default = (S.HitboxParts and S.HitboxParts[key]) or false,
        Callback = function(v)
            if S.HitboxParts then S.HitboxParts[key] = v end
        end,
    })
end
PartToggle("Nape (затылок)", "Nape")
PartToggle("Eyes (глаза)", "Eyes")
PartToggle("Left Arm", "LeftArm")
PartToggle("Left Leg", "LeftLeg")
PartToggle("Right Arm", "RightArm")
PartToggle("Right Leg", "RightLeg")

ui:MakeDivider(HitboxSection)

ui:MakeToggle(HitboxSection, {
    Name = "Show Visual",
    Default = S.HitboxShowVisual or false,
    Callback = function(v) S.HitboxShowVisual = v end,
})
ui:MakeColorpicker(HitboxSection, {
    Name = "Visual Color",
    Default = S.HitboxVisualColor or Color3.fromRGB(255, 100, 200),
    Callback = function(c) S.HitboxVisualColor = c end,
})
ui:MakeSlider(HitboxSection, {
    Name = "Visual Transparency",
    Min = 0, Max = 1, Default = S.HitboxVisualTransparency or 0.6, Step = 0.05,
    Callback = function(v) S.HitboxVisualTransparency = v end,
})

-- ░ Movement & Performance
local PerfSection = ui:MakeSection(MainTab, "⚙️ Movement & Performance")

ui:MakeToggle(PerfSection, {
    Name = "Noclip",
    Default = S.Noclip or false,
    Tooltip = "Проходить сквозь стены",
    Callback = function(v)
        S.Noclip = v
        if v and F.StartNoclip then F.StartNoclip() end
        if not v and F.StopNoclip then F.StopNoclip() end
    end,
})

ui:MakeToggle(PerfSection, {
    Name = "FPS Booster",
    Default = S.FPSBoosterEnabled or false,
    Tooltip = "Отключает эффекты для повышения FPS",
    Callback = function(v)
        S.FPSBoosterEnabled = v
        if v and F.EnableFPSBooster then F.EnableFPSBooster() end
        if not v and F.DisableFPSBooster then F.DisableFPSBooster() end
    end,
})

-- ░ Quick Actions
local QuickSection = ui:MakeSection(MainTab, "🛠️ Quick Actions")

ui:MakeButton(QuickSection, {
    Name = "Rejoin Server", Subtext = "Переподключиться",
    Callback = function() if F.RejoinServer then F.RejoinServer() end end,
})
ui:MakeButton(QuickSection, {
    Name = "Join New Server", Subtext = "Случайный сервер",
    Callback = function() if F.JoinNewServer then F.JoinNewServer() end end,
})
ui:MakeButton(QuickSection, {
    Name = "Copy Server ID",
    Callback = function() if F.CopyServerId then F.CopyServerId() end end,
})

-- ═══════════════════════════════════════════════════════════════
-- 2. ESP
-- ═══════════════════════════════════════════════════════════════
local ESPTab = ui:MakeTab("ESP")
local ESPSection = ui:MakeSection(ESPTab, "👁️ Visuals")

ui:MakeToggle(ESPSection, {
    Name = "Titan ESP",
    Default = S.ESP or false,
    Callback = function(v) S.ESP = v end,
})
ui:MakeToggle(ESPSection, {
    Name = "Player ESP",
    Default = S.PlayerESP or false,
    Callback = function(v) S.PlayerESP = v end,
})
ui:MakeToggle(ESPSection, {
    Name = "Shifter ESP",
    Default = S.ShifterESP or false,
    Callback = function(v) S.ShifterESP = v end,
})

ui:MakeDivider(ESPSection)
ui:MakeLabel(ESPSection, "🎨 Цвета")

ui:MakeColorpicker(ESPSection, {
    Name = "ESP Color",
    Default = S.ESPColor or Color3.fromRGB(255, 60, 60),
    Callback = function(c) S.ESPColor = c end,
})
ui:MakeColorpicker(ESPSection, {
    Name = "Nape Color",
    Default = S.NapeColor or Color3.fromRGB(80, 255, 120),
    Callback = function(c) S.NapeColor = c end,
})
ui:MakeColorpicker(ESPSection, {
    Name = "Target Color",
    Default = S.TargetColor or Color3.fromRGB(255, 210, 60),
    Callback = function(c) S.TargetColor = c end,
})

-- ═══════════════════════════════════════════════════════════════
-- 3. MISC
-- ═══════════════════════════════════════════════════════════════
local MiscTab = ui:MakeTab("MISC")

local PlayerSection = ui:MakeSection(MiscTab, "🏃 Player")

ui:MakeSlider(PlayerSection, {
    Name = "WalkSpeed",
    Min = 16, Max = 200, Default = 16, Step = 2,
    Suffix = " spd",
    Callback = function(v)
        local c = LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then
            c.Humanoid.WalkSpeed = v
        end
    end,
})

ui:MakeSlider(PlayerSection, {
    Name = "JumpPower",
    Min = 50, Max = 300, Default = 50, Step = 5,
    Suffix = " jp",
    Callback = function(v)
        local c = LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then
            c.Humanoid.JumpPower = v
        end
    end,
})

local AntiAFKSection = ui:MakeSection(MiscTab, "💤 Anti-AFK")

ui:MakeToggle(AntiAFKSection, {
    Name = "Enable Anti-AFK",
    Default = S.AntiAFKEnabled or false,
    Callback = function(v)
        S.AntiAFKEnabled = v
        if v and F.AntiAFKEnable then F.AntiAFKEnable() end
        if not v and F.AntiAFKDisable then F.AntiAFKDisable() end
    end,
})
ui:MakeDropdown(AntiAFKSection, {
    Name = "Mode",
    Options = {"Both", "Jump", "Move"},
    Default = S.AntiAFKMode or "Both",
    Callback = function(v) S.AntiAFKMode = v end,
})
ui:MakeSlider(AntiAFKSection, {
    Name = "Interval",
    Min = 5, Max = 120, Default = S.AntiAFKInterval or 20, Step = 1,
    Suffix = " sec",
    Callback = function(v) S.AntiAFKInterval = v end,
})

local SocialSection = ui:MakeSection(MiscTab, "🌐 Social")

ui:MakeButton(SocialSection, {
    Name = "Copy Discord Invite",
    Subtext = "discord.gg/UHCwX78Npc",
    Callback = function() if F.CopyDiscord then F.CopyDiscord() end end,
})

-- ═══════════════════════════════════════════════════════════════
-- 4. MOD DETECTOR
-- ═══════════════════════════════════════════════════════════════
local ModTab = ui:MakeTab("MOD DETECTOR")
local ModSection = ui:MakeSection(ModTab, "🛡️ Mod Detector")

ui:MakeToggle(ModSection, {
    Name = "Auto-Kick on Mod",
    Default = S.AutoKickOnMod or false,
    Tooltip = "Автоматически переподключиться при обнаружении модератора",
    Callback = function(v) S.AutoKickOnMod = v end,
})

ui:MakeLabel(ModSection, "Mod Group: " .. tostring(S.ModGroupId or "—"))
ui:MakeDivider(ModSection)
ui:MakeLabel(ModSection, "📋 Список модераторов в сервере:")

local ModListLabel = ui:MakeLabel(ModSection, "Загрузка...")

task.spawn(function()
    while true do
        task.wait(5)
        local mods = (ST.SecurityState and ST.SecurityState.ModsInServer) or {}
        local list = {}
        for name, rank in pairs(mods) do
            table.insert(list, name .. " (rank " .. tostring(rank) .. ")")
        end
        if #list > 0 then
            ModListLabel:Set("• " .. table.concat(list, "\n• "))
        else
            ModListLabel:Set("Нет модераторов в сервере ✅")
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- 5. STREAMER
-- ═══════════════════════════════════════════════════════════════
local StreamerTab = ui:MakeTab("STREAMER")
local StreamerSection = ui:MakeSection(StreamerTab, "🎥 Streamer Mode")

ui:MakeToggle(StreamerSection, {
    Name = "Enable Streamer Mode",
    Default = S.StreamerEnabled or false,
    Tooltip = "Скрывает настоящий ник, статы и KillFeed",
    Callback = function(v)
        if v and F.StreamerEnable then F.StreamerEnable() end
        if not v and F.StreamerDisable then F.StreamerDisable() end
    end,
})

ui:MakeToggle(StreamerSection, {
    Name = "Hide KillFeed",
    Default = S.StreamerHideKillFeed or false,
    Callback = function(v) S.StreamerHideKillFeed = v end,
})

ui:MakeDivider(StreamerSection)
ui:MakeLabel(StreamerSection, "🎭 Fake Info")

ui:MakeTextbox(StreamerSection, {
    Name = "Fake Name",
    Default = S.StreamerFakeName or "Streamer",
    Placeholder = "Введи имя...",
    Callback = function(v) S.StreamerFakeName = v end,
})
ui:MakeTextbox(StreamerSection, {
    Name = "Fake XP",
    Default = tostring(S.StreamerFakeXP or 1000000),
    Callback = function(v) S.StreamerFakeXP = tonumber(v) or 0 end,
})
ui:MakeTextbox(StreamerSection, {
    Name = "Fake Level",
    Default = tostring(S.StreamerFakeLevel or 1000),
    Callback = function(v) S.StreamerFakeLevel = tonumber(v) or 0 end,
})
ui:MakeTextbox(StreamerSection, {
    Name = "Fake Money",
    Default = tostring(S.StreamerFakeMoney or 1000000),
    Callback = function(v) S.StreamerFakeMoney = tonumber(v) or 0 end,
})

-- ═══════════════════════════════════════════════════════════════
-- 6. ONLINE
-- ═══════════════════════════════════════════════════════════════
local OnlineTab = ui:MakeTab("ONLINE")
local OnlineSection = ui:MakeSection(OnlineTab, "👥 Игроки онлайн (Supabase)")

local OnlineDropdown = ui:MakeDropdown(OnlineSection, {
    Name = "Список онлайн",
    Options = {"Загрузка..."},
    Default = "Загрузка...",
})
local OnlineCount = ui:MakeLabel(OnlineSection, "Всего онлайн: ...")

local function RefreshOnline()
    if not F.FetchOnlineUsers then
        OnlineCount:Set("Supabase не настроен")
        return
    end
    local users = F.FetchOnlineUsers() or {}
    local names = {}
    for _, u in ipairs(users) do
        table.insert(names, (u.name or "?") .. " (" .. (u.role or "User") .. ")")
    end
    if #names == 0 then names = {"Никого нет"} end
    OnlineDropdown:SetOptions(names)
    OnlineCount:Set("Всего онлайн: " .. #users)
end

ui:MakeButton(OnlineSection, {
    Name = "🔄 Refresh Online List",
    Callback = function()
        RefreshOnline()
        ui:Notify({ Title = "Online", Content = "Обновлено", Type = "success" })
    end,
})

task.spawn(function()
    task.wait(2)
    pcall(RefreshOnline)
    while true do
        task.wait(15)
        pcall(RefreshOnline)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- 7. ANNOUNCE
-- ═══════════════════════════════════════════════════════════════
local AnnounceTab = ui:MakeTab("ANNOUNCE")
local AnnounceSection = ui:MakeSection(AnnounceTab, "📢 Объявления (DEV only)")

local AnnounceTitle = "Announcement"
local AnnounceText  = ""

ui:MakeTextbox(AnnounceSection, {
    Name = "Title",
    Default = "Announcement",
    Placeholder = "Заголовок",
    Callback = function(v) AnnounceTitle = v end,
})
ui:MakeTextbox(AnnounceSection, {
    Name = "Text",
    Default = "",
    Placeholder = "Текст объявления...",
    Callback = function(v) AnnounceText = v end,
})
ui:MakeButton(AnnounceSection, {
    Name = "📤 Send Announcement",
    Subtext = "Отправить всем игрокам скрипта",
    Callback = function()
        if F.SendAnnouncement then
            F.SendAnnouncement(AnnounceTitle, AnnounceText)
        end
    end,
})
ui:MakeDivider(AnnounceSection)
ui:MakeLabel(AnnounceSection, "⚠️ Только владелец скрипта может отправлять")

-- ═══════════════════════════════════════════════════════════════
-- 8. SETTINGS
-- ═══════════════════════════════════════════════════════════════
local SettingsTab = ui:MakeTab("SETTINGS")
local SettingsSection = ui:MakeSection(SettingsTab, "⚙️ Настройки")

ui:MakeDropdown(SettingsSection, {
    Name = "Тема",
    Options = {"Dark", "Purple", "Red", "White", "Ocean"},
    Default = Library.Config.Theme or "Dark",
    Callback = function(v) ui:SetTheme(v) end,
})

ui:MakeKeybind(SettingsSection, {
    Name = "Toggle Keybind",
    Default = Library.Config.Keybind or "RightShift",
    Callback = function(v)
        Library.Config.Keybind = v
        Library.ToggleKey = Enum.KeyCode[v] or Enum.KeyCode.RightShift
    end,
})

ui:MakeToggle(SettingsSection, {
    Name = "Watermark",
    Default = Library.Config.Watermark ~= false,
    Callback = function(v)
        Library.WatermarkVisible = v
        Library.Config.Watermark = v
    end,
})

ui:MakeToggle(SettingsSection, {
    Name = "Animations",
    Default = Library.Config.Animations ~= false,
    Callback = function(v)
        Library.Animations = v
        Library.Config.Animations = v
    end,
})

ui:MakeDivider(SettingsSection)

-- Config section (встроенный билдер из GUI1)
Library:BuildConfigSection(SettingsTab)

-- Unload
ui:MakeButton(SettingsSection, {
    Name = "❌ Unload Script",
    Danger = true,
    Tooltip = "Полностью выгрузить скрипт и вернуть игру в норму",
    Callback = function()
        pcall(function()
            S.HitboxExpand = false
            S.Noclip = false
            S.FPSBoosterEnabled = false
            S.AutoFarmEnabled = false
            S.AutoHealEnabled = false
            S.AntiAFKEnabled = false
            if F.ResetAllHitboxes then F.ResetAllHitboxes() end
            if F.StopNoclip then F.StopNoclip() end
            if F.DisableFPSBooster then F.DisableFPSBooster() end
            if F.CleanupFarm then F.CleanupFarm() end
            if F.StopAntiGrab then F.StopAntiGrab() end
        end)
        if ui.Destroy then ui:Destroy() end
        warn("[Venture] Script unloaded.")
    end,
})

-- ═══════════════════════════════════════════════════════════════
-- READY
-- ═══════════════════════════════════════════════════════════════
ui:Notify({
    Title = "Venture AOT v3.0",
    Content = "Готов к работе! Нажми " .. (Library.Config.Keybind or "RightShift") .. " чтобы скрыть.",
    Duration = 6,
    Type = "success",
})

print("[Venture GUI2] Tabs created: MAIN, ESP, MISC, MOD DETECTOR, STREAMER, ONLINE, ANNOUNCE, SETTINGS")

return ui
