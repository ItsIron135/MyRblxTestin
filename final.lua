-- [[ ROCKET ADMIN V39: RENDER-STEPS & VOID V2 ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V39"
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
main.Size = UDim2.new(0, 200, 0, 380)
main.Position = UDim2.new(0.5, -100, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "ROCKET ADMIN V39"
title.TextColor3 = Color3.fromRGB(255, 100, 0)
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

-- 2. HIGH-SPEED VOID PROTECTION
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        -- If you fall below -50 or are falling too fast downward
        if root.Position.Y < -50 or root.AssemblyLinearVelocity.Y < -150 then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(root.Position.X, 150, root.Position.Z)
        end
    end
end)

-- 3. SYNCED ACTION LOOP
task.spawn(function()
    while true do
        local char = player.Character
        local bp = player:FindFirstChild("Backpack")
        if char and bp then
            if isStackingActive then
                for _, item in ipairs(bp:GetChildren()) do
                    if item.Name == "RocketJumper" then item.Parent = char end
                end
            end
            if isLooping then
                for _, item in ipairs(char:GetChildren()) do
                    if item.Name == "RocketJumper" then item:Activate() end
                end
            end
        end
        task.wait(0.03)
    end
end)

-- 4. CARROT THREAD
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

-- 5. BUTTON BUILDER
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
        b.BackgroundColor3 = active and Color3.fromRGB(120, 20, 20) or Color3.fromRGB(40, 40, 45)
    end
    b.MouseButton1Click:Connect(function() setVal(not getVal()) update() end)
end

createBtn("LOOP: ON", "LOOP: OFF", 145, function() return isLooping end, function(v) isLooping = v end)
createBtn("GIVE ALL: ON", "GIVE ALL: OFF", 185, function() return isGiveAllActive end, function(v) isGiveAllActive = v end)
createBtn("INF STACK: ON", "INF STACK: OFF", 225, function() return isStackingActive end, function(v) isStackingActive = v end)

-- FORCE DROP FIX
local fixBtn = Instance.new("TextButton", main)
fixBtn.Size = UDim2.new(0.9, 0, 0, 35)
fixBtn.Position = UDim2.new(0.05, 0, 0, 265)
fixBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
fixBtn.Text = "FORCE DROP FIX"
fixBtn.TextColor3 = Color3.new(1,1,1)
fixBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", fixBtn)
fixBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, t in pairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name == "RocketJumper" then
            t.Parent = workspace
            task.wait(0.05)
            t.Parent = char
        end
    end
end)

local stopTP = Instance.new("TextButton", main)
stopTP.Size = UDim2.new(0.9, 0, 0, 35)
stopTP.Position = UDim2.new(0.05, 0, 0, 310)
stopTP.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
stopTP.Text = "STOP TP LOCK"
stopTP.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", stopTP)
stopTP.MouseButton1Click:Connect(function() targetLock = false if lockConnection then lockConnection:Disconnect() end end)

-- 6. RENDER-STEPPED TELEPORT (The "Sticky" TP)
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
                -- Switch to RenderStepped for frame-perfect tracking
                lockConnection = RunService.RenderStepped:Connect(function()
                    if not targetLock or not p.Character or not player.Character then return end
                    local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and targetRoot then
                        myRoot.Velocity = Vector3.new(0,0,0)
                        -- Offsetting slightly above their head to avoid collision lag
                        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3.5, 0)
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
