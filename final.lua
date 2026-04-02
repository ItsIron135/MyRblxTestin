-- [[ ROCKET ADMIN V80: OPTIMIZED PHANTOM ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V80"
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
main.Size = UDim2.new(0, 220, 0, 440)
main.Position = UDim2.new(0.5, -110, 0.5, -220)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "PHASE STRIKE V80"
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
xBtn.MouseButton1Click:Connect(function() isLooping = false isStackingActive = false isGodMode = false sg:Destroy() end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0.3, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. CORE SHIELDS (VOID / FLING / CAMERA)
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if root and hum then
        if root.Position.Y < -20 or root.AssemblyLinearVelocity.Magnitude > 950 then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(root.Position.X, 150, root.Position.Z)
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if isLooping then camera.CameraSubject = nil else
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then camera.CameraSubject = char.Humanoid end
    end
end)

-- 3. COMBAT ENGINE (PHANTOM BLINK + SILENT AIM)
local targetIndex = 1
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not isLooping then return end

    local targets = {}
    for p, active in pairs(selectedTargets) do
        if active and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, p.Character.HumanoidRootPart)
        end
    end

    if #targets > 0 then
        targetIndex = (targetIndex % #targets) + 1
        local currentT = targets[targetIndex]
        local oldCF = root.CFrame
        
        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
        root.CFrame = currentT.CFrame * CFrame.new(0, 0, 0.2) * CFrame.Angles(math.rad(-90), 0, 0)
        
        for _, r in pairs(workspace:GetChildren()) do
            if r:IsA("BasePart") and (r.Name == "Rocket" or r.Name == "Projectile") then
                if (r.Position - root.Position).Magnitude < 15 then
                    r.CFrame = CFrame.lookAt(r.Position, currentT.Position)
                    r.AssemblyLinearVelocity = (currentT.Position - r.Position).Unit * 600
                end
            end
        end
        task.wait(0.01)
        root.CFrame = oldCF
    end
end)

-- 4. POWER CYCLES (20ms ATTACK + SWORD GOD MODE + CARROT)
task.spawn(function()
    local lastCarrot = tick()
    while true do
        local char = player.Character
        local bp = player:FindFirstChild("Backpack")
        if not char or not bp then task.wait(0.1) continue end

        -- God Mode
        if isGodMode then
            local swords = {}
            for _, t in pairs(char:GetChildren()) do if t.Name == swordName then table.insert(swords, t) end end
            for _, t in pairs(bp:GetChildren()) do if t.Name == swordName and #swords < 10 then table.insert(swords, t) end end
            if #swords > 0 then
                for _, s in pairs(swords) do s.Parent = char end
                task.wait(0.01)
                for _, s in pairs(swords) do s.Parent = bp end
                task.wait(0.01)
            end
        end

        -- Carrot Timer
        if isStackingActive and (tick() - lastCarrot) > 30 then
            local c = bp:FindFirstChild("Carrot") or char:FindFirstChild("Carrot")
            if c then
                local oldP = c.Parent
                c.Parent = char; c:Activate(); task.wait(0.1); c.Parent = oldP
                lastCarrot = tick()
            end
        end
        
        -- Attack Cycle
        if isLooping then
            local source = isStackingActive and char or bp
            local jumpers = {}
            for _, t in pairs(source:GetChildren()) do if t.Name == "RocketJumper" then table.insert(jumpers, t) end end
            for i = 1, #jumpers do
                if not isLooping then break end
                jumpers[i].Parent = char; jumpers[i]:Activate(); task.wait(0.02)
                if not isStackingActive then jumpers[i].Parent = bp end
            end
        end
        task.wait(0.01)
    end
end)

-- 5. UI BUTTONS
local function createBtn(txt, y, getVal, setVal)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0, 200, 0, 35); b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35); b.TextColor3 = Color3.new(1,1,1)
    b.Text = txt; b.Font = Enum.Font.SourceSansBold; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() 
        setVal(not getVal())
        b.BackgroundColor3 = getVal() and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(30, 30, 35)
        if txt:find("GOD") then b.Text = getVal() and "GOD MODE: ON" or "GOD MODE: OFF" end
    end)
    return b
end

createBtn("PHANTOM ATTACK", 180, function() return isLooping end, function(v) isLooping = v end)
createBtn("INF STACK", 220, function() return isStackingActive end, function(v) isStackingActive = v end)
createBtn("GOD MODE: OFF", 260, function() return isGodMode end, function(v) isGodMode = v end)

local fixBtn = Instance.new("TextButton", main)
fixBtn.Size = UDim2.new(0, 200, 0, 35); fixBtn.Position = UDim2.new(0, 10, 0, 300)
fixBtn.Text = "INSTANT FIX"; fixBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60); fixBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", fixBtn); fixBtn.MouseButton1Click:Connect(function()
    local items = {}
    for _, t in pairs(player.Character:GetChildren()) do if t.Name == "RocketJumper" then table.insert(items, t) end end
    for _, t in pairs(player.Backpack:GetChildren()) do if t.Name == "RocketJumper" then table.insert(items, t) end end
    for _, t in pairs(items) do t.Parent = workspace end; task.wait(0.1)
    for _, t in pairs(items) do t.Parent = player.Character end
end)

function updateList()
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", scroll); b.Size = UDim2.new(1, -5, 0, 25)
            b.Text = p.Name; b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(40, 40, 40)
            b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                selectedTargets[p] = not selectedTargets[p]
                b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(0, 80, 150) or Color3.fromRGB(40, 40, 40)
            end)
        end
    end
end
updateList(); Players.PlayerAdded:Connect(updateList); Players.PlayerRemoving:Connect(updateList)
