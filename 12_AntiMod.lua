--// Venture | 12_AntiMod.lua
-- Защита от модераторов: полноэкранный баннер + кик

local Shared = _G.Venture.Shared
local Config = _G.Venture.Config

local Players = Shared.Players
local StarterGui = Shared.StarterGui
local TeleportService = Shared.TeleportService
local TweenService = Shared.TweenService
local LocalPlayer = Shared.LocalPlayer
local PlayerGui = Shared.PlayerGui

local AntiMod = {}
AntiMod.Triggered = false

local KICK_TITLE = "FUCK YOU MOD"
local KICK_SUB   = "you noob"

--====================================================
-- ПРОВЕРКА: Я МОДЕР?
--====================================================
local function AmIMod()
    local checks = {}

    pcall(function()
        local rank = LocalPlayer:GetRankInGroup(Config.MOD_GROUP_ID)
        if rank and rank > 0 then
            table.insert(checks, "Group rank: " .. rank)
        end
    end)

    local KNOWN_MODS = {}
    if KNOWN_MODS[LocalPlayer.Name] then
        table.insert(checks, "Known mod: " .. LocalPlayer.Name)
    end

    pcall(function()
        if game.CreatorType == Enum.CreatorType.User and game.CreatorId == LocalPlayer.UserId then
            table.insert(checks, "Place owner")
        end
    end)

    pcall(function()
        if game.CreatorType == Enum.CreatorType.Group then
            local r = LocalPlayer:GetRankInGroup(game.CreatorId)
            if r and r >= 200 then
                table.insert(checks, "Owner group rank: " .. r)
            end
        end
    end)

    return #checks > 0, checks
end

--====================================================
-- ПОЛНОЭКРАННЫЙ БАННЕР
--====================================================
local function ShowFullscreenBanner(reasons)
    pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "AntiModKick"
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 2147483647
        gui.IgnoreGuiInset = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = PlayerGui

        local bg = Instance.new("Frame")
        bg.Name = "Bg"
        bg.Size = UDim2.fromScale(1, 1)
        bg.Position = UDim2.fromScale(0, 0)
        bg.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
        bg.BorderSizePixel = 0
        bg.ZIndex = 1
        bg.Parent = gui

        local grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 20, 20)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 0, 0)),
        })
        grad.Rotation = 90
        grad.Parent = bg

        local flash = Instance.new("Frame")
        flash.Size = UDim2.fromScale(1, 1)
        flash.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        flash.BackgroundTransparency = 1
        flash.BorderSizePixel = 0
        flash.ZIndex = 2
        flash.Parent = gui

        local skull = Instance.new("TextLabel")
        skull.AnchorPoint = Vector2.new(0.5, 0.5)
        skull.Position = UDim2.fromScale(0.5, 0.2)
        skull.Size = UDim2.new(1, 0, 0, 160)
        skull.BackgroundTransparency = 1
        skull.Text = "💀"
        skull.TextColor3 = Color3.fromRGB(255, 255, 255)
        skull.TextSize = 140
        skull.Font = Enum.Font.GothamBlack
        skull.TextStrokeTransparency = 0
        skull.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        skull.ZIndex = 10
        skull.Parent = bg

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.AnchorPoint = Vector2.new(0.5, 0.5)
        title.Position = UDim2.fromScale(0.5, 0.42)
        title.Size = UDim2.new(1, 0, 0, 200)
        title.BackgroundTransparency = 1
        title.Text = KICK_TITLE
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 160
        title.Font = Enum.Font.GothamBlack
        title.TextStrokeTransparency = 0
        title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        title.ZIndex = 10
        title.Parent = bg

        local sub = Instance.new("TextLabel")
        sub.Name = "Sub"
        sub.AnchorPoint = Vector2.new(0.5, 0.5)
        sub.Position = UDim2.fromScale(0.5, 0.62)
        sub.Size = UDim2.new(1, 0, 0, 80)
        sub.BackgroundTransparency = 1
        sub.Text = KICK_SUB
        sub.TextColor3 = Color3.fromRGB(255, 200, 200)
        sub.TextSize = 64
        sub.Font = Enum.Font.GothamBold
        sub.TextStrokeTransparency = 0
        sub.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        sub.ZIndex = 10
        sub.Parent = bg

        local reasonLabel = Instance.new("TextLabel")
        reasonLabel.AnchorPoint = Vector2.new(0.5, 1)
        reasonLabel.Position = UDim2.fromScale(0.5, 1)
        reasonLabel.Size = UDim2.new(1, 0, 0, 50)
        reasonLabel.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
        reasonLabel.BackgroundTransparency = 0.2
        reasonLabel.BorderSizePixel = 0
        reasonLabel.Text = "Reason: " .. table.concat(reasons, ", ")
        reasonLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        reasonLabel.TextSize = 20
        reasonLabel.Font = Enum.Font.GothamBold
        reasonLabel.ZIndex = 10
        reasonLabel.Parent = bg

        bg.BackgroundTransparency = 1
        title.TextTransparency = 1
        sub.TextTransparency = 1
        skull.TextTransparency = 1

        TweenService:Create(bg, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        TweenService:Create(title, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
        TweenService:Create(sub, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
        TweenService:Create(skull, TweenInfo.new(0.2), {TextTransparency = 0}):Play()

        task.spawn(function()
            for _ = 1, 8 do
                TweenService:Create(flash, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
                task.wait(0.15)
                TweenService:Create(flash, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                task.wait(0.15)
            end
        end)

        task.spawn(function()
            local basePos = title.Position
            while gui.Parent do
                title.Position = UDim2.new(basePos.X.Scale + math.random(-15, 15)/1000, basePos.X.Offset, basePos.Y.Scale + math.random(-15, 15)/1000, basePos.Y.Offset)
                task.wait(0.03)
            end
        end)

        task.spawn(function()
            while gui.Parent do
                TweenService:Create(title, TweenInfo.new(0.4), {TextSize = 175}):Play()
                task.wait(0.4)
                TweenService:Create(title, TweenInfo.new(0.4), {TextSize = 160}):Play()
                task.wait(0.4)
            end
        end)
    end)
end

--====================================================
-- ВЫХОД
--====================================================
local function KickSelf(reasons)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = KICK_TITLE,
            Text = KICK_SUB,
            Duration = 5,
        })
    end)

    pcall(function()
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[Venture] " .. KICK_TITLE .. ", " .. KICK_SUB,
            Color = Color3.fromRGB(255, 50, 50),
            Font = Enum.Font.GothamBold,
        })
    end)

    ShowFullscreenBanner(reasons)

    warn("[AntiMod] ================================")
    warn("[AntiMod] " .. KICK_TITLE .. ", " .. KICK_SUB)
    for _, r in ipairs(reasons) do warn("  - " .. r) end
    warn("[AntiMod] ================================")

    task.wait(2.0)

    pcall(function() TeleportService:Teleport(0) end)
    task.wait(0.3)
    if kickSelf then pcall(kickSelf) end
    if closeRoblox then pcall(closeRoblox) end
    pcall(function()
        if game and game.Shutdown then game:Shutdown() end
    end)
    task.wait(0.3)
    pcall(function()
        if syn and syn.kill then syn.kill() end
    end)
end

--====================================================
-- ПРОВЕРКА
--====================================================
function AntiMod.Check()
    if AntiMod.Triggered then return true end
    local isMod, reasons = AmIMod()
    if isMod then
        AntiMod.Triggered = true
        KickSelf(reasons)
        return true
    end
    return false
end

function AntiMod.Init()
    if AntiMod.Check() then return end
    print("[Venture] AntiMod: you are not a moderator, OK")
end

_G.Venture = _G.Venture or {}
_G.Venture.AntiMod = AntiMod

return AntiMod
