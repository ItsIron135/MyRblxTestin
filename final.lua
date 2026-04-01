-- [[ ROCKET ADMIN V65: THE WALKING PHANTOM ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V65"
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
main.BackgroundColor3 = Color3.fromRGB(10, 15, 10)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "PHANTOM WALK V65"
title.TextColor3 = Color3.fromRGB(100, 255, 100)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

local xBtn = Instance.new("TextButton", main)
xBtn.Size = UDim2.new(0, 25, 0, 25)
xBtn.Position = UDim2.new(1, -30, 0, 5)
xBtn.Text = "X"
xBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
xBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", xBtn)
xBtn.MouseButton1Click:Connect(function() sg:Destroy() isLooping = false isStackingActive = false end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0.35, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. VOID PROTECTION
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and root.Position.Y < -20 then
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.CFrame = CFrame.new(root.Position.X, 150, root.Position.Z)
    end
end)

-- 3. THE PHANTOM LOOP (The "Blink" Logic)
task.spawn(function()
    local targetIndex = 1
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local bp = player:FindFirstChild("Backpack")
        
        if isLooping and root and char then
            -- Get active targets
            local targets = {}
            for p, active in pairs(selectedTargets) do
                if active and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(targets, p.Character.HumanoidRootPart)
                end
            end

            if #targets > 0 then
                targetIndex = (targetIndex % #targets) + 1
                local currentT = targets[targetIndex]
                
                -- Save where you are walking
                local originalCF = root.CFrame
                
                -- BLINK: Snap to target, Fire, Snap back
                root.CFrame = currentT.CFrame * CFrame.new(0, 0, 0.5) * CFrame.Angles(math.rad(-90), 0, 0)
                
                -- Fire one rocket from the stack
                local tool = char:FindFirstChild("RocketJumper") or (bp and bp:FindFirstChild("RocketJumper"))
                if tool then
                    tool.Parent = char
                    tool:Activate()
                    task.wait(0.01) -- Minimum time to register fire
                    if not isStackingActive and bp then tool.Parent = bp end
                end
                
                -- Return to your walking position immediately
                root.CFrame = originalCF
            end
        end
        task.wait(0.03) -- 30ms cycle
    end
end)

-- 4. AGGRESSIVE STACKER
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

-- 5. PRECISION CARROT
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

-- 6. BUTTONS & LIST
local function createBtn(txt, y, getVal, setVal)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0, 200, 0, 35)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(30, 35, 30)
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() 
        setVal(not getVal()) 
        b.BackgroundColor3 = getVal() and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(30, 35, 30) 
    end)
end

createBtn("PHANTOM LOOP", 180, function() return isLooping end, function(v) isLooping = v end)
createBtn("INF STACK", 220, function() return isStackingActive end, function(v) isStackingActive = v end)

local fixBtn = Instance.new("TextButton", main)
fixBtn.Size = UDim2.new(0, 200, 0, 35)
fixBtn.Position = UDim2.new(0, 10, 0, 260)
fixBtn.Text = "INSTANT FIX"
fixBtn.BackgroundColor3 = Color3.fromRGB(50, 60, 50)
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
            b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(40, 40, 40)
            b.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                selectedTargets[p] = not selectedTargets[p]
                b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(40, 40, 40)
            end)
        end
    end
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
