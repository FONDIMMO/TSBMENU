--[[
    PISHENAK HUB v14 (PLAYER LIST EDITION)
    Keybind: L to Toggle Visibility
]]

for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "PishenakModernHub" then v:Destroy() end
end

local p = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")

local sg = Instance.new("ScreenGui", coreGui)
sg.Name = "PishenakModernHub"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true

-- ГЛАВНОЕ ОКНО (Увеличил ширину для списка игроков)
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 520, 0, 350)
main.Position = UDim2.new(0.5, -260, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)
Instance.new("UIStroke", main).Color = Color3.fromRGB(0, 255, 127)

-- САЙДБАР
local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 120, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Instance.new("UICorner", side)

local label = Instance.new("TextLabel", side)
label.Size = UDim2.new(1, 0, 0, 50)
label.Text = "PISHENAK"
label.TextColor3 = Color3.fromRGB(0, 255, 127)
label.Font = Enum.Font.GothamBold
label.BackgroundTransparency = 1

-- КОНТЕНТ (ФУНКЦИИ)
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0, 190, 1, -20)
scroll.Position = UDim2.new(0, 130, 0, 10)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
local lay = Instance.new("UIListLayout", scroll)
lay.Padding = UDim.new(0, 5)

-- ПАНЕЛЬ ИГРОКОВ (Справа)
local pListFrame = Instance.new("Frame", main)
pListFrame.Size = UDim2.new(0, 180, 1, -20)
pListFrame.Position = UDim2.new(0, 330, 0, 10)
pListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", pListFrame)

local pTitle = Instance.new("TextLabel", pListFrame)
pTitle.Size = UDim2.new(1, 0, 0, 30)
pTitle.Text = "ВЫБОР ИГРОКА"
pTitle.TextColor3 = Color3.new(1, 1, 1)
pTitle.Font = Enum.Font.GothamBold
pTitle.TextSize = 12
pTitle.BackgroundTransparency = 1

local pScroll = Instance.new("ScrollingFrame", pListFrame)
pScroll.Size = UDim2.new(1, -10, 1, -40)
pScroll.Position = UDim2.new(0, 5, 0, 35)
pScroll.BackgroundTransparency = 1
pScroll.BorderSizePixel = 0
pScroll.ScrollBarThickness = 2
local pLay = Instance.new("UIListLayout", pScroll)
pLay.Padding = UDim.new(0, 3)

-- Функция создания кнопок функций
local function addBtn(txt, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 30)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 12
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- ОБНОВЛЕНИЕ СПИСКА ИГРОКОВ
local function updatePlayerList()
    for _, v in pairs(pScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    
    for _, pl in pairs(game.Players:GetPlayers()) do
        if pl ~= p then
            local b = Instance.new("TextButton", pScroll)
            b.Size = UDim2.new(1, -5, 0, 25)
            b.Text = pl.DisplayName or pl.Name
            b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            b.TextColor3 = Color3.new(0.9, 0.9, 0.9)
            b.Font = Enum.Font.Gotham
            b.TextSize = 11
            Instance.new("UICorner", b)
            
            b.MouseButton1Click:Connect(function()
                if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    p.Character.HumanoidRootPart.CFrame = pl.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end

--------------------------------------------------
-- КНОПКИ УПРАВЛЕНИЯ
--------------------------------------------------

addBtn("Обновить игроков", scroll, updatePlayerList)

-- Полет (CFrame)
local flyOn, flySpd = false, 2.5
local flyEv
addBtn("FLY: OFF", scroll, function(btn)
    flyOn = not flyOn
    btn.Text = flyOn and "FLY: ON" or "FLY: OFF"
    btn.TextColor3 = flyOn and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
    if flyOn then
        p.Character.Humanoid.PlatformStand = true
        flyEv = rs.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(0,0,0)
            if uis:IsKeyDown("W") then dir = dir + cam.CFrame.LookVector end
            if uis:IsKeyDown("S") then dir = dir - cam.CFrame.LookVector end
            if uis:IsKeyDown("D") then dir = dir + cam.CFrame.RightVector end
            if uis:IsKeyDown("A") then dir = dir - cam.CFrame.RightVector end
            if uis:IsKeyDown("Space") then dir = dir + Vector3.new(0,1,0) end
            if uis:IsKeyDown("LeftControl") then dir = dir - Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then p.Character.HumanoidRootPart.CFrame += (dir.Unit * flySpd) end
            p.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end)
    else
        if flyEv then flyEv:Disconnect() end
        p.Character.Humanoid.PlatformStand = false
    end
end)

addBtn("No CD: OFF", scroll, function(btn)
    _G.ncd = not _G.ncd
    btn.Text = _G.ncd and "No CD: ON" or "No CD: OFF"
    task.spawn(function()
        while _G.ncd do
            pcall(function() p.Character:SetAttribute("Cooldown", 0) end)
            task.wait(0.1)
        end
    end)
end)

addBtn("TP TO TRASH", scroll, function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("trash") and v:IsA("BasePart") then
            p.Character.HumanoidRootPart.CFrame = v.CFrame + Vector3.new(0, 3, 0)
            break
        end
    end
end)

addBtn("ESP: OFF", scroll, function(btn)
    _G.esp = not _G.esp
    btn.Text = _G.esp and "ESP: ON" or "ESP: OFF"
    task.spawn(function()
        while _G.esp do
            for _, pl in pairs(game.Players:GetPlayers()) do
                if pl ~= p and pl.Character then
                    local h = pl.Character:FindFirstChild("Hi") or Instance.new("Highlight", pl.Character)
                    h.Name = "Hi"
                    h.FillColor = Color3.fromHSV(tick()%5/5, 1, 1)
                end
            end
            task.wait(0.5)
        end
    end)
end)

-- Свернуть список игроков (кнопка в углу секции)
local listVisible = true
local hideList = Instance.new("TextButton", pListFrame)
hideList.Size = UDim2.new(0, 20, 0, 20)
hideList.Position = UDim2.new(1, -25, 0, 5)
hideList.Text = ">"
hideList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
hideList.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", hideList)

hideList.MouseButton1Click:Connect(function()
    listVisible = not listVisible
    pScroll.Visible = listVisible
    pTitle.Visible = listVisible
    if not listVisible then
        pListFrame.Size = UDim2.new(0, 30, 1, -20)
        hideList.Text = "<"
        hideList.Position = UDim2.new(0, 5, 0, 5)
    else
        pListFrame.Size = UDim2.new(0, 180, 1, -20)
        hideList.Text = ">"
        hideList.Position = UDim2.new(1, -25, 0, 5)
    end
end)

uis.InputBegan:Connect(function(k, g)
    if not g and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

updatePlayerList() -- Сразу при запуске
