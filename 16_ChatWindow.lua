local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils
local Theme  = _G.Venture.Theme
local GUI    = _G.Venture.GUI
local Supa   = _G.Venture.Supabase

local Players = Shared.Players
local HttpService = Shared.HttpService
local UserInputService = Shared.UserInputService
local TweenService = Shared.TweenService
local LocalPlayer = Shared.LocalPlayer
local PlayerGui = Shared.PlayerGui
local IsMobile = Shared.IsMobile
local New = Utils.New
local Tween = Utils.Tween
local HttpGet = Utils.HttpGet
local HttpPost = Utils.HttpPost
local HttpDelete = Utils.HttpDelete
local ISOTime = Utils.ISOTime
local Notify = Utils.Notify

local ChatWindow = {}

local TABLE_URL = Config.SUPABASE_URL .. "/rest/v1/venture_chat"
local PINNED_URL = Config.SUPABASE_URL .. "/rest/v1/venture_pinned"
local HEADERS = {
    ["apikey"] = Config.SUPABASE_KEY,
    ["Authorization"] = "Bearer " .. Config.SUPABASE_KEY,
    ["Content-Type"] = "application/json",
}

-- ============================================================
-- STATE
-- ============================================================
ChatWindow.Visible = false
ChatWindow.Messages = {}
ChatWindow.PinnedMessage = nil
ChatWindow.UnreadCount = 0
ChatWindow.LastMessageId = 0
ChatWindow.Container = nil
ChatWindow.Gui = nil
ChatWindow.WhisperTarget = nil

-- Anonymous name generator (same as 14_Chat.lua)
local function GenerateAnonName(name)
    local seed = 0
    for i = 1, #name do
        seed = seed + string.byte(name, i) * i
    end
    local a = 1103515245
    local c = 12345
    local m = 2147483648
    seed = (a * seed + c) % m

    if name == Config.OWNER_NAME then
        return "DEV_" .. tostring((seed % 900) + 100)
    else
        return "Anon" .. tostring((seed % 9000) + 1000)
    end
end

ChatWindow.MyAnonName = GenerateAnonName(LocalPlayer.Name)

-- ============================================================
-- HELPERS
-- ============================================================
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

local function FetchMessages(limit)
    limit = limit or 100
    local url = TABLE_URL .. "?select=*&order=id.desc&limit=" .. limit
    local res = HttpGet(url, HEADERS)
    if not res then return {} end
    local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
    if ok and type(data) == "table" then
        table.reverse(data)
        return data
    end
    return {}
end

local function FetchPinned()
    local url = PINNED_URL .. "?select=*&order=id.desc&limit=1"
    local res = HttpGet(url, HEADERS)
    if not res then return nil end
    local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
    if ok and type(data) == "table" and #data > 0 then return data[1] end
    return nil
end

local function SendMessage(text, target)
    if not text or #text == 0 then return end
    text = text:gsub("[\n\r]", " "):sub(1, 200)
    local payload = {
        user_id = Supa.MY_UID,
        name = ChatWindow.MyAnonName,
        role = Supa.MY_ROLE,
        message = text,
        created_at = ISOTime(0),
    }
    if target and #target > 0 then
        payload.target = target
    end
    HttpPost(TABLE_URL, payload, HEADERS)
end

local function ClearChat()
    if Supa.MY_ROLE ~= "Owner" then
        Notify("Denied", "Only SCRIPT DEV can clear chat", 4)
        return
    end
    local url = TABLE_URL .. "?id=gte.0"
    HttpDelete(url, HEADERS)
    ChatWindow.Messages = {}
    ChatWindow.LastMessageId = 0
    if ChatWindow.Container then
        for _, c in ipairs(ChatWindow.Container:GetChildren()) do
            if c:IsA("Frame") or c:IsA("TextLabel") then
                c:Destroy()
            end
        end
    end
    Notify("Chat", "Cleared", 3)
end

local function PinMessage(text)
    if Supa.MY_ROLE ~= "Owner" then
        Notify("Denied", "Only SCRIPT DEV can pin", 4)
        return
    end
    if not text or #text == 0 then return end
    HttpPost(PINNED_URL, {
        author = "DEV",
        text = text:sub(1, 200),
    }, HEADERS)
    ChatWindow.PinnedMessage = {text = text, author = "DEV"}
    if ChatWindow.UpdatePinned then ChatWindow.UpdatePinned() end
    Notify("Pinned", "Message pinned", 3)
end

local function UnpinMessage()
    if Supa.MY_ROLE ~= "Owner" then return end
    HttpDelete(PINNED_URL .. "?id=gte.0", HEADERS)
    ChatWindow.PinnedMessage = nil
    if ChatWindow.UpdatePinned then ChatWindow.UpdatePinned() end
    Notify("Unpinned", "Message removed", 3)
end

-- ============================================================
-- BUILD UI
-- ============================================================
local function BuildBubbles()
    if not ChatWindow.Container then return end
    local T = Theme.Get()

    for _, c in ipairs(ChatWindow.Container:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextLabel") then
            c:Destroy()
        end
    end

    local y = 0
    for _, msg in ipairs(ChatWindow.Messages) do
        local isMine = (msg.user_id == Supa.MY_UID)
        local isOwner = (msg.role == "Owner")
        local isWhisper = (msg.target and #msg.target > 0)

        local bubbleBg = T.BtnBg
        if isOwner then
            bubbleBg = Color3.fromRGB(60,20,100)
        elseif isWhisper then
            bubbleBg = Color3.fromRGB(80,40,20)
        elseif isMine then
            bubbleBg = Color3.fromRGB(30,60,120)
        end

        local textColor = isOwner and Color3.fromRGB(255,200,255) or T.BtnText

        local bubble = New("Frame", {
            Position = UDim2.new(0,0,0,y),
            Size = UDim2.new(1,-8,0,52),
            BackgroundColor3 = bubbleBg,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            ZIndex = 8,
        }, ChatWindow.Container)
        New("UICorner", {CornerRadius = UDim.new(0,8)}, bubble)
        New("UIStroke", {
            Color = isOwner and Color3.fromRGB(200,100,255) 
                or (isWhisper and Color3.fromRGB(255,180,60) or T.BtnStroke),
            Thickness = 1, Transparency = 0.3
        }, bubble)

        local nameText = msg.name or "?"
        if isWhisper then
            nameText = "🔒 " .. nameText .. " → " .. tostring(msg.target)
        end

        New("TextLabel", {
            Position = UDim2.new(0,8,0,4),
            Size = UDim2.new(1,-60,0,16),
            BackgroundTransparency = 1,
            Text = nameText,
            TextColor3 = isOwner and Color3.fromRGB(255,180,255) 
                or (isWhisper and Color3.fromRGB(255,220,150) or Color3.fromRGB(180,200,255)),
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

        -- Right-click / long-press for whisper + pin
        bubble.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                -- Right click — whisper
                if msg.name and msg.name ~= ChatWindow.MyAnonName then
                    ChatWindow.WhisperTarget = msg.name
                    if ChatWindow.UpdateWhisper then ChatWindow.UpdateWhisper() end
                end
            end
        end)

        y = y + 58
    end

    ChatWindow.Container.CanvasSize = UDim2.new(0, 0, 0, y + 10)

    -- Скролл вниз
    task.wait(0.05)
    pcall(function()
        ChatWindow.Container.CanvasPosition = Vector2.new(0, math.max(0, y - ChatWindow.Container.AbsoluteSize.Y + 60))
    end)
end

local function RefreshMessages()
    local data = FetchMessages(100)
    local prevLast = ChatWindow.LastMessageId

    ChatWindow.Messages = data
    if #data > 0 then
        ChatWindow.LastMessageId = data[#data].id or 0
    end

    -- Уведомление если окно закрыто
    if not ChatWindow.Visible and prevLast > 0 and ChatWindow.LastMessageId > prevLast then
        local newCount = 0
        for _, m in ipairs(data) do
            if m.id and m.id > prevLast and m.user_id ~= Supa.MY_UID then
                newCount = newCount + 1
            end
        end
        if newCount > 0 then
            ChatWindow.UnreadCount = ChatWindow.UnreadCount + newCount
            if ChatWindow.UpdateBadge then ChatWindow.UpdateBadge() end
            Notify("💬 Chat", newCount .. " new message(s)", 4)
        end
    end

    if ChatWindow.Visible then
        BuildBubbles()
    end
end

local function RefreshPinned()
    local pin = FetchPinned()
    ChatWindow.PinnedMessage = pin
    if ChatWindow.UpdatePinned then ChatWindow.UpdatePinned() end
end

-- ============================================================
-- BUILD WINDOW
-- ============================================================
local function BuildChatWindow()
    local T = Theme.Get()

    local gui = New("ScreenGui", {
        Name = "VentureChatWindow",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 999997,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)
    ChatWindow.Gui = gui

    local win = New("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = IsMobile and UDim2.fromOffset(360,480) or UDim2.fromOffset(420,540),
        BackgroundColor3 = T.MainBg,
        BackgroundTransparency = 0.06,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        Active = true,
        ZIndex = 5,
    }, gui)
    New("UICorner", {CornerRadius = UDim.new(0,18)}, win)
    local winStroke = New("UIStroke", {Color = T.Accent, Thickness = 1.5, Transparency = 0.2}, win)
    New("UIGradient", {Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, T.MainGradientA),
        ColorSequenceKeypoint.new(0.5, T.MainGradientB),
        ColorSequenceKeypoint.new(1, T.MainGradientC),
    }), Rotation = 135}, win)

    ChatWindow.Window = win
    ChatWindow.Stroke = winStroke

    -- Header
    local header = New("Frame", {
        Size = UDim2.new(1,0,0,44),
        BackgroundTransparency = 1,
        ZIndex = 6,
    }, win)

    local headerIcon = New("TextLabel", {
        Position = UDim2.new(0,16,0,10),
        Size = UDim2.fromOffset(24,24),
        BackgroundTransparency = 1,
        Text = "💬",
        TextColor3 = Color3.fromRGB(255,220,255),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        ZIndex = 7,
    }, header)

    local headerTitle = New("TextLabel", {
        Position = UDim2.new(0,48,0,10),
        Size = UDim2.new(1,-140,0,24),
        BackgroundTransparency = 1,
        Text = "VENTURE CHAT",
        TextColor3 = T.TitleText,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7,
    }, header)

    local headerInfo = New("TextLabel", {
        Position = UDim2.new(0,48,0,26),
        Size = UDim2.new(1,-140,0,14),
        BackgroundTransparency = 1,
        Text = "You: " .. ChatWindow.MyAnonName,
        TextColor3 = T.SubText,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7,
    }, header)

    local clearBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1,-52,0,10),
        Size = UDim2.fromOffset(28,24),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "🗑",
        TextColor3 = Color3.fromRGB(255,180,180),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 8,
    }, header)
    New("UICorner", {CornerRadius = UDim.new(0,6)}, clearBtn)
    clearBtn.MouseButton1Click:Connect(ClearChat)

    local closeBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1,-16,0,10),
        Size = UDim2.fromOffset(28,24),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "✕",
        TextColor3 = Color3.fromRGB(255,120,120),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 8,
    }, header)
    New("UICorner", {CornerRadius = UDim.new(0,6)}, closeBtn)
    closeBtn.MouseButton1Click:Connect(function()
        ChatWindow.Hide()
    end)

    -- Pinned message bar
    local pinnedBar = New("Frame", {
        Position = UDim2.new(0,10,0,50),
        Size = UDim2.new(1,-20,0,0),
        BackgroundColor3 = Color3.fromRGB(60,30,100),
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 7,
    }, win)
    New("UICorner", {CornerRadius = UDim.new(0,8)}, pinnedBar)
    local pinnedStroke = New("UIStroke", {Color = Color3.fromRGB(180,120,255), Thickness = 1}, pinnedBar)

    local pinnedIcon = New("TextLabel", {
        Position = UDim2.new(0,8,0,4),
        Size = UDim2.fromOffset(18,18),
        BackgroundTransparency = 1,
        Text = "📌",
        TextColor3 = Color3.fromRGB(255,220,255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 8,
    }, pinnedBar)

    local pinnedText = New("TextLabel", {
        Position = UDim2.new(0,28,0,4),
        Size = UDim2.new(1,-70,0,20),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.fromRGB(255,230,255),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = false,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 8,
    }, pinnedBar)

    local pinnedUnpin = New("TextButton", {
        AnchorPoint = Vector2.new(1,0),
        Position = UDim2.new(1,-6,0,4),
        Size = UDim2.fromOffset(20,20),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = Color3.fromRGB(255,150,150),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 8,
    }, pinnedBar)
    pinnedUnpin.MouseButton1Click:Connect(UnpinMessage)

    ChatWindow.PinnedBar = pinnedBar
    ChatWindow.PinnedText = pinnedText

    ChatWindow.UpdatePinned = function()
        if ChatWindow.PinnedMessage and ChatWindow.PinnedMessage.text then
            pinnedBar.Visible = true
            pinnedBar.Size = UDim2.new(1,-20,0,28)
            pinnedText.Text = ChatWindow.PinnedMessage.text
        else
            pinnedBar.Visible = false
            pinnedBar.Size = UDim2.new(1,-20,0,0)
        end
    end

    -- Chat scroll area
    local scrollTopOffset = 84
    local chatScroll = New("ScrollingFrame", {
        Position = UDim2.new(0,10,0,scrollTopOffset),
        Size = UDim2.new(1,-20,1,-scrollTopOffset-56),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = T.Accent,
        ZIndex = 7,
    }, win)
    ChatWindow.Container = chatScroll

    -- Input bar
    local inputBar = New("Frame", {
        Position = UDim2.new(0,10,1,-52),
        Size = UDim2.new(1,-20,0,42),
        BackgroundColor3 = T.BtnBg,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ZIndex = 7,
    }, win)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, inputBar)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, inputBar)

    local whisperTag = New("TextLabel", {
        Position = UDim2.new(0,8,0,8),
        Size = UDim2.fromOffset(0,26),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.fromRGB(255,200,100),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8,
    }, inputBar)

    local input = New("TextBox", {
        Position = UDim2.new(0,8,0,8),
        Size = UDim2.new(1,-76,0,26),
        BackgroundColor3 = T.MainBg,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "Type message...",
        PlaceholderColor3 = T.SubText,
        TextColor3 = T.BtnText,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false,
        ZIndex = 9,
    }, inputBar)
    New("UICorner", {CornerRadius = UDim.new(0,6)}, input)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.3}, input)

    local sendBtn = New("TextButton", {
        AnchorPoint = Vector2.new(1,0.5),
        Position = UDim2.new(1,-6,0.5,0),
        Size = UDim2.fromOffset(56,30),
        BackgroundColor3 = T.TabBgActive,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "Send",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        ZIndex = 9,
    }, inputBar)
    New("UICorner", {CornerRadius = UDim.new(0,6)}, sendBtn)

    ChatWindow.UpdateWhisper = function()
        if ChatWindow.WhisperTarget then
            whisperTag.Text = "🔒 " .. ChatWindow.WhisperTarget
            whisperTag.Size = UDim2.fromOffset(120, 26)
            input.Position = UDim2.new(0, 130, 0, 8)
            input.Size = UDim2.new(1, -200, 0, 26)
            input.PlaceholderText = "Whisper to " .. ChatWindow.WhisperTarget .. "..."
        else
            whisperTag.Text = ""
            whisperTag.Size = UDim2.fromOffset(0, 26)
            input.Position = UDim2.new(0, 8, 0, 8)
            input.Size = UDim2.new(1, -76, 0, 26)
            input.PlaceholderText = "Type message..."
        end
    end

    whisperTag.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 
            or inputObj.UserInputType == Enum.UserInputType.Touch then
            ChatWindow.WhisperTarget = nil
            ChatWindow.UpdateWhisper()
        end
    end)

    local function Submit()
        local text = input.Text
        if text and #text > 0 then
            local target = ChatWindow.WhisperTarget
            input.Text = ""
            task.spawn(function()
                SendMessage(text, target)
                task.wait(0.3)
                RefreshMessages()
            end)
        end
    end

    sendBtn.MouseButton1Click:Connect(Submit)
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then Submit() end
    end)

    -- Dragging
    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 
            or inputObj.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inputObj.Position
            startPos = win.Position
            inputObj.Changed:Connect(function()
                if inputObj.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    header.InputChanged:Connect(function(inputObj)
        if dragging and (inputObj.UserInputType == Enum.UserInputType.MouseMovement 
            or inputObj.UserInputType == Enum.UserInputType.Touch) then
            local delta = inputObj.Position - dragStart
            win.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    return win
end

-- ============================================================
-- SHOW / HIDE / TOGGLE
-- ============================================================
function ChatWindow.Show()
    if not ChatWindow.Window then BuildChatWindow() end
    local win = ChatWindow.Window
    win.Visible = true
    win.Size = UDim2.fromOffset(300, 300)
    win.BackgroundTransparency = 1
    ChatWindow.Visible = true

    Tween(win, 0.5, {
        Size = IsMobile and UDim2.fromOffset(360,480) or UDim2.fromOffset(420,540),
        BackgroundTransparency = 0.06,
    }, Enum.EasingStyle.Back)

    ChatWindow.UnreadCount = 0
    if ChatWindow.UpdateBadge then ChatWindow.UpdateBadge() end

    task.spawn(function()
        RefreshPinned()
        RefreshMessages()
    end)
end

function ChatWindow.Hide()
    if not ChatWindow.Window then return end
    local win = ChatWindow.Window
    ChatWindow.Visible = false
    Tween(win, 0.4, {
        Size = UDim2.fromOffset(300, 300),
        BackgroundTransparency = 1,
    }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.delay(0.4, function()
        win.Visible = false
    end)
end

function ChatWindow.Toggle()
    if ChatWindow.Visible then
        ChatWindow.Hide()
    else
        ChatWindow.Show()
    end
end

-- ============================================================
-- BADGE on the 💬 button (unread count)
-- ============================================================
function ChatWindow.UpdateBadge()
    local chatBtn = GUI and GUI.ChatBtn
    if not chatBtn then return end
    local badge = chatBtn:FindFirstChild("UnreadBadge")
    if ChatWindow.UnreadCount > 0 then
        if not badge then
            badge = New("TextLabel", {
                Name = "UnreadBadge",
                AnchorPoint = Vector2.new(1,0),
                Position = UDim2.new(1,6,0,-4),
                Size = UDim2.fromOffset(18,18),
                BackgroundColor3 = Color3.fromRGB(255,60,60),
                BorderSizePixel = 0,
                Text = tostring(ChatWindow.UnreadCount),
                TextColor3 = Color3.fromRGB(255,255,255),
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                ZIndex = 11,
            }, chatBtn)
            New("UICorner", {CornerRadius = UDim.new(1,0)}, badge)
        else
            badge.Text = tostring(ChatWindow.UnreadCount)
        end
    elseif badge then
        badge:Destroy()
    end
end

-- ============================================================
-- BACKGROUND POLLING (light — when closed every 30s, when open every 5s)
-- ============================================================
function ChatWindow.Init()
    -- Create window lazily
    task.spawn(function()
        -- Pre-build the window (hidden)
        pcall(BuildChatWindow)
        if ChatWindow.Window then ChatWindow.Window.Visible = false end
    end)

    -- When closed: poll every 30s for unread
    task.spawn(function()
        while true do
            task.wait(ChatWindow.Visible and 5 or 30)
            pcall(function()
                if ChatWindow.Visible then
                    RefreshMessages()
                    RefreshPinned()
                else
                    -- light check for unread
                    local data = FetchMessages(20)
                    if #data > 0 then
                        local maxId = data[#data].id or 0
                        if ChatWindow.LastMessageId > 0 and maxId > ChatWindow.LastMessageId then
                            local newCount = 0
                            for _, m in ipairs(data) do
                                if m.id and m.id > ChatWindow.LastMessageId and m.user_id ~= Supa.MY_UID then
                                    newCount = newCount + 1
                                end
                            end
                            if newCount > 0 then
                                ChatWindow.UnreadCount = ChatWindow.UnreadCount + newCount
                                ChatWindow.UpdateBadge()
                                Notify("💬 Chat", newCount .. " new", 4)
                            end
                        end
                        ChatWindow.LastMessageId = maxId
                        ChatWindow.Messages = data
                    end
                end
            end)
        end
    end)
end

_G.Venture = _G.Venture or {}
_G.Venture.ChatWindow = ChatWindow

return ChatWindow
