-- [[ ROCKET ADMIN V60: PHASE STRIKE ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V60"
local isLooping = false
local isStackingActive = false
local selectedTargets = {} 

-- 1. UI SETUP
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 220, 0, 380)
main.Position = UDim2.new(0.5, -110, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "PHASE STRIKE V60"
title.TextColor3 = Color3.fromRGB(150, 100, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0.35, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. PHASE TELEPORT & SHIELD
local targetIndex = 1
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Shield
    if root.Position.Y < -20 or root.AssemblyLinearVelocity.Magnitude > 950 then
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.CFrame = CFrame.new(root.Position.X, 150, root.Position.Z)
    end

    local targets = {}
    for p, active in pairs(selectedTargets) do
        if active and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, p.Character.HumanoidRootPart)
        end
    end

    if #targets > 0 then
        targetIndex = (targetIndex % #targets) + 1
        local currentT = targets[targetIndex]
        
        -- PHASE POSITIONING:
        -- We TP slightly behind their neck. This often bypasses 
        -- front-facing shield logic and keeps the rockets in their hitbox.
        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
        root.CFrame = currentT.CFrame * CFrame.new(0, 0, 0.5) * CFrame.Angles(math.rad(-90), 0, 0)
        
        -- SILENT AIM
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

-- 3. THE 30MS TACTICAL CYCLE (Always Fire)
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
                
                if not isStackingActive then
                    tool.Parent = bp
                end
            end
        end
        task.wait(0.01)
    end
end)

-- 4. INF STACK / CARROT
task.spawn(function()
    local lastStack = false
    while true do
        if isStackingActive then
            if not lastStack then lastStack = true task.wait(3) end
            local bp = player:FindFirstChild("Backpack")
            local char = player.Character
            if bp and char then
                for _, item in ipairs(bp:GetChildren()) do
                    if item.Name == "RocketJumper" then item.Parent = char end
                end
                local c = bp:FindFirstChild("Carrot") or char:FindFirstChild("Carrot")
                if c then
                    local oldP = c.Parent
                    c.Parent = char
                    task.wait(0.1)
                    c:Activate()
                    task.wait(0.1)
                    c.Parent = oldP
                end
            end
            task.wait(30)
        else
            lastStack = false
            task.wait(0.5)
        end
    end
end)

-- 5. UI CONTROLS
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
        b.BackgroundColor3 = getVal() and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(30, 30, 35) 
    end)
end

createBtn("LOOP ATTACK", 180, function() return isLooping end, function(v) isLooping = v end)
createBtn("INF STACK", 220, function() return isStackingActive end, function(v) isStackingActive = v end)

local clrBtn = Instance.new("TextButton", main)
clrBtn.Size = UDim2.new(0, 200, 0, 35)
clrBtn.Position = UDim2.new(0, 10, 0, 260)
clrBtn.Text = "CLEAR TARGETS"
clrBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
clrBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", clrBtn)
clrBtn.MouseButton1Click:Connect(function() selectedTargets = {} updateList() end)

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
    for _, t in pairs(player.Backpack:GetChildren()) do if t.Name == "RocketJumper" then table.insert(items, t) end end
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
            b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(80, 0, 150) or Color3.fromRGB(40, 40, 40)
            b.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                selectedTargets[p] = not selectedTargets[p]
                b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(80, 0, 150) or Color3.fromRGB(40, 40, 40)
            end)
        end
    end
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
