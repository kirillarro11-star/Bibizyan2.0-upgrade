-- Ryzen Mobile Script / Delta
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local state = { esp = true, noclip = true, aimbot = true, silent = true }
local aimTarget = nil
local espDrawings = {}

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer.PlayerGui

local function makeSection(title, yPos, height)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 160, 0, height)
    frame.Position = UDim2.new(0.02, 0, yPos, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 30)
    titleLbl.Position = UDim2.new(0, 0, 0, 2)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(180, 180, 255)
    titleLbl.TextScaled = true
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.Parent = frame
    return frame
end

local function makeToggle(parent, text, yPos, key)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, yPos, 0)
    btn.BackgroundColor3 = state[key] and Color3.fromRGB(40, 180, 70) or Color3.fromRGB(180, 40, 40)
    btn.Text = text .. (state[key] and " ON" or " OFF")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(function()
        state[key] = not state[key]
        btn.BackgroundColor3 = state[key] and Color3.fromRGB(40, 180, 70) or Color3.fromRGB(180, 40, 40)
        btn.Text = text .. (state[key] and " ON" or " OFF")
    end)
end

-- Me Section
local meFrame = makeSection("ME", 0.03, 140)
makeToggle(meFrame, "Noclip", 0.30, "noclip")
makeToggle(meFrame, "Aimbot", 0.55, "aimbot")
makeToggle(meFrame, "Silent Aim", 0.80, "silent")

-- Esp Section
local espFrame = makeSection("ESP", 0.20, 70)
makeToggle(espFrame, "ESP", 0.30, "esp")

-- Misc Section
local miscFrame = makeSection("MISC", 0.34, 60)
local soon = Instance.new("TextLabel")
soon.Size = UDim2.new(0.9, 0, 0, 30)
soon.Position = UDim2.new(0.05, 0, 0.25, 0)
soon.BackgroundTransparency = 1
soon.Text = "SOON..."
soon.TextColor3 = Color3.fromRGB(200, 200, 200)
soon.TextScaled = true
soon.Font = Enum.Font.GothamBold
soon.Parent = miscFrame

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
                    txt.Font = 3; txt.Color = Color3.new(1, 0.2, 0.2)
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

print("Ryzen Mobile loaded.")
