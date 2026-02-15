local VenyxLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Documantation12/Universal-Vehicle-Script/main/Library.lua"))()
local Venyx = VenyxLibrary.new("Universal Vehicle + Mining Script", 5013109572)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")

local Theme = {
	Background = Color3.fromRGB(61, 60, 124), 
	Glow = Color3.fromRGB(60, 63, 221), 
	Accent = Color3.fromRGB(55, 52, 90), 
	LightContrast = Color3.fromRGB(64, 65, 128), 
	DarkContrast = Color3.fromRGB(32, 33, 64),  
	TextColor = Color3.fromRGB(255, 255, 255)
}

for index, value in pairs(Theme) do
	pcall(Venyx.setTheme, Venyx, index, value)
end

-- Сохранение дефолтного освещения
local defaultAmbient = Lighting.Ambient
local defaultColorBottom = Lighting.ColorShift_Bottom
local defaultColorTop = Lighting.ColorShift_Top

local function GetVehicleFromDescendant(Descendant)
	if not Descendant then return nil end
	return
		Descendant:FindFirstAncestor(LocalPlayer.Name .. "\'s Car") or
		(Descendant:FindFirstAncestor("Body") and Descendant:FindFirstAncestor("Body").Parent) or
		(Descendant:FindFirstAncestor("Misc") and Descendant:FindFirstAncestor("Misc").Parent) or
		Descendant:FindFirstAncestorWhichIsA("Model")
end

local vehiclePage = Venyx:addPage("Vehicle", 8356815386)

local usageSection = vehiclePage:addSection("Usage")
local velocityEnabled = true
usageSection:addToggle("Keybinds Active", velocityEnabled, function(v) velocityEnabled = v end)

local flightSection = vehiclePage:addSection("Flight")
local flightEnabled = false
local flightSpeed = 1
flightSection:addToggle("Enabled", false, function(v) flightEnabled = v end)
flightSection:addSlider("Speed", 100, 0, 800, function(v) flightSpeed = v / 100 end)

local defaultCharacterParent 
RunService.Stepped:Connect(function()
	local Character = LocalPlayer.Character
	if not Character then return end

	if flightEnabled then
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		if not Humanoid or not Humanoid.SeatPart or not Humanoid.SeatPart:IsA("VehicleSeat") then return end

		local SeatPart = Humanoid.SeatPart
		local Vehicle = GetVehicleFromDescendant(SeatPart)
		if not Vehicle or not Vehicle:IsA("Model") then return end

		pcall(function()
			Character.Parent = Vehicle
			if not Vehicle.PrimaryPart then
				Vehicle.PrimaryPart = SeatPart or Vehicle:FindFirstChildWhichIsA("BasePart")
			end

			local PrimaryPartCFrame = Vehicle:GetPrimaryPartCFrame()
			local look = workspace.CurrentCamera.CFrame.LookVector

			local moveX = (UserInputService:IsKeyDown(Enum.KeyCode.D) and flightSpeed or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and flightSpeed or 0)
			local moveY = (UserInputService:IsKeyDown(Enum.KeyCode.E) and flightSpeed/2 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.Q) and flightSpeed/2 or 0)
			local moveZ = (UserInputService:IsKeyDown(Enum.KeyCode.S) and flightSpeed or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and flightSpeed or 0)

			Vehicle:SetPrimaryPartCFrame(CFrame.new(PrimaryPartCFrame.Position, PrimaryPartCFrame.Position + look) * CFrame.new(moveX, moveY, moveZ))
			SeatPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
			SeatPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
		end)
	else
		Character.Parent = defaultCharacterParent or workspace
		defaultCharacterParent = Character.Parent
	end
end)

local speedSection = vehiclePage:addSection("Acceleration")
local velocityMult = 0.025
speedSection:addSlider("Multiplier (Thousandths)", 25, 0, 50, function(v) velocityMult = v / 1000 end)

local velocityEnabledKeyCode = Enum.KeyCode.W
speedSection:addKeybind("Velocity Enabled", velocityEnabledKeyCode, function()
	if not velocityEnabled then return end
	while UserInputService:IsKeyDown(velocityEnabledKeyCode) do
		task.wait()
		local Character = LocalPlayer.Character
		if not Character then continue end
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		if not Humanoid or not Humanoid.SeatPart or not Humanoid.SeatPart:IsA("VehicleSeat") then continue end

		pcall(function()
			Humanoid.SeatPart.AssemblyLinearVelocity *= Vector3.new(1 + velocityMult, 1, 1 + velocityMult)
		end)
	end
end, function(v) velocityEnabledKeyCode = v.KeyCode end)

local decelerateSection = vehiclePage:addSection("Deceleration")
local qbEnabledKeyCode = Enum.KeyCode.S
local velocityMult2 = 0.150
decelerateSection:addSlider("Brake Force (Thousandths)", 150, 0, 300, function(v) velocityMult2 = v / 1000 end)

decelerateSection:addKeybind("Quick Brake Enabled", qbEnabledKeyCode, function()
	if not velocityEnabled then return end
	while UserInputService:IsKeyDown(qbEnabledKeyCode) do
		task.wait()
		local Character = LocalPlayer.Character
		if not Character then continue end
		local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
		if not Humanoid or not Humanoid.SeatPart or not Humanoid.SeatPart:IsA("VehicleSeat") then continue end

		pcall(function()
			Humanoid.SeatPart.AssemblyLinearVelocity *= Vector3.new(1 - velocityMult2, 1, 1 - velocityMult2)
		end)
	end
end, function(v) qbEnabledKeyCode = v.KeyCode end)

decelerateSection:addKeybind("Stop the Vehicle", Enum.KeyCode.P, function()
	if not velocityEnabled then return end
	local Character = LocalPlayer.Character
	if not Character then return end
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	if not Humanoid or not Humanoid.SeatPart or not Humanoid.SeatPart:IsA("VehicleSeat") then return end

	pcall(function()
		Humanoid.SeatPart.AssemblyLinearVelocity = Vector3.new(0,0,0)
		Humanoid.SeatPart.AssemblyAngularVelocity = Vector3.new(0,0,0)
	end)
end)

local springSection = vehiclePage:addSection("Springs")
springSection:addToggle("Visible", false, function(v)
	local Character = LocalPlayer.Character
	if not Character then return end
	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	if not Humanoid or not Humanoid.SeatPart then return end

	local Vehicle = GetVehicleFromDescendant(Humanoid.SeatPart)
	if not Vehicle then return end

	for _, SpringConstraint in pairs(Vehicle:GetDescendants()) do
		if SpringConstraint:IsA("SpringConstraint") then
			SpringConstraint.Visible = v
		end
	end
end)

local fuelSection = vehiclePage:addSection("Fuel")
local infFuelEnabled = false
fuelSection:addToggle("Infinite Fuel", false, function(v) infFuelEnabled = v end)

RunService.Heartbeat:Connect(function()
	if not infFuelEnabled then return end
	local veh = GetVehicleFromDescendant(LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and LocalPlayer.Character.Humanoid.SeatPart)
	if not veh then return end

	for _, value in pairs(veh:GetDescendants()) do
		if (value:IsA("NumberValue") or value:IsA("IntValue")) then
			local name = value.Name:lower()
			if name:find("fuel") or name:find("gas") or name:find("energy") or name:find("battery") then
				value.Value = math.huge
			end
		end
	end
end)

-- Visuals Page
local visualsPage = Venyx:addPage("Visuals")

local fbSection = visualsPage:addSection("Lighting")
local fbEnabled = false

local function dofullbright()
	Lighting.Ambient = Color3.new(1,1,1)
	Lighting.ColorShift_Bottom = Color3.new(1,1,1)
	Lighting.ColorShift_Top = Color3.new(1,1,1)
end

local function resetLighting()
	Lighting.Ambient = defaultAmbient
	Lighting.ColorShift_Bottom = defaultColorBottom
	Lighting.ColorShift_Top = defaultColorTop
end

fbSection:addToggle("Fullbright", false, function(v)
	fbEnabled = v
	if v then
		dofullbright()
	else
		resetLighting()
	end
end)

Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
	if fbEnabled then dofullbright() end
end)

local oreEspEnabled = false
visualsPage:addSection("ESP"):addToggle("Ore ESP (1 на тип)", false, function(v)
	oreEspEnabled = v
	if not v then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:FindFirstChild("OreHighlight") then obj.OreHighlight:Destroy() end
			if obj:FindFirstChild("OreLabel") then obj.OreLabel:Destroy() end
		end
		seenOreTypes = {}
	end
end)

-- Оптимизированный ESP: одна метка на уникальное имя руды
local seenOreTypes = {}

local ESP_UPDATE_INTERVAL = 3
local lastCheck = 0

RunService.Heartbeat:Connect(function()
	if not oreEspEnabled then return end
	if tick() - lastCheck < ESP_UPDATE_INTERVAL then return end
	lastCheck = tick()

	for _, obj in pairs(workspace:GetDescendants()) do
		local nameLower = obj.Name:lower()
		if (obj:IsA("BasePart") or obj:IsA("MeshPart")) and
		   (nameLower:find("ore") or nameLower:find("rock") or nameLower:find("resource") or nameLower:find("mineral")) and
		   not seenOreTypes[obj.Name] and
		   not obj:FindFirstChild("OreHighlight") then

			seenOreTypes[obj.Name] = true

			local hl = Instance.new("Highlight")
			hl.Name = "OreHighlight"
			hl.FillColor = Color3.fromRGB(255,215,0)
			hl.OutlineColor = Color3.fromRGB(255,255,0)
			hl.FillTransparency = 0.6
			hl.Parent = obj

			local bb = Instance.new("BillboardGui")
			bb.Name = "OreLabel"
			bb.AlwaysOnTop = true
			bb.Size = UDim2.new(0, 160, 0, 40)
			bb.StudsOffset = Vector3.new(0, 5, 0)
			bb.Parent = obj

			local frame = Instance.new("Frame", bb)
			frame.Size = UDim2.new(1,0,1,0)
			frame.BackgroundColor3 = Color3.new(0,0,0)
			frame.BackgroundTransparency = 0.65
			frame.BorderSizePixel = 0

			local txt = Instance.new("TextLabel", frame)
			txt.Size = UDim2.new(1, -10, 1, -4)
			txt.Position = UDim2.new(0,5,0,2)
			txt.BackgroundTransparency = 1
			txt.Text = obj.Name
			txt.TextColor3 = Color3.fromRGB(255,255,100)
			txt.TextScaled = true
			txt.Font = Enum.Font.GothamBold
			txt.TextStrokeTransparency = 0.4
			txt.TextStrokeColor3 = Color3.new(0,0,0)
		end
	end

	for name, _ in pairs(seenOreTypes) do
		local found = false
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj.Name == name then found = true break end
		end
		if not found then seenOreTypes[name] = nil end
	end
end)

-- Information Page
local infoPage = Venyx:addPage("Information", 8356778308)
local discordSection = infoPage:addSection("Discord")
discordSection:addButton("Copy Discord Link", function()
	setclipboard("https://discord.com/invite/ENHYznSPmM")
end)

-- Перетаскиваемая кнопка (мобильная)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToggleButtonGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(1, -80, 1, -80)
toggleButton.Text = "M"
toggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleButton.BackgroundTransparency = 0.6
toggleButton.TextColor3 = Color3.fromRGB(220, 220, 220)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 28
toggleButton.BorderSizePixel = 0
toggleButton.Parent = screenGui

-- Drag logic (ПК + мобильный)
local dragging, dragInput, dragStart, startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	toggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

toggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = toggleButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

toggleButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateDrag(input)
	end
end)

toggleButton.MouseButton1Click:Connect(function()
	Venyx:toggle()
end)

-- Toggle on Left Alt
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftAlt then
		Venyx:toggle()
	end
end)
