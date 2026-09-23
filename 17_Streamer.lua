local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils
local Theme  = _G.Venture.Theme
local GUI    = _G.Venture.GUI

local Players = Shared.Players
local RunService = Shared.RunService
local HttpService = Shared.HttpService
local LocalPlayer = Shared.LocalPlayer
local PlayerGui = Shared.PlayerGui
local IsMobile = Shared.IsMobile
local New = Utils.New
local Tween = Utils.Tween
local Notify = Utils.Notify

local Streamer = {}

Streamer.Enabled = false
Streamer.FakeName = "Streamer"
Streamer.FakeXP = 1000000
Streamer.FakeLevel = 1000
Streamer.FakeMoney = 1000000
Streamer.HideKillFeed = false
Streamer.FixingStats = false

Streamer.Files = {
    CONFIG = "VentureAOT_Streamer.json",
}

function Streamer.Save()
    if not writefile then return end
    local data = {
        Enabled = Streamer.Enabled,
        FakeName = Streamer.FakeName,
        FakeXP = Streamer.FakeXP,
        FakeLevel = Streamer.FakeLevel,
        FakeMoney = Streamer.FakeMoney,
        HideKillFeed = Streamer.HideKillFeed,
    }
    pcall(function()
        writefile(Streamer.Files.CONFIG, HttpService:JSONEncode(data))
    end)
end

function Streamer.Load()
    if not (isfile and readfile) then return end
    if not isfile(Streamer.Files.CONFIG) then return end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(Streamer.Files.CONFIG))
    end)
    if ok and data then
        Streamer.Enabled = data.Enabled or false
        Streamer.FakeName = data.FakeName or "Streamer"
        Streamer.FakeXP = data.FakeXP or 1000000
        Streamer.FakeLevel = data.FakeLevel or 1000
        Streamer.FakeMoney = data.FakeMoney or 1000000
        Streamer.HideKillFeed = data.HideKillFeed or false
    end
end

-- NAME
function Streamer.ApplyName()
    if not Streamer.Enabled then return end
    local name = Streamer.FakeName
    if not name or #name == 0 then return end

    pcall(function()
        LocalPlayer:SetAttribute("LoreName", name)
    end)
    pcall(function()
        LocalPlayer.DisplayName = name
    end)

    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.DisplayName = name
            end)
        end
    end
end

function Streamer.RestoreName()
    pcall(function()
        LocalPlayer:SetAttribute("LoreName", LocalPlayer.Name)
    end)
    pcall(function()
        LocalPlayer.DisplayName = LocalPlayer.Name
    end)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.DisplayName = LocalPlayer.Name
            end)
        end
    end
end

-- KILL FEED
function Streamer.ApplyKillFeed()
    if not Streamer.Enabled or not Streamer.HideKillFeed then return end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local screen = pg:FindFirstChild("Screen")
    if not screen then return end
    local killFeed = screen:FindFirstChild("KillFeed", true)
    if killFeed then
        pcall(function() killFeed:Destroy() end)
    end
end

-- STATS
function Streamer.ApplyStats()
    if not Streamer.Enabled then return end

    local dataReplica = LocalPlayer:FindFirstChild("DataReplica")

    local function findDataReplica()
        if dataReplica then return dataReplica end
        local reps = game:GetService("ReplicatedStorage")
        local found = reps:FindFirstChild("DataReplica", true)
        if found then return found end
        return LocalPlayer:FindFirstChild("DataReplica", true)
    end

    local dr = findDataReplica()
    if dr then
        pcall(function()
            local xp = dr:FindFirstChild("XP")
            if xp and (xp:IsA("NumberValue") or xp:IsA("IntValue")) then
                xp.Value = Streamer.FakeXP
            end
            local lvl = dr:FindFirstChild("Level")
            if lvl and (lvl:IsA("NumberValue") or lvl:IsA("IntValue")) then
                lvl.Value = Streamer.FakeLevel
            end
        end)
    end

    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        pcall(function()
            local money = leaderstats:FindFirstChild("Money")
            if money and (money:IsA("NumberValue") or money:IsA("IntValue")) then
                money.Value = Streamer.FakeMoney
            end
        end)
    end
end

-- LOOP
Streamer.Loop = nil

function Streamer.StartLoop()
    if Streamer.Loop then return end
    Streamer.Loop = RunService.Heartbeat:Connect(function()
        if not Streamer.Enabled then return end
        pcall(Streamer.ApplyStats)
    end)
end

function Streamer.StopLoop()
    if Streamer.Loop then
        Streamer.Loop:Disconnect()
        Streamer.Loop = nil
    end
end

-- Бейдж обновление
function Streamer.RefreshBadge()
    local Supa = _G.Venture.Supabase
    if not Supa then return end
    local ch = LocalPlayer.Character
    if not ch then return end
    local head = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local old = head:FindFirstChild("VentureBadge")
    if old then old:Destroy() end
    -- Заставляем Supabase пересоздать бейдж
    task.wait(0.1)
    if Supa.BadgeByPlayer and Supa.BadgeByPlayer[LocalPlayer] then
        Supa.BadgeByPlayer[LocalPlayer] = nil
    end
    -- Триггерим через force refresh (refreshBadge не экспортируется, но loop в Supa сам подхватит)
end

-- ENABLE / DISABLE
function Streamer.Enable()
    Streamer.Enabled = true
    Streamer.ApplyName()
    Streamer.ApplyStats()
    Streamer.ApplyKillFeed()
    Streamer.StartLoop()
    Streamer.Save()
    Notify("Streamer Mode", "Enabled - Badge: CONTENT CREATOR", 4)
    task.spawn(function()
        task.wait(0.3)
        pcall(Streamer.RefreshBadge)
    end)
end

function Streamer.Disable()
    Streamer.Enabled = false
    Streamer.RestoreName()
    Streamer.ApplyKillFeed()
    Streamer.StopLoop()
    Streamer.Save()
    Notify("Streamer Mode", "Disabled", 4)
    task.spawn(function()
        task.wait(0.3)
        pcall(Streamer.RefreshBadge)
    end)
end

-- UI
function Streamer.PopulateTab()
    local panel = GUI.StreamerTabPanel
    if not panel then return end

    for _, child in ipairs(panel:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    local y = 0
    local T = Theme.Get()

    y = GUI.MakeToggle(panel, "Enable Streamer Mode", y, Streamer.Enabled, function(v)
        if v then Streamer.Enable() else Streamer.Disable() end
    end)

    y = y + 6
    y = GUI.MakeSectionLabel(panel, "PRESETS", y)

    y = GUI.MakeButton(panel, "Streamer Mode", "Set name to Streamer_XXXX", y, function()
        local n = math.random(1000, 9999)
        Streamer.FakeName = "Streamer_" .. n
        Streamer.Save()
        if Streamer.Enabled then Streamer.ApplyName() end
        Notify("Streamer", "Name: " .. Streamer.FakeName, 3)
    end)
    y = GUI.MakeButton(panel, "Viewer Mode", "Set name to Viewer_XXXX", y, function()
        local n = math.random(1000, 9999)
        Streamer.FakeName = "Viewer_" .. n
        Streamer.Save()
        if Streamer.Enabled then Streamer.ApplyName() end
        Notify("Streamer", "Name: " .. Streamer.FakeName, 3)
    end)
    y = GUI.MakeButton(panel, "Guest Mode", "Set name to Guest_XXXX", y, function()
        local n = math.random(1000, 9999)
        Streamer.FakeName = "Guest_" .. n
        Streamer.Save()
        if Streamer.Enabled then Streamer.ApplyName() end
        Notify("Streamer", "Name: " .. Streamer.FakeName, 3)
    end)
    y = GUI.MakeButton(panel, "Anonymous", "Set name to Anon_XXXX", y, function()
        local n = math.random(1000, 9999)
        Streamer.FakeName = "Anon_" .. n
        Streamer.Save()
        if Streamer.Enabled then Streamer.ApplyName() end
        Notify("Streamer", "Name: " .. Streamer.FakeName, 3)
    end)

    y = y + 6
    y = GUI.MakeSectionLabel(panel, "FAKE NAME", y)

    local nameInput = New("TextBox", {
        Position = UDim2.new(0, 0, 0, y),
        Size = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Text = Streamer.FakeName,
        PlaceholderText = "Enter fake name...",
        PlaceholderColor3 = T.SubText,
        TextColor3 = T.BtnText,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 9,
    }, panel)
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, nameInput)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, nameInput)
    y = y + 44

    y = GUI.MakeButton(panel, "Apply Name", "Save and set fake name", y, function()
        Streamer.FakeName = nameInput.Text:sub(1, 32)
        Streamer.Save()
        if Streamer.Enabled then Streamer.ApplyName() end
        Notify("Streamer", "Name set: " .. Streamer.FakeName, 3)
    end)

    y = y + 6
    y = GUI.MakeSectionLabel(panel, "FAKE STATS", y)

    local xpInput = New("TextBox", {
        Position = UDim2.new(0, 0, 0, y),
        Size = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Text = tostring(Streamer.FakeXP),
        PlaceholderText = "XP...",
        TextColor3 = T.BtnText,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 9,
    }, panel)
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, xpInput)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, xpInput)
    y = y + 44

    local levelInput = New("TextBox", {
        Position = UDim2.new(0, 0, 0, y),
        Size = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Text = tostring(Streamer.FakeLevel),
        PlaceholderText = "Level...",
        TextColor3 = T.BtnText,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 9,
    }, panel)
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, levelInput)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, levelInput)
    y = y + 44

    local moneyInput = New("TextBox", {
        Position = UDim2.new(0, 0, 0, y),
        Size = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Text = tostring(Streamer.FakeMoney),
        PlaceholderText = "Money...",
        TextColor3 = T.BtnText,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 9,
    }, panel)
    New("UICorner", {CornerRadius = UDim.new(0, 8)}, moneyInput)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, moneyInput)
    y = y + 44

    y = GUI.MakeButton(panel, "Apply Stats", "Set XP / Level / Money", y, function()
        Streamer.FakeXP = tonumber(xpInput.Text) or 1000000
        Streamer.FakeLevel = tonumber(levelInput.Text) or 1000
        Streamer.FakeMoney = tonumber(moneyInput.Text) or 1000000
        Streamer.Save()
        if Streamer.Enabled then Streamer.ApplyStats() end
        Notify("Streamer", "Stats applied", 3)
    end)

    y = y + 6
    y = GUI.MakeSectionLabel(panel, "HIDE", y)
    y = GUI.MakeToggle(panel, "Hide Kill Feed", y, Streamer.HideKillFeed, function(v)
        Streamer.HideKillFeed = v
        Streamer.Save()
        Streamer.ApplyKillFeed()
    end)

    y = y + 6
    y = GUI.MakeSectionLabel(panel, "INFO", y)
    New("TextLabel", {
        Position = UDim2.new(0, 4, 0, y),
        Size = UDim2.new(1, -8, 0, 130),
        BackgroundTransparency = 1,
        Text = "Streamer Mode hides your identity on screen.\nBadge becomes CONTENT CREATOR.\nChanges are LOCAL only.\nStats are force-kept every frame.\n\nSet any name, any XP, any Level, any Money.",
        TextColor3 = Theme.Get().SubText,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 8,
    }, panel)
    y = y + 140

    panel.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end

-- INIT
function Streamer.Init()
    Streamer.Load()
    if Streamer.Enabled then
        Streamer.ApplyName()
        Streamer.ApplyStats()
        Streamer.StartLoop()
    end

    task.spawn(function()
        while true do
            task.wait(0.5)
            if Streamer.Enabled and Streamer.HideKillFeed then
                pcall(Streamer.ApplyKillFeed)
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Streamer.Enabled then
            Streamer.ApplyName()
            Streamer.ApplyStats()
        end
    end)
end

_G.Venture = _G.Venture or {}
_G.Venture.Streamer = Streamer

return Streamer
