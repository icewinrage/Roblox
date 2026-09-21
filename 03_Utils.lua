local Shared = _G.Venture.Shared
local Config = _G.Venture.Config

local TweenService = Shared.TweenService
local UserInputService = Shared.UserInputService
local StarterGui = Shared.StarterGui
local Players = Shared.Players

local Utils = {}

function Utils.DetectExecutor()
    local name = "Unknown"
    if syn and syn.request then name = "Synapse"
    elseif fluxus then name = "Fluxus"
    elseif krnl then name = "Krnl"
    elseif is_sirhurt_closure then name = "SirHurt"
    elseif secure_load then name = "Sentinel"
    elseif Kavo then name = "Kavo"
    elseif getexecutorname then
        local ok, n = pcall(getexecutorname)
        if ok and n then name = n end
    elseif identifyexecutor then
        local ok, n = pcall(identifyexecutor)
        if ok and n then name = n end
    end
    if Xeno then name = "Xeno" end
    return name
end

function Utils.New(class, properties, parent)
    local obj = Instance.new(class)
    for k, v in pairs(properties or {}) do
        pcall(function() obj[k] = v end)
    end
    if parent then obj.Parent = parent end
    return obj
end

function Utils.Tween(object, time, properties, style, direction)
    local info = TweenInfo.new(
        time or 0.25,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(object, info, properties)
    t:Play()
    return t
end

function Utils.GetCharacter(pl)
    if not pl or not pl.Parent then return nil end
    return pl.Character
end

function Utils.GetRoot(pl)
    local ch = Utils.GetCharacter(pl)
    if not ch then return nil end
    return ch:FindFirstChild("HumanoidRootPart")
end

function Utils.GetHumanoid(pl)
    local ch = Utils.GetCharacter(pl)
    if not ch then return nil end
    return ch:FindFirstChildOfClass("Humanoid")
end

function Utils.GetHead(pl)
    local ch = Utils.GetCharacter(pl)
    if not ch then return nil end
    return ch:FindFirstChild("Head") or ch:FindFirstChild("HumanoidRootPart")
end

function Utils.Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Venture",
            Text = text or "",
            Duration = duration or 8,
        })
    end)
end

function Utils.SafeTheme()
    local theme = Config.Settings.Theme
    if not Config.Themes[theme] then
        Config.Settings.Theme = "Dark"
        theme = "Dark"
    end
    return Config.Themes[theme]
end

function Utils.HttpRequest(opts)
    if syn and syn.request then
        local ok, res = pcall(syn.request, opts)
        if ok and res and res.Body then return res.Body end
    end
    if request then
        local ok, res = pcall(request, opts)
        if ok and res and res.Body then return res.Body end
    end
    if http_request then
        local ok, res = pcall(http_request, opts)
        if ok and res and res.Body then return res.Body end
    end
    local HttpService = Shared.HttpService
    if opts.Method == "GET" then
        local ok, res = pcall(function() return HttpService:GetAsync(opts.Url) end)
        if ok then return res end
    end
    return nil
end

function Utils.HttpPost(url, body, headers)
    local HttpService = Shared.HttpService
    local allHeaders = headers or {}
    allHeaders["Content-Type"] = "application/json"
    return Utils.HttpRequest({
        Url = url,
        Method = "POST",
        Headers = allHeaders,
        Body = HttpService:JSONEncode(body),
    })
end

function Utils.HttpGet(url, headers)
    return Utils.HttpRequest({
        Url = url,
        Method = "GET",
        Headers = headers or {},
    })
end

function Utils.HttpDelete(url, headers)
    return Utils.HttpRequest({
        Url = url,
        Method = "DELETE",
        Headers = headers or {},
    })
end

function Utils.ISOTime(offsetSeconds)
    offsetSeconds = offsetSeconds or 0
    return os.date("!%Y-%m-%dT%H:%M:%SZ", os.time() + offsetSeconds)
end

function Utils.GetUserId()
    if isfile and readfile and writefile and isfile("VAOT_uid.txt") then
        local ok, d = pcall(readfile, "VAOT_uid.txt")
        if ok and d and #d > 0 then return d end
    end
    local uid = tostring(math.random(100000, 999999)) .. "_" .. tostring(os.time())
    if writefile then pcall(writefile, "VAOT_uid.txt", uid) end
    return uid
end

_G.Venture = _G.Venture or {}
_G.Venture.Utils = Utils

return Utils
