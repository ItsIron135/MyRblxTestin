-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- [[ GHOST CORE SETUP ]] --
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local fakeRoot = Instance.new("Part")
fakeRoot.Name = "FakeRoot"
fakeRoot.Size = root.Size
fakeRoot.CFrame = root.CFrame
fakeRoot.Transparency = 1
fakeRoot.CanCollide = false
fakeRoot.Parent = character

local bv = Instance.new("BodyVelocity", fakeRoot)
bv.MaxForce = Vector3.new(1e7, 1e7, 1e7)
bv.Velocity = Vector3.new(0, 0, 0)

local bg = Instance.new("BodyGyro", fakeRoot)
bg.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
bg.CFrame = fakeRoot.CFrame

-- [[ FLAGS ]] --
local UI_NAME = "RocketAdmin_GhostFixed"
local isLooping = false
local isStackingActive = false
local isGodMode = false 
local selectedTargets = {} 
local swordName = "OverseerwrathSword"
local FLY_SPEED = 100
local running = true

-- [[ 1. UI SETUP ]] --
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 220, 0, 430)
main.Position = UDim2.new(0.5, -110, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "GHOST ISOLATED STRIKE"
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

xBtn.MouseButton1Click:Connect(function() 
    running = false
    isLooping = false 
    isStackingActive = false 
    isGodMode = false
    fakeRoot:Destroy()
    root.Anchored = false
    humanoid.PlatformStand = false
    sg:Destroy() 
end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0.35, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- [[ 2. UNIVERSAL SHIELD (THREAD 1) ]] --
RunService.Heartbeat:Connect(function()
    if not running then return end
    local char = player.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if rootPart and hum then
        local pos = rootPart.Position
        if pos.Y < -20 or rootPart.AssemblyLinearVelocity.Magnitude > 950 then
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            -- If not attacking, stay at seat/safe height
            if not isLooping then
                rootPart.CFrame = CFrame.new(pos.X, 150, pos.Z)
            end
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- [[ 3. AGGRESSIVE STACKER (THREAD 2) ]] --
RunService.RenderStepped:Connect(function()
    if isStackingActive and running then
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

-- [[ 4. GHOST LOOP ATTACK (THREAD 3 - MODIFIED) ]] --
local targetIndex = 1
RunService.Heartbeat:Connect(function()
    if not running or not isLooping then return end
    local char = player.Character
    local realRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not realRoot then return end

    local targets = {}
    for p, active in pairs(selectedTargets) do
        if active and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, p.Character.HumanoidRootPart)
        end
    end

    if #targets > 0 then
        targetIndex = (targetIndex % #targets) + 1
        local currentT = targets[targetIndex]
        
        -- MODIFICATION: Move the GHOST (fakeRoot) instead of the actual player
        fakeRoot.CFrame = currentT.CFrame * CFrame.new(0, 0, 0.2) * CFrame.Angles(math.rad(-90), 0, 0)
        
        -- Sync the REAL root for rocket spawning/hitbox
        realRoot.Anchored = false
        realRoot.CFrame = fakeRoot.CFrame
        
        for _, r in pairs(workspace:GetChildren()) do
            if r:IsA("BasePart") and (r.Name == "Rocket" or r.Name == "Projectile") then
                if (r.Position - fakeRoot.Position).Magnitude < 15 then
                    r.CFrame = currentT.CFrame * CFrame.new(0, -3, 0) 
                    r.AssemblyLinearVelocity = Vector3.new(0, 100, 0)
                end
            end
        end
        
        task.wait(0.01)
        realRoot.Anchored = true -- Snap back to safety
    end
end)

-- [[ 5. AERO FLIGHT & VISUAL SYNC (THREAD 4) ]] --
RunService.PreRender:Connect(function(dt)
    if not running then return end

    -- Fly movement
    local moveDir = Vector3.new(0,0,0)
    if not isLooping then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0,1,0) end
        bv.Velocity = moveDir * FLY_SPEED
        bg.CFrame = camera.CFrame
    else
        bv.Velocity = Vector3.new(0,0,0)
    end

    -- Visual Character Sync
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part ~= root and part ~= fakeRoot then
            part.CFrame = fakeRoot.CFrame * root.CFrame:ToObjectSpace(part.CFrame)
            part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
    workspace.CurrentCamera.CameraSubject = fakeRoot
end)

-- [[ 6. ZERO-DELAY TRIPWIRE (SPAWN CATCHER) ]] --
workspace.ChildAdded:Connect(function(child)
    if not isLooping or not running then return end
    
    local targetPlayer = Players:GetPlayerFromCharacter(child)
    if targetPlayer and selectedTargets[targetPlayer] then
        local char = player.Character
        local realRoot = char and char:FindFirstChild("HumanoidRootPart")
        local targetRoot = child:WaitForChild("HumanoidRootPart", 2)
        
        if realRoot and targetRoot then
            -- TP GHOST
            fakeRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 0.2) * CFrame.Angles(math.rad(-90), 0, 0)
            
            -- TP REAL ROOT (BLINK)
            realRoot.Anchored = false
            realRoot.CFrame = fakeRoot.CFrame
            
            local tool = char:FindFirstChild("RocketJumper") or player.Backpack:FindFirstChild("RocketJumper")
            if tool then
                tool.Parent = char
                tool:Activate()
            end
            
            task.wait(0.01) 
            realRoot.Anchored = true
        end
    end
end)

-- [[ 7. ROCKET CYCLE (THREAD 5) ]] --
task.spawn(function()
    while running do
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
                task.wait(0.02)
                if not isStackingActive and bp then
                    tool.Parent = bp
                end
            end
        end
        task.wait(0.01)
    end
end)

-- [[ 8. GOD MODE STACKER (THREAD 6) ]] --
task.spawn(function()
    while running do
        if isGodMode then
            local char = player.Character
            local bp = player:FindFirstChild("Backpack")
            if char and bp then
                local swords = {}
                for _, t in pairs(char:GetChildren()) do if t.Name == swordName then table.insert(swords, t) end end
                for _, t in pairs(bp:GetChildren()) do if t.Name == swordName and #swords < 10 then table.insert(swords, t) end end

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

-- [[ 9. PRECISION CARROT (THREAD 7) ]] --
task.spawn(function()
    local lastStack = false
    while running do
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

-- [[ 10. TARGET HUD ESP (THREAD 8) ]] --
RunService.RenderStepped:Connect(function()
    if not running then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local highlight = p.Character:FindFirstChild("AdminTargetHUD")
            if selectedTargets[p] then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "AdminTargetHUD"
                    highlight.FillColor = Color3.fromRGB(255, 0, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = p.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

-- [[ 11. BUTTONS & TARGET LIST ]] --
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
createBtn("GOD MODE: OFF", 260, function() return isGodMode end, function(v) isGodMode = v end).MouseButton1Click:Connect(function() 
    local btn = main:GetChildren()[#main:GetChildren()-1]
    if btn:IsA("TextButton") then btn.Text = isGodMode and "GOD MODE: ON" or "GOD MODE: OFF" end
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

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- INITIAL STATE --
root.Anchored = true
humanoid.PlatformStand = true
