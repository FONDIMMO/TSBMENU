local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- Создаем GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "TSB_Mega_Hub_Pishenak"
screenGui.ResetOnSpawn = false

-- Главная панель
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 220, 0, 320)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Заголовок
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "TSB: Pishenak Hub v3"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

-- Контейнер для кнопок
local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, 0, 1, -50)
container.Position = UDim2.new(0, 0, 0, 50)
container.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", container)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 8)

-- Кнопка сворачивания (Стрелка)
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 30, 0, 30)
toggleBtn.Position = mainFrame.Position + UDim2.new(0, 225, 0, 0)
toggleBtn.Text = "V"
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

-- Вспомогательная функция для дизайна кнопок
local function styleButton(btn)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
end

-- 1. ТЕЛЕПОРТ К БЛИЖАЙШЕЙ МУСОРКЕ
local trashBtn = Instance.new("TextButton", container)
trashBtn.Size = UDim2.new(0.9, 0, 0, 40)
trashBtn.Text = "Найти ближ. мусорку"
styleButton(trashBtn)

trashBtn.MouseButton1Click:Connect(function()
    local nearest = nil
    local minDist = math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("trash") and obj:IsA("BasePart") then
            local d = (player.Character.HumanoidRootPart.Position - obj.Position).Magnitude
            if d < minDist then
                minDist = d
                nearest = obj
            end
        end
    end
    if nearest then
        player.Character.HumanoidRootPart.CFrame = nearest.CFrame + Vector3.new(0, 3, 0)
    end
end)

-- 2. СИСТЕМА ПОЛЕТА
local flying = false
local flySpeed = 50
local bv, bg

local flyBtn = Instance.new("TextButton", container)
flyBtn.Size = UDim2.new(0.9, 0, 0, 40)
flyBtn.Text = "Полет: ВЫКЛ"
styleButton(flyBtn)

flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        flyBtn.Text = "Полет: ВКЛ"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0,0,0)
        
        bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = root.CFrame
        
        player.Character.Humanoid.PlatformStand = true
        
        task.spawn(function()
            while flying do
                local cam = workspace.CurrentCamera.CFrame
                local dir = Vector3.new(0,0,0)
                if uis:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
                bv.Velocity = dir * flySpeed
                bg.CFrame = cam
                task.wait()
            end
        end)
    else
        flyBtn.Text = "Полет: ВЫКЛ"
        flyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
        if player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
    end
end)

-- 3. МЕНЮ ИГРОКОВ
local pListFrame = Instance.new("Frame", screenGui)
pListFrame.Size = UDim2.new(0, 200, 0, 250)
pListFrame.Position = mainFrame.Position + UDim2.new(0, -210, 0, 0)
pListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
pListFrame.Visible = false
Instance.new("UICorner", pListFrame)

local closePList = Instance.new("TextButton", pListFrame)
closePList.Size = UDim2.new(0, 25, 0, 25)
closePList.Position = UDim2.new(1, -28, 0, 3)
closePList.Text = "X"
closePList.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
closePList.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", closePList).CornerRadius = UDim.new(1,0)
closePList.MouseButton1Click:Connect(function() pListFrame.Visible = false end)

local scroll = Instance.new("ScrollingFrame", pListFrame)
scroll.Size = UDim2.new(1, -10, 1, -40)
scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1
local sLayout = Instance.new("UIListLayout", scroll)
sLayout.Padding = UDim.new(0, 5)

local playersBtn = Instance.new("TextButton", container)
playersBtn.Size = UDim2.new(0.9, 0, 0, 40)
playersBtn.Text = "Список игроков"
styleButton(playersBtn)

playersBtn.MouseButton1Click:Connect(function()
    pListFrame.Visible = not pListFrame.Visible
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", scroll)
            b.Size = UDim2.new(1, -10, 0, 30)
            b.Text = p.DisplayName
            styleButton(b)
            b.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end)
            scroll.CanvasSize = UDim2.new(0, 0, 0, sLayout.AbsoluteContentSize.Y)
        end
    end
end)

-- АНИМАЦИИ И УПРАВЛЕНИЕ
local opened = true
toggleBtn.MouseButton1Click:Connect(function()
    opened = not opened
    local targetSize = opened and UDim2.new(0, 220, 0, 320) or UDim2.new(0, 220, 0, 45)
    tweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
    container.Visible = opened
    if not opened then pListFrame.Visible = false end
    toggleBtn.Rotation = opened and 0 or 180
end)

mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
    toggleBtn.Position = mainFrame.Position + UDim2.new(0, 225, 0, 0)
    pListFrame.Position = mainFrame.Position + UDim2.new(0, -210, 0, 0)
end)

uis.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.L then screenGui.Enabled = not screenGui.Enabled end
end)

print("TSB Script by Pishenak Loaded!")
