local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils

local Players = Shared.Players
local RunService = Shared.RunService
local Workspace = Shared.Workspace
local Lighting = Shared.Lighting
local VirtualInputManager = Shared.VirtualInputManager
local LocalPlayer = Shared.LocalPlayer
local Camera = Shared.Camera
local Settings = Config.Settings

local Functions = {}

Functions.State = {
    FarmState = {CurrentTitan=nil, LastKillTime=0, IsAttacking=false, OrbitAngle=0, AlignPos=nil, Attachments={}},
    HealerState = {IsHealing=false, SavedPosition=nil, LastHealTime=0},
    SecurityState = {ModsInServer={}, IsPaused=false},
    originalPartData = {},
    expandedParts = {},
    noclipConnection = nil,
    fpsOriginalData = {},
    ESPObjects = {},
    PlayerESPObjects = {},
    ShifterESPObjects = {}
}

local S = Functions.State

function Functions.GetTitans()
    local titans = {}
    local titansFolder = Workspace:FindFirstChild("Titans")
    local aliveFolder = titansFolder and titansFolder:FindFirstChild("Alive")
    if not aliveFolder then return titans end
    local ch = LocalPlayer.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    for _, model in ipairs(aliveFolder:GetChildren()) do
        if model:IsA("Model") then
            local hitboxes = model:FindFirstChild("Hitboxes")
            if hitboxes then
                local nape = hitboxes:FindFirstChild("Nape")
                local head = hitboxes:FindFirstChild("Head")
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                if nape and nape:IsA("BasePart") then
                    local alive = true
                    if humanoid then alive = humanoid.Health > 0 else alive = model.Parent == aliveFolder end
                    if model:GetAttribute("Dead") == true then alive = false end
                    if model:GetAttribute("HeadChopped") == true then alive = false end
                    if alive then
                        local dist = 9999
                        if root then dist = (root.Position - nape.Position).Magnitude end
                        table.insert(titans, {
                            Model = model, Nape = nape,
                            Head = (head and head:IsA("BasePart")) and head or nape,
                            Humanoid = humanoid, Distance = dist
                        })
                    end
                end
            end
        end
    end
    table.sort(titans, function(a, b) return a.Distance < b.Distance end)
    return titans
end

local function ApplyHitboxToPart(part, partName)
    if not Settings.HitboxParts[partName] then return end
    if not part or not part.Parent or not part:IsA("BasePart") then return end

    if not S.originalPartData[part] then
        S.originalPartData[part] = {
            Size = part.Size, Shape = part.Shape,
            Transparency = part.Transparency, Color = part.Color,
            CanCollide = part.CanCollide, Massless = part.Massless,
            CanTouch = part.CanTouch, CanQuery = part.CanQuery
        }
    end

    pcall(function()
        part.Size = Settings.HitboxSize
        if Settings.HitboxShape == "Ball" then part.Shape = Enum.PartType.Ball
        elseif Settings.HitboxShape == "Cylinder" then part.Shape = Enum.PartType.Cylinder
        else part.Shape = Enum.PartType.Block end

        part.CanCollide = false
        part.Massless = true
        part.CanTouch = true
        part.CanQuery = true

        local oldVisual = part:FindFirstChild("VentureHitboxVisual")
        if oldVisual then oldVisual:Destroy() end

        if Settings.HitboxShowVisual then
            local box = Instance.new("SelectionBox")
            box.Name = "VentureHitboxVisual"
            box.Adornee = part
            box.Color3 = Settings.HitboxVisualColor or Color3.fromRGB(255, 100, 200)
            box.SurfaceColor3 = Settings.HitboxVisualColor or Color3.fromRGB(255, 100, 200)
            box.SurfaceTransparency = Settings.HitboxVisualTransparency or 0.5
            box.LineThickness = 0.1
            box.Transparency = 0.2
            box.Parent = part
        end
    end)

    S.expandedParts[part] = true
end

function Functions.ApplyHitboxToAll()
    if not Settings.HitboxExpand then return end
    for _, t in ipairs(Functions.GetTitans()) do
        local hb = t.Model:FindFirstChild("Hitboxes")
        if hb then
            for partName, enabled in pairs(Settings.HitboxParts) do
                if enabled then
                    local p = hb:FindFirstChild(partName)
                    if p then ApplyHitboxToPart(p, partName) end
                end
            end
        end
    end
end

local function ResetHitboxPart(part)
    if not part or not S.originalPartData[part] then return end
    local orig = S.originalPartData[part]
    pcall(function()
        if part.Parent then
            part.Size = orig.Size; part.Shape = orig.Shape
            part.Transparency = orig.Transparency; part.Color = orig.Color
            part.CanCollide = orig.CanCollide; part.Massless = orig.Massless
            part.CanTouch = orig.CanTouch; part.CanQuery = orig.CanQuery
        end
    end)
    S.expandedParts[part] = nil
end

function Functions.ResetAllHitboxes()
    for p, _ in pairs(S.expandedParts) do ResetHitboxPart(p) end
    S.expandedParts = {}
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if Settings.HitboxExpand then pcall(Functions.ApplyHitboxToAll) end
    end
end)

function Functions.StartNoclip()
    if S.noclipConnection then return end
    S.noclipConnection = RunService.Stepped:Connect(function()
        if not Settings.Noclip then return end
        local ch = LocalPlayer.Character
        if not ch then return end
        for _, part in ipairs(ch:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

function Functions.StopNoclip()
    if S.noclipConnection then
        S.noclipConnection:Disconnect()
        S.noclipConnection = nil
    end
    local ch = LocalPlayer.Character
    if ch then
        for _, part in ipairs(ch:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = true end)
            end
        end
    end
end

function Functions.EnableFPSBooster()
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("PostEffect") or e:IsA("Atmosphere") then
            pcall(function() S.fpsOriginalData[e] = e.Enabled; e.Enabled = false end)
        end
    end
    S.fpsOriginalData.GlobalShadows = Lighting.GlobalShadows
    S.fpsOriginalData.ShadowSoftness = Lighting.ShadowSoftness
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke") or o:IsA("Fire") then
            pcall(function() S.fpsOriginalData[o] = o.Enabled; o.Enabled = false end)
        elseif o:IsA("Decal") or o:IsA("Texture") then
            pcall(function() S.fpsOriginalData[o] = o.Transparency; o.Transparency = 1 end)
        end
    end
end

function Functions.DisableFPSBooster()
    for obj, val in pairs(S.fpsOriginalData) do
        if typeof(obj) == "Instance" and obj.Parent then
            pcall(function()
                if obj:IsA("PostEffect") or obj:IsA("Atmosphere") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                    obj.Enabled = val
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = val
                end
            end)
        end
    end
    if S.fpsOriginalData.GlobalShadows ~= nil then
        Lighting.GlobalShadows = S.fpsOriginalData.GlobalShadows
        Lighting.ShadowSoftness = S.fpsOriginalData.ShadowSoftness
    end
    S.fpsOriginalData = {}
end

function Functions.PressE()
    local ch = LocalPlayer.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if root then
        local nearest, nearestDist = nil, 15
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local parent = obj.Parent
                local pos
                if parent and parent:IsA("BasePart") then pos = parent.Position
                elseif parent and parent:IsA("Attachment") and parent.Parent then pos = parent.WorldPosition end
                if pos then
                    local d = (root.Position - pos).Magnitude
                    if d < nearestDist then nearestDist = d; nearest = obj end
                end
            end
        end
        if nearest then
            pcall(function()
                nearest:InputHoldBegin()
                task.wait(0.1)
                nearest:InputHoldEnd()
            end)
            return
        end
    end
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local function FindHealer()
    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end
    return map:FindFirstChild("Healer")
end

function Functions.TriggerAutoHeal()
    if S.HealerState.IsHealing then return end
    local ch = LocalPlayer.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if not root then return end
    S.HealerState.SavedPosition = root.CFrame
    S.HealerState.IsHealing = true
    local healer = FindHealer()
    if not healer then S.HealerState.IsHealing = false; return end
    local hp = healer:GetPivot().Position
    root.CFrame = CFrame.new(hp + Vector3.new(0, 3, 0))
    root.Velocity = Vector3.zero
    root.AssemblyLinearVelocity = Vector3.zero
    task.spawn(function()
        task.wait(0.6)
        for i = 1, 5 do Functions.PressE(); task.wait(0.3) end
        local start = tick()
        while tick() - start < 12 do
            task.wait(0.3)
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h and h.Health >= h.MaxHealth then break end
        end
        task.wait(0.3)
        local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r and S.HealerState.SavedPosition then
            r.CFrame = S.HealerState.SavedPosition
            r.Velocity = Vector3.zero
            r.AssemblyLinearVelocity = Vector3.zero
        end
        S.HealerState.IsHealing = false
        S.HealerState.SavedPosition = nil
        S.HealerState.LastHealTime = tick()
    end)
end

task.spawn(function()
    while true do
        task.wait(1)
        if Settings.AutoHealEnabled and not S.HealerState.IsHealing then
            if tick() - S.HealerState.LastHealTime < 5 then continue end
            local ch = LocalPlayer.Character
            local h = ch and ch:FindFirstChildOfClass("Humanoid")
            if h then
                local p = (h.Health / h.MaxHealth) * 100
                if p < Settings.AutoHealThreshold then Functions.TriggerAutoHeal() end
            end
        end
    end
end)

function Functions.CleanupFarm()
    if S.FarmState.AlignPos and S.FarmState.AlignPos.Parent then
        S.FarmState.AlignPos:Destroy()
    end
    S.FarmState.AlignPos = nil
    for _, a in ipairs(S.FarmState.Attachments) do
        if a and a.Parent then a:Destroy() end
    end
    S.FarmState.Attachments = {}
    S.FarmState.OrbitAngle = 0
end

local function GetNearestTitanDist()
    local ch = LocalPlayer.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if not root then return 9999, nil end
    local af = Workspace:FindFirstChild("Titans") and Workspace.Titans:FindFirstChild("Alive")
    if not af then return 9999, nil end
    local nd, nt = 9999, nil
    for _, m in ipairs(af:GetChildren()) do
        if m:IsA("Model") and m:GetAttribute("Dead") ~= true and m:GetAttribute("HeadChopped") ~= true then
            local d = (root.Position - m:GetPivot().Position).Magnitude
            if d < nd then nd = d; nt = m end
        end
    end
    return nd, nt
end

local function IsTitanDead(t)
    if not t or not t.Model or not t.Model.Parent or not t.Nape or not t.Nape.Parent then return true end
    if t.Humanoid and t.Humanoid.Health <= 0 then return true end
    if t.Model:GetAttribute("Dead") == true or t.Model:GetAttribute("HeadChopped") == true then return true end
    local af = Workspace:FindFirstChild("Titans") and Workspace.Titans:FindFirstChild("Alive")
    if af and t.Model.Parent ~= af then return true end
    return false
end

local function HoverAroundTitan(titan)
    if S.FarmState.IsAttacking then return end
    S.FarmState.IsAttacking = true
    local ch = LocalPlayer.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not root or not hum or not titan.Nape.Parent then
        S.FarmState.IsAttacking = false
        return
    end
    hum.PlatformStand = true
    if Settings.Noclip then Functions.StartNoclip() end
    if Settings.HitboxExpand then Functions.ApplyHitboxToAll() end

    local rootAtt = Instance.new("Attachment")
    rootAtt.Name = "VentureAOT_RootAtt"
    rootAtt.Parent = root
    table.insert(S.FarmState.Attachments, rootAtt)

    local alignPos = Instance.new("AlignPosition")
    alignPos.Name = "VentureAOT_AlignPos"
    alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
    alignPos.Attachment0 = rootAtt
    alignPos.Position = root.Position
    alignPos.Responsiveness = Settings.AutoFarmResponsiveness
    alignPos.MaxForce = math.huge
    alignPos.MaxVelocity = math.huge
    alignPos.RigidityEnabled = false
    alignPos.ApplyAtCenterOfMass = false
    alignPos.Parent = root
    S.FarmState.AlignPos = alignPos

    local start = tick()
    task.spawn(function()
        while true do
            local dt = RunService.Heartbeat:Wait()
            if not Settings.AutoFarmEnabled then break end
            if S.SecurityState.IsPaused then break end
            if not root.Parent or not titan.Nape.Parent then break end
            if S.FarmState.CurrentTitan ~= titan then break end
            if IsTitanDead(titan) then break end
            if tick() - start > 30 then break end

            local nd, nt = GetNearestTitanDist()
            if nd < Settings.AutoFarmSafeDistance and nt then
                local np = nt:GetPivot().Position
                local away = (root.Position - np).Unit
                local safe = np + away * (Settings.AutoFarmSafeDistance + 25)
                local target = Vector3.new(safe.X, safe.Y + Settings.AutoFarmHoverHeight, safe.Z)
                if alignPos then
                    alignPos.Position = target
                    alignPos.Responsiveness = 30
                end
                continue
            end

            local center = titan.Nape.Position
            local angSpd = Settings.AutoFarmOrbitSpeed / Settings.AutoFarmOrbitRadius
            S.FarmState.OrbitAngle = S.FarmState.OrbitAngle + angSpd * dt
            local ox = math.cos(S.FarmState.OrbitAngle) * Settings.AutoFarmOrbitRadius
            local oz = math.sin(S.FarmState.OrbitAngle) * Settings.AutoFarmOrbitRadius
            local target = center + Vector3.new(ox, Settings.AutoFarmHoverHeight, oz)
            if alignPos then
                alignPos.Position = target
                alignPos.Responsiveness = Settings.AutoFarmResponsiveness
            end
        end
        Functions.CleanupFarm()
        task.wait(0.2)
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
        end
        S.FarmState.IsAttacking = false
    end)
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if not Settings.AutoFarmEnabled then
            S.FarmState.IsAttacking = false
            S.FarmState.CurrentTitan = nil
            continue
        end
        if S.SecurityState.IsPaused then continue end
        if tick() - S.FarmState.LastKillTime < Settings.AutoFarmDelay then continue end
        if S.FarmState.CurrentTitan and IsTitanDead(S.FarmState.CurrentTitan) then
            S.FarmState.LastKillTime = tick()
            S.FarmState.CurrentTitan = nil
            S.FarmState.IsAttacking = false
            Functions.CleanupFarm()
            continue
        end
        if not S.FarmState.IsAttacking and not S.FarmState.CurrentTitan then
            local titans = Functions.GetTitans()
            if #titans > 0 then
                S.FarmState.CurrentTitan = titans[1]
                HoverAroundTitan(titans[1])
            end
        end
    end
end)

function Functions.UpdateESP()
    local titans = Functions.GetTitans()
    local aliveTitans = {}
    for _, t in ipairs(titans) do
        aliveTitans[t.Model] = true
        if Settings.ESP then
            if not S.ESPObjects[t.Model] then
                local hl = Instance.new("Highlight")
                hl.FillTransparency = 0.5
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = t.Model
                hl.Parent = t.Model
                S.ESPObjects[t.Model] = hl
            end
            S.ESPObjects[t.Model].FillColor = Settings.ESPColor or Color3.fromRGB(255, 60, 60)
            S.ESPObjects[t.Model].OutlineColor = Settings.ESPColor or Color3.fromRGB(255, 60, 60)
            S.ESPObjects[t.Model].Enabled = true
        end
    end
    for m, hl in pairs(S.ESPObjects) do
        if not aliveTitans[m] or not Settings.ESP then
            hl:Destroy()
            S.ESPObjects[m] = nil
        end
    end

    local alivePlayers = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            alivePlayers[pl.Character] = true
            if Settings.PlayerESP then
                if not S.PlayerESPObjects[pl.Character] then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(0, 255, 0)
                    hl.OutlineColor = Color3.fromRGB(0, 255, 0)
                    hl.FillTransparency = 0.5
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Adornee = pl.Character
                    hl.Parent = pl.Character
                    S.PlayerESPObjects[pl.Character] = hl
                end
                S.PlayerESPObjects[pl.Character].Enabled = true
            end
        end
    end
    for m, hl in pairs(S.PlayerESPObjects) do
        if not alivePlayers[m] or not Settings.PlayerESP then
            hl:Destroy()
            S.PlayerESPObjects[m] = nil
        end
    end
    
    local aliveShifters = {}
    local chars = Workspace:FindFirstChild("Characters")
    if chars then
        for _, model in ipairs(chars:GetChildren()) do
            if model:GetAttribute("IsPlayerShifter") then
                aliveShifters[model] = true
                if Settings.ShifterESP then
                    if not S.ShifterESPObjects[model] then
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(255, 165, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 165, 0)
                        hl.FillTransparency = 0.5
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Adornee = model
                        hl.Parent = model
                        S.ShifterESPObjects[model] = hl
                    end
                    S.ShifterESPObjects[model].Enabled = true
                end
            end
        end
    end
    for m, hl in pairs(S.ShifterESPObjects) do
        if not aliveShifters[m] or not Settings.ShifterESP then
            hl:Destroy()
            S.ShifterESPObjects[m] = nil
        end
    end
end

RunService.RenderStepped:Connect(function() pcall(Functions.UpdateESP) end)

function Functions.ToggleInfiniteSupplies(state)
    Workspace:SetAttribute("StressTest", state)
end

_G.Venture = _G.Venture or {}
_G.Venture.Functions = Functions

return Functions
