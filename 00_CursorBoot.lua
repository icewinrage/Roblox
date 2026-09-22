local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Только для ПК
if UserInputService.TouchEnabled then return end

-- Скрываем системный курсор
pcall(function()
    UserInputService.MouseIconEnabled = false
end)

-- Создаём кастомный курсор
local CursorGui = Instance.new("ScreenGui")
CursorGui.Name = "VentureCursorBoot"
CursorGui.ResetOnSpawn = false
CursorGui.IgnoreGuiInset = true
CursorGui.DisplayOrder = 2147483647
CursorGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CursorGui.Parent = PlayerGui

local CursorImage = Instance.new("ImageLabel")
CursorImage.Name = "Cursor"
CursorImage.Size = UDim2.fromOffset(28, 28)
CursorImage.BackgroundTransparency = 1
CursorImage.Image = "rbxasset://textures/Cursors/KeyboardMouse/ArrowCursor.png"
CursorImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
CursorImage.ZIndex = 9999
CursorImage.Parent = CursorGui

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(125, 92, 255)
stroke.Thickness = 2
stroke.Transparency = 0.3
stroke.Parent = CursorImage

-- Позиция
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local loc = UserInputService:GetMouseLocation()
        CursorImage.Position = UDim2.fromOffset(loc.X, loc.Y)
    end
end)

-- Экспорт в _G.Venture, чтобы 11_Cursor.lua не создавал второй
_G.Venture = _G.Venture or {}
_G.Venture.CursorBoot = {
    Gui = CursorGui,
    Image = CursorImage,
    Stroke = stroke,
}

return _G.Venture.CursorBoot
