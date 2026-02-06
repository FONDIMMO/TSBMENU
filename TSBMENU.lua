local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- Создаем GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "TSB_Final_By_Pishenak"
screenGui.ResetOnSpawn = false

-- Главная панель
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 220, 0, 280)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

-- Заголовок
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "TSB: Pishenak Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

-- Контейнер для кнопок (чтобы скрывались при сворачивании)
local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, 0, 1, -40)
container.Position = UDim2.new(0, 0, 0, 40)
container.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", container)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 8)

-- Кнопка-стрелка
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 30, 0, 30)
toggleBtn.Position = mainFrame.Position + UDim2.new(0, 225, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
toggleBtn.Text = "V"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold

local tCorner = Instance.new("UICorner", toggleBtn)
tCorner.CornerRadius = UDim.new(1, 0)

-- Вспомогательная функция для кнопок
local function createMenuBtn(txt)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Text = txt
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

-- 1. ТЕЛЕПОРТ К МУСОРКЕ
local trashBtn = createMenuBtn("Найти мусорку")
trashBtn.MouseButton1Click:Connect(function()
    local found = false
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("trash") and obj:IsA("BasePart") then
            player.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
            found = true
            break
        end
    end
    trashBtn.Text = found and "Найдено!" or "Не найдено"
    task.wait(1)
    trashBtn.Text = "Найти мусорку"
end)

-- 2. МЕНЮ ИГРОКОВ
local pListFrame = Instance.new("ScrollingFrame", screenGui)
pListFrame.Size = UDim2.new(0, 180, 0, 200)
pListFrame.Position = mainFrame.Position + UDim2.new(0, -190, 0, 0)
pListFrame.Visible = false
pListFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", pListFrame)

local pListLayout = Instance.new("UIListLayout", pListFrame)
pListLayout.Padding = UDim.new(0, 5)

local playersBtn = createMenuBtn("Список игроков")
playersBtn.MouseButton1Click:Connect(function()
    pListFrame.Visible = not pListFrame.Visible
    for _, c in pairs(pListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then
            local pBtn = Instance.new("TextButton", pListFrame)
            pBtn.Size = UDim2.new(1, 0, 0, 30)
            pBtn.Text = p.DisplayName
            pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            pBtn.TextColor3 = Color3.new(1, 1, 1)
            pBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end)
        end
    end
end)

-- АНИМАЦИЯ СВОРАЧИВАНИЯ
local opened = true
toggleBtn.MouseButton1Click:Connect(function()
    opened = not opened
    local targetSize = opened and UDim2.new(0, 220, 0, 280) or UDim2.new(0, 220, 0, 40)
    local targetRot = opened and 0 or 180
    
    tweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    tweenService:Create(toggleBtn, TweenInfo.new(0.4), {Rotation = targetRot}):Play()
    container.Visible = opened
    if not opened then pListFrame.Visible = false end
end)

-- ПРИВЯЗКА КНОПКИ К ПАНЕЛИ
mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
    toggleBtn.Position = mainFrame.Position + UDim2.new(0, 225, 0, 0)
    pListFrame.Position = mainFrame.Position + UDim2.new(0, -190, 0, 0)
end)

-- СКРЫТИЕ НА КЛАВИШУ L
uis.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.L then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

print("TSB Script by Pishenak Loaded! Toggle: L")
