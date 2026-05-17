local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

if game:GetService("CoreGui"):FindFirstChild("Fly.GUI") then
    return
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Fly.GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 165)
Frame.Position = UDim2.new(0.4, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Fly (Keyboard)"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local SpeedFrame = Instance.new("Frame")
SpeedFrame.Size = UDim2.new(0.85, 0, 0, 35)
SpeedFrame.Position = UDim2.new(0.075, 0, 0.28, 0)
SpeedFrame.BackgroundTransparency = 1
SpeedFrame.Parent = Frame

local MinusButton = Instance.new("TextButton")
MinusButton.Size = UDim2.new(0.25, 0, 1, 0)
MinusButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinusButton.Text = "-"
MinusButton.TextColor3 = Color3.new(1, 1, 1)
MinusButton.TextSize = 18
MinusButton.Font = Enum.Font.GothamBold
MinusButton.Parent = SpeedFrame

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0.45, 0, 1, 0)
SpeedBox.Position = UDim2.new(0.27, 0, 0, 0)
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.Text = "50"
SpeedBox.TextColor3 = Color3.new(1, 1, 1)
SpeedBox.TextSize = 16
SpeedBox.Font = Enum.Font.Gotham
SpeedBox.Parent = SpeedFrame

local PlusButton = Instance.new("TextButton")
PlusButton.Size = UDim2.new(0.25, 0, 1, 0)
PlusButton.Position = UDim2.new(0.73, 0, 0, 0)
PlusButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PlusButton.Text = "+"
PlusButton.TextColor3 = Color3.new(1, 1, 1)
PlusButton.TextSize = 18
PlusButton.Font = Enum.Font.GothamBold
PlusButton.Parent = SpeedFrame

Instance.new("UICorner", MinusButton).CornerRadius = UDim.new(0, 6)
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 6)
Instance.new("UICorner", PlusButton).CornerRadius = UDim.new(0, 6)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.85, 0, 0, 45)
ToggleButton.Position = UDim2.new(0.075, 0, 0.55, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "ENABLE FLY"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = Frame

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

local flying = false
local flySpeed = 50
local bodyVelocity
local connection
local holdConnection

local function updateDisplay()
    SpeedBox.Text = tostring(math.floor(flySpeed))
end

local function startFlying()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local root = character.HumanoidRootPart
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = true end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root

    connection = RunService.Heartbeat:Connect(function()
        if not flying then return end
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection -= Vector3.new(0,1,0) end

        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end

        bodyVelocity.Velocity = moveDirection * flySpeed
    end)
end

local function stopFlying()
    flying = false
    if connection then connection:Disconnect() connection = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.PlatformStand = false
    end
end

local function changeSpeed(amount)
    flySpeed = math.clamp(flySpeed + amount, 0, 50000)
    updateDisplay()
end

local function startHolding(amount)
    if holdConnection then holdConnection:Disconnect() end
    holdConnection = RunService.Heartbeat:Connect(function()
        changeSpeed(amount)
    end)
end

local function stopHolding()
    if holdConnection then
        holdConnection:Disconnect()
        holdConnection = nil
    end
end

MinusButton.MouseButton1Down:Connect(function() startHolding(-1) end)
MinusButton.MouseButton1Up:Connect(stopHolding)
MinusButton.MouseLeave:Connect(stopHolding)

PlusButton.MouseButton1Down:Connect(function() startHolding(1) end)
PlusButton.MouseButton1Up:Connect(stopHolding)
PlusButton.MouseLeave:Connect(stopHolding)

SpeedBox.FocusLost:Connect(function()
    flySpeed = math.clamp(tonumber(SpeedBox.Text) or 50, 0, 50000)
    updateDisplay()
end)

ToggleButton.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        ToggleButton.Text = "DISABLE FLY"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        startFlying()
    else
        ToggleButton.Text = "ENABLE FLY"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        stopFlying()
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flying then
        stopFlying()
        task.wait(0.3)
        startFlying()
    end
end)

updateDisplay()