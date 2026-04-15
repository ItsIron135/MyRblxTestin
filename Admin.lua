--[[ ADMIN PANEL - ORGANIZED, OPTIMIZED, & FULL SIZED ]]--

---------------------------------------------------------
-- SERVICES & INITIAL VARIABLES
---------------------------------------------------------
local P = game:GetService("Players")
local LP = P.LocalPlayer
local RS = game:GetService("RunService")
local RP = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
local PG = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)

if PG:FindFirstChild("StealerUI") then PG.StealerUI:Destroy() end

---------------------------------------------------------
-- STATE VARIABLES
---------------------------------------------------------
local desyncActive = false
local ghostOffset = Vector3.new(0, 0, 0)
local flySpeed = 2
local desyncLoop = nil

local RocketSpamActive = false
local RocketTargets = {}

local NoclipActive = false

local AutoChudActive = false
local AutoChudTargets = {}
local isShootingFood = false

local InfSupernovaActive = false
local AntiPickupActive = false
local disabledParts = {}

local StealArmActive = false
local StealArmTargets = {}

local Flying = false
local FlySpeed = 100 

local GiveDroppedGearActive = false
local GhostTouchActive = false
local IsStackingActive = false
local GiveAllActive = false
local isGodMode = false
local isFireAura = false
local IsAntiLaser = false
local AntiVoidActive = false
local isAntiStealing = false

local UsedSwords = {}
local LatestClone = nil
local laserNames = {["Rain"] = true, ["Beam"] = true, ["Effect"] = true, ["StarShard"] = true, ["CrimsonPillar"] = true, ["Part"] = true}

-- =====================================
-- HOME TP SETUP LOGIC
-- =====================================
local homeCFrame = nil
task.spawn(function()
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not root then return end
    
    local closestDist = math.huge
    local closestSpawn = nil
    
    for i = 1, 8 do
        local spawnFolder = workspace:FindFirstChild("Spawn" .. i)
        local spawnLoc = spawnFolder and spawnFolder:FindFirstChild("SpawnLocation")
        
        if spawnLoc and spawnLoc:IsA("BasePart") then
            local dist = (spawnLoc.Position - root.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestSpawn = spawnLoc
            end
        end
    end
    
    if closestSpawn then
        -- Set home right above the spawn block
        homeCFrame = closestSpawn.CFrame + Vector3.new(0, 4, 0)
    end
end)

---------------------------------------------------------
-- CORE UI CREATION (KEPT ORIGINAL FORMAT)
---------------------------------------------------------
local SG = Instance.new("ScreenGui", PG)
SG.Name = "StealerUI"
SG.ResetOnSpawn = false

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 240, 0, 520) 
MF.Position = UDim2.new(0.85, -120, 0.5, -200)
MF.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MF.Active = true
MF.Draggable = true

local T = Instance.new("TextLabel", MF)
T.Size = UDim2.new(1, -30, 0, 30)
T.BackgroundTransparency = 1
T.Text = "Admin Panel"
T.TextColor3 = Color3.new(1, 1, 1)
T.Font = Enum.Font.Code
T.TextSize = 14

local CB = Instance.new("TextButton", MF)
CB.Size = UDim2.new(0, 30, 0, 30)
CB.Position = UDim2.new(1, -30, 0, 0)
CB.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CB.Text = "X"
CB.TextColor3 = Color3.new(1, 1, 1)

local SF = Instance.new("ScrollingFrame", MF)
SF.Size = UDim2.new(1, 0, 1, -300) 
SF.Position = UDim2.new(0, 0, 0, 30)
SF.BackgroundTransparency = 1
SF.CanvasSize = UDim2.new(0, 0, 0, 0)
SF.ScrollBarThickness = 6 
SF.ScrollingEnabled = true
SF.Active = true

local UIList = Instance.new("UIListLayout", SF)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SF.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
end)

---------------------------------------------------------
-- UTILITY FUNCTIONS
---------------------------------------------------------
local function restoreTools()
    for _, part in ipairs(disabledParts) do
        if part and part.Parent then part.CanTouch = true end
    end
    disabledParts = {}
end

local function consistentWeldTPGive(targetPlayer)
    local char = LP.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    local tc = targetPlayer.Character
    local thrp = tc and (tc:FindFirstChild("HumanoidRootPart") or tc:FindFirstChild("Torso"))
    if not root or not thrp then return end

    local gears, welds = {}, {}
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
        for _, w in ipairs(welds) do if w then w:Destroy() end end
        if root then root.CFrame = originalCFrame end
    end)
end

---------------------------------------------------------
-- UI BUTTONS & TRIGGERED LOOP LOGIC
---------------------------------------------------------

CB.MouseButton1Click:Connect(function() 
    if desyncActive then 
        desyncActive = false
        if desyncLoop then desyncLoop:Disconnect() end
    end
    AntiPickupActive = false
    isGodMode = false
    isFireAura = false
    restoreTools()
    SG:Destroy() 
end)

-- =====================================
-- TOP BUTTONS (NOW SPLIT)
-- =====================================
local TVB = Instance.new("TextButton", MF)
TVB.Size = UDim2.new(0.5, 0, 0, 30)
TVB.Position = UDim2.new(0, 0, 1, -300)
TVB.BackgroundColor3 = Color3.fromRGB(80, 40, 80) -- Purple hue for void
TVB.Text = "TP To Void"
TVB.TextColor3 = Color3.new(1, 1, 1)
TVB.Font = Enum.Font.Code
TVB.TextSize = 12

TVB.MouseButton1Click:Connect(function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(-1063.3, -491.6, 368.2)
    end
end)

local THB = Instance.new("TextButton", MF)
THB.Size = UDim2.new(0.5, 0, 0, 30)
THB.Position = UDim2.new(0.5, 0, 1, -300)
THB.BackgroundColor3 = Color3.fromRGB(40, 80, 40) -- Dark Green for Home
THB.Text = "TP Home"
THB.TextColor3 = Color3.new(1, 1, 1)
THB.Font = Enum.Font.Code
THB.TextSize = 12

THB.MouseButton1Click:Connect(function()
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        if homeCFrame then
            root.CFrame = homeCFrame
        else
            local oldText = THB.Text
            THB.Text = "NO HOME!"
            THB.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            task.delay(1, function()
                if THB and THB.Parent then
                    THB.Text = oldText
                    THB.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
                end
            end)
        end
    end
end)

-- =====================================
-- COLUMN 1 BUTTONS
-- =====================================
local FLB = Instance.new("TextButton", MF)
FLB.Size = UDim2.new(0.5, 0, 0, 30)
FLB.Position = UDim2.new(0, 0, 1, -270)
FLB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FLB.Text = "Fly: OFF"
FLB.TextColor3 = Color3.new(1, 1, 1)
FLB.Font = Enum.Font.Code
FLB.TextSize = 11

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
                
                if dir.Magnitude > 0 then bv.Velocity = dir.Unit * FlySpeed else bv.Velocity = Vector3.new(0, 0, 0) end
                bg.CFrame = cam.CFrame
                task.wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
    end
end)

local GDGB = Instance.new("TextButton", MF)
GDGB.Size = UDim2.new(0.5, 0, 0, 30)
GDGB.Position = UDim2.new(0, 0, 1, -240)
GDGB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GDGB.Text = "Give Gear: OFF"
GDGB.TextColor3 = Color3.new(1, 1, 1)
GDGB.Font = Enum.Font.Code
GDGB.TextSize = 11

GDGB.MouseButton1Click:Connect(function()
    GiveDroppedGearActive = not GiveDroppedGearActive
    GDGB.Text = GiveDroppedGearActive and "Give Gear: ON" or "Give Gear: OFF"
    GDGB.BackgroundColor3 = GiveDroppedGearActive and Color3.fromRGB(150, 100, 50) or Color3.fromRGB(60, 60, 60)
end)

local PDB = Instance.new("TextButton", MF)
PDB.Size = UDim2.new(0.5, 0, 0, 30)
PDB.Position = UDim2.new(0, 0, 1, -210)
PDB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
PDB.Text = "Perm Desync: OFF"
PDB.TextColor3 = Color3.new(1, 1, 1)
PDB.Font = Enum.Font.Code
PDB.TextSize = 11

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

            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += lookCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= lookCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= lookCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += lookCF.RightVector end
            
            if moveDir.Magnitude > 0 then 
                ghostOffset = ghostOffset + (moveDir.Unit * (FlySpeed * dt)) 
            end
            
            local basePos = root.Position + ghostOffset
            local ghostRot = lookCF.Rotation
            
            if StealArmActive then
                local stealTargetChar = nil
                for tPlayer, isActive in pairs(StealArmTargets) do
                    if isActive and tPlayer.Character then
                        stealTargetChar = tPlayer.Character
                        break
                    end
                end
                
                if stealTargetChar then
                    local targetLeftArm = stealTargetChar:FindFirstChild("Left Arm") or stealTargetChar:FindFirstChild("LeftLowerArm") or stealTargetChar:FindFirstChild("LeftHand")
                    if targetLeftArm then
                        local myRightArmOffset = Vector3.new(1.5, 0, 0)
                        basePos = targetLeftArm.Position - (ghostRot * myRightArmOffset)
                        ghostOffset = basePos - root.Position 
                    end
                end
            end
            
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    local n = part.Name
                    local pOffset = CFrame.new(0, 0, 0)
                    
                    if n:match("Right Arm") or n:match("RightUpperArm") or n:match("RightLowerArm") or n:match("RightHand") then
                        if char:FindFirstChildOfClass("Tool") then
                            pOffset = CFrame.new(1.5, 0.5, -0.5) * CFrame.Angles(math.rad(90), 0, 0)
                        else
                            pOffset = CFrame.new(1.5, 0, 0)
                        end
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

local GTB = Instance.new("TextButton", MF)
GTB.Size = UDim2.new(0.5, 0, 0, 30)
GTB.Position = UDim2.new(0, 0, 1, -180)
GTB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
GTB.Text = "Ghost Touch: OFF"
GTB.TextColor3 = Color3.new(1, 1, 1)
GTB.Font = Enum.Font.Code
GTB.TextSize = 11

GTB.MouseButton1Click:Connect(function()
    GhostTouchActive = not GhostTouchActive
    GTB.Text = GhostTouchActive and "Ghost Touch: ON" or "Ghost Touch: OFF"
    GTB.BackgroundColor3 = GhostTouchActive and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(60, 60, 60)
end)

local STB = Instance.new("TextButton", MF)
STB.Size = UDim2.new(0.5, 0, 0, 30)
STB.Position = UDim2.new(0, 0, 1, -150)
STB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
STB.Text = "Inf Stack: OFF"
STB.TextColor3 = Color3.new(1, 1, 1)
STB.Font = Enum.Font.Code
STB.TextSize = 11

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

local GAB = Instance.new("TextButton", MF)
GAB.Size = UDim2.new(0.5, 0, 0, 30)
GAB.Position = UDim2.new(0, 0, 1, -120)
GAB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
GAB.Text = "Give All: OFF"
GAB.TextColor3 = Color3.new(1, 1, 1)
GAB.Font = Enum.Font.Code
GAB.TextSize = 11

GAB.MouseButton1Click:Connect(function()
    GiveAllActive = not GiveAllActive
    GAB.Text = GiveAllActive and "Give All: ON" or "Give All: OFF"
    GAB.BackgroundColor3 = GiveAllActive and Color3.fromRGB(50, 100, 150) or Color3.fromRGB(70, 70, 70)
end)

-- *OPTIMIZED* GOD MODE BUTTON
local GDB = Instance.new("TextButton", MF)
GDB.Size = UDim2.new(0.5, 0, 0, 30) 
GDB.Position = UDim2.new(0, 0, 1, -90)
GDB.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
GDB.Text = "God Mode: OFF"
GDB.TextColor3 = Color3.new(1, 1, 1)
GDB.Font = Enum.Font.Code
GDB.TextSize = 11

GDB.MouseButton1Click:Connect(function()
    isGodMode = not isGodMode
    GDB.Text = isGodMode and "God Mode: ON" or "God Mode: OFF"
    GDB.BackgroundColor3 = isGodMode and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(70, 70, 70)
    
    if isGodMode then
        task.spawn(function()
            local swordName = "OverseerwrathSword"
            while isGodMode do 
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
                    else
                        task.wait(0.1) -- Prevents crash if swords go missing
                    end 
                else
                    task.wait(0.1)
                end 
            end 
        end)
    else
        -- Clean up unequipping when off
        local char = LP.Character
        local bp = LP:FindFirstChild("Backpack")
        if char and bp then
            for _, t in pairs(char:GetChildren()) do
                if t.Name == "OverseerwrathSword" then
                    t.Parent = bp
                end
            end
        end
    end
end)

local ALB = Instance.new("TextButton", MF)
ALB.Size = UDim2.new(0.5, 0, 0, 30) 
ALB.Position = UDim2.new(0, 0, 1, -60)
ALB.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ALB.Text = "ANTI-LASER: OFF"
ALB.TextColor3 = Color3.new(1, 1, 1)
ALB.Font = Enum.Font.Code
ALB.TextSize = 11

ALB.MouseButton1Click:Connect(function()
    IsAntiLaser = not IsAntiLaser
    ALB.Text = IsAntiLaser and "ANTI-LASER: ON" or "ANTI-LASER: OFF"
    ALB.BackgroundColor3 = IsAntiLaser and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(45, 45, 45)
end)

local RSB = Instance.new("TextButton", MF)
RSB.Size = UDim2.new(0.5, 0, 0, 30)
RSB.Position = UDim2.new(0, 0, 1, -30) 
RSB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
RSB.Text = "R-Spam: OFF"
RSB.TextColor3 = Color3.new(1, 1, 1)
RSB.Font = Enum.Font.Code
RSB.TextSize = 11

RSB.MouseButton1Click:Connect(function()
    RocketSpamActive = not RocketSpamActive
    RSB.Text = RocketSpamActive and "R-Spam: ON" or "R-Spam: OFF"
    RSB.BackgroundColor3 = RocketSpamActive and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(60, 60, 60)
    if not RocketSpamActive then 
        RocketTargets = {} 
        for _, btn in pairs(SF:GetChildren()) do
            if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end
        end
    end
end)

-- =====================================
-- COLUMN 2 BUTTONS
-- =====================================
local NCB = Instance.new("TextButton", MF)
NCB.Size = UDim2.new(0.5, 0, 0, 30)
NCB.Position = UDim2.new(0.5, 0, 1, -270)
NCB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
NCB.Text = "Noclip: OFF"
NCB.TextColor3 = Color3.new(1, 1, 1)
NCB.Font = Enum.Font.Code
NCB.TextSize = 11

NCB.MouseButton1Click:Connect(function()
    NoclipActive = not NoclipActive
    NCB.Text = NoclipActive and "Noclip: ON" or "Noclip: OFF"
    NCB.BackgroundColor3 = NoclipActive and Color3.fromRGB(150, 50, 150) or Color3.fromRGB(60, 60, 60)
end)

local ACB = Instance.new("TextButton", MF)
ACB.Size = UDim2.new(0.5, 0, 0, 30)
ACB.Position = UDim2.new(0.5, 0, 1, -240)
ACB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ACB.Text = "Auto Chud: OFF"
ACB.TextColor3 = Color3.new(1, 1, 1)
ACB.Font = Enum.Font.Code
ACB.TextSize = 11

ACB.MouseButton1Click:Connect(function()
    AutoChudActive = not AutoChudActive
    ACB.Text = AutoChudActive and "Auto Chud: ON" or "Auto Chud: OFF"
    ACB.BackgroundColor3 = AutoChudActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    if not AutoChudActive then 
        AutoChudTargets = {} 
        for _, btn in pairs(SF:GetChildren()) do
            if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end
        end
    end
end)

local ISB = Instance.new("TextButton", MF)
ISB.Size = UDim2.new(0.5, 0, 0, 30)
ISB.Position = UDim2.new(0.5, 0, 1, -210)
ISB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ISB.Text = "Supernova: OFF"
ISB.TextColor3 = Color3.new(1, 1, 1)
ISB.Font = Enum.Font.Code
ISB.TextSize = 11

ISB.MouseButton1Click:Connect(function()
    InfSupernovaActive = not InfSupernovaActive
    ISB.Text = InfSupernovaActive and "Supernova: ON" or "Supernova: OFF"
    ISB.BackgroundColor3 = InfSupernovaActive and Color3.fromRGB(200, 100, 50) or Color3.fromRGB(60, 60, 60)
end)

local APB = Instance.new("TextButton", MF)
APB.Size = UDim2.new(0.5, 0, 0, 30)
APB.Position = UDim2.new(0.5, 0, 1, -180)
APB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
APB.Text = "Anti-Pickup: OFF"
APB.TextColor3 = Color3.new(1, 1, 1)
APB.Font = Enum.Font.Code
APB.TextSize = 11

APB.MouseButton1Click:Connect(function()
    AntiPickupActive = not AntiPickupActive
    APB.Text = AntiPickupActive and "Anti-Pickup: ON" or "Anti-Pickup: OFF"
    APB.BackgroundColor3 = AntiPickupActive and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 60)
    
    if not AntiPickupActive then
        restoreTools()
    end
end)

local AVB = Instance.new("TextButton", MF)
AVB.Size = UDim2.new(0.5, 0, 0, 30)
AVB.Position = UDim2.new(0.5, 0, 1, -150)
AVB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AVB.Text = "Anti-Void: OFF"
AVB.TextColor3 = Color3.new(1, 1, 1)
AVB.Font = Enum.Font.Code
AVB.TextSize = 11

AVB.MouseButton1Click:Connect(function()
    AntiVoidActive = not AntiVoidActive
    AVB.Text = AntiVoidActive and "Anti-Void: ON" or "Anti-Void: OFF"
    AVB.BackgroundColor3 = AntiVoidActive and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(60, 60, 60)
    
    if AntiVoidActive then
        game.Workspace.FallenPartsDestroyHeight = -9e9
    else
        game.Workspace.FallenPartsDestroyHeight = -500
    end
end)

local SAB = Instance.new("TextButton", MF)
SAB.Size = UDim2.new(0.5, 0, 0, 30)
SAB.Position = UDim2.new(0.5, 0, 1, -120)
SAB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SAB.Text = "Steal Arm: OFF"
SAB.TextColor3 = Color3.new(1, 1, 1)
SAB.Font = Enum.Font.Code
SAB.TextSize = 11

SAB.MouseButton1Click:Connect(function()
    StealArmActive = not StealArmActive
    SAB.Text = StealArmActive and "Steal Arm: ON" or "Steal Arm: OFF"
    SAB.BackgroundColor3 = StealArmActive and Color3.fromRGB(180, 120, 0) or Color3.fromRGB(60, 60, 60)
    
    if not StealArmActive then
        StealArmTargets = {}
        for _, btn in pairs(SF:GetChildren()) do
            if btn:IsA("TextButton") then btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end
        end
    end
end)

local AASB = Instance.new("TextButton", MF)
AASB.Size = UDim2.new(0.5, 0, 0, 30)
AASB.Position = UDim2.new(0.5, 0, 1, -90)
AASB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AASB.Text = "Anti-Arm Steal"
AASB.TextColor3 = Color3.new(1, 1, 1)
AASB.Font = Enum.Font.Code
AASB.TextSize = 11

AASB.MouseButton1Click:Connect(function()
    if isAntiStealing then return end
    isAntiStealing = true
    
    AASB.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    AASB.Text = "DROPPING LEFT ARM..."
    
    task.spawn(function()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if char and hum then
            hum:UnequipTools()
            task.wait(0.05)
            
            local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
            
            local armParts = {}
            for _, name in pairs({"Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand"}) do
                local part = char:FindFirstChild(name)
                if part then table.insert(armParts, part) end
            end
            
            if torso and #armParts > 0 then
                for _, obj in pairs(torso:GetChildren()) do
                    if obj:IsA("JointInstance") then
                        for _, armPart in pairs(armParts) do
                            if obj.Part0 == armPart or obj.Part1 == armPart then
                                obj:Destroy()
                            end
                        end
                    end
                end
                
                for _, armPart in pairs(armParts) do
                    for _, obj in pairs(armPart:GetChildren()) do
                        if obj:IsA("JointInstance") or obj:IsA("BodyMover") or obj:IsA("Constraint") then
                            obj:Destroy()
                        end
                    end
                    
                    armPart.Anchored = false
                    armPart.CanCollide = false
                    armPart.CFrame = CFrame.new(0, -600, 0) 
                end
                
                hum:ChangeState(Enum.HumanoidStateType.Physics)
                task.wait(0.1)
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
        
        task.wait(1.5)
        AASB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        AASB.Text = "Anti-Arm Steal"
        isAntiStealing = false
    end)
end)

-- NEW FIRE AURA BUTTON
local FAB = Instance.new("TextButton", MF)
FAB.Size = UDim2.new(0.5, 0, 0, 30)
FAB.Position = UDim2.new(0.5, 0, 1, -60)
FAB.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FAB.Text = "Fire Aura: OFF"
FAB.TextColor3 = Color3.new(1, 1, 1)
FAB.Font = Enum.Font.Code
FAB.TextSize = 11

FAB.MouseButton1Click:Connect(function()
    isFireAura = not isFireAura
    FAB.Text = isFireAura and "Fire Aura: ON" or "Fire Aura: OFF"
    FAB.BackgroundColor3 = isFireAura and Color3.fromRGB(200, 80, 20) or Color3.fromRGB(60, 60, 60)

    if isFireAura then
        task.spawn(function()
            local swordName = "RedcliffRogueSword"
            while isFireAura do
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
                    else
                        task.wait(0.1) -- Prevents crash if swords go missing
                    end
                else
                    task.wait(0.1)
                end
            end
        end)
    else
        -- Clean up unequipping when off
        local char = LP.Character
        local bp = LP:FindFirstChild("Backpack")
        if char and bp then
            for _, t in pairs(char:GetChildren()) do
                if t.Name == "RedcliffRogueSword" then
                    t.Parent = bp
                end
            end
        end
    end
end)


-- =====================================
-- WORLD EVENTS & BACKGROUND TASKS
-- =====================================
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
    
    if AutoChudActive and (child.Name == "Burger" or child.Name == "Fries") then
        local targetHRP = nil
        for t, active in pairs(AutoChudTargets) do
            if active and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                targetHRP = t.Character.HumanoidRootPart
                break
            end
        end
        
        if targetHRP then
            local bv = child:WaitForChild("BodyVelocity", 0.5)
            local bg = child:WaitForChild("BodyGyro", 0.5)
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            
            child.CanCollide = false
            child.CFrame = targetHRP.CFrame
        end
    end

    if child.Name == LP.Name .. "'s Clone" then LatestClone = child end
end)

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
                        
                        pcall(function()
                            tool.Enabled = true
                            tool.FireRocket:FireServer(targetPos, spawnPos)
                        end)
                    end
                end
            end
        end
        task.wait(0.02)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if AutoChudActive then
            local hasTarget = false
            for t, active in pairs(AutoChudTargets) do
                if active and t.Character then hasTarget = true break end
            end
            
            if hasTarget and not isShootingFood then
                local bp = LP:FindFirstChild("Backpack")
                local char = LP.Character
                if bp and char then
                    local guns = {}
                    for _, item in pairs(bp:GetChildren()) do
                        if item:IsA("Tool") and item.Name == "BeefWellingtonGun" then table.insert(guns, item) end
                    end
                    for _, item in pairs(char:GetChildren()) do
                        if item:IsA("Tool") and item.Name == "BeefWellingtonGun" then table.insert(guns, item) end
                    end
                    for _, gun in ipairs(guns) do
                        if gun.Enabled then
                            isShootingFood = true
                            task.spawn(function()
                                gun.Parent = char
                                task.wait(0.08) 
                                pcall(function() gun:Activate() end)
                                task.wait(0.05) 
                                gun.Parent = bp
                                isShootingFood = false
                            end)
                            break 
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        if InfSupernovaActive then 
            local path = workspace:FindFirstChild("SingleRollDingle10")
            if path then path = path:FindFirstChild("IvoryPeriastron") end
            if path then path = path:FindFirstChild("Server") end
            if path then path = path:FindFirstChild("StarSummon") end
            if path then
                for _, child in ipairs(path:GetChildren()) do
                    if child.Name == "StarShard" or child.Name == "Explosion" then
                        child:Destroy()
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if AntiPickupActive then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Tool") then
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("BasePart") and child:FindFirstChildWhichIsA("TouchTransmitter") then
                            if child.CanTouch == true then
                                child.CanTouch = false
                                table.insert(disabledParts, child)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.5)
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

RS.Stepped:Connect(function()
    if NoclipActive and LP.Character then
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

---------------------------------------------------------
-- PLAYER LIST CLICK LOGIC
---------------------------------------------------------

local function E(t, btn)
    if StealArmActive then
        if StealArmTargets[t] then
            StealArmTargets[t] = nil
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        else
            StealArmTargets = {}
            for _, b in pairs(SF:GetChildren()) do
                if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end
            end
            StealArmTargets[t] = true
            btn.BackgroundColor3 = Color3.fromRGB(180, 120, 0)
            
            task.delay(0.5, function()
                if StealArmTargets[t] then
                    StealArmTargets[t] = nil 
                    if btn and btn.Parent then btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end
                end
            end)
        end
        return
    end

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
    
    if AutoChudActive then
        if AutoChudTargets[t] then
            AutoChudTargets[t] = nil
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        else
            AutoChudTargets[t] = true
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
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

    if not eS or not sS then 
        local oldText = btn.Text
        btn.Text = "NO SWORDS!"
        btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        task.delay(1, function()
            if btn and btn.Parent then
                btn.Text = oldText
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
        end)
        return 
    end

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
            
            if RocketSpamActive and RocketTargets[p] then
                b.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            elseif AutoChudActive and AutoChudTargets[p] then
                b.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            elseif StealArmActive and StealArmTargets[p] then
                b.BackgroundColor3 = Color3.fromRGB(180, 120, 0)
            else
                b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
            
            b.Text = p.Name
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.Code
            b.TextSize = 13 
            b.MouseButton1Click:Connect(function() E(p, b) end)
        end 
    end 
end

R()
P.PlayerAdded:Connect(R)
P.PlayerRemoving:Connect(R)
