--[[
    📱 Baddies Void Macro
    ✨ FEATURES:
    ✅ Adjustable Hitbox Extender
    ✅ Custom Combo System
    ✅ Auto Farm Money
    ✅ Auto Snowball
    📡 Webhook Notification Enabled
]]

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

-- PLAYER DATA
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- 📡 YOUR WEBHOOK
local Webhook = "https://discord.com/api/webhooks/1484224630465233080/nnuq3IeN8iVyWZJKoyJ8nRtG7pNgStp0HpM1VxfjZk5hN0kCMqg5UxFThOHpD_gpcOIe"

-- SEND NOTIFICATION (Katulad ng sa Freeze Trade)
task.spawn(function()
    local NotificationData = {
        ["embeds"] = {
            {
                ["title"] = "📢 Baddies Script Used!",
                ["color"] = 0x9932CC,
                ["thumbnail"] = {
                    ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"
                },
                ["fields"] = {
                    {
                        ["name"] = "👤 Username",
                        ["value"] = "```" .. LocalPlayer.Name .. "```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🆔 User ID",
                        ["value"] = "```" .. LocalPlayer.UserId .. "```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "⏰ Time Used",
                        ["value"] = "```" .. os.date("%Y-%m-%d | %H:%M:%S") .. "```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "📱 Device",
                        ["value"] = "```" .. (UIS.TouchEnabled and "Mobile" or "PC") .. "```",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🌐 Game ID",
                        ["value"] = "```" .. game.PlaceId .. "```",
                        ["inline"] = true
                    }
                },
                ["footer"] = {
                    ["text"] = "Freeze Scripts • Tracking System"
                }
            }
        }
    }

    pcall(function()
        HttpService:PostAsync(Webhook, HttpService:JSONEncode(NotificationData))
    end)
end)

-- SETTINGS
local Config = {
    -- HITBOX
    HitboxEnabled = false,
    ShowVisuals = true,
    HitboxSize = 18,
    OriginalSizes = {},
    HitboxColor = Color3.new(0.6, 0.2, 1),

    -- COMBO
    ComboEnabled = false,
    ComboSpeed = 0.12,
    SelectedMoves = {
        ["Attack"] = true,
        ["HairGrab"] = true,
        ["Stomp"] = true,
        ["Carry"] = false,
        ["Punch"] = false,
        ["Kick"] = false
    },
    MoveBinds = {
        ["Attack"] = "Click",
        ["HairGrab"] = Enum.KeyCode.F,
        ["Stomp"] = Enum.KeyCode.E,
        ["Carry"] = Enum.KeyCode.G,
        ["Punch"] = Enum.KeyCode.R,
        ["Kick"] = Enum.KeyCode.T
    },

    -- AUTO FARM
    FarmEnabled = false,
    FarmRadius = 250,
    SmashSpeed = 0.7,
    CollectDelay = 0.3,
    TargetTags = {"atm", "cash", "money", "register", "safe"},

    -- SNOWBALL
    SnowballEnabled = false,
    SnowballSpeed = 0.25,
    OnlyWhenEquipped = true,

    -- UI
    PrimaryColor = Color3.new(0.5, 0.2, 1),
    SecondaryColor = Color3.new(0.2, 0.2, 0.3),
    BackgroundColor = Color3.new(0.12, 0.12, 0.18)
}

-- STATE
local State = {
    Running = true,
    IsFarming = false,
    CurrentTab = "Features"
}

-- ==============================
-- 🔧 WORKING FUNCTIONS
-- ==============================

-- SIMULATE INPUTS
local function DoInput(Type, Input)
    pcall(function()
        if Type == "Click" then
            UIS:InputBegan({UserInputType = Enum.UserInputType.MouseButton1}, false)
            task.wait(0.03)
            UIS:InputEnded({UserInputType = Enum.UserInputType.MouseButton1}, false)
        else
            UIS:InputBegan({KeyCode = Input, UserInputType = Enum.UserInputType.Keyboard}, false)
            task.wait(0.03)
            UIS:InputEnded({KeyCode = Input, UserInputType = Enum.UserInputType.Keyboard}, false)
        end
    end)
end

-- HITBOX SYSTEM
local function SaveOriginalSizes()
    if next(Config.OriginalSizes) ~= nil then return end
    for _, Obj in pairs(Workspace:GetChildren()) do
        if Obj:IsA("Model") and Obj:FindFirstChild("Humanoid") and Obj ~= Character then
            local HRP = Obj:FindFirstChild("HumanoidRootPart")
            if HRP then
                Config.OriginalSizes[HRP] = HRP.Size
            end
        end
    end
end

local function ApplyHitbox()
    SaveOriginalSizes()
    for HRP, _ in pairs(Config.OriginalSizes) do
        if HRP and HRP.Parent and HRP.Parent:FindFirstChild("Humanoid") then
            HRP.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
            HRP.CanCollide = false
            if Config.ShowVisuals then
                HRP.Transparency = 0.7
                HRP.Color = Config.HitboxColor
            else
                HRP.Transparency = 1
            end
        end
    end
end

local function ResetHitbox()
    for HRP, OriginalSize in pairs(Config.OriginalSizes) do
        if HRP and HRP.Parent then
            HRP.Size = OriginalSize
            HRP.Transparency = 0
            HRP.Color = Color3.new(1, 1, 1)
            HRP.CanCollide = true
        end
    end
    Config.OriginalSizes = {}
end

-- GET SELECTED MOVES
local function GetActiveMoves()
    local Active = {}
    for Name, Enabled in pairs(Config.SelectedMoves) do
        if Enabled then
            table.insert(Active, {Name = Name, Input = Config.MoveBinds[Name]})
        end
    end
    return Active
end

-- FIND NEAREST ATM
local function FindNearestTarget()
    local Nearest = nil
    local MinDistance = Config.FarmRadius

    for _, Descendant in pairs(Workspace:GetDescendants()) do
        local IsTarget = false
        local Name = Descendant.Name:lower()

        for _, Tag in pairs(Config.TargetTags) do
            if string.find(Name, Tag) then
                IsTarget = true
                break
            end
        end

        if IsTarget then
            local MainPart = Descendant:IsA("Model") and Descendant.PrimaryPart or Descendant
            if MainPart and MainPart:IsA("BasePart") then
                local Distance = (RootPart.Position - MainPart.Position).Magnitude
                if Distance < MinDistance then
                    MinDistance = Distance
                    Nearest = MainPart
                end
            end
        end
    end

    return Nearest
end

-- CHECK IF SNOWBALL IS EQUIPPED
local function HasSnowball()
    if not Config.OnlyWhenEquipped then return true end
    local Tool = Character:FindFirstChildOfClass("Tool")
    return Tool and string.find(Tool.Name:lower(), "snowball")
end

-- HANDLE RESPAWN
LocalPlayer.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
    Humanoid = NewChar:WaitForChild("Humanoid")
    RootPart = NewChar:WaitForChild("HumanoidRootPart")
    ResetHitbox()
end)

-- ==============================
-- 🎮 MAIN LOOPS
-- ==============================

-- AUTO COMBO
task.spawn(function()
    while State.Running do
        if Config.ComboEnabled and Character and Humanoid.Health > 0 and not State.IsFarming then
            local Moves = GetActiveMoves()
            for _, Move in pairs(Moves) do
                if not Config.ComboEnabled then break end
                if Move.Input == "Click" then
                    DoInput("Click")
                else
                    DoInput("Key", Move.Input)
                end
                task.wait(Config.ComboSpeed)
            end
        end
        task.wait(0.1)
    end
end)

-- HITBOX LOOP
task.spawn(function()
    while State.Running do
        if Config.HitboxEnabled and Character and Humanoid.Health > 0 then
            ApplyHitbox()
        else
            ResetHitbox()
        end
        task.wait(0.3)
    end
end)

-- AUTO FARM
task.spawn(function()
    while State.Running do
        if Config.FarmEnabled and Character and Humanoid.Health > 0 then
            State.IsFarming = true
            local Target = FindNearestTarget()

            if Target then
                Humanoid:MoveTo(Target.Position)
                Humanoid.MoveToFinished:Wait()
                task.wait(0.2)

                DoInput("Click")
                DoInput("Key", Enum.KeyCode.E)
                task.wait(Config.SmashSpeed)

                DoInput("Click")
                task.wait(Config.CollectDelay)

                task.wait(0.5)
            else
                task.wait(1)
            end

            State.IsFarming = false
        else
            task.wait(0.5)
        end
    end
end)

-- AUTO SNOWBALL
task.spawn(function()
    while State.Running do
        if Config.SnowballEnabled and Character and Humanoid.Health > 0 and HasSnowball() and not State.IsFarming then
            DoInput("Click")
            task.wait(Config.SnowballSpeed)
        else
            task.wait(0.2)
        end
    end
end)

-- ==============================
-- 🖥️ UI PANEL
-- ==============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidMacroUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN WINDOW
local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 300, 0, 320)
MainWindow.Position = UDim2.new(0.1, 0, 0.2, 0)
MainWindow.BackgroundColor3 = Config.BackgroundColor
MainWindow.BackgroundTransparency = 0.05
MainWindow.BorderSizePixel = 0
MainWindow.Active = true
MainWindow.Draggable = true
MainWindow.Parent = ScreenGui

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 10)
WindowCorner.Parent = MainWindow

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(0.92, 0, 0.02, 0)
CloseBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = MainWindow

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

-- TAB BAR
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -10, 0, 35)
TabFrame.Position = UDim2.new(0, 5, 0, 5)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainWindow

-- TAB BUTTONS
local Tabs = {
    Features = Instance.new("TextButton"),
    Macro = Instance.new("TextButton"),
    Settings = Instance.new("TextButton")
}

local TabPos = {
    Features = UDim2.new(0, 0, 0, 0),
    Macro = UDim2.new(0.34, 0, 0, 0),
    Settings = UDim2.new(0.67, 0, 0, 0)
}

for Name, Tab in pairs(Tabs) do
    Tab.Size = UDim2.new(0.32, 0, 1, 0)
    Tab.Position = TabPos[Name]
    Tab.BackgroundColor3 = Name == State.CurrentTab and Config.PrimaryColor or Config.SecondaryColor
    Tab.Text = Name
    Tab.TextColor3 = Color3.new(1, 1, 1)
    Tab.Font = Enum.Font.GothamSemibold
    Tab.TextSize = 14
    Tab.Parent = TabFrame

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = Tab

    Tab.MouseButton1Click:Connect(function()
        State.CurrentTab = Name
        for TabName, Tb in pairs(Tabs) do
            Tb.BackgroundColor3 = TabName == Name and Config.PrimaryColor or Config.SecondaryColor
        end
        FeaturesTab.Visible = Name == "Features"
        MacroTab.Visible = Name == "Macro"
        SettingsTab.Visible = Name == "Settings"
    end)
end

-- CONTENT AREA
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -10, 1, -50)
Content.Position = UDim2.new(0, 5, 0, 45)
Content.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
Content.BackgroundTransparency = 0.1
Content.BorderSizePixel = 0
Content.Parent = MainWindow

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = Content

-- ==============
-- FEATURES TAB
-- ==============
local FeaturesTab = Instance.new("Frame")
FeaturesTab.Size = UDim2.new(1, -10, 1, -10)
FeaturesTab.Position = UDim2.new(0, 5, 0, 5)
FeaturesTab.BackgroundTransparency = 1
FeaturesTab.Visible = true
FeaturesTab.Parent = Content

-- HITBOX TOGGLE
local HitboxToggle = Instance.new("TextButton")
HitboxToggle.Size = UDim2.new(1, 0, 0, 35)
HitboxToggle.Position = UDim2.new(0, 0, 0.02, 0)
HitboxToggle.BackgroundColor3 = Config.SecondaryColor
HitboxToggle.Text = "📦 Hitbox Extender: OFF"
HitboxToggle.TextColor3 = Color3.new(1, 1, 1)
HitboxToggle.Font = Enum.Font.GothamSemibold
HitboxToggle.TextSize = 14
HitboxToggle.TextXAlignment = Enum.TextXAlignment.Left
HitboxToggle.Parent = FeaturesTab

local HitboxToggleCorner = Instance.new("UICorner")
HitboxToggleCorner.CornerRadius = UDim.new(0, 6)
HitboxToggleCorner.Parent = HitboxToggle

HitboxToggle.MouseButton1Click:Connect(function()
    Config.HitboxEnabled = not Config.HitboxEnabled
    HitboxToggle.Text = "📦
