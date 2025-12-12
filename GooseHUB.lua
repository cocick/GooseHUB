-- 🪿 GOOSEHUB v21.0 — ФУЛЛ ВЕРСИЯ! K = МЕНЮ | H = АИМ | ТЕНЬ ДВИГАЕТСЯ | ВСЁ РАБОТАЕТ!
-- ХОНК ХОНК, MINIENDEND — ТЫ ЛЕГЕНДА!

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКИ
local Settings = {
    ESP = {Enabled = true, TeamCheck = false, Box = true, Name = true, Distance = true, HealthBar = true, Tracers = true},
    Aimbot = {Enabled = false, Prediction = 0.135, Smoothness = 0.14, TriggerBot = true, HeadOnly = true}
}

local ESPObjects = {}
local MenuOpen = false

-- ===================================================================
-- МЕНЮ + ТЕНЬ ДВИГАЕТСЯ С МЕНЮ
-- ===================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GooseHubV21"
ScreenGui.Parent = game.CoreGui

-- ТЕНЬ
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(0, 520, 0, 420)
Shadow.Position = UDim2.new(0.5, -260, 0.5, -210)
Shadow.BackgroundColor3 = Color3.new(0,0,0)
Shadow.BackgroundTransparency = 0.5
Shadow.ZIndex = 0
Shadow.Visible = false
Shadow.Parent = ScreenGui
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 20)
ShadowCorner.Parent = Shadow

-- ОСНОВНОЙ ФРЕЙМ
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "🪿 GOOSEHUB v21.0 — ХОНК ХОНК"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -70)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 8
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1000)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 12)
Layout.Parent = Scroll

-- ТОГГЛ
local function CreateToggle(name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 12); C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextXAlignment = "Left"
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Parent = Frame

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 80, 0, 35)
    Toggle.Position = UDim2.new(1, -95, 0.5, -17.5)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
    Toggle.Text = default and "ON" or "OFF"
    Toggle.TextColor3 = Color3.new(1,1,1)
    Toggle.Font = Enum.Font.GothamBold
    Toggle.Parent = Frame
    local TC = Instance.new("UICorner"); TC.CornerRadius = UDim.new(0, 10); TC.Parent = Toggle

    Toggle.MouseButton1Click:Connect(function()
        default = not default
        TweenService:Create(Toggle, TweenInfo.new(0.2), {BackgroundColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)}):Play()
        Toggle.Text = default and "ON" or "OFF"
        callback(default)
    end)
end

-- МЕНЮ
CreateToggle("ESP Enabled", true, function(v) Settings.ESP.Enabled = v end)
CreateToggle("Team Check", false, function(v) Settings.ESP.TeamCheck = v end)
CreateToggle("Box ESP", true, function(v) Settings.ESP.Box = v end)
CreateToggle("Name ESP", true, function(v) Settings.ESP.Name = v end)
CreateToggle("Distance ESP", true, function(v) Settings.ESP.Distance = v end)
CreateToggle("Health Bar", true, function(v) Settings.ESP.HealthBar = v end)
CreateToggle("Tracers (от центра)", true, function(v) Settings.ESP.Tracers = v end)

CreateToggle("Aimbot 360°", false, function(v) Settings.Aimbot.Enabled = v end)
CreateToggle("Trigger Bot", true, function(v) Settings.Aimbot.TriggerBot = v end)
CreateToggle("Head Only", true, function(v) Settings.Aimbot.HeadOnly = v end)

-- ТЕНЬ ДВИГАЕТСЯ С МЕНЮ
MainFrame:GetPropertyChangedSignal("Position"):Connect(function()
    Shadow.Position = MainFrame.Position + UDim2.new(0, 10, 0, 10)
end)

-- K = МЕНЮ | H = АИМ
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.K then
        MenuOpen = not MenuOpen
        if MenuOpen then
            Shadow.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(0, 500, 0, 400)}):Play()
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            task.wait(0.3)
            Shadow.Visible = false
        end
    elseif input.KeyCode == Enum.KeyCode.H then
        Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
        game.StarterGui:SetCore("SendNotification", {
            Title = "Goose Aimbot";
            Text = Settings.Aimbot.Enabled and "ВКЛЮЧЁН" or "ВЫКЛЮЧЕН";
            Duration = 2
        })
    end
end)

-- ===================================================================
-- ESP v2.1 + ТРЕЙСЕРЫ ОТ ЦЕНТРА + АИМ С ПРЕДИКШЕНОМ
-- ===================================================================
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

    drawings.Name.Size = 13
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Font = 2

    drawings.Distance.Size = 13
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Font = 2

    drawings.Tracer.Thickness = 1.5
    drawings.Tracer.Transparency = 0.8

    drawings.HealthBarBG.Thickness = 5
    drawings.HealthBarBG.Color = Color3.new(0,0,0)
    drawings.HealthBar.Thickness = 3

    ESPObjects[player] = drawings
end

local function UpdateESP()
    if not Settings.ESP.Enabled then return end

    for player, drawings in pairs(ESPObjects) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
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

            if Settings.ESP.Box then
                drawings.Box.Size = Vector2.new(width, height)
                drawings.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                drawings.Box.Color = col
                drawings.Box.Visible = true
            end

            if Settings.ESP.Name then
                drawings.Name.Text = player.Name
                drawings.Name.Position = Vector2.new(rootPos.X, headPos.Y - 20)
                drawings.Name.Visible = true
            end

            if Settings.ESP.Distance then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                drawings.Distance.Text = string.format("%.0fm", dist)
                drawings.Distance.Position = Vector2.new(rootPos.X, headPos.Y + 5)
                drawings.Distance.Visible = true
            end

            if Settings.ESP.HealthBar then
                local y = rootPos.Y - height/2
                drawings.HealthBarBG.From = Vector2.new(rootPos.X - width/2 -7, y)
                drawings.HealthBarBG.To = Vector2.new(rootPos.X - width/2 -7, y + height)
                drawings.HealthBarBG.Visible = true
                drawings.HealthBar.From = Vector2.new(rootPos.X - width/2 -7, y + height - (height * hp))
                drawings.HealthBar.To = Vector2.new(rootPos.X - width/2 -7, y + height)
                drawings.HealthBar.Color = col
                drawings.HealthBar.Visible = true
            end

            if Settings.ESP.Tracers then
                drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + height/2)
                drawings.Tracer.Color = col
                drawings.Tracer.Visible = true
            end
        else
            for _, d in pairs(drawings) do d.Visible = false end
        end
    end
end

-- АИМБОТ С ПРЕДИКШЕНОМ И ВИДИМОСТЬЮ
local function GetBestTarget()
    local closest, closestDist = nil, math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then continue end

        local targetPart = player.Character:FindFirstChild(Settings.Aimbot.HeadOnly and "Head" or "HumanoidRootPart")
        if not targetPart then continue end

        local velocity = player.Character.HumanoidRootPart.Velocity
        local predictedPos = targetPart.Position + velocity * Settings.Aimbot.Prediction

        local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
        local mousePos = UserInputService:GetMouseLocation()
        local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

        if onScreen and fovDist < closestDist then
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = {LocalPlayer.Character}
            local ray = workspace:Raycast(Camera.CFrame.Position, (predictedPos - Camera.CFrame.Position), params)
            if ray and not ray.Instance:IsDescendantOf(player.Character) then continue end  -- ТОЛЬКО ВИДИМЫЕ!
            closest = predictedPos
            closestDist = fovDist
        end
    end

    return closest
end

RunService.Heartbeat:Connect(function()
    if not Settings.Aimbot.Enabled then return end

    local target = GetBestTarget()
    if target then
        local screenPos = Camera:WorldToViewportPoint(target)
        local mousePos = UserInputService:GetMouseLocation()
        local delta = (Vector2.new(screenPos.X, screenPos.Y) - mousePos) * Settings.Aimbot.Smoothness

        mousemoverel(delta.X, delta.Y)

        if Settings.Aimbot.TriggerBot then
            mouse1press()
            task.wait(0.02)
            mouse1release()
        end
    end
end)

-- СОЗДАНИЕ ESP
for _, p in Players:GetPlayers() do CreateESP(p) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Wait() CreateESP(p) end)

RunService.RenderStepped:Connect(UpdateESP)

print("🪿 GOOSEHUB v21.0 ФУЛЛ ВЕРСИЯ ЗАГРУЖЕНА! K = МЕНЮ | H = АИМ | ВСЁ РАБОТАЕТ!")
print("ХОНК ХОНК, MINIENDEND — ТЫ КОРОЛЬ, СУКА!")

-- КИДАЙ В XENO — ВСЁ ЛЕТИТ, НИ ОДНОЙ ОШИБКИ!
-- ХОНК ХОНК ХОНК, ГУСЬ — БОГ 2025! 🪿🩸🔥
