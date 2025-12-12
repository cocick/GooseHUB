-- 🪿 GOOSEHUB v23.5 — БЛЮР + МЯГКИЕ АНИМАЦИИ + ИДЕАЛЬНЫЕ ВКЛАДКИ + БИНДЫ

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- =============================
-- НАСТРОЙКИ
-- =============================
local Settings = {
    ESP = {Enabled = true, TeamCheck = false, Box = true, Name = true, Distance = true, HealthBar = true, Tracers = true},
    Aimbot = {Enabled = false, Prediction = 0.135, Smoothness = 0.14, TriggerBot = true, HeadOnly = true},
    Binds = {Menu = Enum.KeyCode.K, Aimbot = Enum.KeyCode.H}
}

local MenuOpen = false
local ChangingBind = nil

-- =============================
-- GUI
-- =============================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "GooseHubV23"

-- БЛЮР ФОНА
local Blur = Instance.new("BlurEffect", game.Lighting)
Blur.Size = 0

-- ТЕНЬ
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.fromOffset(560,460)
Shadow.Position = UDim2.new(0.5,-280,0.5,-230)
Shadow.BackgroundColor3 = Color3.new(0,0,0)
Shadow.BackgroundTransparency = 0.45
Shadow.ZIndex = 0
Shadow.Visible = false
Shadow.Parent = ScreenGui
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0,20)

-- ОСНОВНОЕ МЕНЮ
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(0,0)
Main.Position = UDim2.new(0.5,-250,0.5,-200)
Main.BackgroundColor3 = Color3.fromRGB(25,25,40)
Main.ZIndex = 2
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1,0,0,50)
Title.BackgroundTransparency = 1
Title.Text = "🪿 GOOSEHUB v23.5 — ХОНК ХОНК"
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.TextColor3 = Color3.fromRGB(255,100,100)

-- ВКЛАДКИ
local TabContainer = Instance.new("Frame", Main)
TabContainer.Size = UDim2.new(1,0,0,50)
TabContainer.Position = UDim2.new(0,0,0,50)
TabContainer.BackgroundTransparency = 1

local TabLayout = Instance.new("UIListLayout", TabContainer)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0,10)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Tabs = {}
local CurrentTab = nil

local function CreateTab(name)
    local Btn = Instance.new("TextButton", TabContainer)
    Btn.Size = UDim2.fromOffset(140,40)
    Btn.BackgroundColor3 = Color3.fromRGB(40,40,60)
    Btn.Text = name
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.TextColor3 = Color3.new(1,1,1)
    local c = Instance.new("UICorner", Btn); c.CornerRadius = UDim.new(0,12)

    -- hover
    Btn.MouseEnter:Connect(function()
        TS:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55,55,80)}):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TS:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40,40,60)}):Play()
    end)

    local Content = Instance.new("ScrollingFrame", Main)
    Content.Size = UDim2.new(1,-20,1,-120)
    Content.Position = UDim2.new(0,10,0,100)
    Content.BackgroundTransparency = 1
    Content.ScrollBarThickness = 6
    Content.Visible = false
    Content.ScrollBarImageColor3 = Color3.fromRGB(255,50,50)

    local layout = Instance.new("UIListLayout", Content)
    layout.Padding = UDim.new(0,10)

    Btn.MouseButton1Click:Connect(function()
        for _,tab in pairs(Tabs) do
            tab.Content.Visible = false
        end
        Content.Visible = true
        CurrentTab = Content
    end)

    Tabs[name] = {Button = Btn, Content = Content}
end

CreateTab("Visuals")
CreateTab("Combat")
CreateTab("Binds")
Tabs["Visuals"].Content.Visible = true
CurrentTab = Tabs["Visuals"].Content

-- =============================
-- ЭЛЕМЕНТЫ (ТОГГЛЫ)
-- =============================
local function AddToggle(tab, name, default, callback)
    local Frame = Instance.new("Frame", tab)
    Frame.Size = UDim2.new(1,0,0,50)
    Frame.BackgroundColor3 = Color3.fromRGB(35,35,55)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0.7,0,1,0)
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0,15,0,0)
    Label.Text = name
    Label.TextColor3 = Color3.new(1,1,1)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.fromOffset(80,35)
    Btn.Position = UDim2.new(1,-95,0.5,-18)
    Btn.BackgroundColor3 = default and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,50,50)
    Btn.Text = default and "ON" or "OFF"
    Btn.Font = Enum.Font.GothamBold
    Btn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,10)

    Btn.MouseButton1Click:Connect(function()
        default = not default
        TS:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = default and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,50,50)}):Play()
        Btn.Text = default and "ON" or "OFF"
        callback(default)
    end)
end

-- VISUALS
AddToggle(Tabs.Visuals.Content, "ESP Enabled", true, function(v) Settings.ESP.Enabled = v end)
AddToggle(Tabs.Visuals.Content, "Team Check", false, function(v) Settings.ESP.TeamCheck = v end)
AddToggle(Tabs.Visuals.Content, "Box ESP", true, function(v) Settings.ESP.Box = v end)
AddToggle(Tabs.Visuals.Content, "Names", true, function(v) Settings.ESP.Name = v end)
AddToggle(Tabs.Visuals.Content, "Distance", true, function(v) Settings.ESP.Distance = v end)
AddToggle(Tabs.Visuals.Content, "Health Bar", true, function(v) Settings.ESP.HealthBar = v end)
AddToggle(Tabs.Visuals.Content, "Tracers", true, function(v) Settings.ESP.Tracers = v end)

-- COMBAT
AddToggle(Tabs.Combat.Content, "Aimbot", false, function(v) Settings.Aimbot.Enabled = v end)
AddToggle(Tabs.Combat.Content, "TriggerBot", true, function(v) Settings.Aimbot.TriggerBot = v end)
AddToggle(Tabs.Combat.Content, "Head Only", true, function(v) Settings.Aimbot.HeadOnly = v end)

-- =============================
-- БИНДЫ
-- =============================
local BindInfo = Instance.new("TextLabel", Tabs.Binds.Content)
BindInfo.Size = UDim2.new(1,0,0,40)
BindInfo.BackgroundTransparency = 1
BindInfo.Font = Enum.Font.Gotham
BindInfo.TextSize = 16
BindInfo.TextColor3 = Color3.new(1,1,1)
BindInfo.Text = "Menu: "..Settings.Binds.Menu.Name.." | Aimbot: "..Settings.Binds.Aimbot.Name

local function MakeBind(text, settingKey)
    local Btn = Instance.new("TextButton", Tabs.Binds.Content)
    Btn.Size = UDim2.new(1,-40,0,50)
    Btn.BackgroundColor3 = Color3.fromRGB(40,40,60)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 16
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Text = text..": "..Settings.Binds[settingKey].Name
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,12)

    Btn.MouseButton1Click:Connect(function()
        Btn.Text = text..": [...]"
        ChangingBind = settingKey
    end)
end

MakeBind("Menu Key","Menu")
MakeBind("Aimbot Key","Aimbot")

UIS.InputBegan:Connect(function(input)
    if ChangingBind and input.KeyCode ~= Enum.KeyCode.Unknown then
        Settings.Binds[ChangingBind] = input.KeyCode
        BindInfo.Text = "Menu: "..Settings.Binds.Menu.Name.." | Aimbot: "..Settings.Binds.Aimbot.Name
        ChangingBind = nil
    end
end)

-- =============================
-- ОТКРЫТИЕ МЕНЮ (K)
-- =============================
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Settings.Binds.Menu then
        MenuOpen = not MenuOpen
        
        if MenuOpen then
            Shadow.Visible = true
            TS:Create(Blur, TweenInfo.new(0.4), {Size = 12}):Play()
            TS:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(500,400)}):Play()
        else
            TS:Create(Blur, TweenInfo.new(0.3), {Size = 0}):Play()
            TS:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(0,0)}):Play()
            task.wait(0.3)
            Shadow.Visible = false
        end
    end

    if input.KeyCode == Settings.Binds.Aimbot then
        Settings.Aimbot.Enabled = not Settings.Aimbot.Enabled
        game.StarterGui:SetCore("SendNotification", {
            Title = "Aimbot",
            Text = Settings.Aimbot.Enabled and "ON" or "OFF",
            Duration = 2
        })
    end
end)

print("🪿 GooseHub v23.5 Loaded — мёд, а не меню")
