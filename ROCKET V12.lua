-- [[ ROCKET ADMIN V28: SYNC & STABILITY ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- CONFIG & FLAGS
local UI_NAME = "RocketAdmin_V28"
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
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "ROCKET ADMIN V28"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

local xBtn = Instance.new("TextButton", main)
xBtn.Size = UDim2.new(0, 25, 0, 25)
xBtn.Position = UDim2.new(1, -30, 0, 5)
xBtn.Text = "X"
xBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
xBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", xBtn)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0.35, 0)
scroll.Position = UDim2.new(0.05, 0, 0.12, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. STABILITY UTILS
local function getJumpers()
    local found = {}
    local locations = {player.Backpack, player.Character}
    for _, loc in pairs(locations) do
        if loc then
            for _, tool in pairs(loc:GetChildren()) do
                if tool:IsA("Tool") and tool.Name == "Rocket Jumper" then
                    table.insert(found, tool)
                end
            end
        end
    end
    return found
end

-- Void Protection
task.spawn(function()
    while true do
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root and root.Position.Y < -70 then
            root.Velocity = Vector3.new(0,0,0)
            root.CFrame = CFrame.new(root.Position.X, 100, root.Position.Z)
        end
        task.wait(0.2)
    end
end)

-- 3. THE COMBINED ACTION LOOP (Stack + Fire)
task.spawn(function()
    while true do
        if isLooping or isStackingActive then
            local char = player.Character
            local backpack = player:FindFirstChild("Backpack")
            local jumpers = getJumpers()
            
            if char and #jumpers > 0 then
                for _, jumper in pairs(jumpers) do
                    -- Force to character if stacking is on
                    if isStackingActive and jumper.Parent ~= char then
                        jumper.Parent = char
                    end
                    -- Fire if looping is on
                    if isLooping and jumper.Parent == char then
                        jumper:Activate()
                    end
                end
            end
        end
        task.wait(0.05)
    end
end)

-- 4. CARROT & GIVE ALL
task.spawn(function()
    while true do
        if isStackingActive then
            local carrot = player.Backpack:FindFirstChild("Carrot") or player.Character:FindFirstChild("Carrot")
            if carrot and player.Character then
                carrot.Parent = player.Character
                task.wait(0.1)
                carrot:Activate()
                task.wait(0.1)
                carrot.Parent = player.Backpack
            end
        end
        task.wait(30)
    end
end)

task.spawn(function()
    local remotes = {"SpawnDiamondBlock", "SpawnGalaxyBlock", "SpawnLuckyBlock", "SpawnRainbowBlock", "SpawnSuperBlock"}
    while true do
        if isGiveAllActive then
            for _, name in pairs(remotes) do
                local r = RS:FindFirstChild(name)
                if r then pcall(function() r:FireServer() end) end
            end
        end
        task.wait(0.5)
    end
end)

-- 5. BUTTONS & LIST
local function createBtn(txtOn, txtOff, y, flag)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    b.Text = txtOff
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        if flag == 1 then isLooping = not isLooping b.Text = isLooping and txtOn or txtOff
        elseif flag == 2 then isGiveAllActive = not isGiveAllActive b.Text = isGiveAllActive and txtOn or txtOff
        elseif flag == 3 then isStackingActive = not isStackingActive b.Text = isStackingActive and txtOn or txtOff end
        b.BackgroundColor3 = (isLooping or isGiveAllActive or isStackingActive) and Color3.fromRGB(60, 0, 0) or Color3.fromRGB(40, 40, 45)
    end)
end

createBtn("LOOP: ON", "LOOP: OFF", 160, 1)
createBtn("GIVE ALL: ON", "GIVE ALL: OFF", 195, 2)
createBtn("INF STACK: ON", "INF STACK: OFF", 230, 3)

local releaseB = Instance.new("TextButton", main)
releaseB.Size = UDim2.new(0.9, 0, 0, 30)
releaseB.Position = UDim2.new(0.05, 0, 0, 265)
releaseB.Text = "RELEASE LOCK"
releaseB.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
releaseB.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", releaseB)
releaseB.MouseButton1Click:Connect(function() targetLock = false end)

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

xBtn.MouseButton1Click:Connect(function() sg:Destroy() isLooping = false isStackingActive = false end)
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
