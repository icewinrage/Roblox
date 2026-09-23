local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils
local Theme  = _G.Venture.Theme
local GUI    = _G.Venture.GUI

local Players = Shared.Players
local RunService = Shared.RunService
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = Shared.VirtualInputManager
local UserInputService = Shared.UserInputService
local LocalPlayer = Shared.LocalPlayer
local HttpService = Shared.HttpService
local New = Utils.New
local Notify = Utils.Notify

local AntiAFK = {}

AntiAFK.Enabled = false
AntiAFK.Mode = "Jump"       -- "Jump" | "Move" | "Both"
AntiAFK.Interval = 20        -- сек
AntiAFK.LastAction = 0
AntiAFK.Connection = nil

-- Отключение встроенного анти-AFK Roblox (Idled event)
local function DisableRobloxIdle()
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            pcall(function()
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end)
    end)
end

DisableRobloxIdle()

-- Действия
local function DoJump()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.Jump = true
        end)
    end
end

local function DoMove()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            -- Лёгкое движение вперёд-назад
            hum:Move(Vector3.new(0, 0, -1), false)
            task.wait(0.15)
            hum:Move(Vector3.new(0, 0, 1), false)
            task.wait(0.15)
            hum:Move(Vector3.zero, false)
        end)
    end
end

local function DoKeyPress()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end

local function DoAction()
    if AntiAFK.Mode == "Jump" then
        DoJump()
    elseif AntiAFK.Mode == "Move" then
        DoMove()
    elseif AntiAFK.Mode == "Both" then
        DoJump()
        task.wait(0.2)
        DoMove()
    end
    AntiAFK.LastAction = tick()
end

-- Основной loop
function AntiAFK.StartLoop()
    if AntiAFK.Connection then return end
    AntiAFK.Connection = task.spawn(function()
        while AntiAFK.Enabled do
            task.wait(1)
            if tick() - AntiAFK.LastAction >= AntiAFK.Interval then
                pcall(DoAction)
            end
        end
    end)
end

function AntiAFK.StopLoop()
    if AntiAFK.Connection then
        AntiAFK.Connection = nil
    end
end

-- Включение / выключение
function AntiAFK.Enable()
    AntiAFK.Enabled = true
    AntiAFK.LastAction = tick()
    AntiAFK.StartLoop()
    Notify("Anti-AFK", "Enabled (" .. AntiAFK.Mode .. ")", 3)
end

function AntiAFK.Disable()
    AntiAFK.Enabled = false
    AntiAFK.StopLoop()
    Notify("Anti-AFK", "Disabled", 3)
end

function AntiAFK.Toggle()
    if AntiAFK.Enabled then AntiAFK.Disable() else AntiAFK.Enable() end
end

-- UI
function AntiAFK.PopulateTab()
    local panel = GUI.MiscTabPanel
    if not panel then return end

    local y = 0

    y = GUI.MakeToggle(panel, "Anti-AFK", y, AntiAFK.Enabled, function(v)
        if v then AntiAFK.Enable() else AntiAFK.Disable() end
    end)

    y = GUI.MakeDropdown(panel, "Mode", {"Jump", "Move", "Both"}, y, AntiAFK.Mode, function(v)
        AntiAFK.Mode = v
    end)

    y = GUI.MakeSlider(panel, "Interval", y, 5, 60, AntiAFK.Interval, "s", function(v)
        AntiAFK.Interval = v
    end)
end

-- Init
function AntiAFK.Init()
    -- На старте выключено, включается вручную
end

_G.Venture = _G.Venture or {}
_G.Venture.AntiAFK = AntiAFK

return AntiAFK
