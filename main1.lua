-- Venture AOT v3.0 - Universal Loader (Main.lua)
-- Author: Data Hub Team
-- Xeno / Delta / Solara / Wave / Arceus X / Codex / Oxygen / Krnl / Fluxus

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

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local StarterGui       = game:GetService("StarterGui")
local LocalPlayer      = Players.LocalPlayer
local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")

-- place check
if PLACE_ID and game.PlaceId ~= PLACE_ID then
    warn(string.format("[Venture] Wrong place (%d != %d)", game.PlaceId, PLACE_ID))
    return
end

-- anti re-inject
if _G.VentureLoaded then
    warn("[Venture] Already loaded")
    return
end
local pg = PlayerGui
if pg:FindFirstChild("VentureAOT_GUI") or pg:FindFirstChild("VentureLoadingGui") then
    warn("[Venture] GUI already exists")
    return
end
_G.VentureLoaded = true

-- http wrapper
local function httpGet(url)
    if syn and syn.request then
        local ok, r = pcall(syn.request, { Url = url, Method = "GET" })
        if ok and r and r.Body and #r.Body > 0 then return r.Body end
    end
    if fluxus and fluxus.request then
        local ok, r = pcall(fluxus.request, { Url = url, Method = "GET" })
        if ok and r and r.Body and #r.Body > 0 then return r.Body end
    end
    if delta and delta.request then
        local ok, r = pcall(delta.request, { Url = url, Method = "GET" })
        if ok and r and r.Body and #r.Body > 0 then return r.Body end
    end
    if request then
        local ok, r = pcall(request, { Url = url, Method = "GET" })
        if ok and r and r.Body and #r.Body > 0 then return r.Body end
    end
    if http_request then
        local ok, r = pcall(http_request, { Url = url, Method = "GET" })
        if ok and r and r.Body and #r.Body > 0 then return r.Body end
    end
    local ok, r = pcall(function() return game:HttpGet(url) end)
    if ok and r and #r > 0 then return r end
    return nil
end

-- SOURCES: raw first (fresh), jsdelivr fallback
local BASE_SOURCES = {
    "https://raw.githubusercontent.com/" .. REPO_USER .. "/" .. REPO_NAME .. "/" .. REPO_BRANCH .. "/",
    "https://cdn.jsdelivr.net/gh/" .. REPO_USER .. "/" .. REPO_NAME .. "@" .. REPO_BRANCH .. "/",
}

-- BOM strip (Xeno killer)
local function stripBOM(code)
    if code:sub(1, 3) == "\239\187\191" then
        return code:sub(4)
    end
    return code
end

-- progress UI
local progressGui, progressLabel, progressFill
local progressTotal = #MODULES

local function createProgress()
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

    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(0, 12)
    c1.Parent = frame

    local s1 = Instance.new("UIStroke")
    s1.Color = Color3.fromRGB(125, 92, 255)
    s1.Thickness = 2
    s1.Transparency = 0.2
    s1.Parent = frame

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

    local bar = Instance.new("Frame")
    bar.Position = UDim2.new(0, 20, 0, 60)
    bar.Size = UDim2.new(1, -40, 0, 6)
    bar.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
    bar.BorderSizePixel = 0
    bar.Parent = frame

    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(0, 3)
    c2.Parent = bar

    progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(125, 92, 255)
    progressFill.BorderSizePixel = 0
    progressFill.Parent = bar

    local c3 = Instance.new("UICorner")
    c3.CornerRadius = UDim.new(0, 3)
    c3.Parent = progressFill
end

local function setProgress(i, name)
    if progressLabel then
        progressLabel.Text = string.format("%d / %d   %s", i, progressTotal, name or "")
    end
    if progressFill then
        TweenService:Create(progressFill, TweenInfo.new(0.25), {
            Size = UDim2.new(i / progressTotal, 0, 1, 0)
        }):Play()
    end
end

local function destroyProgress()
    if progressGui then
        if progressFill then
            TweenService:Create(progressFill, TweenInfo.new(0.3), {
                BackgroundColor3 = Color3.fromRGB(80, 220, 120)
            }):Play()
        end
        task.wait(0.4)
        progressGui:Destroy()
        progressGui = nil
    end
end

-- module loader
local function loadModule(mod)
    local name = mod.name
    local file = mod.file
    local code, usedSrc

    for srcIdx, base in ipairs(BASE_SOURCES) do
        for attempt = 1, RETRY_PER_SOURCE do
            local url = base .. file .. "?t=" .. tostring(os.time())
            local ok, body = pcall(httpGet, url)
            if ok and body and #body > 60
                and not body:lower():find("^404")
                and not body:lower():find("^<html")
                and not body:lower():find("not found") then
                code = body
                usedSrc = srcIdx
                break
            end
        end
        if code then break end
    end

    if not code then
        warn("[Venture] Failed to fetch: " .. file)
        return false
    end

    code = stripBOM(code)

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

    print(string.format("[Venture] Loaded: %s (%d bytes, src #%d)", name, #code, usedSrc or 0))
    return true
end

-- main
local START = tick()
createProgress()
task.wait(0.2)

local allOk = true
for i, mod in ipairs(MODULES) do
    setProgress(i - 1, "Loading " .. mod.name .. "...")
    local ok = loadModule(mod)
    if not ok and mod.required then
        allOk = false
        break
    end
    setProgress(i, mod.name)
    task.wait(0.1)
end

local loadTime = string.format("%.2f", tick() - START)

if not allOk then
    warn("[Venture] Required module failed. Aborting.")
    _G.VentureLoaded = false
    destroyProgress()
    return
end

setProgress(progressTotal, "Complete!")
task.wait(0.5)
destroyProgress()

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Venture AOT v3.0",
        Text = "Loaded in " .. loadTime .. "s",
        Duration = 4,
    })
end)

print("[Venture AOT v3.0] Loaded in " .. loadTime .. "s")

-- queue on teleport
local AUTO_EXEC = string.format([[
task.wait(0.5)
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/%s/%s/%s/Main.lua?t=" .. os.time()))()
end)
]], REPO_USER, REPO_NAME, REPO_BRANCH)

local function registerQueue()
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

registerQueue()
task.spawn(function()
    while true do
        task.wait(30)
        pcall(registerQueue)
    end
end)

return _G.Venture
