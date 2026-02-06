local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- Создаем GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "TSB_Fixed_By_Pishenak"
screenGui.ResetOnSpawn = false

-- Главная панель
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 220, 0, 280)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -140)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Заголовок
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "TSB: Pishenak Hub v2"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Font = Enum.Font.GothamBold

local container = Instance.new("Frame", mainFrame)
container.Size = UDim2.new(1, 0, 1, -45)
container.Position = UDim2.new(0, 0, 0, 45)
container.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", container)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 10)

-- Кнопка сворачивания (Стрелка)
local toggleBtn = Instance.new("TextButton", screenGui)
toggleBtn.Size = UDim2.new(0, 30, 0, 30)
toggleBtn.Position = mainFrame.Position + UDim2.new(0, 225, 0, 0)
toggleBtn.Text = "V"
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

-- 1. ИСПРАВЛЕННЫЙ ТЕЛЕПОРТ (К БЛИЖАЙШЕЙ МУСОРКЕ)
local function getNearestTrash()
    local nearest = nil
    local minDict = math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("trash") and obj:IsA("BasePart") then
            local dist = (player.Character.HumanoidRootPart.Position - obj.Position).Magnitude
            if dist < minDict then
                minDict = dist
                nearest = obj
            end
        end
    end
    return nearest
end

local trashBtn = Instance.new("TextButton", container)
trashBtn.Size = UDim2.new(0.9, 0, 0, 40)
trashBtn.Text = "Взять ближ. мусорку"
trashBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
trashBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", trashBtn)

trashBtn.MouseButton1Click:Connect(function()
    local target = getNearestTrash()
    if target then
        player.Character.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 3, 0)
    end
end)

-- 2. МЕНЮ ИГРОКОВ С КНОПКОЙ ЗАКРЫТИЯ
local pListFrame = Instance.new("Frame", screenGui)
pListFrame.Size = UDim2.new(0, 200, 0, 250)
pListFrame.Position = mainFrame.Position + UDim2.new(0, -210, 0, 0)
pListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
pListFrame.Visible = false
Instance.new("UICorner", pListFrame)

local pTitle = Instance.new("TextLabel", pListFrame)
pTitle.Size = UDim2.new(1, -30, 0, 30)
pTitle.Text = " Выберите игрока"
pTitle.TextColor3 = Color3.new(1, 1, 1)
pTitle.BackgroundTransparency = 1
pTitle.TextXAlignment = Enum.TextXAlignment.Left

local closePList = Instance.new("TextButton", pListFrame)
closePList.Size = UDim2.new(0, 25, 0, 25)
closePList.Position = UDim2.new(1, -28, 0, 3)
closePList.Text = "X"
closePList.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
closePList.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", closePList)
closePList.MouseButton1Click:Connect(function() pListFrame.Visible = false end)

local scroll = Instance.new("ScrollingFrame", pListFrame)
scroll.Size = UDim2.new(1, -10, 1, -40)
scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local sLayout = Instance.new("UIListLayout", scroll)
sLayout.Padding = UDim.new(0, 5)

local playersBtn = Instance.new("TextButton", container)
playersBtn.Size = UDim2.new(0.9, 0, 0, 40)
playersBtn.Text = "Список игроков"
playersBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
playersBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", playersBtn)

playersBtn.MouseButton1Click:Connect(function()
    pListFrame.Visible = not pListFrame.Visible
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player then
            local b = Instance.new("TextButton", scroll)
            b.Size = UDim2.new(1, -10, 0, 30)
            b.Text = p.DisplayName
            b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            b.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end)
            scroll.CanvasSize = UDim2.new(0, 0, 0, sLayout.AbsoluteContentSize.Y)
        end
    end
end)

-- Анимация сворачивания основного меню
local opened = true
toggleBtn.MouseButton1Click:Connect(function()
    opened = not opened
    local targetSize = opened and UDim2.new(0, 220, 0, 280) or UDim2.new(0, 220, 0, 40)
    tweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
    container.Visible = opened
    if not opened then pListFrame.Visible = false end
    toggleBtn.Rotation = opened and 0 or 180
end)

-- Слежение за позицией (чтобы всё двигалось вместе)
mainFrame:GetPropertyChangedSignal("Position"):Connect(function()
    toggleBtn.Position = mainFrame.Position + UDim2.new(0, 225, 0, 0)
    pListFrame.Position = mainFrame.Position + UDim2.new(0, -210, 0, 0)
end)

-- Клавиша L для полного скрытия
table.insert(getgenv and getgenv() or {}, uis.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Enum.KeyCode.L then screenGui.Enabled = not screenGui.Enabled end
end))

print("Исправленный скрипт загружен! Мусорки и меню работают.")
