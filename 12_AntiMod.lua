local Shared = _G.Venture.Shared local Config = _G.Venture.Config local Players =
 Shared.Players local StarterGui = Shared.StarterGui local TeleportService = 
Shared.TeleportService local TweenService = Shared.TweenService local 
LocalPlayer = Shared.LocalPlayer local PlayerGui = Shared.PlayerGui local 
AntiMod = {}

AntiMod.Triggered = false
local KICK_TITLE = "FUCK YOU MOD"
local KICK_SUB = "you noob"

local function AmIMod()
    local checks = {}
    pcall(function()
        local rank = LocalPlayer:GetRankInGroup(Config.MOD_GROUP_ID)
        if rank and rank > 0 then table.insert(checks, "Group rank: " .. rank) end
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
        skull.Text = "☠"
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
        title.TextSize = 80
        title.Font = Enum.Font.GothamBlack
        title.TextStrokeTransparency = 0
        title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        title.ZIndex = 10
        title.Parent = bg
        local sub = Instance.new("TextLabel")
        sub.AnchorPoint = Vector2.new(0.5, 0.5)
        sub.Position = UDim2.fromScale(0.5, 0.55)
        sub.Size = UDim2.new(1, 0, 0, 100)
        sub.BackgroundTransparency = 1
        sub.Text = KICK_SUB
        sub.TextColor3 = Color3.fromRGB(255, 200, 200)
        sub.TextSize = 30
        sub.Font = Enum.Font.Gotham
        sub.ZIndex = 10
        sub.Parent = bg
        task.wait(2)
        LocalPlayer:Kick("AntiMod Triggered")
    end)
end

task.spawn(function()
    task.wait(5)
    local isMod, reasons = AmIMod()
    if isMod then
        AntiMod.Triggered = true
        ShowFullscreenBanner(reasons)
    end
end)

_G.Venture = _G.Venture or {}
_G.Venture.AntiMod = AntiMod
return AntiMod
