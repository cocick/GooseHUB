-- ██████╗  ██████╗  ██████╗ ███████╗███████╗██╗  ██╗██╗   ██╗██████╗ 
-- ██╔════╝ ██╔═══██╗██╔═══██╗██╔════╝██╔════╝██║  ██║██║   ██║██╔══██╗
-- ██║  ███╗██║   ██║██║   ██║███████╗█████╗  ███████║██║   ██║██████╔╝
-- ██║   ██║██║   ██║██║   ██║╚════██║██╔══╝  ██╔══██║██║   ██║██╔══██╗
-- ╚██████╔╝╚██████╔╝╚██████╔╝███████║███████╗██║  ██║╚██████╔╝██║  ██║
--  ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝
--                               by Гусь-убийца 2025

local GooseHub = {
    ESP = {Enabled = false, Box = true, Name = true, Distance = true, Health = true, Tracers = true, TeamCheck = false},
    Aimbot = {Enabled = false, FOV = 250, Smooth = 0.14, Trigger = true, VisibleOnly = true, HeadOnly = true},
    Spin = {Enabled = false, Speed = 800},
    Misc = {NoRecoil = true, InfiniteJump = true, Fly = false, FlySpeed = 100},
    Theme = "Blood", -- "Blood", "Neon", "Ice", "Dark", "PinkHell"
    MenuOpen = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("GOOSEHUB v6.9 — ХОНК ХОНК ЕБАШИМ", "Blood")

-- ═══════════════════ ТЕМЫ ═══════════════════
local Themes = {
    Blood = {SchemeColor = Color3.fromRGB(255,0,0), Background = Color3.fromRGB(15,0,0)},
    Neon = {SchemeColor = Color3.fromRGB(0,255,255), Background = Color3.fromRGB(0,10,20)},
    Ice = {SchemeColor = Color3.fromRGB(0,200,255), Background = Color3.fromRGB(0,5,15)},
    PinkHell = {SchemeColor = Color3.fromRGB(255,20,147), Background = Color3.fromRGB(20,0,20)},
    Dark = {SchemeColor = Color3.fromRGB(255,255,255), Background = Color3.fromRGB(10,10,10)}
}

-- ═══════════════════ ESP ═══════════════════
local ESPObjects = {}
local function CreateESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] then return end
    local Box = Drawing.new("Square"); Box.Thickness = 2; Box.Filled = false; Box.Transparency = 1
    local Name = Drawing.new("Text"); Name.Size = 13; Name.Center = true; Name.Outline = true; Name.Font = 2
    local Dist = Drawing.new("Text"); Dist.Size = 13; Dist.Center = true; Dist.Outline = true; Dist.Font = 2
    local Tracer = Drawing.new("Line"); Tracer.Thickness = 2
    ESPObjects[plr] = {Box=Box, Name=Name, Dist=Dist, Tracer=Tracer}
end

local function UpdateESP()
    if not GooseHub.ESP.Enabled then for _,v in pairs(ESPObjects) do for _,d in pairs(v) do d.Visible=false end end return end
    for plr, objs in pairs(ESPObjects) do
        local char = plr.Character
        if char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
            if GooseHub.ESP.TeamCheck and plr.Team == LocalPlayer.Team then for _,d in pairs(objs) do d.Visible=false end continue end
            
            local root = char.HumanoidRootPart
            local headPos, onScreen = Camera:WorldToViewportPoint(char.Head.Position)
            local rootPos = Camera:WorldToViewportPoint(root.Position)
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,5,0))
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height * 0.6
            
            if onScreen then
                local col = Color3.fromHSV(tick()%5/5,1,1)
                if GooseHub.ESP.Box then objs.Box.Size = Vector2.new(width,height); objs.Box.Position = Vector2.new(rootPos.X-width/2, rootPos.Y-height/2); objs.Box.Color = col; objs.Box.Visible = true end
                if GooseHub.ESP.Name then objs.Name.Text = plr.Name; objs.Name.Position = Vector2.new(rootPos.X, headPos.Y-25); objs.Name.Color = col; objs.Name.Visible = true end
                if GooseHub.ESP.Distance then objs.Dist.Text = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude).."m"; objs.Dist.Position = Vector2.new(rootPos.X, headPos.Y+5); objs.Dist.Color = col; objs.Dist.Visible = true end
                if GooseHub.ESP.Tracers then objs.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); objs.Tracer.To = Vector2.new(rootPos.X, rootPos.Y+height/2); objs.Tracer.Color = col; objs.Tracer.Visible = true end
            else
                for _,d in pairs(objs) do d.Visible=false end
            end
        else
            for _,d in pairs(objs) do d.Visible=false end
        end
    end
end

-- ═══════════════════ AIMBOT ═══════════════════
local function GetClosestVisible()
    local closest, dist = nil, 9e9
    for _, plr in Players:GetPlayers() do
        if plr == LocalPlayer or not plr.Character then continue end
        if GooseHub.Aimbot.TeamCheck and plr.Team == LocalPlayer.Team then continue end
        local part = plr.Character:FindFirstChild(GooseHub.Aimbot.HeadOnly and "Head" or "HumanoidRootPart")
        if part then
            local sp, on = Camera:WorldToViewportPoint(part.Position)
            local screenDist = (Vector2D.new(sp.X,sp.Y) - UserInputService:GetMouseLocation()).Magnitude
            if on and screenDist < GooseHub.Aimbot.FOV and screenDist < dist then
                local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), RaycastParams.new({FilterDescendantsInstances={LocalPlayer.Character}, FilterType=Enum.RaycastFilterType.Blacklist}))
                if not ray or ray.Instance:IsDescendantOf(plr.Character) then
                    closest = part; dist = screenDist
                end
            end
        end
    end
    return closest
end

local lastShot = 0
local function AimbotLoop()
    if not GooseHub.Aimbot.Enabled then return end
    local target = GetClosestVisible()
    if target then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
        if GooseHub.Aimbot.Trigger and tick() - lastShot > 0.5 then
            mouse1press() wait(0.03) mouse1release()
            lastShot = tick()
        end
    end
end

-- ═══════════════════ МЕНЮ ═══════════════════
local MainTab = Window:NewTab("Main Cheats")
local VisualTab = Window:NewTab("Visuals")
local MiscTab = Window:NewTab("Misc")
local ConfigTab = Window:NewTab("Themes & Config")

MainTab:NewToggle("360° Spinbot Trigger", "Стреляет во всех кто смотрит на тебя + сзади", function(state)
    GooseHub.Spin.Enabled = state
    if state then
        spawn(function()
            while GooseHub.Spin.Enabled and wait() do
                LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,0, math.cos(tick()*GooseHub.Spin.Speed),0,math.sin(tick()*GooseHub.Spin.Speed),0)
            end
        end)
    end
end)

MainTab:NewToggle("Silent Aimbot + Trigger 0.5s", "Наводка + автострельба", function(v) GooseHub.Aimbot.Enabled = v end)
MainTab:NewSlider("Aimbot FOV", "", 1000, 50, function(v) GooseHub.Aimbot.FOV = v end)
MainTab:NewToggle("Head Only", "", function(v) GooseHub.Aimbot.HeadOnly = v end)

VisualTab:NewToggle("ESP", "Коробки + трейсеры + всё", function(v) GooseHub.ESP.Enabled = v end)
VisualTab:NewToggle("Team Check", "", function(v) GooseHub.ESP.TeamCheck = v; GooseHub.Aimbot.TeamCheck = v end)

MiscTab:NewToggle("Infinite Jump", "", function(v) GooseHub.Misc.InfiniteJump = v end)
MiscTab:NewToggle("Fly (Noclip)", "", function(v) GooseHub.Misc.Fly = v end)

ConfigTab:NewDropdown("Theme", {"Blood","Neon","Ice","PinkHell","Dark"}, function(theme)
    Library:ChangeTheme(Themes[theme])
end)

-- ═══════════════════ КНОПКА END ═══════════════════
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.End then
        GooseHub.MenuOpen = not GooseHub.MenuOpen
        Library:ToggleUI(GooseHub.MenuOpen)
    end
end)

-- ═══════════════════ ЛУПЫ ═══════════════════
for _,p in Players:GetPlayers() do CreateESP(p) end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Wait() CreateESP(p) end)
Players.PlayerRemoving:Connect(function(p) if ESPObjects[p] then for _,d in pairs(ESPObjects[p]) do d:Remove() end ESPObjects[p]=nil end end)

RunService.RenderStepped:Connect(UpdateESP)
RunService.RenderStepped:Connect(AimbotLoop)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if GooseHub.Misc.InfiniteJump then LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping") end
end)

print("🪿 GOOSEHUB v6.9 ЗАГРУЖЕН! ЖМИ END ЧТОБ ОТКРЫТЬ МЕНЮ, СУКА!")
print("ХОНК ХОНК — ВСЕХ НАХУЙ! 2025")
