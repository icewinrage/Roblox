local REPO_USER = "icewinrage"
local REPO_NAME = "Roblox"
local REPO_BRANCH = "main"

local BASE_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    REPO_USER, REPO_NAME, REPO_BRANCH
)

-- НАЧАЛО ОТСЧЁТА
local START_TIME = tick()

local MODULES = {
    "00_CursorBoot",
    "01_Shared",
    "02_Config",
    "03_Utils",
    "04_Theme",
    "05_Functions",
    "06_GUI",
    "07_Keybinds",
    "08_Security",
    "09_Supabase",
    "11_Cursor",
    "12_AntiMod",
    "13_OnlineTab",
    "15_Announcements",
    "16_ChatWindow",
    "17_Streamer",
    "10_Init",
}

local AUTO_EXEC_CODE = [[
    wait(0.5)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/]] .. REPO_USER .. [[/]] .. REPO_NAME .. [[/]] .. REPO_BRANCH .. [[/Main.lua"))()
]]

if syn and syn.queue_on_teleport then
    pcall(function() syn.queue_on_teleport(AUTO_EXEC_CODE) end)
end
if fluxus and fluxus.queue_on_teleport then
    pcall(function() fluxus.queue_on_teleport(AUTO_EXEC_CODE) end)
end
if Krnl and Krnl.queue_on_teleport then
    pcall(function() Krnl.queue_on_teleport(AUTO_EXEC_CODE) end)
end
if queue_on_teleport then
    pcall(function() queue_on_teleport(AUTO_EXEC_CODE) end)
end
if SX and SX.queue_on_teleport then
    pcall(function() SX.queue_on_teleport(AUTO_EXEC_CODE) end)
end

_G.Venture = _G.Venture or {}

local function httpGet(url)
    if syn and syn.request then
        local ok, res = pcall(syn.request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    if request then
        local ok, res = pcall(request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    if http_request then
        local ok, res = pcall(http_request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    local ok, res = pcall(function()
        return game:GetService("HttpService"):GetAsync(url)
    end)
    if ok then return res end
    return nil
end

local function loadModule(name)
    local url = BASE_URL .. name .. ".lua"
    local code = httpGet(url)
    if not code or #code == 0 then
        warn("[Venture] Failed to fetch: " .. name)
        return nil
    end
    if #code < 60 and code:lower():find("404") then
        warn("[Venture] Module not found: " .. name)
        return nil
    end

    local fn, err = loadstring(code, "@" .. name)
    if not fn then
        warn("[Venture] Syntax error in " .. name .. ": " .. tostring(err))
        return nil
    end

    local ok, result = pcall(fn)
    if not ok then
        warn("[Venture] Runtime error in " .. name .. ": " .. tostring(result))
        return nil
    end

    return result
end

for _, name in ipairs(MODULES) do
    pcall(loadModule, name)
    task.wait(0.05)
end

task.wait(0.3)

local Init = _G.Venture.Init
if Init and Init.Run then
    local ok, err = pcall(Init.Run)
    if not ok then
        warn("[Venture] Init.Run failed: " .. tostring(err))
    end
end

-- ============================================
-- SUCCESS NOTIFICATION
-- ============================================
task.wait(0.3)

local LOAD_TIME = tick() - START_TIME

-- Форматируем: 1.23 сек
local timeStr = string.format("%.2f", LOAD_TIME)

local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local LocalPlayer = game:GetService("Players").LocalPlayer

-- 1) SetCore Notification (стандартное)
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Successfully Loaded",
        Text = "Venture AOT v1.5 loaded in " .. timeStr .. "s",
        Duration = 8,
    })
end)

-- 2) Красивая плашка сверху
task.spawn(function()
    local gui = Instance.new("ScreenGui")
    gui.Name = "VentureLoadedNotice"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 2147483000
    gui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.Position = UDim2.new(0.5, 0, 0, -120)
    frame.Size = UDim2.fromOffset(420, 100)
    frame.BackgroundColor3 = Color3.fromRGB(15, 8, 30)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(125, 92, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    stroke.Parent = frame

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 40, 180)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50, 20, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 40, 180)),
    })
    grad.Rotation = 0
    grad.Parent = frame

    -- Титул
    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0, 20, 0, 12)
    title.Size = UDim2.new(1, -40, 0, 26)
    title.BackgroundTransparency = 1
    title.Text = "Successfully Loaded"
    title.TextColor3 = Color3.fromRGB(180, 255, 180)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    -- Время загрузки
    local subtitle = Instance.new("TextLabel")
    subtitle.Position = UDim2.new(0, 20, 0, 40)
    subtitle.Size = UDim2.new(1, -40, 0, 18)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Venture AOT v1.5 | Loaded in " .. timeStr .. "s"
    subtitle.TextColor3 = Color3.fromRGB(220, 220, 240)
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = frame

    -- Thanks
    local thanks = Instance.new("TextLabel")
    thanks.Position = UDim2.new(0, 20, 0, 62)
    thanks.Size = UDim2.new(1, -40, 0, 18)
    thanks.BackgroundTransparency = 1
    thanks.Text = "Thanks for using Venture AOT!"
    thanks.TextColor3 = Color3.fromRGB(212, 175, 55)
    thanks.TextSize = 13
    thanks.Font = Enum.Font.GothamBold
    thanks.TextXAlignment = Enum.TextXAlignment.Left
    thanks.Parent = frame

    -- Появление сверху вниз
    TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, 0, 0, 20)
    }):Play()

    -- Автоскрытие через 5 сек
    task.wait(5)
    local hideTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
        Position = UDim2.new(0.5, 0, 0, -120),
        BackgroundTransparency = 1,
    })
    hideTween:Play()
    hideTween.Completed:Wait()
    gui:Destroy()
end)
