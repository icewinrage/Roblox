local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils
local Theme  = _G.Venture.Theme
local GUI    = _G.Venture.GUI
local Supa   = _G.Venture.Supabase

local Players = Shared.Players
local HttpService = Shared.HttpService
local TweenService = Shared.TweenService
local LocalPlayer = Shared.LocalPlayer
local PlayerGui = Shared.PlayerGui
local New = Utils.New
local HttpGet = Utils.HttpGet
local HttpPost = Utils.HttpPost

local Announce = {}

local TABLE_URL = Config.SUPABASE_URL .. "/rest/v1/venture_announcements"
local HEADERS = {
    ["apikey"] = Config.SUPABASE_KEY,
    ["Authorization"] = "Bearer " .. Config.SUPABASE_KEY,
    ["Content-Type"] = "application/json",
}

Announce.LastSeenId = 0
Announce.ActiveBanner = nil

local function FetchLatest()
    local url = TABLE_URL .. "?select=*&order=id.desc&limit=1"
    local res = HttpGet(url, HEADERS)
    if not res then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
    if ok and type(data) == "table" and #data > 0 then return data[1] end
    return nil
end

local function ShowBanner(title, text, author)
    if Announce.ActiveBanner and Announce.ActiveBanner.Parent then
        Announce.ActiveBanner:Destroy()
    end

    local gui = New("ScreenGui", {
        Name = "VentureAnnounce",
        ResetOnSpawn = false,
        DisplayOrder = 2147483000,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)
    Announce.ActiveBanner = gui

    local bg = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, -100),
        Size = UDim2.new(0.7, 0, 0, 100),
        BackgroundColor3 = Color3.fromRGB(20, 5, 45),
        BorderSizePixel = 0,
        ZIndex = 1,
    }, gui)
    New("UICorner", {CornerRadius = UDim.new(0, 14)}, bg)
    local stroke = New("UIStroke", {Color = Color3.fromRGB(200, 100, 255), Thickness = 2.5}, bg)
    local grad = New("UIGradient", {Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 30, 160)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 10, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 30, 160)),
    }), Rotation = 0}, bg)

    local header = New("TextLabel", {
        Position = UDim2.new(0, 16, 0, 8),
        Size = UDim2.new(1, -32, 0, 22),
        BackgroundTransparency = 1,
        Text = "📢 ANNOUNCEMENT",
        TextColor3 = Color3.fromRGB(255, 220, 255),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    }, bg)

    local titleLabel = New("TextLabel", {
        Position = UDim2.new(0, 16, 0, 30),
        Size = UDim2.new(1, -32, 0, 22),
        BackgroundTransparency = 1,
        Text = title or "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        Font = Enum.Font.GothamBlack,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    }, bg)

    local textLabel = New("TextLabel", {
        Position = UDim2.new(0, 16, 0, 54),
        Size = UDim2.new(1, -32, 0, 32),
        BackgroundTransparency = 1,
        Text = text or "",
        TextColor3 = Color3.fromRGB(230, 200, 255),
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 2,
    }, bg)

    local authorLabel = New("TextLabel", {
        Position = UDim2.new(0, 16, 0, 88),
        Size = UDim2.new(1, -32, 0, 12),
        BackgroundTransparency = 1,
        Text = "by " .. (author or "?"),
        TextColor3 = Color3.fromRGB(200, 150, 255),
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 2,
    }, bg)

    TweenService:Create(bg, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, 0, 0, 20)}):Play()

    task.spawn(function()
        task.wait(8)
        local fadeOut = TweenService:Create(bg, TweenInfo.new(0.4), {Position = UDim2.new(0.5, 0, 0, -120)})
        fadeOut:Play()
        fadeOut.Completed:Wait()
        if gui and gui.Parent then gui:Destroy() end
    end)
end

local function CheckAnnouncements()
    local latest = FetchLatest()
    if not latest then return end
    if latest.id and latest.id > Announce.LastSeenId then
        Announce.LastSeenId = latest.id
        if latest.author ~= LocalPlayer.Name then
            ShowBanner(latest.title, latest.text, latest.author)
        end
    end
end

function Announce.PopulateTab()
    local panel = GUI.AnnounceTabPanel
    if not panel then return end

    for _, child in ipairs(panel:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    local T = Theme.Get()

    -- Только для владельца
    if Supa.MY_ROLE ~= "Owner" then
        New("TextLabel", {
            Position = UDim2.new(0,4,0,0),
            Size = UDim2.new(1,-8,0,60),
            BackgroundTransparency = 1,
            Text = "Only SCRIPT DEV can make announcements.",
            TextColor3 = T.SubText,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            ZIndex = 8,
        }, panel)
        panel.CanvasSize = UDim2.new(0,0,0,80)
        return
    end

    local y = 0
    y = GUI.MakeSectionLabel(panel, "GLOBAL ANNOUNCEMENT", y)
    New("TextLabel", {
        Position = UDim2.new(0,4,0,y),
        Size = UDim2.new(1,-8,0,40),
        BackgroundTransparency = 1,
        Text = "Broadcast a message to ALL script users\nin every server worldwide.",
        TextColor3 = T.SubText,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 8,
    }, panel)
    y = y + 48

    -- Title input
    local titleInput = New("TextBox", {
        Position = UDim2.new(0,0,0,y),
        Size = UDim2.new(1,-8,0,36),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Announcement title...",
        PlaceholderColor3 = T.SubText,
        TextColor3 = T.BtnText,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 9,
    }, panel)
    New("UICorner", {CornerRadius = UDim.new(0,8)}, titleInput)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, titleInput)
    y = y + 44

    -- Text input
    local textInput = New("TextBox", {
        Position = UDim2.new(0,0,0,y),
        Size = UDim2.new(1,-8,0,80),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Announcement message...",
        PlaceholderColor3 = T.SubText,
        TextColor3 = T.BtnText,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 9,
    }, panel)
    New("UICorner", {CornerRadius = UDim.new(0,8)}, textInput)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, textInput)
    y = y + 88

    y = GUI.MakeButton(panel, "Send Announcement", "Broadcast to all servers", y, function()
        local title = titleInput.Text
        local text = textInput.Text
        if not title or #title == 0 then return end
        if not text or #text == 0 then return end

        HttpPost(TABLE_URL, {
            author = LocalPlayer.Name,
            title = title:sub(1, 60),
            text = text:sub(1, 200),
        }, HEADERS)

        titleInput.Text = ""
        textInput.Text = ""
        ShowBanner(title, text, LocalPlayer.Name)
    end)

    y = GUI.MakeSectionLabel(panel, "PREVIEW", y)
    y = GUI.MakeButton(panel, "Test Banner", "Show on your screen", y, function()
        ShowBanner("Test Title", "This is a test announcement", LocalPlayer.Name)
    end)

    panel.CanvasSize = UDim2.new(0,0,0,y+20)
end

function Announce.Init()
    task.spawn(function()
        task.wait(2)
        CheckAnnouncements()
    end)
    task.spawn(function()
        while true do
            task.wait(10)
            pcall(CheckAnnouncements)
        end
    end)
end

_G.Venture = _G.Venture or {}
_G.Venture.Announce = Announce

return Announce
