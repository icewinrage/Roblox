local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Attack On Titans Incremental",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Data",
    ConfigurationSaving = false,
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)

-- ==================== РЕМОТЫ ====================
local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
local CastFish          = Remotes:WaitForChild("CastFish")
local StartTraining     = Remotes:WaitForChild("StartTraining")
local ClickAttack       = Remotes:WaitForChild("ClickAttack")
local BuyUpgrade        = Remotes:WaitForChild("BuyUpgrade")
local ClaimDailyReward  = Remotes:WaitForChild("ClaimDailyReward")
local Rebirth           = Remotes:WaitForChild("Rebirth")

-- ==================== ФЛАГИ ====================
local autoScouting = false
local autoTraining = false
local autoClick    = false
local autoUpgrade  = false
local spamDelay    = 0.05

-- ==================== ЕДИНЫЙ ЦИКЛ (0 ЛАГОВ) ====================
task.spawn(function()
    while true do
        local fired = false
        
        if autoScouting then
            pcall(function() CastFish:FireServer() end)
            fired = true
        end
        if autoTraining then
            pcall(function() StartTraining:FireServer() end)
            fired = true
        end
        if autoClick then
            pcall(function() ClickAttack:FireServer() end)
            fired = true
        end
        if autoUpgrade then
            pcall(function() BuyUpgrade:FireServer() end)
            fired = true
        end
        
        if fired then
            task.wait(spamDelay)      -- скорость для всех авто-фармов
        else
            task.wait(0.1)            -- спим когда всё выключено
        end
    end
end)
-- ============================================================

MainTab:CreateSection("🚀 Auto Farm")

MainTab:CreateToggle({
    Name = "🔄 Auto Scouting",
    CurrentValue = false,
    Callback = function(Value) autoScouting = Value end,
})

MainTab:CreateToggle({
    Name = "🏋️ Auto Training (StartTraining) — для Soldier & Mage",
    CurrentValue = false,
    Callback = function(Value) autoTraining = Value end,
})

MainTab:CreateToggle({
    Name = "⚔️ Auto Click Attack",
    CurrentValue = false,
    Callback = function(Value) autoClick = Value end,
})

MainTab:CreateToggle({
    Name = "⬆️ Auto Buy Upgrade",
    CurrentValue = false,
    Callback = function(Value) autoUpgrade = Value end,
})

MainTab:CreateSlider({
    Name = "⚡ Auto - Speed (yall auto)",
    Range = {0.01, 0.2},
    Increment = 0.01,
    CurrentValue = 0.05,
    Callback = function(Value) spamDelay = Value end,
})

MainTab:CreateSection("🛠 Utilities")

MainTab:CreateButton({
    Name = "📅 Claim Daily Reward",
    Callback = function()
        pcall(function() ClaimDailyReward:FireServer() end)
        Rayfield:Notify({Title = "Daily Claimed", Content = "Check reward!", Duration = 4})
    end,
})

MainTab:CreateButton({
    Name = "♻️ Rebirth",
    Callback = function()
        pcall(function() Rebirth:FireServer() end)
        Rayfield:Notify({Title = "Rebirth enabled", Content = "Good luck!", Duration = 5})
    end,
})

MainTab:CreateButton({
    Name = "🔄 Anti-AFK",
    Callback = function()
        task.spawn(function()
            while task.wait(30) do
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end
        end)
        Rayfield:Notify({Title = "Anti-AFK ON", Content = "Working infinite", Duration = 4})
    end,
})

-- ==================== ГОТОВО ====================
Rayfield:Notify({
    Title = "Loaded ✓",
    Content = "Join discord server!",
    Duration = 10,
    Image = 4483362458
})
