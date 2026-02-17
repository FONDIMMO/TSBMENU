--[[
    VOID HUB v21 // ULTIMATE OVERLORD
    - Дизайн: Premium Neon Void
    - Функции: Fly, Speed, Kill Aura, Ult Tracker (FIXED)
    - Скрытие: Клавиша [L]
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")

-- Очистка старых версий
for _, v in pairs(coreGui:GetChildren()) do
    if v.Name == "Void_v20" then v:Destroy() end
end

local sg = Instance.new("ScreenGui", coreGui)
sg.Name = "Void_v20"

-- [ ГЛАВНОЕ МЕНЮ - КРАСИВЫЙ ДИЗАЙН ]
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 480, 0, 520)
main.Position = UDim2.new(0.5, -240, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

-- Неоновая обводка
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(138, 43, 226)
stroke.Thickness = 2

-- Шапка
local head = Instance.new("Frame", main)
head.Size = UDim2.new(1, 0, 0, 50)
head.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
Instance.new("UICorner", head)

local title = Instance.new("TextLabel", head)
title.Size = UDim2.new(1, 0, 1, 0)
title.Text = "VOID HUB v20 // XENO"
title.TextColor3 = Color3.fromRGB(138, 43, 226)
title.Font = Enum.Font.GothamBold
title.TextSize = 20; title.BackgroundTransparency = 1

-- Скролл для кнопок
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -70)
scroll.Position = UDim2.new(0, 10, 0, 60)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 2
scroll.CanvasSize = UDim2.new(0, 0, 1.5, 0)
local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0, 8)

-- Функция создания красивых кнопок
local function makeBtn(name, desc, color, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, 0, 0, 55)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    b.Text = ""
    Instance.new("UICorner", b)
    
    local t = Instance.new("TextLabel", b)
    t.Size = UDim2.new(1, -20, 0, 25); t.Position = UDim2.new(0, 15, 0, 5)
    t.Text = name; t.TextColor3 = color; t.Font = Enum.Font.GothamBold; t.TextSize = 14; t.TextXAlignment = 0; t.BackgroundTransparency = 1
    
    local d = Instance.new("TextLabel", b)
    d.Size = UDim2.new(1, -20, 0, 20); d.Position = UDim2.new(0, 15, 0, 25)
    d.Text = desc; d.TextColor3 = Color3.new(0.5, 0.5, 0.5); d.Font = Enum.Font.Gotham; d.TextSize = 10; d.TextXAlignment = 0; d.BackgroundTransparency = 1

    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.BackgroundColor3 = active and Color3.fromRGB(35, 35, 50) or Color3.fromRGB(20, 20, 30)
        callback(active)
    end)
end

--------------------------------------------------
-- ФУНКЦИИ
--------------------------------------------------

-- 1. ПОЛЕТ (FLY)
local flying = false
local flySpeed = 50
makeBtn("VOID FLY", "Свободный полет (W/A/S/D)", Color3.new(0, 1, 1), function(t)
    flying = t
    local bv = lp.Character.HumanoidRootPart:FindFirstChild("VoidFlyBV") or Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
    bv.Name = "VoidFlyBV"
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    
    task.spawn(function()
        while flying do
            local dir = workspace.CurrentCamera.CFrame.LookVector
            local move = Vector3.new(0,0,0)
            if uis:IsKeyDown(Enum.KeyCode.W) then move = move + dir end
            if uis:IsKeyDown(Enum.KeyCode.S) then move = move - dir end
            bv.Velocity = move * flySpeed
            task.wait()
        end
        bv.Velocity = Vector3.new(0,0,0)
        if not flying then bv:Destroy() end
    end)
end)

-- 2. KILL AURA (TSB)
local aura = false
makeBtn("KILL AURA", "Авто-атака ближайших целей", Color3.new(1, 0, 0), function(t)
    aura = t
    while aura do
        pcall(function()
            for _, v in pairs(p:GetPlayers()) do
                if v ~= lp and v.Character and (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude < 15 then
                    local tool = lp.Character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChild("Combat")
                    if tool then tool:Activate() end
                end
            end
        end)
        task.wait(0.1)
    end
end)

-- 3. ULTIMATE TRACKER (FIXED)
local showUlt = false
makeBtn("ULT TRACKER", "Показывает прогресс ульты врага", Color3.new(1, 1, 0), function(t)
    showUlt = t
    rs.RenderStepped:Connect(function()
        if not showUlt then return end
        for _, v in pairs(p:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
                -- Пытаемся найти значение ульты в разных местах (зависит от игры)
                local uVal = v:FindFirstChild("Ultimate") or v:FindFirstChild("UltimateValue") or v:FindFirstChild("leaderstats") and v.leaderstats:FindFirstChild("Ultimate")
                
                local head = v.Character.Head
                local gui = head:FindFirstChild("VoidUlt") or Instance.new("BillboardGui", head)
                gui.Name = "VoidUlt"; gui.Size = UDim2.new(0, 100, 0, 15); gui.AlwaysOnTop = true; gui.ExtentsOffset = Vector3.new(0, 3, 0)
                
                local bar = gui:FindFirstChild("Bar") or Instance.new("Frame", gui)
                bar.Name = "Bar"; bar.Size = UDim2.new(1, 0, 1, 0); bar.BackgroundColor3 = Color3.new(0,0,0)
                
                local fill = bar:FindFirstChild("Fill") or Instance.new("Frame", bar)
                fill.Name = "Fill"; fill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
                
                -- Если значение не найдено, ставим 0, если найдено - вычисляем %
                local val = uVal and (uVal.Value / 100) or 0
                fill.Size = UDim2.new(math.clamp(val, 0, 1), 0, 1, 0)
            end
        end
    end)
end)

-- 4. SPEED HACK
local sEnable = false
makeBtn("VOID SPEED", "Ускорение персонажа", Color3.new(0, 1, 0), function(t)
    sEnable = t
    task.spawn(function()
        while sEnable do
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.WalkSpeed = 60
            end
            task.wait(0.1)
        end
        lp.Character.Humanoid.WalkSpeed = 16
    end)
end)

-- Скрытие на L
uis.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

print("VOID HUB v20 PRENIUM LOADED")
