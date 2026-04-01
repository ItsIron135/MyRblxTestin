-- [[ ROCKET ADMIN V25: ROCKET JUMPER SPECIALIST ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- CONFIG & FLAGS
local UI_NAME = "RocketAdmin_V25"
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
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true -- UI is now draggable
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "ROCKET ADMIN V25"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
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

-- 2. GEAR FINDER (Strictly Rocket Jumper)
local function getJumpers()
    local list = {}
    local locs = {player.Backpack, player.Character}
    for _, l in pairs(locs) do
        if l then
            for _, i in pairs(l:GetChildren()) do
                if i:IsA("Tool") and i.Name == "Rocket Jumper" then 
                    table.insert(list, i) 
                end
            end
        end
    end
    return list
end

-- 3. GIVE ALL LOGIC
task.spawn(function()
    local remotes = {"SpawnDiamondBlock", "SpawnGalaxyBlock", "SpawnLuckyBlock", "SpawnRainbowBlock", "SpawnSuperBlock"}
    while true do
        if isGiveAllActive then
            for _, name in pairs(remotes) do
                local r = RS:FindFirstChild(name)
                if r then pcall(function() r:FireServer() end) end
            end
        end
        task.wait(0.2)
    end
end)

-- 4. INF STACKER (With Carrot Buff)
local function useCarrot()
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    if backpack and char then
        local carrot = backpack:FindFirstChild("Carrot")
        if carrot then
            carrot.Parent = char
            task.wait(0.1)
            carrot:Activate()
            task.wait(0.2)
            carrot.Parent = backpack
            print("Carrot Buff Applied") -- Verification
        end
    end
end

-- Carrot Timer Thread
task.spawn(function()
    while true do
        if isStackingActive then
            useCarrot()
            task.wait(30) -- Refreshes every 30 seconds
        end
        task.wait(1)
    end
end)

-- Stacker Thread
task.spawn(function()
    while true do
        if isStackingActive then
            local char = player.Character
            local backpack = player:FindFirstChild("Backpack")
            if char and backpack then
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and item.Name == "Rocket Jumper" then
                        item.Parent = char
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- 5. BUTTON GENERATOR (With Label Fix)
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
        if flagName == "loop" then
            isLooping = not isLooping
            b.Text = isLooping and textOn or textOff
        elseif flagName == "give" then
            isGiveAllActive = not isGiveAllActive
            b.Text = isGiveAllActive and textOn or textOff
        elseif flagName == "stack" then
            isStackingActive = not isStackingActive
            b.Text = isStackingActive and textOn or textOff
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

-- 6. PLAYER LIST
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
                        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    end
                end)
            end)
        end
    end
end

-- Rocket Loop Thread (Strictly Jumper)
task.spawn(function()
    while true do
        if isLooping then
            local jumpers = getJumpers()
            if player.Character and #jumpers > 0 then
                for _, item in pairs(jumpers) do
                    if not isLooping then break end
                    item.Parent = player.Character
                    task.wait(0.01)
                    item:Activate()
                    task.wait(0.05)
                    item.Parent = player:FindFirstChild("Backpack")
                end
            end
        end
        task.wait(0.01)
    end
end)

xBtn.MouseButton1Click:Connect(function() sg:Destroy() isLooping = false isStackingActive = false end)
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
