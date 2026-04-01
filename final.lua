-- [[ ROCKET ADMIN ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V72"
local isLooping = false
local isStackingActive = false
local isGodMode = false 
local selectedTargets = {} 
local swordName = "OverseerwrathSword"

-- 1. UI SETUP
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 220, 0, 430)
main.Position = UDim2.new(0.5, -110, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "PHASE STRIKE V72"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

-- RESTORED: X EXIT BUTTON
local xBtn = Instance.new("TextButton", main)
xBtn.Size = UDim2.new(0, 25, 0, 25)
xBtn.Position = UDim2.new(1, -30, 0, 5)
xBtn.Text = "X"
xBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
xBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", xBtn)

xBtn.MouseButton1Click:Connect(function() 
    sg:Destroy() 
    isLooping = false 
    isStackingActive = false 
    isGodMode = false
    local char = player.Character
    if char then
        for _, t in pairs(char:GetChildren()) do
            if t.Name == swordName then t.Parent = player.Backpack end
        end
    end
    selectedTargets = {} 
end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0.35, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. RESTORED: UNIVERSAL SHIELD (VOID PROTECTION)
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if root and hum then
        local pos = root.Position
        if pos.Y < -20 or root.AssemblyLinearVelocity.Magnitude > 950 then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(pos.X, 150, pos.Z)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- 3. AGGRESSIVE STACKER (STRICT TOGGLE)
RunService.RenderStepped:Connect(function()
    if isStackingActive then
        local bp = player:FindFirstChild("Backpack")
        local char = player.Character
        if bp and char then
            for _, item in ipairs(bp:GetChildren()) do
                if item.Name == "RocketJumper" then
                    item.Parent = char
                end
            end
        end
    end
end)

-- 4. PHASE TELEPORT & SILENT AIM (WITH 0.5 OFFSET)
local targetIndex = 1
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targets = {}
    for p, active in pairs(selectedTargets) do
        if active and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, p.Character.HumanoidRootPart)
        end
    end

    if #targets > 0 then
        targetIndex = (targetIndex % #targets) + 1
        local currentT = targets[targetIndex]
        
        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
        -- Offset restored to 0.5
        root.CFrame = currentT.CFrame * CFrame.new(0, 0, -2) * CFrame.Angles(math.rad(-90), 0, 0)
        
        if isLooping then
            for _, r in pairs(workspace:GetChildren()) do
                if r:IsA("BasePart") and (r.Name == "Rocket" or r.Name == "Projectile") then
                    if (r.Position - root.Position).Magnitude < 15 then
                        r.CFrame = CFrame.lookAt(r.Position, currentT.Position)
                        r.AssemblyLinearVelocity = (currentT.Position - r.Position).Unit * 300
                    end
                end
            end
        end
    end
end)

-- 5. 30MS TACTICAL CYCLE
task.spawn(function()
    while true do
        local char = player.Character
        local bp = player:FindFirstChild("Backpack")
        
        if isLooping and char then
            local source = isStackingActive and char or (bp or char)
            local jumpers = {}
            for _, t in pairs(source:GetChildren()) do
                if t.Name == "RocketJumper" then table.insert(jumpers, t) end
            end
            
            for i = 1, #jumpers do
                if not isLooping then break end
                local tool = jumpers[i]
                
                if tool.Parent ~= char then tool.Parent = char end
                tool:Activate()
                task.wait(0.03) 
                
                if not isStackingActive and bp then
                    tool.Parent = bp
                end
            end
        end
        task.wait(0.01)
    end
end)

-- 6. GOD MODE STACKER (INTEGRATED)
task.spawn(function()
    while true do
        if isGodMode then
            local char = player.Character
            local bp = player:FindFirstChild("Backpack")
            
            if char and bp then
                local swords = {}
                for _, t in pairs(char:GetChildren()) do
                    if t.Name == swordName then table.insert(swords, t) end
                end
                for _, t in pairs(bp:GetChildren()) do
                    if t.Name == swordName and #swords < 10 then
                        table.insert(swords, t)
                    end
                end

                if #swords > 0 then
                    for _, s in pairs(swords) do s.Parent = char end
                    task.wait(0.02)
                    for _, s in pairs(swords) do s.Parent = bp end
                    task.wait(0.02)
                end
            end
        end
        task.wait(0.01)
    end
end)

-- 7. CARROT
task.spawn(function()
    local lastStack = false
    while true do
        if isStackingActive then
            if not lastStack then lastStack = true task.wait(3) end
            local bp = player:FindFirstChild("Backpack")
            local char = player.Character
            local carrot = (bp and bp:FindFirstChild("Carrot")) or (char and char:FindFirstChild("Carrot"))
            if carrot and char then
                local oldP = carrot.Parent
                carrot.Parent = char
                task.wait(0.1)
                carrot:Activate()
                task.wait(0.1)
                carrot.Parent = oldP
            end
            task.wait(30)
        else
            lastStack = false
            task.wait(0.5)
        end
    end
end)

-- 8. BUTTONS
local function createBtn(txt, y, getVal, setVal)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0, 200, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() 
        setVal(not getVal()) 
        b.BackgroundColor3 = getVal() and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(30, 30, 35) 
    end)
    return b
end

createBtn("LOOP ATTACK", 180, function() return isLooping end, function(v) isLooping = v end)
createBtn("INF STACK", 220, function() return isStackingActive end, function(v) isStackingActive = v end)

local godBtn = createBtn("GOD MODE: OFF", 260, function() return isGodMode end, function(v) isGodMode = v end)
godBtn.MouseButton1Click:Connect(function()
    godBtn.Text = isGodMode and "GOD MODE: ON" or "GOD MODE: OFF"
    if not isGodMode then
        local char = player.Character
        if char then
            for _, t in pairs(char:GetChildren()) do
                if t.Name == swordName then t.Parent = player.Backpack end
            end
        end
    end
end)

local fixBtn = Instance.new("TextButton", main)
fixBtn.Size = UDim2.new(0, 200, 0, 35)
fixBtn.Position = UDim2.new(0, 10, 0, 300)
fixBtn.Text = "INSTANT FIX"
fixBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
fixBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", fixBtn)
fixBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local items = {}
    for _, t in pairs(char:GetChildren()) do if t.Name == "RocketJumper" then table.insert(items, t) end end
    if player.Backpack then for _, t in pairs(player.Backpack:GetChildren()) do if t.Name == "RocketJumper" then table.insert(items, t) end end end
    for _, t in pairs(items) do t.Parent = workspace end
    task.wait(0.1)
    for _, t in pairs(items) do t.Parent = char end
end)

function updateList()
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", scroll)
            b.Size = UDim2.new(1, -5, 0, 25)
            b.Text = p.Name
            b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(40, 40, 40)
            b.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                selectedTargets[p] = not selectedTargets[p]
                b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(40, 40, 40)
            end)
        end
    end
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
