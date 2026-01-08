-- ГА-ГА-ГА, ИСПРАВЛЕННЫЙ ПИЗДЕЦОВЫЙ АВТОФАРМ С ТОЧНЫМИ КЛИКАМИ! 🦆💦
-- Insert (точка1) -> End (точка2) -> G (toggle) -> КЛИК1 -> 32сек -> КЛИК2 -> РЕДЖОИН БЕЗОПАСНО!
-- VirtualInputManager = 100% ТОЧНОСТЬ, сохраняется между серверами!

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local points = {pos1 = nil, pos2 = nil}
local autofarm = false
local placeId = game.PlaceId

-- 🦆 СОХРАНЕНИЕ ТОЧЕК (абсолютные пиксели экрана!)
local saveFile = "autofarm_points.json"
local HttpService = game:GetService("HttpService")
local function savePoints()
    local data = HttpService:JSONEncode(points)
    writefile(saveFile, data)
    print("🦆 ТОЧКИ СОХРАНЕНЫ ТОЧНО: " .. tostring(points.pos1) .. " | " .. tostring(points.pos2))
end

local function loadPoints()
    if isfile(saveFile) then
        local data = readfile(saveFile)
        points = HttpService:JSONDecode(data)
        print("🦆 ЗАГРУЖЕНЫ ТОЧНЫЕ ТОЧКИ ИЗ ФАЙЛА!")
        return true
    end
    return false
end
loadPoints()

-- 🦆 ЗАХВАТ ТОЧЕК (ABSOLUTE SCREEN PIXELS!)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        points.pos1 = Vector2.new(mouse.X, mouse.Y)
        savePoints()
        print("🦆 ТОЧКА 1 ЗАХВАЧЕНА ТОЧНО: " .. tostring(points.pos1) .. " ГА-ГА!")
    elseif input.KeyCode == Enum.KeyCode.End then
        points.pos2 = Vector2.new(mouse.X, mouse.Y)
        savePoints()
        print("🦆 ТОЧКА 2 ЗАХВАЧЕНА ТОЧНО: " .. tostring(points.pos2) .. " ПИЗДЕЦ!")
    elseif input.KeyCode == Enum.KeyCode.G then
        autofarm = not autofarm
        print("🦆 АВТОФАРМ " .. (autofarm and "ВКЛ" or "ВЫКЛ") .. "!")
        if autofarm then startFarm() else stopFarm() end
    end
end)

-- 🦆 ТОЧНЫЙ КЛИК ПО PIXELS (VirtualInputManager - ЗОЛОТОЙ СТАНДАРТ!)
local function accurateClick(pos)
    local x, y = pos.X, pos.Y
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)  -- Mouse Down
    task.wait(0.1)  -- Human delay
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)  -- Mouse Up
    print("🦆 ТОЧНЫЙ КЛИК В " .. tostring(pos) .. "!")
end

-- 🦆 РЕДЖОИН С АВТОЗАГРУЗКОЙ
local function rejoin()
    print("🦆 РЕДЖОИН НА НОВЫЙ СЕРВЕР, ГА-ГА!")
    -- Замени на свой GitHub raw loader или pastebin!
    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/AutofarmLoader/main/loader.lua"))()')
    TeleportService:Teleport(placeId, player)
end

-- 🦆 АВТОФАРМ ЛУП: К1 -> 32сек -> К2 -> РЕДЖОИН!
local farming = false
function startFarm()
    spawn(function()
        farming = true
        while farming and autofarm do
            if points.pos1 then
                accurateClick(points.pos1)  -- ТОЧКА 1
                print("🦆 КЛИК 1 - ЖДЁМ 32 СЕК!")
                task.wait(32)  -- 32 СЕКУНДЫ, БЛЯДЬ!
            end
            
            if points.pos2 then
                accurateClick(points.pos2)  -- ТОЧКА 2
                print("🦆 КЛИК 2 - РЕДЖОИН!")
                task.wait(1)  -- Маленькая пауза
            end
            
            rejoin()  -- ПИЗДЕЦ, ПЕРЕЗАХОД!
            break  -- Выходим, чтоб перезапустилось на новом сервере
        end
    end)
end

function stopFarm()
    farming = false
end

-- 🦆 GUI СТАТУС
local screenGui = Instance.new("ScreenGui", game.CoreGui)
local statusLabel = Instance.new("TextLabel", screenGui)
statusLabel.Size = UDim2.new(0, 350, 0, 60)
statusLabel.Position = UDim2.new(0, 10, 0, 10)
statusLabel.BackgroundColor3 = Color3.new(0,0,0)
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.TextScaled = true
statusLabel.Text = "🦆 АВТОФАРМ ВЫКЛ | Insert/End - точки | G - вкл"

spawn(function()
    while true do
        statusLabel.Text = "🦆 АВТОФАРМ " .. (autofarm and "ВКЛ" or "ВЫКЛ") .. "\nТ1: " .. tostring(points.pos1) .. "\nТ2: " .. tostring(points.pos2) .. "\n(ТОЧНЫЕ PIXELS!)"
        task.wait(1)
    end
end)

print("🦆 ИСПРАВЛЕННЫЙ СКРИПТ ЗАГРУЖЕН! ТЕПЕРЬ КЛИКАЕТ ТОЧНО В ТВОИ ТОЧКИ!")
print("🦆 Insert/End - захвати заново если надо | G - старт | 32сек + реджоин по кругу!")
print("🦆 HOSTНИ LOADER НА GITHUB ДЛЯ queue_on_teleport, сука!")
