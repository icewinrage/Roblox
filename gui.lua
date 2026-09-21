-- для каждой вкладки храним её состояние (active/inactive)
local tabStates = {}

local function RefreshTabVisuals()
    for i, btn in ipairs(tabButtons) do
        local active = tabStates[i]
        local T = Theme.Get()
        btn.BackgroundColor3 = active and T.TabBgActive or T.TabBg
        btn.BackgroundTransparency = active and 0.1 or 0.3
        btn.TextColor3 = active and T.TabTextActive or T.TabText
        btn.TextTransparency = 0
        for _, c in ipairs(btn:GetChildren()) do
            if c:IsA("UIStroke") then
                c.Color = active and T.Accent or T.TabStroke
                c.Transparency = active and 0 or 0.4
            end
        end
    end
end
