-- [[ ROCKET ADMIN V16: PURE GLUE & LOOP ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- CONFIG
local UI_NAME = "RocketAdmin_V16"
local isLooping = false
local targetLock = false
local lockConnection = nil

-- 1. UI SETUP
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

local function createBtn(text, x, color)
    local b = Instance.new("TextButton", sg)
    b.Size = UDim2.new(0, 110, 0, 45)
    b.Position = UDim2.new(0.5, x, 0.5, -22)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 11
    Instance.new("UICorner", b)
    return b
end

local loopBtn = createBtn("ROCKET LOOP: OFF", -170, Color3.fromRGB(200, 0, 0))
local lockBtn = createBtn("TARGET LOCK: OFF", -55, Color3.fromRGB(50, 50, 50))
local exitBtn = createBtn("CLOSE UI", 60, Color3.fromRGB(150, 0, 0))

-- 2. GEAR FINDER
local function getRockets()
    local list = {}
    local locations = {player.Backpack, player.Character}
    for _, loc in pairs(locations) do
        if loc then
            for _, i in pairs(loc:GetChildren()) do
                if i:IsA("Tool") and i.Name:lower():find("rocket") then 
                    table.insert(list, i) 
                end
            end
        end
    end
    return list
end

-- 3. PERMANENT ROCKET THREAD
task.spawn(function()
    while true do
        if isLooping then
            local rockets = getRockets()
            local char = player.Character
            if char and #rockets > 0 then
                for _, r in pairs(rockets) do
                    if not isLooping then break end
                    r.Parent = char
                    task.wait(0.01)
                    r:Activate()
                    task.wait(0.05)
                    r.Parent = player:FindFirstChild("Backpack")
                end
            end
        end
        task.wait(0.01)
    end
end)

-- 4. GLUE LOGIC
local function stopLock()
    targetLock = false
    lockBtn.Text = "TARGET LOCK: OFF"
    lockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    if lockConnection then lockConnection:Disconnect() lockConnection = nil end
end

local function startLock(targetP)
    if lockConnection then lockConnection:Disconnect() end
    targetLock = true
    lockBtn.Text = "LOCKED: " .. targetP.Name:sub(1,8)
    lockBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    
    lockConnection = RunService.Heartbeat:Connect(function()
        if not targetLock then return end
        if player.Character and targetP.Character then
            local myRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local tHead = targetP.Character:FindFirstChild("Head")
            if myRoot and tHead then
                myRoot.CFrame = tHead.CFrame * CFrame.new(0, 3, 0)
            end
        end
    end)
end

-- 5. INTERACTION
loopBtn.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    loopBtn.Text = isLooping and "ROCKET LOOP: ON" or "ROCKET LOOP: OFF"
    loopBtn.BackgroundColor3 = isLooping and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(200, 0, 0)
end)

lockBtn.MouseButton1Click:Connect(function()
    if targetLock then stopLock() else
        print("Use ;rocket [name] to lock someone!")
    end
end)

player.Chatted:Connect(function(msg)
    local args = msg:split(" ")
    if args[1]:lower() == ";rocket" and args[2] then
        local tName = args[2]:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Name:lower():sub(1, #tName) == tName then
                isLooping = true
                loopBtn.Text = "ROCKET LOOP: ON"
                loopBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
                startLock(p)
                break
            end
        end
    end
end)

exitBtn.MouseButton1Click:Connect(function()
    isLooping = false
    stopLock()
    sg:Destroy()
end)
