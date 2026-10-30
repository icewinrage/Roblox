local Shared = _G.Venture.Shared local Config = _G.Venture.Config local Utils = 
_G.Venture.Utils local Players = Shared.Players local RunService = 
Shared.RunService local TweenService = Shared.TweenService local HttpService = 
Shared.HttpService local LocalPlayer = Shared.LocalPlayer local Settings = 
Config.Settings local New = Utils.New local Tween = Utils.Tween local HttpPost =
 Utils.HttpPost local HttpGet = Utils.HttpGet local HttpDelete = 
Utils.HttpDelete local ISOTime = Utils.ISOTime local Supa = {}

local TABLE_URL = Config.SUPABASE_URL .. "/rest/v1/" .. Config.SUPABASE_TABLE
local HEADERS = {
    ["apikey"] = Config.SUPABASE_KEY,
    ["Authorization"] = "Bearer " .. Config.SUPABASE_KEY,
    ["Content-Type"] = "application/json",
    ["Prefer"] = "resolution=merge-duplicates",
}

Supa.Users = {}
Supa.BadgeData = {}
Supa.BadgeByPlayer = {}
Supa.MY_UID = Utils.GetUserId()
Supa.MY_NAME = LocalPlayer.Name
Supa.MY_ROLE = (LocalPlayer.Name == Config.OWNER_NAME) and "Owner" or "User"
Supa.MY_JOB = game.JobId

local function SafeMakeBadge(pl, role)
    if not pl or not pl.Parent then return nil end
    local ch = pl.Character
    if not ch then return nil end
    local head = ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
    if not head then return nil end
    local prev = Supa.BadgeByPlayer[pl]
    if prev and prev.Parent then prev:Destroy() end
    Supa.BadgeByPlayer[pl] = nil
    local isOwner = (role == "Owner")
    local Streamer = _G.Venture and _G.Venture.Streamer
    local isStreamer = (pl == LocalPlayer and Streamer and Streamer.Enabled)
    local width = (isOwner or isStreamer) and 150 or 130
    local height = (isOwner or isStreamer) and 32 or 28
    local infoSize = (isOwner or isStreamer) and 9 or 8
    local bg = Instance.new("BillboardGui")
    bg.Name = "VentureBadge"
    bg.Size = UDim2.fromOffset(width, height)
    bg.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
    bg.AlwaysOnTop = true
    bg.LightInfluence = 0
    bg.MaxDistance = 1000
    bg.Adornee = head
    bg.Parent = head
    local container = Instance.new("Frame")
    container.Size = UDim2.fromScale(1, 1)
    container.BackgroundColor3 = (isOwner or isStreamer) and Color3.fromRGB(35, 12, 60) or Color3.fromRGB(25, 12, 50)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = bg
    Instance.new("UICorner", container).CornerRadius = UDim.new(1, 0)
    local grad = Instance.new("UIGradient")
    if isStreamer then
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 100, 30)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 160, 60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 120)),
        })
    else
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, isOwner and Color3.fromRGB(130,50,255) or Color3.fromRGB(90,45,200)),
            ColorSequenceKeypoint.new(0.5, isOwner and Color3.fromRGB(200,100,255) or Color3.fromRGB(150,80,240)),
            ColorSequenceKeypoint.new(1, isOwner and Color3.fromRGB(255,150,255) or Color3.fromRGB(210,110,255)),
        })
    end
    grad.Parent = container
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = (isOwner and "OWNER" or (isStreamer and "STREAMER" or "USER"))
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = infoSize
    label.Parent = container
    Supa.BadgeByPlayer[pl] = bg
    return bg
end

function Supa.SendBeacon()
    local body = {
        user_id = Supa.MY_UID,
        name = Supa.MY_NAME,
        role = Supa.MY_ROLE,
        job_id = Supa.MY_JOB,
        last_seen = ISOTime(0),
    }
    HttpPost(TABLE_URL, body, HEADERS)
end

task.spawn(function()
    while true do
        pcall(Supa.SendBeacon)
        task.wait(15)
    end
end)

task.spawn(function()
    while true do
        task.wait(10)
        pcall(function()
            for _, pl in ipairs(Players:GetPlayers()) do
                local role = (pl.Name == Config.OWNER_NAME) and "Owner" or "User"
                SafeMakeBadge(pl, role)
            end
        end)
    end
end)

_G.Venture = _G.Venture or {}
_G.Venture.Supabase = Supa
return Supa
