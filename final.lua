-- [[ ROCKET ADMIN PHASE STRIKE V72 - FULL RECONSTRUCTION ]] --

-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- [[ VARIABLES ]] --
local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

-- [[ FLAGS ]] --
local UI_NAME = "RocketAdmin_V72"
local isLooping = false
local isStackingActive = false
local isGodMode = false 
local selectedTargets = {} 
local swordName = "OverseerwrathSword"
local rocketName = "RocketJumper"
local projectileName = "Rocket"
local altProjectileName = "Projectile"

-- [[ 1. UI INITIALIZATION ]] --
if pGui:FindFirstChild(UI_NAME) then
	pGui[UI_NAME]:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = UI_NAME
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.Parent = pGui

local main = Instance.new("Frame")
main.Name = "MainFrame"
main.Size = UDim2.new(0, 220, 0, 430)
main.Position = UDim2.new(0.5, -110, 0.5, -215)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true 
main.Parent = sg

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = main

local title = Instance.new("TextLabel")
title.Name = "TitleLabel"
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Text = "PHASE STRIKE V72"
title.TextColor3 = Color3.fromRGB(0, 255, 200)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.TextStrokeTransparency = 0.8
title.Parent = main

local xBtn = Instance.new("TextButton")
xBtn.Name = "ExitButton"
xBtn.Size = UDim2.new(0, 25, 0, 25)
xBtn.Position = UDim2.new(1, -30, 0, 5)
xBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
xBtn.Text = "X"
xBtn.TextColor3 = Color3.new(1, 1, 1)
xBtn.Font = Enum.Font.SourceSansBold
xBtn.TextSize = 14
xBtn.AutoButtonColor = true

local xCorner = Instance.new("UICorner")
xCorner.CornerRadius = UDim.new(0, 4)
xCorner.Parent = xBtn
xBtn.Parent = main

xBtn.MouseButton1Click:Connect(function() 
	sg:Destroy() 
	isLooping = false 
	isStackingActive = false 
	isGodMode = false
	
	local character = player.Character
	if character then
		local backpack = player:FindFirstChild("Backpack")
		for _, tool in pairs(character:GetChildren()) do
			if tool.Name == swordName then
				if backpack then
					tool.Parent = backpack
				end
			end
		end
	end
	selectedTargets = {} 
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "PlayerScroller"
scroll.Size = UDim2.new(0.9, 0, 0.35, 0)
scroll.Position = UDim2.new(0.05, 0, 0.1, 0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

-- [[ 2. UNIVERSAL SHIELD (VOID & VELOCITY PROTECTION) ]] --
RunService.Heartbeat:Connect(function()
	local char = player.Character
	if char then
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChild("Humanoid")
		
		if root and hum then
			local currentPos = root.Position
			local currentVel = root.AssemblyLinearVelocity
			
			if currentPos.Y < -20 then
				root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				root.CFrame = CFrame.new(currentPos.X, 150, currentPos.Z)
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
			
			if currentVel.Magnitude > 950 then
				root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end
		end
	end
end)

-- [[ 3. AGGRESSIVE STACKER ]] --
RunService.RenderStepped:Connect(function()
	if isStackingActive then
		local bp = player:FindFirstChild("Backpack")
		local char = player.Character
		
		if bp and char then
			local backpackItems = bp:GetChildren()
			for i = 1, #backpackItems do
				local item = backpackItems[i]
				if item.Name == rocketName then
					item.Parent = char
				end
			end
		end
	end
end)

-- [[ 4. PHASE TELEPORT & SOFT AIM ]] --
local targetIndex = 1

RunService.RenderStepped:Connect(function()
	local char = player.Character
	if not char then return end
	
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local targets = {}
	for p, active in pairs(selectedTargets) do
		if active then
			if p.Character then
				local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
				local tHum = p.Character:FindFirstChild("Humanoid")
				
				if tRoot and tHum and tHum.Health > 0 then
					table.insert(targets, tRoot)
				end
			end
		end
	end

	if #targets > 0 then
		if targetIndex > #targets then
			targetIndex = 1
		end
		
		local currentT = targets[targetIndex]
		targetIndex = (targetIndex % #targets) + 1
		
		-- Stabilized Teleport logic to prevent camera jitter
		root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		local targetCF = currentT.CFrame
		local offsetCF = CFrame.new(0, 0, 0.5)
		local rotationCF = CFrame.Angles(math.rad(-90), 0, 0)
		
		root.CFrame = targetCF * offsetCF * rotationCF
		
		if isLooping then
			local worldItems = workspace:GetChildren()
			for j = 1, #worldItems do
				local r = worldItems[j]
				if r:IsA("BasePart") then
					if r.Name == projectileName or r.Name == altProjectileName then
						local dist = (r.Position - root.Position).Magnitude
						if dist < 35 then
							-- SOFT AIM IMPLEMENTATION
							local tPos = currentT.Position
							r.CFrame = CFrame.lookAt(r.Position, tPos)
							r.AssemblyLinearVelocity = (tPos - r.Position).Unit * 450
						end
					end
				end
			end
		end
	end
end)

-- [[ 5. TACTICAL ROCKET CYCLE (20MS DELAY) ]] --
task.spawn(function()
	while true do
		if isLooping then
			local char = player.Character
			local bp = player:FindFirstChild("Backpack")
			
			if char then
				local toolSource = nil
				if isStackingActive then
					toolSource = char
				else
					if bp then
						toolSource = bp
					else
						toolSource = char
					end
				end
				
				local jumpers = {}
				local children = toolSource:GetChildren()
				for k = 1, #children do
					local t = children[k]
					if t.Name == rocketName then
						table.insert(jumpers, t)
					end
				end
				
				if #jumpers > 0 then
					for i = 1, #jumpers do
						if not isLooping then break end
						local tool = jumpers[i]
						
						if tool.Parent ~= char then
							tool.Parent = char
						end
						
						tool:Activate()
						
						-- PRESERVED: 20MS DELAY
						task.wait(0.02)
						
						if not isStackingActive then
							if bp then
								tool.Parent = bp
							end
						end
					end
				end
			end
		end
		task.wait(0.01)
	end
end)

-- [[ 6. GOD MODE SWAPPER ]] --
task.spawn(function()
	while true do
		if isGodMode then
			local char = player.Character
			local bp = player:FindFirstChild("Backpack")
			
			if char and bp then
				local activeSwords = {}
				
				local charItems = char:GetChildren()
				for _i = 1, #charItems do
					local t = charItems[_i]
					if t.Name == swordName then
						table.insert(activeSwords, t)
					end
				end
				
				local bpItems = bp:GetChildren()
				for _j = 1, #bpItems do
					local t = bpItems[_j]
					if t.Name == swordName then
						if #activeSwords < 12 then
							table.insert(activeSwords, t)
						end
					end
				end

				if #activeSwords > 0 then
					for _k = 1, #activeSwords do
						activeSwords[_k].Parent = char
					end
					
					task.wait(0.01)
					
					for _l = 1, #activeSwords do
						activeSwords[_l].Parent = bp
					end
					
					task.wait(0.01)
				end
			end
		end
		task.wait(0.01)
	end
end)

-- [[ 7. CARROT CONSUMPTION ]] --
task.spawn(function()
	local stackTriggered = false
	while true do
		if isStackingActive then
			if not stackTriggered then
				stackTriggered = true
				task.wait(3)
			end
			
			local bp = player:FindFirstChild("Backpack")
			local char = player.Character
			
			local carrotItem = nil
			if bp and bp:FindFirstChild("Carrot") then
				carrotItem = bp:FindFirstChild("Carrot")
			elseif char and char:FindFirstChild("Carrot") then
				carrotItem = char:FindFirstChild("Carrot")
			end
			
			if carrotItem and char then
				local previousParent = carrotItem.Parent
				carrotItem.Parent = char
				task.wait(0.1)
				carrotItem:Activate()
				task.wait(0.1)
				carrotItem.Parent = previousParent
			end
			
			task.wait(30)
		else
			stackTriggered = false
			task.wait(0.5)
		end
	end
end)

-- [[ 8. UI COMPONENT GENERATOR ]] --
local function createButton(label, yPos, getter, setter)
	local btn = Instance.new("TextButton")
	btn.Name = label .. "Button"
	btn.Size = UDim2.new(0, 200, 0, 35)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	btn.BorderSizePixel = 0
	btn.Text = label
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.AutoButtonColor = true
	
	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 6)
	bCorner.Parent = btn
	
	btn.Parent = main
	
	btn.MouseButton1Click:Connect(function() 
		local currentStatus = getter()
		local newStatus = not currentStatus
		setter(newStatus)
		
		if getter() then
			btn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
		else
			btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		end
	end)
	
	return btn
end

local loopAttackBtn = createButton("LOOP ATTACK", 180, function() return isLooping end, function(v) isLooping = v end)
local infStackBtn = createButton("INF STACK", 220, function() return isStackingActive end, function(v) isStackingActive = v end)

local godBtn = Instance.new("TextButton")
godBtn.Name = "GodModeButton"
godBtn.Size = UDim2.new(0, 200, 0, 35)
godBtn.Position = UDim2.new(0, 10, 0, 260)
godBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
godBtn.BorderSizePixel = 0
godBtn.Text = "GOD MODE: OFF"
godBtn.TextColor3 = Color3.new(1, 1, 1)
godBtn.Font = Enum.Font.SourceSansBold
godBtn.TextSize = 14
godBtn.AutoButtonColor = true

local gCorner = Instance.new("UICorner")
gCorner.CornerRadius = UDim.new(0, 6)
gCorner.Parent = godBtn
godBtn.Parent = main

godBtn.MouseButton1Click:Connect(function()
	isGodMode = not isGodMode
	if isGodMode then
		godBtn.Text = "GOD MODE: ON"
		godBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
	else
		godBtn.Text = "GOD MODE: OFF"
		godBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		
		local char = player.Character
		if char then
			local backpack = player:FindFirstChild("Backpack")
			local children = char:GetChildren()
			for i = 1, #children do
				local t = children[i]
				if t.Name == swordName then
					if backpack then
						t.Parent = backpack
					end
				end
			end
		end
	end
end)

local fixBtn = Instance.new("TextButton")
fixBtn.Name = "InstantFixButton"
fixBtn.Size = UDim2.new(0, 200, 0, 35)
fixBtn.Position = UDim2.new(0, 10, 0, 300)
fixBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
fixBtn.BorderSizePixel = 0
fixBtn.Text = "INSTANT FIX"
fixBtn.TextColor3 = Color3.new(1, 1, 1)
fixBtn.Font = Enum.Font.SourceSansBold
fixBtn.TextSize = 14
fixBtn.AutoButtonColor = true

local fCorner = Instance.new("UICorner")
fCorner.CornerRadius = UDim.new(0, 6)
fCorner.Parent = fixBtn
fixBtn.Parent = main

fixBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	local backpack = player:FindFirstChild("Backpack")
	local toolsToFix = {}
	
	if char then
		local charChildren = char:GetChildren()
		for i = 1, #charChildren do
			local t = charChildren[i]
			if t.Name == rocketName then
				table.insert(toolsToFix, t)
			end
		end
	end
	
	if backpack then
		local bpChildren = backpack:GetChildren()
		for j = 1, #bpChildren do
			local t = bpChildren[j]
			if t.Name == rocketName then
				table.insert(toolsToFix, t)
			end
		end
	end
	
	for k = 1, #toolsToFix do
		toolsToFix[k].Parent = workspace
	end
	
	task.wait(0.1)
	
	for l = 1, #toolsToFix do
		if char then
			toolsToFix[l].Parent = char
		end
	end
end)

-- [[ 9. LIST REFRESH LOGIC ]] --
function refreshPlayerList()
	local currentButtons = scroll:GetChildren()
	for i = 1, #currentButtons do
		local child = currentButtons[i]
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	local allPlayers = Players:GetPlayers()
	for i = 1, #allPlayers do
		local p = allPlayers[i]
		if p ~= player then
			local pBtn = Instance.new("TextButton")
			pBtn.Name = p.Name .. "_TargetBtn"
			pBtn.Size = UDim2.new(1, -5, 0, 25)
			pBtn.BorderSizePixel = 0
			pBtn.Text = p.Name
			
			if selectedTargets[p] then
				pBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
			else
				pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			end
			
			pBtn.TextColor3 = Color3.new(1, 1, 1)
			pBtn.Font = Enum.Font.SourceSansBold
			pBtn.TextSize = 12
			
			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 4)
			btnCorner.Parent = pBtn
			
			pBtn.Parent = scroll
			
			pBtn.MouseButton1Click:Connect(function()
				local isSelected = selectedTargets[p]
				selectedTargets[p] = not isSelected
				
				if selectedTargets[p] then
					pBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
				else
					pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				end
			end)
		end
	end
	
	local playerCount = #Players:GetPlayers()
	scroll.CanvasSize = UDim2.new(0, 0, 0, playerCount * 30)
end

Players.PlayerAdded:Connect(function()
	refreshPlayerList()
end)

Players.PlayerRemoving:Connect(function()
	refreshPlayerList()
end)

refreshPlayerList()

warn("[PHASE STRIKE V72] EXECUTED SUCCESSFULLY")
