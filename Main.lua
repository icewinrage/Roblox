local REPO_USER = "icewinrage"
local REPO_NAME = "Roblox"
local REPO_BRANCH = "main"

-- ============================================
-- ANTI RE-INJECT
-- ============================================
if _G.VentureLoaded then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Venture AOT",
            Text = "Already injected! Close old instance first.",
            Duration = 6,
        })
    end)
    local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    local existing = pg and pg:FindFirstChild("VentureAOT_GUI")
    local existingFluent = pg and pg:FindFirstChild("Venture_FluentUI")
    if existing or existingFluent then
        warn("[Venture] Script already running. Aborting re-inject.")
        return
    else
        _G.VentureLoaded = false
    end
end
_G.VentureLoaded = true

local START_TIME = tick()

local BASE_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    REPO_USER, REPO_NAME, REPO_BRANCH
)

-- Слои загрузки (параллельно внутри слоя, слои по порядку)
local LAYERS = {
    {"00_CursorBoot", "01_Shared", "02_Config", "03_Utils", "04_Theme"},
    {"05_Functions", "07_Keybinds", "08_Security", "11_Cursor", "17_Streamer", "18_AntiAFK", "19_FluentUI"},
    {"06_GUI", "09_Supabase", "13_OnlineTab", "15_Announcements"},
    {"10_Init"},
}

local AUTO_EXEC_CODE = [[
    wait(0.5)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/]] .. REPO_USER .. [[/]] .. REPO_NAME .. [[/]] .. REPO_BRANCH .. [[/Main.lua"))()
]]

local function RegisterQueue()
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
end

RegisterQueue()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

task.spawn(function()
    while true do
        task.wait(30)
        pcall(RegisterQueue)
    end
end)

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

-- ============================================
-- LAYERED PARALLEL LOADING
-- ============================================
local totalModules = 0
for _, layer in ipairs(LAYERS) do
    totalModules = totalModules + #layer
end

local loadedCount = 0
local loadStart = tick()

for layerIndex, layer in ipairs(LAYERS) do
    local layerDone = 0
    local layerTotal = #layer

    for _, name in ipairs(layer) do
        task.spawn(function()
            pcall(loadModule, name)
            layerDone = layerDone + 1
            loadedCount = loadedCount + 1
        end)
    end

    -- Ждём завершения слоя (макс 5 сек на слой)
    local layerWaitStart = tick()
    while layerDone < layerTotal and tick() - layerWaitStart < 5 do
        task.wait(0.02)
    end

    local layerTime = tick() - loadStart
    print(string.format("[Venture] Layer %d (%d modules) loaded in %.2fs", layerIndex, layerTotal, layerTime))
end

local totalLoadTime = tick() - loadStart
print(string.format("[Venture] All %d modules loaded in %.2fs", loadedCount, totalLoadTime))

task.wait(0.1)

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
task.wait(0.2)

local LOAD_TIME = tick() - START_TIME
local timeStr = string.format("%.2f", LOAD_TIME)

local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Successfully Loaded",
        Text = "Venture AOT v1.5 loaded in " .. timeStr .. "s",
        Duration = 8,
    })
end)

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

    TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, 0, 0, 20)
    }):Play()

    task.wait(5)
    local hideTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
        Position = UDim2.new(0.5, 0, 0, -120),
        BackgroundTransparency = 1,
    })
    hideTween:Play()
    hideTween.Completed:Wait()
    gui:Destroy()
end)

print("[Venture] Main loaded in " .. timeStr .. "s")
