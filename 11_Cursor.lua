local Cursor = {}

function Cursor.Init()
    -- Курсор уже создан в 00_CursorBoot.lua
    if _G.Venture.CursorBoot then
        Cursor.Gui = _G.Venture.CursorBoot.Gui
        Cursor.Image = _G.Venture.CursorBoot.Image
        return
    end

    -- Fallback: если по какой-то причине 00_CursorBoot не сработал — создаём свой
    local UserInputService = game:GetService("UserInputService")
    local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    if UserInputService.TouchEnabled then return end
    UserInputService.MouseIconEnabled = false

    local gui = Instance.new("ScreenGui")
    gui.Name = "VentureCursor"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 2147483647
    gui.Parent = PlayerGui

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.fromOffset(28, 28)
    img.BackgroundTransparency = 1
    img.Image = "rbxasset://textures/Cursors/KeyboardMouse/ArrowCursor.png"
    img.ZIndex = 9999
    img.Parent = gui

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(125, 92, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = img

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local loc = UserInputService:GetMouseLocation()
            img.Position = UDim2.fromOffset(loc.X, loc.Y)
        end
    end)

    Cursor.Gui = gui
    Cursor.Image = img
end

function Cursor.Restore()
    local UserInputService = game:GetService("UserInputService")
    if UserInputService.TouchEnabled then return end
    UserInputService.MouseIconEnabled = true
    if Cursor.Gui then
        Cursor.Gui:Destroy()
        Cursor.Gui = nil
    end
end

_G.Venture = _G.Venture or {}
_G.Venture.Cursor = Cursor

return Cursor
