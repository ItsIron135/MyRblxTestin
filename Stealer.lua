local P = game:GetService("Players")
local LP = P.LocalPlayer
local RS = game:GetService("RunService")
local RP = game:GetService("ReplicatedStorage")
local PG = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)

if PG:FindFirstChild("StealerUI") then PG.StealerUI:Destroy() end

local SG = Instance.new("ScreenGui", PG)
SG.Name = "StealerUI"
SG.ResetOnSpawn = false

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 200, 0, 540)
MF.Position = UDim2.new(0.8, 0, 0.5, -270)
MF.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MF.Active = true
MF.Draggable = true

local T = Instance.new("TextLabel", MF)
T.Size = UDim2.new(1, -30, 0, 30)
T.BackgroundTransparency = 1
T.Text = "Spawn Clone"
T.TextColor3 = Color3.new(1, 1, 1)
T.Font = Enum.Font.Code
T.TextSize = 18

local CB = Instance.new("TextButton", MF)
CB.Size = UDim2.new(0, 30, 0, 30)
CB.Position = UDim2.new(1, -30, 0, 0)
CB.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CB.Text = "X"
CB.TextColor3 = Color3.new(1, 1, 1)
CB.MouseButton1Click:Connect(function() SG:Destroy() end)

local SF = Instance.new("ScrollingFrame", MF)
SF.Size = UDim2.new(1, 0, 1, -270)
SF.Position = UDim2.new(0, 0, 0, 30)
SF.BackgroundTransparency = 1
SF.CanvasSize = UDim2.new(0, 0, 0, 0)
SF.ScrollBarThickness = 0 
SF.ScrollingEnabled = true
SF.Active = true

local UIList = Instance.new("UIListLayout", SF)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SF.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
end)

-- TRACKING THE LATEST CLONE
local LatestClone = nil
workspace.ChildAdded:Connect(function(child)
    if child.Name == LP.Name .. "'s Clone" then
        LatestClone = child
    end
end)

-- SPAM SPAWN TOGGLE
local SpamSpawnActive = false
local SSB = Instance.new("TextButton", MF)
SSB.Size = UDim2.new(1, 0, 0, 40)
SSB.Position = UDim2.new(0, 0, 1, -240)
SSB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SSB.Text = "Spam TP: OFF"
SSB.TextColor3 = Color3.new(1, 1, 1)
SSB.Font = Enum.Font.Code
SSB.TextSize = 16

SSB.MouseButton1Click:Connect(function()
    SpamSpawnActive = not SpamSpawnActive
    SSB.Text = SpamSpawnActive and "Spam TP: ON" or "Spam TP: OFF"
    SSB.BackgroundColor3 = SpamSpawnActive and Color3.fromRGB(50, 50, 150) or Color3.fromRGB(60, 60, 60)
end)

-- CLIENT KILL BUTTON
local CKB = Instance.new("TextButton", MF)
CKB.Size = UDim2.new(1, 0, 0, 40)
CKB.Position = UDim2.new(0, 0, 1, -200)
CKB.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
CKB.Text = "Client Kill Clone"
CKB.TextColor3 = Color3.new(1, 1, 1)
CKB.Font = Enum.Font.Code
CKB.TextSize = 16

CKB.MouseButton1Click:Connect(function()
    local target = LatestClone or workspace:FindFirstChild(LP.Name .. "'s Clone")
    local char = LP.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    
    if target then
        local cloneTorso = target:FindFirstChild("Torso") or target:FindFirstChild("HumanoidRootPart")
        
        if cloneTorso and root then
            cloneTorso.CFrame = root.CFrame * CFrame.new(0, 0, 7) * CFrame.Angles(0, math.rad(180), 0)
            task.wait(0.1)
        end

        target:BreakJoints()
        local h = target:FindFirstChildOfClass("Humanoid")
        if h then h.Health = 0 end
        
        CKB.Text = "KILLED"
        task.wait(1)
        CKB.Text = "Client Kill Clone"
    end
end)

-- GHOST TOUCH SYSTEM
local GhostTouchActive = false
local GTB = Instance.new("TextButton", MF)
GTB.Size = UDim2.new(1, 0, 0, 40)
GTB.Position = UDim2.new(0, 0, 1, -160)
GTB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GTB.Text = "Ghost Touch: OFF"
GTB.TextColor3 = Color3.new(1, 1, 1)
GTB.Font = Enum.Font.Code
GTB.TextSize = 16

GTB.MouseButton1Click:Connect(function()
    GhostTouchActive = not GhostTouchActive
    GTB.Text = GhostTouchActive and "Ghost Touch: ON" or "Ghost Touch: OFF"
    GTB.BackgroundColor3 = GhostTouchActive and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(60, 60, 60)
end)

-- INF STACK SYSTEM
local IsStackingActive = false
local STB = Instance.new("TextButton", MF)
STB.Size = UDim2.new(1, 0, 0, 40)
STB.Position = UDim2.new(0, 0, 1, -120)
STB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
STB.Text = "Inf Stack: OFF"
STB.TextColor3 = Color3.new(1, 1, 1)
STB.Font = Enum.Font.Code
STB.TextSize = 16

STB.MouseButton1Click:Connect(function()
    IsStackingActive = not IsStackingActive
    STB.Text = IsStackingActive and "Inf Stack: ON" or "Inf Stack: OFF"
    STB.BackgroundColor3 = IsStackingActive and Color3.fromRGB(120, 50, 120) or Color3.fromRGB(70, 70, 70)
    
    -- CARROT LOGIC ADDED BACK
    if IsStackingActive then
        local bp = LP:FindFirstChild("Backpack")
        local char = LP.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local carrot = (bp and bp:FindFirstChild("Carrot")) or (char and char:FindFirstChild("Carrot"))
        
        if carrot and hum then
            hum:EquipTool(carrot)
            task.wait(0.1)
            carrot:Activate()
            task.wait(0.1)
            hum:UnequipTools()
        end
    end
end)

-- GIVE ALL BLOCKS SYSTEM
local GiveAllActive = false
local GAB = Instance.new("TextButton", MF)
GAB.Size = UDim2.new(1, 0, 0, 40)
GAB.Position = UDim2.new(0, 0, 1, -80)
GAB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
GAB.Text = "Give All: OFF"
GAB.TextColor3 = Color3.new(1, 1, 1)
GAB.Font = Enum.Font.Code
GAB.TextSize = 16

GAB.MouseButton1Click:Connect(function()
    GiveAllActive = not GiveAllActive
    GAB.Text = GiveAllActive and "Give All: ON" or "Give All: OFF"
    GAB.BackgroundColor3 = GiveAllActive and Color3.fromRGB(50, 100, 150) or Color3.fromRGB(70, 70, 70)
end)

-- GOD MODE TOGGLE
local isGodMode = false
local GDB = Instance.new("TextButton", MF)
GDB.Size = UDim2.new(1, 0, 0, 40)
GDB.Position = UDim2.new(0, 0, 1, -40)
GDB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
GDB.Text = "God Mode: OFF"
GDB.TextColor3 = Color3.new(1, 1, 1)
GDB.Font = Enum.Font.Code
GDB.TextSize = 16

GDB.MouseButton1Click:Connect(function()
    isGodMode = not isGodMode
    GDB.Text = isGodMode and "God Mode: ON" or "God Mode: OFF"
    GDB.BackgroundColor3 = isGodMode and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(70, 70, 70)
end)

-- GOD MODE LOGIC (OverseerwrathSword)
task.spawn(function() 
    local swordName = "OverseerwrathSword"
    local player = LP
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
                    if t.Name == swordName and #swords < 10 then table.insert(swords, t) end 
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

-- GLOBAL HEARTBEAT (MULTI-HOLD INF STACK)
RS.Heartbeat:Connect(function()
    local char = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    
    if IsStackingActive and char and bp then
        local heldTool = char:FindFirstChildOfClass("Tool")
        if heldTool then
            for _, item in ipairs(bp:GetChildren()) do
                if item.Name == heldTool.Name then 
                    item.Parent = char 
                end
            end
        end
    end
    
    if GiveAllActive then
        local events = {"SpawnRainbowBlock", "SpawnDiamondBlock", "SpawnSuperBlock", "SpawnLuckyBlock", "SpawnGalaxyBlock"}
        for _, name in ipairs(events) do
            local event = RP:FindFirstChild(name)
            if event then event:FireServer() end
        end
    end
    
    if GhostTouchActive then
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
        local target = LatestClone or workspace:FindFirstChild(LP.Name .. "'s Clone")
        
        if target and root then
            for _, item in ipairs(target:GetDescendants()) do
                if (item.Name == "Handle" or item:IsA("TouchInterest")) then
                    local p = item:IsA("TouchInterest") and item.Parent or item
                    if p:IsA("BasePart") then
                        local old = p.CFrame
                        p.CFrame = root.CFrame
                        firetouchinterest(root, p, 0)
                        firetouchinterest(root, p, 1)
                        p.CFrame = old
                    end
                end
            end
        end
    end
end)

local UsedSwords = {}
local CurrentTarget = nil
local SpamConnection = nil

-- CLONE SPAWNING / TP LOGIC
local function E(t, btn)
    local c = LP.Character
    local h = c and c:FindFirstChild("Humanoid")
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local tc = t.Character
    local thrp = tc and tc:FindFirstChild("HumanoidRootPart")

    if not c or not h or not hrp or not thrp then return end

    if CurrentTarget == t then
        CurrentTarget = nil
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        if SpamConnection then SpamConnection:Disconnect() SpamConnection = nil end
        return
    end

    if SpamConnection then SpamConnection:Disconnect() SpamConnection = nil end

    local bp = LP:WaitForChild("Backpack")
    local eS = bp:FindFirstChild("EnergySword") or c:FindFirstChild("EnergySword")
    local sS = nil
    
    local items = bp:GetChildren()
    for _, v in pairs(c:GetChildren()) do table.insert(items, v) end
    for _, item in pairs(items) do 
        if item.Name == "SpectralSword" and not UsedSwords[item] then 
            sS = item 
            break 
        end 
    end

    if not eS or not sS then return end
    local kd = sS:FindFirstChild("KeyDown")
    local originalCFrame = hrp.CFrame 

    if SpamSpawnActive then
        CurrentTarget = t
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        SpamConnection = RS.Heartbeat:Connect(function()
            if CurrentTarget == t and thrp and thrp.Parent and hrp then
                hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 4) * CFrame.Angles(0, math.pi, 0)
                if kd then kd:FireServer("r") end
            else
                if SpamConnection then SpamConnection:Disconnect() SpamConnection = nil end
                hrp.CFrame = originalCFrame
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
        end)
    else
        UsedSwords[sS] = true
        h:UnequipTools()
        task.wait(0.05)
        h:EquipTool(eS)
        task.wait(0.05)
        sS.Parent = c

        local startTime = tick()
        local endTime = startTime + 1
        local lastSpam = 0

        local connection
        connection = RS.Heartbeat:Connect(function()
            local now = tick()
            if now < endTime and hrp and thrp and thrp.Parent then
                hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 4) * CFrame.Angles(0, math.pi, 0)
                
                if now > (startTime + 0.2) then
                    if now - lastSpam > 0.1 then
                        if kd then kd:FireServer("r") end
                        lastSpam = now
                    end
                end
            else
                connection:Disconnect()
                if sS then sS.Name = "UsedSpectralSword" end
                hrp.CFrame = originalCFrame
            end
        end)
    end
end

local function R()
    for _, item in pairs(SF:GetChildren()) do if item:IsA("TextButton") then item:Destroy() end end
    local y = 0
    for _, p in pairs(P:GetPlayers()) do 
        if p ~= LP then
            local b = Instance.new("TextButton", SF)
            b.Size = UDim2.new(1, 0, 0, 30) 
            b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            b.Text = p.Name
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.Code
            b.TextSize = 16 
            b.MouseButton1Click:Connect(function() E(p, b) end)
        end 
    end 
end

R()
P.PlayerAdded:Connect(R)
P.PlayerRemoving:Connect(R)
