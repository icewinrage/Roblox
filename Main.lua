local REPO_USER = "icewinrage"
local REPO_NAME = "Roblox"
local REPO_BRANCH = "main"

local BASE_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    REPO_USER, REPO_NAME, REPO_BRANCH
)

local MODULES = {
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
    "10_Init",
}

-- Auto-execute after teleport
local AUTO_EXEC_CODE = [[
loadstring(game:HttpGet("https://raw.githubusercontent.com/]] .. REPO_USER .. [[/]] .. REPO_NAME .. [[/]] .. REPO_BRANCH .. [[/Main.lua"))()
]]

if queue_on_teleport then
    pcall(function() queue_on_teleport(AUTO_EXEC_CODE) end)
elseif syn and syn.queue_on_teleport then
    pcall(function() syn.queue_on_teleport(AUTO_EXEC_CODE) end)
elseif fluxus and fluxus.queue_on_teleport then
    pcall(function() fluxus.queue_on_teleport(AUTO_EXEC_CODE) end)
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

-- LAYERED LOADING (parallel within groups, ordered between groups)
local GROUPS = {
    {"01_Shared"},
    {"02_Config", "03_Utils"},
    {"04_Theme"},
    {"05_Functions"},
    {"06_GUI", "07_Keybinds", "08_Security", "09_Supabase", "11_Cursor", "12_AntiMod", "13_OnlineTab"},
    {"10_Init"},
}

for _, group in ipairs(GROUPS) do
    local threads = {}
    for _, name in ipairs(group) do
        table.insert(threads, task.spawn(function()
            pcall(loadModule, name)
        end))
    end
    -- Wait for group completion
    local allDone = false
    local waitStart = tick()
    while not allDone and tick() - waitStart < 5 do
        allDone = true
        for _, t in ipairs(threads) do
            if coroutine.status(t) ~= "dead" then
                allDone = false
                break
            end
        end
        if not allDone then task.wait(0.02) end
    end
end

task.wait(0.1)

local Init = _G.Venture.Init
if Init and Init.Run then
    local ok, err = pcall(Init.Run)
    if not ok then
        warn("[Venture] Init.Run failed: " .. tostring(err))
    end
end
