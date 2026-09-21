--// Venture | 01_Shared.lua
-- Общие ссылки, которые используются всеми модулями

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local Shared = {
    Players = Players,
    RunService = RunService,
    UserInputService = UserInputService,
    TweenService = TweenService,
    Workspace = Workspace,
    VirtualInputManager = VirtualInputManager,
    TeleportService = TeleportService,
    StarterGui = StarterGui,
    Lighting = Lighting,
    HttpService = HttpService,

    LocalPlayer = Players.LocalPlayer,
    Camera = Workspace.CurrentCamera,
    PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui"),
    IsMobile = UserInputService.TouchEnabled,
}

_G.Venture = _G.Venture or {}
_G.Venture.Shared = Shared

return Shared
