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
MF.Size = UDim2.new(0, 200, 0, 500)
MF.Position = UDim2.new(0.8, 0, 0.5, -250)
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
SF.Size = UDim2.new(1, 0, 1, -230)
SF.Position = UDim2.new(0, 0, 0, 30)
SF.BackgroundTransparency = 1
Instance.new("UIListLayout", SF)

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
    local clone = workspace:FindFirstChild(LP.Name .. "'s Clone")
    if clone then
        clone:BreakJoints()
        local h = clone:FindFirstChildOfClass("Humanoid")
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
GTB.Position = UDim2.new(0, 0, 1, -160) -- Realigned to fix gap
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

-- GOD MODE LOGIC (OVERSEER SWORD)
task.spawn(function()
    local swordName = "OverseerSword"
    while true do
        if isGodMode then
            local char = LP.Character
            local bp = LP:FindFirstChild("Backpack")
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

-- GLOBAL HEARTBEAT
RS.Heartbeat:Connect(function()
    if IsStackingActive then
        local bp = LP:FindFirstChild("Backpack")
        local char = LP.Character
        if bp and char then
            for _, item in ipairs(bp:GetChildren()) do
                if item.Name == "SpectralSword" then item.Parent = char end
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
        local char = LP.Character
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
        local clone = workspace:FindFirstChild(LP.Name .. "'s Clone")
        if clone and root then
            for _, item in ipairs(clone:GetDescendants()) do
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

local function E(t)
    local c = LP.Character
    local h = c and c:FindFirstChild("Humanoid")
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local tc = t.Character
    local thrp = tc and tc:FindFirstChild("HumanoidRootPart")

    if not c or not h or not hrp or not thrp then return end

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
    UsedSwords[sS] = true

    local originalCFrame = hrp.CFrame 

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
            b.MouseButton1Click:Connect(function() E(p) end)
            y = y + 30
        end 
    end 
    SF.CanvasSize = UDim2.new(0, 0, 0, y)
end

R()
P.PlayerAdded:Connect(R)
P.PlayerRemoving:Connect(R)
