--[[
    VOID HUB v20 // STABLE FOR XENO
    GitHub Repository Version
]]

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Пытаемся поместить GUI в безопасное место
local Parent = nil
pcall(function()
    Parent = game:GetService("CoreGui")
end)
if not Parent then Parent = lp:WaitForChild("PlayerGui") end

-- Очистка старого меню
if Parent:FindFirstChild("VoidXeno_v19") then
    Parent.VoidXeno_v19:Destroy()
end

local sg = Instance.new("ScreenGui", Parent)
sg.Name = "VoidXeno_v19"
sg.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 400, 0, 450)
main.Position = UDim2.new(0.5, -200, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.Active = true
main.Draggable = true -- В Xeno должно работать

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "VOID HUB v20 // TSB"
title.TextColor3 = Color3.fromRGB(138, 43, 226)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local list = Instance.new("ScrollingFrame", main)
list.Size = UDim2.new(1, -20, 1, -60)
list.Position = UDim2.new(0, 10, 0, 50)
list.BackgroundTransparency = 1
list.CanvasSize = UDim2.new(0, 0, 1.5, 0)
local layout = Instance.new("UIListLayout", list); layout.Padding = UDim.new(0, 5)

-- ФУНКЦИЯ КНОПКИ
local function createToggle(name, callback)
    local b = Instance.new("TextButton", list)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.Text = name
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.Gotham
    
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.BackgroundColor3 = active and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(25, 25, 30)
        callback(active)
    end)
end

--------------------------------------------------
-- ФУНКЦИОНАЛ
--------------------------------------------------

-- 1. Ultimate Tracker
createToggle("Ultimate Tracker", function(state)
    _G.ShowUlt = state
    RunService.RenderStepped:Connect(function()
        if _G.ShowUlt then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
                    local head = v.Character.Head
                    if not head:FindFirstChild("UltView") then
                        local b = Instance.new("BillboardGui", head)
                        b.Name = "UltView"
                        b.Size = UDim2.new(0, 80, 0, 15)
                        b.AlwaysOnTop = true
                        b.ExtentsOffset = Vector3.new(0, 3, 0)
                        local f = Instance.new("Frame", b)
                        f.Size = UDim2.new(1, 0, 1, 0)
                        f.BackgroundColor3 = Color3.new(1, 0, 0)
                        Instance.new("UICorner", f)
                    end
                end
            end
        else
            -- Удаление при выключении
            for _, v in pairs(Players:GetPlayers()) do
                if v.Character and v.Character:FindFirstChild("Head") and v.Character.Head:FindFirstChild("UltView") then
                    v.Character.Head.UltView:Destroy()
                end
            end
        end
    end)
end)

-- 2. Cooldown Viewer (Анимационный детектор)
createToggle("Cooldown Viewer", function(state)
    _G.ShowCD = state
    RunService.RenderStepped:Connect(function()
        if _G.ShowCD then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("Humanoid") then
                    local anims = v.Character.Humanoid:GetPlayingAnimationTracks()
                    if #anims > 0 then
                        -- Если видим анимацию атаки — вешаем метку
                        local head = v.Character.Head
                        if not head:FindFirstChild("CDView") then
                            local b = Instance.new("BillboardGui", head)
                            b.Name = "CDView"; b.Size = UDim2.new(0, 100, 0, 20); b.AlwaysOnTop = true
                            b.ExtentsOffset = Vector3.new(0, 4.5, 0)
                            local t = Instance.new("TextLabel", b)
                            t.Size = UDim2.new(1,0,1,0); t.Text = "MOVES USED"; t.TextColor3 = Color3.new(1,1,0); t.BackgroundTransparency = 1
                        end
                    end
                end
            end
        end
    end)
end)

-- 3. ESP
createToggle("Void ESP", function(state)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character then
            if state then
                local h = Instance.new("Highlight", v.Character)
                h.Name = "VHighlight"; h.FillColor = Color3.fromRGB(138, 43, 226)
            else
                if v.Character:FindFirstChild("VHighlight") then v.Character.VHighlight:Destroy() end
            end
        end
    end
end)

-- Скрытие на L
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

print("VOID HUB v20 LOADED FROM GITHUB SOURCE")
