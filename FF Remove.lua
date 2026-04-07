local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local pGui = player:WaitForChild("PlayerGui")

-- CONFIG
local UI_NAME = "FF_REMOVE_V23"
local PUSH_BACK_DIST = 40 
local CAM_OFFSET_DIST = 16  
local OFFSET_DIST = 30 
local SAFE_COORDS = Vector3.new(-1840.9, 301.1, 119.6)

local isCamActive = false
local isFireToggled = false
local isGiveAllActive = false
local ActiveObjects = {} 
local OriginalCFrames = {} -- NEW: Stores original positions
local qTrackingUntil = 0 

-- 1. UI SETUP
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local SG = Instance.new("ScreenGui", pGui)
SG.Name = UI_NAME
SG.ResetOnSpawn = false

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 180, 0, 360) 
MF.Position = UDim2.new(0.85, 0, 0.5, -180)
MF.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MF.Active = true; MF.Draggable = true; MF.BorderSizePixel = 0

local T = Instance.new("TextLabel", MF)
T.Size = UDim2.new(1, -30, 0, 30); T.BackgroundTransparency = 1
T.Text = "FF REMOVE"; T.TextColor3 = Color3.new(1, 1, 1)
T.Font = Enum.Font.Code; T.TextSize = 14

local CB = Instance.new("TextButton", MF)
CB.Size = UDim2.new(0, 30, 0, 30); CB.Position = UDim2.new(1, -30, 0, 0)
CB.BackgroundColor3 = Color3.fromRGB(200, 50, 50); CB.Text = "X"
CB.TextColor3 = Color3.new(1, 1, 1); CB.MouseButton1Click:Connect(function() SG:Destroy() end)

local function createBtn(text, yPos, color)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(1, 0, 0, 30); b.Position = UDim2.new(0, 0, 0, yPos)
    b.BackgroundColor3 = color or Color3.fromRGB(60, 60, 60)
    b.Text = text; b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Code; b.TextSize = 14; b.BorderSizePixel = 0
    return b
end

local alignBtn = createBtn("ALIGN", 30)
local giveAllBtn = createBtn("GIVE ALL: OFF", 60)
local fireToggle = createBtn("FIRE: OFF", 90)
local holdBtn = createBtn("MULTI HOLD", 120)
local outerFFBtn = createBtn("OUTER FF", 150, Color3.fromRGB(80, 40, 120))

-- MOBILE Q (200ms Delay)
local mobileQ = Instance.new("TextButton", SG)
mobileQ.Size = UDim2.new(0, 35, 0, 35) 
mobileQ.BackgroundColor3 = Color3.fromRGB(120, 120, 130); mobileQ.BackgroundTransparency = 0.4 
mobileQ.Text = "Q"; mobileQ.TextColor3 = Color3.new(1, 1, 1); mobileQ.Visible = false; mobileQ.ZIndex = 10
Instance.new("UICorner", mobileQ).CornerRadius = UDim.new(1, 0)

mobileQ.MouseButton1Click:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    task.wait(0.2) 
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
end)

-- 2. UNIVERSAL TOGGLE (With Return-To-Home Logic)
local function togglePart(part, button, isOuter)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not part then return end

    if ActiveObjects[part] then
        -- TOGGLE OFF: Send it back to where it was
        if OriginalCFrames[part] then
            part.CFrame = OriginalCFrames[part]
        end
        part.Transparency = 1
        part.CanQuery = false
        button.BackgroundColor3 = isOuter and Color3.fromRGB(45, 45, 45) or Color3.fromRGB(50, 50, 50)
        ActiveObjects[part] = nil
    else
        -- TOGGLE ON: Save current spot then move to safe zone
        if not OriginalCFrames[part] then
            OriginalCFrames[part] = part.CFrame
        end
        
        ActiveObjects[part] = true
        button.BackgroundColor3 = isOuter and Color3.fromRGB(0, 150, 255) or Color3.new(0.2, 0.5, 0.8)
        
        part.Size = Vector3.new(50, 50, 50)
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

-- 3. OUTER FF PANEL
local OF_Panel = Instance.new("Frame", SG)
OF_Panel.Size = UDim2.new(0, 220, 0, 400); OF_Panel.Position = UDim2.new(0.85, -230, 0.5, -200)
OF_Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20); OF_Panel.Visible = false
OF_Panel.Active = true; OF_Panel.Draggable = true; Instance.new("UICorner", OF_Panel)

local OF_Scroll = Instance.new("ScrollingFrame", OF_Panel)
OF_Scroll.Size = UDim2.new(1, -10, 1, -40); OF_Scroll.Position = UDim2.new(0, 5, 0, 35)
OF_Scroll.BackgroundTransparency = 1; OF_Scroll.CanvasSize = UDim2.new(0,0,0,0); OF_Scroll.ScrollBarThickness = 2
local OF_List = Instance.new("UIListLayout", OF_Scroll); OF_List.SortOrder = Enum.SortOrder.LayoutOrder

local baseInfo = {
    ["Spawn1"] = "Dark Blue Base", ["Spawn2"] = "Light Blue Base", ["Spawn3"] = "Green Base",
    ["Spawn4"] = "Yellow Base", ["Spawn5"] = "Orange Base", ["Spawn6"] = "Pink Base",
    ["Spawn7"] = "Purple Base", ["Spawn8"] = "Red Base"
}

local function populateOuterMenu()
    for _, child in ipairs(OF_Scroll:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
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
            label.Size = UDim2.new(1, 0, 0, 20); label.Text = "--- " .. baseName .. " ---"
            label.TextColor3 = Color3.fromRGB(0, 255, 150); label.BackgroundTransparency = 1
            for i, wallPart in ipairs(foundWalls[baseName]) do
                local wBtn = Instance.new("TextButton", OF_Scroll)
                wBtn.Size = UDim2.new(1, 0, 0, 25); wBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                wBtn.Text = "Wall " .. i; wBtn.TextColor3 = Color3.new(1,1,1); wBtn.BorderSizePixel = 0
                if ActiveObjects[wallPart] then wBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255) end
                wBtn.MouseButton1Click:Connect(function() togglePart(wallPart, wBtn, true) end)
            end
        end
    end
    OF_Scroll.CanvasSize = UDim2.new(0,0,0, OF_List.AbsoluteContentSize.Y)
end

outerFFBtn.MouseButton1Click:Connect(function()
    OF_Panel.Visible = not OF_Panel.Visible
    if OF_Panel.Visible then populateOuterMenu() end
end)

-- 4. ALIGN & MAIN SELECTOR
alignBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        isCamActive = not isCamActive
        alignBtn.BackgroundColor3 = isCamActive and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(60, 60, 60)
        if not isCamActive then camera.CameraType = Enum.CameraType.Custom end
        if isCamActive then
            root.CFrame = root.CFrame * CFrame.new(0, 0, PUSH_BACK_DIST) * CFrame.Angles(0, math.rad(-90), 0)
        end
    end
end)

local SF = Instance.new("ScrollingFrame", MF)
SF.Size = UDim2.new(1, 0, 1, -185); SF.Position = UDim2.new(0, 0, 0, 185)
SF.BackgroundTransparency = 1; SF.ScrollBarThickness = 2 
local UIListMain = Instance.new("UIListLayout", SF)

local baseNames = {"Dark Blue Base", "Light Blue Base", "Green Base", "Yellow Base", "Orange Base", "Pink Base", "Purple Base", "Red Base"}

for i = 1, 8 do
    local sBtn = Instance.new("TextButton", SF)
    sBtn.Size = UDim2.new(1, 0, 0, 22); sBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sBtn.Text = baseNames[i]; sBtn.TextColor3 = Color3.new(1, 1, 1); sBtn.BorderSizePixel = 0
    sBtn.MouseButton1Click:Connect(function()
        local spawnPath = workspace:FindFirstChild("Spawn"..i)
        local magPart = spawnPath and spawnPath:FindFirstChild("MagnitudeCheck")
        if magPart then togglePart(magPart, sBtn, false) end
    end)
end

-- 5. BUTTONS
giveAllBtn.MouseButton1Click:Connect(function()
    isGiveAllActive = not isGiveAllActive
    giveAllBtn.Text = isGiveAllActive and "GIVE ALL: ON" or "GIVE ALL: OFF"
    giveAllBtn.BackgroundColor3 = isGiveAllActive and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 60)
end)

fireToggle.MouseButton1Click:Connect(function()
    isFireToggled = not isFireToggled
    mobileQ.Visible = isFireToggled
    fireToggle.Text = isFireToggled and "FIRE: ON" or "FIRE: OFF"
    fireToggle.BackgroundColor3 = isFireToggled and Color3.fromRGB(150, 100, 50) or Color3.fromRGB(60, 60, 60)
    if isFireToggled then qTrackingUntil = tick() + 0.5 end
end)

holdBtn.MouseButton1Click:Connect(function()
    local bp = player:FindFirstChild("Backpack")
    local tool = bp and bp:FindFirstChild("IvoryPeriastron")
    if tool and player.Character then tool.Parent = player.Character end
end)

-- 6. RENDER LOOP
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
    if head and isFireToggled and tick() < qTrackingUntil then
        local headScreenPos, onScreen = camera:WorldToViewportPoint(head.Position)
        if onScreen then mobileQ.Position = UDim2.new(0, headScreenPos.X - 17, 0, headScreenPos.Y - 100) end
    end
    if isCamActive and root then
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.new((root.CFrame * CFrame.new(CAM_OFFSET_DIST, 0, 0)).Position, root.Position)
    end
end)
SF.CanvasSize = UDim2.new(0, 0, 0, UIListMain.AbsoluteContentSize.Y)
