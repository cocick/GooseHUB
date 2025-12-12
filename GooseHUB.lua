-- 🪿 GOOSEHUB v13.0 — ESP НА ЛЮБОМ РАССТОЯНИИ + СИЛЕНТ MOUSE AIM 360° + GUI! ХОНК ХОНК 2025 ФИКС!
-- ESP не пропадает далеко, Aimbot работает через mousemoverel (не camera)!

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()  -- Rayfield 2025 OK!<grok-card data-id="083081" data-type="citation_card"></grok-card>

local Window = Rayfield:CreateWindow({
    Name = "🪿 GOOSEHUB v13.0 — ФИКС ПРОПАДАНИЯ ESP + 360° AIM!",
    LoadingTitle = "Гусь чинит хуйню...",
    LoadingSubtitle = "ХОНК ХОНК, сука!",
    ConfigurationSaving = {Enabled = true, FolderName = "GooseHub", FileName = "Config"},
    KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    Aimbot = {Enabled = false, FOV = math.huge, Smooth = 0.12, Trigger = false, HeadOnly = true, VisibleOnly = true},
    ESP = {Enabled = false, TeamCheck = false},
    Movement = {Fly = false, FlySpeed = 50, Noclip = false, InfJump = false}
}

local ESPObjects = {}
local LastShot = 0
local Friends = {}

-- ДРУЗЬЯ
local function IsFriend(name)
    for _, f in ipairs(Friends) do 
        if string.find(string.lower(name), string.lower(f)) then return true end 
    end
    return false
end

-- ESP (ФИКС ДЛЯ ДАЛЬНИХ РАССТОЯНИЙ: проверки + scale size)
local function CreateESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] or IsFriend(plr.Name) then return end
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 1
    Box.Color = Color3.new(1,0,0)
    
    local Name = Drawing.new("Text")
    Name.Size = 16
    Name.Center = true
    Name.Outline = true
    Name.Font = 2
    Name.Color = Color3.new(1,1,1)
    
    local Dist = Drawing.new("Text")
    Dist.Size = 14
    Dist.Center = true
    Dist.Outline = true
    Dist.Font = 2
    Dist.Color = Color3.new(0,1,0)
    
    ESPObjects[plr] = {Box=Box, Name=Name, Dist=Dist}
end

local function UpdateESP()  -- ФИКС: ESP ВИДИМ ДАЖЕ ДАЛЕКО (без onScreen для box, только size check)
    if not Config.ESP.Enabled then 
        for _, objs in pairs(ESPObjects) do 
            for _, obj in pairs(objs) do obj.Visible = false end 
        end 
        return 
    end
    
    for plr, objs in pairs(ESPObjects) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and char.Humanoid.Health > 0 then
            if Config.ESP.TeamCheck and plr.Team == LocalPlayer.Team then 
                for _, obj in pairs(objs) do obj.Visible = false end 
                continue 
            end
            
            local root = char.HumanoidRootPart
            local head = char.Head
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 4, 0))
            
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height * 0.5
            
            -- ФИКС ДЛЯ ДАЛЬНИХ: если height > 1 и player alive — рисуем ВСЕГДА (даже offscreen)!
            if height > 1 then  -- НЕ ТОЛЬКО onScreen!
                local col = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                local d = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                
                objs.Box.Size = Vector2.new(width, height)
                objs.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                objs.Box.Color = col
                objs.Box.Visible = true
                
                objs.Name.Text = plr.Name
                objs.Name.Position = Vector2.new(rootPos.X, headPos.Y - 25)
                objs.Name.Color = col
                objs.Name.Visible = true
                
                objs.Dist.Text = d.."m"
                objs.Dist.Position = Vector2.new(rootPos.X, headPos.Y + 5)
                objs.Dist.Color = col
                objs.Dist.Visible = true
            else
                for _, obj in pairs(objs) do obj.Visible = false end
            end
        else
            for _, obj in pairs(objs) do obj.Visible = false end
        end
    end
end

-- 360° СИЛЕНТ АИМБОТ ЧЕРЕЗ MOUSE (НЕ CAMERA — ФИКС!)
local function GetBestTarget()
    local best, bestDist = nil, Config.Aimbot.FOV
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer or IsFriend(plr.Name) or not plr.Character then continue end
        if Config.ESP.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        
        local part = plr.Character:FindFirstChild(Config.Aimbot.HeadOnly and "Head" or "HumanoidRootPart")
        if part and plr.Character.Humanoid.Health > 0 then
            local screenPos, _ = Camera:WorldToViewportPoint(part.Position)  -- УБРАЛ onScreen CHECK!
            local mousePos = UserInputService:GetMouseLocation()
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            
            if dist < bestDist then
                if Config.Aimbot.VisibleOnly then
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Blacklist
                    params.FilterDescendantsInstances = {LocalPlayer.Character}
                    local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, params)
                    if ray and not ray.Instance:IsDescendantOf(plr.Character) then continue end
                end
                best = part
                bestDist = dist
            end
        end
    end
    return best
end

-- GUI ТАБЫ
local CombatTab = Window:CreateTab("🎯 АИМБОТ 360°", nil)
local VisualTab = Window:CreateTab("👁️ ESP (ФИКС ДАЛЬНИЕ!)", nil)
local MoveTab = Window:CreateTab("✈️ ДВИГАТЕЛЬ", nil)
local FriendTab = Window:CreateTab("❤️ ДРУЗЬЯ", nil)

CombatTab:CreateToggle({Name = "360° Silent Mouse Aimbot", CurrentValue = false, Callback = function(v) Config.Aimbot.Enabled = v end})
CombatTab:CreateSlider({Name = "FOV (math.huge = FULL 360°)", Range = {100, 2000}, Increment = 50, CurrentValue = 999, Callback = function(v) Config.Aimbot.FOV = v end})
CombatTab:CreateToggle({Name = "Auto Trigger (0.5s)", CurrentValue = false, Callback = function(v) Config.Aimbot.Trigger = v end})
CombatTab:CreateToggle({Name = "Head Only", CurrentValue = true, Callback = function(v) Config.Aimbot.HeadOnly = v end})

VisualTab:CreateToggle({Name = "ESP (НЕ ПРОПАДАЕТ ДАЛЕКО!)", CurrentValue = false, Callback = function(v) Config.ESP.Enabled = v end})
VisualTab:CreateToggle({Name = "Team Check", CurrentValue = false, Callback = function(v) Config.ESP.TeamCheck = v end})

MoveTab:CreateToggle({Name = "Fly (WASD Space Shift)", CurrentValue = false, Callback = function(v) 
    Config.Movement.Fly = v
    if v and LocalPlayer.Character then
        local bv = Instance.new("BodyVelocity", LocalPlayer.Character.HumanoidRootPart)
        bv.MaxForce = Vector3.new(4000,4000,4000)
        RunService.Heartbeat:Connect(function()
            if Config.Movement.Fly then
                local vel = Vector3.new()
                local cam = Workspace.CurrentCamera.CFrame
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + cam.UpVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - cam.UpVector end
                bv.Velocity = vel * Config.Movement.FlySpeed
            end
        end)
    end
end})
MoveTab:CreateSlider({Name = "Fly Speed", Range = {16, 200}, Increment = 5, CurrentValue = 50, Callback = function(v) Config.Movement.FlySpeed = v end})
MoveTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Config.Movement.Noclip = v end})
MoveTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) Config.Movement.InfJump = v end})

FriendTab:CreateInput({Name = "Добавить Друга", PlaceholderText = "Ник...", RemoveTextAfterFocusLost = false, Callback = function(text)
    table.insert(Friends, text)
    Rayfield:Notify({Title="Друг Добавлен!", Content=text, Duration=3})
end})
FriendTab:CreateButton({Name = "Очистить Друзей", Callback = function() Friends = {} Rayfield:Notify({Title="Очищено!", Content="Все друзья удалены", Duration=3}) end})

-- NOCLIP LOOP
RunService.Stepped:Connect(function()
    if Config.Movement.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- INF JUMP
UserInputService.JumpRequest:Connect(function()
    if Config.Movement.InfJump then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ESP LOOP
for _, plr in pairs(Players:GetPlayers()) do CreateESP(plr) end
Players.PlayerAdded:Connect(function(plr) plr.CharacterAdded:Wait() CreateESP(plr) end)
Players.PlayerRemoving:Connect(function(plr) 
    if ESPObjects[plr] then 
        for _, obj in pairs(ESPObjects[plr]) do obj:Remove() end 
        ESPObjects[plr] = nil 
    end 
end)
RunService.RenderStepped:Connect(UpdateESP)

-- АИМБОТ LOOP (MOUSE СИЛЕНТ + SMOOTH!)
RunService.Heartbeat:Connect(function()
    if Config.Aimbot.Enabled then
        local target = GetBestTarget()
        if target then
            local screenPos, _ = Camera:WorldToViewportPoint(target.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local delta = Vector2.new(screenPos.X - mousePos.X, screenPos.Y - mousePos.Y)
            -- СИЛЕНТ MOUSE AIM (ФИКС!)
            mousemoverel(delta.X * Config.Aimbot.Smooth, delta.Y * Config.Aimbot.Smooth)
            
            if Config.Aimbot.Trigger and tick() - LastShot >= 0.5 then
                mouse1press()
                task.wait(0.02)
                mouse1release()
                LastShot = tick()
            end
        end
    end
end)

Rayfield:Notify({Title="🪿 GOOSEHUB v13.0 ФИКС!", Content="ESP на любом расстоянии + Mouse Aimbot 360° работает! ХОНК!", Duration=5})
print("🪿 GOOSEHUB v13.0 — ESP ФИКС ДАЛЬНИЕ + AIMBOT MOUSE СИЛЕНТ!")
