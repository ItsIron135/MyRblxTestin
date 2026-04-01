-- [[ ROCKET ADMIN V13: THE ULTIMATE HUB ]] --
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- 1. SETTINGS & TOGGLES
local UI_NAME = "RocketAdmin_V13"
local isLooping = false
local homeCFrame = nil
local walkSpeedActive = false
local jumpPowerActive = false

-- 2. NOTIFY FUNCTION
local function notify(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = 3;
    })
end

-- 3. UI SETUP
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

local function createBtn(text, x, y, color)
    local b = Instance.new("TextButton", sg)
    b.Size = UDim2.new(0, 90, 0, 40)
    b.Position = UDim2.new(0.5, x, 0.5, y)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 11
    Instance.new("UICorner", b)
    return b
end

-- BUTTONS ROW 1 (Rocket Controls)
local fixBtn = createBtn("MULTI-FIX", -150, -25, Color3.fromRGB(75, 0, 130))
local loopBtn = createBtn("START LOOP", -50, -25, Color3.fromRGB(200, 0, 0))
local homeBtn = createBtn("SET HOME", 50, -25, Color3.fromRGB(0, 150, 0))
local tpBtn = createBtn("TP HOME", 150, -25, Color3.fromRGB(0, 100, 200))

-- BUTTONS ROW 2 (Player Hacks)
local speedBtn = createBtn("SPEED (OFF)", -100, 25, Color3.fromRGB(50, 50, 50))
local jumpBtn = createBtn("JUMP (OFF)", 0, 25, Color3.fromRGB(50, 50, 50))
local exitBtn = createBtn("CLOSE UI", 100, 25, Color3.fromRGB(150, 0, 0))

-- 4. ROCKET LOGIC
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

loopBtn.MouseButton1Click:Connect(function()
    isLooping = not isLooping
    loopBtn.Text = isLooping and "STOP LOOP" or "START LOOP"
    loopBtn.BackgroundColor3 = isLooping and Color3.fromRGB(100,0,0) or Color3.fromRGB(200,0,0)
    
    if isLooping then
        task.spawn(function()
            while isLooping do
                local r = getRockets()
                if #r > 0 and player.Character then
                    for _, item in pairs(r) do
                        if not isLooping then break end
                        item.Parent = player.Character
                        task.wait(0.01)
                        item:Activate()
                        task.wait(0.06)
                        item.Parent = player.Backpack
                    end
                end
                task.wait(0.01)
            end
        end)
    end
end)

-- 5. SPEED & JUMP HACKS
speedBtn.MouseButton1Click:Connect(function()
    walkSpeedActive = not walkSpeedActive
    speedBtn.Text = walkSpeedActive and "SPEED (ON)" or "SPEED (OFF)"
    speedBtn.BackgroundColor3 = walkSpeedActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 50)
end)

jumpBtn.MouseButton1Click:Connect(function()
    jumpPowerActive = not jumpPowerActive
    jumpBtn.Text = jumpPowerActive and "JUMP (ON)" or "JUMP (OFF)"
    jumpBtn.BackgroundColor3 = jumpPowerActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 50)
end)

-- Constant Hack Loop
task.spawn(function()
    while true do
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if walkSpeedActive then hum.WalkSpeed = 100 else hum.WalkSpeed = 16 end
            if jumpPowerActive then hum.JumpPower = 150 hum.UseJumpPower = true else hum.JumpPower = 50 end
        end
        task.wait(0.1)
    end
end)

-- 6. WRAP UP
fixBtn.MouseButton1Click:Connect(function()
    for _, r in pairs(getRockets()) do r.Parent = workspace end
    task.wait(0.3)
    for _, r in pairs(getRockets()) do r.Parent = player.Character end
    notify("Fixed!", "Rockets Refreshed")
end)

homeBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        homeCFrame = player.Character.HumanoidRootPart.CFrame
        notify("Saved!", "Home point set.")
    end
end)

tpBtn.MouseButton1Click:Connect(function()
    if homeCFrame and player.Character then
        player.Character.HumanoidRootPart.CFrame = homeCFrame
    end
end)

exitBtn.MouseButton1Click:Connect(function() isLooping = false sg:Destroy() end)
notify("V13 Loaded", "Welcome back, Boss.")
