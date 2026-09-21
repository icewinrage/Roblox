local Shared = _G.Venture.Shared
local Config = _G.Venture.Config
local Utils  = _G.Venture.Utils
local Theme  = _G.Venture.Theme
local Funcs  = _G.Venture.Functions
local GUI    = _G.Venture.GUI

local Players = Shared.Players
local TeleportService = Shared.TeleportService
local LocalPlayer = Shared.LocalPlayer
local Settings = Config.Settings
local New = Utils.New
local Notify = Utils.Notify

local Security = {}

local function IsModerator(player)
    if not player or player == LocalPlayer then return false, 0 end
    local ok, rank = pcall(function() return player:GetRankInGroup(Config.MOD_GROUP_ID) end)
    if ok and rank and rank > 0 then return true, rank end
    return false, 0
end

function Security.CheckMods()
    local found = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local im, r = IsModerator(pl)
            if im then
                found[pl.Name] = r
            end
        end
    end

    Funcs.State.SecurityState.ModsInServer = found
    local cnt = 0
    for _ in pairs(found) do cnt = cnt + 1 end

    if cnt > 0 then
        if not Funcs.State.SecurityState.IsPaused then
            Funcs.State.SecurityState.IsPaused = true
            Notify("MODERATOR DETECTED", "Switch server! All functions paused.", 15)

            Settings.AutoFarmEnabled = false
            Settings.AutoHealEnabled = false
            Settings.AutoQuestEnabled = false
            Settings.AutoRefillEnabled = false
            Settings.FPSBoosterEnabled = false
            Settings.HitboxExpand = false
            Settings.Noclip = false
            Funcs.ResetAllHitboxes()
            Funcs.StopNoclip()
            Funcs.DisableFPSBooster()
            Funcs.CleanupFarm()
        end

        if Settings.AutoKickOnMod then
            task.wait(1)
            pcall(function()
                TeleportService:Teleport(game.PlaceId)
            end)
        end
    else
        if Funcs.State.SecurityState.IsPaused then
            Funcs.State.SecurityState.IsPaused = false
        end
    end
end

function Security.PopulateTab()
    local panel = GUI.SecurityTabPanel
    if not panel then return end

    for _, child in ipairs(panel:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end

    local sy = 0
    sy = GUI.MakeSectionLabel(panel, "MODERATOR DETECTOR", sy)

    New("TextLabel", {
        Position = UDim2.new(0,4,0,sy), Size = UDim2.new(1,-8,0,60),
        BackgroundTransparency = 1,
        Text = "Monitors group: " .. Config.MOD_GROUP_ID .. "\nAuto-pauses ALL functions if mod joins.\nAlways enabled.",
        TextColor3 = Theme.Get().SubText,
        Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true, ZIndex = 8,
    }, panel)
    sy = sy + 66

    local statusLabel = New("TextLabel", {
        Position = UDim2.new(0,4,0,sy), Size = UDim2.new(1,-8,0,40),
        BackgroundTransparency = 1, Text = "Status: OK",
        TextColor3 = Color3.fromRGB(100,255,100),
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 8,
    }, panel)
    sy = sy + 46

    task.spawn(function()
        while statusLabel.Parent do
            task.wait(1)
            local cnt = 0
            for _ in pairs(Funcs.State.SecurityState.ModsInServer) do cnt = cnt + 1 end
            pcall(function()
                if cnt > 0 then
                    statusLabel.Text = "Status: " .. cnt .. " MOD(S) DETECTED"
                    statusLabel.TextColor3 = Color3.fromRGB(255,60,60)
                else
                    statusLabel.Text = "Status: OK (no mods)"
                    statusLabel.TextColor3 = Color3.fromRGB(100,255,100)
                end
            end)
        end
    end)

    sy = GUI.MakeToggle(panel, "Auto-Kick on Mod (new server)", sy, Settings.AutoKickOnMod, function(v)
        Settings.AutoKickOnMod = v
        Config.SaveSecurity()
    end)

    sy = sy + 6
    sy = GUI.MakeSectionLabel(panel, "SERVER CONTROLS", sy)

    sy = GUI.MakeButton(panel, "Rejoin Same Server", "Teleport back", sy, function()
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end)

    sy = GUI.MakeButton(panel, "Join New Server", "Find another", sy, function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId)
        end)
    end)

    sy = GUI.MakeButton(panel, "Copy Server ID", "To clipboard", sy, function()
        if setclipboard then
            setclipboard(game.JobId)
        elseif toclipboard then
            toclipboard(game.JobId)
        else
            Notify("No clipboard", game.JobId:sub(1,12) .. "...", 8)
        end
    end)

    panel.CanvasSize = UDim2.new(0,0,0,sy+20)
end

function Security.Init()
    Players.PlayerAdded:Connect(function(pl)
        task.wait(2)
        pcall(Security.CheckMods)
    end)

    Players.PlayerRemoving:Connect(function(pl)
        if Funcs.State.SecurityState.ModsInServer[pl.Name] then
            Funcs.State.SecurityState.ModsInServer[pl.Name] = nil
            Security.CheckMods()
        end
    end)

    task.spawn(function()
        while true do
            task.wait(15)
            pcall(Security.CheckMods)
        end
    end)

    task.wait(1)
    pcall(Security.CheckMods)
end

_G.Venture = _G.Venture or {}
_G.Venture.Security = Security

return Security
