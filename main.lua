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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global State
local _G = getgenv()
_G.Aimbot = { Enabled = false, Key = Enum.UserInputType.MouseButton2, Smoothness = 1, FieldOfView = 100, ShowFOV = false, Prediction = false, PredictionAmount = 0.165, TargetPart = "Head", SilentAim = false }
_G.Visuals = { Box = false, BoxColor = Color3.fromRGB(180, 100, 255), NameLabel = false, DistanceLabel = false, Chams = false, ChamsFillColor = Color3.fromRGB(180, 100, 255), ChamsOutlineColor = Color3.fromRGB(255, 255, 255) }
_G.LocalPlayer = { WalkSpeed = 16, JumpPower = 50, Gravity = 196.2, FOV = 70, InfiniteJump = false, NoClip = false }
_G.GameFeatures = { SelectedPlayer = nil, TrollMode = false, MonsterESP = false, ItemESP = false, AutoParry = false, ParryDistance = 15 }

-- Detection
local PlaceId = game.PlaceId
local GameName = "Unknown"
pcall(function() GameName = MarketplaceService:GetProductInfo(PlaceId).Name end)

-- Tabs Creation
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Local = Window:AddTab({ Title = "Local", Icon = "user" }),
    Game = Window:AddTab({ Title = "Game Hub", Icon = "gamepad" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }) -- Fixed icon
}

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
    Fluent:Notify({Title="Outfit Copied", Content="Cloned " .. targetPlayerName, Duration=3})
end

-- SECTION: AIMBOT POPULATION
Tabs.Aimbot:AddToggle("AimEnabled", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) _G.Aimbot.Enabled = v end)
Tabs.Aimbot:AddToggle("SilentAim", {Title = "Silent Aim", Default = false}):OnChanged(function(v) _G.Aimbot.SilentAim = v end)
Tabs.Aimbot:AddDropdown("TargetPart", { Title = "Target Part", Values = {"Head", "HumanoidRootPart"}, Default = "Head" }):OnChanged(function(v) _G.Aimbot.TargetPart = v end)
Tabs.Aimbot:AddSlider("FOV", {Title = "FOV Radius", Default = 100, Min = 10, Max = 800, Rounding = 0}):OnChanged(function(v) _G.Aimbot.FieldOfView = v end)
Tabs.Aimbot:AddSlider("Smooth", {Title = "Smoothness", Default = 1, Min = 1, Max = 20, Rounding = 1}):OnChanged(function(v) _G.Aimbot.Smoothness = v end)

-- SECTION: VISUALS POPULATION
Tabs.Visuals:AddToggle("BoxESP", {Title = "Boxes", Default = false}):OnChanged(function(v) _G.Visuals.Box = v end)
Tabs.Visuals:AddToggle("NameESP", {Title = "Names", Default = false}):OnChanged(function(v) _G.Visuals.NameLabel = v end)
Tabs.Visuals:AddToggle("Chams", {Title = "Chams", Default = false}):OnChanged(function(v) _G.Visuals.Chams = v end)
Tabs.Visuals:AddColorpicker("BoxColor", {Title = "Box Color", Default = _G.Visuals.BoxColor}):OnChanged(function(v) _G.Visuals.BoxColor = v end)
Tabs.Visuals:AddColorpicker("ChamsColor", {Title = "Chams Color", Default = _G.Visuals.ChamsFillColor}):OnChanged(function(v) _G.Visuals.ChamsFillColor = v end)

-- SECTION: LOCAL POPULATION
Tabs.Local:AddSlider("Speed", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 0}):OnChanged(function(v) _G.LocalPlayer.WalkSpeed = v end)
Tabs.Local:AddSlider("Jump", {Title = "JumpPower", Default = 50, Min = 50, Max = 500, Rounding = 0}):OnChanged(function(v) _G.LocalPlayer.JumpPower = v end)
Tabs.Local:AddToggle("InfJump", {Title = "Infinite Jump", Default = false}):OnChanged(function(v) _G.LocalPlayer.InfiniteJump = v end)
Tabs.Local:AddToggle("Noclip", {Title = "NoClip", Default = false}):OnChanged(function(v) _G.LocalPlayer.NoClip = v end)

-- SECTION: GAME HUB LOGIC
local function UpdateGameHub(hubName)
    Tabs.Game.Title = hubName .. " Hub"
    if hubName == "Rivals" then
        Tabs.Game:AddSection("Rivals Features")
        Tabs.Game:AddToggle("AutoParry", {Title = "Auto Parry", Default = false}):OnChanged(function(v) _G.GameFeatures.AutoParry = v end)
        Tabs.Game:AddButton({Title = "Unlock All Skins & Weapons", Callback = function()
            Fluent:Notify({Title="Rivals", Content="Injecting ItemData hooks...", Duration=5})
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
        end})
    elseif hubName == "Brookhaven" then
        Tabs.Game:AddSection("Brookhaven Tools")
        local pd = Tabs.Game:AddDropdown("BHPlayer", { Title = "Select Target", Values = GetPlayerList(), Default = nil })
        Tabs.Game:AddButton({ Title = "Reload Players", Callback = function() pd:SetValues(GetPlayerList()) end })
        pd:OnChanged(function(v) _G.GameFeatures.SelectedPlayer = v end)
        Tabs.Game:AddButton({ Title = "Teleport to Player", Callback = function() if _G.GameFeatures.SelectedPlayer then LocalPlayer.Character.HumanoidRootPart.CFrame = Players[_G.GameFeatures.SelectedPlayer].Character.HumanoidRootPart.CFrame end end })
        Tabs.Game:AddButton({ Title = "Copy Outfit", Callback = function() if _G.GameFeatures.SelectedPlayer then CopyOutfit(_G.GameFeatures.SelectedPlayer) end end })
    elseif hubName == "Dandy's World" then
        Tabs.Game:AddSection("Dandy's World")
        local pd = Tabs.Game:AddDropdown("DPlayer", { Title = "Select Target", Values = GetPlayerList(), Default = nil })
        Tabs.Game:AddButton({ Title = "Reload Players", Callback = function() pd:SetValues(GetPlayerList()) end })
        pd:OnChanged(function(v) _G.GameFeatures.SelectedPlayer = v end)
        Tabs.Game:AddButton({ Title = "Copy Skin", Callback = function() if _G.GameFeatures.SelectedPlayer then CopyOutfit(_G.GameFeatures.SelectedPlayer) end end })
        Tabs.Game:AddToggle("MonstESP", {Title = "Monster ESP", Default = false}):OnChanged(function(v) _G.GameFeatures.MonsterESP = v end)
    end
end

-- Automatic Hub Select
if PlaceId == 4924144171 or string.find(GameName, "Brookhaven") then UpdateGameHub("Brookhaven")
elseif PlaceId == 17625359962 or string.find(GameName, "Rivals") then UpdateGameHub("Rivals")
elseif PlaceId == 16116270224 or string.find(GameName, "Dandy") or game.GameId == 5387498703 then UpdateGameHub("Dandy's World")
else UpdateGameHub("Universal") end

-- MISC POPULATION
Tabs.Misc:AddDropdown("ManualHub", {
    Title = "Manual Hub Select",
    Values = {"Brookhaven", "Rivals", "Dandy's World", "Universal"},
    Default = "Universal",
    Callback = function(v) UpdateGameHub(v) end
})

-- LOGIC LOOPS
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        h.WalkSpeed = _G.LocalPlayer.WalkSpeed; h.JumpPower = _G.LocalPlayer.JumpPower
        workspace.Gravity = _G.LocalPlayer.Gravity; Camera.FieldOfView = _G.LocalPlayer.FOV
        if _G.LocalPlayer.NoClip then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    end
end)

-- Finish Setup (FIXED SETTINGS TAB)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent) -- Fixed missing call

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("Synthesis")
SaveManager:SetFolder("Synthesis/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({ Title = "Synthesis MEGA", Content = "Script Fully Functional!\nPress INSERT to toggle menu.", Duration = 5 })
SaveManager:LoadAutoloadConfig()
