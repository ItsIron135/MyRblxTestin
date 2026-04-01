-- [[ ROCKET ADMIN V47: THE UNIVERSAL SHIELD ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V47"
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
title.Text = "ROCKET ADMIN V47"
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
scroll.Size = UDim2.new(0.9, 0, 0.25, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. UNIVERSAL SHIELD (Void & Fling Protection)
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if root and hum then
        local pos = root.Position
        local vel = root.AssemblyLinearVelocity
        local shouldReset = false
        
        -- Height check (Void is -30, we trigger at -20)
        if pos.Y < -20 then shouldReset = true end
        
        -- Velocity check (Catching flings/death zones)
        if vel.Magnitude > 850 then shouldReset = true end

        if shouldReset then
            -- LOG COORDINATES TO CONSOLE (F9)
            print(string.format("[SHIELD ACTIVE] Saved at X: %.1f Y: %.1f Z: %.1f", pos.X, pos.Y, pos.Z))
            
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(pos.X, 150, pos.Z)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- 3. CONTINUOUS ACTION LOOP (1-by-1 Firing)
task.spawn(function()
    while true do
        local char = player.Character
        local bp = player:FindFirstChild("Backpack")
        if char then
            if isStackingActive and bp then
                for _, item in ipairs(bp:GetChildren()) do
                    if item.Name == "RocketJumper" then item.Parent = char end
                end
            end
            
            if isLooping then
                local tools = char:GetChildren()
                for i = 1, #tools do
                    local t = tools[i]
                    if t:IsA("Tool") and t.Name == "RocketJumper" then
                        t:Activate()
                        task.wait(0.01) -- High-speed 1-by-1 usage
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

-- 4. BUTTON BUILDER
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
        b.BackgroundColor3 = active and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(40, 40, 45)
    end
    b.MouseButton1Click:Connect(function() setVal(not getVal()) update() end)
end

createBtn("LOOP: ON", "LOOP: OFF", 145, function() return isLooping end, function(v) isLooping = v end)
createBtn("GIVE ALL: ON", "GIVE ALL: OFF", 185, function() return isGiveAllActive end, function(v) isGiveAllActive = v end)
createBtn("INF STACK: ON", "INF STACK: OFF", 225, function() return isStackingActive end, function(v) isStackingActive = v end)

local stopTP = Instance.new("TextButton", main)
stopTP.Size = UDim2.new(0.9, 0, 0, 35)
stopTP.Position = UDim2.new(0.05, 0, 0, 280)
stopTP.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopTP.Text = "STOP TP"
stopTP.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", stopTP)
stopTP.MouseButton1Click:Connect(function() targetLock = false if lockConnection then lockConnection:Disconnect() end end)

-- 5. TARGET SYSTEM
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
                        -- Added LookAt to ensure rockets fire toward target
                        myRoot.CFrame = CFrame.lookAt(targetRoot.Position + Vector3.new(0, 3.5, 0), targetRoot.Position)
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
