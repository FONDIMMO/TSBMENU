-- Принудительная очистка старых версий
for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v.Name == "PishenakModernHub" then v:Destroy() end
end

local p = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")

-- Создаем GUI в CoreGui (это стабильнее для Xeno)
local sg = Instance.new("ScreenGui")
sg.Name = "PishenakModernHub"
sg.Parent = coreGui
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true -- Чтобы не мешала полоска сверху

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 450, 0, 320)
main.Position = UDim2.new(0.5, -225, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Добавим обводку, чтобы точно было видно
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0, 255, 127)
stroke.Thickness = 2

-- САЙДБАР
local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 120, 1, 0)
side.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", side)

local label = Instance.new("TextLabel", side)
label.Size = UDim2.new(1, 0, 0, 50)
label.Text = "PISHENAK HUB"
label.TextColor3 = Color3.fromRGB(0, 255, 127)
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.BackgroundTransparency = 1

-- КОНТЕНТ (СКРОЛЛ)
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -130, 1, -20)
scroll.Position = UDim2.new(0, 125, 0, 10)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
local lay = Instance.new("UIListLayout", scroll)
lay.Padding = UDim.new(0, 7)

-- ФУНКЦИЯ ДЛЯ КНОПОК
local function addBtn(txt, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    Instance.new("UICorner", b)
    
    b.MouseButton1Click:Connect(function()
        pcall(callback, b)
    end)
    return b
end

--------------------------------------------------
-- ФУНКЦИОНАЛ
--------------------------------------------------

-- 1. ПОЛЕТ (WASD + Space/Ctrl)
local flyOn = false
local flySpd = 60
local bv, bg, flyEv

addBtn("FLY: OFF", function(btn)
    flyOn = not flyOn
    btn.Text = flyOn and "FLY: ON" or "FLY: OFF"
    btn.TextColor3 = flyOn and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
    
    local char = p.Character or p.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    if flyOn then
        bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bg.P = 9e4
        
        flyEv = rs.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            local dir = Vector3.new(0,0,0)
            if uis:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            
            bv.Velocity = dir.Unit * (dir.Magnitude > 0 and flySpd or 0)
            bg.CFrame = cam.CFrame
        end)
    else
        if flyEv then flyEv:Disconnect() end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end)

-- 2. NO CD
local ncd = false
addBtn("NO CD: OFF", function(btn)
    ncd = not ncd
    btn.Text = ncd and "NO CD: ON" or "NO CD: OFF"
    btn.TextColor3 = ncd and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
    task.spawn(function()
        while ncd do
            pcall(function() p.Character:SetAttribute("Cooldown", 0) end)
            task.wait(0.1)
        end
    end)
end)

-- 3. ТЕЛЕПОРТЫ
addBtn("TP TO TRASH", function()
    local r = p.Character.HumanoidRootPart
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:lower():find("trash") and v:IsA("BasePart") then
            r.CFrame = v.CFrame + Vector3.new(0, 3, 0)
            break
        end
    end
end)

addBtn("TP TO PLAYER", function()
    local players = game:GetService("Players"):GetPlayers()
    local target = players[math.random(1, #players)]
    if target ~= p and target.Character then
        p.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
    end
end)

-- 4. ESP
local esp = false
addBtn("ESP: OFF", function(btn)
    esp = not esp
    btn.Text = esp and "ESP: ON" or "ESP: OFF"
    btn.TextColor3 = esp and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
    task.spawn(function()
        while esp do
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

-- СКРЫТИЕ НА L
uis.InputBegan:Connect(function(k, g)
    if not g and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

warn("PISHENAK HUB LOADED!")
