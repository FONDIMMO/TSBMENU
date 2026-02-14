--[[
    VOID HUB v18 // XENO EDITION
    Разработано для: Void Launcher
    Поддержка: The Strongest Battlegrounds
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")
local vim = game:GetService("VirtualInputManager")

-- Очистка старого GUI
for _, v in pairs(coreGui:GetChildren()) do
    if v.Name == "VoidTSB_Xeno" then v:Destroy() end
end

local sg = Instance.new("ScreenGui", coreGui)
sg.Name = "VoidTSB_Xeno"

-- ГЛАВНЫЙ ДИЗАЙН (VOID AESTHETIC)
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 550, 0, 400)
main.Position = UDim2.new(0.5, -275, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Неоновое свечение Void
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(138, 43, 226) -- Фиолетовый Void
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Категории (Sidebar)
local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 140, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Instance.new("UICorner", side)

local title = Instance.new("TextLabel", side)
title.Size = UDim2.new(1, 0, 0, 60)
title.Text = "VOID XENO"
title.TextColor3 = Color3.fromRGB(138, 43, 226)
title.Font = Enum.Font.GothamBold; title.TextSize = 20; title.BackgroundTransparency = 1

local container = Instance.new("ScrollingFrame", main)
container.Size = UDim2.new(1, -160, 1, -20)
container.Position = UDim2.new(0, 150, 0, 10)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ScrollBarThickness = 0
local layout = Instance.new("UIListLayout", container); layout.Padding = UDim.new(0, 10)

-- Функция создания кнопок
local function makeToggle(txt, callback)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    btn.Text = txt
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(20, 20, 30)
        callback(state)
    end)
end

--------------------------------------------------
-- ФУНКЦИИ v18
--------------------------------------------------

-- 1. Void Kill Aura (Optimized for Xeno)
local kAura = false
makeToggle("VOID KILL AURA", function(t)
    kAura = t
    task.spawn(function()
        while kAura do
            for _, player in pairs(p:GetPlayers()) do
                if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (lp.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 18 then
                        -- Xeno Bypass Attack
                        local tool = lp.Character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChild("Combat")
                        if tool then tool:Activate() end
                    end
                end
            end
            task.wait(0.05) -- Быстрее чем в v17
        end
    end)
end)

-- 2. Auto-Counter (Q-Dodge)
local autoQ = false
makeToggle("AUTO COUNTER (DODGE)", function(t)
    autoQ = t
    rs.Stepped:Connect(function()
        if autoQ then
            for _, enemy in pairs(p:GetPlayers()) do
                if enemy ~= lp and enemy.Character and enemy.Character:FindFirstChild("Humanoid") then
                    local dist = (lp.Character.HumanoidRootPart.Position - enemy.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 12 and enemy.Character.Humanoid:GetPlayingAnimationTracks()[1] then
                         vim:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                    end
                end
            end
        end
    end)
end)

-- 3. Infinite Dash & Energy
makeToggle("VOID INFINITY (ENERGY)", function(t)
    local conn
    if t then
        conn = rs.Heartbeat:Connect(function()
            if lp.Character and lp.Character:FindFirstChild("Energy") then
                lp.Character.Energy.Value = 100
            end
        end)
    else
        if conn then conn:Disconnect() end
    end
end)

-- 4. ESP (Visual Void)
makeToggle("VOID VISION (ESP)", function(t)
    for _, player in pairs(p:GetPlayers()) do
        if player ~= lp and player.Character then
            local highlight = player.Character:FindFirstChild("VoidHigh") or Instance.new("Highlight", player.Character)
            highlight.Name = "VoidHigh"
            highlight.Enabled = t
            highlight.FillColor = Color3.fromRGB(138, 43, 226)
            highlight.OutlineColor = Color3.new(1, 1, 1)
        end
    end
end)

-- Скрыть/Показать на L
uis.InputBegan:Connect(function(input, g)
    if not g and input.KeyCode == Enum.KeyCode.L then
        main.Visible = not main.Visible
    end
end)

print("VOID XENO v18 LOADED")
