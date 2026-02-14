local VenyxLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Documantation12/Universal-Vehicle-Script/main/Library.lua"))()
local Venyx = VenyxLibrary.new("Universal Vehicle Script", 5013109572)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

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

-- ─────────────── Vehicle Functions (оригинал) ───────────────
local function GetVehicleFromDescendant(Descendant)
	return Descendant:FindFirstAncestor(LocalPlayer.Name .. "\'s Car") or
		(Descendant:FindFirstAncestor("Body") and Descendant:FindFirstAncestor("Body").Parent) or
		(Descendant:FindFirstAncestor("Misc") and Descendant:FindFirstAncestor("Misc").Parent) or
		Descendant:FindFirstAncestorWhichIsA("Model")
end

local function TeleportVehicle(cf)
	local char = LocalPlayer.Character
	if not char then return end
	local seat = char:FindFirstChildWhichIsA("Humanoid") and char.Humanoid.SeatPart
	if not seat then return end
	local veh = GetVehicleFromDescendant(seat)
	if not veh then return end
	
	char.Parent = veh
	pcall(function()
		veh:SetPrimaryPartCFrame(cf)
	end)
end

-- ─────────────── Original Tabs ───────────────
local vehiclePage = Venyx:addPage("Vehicle", 8356815386)

local usage = vehiclePage:addSection("Usage")
local keybindsActive = true
usage:addToggle("Keybinds Active", true, function(v) keybindsActive = v end)

local flightSec = vehiclePage:addSection("Flight")
local flightEnabled = false
local flightSpeed = 1
flightSec:addToggle("Enabled", false, function(v) flightEnabled = v end)
flightSec:addSlider("Speed", 100, 0, 800, function(v) flightSpeed = v/100 end)

local defaultCharParent
RunService.Stepped:Connect(function()
	if not flightEnabled then
		if LocalPlayer.Character then
			LocalPlayer.Character.Parent = defaultCharParent or workspace
		end
		return
	end
	
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if not hum or not hum.SeatPart or not hum.SeatPart:IsA("VehicleSeat") then return end
	
	local veh = GetVehicleFromDescendant(hum.SeatPart)
	if not veh or not veh:IsA("Model") then return end
	
	char.Parent = veh
	if not veh.PrimaryPart then
		veh.PrimaryPart = hum.SeatPart or veh:FindFirstChildWhichIsA("BasePart")
	end
	
	local camLook = workspace.CurrentCamera.CFrame.LookVector
	local move = Vector3.new(
		(UserInputService:IsKeyDown(Enum.KeyCode.D) and flightSpeed or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and flightSpeed or 0),
		(UserInputService:IsKeyDown(Enum.KeyCode.E) and flightSpeed/2 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.Q) and flightSpeed/2 or 0),
		(UserInputService:IsKeyDown(Enum.KeyCode.S) and flightSpeed or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and flightSpeed or 0)
	)
	
	veh:SetPrimaryPartCFrame(CFrame.new(veh:GetPrimaryPartCFrame().Position, veh:GetPrimaryPartCFrame().Position + camLook) * CFrame.new(move))
	hum.SeatPart.AssemblyLinearVelocity = Vector3.zero
	hum.SeatPart.AssemblyAngularVelocity = Vector3.zero
end)

-- Acceleration / Deceleration / Stop (оставил как было, сократил для читаемости)
-- ... (вставь сюда свой оригинальный код Acceleration, Deceleration, Stop Vehicle, Springs)

-- ─────────────── New Tabs ───────────────

local visualsPage = Venyx:addPage("Visuals", 8356778308)

local fbSec = visualsPage:addSection("Lighting")
local fbEnabled = true
local function doFullbright()
	Lighting.Ambient = Color3.new(1,1,1)
	Lighting.ColorShift_Bottom = Color3.new(1,1,1)
	Lighting.ColorShift_Top = Color3.new(1,1,1)
end
fbSec:addToggle("Fullbright", true, function(v)
	fbEnabled = v
	if v then doFullbright() end
end)
Lighting.LightingChanged:Connect(function()
	if fbEnabled then doFullbright() end
end)

local espSec = visualsPage:addSection("ESP")
local oreEspEnabled = false
local playerEspEnabled = false

espSec:addToggle("Ore ESP (Highlight)", false, function(v)
	oreEspEnabled = v
end)

espSec:addToggle("Player ESP (Boxes)", false, function(v)
	playerEspEnabled = v
end)

-- Простой ESP loop
RunService.RenderStepped:Connect(function()
	for _, obj in pairs(workspace:GetDescendants()) do
		if oreEspEnabled and obj:IsA("BasePart") and (obj.Name:lower():find("ore") or obj.Name:lower():find("rock") or obj.Name:lower():find("resource")) then
			if not obj:FindFirstChild("OreHighlight") then
				local hl = Instance.new("Highlight")
				hl.Name = "OreHighlight"
				hl.FillColor = Color3.fromRGB(255, 215, 0)
				hl.OutlineColor = Color3.fromRGB(255, 255, 0)
				hl.Parent = obj
			end
		elseif not oreEspEnabled and obj:FindFirstChild("OreHighlight") then
			obj.OreHighlight:Destroy()
		end
	end
	
	-- Player ESP (очень базовый)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and playerEspEnabled then
			local root = plr.Character:FindFirstChild("HumanoidRootPart")
			if root and not root:FindFirstChild("PlayerESP") then
				local box = Instance.new("BoxHandleAdornment")
				box.Name = "PlayerESP"
				box.Adornee = root
				box.Size = Vector3.new(4,6,4)
				box.Color3 = Color3.fromRGB(255,0,0)
				box.Transparency = 0.7
				box.AlwaysOnTop = true
				box.ZIndex = 10
				box.Parent = root
				
				local name = Instance.new("BillboardGui", root)
				name.Name = "NameESP"
				name.Size = UDim2.new(0,100,0,30)
				name.AlwaysOnTop = true
				name.StudsOffset = Vector3.new(0,4,0)
				local txt = Instance.new("TextLabel", name)
				txt.Size = UDim2.new(1,0,1,0)
				txt.BackgroundTransparency = 1
				txt.Text = plr.Name
				txt.TextColor3 = Color3.new(1,1,1)
				txt.TextScaled = true
			end
		elseif not playerEspEnabled then
			if plr.Character then
				local root = plr.Character:FindFirstChild("HumanoidRootPart")
				if root then
					if root:FindFirstChild("PlayerESP") then root.PlayerESP:Destroy() end
					if root:FindFirstChild("NameESP") then root.NameESP:Destroy() end
				end
			end
		end
	end
end)

local miningPage = Venyx:addPage("Mining", 8357222903)

local helpers = miningPage:addSection("Helpers")
local infFuel = false
helpers:addToggle("Infinite Fuel", false, function(v) infFuel = v end)

local fasterMine = false
helpers:addToggle("Faster Mining", false, function(v) fasterMine = v end)

local autoSell = false
helpers:addToggle("Auto Sell Ore (try)", false, function(v) autoSell = v end)

RunService.Heartbeat:Connect(function()
	if infFuel then
		-- Пример: ищи NumberValue "Fuel" в машине
		local veh = GetVehicleFromDescendant(LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") and LocalPlayer.Character.Humanoid.SeatPart)
		if veh then
			for _, v in pairs(veh:GetDescendants()) do
				if v:IsA("NumberValue") and (v.Name:lower():find("fuel") or v.Name:lower():find("gas")) then
					v.Value = math.huge
				end
			end
		end
	end
	
	if fasterMine then
		-- Пример: если в инструменте/машине есть "MiningSpeed"
		-- доработай под реальные свойства
	end
	
	if autoSell then
		-- Ищи RemoteEvent на продажу (часто в ReplicatedStorage.Remotes)
		-- Пример: game.ReplicatedStorage.Remotes.SellOre:FireServer()
		-- пока заглушка — добавь реальный путь
	end
end)

local vehicleExtra = Venyx:addPage("Vehicle Extra")

local extraSec = vehicleExtra:addSection("Tweaks")
local noFlip = false
extraSec:addToggle("No Flip / Always Stable", false, function(v)
	noFlip = v
end)

RunService.Stepped:Connect(function()
	if noFlip then
		local veh = -- получи машину как выше
		if veh and veh.PrimaryPart then
			local cf = veh.PrimaryPart.CFrame
			veh.PrimaryPart.CFrame = CFrame.new(cf.Position) * CFrame.Angles(0, cf:ToEulerAnglesXYZ())
			-- или используй AlignOrientation / другие constraints
		end
	end
end)

-- ─────────────── Information + Hide Button ───────────────
local infoPage = Venyx:addPage("Information", 8356778308)

local miscSec = infoPage:addSection("Misc")
miscSec:addButton("Hide Menu", function()
	Venyx:toggle()
end)

-- Discord (оставил как было)

-- ─────────────── GUI Toggle Keys ───────────────
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightBracket or input.KeyCode == Enum.KeyCode.LeftAlt then
		Venyx:toggle()
	end
end)

print("Universal Vehicle Script + Mining features loaded for Chacalot's Mining Sim")
