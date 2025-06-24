-- Полный финальный скрипт для Roblox Studio
-- LocalScript в StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    AimEnabled = false,
    ESPBox = false,
    ESPHealth = false,
    ESPTracer = false,
    ESPTrail = false,
    XRayEnabled = false,
}

local hitSoundId = "rbxassetid://78081415858723"
local deathSoundId = "rbxassetid://130772284"

local function Notify(text)
    local hint = Instance.new("Hint", workspace)
    hint.Text = text
    task.delay(2, function() hint:Destroy() end)
end

local function CreateCrosshair()
    local gui = Instance.new("ScreenGui")
    gui.Name = "Crosshair"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 2, 0, 20)
    frame.Position = UDim2.new(0.5, -1, 0.5, -10)
    frame.BackgroundColor3 = Color3.new(1, 1, 1)
    frame.BorderSizePixel = 0

    local frame2 = Instance.new("Frame", gui)
    frame2.Size = UDim2.new(0, 20, 0, 2)
    frame2.Position = UDim2.new(0.5, -10, 0.5, -1)
    frame2.BackgroundColor3 = Color3.new(1, 1, 1)
    frame2.BorderSizePixel = 0
end

CreateCrosshair()

local Gui = Instance.new("ScreenGui")
Gui.Name = "SimpleCheatMenu"
Gui.ResetOnSpawn = false
Gui.Parent = game.CoreGui

local Menu = Instance.new("Frame", Gui)
Menu.Size = UDim2.new(0, 220, 0, 280)
Menu.Position = UDim2.new(0, 20, 0, 100)
Menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Menu.BorderSizePixel = 0
Menu.Active = true
Menu.Draggable = true

local function CreateToggleButton(text, yPos, initialState, callback)
    local btn = Instance.new("TextButton", Menu)
    btn.Size = UDim2.new(0, 200, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = text .. ": OFF"

    local enabled = initialState

    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = text .. (enabled and ": ON" or ": OFF")
        callback(enabled)
        Notify(text .. (enabled and " включено" or " отключено"))
    end)

    return btn
end

local btnESPBox = CreateToggleButton("ESP Box", 20, false, function(state) Settings.ESPBox = state end)
local btnESPHealth = CreateToggleButton("ESP Health", 60, false, function(state) Settings.ESPHealth = state end)
local btnESPTracer = CreateToggleButton("ESP Tracer", 100, false, function(state) Settings.ESPTracer = state end)
local btnESPTrail = CreateToggleButton("ESP Trail", 140, false, function(state) Settings.ESPTrail = state end)
local btnXRay = CreateToggleButton("X-Ray", 180, false, function(state)
    Settings.XRayEnabled = state
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
            part.LocalTransparencyModifier = state and 0.6 or 0
        end
    end
end)
local btnAim = CreateToggleButton("AIM", 220, false, function(state) Settings.AimEnabled = state end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.B then
        Settings.ESPBox = not Settings.ESPBox
        btnESPBox.Text = "ESP Box: " .. (Settings.ESPBox and "ON" or "OFF")
        Notify("ESP Box " .. (Settings.ESPBox and "включено" or "отключено"))
    elseif input.KeyCode == Enum.KeyCode.H then
        Settings.ESPHealth = not Settings.ESPHealth
        btnESPHealth.Text = "ESP Health: " .. (Settings.ESPHealth and "ON" or "OFF")
        Notify("ESP Health " .. (Settings.ESPHealth and "включено" or "отключено"))
    elseif input.KeyCode == Enum.KeyCode.T then
        Settings.ESPTracer = not Settings.ESPTracer
        btnESPTracer.Text = "ESP Tracer: " .. (Settings.ESPTracer and "ON" or "OFF")
        Notify("ESP Tracer " .. (Settings.ESPTracer and "включено" or "отключено"))
    elseif input.KeyCode == Enum.KeyCode.R then
        Settings.ESPTrail = not Settings.ESPTrail
        btnESPTrail.Text = "ESP Trail: " .. (Settings.ESPTrail and "ON" or "OFF")
        Notify("ESP Trail " .. (Settings.ESPTrail and "включено" or "отключено"))
    elseif input.KeyCode == Enum.KeyCode.X then
        Settings.XRayEnabled = not Settings.XRayEnabled
        btnXRay.Text = "X-Ray: " .. (Settings.XRayEnabled and "ON" or "OFF")
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
                part.LocalTransparencyModifier = Settings.XRayEnabled and 0.6 or 0
            end
        end
        Notify("X-Ray " .. (Settings.XRayEnabled and "включено" or "отключено"))
    elseif input.KeyCode == Enum.KeyCode.F then
        Settings.AimEnabled = not Settings.AimEnabled
        btnAim.Text = "AIM: " .. (Settings.AimEnabled and "ON" or "OFF")
        Notify("AIM " .. (Settings.AimEnabled and "включено" or "отключено"))
    end
end)

local function IsEnemy(player)
    if not player then return false end
    if not player.Character then return false end
    if player == LocalPlayer then return false end
    if LocalPlayer.Team and player.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

local function GetNearestVisibleEnemy()
    local nearest
    local nearestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
            local head = player.Character.Head
            local root = player.Character.HumanoidRootPart
            local dist = (root.Position - Camera.CFrame.Position).Magnitude

            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

            local raycastResult = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position), raycastParams)

            if raycastResult and raycastResult.Instance:IsDescendantOf(player.Character) then
                if dist < nearestDistance then
                    nearest = player
                    nearestDistance = dist
                end
            end
        end
    end
    return nearest
end

local function CreateBox(player)
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if hrp:FindFirstChild("ESPBox") then return end

    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.Adornee = hrp
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0
    box.Color3 = Color3.new(1, 1, 1)
    box.Size = Vector3.new(2, 5, 1)
    box.Parent = hrp
end

local function RemoveBox(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local box = player.Character.HumanoidRootPart:FindFirstChild("ESPBox")
        if box then box:Destroy() end
    end
end

local function CreateHealthTag(player)
    if not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    if head:FindFirstChild("HealthTag") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 60, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 1.5, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 0, 0)
    label.TextScaled = true
    label.TextStrokeTransparency = 0.5
    label.Text = "HP"

    billboard.Parent = head
end

local function RemoveHealthTag(player)
    if player.Character and player.Character:FindFirstChild("Head") then
        local billboard = player.Character.Head:FindFirstChild("HealthTag")
        if billboard then billboard:Destroy() end
    end
end

local function CreateTracer(player)
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if hrp:FindFirstChild("ESPTracer") then return end

    local attachment0 = Instance.new("Attachment", Camera)
    attachment0.Name = "TracerAttach0"

    local attachment1 = Instance.new("Attachment", hrp)
    attachment1.Name = "TracerAttach1"

    local beam = Instance.new("Beam")
    beam.Name = "ESPTracer"
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.FaceCamera = true
    beam.Width0 = 0.03
    beam.Width1 = 0.03
    beam.Color = ColorSequence.new(Color3.new(0, 1, 0))
    beam.Parent = hrp
end

local function RemoveTracer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local tracer = hrp:FindFirstChild("ESPTracer")
        if tracer then
            if tracer.Attachment0 then tracer.Attachment0:Destroy() end
            if tracer.Attachment1 then tracer.Attachment1:Destroy() end
            tracer:Destroy()
        end
    end
end

local function CreateTrail(player)
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if hrp:FindFirstChild("ESPTrail") then return end

    local att0 = Instance.new("Attachment", hrp)
    att0.Name = "TrailAttach0"
    local att1 = Instance.new("Attachment", hrp)
    att1.Name = "TrailAttach1"

    local trail = Instance.new("Trail")
    trail.Name = "ESPTrail"
    trail.Attachment0 = att0
    trail.Attachment1 = att1
    trail.Lifetime = 1
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Color = ColorSequence.new(Color3.new(0, 1, 1))

    trail.Parent = hrp
end

local function RemoveTrail(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local att0 = hrp:FindFirstChild("TrailAttach0")
        local att1 = hrp:FindFirstChild("TrailAttach1")
        local trail = hrp:FindFirstChild("ESPTrail")
        if att0 then att0:Destroy() end
        if att1 then att1:Destroy() end
        if trail then trail:Destroy() end
    end
end

local lastHealths = {}

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid

            if Settings.ESPBox then
                CreateBox(player)
            else
                RemoveBox(player)
            end

            if Settings.ESPHealth then
                CreateHealthTag(player)
                if player.Character and player.Character.Head and player.Character.Head:FindFirstChild("HealthTag") then
                    local billboard = player.Character.Head.HealthTag
                    local label = billboard:FindFirstChildWhichIsA("TextLabel")
                    if label then
                        label.Text = "HP: "..math.floor(humanoid.Health)
                    end
                end
            else
                RemoveHealthTag(player)
            end

            if Settings.ESPTracer then
                CreateTracer(player)
            else
                RemoveTracer(player)
            end

            if Settings.ESPTrail then
                CreateTrail(player)
            else
                RemoveTrail(player)
            end
        else
            RemoveBox(player)
            RemoveHealthTag(player)
            RemoveTracer(player)
            RemoveTrail(player)
        end
    end

    if Settings.AimEnabled then
        local target = GetNearestVisibleEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") and target.Character:FindFirstChild("Humanoid") then
            local headPos = target.Character.Head.Position
            local camPos = Camera.CFrame.Position

            Camera.CFrame = CFrame.new(camPos, headPos)

            local humanoid = target.Character.Humanoid

            local lastHealth = lastHealths[target]
            if lastHealth and humanoid.Health < lastHealth then
                local soundHit = Instance.new("Sound", Camera)
                soundHit.SoundId = hitSoundId
                soundHit.Volume = 1
                soundHit:Play()
                game.Debris:Add
