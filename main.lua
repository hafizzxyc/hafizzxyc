-- Apiess GUI + Brainrot Support (Revisi Aman untuk Steal a Brainrot)

-- == ANTI-KICK == --
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or method == "kick" then
        warn("[Apiess] Kick attempt blocked!")
        return
    end
    return old(self, ...)
end)
setreadonly(mt, true)

-- == SERVICES == --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local char, root, humanoid

local function updateCharacter()
    char = player.Character or player.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end
updateCharacter()
player.CharacterAdded:Connect(function()
    task.wait(1)
    updateCharacter()
end)

-- == GUI == --
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "ApiessGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 270, 0, 580)
frame.Position = UDim2.new(0, 20, 0.5, -290)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Draggable = true
frame.Active = true
frame.BackgroundTransparency = 0.05

local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🧠 Apiess Brainrot GUI"
title.Font = Enum.Font.FredokaOne
title.TextSize = 20
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 127)
title.TextStrokeTransparency = 0.8

local yOffset = 50
local function addButton(text, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -30, 0, 32)
    btn.Position = UDim2.new(0, 15, 0, yOffset)
    btn.Text = text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.BorderSizePixel = 0

    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)

    local shadow = Instance.new("UIStroke", btn)
    shadow.Thickness = 1
    shadow.Color = Color3.fromRGB(0, 255, 127)
    shadow.Transparency = 0.5

    btn.MouseButton1Click:Connect(callback)
    yOffset = yOffset + 40
end

-- == FITUR == --
local function antiStun()
    if humanoid then
        humanoid.StateChanged:Connect(function(_, new)
            if new == Enum.HumanoidStateType.Physics then
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end
end

local function autoRevive()
    RunService.Heartbeat:Connect(function()
        if player.Character and player.Character:FindFirstChild("Downed") then
            player.Character.Downed:Destroy()
        end
    end)
end

local function brainESP()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and not v:FindFirstChild("ApiessESP") then
            local h = Instance.new("Highlight", v)
            h.Name = "ApiessESP"
            h.FillColor = v.Name:lower():find("zombie") and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
            h.OutlineColor = Color3.new(1,1,1)
            h.FillTransparency = 0.6
        end
    end
end

local function antiFlash()
    player.PlayerGui.ChildAdded:Connect(function(c)
        if c.Name:lower():find("flash") or c.Name:lower():find("slow") then
            wait(0.1)
            c:Destroy()
        end
    end)
end

local speedOn = false
local function toggleSpeed()
    speedOn = not speedOn
    if humanoid then
        humanoid.WalkSpeed = speedOn and 28 or 16
    end
end

local nvEnabled = false
local function toggleNightVision()
    nvEnabled = not nvEnabled
    Lighting.Brightness = nvEnabled and 5 or 1
    Lighting.FogEnd = nvEnabled and 100000 or 1000
    Lighting.Ambient = nvEnabled and Color3.fromRGB(200, 255, 200) or Color3.fromRGB(70, 70, 70)
end

local function getClosestEnemy()
    if not root then return nil end
    local closest, minDist = nil, 60
    for _, model in pairs(workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model.Name:lower():find("zombie") then
            local dist = (root.Position - model.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                closest = model
                minDist = dist
            end
        end
    end
    return closest
end

local function attackTarget(target)
    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

local autoAttackEnabled = false
local autoAttackConn
local function toggleAutoAttack()
    autoAttackEnabled = not autoAttackEnabled
    if autoAttackEnabled then
        autoAttackConn = RunService.RenderStepped:Connect(function()
            local target = getClosestEnemy()
            if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                root.CFrame = CFrame.lookAt(root.Position, Vector3.new(target.HumanoidRootPart.Position.X, root.Position.Y, target.HumanoidRootPart.Position.Z))
                attackTarget(target)
            end
        end)
    elseif autoAttackConn then
        autoAttackConn:Disconnect()
    end
end

local flyEnabled = false
local flyVelocity
local function toggleFly()
    flyEnabled = not flyEnabled
    if flyEnabled then
        if not root:FindFirstChild("BodyVelocity") then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.Name = "BodyVelocity"
            flyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            flyVelocity.Velocity = Vector3.zero
            flyVelocity.Parent = root

            RunService.RenderStepped:Connect(function()
                if flyEnabled and flyVelocity then
                    local moveVec = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - workspace.CurrentCamera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - workspace.CurrentCamera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + workspace.CurrentCamera.CFrame.RightVector end
                    flyVelocity.Velocity = moveVec.Unit * 90
                end
            end)
        end
    else
        if root:FindFirstChild("BodyVelocity") then
            root.BodyVelocity:Destroy()
        end
    end
end

local autoFarmEnabled = false
local autoFarmConn
local function toggleAutoFarm()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        autoFarmConn = RunService.RenderStepped:Connect(function()
            local target = getClosestEnemy()
            if target and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
                root.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                attackTarget(target)
            end
        end)
    elseif autoFarmConn then
        autoFarmConn:Disconnect()
    end
end

-- == TOMBOL GUI == --
addButton("✅ Anti Stun", antiStun)
addButton("💖 Auto Revive", autoRevive)
addButton("🔦 ESP (Zombie & Player)", brainESP)
addButton("⚡ Toggle Speed", toggleSpeed)
addButton("🚫 Anti Flash/Slow", antiFlash)
addButton("🗡️ Auto Attack + Aimbot", toggleAutoAttack)
addButton("🕊️ Toggle Fly", toggleFly)
addButton("🌙 Night Vision", toggleNightVision)
addButton("💰 Auto Farm", toggleAutoFarm)

-- == NOTIFIKASI == --
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "✅ Apiess GUI Aktif",
        Text = "Steal a Brainrot mode: Aman & Siap Farming!",
        Duration = 6
    })
end)

-- DONE
