-- Venture AOT v3.0 - Universal Loader (Main.lua)
-- Author: Data Hub Team
-- Compatible: Xeno / Delta / Solara / Wave / Arceus X / Codex / Oxygen /
--             Krnl / Fluxus / Synapse / SirHurt / Hydrogen / AWP / Trigon

-- ===============================================================
-- CONFIG
-- ===============================================================
local REPO_USER   = "icewinrage"
local REPO_NAME   = "Roblox"
local REPO_BRANCH = "main"
local PLACE_ID    = 129554597954928

local MODULES = {
    { name = "Functions", file = "Functions.lua", required = true },
    { name = "GUI1",      file = "GUI1.lua",      required = true },
    { name = "GUI2",      file = "GUI2.lua",      required = true },
}

local RETRY_PER_SOURCE = 2
local SHOW_PROGRESS    = true

-- ===============================================================
-- SERVICES
-- ===============================================================
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local LocalPlayer      = Players.LocalPlayer
local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")

-- ===============================================================
-- PLACE CHECK
-- ===============================================================
if PLACE_ID and game.PlaceId ~= PLACE_ID then
    warn(string.format("[Venture] Wrong place (%d != %d). Aborting.",
        game.PlaceId, PLACE_ID))
    return
end

-- ===============================================================
-- ANTI RE-INJECT
-- ===============================================================
if _G.VentureLoaded then
    warn("[Venture] Already loaded (_G.VentureLoaded). Aborting.")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Venture AOT",
            Text = "Script is already running!",
            Duration = 4,
        })
    end)
    return
end

local pg = PlayerGui
local existing = pg:FindFirstChild("VentureAOT_GUI")
    or pg:FindFirstChild("VentureLoadingGui")
if existing then
    warn("[Venture] Found existing GUI. Aborting.")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Venture AOT",
            Text = "Script is already running!",
            Duration = 4,
        })
    end)
    return
end

_G.VentureLoaded = true

-- ===============================================================
-- HTTP WRAPPER
-- ===============================================================
local function httpGet(url)
    if syn and syn.request then
        local ok, res = pcall(syn.request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    if fluxus and fluxus.request then
        local ok, res = pcall(fluxus.request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    if delta and delta.request then
        local ok, res = pcall(delta.request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    if request then
        local ok, res = pcall(request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    if http_request then
        local ok, res = pcall(http_request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #res > 0 then return res end
    return nil
end

-- ===============================================================
-- MULTI-SOURCE
-- ===============================================================
local BASE_SOURCES = {
    string.format("https://raw.githubusercontent.com/%s/%s/%s/",
        REPO_USER, REPO_NAME, REPO_BRANCH),
    string.format("https://cdn.jsdelivr.net/gh/%s/%s@%s/",
        REPO_USER, REPO_NAME, REPO_BRANCH),
    string.format("https://cdn.statically.io/gh/%s/%s/%s/",
        REPO_USER, REPO_NAME, REPO_BRANCH),
}

-- ===============================================================
-- PROGRESS UI
-- ===============================================================
local progressGui, progressLabel, progressBar, progressFill
local progressTotal = #MODULES
local progressCurrent = 0

local function CreateProgressUI()
    if not SHOW_PROGRESS then return end

    progressGui = Instance.new("ScreenGui")
    progressGui.Name = "VentureLoadingGui"
    progressGui.ResetOnSpawn = false
    progressGui.IgnoreGuiInset = true
    progressGui.DisplayOrder = 2147483647
    progressGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(340, 80)
    frame.Position = UDim2.new(0.5, -170, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(15, 8, 30)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Parent = progressGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(125, 92, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.2
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0, 20, 0, 14)
    title.Size = UDim2.new(1, -40, 0, 22)
    title.BackgroundTransparency = 1
    title.Text = "Loading Venture AOT..."
    title.TextColor3 = Color3.fromRGB(230, 215, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    progressLabel = Instance.new("TextLabel")
    progressLabel.Position = UDim2.new(0, 20, 0, 38)
    progressLabel.Size = UDim2.new(1, -40, 0, 16)
    progressLabel.BackgroundTransparency = 1
    progressLabel.Text = "0 / " .. progressTotal
    progressLabel.TextColor3 = Color3.fromRGB(160, 165, 190)
    progressLabel.TextSize = 11
    progressLabel.Font = Enum.Font.Gotham
    progressLabel.TextXAlignment = Enum.TextXAlignment.Left
    progressLabel.Parent = frame

    progressBar = Instance.new("Frame")
    progressBar.Position = UDim2.new(0, 20, 0, 60)
    progressBar.Size = UDim2.new(1, -40, 0, 6)
    progressBar.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = frame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 3)
    barCorner.Parent = progressBar

    progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(125, 92, 255)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBar

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = progressFill
end

local function SetProgress(current, name)
    progressCurrent = current
    if progressLabel then
        progressLabel.Text = string.format("%d / %d   %s",
            current, progressTotal, name or "")
    end
    if progressFill then
        TweenService:Create(progressFill, TweenInfo.new(0.25), {
            Size = UDim2.new(current / progressTotal, 0, 1, 0)
        }):Play()
    end
end

local function DestroyProgressUI()
    if progressGui then
        TweenService:Create(progressFill, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(80, 220, 120)
        }):Play()
        task.wait(0.4)
        progressGui:Destroy()
        progressGui = nil
    end
end

-- ===============================================================
-- MODULE LOADER
-- ===============================================================
local loadedList = {}
local failedList = {}

local function LoadModule(mod)
    local name = mod.name
    local file = mod.file
    local code, usedSource

    for srcIdx, base in ipairs(BASE_SOURCES) do
        for attempt = 1, RETRY_PER_SOURCE do
            local url = base .. file
            local ok, body = pcall(httpGet, url)
            if ok and body and #body > 60
                and not body:lower():find("^404")
                and not body:lower():find("not found") then
                code = body
                usedSource = srcIdx
                break
            end
        end
        if code then break end
    end

    if not code then
        warn("[Venture] Failed to fetch: " .. file)
        return false
    end

    local fn, err = loadstring(code, "@" .. name)
    if not fn then
        warn("[Venture] Syntax error in " .. name .. ": " .. tostring(err))
        return false
    end

    local ok, runErr = pcall(fn)
    if not ok then
        warn("[Venture] Runtime error in " .. name .. ": " .. tostring(runErr))
        return false
    end

    print(string.format("[Venture] Loaded: %s (%d bytes, source #%d)",
        name, #code, usedSource or 0))
    return true
end

-- ===============================================================
-- MAIN LOAD
-- ===============================================================
local START_TIME = tick()

CreateProgressUI()
SetProgress(0, "Initializing...")
task.wait(0.2)

local allOk = true

for i, mod in ipairs(MODULES) do
    SetProgress(i - 1, "Loading " .. mod.name .. "...")
    local ok = LoadModule(mod)
    if ok then
        table.insert(loadedList, mod.name)
    else
        table.insert(failedList, mod.name)
        if mod.required then
            allOk = false
            break
        end
    end
    SetProgress(i, mod.name)
    task.wait(0.1)
end

local loadTime = string.format("%.2f", tick() - START_TIME)

if not allOk then
    warn("[Venture] Required module failed. Aborting.")
    _G.VentureLoaded = false
    DestroyProgressUI()
    return
end

SetProgress(progressTotal, "Complete!")
task.wait(0.5)
DestroyProgressUI()

-- ===============================================================
-- SUCCESS
-- ===============================================================
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Venture AOT v3.0",
        Text = string.format("Loaded in %ss", loadTime),
        Duration = 4,
    })
end)

print(string.format("[Venture AOT v3.0] Loaded in %ss | Modules: %s",
    loadTime, table.concat(loadedList, ", ")))

-- ===============================================================
-- QUEUE ON TELEPORT
-- ===============================================================
local AUTO_EXEC = string.format([[
    task.wait(0.5)
    local ok, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/%s/%s/%s/Main.lua"))()
    end)
    if not ok then warn("[Venture] Auto re-exec failed:", err) end
]], REPO_USER, REPO_NAME, REPO_BRANCH)

local function RegisterQueue()
    if syn and syn.queue_on_teleport then
        pcall(function() syn.queue_on_teleport(AUTO_EXEC) end)
    end
    if fluxus and fluxus.queue_on_teleport then
        pcall(function() fluxus.queue_on_teleport(AUTO_EXEC) end)
    end
    if queue_on_teleport then
        pcall(function() queue_on_teleport(AUTO_EXEC) end)
    end
end

RegisterQueue()

task.spawn(function()
    while true do
        task.wait(30)
        pcall(RegisterQueue)
    end
end)

return _G.Venture
