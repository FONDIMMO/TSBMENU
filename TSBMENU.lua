--[[
    PISHENAK HUB v16 (ULTIMATE BYPASS)
    - Настройка скорости полета (Slider)
    - Kill Aura (Радиус 15м)
    - Safe Mode (Авто-блок при низком HP)
    - Chat Logger (Логи в F9)
    - Player List & Killer Detector
    КЛАВИША: [L] Скрыть меню
]]

-- Очистка старых версий
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "PishenakModernHub" then v:Destroy() end
end

local p = game:GetService("Players")
local lp = p.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local tw = game:GetService("TweenService")

local sg = Instance.new("ScreenGui", coreGui)
sg.Name = "PishenakModernHub"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 520, 0, 420)
main.Position = UDim2.new(0.5, -260, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)
local neon = Instance.new("UIStroke", main)
neon.Color = Color3.fromRGB(0, 255, 127)
neon.Thickness = 2

-- САЙДБАР (СЛЕВА)
local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 120, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Instance.new("UICorner", side)

local label = Instance.new("TextLabel", side)
label.Size = UDim2.new(1, 0, 0, 50)
label.Text = "PISHENAK"
label.TextColor3 = Color3.fromRGB(0, 255, 127)
label.Font = Enum.Font.GothamBold
label.TextSize = 18
label.BackgroundTransparency = 1

-- КОНТЕНТ (ЦЕНТР)
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0, 200, 1, -20)
scroll.Position = UDim2.new(0, 130, 0, 10)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
local lay = Instance.new("UIListLayout", scroll)
lay.Padding = UDim.new(0, 6)

-- ПАНЕЛЬ ИГРОКОВ (СПРАВА)
local pListFrame = Instance.new("Frame", main)
pListFrame.Size = UDim2.new(0, 170, 1, -20)
pListFrame.Position = UDim2.new(0, 340, 0, 10)
pListFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Instance.new("UICorner", pListFrame)

local pTitle = Instance.new("TextLabel", pListFrame)
pTitle.Size = UDim2.new(1, 0, 0, 30)
pTitle.Text = "ИГРОКИ (Killer Det.)"
pTitle.TextColor3 = Color3.new(1, 1, 1)
pTitle.Font = Enum.Font.GothamBold
pTitle.TextSize = 12
pTitle.BackgroundTransparency = 1

local pScroll = Instance.new("ScrollingFrame", pListFrame)
pScroll.Size = UDim2.new(1, -10, 1, -40)
pScroll.Position = UDim2.new(0, 5, 0, 35)
pScroll.BackgroundTransparency = 1
pScroll.BorderSizePixel = 0
local pLay = Instance.new("UIListLayout", pScroll)
pLay.Padding = UDim.new(0, 3)

-- Функция создания кнопок
local function addBtn(txt, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

--------------------------------------------------
-- МОДУЛЬ ПОЛЕТА И СЛАЙДЕР
--------------------------------------------------
local flySpd = 2.5
local flyOn, flyEv

local sliderFrame = Instance.new("Frame", scroll)
sliderFrame.Size = UDim2.new(1, -10, 0, 45)
sliderFrame.BackgroundTransparency = 1

local sLabel = Instance.new("TextLabel", sliderFrame)
sLabel.Size = UDim2.new(1, 0, 0, 15)
sLabel.Text = "FLY SPEED: " .. flySpd
sLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
sLabel.Font = Enum.Font.Gotham; sLabel.TextSize = 10; sLabel.BackgroundTransparency = 1

local sBack = Instance.new("Frame", sliderFrame)
sBack.Size = UDim2.new(1, 0, 0, 8)
sBack.Position = UDim2.new(0, 0, 0, 22)
sBack.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
Instance.new("UICorner", sBack)

local sFill = Instance.new("TextButton", sBack)
sFill.Size = UDim2.new(0.25, 0, 1, 0)
sFill.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
sFill.Text = ""
Instance.new("UICorner", sFill)

sFill.MouseButton1Down:Connect(function()
    local move = uis.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - sBack.AbsolutePosition.X) / sBack.AbsoluteSize.X, 0, 1)
            sFill.Size = UDim2.new(rel, 0, 1, 0)
            flySpd = math.round(rel * 15 * 10) / 10 -- Скорость до 15
            sLabel.Text = "FLY SPEED: " .. flySpd
        end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end
    end)
end)

addBtn("FLY: OFF", scroll, function(btn)
    flyOn = not flyOn
    btn.Text = flyOn and "FLY: ON" or "FLY: OFF"
    btn.TextColor3 = flyOn and Color3.fromRGB(0, 255, 127) or Color3.new(1, 1, 1)
    if flyOn then
        lp.Character.Humanoid.PlatformStand = true
        flyEv = rs.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(0,0,0)
            if uis:IsKeyDown("W") then dir = dir + cam.CFrame.LookVector end
            if uis:IsKeyDown("S") then dir = dir - cam.CFrame.LookVector end
            if uis:IsKeyDown("D") then dir = dir + cam.CFrame.RightVector end
            if uis:IsKeyDown("A") then dir = dir - cam.CFrame.RightVector end
            if uis:IsKeyDown("Space") then dir = dir + Vector3.new(0,1,0) end
            if uis:IsKeyDown("LeftControl") then dir = dir - Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then lp.Character.HumanoidRootPart.CFrame += (dir.Unit * flySpd) end
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end)
    else
        if flyEv then flyEv:Disconnect() end
        lp.Character.Humanoid.PlatformStand = false
    end
end)

--------------------------------------------------
-- МОЩНЫЕ ФУНКЦИИ
--------------------------------------------------

-- Kill Aura
local kAura = false
addBtn("KILL AURA: OFF", scroll, function(btn)
    kAura = not kAura
    btn.Text = kAura and "KILL AURA: ON" or "KILL AURA: OFF"
    btn.TextColor3 = kAura and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
    task.spawn(function()
        while kAura do
            for _, pl in pairs(p:GetPlayers()) do
                if pl ~= lp and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (lp.Character.HumanoidRootPart.Position - pl.Character.HumanoidRootPart.Position).Magnitude
                    if dist < 18 then
                        local tool = lp.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end
            task.wait(0.05)
        end
    end)
end)

-- Safe Mode
local safeMode = false
addBtn("SAFE MODE: OFF", scroll, function(btn)
    safeMode = not safeMode
    btn.Text = safeMode and "SAFE MODE: ON" or "SAFE MODE: OFF"
    task.spawn(function()
        while safeMode do
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                if lp.Character.Humanoid.Health < (lp.Character.Humanoid.MaxHealth * 0.35) then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    task.wait(0.1)
                end
            end
            task.wait(0.5)
        end
    end)
end)

-- Chat Logs
addBtn("ACTIVATE CHAT LOGS", scroll, function(btn)
    btn.Text = "LOGS ACTIVE (F9)"
    for _, pl in pairs(p:GetPlayers()) do
        pl.Chatted:Connect(function(msg) print("[" .. pl.Name .. "]: " .. msg) end)
    end
    p.PlayerAdded:Connect(function(pl)
        pl.Chatted:Connect(function(msg) print("[" .. pl.Name .. "]: " .. msg) end)
    end)
end)

-- ESP
addBtn("ESP: TOGGLE", scroll, function()
    _G.esp = not _G.esp
    task.spawn(function()
        while _G.esp do
            for _, pl in pairs(p:GetPlayers()) do
                if pl ~= lp and pl.Character then
                    local h = pl.Character:FindFirstChild("PishenakESP") or Instance.new("Highlight", pl.Character)
                    h.Name = "PishenakESP"
                    h.FillColor = pl.Character:FindFirstChildOfClass("Tool") and Color3.new(1,0,0) or Color3.new(0,1,0)
                    h.OutlineColor = Color3.new(1,1,1)
                end
            end
            task.wait(1)
        end
    end)
end)

addBtn("TP TO TRASH", scroll, function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("trash") and v:IsA("BasePart") then
            lp.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
            break
        end
    end
end)

--------------------------------------------------
-- СПИСОК ИГРОКОВ (Killer Detector)
--------------------------------------------------
local function updatePlayerList()
    for _, v in pairs(pScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, pl in pairs(p:GetPlayers()) do
        if pl ~= lp then
            local b = Instance.new("TextButton", pScroll)
            b.Size = UDim2.new(1, -5, 0, 28)
            b.Text = pl.DisplayName
            
            -- Детектор маньяка (если есть Tool)
            local isKiller = pl.Character and pl.Character:FindFirstChildOfClass("Tool")
            b.BackgroundColor3 = isKiller and Color3.fromRGB(120, 30, 30) or Color3.fromRGB(40, 40, 45)
            
            b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 10; Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    lp.Character.HumanoidRootPart.CFrame = pl.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end

addBtn("Update Player List", scroll, updatePlayerList)

-- Управление видимостью
uis.InputBegan:Connect(function(k, g)
    if not g and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

-- Авто-обновление списка каждые 10 секунд
task.spawn(function()
    while true do
        updatePlayerList()
        task.wait(10)
    end
end)

print("PISHENAK HUB v16 LOADED!")
