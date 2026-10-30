local Shared = _G.Venture.Shared local Config = _G.Venture.Config local Utils = 
_G.Venture.Utils local Theme = _G.Venture.Theme local GUI = _G.Venture.GUI local
 Supa = _G.Venture.Supabase local Players = Shared.Players local HttpService = 
Shared.HttpService local TeleportService = Shared.TeleportService local 
LocalPlayer = Shared.LocalPlayer local New = Utils.New local HttpGet = 
Utils.HttpGet local ISOTime = Utils.ISOTime local Notify = Utils.Notify local 
OnlineTab = {}

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
            return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and res then url = res end
    end)
    ThumbCache[userId] = url
    return url
end

local function FetchAllOnline()
    local cutoff = ISOTime(-60)
    local url = TABLE_URL .. "?last_seen=gte." .. cutoff .. "&order=last_seen.desc"
    local res = HttpGet(url, HEADERS, true)
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
            hour = tonumber(hour), min = tonumber(min), sec = tonumber(sec), isdst = false,
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
        Position = UDim2.new(0,0,0,y), Size = UDim2.new(1,-8,0,cardHeight),
        BackgroundColor3 = T.BtnBg, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, card)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, card)
    local avatarFrame = New("Frame", {
        Position = UDim2.new(0,10,0,10), Size = UDim2.fromOffset(44,44),
        BackgroundColor3 = Color3.fromRGB(20,20,30), BorderSizePixel = 0, ZIndex = 9,
    }, card)
    New("UICorner", {CornerRadius = UDim.new(1,0)}, avatarFrame)
    local avatarImg = New("ImageLabel", {
        Size = UDim2.fromScale(1,1), BackgroundTransparency = 1,
        Image = GetAvatarUrl(row.user_id), ZIndex = 10,
    }, avatarFrame)
    New("UICorner", {CornerRadius = UDim.new(1,0)}, avatarImg)
    local nameLabel = New("TextLabel", {
        Position = UDim2.new(0,64,0,10), Size = UDim2.new(1,-140,0,20),
        BackgroundTransparency = 1, Text = row.name or "Unknown",
        TextColor3 = T.Text, Font = Enum.Font.GothamBold, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, card)
    local roleLabel = New("TextLabel", {
        Position = UDim2.new(0,64,0,32), Size = UDim2.new(1,-140,0,16),
        BackgroundTransparency = 1, Text = row.role or "User",
        TextColor3 = T.SubText, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, card)
    local timeLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,-10,0,10),
        Size = UDim2.new(0,60,0,20), BackgroundTransparency = 1,
        Text = FormatTimeAgo(row.last_seen), TextColor3 = T.SubText,
        Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 9,
    }, card)
    return cardHeight + 8
end

function OnlineTab.Refresh()
    if not GUI.OnlinePanel then return end
    for _, child in ipairs(GUI.OnlinePanel:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    local users = FetchAllOnline()
    local y = 0
    for _, row in ipairs(users) do
        y = y + MakeCard(GUI.OnlinePanel, y, row)
    end
    if #users == 0 then
        New("TextLabel", {
            Size = UDim2.new(1,0,0,30), BackgroundTransparency = 1,
            Text = "No one online", TextColor3 = Theme.Get().SubText,
            Font = Enum.Font.Gotham, TextSize = 12, ZIndex = 8,
        }, GUI.OnlinePanel)
    end
end

task.spawn(function()
    task.wait(5)
    OnlineTab.Refresh()
    while true do
        task.wait(30)
        pcall(OnlineTab.Refresh)
    end
end)

_G.Venture = _G.Venture or {}
_G.Venture.OnlineTab = OnlineTab
return OnlineTab
