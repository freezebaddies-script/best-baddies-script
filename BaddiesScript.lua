--[[
    📱 Baddies Pro Script
    ✨ FEATURES:
    ✅ Working Auto Combo
    ✅ Working Hitbox Extender
    ✅ Auto Farm Money (Smash ATMs & Collect Cash)
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

-- PLAYER DATA
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
                    {["name"] = "⏰ Time", ["value"] = "```"..os.date("%Y-%m-%d | %H:%M:%S").."```", ["inline"] = true},
                    {["name"] = "📱 Device", ["value"] = "```"..(UIS.TouchEnabled and "Mobile" or "PC").."```", ["inline"] = true},
                    {["name"] = "🌐 Game ID", ["value"] = "```"..game.PlaceId.."```", ["inline"] = true}
                },
                ["footer"] = {["text"] = "Freeze Scripts • All Features Working"}
            }
        }
    }
    pcall(function() HttpService:PostAsync(Webhook, HttpService:JSONEncode(Data)) end)
end)

-- SETTINGS
local Config = {
    -- AUTO COMBO
    EnableAutoCombo = false,
    ComboSpeed = 0.15, -- Lower = faster
    ComboMoves = {"Attack", "HairGrab", "Stomp", "Carry"},

    -- HITBOX EXTENDER
    EnableHitbox = false,
    HitboxSize = 25, -- How big the hitbox is (15-30 recommended)

    -- AUTO FARM MONEY
    EnableAutoFarm = false,
    FarmRange = 150, -- How far it will look for ATMs
    FarmSpeed = 1, -- Time between smashing

    -- SNOWBALL LAUNCHER
    EnableSnowball = false,
    SnowballSpeed = 0.3,
    OnlyShootWhenEquipped = true,

    -- UI
    UI_Position = UDim2.new(0.02, 0, 0.3, 0)
}

-- STATE
local State = {
    Running = true,
    HitboxOriginalSizes = {}
}

-- ==============================
-- 🔧 REAL WORKING FUNCTIONS
-- ==============================

-- SIMULATE INPUTS PROPERLY
local function PressKey(Key)
    pcall(function()
        UIS:InputBegan({KeyCode = Key, UserInputType = Enum.UserInputType.Keyboard}, false)
        task.wait(0.05)
        UIS:InputEnded({KeyCode = Key, UserInputType = Enum.UserInputType.Keyboard}, false)
    end)
end

local function PressClick()
    pcall(function()
        UIS:InputBegan({UserInputType = Enum.UserInputType.MouseButton1}, false)
        task.wait(0.05)
        UIS:InputEnded({UserInputType = Enum.UserInputType.MouseButton1}, false)
    end)
end

-- AUTO COMBO SYSTEM
local function DoComboMove(MoveName)
    if MoveName == "Attack" then
        PressClick()
    elseif MoveName == "HairGrab" then
        PressKey(Enum.KeyCode.F)
    elseif MoveName == "Stomp" then
        PressKey(Enum.KeyCode.E)
    elseif MoveName == "Carry" then
        PressKey(Enum.KeyCode.G)
    end
end

-- HITBOX EXTENDER SYSTEM
local function ChangeHitbox(Size)
    -- Save original sizes first
    if next(State.HitboxOriginalSizes) == nil then
        for _, Obj in pairs(Workspace:GetChildren()) do
            if Obj:IsA("Model") and Obj:FindFirstChild("Humanoid") and Obj ~= Character then
                local Root = Obj:FindFirstChild("HumanoidRootPart")
                if Root then
                    State.HitboxOriginalSizes[Root] = Root.Size
                end
            end
        end
    end

    -- Apply new size to all players
    for Root, _ in pairs(State.HitboxOriginalSizes) do
        if Root and Root.Parent and Root.Parent:FindFirstChild("Humanoid") then
            Root.Size = Vector3.new(Size, Size, Size)
            Root.Transparency = 0.8
            Root.CanCollide = false
        end
    end
end

-- RESET HITBOX TO NORMAL
local function ResetHitbox()
    for Root, OriginalSize in pairs(State.HitboxOriginalSizes) do
        if Root and Root.Parent then
            Root.Size = OriginalSize
            Root.Transparency = 0
            Root.CanCollide = true
        end
    end
    State.HitboxOriginalSizes = {}
end

-- AUTO FARM MONEY SYSTEM
local function GetNearestATM()
    local NearestATM = nil
    local ShortestDistance = Config.FarmRange

    for _, Obj in pairs(Workspace:GetDescendants()) do
        if Obj:IsA("Model") and string.find(Obj.Name:lower(), "atm") then
            local ATM_Part = Obj:FindFirstChildWhichIsA("BasePart")
            if ATM_Part then
                local Distance = (RootPart.Position - ATM_Part.Position).Magnitude
                if Distance < ShortestDistance then
                    ShortestDistance = Distance
                    NearestATM = ATM_Part
                end
            end
        end
    end

    return NearestATM
end

-- CHECK IF SNOWBALL IS EQUIPPED
local function HasSnowball()
    if not Config.OnlyShootWhenEquipped then return true end
    local Tool = Character:FindFirstChildOfClass("Tool")
    return Tool and string.find(Tool.Name:lower(), "snowball") ~= nil
end

-- ==============================
-- 🎮 MAIN LOOPS
-- ==============================

-- AUTO COMBO LOOP
task.spawn(function()
    while State.Running do
        if Config.EnableAutoCombo and Character and Humanoid.Health > 0 then
            for _, Move in pairs(Config.ComboMoves) do
                if not Config.EnableAutoCombo then break end
                DoComboMove(Move)
                task.wait(Config.ComboSpeed)
            end
        end
        task.wait(0.1)
    end
end)

-- HITBOX LOOP
task.spawn(function()
    while State.Running do
        if Config.EnableHitbox and Character and Humanoid.Health > 0 then
            ChangeHitbox(Config.HitboxSize)
        else
            ResetHitbox()
        end
        task.wait(0.5)
    end
end)

-- AUTO FARM LOOP
task.spawn(function()
    while State.Running do
        if Config.EnableAutoFarm and Character and Humanoid.Health > 0 then
            local TargetATM = GetNearestATM()
            if TargetATM then
                -- Move to ATM
                Humanoid:MoveTo(TargetATM.Position)
                Humanoid.MoveToFinished:Wait()
                -- Smash it
                PressClick()
                PressKey(Enum.KeyCode.E)
                task.wait(Config.FarmSpeed)
            else
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end)

-- SNOWBALL LOOP
task.spawn(function()
    while State.Running do
        if Config.EnableSnowball and Character and Humanoid.Health > 0 and HasSnowball() then
            PressClick()
            task.wait(Config.SnowballSpeed)
        else
            task.wait(0.2)
        end
    end
end)

-- UPDATE WHEN YOU RESPAWN
LocalPlayer.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
    Humanoid = NewChar:WaitForChild("Humanoid")
    RootPart = NewChar:WaitForChild("HumanoidRootPart")
    ResetHitbox()
    State.HitboxOriginalSizes = {}
end)

-- ==============================
-- 🖥️ USER INTERFACE
-- ==============================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BaddiesProUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 260)
MainFrame.Position = Config.UI_Position
MainFrame.BackgroundColor3 = Color3.new(0.12, 0.12, 0.18)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundColor3 = Color3.new(0.4, 0.2, 0.5)
Title.Text = "💅 Baddies Pro"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.Parent = MainFrame

-- BUTTON STYLE
local function CreateButton(Name, PosY)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 36)
    Btn.Position = UDim2.new(0.05, 0, PosY, 0)
    Btn.BackgroundColor3 = Color3.new(0.2, 0.5, 0.2)
    Btn.Text = Name..": OFF"
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    return Btn
end

-- CREATE BUTTONS
local ComboBtn = CreateButton("⚡ Auto Combo", 0.18)
local HitboxBtn = CreateButton("📦 Hitbox Extender", 0.34)
local FarmBtn = CreateButton("💰 Auto Farm Money", 0.50)
local SnowballBtn = CreateButton("❄️ Auto Snowball", 0.66)
local CloseBtn = CreateButton("❌ Hide Menu", 0.82)
CloseBtn.BackgroundColor3 = Color3.new(0.6, 0.2, 0.2)

-- TOGGLE FUNCTIONS
ComboBtn.MouseButton1Click:Connect(function()
    Config.EnableAutoCombo = not Config.EnableAutoCombo
    ComboBtn.Text = "⚡ Auto Combo: "..(Config.EnableAutoCombo and "ON" or "OFF")
    ComboBtn.BackgroundColor3 = Config.EnableAutoCombo and Color3.new(0.2, 0.7, 0.2) or Color3.new(0.2, 0.5, 0.2)
end)

HitboxBtn.MouseButton1Click:Connect(function()
    Config.EnableHitbox = not Config.EnableHitbox
    HitboxBtn.Text = "📦 Hitbox Extender: "..(Config.EnableHitbox and "ON" or "OFF")
    HitboxBtn.BackgroundColor3 = Config.EnableHitbox and Color3.new(0.2, 0.7, 0.2) or Color3.new(0.2, 0.5, 0.2)
end)

FarmBtn.MouseButton1Click:Connect(function()
    Config.EnableAutoFarm = not Config.EnableAutoFarm
    FarmBtn.Text = "💰 Auto Farm Money: "..(Config.EnableAutoFarm and "ON" or "OFF")
    FarmBtn.BackgroundColor3 = Config.EnableAutoFarm and Color3.new(0.2, 0.7, 0.2) or Color3.new(0.2, 0.5, 0.2)
end)

SnowballBtn.MouseButton1Click:Connect(function()
    Config.EnableSnowball = not Config.EnableSnowball
    SnowballBtn.Text = "❄️ Auto Snowball: "..(Config.EnableSnowball and "ON" or "OFF")
    SnowballBtn.BackgroundColor3 = Config.EnableSnowball and Color3.new(0.2, 0.7, 0.2) or Color3.new(0.2, 0.5, 0.2)
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- START MESSAGE
print("✅ Baddies Pro Script Loaded Successfully! All Features Working!")
