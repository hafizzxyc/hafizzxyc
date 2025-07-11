--[[
✅ FIX TOTAL by Apiss
Fly + Vehicle Fly + NoClip + Minimize GUI (ImageButton)
--]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Basic Vars
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ApissFlyUI"

-- Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 160)
frame.Position = UDim2.new(0.75, 0, 0.6, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

-- Title
local title = Instance.new("TextLabel", frame)
title.Text = "🛫 Apiss Fly Executor"
title.Size = UDim2.new(1, 0, 0, 30)
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextSize = 16

-- Speed Label
local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Text = "Speed:"
speedLabel.Position = UDim2.new(0, 10, 0, 35)
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
speedLabel.BackgroundTransparency = 1
speedLabel.TextSize = 14
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Speed Box
local speedBox = Instance.new("TextBox", frame)
speedBox.Position = UDim2.new(0, 10, 0, 55)
speedBox.Size = UDim2.new(1, -20, 0, 25)
speedBox.Text = "100"
speedBox.Font = Enum.Font.Gotham
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
speedBox.TextSize = 14

-- Buttons
local toggleFlyButton = Instance.new("TextButton", frame)
toggleFlyButton.Position = UDim2.new(0, 10, 0, 90)
toggleFlyButton.Size = UDim2.new(1, -20, 0, 25)
toggleFlyButton.Text = "Toggle Fly [E]"
toggleFlyButton.Font = Enum.Font.GothamBold
toggleFlyButton.TextColor3 = Color3.new(1,1,1)
toggleFlyButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
toggleFlyButton.TextSize = 14

local toggleNoclipButton = Instance.new("TextButton", frame)
toggleNoclipButton.Position = UDim2.new(0, 10, 0, 120)
toggleNoclipButton.Size = UDim2.new(1, -20, 0, 25)
toggleNoclipButton.Text = "Toggle NoClip [N]"
toggleNoclipButton.Font = Enum.Font.GothamBold
toggleNoclipButton.TextColor3 = Color3.new(1,1,1)
toggleNoclipButton.BackgroundColor3 = Color3.fromRGB(60,60,60)
toggleNoclipButton.TextSize = 14

-- Minimize Button
local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Text = "-"
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -30, 0, 5)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)

-- Minimized Image Icon
local minimizedButton = Instance.new("ImageButton", gui)
minimizedButton.Size = UDim2.new(0, 70, 0, 70)
minimizedButton.Position = UDim2.new(0.9, 0, 0.6, 0)
minimizedButton.Image = "https://files.catbox.moe/3vm1ax.jpg"
minimizedButton.BackgroundTransparency = 1
minimizedButton.Visible = false

-- Control Variables
local flying = false
local noclip = false
local speed = 100
local control = {F = 0, B = 0, L = 0, R = 0, Y = 0}
local bodyGyro, bodyVelocity, flyConn, noclipConn

-- Functions
local function updateSpeed()
	local val = tonumber(speedBox.Text)
	if val and val > 0 then speed = val end
end
speedBox.FocusLost:Connect(updateSpeed)

local function getRoot()
	character = player.Character or player.CharacterAdded:Wait()
	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum and hum.SeatPart then
		local seat = hum.SeatPart
		local model = seat:FindFirstAncestorOfClass("Model")
		return (model and model.PrimaryPart) or seat
	end
	return character:FindFirstChild("HumanoidRootPart")
end

-- Fly Function
local function startFly()
	updateSpeed()
	local part = getRoot()

	bodyGyro = Instance.new("BodyGyro", part)
	bodyGyro.P = 9e4
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.CFrame = part.CFrame

	bodyVelocity = Instance.new("BodyVelocity", part)
	bodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	flyConn = RunService.RenderStepped:Connect(function()
		local cam = workspace.CurrentCamera.CFrame
		local dir = Vector3.new(control.L + control.R, control.Y, control.F + control.B)
		if dir.Magnitude > 0 then
			bodyVelocity.Velocity = cam:VectorToWorldSpace(dir.Unit) * speed
		else
			bodyVelocity.Velocity = Vector3.new(0, 1, 0)
		end
		bodyGyro.CFrame = cam
	end)
end

local function stopFly()
	if flyConn then flyConn:Disconnect() end
	if bodyGyro then bodyGyro:Destroy() end
	if bodyVelocity then bodyVelocity:Destroy() end
end

-- NoClip Function
local function startNoClip()
	noclipConn = RunService.Stepped:Connect(function()
		for _, part in ipairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end)
end

local function stopNoClip()
	if noclipConn then noclipConn:Disconnect() end
	for _, part in ipairs(player.Character:GetDescendants()) do
		if part:IsA("BasePart") then part.CanCollide = true end
	end
end

-- Toggle Functions
local function toggleFly()
	flying = not flying
	if flying then startFly() else stopFly() end
end

local function toggleNoClip()
	noclip = not noclip
	if noclip then startNoClip() else stopNoClip() end
end

-- Button Events
toggleFlyButton.MouseButton1Click:Connect(toggleFly)
toggleNoclipButton.MouseButton1Click:Connect(toggleNoClip)

-- Minimize/Restore
minimizeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	minimizedButton.Visible = true
end)

minimizedButton.MouseButton1Click:Connect(function()
	frame.Visible = true
	minimizedButton.Visible = false
end)

-- Drag Support for Image
local dragging, dragInput, mousePos, startPos
minimizedButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		mousePos = input.Position
		startPos = minimizedButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)

minimizedButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

RunService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - mousePos
		minimizedButton.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- Keybinds
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.E then toggleFly()
	elseif input.KeyCode == Enum.KeyCode.N then toggleNoClip()
	elseif input.KeyCode == Enum.KeyCode.W then control.F = 1
	elseif input.KeyCode == Enum.KeyCode.S then control.B = -1
	elseif input.KeyCode == Enum.KeyCode.A then control.L = -1
	elseif input.KeyCode == Enum.KeyCode.D then control.R = 1
	elseif input.KeyCode == Enum.KeyCode.Space then control.Y = 1
	elseif input.KeyCode == Enum.KeyCode.LeftControl then control.Y = -1
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then control.F = 0
	elseif input.KeyCode == Enum.KeyCode.S then control.B = 0
	elseif input.KeyCode == Enum.KeyCode.A then control.L = 0
	elseif input.KeyCode == Enum.KeyCode.D then control.R = 0
	elseif input.KeyCode == Enum.KeyCode.Space then control.Y = 0
	elseif input.KeyCode == Enum.KeyCode.LeftControl then control.Y = 0
	end
end)
