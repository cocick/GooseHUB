-- ██████╗  ██████╗  ██████╗ ███████╗███████╗██╗  ██╗██╗   ██╗██████╗  v7.0 FIXED
-- ХОНК ХОНК СУКА, ТЕПЕРЬ БЕЗ ОШИБОК!

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local GooseHub = {
    ESP = {Enabled = false, Box = true, Name = true, Distance = true, Tracers = true, TeamCheck = false},
    Aimbot = {Enabled = false, FOV = 300, HeadOnly = true, TriggerDelay = 0.5},
    Misc = {InfJump = false}
}

local ESPObjects = {}

-- ЗАГРУЖАЕМ СВЕЖИЙ KAVO БЕЗ ГОВНА
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua'))()

local Window = Library.CreateLib("GOOSEHUB v7.0 — ГУСЬ ЕБЁТ ВСЕХ", "Blood")

-- ═══════════════════ ESP ═══════════════════
local function CreateESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] then return end
    local t = {}
    t.Box = Drawing.new("Square"); t.Box.Thickness = 2; t.Box.Filled = false; t.Box.Transparency = 1
    t.Name = Drawing.new("Text"); t.Name.Size = 14; t.Name.Center = true; t.Name.Outline = true; t.Name.Font = 2
    t.Dist = Drawing.new("Text"); t.Dist.Size = 13; t.Dist.Center = true; t.Dist.Outline = true
    t.Tracer = Drawing.new("Line"); t.Tracer.Thickness = 2
    ESPObjects[plr] = t
end

local function UpdateESP()
    if not GooseHub.ESP.Enabled then for _,v in pairs(ESPObjects) do for _,d in pairs(v) do d.Visible = false end end return end
    for plr, obj in pairs(ESPObjects) do
        local char = plr.Character
        if char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            if GooseHub.ESP.TeamCheck and plr.Team == LocalPlayer.Team then for _,d in pairs(obj) do d.Visible = false end continue end
            local root = char.HumanoidRootPart
            local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0,0.5,0))
            local rootPos = Camera:WorldToViewportPoint(root.Position)
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,4,0))
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height * 0.6
            local col = Color3.fromHSV(tick() % 6 / 6, 1, 1)

            if onScreen then
                if GooseHub.ESP.Box then obj.Box.Size = Vector2.new(width, height); obj.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2); obj.Box.Color = col; obj.Box.Visible = true end
                if GooseHub.ESP.Name then obj.Name.Text = plr.Name; obj.Name.Position = Vector2.new(rootPos.X, headPos.Y - 25); obj.Name.Color = col; obj.Name.Visible = true end
                if GooseHub.ESP.Distance then obj.Dist.Text = math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude).."m"; obj.Dist.Position = Vector2.new(rootPos.X, headPos.Y + 5); obj.Dist.Color = col; obj.Dist.Visible = true end
                if GooseHub.ESP.Tracers then obj.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); obj.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + height/2); obj.Tracer.Color = col; obj.Tracer.Visible = true end
            else
                for _,d in pairs(obj) do d.Visible = false end
            end
        else
            for _,d in pairs(obj) do d.Visible = false end
        end
    end
end

-- ═══════════════════ AIMBOT ═══════════════════
local lastShot = 0
local function AimbotLoop()
    if not GooseHub.Aimbot.Enabled or not LocalPlayer.Character then return end
    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer or not plr.Character or not plr.Character:FindFirstChild("Head") then continue end
        if GooseHub.ESP.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        
        local head = plr.Character.Head
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        local mousePos = UserInputService:GetMouseLocation()
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        if onScreen and dist < GooseHub.Aimbot.FOV then
            local ray = workspace:Raycast(Camera.CFrame.Position, head.Position - Camera.CFrame.Position, RaycastParams or RaycastParams.new())
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {LocalPlayer.Character}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            local result = workspace:Raycast(Camera.CFrame.Position, head.Position - Camera.CFrame.Position, params)
            
            if not result or result.Instance:IsDescendantOf(plr.Character) then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position)
                if tick() - lastShot >= GooseHub.Aimbot.TriggerDelay then
                    mouse1press()
                    task.wait(0.03)
                    mouse1release()
                    lastShot = tick()
                end
                break
            end
        end
    end
end

-- ═══════════════════ МЕНЮ ═══════════════════
local Main = Window:NewTab("Combat")
local Visual = Window:NewTab("Visual")
local Misc = Window:NewTab("Misc")
local Settings = Window:NewTab("Settings")

Main:NewToggle("Silent Aimbot + Autoshoot", "0.5s delay", function(s) GooseHub.Aimbot.Enabled = s end)
Main:NewSlider("Aimbot FOV", "pixels", 1000, 50, function(v) GooseHub.Aimbot.FOV = v end)

Visual:NewToggle("ESP", "Full ESP", function(s) GooseHub.ESP.Enabled = s end)
Visual:NewToggle("Team Check", "", function(s) GooseHub.ESP.TeamCheck = s end)

Misc:NewToggle("Infinite Jump", "", function(s) GooseHub.Misc.InfJump = s end)

Settings:NewDropdown("Theme", {"Blood", "Dark", "Grape", "Light", "Neon", "Ocean"}, function(theme)
    Library:ToggleTheme(theme) -- ← ЭТОТ МЕТОД РАБОТАЕТ В 2025!
end)

Settings:NewKeybind("Toggle Menu", "End key", Enum.KeyCode.End, function()
    Library:ToggleUI()
end)

-- ═══════════════════ ДОПОЛНИТЕЛЬНО ═══════════════════
for _,p in Players:GetPlayers() do CreateESP(p) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Wait() CreateESP(p) end)

UserInputService.JumpRequest:Connect(function()
    if GooseHub.Misc.InfJump then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

RunService.RenderStepped:Connect(UpdateESP)
RunService.RenderStepped:Connect(AimbotLoop)

print("🪿 GOOSEHUB v7.0 УСПЕШНО ЗАГРУЖЕН! ЖМИ END ДЛЯ МЕНЮ, ПИДОР!")
print("ХОНК ХОНК — 2025 НАШ, СУКА!")
