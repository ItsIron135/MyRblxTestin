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
MF.Size = UDim2.new(0, 200, 0, 500) -- Increased height for the new toggle
MF.Position = UDim2.new(0.8, 0, 0.5, -250)
MF.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MF.Active = true
MF.Draggable = true

local T = Instance.new("TextLabel", MF)
T.Size = UDim2.new(1, -30, 0, 30)
T.BackgroundTransparency = 1
T.Text = "Give Clone"
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

-- SPAWN LOCATION SYSTEM
local UseSavedPos = false
local SavedSpawnCFrame = nil

local DB = Instance.new("TextButton", MF)
DB.Size = UDim2.new(1, 0, 0, 40)
DB.Position = UDim2.new(0, 0, 1, -200)
DB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
DB.Text = "Custom Spawn: OFF"
DB.TextColor3 = Color3.new(1, 1, 1)

DB.MouseButton1Click:Connect(function()
    if not SavedSpawnCFrame then 
        DB.Text = "SET A POSITION FIRST!" 
        task.wait(1) 
    end
    UseSavedPos = not UseSavedPos
    DB.Text = UseSavedPos and "Custom Spawn: ON" or "Custom Spawn: OFF"
    DB.BackgroundColor3 = UseSavedPos and Color3.fromRGB(50, 120, 50) or Color3.fromRGB(70, 70, 70)
end)

local SOB = Instance.new("TextButton", MF)
SOB.Size = UDim2.new(1, 0, 0, 40)
SOB.Position = UDim2.new(0, 0, 1, -160)
SOB.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
SOB.Text = "Capture Current Spot"
SOB.TextColor3 = Color3.new(1, 1, 1)

SOB.MouseButton1Click:Connect(function()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        SavedSpawnCFrame = hrp.CFrame
        SOB.Text = "SPOT CAPTURED!"
        task.wait(1)
        SOB.Text = "Capture Current Spot"
    end
end)

-- INF STACK SYSTEM
local IsStackingActive = false
local STB = Instance.new("TextButton", MF)
STB.Size = UDim2.new(1, 0, 0, 40)
STB.Position = UDim2.new(0, 0, 1, -120)
STB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
STB.Text = "Inf Stack: OFF"
STB.TextColor3 = Color3.new(1, 1, 1)

STB.MouseButton1Click:Connect(function()
    IsStackingActive = not IsStackingActive
    STB.Text = IsStackingActive and "Inf Stack: ON" or "Inf Stack: OFF"
    STB.BackgroundColor3 = IsStackingActive and Color3.fromRGB(120, 50, 120) or Color3.fromRGB(70, 70, 70)
end)

-- GIVE ALL BLOCKS SYSTEM (PHOTO LOGIC)
local GiveAllActive = false
local GAB = Instance.new("TextButton", MF)
GAB.Size = UDim2.new(1, 0, 0, 40)
GAB.Position = UDim2.new(0, 0, 1, -80)
GAB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
GAB.Text = "Give All: OFF"
GAB.TextColor3 = Color3.new(1, 1, 1)

GAB.MouseButton1Click:Connect(function()
    GiveAllActive = not GiveAllActive
    GAB.Text = GiveAllActive and "Give All: ON" or "Give All: OFF"
    GAB.BackgroundColor3 = GiveAllActive and Color3.fromRGB(50, 100, 150) or Color3.fromRGB(70, 70, 70)
end)

-- GLOBAL HEARTBEAT FOR STACKER AND BLOCK SPAM
RS.Heartbeat:Connect(function()
    -- Stacker
    if IsStackingActive then
        local bp = LP:FindFirstChild("Backpack")
        local char = LP.Character
        if bp and char then
            for _, item in ipairs(bp:GetChildren()) do
                if item.Name == "SpectralSword" then item.Parent = char end
            end
        end
    end
    
    -- Give All (Photo Logic)
    if GiveAllActive then
        local BLOCKSPAM = 1 -- You can change this number to spam harder
        for i = 1, BLOCKSPAM do
            RP.SpawnRainbowBlock:FireServer()
            RP.SpawnDiamondBlock:FireServer()
            RP.SpawnSuperBlock:FireServer()
            RP.SpawnLuckyBlock:FireServer()
            RP.SpawnGalaxyBlock:FireServer()
        end
    end
end)

-- DROP ALL SYSTEM
local DRB = Instance.new("TextButton", MF)
DRB.Size = UDim2.new(1, 0, 0, 40)
DRB.Position = UDim2.new(0, 0, 1, -40)
DRB.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
DRB.Text = "Drop All Spectrals"
DRB.TextColor3 = Color3.new(1, 1, 1)

DRB.MouseButton1Click:Connect(function()
    local char = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item.Name == "SpectralSword" or item.Name == "UsedSpectralSword" then item.Parent = workspace end
        end
    end
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item.Name == "SpectralSword" or item.Name == "UsedSpectralSword" then item.Parent = workspace end
        end
    end
    DRB.Text = "DROPPED!"
    task.wait(1)
    DRB.Text = "Drop All Spectrals"
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

    h:UnequipTools()
    task.wait(0.05)
    h:EquipTool(eS)
    task.wait(0.05)
    sS.Parent = c

    local startTime = tick()
    local endTime = startTime + 1
    local lastSpam = 0
    local originalCFrame = hrp.CFrame 

    local connection
    connection = RS.Heartbeat:Connect(function()
        local now = tick()
        if now < endTime and hrp and thrp and thrp.Parent then
            
            local tpSpeed = 0.1 -- CHANGE TP SPEED HERE
            
            if UseSavedPos and SavedSpawnCFrame then
                if (now - startTime) < tpSpeed then
                    hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 4) * CFrame.Angles(0, math.pi, 0)
                else
                    hrp.CFrame = SavedSpawnCFrame
                end
            else
                hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 4) * CFrame.Angles(0, math.pi, 0)
            end
            
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
            b.MouseButton1Click:Connect(function() E(p) end)
            y = y + 30
        end 
    end 
    SF.CanvasSize = UDim2.new(0, 0, 0, y)
end

R()
P.PlayerAdded:Connect(R)
P.PlayerRemoving:Connect(R)
