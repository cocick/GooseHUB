-- ██████╗  ██████╗  ██████╗ ███████╗███████╗    █████╗ ██╗███╗   ███╗██████╗  ██████╗ ████████╗ v11.0
-- ХОНК ХОНК, СУКА! ТЕПЕРЬ ВСЁ РАБОТАЕТ КАК НАДО!

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- НАСТРОЙКИ (МЕНЯЙ ЗДЕСЬ)
local Config = {
    Aimbot = {
        Enabled = false,
        FOV = 400,
        Smoothness = 0.18,
        TriggerBot = true,
        VisibleOnly = true,
        TargetPart = "Head", -- "Head" или "HumanoidRootPart"
        TeamCheck = false
    },
    ESP = {
        Enabled = false,
        Box = true,
        Name = true,
        Distance = true,
        Tracer = true,
        TeamCheck = false
    },
    Misc = {
        InfJump = false,
        Fly = false,
        FlySpeed = 100
    },
    Friends = {"твой_ник_если_хочешь"} -- добавляй ники, они не будут в ESP и аимботе
}

-- Проверка друзей
local function IsFriend(name)
    for _, friend in ipairs(Config.Friends) do
        if string.find(string.lower(name), string.lower(friend)) then
            return true
        end
    end
    return false
end

-- FOV КРУГ
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 0, 100)
FOVCircle.Thickness = 2
FOVCircle.Transparency = 0.8
FOVCircle.Filled = false
FOVCircle.Visible = false

-- ESP ОБЪЕКТЫ
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer or ESPObjects[player] or IsFriend(player.Name) then return end

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 1

    local Name = Drawing.new("Text")
    Name.Size = 14
    Name.Center = true
    Name.Outline = true
    Name.Font = 2

    local Distance = Drawing.new("Text")
    Distance.Size = 13
    Distance.Center = true
    Distance.Outline = true
    Distance.Font = 2

    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 2

    ESPObjects[player] = {Box = Box, Name = Name, Distance = Distance, Tracer = Tracer}
end

-- ОБНОВЛЕНИЕ ESP
local function UpdateESP()
    if not Config.ESP.Enabled then
        for _, v in pairs(ESPObjects) do
            v.Box.Visible = false
            v.Name.Visible = false
            v.Distance.Visible = false
            v.Tracer.Visible = false
        end
        return
    end

    for player, drawings in pairs(ESPObjects) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            if Config.ESP.TeamCheck and player.Team == LocalPlayer.Team then
                for _, d in pairs(drawings) do d.Visible = false end
                continue
            end

            local root = char.HumanoidRootPart
            local head = char.Head
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 4, 0))
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height * 0.6
            local col = Color3.fromHSV(tick() % 5 / 5, 1, 1)

            if onScreen then
                if Config.ESP.Box then
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                    drawings.Box.Color = col
                    drawings.Box.Visible = true
                end
                if Config.ESP.Name then
                    drawings.Name.Text = player.Name
                    drawings.Name.Position = Vector2.new(rootPos.X, headPos.Y - 25)
                    drawings.Name.Color = col
                    drawings.Name.Visible = true
                end
                if Config.ESP.Distance then
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                    drawings.Distance.Text = dist.."m"
                    drawings.Distance.Position = Vector2.new(rootPos.X, headPos.Y + 5)
                    drawings.Distance.Color = col
                    drawings.Distance.Visible = true
                end
                if Config.ESP.Tracer then
                    drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + height/2)
                    drawings.Tracer.Color = col
                    drawings.Tracer.Visible = true
                end
            else
                for _, d in pairs(drawings) do d.Visible = false end
            end
        else
            for _, d in pairs(drawings) do d.Visible = false end
        end
    end
end

-- ЛУЧШАЯ ЦЕЛЬ ДЛЯ АИМБОТА
local function GetBestTarget()
    local best = nil
 local bestDist = Config.Aimbot.FOV

    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer or IsFriend(plr.Name) or not plr.Character then continue end
        if Config.Aimbot.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local part = plr.Character:FindFirstChild(Config.Aimbot.TargetPart)
        if not part then continue end

        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
        local mousePos = UserInputService:GetMouseLocation()
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

        if onScreen and dist < bestDist then
            if Config.Aimbot.VisibleOnly then
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {LocalPlayer.Character}
                params.FilterType = Enum.RaycastFilterType.Blacklist
                local result = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
                if result and not result.Instance:IsDescendantOf(plr.Character) then continue end
            end
            best = part
            bestDist = dist
        end
    end
    return best
end

-- ОСНОВНОЙ АИМБОТ ЛУП (СИЛЕНТ + SMOOTH)
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Config.Aimbot.FOV
    FOVCircle.Visible = Config.Aimbot.Enabled

    if not Config.Aimbot.Enabled then return end

    local target = GetBestTarget()
    if target then
        -- СИЛЕНТ АИМ (камера смотрит в цель)
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)

        -- Плавное движение мыши (если хочешь)
        if Config.Aimbot.Smoothness > 0 then
            local screenPos = Camera:WorldToViewportPoint(target.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local delta = Vector2.new(screenPos.X - mousePos.X, screenPos.Y - mousePos.Y) * Config.Aimbot.Smoothness
            mousemoverel(delta.X, delta.Y)
        end

        -- Триггербот
        if Config.Aimbot.TriggerBot then
            mouse1press()
            task.wait(0.02)
            mouse1release()
        end
    end
end)

-- INFINITE JUMP (ВЫКЛЮЧАЕТСЯ НОРМАЛЬНО!)
UserInputService.JumpRequest:Connect(function()
    if Config.Misc.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
    end
end)

-- ТОГГЛЫ ПО КЛАВИШАМ
UserInputService.InputBegan:Connect(function(key)
    if key.KeyCode == Enum.KeyCode.RightControl then
        Config.Aimbot.Enabled = not Config.Aimbot.Enabled
        game.StarterGui:SetCore("SendNotification",{Title="Goose Aimbot",Text=Config.Aimbot.Enabled and "ВКЛЮЧЁН" or "ВЫКЛЮЧЕН",Duration=2})
    elseif key.KeyCode == Enum.KeyCode.LeftControl then
        Config.ESP.Enabled = not Config.ESP.Enabled
        game.StarterGui:SetCore("SendNotification",{Title="Goose ESP",Text=Config.ESP.Enabled and "ВКЛЮЧЁН" or "ВЫКЛЮЧЕН",Duration=2})
    elseif key.KeyCode == Enum.KeyCode.F then
        Config.Misc.InfJump = not Config.Misc.InfJump
        game.StarterGui:SetCore("SendNotification",{Title="Inf Jump",Text=Config.Misc.InfJump and "ВКЛ" or "ВЫКЛ",Duration=2})
    end
end)

-- СОЗДАНИЕ ESP ДЛЯ ВСЕХ
for _, p in Players:GetPlayers() do CreateESP(p) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Wait() CreateESP(p) end)

RunService.RenderStepped:Connect(UpdateESP)

print("🪿 GOOSEHUB v11.0 ЗАГРУЖЕН! ХОНК ХОНК!")
print("Right Ctrl — Aimbot | Left Ctrl — ESP | F — Inf Jump")
