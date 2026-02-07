local player = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")

-- Удаляем старое GUI
if player.PlayerGui:FindFirstChild("PishenakModernHub") then
    player.PlayerGui.PishenakModernHub:Destroy()
end

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "PishenakModernHub"
sg.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 500, 0, 350)
main.Position = UDim2.new(0.5, -250, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- БОКОВАЯ ПАНЕЛЬ (Sidebar)
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 130, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sidebar.BorderSizePixel = 0
local sideCorner = Instance.new("UICorner", sidebar)
sideCorner.CornerRadius = UDim.new(0, 10)

-- Заголовок в сайдбаре
local hubTitle = Instance.new("TextLabel", sidebar)
hubTitle.Size = UDim2.new(1, 0, 0, 50)
hubTitle.Text = "PISHENAK HUB"
hubTitle.TextColor3 = Color3.new(1, 1, 1)
hubTitle.Font = Enum.Font.GothamBold
hubTitle.TextSize = 14
hubTitle.BackgroundTransparency = 1

-- КОНТЕНТНАЯ ЧАСТЬ (Справа)
local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -140, 1, -20)
container.Position = UDim2.new(0, 135, 0, 10)
container.BackgroundTransparency = 1

-- Списки разделов (Для примера сделаем пока один общий)
local page = Instance.new("ScrollingFrame", container)
page.Size = UDim2.new(1, 0, 1, 0)
page.BackgroundTransparency = 1
page.BorderSizePixel = 0
page.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", page)
layout.Padding = UDim.new(0, 8)

-- ФУНКЦИЯ СОЗДАНИЯ ПЕРЕКЛЮЧАТЕЛЯ (Toggle)
local function addToggle(text, default, callback)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, -5, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", frame)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -60, 0.5, -12)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- ФУНКЦИЯ СОЗДАНИЯ КНОПКИ (Button)
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

-- НАПОЛНЕНИЕ ФУНКЦИЯМИ
addToggle("No Cooldown", false, function(v)
    _G.NoCD = v
    task.spawn(function()
        while _G.NoCD do
            pcall(function()
                player.Character:SetAttribute("Cooldown", 0)
            end)
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

addAction("Teleport to Trash", function()
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    local target = nil
    local minDist = 999999
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("trash") and v:IsA("BasePart") then
            local d = (root.Position - v.Position).Magnitude
            if d < minDist then minDist = d target = v end
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

-- СКРЫТИЕ (L)
uis.InputBegan:Connect(function(k, g)
    if not g and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)
