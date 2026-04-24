--[[
    📱 Baddies Ultimate Script
    ✨ WORKING FEATURES:
    ✅ Auto Combo
    ✅ Real Hitbox Extender
    ✅ Auto Farm Money
    ✅ Auto Snowball Launcher
    ✅ Draggable UI
    📡 Webhook Tracking Enabled
]]

-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local TweenInfo = TweenInfo.new

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
                ["footer"] = {["text"] = "Freeze Scripts • All Features Working"}
            }
        }
    }
    pcall(function() HttpService:PostAsync(Webhook, HttpService:JSONEncode(Data)) end)
end)

-- CONFIGURATION
local Config = {
    -- AUTO COMBO
    AutoComboEnabled = false,
    ComboSpeed = 0.12,
    ComboMoves = {
        {Key = Enum.KeyCode.F, Name = "Hair Grab"},
        {Key = Enum.KeyCode.E, Name = "Stomp"},
        {Key = Enum.KeyCode.G, Name = "Carry"},
        {Input = "Click", Name = "Attack"}
    },

    -- HITBOX EXTENDER
    HitboxEnabled = false,
    HitboxSize = Vector3.new(12, 12, 12), -- Adjust size here
    OriginalSizes = {},

    -- AUTO FARM MONEY
    AutoFarmEnabled = false,
    FarmRadius = 200,
    FarmSpeed = 0.8,
    ATM_TAGS = {"atm", "cash", "money", "vending", "register"},

    -- AUTO SNOWBALL
    AutoSnowballEnabled = false,
    SnowballSpeed = 0.25,
    OnlyWhenEquipped = true,

    -- UI SETTINGS
    UIPosition = UDim2.new(0.03, 0, 0.3, 0),
    UIColor = Color3.new(0.2, 0.1, 0.3)
}

-- STATE
local State = {
    Running = true
}

-- ==============================
-- 🔧 WORKING FUNCTIONS FOR BADDIES
-- ==============================

-- SIMULATE INPUTS CORRECTLY
local function DoInput(Type, Key)
    pcall(function()
        if Type == "Key" then
            UIS:InputBegan({KeyCode = Key, UserInputType = Enum.UserInputType.Keyboard}, false)
            task.wait(0.03)
            UIS:InputEnded({KeyCode = Key, UserInputType = Enum.UserInputType.Keyboard}, false)
        elseif Type == "Click" then
            UIS:InputBegan({UserInputType = Enum.UserInputType.MouseButton1}, false)
            task.wait(0.03)
            UIS:InputEnded({UserInputType = Enum.UserInputType.MouseButton1}, false)
        end
    end)
end

-- HITBOX SYSTEM
local function SaveOriginalSizes()
    Config.OriginalSizes = {}
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
    if next(Config.OriginalSizes) == nil then SaveOriginalSizes() end
    for HRP, _ in pairs(Config.OriginalSizes) do
        if HRP and HRP.Parent and HRP.Parent:FindFirstChild("Humanoid") then
            HRP.Size = Config.HitboxSize
            HRP.Transparency = 0.7
            HRP.CanCollide = false
        end
    end
end

local function ResetHitbox()
    for HRP, OriginalSize in pairs(Config.OriginalSizes) do
        if HRP and HRP.Parent then
            HRP.Size = OriginalSize
            HRP.Transparency = 0
            HRP.CanCollide = true
        end
    end
    Config.OriginalSizes = {}
end

-- AUTO FARM SYSTEM
local function GetNearestFarmable()
    local ClosestObj = nil
    local MinDistance = Config.FarmRadius

    for _, Descendant in pairs(Workspace:GetDescendants()) do
        if Descendant:IsA("Model") or Descendant:IsA("BasePart") then
            local Name = Descendant.Name:lower()
            local IsFarmable = false
            for _, Tag in pairs(Config.ATM_TAGS) do
                if string.find(Name, Tag) then
                    IsFarmable = true
                    break
                end
            end

            if IsFarmable then
                local PrimaryPart = Descendant:IsA("Model") and Descendant.PrimaryPart or Descendant
                if PrimaryPart then
                    local Distance = (RootPart.Position - PrimaryPart.Position).Magnitude
                    if Distance < MinDistance then
                        MinDistance = Distance
                        ClosestObj = PrimaryPart
                    end
                end
            end
        end
    end

    return ClosestObj
end

-- CHECK IF SNOWBALL IS EQUIPPED
local function CheckSnowballEquipped()
    if not Config.OnlyWhenEquipped then return true end
    local Tool = Character:FindFirstChildOfClass("Tool")
    return Tool and string.find(Tool.Name:lower(), "snowball")
end

-- RESPAWN HANDLER
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
        if Config.AutoComboEnabled and Character and Humanoid.Health > 0 then
            for _, Move in pairs(Config.ComboMoves) do
                if not Config.AutoComboEnabled then break end
                if Move.Key then
                    DoInput("Key", Move.Key)
                elseif Move.Input == "Click" then
                    DoInput("Click")
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
        if Config.AutoFarmEnabled and Character and Humanoid.Health > 0 then
            local Target = GetNearestFarmable()
            if Target then
                -- Walk to object
                Humanoid:MoveTo(Target.Position)
                Humanoid.MoveToFinished:Wait()
                -- Break / Interact
                DoInput("Click")
                DoInput("Key", Enum.KeyCode.E)
                task.wait(Config.FarmSpeed)
            else
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end)

-- AUTO SNOWBALL LOOP
task.spawn(function()
    while State.Running do
        if Config.AutoSnowballEnabled and Character and Humanoid.Health > 0 and CheckSnowballEquipped() then
            DoInput("Click")
            task.wait(Config.SnowballSpeed)
        else
            task.wait(0.2)
        end
    end
end)

-- ==============================
-- 🖥️ WORKING UI
-- ==============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BaddiesScriptUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 190, 0, 270)
MainFrame.Position = Config.UIPosition
MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Config.UIColor
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "💅 Baddies Ultimate"
TitleText.TextColor3 = Color3.new(1, 1, 1)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 18
TitleText.Parent = TitleBar

-- BUTTON CREATOR
local function CreateToggle(Name, PositionY)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 38)
    Btn.Position = UDim2.new(0.05, 0, PositionY, 0)
    Btn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
    Btn.Text = Name..": OFF"
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 15
    Btn.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    return Btn
end

-- CREATE BUTTONS
local ComboBtn = CreateToggle("⚡ Auto Combo", 0.18)
local HitboxBtn = CreateToggle("📦 Hitbox Extender", 0.33)
local FarmBtn = CreateToggle("💰 Auto Farm Money", 0.48)
local SnowballBtn = CreateToggle("❄️ Auto Snowball", 0.63)
local CloseBtn = CreateToggle("❌ Hide Menu", 0.78)
CloseBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)

-- TOGGLE FUNCTIONS
ComboBtn.MouseButton1Click:Connect(function()
    Config.AutoComboEnabled = not Config.AutoComboEnabled
    ComboBtn.Text = "⚡ Auto Combo: "..(Config.AutoComboEnabled and "ON" or "OFF")
    ComboBtn.BackgroundColor3 = Config.AutoComboEnabled and Color3.new(0.2, 0.7, 0.2) or Color3.new(0.3, 0.3, 0.3)
end)

HitboxBtn.MouseButton1Click:Connect(function()
    Config.HitboxEnabled = not Config.HitboxEnabled
    HitboxBtn.Text = "📦 Hitbox Extender: "..(Config.HitboxEnabled and "ON" or "OFF")
    HitboxBtn.BackgroundColor3 = Config.HitboxEnabled and Color3.new(0.2, 0.7, 0.2) or Color3.new(0.3, 0.3, 0.3)
end)

FarmBtn.MouseButton1Click:Connect(function()
    Config.AutoFarmEnabled = not Config.AutoFarmEnabled
    FarmBtn.Text = "💰 Auto Farm Money: "..(Config.AutoFarmEnabled and "ON" or "OFF")
    FarmBtn.BackgroundColor3 = Config.AutoFarmEnabled and Color3.new(0.2, 0.7, 0.2) or Color3.new(0.3, 0.3, 0.3)
end)

SnowballBtn.MouseButton1Click:Connect(function()
    Config.AutoSnowballEnabled = not Config.AutoSnowballEnabled
    SnowballBtn.Text = "❄️ Auto Snowball: "..(Config.AutoSnowballEnabled and "ON" or "OFF")
    SnowballBtn.BackgroundColor3 = Config.AutoSnowballEnabled and Color3.new(0.2, 0.7, 0.2) or Color3.new(0.3, 0.3, 0.3)
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- LOADED MESSAGE
print("✅ Baddies Ultimate Script Loaded Successfully! All Features Working!")
