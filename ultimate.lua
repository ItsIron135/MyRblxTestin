-- [[ ROCKET ADMIN V29: RESPONSIVE EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V29"
local isLooping = false
local targetLock = false
local isGiveAllActive = false
local isStackingActive = false
local lockConnection = nil

-- 1. UI SETUP
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 200, 0, 320)
main.Position = UDim2.new(0.5, -100, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "ROCKET ADMIN V29"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

local xBtn = Instance.new("TextButton", main)
xBtn.Size = UDim2.new(0, 25, 0, 25)
xBtn.Position = UDim2.new(1, -30, 0, 5)
xBtn.Text = "X"
xBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
xBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", xBtn)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0.35, 0)
scroll.Position = UDim2.new(0.05, 0, 0.12, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. STACKING & FIRING (High Priority)
task.spawn(function()
    while true do
        local char = player.Character
        local bp = player:FindFirstChild("Backpack")
        
        if char and bp then
            -- MULTI-EQUIP LOGIC
            if isStackingActive then
                for _, item in ipairs(bp:GetChildren()) do
                    if item.Name == "Rocket Jumper" then
                        item.Parent = char
                    end
                end
            end
            
            -- FIRING LOGIC
            if isLooping then
                for _, item in ipairs(char:GetChildren()) do
                    if item:IsA("Tool") and item.Name == "Rocket Jumper" then
                        item:Activate()
                    end
                end
            end
        end
        task.wait(0.03) -- Faster refresh for stacking
    end
end)

-- 3. GIVE ALL (Lower Priority to prevent lag)
task.spawn(function()
    local blocks = {"SpawnDiamondBlock", "SpawnGalaxyBlock", "SpawnLuckyBlock", "SpawnRainbowBlock", "SpawnSuperBlock"}
    while true do
        if isGiveAllActive then
            for _, b in pairs(blocks) do
                local remote = RS:FindFirstChild(b)
                if remote then pcall(function() remote:FireServer() end) end
            end
            task.wait(0.8) -- Slowed down to prevent "Sluggish" feeling
        else
            task.wait(1)
        end
    end
end)

-- 4. CARROT BUFF
task.spawn(function()
    while true do
        if isStackingActive then
            local bp = player:FindFirstChild("Backpack")
            local char = player.Character
            local carrot = (bp and bp:FindFirstChild("Carrot")) or (char and char:FindFirstChild("Carrot"))
            if carrot and char then
                carrot.Parent = char
                task.wait(0.1)
                carrot:Activate()
                task.wait(0.1)
                carrot.Parent = player:FindFirstChild("Backpack")
            end
        end
        task.wait(31)
    end
end)

-- 5. BUTTON BUILDER (Fixed Colors)
local function createBtn(txtOn, txtOff, y, getVal, setVal)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    b.Text = txtOff
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b)
    
    local function updateVisuals()
        local active = getVal()
        b.Text = active and txtOn or txtOff
        b.BackgroundColor3 = active and Color3.fromRGB(80, 20, 20) or Color3.fromRGB(40, 40, 45)
    end

    b.MouseButton1Click:Connect(function()
        setVal(not getVal())
        updateVisuals()
    end)
end

createBtn("LOOP: ON", "LOOP: OFF", 160, function() return isLooping end, function(v) isLooping = v end)
createBtn("GIVE ALL: ON", "GIVE ALL: OFF", 195, function() return isGiveAllActive end, function(v) isGiveAllActive = v end)
createBtn("INF STACK: ON", "INF STACK: OFF", 230, function() return isStackingActive end, function(v) isStackingActive = v end)

-- 6. PLAYER LIST
local function updateList()
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", scroll)
            b.Size = UDim2.new(1, -5, 0, 25)
            b.Text = p.Name
            b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            b.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                targetLock = true
                if lockConnection then lockConnection:Disconnect() end
                lockConnection = RunService.Heartbeat:Connect(function()
                    if not targetLock or not p.Character or not player.Character then return end
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    local head = p.Character:FindFirstChild("Head")
                    if root and head then
                        root.CFrame = head.CFrame * CFrame.new(0, 3, 0)
                        root.Velocity = Vector3.new(0,0,0)
                    end
                end)
            end)
        end
    end
end

xBtn.MouseButton1Click:Connect(function() sg:Destroy() isLooping = false isStackingActive = false targetLock = false end)
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
