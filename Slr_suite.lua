-- FAKE MESSAGE (visible when opened directly)
print("⚠️ WARNING: Your IP has been logged!")
print("This script is protected.")
return nil -- Stops execution if viewed raw

-- REAL SCRIPT (hidden, extracts only in-game)
--[[
-- DEEPXWEL SLR WORKING v6.9
-- FOR EDUCATIONAL PURPOSES ONLY

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIG (EDIT THESE)
local AIM_KEY = Enum.KeyCode.F
local ESP_COLOR = Color3.new(1, 0.2, 0.2) -- Red
local MAX_AIM_DIST = 300 -- Studs
local AIM_SMOOTHNESS = 0.3 -- 0.1-0.5
local FOV_SIZE = 120 -- Degrees
local REFRESH_TIME = 30 -- Seconds

-- PERMANENT FOV CIRCLE
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.Size = UDim2.new(0, FOV_SIZE*2, 0, FOV_SIZE*2)
FOVCircle.Position = UDim2.new(0.5, -FOV_SIZE, 0.5, -FOV_SIZE)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderColor3 = ESP_COLOR
FOVCircle.BorderSizePixel = 2
FOVCircle.Visible = true -- Always visible
FOVCircle.Parent = game:GetService("CoreGui")

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = FOVCircle

-- SIMPLE ESP
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local char = player.Character or player.CharacterAdded:Wait()
    local head = char:WaitForChild("Head")
    
    -- BOX ESP
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = head
    box.AlwaysOnTop = true
    box.Size = Vector3.new(2, 3, 1)
    box.Transparency = 0.5
    box.Color3 = ESP_COLOR
    box.ZIndex = 10
    box.Parent = head
    
    -- DISTANCE LABEL
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    
    local label = Instance.new("TextLabel")
    label.Text = player.Name
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = ESP_COLOR
    label.Parent = billboard
    billboard.Parent = head
    
    -- AUTO UPDATE
    RunService.Heartbeat:Connect(function()
        if char and head then
            local dist = (head.Position - Camera.CFrame.Position).Magnitude
            label.Text = player.Name.." ("..math.floor(dist).."m)"
            box.Adornee = head
            billboard.Enabled = dist < MAX_AIM_DIST
        end
    end)
end

-- FOV-BASED AIMBOT (300m RANGE)
local aiming = false

local function GetTargetInFOV()
    local closest, minDist = nil, MAX_AIM_DIST
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local dist = (head.Position - Camera.CFrame.Position).Magnitude
                if dist <= MAX_AIM_DIST then
                    local screenPos, visible = Camera:WorldToViewportPoint(head.Position)
                    if visible then
                        local angle = (Vector2.new(screenPos.X, screenPos.Y) - Camera.ViewportSize/2).Magnitude
                        if angle <= FOV_SIZE then
                            if dist < minDist then
                                closest = head
                                minDist = dist
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == AIM_KEY then
        aiming = true
        while aiming do
            local target = GetTargetInFOV()
            if target then
                -- Smooth aiming
                Camera.CFrame = Camera.CFrame:Lerp(
                    CFrame.new(Camera.CFrame.Position, target.Position),
                    AIM_SMOOTHNESS
                )
            end
            task.wait()
        end
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == AIM_KEY then
        aiming = false
    end
end)

-- AUTO REFRESH
task.spawn(function()
    while true do
        task.wait(REFRESH_TIME)
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    for _, obj in pairs(head:GetChildren()) do
                        if obj:IsA("BoxHandleAdornment") or obj:IsA("BillboardGui") then
                            obj:Destroy()
                        end
                    end
                    CreateESP(player)
                end
            end
        end
    end
end)

-- INITIAL SETUP
for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end
Players.PlayerAdded:Connect(CreateESP)

--]]
