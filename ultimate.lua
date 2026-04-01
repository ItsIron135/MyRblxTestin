-- [[ ROCKET ADMIN V32: AUTO-FIX EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V32"
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
main.Size = UDim2.new(0, 200, 0, 350)
main.Position = UDim2.new(0.5, -100, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "ROCKET ADMIN V32"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
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
scroll.Size = UDim2.new(0.9, 0, 0.3, 0)
scroll.Position = UDim2.new(0.05, 0, 0.12, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. THE IMPROVED AUTO-STACKER (One-by-One Fix)
task.spawn(function()
    while true do
        local char = player.Character
        local bp = player:FindFirstChild("Backpack")
        
        if isStackingActive and char and bp then
            -- We process them one by one to prevent inventory lag
            for _, item in ipairs(bp:GetChildren()) do
                if item:IsA("Tool") and (item.Name == "RocketJumper" or item.Name == "Rocket Jumper") then
                    item.Parent = char
                    -- Smallest possible wait to allow the engine to "register" the tool
                    RunService.Heartbeat:Wait() 
                end
            end
        end
        
        if isLooping and char then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") and (item.Name == "RocketJumper" or item.Name == "Rocket Jumper") then
                    item:Activate()
                end
            end
        end
        task.wait(0.05)
    end
end)

-- 3. CARROT THREAD
task.spawn(function()
    while true do
        if isStackingActive then
            local bp = player:FindFirstChild("Backpack")
            local char = player.Character
            local carrot = (bp and bp:FindFirstChild("Carrot")) or (char and char:FindFirstChild("Carrot"))
            
            if carrot and char then
                carrot.Parent = char
                task.wait(0.1)
                carrot:Activate()
                task.wait(0.1)
                carrot.Parent = player:FindFirstChild("Backpack")
            end
        end
        task.wait(31)
    end
end)

-- 4. GIVE ALL (Optimized Speed)
task.spawn(function()
    local blocks = {"SpawnDiamondBlock", "SpawnGalaxyBlock", "SpawnLuckyBlock", "SpawnRainbowBlock", "SpawnSuperBlock"}
    while true do
        if isGiveAllActive then
            for _, b in pairs(blocks) do
                local remote = RS:FindFirstChild(b)
                if remote then pcall(function() remote:FireServer() end) end
            end
        end
        task.wait(0.6) -- Slightly slower to give the stacker room to breathe
    end
end)

-- 5. BUTTONS
local function createBtn(txtOn, txtOff, y, getVal, setVal)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    b.Text = txtOff
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b)
    
    local function update()
        local active = getVal()
        b.Text = active and txtOn or txtOff
        b.BackgroundColor3 = active and Color3.fromRGB(100, 30, 30) or Color3.fromRGB(40, 40, 45)
    end

    b.MouseButton1Click:Connect(function()
        setVal(not getVal())
        update()
    end)
end

createBtn("LOOP: ON", "LOOP: OFF", 155, function() return isLooping end, function(v) isLooping = v end)
createBtn("GIVE ALL: ON", "GIVE ALL: OFF", 195, function() return isGiveAllActive end, function(v) isGiveAllActive = v end)
createBtn("INF STACK: ON", "INF STACK: OFF", 235, function() return isStackingActive end, function(v) isStackingActive = v end)

local stopTP = Instance.new("TextButton", main)
stopTP.Size = UDim2.new(0.9, 0, 0, 35)
stopTP.Position = UDim2.new(0.05, 0, 0, 285)
stopTP.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
stopTP.Text = "STOP TP LOCK"
stopTP.TextColor3 = Color3.new(1,1,1)
stopTP.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", stopTP)

stopTP.MouseButton1Click:Connect(function()
    targetLock = false
    if lockConnection then lockConnection:Disconnect() end
end)

-- 6. PLAYER LIST
local function updateList()
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", scroll)
            b.Size = UDim2.new(1, -5, 0, 25)
            b.Text = p.Name
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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
