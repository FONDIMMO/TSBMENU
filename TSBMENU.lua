local player = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Удаляем старое GUI
if player.PlayerGui:FindFirstChild("PishenakModernHub") then
    player.PlayerGui.PishenakModernHub:Destroy()
end

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "PishenakModernHub"
sg.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 500, 0, 380)
main.Position = UDim2.new(0.5, -250, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- БОКОВАЯ ПАНЕЛЬ
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 130, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", sidebar)

local hubTitle = Instance.new("TextLabel", sidebar)
hubTitle.Size = UDim2.new(1, 0, 0, 50)
hubTitle.Text = "PISHENAK HUB"
hubTitle.TextColor3 = Color3.fromRGB(0, 255, 127)
hubTitle.Font = Enum.Font.GothamBold
hubTitle.TextSize = 14
hubTitle.BackgroundTransparency = 1

-- КОНТЕНТНАЯ ЧАСТЬ
local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -140, 1, -20)
container.Position = UDim2.new(0, 135, 0, 10)
container.BackgroundTransparency = 1

local page = Instance.new("ScrollingFrame", container)
page.Size = UDim2.new(1, 0, 1, 0)
page.BackgroundTransparency = 1
page.BorderSizePixel = 0
page.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", page)
layout.Padding = UDim.new(0, 8)

-- ФУНКЦИИ ИНТЕРФЕЙСА
local function addToggle(text, default, callback)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, -5, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", frame)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 44, 0, 22)
    btn.Position = UDim2.new(1, -54, 0.5, -11)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(60, 60, 60)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 11)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

local function addAction(text, callback)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.new(1, -5, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
end

--------------------------------------------------
-- ЛОГИКА ПОЛЕТА (РУЧНОЕ УПРАВЛЕНИЕ)
--------------------------------------------------
local flySpeed = 50
local flyConnection

local function toggleFly(active)
    _G.Flying = active
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if _G.Flying then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlyVel"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)

        local bg = Instance.new("BodyGyro", root)
        bg.Name = "FlyGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 9e4

        flyConnection = runService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local direction = Vector3.new(0, 0, 0)

            if uis:IsKeyDown(Enum.KeyCode.W) then direction = direction + cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then direction = direction - cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then direction = direction - cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then direction = direction + cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end

            bv.Velocity = direction.Unit * (direction.Magnitude > 0 and flySpeed or 0)
            bg.CFrame = cam.CFrame
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
        if root:FindFirstChild("FlyVel") then root.FlyVel:Destroy() end
        if root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
    end
end

--------------------------------------------------
-- КОНТЕНТ
--------------------------------------------------
addToggle("Manual Fly (Полет)", false, function(v) toggleFly(v) end)

addToggle("No Cooldown", false, function(v)
    _G.NoCD = v
    task.spawn(function()
        while _G.NoCD do
            pcall(function() player.Character:SetAttribute("Cooldown", 0) end)
            task.wait(0.1)
        end
    end)
end)

addToggle("Infinite Dash", false, function(v)
    _G.InfDash = v
    task.spawn(function()
        while _G.InfDash do
            pcall(function() player.Character:SetAttribute("DashCooldown", 0) end)
            task.wait(0.1)
        end
    end)
end)

addToggle("RGB ESP", false, function(v)
    _G.ESP = v
    task.spawn(function()
        while _G.ESP do
            local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local h = p.Character:FindFirstChild("ModernESP") or Instance.new("Highlight", p.Character)
                    h.Name = "ModernESP"
                    h.FillColor = color
                end
            end
            task.wait(0.1)
        end
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("ModernESP") then p.Character.ModernESP:Destroy() end
        end
    end)
end)

addAction("Телепорт к игроку", function()
    local players = game.Players:GetPlayers()
    if #players > 1 then
        local target = players[math.random(1, #players)]
        while target == player do target = players[math.random(1, #players)] end
        if target.Character then player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0) end
    end
end)

addAction("Телепорт к мусорке", function()
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    local target, minDist = nil, 999999
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("trash") and v:IsA("BasePart") then
            local d = (root.Position - v.Position).Magnitude
            if d < minDist then minDist, target = d, v end
        end
    end
    if target then root.CFrame = target.CFrame + Vector3.new(0, 3, 0) end
end)

addAction("FPS Booster", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("PostProcessEffect") or v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
        if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
    end
end)

uis.InputBegan:Connect(function(k, g)
    if not g and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)
