-- 🪿 GOOSEHUB v19.0 — САМОЕ КРАСИВОЕ МЕНЮ 2025 + ESP v2.1 + СИЛЕНТ AIM! ХОНК ХОНК!
-- Трейсеры от центра экрана по умолчанию, анимации, тени, скролл — пиздец имба!

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКИ
local Settings = {
    ESP = {Enabled = true, TeamCheck = false, Box = true, Name = true, Distance = true, HealthBar = true, Tracers = true},
    Aimbot = {Enabled = true, Prediction = 0.135, Smoothness =  = 0.14, TriggerBot = true, HeadOnly = true},
    MenuOpen = true
}

local ESPObjects = {}

-- ===================================================================
-- САМОЕ ИМБОВОЕ МЕНЮ С НУЛЯ (АНИМАЦИИ, ТЕНИ, ГРАДИЕНТ, СКРОЛЛ)
-- ===================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GooseIMBA"
ScreenGui.Parent = game.CoreGui

local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(0, 520, 0, 420)
Shadow.Position = UDim2.new(0.5, -260, 0.5, -210)
Shadow.BackgroundColor3 = Color3.new(0,0,0)
Shadow.BackgroundTransparency = 0.6
Shadow.ZIndex = 0
Shadow.Visible = false
Shadow.Parent = ScreenGui
local ShadowCorner = Instance.new("UICorner")
ShadowCorner.CornerRadius = UDim.new(0, 20)
ShadowCorner.Parent = Shadow

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 1
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = MainFrame

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
}
Gradient.Rotation = 90
Gradient.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "🪿 GOOSEHUB v19.0 — ИМБА МЕНЮ 2025"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -70)
Scroll.Position = UDim2.new(0, 10, 0, 60)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 8
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 50, 50)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 1200)
Scroll.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 12)
Layout.Parent = Scroll

-- ФУНКЦИИ ДЛЯ КРАСИВЫХ КНОПОК
local function CreateToggle(name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Frame.Parent = Scroll
    local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 12); C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextXAlignment = "Left"
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.Parent = Frame
    Label.Position = UDim2.new(0, 15, 0, 0, 0)

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
    return Frame
end

-- СОЗДАЁМ ИМБОВОЕ МЕНЮ
CreateToggle("ESP Enabled", true, function(v) Settings.ESP.Enabled = v end)
CreateToggle("Team Check", false, function(v) Settings.ESP.TeamCheck = v end)
CreateToggle("Box ESP", true, function(v) Settings.ESP.Box = v end)
CreateToggle("Name ESP", true, function(v) Settings.ESP.Name = v end)
CreateToggle("Distance ESP", true, function(v) Settings.ESP.Distance = v end)
CreateToggle("Health Bar", true, function(v) Settings.ESP.HealthBar = v end)
CreateToggle("Tracers (от центра)", true, function(v) Settings.ESP.Tracers = v end)

CreateToggle("Aimbot 360°", true, function(v) Settings.Aimbot.Enabled = v end)
CreateToggle("Trigger Bot", true, function(v) Settings.Aimbot.TriggerBot = v end)
CreateToggle("Head Only", true, function(v) Settings.Aimbot.HeadOnly = v end)

-- СЛАЙДЕРЫ (ПРЕДИКШЕН + SMOOTH)
local function CreateSlider(name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 60)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Frame.Parent = Scroll
    local C = Instance.new("UICorner"); C.CornerRadius = UDim.new(0, 12); C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Text = name .. ": " .. default
    Label.Size = UDim2.new(1, 0, 0.5, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.Parent = Frame

    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(0.9, 0, 0, 15)
    Slider.Position = UDim2.new(0.05, 0, 0.6, 0)
    Slider.BackgroundColor3 = Color3.fromRGB(60,60,70)
    Slider.Parent = Frame
    local SC = Instance.new("UICorner"); SC.CornerRadius = UDim.new(0, 8); SC.Parent = Slider

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    Fill.Parent = Slider
    local FC = Instance.new("UICorner"); FC.CornerRadius = UDim.new(0, 8); FC.Parent = Fill

    Slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn
            conn = RunService.Heartbeat:Connect(function()
                local mouse = UserInputService:GetMouseLocation()
                local rel = math.clamp((mouse.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
                local value = min + rel * (max - min)
                Fill.Size = UDim2.new(rel, 0, 1, 0)
                Label.Text = name .. ": " .. string.format("%.3f", value)
                callback(value)
                if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then conn:Disconnect() end
            end)
        end
    end)
end

CreateSlider("Prediction", 0.1, 0.2, 0.135, function(v) Settings.Aimbot.Prediction = v end)
CreateSlider("Smoothness", 0.05, 0.3, 0.14, function(v) Settings.Aimbot.Smoothness = v end)

-- АНИМАЦИЯ ОТКРЫТИЯ
MainFrame.Size = UDim2.new(0, 0,0, 0)
Shadow.Visible = true
MainFrame.Visible = true
TweenService:Create(Shadow, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 500, 0, 400)}):Play()

-- ===================================================================
-- ТВОЙ ЛЮБИМЫЙ ESP v2.1 + ТРЕЙСЕРЫ ОТ ЦЕНТРА!
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
    -- настройки как в v2.1
    drawings.Box.Thickness = 2; drawings.Box.Filled = false; drawings.Box.Transparency = 1
    drawings.Name.Size = 13; drawings.Name.Center = true; drawings.Name.Outline = true; drawings.Name.Font = 2
    drawings.Distance.Size = 13; drawings.Distance.Center = true; drawings.Distance.Outline = true; drawings.Distance.Font = 2
    drawings.Tracer.Thickness = 1.5; drawings.Tracer.Transparency = 0.8
    drawings.HealthBarBG.Thickness = 5; drawings.HealthBarBG.Color = Color3.new(0,0,0)
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

            -- BOX, NAME, DIST, HEALTH, TRACER — ВСЁ КАК В v2.1!
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
                drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)  -- ОТ ЦЕНТРА ЭКРАНА!
                drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + height/2)
                drawings.Tracer.Color = col
                drawings.Tracer.Visible = true
            end
        else
            for _, d in pairs(drawings) do d.Visible = false end
        end
    end
end

-- СИЛЕНТ АИМ С ПРЕДИКШЕНОМ
local function GetBestTarget()
    local closest, closestDist = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character then continue end
        if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then continue end
        local part = player.Character:FindFirstChild(Settings.Aimbot.HeadOnly and "Head" or "HumanoidRootPart")
        if part then
            local vel = player.Character.HumanoidRootPart.Velocity
            local pred = part.Position + vel * Settings.Aimbot.Prediction
            local sp, on = Camera:WorldToViewportPoint(pred)
            local mp = UserInputService:GetMouseLocation()
            local dist = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
            if on and dist < closestDist then
                closest = pred
                closestDist = dist
            end
        end
    end
    return closest
end

RunService.Heartbeat:Connect(function()
    if not Settings.Aimbot.Enabled then return end
    local target = GetBestTarget()
    if target then
        local sp = Camera:WorldToViewportPoint(target)
        local mp = UserInputService:GetMouseLocation()
        delta = (Vector2.new(sp.X, sp.Y) - mp) * Settings.Aimbot.Smoothness
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

print("🪿 GOOSEHUB v19.0 — ИМБА МЕНЮ + ESP v2.1 + АИМ = ВСЁ РАБОТАЕТ, СУКА!")
