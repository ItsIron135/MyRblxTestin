-- [[ ROCKET ADMIN V24: THE MASTER SUITE ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- CONFIG & FLAGS
local UI_NAME = "RocketAdmin_V24"
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
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "ROCKET ADMIN V24"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
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
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. CORE FUNCTIONS
local function getRockets()
    local list = {}
    local locs = {player.Backpack, player.Character}
    for _, l in pairs(locs) do
        if l then
            for _, i in pairs(l:GetChildren()) do
                if i:IsA("Tool") and i.Name:lower():find("rocket") then table.insert(list, i) end
            end
        end
    end
    return list
end

-- 3. GIVE ALL LOGIC
task.spawn(function()
    local remotes = {"SpawnDiamondBlock", "SpawnGalaxyBlock", "SpawnLuckyBlock", "SpawnRainbowBlock", "SpawnSuperBlock"}
    while true do
        if isGiveAllActive then
            for _, name in pairs(remotes) do
                local r = RS:FindFirstChild(name)
                if r then pcall(function() r:FireServer() end) end
            end
        end
        task.wait(0.2)
    end
end)

-- 4. INF STACKER (Modified for Rockets)
local function useCarrot()
    local char = player.Character
    local carrot = player.Backpack:FindFirstChild("Carrot")
    if carrot and char then
        carrot.Parent = char
        task.wait(0.1)
        carrot:Activate()
        task.wait(0.5)
        carrot.Parent = player.Backpack
    end
end

task.spawn(function()
    while true do
        if isStackingActive then
            local char = player.Character
            if char then
                -- Auto-stack all rockets found in backpack
                for _, item in pairs(player.Backpack:GetChildren()) do
                    if item:IsA("Tool") and item.Name:lower():find("rocket") then
                        item.Parent = char
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if isStackingActive then
            useCarrot()
            task.wait(32) -- Refresh Carrot buff
        else
            task.wait(1)
        end
    end
end)

-- 5. BUTTON GENERATOR
local function createActionBtn(text, y, color, callback)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0.9, 0, 0, 30)
    b.Position = UDim2.new(0.05, 0, 0, y)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local loopB = createActionBtn("ROCKET LOOP: OFF", 155, Color3.fromRGB(150, 0, 0), function()
    isLooping = not isLooping
end)

local giveB = createActionBtn("GIVE ALL: OFF", 190, Color3.fromRGB(50, 50, 50), function()
    isGiveAllActive = not isGiveAllActive
    giveB.Text = isGiveAllActive and "GIVE ALL: ON" or "GIVE ALL: OFF"
end)

local stackB = createActionBtn("INF STACK: OFF", 225, Color3.fromRGB(50, 50, 50), function()
    isStackingActive = not isStackingActive
    stackB.Text = isStackingActive and "INF STACK: ON" or "INF STACK: OFF"
end)

local releaseB = createActionBtn("RELEASE LOCK", 260, Color3.fromRGB(80, 80, 80), function()
    targetLock = false
    if lockConnection then lockConnection:Disconnect() end
end)

-- 6. PLAYER LIST & LOOP
local function updateList()
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", scroll)
            b.Size = UDim2.new(1, -5, 0, 25)
            b.Text = p.Name
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
                        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    end
                end)
            end)
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

task.spawn(function()
    while true do
        if isLooping then
            local r = getRockets()
            if player.Character and #r > 0 then
                for _, item in pairs(r) do
                    if not isLooping then break end
                    item.Parent = player.Character
                    task.wait(0.01)
                    item:Activate()
                    task.wait(0.05)
                    item.Parent = player.Backpack
                end
            end
        end
        task.wait(0.01)
    end
end)

xBtn.MouseButton1Click:Connect(function() sg:Destroy() isLooping = false isStackingActive = false end)
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
