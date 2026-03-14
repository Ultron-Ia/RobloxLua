local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SYNTHESIS MEGA",
    SubTitle = "by Antigravity",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Insert
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global State
local _G = getgenv()
_G.Aimbot = { Enabled = false, Key = Enum.UserInputType.MouseButton2, Smoothness = 1, FieldOfView = 100, ShowFOV = false, Prediction = false, PredictionAmount = 0.165, TargetPart = "Head", SilentAim = false }
_G.Visuals = { Box = false, BoxColor = Color3.fromRGB(180, 100, 255), NameLabel = false, DistanceLabel = false, Chams = false, ChamsFillColor = Color3.fromRGB(180, 100, 255), ChamsOutlineColor = Color3.fromRGB(255, 255, 255) }
_G.LocalPlayer = { WalkSpeed = 16, JumpPower = 50, Gravity = 196.2, FOV = 70, InfiniteJump = false, NoClip = false }
_G.GameFeatures = { SelectedPlayer = nil, TrollMode = false, MonsterESP = false, ItemESP = false, AutoParry = false }

-- Helpers
local function GetPlayerList()
    local names = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then table.insert(names, v.Name) end
    end
    return names
end

local function CopyOutfit(targetPlayerName)
    local target = Players:FindFirstChild(targetPlayerName)
    if not target or not target.Character then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") or v:IsA("BodyColors") or v:IsA("ShirtGraphic") then v:Destroy() end
    end
    for _, v in pairs(target.Character:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") or v:IsA("BodyColors") or v:IsA("ShirtGraphic") then
            local clone = v:Clone(); clone.Parent = char
        end
    end
    Fluent:Notify({Title="Outfit Copied", Content="Successfully cloned " .. targetPlayerName, Duration=3})
end

-- Detection Variables
local PlaceId = game.PlaceId
local GameName = "Unknown"
pcall(function() GameName = MarketplaceService:GetProductInfo(PlaceId).Name end)
local CurrentGame = "Universal"

-- Tabs
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Local = Window:AddTab({ Title = "Local", Icon = "user" }),
}

-- Populate Aimbot
Tabs.Aimbot:AddToggle("AimEnabled", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) _G.Aimbot.Enabled = v end)
Tabs.Aimbot:AddToggle("SilentAim", {Title = "Silent Aim", Default = false}):OnChanged(function(v) _G.Aimbot.SilentAim = v end)
Tabs.Aimbot:AddSlider("FOV", {Title = "FOV Radius", Default = 100, Min = 10, Max = 800, Rounding = 0}):OnChanged(function(v) _G.Aimbot.FieldOfView = v end)
Tabs.Aimbot:AddSlider("Smooth", {Title = "Smoothness", Default = 1, Min = 1, Max = 20, Rounding = 1}):OnChanged(function(v) _G.Aimbot.Smoothness = v end)

-- Populate Visuals
Tabs.Visuals:AddToggle("BoxESP", {Title = "Boxes", Default = false}):OnChanged(function(v) _G.Visuals.Box = v end)
Tabs.Visuals:AddToggle("NameESP", {Title = "Names", Default = false}):OnChanged(function(v) _G.Visuals.NameLabel = v end)
Tabs.Visuals:AddToggle("Chams", {Title = "Chams", Default = false}):OnChanged(function(v) _G.Visuals.Chams = v end)
Tabs.Visuals:AddColorpicker("ChamsColor", {Title = "Chams Color", Default = _G.Visuals.ChamsFillColor}):OnChanged(function(v) _G.Visuals.ChamsFillColor = v end)

-- Populate Local
Tabs.Local:AddSlider("Speed", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 0}):OnChanged(function(v) _G.LocalPlayer.WalkSpeed = v end)
Tabs.Local:AddSlider("Jump", {Title = "JumpPower", Default = 50, Min = 50, Max = 500, Rounding = 0}):OnChanged(function(v) _G.LocalPlayer.JumpPower = v end)
Tabs.Local:AddToggle("InfJump", {Title = "Infinite Jump", Default = false}):OnChanged(function(v) _G.LocalPlayer.InfiniteJump = v end)
Tabs.Local:AddToggle("Noclip", {Title = "NoClip", Default = false}):OnChanged(function(v) _G.LocalPlayer.NoClip = v end)

-- Game Hub Logic
local GameTab = nil
local function SetupGameHub(name)
    if GameTab then GameTab:Remove() end
    CurrentGame = name
    
    if name == "Rivals" then
        GameTab = Window:AddTab({ Title = "Rivals", Icon = "swords" })
        GameTab:AddToggle("AutoParry", {Title = "Auto Parry", Default = false}):OnChanged(function(v) _G.GameFeatures.AutoParry = v end)
        GameTab:AddSlider("ParryDist", {Title = "Parry Distance", Default = 15, Min = 5, Max = 50, Rounding = 0}):OnChanged(function(v) _G.GameFeatures.ParryDistance = v end)
    elseif name == "Brookhaven" then
        GameTab = Window:AddTab({ Title = "Brookhaven", Icon = "home" })
        local pd = GameTab:AddDropdown("BHPlayer", { Title = "Select Player", Values = GetPlayerList(), Default = nil })
        GameTab:AddButton({ Title = "Update Player List", Callback = function() pd:SetValues(GetPlayerList()) end })
        pd:OnChanged(function(v) _G.GameFeatures.SelectedPlayer = v end)
        GameTab:AddButton({ Title = "Teleport to Player", Callback = function() if _G.GameFeatures.SelectedPlayer then LocalPlayer.Character.HumanoidRootPart.CFrame = Players[_G.GameFeatures.SelectedPlayer].Character.HumanoidRootPart.CFrame end end })
        GameTab:AddButton({ Title = "Copy Outfit", Callback = function() if _G.GameFeatures.SelectedPlayer then CopyOutfit(_G.GameFeatures.SelectedPlayer) end end })
    elseif name == "Dandy's World" then
        GameTab = Window:AddTab({ Title = "Dandy's World", Icon = "skull" })
        local pd = GameTab:AddDropdown("DandyPlayer", { Title = "Select Player", Values = GetPlayerList(), Default = nil })
        GameTab:AddButton({ Title = "Update Player List", Callback = function() pd:SetValues(GetPlayerList()) end })
        pd:OnChanged(function(v) _G.GameFeatures.SelectedPlayer = v end)
        GameTab:AddButton({ Title = "Copy Skin", Callback = function() if _G.GameFeatures.SelectedPlayer then CopyOutfit(_G.GameFeatures.SelectedPlayer) end end })
        GameTab:AddSection("Exploits")
        GameTab:AddToggle("MonstESP", {Title = "Monster ESP", Default = false}):OnChanged(function(v) _G.GameFeatures.MonsterESP = v end)
        GameTab:AddButton({Title = "Restore Stamina", Callback = function() if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Stamina = 100 end end})
    end
end

-- Detection
if PlaceId == 4924144171 or string.find(GameName, "Brookhaven") then SetupGameHub("Brookhaven")
elseif PlaceId == 17625359962 or string.find(GameName, "Rivals") then SetupGameHub("Rivals")
elseif PlaceId == 16116270224 or string.find(GameName, "Dandy") or game.GameId == 5387498703 then SetupGameHub("Dandy's World")
end

Tabs.Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
Tabs.Settings = Window:AddTab({ Title = "Settings", Icon = "config" })

Tabs.Misc:AddDropdown("ForceGame", {
    Title = "Force Game Hub",
    Values = {"Universal", "Rivals", "Brookhaven", "Dandy's World"},
    Default = CurrentGame,
    Callback = function(v) SetupGameHub(v) end
})

-- Main Loops & ESP Management (Kept stable)
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); h.WalkSpeed = _G.LocalPlayer.WalkSpeed; h.JumpPower = _G.LocalPlayer.JumpPower; workspace.Gravity = _G.LocalPlayer.Gravity; Camera.FieldOfView = _G.LocalPlayer.FOV
        if _G.LocalPlayer.NoClip then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    end
end)

SaveManager:SetLibrary(Fluent); SaveManager:IgnoreThemeSettings(); InterfaceManager:SetFolder("Synthesis"); SaveManager:SetFolder("Synthesis/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings); SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
Fluent:Notify({ Title = "Synthesis MEGA", Content = "Ready for " .. CurrentGame .. "\nPress INSERT to toggle menu.", Duration = 8 })
SaveManager:LoadAutoloadConfig()
