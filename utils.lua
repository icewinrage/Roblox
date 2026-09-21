--// Venture | 3_Utils.lua
local TweenService = game:GetService("TweenService")

local Utils = {}

function Utils.DetectExecutor()
    local name = "Unknown"
    if syn and syn.request then name = "Synapse"
    elseif fluxus then name = "Fluxus"
    elseif krnl then name = "Krnl"
    elseif getexecutorname then
        local ok, n = pcall(getexecutorname); if ok and n then name = n end
    elseif identifyexecutor then
        local ok, n = pcall(identifyexecutor); if ok and n then name = n end
    end
    if Xeno then name = "Xeno" end
    return name
end

function Utils.New(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

function Utils.Tween(obj, time, props, style, dir)
    local info = TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

return Utils
