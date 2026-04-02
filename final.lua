-- [[ ROCKET ADMIN PHASE STRIKE V72 ]] --
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
if pGui:FindFirstChild(UI_NAME) then
    pGui[UI_NAME]:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = UI_NAME
sg.Parent = pGui
sg.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 220, 0, 430)
main.Position = UDim2.new(0.5, -110, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true 
main.Parent = sg

local uiCorner = Instance.new("UICorner")
uiCorner.Parent = main

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "PHASE STRIKE V72"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = main

-- RESTORED: X EXIT BUTTON
local xBtn = Instance.new("TextButton")
xBtn.Name = "ExitButton"
xBtn.Size = UDim2.new(0, 25, 0, 25)
xBtn.Position = UDim2.new(1, -30, 0, 5)
xBtn.Text = "X"
xBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
xBtn.TextColor3 = Color3.new(1, 1, 1)
xBtn.Font = Enum.Font.SourceSansBold
xBtn.TextSize = 14
local xCorner = Instance.new("UICorner")
xCorner.Parent = xBtn
xBtn.Parent = main

xBtn.MouseButton1Click:Connect(function() 
    sg:Destroy() 
    isLooping = false 
    isStackingActive = false 
    isGodMode = false
    local char = player.Character
    if char then
        for _, t in pairs(char:GetChildren()) do
            if t.Name == swordName then
                t.Parent = player.Backpack
            end
        end
    end
    selectedTargets = {} 
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "TargetList"
scroll.Size = UDim2.new(0.9, 0, 0.35, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = scroll

-- 2. RESTORED: UNIVERSAL SHIELD (VOID PROTECTION - NO DELAY)
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

-- 3. AGGRESSIVE STACKER (STRICT TOGGLE - NO DELAY)
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

-- 4. PHASE TELEPORT & SILENT AIM (SOFT AIM LOGIC - NO DELAY)
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
        if targetIndex > #targets then targetIndex = 1 end
        local currentT = targets[targetIndex]
        targetIndex = (targetIndex % #targets) + 1
        
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.CFrame = currentT.CFrame * CFrame.new(0, 0, 0.5) * CFrame.Angles(math.rad(-90), 0, 0)
        
        if isLooping then
            for _, r in pairs(workspace:GetChildren()) do
                if r:IsA("BasePart") and (r.Name == "Rocket" or r.Name == "Projectile") then
                    local distance = (r.Position - root.Position).Magnitude
                    if distance < 30 then
                        -- SOFT AIM: Instant vector correction toward current target
                        r.CFrame = CFrame.lookAt(r.Position, currentT.Position)
                        r.AssemblyLinearVelocity = (currentT.Position - r.Position).Unit * 500
                    end
                end
            end
        end
    end
end)

-- 5. 20MS TACTICAL CYCLE (SPECIFIC 20MS DELAY PRESERVED)
task.spawn(function()
    while true do
        if isLooping then
            local char = player.Character
            local bp = player:FindFirstChild("Backpack")
            
            if char then
                local source = nil
                if isStackingActive then
                    source = char
                else
                    source = bp or char
                end
                
                local jumpers = {}
                for _, t in pairs(source:GetChildren()) do
                    if t.Name == "RocketJumper" then
                        table.insert(jumpers, t)
                    end
                end
                
                if #jumpers > 0 then
                    for i = 1, #jumpers do
                        if not isLooping then break end
                        local tool = jumpers[i]
                        
                        if tool.Parent ~= char then
                            tool.Parent = char
                        end
                        
                        tool:Activate()
                        
                        -- THE ONLY DELAY ALLOWED (20ms)
                        task.wait(0.02) 
                        
                        if not isStackingActive and bp then
                            tool.Parent = bp
                        end
                    end
                end
            end
        end
        -- Instant cycle check
        RunService.Heartbeat:Wait()
    end
end)

-- 6. GOD MODE STACKER (NO DELAY SWAPPING)
task.spawn(function()
    while true do
        if isGodMode then
            local char = player.Character
            local bp = player:FindFirstChild("Backpack")
            
            if char and bp then
                local swords = {}
                for _, t in pairs(char:GetChildren()) do
                    if t.Name == swordName then
                        table.insert(swords, t)
                    end
                end
                for _, t in pairs(bp:GetChildren()) do
                    if t.Name == swordName and #swords < 15 then
                        table.insert(swords, t)
                    end
                end

                if #swords > 0 then
                    for _, s in pairs(swords) do
                        s.Parent = char
                    end
                    -- No task.wait(0.02) here, removed for max speed
                    RunService.Heartbeat:Wait()
                    for _, s in pairs(swords) do
                        s.Parent = bp
                    end
                    RunService.Heartbeat:Wait()
                end
            end
        end
        RunService.Heartbeat:Wait()
    end
end)

-- 7. CARROT (NO STARTUP DELAY)
task.spawn(function()
    local lastStack = false
    while true do
        if isStackingActive then
            if not lastStack then
                lastStack = true
                -- Removed 3s startup delay
            end
            
            local bp = player:FindFirstChild("Backpack")
            local char = player.Character
            
            local carrot = nil
            if bp and bp:FindFirstChild("Carrot") then
                carrot = bp:FindFirstChild("Carrot")
            elseif char and char:FindFirstChild("Carrot") then
                carrot = char:FindFirstChild("Carrot")
            end
            
            if carrot and char then
                local oldP = carrot.Parent
                carrot.Parent = char
                -- Instant activation sequence
                carrot:Activate()
                carrot.Parent = oldP
            end
            -- Long cooldown between uses to prevent spam kick
            task.wait(30)
        else
            lastStack = false
            RunService.Heartbeat:Wait()
        end
    end
end)

-- 8. BUTTON GENERATOR
local function createBtn(txt, y, getVal, setVal)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 200, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.Text = txt
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 14
    local bCorner = Instance.new("UICorner")
    bCorner.Parent = b
    b.Parent = main
    
    b.MouseButton1Click:Connect(function() 
        local newVal = not getVal()
        setVal(newVal)
        if getVal() then
            b.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        else
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        end
    end)
    return b
end

local loopBtn = createBtn("LOOP ATTACK", 180, function() return isLooping end, function(v) isLooping = v end)
local stackBtn = createBtn("INF STACK", 220, function() return isStackingActive end, function(v) isStackingActive = v end)

local godBtn = Instance.new("TextButton")
godBtn.Size = UDim2.new(0, 200, 0, 35)
godBtn.Position = UDim2.new(0, 10, 0, 260)
godBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
godBtn.Text = "GOD MODE: OFF"
godBtn.TextColor3 = Color3.new(1, 1, 1)
godBtn.Font = Enum.Font.SourceSansBold
godBtn.TextSize = 14
local gCorner = Instance.new("UICorner")
gCorner.Parent = godBtn
godBtn.Parent = main

godBtn.MouseButton1Click:Connect(function()
    isGodMode = not isGodMode
    if isGodMode then
        godBtn.Text = "GOD MODE: ON"
        godBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    else
        godBtn.Text = "GOD MODE: OFF"
        godBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        local char = player.Character
        if char then
            for _, t in pairs(char:GetChildren()) do
                if t.Name == swordName then
                    t.Parent = player.Backpack
                end
            end
        end
    end
end)

-- RESTORED: INSTANT FIX BUTTON (NO DELAY)
local fixBtn = Instance.new("TextButton")
fixBtn.Name = "InstantFix"
fixBtn.Size = UDim2.new(0, 200, 0, 35)
fixBtn.Position = UDim2.new(0, 10, 0, 300)
fixBtn.Text = "INSTANT FIX"
fixBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
fixBtn.TextColor3 = Color3.new(1, 1, 1)
fixBtn.Font = Enum.Font.SourceSansBold
fixBtn.TextSize = 14
local fCorner = Instance.new("UICorner")
fCorner.Parent = fixBtn
fixBtn.Parent = main

fixBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local items = {}
    if char then
        for _, t in pairs(char:GetChildren()) do
            if t.Name == "RocketJumper" then
                table.insert(items, t)
            end
        end
    end
    if player.Backpack then
        for _, t in pairs(player.Backpack:GetChildren()) do
            if t.Name == "RocketJumper" then
                table.insert(items, t)
            end
        end
    end
    for _, t in pairs(items) do
        t.Parent = workspace
    end
    -- Instant return
    for _, t in pairs(items) do
        t.Parent = char
    end
end)

-- 9. TARGET LIST UPDATER
function updateList()
    for _, c in pairs(scroll:GetChildren()) do
        if c:IsA("TextButton") then
            c:Destroy()
        end
    end
    
    local playersList = Players:GetPlayers()
    for i = 1, #playersList do
        local p = playersList[i]
        if p ~= player then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -5, 0, 25)
            b.Text = p.Name
            b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(40, 40, 40)
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.SourceSansBold
            b.TextSize = 12
            local bc = Instance.new("UICorner")
            bc.Parent = b
            b.Parent = scroll
            
            b.MouseButton1Click:Connect(function()
                selectedTargets[p] = not selectedTargets[p]
                b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(40, 40, 40)
            end)
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 30)
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
