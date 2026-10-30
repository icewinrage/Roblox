local Shared = _G.Venture.Shared local Config = _G.Venture.Config local Utils = 
_G.Venture.Utils local Theme = _G.Venture.Theme local Funcs = 
_G.Venture.Functions local GUI = _G.Venture.GUI local UserInputService = 
Shared.UserInputService local HttpService = Shared.HttpService local LocalPlayer
 = Shared.LocalPlayer local PlayerGui = Shared.PlayerGui local IsMobile = 
Shared.IsMobile local Settings = Config.Settings local New = Utils.New local 
Tween = Utils.Tween local Keybinds = {}

Keybinds.Data = {}
Keybinds.Listening = nil
Keybinds.Buttons = {}
Keybinds.Rows = {}

function Keybinds.Load()
    for k, v in pairs(Config.DefaultBinds or {}) do
        Keybinds.Data[k] = v
    end
    if not (isfile and readfile) then return end
    if not isfile("VentureAOT_Keybinds.json") then return end
    local s, data = pcall(function()
        return HttpService:JSONDecode(readfile("VentureAOT_Keybinds.json"))
    end)
    if s and data then
        for k, _ in pairs(Config.DefaultBinds or {}) do
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

local function BuildKeybindList()
    local listData = {
        {"Toggle GUI", Keybinds.Data.ToggleGUI},
        {"AutoFarm", Keybinds.Data.AutoFarmToggle},
        {"Noclip", Keybinds.Data.NoclipToggle},
        {"Auto Heal", Keybinds.Data.AutoHealToggle},
        {"FPS Booster", Keybinds.Data.FPSBoosterToggle},
        {"AutoQuest", Keybinds.Data.AutoQuestToggle},
    }
    for _, r in ipairs(Keybinds.Rows) do if r then r:Destroy() end end
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
            BackgroundTransparency = 1, Text = entry[1], TextColor3 = T.BtnText,
            TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        New("TextLabel", {
            AnchorPoint = Vector2.new(1,0), Position = UDim2.new(1,0,0,0),
            Size = UDim2.new(0.4,0,1,0), BackgroundTransparency = 1,
            Text = entry[2] and entry[2].Name or "--",
            TextColor3 = entry[2] and Color3.fromRGB(212,175,55) or Color3.fromRGB(100,100,120),
            TextSize = 10, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right,
        }, row)
        table.insert(Keybinds.Rows, row)
    end
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Keybinds.Listening then
        Keybinds.Data[Keybinds.Listening] = input.KeyCode
        Keybinds.Listening = nil
        Keybinds.Save()
        BuildKeybindList()
        return
    end
    for k, v in pairs(Keybinds.Data) do
        if v == input.KeyCode then
            if k == "ToggleGUI" then
                if GUI.MainFrame then
                    GUI.MainFrame.Visible = not GUI.MainFrame.Visible
                end
            elseif k == "AutoFarmToggle" then
                Settings.AutoFarmEnabled = not Settings.AutoFarmEnabled
                Utils.Notify("AutoFarm", Settings.AutoFarmEnabled and "Enabled" or "Disabled", 3)
            elseif k == "NoclipToggle" then
                Settings.Noclip = not Settings.Noclip
                if Settings.Noclip then Funcs.StartNoclip() else Funcs.StopNoclip() end
            elseif k == "AutoHealToggle" then
                Settings.AutoHealEnabled = not Settings.AutoHealEnabled
                Utils.Notify("AutoHeal", Settings.AutoHealEnabled and "Enabled" or "Disabled", 3)
            elseif k == "FPSBoosterToggle" then
                Settings.FPSBoosterEnabled = not Settings.FPSBoosterEnabled
                if Settings.FPSBoosterEnabled then Funcs.EnableFPSBooster() else Funcs.DisableFPSBooster() end
            elseif k == "AutoQuestToggle" then
                Settings.AutoQuestEnabled = not Settings.AutoQuestEnabled
                Utils.Notify("AutoQuest", Settings.AutoQuestEnabled and "Enabled" or "Disabled", 3)
            end
        end
    end
end)

BuildKeybindList()

_G.Venture = _G.Venture or {}
_G.Venture.Keybinds = Keybinds
return Keybinds
