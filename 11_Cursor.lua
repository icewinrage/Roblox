local Shared = _G.Venture.Shared
local Utils  = _G.Venture.Utils

local UserInputService = Shared.UserInputService
local PlayerGui = Shared.PlayerGui
local New = Utils.New

local Cursor = {}

function Cursor.Init()
    if UserInputService.TouchEnabled then return end

    UserInputService.MouseIconEnabled = false

    local CursorGui = New("ScreenGui", {
        Name = "VentureCursor",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 2147483647,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, PlayerGui)

    local CursorImage = New("ImageLabel", {
        Name = "Cursor",
        Size = UDim2.fromOffset(28, 28),
        BackgroundTransparency = 1,
        Image = "rbxasset://textures/Cursors/KeyboardMouse/ArrowCursor.png",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 9999,
    }, CursorGui)

    New("UIStroke", {
        Color = Color3.fromRGB(125, 92, 255),
        Thickness = 2,
        Transparency = 0.3,
    }, CursorImage)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local loc = UserInputService:GetMouseLocation()
            CursorImage.Position = UDim2.fromOffset(loc.X, loc.Y)
        end
    end)

    Cursor.Gui = CursorGui
    Cursor.Image = CursorImage
end

function Cursor.Restore()
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
