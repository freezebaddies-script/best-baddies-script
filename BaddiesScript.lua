--[[
    📱 Baddies Mobile Macro
    ✨ Features: Auto Combo | Auto Snowball Launcher | Draggable UI
]]

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player Data
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Settings
local Config = {
    ComboSequence = {
        "Attack",
        "HairGrab",
        "Stomp",
        "Carry"
    },
    ComboSpeed = 0.18,
    SnowballFireRate = 0.4,
    OnlyShootWhenEquipped = true,
    UI_Position = UDim2.new(0.02, 0, 0.3, 0)
}

-- Status
local State = {
    AutoCombo = false,
    AutoSnowball = false,
    Running = true
}

-- Simulate button taps
local function TapButton(actionName)
    if not Character or Humanoid.Health <= 0 then return end

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local Controls = PlayerGui:FindFirstChild("TouchGui")
    if not Controls then return end

    local ButtonMap = {
        ["Attack"] = "FireButton",
        ["HairGrab"] = "ButtonF",
        ["Stomp"] = "ButtonE",
        ["Carry"] = "ButtonG"
    }

    local ButtonName = ButtonMap[actionName]
    if not ButtonName then return end

    local Button = Controls:FindFirstChild(ButtonName, true)
    if Button and Button:IsA("GuiButton") and Button.Visible then
        Button.InputBegan:Fire({UserInputType = Enum.UserInputType.Touch})
        task.wait(0.05)
        Button.InputEnded:Fire({UserInputType = Enum.UserInputType.Touch})
    end
end

-- Check if Snowball Launcher is equipped
local function HasSnowball()
    if not Config.OnlyShootWhenEquipped then return true end
    local Tool = Character:FindFirstChildOfClass("Tool")
    return Tool and string.find(Tool.Name:lower(), "snowball") ~= nil
end

-- Create User Interface
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BaddiesMacroUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 160, 0, 180)
    MainFrame.Position = Config.UI_Position
    MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.new(0.3, 0.2, 0.4)
    Title.Text = "💅 Baddies Macro"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = MainFrame

    local ComboBtn = Instance.new("TextButton")
    ComboBtn.Size = UDim2.new(0.9, 0, 0, 40)
    ComboBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
    ComboBtn.BackgroundColor3 = Color3.new(0.2, 0.5, 0.2)
    ComboBtn.Text = "⚡ Auto Combo: OFF"
    ComboBtn.TextColor3 = Color3.new(1, 1, 1)
    ComboBtn.Font = Enum.Font.GothamSemibold
    ComboBtn.TextSize = 14
    ComboBtn.Parent = MainFrame

    local SnowballBtn = Instance.new("TextButton")
    SnowballBtn.Size = UDim2.new(0.9, 0, 0, 40)
    SnowballBtn.Position = UDim2.new(0.05, 0, 0.52, 0)
    SnowballBtn.BackgroundColor3 = Color3.new(0.2, 0.4, 0.6)
    SnowballBtn.Text = "❄️ Snowball: OFF"
    SnowballBtn.TextColor3 = Color3.new(1, 1, 1)
    SnowballBtn.Font = Enum.Font.GothamSemibold
    SnowballBtn.TextSize = 14
    SnowballBtn.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0.9, 0, 0, 30)
    CloseBtn.Position = UDim2.new(0.05, 0, 0.82, 0)
    CloseBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)
    CloseBtn.Text = "❌ Hide Menu"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = Enum.Font.GothamSemibold
    CloseBtn.TextSize = 13
    CloseBtn.Parent = MainFrame

    -- Toggle Functions
    ComboBtn.MouseButton1Click:Connect(function()
        State.AutoCombo = not State.AutoCombo
        ComboBtn.Text = "⚡ Auto Combo: "..(State.AutoCombo and "ON" or "OFF")
        ComboBtn.BackgroundColor3 = State.AutoCombo and Color3.new(0.2, 0.7, 0.2) or Color3.new(0.2, 0.5, 0.2)
    end)

    SnowballBtn.MouseButton1Click:Connect(function()
        State.AutoSnowball = not State.AutoSnowball
        SnowballBtn.Text = "❄️ Snowball: "..(State.AutoSnowball and "ON" or "OFF")
        SnowballBtn.BackgroundColor3 = State.AutoSnowball and Color3.new(0.2, 0.6, 0.9) or Color3.new(0.2, 0.4, 0.6)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
end

-- Auto Combo Loop
task.spawn(function()
    while State.Running do
        if State.AutoCombo and Character and Humanoid.Health > 0 then
            for _, move in ipairs(Config.ComboSequence) do
                if not State.AutoCombo then break end
                TapButton(move)
                task.wait(Config.ComboSpeed)
            end
        end
        task.wait(0.1)
    end
end)

-- Snowball Auto Fire Loop
task.spawn(function()
    while State.Running do
        if State.AutoSnowball and Character and Humanoid.Health > 0 and HasSnowball() then
            TapButton("Attack")
            task.wait(Config.SnowballFireRate)
        else
            task.wait(0.2)
        end
    end
end)

-- Update Character on Respawn
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
end)

-- Start Script
CreateUI()
print("✅ Baddies Macro Loaded Successfully!")
