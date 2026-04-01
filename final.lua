-- [[ ROCKET ADMIN V73: SPAWN LOCKDOWN ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V73"
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
title.Text = "SPAWN LOCK V73"
title.TextColor3 = Color3.fromRGB(255, 50, 50) -- Aggressive Red
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

-- EXIT
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
    selectedTargets = {} 
end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0.35, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. INSTANT SPAWN LISTENER (The "Lockdown" Logic)
local function instantFire(targetRoot)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if isLooping and root and targetRoot then
        -- Snap and Fire immediately before loop even hits
        root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 0.5) * CFrame.Angles(math.rad(-90), 0, 0)
        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(character)
        if selectedTargets[p] then
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if hrp then instantFire(hrp) end
        end
    end)
end)

-- 3. AGGRESSIVE STACKER
RunService.RenderStepped:Connect(function()
    if isStackingActive then
        local bp = player:FindFirstChild("Backpack")
        local char = player.Character
        if bp and char then
            for _, item in ipairs(bp:GetChildren()) do
                if item.Name == "RocketJumper" then item.Parent = char end
            end
        end
    end
end)

-- 4. COMBAT LOOP (V63 BASE + HIGH VELOCITY AIM)
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
        root.CFrame = currentT.CFrame * CFrame.new(0, 0, 0.5) * CFrame.Angles(math.rad(-90), 0, 0)
        
        if isLooping then
            for _, r in pairs(workspace:GetChildren()) do
                if r:IsA("BasePart") and (r.Name == "Rocket" or r.Name == "Projectile") then
                    if (r.Position - root.Position).Magnitude < 15 then
                        -- PROJECTILE BUFF: Increased velocity to 600 to beat spawn shields
                        r.CFrame = CFrame.lookAt(r.Position, currentT.Position)
                        r.AssemblyLinearVelocity = (currentT.Position - r.Position).Unit * 600 
                    end
                end
            end
        end
    end
end)

-- 5. TOOL CYCLES
task.spawn(function()
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
                task.wait(0.02)
                for _, s in pairs(swords) do s.Parent = bp end
                task.wait(0.02)
            end
        end
        
        -- Rocket Cycle
        if isLooping then
            local jumpers = {}
            local source = isStackingActive and char or bp
            for _, t in pairs(source:GetChildren()) do if t.Name == "RocketJumper" then table.insert(jumpers, t) end end
            for i = 1, #jumpers do
                if not isLooping then break end
                jumpers[i].Parent = char
                jumpers[i]:Activate()
                task.wait(0.03) 
                if not isStackingActive then jumpers[i].Parent = bp end
            end
        end
        task.wait(0.01)
    end
end)

-- 6. BUTTONS
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
        b.BackgroundColor3 = getVal() and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 30, 35) 
    end)
    return b
end

createBtn("LOCKDOWN LOOP", 180, function() return isLooping end, function(v) isLooping = v end)
createBtn("INF STACK", 220, function() return isStackingActive end, function(v) isStackingActive = v end)
local godBtn = createBtn("GOD MODE: OFF", 260, function() return isGodMode end, function(v) isGodMode = v end)
godBtn.MouseButton1Click:Connect(function() godBtn.Text = isGodMode and "GOD MODE: ON" or "GOD MODE: OFF" end)

function updateList()
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", scroll)
            b.Size = UDim2.new(1, -5, 0, 25)
            b.Text = p.Name
            b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
            b.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                selectedTargets[p] = not selectedTargets[p]
                b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(40, 40, 40)
            end)
        end
    end
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
