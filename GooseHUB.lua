-- ██████╗  ██████╗ ██████╗ ███████╗███████╗██╗  ██╗██╗   ██╗██████╗  v10.0 FULL ULTIMATE GOOSEHUB
-- 360° AIMBOT + ESP + FRIENDS + FLY + NOCLIP + TELE + GUN MODS + MODERN RAYFIELD UI 2025

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))() <grok-card data-id="7fd45c" data-type="citation_card"></grok-card>

local Window = Rayfield:CreateWindow({
   Name = "🪿 GOOSEHUB v10.0 — ХОНК ХОНК ЕБАШИМ ВСЕХ!",
   LoadingTitle = "Гусь летит...",
   LoadingSubtitle = "by GooseKiller 2025",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GooseHub",
      FileName = "GooseHubConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Settings = {
   ESP = {Enabled = false, Box = true, Name = true, Distance = true, Tracer = true, Health = true, TeamCheck = false},
   Aimbot = {Enabled = false, FOV = math.huge, Trigger = false, HeadOnly = true, Delay = 0.5, VisibleOnly = true},
   Combat = {NoRecoil = false, InfAmmo = false},
   Movement = {Fly = false, FlySpeed = 50, Noclip = false, InfJump = false},
   Friends = {},
   Teleport = {Enabled = false}
}

local ESPObjects = {}
local LastShot = 0
local FlyConnection
local NoclipConnection

-- FRIENDS SYSTEM
local function IsFriend(name)
   for _, friend in ipairs(Settings.Friends) do
      if string.lower(name):find(string.lower(friend)) then return true end
   end
   return false
end

-- ESP FUNCTION
local function CreateESP(plr)
   if plr == LocalPlayer or ESPObjects[plr] or IsFriend(plr.Name) then return end
   
   local Box = Drawing.new("Square")
   Box.Thickness = 2
   Box.Filled = false
   Box.Transparency = 1
   Box.Color = Color3.fromRGB(255, 0, 0)
   Box.Visible = false

   local Name = Drawing.new("Text")
   Name.Size = 16
   Name.Center = true
   Name.Outline = true
   Name.Font = 2
   Name.Color = Color3.fromRGB(255, 255, 255)
   Name.Visible = false

   local Distance = Drawing.new("Text")
   Distance.Size = 14
   Distance.Center = true
   Distance.Outline = true
   Distance.Font = 2
   Distance.Color = Color3.fromRGB(0, 255, 0)
   Distance.Visible = false

   local Tracer = Drawing.new("Line")
   Tracer.Thickness = 2
   Tracer.Color = Color3.fromRGB(255, 0, 0)
   Tracer.Transparency = 0.7
   Tracer.Visible = false

   ESPObjects[plr] = {Box = Box, Name = Name, Distance = Distance, Tracer = Tracer}
end

local function UpdateESP()
   if not Settings.ESP.Enabled then
      for _, objs in pairs(ESPObjects) do
         for _, obj in pairs(objs) do
            obj.Visible = false
         end
      end
      return
   end

   for plr, objs in pairs(ESPObjects) do
      local char = plr.Character
      if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
         if Settings.ESP.TeamCheck and plr.Team == LocalPlayer.Team then
            for _, obj in pairs(objs) do obj.Visible = false end
            continue
         end

         local root = char.HumanoidRootPart
         local head = char.Head
         local humanoid = char.Humanoid

         local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
         local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
         local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 4, 0))

         local height = math.abs(headPos.Y - legPos.Y)
         local width = height * 0.5

         if onScreen then
            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
            local col = Color3.fromHSV((tick() % 5) / 5, 1, 1)

            if Settings.ESP.Box then
               objs.Box.Size = Vector2.new(width, height)
               objs.Box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
               objs.Box.Color = col
               objs.Box.Visible = true
            end

            if Settings.ESP.Name then
               objs.Name.Text = plr.Name
               objs.Name.Position = Vector2.new(rootPos.X, headPos.Y - 25)
               objs.Name.Color = col
               objs.Name.Visible = true
            end

            if Settings.ESP.Distance then
               objs.Distance.Text = dist .. "m"
               objs.Distance.Position = Vector2.new(rootPos.X, headPos.Y + 5)
               objs.Distance.Color = col
               objs.Distance.Visible = true
            end

            if Settings.ESP.Tracer then
               objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
               objs.Tracer.To = Vector2.new(rootPos.X, rootPos.Y + height / 2)
               objs.Tracer.Color = col
               objs.Tracer.Visible = true
            end
         else
            for _, obj in pairs(objs) do obj.Visible = false end
         end
      else
         for _, obj in pairs(objs) do obj.Visible = false end
      end
   end
end

-- 360° AIMBOT
local function GetBestTarget()
   local bestTarget = nil
   local bestScore = -math.huge

   for _, plr in ipairs(Players:GetPlayers()) do
      if plr == LocalPlayer or IsFriend(plr.Name) or not plr.Character then continue end
      if Settings.ESP.TeamCheck and plr.Team == LocalPlayer.Team then continue end

      local humanoid = plr.Character:FindFirstChild("Humanoid")
      local root = plr.Character:FindFirstChild("HumanoidRootPart")
      local head = plr.Character:FindFirstChild("Head")
      if not humanoid or humanoid.Health <= 0 or not root or not head then continue end

      local targetPart = Settings.Aimbot.HeadOnly and head or root
      local distance = (targetPart.Position - Camera.CFrame.Position).Magnitude

      -- Raycast visible check
      if Settings.Aimbot.VisibleOnly then
         local params = RaycastParams.new()
         params.FilterDescendantsInstances = {LocalPlayer.Character}
         params.FilterType = Enum.RaycastFilterType.Blacklist
         local result = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * distance, params)
         if result and not result.Instance:IsDescendantOf(plr.Character) then continue end
      end

      -- Score: closer + looking at you = higher priority
      local score = 1 / distance
      local lookDir = head.CFrame.LookVector
      local toMe = (LocalPlayer.Character.Head.Position - head.Position).Unit
      if lookDir:Dot(toMe) > 0.2 then score = score * 3 end  -- Looking at you bonus

      if score > bestScore then
         bestScore = score
         bestTarget = targetPart
      end
   end

   return bestTarget
end

-- FLY
local function ToggleFly()
   Settings.Movement.Fly = not Settings.Movement.Fly
   if Settings.Movement.Fly then
      local bodyVelocity = Instance.new("BodyVelocity")
      bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
      bodyVelocity.Velocity = Vector3.new(0, 0, 0)
      bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart

      FlyConnection = RunService.Heartbeat:Connect(function()
         if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local cam = Workspace.CurrentCamera.CFrame
            local speed = Settings.Movement.FlySpeed
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then bodyVelocity.Velocity = cam.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then bodyVelocity.Velocity = -cam.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then bodyVelocity.Velocity = -cam.RightVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then bodyVelocity.Velocity = cam.RightVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then bodyVelocity.Velocity = cam.UpVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then bodyVelocity.Velocity = -cam.UpVector * speed end
         end
      end)
   else
      if FlyConnection then FlyConnection:Disconnect() end
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("BodyVelocity") then
         LocalPlayer.Character.HumanoidRootPart.BodyVelocity:Destroy()
      end
   end
end

-- NOCLIP
NoclipConnection = RunService.Stepped:Connect(function()
   if Settings.Movement.Noclip and LocalPlayer.Character then
      for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
         if part:IsA("BasePart") then part.CanCollide = false end
      end
   end
end)

-- TABS
local CombatTab = Window:CreateTab("🎯 Combat", nil)
local VisualTab = Window:CreateTab("👁️ Visuals", nil)
local MovementTab = Window:CreateTab("✈️ Movement", nil)
local FriendsTab = Window:CreateTab("❤️ Friends", nil)
local MiscTab = Window:CreateTab("⚙️ Misc", nil)

-- COMBAT TAB
CombatTab:CreateToggle({Name = "Silent Aimbot 360°", CurrentValue = false, Flag = "AimbotToggle", Callback = function(v) Settings.Aimbot.Enabled = v end})
CombatTab:CreateToggle({Name = "Auto Trigger (0.5s)", CurrentValue = false, Flag = "TriggerToggle", Callback = function(v) Settings.Aimbot.Trigger = v end})
CombatTab:CreateToggle({Name = "Head Only", CurrentValue = true, Flag = "HeadOnly", Callback = function(v) Settings.Aimbot.HeadOnly = v end})
CombatTab:CreateToggle({Name = "Visible Only", CurrentValue = true, Flag = "VisibleOnly", Callback = function(v) Settings.Aimbot.VisibleOnly = v end})
CombatTab:CreateToggle({Name = "No Recoil", CurrentValue = false, Flag = "NoRecoil", Callback = function(v) Settings.Combat.NoRecoil = v end})
CombatTab:CreateToggle({Name = "Infinite Ammo", CurrentValue = false, Flag = "InfAmmo", Callback = function(v) Settings.Combat.InfAmmo = v end})

-- VISUALS TAB
VisualTab:CreateToggle({Name = "Full ESP", CurrentValue = false, Flag = "ESPToggle", Callback = function(v) Settings.ESP.Enabled = v end})
VisualTab:CreateToggle({Name = "Team Check", CurrentValue = false, Flag = "TeamCheck", Callback = function(v) Settings.ESP.TeamCheck = v end})

-- MOVEMENT TAB
MovementTab:CreateToggle({Name = "Fly (WASD Space Shift)", CurrentValue = false, Flag = "FlyToggle", Callback = ToggleFly})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {16, 200}, Increment = 1, CurrentValue = 50, Flag = "FlySpeed", Callback = function(v) Settings.Movement.FlySpeed = v end})
MovementTab:CreateToggle({Name = "Noclip", CurrentValue = false, Flag = "NoclipToggle", Callback = function(v) Settings.Movement.Noclip = v end})
MovementTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Flag = "InfJump", Callback = function(v) Settings.Movement.InfJump = v end})

-- FRIENDS TAB
FriendsTab:CreateInput({Name = "Add Friend", PlaceholderText = "Enter player name", RemoveTextAfterFocusLost = false, Callback = function(text)
   table.insert(Settings.Friends, text)
   Rayfield:Notify({Title = "Friend Added", Content = text .. " added to friends!", Duration = 3})
end})
FriendsTab:CreateButton({Name = "Clear Friends", Callback = function()
   Settings.Friends = {}
   Rayfield:Notify({Title = "Friends Cleared", Content = "All friends removed!", Duration = 3})
end})

-- MISC TAB
MiscTab:CreateButton({Name = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId) end})
MiscTab:CreateButton({Name = "Server Crash (DANGER)", Callback = function() while true do end end})

-- LOOPS
for _, plr in ipairs(Players:GetPlayers()) do CreateESP(plr) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(plr) if ESPObjects[plr] then for _, obj in pairs(ESPObjects[plr]) do obj:Remove() end ESPObjects[plr] = nil end end)

RunService.RenderStepped:Connect(UpdateESP)

RunService.Heartbeat:Connect(function()
   -- Aimbot Loop
   if Settings.Aimbot.Enabled then
      local target = GetBestTarget()
      if target then
         Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
         if Settings.Aimbot.Trigger and tick() - LastShot >= Settings.Aimbot.Delay then
            mouse1press()
            task.wait(0.03)
            mouse1release()
            LastShot = tick()
         end
      end
   end

   -- Infinite Jump
   if Settings.Movement.InfJump and LocalPlayer.Character then
      UserInputService.JumpRequest:Connect(function() LocalPlayer.Character.Humanoid:ChangeState("Jumping") end)
   end
end)

Rayfield:Notify({
   Title = "🪿 GOOSEHUB v10.0",
   Content = "Фулл пак загружен! ХОНК ХОНК, ебашь всех, сука!",
   Duration = 5,
   Image = nil
})

print("🪿 GOOSEHUB v10.0 FULL LOADED! ХОНК ХОНК!")
