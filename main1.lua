--[[
    ═══════════════════════════════════════════════════════════════════════════
    VENTURE AOT v3.0 — Universal Loader (main1.lua)
    ═══════════════════════════════════════════════════════════════════════════
    Автор: Data Hub Team
    Совместимость: Xeno / Delta / Solara / Wave / Arceus X / Codex / Oxygen /
                   Krnl / Fluxus / Synapse / SirHurt / Hydrogen / AWP / Trigon
    Особенности:
        • Multi-source load (jsdelivr → statically → github raw)
        • Прогресс-бар загрузки
        • Детект executor'а
        • Retry-логика (до 3 попыток на источник)
        • Anti-reinject
        • Queue on teleport (авто-перезапуск после телепорта)
        • Mobile-friendly loading UI
        • Подробные ошибки в консоль
    ═══════════════════════════════════════════════════════════════════════════
--]]

-- ═══════════════════════════════════════════════════════════════
-- CONFIG (единственное место, которое надо править)
-- ═══════════════════════════════════════════════════════════════
local CONFIG = {
    -- Репозиторий
    REPO_USER   = "icewinrage",
    REPO_NAME   = "Roblox",
    REPO_BRANCH = "main",

    -- Файлы (порядок загрузки важен)
    MODULES = {
        { name = "Functions", file = "Functions.lua", required = true },
        { name = "GUI1",      file = "GUI1.lua",      required = true },
        { name = "GUI2",      file = "GUI2.lua",      required = true },
    },

    -- Place ID (false = запуск на любом месте)
    PLACE_ID = 129554597954928,

    -- Тайминги
    HTTP_TIMEOUT        = 15,   -- сек на запрос
    RETRY_PER_SOURCE    = 2,    -- попыток на каждый источник
    LOADING_MIN_TIME    = 1.5,  -- минимум секунд показывать loading UI

    -- Поведение
    ALLOW_QUEUE_TELEPORT = true,
    SHOW_DEBUG           = true,
}

-- ═══════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local LocalPlayer      = Players.LocalPlayer
local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- EXECUTOR DETECTION
-- ═══════════════════════════════════════════════════════════════
local function DetectExecutor()
    local checks = {
        { name = "Synapse",  fn = function() return syn and syn.request end },
        { name = "ScriptWare", fn = function() return scriptware and scriptware.request end },
        { name = "Fluxus",   fn = function() return fluxus and fluxus.request end },
        { name = "Krnl",     fn = function() return krnl and krnl.request end },
        { name = "SirHurt",  fn = function() return is_sirhurt_closure end },
        { name = "Sentinel", fn = function() return secure_load end },
        { name = "Xeno",     fn = function() return Xeno end },
        { name = "Delta",    fn = function() return delta and delta.request end },
        { name = "Solara",   fn = function() return Solara end },
        { name = "Wave",     fn = function() return wave and wave.request end },
        { name = "Codex",    fn = function() return codex end },
        { name = "Hydrogen", fn = function() return hydrogen and hydrogen.request end },
        { name = "AWP",      fn = function() return AWP end },
        { name = "Trigon",   fn = function() return trigon and trigon.request end },
    }
    for _, c in ipairs(checks) do
        local ok, res = pcall(c.fn)
        if ok and res then return c.name end
    end
    if getexecutorname then
        local ok, n = pcall(getexecutorname)
        if ok and n then return tostring(n) end
    end
    if identifyexecutor then
        local ok, n = pcall(identifyexecutor)
        if ok and n then return tostring(n) end
    end
    return "Unknown"
end

local EXECUTOR = DetectExecutor()

-- ═══════════════════════════════════════════════════════════════
-- CAPABILITY CHECKS
-- ═══════════════════════════════════════════════════════════════
local Cap = {
    hasLoadstring = (loadstring ~= nil or load ~= nil),
    hasRequest    = (request ~= nil or http_request ~= nil
                     or (syn and syn.request ~= nil)
                     or (fluxus and fluxus.request ~= nil)
                     or (delta and delta.request ~= nil)),
    hasHttpGet    = (game.HttpGet ~= nil),
    hasClipboard  = (setclipboard ~= nil or toclipboard ~= nil),
    hasFileIO     = (writefile ~= nil and readfile ~= nil and isfile ~= nil),
    hasQueue      = (queue_on_teleport ~= nil
                     or (syn and syn.queue_on_teleport ~= nil)
                     or (fluxus and fluxus.queue_on_teleport ~= nil)),
    isMobile      = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled),
}

-- ═══════════════════════════════════════════════════════════════
-- PLACE CHECK
-- ═══════════════════════════════════════════════════════════════
if CONFIG.PLACE_ID and game.PlaceId ~= CONFIG.PLACE_ID then
    warn(string.format("[Venture] Wrong place (%d), expected %d. Aborting.",
        game.PlaceId, CONFIG.PLACE_ID))
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Venture AOT",
            Text = "Wrong place. This script is for Venture AOT only.",
            Duration = 5,
        })
    end)
    return
end

-- ═══════════════════════════════════════════════════════════════
-- CAPABILITY CHECK
-- ═══════════════════════════════════════════════════════════════
if not Cap.hasLoadstring then
    warn("[Venture] Executor doesn't support loadstring. Aborting.")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Venture AOT",
            Text = "Executor not supported (no loadstring).",
            Duration = 5,
        })
    end)
    return
end

if not Cap.hasRequest and not Cap.hasHttpGet then
    warn("[Venture] Executor doesn't support HTTP. Aborting.")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Venture AOT",
            Text = "Executor not supported (no HTTP).",
            Duration = 5,
        })
    end)
    return
end

-- ═══════════════════════════════════════════════════════════════
-- ANTI-REINJECT
-- ═══════════════════════════════════════════════════════════════
local existingGui = PlayerGui:FindFirstChild("VentureAOT_GUI")
local existingLoading = PlayerGui:FindFirstChild("VentureLoadingGui")

if existingGui or existingLoading then
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Venture AOT",
            Text = "Script is already running!",
            Duration = 4,
        })
    end)
    return
end

-- ═══════════════════════════════════════════════════════════════
-- LOADING UI
-- ═══════════════════════════════════════════════════════════════
local function Round(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = obj
end

local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "VentureLoadingGui"
LoadingGui.ResetOnSpawn = false
LoadingGui.IgnoreGuiInset = true
LoadingGui.DisplayOrder = 2147483647
LoadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadingGui.Parent = PlayerGui

local isMobile = Cap.isMobile
local frameW = isMobile and 300 or 380
local frameH = isMobile and 100 or 110

local loadingFrame = Instance.new("Frame")
loadingFrame.Name = "Frame"
loadingFrame.Size = UDim2.fromOffset(frameW, frameH)
loadingFrame.Position = UDim2.new(0.5, -frameW / 2, 0, -150)
loadingFrame.BackgroundColor3 = Color3.fromRGB(15, 8, 30)
loadingFrame.BackgroundTransparency = 0.05
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = LoadingGui
Round(loadingFrame, 12)

local loadingStroke = Instance.new("UIStroke")
loadingStroke.Color = Color3.fromRGB(125, 92, 255)
loadingStroke.Thickness = 2
loadingStroke.Transparency = 0.2
loadingStroke.Parent = loadingFrame

-- Gradient accent
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 200, 255)),
})
grad.Rotation = 45
grad.Parent = loadingStroke

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Position = UDim2.new(0, 20, 0, 14)
loadingTitle.Size = UDim2.new(1, -40, 0, 24)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "Loading Script..."
loadingTitle.TextColor3 = Color3.fromRGB(230, 215, 255)
loadingTitle.TextSize = isMobile and 16 or 18
loadingTitle.Font = Enum.Font.GothamBold
loadingTitle.TextXAlignment = Enum.TextXAlignment.Left
loadingTitle.Parent = loadingFrame

local loadingSub = Instance.new("TextLabel")
loadingSub.Position = UDim2.new(0, 20, 0, 38)
loadingSub.Size = UDim2.new(1, -40, 0, 16)
loadingSub.BackgroundTransparency = 1
loadingSub.Text = string.format("by __TheDark  |  %s  |  %s",
    EXECUTOR, isMobile and "Mobile" or "PC")
loadingSub.TextColor3 = Color3.fromRGB(160, 165, 190)
loadingSub.TextSize = 11
loadingSub.Font = Enum.Font.Gotham
loadingSub.TextXAlignment = Enum.TextXAlignment.Left
loadingSub.Parent = loadingFrame

-- Progress bar
local progressBg = Instance.new("Frame")
progressBg.Position = UDim2.new(0, 20, 0, 64)
progressBg.Size = UDim2.new(1, -40, 0, 6)
progressBg.BackgroundColor3 = Color3.fromRGB(40, 25, 70)
progressBg.BorderSizePixel = 0
progressBg.Parent = loadingFrame
Round(progressBg, 3)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(125, 92, 255)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBg
Round(progressFill, 3)

local progressGrad = Instance.new("UIGradient")
progressGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 200, 255)),
})
progressGrad.Parent = progressFill

local progressText = Instance.new("TextLabel")
progressText.Position = UDim2.new(0, 20, 0, 76)
progressText.Size = UDim2.new(1, -40, 0, 16)
progressText.BackgroundTransparency = 1
progressText.Text = "0%"
progressText.TextColor3 = Color3.fromRGB(180, 165, 220)
progressText.TextSize = 11
progressText.Font = Enum.Font.Gotham
progressText.TextXAlignment = Enum.TextXAlignment.Right
progressText.Parent = loadingFrame

-- Animate in
TweenService:Create(loadingFrame,
    TweenInfo.new(0.4, Enum.EasingStyle.Back),
    { Position = UDim2.new(0.5, -frameW / 2, 0, 20) }
):Play()

local progressValue = 0

local function SetProgress(pct, text)
    pct = math.clamp(pct, 0, 1)
    progressValue = pct
    TweenService:Create(progressFill, TweenInfo.new(0.25), {
        Size = UDim2.new(pct, 0, 1, 0)
    }):Play()
    progressText.Text = string.format("%d%%", math.floor(pct * 100))
    if text then loadingSub.Text = text end
end

local function SetTitle(t)
    loadingTitle.Text = t
end

-- ═══════════════════════════════════════════════════════════════
-- HTTP WITH MULTI-SOURCE FALLBACK
-- ═══════════════════════════════════════════════════════════════
local BASE_SOURCES = {
    string.format("https://cdn.jsdelivr.net/gh/%s/%s@%s/",
        CONFIG.REPO_USER, CONFIG.REPO_NAME, CONFIG.REPO_BRANCH),
    string.format("https://raw.githubusercontent.com/%s/%s/%s/",
        CONFIG.REPO_USER, CONFIG.REPO_NAME, CONFIG.REPO_BRANCH),
    string.format("https://cdn.statically.io/gh/%s/%s/%s/",
        CONFIG.REPO_USER, CONFIG.REPO_NAME, CONFIG.REPO_BRANCH),
}

-- Низкоуровневый GET с поддержкой всех executor'ов
local function RawGet(url)
    -- Synapse / ScriptWare
    if syn and syn.request then
        local ok, res = pcall(syn.request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    -- Fluxus
    if fluxus and fluxus.request then
        local ok, res = pcall(fluxus.request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    -- Delta
    if delta and delta.request then
        local ok, res = pcall(delta.request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    -- Generic request
    if request then
        local ok, res = pcall(request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    -- http_request
    if http_request then
        local ok, res = pcall(http_request, { Url = url, Method = "GET" })
        if ok and res and res.Body and #res.Body > 0 then return res.Body end
    end
    -- game:HttpGet (универсальный fallback)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and #res > 0 then return res end
    return nil
end

-- GET с retry и fallback на другие источники
local function FetchWithFallback(fileName)
    local errors = {}
    for srcIdx, base in ipairs(BASE_SOURCES) do
        local url = base .. fileName
        for attempt = 1, CONFIG.RETRY_PER_SOURCE do
            local ok, body = pcall(RawGet, url)
            if ok and body and #body > 100 then
                if CONFIG.SHOW_DEBUG then
                    print(string.format("[Venture] %s loaded from source #%d (attempt %d)",
                        fileName, srcIdx, attempt))
                end
                return body, url
            end
            table.insert(errors, string.format("src#%d attempt#%d failed", srcIdx, attempt))
        end
    end
    return nil, table.concat(errors, ", ")
end

-- ═══════════════════════════════════════════════════════════════
-- MODULE LOADER
-- ═══════════════════════════════════════════════════════════════
local START_TIME = tick()
local loadedModules = {}
local failedModules = {}

local function LoadModule(mod)
    local name = mod.name
    local file = mod.file

    local code, url = FetchWithFallback(file)
    if not code then
        warn(string.format("[Venture] Failed to fetch %s: %s", file, tostring(url)))
        return false, "fetch failed"
    end

    -- Compile
    local fn, compileErr = loadstring(code, "@" .. name)
    if not fn then
        -- Попробовать с prefix (некоторые executor требуют)
        if loadstring then
            fn, compileErr = loadstring("return " .. code, "@" .. name)
        end
    end
    if not fn then
        warn(string.format("[Venture] Syntax error in %s: %s", name, tostring(compileErr)))
        return false, "syntax error: " .. tostring(compileErr)
    end

    -- Execute
    local ok, runErr = pcall(fn)
    if not ok then
        warn(string.format("[Venture] Runtime error in %s: %s", name, tostring(runErr)))
        return false, "runtime error: " .. tostring(runErr)
    end

    if CONFIG.SHOW_DEBUG then
        print(string.format("[Venture] Loaded: %s (%d bytes)", name, #code))
    end
    return true
end

-- ═══════════════════════════════════════════════════════════════
-- GLOBAL STATE
-- ═══════════════════════════════════════════════════════════════
_G.Venture = _G.Venture or {}
_G.Venture.ExecutorName = EXECUTOR
_G.Venture.PlaceId = game.PlaceId
_G.Venture.Capabilities = Cap
_G.Venture.Version = "3.0"

-- ═══════════════════════════════════════════════════════════════
-- LOAD SEQUENCE
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
    local total = #CONFIG.MODULES
    local done = 0

    SetTitle("Loading Script...")
    SetProgress(0.05, "Preparing...")
    task.wait(0.15)

    for _, mod in ipairs(CONFIG.MODULES) do
        SetProgress(0.1 + (done / total) * 0.8,
            string.format("Loading %s...", mod.name))

        local ok = LoadModule(mod)
        if ok then
            table.insert(loadedModules, mod.name)
        else
            table.insert(failedModules, mod.name)
            if mod.required then
                SetTitle("Load Failed")
                loadingTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
                loadingStroke.Color = Color3.fromRGB(255, 80, 80)
                SetProgress(1, "Failed: " .. mod.name)
                task.wait(3)
                if LoadingGui.Parent then LoadingGui:Destroy() end
                warn("[Venture] Required module failed: " .. mod.name)
                return
            end
        end

        done = done + 1
        task.wait(0.1)
    end

    -- Ждём минимальное время показа
    local elapsed = tick() - START_TIME
    if elapsed < CONFIG.LOADING_MIN_TIME then
        task.wait(CONFIG.LOADING_MIN_TIME - elapsed)
    end

    local loadTime = string.format("%.2f", tick() - START_TIME)

    -- Success
    SetTitle("Successfully Loaded!")
    loadingTitle.TextColor3 = Color3.fromRGB(180, 255, 180)
    loadingStroke.Color = Color3.fromRGB(80, 220, 120)
    SetProgress(1, string.format("Loaded in %ss  |  Thanks for using!", loadTime))

    task.wait(2.5)

    -- Animate out
    TweenService:Create(loadingFrame,
        TweenInfo.new(0.4, Enum.EasingStyle.Quart),
        { Position = UDim2.new(0.5, -frameW / 2, 0, -150), BackgroundTransparency = 1 }
    ):Play()
    TweenService:Create(loadingStroke, TweenInfo.new(0.4), { Transparency = 1 }):Play()
    TweenService:Create(loadingTitle, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
    TweenService:Create(loadingSub, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
    TweenService:Create(progressBg, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(progressFill, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(progressText, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()

    task.wait(0.5)
    if LoadingGui.Parent then LoadingGui:Destroy() end

    -- Уведомление
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Venture AOT v3.0",
            Text = string.format("Loaded in %ss | %s", loadTime, EXECUTOR),
            Duration = 5,
        })
    end)

    print(string.format("[Venture AOT v3.0] Loaded in %ss | Executor: %s | Mobile: %s",
        loadTime, EXECUTOR, tostring(isMobile)))
    print(string.format("[Venture AOT v3.0] Modules loaded: %s",
        table.concat(loadedModules, ", ")))
    if #failedModules > 0 then
        warn(string.format("[Venture AOT v3.0] Failed modules: %s",
            table.concat(failedModules, ", ")))
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- QUEUE ON TELEPORT (авто-перезапуск после телепорта)
-- ═══════════════════════════════════════════════════════════════
if CONFIG.ALLOW_QUEUE_TELEPORT and Cap.hasQueue then
    local AUTO_EXEC = string.format([[
        task.wait(0.5)
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/%s/%s@%s/main1.lua"))()
        end)
        if not ok then
            warn("[Venture] Auto re-exec failed:", err)
        end
    ]], CONFIG.REPO_USER, CONFIG.REPO_NAME, CONFIG.REPO_BRANCH)

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

    -- Перерегистрация раз в 30 сек (некоторые executor'ы сбрасывают очередь)
    task.spawn(function()
        while true do
            task.wait(30)
            pcall(RegisterQueue)
        end
    end)
end

return _G.Venture
