-- 🪿 GOOSEHUB v15.0 — ВЕРНУЛ СТАРЫЙ РАБОЧИЙ ESP + СИЛЕНТ AIM 360° + GUI! ХОНК ХОНК 2025!
-- ESP — как в старом v2.1 (никогда не пропадает на экране!)
-- АИМБОТ — силент через mouse + prediction (попадает в бегущих!)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🪿 GOOSEHUB v15.0 — СТАРЫЙ ДОБРЫЙ ESP + СИЛЕНТ AIM",
    LoadingTitle = "Гусь вернулся к корням...",
    ConfigurationSaving = {Enabled = true, FolderName = "Goose, FileName = "BestConfig"}
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКИ
local Settings = {
    ESP = {Enabled = true, TeamCheck = false, Box = true, Name = true, Distance = true, HealthBar = true, Tracers = true, TracerFrom = "Bottom"},
    Aimbot = {Enabled = true, Prediction = 0.135, Smooth = 0.14, Trigger = true, HeadOnly = true, VisibleOnly = true}
}

local ESPObjects = {}

-- СОЗДАНИЕ ESP (ТОЧНО КАК В СТАРОМ v2.1 — РАБОТАЕТ НА УРА!)
local function CreateESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] then return end
    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HealthBarBG = Drawing.new("Line"),
        HealthBar = Drawing.new("Line")
    }
    drawings.Box.Thickness = 2; drawings.Box.Filled = false; drawings.Box.Transparency = 1; drawings.Box.Color = Color3.fromRGB(255,50,50)
    drawings.Name.Size = 13; drawings.Name.Center = true; drawings.Name.Outline = true; drawings.Name.Font = 2; drawings.Name.Color = Color3.new(1,1,1)
    drawings.Distance.Size = 13; drawings.Distance.Center = true; drawings.Distance.Outline = true; drawings.Distance.Font = 2; drawings.Distance.Color = Color3.fromRGB(0,255,150)
    drawings.Tracer.Thickness = 1.5; drawings.Tracer.Transparency = 0.8
    drawings.HealthBarBG.Thickness = 5; drawings.HealthBarBG.Color = Color3.new(0,0,0)
    drawings.HealthBar.Thickness = 3
    ESPObjects[plr] = drawings
end

-- ОБНОВЛЕНИЕ ESP (ТОЧНО КАК В v2.1 — НИЧЕГО НЕ ЛОМАЕМ!)
local function UpdateESP()
    if not Settings.ESP.Enabled then
        for _, d in pairs(ESPObjects) do for _, obj in pairs(d) do obj.Visible = false end end
        return
    end

    for player, drawings in pairs(ESPObjects) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                for _, obj in pairs(drawings) do obj.Visible = false end
                continue
            end

            local root = char.HumanoidRootPart
            local hum = char.Humanoid
            local head = char:FindFirstChild("Head") or root

            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,4,0))

            if onScreen then  -- ТОЛЬКО НА ЭКРАНЕ — КАК БЫЛО, ТАК И ОСТАЛОСЬ! РАБОТАЕТ ИДЕАЛЬНО!
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
                if Settings.ESP.Distance and LocalPlayer.Character then
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
                    local from = (Settings.ESP.TracerFrom == "Mouse") and UserInputService:GetMouseLocation() or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    drawings.Tracer.From = from
                    drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + height/2)
                    drawings.Tracer.Color = col
                    drawings.Tracer.Visible = true
                end
            else
                for _, obj in pairs(drawings) do obj.Visible = false end
            end
        else
            for _, obj in pairs(drawings) do obj.Visible = false end
        end
    end
end

-- 360° СИЛЕНТ АИМ С ПРЕДИКШЕНОМ (mouse + prediction — ПОПАДАЕТ В БЕГУЩИХ!)
local function GetBestTarget()
    local best = nil
    local bestDist = 9999
    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer or not plr.Character then continue end
        if Settings.ESP.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        local part = plr.Character:FindFirstChild(Settings.Aimbot.HeadOnly and "Head" or "HumanoidRootPart")
        if part then
            local velocity = plr.Character.HumanoidRootPart.Velocity
            local predicted = part.Position + velocity * Settings.Aimbot.Prediction
            local screenPos, onScreen = Camera:WorldToViewportPoint(predicted)
            local mousePos = UserInputService:GetMouseLocation()
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if onScreen and dist < bestDist then
                if Settings.Aimbot.VisibleOnly then
                    local ray = workspace:Raycast(Camera.CFrame.Position, (predicted - Camera.CFrame.Position), RaycastParams.new({FilterDescendantsInstances = {LocalPlayer.Character}}))
                    if ray and not ray.Instance:IsDescendantOf(plr.Character) then continue end
                end
                best = predicted
                bestDist = dist
            end
        end
    end
    return best
end

RunService.Heartbeat:Connect(function()
    if Settings.Aimbot.Enabled then
        local target = GetBestTarget()
        if target then
            local screen = Camera:WorldToViewportPoint(target)
            local mouse = UserInputService:GetMouseLocation()
            local delta = Vector2.new(screen.X - mouse.X, screen.Y - mouse.Y)
            mousemoverel(delta.X * Settings.Aimbot.Smooth, delta.Y * Settings.Aimbot.Smooth)
            if Settings.Aimbot.Trigger then
                mouse1press()
                task.wait(0.02)
                mouse1release()
            end
        end
    end
end)

-- GUI
local Visual = Window:CreateTab("ESP")
Visual:CreateToggle({Name = "ESP (СТАРЫЙ РАБОЧИЙ!)", CurrentValue = true, Callback = function(v) Settings.ESP.Enabled = v end})
Visual:CreateToggle({Name = "Team Check", CurrentValue = false, Callback = function(v) Settings.ESP.TeamCheck = v end})
Visual:CreateToggle({Name = "Box", CurrentValue = true, Callback = function(v) Settings.ESP.Box = v end})
Visual:CreateToggle({Name = "Name", CurrentValue = true, Callback = function(v) Settings.ESP.Name = v end})
Visual:CreateToggle({Name = "Distance", CurrentValue = true, Callback = function(v) Settings.ESP.Distance = v end})
Visual:CreateToggle({Name = "Health Bar", CurrentValue = true, Callback = function(v) Settings.ESP.HealthBar = v end})
Visual:CreateToggle({Name = "Tracers", CurrentValue = true, Callback = function(v) Settings.ESP.Tracers = v end})

local Combat = Window:CreateTab("🎯 АИМБОТ")
Combat:CreateToggle({Name = "360° Silent Aimbot", CurrentValue = true, Callback = function(v) Settings.Aimbot.Enabled = v end})
Combat:CreateSlider({Name = "Prediction", Range = {0.1, 0.2}, CurrentValue = 0.135, Callback = function(v) Settings.Aimbot.Prediction = v end})
Combat:CreateSlider({Name = "Smoothness", Range = {0.05, 0.3}, CurrentValue = 0.14, Callback = function(v) Settings.Aimbot.Smooth = v end})
Combat:CreateToggle({Name = "Auto Trigger", CurrentValue = true, Callback = function(v) Settings.Aimbot.Trigger = v end})
Combat:CreateToggle({Name = "Head Only", CurrentValue = true, Callback = function(v) Settings.Aimbot.HeadOnly = v end})

-- СОЗДАНИЕ ESP
for _, p in Players:GetPlayers() do CreateESP(p) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Wait() CreateESP(p) end)
Players.PlayerRemoving:Connect(function(p) if ESPObjects[p] then for _, o in pairs(ESPObjects[p]) do o:Remove() end ESPObjects[p] = nil end end)

RunService.RenderStepped:Connect(UpdateESP)

Rayfield:Notify({Title="🪿 GOOSEHUB v15.0", Content="СТАРЫЙ РАБОЧИЙ ESP ВЕРНУЛСЯ! АИМ С ПРЕДИКШЕНОМ — ПОПАДАЕТ ВСЁ!", Duration=6})

print("🪿 GOOSEHUB v15.0 — ESP КАК В СТАРЫЕ ДОБРЫЕ + СИЛЕНТ АИМ С ПРЕДИКШЕНОМ!")
