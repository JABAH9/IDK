local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local hitSoundId = "rbxassetid://78081415858723"
local deathSoundId = "rbxassetid://130772284"

local Settings = {
    ESPBox = false,
    ESPHealth = false,
    ESPTracer = false,
    ESPTrail = false,
    AIM = false,
    AIMSharp = false, -- резкий аим
    XRay = false,
}

local function Notify(text)
    local hint = Instance.new("Hint", workspace)
    hint.Text = text
    task.delay(2, function() hint:Destroy() end)
end

-- Создаем прицел
local function CreateCrosshair()
    if game.CoreGui:FindFirstChild("CrosshairGui") then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "CrosshairGui"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    local vertical = Instance.new("Frame", gui)
    vertical.Size = UDim2.new(0, 2, 0, 20)
    vertical.Position = UDim2.new(0.5, -1, 0.5, -10)
    vertical.BackgroundColor3 = Color3.new(1,1,1)
    vertical.BorderSizePixel = 0

    local horizontal = Instance.new("Frame", gui)
    horizontal.Size = UDim2.new(0, 20, 0, 2)
    horizontal.Position = UDim2.new(0.5, -10, 0.5, -1)
    horizontal.BackgroundColor3 = Color3.new(1,1,1)
    horizontal.BorderSizePixel = 0
end
CreateCrosshair()

-- Меню
local Gui = Instance.new("ScreenGui")
Gui.Name = "CheatMenuGui"
Gui.ResetOnSpawn = false
Gui.Parent = game.CoreGui

local Menu = Instance.new("Frame", Gui)
Menu.Size = UDim2.new(0, 300, 0, 350)
Menu.Position = UDim2.new(0, 20, 0, 100)
Menu.BackgroundColor3 = Color3.fromRGB(30,30,30)
Menu.BorderSizePixel = 0
Menu.Active = true
Menu.Draggable = true

-- Вкладки
local function CreateTabButton(name, posX)
    local btn = Instance.new("TextButton", Menu)
    btn.Size = UDim2.new(0, 90, 0, 30)
    btn.Position = UDim2.new(0, posX, 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name
    return btn
end

local espTabBtn = CreateTabButton("ESP", 5)
local aimTabBtn = CreateTabButton("AIM", 100)
local configTabBtn = CreateTabButton("Config", 195)

local contentFrames = {}
local function CreateContentFrame()
    local frame = Instance.new("Frame", Menu)
    frame.Size = UDim2.new(1, -20, 1, -50)
    frame.Position = UDim2.new(0, 10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.Visible = false
    return frame
end

contentFrames.ESP = CreateContentFrame()
contentFrames.AIM = CreateContentFrame()
contentFrames.Config = CreateContentFrame()

local currentTab = nil
local function SwitchTab(tabName)
    for k,v in pairs(contentFrames) do
        v.Visible = (k == tabName)
    end
    currentTab = tabName
end

espTabBtn.MouseButton1Click:Connect(function() SwitchTab("ESP") end)
aimTabBtn.MouseButton1Click:Connect(function() SwitchTab("AIM") end)
configTabBtn.MouseButton1Click:Connect(function() SwitchTab("Config") end)

SwitchTab("ESP")

local function CreateToggleButton(parent, text, yPos, initialState, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, 260, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)
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

-- ESP кнопки
local btnESPBox = CreateToggleButton(contentFrames.ESP, "Box", 10, false, function(state) Settings.ESPBox = state end)
local btnESPHealth = CreateToggleButton(contentFrames.ESP, "Health", 55, false, function(state) Settings.ESPHealth = state end)
local btnESPTracer = CreateToggleButton(contentFrames.ESP, "Tracer", 100, false, function(state) Settings.ESPTracer = state end)
local btnESPTrail = CreateToggleButton(contentFrames.ESP, "Trail", 145, false, function(state) Settings.ESPTrail = state end)
local btnXRay = CreateToggleButton(contentFrames.ESP, "X-Ray", 190, false, function(state)
    Settings.XRay = state
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) then
            part.LocalTransparencyModifier = state and 0.6 or 0
        end
    end
end)

-- AIM кнопки
local btnAIM = CreateToggleButton(contentFrames.AIM, "AIM", 10, false, function(state) Settings.AIM = state end)
local btnAIMSharp = CreateToggleButton(contentFrames.AIM, "AIM Sharp (резкий)", 55, false, function(state) Settings.AIMSharp = state end)

-- Config кнопка (пример)
local SaveBtn = Instance.new("TextButton", contentFrames.Config)
SaveBtn.Size = UDim2.new(0, 260, 0, 40)
SaveBtn.Position = UDim2.new(0, 10, 0, 10)
SaveBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
SaveBtn.TextColor3 = Color3.new(1,1,1)
SaveBtn.Font = Enum.Font.SourceSansBold
SaveBtn.TextSize = 18
SaveBtn.Text = "Save Config (пример)"
SaveBtn.Parent = contentFrames.Config

SaveBtn.MouseButton1Click:Connect(function()
    Notify("Конфиг сохранён (просто уведомление)")
end)

-- Проверка врага (не союзник)
local function IsEnemy(player)
    if not player or not player.Character then return false end
    if player == LocalPlayer then return false end
    if LocalPlayer.Team and player.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

-- Найти ближайшего видимого врага
local function GetNearestVisibleEnemy()
    local nearest
    local nearestDist = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
            local head = player.Character.Head
            local dist = (head.Position - Camera.CFrame.Position).Magnitude
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local rayResult = workspace:Raycast(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position), rayParams)
            if rayResult and rayResult.Instance:IsDescendantOf(player.Character) then
                if dist < nearestDist then
                    nearest = player
                    nearestDist = dist
                end
            end
        end
    end
    return nearest
end

-- ESP объекты
local Boxes = {}
local HealthTags = {}
local Tracers = {}
local Trails = {}

local function CreateBox(player)
    if Boxes[player] then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "ESPBox"
    box.Adornee = player.Character.HumanoidRootPart
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0
    box.Color3 = Color3.new(1,1,1)
    box.Size = Vector3.new(2,5,1)
    box.Parent = player.Character.HumanoidRootPart
    Boxes[player] = box
end

local function RemoveBox(player)
    if Boxes[player] then
        Boxes[player]:Destroy()
        Boxes[player] = nil
    end
end

local function CreateHealthTag(player)
    if HealthTags[player] then return end
    if not player.Character or not player.Character:FindFirstChild("Head") then return end
    local head = player.Character.Head
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 60, 0, 20)
    billboard.StudsOffset = Vector3.new(0,1.5,0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,0,0)
    label.TextScaled = true
    label.TextStrokeTransparency = 0.5
    label.Text = "HP"

    billboard.Parent = head
    HealthTags[player] = label
end

local function RemoveHealthTag(player)
    if HealthTags[player] then
        local gui = HealthTags[player].Parent
        if gui then gui:Destroy() end
        HealthTags[player] = nil
    end
end

local function UpdateHealthTag(player)
    if HealthTags[player] and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        HealthTags[player].Text = "HP: "..math.floor(humanoid.Health)
    end
end

local function CreateTracer(player)
    if Tracers[player] then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local hrp = player.Character.HumanoidRootPart
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
    beam.Color = ColorSequence.new(Color3.new(0,1,0))
    beam.Parent = hrp

    Tracers[player] = {beam=beam, a0=attachment0, a1=attachment1}
end

local function RemoveTracer(player)
    if Tracers[player] then
        local data = Tracers[player]
        if data.beam then data.beam:Destroy() end
        if data.a0 then data.a0:Destroy() end
        if data.a1 then data.a1:Destroy() end
        Tracers[player] = nil
    end
end

local function CreateTrail(player)
    if Trails[player] then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local hrp = player.Character.HumanoidRootPart
    local att0 = Instance.new("Attachment", hrp)
    att0.Name = "TrailAttach0"
    local att1 = Instance.new("Attachment", hrp)
    att1.Name = "TrailAttach1"

    local trail = Instance.new("Trail")
    trail.Name = "ESPTrail"
    trail.Attachment0 = att0
    trail.Attachment1 = att1
    trail.Lifetime = 1
    trail.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
    trail.Color = ColorSequence.new(Color3.new(0,1,1))

    trail.Parent = hrp
    Trails[player] = {trail=trail, a0=att0, a1=att1}
end

local function RemoveTrail(player)
    if Trails[player] then
        local data = Trails[player]
        if data.trail then data.trail:Destroy() end
        if data.a0 then data.a0:Destroy() end
        if data.a1 then data.a1:Destroy() end
        Trails[player] = nil
    end
end

-- Удаление всех ESP при отключении
local function ClearAllESP()
    for player,_ in pairs(Boxes) do RemoveBox(player) end
    for player,_ in pairs(HealthTags) do RemoveHealthTag(player) end
    for player,_ in pairs(Tracers) do RemoveTracer(player) end
    for player,_ in pairs(Trails) do RemoveTrail(player) end
end

-- Обновление ESP каждый кадр
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if IsEnemy(player) and player.Character and player.Character:FindFirstChild("Humanoid") then
            if Settings.ESPBox then
                CreateBox(player)
            else
                RemoveBox(player)
            end

            if Settings.ESPHealth then
                CreateHealthTag(player)
                UpdateHealthTag(player)
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
