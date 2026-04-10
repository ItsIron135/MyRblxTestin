local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local pGui = player:WaitForChild("PlayerGui")

-- CONFIG
local UI_NAME = "FF_REMOVE_MAPMOVE_V7"
local PUSH_BACK_DIST = 45 
local CAM_OFFSET_DIST = 16  
local OFFSET_DIST = 30 
local SAFE_COORDS = Vector3.new(-1840.9, 301.1, 119.6)
local CAPTURE_SIZE = Vector3.new(50, 50, 50) -- Size for Map Walls & Bases
local CLONE_SIZE = Vector3.new(15, 15, 15)      -- Edit this for your Clones!

local isCamActive = false
local isFireMode = false
local isGiveAllActive = false
local isNoclip = false
local ActiveObjects = {} 
local OriginalCFrames = {} 
local OriginalAppearance = {} 

-- 1. UI SETUP
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local SG = Instance.new("ScreenGui", pGui)
SG.Name = UI_NAME; SG.ResetOnSpawn = false

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 180, 0, 385)
MF.Position = UDim2.new(0.85, 0, 0.5, -192)
MF.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MF.Active = true; MF.Draggable = true; MF.BorderSizePixel = 0

local T = Instance.new("TextLabel", MF)
T.Size = UDim2.new(1, -30, 0, 30); T.BackgroundTransparency = 1
T.Text = "FF V7.8 (RESIZED)"; T.TextColor3 = Color3.new(1, 1, 1)
T.Font = Enum.Font.Code; T.TextSize = 14

local function cleanupScanner()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "ScannerLabel" or v.Name == "ScanHigh" then v:Destroy() end
    end
end

local CB = Instance.new("TextButton", MF)
CB.Size = UDim2.new(0, 30, 0, 30); CB.Position = UDim2.new(1, -30, 0, 0)
CB.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CB.Text = "X"
CB.TextColor3 = Color3.new(1, 1, 1); CB.MouseButton1Click:Connect(function() cleanupScanner(); SG:Destroy() end)

local function createBtn(text, yPos, color)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(1, 0, 0, 30); b.Position = UDim2.new(0, 0, 0, yPos)
    b.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
    b.Text = text; b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Code; b.TextSize = 13; b.BorderSizePixel = 0
    return b
end

-- MAIN BUTTONS
local fireToggle = createBtn("FIRE MODE: OFF", 30)
local giveAllBtn = createBtn("GIVE ALL: OFF", 60)
local noclipBtn = createBtn("NOCLIP: OFF", 90)
local outerFFBtn = createBtn("OUTER FF", 120, Color3.fromRGB(80, 40, 120))
local scanMenuBtn = createBtn("OBJ SCANNER", 150, Color3.fromRGB(0, 100, 150))

-- 2. THE HEAD BUTTON (GO)
local headButton = Instance.new("TextButton", SG)
headButton.Size = UDim2.new(0, 40, 0, 40)
headButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
headButton.BackgroundTransparency = 0.3
headButton.Text = "GO"
headButton.TextColor3 = Color3.new(1, 1, 1)
headButton.Visible = false
headButton.ZIndex = 10
Instance.new("UICorner", headButton).CornerRadius = UDim.new(1, 0)

-- 3. LOGIC FUNCTIONS
local function syncedDoubleQ()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    task.wait(0.2) 
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
end

local function runMapMoveAutomation()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local bp = player:FindFirstChild("Backpack")
    if not root or not bp then return end

    root.CFrame = root.CFrame * CFrame.new(0, 0, PUSH_BACK_DIST) * CFrame.Angles(0, math.rad(-90), 0)
    isCamActive = true
    
    local bow = bp:FindFirstChild("OrnateGoldenBow")
    if bow then char.Humanoid:EquipTool(bow) end
    
    task.wait(0.6)
    syncedDoubleQ()
    task.wait(1.0)
    
    if not char:FindFirstChild("IvoryPeriastron") then
        local ivory = bp:FindFirstChild("IvoryPeriastron")
        if ivory then ivory.Parent = char end
    end
    
    task.wait(0.2)
    isCamActive = false
    camera.CameraType = Enum.CameraType.Custom
end

-- 4. UPGRADED FF SELECTOR LOGIC (Now accepts custom sizes)
local function togglePart(part, button, isOuter, targetSize)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not part then return end

    if ActiveObjects[part] then
        -- RETURN TO NORMAL
        if OriginalCFrames[part] then part.CFrame = OriginalCFrames[part] end
        if OriginalAppearance[part] then
            part.Size = OriginalAppearance[part].Size
            part.Transparency = OriginalAppearance[part].Transparency
            part.Color = OriginalAppearance[part].Color
            part.Anchored = OriginalAppearance[part].Anchored
            part.CanCollide = OriginalAppearance[part].CanCollide
            part.CanQuery = OriginalAppearance[part].CanQuery
        else
            part.Transparency = 1
        end
        part.AssemblyLinearVelocity = Vector3.new(0, 0.1, 0)
        button.BackgroundColor3 = isOuter and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(50, 50, 50)
        ActiveObjects[part] = nil
    else
        -- CAPTURE
        if not OriginalCFrames[part] then OriginalCFrames[part] = part.CFrame end
        if not OriginalAppearance[part] then
            OriginalAppearance[part] = {
                Size = part.Size, Transparency = part.Transparency, Color = part.Color,
                Anchored = part.Anchored, CanCollide = part.CanCollide, CanQuery = part.CanQuery
            }
        end
        ActiveObjects[part] = true
        button.BackgroundColor3 = isOuter and Color3.fromRGB(0, 150, 255) or Color3.new(0.2, 0.5, 0.8)
        
        part.AssemblyLinearVelocity = Vector3.new(0, 0.1, 0) 
        part.Size = targetSize or CAPTURE_SIZE -- Defaults to 50x50x50 unless specified
        part.Transparency = 0.5
        part.Color = Color3.fromRGB(255, 0, 0)
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = true
        part.CFrame = CFrame.new(SAFE_COORDS)
        
        root.CFrame = CFrame.new(SAFE_COORDS + Vector3.new(0, 0, OFFSET_DIST))
        task.wait(0.05)
        root.CFrame = CFrame.lookAt(root.Position, part.Position)
    end
end

-- 5. BUTTON EVENTS
fireToggle.MouseButton1Click:Connect(function()
    isFireMode = not isFireMode
    headButton.Visible = isFireMode
    fireToggle.Text = isFireMode and "FIRE MODE: ON" or "FIRE MODE: OFF"
    fireToggle.BackgroundColor3 = isFireMode and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(60, 60, 60)
end)

headButton.MouseButton1Click:Connect(runMapMoveAutomation)

giveAllBtn.MouseButton1Click:Connect(function()
    isGiveAllActive = not isGiveAllActive
    giveAllBtn.Text = isGiveAllActive and "GIVE ALL: ON" or "GIVE ALL: OFF"
    giveAllBtn.BackgroundColor3 = isGiveAllActive and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 60)
end)

noclipBtn.MouseButton1Click:Connect(function()
    isNoclip = not isNoclip
    noclipBtn.Text = isNoclip and "NOCLIP: ON" or "NOCLIP: OFF"
    noclipBtn.BackgroundColor3 = isNoclip and Color3.fromRGB(150, 50, 150) or Color3.fromRGB(60, 60, 60)
end)

-- 6. OUTER FF PANEL (WITH CLONES TAB)
local OF_Panel = Instance.new("Frame", SG)
OF_Panel.Size = UDim2.new(0, 220, 0, 400); OF_Panel.Position = UDim2.new(0.85, -230, 0.5, -200)
OF_Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20); OF_Panel.Visible = false
OF_Panel.Active = true; OF_Panel.Draggable = true; Instance.new("UICorner", OF_Panel)

local OF_Scroll = Instance.new("ScrollingFrame", OF_Panel)
OF_Scroll.Size = UDim2.new(1, -10, 1, -40); OF_Scroll.Position = UDim2.new(0, 5, 0, 35)
OF_Scroll.BackgroundTransparency = 1; OF_Scroll.CanvasSize = UDim2.new(0,0,0,0); OF_Scroll.ScrollBarThickness = 2
OF_Scroll.Active = true
local OF_List = Instance.new("UIListLayout", OF_Scroll); OF_List.SortOrder = Enum.SortOrder.LayoutOrder

local baseInfo = {
    ["Spawn1"] = "Dark Blue", ["Spawn2"] = "Light Blue", ["Spawn3"] = "Green",
    ["Spawn4"] = "Yellow", ["Spawn5"] = "Orange", ["Spawn6"] = "Pink",
    ["Spawn7"] = "Purple", ["Spawn8"] = "Red"
}

local function populateOuterMenu()
    for _, child in ipairs(OF_Scroll:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
    
    -- === CLONES TAB ===
    local cloneLabel = Instance.new("TextLabel", OF_Scroll)
    cloneLabel.Size = UDim2.new(1, 0, 0, 30); cloneLabel.Text = "--- Spectral Clones ---"
    cloneLabel.TextColor3 = Color3.fromRGB(255, 50, 50); cloneLabel.BackgroundTransparency = 1
    cloneLabel.Font = Enum.Font.Code; cloneLabel.TextSize = 13

    local expectedName = player.Name .. "'s Clone"
    local cloneCount = 0

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == expectedName then
            local torso = v:FindFirstChild("Torso") or v:FindFirstChild("UpperTorso") or v:FindFirstChild("HumanoidRootPart")
            if torso and torso:IsA("BasePart") then
                cloneCount = cloneCount + 1
                local cBtn = Instance.new("TextButton", OF_Scroll)
                cBtn.Size = UDim2.new(1, 0, 0, 25); cBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                cBtn.Text = "["..cloneCount.."] Clone Torso"; cBtn.TextColor3 = Color3.new(1,1,1); cBtn.BorderSizePixel = 0
                if ActiveObjects[torso] then cBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255) end
                
                -- We pass CLONE_SIZE here so it doesn't use the massive default box
                cBtn.MouseButton1Click:Connect(function() togglePart(torso, cBtn, true, CLONE_SIZE) end)
            end
        end
    end

    if cloneCount == 0 then
        local noneLabel = Instance.new("TextLabel", OF_Scroll)
        noneLabel.Size = UDim2.new(1, 0, 0, 20); noneLabel.Text = "No active clones found."
        noneLabel.TextColor3 = Color3.fromRGB(150, 150, 150); noneLabel.BackgroundTransparency = 1
        noneLabel.Font = Enum.Font.Code; noneLabel.TextSize = 11
    end
    -- =======================

    local foundWalls = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "SpawnWalls" and v:IsA("BasePart") then
            for spawnKey, baseName in pairs(baseInfo) do
                if v:GetFullName():find(spawnKey) then
                    if not foundWalls[baseName] then foundWalls[baseName] = {} end
                    table.insert(foundWalls[baseName], v)
                end
            end
        end
    end
    for _, baseName in pairs(baseInfo) do
        if foundWalls[baseName] then
            local label = Instance.new("TextLabel", OF_Scroll)
            label.Size = UDim2.new(1, 0, 0, 25); label.Text = "--- " .. baseName .. " ---"
            label.TextColor3 = Color3.fromRGB(0, 255, 150); label.BackgroundTransparency = 1
            label.Font = Enum.Font.Code; label.TextSize = 13
            for i, wallPart in ipairs(foundWalls[baseName]) do
                local wBtn = Instance.new("TextButton", OF_Scroll)
                wBtn.Size = UDim2.new(1, 0, 0, 25); wBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                wBtn.Text = "Wall " .. i; wBtn.TextColor3 = Color3.new(1,1,1); wBtn.BorderSizePixel = 0
                if ActiveObjects[wallPart] then wBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255) end
                wBtn.MouseButton1Click:Connect(function() togglePart(wallPart, wBtn, true, CAPTURE_SIZE) end)
            end
        end
    end

    local ffLabel = Instance.new("TextLabel", OF_Scroll)
    ffLabel.Size = UDim2.new(1, 0, 0, 30); ffLabel.Text = "--- Terrain ForceFields ---"
    ffLabel.TextColor3 = Color3.fromRGB(255, 150, 0); ffLabel.BackgroundTransparency = 1
    ffLabel.Font = Enum.Font.Code; ffLabel.TextSize = 13

    for i = 1, 8 do
        local terrainFolder = workspace:FindFirstChild("Terrain" .. i)
        local forceFieldPart = terrainFolder and terrainFolder:FindFirstChild("ForceFields")
        if forceFieldPart then
            local fBtn = Instance.new("TextButton", OF_Scroll)
            fBtn.Size = UDim2.new(1, 0, 0, 25); fBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            fBtn.Text = "["..i.."] Terrain FF"; fBtn.TextColor3 = Color3.new(1,1,1); fBtn.BorderSizePixel = 0
            if ActiveObjects[forceFieldPart] then fBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255) end
            fBtn.MouseButton1Click:Connect(function() togglePart(forceFieldPart, fBtn, true, CAPTURE_SIZE) end)
        end
    end

    local spawnLabel = Instance.new("TextLabel", OF_Scroll)
    spawnLabel.Size = UDim2.new(1, 0, 0, 30); spawnLabel.Text = "--- SpawnLocations ---"
    spawnLabel.TextColor3 = Color3.fromRGB(0, 200, 255); spawnLabel.BackgroundTransparency = 1
    spawnLabel.Font = Enum.Font.Code; spawnLabel.TextSize = 13

    for i = 1, 8 do
        local baseFolder = workspace:FindFirstChild("Spawn" .. i)
        local locPart = baseFolder and baseFolder:FindFirstChild("SpawnLocation")
        if locPart then
            local lBtn = Instance.new("TextButton", OF_Scroll)
            lBtn.Size = UDim2.new(1, 0, 0, 25); lBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            lBtn.Text = "["..i.."] SpawnLocation"; lBtn.TextColor3 = Color3.new(1,1,1); lBtn.BorderSizePixel = 0
            if ActiveObjects[locPart] then lBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255) end
            lBtn.MouseButton1Click:Connect(function() togglePart(locPart, lBtn, true, CAPTURE_SIZE) end)
        end
    end

    OF_Scroll.CanvasSize = UDim2.new(0,0,0, OF_List.AbsoluteContentSize.Y)
end

outerFFBtn.MouseButton1Click:Connect(function()
    OF_Panel.Visible = not OF_Panel.Visible
    if OF_Panel.Visible then populateOuterMenu() end
end)

-- 7. OBJECT SCANNER TAB
local ObjFrame = Instance.new("Frame", SG)
ObjFrame.Size = UDim2.new(0, 220, 0, 340); ObjFrame.Position = UDim2.new(0.85, -230, 0.5, -170)
ObjFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); ObjFrame.Visible = false; ObjFrame.Active = true; ObjFrame.Draggable = true; Instance.new("UICorner", ObjFrame)

local ObjSF = Instance.new("ScrollingFrame", ObjFrame)
ObjSF.Size = UDim2.new(1, -10, 1, -80); ObjSF.Position = UDim2.new(0, 5, 0, 35)
ObjSF.BackgroundTransparency = 1; ObjSF.ScrollBarThickness = 2
local ObjList = Instance.new("UIListLayout", ObjSF); ObjList.SortOrder = Enum.SortOrder.LayoutOrder

local ScanBtnAction = Instance.new("TextButton", ObjFrame)
ScanBtnAction.Size = UDim2.new(0.9, 0, 0, 30); ScanBtnAction.Position = UDim2.new(0.05, 0, 1, -40)
ScanBtnAction.BackgroundColor3 = Color3.fromRGB(0, 100, 200); ScanBtnAction.Text = "SCAN AREA"; ScanBtnAction.TextColor3 = Color3.new(1, 1, 1); ScanBtnAction.Font = Enum.Font.Code; Instance.new("UICorner", ScanBtnAction)

ScanBtnAction.MouseButton1Click:Connect(function()
    cleanupScanner()
    for _, item in pairs(ObjSF:GetChildren()) do if item:IsA("Frame") then item:Destroy() end end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local parts = workspace:GetPartBoundsInBox(root.CFrame, Vector3.new(35,35,35))
    local f = 0
    for _, p in ipairs(parts) do
        if p:IsA("BasePart") and not p:IsDescendantOf(player.Character) then
            f = f + 1; local c = Color3.fromHSV(f/15, 0.8, 1)
            local high = Instance.new("Highlight", workspace); high.Name = "ScanHigh"; high.Adornee = p; high.FillColor = c; high.OutlineColor = c
            local bgui = Instance.new("BillboardGui", p); bgui.Name = "ScannerLabel"; bgui.Size = UDim2.new(0, 50, 0, 50); bgui.AlwaysOnTop = true; bgui.ExtentsOffset = Vector3.new(0,3,0)
            local tl = Instance.new("TextLabel", bgui); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = tostring(f); tl.TextColor3 = c; tl.Font = Enum.Font.Code; tl.TextSize = 25

            local row = Instance.new("Frame", ObjSF)
            row.Size = UDim2.new(1,0,0,35); row.BackgroundColor3 = Color3.fromRGB(40,40,40); Instance.new("UICorner", row)
            local l = Instance.new("TextLabel", row)
            l.Size = UDim2.new(0.4,0,1,0); l.Text = "["..f.."] "..p.Name:sub(1,10); l.TextColor3 = c; l.BackgroundTransparency = 1; l.TextSize = 10; l.Position = UDim2.new(0,5,0,0)
            
            local tpB = Instance.new("TextButton", row)
            tpB.Size = UDim2.new(0.2,0,0.8,0); tpB.Position = UDim2.new(0.45,0,0.1,0); tpB.Text = "TP"; tpB.BackgroundColor3 = Color3.fromRGB(0,80,40); tpB.TextColor3 = Color3.new(1,1,1)
            
            local backB = Instance.new("TextButton", row)
            backB.Size = UDim2.new(0.25,0,0.8,0); backB.Position = UDim2.new(0.7,0,0.1,0); backB.Text = "BACK"; backB.BackgroundColor3 = Color3.fromRGB(150,20,20); backB.TextColor3 = Color3.new(1,1,1)
            
            tpB.MouseButton1Click:Connect(function() togglePart(p, tpB, false, CAPTURE_SIZE) end)
            backB.MouseButton1Click:Connect(function()
                if ActiveObjects[p] then togglePart(p, tpB, false, CAPTURE_SIZE) end
            end)
        end
    end
    ObjSF.CanvasSize = UDim2.new(0,0,0, ObjList.AbsoluteContentSize.Y)
end)

scanMenuBtn.MouseButton1Click:Connect(function() ObjFrame.Visible = not ObjFrame.Visible; if not ObjFrame.Visible then cleanupScanner() end end)

-- 8. BASES LIST
local SF = Instance.new("Frame", MF)
SF.Size = UDim2.new(1, 0, 0, 205); SF.Position = UDim2.new(0, 0, 0, 180) 
SF.BackgroundTransparency = 1
local UIListMain = Instance.new("UIListLayout", SF)

local baseNames = {"Dark Blue", "Light Blue", "Green", "Yellow", "Orange", "Pink", "Purple", "Red"}
for i = 1, 8 do
    local sBtn = Instance.new("TextButton", SF)
    sBtn.Size = UDim2.new(1, 0, 0, 25); sBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sBtn.Text = baseNames[i] .. " Base"; sBtn.TextColor3 = Color3.new(1, 1, 1); sBtn.BorderSizePixel = 0
    sBtn.TextSize = 11
    sBtn.MouseButton1Click:Connect(function()
        local spawnPath = workspace:FindFirstChild("Spawn"..i)
        local magPart = spawnPath and spawnPath:FindFirstChild("MagnitudeCheck")
        if magPart then togglePart(magPart, sBtn, false, CAPTURE_SIZE) end
    end)
end

-- 9. RENDER LOOP
RunService.Stepped:Connect(function()
    if isNoclip and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local head = char and char:FindFirstChild("Head")
    
    if isGiveAllActive then
        local blocks = {"Rainbow","Diamond","Super","Lucky","Galaxy"}
        for _, b in pairs(blocks) do 
            local rem = ReplicatedStorage:FindFirstChild("Spawn"..b.."Block")
            if rem then rem:FireServer() end 
        end
    end

    if isCamActive and root then
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.new((root.CFrame * CFrame.new(CAM_OFFSET_DIST, 0, 0)).Position, root.Position)
    end

    if isFireMode and head then
        local headScreenPos, onScreen = camera:WorldToViewportPoint(head.Position)
        if onScreen then
            headButton.Position = UDim2.new(0, headScreenPos.X - 20, 0, headScreenPos.Y - 140)
        end
    end
end)
