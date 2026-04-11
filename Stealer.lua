local P = game:GetService("Players")
local LP = P.LocalPlayer
local RS = game:GetService("RunService")
local RP = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
local PG = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)

if PG:FindFirstChild("StealerUI") then PG.StealerUI:Destroy() end

local SG = Instance.new("ScreenGui", PG)
SG.Name = "StealerUI"
SG.ResetOnSpawn = false

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 180, 0, 400) 
MF.Position = UDim2.new(0.85, 0, 0.5, -200)
MF.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MF.Active = true
MF.Draggable = true

local T = Instance.new("TextLabel", MF)
T.Size = UDim2.new(1, -30, 0, 30)
T.BackgroundTransparency = 1
T.Text = "Clone Spawner +"
T.TextColor3 = Color3.new(1, 1, 1)
T.Font = Enum.Font.Code
T.TextSize = 16

-- DESYNC VARIABLES
local desyncActive = false
local ghostOffset = Vector3.new(0, 0, 0)
local flySpeed = 1.4
local equipLerp = 0
local animSpeed = 18
local desyncLoop = nil

-- NEW: ROCKET VARIABLES
local RocketSpamActive = false
local RocketTargets = {}

--------------------------------
-- CLOSE-QUARTERS DYNAMIC ROCKET LOOP
--------------------------------
task.spawn(function()
    while true do
        if RocketSpamActive then
            local tool = LP.Backpack:FindFirstChild("RocketJumper") or (LP.Character and LP.Character:FindFirstChild("RocketJumper"))
            if tool and tool:FindFirstChild("FireRocket") then
                for targetPlayer, isActive in pairs(RocketTargets) do
                    if isActive and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = targetPlayer.Character.HumanoidRootPart
                        local vel = hrp.Velocity
                        
                        local targetPos = hrp.Position + (vel * 0.05)
                        local spawnPos
                        if vel.Magnitude > 1 then
                            local randomSpread = Vector3.new(math.random(-3, 3), math.random(0, 4), math.random(-3, 3))
                            spawnPos = targetPos + (vel.Unit * 5) + randomSpread
                        else
                            local randomSpread = Vector3.new(math.random(-5, 5), math.random(1, 5), math.random(-5, 5))
                            spawnPos = targetPos + randomSpread
                        end
                        
                        tool.Enabled = true
                        tool.FireRocket:FireServer(targetPos, spawnPos)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

local CB = Instance.new("TextButton", MF)
CB.Size = UDim2.new(0, 30, 0, 30)
CB.Position = UDim2.new(1, -30, 0, 0)
CB.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CB.Text = "X"
CB.TextColor3 = Color3.new(1, 1, 1)
CB.MouseButton1Click:Connect(function() 
    if desyncActive then 
        desyncActive = false
        if desyncLoop then desyncLoop:Disconnect() end
    end
    SG:Destroy() 
end)

local SF = Instance.new("ScrollingFrame", MF)
SF.Size = UDim2.new(1, 0, 1, -310) 
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

local LatestClone = nil
workspace.ChildAdded:Connect(function(child)
    if child.Name == LP.Name .. "'s Clone" then
        LatestClone = child
    end
end)

local Flying = false
local FlySpeed = 100 
local FLB = Instance.new("TextButton", MF)
FLB.Size = UDim2.new(1, 0, 0, 30)
FLB.Position = UDim2.new(0, 0, 1, -250)
FLB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FLB.Text = "Fly: OFF"
FLB.TextColor3 = Color3.new(1, 1, 1)
FLB.Font = Enum.Font.Code
FLB.TextSize = 14

FLB.MouseButton1Click:Connect(function()
    Flying = not Flying
    FLB.Text = Flying and "Fly: ON" or "Fly: OFF"
    FLB.BackgroundColor3 = Flying and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(60, 60, 60)
    
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    if Flying then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlyVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        
        local bg = Instance.new("BodyGyro", root)
        bg.Name = "FlyGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 9e4
        bg.CFrame = root.CFrame
        
        task.spawn(function()
            while Flying and root and root.Parent do
                local dir = hum.MoveDirection 
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
                
                if dir.Magnitude > 0 then
                    bv.Velocity = dir.Unit * FlySpeed
                else
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
                
                bg.CFrame = cam.CFrame
                task.wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
    end
end)

local GiveDroppedGearActive = false
local GDGB = Instance.new("TextButton", MF)
GDGB.Size = UDim2.new(1, 0, 0, 30)
GDGB.Position = UDim2.new(0, 0, 1, -220)
GDGB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GDGB.Text = "Give Dropped Gear: OFF"
GDGB.TextColor3 = Color3.new(1, 1, 1)
GDGB.Font = Enum.Font.Code
GDGB.TextSize = 13

GDGB.MouseButton1Click:Connect(function()
    GiveDroppedGearActive = not GiveDroppedGearActive
    GDGB.Text = GiveDroppedGearActive and "Give Dropped Gear: ON" or "Give Dropped Gear: OFF"
    GDGB.BackgroundColor3 = GiveDroppedGearActive and Color3.fromRGB(150, 100, 50) or Color3.fromRGB(60, 60, 60)
end)

local PDB = Instance.new("TextButton", MF)
PDB.Size = UDim2.new(1, 0, 0, 30)
PDB.Position = UDim2.new(0, 0, 1, -190)
PDB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PDB.Text = "Perm Desync: OFF"
PDB.TextColor3 = Color3.new(1, 1, 1)
PDB.Font = Enum.Font.Code
PDB.TextSize = 14

PDB.MouseButton1Click:Connect(function()
    desyncActive = not desyncActive
    PDB.Text = desyncActive and "Perm Desync: ON" or "Perm Desync: OFF"
    PDB.BackgroundColor3 = desyncActive and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(60, 60, 60)
    
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not char or not hum or not root then return end

    if desyncActive then
        ghostOffset = Vector3.new(0, 0, 0)
        equipLerp = 0
        hum.PlatformStand = true
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "GhostFreeze"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = false end
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then 
                v.Massless = true
                v.CanCollide = false 
            end
        end

        desyncLoop = RS.Heartbeat:Connect(function(dt)
            if not desyncActive then return end
            
            local lookCF = cam.CFrame
            local moveDir = Vector3.new(0, 0, 0)
            local isHoldingTool = char:FindFirstChildOfClass("Tool") ~= nil
            
            local target = isHoldingTool and 1 or 0
            equipLerp = equipLerp + (target - equipLerp) * math.clamp(dt * animSpeed, 0, 1)

            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += lookCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= lookCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= lookCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += lookCF.RightVector end
            
            if moveDir.Magnitude > 0 then
                ghostOffset = ghostOffset + (moveDir.Unit * flySpeed)
            end
            
            local basePos = root.Position + ghostOffset
            local ghostRot = lookCF.Rotation
            
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    local n = part.Name
                    local pOffset = CFrame.new(0, 0, 0)
                    
                    if n:match("Right Arm") or n:match("RightUpperArm") or n:match("RightLowerArm") or n:match("RightHand") then
                        local sidePose = CFrame.new(1.5, 0, 0)
                        local gearPose = CFrame.new(1.5, 0.6, -0.5) * CFrame.Angles(math.rad(90), 0, 0)
                        pOffset = sidePose:Lerp(gearPose, equipLerp)
                    elseif n:match("Left Arm") or n:match("LeftUpperArm") or n:match("LeftLowerArm") or n:match("LeftHand") then
                        pOffset = CFrame.new(-1.5, 0, 0)
                    elseif n:match("Leg") or n:match("Foot") then 
                        pOffset = CFrame.new(n:find("Right") and 0.5 or -0.5, -2, 0)
                    elseif n == "Head" then 
                        pOffset = CFrame.new(0, 1.5, 0) 
                    elseif n:find("Torso") then
                        pOffset = CFrame.new(0, 0, 0)
                    end
                    
                    part.CFrame = CFrame.new(basePos) * ghostRot * pOffset
                    part.AssemblyLinearVelocity = Vector3.new(0,0,0)
                end
            end
            
            local head = char:FindFirstChild("Head")
            if head then
                cam.CameraSubject = head
                hum.CameraOffset = ghostRot:Inverse() * (basePos - root.Position)
            end
        end)
    else
        if desyncLoop then desyncLoop:Disconnect() end
        if root:FindFirstChild("GhostFreeze") then root.GhostFreeze:Destroy() end
        hum.CameraOffset = Vector3.new(0,0,0)
        cam.CameraSubject = hum
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = true end
            if v:IsA("BasePart") then 
                v.Massless = false 
                if v.Name ~= "HumanoidRootPart" then v.CanCollide = true end
                v.Anchored = false 
            end
        end
        if root then root.Anchored = false end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

local GhostTouchActive = false
local GTB = Instance.new("TextButton", MF)
GTB.Size = UDim2.new(1, 0, 0, 30)
GTB.Position = UDim2.new(0, 0, 1, -160)
GTB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GTB.Text = "Ghost Touch: OFF"
GTB.TextColor3 = Color3.new(1, 1, 1)
GTB.Font = Enum.Font.Code
GTB.TextSize = 13

GTB.MouseButton1Click:Connect(function()
    GhostTouchActive = not GhostTouchActive
    GTB.Text = GhostTouchActive and "Ghost Touch: ON" or "Ghost Touch: OFF"
    GTB.BackgroundColor3 = GhostTouchActive and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(60, 60, 60)
end)

local IsStackingActive = false
local STB = Instance.new("TextButton", MF)
STB.Size = UDim2.new(1, 0, 0, 30)
STB.Position = UDim2.new(0, 0, 1, -130)
STB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
STB.Text = "Inf Stack: OFF"
STB.TextColor3 = Color3.new(1, 1, 1)
STB.Font = Enum.Font.Code
STB.TextSize = 13

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

local GiveAllActive = false
local GAB = Instance.new("TextButton", MF)
GAB.Size = UDim2.new(1, 0, 0, 30)
GAB.Position = UDim2.new(0, 0, 1, -100)
GAB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
GAB.Text = "Give All: OFF"
GAB.TextColor3 = Color3.new(1, 1, 1)
GAB.Font = Enum.Font.Code
GAB.TextSize = 13

GAB.MouseButton1Click:Connect(function()
    GiveAllActive = not GiveAllActive
    GAB.Text = GiveAllActive and "Give All: ON" or "Give All: OFF"
    GAB.BackgroundColor3 = GiveAllActive and Color3.fromRGB(50, 100, 150) or Color3.fromRGB(70, 70, 70)
end)

local isGodMode = false
local GDB = Instance.new("TextButton", MF)
GDB.Size = UDim2.new(1, 0, 0, 35)
GDB.Position = UDim2.new(0, 0, 1, -70)
GDB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
GDB.Text = "God Mode: OFF"
GDB.TextColor3 = Color3.new(1, 1, 1)
GDB.Font = Enum.Font.Code
GDB.TextSize = 12

GDB.MouseButton1Click:Connect(function()
    isGodMode = not isGodMode
    GDB.Text = isGodMode and "God Mode: ON" or "God Mode: OFF"
    GDB.BackgroundColor3 = isGodMode and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(70, 70, 70)
end)

local IsAntiLaser = false
local laserNames = {["Rain"] = true, ["Beam"] = true, ["Effect"] = true, ["StarShard"] = true, ["CrimsonPillar"] = true, ["Part"] = true}

local ALB = Instance.new("TextButton", MF)
ALB.Size = UDim2.new(1, 0, 0, 35)
ALB.Position = UDim2.new(0, 0, 1, -35)
ALB.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ALB.Text = "ANTI-LASER: OFF"
ALB.TextColor3 = Color3.new(1, 1, 1)
ALB.Font = Enum.Font.Code
ALB.TextSize = 13

ALB.MouseButton1Click:Connect(function()
    IsAntiLaser = not IsAntiLaser
    ALB.Text = IsAntiLaser and "ANTI-LASER: ON" or "ANTI-LASER: OFF"
    ALB.BackgroundColor3 = IsAntiLaser and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(45, 45, 45)
end)

local RSB = Instance.new("TextButton", MF)
RSB.Size = UDim2.new(1, 0, 0, 30)
RSB.Position = UDim2.new(0, 0, 1, 0)
RSB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RSB.Text = "Rocket Spam: OFF"
RSB.TextColor3 = Color3.new(1, 1, 1)
RSB.Font = Enum.Font.Code
RSB.TextSize = 13

RSB.MouseButton1Click:Connect(function()
    RocketSpamActive = not RocketSpamActive
    RSB.Text = RocketSpamActive and "Rocket Spam: ON" or "Rocket Spam: OFF"
    RSB.BackgroundColor3 = RocketSpamActive and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(60, 60, 60)
    if not RocketSpamActive then 
        RocketTargets = {} 
        for _, btn in pairs(SF:GetChildren()) do
            if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end
        end
    end
end)

workspace.ChildAdded:Connect(function(child)
    if IsAntiLaser then
        RS.Heartbeat:Wait()
        if laserNames[child.Name] or child:IsA("SelectionPartLasso") then
            if child:IsA("BasePart") then
                child.CanTouch = false
                child.CanCollide = false
                child.Transparency = 1
            end
            child:Destroy()
        end
    end
end)

task.spawn(function() 
    local swordName = "OverseerwrathSword"
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
                    task.wait(0.01) 
                    for _, s in pairs(swords) do s.Parent = bp end 
                    task.wait(0.01) 
                end 
            end 
        end 
        task.wait(0.01) 
    end 
end)

RS.Heartbeat:Connect(function()
    local char = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    
    if IsStackingActive and char and bp then
        local heldTool = char:FindFirstChildOfClass("Tool")
        if heldTool then
            for _, item in ipairs(bp:GetChildren()) do
                if item.Name == heldTool.Name then item.Parent = char end
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

--------------------------------
-- NEW: WELD-TO-SELF & TP GIVE LOGIC (FIXED)
--------------------------------
local function consistentWeldTPGive(targetPlayer)
    local char = LP.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    
    local tc = targetPlayer.Character
    local thrp = tc and (tc:FindFirstChild("HumanoidRootPart") or tc:FindFirstChild("Torso"))
    
    if not root or not thrp then return end

    local gears = {}
    local welds = {}
    local originalCFrame = root.CFrame

    for _, item in ipairs(workspace:GetChildren()) do
        if item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.Anchored = false 
                handle.CFrame = root.CFrame
                
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = root
                weld.Part1 = handle
                weld.Parent = root
                
                table.insert(gears, handle)
                table.insert(welds, weld)
            end
        end
    end

    if #gears == 0 then return end

    task.spawn(function()
        local start = tick()
        while tick() - start < 1 do
            if root and thrp and thrp.Parent then
                root.CFrame = thrp.CFrame
                
                for i = #gears, 1, -1 do
                    local h = gears[i]
                    local w = welds[i]
                    local tool = h and h.Parent
                    
                    if tool and tool.Parent ~= workspace then
                        if w then w:Destroy() end 
                        table.remove(gears, i)
                        table.remove(welds, i)
                    elseif h and h.Parent then
                        firetouchinterest(thrp, h, 0)
                        firetouchinterest(thrp, h, 1)
                    end
                end
            end
            RS.Heartbeat:Wait()
        end
        
        for _, w in ipairs(welds) do
            if w then w:Destroy() end
        end
        
        if root then
            root.CFrame = originalCFrame
        end
    end)
end

local UsedSwords = {}

local function E(t, btn)
    if RocketSpamActive then
        if RocketTargets[t] then
            RocketTargets[t] = nil
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        else
            RocketTargets[t] = true
            btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
        return 
    end

    local c = LP.Character
    local h = c and c:FindFirstChild("Humanoid")
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    local tc = t.Character
    local thrp = tc and tc:FindFirstChild("HumanoidRootPart")

    if not c or not h or not hrp or not thrp then return end

    if GiveDroppedGearActive then
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        consistentWeldTPGive(t) 
        task.wait(1.5) 
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        return
    end

    local bp = LP:WaitForChild("Backpack")
    local eS = bp:FindFirstChild("EnergySword") or c:FindFirstChild("EnergySword")
    local sS = nil
    local items = bp:GetChildren()
    for _, v in pairs(c:GetChildren()) do table.insert(items, v) end
    for _, item in pairs(items) do 
        if item.Name == "SpectralSword" and not UsedSwords[item] then 
            sS = item; break 
        end 
    end

    if not eS or not sS then return end
    local kd = sS:FindFirstChild("KeyDown")
    local originalCFrame = hrp.CFrame 

    UsedSwords[sS] = true
    h:UnequipTools()
    task.wait(0.05)
    h:EquipTool(eS)
    task.wait(0.05)
    sS.Parent = c

    local startTime = tick()
    local lastSpam = 0
    local connection
    connection = RS.Heartbeat:Connect(function()
        local now = tick()
        if (now - startTime) < 1 and hrp and thrp and thrp.Parent then
            hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 4) * CFrame.Angles(0, math.pi, 0)
            if now > (startTime + 0.2) and now - lastSpam > 0.1 then
                if kd then kd:FireServer("r") end
                lastSpam = now
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
    for _, p in pairs(P:GetPlayers()) do 
        if p ~= LP then
            local b = Instance.new("TextButton", SF)
            b.Size = UDim2.new(1, 0, 0, 25) 
            b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            b.Text = p.Name
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.Code
            b.TextSize = 14 
            b.MouseButton1Click:Connect(function() E(p, b) end)
        end 
    end 
end

R()
P.PlayerAdded:Connect(R)
P.PlayerRemoving:Connect(R)
