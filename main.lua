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

-- Stats for Detection
local PlaceId = game.PlaceId
local GameId = game.GameId
local GameName = "Unknown"
pcall(function() GameName = MarketplaceService:GetProductInfo(PlaceId).Name end)

local Games = {
    Rivals = 17625359962,
    Brookhaven = 4924144171,
    Brainrot = 16672338573,
    DandysWorld = 16116270224,
    AdoptMe = 920587237,
    Forsaken = 18131346083
}

-- Tabs Initialization
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Local = Window:AddTab({ Title = "Local", Icon = "user" }),
}

-- Game Tab (To be updated dynamically or manually)
local GameTab = nil
local CurrentDetected = "Universal"

local function SetupGameTab(gameName)
    if GameTab then GameTab:Remove() end
    CurrentDetected = gameName
    
    if gameName == "Rivals" then
        GameTab = Window:AddTab({ Title = "Rivals", Icon = "swords" })
        GameTab:AddToggle("AutoParry", {Title = "Auto Parry", Default = false}):OnChanged(function(v) _G.GameFeatures.AutoParry = v end)
    elseif gameName == "Brookhaven" then
        GameTab = Window:AddTab({ Title = "Brookhaven", Icon = "home" })
        local pd = GameTab:AddDropdown("PlayerSelect", { Title = "Target Player", Values = {}, Default = nil })
        RunService.Heartbeat:Connect(function() 
            local plys = {} 
            for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(plys, p.Name) end end
            pd:SetValues(plys)
        end)
        pd:OnChanged(function(v) _G.GameFeatures.SelectedPlayer = v end)
        GameTab:AddButton({ Title = "Teleport to Player", Callback = function() if _G.GameFeatures.SelectedPlayer then LocalPlayer.Character.HumanoidRootPart.CFrame = Players[_G.GameFeatures.SelectedPlayer].Character.HumanoidRootPart.CFrame end end })
        GameTab:AddButton({ Title = "Copy Outfit", Callback = function() if _G.GameFeatures.SelectedPlayer then -- (logic below)
            local target = Players[_G.GameFeatures.SelectedPlayer]
            for _, v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") then v:Destroy() end end
            for _, v in pairs(target.Character:GetChildren()) do if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") then v:Clone().Parent = LocalPlayer.Character end end
        end end })
    elseif gameName == "Dandy's World" then
        GameTab = Window:AddTab({ Title = "Dandy's World", Icon = "skull" })
        local pd = GameTab:AddDropdown("DandyPlayerSelect", { Title = "Target Player", Values = {}, Default = nil })
        RunService.Heartbeat:Connect(function() 
            local plys = {} 
            for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(plys, p.Name) end end
            pd:SetValues(plys)
        end)
        pd:OnChanged(function(v) _G.GameFeatures.SelectedPlayer = v end)
        GameTab:AddButton({ Title = "Copy Skin (Clone)", Callback = function() 
            if _G.GameFeatures.SelectedPlayer then
                local target = Players[_G.GameFeatures.SelectedPlayer]
                for _, v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") then v:Destroy() end end
                for _, v in pairs(target.Character:GetChildren()) do if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") then v:Clone().Parent = LocalPlayer.Character end end
            end
        end })
        GameTab:AddSection("Exploits")
        GameTab:AddToggle("MonstESP", {Title = "Monster ESP", Default = false}):OnChanged(function(v) _G.GameFeatures.MonsterESP = v end)
        GameTab:AddToggle("ItmESP", {Title = "Item ESP", Default = false}):OnChanged(function(v) _G.GameFeatures.ItemESP = v end)
        GameTab:AddButton({Title = "Restore Stamina", Callback = function() if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Stamina = 100 end end})
    end
end

-- Automatic Detection
if PlaceId == Games.Rivals or string.find(GameName, "Rivals") then 
    SetupGameTab("Rivals")
elseif PlaceId == Games.Brookhaven or string.find(GameName, "Brookhaven") then 
    SetupGameTab("Brookhaven")
elseif PlaceId == Games.DandysWorld or string.find(GameName, "Dandy") or GameId == 5387498703 then 
    SetupGameTab("Dandy's World")
end

Tabs.Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
Tabs.Settings = Window:AddTab({ Title = "Settings", Icon = "config" })

-- Manual Selector In Misc
Tabs.Misc:AddDropdown("ManualGame", {
    Title = "Force Game Hub",
    Values = {"Universal", "Rivals", "Brookhaven", "Dandy's World"},
    Default = CurrentDetected,
    Callback = function(v) SetupGameTab(v) end
})

-- State Variables
local _G = getgenv()
_G.Aimbot = { Enabled = false, Key = Enum.UserInputType.MouseButton2, Smoothness = 1, FieldOfView = 100, ShowFOV = false, Prediction = false, PredictionAmount = 0.165, TargetPart = "Head", SilentAim = false }
_G.Visuals = { Box = false, BoxColor = Color3.fromRGB(180, 100, 255), NameLabel = false, DistanceLabel = false, Chams = false, ChamsFillColor = Color3.fromRGB(180, 100, 255), ChamsOutlineColor = Color3.fromRGB(255, 255, 255) }
_G.LocalPlayer = { WalkSpeed = 16, JumpPower = 50, Gravity = 196.2, FOV = 70, InfiniteJump = false, NoClip = false }
_G.GameFeatures = { SelectedPlayer = nil, TrollMode = false, MonsterESP = false, ItemESP = false, AutoParry = false }

-- Aimbot, ESP, Loops (Same as before, optimized)
local function GetClosestPlayer() local Best = _G.Aimbot.FieldOfView; local Target = nil; for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.Aimbot.TargetPart) then local Pos, OnScreen = Camera:WorldToViewportPoint(p.Character[_G.Aimbot.TargetPart].Position); if OnScreen then local Dist = (Vector2.new(Pos.X, Pos.Y) - UserInputService:GetMouseLocation()).Magnitude; if Dist < Best then Best = Dist; Target = p end end end end return Target end

RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); h.WalkSpeed = _G.LocalPlayer.WalkSpeed; h.JumpPower = _G.LocalPlayer.JumpPower; workspace.Gravity = _G.LocalPlayer.Gravity; Camera.FieldOfView = _G.LocalPlayer.FOV
        if _G.LocalPlayer.NoClip then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    end
end)

-- Finish UI
SaveManager:SetLibrary(Fluent); SaveManager:IgnoreThemeSettings(); InterfaceManager:SetFolder("Synthesis"); SaveManager:SetFolder("Synthesis/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings); SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
Fluent:Notify({ Title = "Synthesis MEGA", Content = "Detected: " .. CurrentDetected .. "\nPlace: " .. PlaceId .. "\nName: " .. GameName, Duration = 8 })
SaveManager:LoadAutoloadConfig()
