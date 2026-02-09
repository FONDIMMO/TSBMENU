--[[
    PISHENAK HUB v16 (TSB EDITION)
    - Настройка скорости полета (Slider)
    - Kill Aura (Для фарма и комбо)
    - Auto-Block (Safe Mode для TSB)
    - Dash Mastery (Бесконечные дэши/энергия)
    - Player List (TP к противникам)
    КЛАВИША: [L] Скрыть меню | [E] Быстрый Полет
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

local sg = Instance.new("ScreenGui", coreGui)
sg.Name = "PishenakModernHub"
sg.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 520, 0, 420)
main.Position = UDim2.new(0.5, -260, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)
local neon = Instance.new("UIStroke", main)
neon.Color = Color3.fromRGB(255, 80, 0) -- Оранжевый стиль TSB
neon.Thickness = 2

-- САЙДБАР
local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 120, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", side)

local label = Instance.new("TextLabel", side)
label.Size = UDim2.new(1, 0, 0, 50)
label.Text = "TSB HUB"
label.TextColor3 = Color3.fromRGB(255, 80, 0)
label.Font = Enum.Font.GothamBold
label.TextSize = 18
label.BackgroundTransparency = 1

-- КОНТЕНТ
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0, 200, 1, -20)
scroll.Position = UDim2.new(0, 130, 0, 10)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
local lay = Instance.new("UIListLayout", scroll)
lay.Padding = UDim.new(0, 6)

-- ПАНЕЛЬ ИГРОКОВ
local pListFrame = Instance.new("Frame", main)
pListFrame.Size = UDim2.new(0, 170, 1, -20)
pListFrame.Position = UDim2.new(0, 340, 0, 10)
pListFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Instance.new("UICorner", pListFrame)

local pScroll = Instance.new("ScrollingFrame", pListFrame)
pScroll.Size = UDim2.new(1, -10, 1, -10)
pScroll.Position = UDim2.new(0, 5, 0, 5)
pScroll.BackgroundTransparency = 1
pScroll.BorderSizePixel = 0
local pLay = Instance.new("UIListLayout", pScroll)
pLay.Padding = UDim.new(0, 3)

local function addBtn(txt, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

--------------------------------------------------
-- TSB FLY ENGINE & SLIDER
--------------------------------------------------
local flySpd = 50 -- В TSB лучше использовать бОльшие значения для BodyVelocity
local flyOn, bv, bg

local sliderFrame = Instance.new("Frame", scroll)
sliderFrame.Size = UDim2.new(1, -10, 0, 45)
sliderFrame.BackgroundTransparency = 1

local sLabel = Instance.new("TextLabel", sliderFrame)
sLabel.Size = UDim2.new(1, 0, 0, 15)
sLabel.Text = "FLY SPEED: " .. flySpd
sLabel.TextColor3 = Color3.fromRGB(255, 80, 0)
sLabel.Font = Enum.Font.Gotham; sLabel.TextSize = 10; sLabel.BackgroundTransparency = 1

local sBack = Instance.new("Frame", sliderFrame)
sBack.Size = UDim2.new(1, 0, 0, 8)
sBack.Position = UDim2.new(0, 0, 0, 22)
sBack.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
Instance.new("UICorner", sBack)

local sFill = Instance.new("TextButton", sBack)
sFill.Size = UDim2.new(0.2, 0, 1, 0)
sFill.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
sFill.Text = ""
Instance.new("UICorner", sFill)

sFill.MouseButton1Down:Connect(function()
    local move = uis.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - sBack.AbsolutePosition.X) / sBack.AbsoluteSize.X, 0, 1)
            sFill.Size = UDim2.new(rel, 0, 1, 0)
            flySpd = math.floor(rel * 300) -- Скорость до 300 для TSB
            sLabel.Text = "FLY SPEED: " .. flySpd
        end
    end)
    uis.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end
    end)
end)

local function toggleFly()
    flyOn = not flyOn
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    if flyOn then
        bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(1e8, 1e8, 1e8); bv.Velocity = Vector3.zero
        bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8); bg.P = 9e4
        task.spawn(function()
            while flyOn do
                rs.RenderStepped:Wait()
                local cam = workspace.CurrentCamera.CFrame
                local dir = Vector3.zero
                if uis:IsKeyDown("W") then dir = dir + cam.LookVector end
                if uis:IsKeyDown("S") then dir = dir - cam.LookVector end
                if uis:IsKeyDown("D") then dir = dir + cam.RightVector end
                if uis:IsKeyDown("A") then dir = dir - cam.RightVector end
                if uis:IsKeyDown("Space") then dir = dir + Vector3.new(0,1,0) end
                if uis:IsKeyDown("LeftShift") then dir = dir - Vector3.new(0,1,0) end
                bv.Velocity = dir * flySpd
                bg.CFrame = cam
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
    end
end

addBtn("TOGGLE FLY (E)", scroll, toggleFly)

--------------------------------------------------
-- TSB COMBAT FUNCTIONS
--------------------------------------------------

-- Kill Aura (Авто-атака)
local kAura = false
addBtn("KILL AURA: OFF", scroll, function(btn)
    kAura = not kAura
    btn.Text = kAura and "KILL AURA: ON" or "KILL AURA: OFF"
    btn.TextColor3 = kAura and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
    task.spawn(function()
        while kAura do
            pcall(function()
                for _, pl in pairs(p:GetPlayers()) do
                    if pl ~= lp and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (lp.Character.HumanoidRootPart.Position - pl.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 15 then
                            -- Имитация нажатия для TSB атак
                            local tool = lp.Character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChild("Combat")
                            if tool then tool:Activate() end
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end)

-- Auto-Block (F)
local autoBlock = false
addBtn("AUTO BLOCK: OFF", scroll, function(btn)
    autoBlock = not autoBlock
    btn.Text = autoBlock and "AUTO BLOCK: ON" or "AUTO BLOCK: OFF"
    task.spawn(function()
        while autoBlock do
            pcall(function()
                if lp.Character.Humanoid.Health < (lp.Character.Humanoid.MaxHealth * 0.4) then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                end
            end)
            task.wait(0.5)
        end
    end)
end)

-- Infinity Dash / Energy
addBtn("INF ENERGY/DASH", scroll, function(btn)
    btn.Text = "ENERGY: ACTIVE"
    rs.Heartbeat:Connect(function()
        pcall(function()
            lp.Character.Energy.Value = 100
        end)
    end)
end)

addBtn("ESP: PLAYERS", scroll, function()
    for _, v in pairs(p:GetPlayers()) do
        if v ~= lp and v.Character then
            local h = Instance.new("Highlight", v.Character)
            h.FillColor = Color3.fromRGB(255, 80, 0)
        end
    end
end)

--------------------------------------------------
-- PLAYER LIST (TP)
--------------------------------------------------
local function updatePlayerList()
    for _, v in pairs(pScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, pl in pairs(p:GetPlayers()) do
        if pl ~= lp then
            local b = Instance.new("TextButton", pScroll)
            b.Size = UDim2.new(1, -5, 0, 30)
            b.Text = pl.DisplayName
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; b.TextSize = 10; Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function()
                if pl.Character then lp.Character.HumanoidRootPart.CFrame = pl.Character.HumanoidRootPart.CFrame end
            end)
        end
    end
end

addBtn("UPDATE PLAYERS", scroll, updatePlayerList)

-- КЛАВИШИ
uis.InputBegan:Connect(function(k, g)
    if not g and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
    if not g and k.KeyCode == Enum.KeyCode.E then toggleFly() end
end)

updatePlayerList()
print("TSB HUB v16 LOADED")
