-- Venture AOT v3.0 - Rayfield Edition (Main.lua)
-- Author: Data Hub Team
-- Xeno / Delta / Solara / Wave / Arceus X / Krnl / Fluxus

local PLACE_ID = 129554597954928
local REPO_USER = "icewinrage"
local REPO_NAME = "Roblox"
local REPO_BRANCH = "main1"

-- ===============================================================
-- PLACE CHECK
-- ===============================================================
if PLACE_ID and game.PlaceId ~= PLACE_ID then
    warn("[Venture] Wrong place. Aborting.")
    return
end

-- ===============================================================
-- EXECUTOR CHECK
-- ===============================================================
if not (loadstring or load) then
    warn("[Venture] Executor doesn't support loadstring.")
    return
end

local function httpGet(url)
    if syn and syn.request then
        local ok, res = pcall(syn.request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    if fluxus and fluxus.request then
        local ok, res = pcall(fluxus.request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    if request then
        local ok, res = pcall(request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    if http_request then
        local ok, res = pcall(http_request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #res > 0 then return res end
    return nil
end

-- ===============================================================
-- LOAD RAYFIELD
-- ===============================================================
local RayfieldOk, Rayfield = pcall(function()
    return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not RayfieldOk or not Rayfield then
    warn("[Venture] Failed to load Rayfield:", Rayfield)
    return
end

-- ===============================================================
-- LOAD FUNCTIONS.LUA
-- ===============================================================
local functionUrl = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/Functions.lua?t=%d",
    REPO_USER, REPO_NAME, REPO_BRANCH, os.time()
)

local funcCode = httpGet(functionUrl)
if not funcCode or #funcCode < 100 then
    warn("[Venture] Failed to fetch Functions.lua")
    return
end

-- BOM strip (Xeno killer)
if funcCode:sub(1, 3) == "\239\187\191" then
    funcCode = funcCode:sub(4)
end

local fn, err = loadstring(funcCode, "@Functions")
if not fn then
    warn("[Venture] Syntax error in Functions.lua:", tostring(err))
    return
end

local ok2, F = pcall(fn)
if not ok2 or not F then
    warn("[Venture] Runtime error in Functions.lua:", tostring(F))
    return
end

_G.Venture = _G.Venture or {}
_G.Venture.F = F

-- Override F.Notify to use Rayfield notifications
F.Notify = function(title, text, dur, kind)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = text,
            Duration = dur or 4,
            Image = 4483362458,
        })
    end)
end

-- ===============================================================
-- WINDOW
-- ===============================================================
local Window = Rayfield:CreateWindow({
    Name = "Venture AOT",
    LoadingTitle = "Venture AOT",
    LoadingSubtitle = "by __TheDark",
    ToggleUIKeybind = "RightShift",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false,
})

local S = F.Settings

-- ===============================================================
-- 1. MAIN
-- ===============================================================
local MainTab = Window:CreateTab("MAIN", 4483362458)

MainTab:CreateSection("Auto Farm")

MainTab:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = S.AutoFarmEnabled or false,
    Flag = "AutoFarmEnabled",
    Callback = function(v) S.AutoFarmEnabled = v end,
})

MainTab:CreateSlider({
    Name = "Orbit Speed",
    Range = { 50, 500 },
    Increment = 5,
    CurrentValue = S.AutoFarmOrbitSpeed or 220,
    Flag = "AutoFarmOrbitSpeed",
    Callback = function(v) S.AutoFarmOrbitSpeed = v end,
})

MainTab:CreateSlider({
    Name = "Hover Height",
    Range = { 10, 200 },
    Increment = 1,
    Suffix = " studs",
    CurrentValue = S.AutoFarmHoverHeight or 70,
    Flag = "AutoFarmHoverHeight",
    Callback = function(v) S.AutoFarmHoverHeight = v end,
})

MainTab:CreateSlider({
    Name = "Orbit Radius",
    Range = { 20, 300 },
    Increment = 5,
    CurrentValue = S.AutoFarmOrbitRadius or 70,
    Flag = "AutoFarmOrbitRadius",
    Callback = function(v) S.AutoFarmOrbitRadius = v end,
})

MainTab:CreateSlider({
    Name = "Safe Distance",
    Range = { 30, 500 },
    Increment = 10,
    Suffix = " studs",
    CurrentValue = S.AutoFarmSafeDistance or 100,
    Flag = "AutoFarmSafeDistance",
    Callback = function(v) S.AutoFarmSafeDistance = v end,
})

MainTab:CreateSlider({
    Name = "Responsiveness",
    Range = { 5, 100 },
    Increment = 1,
    CurrentValue = S.AutoFarmResponsiveness or 20,
    Flag = "AutoFarmResponsiveness",
    Callback = function(v) S.AutoFarmResponsiveness = v end,
})

MainTab:CreateSection("Auto Heal")

MainTab:CreateToggle({
    Name = "Enable Auto Heal",
    CurrentValue = S.AutoHealEnabled or false,
    Flag = "AutoHealEnabled",
    Callback = function(v) S.AutoHealEnabled = v end,
})

MainTab:CreateSlider({
    Name = "HP Threshold",
    Range = { 10, 100 },
    Increment = 5,
    Suffix = "%",
    CurrentValue = S.AutoHealThreshold or 80,
    Flag = "AutoHealThreshold",
    Callback = function(v) S.AutoHealThreshold = v end,
})

MainTab:CreateSection("Hitbox Expander")

MainTab:CreateToggle({
    Name = "Enable Hitbox",
    CurrentValue = S.HitboxExpand or false,
    Flag = "HitboxExpand",
    Callback = function(v)
        S.HitboxExpand = v
        if not v and F.ResetAllHitboxes then F.ResetAllHitboxes() end
    end,
})

MainTab:CreateDropdown({
    Name = "Shape",
    Options = { "Block", "Ball", "Cylinder" },
    CurrentOption = { S.HitboxShape or "Block" },
    Flag = "HitboxShape",
    Callback = function(opts)
        S.HitboxShape = opts[1]
    end,
})

MainTab:CreateSlider({
    Name = "Size X",
    Range = { 5, 500 },
    Increment = 5,
    CurrentValue = S.HitboxSize and S.HitboxSize.X or 300,
    Flag = "HitboxSizeX",
    Callback = function(v)
        S.HitboxSize = Vector3.new(v, S.HitboxSize.Y, S.HitboxSize.Z)
    end,
})

MainTab:CreateSlider({
    Name = "Size Y",
    Range = { 5, 500 },
    Increment = 5,
    CurrentValue = S.HitboxSize and S.HitboxSize.Y or 200,
    Flag = "HitboxSizeY",
    Callback = function(v)
        S.HitboxSize = Vector3.new(S.HitboxSize.X, v, S.HitboxSize.Z)
    end,
})

MainTab:CreateSlider({
    Name = "Size Z",
    Range = { 5, 500 },
    Increment = 5,
    CurrentValue = S.HitboxSize and S.HitboxSize.Z or 300,
    Flag = "HitboxSizeZ",
    Callback = function(v)
        S.HitboxSize = Vector3.new(S.HitboxSize.X, S.HitboxSize.Y, v)
    end,
})

MainTab:CreateLabel("Hitbox Parts")

MainTab:CreateToggle({
    Name = "Nape",
    CurrentValue = S.HitboxParts and S.HitboxParts.Nape or true,
    Flag = "HitboxNape",
    Callback = function(v) S.HitboxParts.Nape = v end,
})

MainTab:CreateToggle({
    Name = "Eyes",
    CurrentValue = S.HitboxParts and S.HitboxParts.Eyes or false,
    Flag = "HitboxEyes",
    Callback = function(v) S.HitboxParts.Eyes = v end,
})

MainTab:CreateToggle({
    Name = "Left Arm",
    CurrentValue = S.HitboxParts and S.HitboxParts.LeftArm or false,
    Flag = "HitboxLeftArm",
    Callback = function(v) S.HitboxParts.LeftArm = v end,
})

MainTab:CreateToggle({
    Name = "Left Leg",
    CurrentValue = S.HitboxParts and S.HitboxParts.LeftLeg or false,
    Flag = "HitboxLeftLeg",
    Callback = function(v) S.HitboxParts.LeftLeg = v end,
})

MainTab:CreateToggle({
    Name = "Right Arm",
    CurrentValue = S.HitboxParts and S.HitboxParts.RightArm or false,
    Flag = "HitboxRightArm",
    Callback = function(v) S.HitboxParts.RightArm = v end,
})

MainTab:CreateToggle({
    Name = "Right Leg",
    CurrentValue = S.HitboxParts and S.HitboxParts.RightLeg or false,
    Flag = "HitboxRightLeg",
    Callback = function(v) S.HitboxParts.RightLeg = v end,
})

MainTab:CreateLabel("Visuals")

MainTab:CreateToggle({
    Name = "Show Visual",
    CurrentValue = S.HitboxShowVisual or false,
    Flag = "HitboxShowVisual",
    Callback = function(v) S.HitboxShowVisual = v end,
})

MainTab:CreateColorPicker({
    Name = "Visual Color",
    Color = S.HitboxVisualColor or Color3.fromRGB(255, 100, 200),
    Flag = "HitboxVisualColor",
    Callback = function(c) S.HitboxVisualColor = c end,
})

MainTab:CreateSlider({
    Name = "Visual Transparency",
    Range = { 0, 1 },
    Increment = 0.05,
    CurrentValue = S.HitboxVisualTransparency or 0.6,
    Flag = "HitboxVisualTransparency",
    Callback = function(v) S.HitboxVisualTransparency = v end,
})

MainTab:CreateSection("Movement & Performance")

MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = S.Noclip or false,
    Flag = "Noclip",
    Callback = function(v)
        S.Noclip = v
        if v and F.StartNoclip then F.StartNoclip() end
        if not v and F.StopNoclip then F.StopNoclip() end
    end,
})

MainTab:CreateToggle({
    Name = "FPS Booster",
    CurrentValue = S.FPSBoosterEnabled or false,
    Flag = "FPSBoosterEnabled",
    Callback = function(v)
        S.FPSBoosterEnabled = v
        if v and F.EnableFPSBooster then F.EnableFPSBooster() end
        if not v and F.DisableFPSBooster then F.DisableFPSBooster() end
    end,
})

MainTab:CreateSection("Quick Actions")

MainTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        if F.RejoinServer then F.RejoinServer() end
    end,
})

MainTab:CreateButton({
    Name = "Join New Server",
    Callback = function()
        if F.JoinNewServer then F.JoinNewServer() end
    end,
})

MainTab:CreateButton({
    Name = "Copy Server ID",
    Callback = function()
        if F.CopyServerId then F.CopyServerId() end
    end,
})

-- ===============================================================
-- 2. ESP
-- ===============================================================
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateSection("Visuals")

ESPTab:CreateToggle({
    Name = "Titan ESP",
    CurrentValue = S.ESP or false,
    Flag = "TitanESP",
    Callback = function(v) S.ESP = v end,
})

ESPTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = S.PlayerESP or false,
    Flag = "PlayerESP",
    Callback = function(v) S.PlayerESP = v end,
})

ESPTab:CreateToggle({
    Name = "Shifter ESP",
    CurrentValue = S.ShifterESP or false,
    Flag = "ShifterESP",
    Callback = function(v) S.ShifterESP = v end,
})

ESPTab:CreateSection("Colors")

ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = S.ESPColor or Color3.fromRGB(255, 60, 60),
    Flag = "ESPColor",
    Callback = function(c) S.ESPColor = c end,
})

ESPTab:CreateColorPicker({
    Name = "Nape Color",
    Color = S.NapeColor or Color3.fromRGB(80, 255, 120),
    Flag = "NapeColor",
    Callback = function(c) S.NapeColor = c end,
})

ESPTab:CreateColorPicker({
    Name = "Target Color",
    Color = S.TargetColor or Color3.fromRGB(255, 210, 60),
    Flag = "TargetColor",
    Callback = function(c) S.TargetColor = c end,
})

-- ===============================================================
-- 3. MISC
-- ===============================================================
local MiscTab = Window:CreateTab("MISC", 4483362458)

MiscTab:CreateSection("Player")

MiscTab:CreateSlider({
    Name = "WalkSpeed",
    Range = { 16, 200 },
    Increment = 2,
    Suffix = " spd",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(v)
        local c = game.Players.LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then
            c.Humanoid.WalkSpeed = v
        end
    end,
})

MiscTab:CreateSlider({
    Name = "JumpPower",
    Range = { 50, 300 },
    Increment = 5,
    Suffix = " jp",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(v)
        local c = game.Players.LocalPlayer.Character
        if c and c:FindFirstChildOfClass("Humanoid") then
            c.Humanoid.JumpPower = v
        end
    end,
})

MiscTab:CreateSection("Anti-AFK")

MiscTab:CreateToggle({
    Name = "Enable Anti-AFK",
    CurrentValue = S.AntiAFKEnabled or false,
    Flag = "AntiAFKEnabled",
    Callback = function(v)
        S.AntiAFKEnabled = v
        if v and F.AntiAFKEnable then F.AntiAFKEnable() end
        if not v and F.AntiAFKDisable then F.AntiAFKDisable() end
    end,
})

MiscTab:CreateDropdown({
    Name = "Mode",
    Options = { "Both", "Jump", "Move" },
    CurrentOption = { S.AntiAFKMode or "Both" },
    Flag = "AntiAFKMode",
    Callback = function(opts)
        S.AntiAFKMode = opts[1]
    end,
})

MiscTab:CreateSlider({
    Name = "Interval",
    Range = { 5, 120 },
    Increment = 1,
    Suffix = " sec",
    CurrentValue = S.AntiAFKInterval or 20,
    Flag = "AntiAFKInterval",
    Callback = function(v) S.AntiAFKInterval = v end,
})

MiscTab:CreateSection("Social")

MiscTab:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        if F.CopyDiscord then F.CopyDiscord() end
    end,
})

-- ===============================================================
-- 4. MOD DETECTOR
-- ===============================================================
local ModTab = Window:CreateTab("MOD DETECTOR", 4483362458)

ModTab:CreateSection("Mod Detector")

ModTab:CreateToggle({
    Name = "Auto-Kick on Mod",
    CurrentValue = S.AutoKickOnMod or false,
    Flag = "AutoKickOnMod",
    Callback = function(v) S.AutoKickOnMod = v end,
})

ModTab:CreateLabel("Mod Group: " .. tostring(S.ModGroupId or "-"))

local ModListLabel = ModTab:CreateLabel("Loading...")

task.spawn(function()
    while task.wait(5) do
        local mods = (F.State and F.State.SecurityState and F.State.SecurityState.ModsInServer) or {}
        local list = {}
        for name, rank in pairs(mods) do
            table.insert(list, name .. " (rank " .. tostring(rank) .. ")")
        end
        if #list > 0 then
            ModListLabel:Set("Moderators:\n- " .. table.concat(list, "\n- "))
        else
            ModListLabel:Set("No moderators in server")
        end
    end
end)

-- ===============================================================
-- 5. STREAMER
-- ===============================================================
local StreamerTab = Window:CreateTab("STREAMER", 4483362458)

StreamerTab:CreateSection("Streamer Mode")

StreamerTab:CreateToggle({
    Name = "Enable Streamer Mode",
    CurrentValue = S.StreamerEnabled or false,
    Flag = "StreamerEnabled",
    Callback = function(v)
        if v and F.StreamerEnable then F.StreamerEnable() end
        if not v and F.StreamerDisable then F.StreamerDisable() end
    end,
})

StreamerTab:CreateToggle({
    Name = "Hide KillFeed",
    CurrentValue = S.StreamerHideKillFeed or true,
    Flag = "StreamerHideKillFeed",
    Callback = function(v) S.StreamerHideKillFeed = v end,
})

StreamerTab:CreateSection("Fake Info")

StreamerTab:CreateInput({
    Name = "Fake Name",
    CurrentValue = S.StreamerFakeName or "Streamer",
    PlaceholderText = "Enter name...",
    RemoveTextAfterFocusLost = false,
    Flag = "StreamerFakeName",
    Callback = function(v) S.StreamerFakeName = v end,
})

StreamerTab:CreateInput({
    Name = "Fake XP",
    CurrentValue = tostring(S.StreamerFakeXP or 1000000),
    PlaceholderText = "XP",
    RemoveTextAfterFocusLost = false,
    Flag = "StreamerFakeXP",
    Callback = function(v) S.StreamerFakeXP = tonumber(v) or 0 end,
})

StreamerTab:CreateInput({
    Name = "Fake Level",
    CurrentValue = tostring(S.StreamerFakeLevel or 1000),
    PlaceholderText = "Level",
    RemoveTextAfterFocusLost = false,
    Flag = "StreamerFakeLevel",
    Callback = function(v) S.StreamerFakeLevel = tonumber(v) or 0 end,
})

StreamerTab:CreateInput({
    Name = "Fake Money",
    CurrentValue = tostring(S.StreamerFakeMoney or 1000000),
    PlaceholderText = "Money",
    RemoveTextAfterFocusLost = false,
    Flag = "StreamerFakeMoney",
    Callback = function(v) S.StreamerFakeMoney = tonumber(v) or 0 end,
})

-- ===============================================================
-- 6. ONLINE
-- ===============================================================
local OnlineTab = Window:CreateTab("ONLINE", 4483362458)

OnlineTab:CreateSection("Players Online (Supabase)")

local OnlineDropdown = OnlineTab:CreateDropdown({
    Name = "Online List",
    Options = { "Loading..." },
    CurrentOption = { "Loading..." },
    Flag = "OnlineList",
    Callback = function(opts) end,
})

local OnlineCount = OnlineTab:CreateLabel("Total online: ...")

local function RefreshOnline()
    if not F.FetchOnlineUsers then
        OnlineCount:Set("Supabase not configured")
        return
    end
    local users = F.FetchOnlineUsers() or {}
    local names = {}
    for _, u in ipairs(users) do
        table.insert(names, (u.name or "?") .. " (" .. (u.role or "User") .. ")")
    end
    if #names == 0 then names = { "Nobody" } end
    OnlineDropdown:Refresh(names)
    OnlineCount:Set("Total online: " .. #users)
end

OnlineTab:CreateButton({
    Name = "Refresh Online List",
    Callback = function()
        RefreshOnline()
        F.Notify("Online", "Refreshed", 3)
    end,
})

task.spawn(function()
    task.wait(2)
    pcall(RefreshOnline)
    while task.wait(15) do
        pcall(RefreshOnline)
    end
end)

-- ===============================================================
-- 7. ANNOUNCE
-- ===============================================================
local AnnounceTab = Window:CreateTab("ANNOUNCE", 4483362458)

AnnounceTab:CreateSection("Announcements (DEV only)")

local AnnounceTitle = "Announcement"
local AnnounceText = ""

AnnounceTab:CreateInput({
    Name = "Title",
    CurrentValue = "Announcement",
    PlaceholderText = "Title",
    RemoveTextAfterFocusLost = false,
    Flag = "AnnounceTitle",
    Callback = function(v) AnnounceTitle = v end,
})

AnnounceTab:CreateInput({
    Name = "Text",
    CurrentValue = "",
    PlaceholderText = "Text...",
    RemoveTextAfterFocusLost = false,
    Flag = "AnnounceText",
    Callback = function(v) AnnounceText = v end,
})

AnnounceTab:CreateButton({
    Name = "Send Announcement",
    Callback = function()
        if F.SendAnnouncement then
            F.SendAnnouncement(AnnounceTitle, AnnounceText)
        end
    end,
})

AnnounceTab:CreateLabel("Only DEV can announce")

-- ===============================================================
-- 8. SETTINGS
-- ===============================================================
local SettingsTab = Window:CreateTab("SETTINGS", 4483362458)

SettingsTab:CreateSection("Config")

SettingsTab:CreateButton({
    Name = "Save Config",
    Callback = function()
        F.Notify("Config", "Saved (Rayfield handles this)", 3)
    end,
})

SettingsTab:CreateButton({
    Name = "Unload Script",
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
        Rayfield:Destroy()
    end,
})

-- ===============================================================
-- INIT DONE
-- ===============================================================
F.Notify("Venture AOT v3.0", "Loaded successfully", 5)

print("[Venture AOT v3.0] Rayfield edition loaded")
