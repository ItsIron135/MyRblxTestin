--[[ CBM'S ADMIN PANEL ]]--

---------------------------------------------------------
-- SERVICES & VARIABLES
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
local desyncActive, desyncLoop, ghostOffset = false, nil, Vector3.new(0, 0, 0)
local Flying, FlySpeed = false, 100 
local NoclipActive, GhostTouchActive, GiveDroppedGearActive = false, false, false
local IsStackingActive, isGodMode, InfSupernovaActive = false, false, false
local isAntiStealing = false

-- AUTO-ON STATES
local GiveAllActive = true
local IsAntiLaser = true
local AntiVoidActive = true

local RocketSpamActive, AutoRocketEnabled, AUTO_RANGE, RocketTargets = false, false, 25, {}
local SpawnCloneActive, SpawnCloneTargets = false, {}

local SKillActive, SKillTargets, SKillLoops, SKillTrackers, ActiveSKillSwords = false, {}, {}, {}, {}
local VoidKillActive, VoidKillTargets, VoidKillLoops, VoidKillTrackers, ActiveVoidKillSwords = false, {}, {}, {}, {}
local StealArmActive, StealArmTargets = false, {}

local AntiPickupActive, hiddenTools, antiPickupConnection = false, {}, nil
local hiddenToolsCache = Instance.new("Folder") 
hiddenToolsCache.Name = "AntiPickupCache"

local UsedSwords, LatestClone = {}, nil
local lastGhostTouch = 0 -- Prevents game crash from spamming touch interest
local laserNames = {["Rain"]=true, ["Beam"]=true, ["Effect"]=true, ["StarShard"]=true, ["CrimsonPillar"]=true, ["Part"]=true}

---------------------------------------------------------
-- CORE UI CREATION
---------------------------------------------------------
local SG = Instance.new("ScreenGui", PG)
SG.Name, SG.ResetOnSpawn = "StealerUI", false

local MF = Instance.new("Frame", SG)
MF.Size, MF.Position, MF.BackgroundColor3, MF.Active, MF.Draggable, MF.BorderSizePixel = UDim2.new(0, 240, 0, 520), UDim2.new(0.85, -120, 0.5, -200), Color3.fromRGB(35, 35, 35), true, true, 0

local T = Instance.new("TextLabel", MF)
T.Size, T.BackgroundTransparency, T.Text, T.TextColor3, T.Font, T.TextSize = UDim2.new(1, -30, 0, 30), 1, "Admin Panel", Color3.new(0.9, 0.9, 0.9), Enum.Font.Code, 14

local CB = Instance.new("TextButton", MF)
CB.Size, CB.Position, CB.BackgroundColor3, CB.Text, CB.TextColor3 = UDim2.new(0, 30, 0, 30), UDim2.new(1, -30, 0, 0), Color3.fromRGB(150, 50, 50), "X", Color3.new(1, 1, 1)

local SF = Instance.new("ScrollingFrame", MF)
SF.Size, SF.Position, SF.BackgroundTransparency, SF.ScrollBarThickness, SF.ScrollingEnabled, SF.Active = UDim2.new(1, 0, 1, -300), UDim2.new(0, 0, 0, 30), 1, 6, true, true

local UIList = Instance.new("UIListLayout", SF)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SF.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
end)

local AutoLabel = Instance.new("TextLabel", SG)
AutoLabel.Size, AutoLabel.Position, AutoLabel.BackgroundColor3, AutoLabel.TextColor3 = UDim2.new(0, 220, 0, 40), UDim2.new(0.5, -110, 0.1, 0), Color3.fromRGB(30, 30, 30), Color3.fromRGB(200, 70, 70)
AutoLabel.Text, AutoLabel.TextScaled, AutoLabel.Font, AutoLabel.Visible = "Auto Rocket: OFF", true, Enum.Font.SourceSansBold, false
Instance.new("UICorner", AutoLabel)

---------------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------------
local function refreshPlayerColors()
    for _, b in pairs(SF:GetChildren()) do
        if b:IsA("TextButton") then
            local p = P:FindFirstChild(b.Text)
            if p then
                if RocketSpamActive and RocketTargets[p.UserId] then b.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
                elseif VoidKillActive and VoidKillTargets[p] then b.BackgroundColor3 = Color3.fromRGB(40, 150, 160)
                elseif SKillActive and SKillTargets[p] then b.BackgroundColor3 = Color3.fromRGB(40, 110, 150)
                elseif SpawnCloneActive and SpawnCloneTargets[p] then b.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
                elseif StealArmActive and StealArmTargets[p] then b.BackgroundColor3 = Color3.fromRGB(140, 90, 20)
                else b.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end
            end
        end
    end
end

local function makeBtn(parent, text, size, pos, bgColor)
    local b = Instance.new("TextButton", parent)
    b.Size, b.Position, b.BackgroundColor3, b.Text, b.TextColor3, b.Font, b.TextSize = size, pos, bgColor, text, Color3.new(0.9, 0.9, 0.9), Enum.Font.Code, 12
    return b
end

local function hideTool(tool)
    if tool:IsA("Tool") and tool.Parent and not tool.Parent:FindFirstChild("Humanoid") and not tool.Parent:IsA("Backpack") then
        hiddenTools[tool], tool.Parent = tool.Parent, hiddenToolsCache 
    end
end

local function restoreTools()
    for tool, p in pairs(hiddenTools) do if tool then pcall(function() tool.Parent = p or workspace end) end end
    table.clear(hiddenTools)
end

local function clearToolTargets(targets, loops, trackers, activeMap)
    for t, _ in pairs(targets) do
        local n = t.Name
        if loops[n] then loops[n]:Disconnect(); loops[n] = nil end
        if trackers[n] then trackers[n]:Disconnect(); trackers[n] = nil end
        for sword, ply in pairs(activeMap) do
            if ply == t then
                activeMap[sword] = nil
                if sword and sword.Parent == LP.Character then
                    sword.Parent = LP:FindFirstChild("Backpack") or sword.Parent
                    local h = sword:FindFirstChild("Handle")
                    if h then h.Massless = false end
                end
            end
        end
    end
    table.clear(targets)
end

local function attachTool(tPlayer, tool, loopsMap)
    local char = LP.Character
    if not char then return end
    for _, part in pairs(tool:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Massless = true
            part.CanCollide = false
            part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        end
    end
    local handle = tool:FindFirstChild("Handle")
    local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
    if handle and rightArm then
        tool.RequiresHandle = true 
        local n = tPlayer.Name
        if loopsMap[n] then loopsMap[n]:Disconnect() end
        loopsMap[n] = RS.Heartbeat:Connect(function()
            local tChar = tPlayer.Character
            local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if not tHRP then return end 
            if tool.Parent == LP:FindFirstChild("Backpack") then tool.Parent = char end
            if tool.Parent == char and handle then
                local grip
                for _, j in pairs(rightArm:GetChildren()) do 
                    if j.Name == "RightGrip" and j.Part1 == handle then grip = j; break end 
                end
                if grip then grip.C1 = tHRP.CFrame:Inverse() * rightArm.CFrame * grip.C0 end
            end
        end)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            for _, t in pairs(hum:GetPlayingAnimationTracks()) do
                if t.Name:lower():find("tool") or (t.Animation and tostring(t.Animation.AnimationId):find("507768375")) then t:Stop() end
            end
        end
    end
end

local function toggleTargetSkill(btn, t, swordName, targetMap, loopMap, trackerMap, activeMap)
    if targetMap[t] then
        local singleTarget = {[t] = true}
        clearToolTargets(singleTarget, loopMap, trackerMap, activeMap)
        targetMap[t] = nil
    else
        local bp, char = LP:FindFirstChild("Backpack"), LP.Character
        local sword, allSwords = nil, {}
        if char then for _, obj in pairs(char:GetChildren()) do if obj.Name == swordName then table.insert(allSwords, obj) end end end
        if bp then for _, obj in pairs(bp:GetChildren()) do if obj.Name == swordName then table.insert(allSwords, obj) end end end
        for _, s in pairs(allSwords) do if not activeMap[s] then sword = s; break end end
        if sword then
            targetMap[t], activeMap[sword], sword.Parent = true, t, char 
            attachTool(t, sword, loopMap)
            trackerMap[t.Name] = t.CharacterAdded:Connect(function() if sword and sword.Parent == char then attachTool(t, sword, loopMap) end end)
        else
            local old = btn.Text
            btn.Text, btn.BackgroundColor3 = "NO "..swordName:upper(), Color3.fromRGB(150, 40, 40)
            task.delay(1, function() if btn and btn.Parent and not targetMap[t] then btn.Text = old; refreshPlayerColors() end end)
        end
    end
end

local function consistentWeldTPGive(targetPlayer)
    local char = LP.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
    local tc = targetPlayer.Character
    local thrp = tc and (tc:FindFirstChild("HumanoidRootPart") or tc:FindFirstChild("Torso"))
    if not root or not thrp then return end
    local gears, welds, originalCFrame = {}, {}, root.CFrame
    for _, item in ipairs(workspace:GetChildren()) do
        if item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then
                handle.Anchored, handle.CFrame = false, root.CFrame
                local weld = Instance.new("WeldConstraint")
                weld.Part0, weld.Part1, weld.Parent = root, handle, root
                table.insert(gears, handle); table.insert(welds, weld)
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
                    local h, w = gears[i], welds[i]
                    local tool = h and h.Parent
                    if tool and tool.Parent ~= workspace then
                        if w then w:Destroy() end 
                        table.remove(gears, i); table.remove(welds, i)
                    elseif h and h.Parent then
                        firetouchinterest(thrp, h, 0); firetouchinterest(thrp, h, 1)
                    end
                end
            end
            RS.Heartbeat:Wait()
        end
        for _, w in ipairs(welds) do if w then w:Destroy() end end
        if root then root.CFrame = originalCFrame end
    end)
end

local function executeSpectralNuke(t, btn)
    local c = LP.Character
    local h, hrp = c and c:FindFirstChild("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
    local tc = t.Character
    local thrp = tc and tc:FindFirstChild("HumanoidRootPart")
    if not c or not h or not hrp or not thrp then return end
    local bp = LP:WaitForChild("Backpack")
    local eS = bp:FindFirstChild("EnergySword") or c:FindFirstChild("EnergySword")
    local sS
    for _, item in ipairs(bp:GetChildren()) do if item.Name == "SpectralSword" and not UsedSwords[item] then sS = item break end end
    if not sS then for _, item in ipairs(c:GetChildren()) do if item.Name == "SpectralSword" and not UsedSwords[item] then sS = item break end end end
    if not eS or not sS then 
        local old = btn.Text
        btn.Text, btn.BackgroundColor3 = "NO SWORDS!", Color3.fromRGB(150, 40, 40)
        task.delay(1, function() if btn and btn.Parent then btn.Text = old; refreshPlayerColors() end end)
        return 
    end
    local kd, originalCFrame = sS:FindFirstChild("KeyDown"), hrp.CFrame 
    UsedSwords[sS], eS.Parent, sS.Parent = true, c, c
    local startTime, lastSpam, conn = tick(), 0, nil
    conn = RS.Heartbeat:Connect(function()
        local now = tick()
        if (now - startTime) < 1 and hrp and thrp and thrp.Parent then
            hrp.CFrame = thrp.CFrame * CFrame.new(0, 0, 4) * CFrame.Angles(0, math.pi, 0)
            if now > (startTime + 0.2) and now - lastSpam > 0.1 then
                if kd then kd:FireServer("r") end
                lastSpam = now
            end
        else
            conn:Disconnect()
            if sS then sS.Name = "UsedSpectralSword" end
            hrp.CFrame = originalCFrame
            SpawnCloneTargets[t] = nil
            refreshPlayerColors()
        end
    end)
end

---------------------------------------------------------
-- ROCKET SPAM LOGIC
---------------------------------------------------------
local function getFR()
    local char, bp = LP.Character, LP:FindFirstChild("Backpack")
    local RJ = (bp and bp:FindFirstChild("RocketJumper")) or (char and char:FindFirstChild("RocketJumper"))
    return RJ and RJ:FindFirstChild("FireRocket")
end

local function fireRocketAt(pos)
    local FR = getFR()
    if FR then FR:FireServer(pos, pos + Vector3.new(0.002, 0.002, 0.002)) end
end

task.spawn(function()
    while true do
        for userId, isActive in pairs(RocketTargets) do
            if isActive then
                local tp = P:GetPlayerByUserId(userId)
                if tp and tp.Character and tp.Character:FindFirstChild("HumanoidRootPart") then
                    fireRocketAt(tp.Character.HumanoidRootPart.Position)
                end
            end
        end
        if AutoRocketEnabled then
            local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local hum, root = p.Character:FindFirstChildOfClass("Humanoid"), p.Character:FindFirstChild("HumanoidRootPart")
                        if hum and hum.Health > 0 and root then
                            local dist = (root.Position - myRoot.Position).Magnitude
                            if dist <= AUTO_RANGE and dist >= 6 then
                                local isHolding = false
                                for _, obj in ipairs(p.Character:GetChildren()) do
                                    if obj:IsA("Tool") and obj:FindFirstChild("Handle") then isHolding = true; break end
                                end
                                if isHolding then fireRocketAt(root.Position) end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.B then
        AutoRocketEnabled = not AutoRocketEnabled
        print("Auto Rocket Active: ", AutoRocketEnabled)
    end
end)

---------------------------------------------------------
-- IMMEDIATE EXECUTIONS (AUTO-RUN)
---------------------------------------------------------
task.spawn(function()
    workspace.FallenPartsDestroyHeight = -9e9
    local root = (LP.Character or LP.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart", 5)
    if not root then return end
    local closest, cDist = nil, math.huge
    for i = 1, 8 do
        local loc = workspace:FindFirstChild("Spawn"..i) and workspace:FindFirstChild("Spawn"..i):FindFirstChild("SpawnLocation")
        if loc and loc:IsA("BasePart") and (loc.Position - root.Position).Magnitude < cDist then
            cDist, closest = (loc.Position - root.Position).Magnitude, loc
        end
    end
    if closest then homeCFrame = closest.CFrame + Vector3.new(0, 4, 0) end
end)

task.spawn(function()
    local FAR_AWAY_COORDS = CFrame.new(99999, 99999, 99999)
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "SpawnWalls" and v:IsA("BasePart") then
            v.CFrame = FAR_AWAY_COORDS
            v.Anchored = true
            v.CanCollide = false
        end
    end
end)

---------------------------------------------------------
-- UI CREATION
---------------------------------------------------------
makeBtn(MF, "TP To Void", UDim2.new(0.5,0,0,30), UDim2.new(0,0,1,-300), Color3.fromRGB(70,40,70)).MouseButton1Click:Connect(function()
    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if r then r.CFrame = CFrame.new(-1050, -490, 90) end
end)

local THB = makeBtn(MF, "TP Home", UDim2.new(0.5,0,0,30), UDim2.new(0.5,0,1,-300), Color3.fromRGB(40,70,40))
THB.MouseButton1Click:Connect(function()
    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if r then
        if homeCFrame then r.CFrame = homeCFrame else
            local old = THB.Text; THB.Text, THB.BackgroundColor3 = "NO HOME!", Color3.fromRGB(150,40,40)
            task.delay(1, function() if THB.Parent then THB.Text, THB.BackgroundColor3 = old, Color3.fromRGB(40,70,40) end end)
        end
    end
end)

local function createToggle(col, yPos, text, activeCol, initialValue, action)
    local btn = makeBtn(MF, text..(initialValue and ": ON" or ": OFF"), UDim2.new(0.5,0,0,30), UDim2.new(col,0,1,yPos), initialValue and activeCol or Color3.fromRGB(50,50,50))
    btn.TextSize = 11
    btn.MouseButton1Click:Connect(function()
        local state = action()
        btn.Text, btn.BackgroundColor3 = text..(state and ": ON" or ": OFF"), state and activeCol or Color3.fromRGB(50,50,50)
    end)
end

-- COLUMN 1
createToggle(0, -270, "Fly", Color3.fromRGB(40,100,150), false, function()
    Flying = not Flying
    local char = LP.Character
    local root, hum = char and char:FindFirstChild("HumanoidRootPart"), char and char:FindFirstChildOfClass("Humanoid")
    if Flying and root and hum then
        local bv, bg = Instance.new("BodyVelocity", root), Instance.new("BodyGyro", root)
        bv.Name, bv.MaxForce, bv.Velocity = "FlyVelocity", Vector3.new(9e9,9e9,9e9), Vector3.new(0,0,0)
        bg.Name, bg.MaxTorque, bg.P, bg.CFrame = "FlyGyro", Vector3.new(9e9,9e9,9e9), 9e4, root.CFrame
        task.spawn(function()
            while Flying and root and root.Parent do
                local dir = hum.MoveDirection 
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
                bv.Velocity = dir.Magnitude > 0 and (dir.Unit * FlySpeed) or Vector3.new(0, 0, 0)
                bg.CFrame = cam.CFrame
                task.wait()
            end
            if bv then bv:Destroy() end; if bg then bg:Destroy() end
        end)
    end
    return Flying
end)
createToggle(0, -240, "Give Gear", Color3.fromRGB(120,80,40), false, function() GiveDroppedGearActive = not GiveDroppedGearActive; return GiveDroppedGearActive end)
createToggle(0, -210, "Perm Desync", Color3.fromRGB(40,100,150), false, function()
    desyncActive = not desyncActive
    local char = LP.Character
    local hum, root = char and char:FindFirstChildOfClass("Humanoid"), char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not root then return desyncActive end
    if desyncActive then
        ghostOffset, hum.PlatformStand = Vector3.new(0,0,0), true
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        local bv = Instance.new("BodyVelocity", root)
        bv.Name, bv.MaxForce, bv.Velocity = "GhostFreeze", Vector3.new(9e9,9e9,9e9), Vector3.new(0,0,0)
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = false end
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Massless, v.CanCollide = true, false end
        end
        desyncLoop = RS.Heartbeat:Connect(function(dt)
            if not desyncActive then return end
            local lookCF, moveDir = cam.CFrame, Vector3.new(0,0,0)
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += lookCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= lookCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= lookCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += lookCF.RightVector end
            if moveDir.Magnitude > 0 then ghostOffset += (moveDir.Unit * (FlySpeed * dt)) end
            local basePos, ghostRot = root.Position + ghostOffset, lookCF.Rotation
            local sChar
            for t, a in pairs(StealArmTargets) do if a and t.Character then sChar = t.Character break end end
            if sChar then
                local tArm = sChar:FindFirstChild("Left Arm") or sChar:FindFirstChild("LeftLowerArm") or sChar:FindFirstChild("LeftHand")
                if tArm then basePos = tArm.Position - (ghostRot * Vector3.new(1.5,0,0)); ghostOffset = basePos - root.Position end
            end
            for _, part in pairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    local n, pOffset = part.Name, CFrame.new(0,0,0)
                    if n:match("Right Arm") or n:match("RightHand") then pOffset = char:FindFirstChildOfClass("Tool") and CFrame.new(1.5,0.5,-0.5)*CFrame.Angles(math.rad(90),0,0) or CFrame.new(1.5,0,0)
                    elseif n:match("Left Arm") or n:match("LeftHand") then pOffset = CFrame.new(-1.5,0,0)
                    elseif n:match("Leg") or n:match("Foot") then pOffset = CFrame.new(n:find("Right") and 0.5 or -0.5,-2,0)
                    elseif n == "Head" then pOffset = CFrame.new(0,1.5,0) end
                    part.CFrame, part.AssemblyLinearVelocity = CFrame.new(basePos) * ghostRot * pOffset, Vector3.new(0,0,0)
                end
            end
            if char:FindFirstChild("Head") then cam.CameraSubject, hum.CameraOffset = char.Head, ghostRot:Inverse()*(basePos - root.Position) end
        end)
    else
        if desyncLoop then desyncLoop:Disconnect() end
        if root:FindFirstChild("GhostFreeze") then root.GhostFreeze:Destroy() end
        hum.CameraOffset, cam.CameraSubject = Vector3.new(0,0,0), hum
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Motor6D") then v.Enabled = true end
            if v:IsA("BasePart") then v.Massless = false; if v.Name ~= "HumanoidRootPart" then v.CanCollide = true end; v.Anchored = false end
        end
        root.Anchored, hum.PlatformStand = false, false
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    return desyncActive
end)
createToggle(0, -180, "Ghost Touch", Color3.fromRGB(150,80,20), false, function() GhostTouchActive = not GhostTouchActive; return GhostTouchActive end)
createToggle(0, -150, "Inf Stack", Color3.fromRGB(100,40,100), false, function()
    IsStackingActive = not IsStackingActive
    local char, bp = LP.Character, LP:FindFirstChild("Backpack")
    local carrot = (bp and bp:FindFirstChild("Carrot")) or (char and char:FindFirstChild("Carrot"))
    if IsStackingActive and carrot and char and char:FindFirstChild("Humanoid") then
        char.Humanoid:EquipTool(carrot); task.wait(0.1); carrot:Activate(); task.wait(0.1); char.Humanoid:UnequipTools()
    end
    return IsStackingActive
end)
createToggle(0, -120, "Give All", Color3.fromRGB(40,80,120), true, function() GiveAllActive = not GiveAllActive; return GiveAllActive end)

-- God Mode touch button with local inventory desync sequence
local GodBtn = makeBtn(MF, "God Mode", UDim2.new(0.5,0,0,30), UDim2.new(0,0,1,-90), Color3.fromRGB(50,50,50))
GodBtn.TextSize = 11
GodBtn.MouseButton1Click:Connect(function()
    if isGodMode then return end
    isGodMode = true
    GodBtn.Text = "STACKING..."
    GodBtn.BackgroundColor3 = Color3.fromRGB(40,120,40)
    
    task.spawn(function()
        while isGodMode do 
            local char, bp = LP.Character, LP:FindFirstChild("Backpack") 
            if char and bp then 
                local swords = {} 
                for _, t in pairs(char:GetChildren()) do if t.Name == "OverseerwrathSword" then table.insert(swords, t) end end 
                for _, t in pairs(bp:GetChildren()) do if t.Name == "OverseerwrathSword" then table.insert(swords, t) end end 
                
                -- Sequence triggered at 6 swords
                if #swords >= 6 then
                    for _, s in pairs(swords) do s.Parent = bp end
                    task.wait(0.2)
                    for _, s in pairs(swords) do s.Parent = char end
                    task.wait(0.2)
                    for _, s in pairs(swords) do s.Parent = bp end
                    task.wait() 
                    for _, s in pairs(swords) do s.Parent = nil end
                    break
                end
                
                if #swords > 0 then 
                    for _, s in pairs(swords) do s.Parent = char end; task.wait(0.01) 
                    for _, s in pairs(swords) do s.Parent = bp end; task.wait(0.01) 
                else 
                    task.wait(0.1) 
                end 
            else 
                task.wait(0.1) 
            end 
        end 
        GodBtn.Text = "God Mode"
        GodBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        isGodMode = false
    end)
end)

createToggle(0, -60, "ANTI-LASER", Color3.fromRGB(40,90,40), true, function() IsAntiLaser = not IsAntiLaser; return IsAntiLaser end)
createToggle(0, -30, "R-Spam", Color3.fromRGB(150,30,30), false, function() RocketSpamActive = not RocketSpamActive; if not RocketSpamActive then table.clear(RocketTargets) end; refreshPlayerColors(); return RocketSpamActive end)

-- COLUMN 2
createToggle(0.5, -270, "Noclip", Color3.fromRGB(120,40,120), false, function() NoclipActive = not NoclipActive; return NoclipActive end)
createToggle(0.5, -240, "Spawn Clone", Color3.fromRGB(40,120,40), false, function() SpawnCloneActive = not SpawnCloneActive; if not SpawnCloneActive then table.clear(SpawnCloneTargets) end; refreshPlayerColors(); return SpawnCloneActive end)
createToggle(0.5, -210, "Supernova", Color3.fromRGB(150,80,40), false, function() InfSupernovaActive = not InfSupernovaActive; return InfSupernovaActive end)
createToggle(0.5, -180, "Anti-Pickup", Color3.fromRGB(40,120,40), false, function()
    AntiPickupActive = not AntiPickupActive
    if AntiPickupActive then
        for _, obj in ipairs(workspace:GetDescendants()) do hideTool(obj) end
        task.spawn(function() while AntiPickupActive do task.wait(0.05); for _, obj in ipairs(workspace:GetChildren()) do hideTool(obj) end end end)
        antiPickupConnection = workspace.DescendantAdded:Connect(function(obj) if AntiPickupActive then task.wait(0.05); hideTool(obj) end end)
    else
        if antiPickupConnection then antiPickupConnection:Disconnect(); antiPickupConnection = nil end
        restoreTools()
    end
    return AntiPickupActive
end)
createToggle(0.5, -150, "Anti-Void", Color3.fromRGB(40,120,120), true, function() AntiVoidActive = not AntiVoidActive; workspace.FallenPartsDestroyHeight = AntiVoidActive and -9e9 or -500; return AntiVoidActive end)
createToggle(0.5, -120, "Steal Arm", Color3.fromRGB(140,90,20), false, function() StealArmActive = not StealArmActive; if not StealArmActive then table.clear(StealArmTargets) end; refreshPlayerColors(); return StealArmActive end)

local AASB = makeBtn(MF, "Anti-Arm Steal", UDim2.new(0.5,0,0,30), UDim2.new(0.5,0,1,-90), Color3.fromRGB(50,50,50))
AASB.TextSize = 11
AASB.MouseButton1Click:Connect(function()
    if isAntiStealing then return end
    isAntiStealing, AASB.BackgroundColor3, AASB.Text = true, Color3.fromRGB(120,30,30), "GLITCHING ARMS..."
    task.spawn(function()
        if LP and LP.Character and LP:FindFirstChild("Backpack") then
            local char, bp = LP.Character, LP.Backpack
            local initK = bp:FindFirstChild("MadMurdererKnife")
            if initK and initK:IsA("Tool") then
                initK.Parent = char; task.wait(0.4); initK.Parent = bp; task.wait()
                local ks = {}
                for _, i in ipairs(bp:GetChildren()) do if i:IsA("Tool") and i.Name == "MadMurdererKnife" then table.insert(ks, i) end end
                if #ks >= 2 then
                    local k1, k2 = ks[1], ks[2]
                    k1.Parent = char; task.wait(0.2); k2.Parent = char; task.wait(); k2.Parent = bp; task.wait(0.2)
                    if k1.Parent == char then k1.Parent = bp end; task.wait(0.2)
                    local rw = char:FindFirstChild("RightWeld", true)
                    if rw then rw:Destroy() end
                    local ls = char:FindFirstChild("Left Shoulder", true)
                    if ls then ls:Destroy() end
                end
            end
        end
        task.wait(1.5)
        AASB.BackgroundColor3, AASB.Text, isAntiStealing = Color3.fromRGB(50,50,50), "Anti-Arm Steal", false
    end)
end)

createToggle(0.5, -60, "Void-Kill", Color3.fromRGB(40,150,160), false, function() VoidKillActive = not VoidKillActive; if not VoidKillActive then clearToolTargets(VoidKillTargets, VoidKillLoops, VoidKillTrackers, ActiveVoidKillSwords) end; refreshPlayerColors(); return VoidKillActive end)
createToggle(0.5, -30, "S-Kill", Color3.fromRGB(40,110,150), false, function() SKillActive = not SKillActive; if not SKillActive then clearToolTargets(SKillTargets, SKillLoops, SKillTrackers, ActiveSKillSwords) end; refreshPlayerColors(); return SKillActive end)

---------------------------------------------------------
-- BACKGROUND TASKS & EVENTS
---------------------------------------------------------
CB.MouseButton1Click:Connect(function() 
    if desyncActive then desyncActive = false; if desyncLoop then desyncLoop:Disconnect() end end
    if antiPickupConnection then antiPickupConnection:Disconnect(); antiPickupConnection = nil end
    AntiPickupActive, isGodMode, VoidKillActive, SpawnCloneActive = false, false, false, false
    clearToolTargets(SKillTargets, SKillLoops, SKillTrackers, ActiveSKillSwords)
    clearToolTargets(VoidKillTargets, VoidKillLoops, VoidKillTrackers, ActiveVoidKillSwords)
    restoreTools()
    SG:Destroy() 
end)

workspace.ChildAdded:Connect(function(child)
    if IsAntiLaser then
        RS.Heartbeat:Wait()
        if laserNames[child.Name] or child:IsA("SelectionPartLasso") then
            if child:IsA("BasePart") then child.CanTouch, child.CanCollide, child.Transparency = false, false, 1 end
            child:Destroy()
        end
    end
    if child.Name == LP.Name .. "'s Clone" then LatestClone = child end
end)

task.spawn(function()
    while true do
        task.wait(0.1)

        if InfSupernovaActive and LP then 
            local pth = workspace:FindFirstChild(LP.Name) 
            
            if pth then pth = pth:FindFirstChild("IvoryPeriastron") end
            if pth then pth = pth:FindFirstChild("Server") end
            if pth then pth = pth:FindFirstChild("StarSummon") end
            
            if pth then
                for _, c in ipairs(pth:GetChildren()) do
                    if c.Name == "StarShard" or c.Name == "Explosion" then
                        c:Destroy()
                    end
                end
            end
        end
    end
end)

RS.Heartbeat:Connect(function()
    local char, bp = LP.Character, LP:FindFirstChild("Backpack")
    if IsStackingActive and char and bp then
        local t = char:FindFirstChildOfClass("Tool")
        if t then for _, i in ipairs(bp:GetChildren()) do if i.Name == t.Name then i.Parent = char end end end
    end
    if GiveAllActive then
        for _, n in ipairs({"SpawnRainbowBlock", "SpawnDiamondBlock", "SpawnSuperBlock", "SpawnLuckyBlock", "SpawnGalaxyBlock"}) do
            local e = RP:FindFirstChild(n); if e then e:FireServer() end
        end
    end
    if GhostTouchActive then
        local root = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
        local target = LatestClone or workspace:FindFirstChild(LP.Name .. "'s Clone")
        
        if target and root then
            local cloneTool = target:FindFirstChildOfClass("Tool")
            local handle = cloneTool and (cloneTool:FindFirstChild("Handle") or cloneTool:FindFirstChildOfClass("BasePart"))
            
            if handle and (tick() - lastGhostTouch > 0.1) then
                lastGhostTouch = tick()
                firetouchinterest(root, handle, 0)
                firetouchinterest(root, handle, 1)
            end
        end
    end
end)

RS.Stepped:Connect(function()
    if NoclipActive and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end
    end
end)

---------------------------------------------------------
-- PLAYER LIST CLICK LOGIC 
---------------------------------------------------------
local function E(t, btn)
    local tookAction = false
    if StealArmActive then
        tookAction = true
        if StealArmTargets[t] then StealArmTargets[t] = nil else
            table.clear(StealArmTargets); StealArmTargets[t] = true
            task.delay(0.2, function() if StealArmTargets[t] then StealArmTargets[t] = nil; refreshPlayerColors() end end)
        end
    end
    if RocketSpamActive then
        tookAction = true
        RocketTargets[t.UserId] = not RocketTargets[t.UserId] and true or nil
    end
    if SpawnCloneActive then
        tookAction = true
        table.clear(SpawnCloneTargets); SpawnCloneTargets[t] = true
        task.spawn(function() executeSpectralNuke(t, btn) end)
    end
    if VoidKillActive then
        tookAction = true
        if VoidKillTargets[t] then
            local single = {[t] = true}
            clearToolTargets(single, VoidKillLoops, VoidKillTrackers, ActiveVoidKillSwords)
            VoidKillTargets[t] = nil
        else
            VoidKillTargets[t] = true; refreshPlayerColors()
            task.spawn(function()
                local char = LP.Character
                local hum, root = char and char:FindFirstChildOfClass("Humanoid"), char and char:FindFirstChild("HumanoidRootPart")
                local bp = LP:FindFirstChild("Backpack")
                if not char or not hum or not root or not bp then return end
                root.CFrame = CFrame.new(-1050, -490, 90)
                task.wait(0.1)
                hum:UnequipTools()
                local specificBearArm = bp:FindFirstChild("Bear Arm") or char:FindFirstChild("Bear Arm") or bp:FindFirstChild("BearArm") or char:FindFirstChild("BearArm")
                if specificBearArm then
                    hum:EquipTool(specificBearArm)
                    StealArmTargets[t] = true
                    local loopEnd = tick() + 0.2
                    while tick() < loopEnd and VoidKillTargets[t] do RS.Heartbeat:Wait() end
                end
                if not VoidKillTargets[t] then return end
                local sword, allSwords = nil, {}
                for _, obj in pairs(char:GetChildren()) do if obj.Name == "IceSword" then table.insert(allSwords, obj) end end
                for _, obj in pairs(bp:GetChildren()) do if obj.Name == "IceSword" then table.insert(allSwords, obj) end end
                for _, s in pairs(allSwords) do if not ActiveVoidKillSwords[s] then sword = s; break end end
                if sword then
                    ActiveVoidKillSwords[sword] = t
                    hum:EquipTool(sword) 
                    attachTool(t, sword, VoidKillLoops)
                    VoidKillTrackers[t.Name] = t.CharacterAdded:Connect(function() 
                        if sword and sword.Parent == char then attachTool(t, sword, VoidKillLoops) end 
                    end)
                else
                    local old = btn.Text
                    btn.Text, btn.BackgroundColor3 = "NO ICESWORD", Color3.fromRGB(150, 40, 40)
                    task.delay(1, function() if btn and btn.Parent and not VoidKillTargets[t] then btn.Text = old; refreshPlayerColors() end end)
                    local single = {[t] = true}
                    clearToolTargets(single, VoidKillLoops, VoidKillTrackers, ActiveVoidKillSwords)
                    VoidKillTargets[t] = nil
                    StealArmTargets[t] = nil
                    return
                end
                if specificBearArm then
                    local spamEndTime = tick() + 3.0
                    while tick() < spamEndTime and VoidKillTargets[t] do
                        if specificBearArm.Parent == bp then specificBearArm.Parent = char else specificBearArm.Parent = bp end
                        task.wait(0.01)
                    end
                    specificBearArm.Parent = bp
                    StealArmTargets[t] = nil
                end
            end)
        end
    end
    if SKillActive then tookAction = true; toggleTargetSkill(btn, t, "BoneSword", SKillTargets, SKillLoops, SKillTrackers, ActiveSKillSwords) end
    if tookAction then refreshPlayerColors(); return end 
    if GiveDroppedGearActive then
        btn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
        consistentWeldTPGive(t); task.wait(1.5); refreshPlayerColors()
        return
    end
    executeSpectralNuke(t, btn)
end

local function R()
    for _, item in pairs(SF:GetChildren()) do if item:IsA("TextButton") then item:Destroy() end end
    for _, p in pairs(P:GetPlayers()) do 
        if p ~= LP then
            local b = makeBtn(SF, p.Name, UDim2.new(1, 0, 0, 25), UDim2.new(0,0,0,0), Color3.fromRGB(50,50,50))
            b.TextSize = 13 
            b.MouseButton1Click:Connect(function() E(p, b) end)
        end 
    end 
    refreshPlayerColors()
end

R()
P.PlayerAdded:Connect(R)
P.PlayerRemoving:Connect(R)
