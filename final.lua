-- [[ ROCKET ADMIN V58: OVERHEAD TACTICAL ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V58"
local isLooping = false
local targetLock = false
local isStackingActive = false
local lockConnection = nil
local currentTarget = nil

-- 1. UI SETUP
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 200, 0, 350)
main.Position = UDim2.new(0.5, -100, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "ROCKET ADMIN V58"
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
scroll.Size = UDim2.new(0.9, 0, 0.28, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. UNIVERSAL SHIELD & SILENT AIM
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        -- Void/Fling Guard
        if root.Position.Y < -20 or root.AssemblyLinearVelocity.Magnitude > 950 then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(root.Position.X, 150, root.Position.Z)
        end
        
        -- SILENT AIM (Redirects nearby rockets to Target)
        if isLooping and currentTarget and currentTarget.Character then
            local tRoot = currentTarget.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:IsA("BasePart") and (obj.Name == "Rocket" or obj.Name == "Projectile") then
                        if (obj.Position - root.Position).Magnitude < 15 then
                            obj.CFrame = CFrame.lookAt(obj.Position, tRoot.Position)
                            obj.AssemblyLinearVelocity = (tRoot.Position - obj.Position).Unit * 180
                        end
                    end
                end
            end
        end
    end
end)

-- 3. THE FIRING LOOP (30ms Tactical Switch)
task.spawn(function()
    while true do
        local char = player.Character
        local bp = player:FindFirstChild("Backpack")
        if isLooping and char and bp then
            local backpackJumpers = {}
            for _, t in pairs(bp:GetChildren()) do
                if t.Name == "RocketJumper" then table.insert(backpackJumpers, t) end
            end
            for i = 1, #backpackJumpers do
                if not isLooping then break end
                local tool = backpackJumpers[i]
                tool.Parent = char
                task.wait(0.01)
                tool:Activate()
                task.wait(0.03) -- 30ms switch
                if not isStackingActive and tool.Parent == char then
                    tool.Parent = bp
                end
            end
        end
        task.wait(0.01)
    end
end)

-- 4. INF STACK & PRECISION CARROT
task.spawn(function()
    local lastStackState = false
    while true do
        if isStackingActive then
            if not lastStackState then lastStackState = true task.wait(3) end
            local bp = player:FindFirstChild("Backpack")
            local char = player.Character
            if bp and char then
                for _, item in ipairs(bp:GetChildren()) do
                    if item.Name == "RocketJumper" then item.Parent = char end
                end
                local carrot = bp:FindFirstChild("Carrot") or char:FindFirstChild("Carrot")
                if carrot then
                    local oldP = carrot.Parent
                    carrot.Parent = char
                    task.wait(0.1)
                    carrot:Activate()
                    task.wait(0.1)
                    carrot.Parent = oldP
                end
            end
            task.wait(30)
        else
            lastStackState = false
            task.wait(0.5)
        end
    end
end)

-- 5. BUTTONS
local function createBtn(txtOn, txtOff, y, getVal, setVal)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    b.Text = txtOff
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b)
    
    local function update()
        local active = getVal()
        b.Text = active and txtOn or txtOff
        b.BackgroundColor3 = active and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(40, 40, 45)
    end
    b.MouseButton1Click:Connect(function() setVal(not getVal()) update() end)
end

createBtn("LOOP: ON", "LOOP: OFF", 145, function() return isLooping end, function(v) isLooping = v end)
createBtn("INF STACK: ON", "INF STACK: OFF", 195, function() return isStackingActive end, function(v) isStackingActive = v end)

local fixBtn = Instance.new("TextButton", main)
fixBtn.Size = UDim2.new(0.9, 0, 0, 40)
fixBtn.Position = UDim2.new(0.05, 0, 0, 245)
fixBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
fixBtn.Text = "INSTANT FIX"
fixBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", fixBtn)
fixBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local items = {}
    for _, t in pairs(char:GetChildren()) do if t.Name == "RocketJumper" then table.insert(items, t) end end
    for _, t in pairs(player.Backpack:GetChildren()) do if t.Name == "RocketJumper" then table.insert(items, t) end end
    for _, t in pairs(items) do t.Parent = workspace end
    task.wait(0.1)
    for _, t in pairs(items) do t.Parent = char end
end)

local stopTP = Instance.new("TextButton", main)
stopTP.Size = UDim2.new(0.9, 0, 0, 40)
stopTP.Position = UDim2.new(0.05, 0, 0, 295)
stopTP.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
stopTP.Text = "STOP TP"
stopTP.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", stopTP)
stopTP.MouseButton1Click:Connect(function() targetLock = false currentTarget = nil if lockConnection then lockConnection:Disconnect() end end)

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
                currentTarget = p
                if lockConnection then lockConnection:Disconnect() end
                lockConnection = RunService.Heartbeat:Connect(function()
                    if not targetLock or not p.Character or not player.Character then return end
                    local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and targetRoot then
                        myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        -- Positioned back overhead (3.8 studs)
                        myRoot.CFrame = CFrame.lookAt(targetRoot.Position + Vector3.new(0, 3.8, 0), targetRoot.Position)
                    end
                end)
            end)
        end
    end
end

xBtn.MouseButton1Click:Connect(function() sg:Destroy() isLooping = false isStackingActive = false targetLock = false currentTarget = nil end)
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
