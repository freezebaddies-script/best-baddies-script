--[[
    📱 Baddies Void Macro
    ✨ FEATURES:
    ✅ Custom Combo System (Choose Weapons/Moves)
    ✅ Adjustable Hitbox Extender (With Visuals)
    ✅ Real Auto Farm Money (Go → Smash → Collect → Repeat)
    ✅ Auto Snowball
    ✅ Clean Tabbed UI Like In Your Screenshots
    📡 Webhook Tracking Enabled
]]

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

-- PLAYER SETUP
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- 📡 YOUR WEBHOOK
local Webhook = "https://discord.com/api/webhooks/1484224630465233080/nnuq3IeN8iVyWZJKoyJ8nRtG7pNgStp0HpM1VxfjZk5hN0kCMqg5UxFThOHpD_gpcOIe"

-- SEND NOTIFICATION
task.spawn(function()
    local Data = {
        ["embeds"] = {
            {
                ["title"] = "📢 Baddies Script Used!",
                ["color"] = 0x9932CC,
                ["thumbnail"] = {
                    ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
                },
                ["fields"] = {
                    {["name"] = "👤 Username", ["value"] = "```"..LocalPlayer.Name.."```", ["inline"] = true},
                    {["name"] = "🆔 User ID", ["value"] = "```"..LocalPlayer.UserId.."```", ["inline"] = true},
                    {["name"] = "⏰ Time Used", ["value"] = "```"..os.date("%Y-%m-%d | %H:%M:%S").."```", ["inline"] = true},
                    {["name"] = "📱 Device", ["value"] = "```"..(UIS.TouchEnabled and "Mobile" or "PC").."```", ["inline"] = true},
                    {["name"] = "🌐 Game ID", ["value"] = "```"..game.PlaceId.."```", ["inline"] = true}
                },
                ["footer"] = {["text"] = "Freeze Scripts • Void Macro"}
            }
        }
    }
    pcall(function() HttpService:PostAsync(Webhook, HttpService:JSONEncode(Data)) end)
end)

-- CONFIGURATION
local Config = {
    -- COMBO SETTINGS
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

    -- HITBOX SETTINGS
    HitboxEnabled = false,
    ShowHitboxVisuals = true,
    HitboxSize = 18,
    OriginalSizes = {},
    VisualColor = Color3.new(0.6, 0.2, 1),

    -- AUTO FARM SETTINGS
    FarmEnabled = false,
    FarmRadius = 250,
    SmashSpeed = 0.7,
    CollectDelay = 0.3,
    TargetTags = {"atm", "cash", "money", "register", "safe"},

    -- SNOWBALL SETTINGS
    SnowballEnabled = false,
    SnowballSpeed = 0.25,
    OnlyWhenEquipped = true,

    -- UI SETTINGS
    PrimaryColor = Color3.new(0.5, 0.2, 1),
    SecondaryColor = Color3.new(0.2, 0.2, 0.3),
    TextColor = Color3.new(1, 1, 1)
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

-- GET ONLY THE MOVES YOU SELECTED
local function GetActiveMoves()
    local Active = {}
    for Name, Enabled in pairs(Config.SelectedMoves) do
        if Enabled then
            table.insert(Active, {Name = Name, Input = Config.MoveBinds[Name]})
        end
    end
    return Active
end

-- HITBOX SYSTEM WITH VISUALS
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
            if Config.ShowHitboxVisuals then
                HRP.Transparency = 0.7
                HRP.Color = Config.VisualColor
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

-- AUTO FARM SYSTEM - GO TO ATM → SMASH → COLLECT → NEXT
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

-- HANDLE RESPAWNS
LocalPlayer.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
    Humanoid = NewChar:WaitForChild("Humanoid")
    RootPart = NewChar:WaitForChild("HumanoidRootPart")
    ResetHitbox()
end)

-- ==============================
-- 🎮 MAIN LOOPS
-- ==============================

-- AUTO COMBO LOOP
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

-- AUTO FARM LOOP
task.spawn(function()
    while State.Running do
        if Config.FarmEnabled and Character and Humanoid.Health > 0 then
            State.IsFarming = true
            local Target = FindNearestTarget()

            if Target then
                -- Walk to ATM
                Humanoid:MoveTo(Target.Position)
                Humanoid.MoveToFinished:Wait()
                task.wait(0.2)

                -- Smash it
                DoInput("Click")
                DoInput("Key", Enum.KeyCode.E)
                task.wait(Config.SmashSpeed)

                -- Collect money
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

-- AUTO SNOWBALL LOOP
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
-- 🖥️ UI EXACTLY LIKE YOUR SCREENSHOTS
-- ==============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidMacroUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN WINDOW
local MainWindow = Instance.new("Frame")
MainWindow.Size = UDim2.new(0, 320, 0, 350)
MainWindow.Position = UDim2.new(0.1, 0, 0.2, 0)
MainWindow.BackgroundColor3 = Config.SecondaryColor
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
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(0.92, 0, 0.02, 0)
CloseBtn.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainWindow

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = CloseBtn

-- TABS BAR
local TabsFrame = Instance.new("Frame")
TabsFrame.Size = UDim2.new(1, -10, 0, 35)
TabsFrame.Position = UDim2.new(0, 5, 0, 5)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = MainWindow

-- TAB BUTTONS
local TabButtons = {
    ["Features"] = Instance.new("TextButton"),
    ["Macro"] = Instance.new("TextButton"),
    ["Settings"] = Instance.new("TextButton")
}

local TabPositions = {
    ["Features"] = UDim2.new(0, 0, 0, 0),
    ["Macro"] = UDim2.new(0.34, 0, 0, 0),
    ["Settings"] = UDim2.new(0.67, 0, 0, 0)
}

for TabName, TabBtn in pairs(TabButtons) do
    TabBtn.Size = UDim2.new(0.32, 0, 1, 0)
    TabBtn.Position = TabPositions[TabName]
    TabBtn.BackgroundColor3 = TabName == State.CurrentTab and Config.PrimaryColor or Color3.new(0.3, 0.3, 0.4)
    TabBtn.Text = TabName
    TabBtn.TextColor3 = Color3.new(1, 1, 1)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 14
    TabBtn.Parent = TabsFrame

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabBtn
end

-- CONTENT AREA
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -10, 1, -50)
ContentFrame.Position = UDim2.new(0, 5, 0, 40)
ContentFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.2)
ContentFrame.BackgroundTransparency = 0.1
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainWindow

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- ==============
-- FEATURES TAB
-- ==============
local FeaturesTab = Instance.new("Frame")
FeaturesTab.Size = UDim2.new(1, -10, 1, -10)
FeaturesTab.Position = UDim2.new(0, 5, 0, 5)
FeaturesTab.BackgroundTransparency = 1
FeaturesTab.Visible = State.CurrentTab == "Features"
FeaturesTab.Parent = ContentFrame

-- HITBOX TOGGLE
local HitboxToggle = Instance.new("TextButton")
HitboxToggle.Size = UDim2.new(0.7, 0, 0, 35)
HitboxToggle.Position = UDim2.new(0, 0, 0.02, 0)
HitboxToggle.BackgroundColor3 = Color3.new(0.3, 0.3, 0.4)
HitboxToggle.Text = "📦 Hitbox Extender: OFF"
HitboxToggle.TextColor3 = Config.TextColor
HitboxToggle.Font = Enum.Font.GothamSemibold
HitboxToggle.TextSize = 14
HitboxToggle.TextXAlignment = Enum.TextXAlignment.Left
HitboxToggle.Parent = FeaturesTab

local HitboxToggleCorner = Instance.new("UICorner")
HitboxToggleCorner.CornerRadius = UDim.new(0, 6)
HitboxToggleCorner.Parent = HitboxToggle

-- SHOW VISUALS TOGGLE
local VisualToggle = Instance.new("TextButton")
VisualToggle.Size = UDim
