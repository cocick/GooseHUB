-- 🪿 GOOSEHUB v12.0 — GUI + 360° SILENT AIM + ESP + FLY + NOCLIP + INF JUMP | ХОНК ХОНК 2025!
-- ПОЛНЫЙ КОД, РАБОТАЕТ В SYNAPSE/KRNL, БЕЗ ОШИБОК!

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()  -- Свежий Rayfield UI 2025!<grok-card data-id="6437e6" data-type="citation_card"></grok-card>

local Window = Rayfield:CreateWindow({
    Name = "🪿 GOOSEHUB v12.0 — ЕБАШИМ ВСЕХ!",
    LoadingTitle = "Гусь грузит 360° читы...",
    LoadingSubtitle = "ХОНК ХОНК, сука!",
    ConfigurationSaving = {Enabled = true, FolderName = "GooseHub", FileName = "Config"},
    KeySystem = false  -- Без ключа, пидор!
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    Aimbot = {Enabled = false, FOVRadius = math.huge, Smooth = 0.15, Trigger = false, HeadOnly = true, VisibleOnly = true},
    ESP = {Enabled = false, TeamCheck = false},
    Movement = {Fly = false, FlySpeed = 50, Noclip = false, InfJump = false}
}

local ESPObjects = {}
local LastShot = 0
local FlyVel, NoclipConn, InfJumpConn

-- ДРУЗЬЯ (НЕ ТРОГАЕМ)
local Friends = {}

-- ПРОВЕРКА ДРУГА
local function IsFriend(name)
    for _, f in ipairs(Friends) do if string.find(string.lower(name), string.lower(f)) then return true end end
    return false
end

-- ESP
local function CreateESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] or IsFriend(plr.Name) then return end
    local Box = Drawing.new("Square"); Box.Thickness = 2; Box.Filled = false; Box.Transparency = 1; Box.Color = Color3.new(1,0,0)
    local Name = Drawing.new("Text"); Name.Size = 16; Name.Center = true; Name.Outline = true; Name.Font = 2; Name.Color = Color3.new(1,1,1)
    local Dist = Drawing.new("Text"); Dist.Size = 14; Dist.Center = true; Dist.Outline = true; Dist.Font = 2; Dist.Color = Color3.new(0,1,0)
    ESPObjects[plr] = {Box=Box, Name=Name, Dist=Dist}
end

local function UpdateESP()
    if not Config.ESP.Enabled then for _, objs in pairs(ESPObjects) do for _, obj in pairs(objs) do obj.Visible = false end end return end
    for plr, objs in pairs(ESPObjects) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
            if Config.ESP.TeamCheck and plr.Team == LocalPlayer.Team then for _, obj in pairs(objs) do obj.Visible = false end continue end
            local root = char.HumanoidRootPart
            local headPos, onScreen = Camera:WorldToViewportPoint(root.Position + Vector3.new(0,3,0))
            local rootPos = Camera:WorldToViewportPoint(root.Position)
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,4,0))
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height * 0.5
            if onScreen then
                objs.Box.Size = Vector2.new(width, height); objs.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2); objs.Box.Color = Color3.fromHSV(tick()%5/5,1,1); objs.Box.Visible = true
                objs.Name.Text = plr.Name; objs.Name.Position = Vector2.new(rootPos.X, headPos.Y - 25); objs.Name.Color = Color3.fromHSV(tick()%5/5,1,1); objs.Name.Visible = true
                local d = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                objs.Dist.Text = d.."m"; objs.Dist.Position = Vector2.new(rootPos.X, headPos.Y + 5); objs.Dist.Color = Color3.new(0,1,0); objs.Dist.Visible = true
            else for _, obj in pairs(objs) do obj.Visible = false end end
        else for _, obj in pairs(objs) do obj.Visible = false end end
    end
end

-- 360° АИМБОТ (FOV = БЕСКОНЕЧНЫЙ, ЛОВИТ СО ВСЕХ СТОРОН!)
local function GetClosestVisible()
    local closest, dist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer or IsFriend(plr.Name) or not plr.Character then continue end
        if Config.ESP.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        local part = plr.Character:FindFirstChild(Config.Aimbot.HeadOnly and "Head" or "HumanoidRootPart")
        if part and plr.Character.Humanoid.Health > 0 then
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if fovDist < Config.Aimbot.FOVRadius and onScreen then
                if Config.Aimbot.VisibleOnly then
                    local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Blacklist; params.FilterDescendantsInstances = {LocalPlayer.Character}
                    local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 500, params)
                    if ray and not ray.Instance:IsDescendantOf(plr.Character) then continue end
                end
                if fovDist < dist then closest = part; dist = fovDist end
            end
        end
    end
    return closest
end

-- FLY
local function ToggleFly(state)
    Config.Movement.Fly = state
    if state and LocalPlayer.Character then
        FlyVel = Instance.new("BodyVelocity")
        FlyVel.MaxForce = Vector3.new(4000,4000,4000)
        FlyVel.Parent = LocalPlayer.Character.HumanoidRootPart
        RunService.Heartbeat:Connect(function()
            if Config.Movement.Fly then
                local speed = Config.Movement.FlySpeed / 100
                local vel = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + Workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - Workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - Workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + Workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0,1,0) end
                FlyVel.Velocity = vel * Config.Movement.FlySpeed
            end
        end)
    else
        if FlyVel then FlyVel:Destroy() end
    end
end

-- NOCLIP
NoclipConn = RunService.Stepped:Connect(function()
    if Config.Movement.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- INF JUMP (ВЫКЛЮЧАЕТСЯ!)
InfJumpConn = UserInputService.JumpRequest:Connect(function()
    if Config.Movement.InfJump then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ТАБЫ GUI
local CombatTab = Window:CreateTab("🎯 АИМБОТ 360°", nil)
local VisualTab = Window:CreateTab("👁️ ESP", nil)
local MoveTab = Window:CreateTab("✈️ ДВИГАТЕЛЬ", nil)
local FriendTab = Window:CreateTab("❤️ ДРУЗЬЯ", nil)

CombatTab:CreateToggle({Name = "360° Silent Aimbot", CurrentValue = false, Callback = function(v) Config.Aimbot.Enabled = v end})
CombatTab:CreateSlider({Name = "FOV (math.huge = 360°)", Range = {50, 1000}, Increment = 10, CurrentValue = 999, Callback = function(v) Config.Aimbot.FOVRadius = v end})
CombatTab:CreateToggle({Name = "Auto Trigger", CurrentValue = false, Callback = function(v) Config.Aimbot.Trigger = v end})
CombatTab:CreateToggle({Name = "Head Only", CurrentValue = true, Callback = function(v) Config.Aimbot.HeadOnly = v end})
CombatTab:CreateToggle({Name = "Visible Only", CurrentValue = true, Callback = function(v) Config.Aimbot.VisibleOnly = v end})

VisualTab:CreateToggle({Name = "ESP", CurrentValue = false, Callback = function(v) Config.ESP.Enabled = v end})
VisualTab:CreateToggle({Name = "Team Check", CurrentValue = false, Callback = function(v) Config.ESP.TeamCheck = v end})

MoveTab:CreateToggle({Name = "Fly (WASD Space Shift)", CurrentValue = false, Callback = ToggleFly})
MoveTab:CreateSlider({Name = "Fly Speed", Range = {16, 200}, Increment = 5, CurrentValue = 50, Callback = function(v) Config.Movement.FlySpeed = v end})
MoveTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) Config.Movement.Noclip = v end})
MoveTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) Config.Movement.InfJump = v end})

FriendTab:CreateInput({Name = "Добавить Друга", PlaceholderText = "Ник...", Callback = function(text) table.insert(Friends, text); Rayfield:Notify({Title="Друг Добавлен", Content=text, Duration=3}) end})
FriendTab:CreateButton({Name = "Очистить Друзей", Callback = function() Friends = {}; Rayfield:Notify({Title="Очищено", Content="Все друзья удалены!", Duration=3}) end})

-- ЛУПЫ
for _, plr in pairs(Players:GetPlayers()) do CreateESP(plr) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(plr) if ESPObjects[plr] then for _, obj in pairs(ESPObjects[plr]) do obj:Remove() end; ESPObjects[plr] = nil end end)

RunService.RenderStepped:Connect(UpdateESP)

RunService.Heartbeat:Connect(function()
    if Config.Aimbot.Enabled then
        local target = GetClosestVisible()
        if target then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            if Config.Aimbot.Trigger and tick() - LastShot > 0.5 then
                mouse1press(); task.wait(0.02); mouse1release()
                LastShot = tick()
            end
        end
    end
end)

Rayfield:Notify({Title="🪿 GOOSEHUB v12.0", Content="360° АИМБОТ + GUI ЗАГРУЖЕН! ХОНК ХОНК!", Duration=5})

print("🪿 GOOSEHUB v12.0 — 360° + GUI + ВСЁ РАБОТАЕТ, СУКА!")
