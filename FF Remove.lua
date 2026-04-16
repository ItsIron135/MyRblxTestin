local P, VIM, RS, UIS = game:GetService("Players"), game:GetService("VirtualInputManager"), game:GetService("RunService"), game:GetService("UserInputService")
local plr = P.LocalPlayer
local cam = workspace.CurrentCamera
local pGui = plr:WaitForChild("PlayerGui")

local UI_NAME = "FF_REMOVE_MAPMOVE_V7"
local PUSH_BACK_DIST, CAM_OFFSET_DIST, OFFSET_DIST = 45, 16, 30 
local SAFE_COORDS, FAR_AWAY_COORDS = Vector3.new(-1840.9, 301.1, 119.6), Vector3.new(99999, 99999, 99999)
local CAPTURE_SIZE, CLONE_SIZE = Vector3.new(50, 50, 50), Vector3.new(15, 15, 15)

local baseInfo = {Spawn1="Dark Blue", Spawn2="Light Blue", Spawn3="Green", Spawn4="Yellow", Spawn5="Orange", Spawn6="Pink", Spawn7="Purple", Spawn8="Red"}

local isCamActive, isFireMode = false, false
local ActiveObjects, OrigCFs, OrigApp = {}, {}, {} 

if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local SG = Instance.new("ScreenGui", pGui)
SG.Name, SG.ResetOnSpawn = UI_NAME, false

local MF = Instance.new("Frame", SG)
MF.Size, MF.Position, MF.BackgroundColor3, MF.Active, MF.Draggable, MF.BorderSizePixel = UDim2.new(0, 180, 0, 325), UDim2.new(0.85, 0, 0.5, -192), Color3.fromRGB(30, 30, 30), true, true, 0

local T = Instance.new("TextLabel", MF)
T.Size, T.BackgroundTransparency, T.Text, T.TextColor3, T.Font, T.TextSize = UDim2.new(1, -30, 0, 30), 1, "FF REMOVER", Color3.new(1, 1, 1), Enum.Font.Code, 14

local headBtn = Instance.new("TextButton", SG)
headBtn.Size, headBtn.BackgroundColor3, headBtn.BackgroundTransparency, headBtn.Text, headBtn.TextColor3, headBtn.Visible, headBtn.ZIndex = UDim2.new(0, 40, 0, 40), Color3.fromRGB(255, 50, 50), 0.3, "GO", Color3.new(1, 1, 1), false, 10
Instance.new("UICorner", headBtn).CornerRadius = UDim.new(1, 0)

local function cleanupScanner()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name == "ScannerLabel" or v.Name == "ScanHigh" then v:Destroy() end
    end
end

local function createBtn(txt, yPos, color)
    local b = Instance.new("TextButton", MF)
    b.Size, b.Position, b.BackgroundColor3, b.Text, b.TextColor3, b.Font, b.TextSize, b.BorderSizePixel = UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, yPos), color or Color3.fromRGB(60, 60, 60), txt, Color3.new(1, 1, 1), Enum.Font.Code, 13, 0
    return b
end

local CB = Instance.new("TextButton", MF)
CB.Size, CB.Position, CB.BackgroundColor3, CB.Text, CB.TextColor3 = UDim2.new(0, 30, 0, 30), UDim2.new(1, -30, 0, 0), Color3.fromRGB(200, 50, 50), "X", Color3.new(1, 1, 1)
CB.MouseButton1Click:Connect(function() cleanupScanner(); SG:Destroy() end)

local function runMapMoveAutomation()
    local char, bp = plr.Character, plr:FindFirstChild("Backpack")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not bp then return end

    root.CFrame = root.CFrame * CFrame.new(0, 0, PUSH_BACK_DIST) * CFrame.Angles(0, math.rad(-90), 0)
    isCamActive = true
    
    local bow = bp:FindFirstChild("OrnateGoldenBow")
    if bow then char.Humanoid:EquipTool(bow) end
    
    task.wait(0.6)
    VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game); VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    task.wait(0.2) 
    VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game); VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    task.wait(1.0)
    
    if not char:FindFirstChild("IvoryPeriastron") then
        local ivory = bp:FindFirstChild("IvoryPeriastron")
        if ivory then ivory.Parent = char end
    end
    task.wait(0.2)
    isCamActive, cam.CameraType = false, Enum.CameraType.Custom
end

local function togglePart(part, btn, isOuter, tSize)
    local char = plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not part then return end

    if ActiveObjects[part] then
        if OrigCFs[part] then part.CFrame = OrigCFs[part] end
        if OrigApp[part] then
            local oa = OrigApp[part]
            part.Size, part.Transparency, part.Color, part.Anchored, part.CanCollide, part.CanQuery = oa.Size, oa.Transparency, oa.Color, oa.Anchored, oa.CanCollide, oa.CanQuery
        else part.Transparency = 1 end
        
        part.AssemblyLinearVelocity = Vector3.new(0, 0.1, 0)
        btn.BackgroundColor3 = isOuter and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(50, 50, 50)
        ActiveObjects[part] = nil
    else
        if not OrigCFs[part] then OrigCFs[part] = part.CFrame end
        if not OrigApp[part] then OrigApp[part] = {Size=part.Size, Transparency=part.Transparency, Color=part.Color, Anchored=part.Anchored, CanCollide=part.CanCollide, CanQuery=part.CanQuery} end
        
        ActiveObjects[part], btn.BackgroundColor3 = true, isOuter and Color3.fromRGB(0, 150, 255) or Color3.new(0.2, 0.5, 0.8)
        part.AssemblyLinearVelocity = Vector3.new(0, 0.1, 0) 
        part.Size, part.Transparency, part.Color, part.Anchored, part.CanCollide, part.CanQuery, part.CFrame = tSize or CAPTURE_SIZE, 0.5, Color3.fromRGB(255, 0, 0), true, false, true, CFrame.new(SAFE_COORDS)
        
        root.CFrame = CFrame.new(SAFE_COORDS + Vector3.new(0, 0, OFFSET_DIST))
        task.wait(0.05)
        root.CFrame = CFrame.lookAt(root.Position, part.Position)
    end
end

local fireToggle = createBtn("FIRE MODE: OFF", 30)
local outerFFBtn = createBtn("OUTER FF", 60, Color3.fromRGB(80, 40, 120))
local scanMenuBtn = createBtn("OBJ SCANNER", 90, Color3.fromRGB(0, 100, 150))

fireToggle.MouseButton1Click:Connect(function()
    isFireMode = not isFireMode
    headBtn.Visible = isFireMode
    fireToggle.Text, fireToggle.BackgroundColor3 = isFireMode and "FIRE MODE: ON" or "FIRE MODE: OFF", isFireMode and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(60, 60, 60)
end)
headBtn.MouseButton1Click:Connect(runMapMoveAutomation)

local OF_Panel = Instance.new("Frame", SG)
OF_Panel.Size, OF_Panel.Position, OF_Panel.BackgroundColor3, OF_Panel.Visible, OF_Panel.Active, OF_Panel.Draggable = UDim2.new(0, 220, 0, 400), UDim2.new(0.85, -230, 0.5, -200), Color3.fromRGB(20, 20, 20), false, true, true
Instance.new("UICorner", OF_Panel)

local OF_Scroll = Instance.new("ScrollingFrame", OF_Panel)
OF_Scroll.Size, OF_Scroll.Position, OF_Scroll.BackgroundTransparency, OF_Scroll.CanvasSize, OF_Scroll.ScrollBarThickness, OF_Scroll.Active = UDim2.new(1, -10, 1, -40), UDim2.new(0, 5, 0, 35), 1, UDim2.new(0,0,0,0), 2, true
local OF_List = Instance.new("UIListLayout", OF_Scroll); OF_List.SortOrder = Enum.SortOrder.LayoutOrder

local function populateOuterMenu()
    for _, c in ipairs(OF_Scroll:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
    
    local clLbl = Instance.new("TextLabel", OF_Scroll)
    clLbl.Size, clLbl.Text, clLbl.TextColor3, clLbl.BackgroundTransparency, clLbl.Font, clLbl.TextSize = UDim2.new(1, 0, 0, 30), "--- Spectral Clones ---", Color3.fromRGB(255, 50, 50), 1, Enum.Font.Code, 13
    
    local cCount, fWalls, expName = 0, {}, plr.Name .. "'s Clone"

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == expName then
            local t = v:FindFirstChild("Torso") or v:FindFirstChild("UpperTorso") or v:FindFirstChild("HumanoidRootPart")
            if t and t:IsA("BasePart") then
                cCount = cCount + 1
                local cB = Instance.new("TextButton", OF_Scroll)
                cB.Size, cB.BackgroundColor3, cB.Text, cB.TextColor3, cB.BorderSizePixel = UDim2.new(1, 0, 0, 25), ActiveObjects[t] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45), "["..cCount.."] Clone Torso", Color3.new(1,1,1), 0
                cB.MouseButton1Click:Connect(function() togglePart(t, cB, true, CLONE_SIZE) end)
            end
        end
        if v.Name == "SpawnWalls" and v:IsA("BasePart") then
            for sK, bN in pairs(baseInfo) do
                if v:GetFullName():find(sK) then fWalls[bN] = fWalls[bN] or {}; table.insert(fWalls[bN], v) end
            end
        end
    end

    if cCount == 0 then
        local nLbl = Instance.new("TextLabel", OF_Scroll)
        nLbl.Size, nLbl.Text, nLbl.TextColor3, nLbl.BackgroundTransparency, nLbl.Font, nLbl.TextSize = UDim2.new(1, 0, 0, 20), "No active clones found.", Color3.fromRGB(150, 150, 150), 1, Enum.Font.Code, 11
    end

    local aWB = Instance.new("TextButton", OF_Scroll)
    aWB.Size, aWB.BackgroundColor3, aWB.Text, aWB.TextColor3, aWB.Font, aWB.TextSize, aWB.BorderSizePixel = UDim2.new(1, 0, 0, 30), Color3.fromRGB(120, 40, 40), "[ TELEPORT ALL WALLS ]", Color3.new(1, 1, 1), Enum.Font.Code, 13, 0

    local aWTog, wBM = false, {} 
    aWB.MouseButton1Click:Connect(function()
        aWTog, aWB.BackgroundColor3 = not aWTog, not aWTog and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(120, 40, 40)
        for p, b in pairs(wBM) do
            if aWTog and not ActiveObjects[p] then
                if not OrigCFs[p] then OrigCFs[p] = p.CFrame end
                if not OrigApp[p] then OrigApp[p] = {Size=p.Size, Transparency=p.Transparency, Color=p.Color, Anchored=p.Anchored, CanCollide=p.CanCollide, CanQuery=p.CanQuery} end
                ActiveObjects[p], b.BackgroundColor3 = true, Color3.fromRGB(0, 150, 255)
                p.AssemblyLinearVelocity = Vector3.new(0, 0.1, 0) 
                p.Size, p.Transparency, p.Color, p.Anchored, p.CanCollide, p.CanQuery, p.CFrame = CAPTURE_SIZE, 0.5, Color3.fromRGB(255, 0, 0), true, false, true, CFrame.new(FAR_AWAY_COORDS)
            elseif not aWTog and ActiveObjects[p] then
                if OrigCFs[p] then p.CFrame = OrigCFs[p] end
                if OrigApp[p] then
                    local oa = OrigApp[p]
                    p.Size, p.Transparency, p.Color, p.Anchored, p.CanCollide, p.CanQuery = oa.Size, oa.Transparency, oa.Color, oa.Anchored, oa.CanCollide, oa.CanQuery
                else p.Transparency = 1 end
                p.AssemblyLinearVelocity, b.BackgroundColor3, ActiveObjects[p] = Vector3.new(0, 0.1, 0), Color3.fromRGB(45, 45, 45), nil
            end
        end
    end)

    for _, bN in pairs(baseInfo) do
        if fWalls[bN] then
            local lbl = Instance.new("TextLabel", OF_Scroll)
            lbl.Size, lbl.Text, lbl.TextColor3, lbl.BackgroundTransparency, lbl.Font, lbl.TextSize = UDim2.new(1, 0, 0, 25), "--- " .. bN .. " ---", Color3.fromRGB(0, 255, 150), 1, Enum.Font.Code, 13
            for i, wP in ipairs(fWalls[bN]) do
                local wB = Instance.new("TextButton", OF_Scroll)
                wB.Size, wB.BackgroundColor3, wB.Text, wB.TextColor3, wB.BorderSizePixel = UDim2.new(1, 0, 0, 25), ActiveObjects[wP] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45), "Wall " .. i, Color3.new(1,1,1), 0
                wBM[wP] = wB 
                wB.MouseButton1Click:Connect(function() togglePart(wP, wB, true, CAPTURE_SIZE) end)
            end
        end
    end

    local ffLbl = Instance.new("TextLabel", OF_Scroll)
    ffLbl.Size, ffLbl.Text, ffLbl.TextColor3, ffLbl.BackgroundTransparency, ffLbl.Font, ffLbl.TextSize = UDim2.new(1, 0, 0, 30), "--- Terrain ForceFields ---", Color3.fromRGB(255, 150, 0), 1, Enum.Font.Code, 13

    for i = 1, 8 do
        local tF = workspace:FindFirstChild("Terrain" .. i)
        local ff = tF and tF:FindFirstChild("ForceFields")
        if ff then
            local fB = Instance.new("TextButton", OF_Scroll)
            fB.Size, fB.BackgroundColor3, fB.Text, fB.TextColor3, fB.BorderSizePixel = UDim2.new(1, 0, 0, 25), ActiveObjects[ff] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45), "["..i.."] Terrain FF", Color3.new(1,1,1), 0
            fB.MouseButton1Click:Connect(function() togglePart(ff, fB, true, CAPTURE_SIZE) end)
        end
    end

    local spLbl = Instance.new("TextLabel", OF_Scroll)
    spLbl.Size, spLbl.Text, spLbl.TextColor3, spLbl.BackgroundTransparency, spLbl.Font, spLbl.TextSize = UDim2.new(1, 0, 0, 30), "--- SpawnLocations ---", Color3.fromRGB(0, 200, 255), 1, Enum.Font.Code, 13

    for i = 1, 8 do
        local bF = workspace:FindFirstChild("Spawn" .. i)
        local lP = bF and bF:FindFirstChild("SpawnLocation")
        if lP then
            local lB = Instance.new("TextButton", OF_Scroll)
            lB.Size, lB.BackgroundColor3, lB.Text, lB.TextColor3, lB.BorderSizePixel = UDim2.new(1, 0, 0, 25), ActiveObjects[lP] and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 45), "["..i.."] SpawnLocation", Color3.new(1,1,1), 0
            lB.MouseButton1Click:Connect(function() togglePart(lP, lB, true, CAPTURE_SIZE) end)
        end
    end
    OF_Scroll.CanvasSize = UDim2.new(0,0,0, OF_List.AbsoluteContentSize.Y)
end

outerFFBtn.MouseButton1Click:Connect(function() OF_Panel.Visible = not OF_Panel.Visible; if OF_Panel.Visible then populateOuterMenu() end end)

local ObjFrame = Instance.new("Frame", SG)
ObjFrame.Size, ObjFrame.Position, ObjFrame.BackgroundColor3, ObjFrame.Visible, ObjFrame.Active, ObjFrame.Draggable = UDim2.new(0, 220, 0, 340), UDim2.new(0.85, -230, 0.5, -170), Color3.fromRGB(25, 25, 25), false, true, true
Instance.new("UICorner", ObjFrame)

local ObjSF = Instance.new("ScrollingFrame", ObjFrame)
ObjSF.Size, ObjSF.Position, ObjSF.BackgroundTransparency, ObjSF.ScrollBarThickness = UDim2.new(1, -10, 1, -80), UDim2.new(0, 5, 0, 35), 1, 2
local ObjList = Instance.new("UIListLayout", ObjSF); ObjList.SortOrder = Enum.SortOrder.LayoutOrder

local ScanBtnAction = Instance.new("TextButton", ObjFrame)
ScanBtnAction.Size, ScanBtnAction.Position, ScanBtnAction.BackgroundColor3, ScanBtnAction.Text, ScanBtnAction.TextColor3, ScanBtnAction.Font = UDim2.new(0.9, 0, 0, 30), UDim2.new(0.05, 0, 1, -40), Color3.fromRGB(0, 100, 200), "SCAN AREA", Color3.new(1, 1, 1), Enum.Font.Code
Instance.new("UICorner", ScanBtnAction)

ScanBtnAction.MouseButton1Click:Connect(function()
    cleanupScanner()
    for _, i in ipairs(ObjSF:GetChildren()) do if i:IsA("Frame") then i:Destroy() end end
    
    local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local f = 0
    for _, p in ipairs(workspace:GetPartBoundsInBox(root.CFrame, Vector3.new(35,35,35))) do
        if p:IsA("BasePart") and not p:IsDescendantOf(plr.Character) then
            f = f + 1; local c = Color3.fromHSV(f/15, 0.8, 1)
            local high = Instance.new("Highlight", workspace); high.Name, high.Adornee, high.FillColor, high.OutlineColor = "ScanHigh", p, c, c
            
            local bgui = Instance.new("BillboardGui", p); bgui.Name, bgui.Size, bgui.AlwaysOnTop, bgui.ExtentsOffset = "ScannerLabel", UDim2.new(0, 50, 0, 50), true, Vector3.new(0,3,0)
            local tl = Instance.new("TextLabel", bgui); tl.Size, tl.BackgroundTransparency, tl.Text, tl.TextColor3, tl.Font, tl.TextSize = UDim2.new(1,0,1,0), 1, tostring(f), c, Enum.Font.Code, 25

            local row = Instance.new("Frame", ObjSF)
            row.Size, row.BackgroundColor3 = UDim2.new(1,0,0,35), Color3.fromRGB(40,40,40); Instance.new("UICorner", row)
            
            local l = Instance.new("TextLabel", row)
            l.Size, l.Text, l.TextColor3, l.BackgroundTransparency, l.TextSize, l.Position = UDim2.new(0.4,0,1,0), "["..f.."] "..p.Name:sub(1,10), c, 1, 10, UDim2.new(0,5,0,0)
            
            local tpB = Instance.new("TextButton", row)
            tpB.Size, tpB.Position, tpB.Text, tpB.BackgroundColor3, tpB.TextColor3 = UDim2.new(0.2,0,0.8,0), UDim2.new(0.45,0,0.1,0), "TP", Color3.fromRGB(0,80,40), Color3.new(1,1,1)
            
            local backB = Instance.new("TextButton", row)
            backB.Size, backB.Position, backB.Text, backB.BackgroundColor3, backB.TextColor3 = UDim2.new(0.25,0,0.8,0), UDim2.new(0.7,0,0.1,0), "BACK", Color3.fromRGB(150,20,20), Color3.new(1,1,1)
            
            tpB.MouseButton1Click:Connect(function() togglePart(p, tpB, false, CAPTURE_SIZE) end)
            backB.MouseButton1Click:Connect(function() if ActiveObjects[p] then togglePart(p, tpB, false, CAPTURE_SIZE) end end)
        end
    end
    ObjSF.CanvasSize = UDim2.new(0,0,0, ObjList.AbsoluteContentSize.Y)
end)

scanMenuBtn.MouseButton1Click:Connect(function() ObjFrame.Visible = not ObjFrame.Visible; if not ObjFrame.Visible then cleanupScanner() end end)

local SF = Instance.new("Frame", MF)
SF.Size, SF.Position, SF.BackgroundTransparency = UDim2.new(1, 0, 0, 205), UDim2.new(0, 0, 0, 120), 1
Instance.new("UIListLayout", SF)

for i = 1, 8 do
    local sBtn = Instance.new("TextButton", SF)
    sBtn.Size, sBtn.BackgroundColor3, sBtn.Text, sBtn.TextColor3, sBtn.BorderSizePixel, sBtn.TextSize = UDim2.new(1, 0, 0, 25), Color3.fromRGB(50, 50, 50), baseInfo["Spawn"..i] .. " Base", Color3.new(1, 1, 1), 0, 11
    sBtn.MouseButton1Click:Connect(function()
        local sP = workspace:FindFirstChild("Spawn"..i)
        local magP = sP and sP:FindFirstChild("MagnitudeCheck")
        if magP then togglePart(magP, sBtn, false, CAPTURE_SIZE) end
    end)
end

RS.RenderStepped:Connect(function()
    local char = plr.Character
    local root, head = char and char:FindFirstChild("HumanoidRootPart"), char and char:FindFirstChild("Head")

    if isCamActive and root then
        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = CFrame.new((root.CFrame * CFrame.new(CAM_OFFSET_DIST, 0, 0)).Position, root.Position)
    end

    if isFireMode and head then
        local headPos, onScr = cam:WorldToViewportPoint(head.Position)
        if onScr then headBtn.Position = UDim2.new(0, headPos.X - 20, 0, headPos.Y - 140) end
    end
end)
