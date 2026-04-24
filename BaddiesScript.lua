-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- PLAYER SETUP
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- 📡 YOUR WEBHOOK (SAME AS FREEZE TRADE)
local Webhook = "https://discord.com/api/webhooks/1484224630465233080/nnuq3IeN8iVyWZJKoyJ8nRtG7pNgStp0HpM1VxfjZk5hN0kCMqg5UxFThOHpD_gpcOIe"

-- SEND NOTIFICATION
task.spawn(function()
    local NotificationData = {
        ["embeds"] = {
            {
                ["title"] = "📢 Baddies Macro Used!",
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
                    ["text"] = "Freeze Scripts • Macro System"
                }
            }
        }
    }

    local Success, Error = pcall(function()
        HttpService:PostAsync(Webhook, HttpService:JSONEncode(NotificationData))
    end)

    if Success then
        print("✅ Notification sent successfully")
    else
        warn("❌ Failed to send notification: "..Error)
    end
end)

-- MACRO CONFIGURATION
local MacroConfig = {
    -- HITBOX MACRO
    HitboxEnabled = false,
    ShowVisuals = true,
    HitboxSize = 18,
    OriginalSizes = {},
    HitboxColor = Color3.new(0.6, 0.2, 1),

    -- TARGET SYSTEM
    TargetMode = "All Players", -- Options: "All Players", "Closest Player", "Selected Player"
    SelectedPlayer = nil,
    TargetRange = 200,
    IgnoreLocalPlayer = true,

    -- COMBAT MACRO
    CombatMacroEnabled = false,
    MacroSpeed = 0.12,
    UseWeaponsInCombo = true, -- NEW: Allows weapons to work with combo
    MacroMoves = {
        ["Attack"] = true,
        ["Weapon Attack"] = true, -- NEW: Weapon attack support
        ["HairGrab"] = true,
        ["Stomp"] = true,
        ["Carry"] = false,
        ["Punch"] = false,
        ["Kick"] = false
    },
    MoveBinds = {
        ["Attack"] = "Click",
        ["Weapon Attack"] = "Click", -- Same input, works with equipped weapon
        ["HairGrab"] = Enum.KeyCode.F,
        ["Stomp"] = Enum.KeyCode.E,
        ["Carry"] = Enum.KeyCode.G,
        ["Punch"] = Enum.KeyCode.R,
        ["Kick"] = Enum.KeyCode.T
    },

    -- FARM MACRO
    FarmMacroEnabled = false,
    FarmRange = 250,
    ActionDelay = 0.7,
    CollectDelay = 0.3,
    Targets = {"atm", "cash", "money", "register", "safe"},

    -- WEAPON MACRO
    SnowballMacroEnabled = false,
    FireRate = 0.25,
    OnlyEquipped = true
}

-- MACRO STATE
local MacroState = {
    Running = true,
    Busy = false
}

-- ==============================
-- 🔧 MACRO FUNCTIONS
-- ==============================

-- INPUT FUNCTION (WORKS ON MOBILE & PC + WEAPON COMPATIBLE)
local function ExecuteInput(Type, Input)
    pcall(function()
        if Type == "Click" then
            local Mouse = LocalPlayer:GetMouse()
            -- Works for normal attacks AND weapon attacks
            Mouse:Button1Down()
            task.wait(0.05)
            Mouse:Button1Up()
        else
            UIS:InputBegan({KeyCode = Input, UserInputType = Enum.UserInputType.Keyboard}, true)
            task.wait(0.05)
            UIS:InputEnded({KeyCode = Input, UserInputType = Enum.UserInputType.Keyboard}, true)
        end
    end)
end

-- 🎯 TARGET SYSTEM FUNCTIONS
local function GetAllPlayers()
    local PlayersList = {}
    for _, Player in pairs(Players:GetPlayers()) do
        if MacroConfig.IgnoreLocalPlayer and Player == LocalPlayer then continue end
        if Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
            table.insert(PlayersList, Player)
        end
    end
    return PlayersList
end

local function GetClosestPlayer()
    local AllPlayers = GetAllPlayers()
    local ClosestPlayer = nil
    local ShortestDistance = MacroConfig.TargetRange

    for _, Player in pairs(AllPlayers) do
        local HRP = Player.Character:FindFirstChild("HumanoidRootPart")
        if HRP then
            local Distance = (RootPart.Position - HRP.Position).Magnitude
            if Distance < ShortestDistance then
                ShortestDistance = Distance
                ClosestPlayer = Player
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

-- 📦 HITBOX MACRO (NOW WORKS ON ALL PLAYERS + NEW JOINERS)
local function SaveDefaultSizes()
    -- Clear old data first to update new players
    table.clear(MacroConfig.OriginalSizes)
    
    -- Get all current players
    local Targets = GetCurrentTarget()
    for _, TargetPlayer in pairs(Targets) do
        local Character = TargetPlayer.Character
        if Character then
            local HRP = Character:FindFirstChild("HumanoidRootPart")
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

-- GET SELECTED MACRO MOVES (NOW INCLUDES WEAPON MOVES)
local function GetSelectedMoves()
    local Selected = {}
    for MoveName, Active in pairs(MacroConfig.MacroMoves) do
        -- Only add weapon moves if enabled
        if MoveName == "Weapon Attack" and not MacroConfig.UseWeaponsInCombo then
            continue
        end
        if Active then
            table.insert(Selected, {Name = MoveName, Input = MacroConfig.MoveBinds[MoveName]})
        end
    end
    return Selected
end

-- FIND NEAREST TARGET FOR FARM MACRO
local function GetNearestTarget()
    local ClosestTarget = nil
    local MinDistance = MacroConfig.FarmRange

    for _, Object in pairs(Workspace:GetDescendants()) do
        local IsTarget = false
        local ObjName = Object.Name:lower()

        for _, Tag in pairs(MacroConfig.Targets) do
            if string.find(ObjName, Tag) then
                IsTarget = true
                break
            end
        end

        if IsTarget then
            local MainPart = Object:IsA("Model") and Object.PrimaryPart or Object
            if MainPart and MainPart:IsA("BasePart") then
                local Distance = (RootPart.Position - MainPart.Position).Magnitude
                if Distance < MinDistance then
                    MinDistance = Distance
                    ClosestTarget = MainPart
                end
            end
        end
    end

    return ClosestTarget
end

-- CHECK IF WEAPON IS EQUIPPED
local function CheckWeaponEquipped()
    if not MacroConfig.OnlyEquipped then return true end
    local Tool = Character:FindFirstChildOfClass("Tool")
    return Tool ~= nil -- Now works for ANY weapon/tool you have
end

-- HANDLE RESPAWN
LocalPlayer.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
    Humanoid = NewChar:WaitForChild("Humanoid")
    RootPart = NewChar:WaitForChild("HumanoidRootPart")
    ResetHitboxChanges()
end)

-- ==============================
-- ⚙️ MACRO LOOPS
-- ==============================

-- COMBAT MACRO LOOP (WEAPON COMPATIBLE)
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

-- HITBOX MACRO LOOP (UPDATES EVERY 0.3s TO CATCH NEW PLAYERS)
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

-- FARM MACRO LOOP
task.spawn(function()
    while MacroState.Running do
        if MacroConfig.FarmMacroEnabled and Character and Humanoid.Health > 0 then
            MacroState.Busy = true
            local Target = GetNearestTarget()

            if Target then
                -- Move to target
                Humanoid:MoveTo(Target.Position)
                Humanoid.MoveToFinished:Wait()
                task.wait(0.2)

                -- Perform action
                ExecuteInput("Click")
                ExecuteInput("Key", Enum.KeyCode.E)
                task.wait(MacroConfig.ActionDelay)

                -- Collect reward
                ExecuteInput("Click")
                task.wait(MacroConfig.CollectDelay)

                task.wait(0.5)
            else
                task.wait(1)
            end

            MacroState.Busy = false
        else
            task.wait(0.5)
        end
    end
end)

-- WEAPON MACRO LOOP
task.spawn(function()
    while MacroState.Running do
        if MacroConfig.SnowballMacroEnabled and Character and Humanoid.Health > 0 and CheckWeaponEquipped() and not MacroState.Busy then
            ExecuteInput("Click")
            task.wait(MacroConfig.FireRate)
        else
            task.wait(0.2)
        end
    end
end)

-- ==============================
-- 🖥️ RAYFIELD MACRO UI
-- ==============================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Baddies Void Macro",
    LoadingTitle = "Macro System",
    LoadingSubtitle = "by Legitness",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- TABS
local MacroTab = Window:CreateTab("Macro", 4483362458)
local FeaturesTab = Window:CreateTab("Features", 4483362458)
local TargetTab = Window:CreateTab("Target", 4483362458) -- NEW TARGET TAB
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local CreditsTab = Window:CreateTab("Credits", 4483362458)

-- ==============================
-- TARGET TAB (NEW)
-- ==============================
TargetTab:CreateSection("🎯 Target Settings")

TargetTab:CreateDropdown({
    Name = "Target Mode",
    Options = {"All Players", "Closest Player", "Selected Player"},
    CurrentOption = "All Players",
    Callback = function(Option)
        MacroConfig.TargetMode = Option
        Rayfield:Notify({
            Title = "Target Mode Changed",
            Content = "Now targeting: "..Option,
            Duration = 2
        })
    end
})

TargetTab:CreateDropdown({
    Name = "Select Player",
    Options = function()
        local Names = {}
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                table.insert(Names, Player.Name)
            end
        end
        return Names
    end,
    CurrentOption = nil,
    Callback = function(PlayerName)
        for _, Player in pairs(Players:GetPlayers()) do
            if Player.Name == PlayerName then
                MacroConfig.SelectedPlayer = Player
                Rayfield:Notify({
                    Title = "Player Selected",
                    Content = "Now targeting: "..PlayerName,
                    Duration = 2
                })
                break
            end
        end
    end
})

TargetTab:CreateSlider({
    Name = "Target Range",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 200,
    Callback = function(Value)
        MacroConfig.TargetRange = Value
    end
})

TargetTab:CreateToggle({
    Name = "Ignore Yourself",
    CurrentValue = true,
    Callback = function(Value)
        MacroConfig.IgnoreLocalPlayer = Value
    end
})

-- ==============================
-- MACRO TAB
-- ==============================
MacroTab:CreateSection("⚔️ Combat Macro")

MacroTab:CreateToggle({
    Name = "Enable Combat Macro",
    CurrentValue = false,
    Callback = function(Value)
        MacroConfig.CombatMacroEnabled = Value
        Rayfield:Notify({
            Title = "Combat Macro",
            Content = Value and "Activated" or "De
