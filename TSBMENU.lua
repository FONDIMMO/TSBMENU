--[[
    PISHENAK HUB v17 // THE STRONGEST BATTLEGROUNDS
    Особенности:
    - ANTI-TP FLY: Полет через физику (не кикает, не телепортирует)
    - FLY SPEED SLIDER: Настройка скорости прямо в меню
    - KILL AURA: Авто-атака в радиусе 15 метров
    - AUTO-BLOCK: Защита при низком здоровье
    - INF DASH/ENERGY: Бесконечные рывки
    УПРАВЛЕНИЕ: [L] - Меню, [E] - Полет
]]

for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "PishenakTSB_Final" then v:Destroy() end
end

local p = game:GetService("Players")
local lp = p.LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local vim = game:GetService("VirtualInputManager")

local sg = Instance.new("ScreenGui", coreGui)
sg.Name = "PishenakTSB_Final"
sg.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 520, 0, 420)
main.Position = UDim2.new(0.5, -260, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)
local neon = Instance.new("UIStroke", main)
neon.Color = Color3.fromRGB(255, 85, 0) -- Фирменный оранжевый TSB
neon.Thickness = 2

-- САЙДБАР
local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 120, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Instance.new("UICorner", side)

local label = Instance.new("TextLabel", side)
label.Size = UDim2.new(1, 0, 0, 50)
label.Text = "TSB HUB v17"
label.TextColor3 = Color3.fromRGB(255, 85, 0)
label.Font = Enum.Font.GothamBold; label.TextSize = 18; label.BackgroundTransparency = 1

-- КОНТЕНТ
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0, 200, 1, -20)
scroll.Position = UDim2.new(0, 130, 0, 10)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
local lay = Instance.new("UIListLayout", scroll); lay.Padding = UDim.new(0, 6)

-- СПИСОК ИГРОКОВ
local pList = Instance.new("Frame", main)
pList.Size = UDim2.new(0, 170, 1, -20)
pList.Position = UDim2.new(0, 340, 0, 10)
pList.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
Instance.new("UICorner", pList)

local pScroll = Instance.new("ScrollingFrame", pList)
pScroll.Size = UDim2.new(1, -10, 1, -10)
pScroll.Position = UDim2.new(0, 5, 0, 5)
pScroll.BackgroundTransparency = 1; pScroll.BorderSizePixel = 0
Instance.new("UIListLayout", pScroll).Padding = UDim.new(0, 3)

local function addBtn(txt, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamSemibold; b.TextSize = 11
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
    return b
end

--------------------------------------------------
-- ANTI-TP FLY ENGINE
--------------------------------------------------
local flySpeed = 70
local flying = false
local bv, bg

local sliderFrame = Instance.new("Frame", scroll)
sliderFrame.Size = UDim2.new(1, -10, 0, 45); sliderFrame.BackgroundTransparency = 1

local sLabel = Instance.new("TextLabel", sliderFrame)
sLabel.Size = UDim2.new(1, 0, 0, 15); sLabel.Text = "FLY SPEED: " .. flySpeed
sLabel.TextColor3 = Color3.fromRGB(255, 85, 0); sLabel.Font = Enum.Font.Gotham; sLabel.TextSize = 10; sLabel.BackgroundTransparency = 1

local sBack = Instance.new("Frame", sliderFrame)
sBack.Size = UDim2.new(1, 0, 0, 8); sBack.Position = UDim2.new(0, 0, 0, 22); sBack.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1); Instance.new("UICorner", sBack)

local sFill = Instance.new("TextButton", sBack)
sFill.Size = UDim2.new(0.3, 0, 1, 0); sFill.BackgroundColor3 = Color3.fromRGB(255, 85, 0); sFill.Text = ""; Instance.new("UICorner", sFill)

sFill.MouseButton1Down:Connect(function()
    local move = uis.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - sBack.AbsolutePosition.X) / sBack.AbsoluteSize.X, 0, 1)
            sFill.Size = UDim2.new(rel, 0, 1, 0)
            flySpeed = math.floor(rel * 300)
            sLabel.Text = "FLY SPEED: " .. flySpeed
        end
    end)
    uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
end)

local function toggleFly()
    flying = not flying
    local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if flying then
        bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(1e8, 1e8, 1e8); bv.Velocity = Vector3.zero
        bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8); bg.P = 10000
        task.spawn(function()
            while flying do
                rs.Heartbeat:Wait()
                local cam = workspace.CurrentCamera.CFrame
                local moveDir = Vector3.new(0,0,0)
                if uis:IsKeyDown("W") then moveDir = moveDir + cam.LookVector end
                if uis:IsKeyDown("S") then moveDir = moveDir - cam.LookVector end
                if uis:IsKeyDown("D") then moveDir = moveDir + cam.RightVector end
                if uis:IsKeyDown("A") then moveDir = moveDir - cam.RightVector end
                if uis:IsKeyDown("Space") then moveDir = moveDir + Vector3.new(0,1,0) end
                if uis:IsKeyDown("LeftShift") then moveDir = moveDir - Vector3.new(0,1,0) end
                bv.Velocity = moveDir * flySpeed
                bg.CFrame = cam
            end
            if bv then bv:Destroy() end; if bg then bg:Destroy() end
        end)
    end
end

addBtn("FLY TOGGLE (E)", scroll, toggleFly)

--------------------------------------------------
-- TSB COMBAT MODS
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
                    if (lp.Character.HumanoidRootPart.Position - pl.Character.HumanoidRootPart.Position).Magnitude < 15 then
                        local tool = lp.Character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChild("Combat")
                        if tool then tool:Activate() end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end)

-- Auto Block
local autoB = false
addBtn("AUTO BLOCK: OFF", scroll, function(btn)
    autoB = not autoB
    btn.Text = autoB and "AUTO BLOCK: ON" or "AUTO BLOCK: OFF"
    task.spawn(function()
        while autoB do
            if lp.Character.Humanoid.Health < (lp.Character.Humanoid.MaxHealth * 0.4) then
                vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            end
            task.wait(0.5)
        end
    end)
end)

-- Inf Energy
addBtn("INF ENERGY/DASH", scroll, function(btn)
    btn.Text = "ENERGY: INF"
    rs.Heartbeat:Connect(function()
        pcall(function() lp.Character.Energy.Value = 100 end)
    end)
end)

-- ESP
addBtn("ESP: TOGGLE", scroll, function()
    for _, v in pairs(p:GetPlayers()) do
        if v ~= lp and v.Character then
            local h = v.Character:FindFirstChild("Highlight") or Instance.new("Highlight", v.Character)
            h.FillColor = Color3.fromRGB(255, 85, 0)
        end
    end
end)

--------------------------------------------------
-- PLAYER LIST & TP
--------------------------------------------------
local function updatePlayers()
    for _, v in pairs(pScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, pl in pairs(p:GetPlayers()) do
        if pl ~= lp then
            local b = addBtn(pl.DisplayName, pScroll, function()
                if pl.Character then lp.Character.HumanoidRootPart.CFrame = pl.Character.HumanoidRootPart.CFrame end
            end)
            b.Size = UDim2.new(1, -5, 0, 25); b.TextSize = 10
        end
    end
end

addBtn("REFRESH PLAYERS", scroll, updatePlayers)

-- Управление
uis.InputBegan:Connect(function(k, g)
    if not g and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
    if not g and k.KeyCode == Enum.KeyCode.E then toggleFly() end
end)

updatePlayers()
print("TSB HUB v17 LOADED - NO TP MODE")
