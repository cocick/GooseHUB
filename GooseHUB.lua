-- 🪿 GOOSEHUB v17.1 — ОРИОН С ОФИЦИАЛЬНОЙ ССЫЛКОЙ + ТВОЙ ESP v2.1 + СИЛЕНТ AIM! ХОНК ХОНК 2025!
-- Ссылка на Orion: https://raw.githubusercontent.com/jensonhirst/Orion/main/source (стабильная, без ошибок!)

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/jensonhirst/Orion/main/source'))()

local Window = OrionLib:MakeWindow({
    Name = "🪿 GOOSEHUB v17.1 — ОРИОН ЕБЁТ ВСЕХ!",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "GooseHub"
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = {
    Enabled = false,
    TeamCheck = false,
    Box = true,
    Name = true,
    Distance = true,
    HealthBar = true,
    Tracers = true,
    TracerFrom = "Bottom"  -- "Bottom" or "Mouse"
}

local Aimbot = {
    Enabled = false,
    Prediction = 0.135,
    Smoothness = 0.14,
    TriggerBot = true,
    HeadOnly = true,
    VisibleCheck = true
}

local ESPObjects = {}

-- СОЗДАНИЕ ESP (ТОЧНО ТВОЙ v2.1!)
local function CreateESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end

    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HealthBarBG = Drawing.new("Line"),
        HealthBar = Drawing.new("Line")
    }

    drawings.Box.Thickness = 2
    drawings.Box.Filled = false
    drawings.Box.Transparency = 1
    drawings.Box.Color = Color3.fromRGB(255,50,50)

    drawings.Name.Size = 13
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Font = 2
    drawings.Name.Color = Color3.new(1,1,1)

    drawings.Distance.Size = 13
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Font = 2
    drawings.Distance.Color = Color3.fromRGB(0,255,150)

    drawings.Tracer.Thickness = 1.5
    drawings.Tracer.Color = Color3.fromRGB(255,50,50)
    drawings.Tracer.Transparency = 0.8

    drawings.HealthBarBG.Thickness = 5
    drawings.HealthBarBG.Color = Color3.new(0,0,0)
    drawings.HealthBar.Thickness = 3

    ESPObjects[player] = drawings
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            obj:Remove()
        end
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    if not ESP.Enabled then return end

    for player, drawings in pairs(ESPObjects) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        if ESP.TeamCheck and player.Team == LocalPlayer.Team then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        local root = char.HumanoidRootPart
        local hum = char.Humanoid
        local head = char:FindFirstChild("Head") or root

        local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,4,0))

        if onScreen then
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height * 0.6
            local hp = hum.Health / hum.MaxHealth
            local col = Color3.fromHSV(math.clamp(hp*0.35,0,0.35),1,1)

            if ESP.Box then
                drawings.Box.Size = Vector2.new(width, height)
                drawings.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                drawings.Box.Color = col
                drawings.Box.Visible = true
            end

            if ESP.Name then
                drawings.Name.Text = player.Name
                drawings.Name.Position = Vector2.new(rootPos.X, headPos.Y - 20)
                drawings.Name.Visible = true
            end

            if ESP.Distance and LocalPlayer.Character then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                drawings.Distance.Text = string.format("%.0fm", dist)
                drawings.Distance.Position = Vector2.new(rootPos.X, headPos.Y + 5)
                drawings.Distance.Visible = true
            end

            if ESP.HealthBar then
                local y = rootPos.Y - height/2
                drawings.HealthBarBG.From = Vector2.new(rootPos.X - width/2 -7, y)
                drawings.HealthBarBG.To = Vector2.new(rootPos.X - width/2 -7, y + height)
                drawings.HealthBarBG.Visible = true

                drawings.HealthBar.From = Vector2.new(rootPos.X - width/2 -7, y + height - (height * hp))
                drawings.HealthBar.To = Vector2.new(rootPos.X - width/2 -7, y + height)
                drawings.HealthBar.Color = col
                drawings.HealthBar.Visible = true
            end

            if ESP.Tracers then
                local from = (ESP.TracerFrom == "Mouse") and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                drawings.Tracer.From = from
                drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + height/2)
                drawings.Tracer.Color = col
                drawings.Tracer.Visible = true
            end
        else
            for _, d in pairs(drawings) do d.Visible = false end
        end
    end
end

-- АИМБОТ С ПРЕДИКШЕНОМ
local function GetBestTarget()
    local closest, closestDist = nil, math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end

        if ESP.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local targetPart = player.Character:FindFirstChild(Aimbot.HeadOnly and "Head" or "HumanoidRootPart")
        if not targetPart then continue end

        local velocity = player.Character.HumanoidRootPart.Velocity
        local predictedPos = targetPart.Position + velocity * Aimbot.Prediction

        local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
        local mousePos = UserInputService:GetMouseLocation()
        local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

        if onScreen and fovDist < closestDist then
            if Aimbot.VisibleCheck then
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Blacklist
                params.FilterDescendantsInstances = {LocalPlayer.Character}
                local ray = workspace:Raycast(Camera.CFrame.Position, (predictedPos - Camera.CFrame.Position), params)
                if ray and not ray.Instance:IsDescendantOf(player.Character) then continue end
            end
            closest = predictedPos
            closestDist = fovDist
        end
    end

    return closest
end

RunService.Heartbeat:Connect(function()
    if not Aimbot.Enabled then return end

    local target = GetBestTarget()
    if target then
        local screenPos = Camera:WorldToViewportPoint(target)
        local mousePos = UserInputService:GetMouseLocation()
        local delta = (Vector2.new(screenPos.X, screenPos.Y) - mousePos) * Aimbot.Smoothness

        mousemoverel(delta.X, delta.Y)

        if Aimbot.TriggerBot then
            mouse1press()
            task.wait(0.02)
            mouse1release()
        end
    end
end)

-- ORION GUI ТАБЫ
local VisualTab = Window:MakeTab({
    Name = "👁️ ESP (v2.1)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

VisualTab:AddToggle({
    Name = "ESP Enabled",
    Default = false,
    Callback = function(Value)
        ESP.Enabled = Value
    end    
})

VisualTab:AddToggle({
    Name = "Team Check",
    Default = false,
    Callback = function(Value)
        ESP.TeamCheck = Value
    end    
})

VisualTab:AddToggle({
    Name = "Box",
    Default = true,
    Callback = function(Value)
        ESP.Box = Value
    end    
})

VisualTab:AddToggle({
    Name = "Name",
    Default = true,
    Callback = function(Value)
        ESP.Name = Value
    end    
})

VisualTab:AddToggle({
    Name = "Distance",
    Default = true,
    Callback = function(Value)
        ESP.Distance = Value
    end    
})

VisualTab:AddToggle({
    Name = "Health Bar",
    Default = true,
    Callback = function(Value)
        ESP.HealthBar = Value
    end    
})

VisualTab:AddToggle({
    Name = "Tracers",
    Default = true,
    Callback = function(Value)
        ESP.Tracers = Value
    end    
})

local CombatTab = Window:MakeTab({
    Name = "🎯 Aimbot",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CombatTab:AddToggle({
    Name = "Aimbot Enabled",
    Default = false,
    Callback = function(Value)
        Aimbot.Enabled = Value
    end    
})

CombatTab:AddSlider({
    Name = "Prediction",
    Min = 0.1,
    Max = 0.2,
    Default = 0.135,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.01,
    ValueName = "x",
    Callback = function(Value)
        Aimbot.Prediction = Value
    end    
})

CombatTab:AddSlider({
    Name = "Smoothness",
    Min = 0.05,
    Max = 0.3,
    Default = 0.14,
    Color = Color3.fromRGB(255,255,255),
    Increment = 0.01,
    ValueName = "x",
    Callback = function(Value)
        Aimbot.Smoothness = Value
    end    
})

CombatTab:AddToggle({
    Name = "Trigger Bot",
    Default = true,
    Callback = function(Value)
        Aimbot.TriggerBot = Value
    end    
})

CombatTab:AddToggle({
    Name = "Head Only",
    Default = true,
    Callback = function(Value)
        Aimbot.HeadOnly = Value
    end    
})

CombatTab:AddToggle({
    Name = "Visible Check",
    Default = true,
    Callback = function(Value)
        Aimbot.VisibleCheck = Value
    end    
})

-- СОЗДАНИЕ ESP
for _, p in Players:GetPlayers() do CreateESP(p) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Wait() CreateESP(p) end)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(UpdateESP)

OrionLib:Init()

print("🪿 GOOSEHUB v17.1 С ОРИОН (ОФИЦИАЛЬНАЯ ССЫЛКА) ЗАГРУЖЕН! ХОНК ХОНК, СУКА!")
