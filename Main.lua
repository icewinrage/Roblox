--// Venture AOT | Main.lua
-- Точка входа: подтягивает все модули с GitHub и запускает

local REPO_USER = "icewinrage"
local REPO_NAME = "Roblox"
local REPO_BRANCH = "main"

local BASE_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/%s/",
    REPO_USER, REPO_NAME, REPO_BRANCH
)

-- Порядок загрузки модулей (важен!)
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
    "10_Init",
}

_G.Venture = _G.Venture or {}

--====================================================
-- HTTP GET (универсальный, работает на всех экзекьюторах)
--====================================================
local function httpGet(url)
    -- Synapse / Script-Ware
    if syn and syn.request then
        local ok, res = pcall(syn.request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    -- Fluxus, Krnl, Delta, Arceus X, Solara, Xeno
    if request then
        local ok, res = pcall(request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    -- Старый Synapse
    if http_request then
        local ok, res = pcall(http_request, {Url = url, Method = "GET"})
        if ok and res and res.Body then return res.Body end
    end
    -- HttpService fallback (не для raw.githubusercontent, но пусть будет)
    local ok, res = pcall(function()
        return game:GetService("HttpService"):GetAsync(url)
    end)
    if ok then return res end
    return nil
end

--====================================================
-- ЗАГРУЗКА МОДУЛЯ
--====================================================
local function loadModule(name)
    local url = BASE_URL .. name .. ".lua"
    local code = httpGet(url)

    if not code or #code == 0 then
        warn("[Venture] Failed to fetch: " .. name)
        return nil
    end

    -- Проверка на 404 от GitHub
    if #code < 60 and code:lower():find("404") then
        warn("[Venture] Module not found on GitHub: " .. name)
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

--====================================================
-- ЗАПУСК
--====================================================
print("[Venture] Loading from GitHub: " .. REPO_USER .. "/" .. REPO_NAME)

for _, name in ipairs(MODULES) do
    local ok, err = pcall(loadModule, name)
    if not ok then
        warn("[Venture] Failed to load " .. name .. ": " .. tostring(err))
    else
        print("[Venture] ✓ Loaded " .. name)
    end
    task.wait(0.05)  -- небольшая пауза между запросами (чтобы не забанили за спам)
end

--====================================================
-- ФИНАЛЬНЫЙ СТАРТ
--====================================================
task.wait(0.3)

local Init = _G.Venture.Init
if Init and Init.Run then
    local ok, err = pcall(Init.Run)
    if not ok then
        warn("[Venture] Init.Run failed: " .. tostring(err))
    end
else
    warn("[Venture] Init module missing — check console for load errors")
end
