local REPO_USER = "icewinrage"
local REPO_NAME = "Roblox"
local REPO_BRANCH = "main"

local BASE_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    REPO_USER, REPO_NAME, REPO_BRANCH
)

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
