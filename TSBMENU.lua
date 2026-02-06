--[[
    PISHENAK FREE HUB (Universal Edition)
    Name: PremiumHumTSBScript.lua
]]

local player = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")

-- Удаляем старое меню при перезапуске
if player.PlayerGui:FindFirstChild("PishenakFreeHub") then
    player.PlayerGui.PishenakFreeHub:Destroy()
end

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "PishenakFreeHub"
sg.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 220, 0, 320)
main.Position = UDim2.new(0.5, -110, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BackgroundTransparency = 0.2
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Заголовок
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "PISHENAK FREE v4"
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
Instance.new("UICorner", title)

-- Список функций
local list = Instance.new("ScrollingFrame", main)
list.Size = UDim2.new(1, -10, 1, -50)
list.Position = UDim2.new(0, 5, 0, 45)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Функция для создания кнопок
local function addBtn(text, color, callback)
    local b = Instance.new("TextButton", list)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Text = text
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- 1. RGB ESP (Highlight)
local espOn = false
addBtn("RGB ESP: OFF", Color3.fromRGB(50, 50, 50), function(btn)
    espOn = not espOn
    btn.Text = espOn and "RGB ESP: ON" or "RGB ESP: OFF"
    btn.TextColor3 = espOn and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
    
    task.spawn(function()
        while espOn do
            local rainbow = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                if p ~= player and p.Character then
                    local h = p.Character:FindFirstChild("FreeESP") or Instance.new("Highlight", p.Character)
                    h.Name = "FreeESP"
                    h.FillColor = rainbow
                    h.OutlineColor = Color3.new(1, 1, 1)
                end
            end
            task.wait(0.1)
        end
        -- Чистка
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("FreeESP") then
                p.Character.FreeESP:Destroy()
            end
        end
    end)
end)

-- 2. Телепорт к ближайшей мусорке
addBtn("Ближ. мусорка", Color3.fromRGB(50, 50, 50), function()
    local target = nil
    local minDist = 999999
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("trash") and v:IsA("BasePart") then
            local d = (player.Character.HumanoidRootPart.Position - v.Position).Magnitude
            if d < minDist then minDist = d target = v end
        end
    end
    if target then player.Character.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 3, 0) end
end)

-- 3. Улучшенный полет
local flying = false
addBtn("Полет: OFF", Color3.fromRGB(50, 50, 50), function(btn)
    flying = not flying
    btn.Text = flying and "Полет: ON" or "Полет: OFF"
    btn.TextColor3 = flying and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
    
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if flying then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlyVel"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while flying do
                bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * 100
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

-- 4. Speed Hack (Бег)
local speedOn = false
addBtn("Быстрый бег: OFF", Color3.fromRGB(50, 50, 50), function(btn)
    speedOn = not speedOn
    btn.Text = speedOn and "Быстрый бег: ON" or "Быстрый бег: OFF"
    player.Character.Humanoid.WalkSpeed = speedOn and 100 or 16
end)

-- Скрытие на L
uis.InputBegan:Connect(function(k, g)
    if not g and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

print("Pishenak Free Hub Loaded!")
