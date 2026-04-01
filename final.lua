-- [[ ROCKET ADMIN V67: STABLE PHANTOM ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")

-- FLAGS
local UI_NAME = "RocketAdmin_V67"
local isLooping = false
local isStackingActive = false
local selectedTargets = {} 

-- 1. UI SETUP
if pGui:FindFirstChild(UI_NAME) then pGui[UI_NAME]:Destroy() end
local sg = Instance.new("ScreenGui", pGui)
sg.Name = UI_NAME
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 220, 0, 380)
main.Position = UDim2.new(0.5, -110, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
main.Active = true
main.Draggable = true 
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "STABLE PHANTOM V67"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold

local xBtn = Instance.new("TextButton", main)
xBtn.Size = UDim2.new(0, 25, 0, 25)
xBtn.Position = UDim2.new(1, -30, 0, 5)
xBtn.Text = "X"
xBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
xBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", xBtn)
xBtn.MouseButton1Click:Connect(function() sg:Destroy() isLooping = false isStackingActive = false end)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0.35, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", scroll)

-- 2. VOID SHIELD
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and root.Position.Y < -30 then
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.CFrame = CFrame.new(root.Position.X, 150, root.Position.Z)
    end
end)

-- 3. THE STABLE BLINK LOOP
task.spawn(function()
    local targetIndex = 1
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local bp = player:FindFirstChild("Backpack")
        
        if isLooping and root and char then
            local targets = {}
            for p, active in pairs(selectedTargets) do
                if active and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(targets, p.Character.HumanoidRootPart)
                end
            end

            if #targets > 0 then
                targetIndex = (targetIndex % #targets) + 1
                local currentT = targets[targetIndex]
                
                -- Save current walk position
                local walkPos = root.CFrame
                
                -- STOP SPINNING: Disable AutoRotate during the blink
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.AutoRotate = false end
                
                -- BLINK & FIRE
                root.CFrame = currentT.CFrame
                
                local tool = char:FindFirstChild("RocketJumper") or (bp and bp:FindFirstChild("RocketJumper"))
                if tool then
                    tool.Parent = char
                    task.wait(0.02) -- Min time for server to see you at target
                    tool:Activate()
                    task.wait(0.02)
                    if not isStackingActive and bp then tool.Parent = bp end
                end
                
                -- RETURN & RESTORE
                root.CFrame = walkPos
                if hum then hum.AutoRotate = true end
            end
        end
        task.wait(0.03)
    end
end)

-- 4. AGGRESSIVE STACKER
RunService.RenderStepped:Connect(function()
    if isStackingActive then
        local bp = player:FindFirstChild("Backpack")
        local char = player.Character
        if bp and char then
            for _, item in ipairs(bp:GetChildren()) do
                if item.Name == "RocketJumper" then item.Parent = char end
            end
        end
    end
end)

-- 5. LIST LOGIC
function updateList()
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", scroll)
            b.Size = UDim2.new(1, -5, 0, 25)
            b.Text = p.Name
            b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(40, 40, 40)
            b.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                selectedTargets[p] = not selectedTargets[p]
                b.BackgroundColor3 = selectedTargets[p] and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(40, 40, 40)
            end)
        end
    end
end

Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)
updateList()
