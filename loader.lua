-- ГА-ГА-ГА, ПИЗДЕЦОВЫЙ УНИВЕРСАЛЬНЫЙ АВТОФАРМ! 🦆💦
-- Insert (первая точка) -> End (вторая точка) -> G (toggle) -> РЕЖИМ БЕЗОПАСНЫЙ ФАРМ С РЕДЖОЙНОМ!
-- Сохраняется в writefile/getgenv(), работает между серверами, блядь!

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local points = {pos1 = nil, pos2 = nil}
local autofarm = false
local farming = false
local placeId = game.PlaceId  -- Для реджоина в ту же игру

-- 🦆 СОХРАНЕНИЕ/ЗАГРУЗКА ТОЧЕК В ФАЙЛ (МЕЖДУ СЕРВЕРАМИ!)
local saveFile = "autofarm_points.json"
local function savePoints()
    local data = game:GetService("HttpService"):JSONEncode(points)
    writefile(saveFile, data)
    print("🦆 ТОЧКИ СОХРАНЕНЫ В ФАЙЛ, ГА-ГА!")
end

local function loadPoints()
    if isfile(saveFile) then
        local data = readfile(saveFile)
        points = game:GetService("HttpService"):JSONDecode(data)
        print("🦆 ТОЧКИ ЗАГРУЖЕНЫ ИЗ ФАЙЛА: Pos1=" .. tostring(points.pos1) .. " Pos2=" .. tostring(points.pos2))
        return true
    end
    return false
end

loadPoints()  -- Автозагрузка при запуске

-- 🦆 КАПЧЕР ПОЗИЦИЙ МЫШКИ (INSERT/END)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Insert then
        points.pos1 = Vector2.new(mouse.X, mouse.Y)
        savePoints()
        print("🦆 ПЕРВАЯ ТОЧКА ЗАХВАЧЕНА: " .. tostring(points.pos1) .. " ГА-ГА!")
    elseif input.KeyCode == Enum.KeyCode.End then
        points.pos2 = Vector2.new(mouse.X, mouse.Y)
        savePoints()
        print("🦆 ВТОРАЯ ТОЧКА ЗАХВАЧЕНА: " .. tostring(points.pos2) .. " ПИЗДЕЦ!")
    elseif input.KeyCode == Enum.KeyCode.G then
        autofarm = not autofarm
        print("🦆 АВТОФАРМ " .. (autofarm and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН") .. " ГА-ГА-ГА!")
        if autofarm then startFarm() else stopFarm() end
    end
end)

-- 🦆 ФУНКЦИЯ КЛИКА ПО ПОЗИЦИИ (VirtualInputManager или mouse1click)
local function clickAt(pos)
    local oldPos = Vector2.new(mouse.X, mouse.Y)
    mousemoverel((pos.X - oldPos.X), (pos.Y - oldPos.Y))  -- Плавный мув
    wait(0.05)
    mouse1click()  -- Клик!
    wait(0.05)
    mousemoverel((oldPos.X - pos.X), (oldPos.Y - pos.Y))  -- Бэк
end

-- 🦆 РЕДЖОИН ФУНКЦИЯ
local function rejoin()
    print("🦆 РЕДЖОИН, ПИЗДЕЦ! Перезаход на новый сервер...")
    queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/cocick/GooseHUB/refs/heads/main/loader.lua'))()")  -- Автоэкзек на реджойне (замени на свой хост)
    TeleportService:Teleport(placeId, player)
end

-- 🦆 АВТОФАРМ ЛУП
function startFarm()
    spawn(function()
        farming = true
        while farming do
            if not autofarm then break end
            
            -- КЛИК НА ПЕРВУЮ ТОЧКУ
            if points.pos1 then
                clickAt(points.pos1)
                print("🦆 КЛИК ПО ТОЧКЕ 1!")
            end
            
            wait(20)  -- 20 сек ждём, сука!
            
            -- КЛИК НА ВТОРУЮ ТОЧКУ
            if points.pos2 then
                clickAt(points.pos2)
                print("🦆 КЛИК ПО ТОЧКЕ 2!")
            end
            
            wait(1)  -- Пауза между циклами
        end
    end)
    
    -- Авто-реджоин каждые 5 мин (300 сек), чтоб не кикали за AFK
    spawn(function()
        while autofarm do
            wait(300)
            if autofarm then
                rejoin()
            end
        end
    end)
end

function stopFarm()
    farming = false
end

-- 🦆 GUI ИНДИКАТОР (опционально, в CoreGui)
local screenGui = Instance.new("ScreenGui", game.CoreGui)
local statusLabel = Instance.new("TextLabel", screenGui)
statusLabel.Size = UDim2.new(0, 300, 0, 50)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundColor3 = Color3.new(0,0,0)
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.TextScaled = true
statusLabel.Text = "🦆 АВТОФАРМ ВЫКЛ | Insert/End - точки | G - toggle"

spawn(function()
    while true do
        statusLabel.Text = "🦆 АВТОФАРМ " .. (autofarm and "ВКЛ" or "ВЫКЛ") .. "\nТочки: " .. tostring(points.pos1) .. " | " .. tostring(points.pos2)
        wait(1)
    end
end)

print("🦆 СКРИПТ ЗАГРУЖЕН, БЛЯДЬ! Insert на первую точку, End на вторую, G для старта!")
print("🦆 Точки сохраняются в " .. saveFile .. " - работает на всех серверах, га-га-га!")
print("🦆 Авто-реджоин каждые 5 мин, чтоб не спалили! 🦆💦")
