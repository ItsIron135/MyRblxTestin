-- [[ ROCKET ADMIN V12: LOADSTRING EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- CONFIGURATION
local UI_NAME = "RocketAdmin_V12"
local TARGET_GEAR = "Rocket Jumper"
local PREFIX = ";"
local Y_POS = 0.5
local isLooping = false
local homeCFrame = nil

-- CLEANUP PREVIOUS SESSIONS
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end

-- 1. NOTIFICATION SYSTEM
local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = duration or 3;
    })
end

-- 2. UI CONSTRUCTION
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

local function createBtn(text, xPos, color)
    local btn = Instance.new("TextButton", sg)
    btn.Name = text:gsub(" ", "")
    btn.Size = UDim2.new(0, 100, 0, 45)
    btn.Position = UDim2.new(0.5, xPos, Y_POS, 0)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.AutoButtonColor = true
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = ToolPunchout or指标码--Standard 8px
    return btn
end

local fixBtn    = createBtn("MULTI-FIX", -160, Color3.fromRGB(60, 0, 120))
local loopBtn   = createBtn("START LOOP", -50, Color3.fromRGB(180, 0, 0))
local homeBtn   = createBtn("SET HOME", 60, Color3.fromRGB(0, 120, 60))
local tpHomeBtn = createBtn("TP HOME", 170, Color3.fromRGB(0, 80, 180))
local exitBtn   = createBtn("X", 280, Color3.fromRGB(150, 0, 0))
exitBtn.Size = UDim2.new(0, 40, 0, 45)

-- 3. CORE LOGIC FUNCTIONS
local function getRockets()
    local found = {}
    local locations = {player.Backpack, player.Character}
    for _, loc in pairs(locations) do
        if loc then
            for _, item in pairs(loc:GetChildren()) do
                if item:IsA("Tool") and (item.Name:lower():find("rocket") or item.Name:lower():find("jumper")) then
                    table.insert(found, item)
                end
            end
        end
    end
    return found
end

-- 4. BUTTON FUNCTIONALITY
fixBtn.MouseButton1Click:Connect(function()
    local items = getRockets()
    if #items == 0 then notify("Error", "No Rocket Jumpers found!") return end
    
    for _, item in pairs(items) do item.Parent = workspace end
    task.wait(0.3)
    for _, item in pairs(items) do item.Parent = player.Character or player.Backpack end
    notify("Success", "Fixed " .. #items .. " rockets!")
end)

loopBtn.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    loopBtn.Text = isLooping and "STOP LOOP" or "START LOOP"
    loopBtn.BackgroundColor3 = isLooping and Color3.fromRGB(80, 0, 0) or Color3.fromRGB(180, 0, 0)
    
    if isLooping then
        task.spawn(function()
            while isLooping do
                local items = getRockets()
                local char = player.Character
                if char and #items > 0 then
                    for _, r in pairs(items) do
                        if not isLooping then break end
                        r.Parent = char
                        task.wait(0.02)
                        r:Activate()
                        task.wait(0.06)
                        r.Parent = player.Backpack
                    end
                else
                    task.wait(0.5) -- Wait for character/items if missing
                end
                task.wait(0.01)
            end
        end)
    end
end)

homeBtn.MouseButton1Click:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        homeCFrame = root.CFrame
        notify("Home Set", "Location saved successfully.")
    end
end)

tpHomeBtn.MouseButton1Click:Connect(function()
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root and homeCFrame then
        root.CFrame = homeCFrame
    else
        notify("Error", "No home location set!")
    end
end)

exitBtn.MouseButton1Click:Connect(function()
    isLooping = false
    sg:Destroy()
end)

-- 5. CHAT COMMANDS (;rocket name)
player.Chatted:Connect(function(msg)
    local split = msg:split(" ")
    if split[1]:lower() == PREFIX .. "rocket" and split[2] then
        local targetName = split[2]:lower()
        for _, other in pairs(Players:GetPlayers()) do
            if other ~= player and other.Name:lower():sub(1, #targetName) == targetName then
                local tRoot = other.Character and other.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and myRoot then
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 5)
                    if not isLooping then 
                        -- Trigger the loop button logic
                        loopBtn.Text = "STOP LOOP"
                        isLooping = true
                        -- (The task.spawn logic inside loopBtn would be triggered here manually)
                    end
                end
                break
            end
        end
    end
end)

notify("Rocket Admin Loaded", "V12 Active - Muahaha!", 5)