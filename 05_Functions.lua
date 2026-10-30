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
    currentTarget = nil,
    currentAlignPos = nil,
    currentAttachments = {},
    isReleasing = false,

    FarmState = {CurrentTitan=nil, LastKillTime=0, IsAttacking=false, OrbitAngle=0, AlignPos=nil, Attachments={}},
    HealerState = {IsHealing=false, SavedPosition=nil, LastHealTime=0},
    RefillState = {IsRefilling=false, SavedPosition=nil, LastRefillTime=0},
    QuestState = {LastQuestNPCPos=nil, IsDoingQuest=false, CurrentNPC=nil},
    SecurityState = {ModsInServer={}, IsPaused=false},

    originalPartData = {},
    expandedParts = {},
    noclipConnection = nil,
    fpsOriginalData = {},
    originalHitboxData = {},
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
                    if humanoid then alive = humanoid.Health > 0
                    else alive = model.Parent == aliveFolder end
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

function Functions.GetRefills()
    local refills = {}
    local folder = Workspace:FindFirstChild("Refills")
    if not folder then return refills end
    local ch = LocalPlayer.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    for _, model in ipairs(folder:GetChildren()) do
        if model.Name:lower():find("blade") or model.Name:lower():find("refill") then
            local part = model.PrimaryPart
            if not part then
                for _, p in ipairs(model:GetDescendants()) do
                    if p:IsA("BasePart") then part = p; break end
                end
            end
            if part then
                local dist = 9999
                if root then dist = (root.Position - part.Position).Magnitude end
                table.insert(refills, {Model = model, Part = part, Distance = dist})
            end
        end
    end
    table.sort(refills, function(a, b) return a.Distance < b.Distance end)
    return refills
end

function Functions.FindBladeState()
    if Settings.BladeStateValue and Settings.BladeStateValue.Parent then
        return Settings.BladeStateValue
    end
    local ch = LocalPlayer.Character
    if not ch then return nil end
    for _, obj in ipairs(ch:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            local n = obj.Name:lower()
            if n:find("blade") and (n:find("state") or n:find("sharp") or n:find("dura")) then
                Settings.BladeStateValue = obj
                return obj
            end
        end
    end
    return nil
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
        if Settings.HitboxShowVisual then
            part.Transparency = Settings.HitboxTransparency
            part.Color = Settings.HitboxColor
        else
            if S.originalPartData[part] then
                part.Transparency = S.originalPartData[part].Transparency
                part.Color = S.originalPartData[part].Color
            end
        end
        part.CanCollide = false
        part.Massless = true
        part.CanTouch = true
        part.CanQuery = true
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
    local Terrain = Workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        pcall(function()
            Terrain.Decoration = false
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end)
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

function Functions.TriggerAutoRefill()
    if S.RefillState.IsRefilling then return false end
    local ch = LocalPlayer.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local refills = Functions.GetRefills()
    if #refills == 0 then return false end

    Settings.AutoFarmEnabled = false
    S.FarmState.IsAttacking = false
    S.FarmState.CurrentTitan = nil
    Functions.CleanupFarm()

    S.RefillState.SavedPosition = root.CFrame
    S.RefillState.IsRefilling = true
    local r = refills[1]
    root.CFrame = CFrame.new(r.Part.Position + Vector3.new(0, 5, 0))
    root.Velocity = Vector3.zero
    root.AssemblyLinearVelocity = Vector3.zero

    task.spawn(function()
        task.wait(Settings.AutoBladeRefillReturnDelay)
        local r2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if r2 and S.RefillState.SavedPosition then
            r2.CFrame = S.RefillState.SavedPosition
            r2.Velocity = Vector3.zero
            r2.AssemblyLinearVelocity = Vector3.zero
        end
        S.RefillState.IsRefilling = false
        S.RefillState.SavedPosition = nil
        S.RefillState.LastRefillTime = tick()
        task.wait(0.3)
        Settings.AutoFarmEnabled = true
    end)
    return true
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if Settings.AutoRefillEnabled and not S.RefillState.IsRefilling then
            if tick() - S.RefillState.LastRefillTime < 5 then continue end
            local bv = Functions.FindBladeState()
            if bv and bv.Value <= Settings.AutoBladeRefillThreshold then
                Functions.TriggerAutoRefill()
            end
        end
    end
end)

local function FindQuestNPCs()
    local q = Workspace:FindFirstChild("Quests")
    if not q then return {} end
    local npcs = {}
    for _, o in ipairs(q:GetChildren()) do
        if o:IsA("Model") then table.insert(npcs, o) end
    end
    return npcs
end

local function TriggerQuestNPC(npc)
    if not npc then return end
    local ch = LocalPlayer.Character
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if not root then return end
    S.QuestState.LastQuestNPCPos = root.CFrame
    S.QuestState.CurrentNPC = npc
    local np = npc:GetPivot().Position
    root.CFrame = CFrame.new(np + Vector3.new(0, 3, 0))
    root.Velocity = Vector3.zero
    task.wait(0.5)
    for i = 1, 3 do Functions.PressE(); task.wait(0.3) end
end

do
    local RS = game:GetService("ReplicatedStorage")
    local Remotes = RS:WaitForChild("Remotes", 10)
    if Remotes then
        local Mission = Remotes:FindFirstChild("Mission")
        if Mission then
            local ed = Mission:FindFirstChild("Ended")
            if ed then
                ed.OnClientEvent:Connect(function()
                    Settings.AutoFarmEnabled = false
                    task.wait(0.5)
                    if S.QuestState.LastQuestNPCPos then
                        local r = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if r then r.CFrame = S.QuestState.LastQuestNPCPos end
                        task.wait(0.5)
                        if S.QuestState.CurrentNPC then
                            for i = 1, 3 do Functions.PressE(); task.wait(0.3) end
                        end
                    end
                    S.QuestState.IsDoingQuest = false
                    Settings.AutoQuestEnabled = false
                end)
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if Settings.AutoQuestEnabled and not S.QuestState.IsDoingQuest then
            local npcs = FindQuestNPCs()
            if #npcs > 0 then
                local target = npcs[1]
                if Settings.AutoQuestSelected then
                    for _, npc in ipairs(npcs) do
                        if npc.Name:lower():find(Settings.AutoQuestSelected:lower()) then
                            target = npc
                            break
                        end
                    end
                end
                S.QuestState.IsDoingQuest = true
                TriggerQuestNPC(target)
                task.wait(2)
                Settings.AutoFarmEnabled = true
            end
        end
    end
end)

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
            if S.RefillState.IsRefilling then break end
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
        if S.SecurityState.IsPaused or S.RefillState.IsRefilling then continue end
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

function Functions.ForceResetState()
    local ch = LocalPlayer.Character
    if ch then
        for _, obj in ipairs(ch:GetDescendants()) do
            if obj:IsA("AlignPosition") or obj:IsA("AlignOrientation") or obj:IsA("BodyVelocity") then
                if obj.Name:find("VentureAOT") or obj.Name == "BodyVelocity" then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
        local hum = ch:FindFirstChildOfClass("Humanoid")
        local root = ch:FindFirstChild("HumanoidRootPart")
        if hum then
            hum.PlatformStand = false
            hum.AutoRotate = true
            pcall(function()
                Camera.CameraSubject = hum
                Camera.CameraType = Enum.CameraType.Custom
            end)
        end
        if root then
            root.Velocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end
    S.currentTarget = nil
    S.currentAlignPos = nil
    S.currentAttachments = {}
    S.isReleasing = false
end

function Functions.CleanupStick(safeRelease)
    local ch = LocalPlayer.Character
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    local root = ch and ch:FindFirstChild("HumanoidRootPart")
    if hum then
        pcall(function()
            Camera.CameraSubject = hum
            Camera.CameraType = Enum.CameraType.Custom
        end)
        hum.PlatformStand = false
        hum.AutoRotate = true
    end
    if S.currentAlignPos then pcall(function() S.currentAlignPos:Destroy() end); S.currentAlignPos = nil end
    for _, a in ipairs(S.currentAttachments) do
        if a and a.Parent then pcall(function() a:Destroy() end) end
    end
    S.currentAttachments = {}
    if root then
        root.Velocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
    end
    if safeRelease and root and not S.isReleasing then
        S.isReleasing = true
        local away = Vector3.new(0, 1, 0)
        if S.currentTarget and S.currentTarget.Nape and S.currentTarget.Nape.Parent then
            away = (root.Position - S.currentTarget.Nape.Position).Unit
            if math.abs(away.Y) > 0.9 then
                away = (away + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))).Unit
            end
        end
        local up = Vector3.new(0, Settings.ReleaseUpVelocity, 0)
        local side = away * Settings.ReleaseSideVelocity
        root.Velocity = up + side
        root.AssemblyLinearVelocity = up + side
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = up + side
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.P = 10000
        bv.Parent = root
        task.delay(0.2, function()
            if bv and bv.Parent then bv:Destroy() end
            S.isReleasing = false
        end)
    end
end

function Functions.StickToTitan(titan)
    if not titan or not titan.Nape or not titan.Nape.Parent then
        Functions.CleanupStick(true)
        return false
    end
    Functions.ForceResetState()
    local ch = LocalPlayer.Character
    if not ch then return false end
    local root = ch:FindFirstChild("HumanoidRootPart")
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return false end
    S.currentTarget = titan
    local np = titan.Nape.Position
    local ncf = titan.Nape.CFrame
    local standPos = np - ncf.LookVector * Settings.BackOffset + ncf.RightVector * Settings.SideOffset + Vector3.new(0, Settings.UpOffset, 0)
    root.CFrame = CFrame.new(standPos, np)
    root.Velocity = Vector3.zero
    root.AssemblyLinearVelocity = Vector3.zero
    hum.PlatformStand = true
    local na = Instance.new("Attachment"); na.Name = "VentureAOT_NapeAtt"; na.Parent = titan.Nape
    table.insert(S.currentAttachments, na)
    local ra = Instance.new("Attachment"); ra.Name = "VentureAOT_RootAttPos"; ra.Parent = root
    table.insert(S.currentAttachments, ra)
    local ao = Instance.new("AlignPosition")
    ao.Attachment0 = ra
    ao.Attachment1 = na
    ao.Mode = Enum.PositionAlignmentMode.TwoAttachment
    ao.Responsiveness = 200
    ao.MaxVelocity = math.huge
    ao.MaxForce = math.huge
    ao.Position = Vector3.new(Settings.SideOffset, Settings.UpOffset, Settings.BackOffset)
    ao.Parent = root
    S.currentAlignPos = ao
    return true
end

function Functions.TeleportToRefill(refill)
    if not refill or not refill.Part or not refill.Part.Parent then return false end
    Functions.ForceResetState()
    local ch = LocalPlayer.Character
    if not ch then return false end
    local root = ch:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    root.CFrame = CFrame.new(refill.Part.Position + Vector3.new(0, 5, 0))
    root.Velocity = Vector3.zero
    root.AssemblyLinearVelocity = Vector3.zero
    return true
end

_G.Venture = _G.Venture or {}
_G.Venture.Functions = Functions

return Functions
