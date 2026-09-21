--// Venture | 07_Keybinds.lua
-- Система кастомных биндов + заполнение вкладки KEYBINDS

local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils
local Theme  = _G.Venture.Theme
local Funcs  = _G.Venture.Functions
local GUI    = _G.Venture.GUI

local UserInputService = Shared.UserInputService
local HttpService = Shared.HttpService
local LocalPlayer = Shared.LocalPlayer
local PlayerGui = Shared.PlayerGui
local IsMobile = Shared.IsMobile
local Settings = Config.Settings
local New = Utils.New
local Tween = Utils.Tween

local Keybinds = {}

Keybinds.Data = {}
Keybinds.Listening = nil
Keybinds.Buttons = {}
Keybinds.Rows = {}

--====================================================
-- ЗАГРУЗКА / СОХРАНЕНИЕ
--====================================================
function Keybinds.Load()
    for k, v in pairs(Config.DefaultBinds) do
        Keybinds.Data[k] = v
    end
    if not (isfile and readfile) then return end
    if not isfile("VentureAOT_Keybinds.json") then return end
    local s, data = pcall(function()
        return HttpService:JSONDecode(readfile("VentureAOT_Keybinds.json"))
    end)
    if s and data then
        for k, _ in pairs(Config.DefaultBinds) do
            if data[k] and data[k] ~= "" then
                local ok, key = pcall(function() return Enum.KeyCode[data[k]] end)
                Keybinds.Data[k] = ok and key or nil
            else
                Keybinds.Data[k] = Config.DefaultBinds[k]
            end
        end
    end
end

function Keybinds.Save()
    if not writefile then return end
    local data = {}
    for k, v in pairs(Keybinds.Data) do
        data[k] = v and v.Name or ""
    end
    pcall(function()
        writefile("VentureAOT_Keybinds.json", HttpService:JSONEncode(data))
    end)
end

Keybinds.Load()

--====================================================
-- ОБНОВЛЕНИЕ KEYBIND LIST (слева)
--====================================================
local function BuildKeybindList()
    local listData = {
        {"TP Titan", Keybinds.Data.TPTitan},
        {"Safe Release", Keybinds.Data.SafeRelease},
        {"Force Reset", Keybinds.Data.ForceReset},
        {"Refill TP", Keybinds.Data.RefillTP},
        {"Toggle GUI", Keybinds.Data.ToggleGUI},
        {"AutoFarm", Keybinds.Data.AutoFarmToggle},
        {"Noclip", Keybinds.Data.NoclipToggle},
        {"Auto Heal", Keybinds.Data.AutoHealToggle},
        {"FPS Booster", Keybinds.Data.FPSBoosterToggle},
        {"AutoQuest", Keybinds.Data.AutoQuestToggle},
        {"AutoRefill", Keybinds.Data.AutoRefillToggle},
    }
    for _, r in ipairs(Keybinds.Rows) do
        if r then r:Destroy() end
    end
    Keybinds.Rows = {}
    local T = Theme.Get()
    for i, entry in ipairs(listData) do
        local row = New("Frame", {
            Position = UDim2.new(0,0,0,(i-1)*22),
            Size = UDim2.new(1,0,0,20),
            BackgroundTransparency = 1,
        }, GUI.KBContainer)
        New("TextLabel", {
            Position = UDim2.new(0,0,0,0), Size = UDim2.new(0.6,0,1,0),
            BackgroundTransparency = 1, Text = entry[1],
            TextColor3 = T.BtnText,
            TextSize = 10, Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        New("TextLabel", {
            AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,0,0,0),
            Size = UDim2.new(0.4,0,1,0), BackgroundTransparency = 1,
            Text = entry[2] and entry[2].Name or "--",
            TextColor3 = entry[2] and Color3.fromRGB(212,175,55) or Color3.fromRGB(100,100,120),
            TextSize = 10, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, row)
        table.insert(Keybinds.Rows, row)
    end
end
Keybinds.BuildList = BuildKeybindList

--====================================================
-- КНОПКИ БИНДОВ ВО ВКЛАДКЕ KEYBINDS
--====================================================
local function UpdateBindButtonLabel(action)
    local btn = Keybinds.Buttons[action]
    if not btn then return end
    local key = Keybinds.Data[action]
    btn.Text = key and key.Name or "--"
    btn.TextColor3 = key and Theme.Get().TabTextActive or Color3.fromRGB(100,100,120)
end

local function MakeBindRow(parent, action, label, yPos)
    local T = Theme.Get()
    local row = New("Frame", {
        Position = UDim2.new(0,0,0,yPos), Size = UDim2.new(1,-8,0,44),
        BackgroundColor3 = T.BtnBg, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ZIndex = 8,
    }, parent)
    New("UICorner", {CornerRadius = UDim.new(0,10)}, row)
    New("UIStroke", {Color = T.BtnStroke, Thickness = 1, Transparency = 0.2}, row)
    local mainLabel = New("TextLabel", {
        Position = UDim2.new(0,16,0,0), Size = UDim2.new(1,-130,1,0),
        BackgroundTransparency = 1, Text = label,
        TextColor3 = T.BtnText,
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9,
    }, row)
    local kb = New("TextButton", {
        AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-16,0.5,0),
        Size = UDim2.fromOffset(100,30),
        BackgroundColor3 = T.BtnBgHover, BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = Keybinds.Data[action] and Keybinds.Data[action].Name or "--",
        TextColor3 = Keybinds.Data[action] and T.TabTextActive or Color3.fromRGB(100,100,120),
        Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 9,
    }, row)
    New("UICorner", {CornerRadius = UDim.new(0,8)}, kb)
    Keybinds.Buttons[action] = kb

    -- Регистрируем для темы
    Theme.Register("Buttons", {Btn = row, Stroke = row:FindFirstChildOfClass("UIStroke"), Label = mainLabel, Sub = nil})

    kb.MouseButton1Click:Connect(function()
        Keybinds.Listening = action
        kb.Text = "..."
        kb.TextColor3 = Color3.fromRGB(255,100,100)
    end)
    return yPos + 50
end

function Keybinds.PopulateTab()
    local panel = GUI.KeybindTabPanel
    if not panel then return end
    -- Очищаем старые элементы (кроме первого заголовка)
    for _, child in ipairs(panel:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    local ky = 0
    ky = GUI.MakeSectionLabel(panel, "CUSTOM KEYBINDS", ky)
    New("TextLabel", {
        Position = UDim2.new(0,4,0,ky), Size = UDim2.new(1,-8,0,40),
        BackgroundTransparency = 1, Text = "Click button -> press key\nEmpty = not set",
        TextColor3 = Theme.Get().SubText,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 8,
    }, panel)
    ky = ky + 46

    ky = MakeBindRow(panel, "TPTitan", "TP to Titan", ky)
    ky = MakeBindRow(panel, "SafeRelease", "Safe Release", ky)
    ky = MakeBindRow(panel, "ForceReset", "Force Reset", ky)
    ky = MakeBindRow(panel, "RefillTP", "Refill TP", ky)
    ky = MakeBindRow(panel, "ToggleGUI", "Toggle GUI", ky)
    ky = MakeBindRow(panel, "AutoFarmToggle", "Toggle AutoFarm", ky)
    ky = MakeBindRow(panel, "NoclipToggle", "Toggle Noclip", ky)
    ky = MakeBindRow(panel, "AutoHealToggle", "Toggle Auto Heal", ky)
    ky = MakeBindRow(panel, "FPSBoosterToggle", "Toggle FPS Booster", ky)
    ky = MakeBindRow(panel, "AutoQuestToggle", "Toggle Auto Quest", ky)
    ky = MakeBindRow(panel, "AutoRefillToggle", "Toggle Auto Refill", ky)
    ky = ky + 6
    ky = GUI.MakeButton(panel, "Reset to Defaults", "Only ToggleGUI = K", ky, function()
        for k, v in pairs(Config.DefaultBinds) do
            Keybinds.Data[k] = v
        end
        for action, _ in pairs(Keybinds.Buttons) do
            UpdateBindButtonLabel(action)
        end
        Keybinds.Save()
        BuildKeybindList()
    end)
    panel.CanvasSize = UDim2.new(0,0,0,ky+20)
end

--====================================================
-- ВЫПОЛНЕНИЕ БИНДА
--====================================================
local function ExecuteBind(action)
    if action == "TPTitan" then
        local t = Funcs.GetTitans()
        if #t > 0 then Funcs.StickToTitan(t[1]) end
    elseif action == "SafeRelease" then
        Funcs.CleanupStick(true); Funcs.State.currentTarget = nil
    elseif action == "ForceReset" then
        Funcs.ForceResetState()
    elseif action == "RefillTP" then
        local r = Funcs.GetRefills()
        if #r > 0 then Funcs.TeleportToRefill(r[1]) end
    elseif action == "ToggleGUI" then
        if GUI.Main.Visible then
            GUI.HideToIcon()
        else
            GUI.OpenFromIcon()
        end
    elseif action == "AutoFarmToggle" then
        Settings.AutoFarmEnabled = not Settings.AutoFarmEnabled
        if Settings.AutoFarmEnabled then
            if not Settings.HitboxExpand then Settings.HitboxExpand = true; Funcs.ApplyHitboxToAll() end
            if not Settings.Noclip then Settings.Noclip = true; Funcs.StartNoclip() end
        else
            Funcs.ResetAllHitboxes(); Funcs.StopNoclip(); Funcs.CleanupFarm()
            Funcs.State.FarmState.IsAttacking = false
            Funcs.State.FarmState.CurrentTitan = nil
        end
    elseif action == "NoclipToggle" then
        Settings.Noclip = not Settings.Noclip
        if Settings.Noclip then Funcs.StartNoclip() else Funcs.StopNoclip() end
    elseif action == "AutoHealToggle" then
        Settings.AutoHealEnabled = not Settings.AutoHealEnabled
    elseif action == "FPSBoosterToggle" then
        Settings.FPSBoosterEnabled = not Settings.FPSBoosterEnabled
        if Settings.FPSBoosterEnabled then Funcs.EnableFPSBooster() else Funcs.DisableFPSBooster() end
    elseif action == "AutoQuestToggle" then
        Settings.AutoQuestEnabled = not Settings.AutoQuestEnabled
    elseif action == "AutoRefillToggle" then
        Settings.AutoRefillEnabled = not Settings.AutoRefillEnabled
    end
end

--====================================================
-- LISTENER
--====================================================
function Keybinds.Init()
    BuildKeybindList()

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- Режим назначения бинда
        if Keybinds.Listening then
            local action = Keybinds.Listening
            Keybinds.Listening = nil
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Keybinds.Data[action] = input.KeyCode
                UpdateBindButtonLabel(action)
                Keybinds.Save()
                BuildKeybindList()
            else
                UpdateBindButtonLabel(action)
            end
            return
        end

        -- Обычное нажатие
        local key = input.KeyCode
        for action, bindKey in pairs(Keybinds.Data) do
            if bindKey and key == bindKey then
                pcall(ExecuteBind, action)
                break
            end
        end
    end)
end

_G.Venture = _G.Venture or {}
_G.Venture.Keybinds = Keybinds

return Keybinds
