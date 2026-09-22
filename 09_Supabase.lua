local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils

local Players = Shared.Players
local RunService = Shared.RunService
local TweenService = Shared.TweenService
local HttpService = Shared.HttpService
local LocalPlayer = Shared.LocalPlayer

local Settings = Config.Settings
local New = Utils.New
local Tween = Utils.Tween
local HttpPost = Utils.HttpPost
local HttpGet = Utils.HttpGet
local HttpDelete = Utils.HttpDelete
local ISOTime = Utils.ISOTime

local Supa = {}

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
    local width = isOwner and 150 or 130
    local height = isOwner and 32 or 28
    local infoSize = isOwner and 9 or 8

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
    container.BackgroundColor3 = isOwner and Color3.fromRGB(35, 12, 60) or Color3.fromRGB(25, 12, 50)
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = bg
    Instance.new("UICorner", container).CornerRadius = UDim.new(1, 0)

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, isOwner and Color3.fromRGB(130,50,255) or Color3.fromRGB(90,45,200)),
        ColorSequenceKeypoint.new(0.5, isOwner and Color3.fromRGB(200,100,255) or Color3.fromRGB(150,80,240)),
        ColorSequenceKeypoint.new(1, isOwner and Color3.fromRGB(255,170,255) or Color3.fromRGB(210,130,255)),
    })
    grad.Rotation = 30
    grad.Parent = container

    local shine = Instance.new("Frame")
    shine.Name = "Shine"
    shine.Size = UDim2.new(0.35, 0, 1, 0)
    shine.Position = UDim2.new(-0.5, 0, 0, 0)
    shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shine.BackgroundTransparency = 0.65
    shine.BorderSizePixel = 0
    shine.ZIndex = 4
    shine.Parent = container
    Instance.new("UICorner", shine).CornerRadius = UDim.new(1, 0)

    local shineGrad = Instance.new("UIGradient")
    shineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    shineGrad.Parent = shine

    local stroke = Instance.new("UIStroke")
    stroke.Color = isOwner and Color3.fromRGB(240,180,255) or Color3.fromRGB(200,150,255)
    stroke.Thickness = isOwner and 1.8 or 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = container

    local glow = Instance.new("UIStroke")
    glow.Color = isOwner and Color3.fromRGB(220,130,255) or Color3.fromRGB(170,100,255)
    glow.Thickness = isOwner and 4 or 3
    glow.Transparency = 0.5
    glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glow.Parent = container

    local icon = Instance.new("TextLabel")
    icon.Name = "Icon"
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.Position = UDim2.new(0, isOwner and 8 or 6, 0.5, 0)
    icon.Size = UDim2.fromOffset(isOwner and 16 or 14, isOwner and 16 or 14)
    icon.BackgroundTransparency = 1
    icon.Text = isOwner and "👑" or "⚡"
    icon.TextColor3 = isOwner and Color3.fromRGB(255,220,100) or Color3.fromRGB(230,200,255)
    icon.TextScaled = true
    icon.Font = Enum.Font.GothamBlack
    icon.ZIndex = 5
    icon.Parent = container

    local label = Instance.new("TextLabel")
    label.Name = "Text"
    label.Position = UDim2.new(0, isOwner and 28 or 24, 0, 0)
    label.Size = UDim2.new(1, isOwner and -32 or -28, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = isOwner and "DEVELOPER" or "SCRIPT USER"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(40, 0, 80)
    label.Font = Enum.Font.GothamBlack
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 5
    label.Parent = container

    local info = Instance.new("TextLabel")
    info.Name = "Info"
    info.AnchorPoint = Vector2.new(0.5, 0)
    info.Position = UDim2.new(0.5, 0, 1, 3)
    info.Size = UDim2.fromScale(1.05, 0.55)
    info.BackgroundTransparency = 1
    info.Text = isOwner and ("by " .. pl.Name) or pl.Name
    info.TextColor3 = isOwner and Color3.fromRGB(255,200,255) or Color3.fromRGB(210,180,255)
    info.TextStrokeTransparency = 0.2
    info.TextStrokeColor3 = Color3.fromRGB(30, 0, 50)
    info.Font = Enum.Font.Gotham
    info.TextSize = infoSize
    info.ZIndex = 5
    info.Parent = bg

    Supa.BadgeData[bg] = {
        BaseWidth = width,
        BaseHeight = height,
        BaseInfoSize = infoSize,
        Label = label, Icon = icon, Info = info,
        Head = head, Owner = pl,
    }
    Supa.BadgeByPlayer[pl] = bg

    task.spawn(function()
        while bg.Parent do
            pcall(function()
                TweenService:Create(stroke, TweenInfo.new(0.9), {Transparency = 0.4}):Play()
                TweenService:Create(glow, TweenInfo.new(0.9), {Transparency = 0.85, Thickness = isOwner and 7 or 5}):Play()
            end)
            task.wait(0.9)
            pcall(function()
                TweenService:Create(stroke, TweenInfo.new(0.9), {Transparency = 0}):Play()
                TweenService:Create(glow, TweenInfo.new(0.9), {Transparency = 0.5, Thickness = isOwner and 4 or 3}):Play()
            end)
            task.wait(0.9)
        end
    end)

    if isOwner then
        task.spawn(function()
            while bg.Parent do
                pcall(function()
                    TweenService:Create(icon, TweenInfo.new(0.6), {TextColor3 = Color3.fromRGB(255,255,180)}):Play()
                end)
                task.wait(0.6)
                pcall(function()
                    TweenService:Create(icon, TweenInfo.new(0.6), {TextColor3 = Color3.fromRGB(255,200,60)}):Play()
                end)
                task.wait(0.6)
            end
        end)
    end

    task.spawn(function()
        while bg.Parent do
            pcall(function() shine.Position = UDim2.new(-0.5, 0, 0, 0) end)
            task.wait(2.5)
            pcall(function()
                TweenService:Create(shine, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(1.5, 0, 0, 0)
                }):Play()
            end)
            task.wait(1)
        end
    end)

    return bg
end

local function RemoveBadge(pl)
    if not pl then return end
    local bg = Supa.BadgeByPlayer[pl]
    if bg then
        Supa.BadgeData[bg] = nil
        Supa.BadgeByPlayer[pl] = nil
        if bg.Parent then bg:Destroy() end
    end
end

local function CleanBadgeData()
    for bg, data in pairs(Supa.BadgeData) do
        if not bg or not bg.Parent then
            Supa.BadgeData[bg] = nil
            if data.Owner and Supa.BadgeByPlayer[data.Owner] == bg then
                Supa.BadgeByPlayer[data.Owner] = nil
            end
        end
    end
end

local function RefreshBadge(pl)
    if not pl or not pl.Parent then return end
    if pl == LocalPlayer then
        SafeMakeBadge(pl, Supa.MY_ROLE)
        return
    end
    local data = Supa.Users[pl]
    if data then
        SafeMakeBadge(pl, data.Role)
    else
        RemoveBadge(pl)
    end
end

local function SendBeacon()
    HttpPost(TABLE_URL, {
        user_id = Supa.MY_UID,
        name = Supa.MY_NAME,
        role = Supa.MY_ROLE,
        job_id = Supa.MY_JOB,
        last_seen = ISOTime(0),
    }, HEADERS)
end

local function FetchUsers()
    local cutoff = ISOTime(-Config.TIMEOUT_SECONDS)
    local url = TABLE_URL .. "?job_id=eq." .. Supa.MY_JOB .. "&last_seen=gte." .. cutoff
    local res = HttpGet(url, HEADERS)
    if not res then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
    if ok and type(data) == "table" then return data end
    return nil
end

local function Cleanup()
    local cutoff = ISOTime(-600)
    HttpDelete(TABLE_URL .. "?last_seen=lt." .. cutoff, HEADERS)
end

function Supa.Init()
    Supa.Users[LocalPlayer] = {Role = Supa.MY_ROLE, LastSeen = tick()}
    SafeMakeBadge(LocalPlayer, Supa.MY_ROLE)

    task.spawn(function()
        while true do
            pcall(SendBeacon)
            task.wait(Config.BEACON_INTERVAL)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(Config.FETCH_INTERVAL)
            pcall(function()
                local data = FetchUsers()
                if not data then return end
                local seen = {}
                for _, row in ipairs(data) do
                    if row.name and row.name ~= Supa.MY_NAME then
                        local pl = Players:FindFirstChild(row.name)
                        if pl then
                            local role = row.role or "User"
                            if pl.Name == Config.OWNER_NAME then role = "Owner" end
                            local ex = Supa.Users[pl]
                            if not ex or ex.Role ~= role then
                                Supa.Users[pl] = {Role = role, LastSeen = tick()}
                                RefreshBadge(pl)
                            else
                                ex.LastSeen = tick()
                            end
                            seen[pl] = true
                        end
                    end
                end
                for pl, _ in pairs(Supa.Users) do
                    if pl ~= LocalPlayer and not seen[pl] then
                        Supa.Users[pl] = nil
                        RemoveBadge(pl)
                    end
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(Config.CLEANUP_INTERVAL)
            pcall(Cleanup)
        end
    end)

    RunService.RenderStepped:Connect(function()
        pcall(CleanBadgeData)
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        for bg, data in pairs(Supa.BadgeData) do
            if not bg or not bg.Parent then continue end
            local head = data.Head
            if not head or not head.Parent then
                local pl = data.Owner
                if pl and pl.Character then
                    head = pl.Character:FindFirstChild("Head") or pl.Character:FindFirstChild("HumanoidRootPart")
                    data.Head = head
                    if head then bg.Adornee = head end
                end
            end
            if head and head.Parent then
                local dist = (myRoot.Position - head.Position).Magnitude
                local scale = math.clamp(1 - (dist - 30) / 400, 0.5, 1.0)
                pcall(function()
                    bg.Size = UDim2.fromOffset(
                        math.floor(data.BaseWidth * scale),
                        math.floor(data.BaseHeight * scale)
                    )
                    if data.Info then
                        data.Info.TextSize = math.max(5, math.floor(data.BaseInfoSize * scale * 0.85))
                    end
                end)
            end
        end
    end)

    local function OnCharAdded(pl)
        if not pl then return end
        task.wait(0.5)
        CleanBadgeData()
        if pl == LocalPlayer then
            SafeMakeBadge(pl, Supa.MY_ROLE)
        else
            local data = Supa.Users[pl]
            if data then SafeMakeBadge(pl, data.Role) end
        end
    end

    LocalPlayer.CharacterAdded:Connect(function() OnCharAdded(LocalPlayer) end)
    Players.PlayerAdded:Connect(function(pl)
        pl.CharacterAdded:Connect(function() OnCharAdded(pl) end)
    end)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            pl.CharacterAdded:Connect(function() OnCharAdded(pl) end)
        end
    end
    Players.PlayerRemoving:Connect(function(pl)
        Supa.Users[pl] = nil
        RemoveBadge(pl)
    end)
end

_G.Venture = _G.Venture or {}
_G.Venture.Supabase = Supa

return Supa
