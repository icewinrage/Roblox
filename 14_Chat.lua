local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils
local Theme  = _G.Venture.Theme
local GUI    = _G.Venture.GUI
local Supa   = _G.Venture.Supabase

local Players = Shared.Players
local HttpService = Shared.HttpService
local LocalPlayer = Shared.LocalPlayer
local New = Utils.New
local HttpGet = Utils.HttpGet
local HttpPost = Utils.HttpPost
local ISOTime = Utils.ISOTime

local Chat = {}

local TABLE_URL = Config.SUPABASE_URL .. "/rest/v1/venture_chat"
local HEADERS = {
    ["apikey"] = Config.SUPABASE_KEY,
    ["Authorization"] = "Bearer " .. Config.SUPABASE_KEY,
    ["Content-Type"] = "application/json",
}

Chat.Panel = nil
Chat.Messages = {}
Chat.Container = nil

-- Anonymous name generator
local function GenerateAnonName(name)
    local seed = 0
    for i = 1, #name do
        seed = seed + string.byte(name, i) * i
    end
    -- Deterministic random from seed
    local a = 1103515245
    local c = 12345
    local m = 2147483648
    seed = (a * seed + c) % m

    if name == Config.OWNER_NAME then
        local num = (seed % 900) + 100
        return "DEV_" .. tostring(num)
    else
        local num = (seed % 9000) + 1000
        return "Anon" .. tostring(num)
    end
end

Chat.MyAnonName = GenerateAnonName(LocalPlayer.Name)

local function FormatTime(isoString)
    if not isoString then return "?" end
    local ok, t = pcall(function()
        local y, m, d, h, mi, s = isoString:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
        if not y then return nil end
        return os.time({year=tonumber(y),month=tonumber(m),day=tonumber(d),hour=tonumber(h),min=tonumber(mi),sec=tonumber(s),isdst=false})
    end)
    if not ok or not t then return "?" end
    local diff = os.time() - t
    if diff < 60 then return "now" end
    if diff < 3600 then return math.floor(diff/60).."m" end
    return math.floor(diff/3600).."h"
end

local function FetchMessages()
    local url = TABLE_URL .. "?select=*&order=id.desc&limit=50"
    local res = HttpGet(url, HEADERS)
    if not res then return {} end
    local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
    if ok and type(data) == "table" then
        table.reverse(data)
        return data
    end
    return {}
end

local function SendMessage(text)
    if not text or #text == 0 then return end
    text = text:gsub("[\n\r]", " "):sub(1, 200)
    HttpPost(TABLE_URL, {
        user_id = Supa.MY_UID,
        name = Chat.MyAnonName,
        role = Supa.MY_ROLE,
        message = text,
        created_at = ISOTime(0),
    }, HEADERS)
end

local function BuildMessages()
    if not Chat.Container then return end
    local T = Theme.Get()

    for _, c in ipairs(Chat.Container:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextLabel") then
            c:Destroy()
        end
    end

    local y = 0
    for _, msg in ipairs(Chat.Messages) do
        local isMine = (msg.user_id == Supa.MY_UID)
        local isOwner = (msg.role == "Owner")

        local bubbleBg = isOwner and Color3.fromRGB(60,20,100) or (isMine and Color3.fromRGB(30,60,120) or T.BtnBg)
        local textColor = isOwner and Color3.fromRGB(255,200,255) or T.BtnText

        local bubble = New("Frame", {
            Position = UDim2.new(0,0,0,y),
            Size = UDim2.new(1,-8,0,52),
            BackgroundColor3 = bubbleBg,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            ZIndex = 8,
        }, Chat.Container)
        New("UICorner", {CornerRadius = UDim.new(0,8)}, bubble)
        New("UIStroke", {Color = isOwner and Color3.fromRGB(200,100,255) or T.BtnStroke, Thickness = 1, Transparency = 0.3}, bubble)

        New("TextLabel", {
            Position = UDim2.new(0,8,0,4),
            Size = UDim2.new(1,-60,0,16),
            BackgroundTransparency = 1,
            Text = msg.name or "?",
            TextColor3 = isOwner and Color3.fromRGB(255,180,255) or Color3.fromRGB(180,200,255),
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 9,
        }, bubble)

        New("TextLabel", {
            Position = UDim2.new(1,-60,0,4),
            Size = UDim2.new(0,52,0,16),
            BackgroundTransparency = 1,
            Text = FormatTime(msg.created_at),
            TextColor3 = T.SubText,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 9,
        }, bubble)

        New("TextLabel", {
            Position = UDim2.new(0,8,0,22),
            Size = UDim2.new(1,-16,0,26),
            BackgroundTransparency = 1,
            Text = msg.message or "",
            TextColor3 = textColor,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            ZIndex = 9,
        }, bubble)

        y = y + 58
    end

    Chat.Container.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

local function RefreshMessages()
    local data = FetchMessages()
    Chat.Messages = data
    BuildMessages()
end

function Chat.PopulateTab()
    local panel = GUI.ChatTabPanel
    if not panel then return end
    Chat.Panel = panel

    for _, child in ipairs(panel:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    local T = Theme.Get()

    local inputFrame = New("Frame", {
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,-8,0,44),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ZIndex = 8,
    }, panel)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, inputFrame)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, inputFrame)

    local input = New("TextBox", {
        Position = UDim2.new(0,10,0,8),
        Size = UDim2.new(1,-110,0,28),
        BackgroundColor3 = T.MainBg,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Message as " .. Chat.MyAnonName .. "...",
        PlaceholderColor3 = T.SubText,
        TextColor3 = T.BtnText,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 9,
    }, inputFrame)
    New("UICorner", {CornerRadius = UDim.new(0,8)}, input)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.3}, input)

    local sendBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1,-10,0,8),
        Size = UDim2.fromOffset(90,28),
        BackgroundColor3 = T.TabBgActive,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "Send",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 9,
    }, inputFrame)
    New("UICorner", {CornerRadius = UDim.new(0,8)}, sendBtn)

    local function Submit()
        local text = input.Text
        if text and #text > 0 then
            input.Text = ""
            task.spawn(function()
                SendMessage(text)
                task.wait(0.3)
                RefreshMessages()
            end)
        end
    end

    sendBtn.MouseButton1Click:Connect(Submit)
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then Submit() end
    end)

    local scroll = New("ScrollingFrame", {
        Position = UDim2.new(0,0,0,52),
        Size = UDim2.new(1,-8,1,-60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = T.Accent,
        ZIndex = 8,
    }, panel)
    Chat.Container = scroll

    task.spawn(function()
        RefreshMessages()
    end)

    task.spawn(function()
        while panel.Parent do
            task.wait(5)
            pcall(RefreshMessages)
        end
    end)
end

_G.Venture = _G.Venture or {}
_G.Venture.Chat = Chat

return Chat
