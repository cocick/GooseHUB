-- 🪿 GOOSEHUB v24.0 — FULL (Menu + ESP v2.1 + Silent Aim + Sliders + Save/Load)
-- Works on Synapse / Krnl / Xeno (where Drawing and exploit functions exist)
-- K = menu (toggle) | H = aimbot toggle
-- Автор: Гусь (подправил и скомпоновал — готово к использованию)

-- ========== Services & locals ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========== Executor feature checks ==========
local HasDrawing, Drawing = pcall(function() return Drawing, Drawing.new end)
if not HasDrawing then
    warn("Drawing API not found. ESP won't work.")
end

-- mouse functions (may be provided by exploit)
local canMouseMove, mousemoverel = pcall(function() return mousemoverel end)
local canMouse1Press, mouse1press = pcall(function() return mouse1press end)
local canMouse1Release, mouse1release = pcall(function() return mouse1release end)
-- file functions
local canWriteFile, writefile = pcall(function() return writefile end)
local canReadFile, readfile = pcall(function() return readfile end)

-- ========== Settings (default) ==========
local Settings = {
    ESP = {Enabled = true, TeamCheck = false, Box = true, Name = true, Distance = true, HealthBar = true, Tracers = true, FOV = true, FOVRadius = 200},
    Aimbot = {Enabled = false, Prediction = 0.135, Smoothness = 0.14, TriggerBot = false, HeadOnly = true, FOV = 150},
    Binds = {Menu = Enum.KeyCode.K, Aimbot = Enum.KeyCode.H},
    Theme = {Accent = Color3.fromRGB(255, 100, 100)}
}

local MenuOpen = false
local ChangingBind = nil
local ESPObjects = {}
local CONFIG_FILE = "GooseHub_v24_config.json"

-- ========== Helpers ==========
local function safeWriteConfig(tbl)
    if not canWriteFile then return false end
    local ok, err = pcall(function()
        writefile(CONFIG_FILE, game:GetService("HttpService"):JSONEncode(tbl))
    end)
    return ok, err
end

local function safeReadConfig()
    if not canReadFile then return nil end
    local ok, content = pcall(function()
        return readfile(CONFIG_FILE)
    end)
    if not ok then return nil end
    local ok2, tbl = pcall(function()
        return game:GetService("HttpService"):JSONDecode(content)
    end)
    if not ok2 then return nil end
    return tbl
end

local function clamp(v, a, b) if v < a then return a end if v > b then return b end return v end

-- ========== GUI (ScreenGui) ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GooseHub_v24"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Shadow (background dim)
local Shadow = Instance.new("Frame", ScreenGui)
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5,0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(0, 560, 0, 460)
Shadow.BackgroundColor3 = Color3.new(0,0,0)
Shadow.BackgroundTransparency = 0.45
Shadow.Visible = false
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0,20)
Shadow.ZIndex = 0

-- Main frame
local Main = Instance.new("Frame", ScreenGui)
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5,0.5)
Main.Position = UDim2.new(0.5,0,0.5,0)
Main.Size = UDim2.new(0,0,0,0)
Main.BackgroundColor3 = Color3.fromRGB(20,20,34)
Main.BorderSizePixel = 0
Main.ZIndex = 2
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,48)
Title.Position = UDim2.new(0,0,0,0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Text = "🪿 GOOSEHUB v24.0 — FULL"
Title.TextColor3 = Settings.Theme.Accent

-- Tabs container
local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(1,0,0,50)
TabContainer.Position = UDim2.new(0,0,0,48)
TabContainer.BackgroundTransparency = 1
local TabLayout = Instance.new("UIListLayout", TabContainer)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0,8)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(0,140,0,36)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,60)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

    local content = Instance.new("ScrollingFrame", Main)
    content.Size = UDim2.new(1,-20,1,-120)
    content.Position = UDim2.new(0,10,0,100)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 6
    content.ScrollBarImageColor3 = Settings.Theme.Accent
    content.Visible = false
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        for k,v in pairs(Tabs) do v.Content.Visible = false end
        content.Visible = true
    end)

    Tabs[name] = {Button = btn, Content = content}
    return Tabs[name]
end

CreateTab("Visuals")
CreateTab("Combat")
CreateTab("Binds")
Tabs["Visuals"].Content.Visible = true

-- Small helper to create toggles
local function AddToggle(parent, labelText, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,44)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,50)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7,0,1,0)
    label.Position = UDim2.new(0,12,0,0)
    label.Text = labelText
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0,80,0,30)
    btn.Position = UDim2.new(1,-95,0.5,-15)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = default and "ON" or "OFF"
    btn.BackgroundColor3 = default and Color3.fromRGB(0,200,100) or Color3.fromRGB(200,60,60)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    btn.MouseButton1Click:Connect(function()
        default = not default
        btn.Text = default and "ON" or "OFF"
        TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = default and Color3.fromRGB(0,200,100) or Color3.fromRGB(200,60,60)}):Play()
        pcall(callback, default)
    end)

    return frame, btn
end

-- Sliders helper
local function AddSlider(parent, labelText, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1,0,0,54)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,50)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0,18)
    label.Position = UDim2.new(0,8,0,6)
    label.BackgroundTransparency = 1
    label.Text = string.format("%s: %.3g", labelText, default)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local barBg = Instance.new("Frame", frame)
    barBg.Size = UDim2.new(1,-16,0,14)
    barBg.Position = UDim2.new(0,8,0,30)
    barBg.BackgroundColor3 = Color3.fromRGB(45,45,65)
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0,6)

    local fill = Instance.new("Frame", barBg)
    fill.Size = UDim2.new((default - min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Settings.Theme.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6)

    local dragging = false
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    barBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mx = UserInputService:GetMouseLocation().X
            local absPos = barBg.AbsolutePosition.X
            local width = barBg.AbsoluteSize.X
            local ratio = clamp((mx - absPos) / width, 0, 1)
            fill.Size = UDim2.new(ratio,0,1,0)
            local value = min + (max-min)*ratio
            label.Text = string.format("%s: %.3g", labelText, value)
            pcall(callback, value)
        end
    end)

    return frame
end

-- Fill Visuals tab
AddToggle(Tabs.Visuals.Content, "ESP Enabled", Settings.ESP.Enabled, function(v) Settings.ESP.Enabled = v end)
AddToggle(Tabs.Visuals.Content, "Team Check", Settings.ESP.TeamCheck, function(v) Settings.ESP.TeamCheck = v end)
AddToggle(Tabs.Visuals.Content, "Box ESP", Settings.ESP.Box, function(v) Settings.ESP.Box = v end)
AddToggle(Tabs.Visuals.Content, "Names", Settings.ESP.Name, function(v) Settings.ESP.Name = v end)
AddToggle(Tabs.Visuals.Content, "Distance", Settings.ESP.Distance, function(v) Settings.ESP.Distance = v end)
AddToggle(Tabs.Visuals.Content, "Health Bar", Settings.ESP.HealthBar, function(v) Settings.ESP.HealthBar = v end)
AddToggle(Tabs.Visuals.Content, "Tracers (от центра)", Settings.ESP.Tracers, function(v) Settings.ESP.Tracers = v end)
AddToggle(Tabs.Visuals.Content, "Show FOV circle", Settings.ESP.FOV, function(v) Settings.ESP.FOV = v end)
AddSlider(Tabs.Visuals.Content, "FOV Radius", 50, 800, Settings.ESP.FOVRadius, function(v) Settings.ESP.FOVRadius = v end)

-- Combat tab
AddToggle(Tabs.Combat.Content, "Aimbot Enabled", Settings.Aimbot.Enabled, function(v) Settings.Aimbot.Enabled = v end)
AddToggle(Tabs.Combat.Content, "Trigger Bot", Settings.Aimbot.TriggerBot, function(v) Settings.Aimbot.TriggerBot = v end)
AddToggle(Tabs.Combat.Content, "Head Only", Settings.Aimbot.HeadOnly, function(v) Settings.Aimbot.HeadOnly = v end)
AddSlider(Tabs.Combat.Content, "Prediction", 0, 1, Settings.Aimbot.Prediction, function(v) Settings.Aimbot.Prediction = v end)
AddSlider(Tabs.Combat.Content, "Smoothness", 0, 1, Settings.Aimbot.Smoothness, function(v) Settings.Aimbot.Smoothness = v end)
AddSlider(Tabs.Combat.Content, "Aimbot FOV", 30, 600, Settings.Aimbot.FOV, function(v) Settings.Aimbot.FOV = v end)

-- Binds tab: display + change
local bindLabel = Instance.new("TextLabel", Tabs.Binds.Content)
bindLabel.Size = UDim2.new(1,0,0,26)
bindLabel.BackgroundTransparency = 1
bindLabel.TextColor3 = Color3.new(1,1,1)
bindLabel.Font = Enum.Font.Gotham
bindLabel.TextSize = 14
bindLabel.Text = "Menu: "..Settings.Binds.Menu.Name.." | Aimbot: "..Settings.Binds.Aimbot.Name

local function MakeBindButton(text, keyName, setter)
    local frame = Instance.new("TextButton", Tabs.Binds.Content)
    frame.Size = UDim2.new(1,-24,0,44)
    frame.Position = UDim2.new(0,12,0,0)
    frame.Text = text..": "..keyName
    frame.Font = Enum.Font.GothamBold
    frame.TextSize = 14
    frame.BackgroundColor3 = Color3.fromRGB(40,40,60)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
    frame.MouseButton1Click:Connect(function()
        frame.Text = text..": [press key]"
        ChangingBind = function(newKey)
            setter(newKey)
            bindLabel.Text = "Menu: "..Settings.Binds.Menu.Name.." | Aimbot: "..Settings.Binds.Aimbot.Name
            frame.Text = text..": "..newKey.Name
        end
    end)
    return frame
end

MakeBindButton("Menu Key", Settings.Binds.Menu.Name, function(k) Settings.Binds.Menu = k end)
MakeBindButton("Aimbot Key", Settings.Binds.Aimbot.Name, function(k) Settings.Binds.Aimbot = k end)

-- Save / Load buttons
local saveBtn = Instance.new("TextButton", Tabs.Binds.Content)
saveBtn.Size = UDim2.new(1,-24,0,40)
saveBtn.Text = "Save config"
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 14
saveBtn.Position = UDim2.new(0,12,0,80)
saveBtn.BackgroundColor3 = Color3.fromRGB(50,80,50)
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0,8)
saveBtn.MouseButton1Click:Connect(function()
    local ok, err = safeWriteConfig(Settings)
    if ok then
        game.StarterGui:SetCore("SendNotification", {Title="GooseHub", Text="Config saved", Duration=2})
    else
        game.StarterGui:SetCore("SendNotification", {Title="GooseHub", Text="Save failed", Duration=2})
    end
end)

local loadBtn = Instance.new("TextButton", Tabs.Binds.Content)
loadBtn.Size = UDim2.new(1,-24,0,40)
loadBtn.Text = "Load config"
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextSize = 14
loadBtn.Position = UDim2.new(0,12,0,130)
loadBtn.BackgroundColor3 = Color3.fromRGB(80,50,50)
Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0,8)
loadBtn.MouseButton1Click:Connect(function()
    local cfg = safeReadConfig()
    if cfg then
        Settings = cfg
        game.StarterGui:SetCore("SendNotification", {Title="GooseHub", Text="Config loaded (restart UI to reflect)", Duration=2})
    else
        game.StarterGui:SetCore("SendNotification", {Title="GooseHub", Text="Load failed or no config", Duration=2})
    end
end)

-- ========== Open/close menu (binds) ==========
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if ChangingBind then
        if input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
            ChangingBind(input.KeyCode)
            ChangingBind = nil
        end
        return
    end

    if input.KeyCode == Settings.Binds.Menu then
        MenuOpen = not MenuOpen
        if MenuOpen then
            Shadow.Visible = true
            TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Size = UDim2.new(0,520,0,420)}):Play()
        else
            TweenService:Create(Main, TweenInfo.new(0.28, Enum.EasingStyle.Back), {Size = UDim2.new(0,0,0,0)}):Play()
            task.wait(0.28)
            Shadow.Visible = false
        end
    elseif input.KeyCode == Settings.Binds.Aimbot then
        Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
        game.StarterGui:SetCore("SendNotification", {Title="GooseHub", Text = "Aimbot: "..(Settings.Aimbot.Enabled and "ON" or "OFF"), Duration = 2})
    end
end)

-- ========== Drawing helpers & ESP creation ==========
local function CreateESPForPlayer(player)
    if not HasDrawing or ESPObjects[player] then return end
    local d = {}
    d.Box = Drawing.new("Square"); d.Box.Thickness = 2; d.Box.Filled = false; d.Box.Transparency = 1
    d.Name = Drawing.new("Text"); d.Name.Size = 14; d.Name.Center = true; d.Name.Outline = true; d.Name.Font = 2
    d.Distance = Drawing.new("Text"); d.Distance.Size = 12; d.Distance.Center = true; d.Distance.Outline = true; d.Distance.Font = 2
    d.Tracer = Drawing.new("Line"); d.Tracer.Thickness = 1.5; d.Tracer.Transparency = 0.9
    d.HPBG = Drawing.new("Line"); d.HP = Drawing.new("Line"); d.HPBG.Thickness = 4; d.HP.Thickness = 3
    ESPObjects[player] = d
end

local function RemoveESPForPlayer(player)
    if not ESPObjects[player] then return end
    for _,v in pairs(ESPObjects[player]) do
        pcall(function() v:Remove() end)
    end
    ESPObjects[player] = nil
end

Players.PlayerRemoving:Connect(function(p) RemoveESPForPlayer(p) end)
Players.PlayerAdded:Connect(function(p) CreateESPForPlayer(p) end)
for _,p in pairs(Players:GetPlayers()) do CreateESPForPlayer(p) end

-- ========== ESP update ==========
local function UpdateESP()
    if not HasDrawing then return end
    if not Settings.ESP.Enabled then
        for p,draws in pairs(ESPObjects) do
            for _,v in pairs(draws) do v.Visible = false end
        end
        return
    end

    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X/2, viewport.Y/2)

    for player, drawings in pairs(ESPObjects) do
        if not player or player == LocalPlayer then
            for _,v in pairs(drawings) do v.Visible = false end
            goto continue
        end

        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
            for _,v in pairs(drawings) do v.Visible = false end
            goto continue
        end

        if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then
            for _,v in pairs(drawings) do v.Visible = false end
            goto continue
        end

        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head") or root
        local hum = char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then
            for _,v in pairs(drawings) do v.Visible = false end
            goto continue
        end

        local rootPos3, onScreen = Camera:WorldToViewportPoint(root.Position)
        local headPos3 = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
        local footPos3 = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,4,0))

        if not onScreen then
            for _,v in pairs(drawings) do v.Visible = false end
            goto continue
        end

        local height = math.abs(headPos3.Y - footPos3.Y)
        local width = height * 0.6
        local x = rootPos3.X - width/2
        local y = rootPos3.Y - height/2
        local hp = clamp(hum.Health / (hum.MaxHealth ~= 0 and hum.MaxHealth or 1), 0, 1)
        local col = Color3.fromHSV(clamp(hp*0.35,0,0.35),1,1)

        -- Box
        if Settings.ESP.Box then
            drawings.Box.Position = Vector2.new(x,y)
            drawings.Box.Size = Vector2.new(width, height)
            drawings.Box.Color = col
            drawings.Box.Visible = true
        else
            drawings.Box.Visible = false
        end

        -- Name
        if Settings.ESP.Name then
            drawings.Name.Text = player.Name
            drawings.Name.Position = Vector2.new(rootPos3.X, y - 8)
            drawings.Name.Color = col
            drawings.Name.Visible = true
        else
            drawings.Name.Visible = false
        end

        -- Distance
        if Settings.ESP.Distance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
            drawings.Distance.Text = string.format("%.0f m", dist)
            drawings.Distance.Position = Vector2.new(rootPos3.X, y + height + 6)
            drawings.Distance.Visible = true
        else
            drawings.Distance.Visible = false
        end

        -- Healthbar
        if Settings.ESP.HealthBar then
            local from = Vector2.new(x - 8, y)
            local to = Vector2.new(x - 8, y + height)
            drawings.HPBG.From = from
            drawings.HPBG.To = to
            drawings.HPBG.Color = Color3.new(0,0,0)
            drawings.HPBG.Visible = true

            drawings.HP.From = Vector2.new(from.X, from.Y + (1 - hp) * height)
            drawings.HP.To = to
            drawings.HP.Color = col
            drawings.HP.Visible = true
        else
            drawings.HPBG.Visible = false
            drawings.HP.Visible = false
        end

        -- Tracer from center bottom
        if Settings.ESP.Tracers then
            local from = Vector2.new(center.X, viewport.Y) -- bottom center
            local to = Vector2.new(rootPos3.X, rootPos3.Y)
            drawings.Tracer.From = from
            drawings.Tracer.To = to
            drawings.Tracer.Color = col
            drawings.Tracer.Visible = true
        else
            drawings.Tracer.Visible = false
        end

        ::continue::
    end
end

-- Draw FOV circle
local FOVCircle = nil
if HasDrawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.Filled = false
    FOVCircle.Visible = false
    FOVCircle.Radius = Settings.ESP.FOVRadius
    FOVCircle.Color = Settings.Theme.Accent
end

-- ========== Silent Aim (target selection) ==========
local function GetAimTarget()
    local bestPos, bestDist = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then goto cont end
        if Settings.ESP.TeamCheck and player.Team == LocalPlayer.Team then goto cont end
        local char = player.Character
        if not char then goto cont end
        local targetPart = char:FindFirstChild(Settings.Aimbot.HeadOnly and "Head" or "HumanoidRootPart")
        if not targetPart then goto cont end
        local vel = char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Velocity or Vector3.new()
        local predicted = targetPart.Position + vel * Settings.Aimbot.Prediction
        local screenPos, onScreen = Camera:WorldToViewportPoint(predicted)
        if not onScreen then goto cont end
        local screenVec = Vector2.new(screenPos.X, screenPos.Y)
        local dist = (screenVec - mousePos).Magnitude
        if dist < bestDist and dist <= Settings.Aimbot.FOV then
            -- optional wallcheck (raycast)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = {LocalPlayer.Character}
            local ray = workspace:Raycast(Camera.CFrame.Position, (predicted - Camera.CFrame.Position), params)
            if ray and ray.Instance and ray.Instance:IsDescendantOf(player.Character) == false then
                -- occluded
                goto cont
            end
            bestDist = dist
            bestPos = predicted
        end
        ::cont::
    end
    return bestPos
end

-- ========== Aimbot loop ==========
RunService.Heartbeat:Connect(function()
    -- update FOV circle pos
    if FOVCircle then
        if Settings.ESP.FOV then
            local mouse = UserInputService:GetMouseLocation()
            FOVCircle.Position = Vector2.new(mouse.X, mouse.Y)
            FOVCircle.Radius = Settings.ESP.FOVRadius
            FOVCircle.Visible = true
            FOVCircle.Color = Settings.Theme.Accent
        else
            FOVCircle.Visible = false
        end
    end

    -- ESP
    UpdateESP()

    -- Aimbot
    if Settings.Aimbot.Enabled then
        local target = GetAimTarget()
        if target then
            local screen, onScreen = Camera:WorldToViewportPoint(target)
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local target2 = Vector2.new(screen.X, screen.Y)
                local delta = (target2 - mousePos) * Settings.Aimbot.Smoothness
                -- move mouse relatively (exploit dependent)
                if canMouseMove and mousemoverel then
                    pcall(function() mousemoverel(delta.X, delta.Y) end)
                end
                -- trigger bot
                if Settings.Aimbot.TriggerBot and canMouse1Press and mouse1press and mouse1release then
                    pcall(mouse1press)
                    task.wait(0.02)
                    pcall(mouse1release)
                end
            end
        end
    end
end)

-- ========== Create & maintain ESP objects for players ==========
for _,p in pairs(Players:GetPlayers()) do CreateESPForPlayer(p) end
Players.PlayerAdded:Connect(function(p) CreateESPForPlayer(p) end)
Players.PlayerRemoving:Connect(function(p) RemoveESPForPlayer(p) end)

-- ========== Final prints ==========
print("🪿 GOOSEHUB v24.0 — FULL loaded. K = menu | H = aimbot")
game.StarterGui:SetCore("SendNotification", {Title="GooseHub", Text="Loaded v24.0", Duration=3})

-- ========== End of script ==========
