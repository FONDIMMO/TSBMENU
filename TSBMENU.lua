--[[
    VOID HUB v19 // LITE VERSION
    Если не запускается: проверь консоль F9
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local coreGui = game:GetService("CoreGui")

-- Прямая проверка на запуск
print("VOID LITE: Инициализация...")

-- Очистка старого меню
if coreGui:FindFirstChild("VoidTSB_Xeno") then
    coreGui.VoidTSB_Xeno:Destroy()
end

local sg = Instance.new("ScreenGui")
sg.Name = "VoidTSB_Xeno"
sg.Parent = coreGui
sg.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 500, 0, 400)
main.Position = UDim2.new(0.5, -250, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.Active = true
main.Draggable = true -- Теперь точно можно двигать

local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ФУНКЦИЯ КНОПКИ
local function addBtn(name, callback)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0, 480, 0, 40)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    
    local enabled = false
    b.MouseButton1Click:Connect(function()
        enabled = not enabled
        b.BackgroundColor3 = enabled and Color3.fromRGB(138, 43, 226) or Color3.fromRGB(30, 30, 40)
        callback(enabled)
    end)
end

-- КНОПКИ
addBtn("KILL AURA", function(t)
    _G.kAura = t
    while _G.kAura do
        pcall(function()
            for _, v in pairs(p:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    if (lp.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude < 15 then
                        local tool = lp.Character:FindFirstChildOfClass("Tool") or lp.Backpack:FindFirstChild("Combat")
                        if tool then tool:Activate() end
                    end
                end
            end
        end)
        task.wait(0.1)
    end
end)

addBtn("ULTIMATE TRACKER", function(t)
    _G.UltTrack = t
    rs.RenderStepped:Connect(function()
        if _G.UltTrack then
            for _, v in pairs(p:GetPlayers()) do
                if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
                    if not v.Character.Head:FindFirstChild("UltM") then
                        local m = Instance.new("BillboardGui", v.Character.Head)
                        m.Name = "UltM"
                        m.Size = UDim2.new(0, 50, 0, 10)
                        m.AlwaysOnTop = true
                        local f = Instance.new("Frame", m)
                        f.Size = UDim2.new(1, 0, 1, 0)
                        f.BackgroundColor3 = Color3.new(1, 0, 0)
                    end
                end
            end
        end
    end)
end)

addBtn("ESP VISION", function(t)
    for _, v in pairs(p:GetPlayers()) do
        if v ~= lp and v.Character then
            if t then
                local h = Instance.new("Highlight", v.Character)
                h.Name = "VoidH"
                h.FillColor = Color3.fromRGB(138, 43, 226)
            else
                if v.Character:FindFirstChild("VoidH") then v.Character.VoidH:Destroy() end
            end
        end
    end
end)

-- СКРЫТИЕ НА L
uis.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

print("VOID LITE УСПЕШНО ЗАПУЩЕН!")
