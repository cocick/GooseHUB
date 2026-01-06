local ProximityPromptService = game:GetService("ProximityPromptService")

local HOLD_TIME = 0.2 -- время удержания (в секундах)

local function setupPrompt(prompt)
    prompt.HoldDuration = HOLD_TIME
    prompt.RequiresLineOfSight = false
end

-- уже существующие
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("ProximityPrompt") then
        setupPrompt(obj)
    end
end

-- новые, которые появятся позже
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        setupPrompt(obj)
    end
end)
