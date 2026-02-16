--[[
    VOID HUB v19 // XENO EDITION (TSB OVERLORD)
    Разработано для: Void Launcher
    Поддержка: The Strongest Battlegrounds
    Обновление: Ultimate Tracker & Cooldown Viewer
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
main.Size = UDim2.new(0, 550, 0, 450) -- Чуть увеличил под новые функции
main.Position = UDim2.new(0.5, -275, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
main.BorderSizePixel = 0
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(138, 43, 226)
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Sidebar
local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 140, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Instance.new("UICorner", side)

local title = Instance.new("TextLabel", side)
title.Size = UDim2.new(1, 0, 0, 60)
title.Text = "VOID XENO v19"
title.TextColor3 = Color3.fromRGB(138, 43, 226)
title.Font = Enum.Font.GothamBold; title.TextSize = 18; title.BackgroundTransparency = 1

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
-- НОВЫЕ ФУНКЦИИ v19
--------------------------------------------------

-- 1. Ultimate Tracker (TSB)
local ultTracker = false
makeToggle("ULTIMATE TRACKER", function(t)
    ultTracker = t
end)

-- 2. Cooldown Viewer (Detects used moves)
local cdViewer = false
makeToggle("COOLDOWN VIEWER", function(t)
    cdViewer = t
end)

-- Логика для Трекера и Кулдаунов
rs.RenderStepped:Connect(function()
    for _, player in pairs(p:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local head = char:FindFirstChild("Head")
            
            -- Ultimate Tracker Logic
            if ultTracker then
                local ultVal = player:FindFirstChild("UltimateValue") or char:FindFirstChild("UltimateValue") -- Зависит от версии TSB
                local marker = head:FindFirstChild("VoidUlt") or Instance.new("BillboardGui", head)
                marker.Name = "VoidUlt"
                marker.Size = UDim2.new(0, 100, 0, 20)
                marker.AlwaysOnTop = true
                marker.ExtentsOffset = Vector3.new(0, 3, 0)
                
                local frame = marker:FindFirstChild("Bar") or Instance.new("Frame", marker)
                frame.Name = "Bar"
                frame.Size = UDim2.new(1, 0, 0, 5)
                frame.BackgroundColor3 = Color3.new(0.2, 0, 0)
                
                local fill = frame:FindFirstChild("Fill") or Instance.new("Frame", frame)
                fill.Name = "Fill"
                fill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                -- В TSB ульта обычно в процентах. Если нет значения, ставим фейк для теста
                local percent = ultVal and (ultVal.Value / 100) or 0.5 
                fill.Size = UDim2.new(percent, 0, 1, 0)
            else
                if head:FindFirstChild("VoidUlt") then head.VoidUlt:Destroy() end
            end

            -- Cooldown Viewer Logic
            if cdViewer then
                -- В TSB кулдауны часто видны по анимациям или в папке в игроке
                local anims = char.Humanoid:GetPlayingAnimationTracks()
                if #anims > 0 then
                    local marker = head:FindFirstChild("VoidCD") or Instance.new("BillboardGui", head)
                    marker.Name = "VoidCD"
                    marker.Size = UDim2.new(0, 150, 0, 30)
                    marker.AlwaysOnTop = true
                    marker.ExtentsOffset = Vector3.new(0, 4.5, 0)
                    
                    local txt = marker:FindFirstChild("Label") or Instance.new("TextLabel", marker)
                    txt.Name = "Label"
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextColor3 = Color3.new(1, 1, 0)
                    txt.Font = Enum.Font.GothamBold
                    txt.TextSize = 12
                    
                    -- Если проигрывается атака, пишем "MOVE USED"
                    for _, a in pairs(anims) do
                        if a.Name:lower():find("attack") or a.Name:lower():find("skill") then
                            txt.Text = "SKILL USED! (CD START)"
                            task.delay(3, function() if txt then txt.Text = "READY" end end)
                        end
                    end
                end
            else
                if head:FindFirstChild("VoidCD") then head.VoidCD:Destroy() end
            end
        end
    end
end)

--------------------------------------------------
-- ОСТАЛЬНЫЕ ФУНКЦИИ (V18 STABLE)
--------------------------------------------------

local kAura = false
makeToggle("VOID KILL AURA", function(t)
    kAura = t
    task.spawn(function()
        while kAura do
            for _, player in pairs(p:GetPlayers()) do
                if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (lp.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 18 then
                        local tool = lp.Character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChild("Combat")
                        if tool then tool:Activate() end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end)

local autoQ = false
makeToggle("AUTO COUNTER (DODGE)", function(t)
    autoQ = t
    rs.Stepped:Connect(function()
        if autoQ then
            for _, enemy in pairs(p:GetPlayers()) do
                if enemy ~= lp and enemy.Character and enemy.Character:FindFirstChild("Humanoid") then
                    local dist = (lp.Character.HumanoidRootPart.Position - enemy.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 12 and #enemy.Character.Humanoid:GetPlayingAnimationTracks() > 0 then
                         vim:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                    end
                end
            end
        end
    end)
end)

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

uis.InputBegan:Connect(function(input, g)
    if not g and input.KeyCode == Enum.KeyCode.L then
        main.Visible = not main.Visible
    end
end)

print("VOID XENO v19 LOADED - Ultimate & Cooldowns Active")
