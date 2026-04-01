-- [[ ROCKET ADMIN V36: JUMPER SPECIALIST ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V36"
local isLooping = false
local targetLock = false
local isStackingActive = false
local lockConnection = nil

-- 1. UI SETUP
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 220, 0, 400)
main.Position = UDim2.new(0.5, -110, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(15, 20, 25)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "ROCKET ADMIN V36"
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

-- 2. SINGLE JUMPER SPAWNER
local getOneBtn = Instance.new("TextButton", main)
getOneBtn.Size = UDim2.new(0.9, 0, 0, 40)
getOneBtn.Position = UDim2.new(0.05, 0, 0, 45)
getOneBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
getOneBtn.Text = "GET 1 ROCKETJUMPER"
getOneBtn.TextColor3 = Color3.new(1,1,1)
getOneBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", getOneBtn)

getOneBtn.MouseButton1Click:Connect(function()
    -- This assumes the remote for the Jumper is "SpawnSuperBlock" or similar 
    -- based on your previous scripts. Change name below if it's different!
    local remote = RS:FindFirstChild("SpawnSuperBlock") 
    if remote then 
        remote:FireServer()
        getOneBtn.Text = "RECEIVED!"
        task.wait(0.5)
        getOneBtn.Text = "GET 1 ROCKETJUMPER"
    end
end)

-- 3. PLAYER LIST SECTION
local playerScroll = Instance.new("ScrollingFrame", main)
playerScroll.Size = UDim2.new(0.9, 0, 0.25, 0)
playerScroll.Position = UDim2.new(0.05, 0, 0.25, 0)
playerScroll.BackgroundTransparency = 1
playerScroll.ScrollBarThickness = 2
local playerLayout = Instance.new("UIListLayout", playerScroll)

-- 4. CORE ACTION LOOPS
task.spawn(function()
    while true do
        local char = player.Character
        local bp = player:FindFirstChild("Backpack")
        if char and bp then
            if isStackingActive then
                for _, item in ipairs(bp:GetChildren()) do
                    if item:IsA("Tool") and item.Name == "RocketJumper" then
                        item.Parent = char
                    end
                end
            end
            if isLooping then
                for _, item in ipairs(char:GetChildren()) do
                    if item:IsA("Tool") and item.Name == "RocketJumper" then
                        item:Activate()
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

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

-- 5. MAIN CONTROL BUTTONS
local function createMainBtn(txtOn, txtOff, y, getVal, setVal)
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
        b.BackgroundColor3 = active and Color3.fromRGB(120, 20, 20) or Color3.fromRGB(40, 40, 45)
    end
    b.MouseButton1Click:Connect(function() setVal(not getVal()) update() end)
end

createMainBtn("LOOP: ON", "LOOP: OFF", 240, function() return isLooping end, function(v) isLooping = v end)
createMainBtn("INF STACK: ON", "INF STACK: OFF", 280, function() return isStackingActive end, function(v) isStackingActive = v end)

local fixBtn = Instance.new("TextButton", main)
fixBtn.Size = UDim2.new(0.9, 0, 0, 35)
fixBtn.Position = UDim2.new(0.05, 0, 0, 320)
fixBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
fixBtn.Text = "FIX ROCKETJUMPERS"
fixBtn.TextColor3 = Color3.new(1,1,1)
fixBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", fixBtn)
fixBtn.MouseButton1Click:Connect(function()
    local bp = player:FindFirstChild("Backpack")
    local char = player.Character
    if bp and char then
        for _, item in pairs(bp:GetChildren()) do
            if item.Name == "RocketJumper" then item.Parent = char task.wait(0.01) item.Parent = bp end
        end
    end
end)

local stopTP = Instance.new("TextButton", main)
stopTP.Size = UDim2.new(0.9, 0, 0, 35)
stopTP.Position = UDim2.new(0.05, 0, 0, 360)
stopTP.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
stopTP.Text = "STOP TP LOCK"
stopTP.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", stopTP)
stopTP.MouseButton1Click:Connect(function() targetLock = false if lockConnection then lockConnection:Disconnect() end end)

-- 6. LIST UPDATE
local function updateList()
    for _, c in pairs(playerScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", playerScroll)
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
                    if root and head then root.CFrame = head.CFrame * CFrame.new(0, 3, 0) root.Velocity = Vector3.new(0,0,0) end
                end)
            end)
        end
    end
end

xBtn.MouseButton1Click:Connect(function() sg:Destroy() isLooping = false isStackingActive = false targetLock = false end)
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
