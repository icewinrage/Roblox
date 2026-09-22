local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils
local Theme  = _G.Venture.Theme
local Funcs  = _G.Venture.Functions
local GUI    = _G.Venture.GUI
local Keybinds = _G.Venture.Keybinds
local Security = _G.Venture.Security
local Supa     = _G.Venture.Supabase

local Players = Shared.Players
local RunService = Shared.RunService
local UserInputService = Shared.UserInputService
local Workspace = Shared.Workspace
local Camera = Shared.Camera
local LocalPlayer = Shared.LocalPlayer
local Settings = Config.Settings
local New = Utils.New

local Init = {}

local HAS_DRAWING = (Drawing and Drawing.new ~= nil)

local ESPObjects = {}
local RefillESP = {}
local PlayerESPObjects = {}

local function CreateESP_Drawing(model)
    if ESPObjects[model] then return end
    local box = Drawing.new("Square"); box.Thickness = 2; box.Filled = false; box.Visible = false
    local dot = Drawing.new("Circle"); dot.Radius = 6; dot.Filled = true; dot.Thickness = 1; dot.Visible = false
    local text = Drawing.new("Text"); text.Size = 14; text.Center = true; text.Outline = true; text.Font = 2; text.Visible = false
    ESPObjects[model] = {Box = box, NapeDot = dot, Text = text, Mode = "Drawing"}
end

local function CreateRefillESP_Drawing(model)
    if RefillESP[model] then return end
    local text = Drawing.new("Text")
    text.Size = 14; text.Center = true; text.Outline = true; text.Font = 2
    text.Color = Settings.RefillColor; text.Visible = false
    RefillESP[model] = {Text = text, Mode = "Drawing"}
end

local function CreatePlayerESP_Drawing(pl)
    if PlayerESPObjects[pl] then return end
    local box = Drawing.new("Square"); box.Thickness = 2; box.Filled = false; box.Visible = false
    local nm = Drawing.new("Text"); nm.Size = 14; nm.Center = true; nm.Outline = true; nm.Font = 2; nm.Visible = false
    local hp = Drawing.new("Text"); hp.Size = 12; hp.Center = true; hp.Outline = true; hp.Font = 2; hp.Visible = false
    local dst = Drawing.new("Text"); dst.Size = 11; dst.Center = true; dst.Outline = true; dst.Font = 2; dst.Visible = false
    PlayerESPObjects[pl] = {Box = box, Name = nm, HP = hp, Distance = dst, Mode = "Drawing"}
end

local function CreateESP_Highlight(model)
    if ESPObjects[model] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "VentureESP"
    hl.FillColor = Settings.ESPColor
    hl.FillTransparency = 0.6
    hl.OutlineColor = Settings.ESPColor
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = model
    ESPObjects[model] = {Highlight = hl, Mode = "Highlight"}
end

local function CreateRefillESP_Highlight(model)
    if RefillESP[model] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "VentureRefillESP"
    hl.FillColor = Settings.RefillColor
    hl.FillTransparency = 0.7
    hl.OutlineColor = Settings.RefillColor
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = model
    RefillESP[model] = {Highlight = hl, Mode = "Highlight"}
end

local function CreatePlayerESP_Highlight(pl)
    if PlayerESPObjects[pl] then return end
    local hl = Instance.new("Highlight")
    hl.Name = "VenturePlayerESP"
    hl.FillColor = Color3.fromRGB(255,60,60)
    hl.FillTransparency = 0.6
    hl.OutlineColor = Color3.fromRGB(255,60,60)
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = Shared.PlayerGui
    PlayerESPObjects[pl] = {Highlight = hl, Mode = "Highlight"}
end

local function UpdateESP()
    local titans = Funcs.GetTitans()
    local alive = {}
    for _, t in ipairs(titans) do
        alive[t.Model] = true
        local isT = (Funcs.State.currentTarget and Funcs.State.currentTarget.Model == t.Model)
                 or (Funcs.State.FarmState.CurrentTitan and Funcs.State.FarmState.CurrentTitan.Model == t.Model)
        if HAS_DRAWING then
            if not ESPObjects[t.Model] then CreateESP_Drawing(t.Model) end
            local d = ESPObjects[t.Model]
            if d then
                d.Box.Color = isT and Settings.TargetColor or Settings.ESPColor
                d.NapeDot.Color = isT and Settings.TargetColor or Settings.NapeColor
                if not Settings.ESP then
                    d.Box.Visible = false; d.NapeDot.Visible = false; d.Text.Visible = false
                else
                    local hPos, on = Camera:WorldToViewportPoint(t.Head.Position)
                    local nPos, nOn = Camera:WorldToViewportPoint(t.Nape.Position)
                    if on then
                        local scale = math.clamp(200 / math.max(t.Distance, 1), 0.3, 3)
                        local size = Vector2.new(20 * scale, 35 * scale)
                        d.Box.Size = size
                        d.Box.Position = Vector2.new(hPos.X - size.X / 2, hPos.Y - size.Y / 2)
                        d.Box.Visible = true
                        d.Text.Position = Vector2.new(hPos.X, hPos.Y - size.Y / 2 - 18)
                        d.Text.Text = (isT and "* " or "") .. t.Model.Name .. " [" .. math.floor(t.Distance) .. "]"
                        d.Text.Color = isT and Settings.TargetColor or Color3.new(1,1,1)
                        d.Text.Visible = true
                    else
                        d.Box.Visible = false; d.Text.Visible = false
                    end
                    if nOn then
                        d.NapeDot.Position = Vector2.new(nPos.X, nPos.Y)
                        d.NapeDot.Visible = true
                    else
                        d.NapeDot.Visible = false
                    end
                end
            end
        else
            if Settings.ESP then
                if not ESPObjects[t.Model] then CreateESP_Highlight(t.Model) end
                local d = ESPObjects[t.Model]
                if d and d.Highlight then
                    d.Highlight.FillColor = isT and Settings.TargetColor or Settings.ESPColor
                    d.Highlight.OutlineColor = d.Highlight.FillColor
                    d.Highlight.Enabled = true
                end
            else
                local d = ESPObjects[t.Model]
                if d and d.Highlight then d.Highlight.Enabled = false end
            end
        end
    end
    for m, d in pairs(ESPObjects) do
        if not alive[m] then
            if d.Mode == "Drawing" then
                for _, o in pairs(d) do
                    if typeof(o) == "userdata" or type(o) == "table" then
                        pcall(function() o:Destroy() end)
                    end
                end
            elseif d.Highlight then
                d.Highlight:Destroy()
            end
            ESPObjects[m] = nil
        end
    end

    local refills = Funcs.GetRefills()
    local aliveR = {}
    for _, r in ipairs(refills) do
        aliveR[r.Model] = true
        if HAS_DRAWING then
            if not RefillESP[r.Model] then CreateRefillESP_Drawing(r.Model) end
            local d = RefillESP[r.Model]
            if d then
                if not Settings.ESP then d.Text.Visible = false
                else
                    local pos, on = Camera:WorldToViewportPoint(r.Part.Position)
                    if on then
                        d.Text.Position = Vector2.new(pos.X, pos.Y)
                        d.Text.Text = "[Refill] [" .. math.floor(r.Distance) .. "]"
                        d.Text.Visible = true
                    else
                        d.Text.Visible = false
                    end
                end
            end
        else
            if Settings.ESP then
                if not RefillESP[r.Model] then CreateRefillESP_Highlight(r.Model) end
                local d = RefillESP[r.Model]
                if d and d.Highlight then d.Highlight.Enabled = true end
            else
                local d = RefillESP[r.Model]
                if d and d.Highlight then d.Highlight.Enabled = false end
            end
        end
    end
    for m, d in pairs(RefillESP) do
        if not aliveR[m] then
            if d.Mode == "Drawing" then
                pcall(function() d.Text:Destroy() end)
            elseif d.Highlight then
                d.Highlight:Destroy()
            end
            RefillESP[m] = nil
        end
    end

    if Settings.PlayerESP then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                if not PlayerESPObjects[pl] then
                    if HAS_DRAWING then CreatePlayerESP_Drawing(pl) else CreatePlayerESP_Highlight(pl) end
                end
                local d = PlayerESPObjects[pl]
                local ch = pl.Character
                local h = ch and ch:FindFirstChildOfClass("Humanoid")
                local rt = ch and ch:FindFirstChild("HumanoidRootPart")
                if h and rt and h.Health > 0 then
                    local pvpOff = pl:GetAttribute("PvPDisabled")
                    if d.Mode == "Drawing" then
                        local pos, on = Camera:WorldToViewportPoint(rt.Position)
                        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if on and myRoot then
                            local hpv = math.floor(h.Health)
                            local mx = math.floor(h.MaxHealth)
                            local pct = math.floor((h.Health / h.MaxHealth) * 100)
                            local pvpS = pvpOff and "OFF" or "ON"
                            local sh = pl:GetAttribute("AssignedShifterType")
                            local dist = (myRoot.Position - rt.Position).Magnitude
                            local scale = math.clamp(200 / math.max(dist, 1), 0.3, 3)
                            local size = Vector2.new(20 * scale, 35 * scale)
                            d.Box.Size = size
                            d.Box.Position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)
                            d.Box.Color = pvpOff and Color3.fromRGB(100,200,100) or Color3.fromRGB(255,60,60)
                            d.Box.Visible = true
                            d.Name.Position = Vector2.new(pos.X, pos.Y - size.Y / 2 - 40)
                            d.Name.Text = pl.Name .. (sh and " [" .. sh .. "]" or "")
                            d.Name.Visible = true
                            d.HP.Position = Vector2.new(pos.X, pos.Y - size.Y / 2 - 22)
                            d.HP.Text = "HP: " .. hpv .. "/" .. mx .. " (" .. pct .. "%)"
                            d.HP.Color = pct > 50 and Color3.fromRGB(100,255,100) or pct > 25 and Color3.fromRGB(255,200,60) or Color3.fromRGB(255,60,60)
                            d.HP.Visible = true
                            d.Distance.Position = Vector2.new(pos.X, pos.Y + size.Y / 2 + 5)
                            d.Distance.Text = "[" .. math.floor(dist) .. " studs] PvP: " .. pvpS
                            d.Distance.Visible = true
                        else
                            d.Box.Visible = false; d.Name.Visible = false; d.HP.Visible = false; d.Distance.Visible = false
                        end
                    else
                        if d.Highlight then
                            d.Highlight.Adornee = ch
                            d.Highlight.FillColor = pvpOff and Color3.fromRGB(100,200,100) or Color3.fromRGB(255,60,60)
                            d.Highlight.OutlineColor = d.Highlight.FillColor
                            d.Highlight.Enabled = true
                        end
                    end
                else
                    if d.Mode == "Drawing" then
                        d.Box.Visible = false; d.Name.Visible = false; d.HP.Visible = false; d.Distance.Visible = false
                    elseif d.Highlight then
                        d.Highlight.Enabled = false
                    end
                end
            end
        end
    else
        for _, d in pairs(PlayerESPObjects) do
            if d.Mode == "Drawing" then
                d.Box.Visible = false; d.Name.Visible = false; d.HP.Visible = false; d.Distance.Visible = false
            elseif d.Highlight then
                d.Highlight.Enabled = false
            end
        end
    end
end

function Init.Run()
    local AntiMod = _G.Venture.AntiMod
    if AntiMod then
        if AntiMod.Check() then return end
    end

    Theme.Load()
    Theme.Apply(Settings.Theme, false)

    if GUI.Boot then GUI.Boot() end

    if Keybinds then
        pcall(Keybinds.PopulateTab)
        pcall(Keybinds.Init)
    end

    if Security then
        pcall(Security.PopulateTab)
        pcall(Security.Init)
    end

    if Supa then
        pcall(Supa.Init)
    end

    local OnlineTab = _G.Venture.OnlineTab
    if OnlineTab then
        pcall(OnlineTab.PopulateTab)
    end

    local Chat = _G.Venture.Chat
    if Chat then
        pcall(Chat.PopulateTab)
    end

    local Announce = _G.Venture.Announce
    if Announce then
        pcall(Announce.PopulateTab)
        pcall(Announce.Init)
    end

    local ChatWindow = _G.Venture.ChatWindow
    if ChatWindow then
        pcall(ChatWindow.Init)
    end

    RunService.RenderStepped:Connect(function()
        pcall(UpdateESP)
    end)

    local Cursor = _G.Venture.Cursor
    if Cursor then pcall(Cursor.Init) end
end

_G.Venture = _G.Venture or {}
_G.Venture.Init = Init

return Init
