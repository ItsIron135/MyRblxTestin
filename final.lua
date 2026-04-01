-- [[ ROCKET ADMIN V50: HOT-SWAP MACHINE GUN ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V50"
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
main.Size = UDim2.new(0, 200, 0, 390)
main.Position = UDim2.new(0.5, -100, 0.5, -195)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "ROCKET ADMIN V50"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
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
scroll.Size = UDim2.new(0.9, 0, 0.25, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. UNIVERSAL SHIELD (Void Protection - Trigger at -20)
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if root and hum then
        local pos = root.Position
        local vel = root.AssemblyLinearVelocity
        if pos.Y < -20 or vel.Magnitude > 950 then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(pos.X, 150, pos.Z)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- 3. THE MACHINE GUN (Rapid Hot-Swap Logic)
task.spawn(function()
    while true do
        local char = player.Character
        local bp = player:FindFirstChild("Backpack")
        
        if isLooping and char and bp then
            -- Find all rockets currently in the backpack (unfired/ready)
            local backpackJumpers = {}
            for _, t in pairs(bp:GetChildren()) do
                if t.Name == "RocketJumper" then table.insert(backpackJumpers, t) end
            end
            
            for i = 1, #backpackJumpers do
                if not isLooping then break end
                local tool = backpackJumpers[i]
                
                -- HOT-SWAP: Equip, Fire, and immediately move to next
                tool.Parent = char
                tool:Activate()
                
                -- This tiny wait allows the equip/fire animation to trigger
                -- without letting the global cooldown kick in.
                task.wait(0.02) 
            end
        end
        task.wait(0.01)
    end
end)

-- 4. AUTO-STACKER (Independent)
task.spawn(function()
    while true do
        if isStackingActive then
            local bp = player:FindFirstChild("Backpack")
            local char = player.Character
            if bp and char then
                for _, item in ipairs(bp:GetChildren()) do
                    if item.Name == "RocketJumper" then item.Parent = char end
                end
            end
        end
        task.wait(0.5)
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
        b.BackgroundColor3 = active and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(40, 40, 45)
    end
    b.MouseButton1Click:Connect(function() setVal(not getVal()) update() end)
end

createBtn("LOOP: ON", "LOOP: OFF", 145, function() return isLooping end, function(v) isLooping = v end)
createBtn("GIVE ALL: ON", "GIVE ALL: OFF", 185, function() return isGiveAllActive end, function(v) isGiveAllActive = v end)
createBtn("INF STACK: ON", "INF STACK: OFF", 225, function() return isStackingActive end, function(v) isStackingActive = v end)

-- INSTANT FIX
local fixBtn = Instance.new("TextButton", main)
fixBtn.Size = UDim2.new(0.9, 0, 0, 35)
fixBtn.Position = UDim2.new(0.05, 0, 0, 265)
fixBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
fixBtn.Text = "INSTANT FIX"
fixBtn.TextColor3 = Color3.new(1,1,1)
fixBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", fixBtn)
fixBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local jumpers = {}
    for _, t in pairs(char:GetChildren()) do if t.Name == "RocketJumper" then table.insert(jumpers, t) end end
    for _, t in pairs(player.Backpack:GetChildren()) do if t.Name == "RocketJumper" then table.insert(jumpers, t) end end
    for _, t in pairs(jumpers) do t.Parent = workspace end
    task.wait(0.1)
    for _, t in pairs(jumpers) do t.Parent = char end
end)

local stopTP = Instance.new("TextButton", main)
stopTP.Size = UDim2.new(0.9, 0, 0, 35)
stopTP.Position = UDim2.new(0.05, 0, 0, 310)
stopTP.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopTP.Text = "STOP TP"
stopTP.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", stopTP)
stopTP.MouseButton1Click:Connect(function() targetLock = false if lockConnection then lockConnection:Disconnect() end end)

-- 6. TARGET SYSTEM
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
                    local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and targetRoot then
                        myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        myRoot.CFrame = CFrame.lookAt(targetRoot.Position + Vector3.new(0, 3.8, 0), targetRoot.Position)
                    end
                end)
            end)
        end
    end
end

xBtn.MouseButton1Click:Connect(function() sg:Destroy() isLooping = false isStackingActive = false targetLock = false end)
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
