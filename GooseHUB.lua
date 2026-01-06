-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local savedCFrame = nil
local running = false

-- === НАСТРОЙКИ ===
local MIN_INCOME = 95

local WAIT_AFTER_TP = 0.5
local HOLD_E_TIME = 0.5
local WAIT_AFTER_E = 0.3

local GUARDIAN_SLEEP_TIME = 8        -- сек без движения = спит
local DIST_SLEEP = 20              -- можно забирать
local DIST_AWAKE = 30                -- нельзя забирать

-- ===== ВСПОМОГАТЕЛЬНОЕ =====
local function getChar()
    local char = player.Character or player.CharacterAdded:Wait()
    return char, char:WaitForChild("Humanoid"), char:WaitForChild("HumanoidRootPart")
end

local function unequipTools()
    local _, humanoid = getChar()
    humanoid:UnequipTools()
end

local function holdE(seconds)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(seconds)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function parseIncome(text)
    local num = string.match(text or "", "%$(%d+)")
    return tonumber(num)
end

-- ===== GUARDIANS ТРЕКИНГ =====
local guardianData = {}
-- guardianData[model] = { lastPos = Vector3, lastMove = time }

local function updateGuardians()
    local live = workspace:FindFirstChild("Live")
    local guardians = live and live:FindFirstChild("Guardians")
    if not guardians then return end

    for _, g in ipairs(guardians:GetChildren()) do
        local root = g:FindFirstChild("RootPart", true)
        if root then
            local data = guardianData[g]
            if not data then
                guardianData[g] = {
                    lastPos = root.Position,
                    lastMove = tick()
                }
            else
                if (root.Position - data.lastPos).Magnitude > 0.5 then
                    data.lastPos = root.Position
                    data.lastMove = tick()
                end
            end
        end
    end
end

-- обновляем движение guardians постоянно
RunService.Heartbeat:Connect(updateGuardians)

-- ===== ПРОВЕРКА GUARDIANS =====
local function isGuardianBlocking(targetPosition)
    local live = workspace:FindFirstChild("Live")
    local guardians = live and live:FindFirstChild("Guardians")
    if not guardians then return false end

    for _, g in ipairs(guardians:GetChildren()) do
        local root = g:FindFirstChild("RootPart", true)
        local data = guardianData[g]

        if root and data then
            local dist = (root.Position - targetPosition).Magnitude
            local idleTime = tick() - data.lastMove

            if idleTime >= GUARDIAN_SLEEP_TIME then
                -- 🟢 Guardian СПИТ
                if dist <= DIST_SLEEP then
                    return true
                end
            else
                -- 🔴 Guardian АКТИВЕН
                if dist <= DIST_AWAKE then
                    return true
                end
            end
        end
    end

    return false
end

-- ===== СБОР И СОРТИРОВКА ЦЕЛЕЙ =====
local function collectTargets()
    local targets = {}

    local live = workspace:FindFirstChild("Live")
    local friends = live and live:FindFirstChild("Friends")
    if not friends then return targets end

    for _, model in ipairs(friends:GetChildren()) do
        local billboard = model:FindFirstChild("FriendBillboard", true)
        local frame = billboard and billboard:FindFirstChild("Frame", true)
        local incomeLabel = frame and frame:FindFirstChild("Income", true)
        local root = model:FindFirstChild("RootPart", true)

        if incomeLabel and incomeLabel:IsA("TextLabel") and root then
            local income = parseIncome(incomeLabel.Text)
            if income and income >= MIN_INCOME then
                if not isGuardianBlocking(root.Position) then
                    table.insert(targets, {
                        root = root,
                        income = income
                    })
                end
            end
        end
    end

    -- 🔽 Сначала самые дорогие
    table.sort(targets, function(a, b)
        return a.income > b.income
    end)

    return targets
end

-- ===== ОСНОВНОЙ ЦИКЛ =====
task.spawn(function()
    while true do
        task.wait(0.2)
        if not running or not savedCFrame then continue end

        local targets = collectTargets()

        for _, t in ipairs(targets) do
            if not running then break end

            local _, _, hrp = getChar()

            hrp.CFrame = t.root.CFrame * CFrame.new(0, 0, -2)
            task.wait(WAIT_AFTER_TP)

            holdE(HOLD_E_TIME)
            task.wait(WAIT_AFTER_E)

            hrp.CFrame = savedCFrame
            task.wait(0.2)

            unequipTools()
        end
    end
end)

-- ===== УПРАВЛЕНИЕ =====
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.Insert then
        local _, _, hrp = getChar()
        savedCFrame = hrp.CFrame
        print("Точка сохранена")

    elseif input.KeyCode == Enum.KeyCode.G then
        running = not running
        print(running and "Автофарм ВКЛ" or "Автофарм ВЫКЛ")
    end
end)
