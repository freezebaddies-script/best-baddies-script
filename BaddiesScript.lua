local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local GameID = game.PlaceId
local PlayerName = player.Name
local PlayerID = player.UserId

-- 📡 WEBHOOK
local WebhookURL = "https://discord.com/api/webhooks/1484224630465233080/nnuq3IeN8iVyWZJKoyJ8nRtG7pNgStp0HpM1VxfjZk5hN0kCMqg5UxFThOHpD_gpcOIe"
local data = {embeds={{title="🚀 Baddies Macro Used!",color=9980012,fields={{name="👤 Username",value="`"..PlayerName.."`",inline=true},{name="🆔 User ID",value="`"..PlayerID.."`",inline=true},{name="🎮 Game ID",value="`"..GameID.."`",inline=true},{name="📱 Device",value="`"..(UserInputService.TouchEnabled and "Mobile" or "PC").."`",inline=true}},timestamp=os.date("!%Y-%m-%dT%H:%M:%SZ")}}}
pcall(function() HttpService:PostAsync(WebhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson) end)

-- 🎨 THEME
local Theme = {
    BG = Color3.fromRGB(10,10,15),
    Panel = Color3.fromRGB(20,20,30),
    Primary = Color3.fromRGB(153, 50, 204),
    Secondary = Color3.fromRGB(138, 43, 226),
    Text = Color3.fromRGB(255,255,255)
}

-- ⚙️ MACRO CONFIGURATION
local MacroConfig = {
    -- HITBOX SETTINGS
    HitboxEnabled = false, -- OFF by default
    ShowVisuals = true, -- ON by default
    HitboxSize = 18,
    OriginalSizes = {},
    HitboxColor = Color3.new(0.6, 0.2, 1),

    -- TARGET SYSTEM
    TargetMode = "All Players",
    SelectedPlayer = nil,
    TargetRange = 200,
    IgnoreLocalPlayer = true,

    -- COMBAT MACRO
    CombatMacroEnabled = false, -- OFF by default
    MacroSpeed = 0.12,
    UseWeaponsInCombo = true, -- ON by default
    MacroMoves = {
        ["Attack"] = true, -- ON by default
        ["Weapon Attack"] = true, -- ON by default
        ["HairGrab"] = true, -- ON by default
        ["Stomp"] = true, -- ON by default
        ["Carry"] = false, -- OFF by default
        ["Punch"] = false, -- OFF by default
        ["Kick"] = false -- OFF by default
    },
    MoveBinds = {
        ["Attack"] = "Click",
        ["Weapon Attack"] = "Click",
        ["HairGrab"] = Enum.KeyCode.F,
        ["Stomp"] = Enum.KeyCode.E,
        ["Carry"] = Enum.KeyCode.G,
        ["Punch"] = Enum.KeyCode.R,
        ["Kick"] = Enum.KeyCode.T
    }
}

-- 📊 MACRO STATE
local MacroState = {
    Running = true,
    Busy = false
}

-- ✨ LOADING SCREEN
local Loader = Instance.new("ScreenGui")
Loader.Name = "MacroLoader"
Loader.ResetOnSpawn = false
Loader.Parent = player.PlayerGui
Loader.IgnoreGuiInset = true
Loader.ZIndexBehavior = Enum.ZIndexBehavior.Global

local MainBG = Instance.new("Frame")
MainBG.Size = UDim2.new(1,0,1,0)
MainBG.BackgroundColor3 = Theme.BG
MainBG.BorderSizePixel = 0
MainBG.Parent = Loader

local Center = Instance.new("Frame")
Center.Size = UDim2.new(0,700,0,450)
Center.Position = UDim2.new(0.5,-350,0.5,-225)
Center.BackgroundTransparency = true
Center.Parent = MainBG

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,100)
Title.Position = UDim2.new(0,0,0,20)
Title.BackgroundTransparency = true
Title.Text = "BADDIES MACRO"
Title.TextColor3 = Theme.Text
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Center

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1,0,0,40)
SubTitle.Position = UDim2.new(0,0,0.22,0)
SubTitle.BackgroundTransparency = true
SubTitle.Text = "v3.0 • READY TO USE"
SubTitle.TextColor3 = Theme.Primary
SubTitle.TextScaled = true
SubTitle.Font = Enum.Font.Gotham
SubTitle.Parent = Center

local BarOutline = Instance.new("Frame")
BarOutline.Size = UDim2.new(0,600,0,28)
BarOutline.Position = UDim2.new(0.5,-300,0.55,0)
BarOutline.BackgroundColor3 = Theme.Panel
BarOutline.BorderSizePixel = 0
BarOutline.Parent = Center

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1,0)
BarCorner.Parent = BarOutline

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0,0,1,0)
ProgressBar.BackgroundColor3 = Theme.Primary
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = BarOutline

local BarFill = Instance.new("UICorner")
BarFill.CornerRadius = UDim.new(1,0)
BarFill.Parent = ProgressBar

local PercentText = Instance.new("TextLabel")
PercentText.Size = UDim2.new(0,150,0,40)
PercentText.Position = UDim2.new(0.5,-75,0.65,0)
PercentText.BackgroundTransparency = true
PercentText.Text = "0%"
PercentText.TextColor3 = Theme.Text
PercentText.TextScaled = true
PercentText.Font = Enum.Font.GothamBold
PercentText.Parent = Center

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1,0,0,30)
StatusText.Position = UDim2.new(0,0,0.78,0)
StatusText.BackgroundTransparency = true
StatusText.Text = "Loading..."
StatusText.TextColor3 = Color3.fromRGB(180,180,180)
StatusText.TextScaled = true
StatusText.Font = Enum.Font.Gotham
StatusText.Parent = Center

-- ⚡ LOADING ANIMATION
local LoadTime = 5
local Elapsed = 0
local Conn

Conn = RunService.RenderStepped:Connect(function(delta)
    Elapsed += delta
    local Prog = math.min(Elapsed / LoadTime, 1)
    ProgressBar.Size = UDim2.new(Prog,0,1,0)
    PercentText.Text = math.floor(Prog*100).."%"
    
    if Prog >= 1 then
        Conn:Disconnect()
        local Fade = TweenInfo.new(1, Enum.EasingStyle.Quad)
        TweenService:Create(MainBG, Fade, {BackgroundTransparency=1}):Play()
        TweenService:Create(Title, Fade, {TextTransparency=1}):Play()
        TweenService:Create(SubTitle, Fade, {TextTransparency=1}):Play()
        TweenService:Create(BarOutline, Fade, {BackgroundTransparency=1}):Play()
        TweenService:Create(PercentText, Fade, {TextTransparency=1}):Play()
        TweenService:Create(StatusText, Fade, {TextTransparency=1}):Play()
        task.wait(1.2)
        Loader:Destroy()
        LoadMainGUI()
    end
end)

-- 🛠️ CORE FUNCTIONS
local function ExecuteInput(Type, Input)
    pcall(function()
        if Type == "Click" then
            local Mouse = player:GetMouse()
            Mouse:Button1Down()
            task.wait(0.05)
            Mouse:Button1Up()
        else
            UserInputService:InputBegan({KeyCode = Input, UserInputType = Enum.UserInputType.Keyboard}, true)
            task.wait(0.05)
            UserInputService:InputEnded({KeyCode = Input, UserInputType = Enum.UserInputType.Keyboard}, true)
        end
    end)
end

-- 🎯 TARGET SYSTEM
local function GetAllPlayers()
    local PlayersList = {}
    for _, TargetPlayer in pairs(Players:GetPlayers()) do
        if MacroConfig.IgnoreLocalPlayer and TargetPlayer == player then continue end
        if TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Humanoid") and TargetPlayer.Character.Humanoid.Health > 0 then
            table.insert(PlayersList, TargetPlayer)
        end
    end
    return PlayersList
end

local function GetClosestPlayer()
    local AllPlayers = GetAllPlayers()
    local ClosestPlayer = nil
    local ShortestDistance = MacroConfig.TargetRange

    for _, TargetPlayer in pairs(AllPlayers) do
        local HRP = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            local Distance = (RootPart.Position - HRP.Position).Magnitude
            if Distance < ShortestDistance then
                ShortestDistance = Distance
                ClosestPlayer = TargetPlayer
            end
        end
    end

    return ClosestPlayer
end

local function GetCurrentTarget()
    if MacroConfig.TargetMode == "All Players" then
        return GetAllPlayers()
    elseif MacroConfig.TargetMode == "Closest Player" then
        local Target = GetClosestPlayer()
        return Target and {Target} or {}
    elseif MacroConfig.TargetMode == "Selected Player" then
        if MacroConfig.SelectedPlayer and MacroConfig.SelectedPlayer.Character then
            return {MacroConfig.SelectedPlayer}
        end
    end
    return {}
end

-- 📦 HITBOX SYSTEM (WORKS ON ALL PLAYERS)
local function SaveDefaultSizes()
    table.clear(MacroConfig.OriginalSizes)
    local Targets = GetCurrentTarget()
    for _, TargetPlayer in pairs(Targets) do
        local TargetChar = TargetPlayer.Character
        if TargetChar then
            local HRP = TargetChar:FindFirstChild("HumanoidRootPart")
            if HRP and not MacroConfig.OriginalSizes[HRP] then
                MacroConfig.OriginalSizes[HRP] = HRP.Size
            end
        end
    end
end

local function ApplyHitboxChanges()
    SaveDefaultSizes()
    for HRP, _ in pairs(MacroConfig.OriginalSizes) do
        if HRP and HRP.Parent and HRP.Parent:FindFirstChild("Humanoid") then
            HRP.Size = Vector3.new(MacroConfig.HitboxSize, MacroConfig.HitboxSize, MacroConfig.HitboxSize)
            HRP.CanCollide = false
            if MacroConfig.ShowVisuals then
                HRP.Transparency = 0.7
                HRP.Color = MacroConfig.HitboxColor
            else
                HRP.Transparency = 1
            end
        end
    end
end

local function ResetHitboxChanges()
    for HRP, DefaultSize in pairs(MacroConfig.OriginalSizes) do
        if HRP and HRP.Parent then
            HRP.Size = DefaultSize
            HRP.Transparency = 0
            HRP.Color = Color3.new(1, 1, 1)
            HRP.CanCollide = true
        end
    end
    table.clear(MacroConfig.OriginalSizes)
end

-- ⚔️ COMBAT MACRO
local function GetSelectedMoves()
    local Selected = {}
    for MoveName, Active in pairs(MacroConfig.MacroMoves) do
        if MoveName == "Weapon Attack" and not MacroConfig.UseWeaponsInCombo then
            continue
        end
        if Active then
            table.insert(Selected, {Name = MoveName, Input = MacroConfig.MoveBinds[MoveName]})
        end
    end
    return Selected
end

-- 🧍 HANDLE RESPAWN
player.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
    Humanoid = NewChar:WaitForChild("Humanoid")
    RootPart = NewChar:WaitForChild("HumanoidRootPart")
    ResetHitboxChanges()
end)

-- ⚙️ MACRO LOOPS
task.spawn(function()
    while MacroState.Running do
        if MacroConfig.CombatMacroEnabled and Character and Humanoid.Health > 0 and not MacroState.Busy then
            local Moves = GetSelectedMoves()
            for _, Move in pairs(Moves) do
                if not MacroConfig.CombatMacroEnabled then break end
                if Move.Input == "Click" then
                    ExecuteInput("Click")
                else
                    ExecuteInput("Key", Move.Input)
                end
                task.wait(MacroConfig.MacroSpeed)
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while MacroState.Running do
        if MacroConfig.HitboxEnabled and Character and Humanoid.Health > 0 then
            ApplyHitboxChanges()
        else
            ResetHitboxChanges()
        end
        task.wait(0.3)
    end
end)

-- 🖥️ MAIN GUI
function LoadMainGUI()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "⚡ BADDIES MACRO",
        LoadingTitle = "SYSTEM READY",
        LoadingSubtitle = "by Legitness",
        ConfigurationSaving = {Enabled = false},
        Discord = {Enabled = false},
        KeySystem = false
    })

    local MacroTab = Window:CreateTab("⚔️ Macro", 4483362458)
    local HitboxTab = Window:CreateTab("📦 Hitbox", 4483362458)
    local TargetTab = Window:CreateTab("🎯 Target", 4483362458)
    local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
    local CreditsTab = Window:CreateTab("📜 Credits", 4483362458)

    -- ⚔️ MACRO TAB
    MacroTab:CreateSection("COMBAT MACRO")

    MacroTab:CreateToggle({
        Name = "Enable Combat Macro",
        CurrentValue = false,
        Callback = function(Value)
