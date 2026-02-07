local player = game:GetService("Players").LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- Удаление старого GUI
if player.PlayerGui:FindFirstChild("PishenakFreeHub") then
    player.PlayerGui.PishenakFreeHub:Destroy()
end

local sg = Instance.new("ScreenGui", player.PlayerGui)
sg.Name = "PishenakFreeHub"
sg.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 220, 0, 350)
main.Position = UDim2.new(0.5, -110, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BackgroundTransparency = 0.2
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

-- Кнопка Свернуть
local isMinimized = false
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.Text = "_"
minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
minBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", minBtn)

local list = Instance.new("ScrollingFrame", main)
list.Size = UDim2.new(1, -10, 1, -50)
list.Position = UDim2.new(0, 5, 0, 45)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 2
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        list.Visible = false
        main.Size = UDim2.new(0, 220, 0, 40)
        minBtn.Text = "+"
    else
        main.Size = UDim2.new(0, 220, 0, 350)
        list.Visible = true
        minBtn.Text = "_"
    end
end)

local function addBtn(text, callback)
    local b = Instance.new("TextButton", list)
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() callback(b) end)
end

-- 1. УЛУЧШЕННЫЙ NO CD (Перезагрузка анимаций атак)
local noCdOn = false
addBtn("No CD: OFF", function(btn)
    noCdOn = not noCdOn
    btn.Text = noCdOn and "No CD: ON" or "No CD: OFF"
    btn.TextColor3 = noCdOn and Color3.new(0, 1, 0) or Color3.new(1, 1, 1)
    
    task.spawn(function()
        while noCdOn do
            pcall(function()
                -- Метод 1: Сброс локальных кулдаунов в атрибутах
                for _, v in pairs(player.Character:GetAttributes()) do
                    if v:find("Cooldown") or v:find("CD") then
                        player.Character:SetAttribute(v, 0)
                    end
                end
                -- Метод 2: Остановка анимаций стана (чтобы можно было сразу бить снова)
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    for _, anim in pairs(hum:GetPlayingAnimationTracks()) do
                        if anim.Name:lower():find("cooldown") or anim.Name:lower():find("attack") then
                            anim:Stop()
                        end
                    end
                end
            end)
            task.wait(0.05)
        end
    end)
end)

-- 2. INFINITE DASH (Q спам)
local infDash = false
addBtn("Inf Dash: OFF", function(btn)
    infDash = not infDash
    btn.Text = infDash and "Inf Dash: ON" or "Inf Dash: OFF"
    task.spawn(function()
        while infDash do
            pcall(function()
                player.Character:SetAttribute("DashCooldown", 0)
            end)
            task.wait(0.1)
        end
    end)
end)

-- 3. FPS BOOSTER
addBtn("FPS Booster", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("PostProcessEffect") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
        if v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        end
    end
    print("FPS Boost Activated")
end)

-- 4. RGB ESP
local espOn = false
addBtn("RGB ESP: OFF", function(btn)
    espOn = not espOn
    btn.Text = espOn and "RGB ESP: ON" or "RGB ESP: OFF"
    task.spawn(function()
        while espOn do
            local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local h = p.Character:FindFirstChild("FreeESP") or Instance.new("Highlight", p.Character)
                    h.Name = "FreeESP"
                    h.FillColor = color
                end
            end
            task.wait(0.1)
        end
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("FreeESP") then p.Character.FreeESP:Destroy() end
        end
    end)
end)

-- 5. Fly
local flying = false
addBtn("Fly: OFF", function(btn)
    flying = not flying
    btn.Text = flying and "Fly: ON" or "Fly: OFF"
    if flying then
        local bv = Instance.new("BodyVelocity", player.Character.HumanoidRootPart)
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        task.spawn(function()
            while flying do
                bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * 100
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

uis.InputBegan:Connect(function(k, g)
    if not g and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)
