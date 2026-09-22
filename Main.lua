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
    if not code or #code == 0 then return nil end
    if #code < 60 and code:lower():find("404") then return nil end

    local fn, err = loadstring(code, "@" .. name)
    if not fn then return nil end

    local ok, result = pcall(fn)
    if not ok then return nil end

    return result
end

for _, name in ipairs(MODULES) do
    pcall(loadModule, name)
    task.wait(0.05)
end

task.wait(0.3)

local Init = _G.Venture.Init
if Init and Init.Run then
    pcall(Init.Run)
end
