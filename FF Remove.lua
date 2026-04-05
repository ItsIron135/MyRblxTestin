local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local pGui = player:WaitForChild("PlayerGui")

-- CONFIG
local UI_NAME = "FF_REMOVE_FINAL_MOBILE_FIX"
local PUSH_BACK_DIST = 40 
local CAM_OFFSET_DIST = 16  
local CAM_HEIGHT_OFFSET = -1.5

-- Fallback default position
local Q_BUTTON_X_SCALE = 0.75  
local Q_BUTTON_Y_SCALE = 0.60  
local Q_BUTTON_X_OFFSET = 0    
local Q_BUTTON_Y_OFFSET = 0    

local isCamActive = false
local isFireToggled = false
local TargetObject = nil 
local qTrackingUntil = 0 
local activeSpawnBtn = nil 

-- 1. UI SETUP 
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local SG = Instance.new("ScreenGui", pGui)
SG.Name = UI_NAME
SG.ResetOnSpawn = false

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 180, 0, 300) 
MF.Position = UDim2.new(0.85, 0, 0.5, -150)
MF.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MF.Active = true
MF.Draggable = true
MF.BorderSizePixel = 0

local T = Instance.new("TextLabel", MF)
T.Size = UDim2.new(1, -30, 0, 30)
T.BackgroundTransparency = 1
T.Text = "FF REMOVE"
T.TextColor3 = Color3.new(1, 1, 1)
T.Font = Enum.Font.Code
T.TextSize = 16

local CB = Instance.new("TextButton", MF)
CB.Size = UDim2.new(0, 30, 0, 30)
CB.Position = UDim2.new(1, -30, 0, 0)
CB.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CB.Text = "X"
CB.TextColor3 = Color3.new(1, 1, 1)
CB.Font = Enum.Font.Code
CB.TextSize = 16
CB.BorderSizePixel = 0

local function createBtn(text, yPos)
    local b = Instance.new("TextButton", MF)
    b.Size = UDim2.new(1, 0, 0, 30)
    b.Position = UDim2.new(0, 0, 0, yPos)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Code
    b.TextSize = 14
    b.BorderSizePixel = 0
    return b
end

local fireToggle = createBtn("FIRE: OFF", 30)
local holdBtn = createBtn("MULTI HOLD", 60)

-- FLOATING Q BUTTON (Restored and Fixed)
local mobileQ = Instance.new("TextButton", SG)
mobileQ.Size = UDim2.new(0, 35, 0, 35) 
mobileQ.Position = UDim2.new(Q_BUTTON_X_SCALE, Q_BUTTON_X_OFFSET, Q_BUTTON_Y_SCALE, Q_BUTTON_Y_OFFSET)
mobileQ.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
mobileQ.BackgroundTransparency = 0.5 
mobileQ.Text = "Q"
mobileQ.TextColor3 = Color3.new(1, 1, 1)
mobileQ.TextTransparency = 0.2 
mobileQ.Font = Enum.Font.Code
mobileQ.TextSize = 18 
mobileQ.Visible = false
mobileQ.ZIndex = 10
Instance.new("UICorner", mobileQ).CornerRadius = UDim.new(1, 0)

-- 2. Q BUTTON LOGIC (SENDS Q TWICE)
mobileQ.MouseButton1Click:Connect(function()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    
    pcall(function()
        game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
        task.wait(0.1)
        game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
    end)
end)

fireToggle.MouseButton1Click:Connect(function()
    isFireToggled = not isFireToggled
    mobileQ.Visible = isFireToggled
    fireToggle.Text = isFireToggled and "FIRE: ON" or "FIRE: OFF"
    fireToggle.BackgroundColor3 = isFireToggled and Color3.fromRGB(150, 100, 50) or Color3.fromRGB(60, 60, 60)
    
    if isFireToggled then
        qTrackingUntil = tick() + 0.5
    end
end)

holdBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    local bp = player:FindFirstChild("Backpack")
    if bp and char then
        local tool = bp:FindFirstChild("IvoryPeriastron")
        if tool then tool.Parent = char end
    end
end)

-- 4. RENDER STEPPED (CAMERA & Q TRACKING)
RunService.RenderStepped:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local head = char and char:FindFirstChild("Head")

    if head and isFireToggled then
        if tick() < qTrackingUntil then
            local headScreenPos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                mobileQ.Position = UDim2.new(0, headScreenPos.X - 17, 0, headScreenPos.Y - 100) 
            end
        end
    end

    if isCamActive and root then
        camera.CameraType = Enum.CameraType.Scriptable
        local steadyBasePos = root.Position + Vector3.new(0, 1.5, 0) 
        local camPos = (root.CFrame * CFrame.new(CAM_OFFSET_DIST, CAM_HEIGHT_OFFSET + 1.5, 0)).Position
        camera.CFrame = CFrame.new(camPos, steadyBasePos)
    end
end)

-- 5. SPAWN DROPDOWN (RENAMED BASES)
local SF = Instance.new("ScrollingFrame", MF)
SF.Size = UDim2.new(1, 0, 1, -90) 
SF.Position = UDim2.new(0, 0, 0, 90)
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

local baseNames = {
    "Dark Blue Base",
    "Light Blue Base",
    "Green Base",
    "Yellow Base",
    "Orange Base",
    "Pink Base",
    "Purple Base",
    "Red Base"
}

for i = 1, 8 do
    local sBtn = Instance.new("TextButton", SF)
    sBtn.Size = UDim2.new(1, 0, 0, 25)
    sBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sBtn.Text = baseNames[i]
    sBtn.TextColor3 = Color3.new(1, 1, 1)
    sBtn.Font = Enum.Font.Code
    sBtn.TextSize = 12
    sBtn.BorderSizePixel = 0
    
    sBtn.MouseButton1Click:Connect(function()
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if activeSpawnBtn == sBtn then
            sBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            sBtn.TextColor3 = Color3.new(1, 1, 1)
            activeSpawnBtn = nil
            if TargetObject then TargetObject.Transparency = 1 end
            isCamActive = false
            camera.CameraType = Enum.CameraType.Custom
            if hum then camera.CameraSubject = hum end
            return
        end
        
        if activeSpawnBtn then
            activeSpawnBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            activeSpawnBtn.TextColor3 = Color3.new(1, 1, 1)
        end
        sBtn.BackgroundColor3 = Color3.new(1, 1, 1) 
        sBtn.TextColor3 = Color3.new(0, 0, 0)      
        activeSpawnBtn = sBtn
        
        if TargetObject then TargetObject.Transparency = 1 end
        local spawnPath = workspace:FindFirstChild("Spawn"..i)
        
        if spawnPath and spawnPath:FindFirstChild("MagnitudeCheck") and root then
            root.CFrame = CFrame.new(-1840.9, 301.1, 119.6)
            task.wait(0.1) 
            
            TargetObject = spawnPath.MagnitudeCheck
            TargetObject:BreakJoints() 
            TargetObject.Anchored = true 
            TargetObject.CanCollide = false 
            TargetObject.Size = Vector3.new(50, 50, 50)
            TargetObject.Transparency = 0.5
            TargetObject.Color = Color3.fromRGB(255, 0, 0)
            
            TargetObject.CFrame = CFrame.new(root.Position.X, root.Position.Y + 25, root.Position.Z)
            
            task.wait(0.1) 
            
            local bp = player:FindFirstChild("Backpack")
            if bp and hum then
                local bow = bp:FindFirstChild("OrnateGoldenBow")
                if bow then hum:EquipTool(bow) end
            end
            
            local blockPos = TargetObject.Position
            local edgePos = blockPos + Vector3.new(0, 0, PUSH_BACK_DIST + 25) 
            edgePos = Vector3.new(edgePos.X, root.Position.Y, edgePos.Z)
            
            local lookCFrame = CFrame.lookAt(edgePos, Vector3.new(blockPos.X, edgePos.Y, blockPos.Z))
            root.CFrame = lookCFrame * CFrame.Angles(0, math.rad(-90), 0)
            
            isCamActive = true
        end
    end)
end

CB.MouseButton1Click:Connect(function() 
    isCamActive = false
    camera.CameraType = Enum.CameraType.Custom
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then camera.CameraSubject = hum end
    SG:Destroy() 
end)
