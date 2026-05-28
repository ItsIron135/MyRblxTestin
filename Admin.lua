--[[ CBM'S ADMIN PANEL ]]--
 
---------------------------------------------------------
-- SERVICES & VARIABLES
---------------------------------------------------------
local getgenv = getgenv or function() return _G end
getgenv().IsDroppingGears = false 
 
local P, LP, RS, RP, UIS = game:GetService("Players"), game:GetService("Players").LocalPlayer, game:GetService("RunService"), game:GetService("ReplicatedStorage"), game:GetService("UserInputService")
local cam, PG = workspace.CurrentCamera, LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
if PG:FindFirstChild("StealerUI") then PG.StealerUI:Destroy() end
 
---------------------------------------------------------
-- STATE
---------------------------------------------------------	
local env = getgenv()
env.desyncActive, env.fakeCF, env.realCF = env.desyncActive or false, env.fakeCF or CFrame.new(), env.realCF or CFrame.new()
 
local BoneSwordTouchLoop, renderConn, steppedConn, heartbeatConn, ghostConn, nullDesyncLoop = nil
local Flying, FlySpeed = false, 100
local NoclipActive, GhostTouchActive, GiveDroppedGearActive, IsStackingActive, isGodMode, InfSupernovaActive, isAntiStealing = false, false, false, false, false, false, false
local IsAntiLaser, AntiVoidActive, GiveAllBtn = false, true, nil
local NullDesyncActive, nullGhostOffset, nullPartOffsets, nullCamPart, nullSavedCF, nullWeldOverride = true, Vector3.new(), {}, nil, nil, nil
local NAN_POSITION = CFrame.new(9e9, 9e9, 9e9)
local KillAuraActive, KillAuraRange, KillAuraDebounces = false, 12, {}
local isSpectating, savedPlayer, originalCamSubject = false, nil, nil
local RocketSpamActive, AutoRocketEnabled, AUTO_RANGE, RocketTargets = false, false, 25, {}
local RocketLastKnownPos = {}
local SpawnCloneActive, SpawnCloneTargets = false, {}
local SKillActive, SKillTargets, SKillLoops, SKillTrackers, ActiveSKillSwords = false, {}, {}, {}, {}
local VoidKillActive, VoidKillTargets, VoidKillLoops, VoidKillTrackers, ActiveVoidKillSwords = false, {}, {}, {}, {}
local StealArmActive, StealArmTargets = false, {}
local WeldKillActive, WeldKillTargets = false, {}
local FireInterestActive, FireInterestTargets, FireInterestLoops = false, {}, {}
local AntiPickupActive, hiddenTools, antiPickupConnection, antiPickupCharConn, antiPickupBpConn = false, {}, nil, nil, nil
local allowedTools, hiddenToolsCache = {}, Instance.new("Folder")
hiddenToolsCache.Name = "AntiPickupCache"
local UsedSwords, LatestClone = {}, nil
local laserNames = {Rain=1,Beam=1,RainBeam=1,Effect=1,Center=1,Part=1,StarShard=1,["Mini-StarShard"]=1,CrimsonPillar=1,Pulse=1}
local homeCFrame = CFrame.new(0, 10, 0)
local homeTPLoop = nil
local SPAWN_COORDS = {
    Spawn1 = CFrame.new(-1312, 193, 205),
    Spawn2 = CFrame.new(-1312, 193, -23),
    Spawn3 = CFrame.new(-1155, 193, -179),
    Spawn4 = CFrame.new(-927, 193, -179),
    Spawn5 = CFrame.new(-770, 193, -22),
    Spawn6 = CFrame.new(-770, 193, 205),
    Spawn7 = CFrame.new(-927, 193, 361),
    Spawn8 = CFrame.new(-1155, 193, 361),
}
local function getHomeFromSpawnValue()
    local so = LP:FindFirstChild("Spawn")
    if so and so.Value then
        local c = SPAWN_COORDS[tostring(so.Value)]
        if c then return c end
    end
    return nil
end
 
local giveAllRunning = false
local GIVE_ALL_NORMAL_DELAY = 0.02
local GIVE_ALL_BURST_TIME = 0.05
local GIVE_ALL_BURST_AMOUNT = 60
local GIVE_ALL_REMOTES = {"SpawnRainbowBlock","SpawnDiamondBlock","SpawnSuperBlock","SpawnLuckyBlock","SpawnGalaxyBlock"}
 
---------------------------------------------------------
-- CORE UI
---------------------------------------------------------
local function set(o, t) for k,v in pairs(t) do o[k] = v end return o end
 
local SG = set(Instance.new("ScreenGui", PG), {Name="StealerUI", ResetOnSpawn=false})
local MF = set(Instance.new("Frame", SG), {Size=UDim2.new(0,240,0,610), Position=UDim2.new(0.85,-120,0.5,-200), BackgroundColor3=Color3.fromRGB(35,35,35), Active=true, Draggable=true, BorderSizePixel=0})
set(Instance.new("TextLabel", MF), {Size=UDim2.new(1,-30,0,30), BackgroundTransparency=1, Text="Admin Panel", TextColor3=Color3.new(0.9,0.9,0.9), Font=Enum.Font.Code, TextSize=14})
local CB = set(Instance.new("TextButton", MF), {Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-30,0,0), BackgroundColor3=Color3.fromRGB(150,50,50), Text="X", TextColor3=Color3.new(1,1,1)})
local SF = set(Instance.new("ScrollingFrame", MF), {Size=UDim2.new(1,0,1,-440), Position=UDim2.new(0,0,0,30), BackgroundTransparency=1, ScrollBarThickness=6, ScrollingEnabled=true, Active=true})
local UIList = Instance.new("UIListLayout", SF)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() SF.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y) end)
 
-- SPECTATE PANEL
local SP_Panel = set(Instance.new("Frame", SG), {Size=UDim2.new(0,200,0,400), Position=UDim2.new(0.5,-100,0.5,-200), BackgroundColor3=Color3.fromRGB(25,25,25), Visible=false, Active=true, Draggable=true})
Instance.new("UICorner", SP_Panel).CornerRadius = UDim.new(0,8)
set(Instance.new("TextLabel", SP_Panel), {Size=UDim2.new(1,-30,0,30), BackgroundTransparency=1, Text="PLAYER VIEWER", TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold, TextSize=14})
local SP_Close = set(Instance.new("TextButton", SP_Panel), {Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-30,0,0), BackgroundColor3=Color3.fromRGB(200,50,50), Text="X", TextColor3=Color3.new(1,1,1), BorderSizePixel=0})
local SP_Scroll = set(Instance.new("ScrollingFrame", SP_Panel), {Size=UDim2.new(1,-10,1,-45), Position=UDim2.new(0,5,0,35), BackgroundColor3=Color3.fromRGB(20,20,20), ScrollBarThickness=6, Active=true})
Instance.new("UICorner", SP_Scroll).CornerRadius = UDim.new(0,6)
local SP_List = Instance.new("UIListLayout", SP_Scroll)
SP_List.SortOrder, SP_List.Padding = Enum.SortOrder.Name, UDim.new(0,2)
 
---------------------------------------------------------
-- SPECTATE SYSTEM
---------------------------------------------------------
local function startSpectate(p)
    if not p or not p.Character then return end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if not originalCamSubject then originalCamSubject = cam.CameraSubject end
    cam.CameraSubject, isSpectating, savedPlayer = h, true, p
end
 
local function stopSpectate()
    if originalCamSubject then cam.CameraSubject = originalCamSubject end
    isSpectating = false
end
 
local function fullClearSpectate()
    stopSpectate()
    savedPlayer = nil
    originalCamSubject = nil
end
 
local function populateSpectateMenu()
    for _, c in ipairs(SP_Scroll:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= LP then
            local btn = set(Instance.new("TextButton", SP_Scroll), {Size=UDim2.new(1,-10,0,30), BackgroundColor3=(savedPlayer==p) and Color3.fromRGB(0,150,100) or Color3.fromRGB(50,50,50), Text=p.Name, TextColor3=Color3.new(1,1,1), Font=Enum.Font.Code, TextSize=13, BorderSizePixel=0})
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
            btn.MouseButton1Click:Connect(function()
                if savedPlayer == p then
                    fullClearSpectate()
                    populateSpectateMenu()
                else
                    startSpectate(p)
                    SP_Panel.Visible = false
                end
            end)
        end
    end
    SP_Scroll.CanvasSize = UDim2.new(0,0,0,SP_List.AbsoluteContentSize.Y + 5)
end
 
SP_Close.MouseButton1Click:Connect(function()
    SP_Panel.Visible = false
    if isSpectating then stopSpectate() end
end)
 
task.spawn(function()
    while true do
        if savedPlayer and isSpectating and savedPlayer.Character then
            local h = savedPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h and cam.CameraSubject ~= h then cam.CameraSubject = h end
        end
        task.wait(0.5)
    end
end)
 
---------------------------------------------------------
-- HELPERS
---------------------------------------------------------
local function refreshPlayerColors()
    for _, b in pairs(SF:GetChildren()) do
        if b:IsA("TextButton") then
            local p = P:FindFirstChild(b.Text)
            if p then
                local c = Color3.fromRGB(50,50,50)
                if RocketSpamActive and RocketTargets[p.UserId] then c = Color3.fromRGB(180,40,40)
                elseif VoidKillActive and VoidKillTargets[p] then c = Color3.fromRGB(40,150,160)
                elseif SKillActive and SKillTargets[p] then c = Color3.fromRGB(40,110,150)
                elseif SpawnCloneActive and SpawnCloneTargets[p] then c = Color3.fromRGB(40,120,40)
                elseif StealArmActive and StealArmTargets[p] then c = Color3.fromRGB(140,90,20)
                elseif WeldKillActive and WeldKillTargets[p] then c = Color3.fromRGB(180,100,40)
                elseif FireInterestActive and FireInterestTargets[p] then c = Color3.fromRGB(200,50,200) end
                b.BackgroundColor3 = c
            end
        end
    end
end
 
local function makeBtn(parent, text, size, pos, bg)
    return set(Instance.new("TextButton", parent), {Size=size, Position=pos, BackgroundColor3=bg, Text=text, TextColor3=Color3.new(0.9,0.9,0.9), Font=Enum.Font.Code, TextSize=12})
end
 
local function createToggle(col, yPos, text, activeCol, init, action)
    local btn = makeBtn(MF, text..(init and ": ON" or ": OFF"), UDim2.new(0.5,0,0,30), UDim2.new(col,0,1,yPos), init and activeCol or Color3.fromRGB(50,50,50))
    btn.TextSize = 11
    btn.MouseButton1Click:Connect(function()
        local s = action()
        btn.Text, btn.BackgroundColor3 = text..(s and ": ON" or ": OFF"), s and activeCol or Color3.fromRGB(50,50,50)
    end)
    return btn
end
 
local function hideTool(t)
    if t:IsA("Tool") and t.Parent and not t.Parent:FindFirstChild("Humanoid") and not t.Parent:IsA("Backpack") then
        hiddenTools[t], t.Parent = t.Parent, hiddenToolsCache 
    end
end
 
local function restoreTools()
    for t, p in pairs(hiddenTools) do if t then pcall(function() t.Parent = p or workspace end) end end
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
                    local h = sword:FindFirstChild("Handle"); if h then h.Massless = false end
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
        if part:IsA("BasePart") then part.Massless, part.CanCollide, part.CustomPhysicalProperties = true, false, PhysicalProperties.new(0,0,0,0,0) end
    end
    local handle, rightArm = tool:FindFirstChild("Handle"), char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
    if handle and rightArm then
        tool.RequiresHandle = true 
        local n = tPlayer.Name
        if loopsMap[n] then loopsMap[n]:Disconnect() end
        loopsMap[n] = RS.Heartbeat:Connect(function()
            local tTargetPart = tPlayer.Character and tPlayer.Character:FindFirstChild("Torso")
            if not tTargetPart then return end 
            if tool.Parent == LP:FindFirstChild("Backpack") then tool.Parent = char end
            if tool.Parent == char and handle then
                local grip
                for _, j in pairs(rightArm:GetChildren()) do if j.Name == "RightGrip" and j.Part1 == handle then grip = j; break end end
                if grip then 
                    local predCF = tTargetPart.CFrame + (tTargetPart.AssemblyLinearVelocity * 0.08)
                    grip.C1 = predCF:Inverse() * rightArm.CFrame * grip.C0 
                end
            end
        end)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then for _, t in pairs(hum:GetPlayingAnimationTracks()) do if t.Name:lower():find("tool") or (t.Animation and tostring(t.Animation.AnimationId):find("507768375")) then t:Stop() end end end
    end
end
 
local function toggleTargetSkill(btn, t, swordName, targetMap, loopMap, trackerMap, activeMap)
    if targetMap[t] then
        clearToolTargets({[t]=true}, loopMap, trackerMap, activeMap); targetMap[t] = nil
    else
        local bp, char = LP:FindFirstChild("Backpack"), LP.Character
        local sword, allSwords = nil, {}
        if char then for _, o in pairs(char:GetChildren()) do if o.Name == swordName then table.insert(allSwords, o) end end end
        if bp then for _, o in pairs(bp:GetChildren()) do if o.Name == swordName then table.insert(allSwords, o) end end end
        for _, s in pairs(allSwords) do if not activeMap[s] then sword = s; break end end
        if sword then
            targetMap[t], activeMap[sword], sword.Parent = true, t, char 
            attachTool(t, sword, loopMap)
            trackerMap[t.Name] = t.CharacterAdded:Connect(function() if sword and sword.Parent == char then attachTool(t, sword, loopMap) end end)
        else
            local old = btn.Text
            btn.Text, btn.BackgroundColor3 = "NO "..swordName:upper(), Color3.fromRGB(150,40,40)
            task.delay(1, function() if btn and btn.Parent and not targetMap[t] then btn.Text = old; refreshPlayerColors() end end)
        end
    end
end
 
local function consistentWeldTPGive(tp)
    local root = LP.Character and (LP.Character:FindFirstChild("HumanoidRootPart") or LP.Character:FindFirstChild("Torso"))
    local targetTorso = tp.Character and tp.Character:FindFirstChild("Torso")
    if not root or not targetTorso then return end
    local gears, welds, originalCFrame = {}, {}, root.CFrame
    for _, item in ipairs(workspace:GetChildren()) do
        if item:IsA("Tool") then
            local h = item:FindFirstChild("Handle")
            if h and h:IsA("BasePart") then
                h.Anchored, h.CanCollide, h.Massless, h.CFrame = false, false, true, root.CFrame
                local w = Instance.new("WeldConstraint"); w.Part0, w.Part1, w.Parent = root, h, root
                table.insert(gears, h); table.insert(welds, w)
            end
        end
    end
    if #gears == 0 then return end
    task.spawn(function()
        local s = tick()
        while tick() - s < 1.5 do
            if root and targetTorso and targetTorso.Parent then root.CFrame = targetTorso.CFrame end
            RS.Heartbeat:Wait()
        end
        for _, w in ipairs(welds) do if w then w:Destroy() end end
        if root then root.CFrame = originalCFrame end
    end)
end
 
local function executeSpectralNuke(t, btn)
    local c = LP.Character
    local h, hrp = c and c:FindFirstChild("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
    local targetTorso = t.Character and t.Character:FindFirstChild("Torso")
    if not c or not h or not hrp or not targetTorso then return end
    local bp = LP:WaitForChild("Backpack")
    local eS = bp:FindFirstChild("EnergySword") or c:FindFirstChild("EnergySword")
    local sS
    for _, i in ipairs(bp:GetChildren()) do if i.Name == "SpectralSword" and not UsedSwords[i] then sS = i; break end end
    if not sS then for _, i in ipairs(c:GetChildren()) do if i.Name == "SpectralSword" and not UsedSwords[i] then sS = i; break end end end
    if not eS or not sS then 
        local old = btn.Text
        btn.Text, btn.BackgroundColor3 = "NO SWORDS!", Color3.fromRGB(150,40,40)
        task.delay(1, function() if btn and btn.Parent then btn.Text = old; refreshPlayerColors() end end)
        return 
    end
    local kd, originalCFrame = sS:FindFirstChild("KeyDown"), hrp.CFrame 
    UsedSwords[sS], eS.Parent, sS.Parent = true, c, c
    local startTime, lastSpam, conn = tick(), 0, nil
    conn = RS.Heartbeat:Connect(function()
        local now = tick()
        if (now - startTime) < 1 and hrp and targetTorso and targetTorso.Parent then
            hrp.CFrame = targetTorso.CFrame * CFrame.new(0,0,4) * CFrame.Angles(0, math.pi, 0)
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
 
local function giveAllFireOnce()
    for _, n in ipairs(GIVE_ALL_REMOTES) do
        local e = RP:FindFirstChild(n)
        if e then pcall(function() e:FireServer() end) end
    end
end
 
local function giveAllFindCarrot()
    local char, bp = LP.Character, LP:FindFirstChild("Backpack")
    if bp then local c = bp:FindFirstChild("Carrot"); if c then return c end end
    if char then local c = char:FindFirstChild("Carrot"); if c then return c end end
    return nil
end
 
local function runGiveAll()
    if giveAllRunning then return end
    if not GiveAllBtn then return end
    giveAllRunning = true
    local origText, origColor = "Give All", Color3.fromRGB(50,50,50)
    GiveAllBtn.Text = "WAITING CARROT..."
    GiveAllBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 0)
 
    task.spawn(function()
        while giveAllRunning do
            giveAllFireOnce()
            if giveAllFindCarrot() then break end
            task.wait(GIVE_ALL_NORMAL_DELAY)
        end
 
        if not giveAllRunning then return end
 
        GiveAllBtn.Text = "EATING..."
        local carrot = giveAllFindCarrot()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if carrot and hum then
            hum:UnequipTools()
            task.wait(0.05)
            hum:EquipTool(carrot)
            task.wait(0.1)
            pcall(function() carrot:Activate() end)
            task.wait(0.1)
            hum:UnequipTools()
        end
 
        if not giveAllRunning then return end
 
        GiveAllBtn.Text = "BURST..."
        GiveAllBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        local burstConn
        burstConn = RS.Heartbeat:Connect(function()
            if not giveAllRunning then return end
            for _, n in ipairs(GIVE_ALL_REMOTES) do
                local e = RP:FindFirstChild(n)
                if e then
                    for i = 1, GIVE_ALL_BURST_AMOUNT do
                        task.spawn(function() pcall(function() e:FireServer() end) end)
                    end
                end
            end
        end)
        task.wait(GIVE_ALL_BURST_TIME)
        if burstConn then burstConn:Disconnect() end
 
        giveAllRunning = false
        if GiveAllBtn and GiveAllBtn.Parent then
            GiveAllBtn.Text = origText
            GiveAllBtn.BackgroundColor3 = origColor
        end
    end)
end
 
---------------------------------------------------------
-- NULL DESYNC
---------------------------------------------------------
local function stopNullDesync()
    NullDesyncActive, nullWeldOverride = false, nil
    if nullDesyncLoop then nullDesyncLoop:Disconnect(); nullDesyncLoop = nil end 
    if nullCamPart then nullCamPart:Destroy(); nullCamPart = nil end
    workspace.FallenPartsDestroyHeight = AntiVoidActive and -9e9 or -500
    local char = LP.Character
    local hum, root = char and char:FindFirstChildOfClass("Humanoid"), char and char:FindFirstChild("HumanoidRootPart")
    if char and hum and root then 
        hum.CameraOffset, cam.CameraSubject = Vector3.new(), hum
        for _, v in pairs(char:GetDescendants()) do 
            if v:IsA("Motor6D") then v.Enabled = true end 
            if v:IsA("BasePart") then v.Massless = false; if v.Name ~= "HumanoidRootPart" then v.CanCollide = true end end 
        end 
        hum.PlatformStand = Flying
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) 
        hum:ChangeState(Enum.HumanoidStateType.GettingUp) 
        if nullSavedCF then root.CFrame, root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = nullSavedCF, Vector3.new(), Vector3.new() end 
    end 
    nullPartOffsets = {} 
end
 
local function startNullDesync(char)
    if not NullDesyncActive then return end
    local root, hum = char and char:FindFirstChild("HumanoidRootPart"), char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end 
    if nullDesyncLoop then nullDesyncLoop:Disconnect() end
    workspace.FallenPartsDestroyHeight = -9e9
    nullSavedCF, nullGhostOffset, nullWeldOverride = nullSavedCF or root.CFrame, Vector3.new(), nil
    hum.PlatformStand = true 
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) 
    nullPartOffsets = {}
    if nullCamPart then nullCamPart:Destroy() end
    nullCamPart = set(Instance.new("Part"), {Transparency=1, CanCollide=false, Anchored=true, Size=Vector3.new(1,1,1), CFrame=nullSavedCF, Parent=workspace.CurrentCamera})
    cam.CameraSubject = nullCamPart
    getgenv().NaN_CamPart = nullCamPart 
    for _, v in pairs(char:GetDescendants()) do 
        if v:IsA("TouchTransmitter") then v:Destroy() end
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then  
            nullPartOffsets[v] = root.CFrame:ToObjectSpace(v.CFrame)
            v.Massless, v.CanCollide = true, false
        end 
    end 
    for _, v in pairs(char:GetDescendants()) do if v:IsA("Motor6D") then v.Enabled = false end end
    nullDesyncLoop = RS.Heartbeat:Connect(function(dt) 
        local currentRoot = char:FindFirstChild("HumanoidRootPart")
        if not char or not currentRoot or not nullCamPart then return end 
        if getgenv().IsDroppingGears then return end
        local lookCF, moveDir = cam.CFrame, Vector3.new()
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += lookCF.LookVector end 
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= lookCF.LookVector end 
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= lookCF.RightVector end 
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += lookCF.RightVector end 
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
        if moveDir.Magnitude > 0 then nullGhostOffset += (moveDir.Unit * (FlySpeed * dt)) end 
        local ghostRootCF = CFrame.new(nullSavedCF.Position + nullGhostOffset) * lookCF.Rotation 
        nullCamPart.CFrame = ghostRootCF
        for part, offset in pairs(nullPartOffsets) do 
            if part and part.Parent then part.CFrame, part.AssemblyLinearVelocity, part.AssemblyAngularVelocity = ghostRootCF * offset, Vector3.new(), Vector3.new() end
        end 
        currentRoot.CFrame = nullWeldOverride or NAN_POSITION
    end)
end
 
---------------------------------------------------------
-- ROCKET SPAM & DESYNC
---------------------------------------------------------
local ROCKET_MULTIPLIER = 3 -- How many times to fire PER launcher, PER frame. (Increase if you want it even faster!)
 
local function fireRocketAt(pos)
    local char, bp = LP.Character, LP:FindFirstChild("Backpack")
    local launchers = {}
    
    -- 1. Gather ALL RocketJumpers in the Character (Equipped)
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool.Name == "RocketJumper" and tool:FindFirstChild("FireRocket") then
                table.insert(launchers, tool.FireRocket)
            end
        end
    end
    
    -- 2. Gather ALL RocketJumpers in the Backpack (Unequipped)
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool.Name == "RocketJumper" and tool:FindFirstChild("FireRocket") then
                table.insert(launchers, tool.FireRocket)
            end
        end
    end
    
    -- 3. Fire every single launcher multiple times instantly
    local targetPos2 = pos + Vector3.new(0.002, 0.002, 0.002)
    for _, FR in ipairs(launchers) do
        for i = 1, ROCKET_MULTIPLIER do
            -- Using task.spawn prevents the loop from yielding if the remote takes a microsecond to process
            task.spawn(function()
                pcall(function()
                    FR:FireServer(pos, targetPos2)
                end)
            end)
        end
    end
end
 
task.spawn(function()
    while true do
        for uid, a in pairs(RocketTargets) do
            if a then
                local tp = P:GetPlayerByUserId(uid)
                if tp then
                    local tTorso = tp.Character and tp.Character:FindFirstChild("Torso")
                    if tTorso then
                        RocketLastKnownPos[uid] = tTorso.Position
                        fireRocketAt(tTorso.Position)
                    elseif RocketLastKnownPos[uid] then
                        fireRocketAt(RocketLastKnownPos[uid])
                    end
                end
            end
        end
        if AutoRocketEnabled then
            local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                for _, p in ipairs(P:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local hum, tt = p.Character:FindFirstChildOfClass("Humanoid"), p.Character:FindFirstChild("Torso")
                        if hum and hum.Health > 0 and tt then
                            local d = (tt.Position - myRoot.Position).Magnitude
                            if d <= AUTO_RANGE and d >= 6 then
                                local holding = false
                                for _, o in ipairs(p.Character:GetChildren()) do if o:IsA("Tool") and o:FindFirstChild("Handle") then holding = true; break end end
                                if holding then fireRocketAt(tt.Position) end
                            end
                        end
                    end
                end
            end
        end
        task.wait()
    end
end)
 
local function stopDesync()
    if renderConn then renderConn:Disconnect(); renderConn = nil end
    if steppedConn then steppedConn:Disconnect(); steppedConn = nil end
    if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn = nil end
    pcall(function() RS:UnbindFromRenderStep("DesyncCameraFix") end)
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if root then 
        root.CFrame = env.realCF 
        for _, i in ipairs(root:GetChildren()) do if i:IsA("BodyGyro") or i:IsA("BodyPosition") then i:Destroy() end end
    end
end
 
---------------------------------------------------------
-- KEYBINDS
---------------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.X then
        runGiveAll()
    elseif input.KeyCode == Enum.KeyCode.RightBracket then
        if SP_Panel.Visible then
            SP_Panel.Visible = false
            if isSpectating then stopSpectate() end
        else
            SP_Panel.Visible = true
            populateSpectateMenu()
            if savedPlayer and savedPlayer.Parent and savedPlayer.Character and not isSpectating then
                startSpectate(savedPlayer)
            end
        end
    elseif input.KeyCode == Enum.KeyCode.LeftBracket then
        local char, bp = LP.Character, LP:FindFirstChild("Backpack")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char and bp and hum then
            local equipped = char:FindFirstChild("BoneSword")
            if equipped then
                equipped.Parent = bp
                if BoneSwordTouchLoop then BoneSwordTouchLoop:Disconnect(); BoneSwordTouchLoop = nil; print("[BONESWORD] Touch stopped") end
            else
                local unequipped = bp:FindFirstChild("BoneSword")
                if unequipped then 
                    hum:EquipTool(unequipped)
                    if BoneSwordTouchLoop then BoneSwordTouchLoop:Disconnect() end
                    BoneSwordTouchLoop = RS.Heartbeat:Connect(function()
                        local cc = LP.Character
                        if not cc then return end
                        local bs = cc:FindFirstChild("BoneSword")
                        if not bs then if BoneSwordTouchLoop then BoneSwordTouchLoop:Disconnect(); BoneSwordTouchLoop = nil end return end
                        local handle = bs:FindFirstChild("Handle")
                        if not handle then return end
                        for _, p in pairs(P:GetPlayers()) do
                            if p ~= LP and p.Character then
                                local tp = p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("HumanoidRootPart")
                                if tp then pcall(function() firetouchinterest(handle, tp, 0); task.wait(); firetouchinterest(handle, tp, 1) end) end
                            end
                        end
                    end)
                    print("[BONESWORD] Touch started on all players")
                end
            end
        end
    end
end)
 
---------------------------------------------------------
-- KILL AURA
---------------------------------------------------------
RS.Heartbeat:Connect(function()
    if not KillAuraActive then return end
    local char = LP.Character
    local myTorso = char and char:FindFirstChild("Torso") 
    local bp = LP:FindFirstChild("Backpack")
    if not myTorso or not char then return end
    for _, p in pairs(P:GetPlayers()) do
        if p ~= LP and p.Character then
            local tt = p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("UpperTorso")
            local th = p.Character:FindFirstChildOfClass("Humanoid")
            if tt and th and th.Health > 0 and (myTorso.Position - tt.Position).Magnitude <= KillAuraRange then
                if not KillAuraDebounces[p] then
                    KillAuraDebounces[p] = true
                    local equipped = 0
                    for _, t in ipairs(char:GetChildren()) do if t.Name == "TriLaserGun" then equipped += 1 end end
                    if bp and equipped < 2 then
                        for _, tool in ipairs(bp:GetChildren()) do
                            if tool.Name == "TriLaserGun" then tool.Parent = char; equipped += 1; if equipped >= 2 then break end end
                        end
                    end
                    tt.Anchored = true
                    task.delay(0.1, function()
                        for _, g in ipairs(char:GetChildren()) do
                            if g.Name == "TriLaserGun" and g:FindFirstChild("Click") then g.Click:FireServer(tt.Position) end
                        end
                        task.delay(0.5, function()
                            if tt then tt.Anchored = false end
                            KillAuraDebounces[p] = false
                            local cbp = LP:FindFirstChild("Backpack")
                            if char and cbp then for _, t in ipairs(char:GetChildren()) do if t.Name == "TriLaserGun" then t.Parent = cbp end end end
                        end)
                    end)
                end
            end
        end
    end
end)
 
---------------------------------------------------------
-- UI LAYOUT
---------------------------------------------------------
makeBtn(MF, "TP To Void", UDim2.new(0.5,0,0,30), UDim2.new(0,0,1,-390), Color3.fromRGB(70,40,70)).MouseButton1Click:Connect(function()
    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local targetCF = CFrame.new(-1050, -490, 90)
    local tf = set(Instance.new("Part", workspace), {Size=Vector3.new(200,5,200), CFrame=targetCF * CFrame.new(0,-4,0), Anchored=true, Transparency=1})
    game:GetService("Debris"):AddItem(tf, 10)
    if r then 
        if env.desyncActive then env.fakeCF, env.realCF = targetCF, targetCF
        elseif NullDesyncActive then nullSavedCF = targetCF
        else r.CFrame = targetCF end
    end
end)
 
createToggle(0, -360, "Fly", Color3.fromRGB(40,100,150), false, function()
    Flying = not Flying
    local char = LP.Character
    local root, hum = char and char:FindFirstChild("HumanoidRootPart"), char and char:FindFirstChildOfClass("Humanoid")
    if env.desyncActive or NullDesyncActive then
        if hum then hum.PlatformStand = Flying end
    else
        if Flying and root and hum then
            local bv = set(Instance.new("BodyVelocity", root), {Name="FlyVelocity", MaxForce=Vector3.new(9e9,9e9,9e9), Velocity=Vector3.new()})
            local bg = set(Instance.new("BodyGyro", root), {Name="FlyGyro", MaxTorque=Vector3.new(9e9,9e9,9e9), P=9e4, CFrame=root.CFrame})
            task.spawn(function()
                while Flying and root and root.Parent do
                    local dir = hum.MoveDirection 
                    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
                    bv.Velocity = dir.Magnitude > 0 and (dir.Unit * FlySpeed) or Vector3.new()
                    bg.CFrame = cam.CFrame
                    task.wait()
                end
                if bv then bv:Destroy() end; if bg then bg:Destroy() end
            end)
        else if hum then hum.PlatformStand = false end end
    end
    return Flying
end)
 
createToggle(0, -330, "Give Gear", Color3.fromRGB(120,80,40), false, function() GiveDroppedGearActive = not GiveDroppedGearActive; return GiveDroppedGearActive end)
 
createToggle(0, -300, "Perm Desync", Color3.fromRGB(40,100,150), false, function()
    env.desyncActive = not env.desyncActive
    local char = LP.Character
    local root, hum = char and char:FindFirstChild("HumanoidRootPart"), char and char:FindFirstChildOfClass("Humanoid")
    if not char or not root or not hum then return env.desyncActive end
    if not env.desyncActive then stopDesync(); return env.desyncActive end
    if root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
    if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
    do
        local carpet = (LP:FindFirstChild("Backpack") and LP.Backpack:FindFirstChild("RainbowMagicCarpet")) or char:FindFirstChild("RainbowMagicCarpet")
        if carpet then hum:EquipTool(carpet); task.wait(0.1); carpet:Activate(); task.wait(0.05); hum:UnequipTools() end
    end
    env.fakeCF, env.realCF = root.CFrame, root.CFrame 
    if Flying then hum.PlatformStand = true end
    RS:BindToRenderStep("DesyncCameraFix", Enum.RenderPriority.Camera.Value - 1, function() if root then root.CFrame = env.realCF end end)
    steppedConn = RS.Stepped:Connect(function() if root then root.CFrame = env.realCF end end)
    heartbeatConn = RS.Heartbeat:Connect(function(dt)
        if not root then return end
        local sChar
        for t, a in pairs(StealArmTargets) do if a and t.Character then sChar = t.Character; break end end
        if sChar then
            local tArm = sChar:FindFirstChild("Left Arm") or sChar:FindFirstChild("LeftLowerArm") or sChar:FindFirstChild("LeftHand")
            if tArm then env.realCF = CFrame.new(tArm.Position) * cam.CFrame.Rotation * CFrame.new(-1.5,0,0) end
        end
        if Flying then
            local lookCF, moveDir = cam.CFrame, Vector3.new()
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += lookCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= lookCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= lookCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += lookCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
            local cp = env.realCF.Position
            if moveDir.Magnitude > 0 then cp = cp + (moveDir.Unit * (FlySpeed * dt)) end
            env.realCF = CFrame.new(cp) * lookCF.Rotation
            root.AssemblyLinearVelocity, root.AssemblyAngularVelocity = Vector3.new(), Vector3.new()
        else if not sChar then env.realCF = root.CFrame end end
        root.CFrame = env.fakeCF 
    end)
    return env.desyncActive
end)
 
createToggle(0, -270, "Null Desync", Color3.fromRGB(200,50,50), true, function()
    NullDesyncActive = not NullDesyncActive
    if NullDesyncActive then
        nullSavedCF = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.CFrame
        startNullDesync(LP.Character)
    else stopNullDesync() end
    return NullDesyncActive
end)
 
createToggle(0, -240, "Ghost Touch", Color3.fromRGB(150,80,20), false, function() 
    GhostTouchActive = not GhostTouchActive
    local target, root = LatestClone or workspace:FindFirstChild(LP.Name .. "'s Clone"), LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if GhostTouchActive and target and root then
        local ct = target:FindFirstChild("EnergySword")
        if ct then
            local handle = ct:FindFirstChild("Handle")
            if handle then
                for _, j in ipairs(target:GetDescendants()) do
                    if (j:IsA("JointInstance") or j:IsA("WeldConstraint")) and (j.Part0 == handle or j.Part1 == handle) then j:Destroy() end
                end
                for _, p in ipairs(ct:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide, p.Massless = false, true end end
                if ghostConn then ghostConn:Disconnect() end
                ghostConn = RS.Heartbeat:Connect(function()
                    if handle and handle.Parent and root and root.Parent then
                        handle.CFrame = root.CFrame * CFrame.Angles(math.random(-10,10), math.random(-10,10), math.random(-10,10))
                    else if ghostConn then ghostConn:Disconnect(); ghostConn = nil end end
                end)
            end
        else GhostTouchActive = false end
    else if ghostConn then ghostConn:Disconnect(); ghostConn = nil end end
    return GhostTouchActive 
end)
 
createToggle(0, -210, "Inf Stack", Color3.fromRGB(100,40,100), false, function()
    IsStackingActive = not IsStackingActive
    local char, bp = LP.Character, LP:FindFirstChild("Backpack")
    local carrot = (bp and bp:FindFirstChild("Carrot")) or (char and char:FindFirstChild("Carrot"))
    if IsStackingActive and carrot and char and char:FindFirstChild("Humanoid") then
        char.Humanoid:EquipTool(carrot); task.wait(0.1); carrot:Activate(); task.wait(0.1); char.Humanoid:UnequipTools()
    end
    return IsStackingActive
end)
 
GiveAllBtn = makeBtn(MF, "Give All", UDim2.new(0.5,0,0,30), UDim2.new(0,0,1,-180), Color3.fromRGB(50,50,50))
GiveAllBtn.TextSize = 11
GiveAllBtn.MouseButton1Click:Connect(runGiveAll)
 
local GodBtn = makeBtn(MF, "God Mode", UDim2.new(0.5,0,0,30), UDim2.new(0,0,1,-150), Color3.fromRGB(50,50,50)); GodBtn.TextSize = 11
local function activateGodMode()
    if isGodMode then return end
    isGodMode = true
    task.spawn(function()
        local char, bp = LP.Character, LP:FindFirstChild("Backpack")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not bp or not hum then isGodMode = false; return end
        local carrot = bp:FindFirstChild("Carrot") or char:FindFirstChild("Carrot")
        if carrot then hum:UnequipTools(); carrot.Parent = char; task.wait(0.05); carrot:Activate(); task.wait(0.1); hum:UnequipTools() end
        GodBtn.Text, GodBtn.BackgroundColor3 = "SEQUENTIAL LOOP...", Color3.fromRGB(180,80,0)
        local startTime, lastSkin = tick(), nil
        while tick() - startTime < 10 do
            if not char.Parent then break end 
            local nO = bp:FindFirstChild("OverseerwrathSword")
            if nO then nO.Parent = char; task.wait(0.05) end
            local nS = bp:FindFirstChild("TigerSkin")
            if nS then lastSkin = nS; nS.Parent = char; task.wait(0.05); nS:Activate(); task.wait(0.05) end
            if not nO and not nS then task.wait(0.1) end
        end
        GodBtn.Text = "WIPING HANDS..."; hum:UnequipTools(); task.wait(0.4) 
        GodBtn.Text, GodBtn.BackgroundColor3 = "MULTI-HOLDING...", Color3.fromRGB(200,0,0)
        local final = {}
        for _, t in ipairs(bp:GetChildren()) do if t.Name == "OverseerwrathSword" then table.insert(final, t) end end
        if lastSkin and lastSkin.Parent == bp then table.insert(final, lastSkin) end
        for _, t in ipairs(final) do t.Parent = char end
        task.wait(0.05) 
        for _, t in ipairs(final) do t.Parent = bp end
        GodBtn.Text, GodBtn.BackgroundColor3 = "GOD MODE ACTIVE!", Color3.fromRGB(40,150,40)
        task.wait(2)
        GodBtn.Text, GodBtn.BackgroundColor3 = "God Mode", Color3.fromRGB(50,50,50)
        isGodMode = false
    end)
end
GodBtn.MouseButton1Click:Connect(activateGodMode)
 
local PeriBtn = makeBtn(MF, "Peri Laser", UDim2.new(0.5,0,0,30), UDim2.new(0,0,1,-120), Color3.fromRGB(50,50,50)); PeriBtn.TextSize = 11
PeriBtn.MouseButton1Click:Connect(function()
    local pth = workspace:FindFirstChild(LP.Name) 
    if pth and pth:FindFirstChild("RainbowPeriastron") and pth.RainbowPeriastron:FindFirstChild("Server") and pth.RainbowPeriastron.Server:FindFirstChild("RainBeam") then
        local ls = pth.RainbowPeriastron.Server.RainBeam:FindFirstChild("LoopSound")
        if ls then ls:Destroy() end
    end
    local tool = (LP.Character and LP.Character:FindFirstChild("RainbowPeriastron")) or (LP:FindFirstChild("Backpack") and LP.Backpack:FindFirstChild("RainbowPeriastron"))
    if tool and tool:FindFirstChild("Remote") then tool.Remote:FireServer(Enum.KeyCode.Q) end
end)
 
local HatDropBtn = makeBtn(MF, "Hat Drop", UDim2.new(0.5,0,0,30), UDim2.new(0,0,1,-90), Color3.fromRGB(50,50,50)); HatDropBtn.TextSize = 11
HatDropBtn.MouseButton1Click:Connect(function()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        local clone = hum:Clone()
        hum:Destroy()
        clone.Parent = char
        if NullDesyncActive and nullCamPart then
            cam.CameraSubject = nullCamPart
        else
            cam.CameraSubject = clone
        end
        local oldTxt, oldCol = HatDropBtn.Text, HatDropBtn.BackgroundColor3
        HatDropBtn.Text, HatDropBtn.BackgroundColor3 = "DROPPED!", Color3.fromRGB(0,150,255)
        task.delay(1, function() if HatDropBtn and HatDropBtn.Parent then HatDropBtn.Text, HatDropBtn.BackgroundColor3 = oldTxt, oldCol end end)
    else
        local oldTxt, oldCol = HatDropBtn.Text, HatDropBtn.BackgroundColor3
        HatDropBtn.Text, HatDropBtn.BackgroundColor3 = "NO HUMANOID", Color3.fromRGB(150,40,40)
        task.delay(1, function() if HatDropBtn and HatDropBtn.Parent then HatDropBtn.Text, HatDropBtn.BackgroundColor3 = oldTxt, oldCol end end)
    end
end)
 
local function getHighlightedPlayers()
    local set = {}
    for uid, a in pairs(RocketTargets) do if a then local p = P:GetPlayerByUserId(uid); if p then set[p] = true end end end
    for p, _ in pairs(VoidKillTargets) do set[p] = true end
    for p, _ in pairs(SKillTargets) do set[p] = true end
    for p, _ in pairs(SpawnCloneTargets) do set[p] = true end
    for p, _ in pairs(StealArmTargets) do set[p] = true end
    for p, _ in pairs(WeldKillTargets) do set[p] = true end
    for p, _ in pairs(FireInterestTargets) do set[p] = true end
    local list = {}
    for p, _ in pairs(set) do table.insert(list, p) end
    return list
end
 
local function applyFireInterestToPlayer(t)
    if FireInterestTargets[t] then return end
    FireInterestTargets[t] = true
    if FireInterestLoops[t.Name] then FireInterestLoops[t.Name]:Disconnect() end
    FireInterestLoops[t.Name] = RS.Heartbeat:Connect(function()
        if not FireInterestTargets[t] then if FireInterestLoops[t.Name] then FireInterestLoops[t.Name]:Disconnect(); FireInterestLoops[t.Name] = nil end return end
        local char = LP.Character; if not char then return end
        local heldTool = char:FindFirstChildOfClass("Tool"); if not heldTool then return end
        local handle = heldTool:FindFirstChild("Handle"); if not handle then return end
        local tc = t.Character; if not tc then return end
        local tp = tc:FindFirstChild("Torso") or tc:FindFirstChild("HumanoidRootPart"); if not tp then return end
        pcall(function() firetouchinterest(handle, tp, 0); task.wait(); firetouchinterest(handle, tp, 1) end)
    end)
end
 
createToggle(0, -60, "Kill Aura", Color3.fromRGB(255,50,50), false, function()
    KillAuraActive = not KillAuraActive
    if not KillAuraActive then
        for plr, _ in pairs(KillAuraDebounces) do
            if plr and plr.Character and plr.Character:FindFirstChild("Torso") then plr.Character.Torso.Anchored = false end
        end
        table.clear(KillAuraDebounces)
    end
    return KillAuraActive
end)
createToggle(0, -30, "R-Spam", Color3.fromRGB(150,30,30), false, function() 
    RocketSpamActive = not RocketSpamActive
    if not RocketSpamActive then 
        table.clear(RocketTargets); table.clear(RocketLastKnownPos) 
    else
        for _, p in ipairs(getHighlightedPlayers()) do RocketTargets[p.UserId] = true end
    end
    refreshPlayerColors()
    return RocketSpamActive 
end)
createToggle(0, 0, "S-Kill", Color3.fromRGB(40,110,150), false, function() 
    SKillActive = not SKillActive
    if not SKillActive then 
        clearToolTargets(SKillTargets, SKillLoops, SKillTrackers, ActiveSKillSwords) 
    else
        for _, p in ipairs(getHighlightedPlayers()) do
            if not SKillTargets[p] then
                local fakeBtn = {Text="", BackgroundColor3=Color3.new(), Parent=SF}
                toggleTargetSkill(fakeBtn, p, "BoneSword", SKillTargets, SKillLoops, SKillTrackers, ActiveSKillSwords)
            end
        end
    end
    refreshPlayerColors()
    return SKillActive 
end)
 
local THB = makeBtn(MF, "TP Home", UDim2.new(0.5,0,0,30), UDim2.new(0.5,0,1,-390), Color3.fromRGB(40,70,40))
THB.MouseButton1Click:Connect(function()
    local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if r then
        local thc = homeCFrame
        if thc then 
            if env.desyncActive then env.fakeCF, env.realCF = thc, thc
            elseif NullDesyncActive then nullSavedCF = thc
            else r.CFrame = thc end
        else
            local old = THB.Text
            THB.Text, THB.BackgroundColor3 = "NO HOME!", Color3.fromRGB(150,40,40)
            task.delay(1, function() if THB.Parent then THB.Text, THB.BackgroundColor3 = old, Color3.fromRGB(40,70,40) end end)
        end
    end
end)
 
createToggle(0.5, -360, "Noclip", Color3.fromRGB(120,40,120), false, function() NoclipActive = not NoclipActive; return NoclipActive end)
createToggle(0.5, -330, "Spawn Clone", Color3.fromRGB(40,120,40), false, function() SpawnCloneActive = not SpawnCloneActive; if not SpawnCloneActive then table.clear(SpawnCloneTargets) end; refreshPlayerColors(); return SpawnCloneActive end)
 
local TPCloneBtn = makeBtn(MF, "TP Clone", UDim2.new(0.5,0,0,30), UDim2.new(0.5,0,1,-300), Color3.fromRGB(50,50,50)); TPCloneBtn.TextSize = 11
TPCloneBtn.MouseButton1Click:Connect(function()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local tc = LatestClone or workspace:FindFirstChild(LP.Name .. "'s Clone")
    if root and tc then
        local cT = tc:FindFirstChild("Torso") or tc:FindFirstChild("UpperTorso") or tc:FindFirstChild("HumanoidRootPart")
        if cT then
            local topCF = cT.CFrame + Vector3.new(0,3,0)
            if env.desyncActive then env.realCF = topCF elseif NullDesyncActive then nullSavedCF = topCF else root.CFrame = topCF end
            task.wait(0.3)
            local VOID_CF = CFrame.new(-800, 340, -650)
            task.spawn(function()
                for i = 1, 20 do
                    if cT and cT.Parent and root then
                        cT.CFrame = VOID_CF
                        if env.desyncActive then env.realCF = VOID_CF + Vector3.new(0,3,0) elseif NullDesyncActive then nullSavedCF = VOID_CF + Vector3.new(0,3,0) else root.CFrame = VOID_CF + Vector3.new(0,3,0) end
                    end
                    RS.Heartbeat:Wait()
                end
            end)
        end
    end
end)
 
createToggle(0.5, -270, "Anti-Pickup", Color3.fromRGB(40,120,40), false, function()
    AntiPickupActive = not AntiPickupActive
    if AntiPickupActive then
        local char, bp = LP.Character, LP:FindFirstChild("Backpack")
        allowedTools = {}
        if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then allowedTools[t] = true end end end
        if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") then allowedTools[t] = true end end end
        for _, o in ipairs(workspace:GetDescendants()) do hideTool(o) end
        task.spawn(function() while AntiPickupActive do task.wait(0.05); for _, o in ipairs(workspace:GetChildren()) do hideTool(o) end end end)
        antiPickupConnection = workspace.DescendantAdded:Connect(function(o) if AntiPickupActive then task.wait(0.05); hideTool(o) end end)
        local function handleNewGear(item)
            if not AntiPickupActive then return end
            if item:IsA("Tool") and not allowedTools[item] then task.defer(function() if item and item.Parent then item.Parent = hiddenToolsCache end end) end
        end
        if char then antiPickupCharConn = char.ChildAdded:Connect(handleNewGear) end
        if bp then antiPickupBpConn = bp.ChildAdded:Connect(handleNewGear) end
    else
        if antiPickupConnection then antiPickupConnection:Disconnect(); antiPickupConnection = nil end
        if antiPickupCharConn then antiPickupCharConn:Disconnect(); antiPickupCharConn = nil end
        if antiPickupBpConn then antiPickupBpConn:Disconnect(); antiPickupBpConn = nil end
        table.clear(allowedTools)
        restoreTools()
    end
    return AntiPickupActive
end)
 
createToggle(0.5, -240, "Anti-Void", Color3.fromRGB(40,120,120), true, function() AntiVoidActive = not AntiVoidActive; workspace.FallenPartsDestroyHeight = AntiVoidActive and -9e9 or (NullDesyncActive and -9e9 or -500); return AntiVoidActive end)
createToggle(0.5, -210, "Steal Arm", Color3.fromRGB(140,90,20), false, function() 
    StealArmActive = not StealArmActive
    if not StealArmActive then 
        table.clear(StealArmTargets) 
    else
        local hl = getHighlightedPlayers()
        if hl[1] then 
            StealArmTargets[hl[1]] = true
            task.delay(0.2, function() if StealArmTargets[hl[1]] then StealArmTargets[hl[1]] = nil; refreshPlayerColors() end end)
        end
    end
    refreshPlayerColors()
    return StealArmActive 
end)
 
local AASB = makeBtn(MF, "Anti-Arm Steal", UDim2.new(0.5,0,0,30), UDim2.new(0.5,0,1,-180), Color3.fromRGB(50,50,50)); AASB.TextSize = 11
local function activateAntiArm()
    if isAntiStealing then return end
    isAntiStealing, AASB.BackgroundColor3, AASB.Text = true, Color3.fromRGB(120,30,30), "GLITCHING ARMS..."
    task.spawn(function()
        if LP and LP.Character and LP:FindFirstChild("Backpack") then
            local char, bp = LP.Character, LP.Backpack
            local iK = bp:FindFirstChild("MadMurdererKnife")
            if iK and iK:IsA("Tool") then
                iK.Parent = char; task.wait(0.6); iK.Parent = bp; task.wait()
                local ks = {}
                for _, i in ipairs(bp:GetChildren()) do if i:IsA("Tool") and i.Name == "MadMurdererKnife" then table.insert(ks, i) end end
                if #ks >= 2 then
                    local k1, k2 = ks[1], ks[2]
                    k1.Parent = char; task.wait(0.4); k2.Parent = char; task.wait(); k2.Parent = bp; task.wait(0.4)
                    if k1.Parent == char then k1.Parent = bp end; task.wait(0.4)
                    local rw = char:FindFirstChild("RightWeld", true); if rw then rw:Destroy() end
                    local ls = char:FindFirstChild("Left Shoulder", true); if ls then ls:Destroy() end
                end
            end
        end
        task.wait(1.5)
        AASB.BackgroundColor3, AASB.Text, isAntiStealing = Color3.fromRGB(50,50,50), "Anti-Arm Steal", false
    end)
end
AASB.MouseButton1Click:Connect(activateAntiArm)
 
createToggle(0.5, -150, "ANTI-LASER", Color3.fromRGB(40,90,40), false, function() IsAntiLaser = not IsAntiLaser; return IsAntiLaser end)
createToggle(0.5, -120, "Supernova", Color3.fromRGB(150,80,40), false, function() InfSupernovaActive = not InfSupernovaActive; return InfSupernovaActive end)
 
local DelGearBtn = makeBtn(MF, "Delete Gear", UDim2.new(0.5,0,0,30), UDim2.new(0.5,0,1,-90), Color3.fromRGB(50,50,50)); DelGearBtn.TextSize = 11
DelGearBtn.MouseButton1Click:Connect(function()
    local char = LP.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local nm = tool.Name
        tool:Destroy()
        local oldTxt, oldCol = DelGearBtn.Text, DelGearBtn.BackgroundColor3
        DelGearBtn.Text, DelGearBtn.BackgroundColor3 = "DELETED: "..nm, Color3.fromRGB(150,40,40)
        task.delay(1, function() if DelGearBtn and DelGearBtn.Parent then DelGearBtn.Text, DelGearBtn.BackgroundColor3 = oldTxt, oldCol end end)
    else
        local oldTxt, oldCol = DelGearBtn.Text, DelGearBtn.BackgroundColor3
        DelGearBtn.Text, DelGearBtn.BackgroundColor3 = "NO TOOL", Color3.fromRGB(150,40,40)
        task.delay(1, function() if DelGearBtn and DelGearBtn.Parent then DelGearBtn.Text, DelGearBtn.BackgroundColor3 = oldTxt, oldCol end end)
    end
end)
 
createToggle(0.5, -60, "Fire Interest", Color3.fromRGB(200,50,200), false, function()
    FireInterestActive = not FireInterestActive
    if not FireInterestActive then
        for _, l in pairs(FireInterestLoops) do if l then l:Disconnect() end end
        table.clear(FireInterestLoops); table.clear(FireInterestTargets)
    else
        for _, p in ipairs(getHighlightedPlayers()) do applyFireInterestToPlayer(p) end
    end
    refreshPlayerColors()
    return FireInterestActive
end)
createToggle(0.5, -30, "Void-Kill", Color3.fromRGB(40,150,160), false, function() VoidKillActive = not VoidKillActive; if not VoidKillActive then clearToolTargets(VoidKillTargets, VoidKillLoops, VoidKillTrackers, ActiveVoidKillSwords) end; refreshPlayerColors(); return VoidKillActive end)
 
createToggle(0.5, 0, "Weld-Kill", Color3.fromRGB(180,100,40), false, function() 
    WeldKillActive = not WeldKillActive
    if not WeldKillActive then 
        nullWeldOverride = nil 
        for tp, _ in pairs(WeldKillTargets) do
            if tp and tp.Character then
                local tr = tp.Character:FindFirstChild("Torso") or tp.Character:FindFirstChild("HumanoidRootPart")
                if tr then tr.Anchored = false end
            end
        end
        table.clear(WeldKillTargets) 
    end
    refreshPlayerColors()
    return WeldKillActive 
end)
 
---------------------------------------------------------
-- PLAYER CLICK LOGIC
---------------------------------------------------------
local function E(t, btn)
    local took = false
    if FireInterestActive then
        took = true
        if FireInterestTargets[t] then
            FireInterestTargets[t] = nil
            if FireInterestLoops[t.Name] then FireInterestLoops[t.Name]:Disconnect(); FireInterestLoops[t.Name] = nil end
        else
            FireInterestTargets[t] = true
            if FireInterestLoops[t.Name] then FireInterestLoops[t.Name]:Disconnect() end
            FireInterestLoops[t.Name] = RS.Heartbeat:Connect(function()
                if not FireInterestTargets[t] then if FireInterestLoops[t.Name] then FireInterestLoops[t.Name]:Disconnect(); FireInterestLoops[t.Name] = nil end return end
                local char = LP.Character; if not char then return end
                local heldTool = char:FindFirstChildOfClass("Tool"); if not heldTool then return end
                local handle = heldTool:FindFirstChild("Handle"); if not handle then return end
                local tc = t.Character; if not tc then return end
                local tp = tc:FindFirstChild("Torso") or tc:FindFirstChild("HumanoidRootPart"); if not tp then return end
                pcall(function() firetouchinterest(handle, tp, 0); task.wait(); firetouchinterest(handle, tp, 1) end)
            end)
        end
    end
    if WeldKillActive then
        took = true
        WeldKillTargets[t] = true 
        local tChar = t.Character
        local tRoot = tChar and (tChar:FindFirstChild("Torso") or tChar:FindFirstChild("HumanoidRootPart"))
        if tRoot then
            local thc = homeCFrame
            local so = LP:FindFirstChild("Spawn")
            if so and so.Value then
                local sg = workspace:FindFirstChild(tostring(so.Value))
                if sg and sg:FindFirstChild("SpawnLocation") then thc = sg.SpawnLocation.CFrame + Vector3.new(0,4,0) end
            end
            local baseSpot = (thc or CFrame.new(0,10,0)) * CFrame.new(0,-3,0)
            local wkLoop
            wkLoop = RS.Heartbeat:Connect(function()
                if WeldKillTargets[t] and tRoot and tRoot.Parent then tRoot.Anchored, tRoot.CFrame = true, baseSpot
                else if tRoot and tRoot.Parent then tRoot.Anchored = false end; if wkLoop then wkLoop:Disconnect() end end
            end)
            local myChar = LP.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local newHum
            if myHum then
                newHum = myHum:Clone(); myHum:Destroy(); newHum.Parent = myChar
                if NullDesyncActive and nullCamPart then workspace.CurrentCamera.CameraSubject = nullCamPart
                else workspace.CurrentCamera.CameraSubject = newHum end
            end
            local behindCF = baseSpot * CFrame.new(-1.5,0,0)
            if env.desyncActive then env.realCF = behindCF end
            if NullDesyncActive then 
                nullSavedCF, nullWeldOverride = behindCF, behindCF
                local th = tChar:FindFirstChildOfClass("Humanoid")
                if th then
                    local dC; dC = th.Died:Connect(function()
                        if nullWeldOverride == behindCF then nullWeldOverride = nil end 
                        if dC then dC:Disconnect() end
                    end)
                end
            end
            if not env.desyncActive and not NullDesyncActive and myChar and myChar:FindFirstChild("HumanoidRootPart") then myChar.HumanoidRootPart.CFrame = behindCF end
            local badGears = {RocketJumper=1,BoneSword=1,ChopperBroom=1,FlyingBroom=1}
            local endTime = tick() + 4.0
            task.spawn(function()
                local idx = 1
                while tick() < endTime and WeldKillTargets[t] and myChar and newHum do
                    local bp, valid = LP:FindFirstChild("Backpack"), {}
                    if bp then for _, i in ipairs(bp:GetChildren()) do if i:IsA("Tool") and not badGears[i.Name] then table.insert(valid, i) end end end
                    local eq = myChar:FindFirstChildOfClass("Tool")
                    if eq and not badGears[eq.Name] then
                        local f = false
                        for _, vt in ipairs(valid) do if vt == eq then f = true; break end end
                        if not f then table.insert(valid, eq) end
                    end
                    if #valid > 0 then
                        if idx > #valid then idx = 1 end
                        local nt = valid[idx]
                        if nt then newHum:UnequipTools(); newHum:EquipTool(nt); idx += 1 end
                    end
                    task.wait(0.2)
                end
                WeldKillTargets[t] = nil
                refreshPlayerColors()
            end)
            local dC; dC = t.CharacterAdded:Connect(function() WeldKillTargets[t] = nil; refreshPlayerColors(); if dC then dC:Disconnect() end end)
        end
    end
    if StealArmActive then
        took = true
        if StealArmTargets[t] then StealArmTargets[t] = nil 
        else table.clear(StealArmTargets); StealArmTargets[t] = true; task.delay(0.2, function() if StealArmTargets[t] then StealArmTargets[t] = nil; refreshPlayerColors() end end) end
    end
    if RocketSpamActive then 
        took = true
        if WeldKillActive then RocketTargets[t.UserId] = true
        else 
            RocketTargets[t.UserId] = not RocketTargets[t.UserId] and true or nil
            if not RocketTargets[t.UserId] then RocketLastKnownPos[t.UserId] = nil end
        end
    end
    if SpawnCloneActive then took = true; table.clear(SpawnCloneTargets); SpawnCloneTargets[t] = true; task.spawn(function() executeSpectralNuke(t, btn) end) end
    if VoidKillActive then
        took = true
        if VoidKillTargets[t] then clearToolTargets({[t]=true}, VoidKillLoops, VoidKillTrackers, ActiveVoidKillSwords); VoidKillTargets[t] = nil
        else
            VoidKillTargets[t] = true; refreshPlayerColors()
            local function doVoidKill()
                if not VoidKillTargets[t] then return end
                local char = LP.Character
                local hum, root, bp = char and char:FindFirstChildOfClass("Humanoid"), char and char:FindFirstChild("HumanoidRootPart"), LP:FindFirstChild("Backpack")
                if not char or not hum or not root or not bp then return end
                local tvCF = CFrame.new(-1050,-490,90)
                local tf = set(Instance.new("Part", workspace), {Size=Vector3.new(200,5,200), CFrame=tvCF * CFrame.new(0,-4,0), Anchored=true, Transparency=1})
                game:GetService("Debris"):AddItem(tf, 10)
                if env.desyncActive then env.fakeCF = tvCF elseif NullDesyncActive then nullSavedCF = tvCF else root.CFrame = tvCF end
                task.wait(0.1); hum:UnequipTools()
                local sba = bp:FindFirstChild("Bear Arm") or char:FindFirstChild("Bear Arm") or bp:FindFirstChild("BearArm") or char:FindFirstChild("BearArm")
                if sba then
                    hum:EquipTool(sba)
                    local tArm = t.Character and (t.Character:FindFirstChild("Left Arm") or t.Character:FindFirstChild("LeftHand") or t.Character:WaitForChild("Left Arm", 3) or t.Character:WaitForChild("LeftHand", 3))
                    if tArm and (env.desyncActive or NullDesyncActive) then
                        if env.desyncActive then env.fakeCF = tvCF end
                        local oldReal, wasFly = env.realCF, Flying
                        Flying, StealArmTargets[t] = false, true
                        task.wait(0.4); StealArmTargets[t] = nil; env.realCF, Flying = oldReal, wasFly
                    else task.wait(0.4) end
                end
                if not VoidKillTargets[t] then return end
                task.wait(0.5)
                local sword, all = nil, {}
                for _, o in pairs(char:GetChildren()) do if o.Name == "IceSword" then table.insert(all, o) end end
                for _, o in pairs(bp:GetChildren()) do if o.Name == "IceSword" then table.insert(all, o) end end
                for _, s in pairs(all) do if not ActiveVoidKillSwords[s] or ActiveVoidKillSwords[s] == t then sword = s; break end end
                if sword then ActiveVoidKillSwords[sword] = t; hum:EquipTool(sword); attachTool(t, sword, VoidKillLoops) 
                else
                    local old = btn.Text; btn.Text, btn.BackgroundColor3 = "NO ICESWORD", Color3.fromRGB(150,40,40)
                    task.delay(1, function() if btn and btn.Parent and not VoidKillTargets[t] then btn.Text = old; refreshPlayerColors() end end)
                    clearToolTargets({[t]=true}, VoidKillLoops, VoidKillTrackers, ActiveVoidKillSwords); VoidKillTargets[t] = nil; return
                end
                if sba then
                    local et = tick() + 5.0
                    while tick() < et and VoidKillTargets[t] do
                        if sba.Parent == bp then sba.Parent = char else sba.Parent = bp end; task.wait(0.01)
                    end
                    if sba then sba.Parent = bp end
                end
            end
            local function hookDeath(tc)
                local th = tc:WaitForChild("Humanoid", 5)
                if th then th.Died:Connect(function()
                    if VoidKillLoops[t.Name] then VoidKillLoops[t.Name]:Disconnect(); VoidKillLoops[t.Name] = nil end
                    for s, ply in pairs(ActiveVoidKillSwords) do if ply == t and s.Parent == LP.Character then s.Parent = LP:FindFirstChild("Backpack") or s.Parent end end
                end) end
            end
            if t.Character then task.spawn(function() hookDeath(t.Character) end) end
            VoidKillTrackers[t.Name] = t.CharacterAdded:Connect(function(nc) hookDeath(nc); if VoidKillTargets[t] then task.wait(0.3); task.spawn(doVoidKill) end end)
            task.spawn(doVoidKill)
        end
    end
    if SKillActive then took = true; toggleTargetSkill(btn, t, "BoneSword", SKillTargets, SKillLoops, SKillTrackers, ActiveSKillSwords) end
    if took then refreshPlayerColors(); return end 
    if GiveDroppedGearActive then btn.BackgroundColor3 = Color3.fromRGB(40,120,40); consistentWeldTPGive(t); task.wait(1.5); refreshPlayerColors(); return end
    executeSpectralNuke(t, btn)
end
 
local function R()
    for _, i in pairs(SF:GetChildren()) do if i:IsA("TextButton") then i:Destroy() end end
    for _, p in pairs(P:GetPlayers()) do 
        if p ~= LP then
            local b = makeBtn(SF, p.Name, UDim2.new(1,0,0,25), UDim2.new(0,0,0,0), Color3.fromRGB(50,50,50))
            b.TextSize = 13 
            b.MouseButton1Click:Connect(function() E(p, b) end)
        end 
    end 
    refreshPlayerColors()
end
R()
P.PlayerAdded:Connect(R); P.PlayerRemoving:Connect(R)
 
---------------------------------------------------------
-- BACKGROUND TASKS
---------------------------------------------------------
CB.MouseButton1Click:Connect(function() 
    if env.desyncActive then stopDesync() end
    if NullDesyncActive then stopNullDesync() end
    if antiPickupConnection then antiPickupConnection:Disconnect(); antiPickupConnection = nil end
    if antiPickupCharConn then antiPickupCharConn:Disconnect(); antiPickupCharConn = nil end
    if antiPickupBpConn then antiPickupBpConn:Disconnect(); antiPickupBpConn = nil end
    if BoneSwordTouchLoop then BoneSwordTouchLoop:Disconnect(); BoneSwordTouchLoop = nil end
    if homeTPLoop then homeTPLoop:Disconnect(); homeTPLoop = nil end
    AntiPickupActive, isGodMode, VoidKillActive, SpawnCloneActive, FireInterestActive, KillAuraActive = false, false, false, false, false, false
    giveAllRunning = false
    clearToolTargets(SKillTargets, SKillLoops, SKillTrackers, ActiveSKillSwords)
    clearToolTargets(VoidKillTargets, VoidKillLoops, VoidKillTrackers, ActiveVoidKillSwords)
    for _, l in pairs(FireInterestLoops) do if l then l:Disconnect() end end
    for plr, _ in pairs(KillAuraDebounces) do
        if plr and plr.Character and plr.Character:FindFirstChild("Torso") then plr.Character.Torso.Anchored = false end
    end
    table.clear(KillAuraDebounces); table.clear(FireInterestLoops); table.clear(FireInterestTargets)
    fullClearSpectate()
    restoreTools()
    SG:Destroy() 
end)
 
workspace.ChildAdded:Connect(function(c)
    if IsAntiLaser then
        RS.Heartbeat:Wait()
        if laserNames[c.Name] or c:IsA("SelectionPartLasso") then
            if c:IsA("BasePart") then c.CanTouch, c.CanCollide, c.Transparency = false, false, 1 end
            c:Destroy()
        end
    end
    if c.Name == LP.Name .. "'s Clone" then LatestClone = c end
end)
 
task.spawn(function()
    while true do
        task.wait(0.1)
        if InfSupernovaActive and LP then 
            local pth = workspace:FindFirstChild(LP.Name) 
            if pth and pth:FindFirstChild("IvoryPeriastron") and pth.IvoryPeriastron:FindFirstChild("Server") and pth.IvoryPeriastron.Server:FindFirstChild("StarSummon") then
                for _, c in ipairs(pth.IvoryPeriastron.Server.StarSummon:GetChildren()) do if c.Name == "StarShard" or c.Name == "Explosion" then c:Destroy() end end
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
end)
 
RS.Stepped:Connect(function() if NoclipActive and LP.Character then for _, p in ipairs(LP.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end)
 
---------------------------------------------------------
-- HOME TP LOOP (loops to home for 1s after respawn when NOT in null desync)
---------------------------------------------------------
local function handleHomeTP(char)
    local hum = char:WaitForChild("Humanoid", 5)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not hum or not root then return end
    if homeTPLoop then homeTPLoop:Disconnect(); homeTPLoop = nil end
    local hardCoord = getHomeFromSpawnValue()
    if hardCoord then homeCFrame = hardCoord end
    if not NullDesyncActive then
        local endTime = tick() + 1.0
        homeTPLoop = RS.Heartbeat:Connect(function()
            if NullDesyncActive then
                if homeTPLoop then homeTPLoop:Disconnect(); homeTPLoop = nil end
                return
            end
            if root and root.Parent then root.CFrame = homeCFrame end
            if tick() >= endTime then
                if homeTPLoop then homeTPLoop:Disconnect(); homeTPLoop = nil end
            end
        end)
    end
end
 
LP.CharacterAdded:Connect(function(c)
    if NullDesyncActive then task.wait(0.5); startNullDesync(c) end
    task.spawn(function() handleHomeTP(c) end)
end)
 
if LP.Character then
    task.spawn(function() handleHomeTP(LP.Character) end)
end
 
task.spawn(function()
    workspace.FallenPartsDestroyHeight = -9e9
    local root = (LP.Character or LP.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart", 5)
    if root then
        local found = getHomeFromSpawnValue()
        if not found then
            local so = LP:FindFirstChild("Spawn")
            if so and so.Value then
                local sg = workspace:FindFirstChild(tostring(so.Value))
                if sg and sg:FindFirstChild("SpawnLocation") then found = sg.SpawnLocation.CFrame + Vector3.new(0,4,0) end
            end
        end
        if not found then
            local closest, cd = nil, math.huge
            for i = 1, 8 do
                local loc = workspace:FindFirstChild("Spawn"..i) and workspace:FindFirstChild("Spawn"..i):FindFirstChild("SpawnLocation")
                if loc and loc:IsA("BasePart") and (loc.Position - root.Position).Magnitude < cd then cd, closest = (loc.Position - root.Position).Magnitude, loc end
            end
            if closest then found = closest.CFrame + Vector3.new(0,4,0) end
        end
        if found then homeCFrame = found end
    end
    if NullDesyncActive and LP.Character then task.wait(0.5); startNullDesync(LP.Character) end
    task.wait(3)
    local FAR = CFrame.new(99999,99999,99999)
    for _, v in ipairs(workspace:GetDescendants()) do if v.Name == "SpawnWalls" and v:IsA("BasePart") then v.CFrame, v.Anchored, v.CanCollide = FAR, true, false end end
    task.wait(4)
    do
        local char, bp = LP.Character, LP:FindFirstChild("Backpack")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local bow = (bp and bp:FindFirstChild("OrnateGoldenBow")) or (char and char:FindFirstChild("OrnateGoldenBow"))
        if bow and hum then
            hum:EquipTool(bow)
            task.wait(0.2)
            hum:UnequipTools()
            task.wait(0.2)
        end
    end
    activateAntiArm()
end)
 
task.spawn(function()
    task.wait(1.5)
    runGiveAll()
end)
