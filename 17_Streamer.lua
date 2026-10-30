local Shared = _G.Venture.Shared local Config = _G.Venture.Config local Utils = 
_G.Venture.Utils local Theme = _G.Venture.Theme local GUI = _G.Venture.GUI local
 Players = Shared.Players local RunService = Shared.RunService local HttpService
 = Shared.HttpService local LocalPlayer = Shared.LocalPlayer local PlayerGui = 
Shared.PlayerGui local IsMobile = Shared.IsMobile local New = Utils.New local 
Tween = Utils.Tween local Notify = Utils.Notify local Streamer = {}

Streamer.Enabled = false
Streamer.FakeName = "Streamer"
Streamer.FakeXP = 1000000
Streamer.FakeLevel = 1000
Streamer.FakeMoney = 1000000
Streamer.HideKillFeed = false
Streamer.FixingStats = false
Streamer.Files = { CONFIG = "VentureAOT_Streamer.json" }

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
    pcall(function() writefile(Streamer.Files.CONFIG, HttpService:JSONEncode(data)) end)
end

function Streamer.Load()
    if not (isfile and readfile) then return end
    if not isfile(Streamer.Files.CONFIG) then return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(Streamer.Files.CONFIG)) end)
    if ok and data then
        Streamer.Enabled = data.Enabled or false
        Streamer.FakeName = data.FakeName or "Streamer"
        Streamer.FakeXP = data.FakeXP or 1000000
        Streamer.FakeLevel = data.FakeLevel or 1000
        Streamer.FakeMoney = data.FakeMoney or 1000000
        Streamer.HideKillFeed = data.HideKillFeed or false
    end
end

Streamer.Load()

-- NAME
function Streamer.ApplyName()
    if not Streamer.Enabled then return end
    local name = Streamer.FakeName
    if not name or #name == 0 then return end
    pcall(function() LocalPlayer:SetAttribute("LoreName", name) end)
    pcall(function() LocalPlayer.DisplayName = name end)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.DisplayName = name end) end
    end
end

function Streamer.RestoreName()
    pcall(function() LocalPlayer:SetAttribute("LoreName", LocalPlayer.Name) end)
    pcall(function() LocalPlayer.DisplayName = LocalPlayer.Name end)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum.DisplayName = LocalPlayer.Name end) end
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
    if killFeed then pcall(function() killFeed:Destroy() end) end
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
        return nil
    end
    dataReplica = dataReplica or findDataReplica()
    if not dataReplica then return end
    local xp = dataReplica:FindFirstChild("XP")
    if xp and (xp:IsA("NumberValue") or xp:IsA("IntValue")) then
        xp.Value = Streamer.FakeXP
    end
    local level = dataReplica:FindFirstChild("Level")
    if level and (level:IsA("NumberValue") or level:IsA("IntValue")) then
        level.Value = Streamer.FakeLevel
    end
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats then
        local money = stats:FindFirstChild("Money")
        if money and (money:IsA("NumberValue") or money:IsA("IntValue")) then
            money.Value = Streamer.FakeMoney
        end
    end
end

-- BADGE
function Streamer.UpdateBadge()
    if _G.Venture.Supabase and _G.Venture.Supabase.BadgeByPlayer then
        local badge = _G.Venture.Supabase.BadgeByPlayer[LocalPlayer]
        if badge and badge.Parent then
            badge:Destroy()
        end
    end
end

-- LOOP
local function StreamerLoop()
    while Streamer.Enabled do
        task.wait(1)
        pcall(Streamer.ApplyName)
        pcall(Streamer.ApplyStats)
        pcall(Streamer.ApplyKillFeed)
        pcall(Streamer.UpdateBadge)
    end
end

function Streamer.Toggle(state)
    if state == nil then state = not Streamer.Enabled end
    Streamer.Enabled = state
    if Streamer.Enabled then
        Streamer.ApplyName()
        Streamer.ApplyStats()
        Streamer.ApplyKillFeed()
        Streamer.UpdateBadge()
        task.spawn(StreamerLoop)
        Notify("Streamer Mode", "Enabled", 3)
    else
        Streamer.RestoreName()
        Streamer.UpdateBadge()
        Notify("Streamer Mode", "Disabled", 3)
    end
    Streamer.Save()
end

_G.Venture = _G.Venture or {}
_G.Venture.Streamer = Streamer
return Streamer
