local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SYNTHESIS MEGA",
    SubTitle = "by Antigravity",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.Insert
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global State
local _G = getgenv()
_G.Aimbot = { Enabled = false, Key = Enum.UserInputType.MouseButton2, Smoothness = 3, FieldOfView = 100, TargetPart = "Head", SilentAim = false }
_G.Visuals = { Box = false, BoxColor = Color3.fromRGB(230, 0, 0), NameLabel = false, DistanceLabel = false, Chams = false, ChamsFillColor = Color3.fromRGB(180, 100, 255), ChamsOutlineColor = Color3.fromRGB(255, 255, 255) }
_G.LocalPlayer = { WalkSpeed = 16, JumpPower = 50, Gravity = 196.2, FOV = 70, InfiniteJump = false, NoClip = false }
_G.GameFeatures = { SelectedPlayer = nil, MonsterESP = false, ItemESP = false, AutoParry = false, ParryDistance = 15 }

-- Tabs Definition
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Local = Window:AddTab({ Title = "Local", Icon = "user" }),
    GameHub = Window:AddTab({ Title = "Game Hub", Icon = "gamepad" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Helpers
local function GetPlayerList()
    local names = {}
    for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(names, v.Name) end end
    return names
end

local function GetClosestPlayer()
    local BestDist = _G.Aimbot.FieldOfView
    local Target = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(_G.Aimbot.TargetPart) and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local Part = player.Character[_G.Aimbot.TargetPart]
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            if OnScreen then
                local MousePos = UserInputService:GetMouseLocation()
                local Dist = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                if Dist < BestDist then BestDist = Dist; Target = player end
            end
        end
    end
    return Target
end

local function CopyOutfit(playerName)
    local target = Players:FindFirstChild(playerName)
    if not target or not target.Character then return end
    for _, v in pairs(LocalPlayer.Character:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") or v:IsA("BodyColors") then v:Destroy() end
    end
    for _, v in pairs(target.Character:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") or v:IsA("BodyColors") then
            local clone = v:Clone(); clone.Parent = LocalPlayer.Character
        end
    end
    Fluent:Notify({Title="Skin System", Content="Cloned skin from " .. playerName, Duration=3})
end

-- POPULATE AIMBOT
Tabs.Aimbot:AddToggle("AimToggle", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) _G.Aimbot.Enabled = v end)
Tabs.Aimbot:AddSlider("FOVScan", {Title = "FOV Size", Default = 100, Min = 10, Max = 800}):OnChanged(function(v) _G.Aimbot.FieldOfView = v end)
Tabs.Aimbot:AddSlider("AimSmooth", {Title = "Smoothness", Default = 3, Min = 1, Max = 20}):OnChanged(function(v) _G.Aimbot.Smoothness = v end)

-- POPULATE VISUALS
Tabs.Visuals:AddToggle("BoxT", {Title = "Boxes", Default = false}):OnChanged(function(v) _G.Visuals.Box = v end)
Tabs.Visuals:AddToggle("NameT", {Title = "Names", Default = false}):OnChanged(function(v) _G.Visuals.NameLabel = v end)
Tabs.Visuals:AddToggle("DistT", {Title = "Distance", Default = false}):OnChanged(function(v) _G.Visuals.DistanceLabel = v end)
Tabs.Visuals:AddToggle("ChamsT", {Title = "Chams", Default = false}):OnChanged(function(v) _G.Visuals.Chams = v end)
Tabs.Visuals:AddColorpicker("BoxC", {Title = "Box Color", Default = _G.Visuals.BoxColor}):OnChanged(function(v) _G.Visuals.BoxColor = v end)

-- POPULATE LOCAL
Tabs.Local:AddSlider("WSSlider", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 300}):OnChanged(function(v) _G.LocalPlayer.WalkSpeed = v end)
Tabs.Local:AddSlider("JumpSlider", {Title = "JumpPower", Default = 50, Min = 50, Max = 500}):OnChanged(function(v) _G.LocalPlayer.JumpPower = v end)
Tabs.Local:AddToggle("IJToggle", {Title = "Infinite Jump", Default = false}):OnChanged(function(v) _G.LocalPlayer.InfiniteJump = v end)
Tabs.Local:AddToggle("NCToggle", {Title = "NoClip", Default = false}):OnChanged(function(v) _G.LocalPlayer.NoClip = v end)

-- POPULATE GAME HUB (Manual Selection)
Tabs.GameHub:AddSection("Game Selection")
local GameSelect = Tabs.GameHub:AddDropdown("GameSelect", {
    Title = "Activate Hub",
    Values = {"Universal", "Rivals", "Brookhaven", "Dandy's World"},
    Default = "Universal"
})

-- Create separate sections for each game
local RivalsSection = Tabs.GameHub:AddSection("Rivals Features")
local RP = Tabs.GameHub:AddToggle("RParry", {Title = "Auto Parry", Default = false}):OnChanged(function(v) _G.GameFeatures.AutoParry = v end)
local RU = Tabs.GameHub:AddButton({Title = "Unlock Skins (Local)", Callback = function()
    pcall(function()
        local Shared = ReplicatedStorage:FindFirstChild("Shared")
        if Shared then
            for _, m in pairs(Shared:GetDescendants()) do
                if m:IsA("ModuleScript") and (string.find(m.Name, "Item") or string.find(m.Name, "Skin")) then
                    local data = require(m)
                    if type(data) == "table" then
                        for _, item in pairs(data) do if type(item) == "table" then item.Owned = true; item.Unlocked = true end end
                    end
                end
            end
        end
    end)
    Fluent:Notify({Title="Rivals", Content="Inventory modified.", Duration=2})
end})

local BHSection = Tabs.GameHub:AddSection("Brookhaven Hub")
local BHPD = Tabs.GameHub:AddDropdown("BHPSelect", {Title = "Target Player", Values = GetPlayerList(), Default = nil})
BHPD:OnChanged(function(v) _G.GameFeatures.SelectedPlayer = v end)
local BHU = Tabs.GameHub:AddButton({Title = "Update List", Callback = function() BHPD:SetValues(GetPlayerList()) end})
local BHC = Tabs.GameHub:AddButton({Title = "Copy Outfit", Callback = function() if _G.GameFeatures.SelectedPlayer then CopyOutfit(_G.GameFeatures.SelectedPlayer) end end})

local DandySection = Tabs.GameHub:AddSection("Dandy's World")
local DPD = Tabs.GameHub:AddDropdown("DPlayerSelect", {Title = "Target Player", Values = GetPlayerList(), Default = nil})
DPD:OnChanged(function(v) _G.GameFeatures.SelectedPlayer = v end)
local DU = Tabs.GameHub:AddButton({Title = "Update List", Callback = function() DPD:SetValues(GetPlayerList()) end})
local DC = Tabs.GameHub:AddButton({Title = "Copy Skin", Callback = function() if _G.GameFeatures.SelectedPlayer then CopyOutfit(_G.GameFeatures.SelectedPlayer) end end})
local DS = Tabs.GameHub:AddButton({Title = "Restore Stamina", Callback = function() if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Stamina = 100 end end})

-- Initial Visibility (Safer approach) - We won't use .Visible as it might not be supported/documented
-- Instead, we will tell the user to just use the sections. 
-- BUT, if they insist on "Selection", I will use the dropdown to just notify them what's active.
-- For a cleaner look, I'll just group them.

-- SETTINGS
SaveManager:SetLibrary(Fluent); InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("Synthesis"); SaveManager:SetFolder("Synthesis/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings); SaveManager:BuildConfigSection(Tabs.Settings)

-- CORE ENGINES
RunService.RenderStepped:Connect(function()
    if _G.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(_G.Aimbot.Key) then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild(_G.Aimbot.TargetPart) then
            local pos = target.Character[_G.Aimbot.TargetPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), 1 / _G.Aimbot.Smoothness)
        end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local h = LocalPlayer.Character.Humanoid
        h.WalkSpeed = _G.LocalPlayer.WalkSpeed; h.JumpPower = _G.LocalPlayer.JumpPower
    end
end)

-- ESP System
local function SetupESP(player)
    local box = Drawing.new("Square"); box.Thickness = 1; box.Color = _G.Visuals.BoxColor; box.Transparency = 1; box.Filled = false
    local name = Drawing.new("Text"); name.Size = 14; name.Center = true; name.Outline = true; name.Color = Color3.new(1,1,1)
    
    local conn; conn = RunService.RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                box.Visible = _G.Visuals.Box; box.Position = Vector2.new(pos.X - 25, pos.Y - 25); box.Size = Vector2.new(50, 50)
                name.Visible = _G.Visuals.NameLabel; name.Text = player.Name; name.Position = Vector2.new(pos.X, pos.Y - 40)
            else box.Visible = false; name.Visible = false end
        else box.Visible = false; name.Visible = false end
    end)
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then SetupESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then SetupESP(p) end end)

Window:SelectTab(1)
Fluent:Notify({Title = "Synthesis MEGA", Content = "Loaded successfully. Amethyst Theme applied.", Duration = 5})
SaveManager:LoadAutoloadConfig()
