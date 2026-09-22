local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils
local Theme  = _G.Venture.Theme
local GUI    = _G.Venture.GUI
local Supa   = _G.Venture.Supabase

local Players = Shared.Players
local HttpService = Shared.HttpService
local TeleportService = Shared.TeleportService
local LocalPlayer = Shared.LocalPlayer
local New = Utils.New
local HttpGet = Utils.HttpGet
local ISOTime = Utils.ISOTime
local Notify = Utils.Notify

local OnlineTab = {}

local TABLE_URL = Config.SUPABASE_URL .. "/rest/v1/" .. Config.SUPABASE_TABLE
local HEADERS = {
    ["apikey"] = Config.SUPABASE_KEY,
    ["Authorization"] = "Bearer " .. Config.SUPABASE_KEY,
}

OnlineTab.Cards = {}
OnlineTab.CachedUsers = {}

local ThumbCache = {}

local function GetAvatarUrl(userId)
    if ThumbCache[userId] then return ThumbCache[userId] end
    local url = ""
    pcall(function()
        local ok, res = pcall(function()
            return Players:GetUserThumbnailAsync(
                userId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)
        if ok and res then url = res end
    end)
    ThumbCache[userId] = url
    return url
end

local function FetchAllOnline()
    local cutoff = ISOTime(-60)
    local url = TABLE_URL .. "?last_seen=gte." .. cutoff .. "&order=last_seen.desc"
    local res = HttpGet(url, HEADERS)
    if not res then return {} end
    local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
    if ok and type(data) == "table" then return data end
    return {}
end

local function FormatTimeAgo(isoString)
    if not isoString then return "?" end
    local ok, t = pcall(function()
        local year, month, day, hour, min, sec = isoString:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
        if not year then return nil end
        return os.time({
            year = tonumber(year), month = tonumber(month), day = tonumber(day),
            hour = tonumber(hour), min = tonumber(min), sec = tonumber(sec),
            isdst = false,
        })
    end)
    if not ok or not t then return "?" end
    local diff = os.time() - t
    if diff < 0 then diff = 0 end
    if diff < 60 then return diff .. "s" end
    if diff < 3600 then return math.floor(diff/60) .. "m" end
    return math.floor(diff/3600) .. "h"
end

local function MakeCard(parent, y, row)
    local T = Theme.Get()
    local cardHeight = 64

    local card = New("Frame", {
        Position = UDim2.new(0,0,0,y),
        Size = UDim2.new(1,-8,0,cardHeight),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, card)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, card)

    local avatarFrame = New("Frame", {
        Position = UDim2.new(0,10,0,10),
        Size = UDim2.fromOffset(44,44),
        BackgroundColor3 = Color3.fromRGB(20,20,30),
        BorderSizePixel = 0,
        ZIndex = 9,
    }, card)
    New("UICorner", {CornerRadius = UDim.new(1,0)}, avatarFrame)

    local avatar = New("ImageLabel", {
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        Image = "",
        ZIndex = 10,
    }, avatarFrame)
    New("UICorner", {CornerRadius = UDim.new(1,0)}, avatar)

    task.spawn(function()
        local userId = nil
        pcall(function()
            local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(row.name) end)
            if ok and id then userId = id end
        end)
        if userId then
            local url = GetAvatarUrl(userId)
            if url and #url > 0 then
                pcall(function() avatar.Image = url end)
            end
        end
    end)

    local roleTag = (row.role == "Owner") and "[DEV] " or ""
    New("TextLabel", {
        Position = UDim2.new(0,64,0,8),
        Size = UDim2.new(1,-160,0,20),
        BackgroundTransparency = 1,
        Text = roleTag .. row.name,
        TextColor3 = (row.role == "Owner") and Color3.fromRGB(255,180,255) or T.BtnText,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9,
    }, card)

    local infoText = "seen " .. FormatTimeAgo(row.last_seen) .. " ago"
    if row.place_id then
        infoText = infoText .. "  |  place " .. tostring(row.place_id)
    end
    New("TextLabel", {
        Position = UDim2.new(0,64,0,30),
        Size = UDim2.new(1,-160,0,16),
        BackgroundTransparency = 1,
        Text = infoText,
        TextColor3 = T.SubText,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9,
    }, card)

    local isMe = (row.name == LocalPlayer.Name)
    local sameJob = (row.job_id == game.JobId)
    local samePlace = (tostring(row.place_id or "") == tostring(game.PlaceId))

    local btnText = "JOIN"
    local btnColor = Color3.fromRGB(60,140,60)
    if isMe then
        btnText = "YOU"
        btnColor = Color3.fromRGB(40,40,60)
    elseif sameJob then
        btnText = "HERE"
        btnColor = Color3.fromRGB(80,80,120)
    elseif not samePlace then
        btnText = "OTHER"
        btnColor = Color3.fromRGB(100,60,60)
    end

    local joinBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-10,0.5,0),
        Size = UDim2.fromOffset(80,32),
        BackgroundColor3 = btnColor,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = btnText,
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 9,
    }, card)
    New("UICorner", {CornerRadius = UDim.new(0,8)}, joinBtn)

    if not isMe and not sameJob then
        joinBtn.MouseButton1Click:Connect(function()
            if not row.job_id or #row.job_id == 0 then
                Notify("Can't join", "No server ID", 4)
                return
            end
            if not samePlace then
                Notify("Different game", "User is in another place", 5)
                return
            end
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, row.job_id, LocalPlayer)
            end)
        end)
    end

    return card, cardHeight + 6
end

local function RebuildList()
    local panel = OnlineTab.Panel
    if not panel then return end

    for _, c in ipairs(OnlineTab.Cards) do
        if c then c:Destroy() end
    end
    OnlineTab.Cards = {}

    for _, child in ipairs(panel:GetChildren()) do
        if child.Name ~= "OnlineHeader" then
            if child:IsA("Frame") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end

    local data = OnlineTab.CachedUsers
    local y = 60

    if #data == 0 then
        local empty = New("TextLabel", {
            Position = UDim2.new(0,4,0,y),
            Size = UDim2.new(1,-8,0,40),
            BackgroundTransparency = 1,
            Text = "Nobody online right now.",
            TextColor3 = Theme.Get().SubText,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 8,
        }, panel)
        table.insert(OnlineTab.Cards, empty)
        y = y + 46
    else
        for _, row in ipairs(data) do
            local card, h = MakeCard(panel, y, row)
            table.insert(OnlineTab.Cards, card)
            y = y + h
        end
    end

    panel.CanvasSize = UDim2.new(0,0,0,y+20)
end

local function UpdateList()
    local data = FetchAllOnline()
    OnlineTab.CachedUsers = data
    RebuildList()
end

function OnlineTab.PopulateTab()
    local panel = GUI.OnlineTabPanel
    if not panel then return end

    -- ONLY FOR SCRIPT DEV
    if Supa.MY_ROLE ~= "Owner" then
        for _, child in ipairs(panel:GetChildren()) do
            if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                child:Destroy()
            end
        end
        New("TextLabel", {
            Position = UDim2.new(0,4,0,20),
            Size = UDim2.new(1,-8,0,80),
            BackgroundTransparency = 1,
            Text = "This tab is only available for SCRIPT DEV.\n\nUse CHAT tab to talk to other users.",
            TextColor3 = Theme.Get().SubText,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            ZIndex = 8,
        }, panel)
        panel.CanvasSize = UDim2.new(0,0,0,110)
        return
    end

    OnlineTab.Panel = panel

    for _, child in ipairs(panel:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    local T = Theme.Get()

    local header = New("Frame", {
        Name = "OnlineHeader",
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,-8,0,50),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 8,
    }, panel)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, header)

    New("TextLabel", {
        Position = UDim2.new(0,16,0,6),
        Size = UDim2.new(1,-32,0,20),
        BackgroundTransparency = 1,
        Text = "VENTURE ONLINE",
        TextColor3 = T.TabTextActive,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9,
    }, header)

    local headerCount = New("TextLabel", {
        Position = UDim2.new(0,16,0,26),
        Size = UDim2.new(1,-32,0,16),
        BackgroundTransparency = 1,
        Text = "Loading...",
        TextColor3 = T.SubText,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 9,
    }, header)

    local refreshBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-10,0.5,0),
        Size = UDim2.fromOffset(70,30),
        BackgroundColor3 = T.BtnBgHover,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "Refresh",
        TextColor3 = T.TabTextActive,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        ZIndex = 9,
    }, header)
    New("UICorner", {CornerRadius = UDim.new(0,8)}, refreshBtn)
    refreshBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            UpdateList()
            headerCount.Text = "Total: " .. #OnlineTab.CachedUsers .. " users online"
        end)
    end)

    task.spawn(function()
        UpdateList()
        headerCount.Text = "Total: " .. #OnlineTab.CachedUsers .. " users online"
    end)

    task.spawn(function()
        while panel.Parent do
            task.wait(10)
            pcall(function()
                UpdateList()
                headerCount.Text = "Total: " .. #OnlineTab.CachedUsers .. " users online"
            end)
        end
    end)
end

_G.Venture = _G.Venture or {}
_G.Venture.OnlineTab = OnlineTab

return OnlineTab
