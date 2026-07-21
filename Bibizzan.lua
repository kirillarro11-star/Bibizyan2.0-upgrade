-- Ryzen Mobile v3 / Delta
-- Создатель: bibizzzana
-- Меню 10 см, перетаскиваемое, с кнопкой открытия, Infinity Jump.
-- Функции: ESP (шкала здоровья), Noclip, Aimbot, Silent Aim, Infinity Jump.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Состояния
local state = {
    esp = true,
    noclip = true,
    aimbot = true,
    silent = true,
    infJump = true,
    menuOpen = true
}

local espDrawings = {}
local aimTarget = nil

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer.PlayerGui

-- Кнопка открытия/закрытия (всегда видима)
local toggleOpenBtn = Instance.new("TextButton")
toggleOpenBtn.Size = UDim2.new(0, 44, 0, 44)
toggleOpenBtn.Position = UDim2.new(1, -54, 0, 10)
toggleOpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
toggleOpenBtn.Text = "R"
toggleOpenBtn.TextColor3 = Color3.new(1,1,1)
toggleOpenBtn.TextScaled = true
toggleOpenBtn.Font = Enum.Font.GothamBold
toggleOpenBtn.BorderSizePixel = 0
toggleOpenBtn.Parent = gui
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = toggleOpenBtn

-- Основная панель (меню) размер ~10 см (350x450)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225) -- центр экрана
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
mainFrame.Visible = true
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Ryzen • bibizzzana"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 34, 1, 0)
toggleBtn.Position = UDim2.new(0.9, 0, 0, 0)
toggleBtn.BackgroundTransparency = 1
toggleBtn.Text = "−"
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.Parent = titleBar
toggleBtn.MouseButton1Click:Connect(function()
    state.menuOpen = not state.menuOpen
    mainFrame.Visible = state.menuOpen
    toggleBtn.Text = state.menuOpen and "−" or "+"
end)

-- Перетаскивание
local dragging = false
local dragStart, frameStart

local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(0, frameStart.X.Offset + delta.X, 0, frameStart.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = mainFrame.Position
    end
end)

titleBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        updateDrag(input)
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Кнопка открытия/закрытия (переключатель)
toggleOpenBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    state.menuOpen = mainFrame.Visible
    toggleBtn.Text = state.menuOpen and "−" or "+"
end)

-- ===== Секции =====
local function makeSection(frame, title, yPos, height)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(0.92, 0, 0, height)
    sec.Position = UDim2.new(0.04, 0, yPos, 0)
    sec.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    sec.BackgroundTransparency = 0.3
    sec.BorderSizePixel = 0
    sec.Parent = frame
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = sec

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.Position = UDim2.new(0, 0, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(180, 180, 255)
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = sec
    return sec
end

local function makeToggle(parent, text, yPos, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.92, 0, 0, 32)
    btn.Position = UDim2.new(0.04, 0, yPos, 0)
    btn.BackgroundColor3 = state[key] and Color3.fromRGB(40, 180, 70) or Color3.fromRGB(180, 40, 40)
    btn.Text = text .. (state[key] and " ON" or " OFF")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Parent = parent
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    btn.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        btn.BackgroundColor3 = state[key] and Color3.fromRGB(40, 180, 70) or Color3.fromRGB(180, 40, 40)
        btn.Text = text .. (state[key] and " ON" or " OFF")
    end)
end

-- Me секция (высота 150)
local meSec = makeSection(mainFrame, "ME", 0.10, 150)
makeToggle(meSec, "Noclip", 0.28, "noclip")
makeToggle(meSec, "Aimbot", 0.48, "aimbot")
makeToggle(meSec, "Silent Aim", 0.68, "silent")
makeToggle(meSec, "Infinity Jump", 0.88, "infJump")

-- Esp секция (высота 70)
local espSec = makeSection(mainFrame, "ESP", 0.45, 70)
makeToggle(espSec, "ESP", 0.30, "esp")

-- Misc секция (высота 60)
local miscSec = makeSection(mainFrame, "MISC", 0.63, 60)
local soon = Instance.new("TextLabel")
soon.Size = UDim2.new(1, 0, 0, 30)
soon.Position = UDim2.new(0, 0, 0.1, 0)
soon.BackgroundTransparency = 1
soon.Text = "SOON..."
soon.TextColor3 = Color3.fromRGB(200, 200, 200)
soon.TextScaled = true
soon.Font = Enum.Font.GothamBold
soon.Parent = miscSec

-- ===== Функции =====

-- ESP
local function updateESP()
    for _, d in pairs(espDrawings) do d:Remove() end
    espDrawings = {}
    if not state.esp then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum and root then
                local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local txt = Drawing.new("Text")
                    txt.Size = 18; txt.Center = true; txt.Outline = true; txt.OutlineColor = Color3.new(0,0,0)
                    txt.Font = 3; txt.Color = Color3.new(1,0.2,0.2)
                    txt.Text = "♥ " .. math.round(hum.Health) .. "/" .. hum.MaxHealth
                    txt.Position = Vector2.new(pos.X, pos.Y - 80)
                    txt.Visible = true
                    table.insert(espDrawings, txt)

                    local barBg = Drawing.new("Line")
                    barBg.From = Vector2.new(pos.X - 30, pos.Y - 60)
                    barBg.To = Vector2.new(pos.X + 30, pos.Y - 60)
                    barBg.Thickness = 6; barBg.Color = Color3.new(0.2,0.2,0.2)
                    barBg.Visible = true
                    table.insert(espDrawings, barBg)

                    local hp = hum.Health / hum.MaxHealth
                    local barFill = Drawing.new("Line")
                    barFill.From = Vector2.new(pos.X - 30, pos.Y - 60)
                    barFill.To = Vector2.new(pos.X - 30 + 60 * hp, pos.Y - 60)
                    barFill.Thickness = 6; barFill.Color = Color3.new(1 - hp, hp, 0)
                    barFill.Visible = true
                    table.insert(espDrawings, barFill)

                    local name = Drawing.new("Text")
                    name.Size = 14; name.Center = true; name.Outline = true; name.OutlineColor = Color3.new(0,0,0)
                    name.Font = 2; name.Color = Color3.new(1,1,1)
                    name.Text = plr.Name
                    name.Position = Vector2.new(pos.X, pos.Y - 100)
                    name.Visible = true
                    table.insert(espDrawings, name)
                end
            end
        end
    end
end
RunService.Heartbeat:Connect(updateESP)

-- Noclip
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state.noclip
        end
    end
end)

-- Infinity Jump (через JumpRequest)
UserInputService.JumpRequest:Connect(function()
    if state.infJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then
                hum.Jump = true
            end
        end
    end
end)

-- Aimbot + Silent
local function getClosest()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local tr = plr.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local dist = (tr.Position - root.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist; best = plr
                end
            end
        end
    end
    return best
end

local function doAimbot()
    if not state.aimbot then return end
    local target = getClosest()
    if target and target.Character then
        local pos = target.Character.HumanoidRootPart.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
    end
end

RunService.Heartbeat:Connect(function()
    if state.aimbot and not state.silent then
        doAimbot()
    else
        aimTarget = state.silent and getClosest() or nil
    end
end)

UserInputService.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.UserInputType == Enum.UserInputType.Touch and state.silent and aimTarget then
        local old = Camera.CFrame
        local pos = aimTarget.Character.HumanoidRootPart.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, pos)
        task.wait(0.01)
        Camera.CFrame = old
    end
end)

print("Ryzen Mobile loaded. Создатель: bibizzzana")
