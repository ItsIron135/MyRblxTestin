-- [[ ROCKET ADMIN V19: SCROLLING PLAYER LIST ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- CONFIG
local UI_NAME = "RocketAdmin_V19"
local isLooping = false
local targetLock = false
local lockConnection = nil

-- 1. UI CONSTRUCTION
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

-- Main Frame
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 200, 0, 300)
main.Position = UDim2.new(0.5, -100, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "ROCKET ADMIN V19"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

-- Scrolling List
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0.6, 0)
scroll.Position = UDim2.new(0.05, 0, 0.15, 0)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 5)

-- 2. GEAR & LOCK LOGIC
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

local function stopLock()
    targetLock = false
    if lockConnection then lockConnection:Disconnect() lockConnection = nil end
end

local function startLock(targetP)
    stopLock()
    targetLock = true
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

-- 3. PLAYER LIST REFRESH
local function updateList()
    for _, child in pairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = p.DisplayName
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.SourceSans
            Instance.new("UICorner", btn)
            
            btn.MouseButton1Click:Connect(function()
                startLock(p)
            end)
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- 4. ROCKET THREAD
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

-- 5. FOOTER BUTTONS
local loopBtn = Instance.new("TextButton", main)
loopBtn.Size = UDim2.new(0.4, 0, 0, 40)
loopBtn.Position = UDim2.new(0.05, 0, 0.8, 0)
loopBtn.Text = "LOOP: OFF"
loopBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
loopBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", loopBtn)

loopBtn.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    loopBtn.Text = isLooping and "LOOP: ON" or "LOOP: OFF"
    loopBtn.BackgroundColor3 = isLooping and Color3.fromRGB(100, 0, 0) or Color3.fromRGB(200, 0, 0)
end)

local stopBtn = Instance.new("TextButton", main)
stopBtn.Size = UDim2.new(0.4, 0, 0, 40)
stopBtn.Position = UDim2.new(0.55, 0, 0.8, 0)
stopBtn.Text = "STOP LOCK"
stopBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
stopBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", stopBtn)

stopBtn.MouseButton1Click:Connect(function() stopLock() end)

-- Auto-update list when people join/leave
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
