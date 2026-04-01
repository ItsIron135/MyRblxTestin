-- [[ ROCKET ADMIN V26: OVERDRIVE EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- CONFIG & FLAGS
local UI_NAME = "RocketAdmin_V26"
local isLooping = false
local targetLock = false
local isGiveAllActive = false
local isStackingActive = false
local lockConnection = nil

-- 1. UI SETUP
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 200, 0, 320)
main.Position = UDim2.new(0.5, -100, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "ROCKET ADMIN V26"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

local xBtn = Instance.new("TextButton", main)
xBtn.Size = UDim2.new(0, 25, 0, 25)
xBtn.Position = UDim2.new(1, -30, 0, 5)
xBtn.Text = "X"
xBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
xBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", xBtn)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0.35, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. VOID PROTECTION (ULTRA FAST)
task.spawn(function()
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root and root.Position.Y < -60 then
            root.Velocity = Vector3.new(0,0,0)
            root.CFrame = CFrame.new(0, 100, 0) -- TPs you to the sky center
        end
        task.wait(0.1)
    end
end)

-- 3. THE INF-STACKER (OVERDRIVE)
local function useCarrot()
    local bp = player:FindFirstChild("Backpack")
    local char = player.Character
    local carrot = bp and bp:FindFirstChild("Carrot")
    if carrot and char then
        carrot.Parent = char
        task.wait(0.05)
        carrot:Activate()
        task.wait(0.1)
        carrot.Parent = bp
    end
end

task.spawn(function()
    while true do
        if isStackingActive then
            local char = player.Character
            local bp = player:FindFirstChild("Backpack")
            if char and bp then
                -- This loop force-parents all jumpers instantly
                for _, item in ipairs(bp:GetChildren()) do
                    if item.Name == "Rocket Jumper" then
                        item.Parent = char
                    end
                end
            end
        end
        task.wait(0.05) -- High speed stack
    end
end)

task.spawn(function()
    while true do
        if isStackingActive then useCarrot() end
        task.wait(31)
    end
end)

-- 4. BUTTON GENERATOR
local function createActionBtn(textOn, textOff, y, color, flagName)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = color
    b.Text = textOff
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        if flagName == "loop" then isLooping = not isLooping b.Text = isLooping and textOn or textOff
        elseif flagName == "give" then isGiveAllActive = not isGiveAllActive b.Text = isGiveAllActive and textOn or textOff
        elseif flagName == "stack" then isStackingActive = not isStackingActive b.Text = isStackingActive and textOn or textOff
        end
    end)
    return b
end

local loopB = createActionBtn("LOOP: ON", "LOOP: OFF", 155, Color3.fromRGB(150, 0, 0), "loop")
local giveB = createActionBtn("GIVE ALL: ON", "GIVE ALL: OFF", 190, Color3.fromRGB(50, 50, 50), "give")
local stackB = createActionBtn("INF STACK: ON", "INF STACK: OFF", 225, Color3.fromRGB(50, 50, 50), "stack")

local releaseB = Instance.new("TextButton", main)
releaseB.Size = UDim2.new(0.9, 0, 0, 30)
releaseB.Position = UDim2.new(0.05, 0, 0, 260)
releaseB.Text = "RELEASE LOCK"
releaseB.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
releaseB.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", releaseB)
releaseB.MouseButton1Click:Connect(function() targetLock = false end)

-- 5. PLAYER LIST & AUTO-REFRESH
local function updateList()
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", scroll)
            b.Size = UDim2.new(1, -5, 0, 25)
            b.Text = p.Name
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            b.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                targetLock = true
                if lockConnection then lockConnection:Disconnect() end
                lockConnection = RunService.Heartbeat:Connect(function()
                    if not targetLock or not p.Character or not player.Character then return end
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    local head = p.Character:FindFirstChild("Head")
                    if root and head then
                        root.CFrame = head.CFrame * CFrame.new(0, 3, 0)
                        root.Velocity = Vector3.new(0,0,0)
                    end
                end)
            end)
        end
    end
end

-- Rocket Jumper Firing Loop
task.spawn(function()
    while true do
        if isLooping then
            local char = player.Character
            if char then
                for _, item in pairs(char:GetChildren()) do
                    if item:IsA("Tool") and item.Name == "Rocket Jumper" then
                        item:Activate()
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

xBtn.MouseButton1Click:Connect(function() sg:Destroy() isLooping = false isStackingActive = false end)
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
