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

-- Tabs
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Local = Window:AddTab({ Title = "Local", Icon = "user" }),
    Game = Window:AddTab({ Title = "Game Hub", Icon = "gamepad" }),
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
    Fluent:Notify({Title="Skin Copied", Content="Successfully cloned " .. targetPlayerName, Duration=3})
end

-- ESP Core Logic
local function CreateESP(player)
    local Box = Drawing.new("Square"); Box.Visible = false; Box.Thickness = 1; Box.Color = _G.Visuals.BoxColor; Box.Filled = false
    local Name = Drawing.new("Text"); Name.Visible = false; Name.Size = 14; Name.Center = true; Name.Outline = true; Name.Color = Color3.new(1,1,1)
    local DistTxt = Drawing.new("Text"); DistTxt.Visible = false; DistTxt.Size = 13; DistTxt.Center = true; DistTxt.Outline = true; DistTxt.Color = Color3.new(0.8,0.8,0.8)

    local Updater = RunService.RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local Root = player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            if OnScreen then
                local Size = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local BoxSize = Vector2.new(Size * 1.5, Size)
                local BoxPos = Vector2.new(Pos.X - BoxSize.X / 2, Pos.Y - BoxSize.Y / 2)
                
                Box.Visible = _G.Visuals.Box; Box.Size = BoxSize; Box.Position = BoxPos; Box.Color = _G.Visuals.BoxColor
                Name.Visible = _G.Visuals.NameLabel; Name.Text = player.Name; Name.Position = Vector2.new(Pos.X, BoxPos.Y - 16)
                DistTxt.Visible = _G.Visuals.DistanceLabel; DistTxt.Text = "[" .. math.floor((LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude) .. "m]"; DistTxt.Position = Vector2.new(Pos.X, BoxPos.Y + BoxSize.Y + 2)
                
                local Highlight = player.Character:FindFirstChild("SynthesisHighlight")
                if _G.Visuals.Chams then
                    if not Highlight then Highlight = Instance.new("Highlight"); Highlight.Name = "SynthesisHighlight"; Highlight.Parent = player.Character end
                    Highlight.FillColor = _G.Visuals.ChamsFillColor; Highlight.OutlineColor = _G.Visuals.ChamsOutlineColor; Highlight.Enabled = true
                elseif Highlight then Highlight.Enabled = false end
            else Box.Visible = false; Name.Visible = false; DistTxt.Visible = false; if player.Character:FindFirstChild("SynthesisHighlight") then player.Character.SynthesisHighlight.Enabled = false end end
        else Box.Visible = false; Name.Visible = false; DistTxt.Visible = false; if player and player.Character and player.Character:FindFirstChild("SynthesisHighlight") then player.Character.SynthesisHighlight.Enabled = false end end
    end)
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)

-- UI POPULATION (Aimbot, Visuals, Local)
Tabs.Aimbot:AddToggle("AimToggle", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) _G.Aimbot.Enabled = v end)
Tabs.Aimbot:AddSlider("FOV", {Title = "FOV Radius", Default = 100, Min = 10, Max = 800}):OnChanged(function(v) _G.Aimbot.FieldOfView = v end)
Tabs.Aimbot:AddSlider("Smooth", {Title = "Smoothness", Default = 3, Min = 1, Max = 20}):OnChanged(function(v) _G.Aimbot.Smoothness = v end)

Tabs.Visuals:AddToggle("BoxT", {Title = "Boxes", Default = false}):OnChanged(function(v) _G.Visuals.Box = v end)
Tabs.Visuals:AddToggle("NameT", {Title = "Names", Default = false}):OnChanged(function(v) _G.Visuals.NameLabel = v end)
Tabs.Visuals:AddToggle("DistT", {Title = "Distance", Default = false}):OnChanged(function(v) _G.Visuals.DistanceLabel = v end)
Tabs.Visuals:AddToggle("ChamsT", {Title = "Chams", Default = false}):OnChanged(function(v) _G.Visuals.Chams = v end)
Tabs.Visuals:AddColorpicker("BoxC", {Title = "Box Color", Default = _G.Visuals.BoxColor}):OnChanged(function(v) _G.Visuals.BoxColor = v end)

Tabs.Local:AddSlider("WS", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 300}):OnChanged(function(v) _G.LocalPlayer.WalkSpeed = v end)
Tabs.Local:AddToggle("IJ", {Title = "Infinite Jump", Default = false}):OnChanged(function(v) _G.LocalPlayer.InfiniteJump = v end)

-- GAME HUB: MANUAL SELECTION LOGIC
local GameSections = {}
local function ClearGameHub()
    for _, s in pairs(GameSections) do s:Destroy() end -- Assuming Fluent elements can be destroyed or we just add to them
    GameSections = {}
end

Tabs.Game:AddSection("Select Your Game")
local GameSelector = Tabs.Game:AddDropdown("ManualGameSelector", {
    Title = "Active Game Features",
    Values = {"Universal", "Rivals", "Brookhaven", "Dandy's World"},
    Default = "Universal"
})

-- Rivals Section
local RivalsSec = Tabs.Game:AddSection("Rivals Features")
local RivalsParry = Tabs.Game:AddToggle("RivalsParry", {Title = "Auto Parry", Default = false})
RivalsParry:OnChanged(function(v) _G.GameFeatures.AutoParry = v end)
local RivalsUnlock = Tabs.Game:AddButton({Title = "Unlock All Skins & Weapons", Callback = function()
    Fluent:Notify({Title="Rivals", Content="Unlocking skins... (Local Only)", Duration=3})
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

-- Brookhaven Section
local BHSec = Tabs.Game:AddSection("Brookhaven Hub")
local BHDrop = Tabs.Game:AddDropdown("BHPlayerSelect", {Title = "Target Player", Values = GetPlayerList(), Default = nil})
BHDrop:OnChanged(function(v) _G.GameFeatures.SelectedPlayer = v end)
local BHUpdate = Tabs.Game:AddButton({Title = "Update Player List", Callback = function() BHDrop:SetValues(GetPlayerList()) end})
local BHCopy = Tabs.Game:AddButton({Title = "Copy Outfit", Callback = function() if _G.GameFeatures.SelectedPlayer then CopyOutfit(_G.GameFeatures.SelectedPlayer) end end})
local BHTP = Tabs.Game:AddButton({Title = "Teleport to Player", Callback = function() if _G.GameFeatures.SelectedPlayer then LocalPlayer.Character.HumanoidRootPart.CFrame = Players[_G.GameFeatures.SelectedPlayer].Character.HumanoidRootPart.CFrame end end})

-- Dandy's World Section
local DandySec = Tabs.Game:AddSection("Dandy's World")
local DandyDrop = Tabs.Game:AddDropdown("DandyPlayerSelect", {Title = "Target Player", Values = GetPlayerList(), Default = nil})
DandyDrop:OnChanged(function(v) _G.GameFeatures.SelectedPlayer = v end)
local DandyUpdate = Tabs.Game:AddButton({Title = "Update Player List", Callback = function() DandyDrop:SetValues(GetPlayerList()) end})
local DandyCopy = Tabs.Game:AddButton({Title = "Copy Skin", Callback = function() if _G.GameFeatures.SelectedPlayer then CopyOutfit(_G.GameFeatures.SelectedPlayer) end end})
local DandyStam = Tabs.Game:AddButton({Title = "Restore Stamina", Callback = function() if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Stamina = 100 end end})

-- Initial Visibility Control
local function HideAllHubs()
    RivalsSec.Visible = false; RivalsParry.Visible = false; RivalsUnlock.Visible = false
    BHSec.Visible = false; BHDrop.Visible = false; BHUpdate.Visible = false; BHCopy.Visible = false; BHTP.Visible = false
    DandySec.Visible = false; DandyDrop.Visible = false; DandyUpdate.Visible = false; DandyCopy.Visible = false; DandyStam.Visible = false
end

GameSelector:OnChanged(function(v)
    HideAllHubs()
    if v == "Rivals" then
        RivalsSec.Visible = true; RivalsParry.Visible = true; RivalsUnlock.Visible = true
    elseif v == "Brookhaven" then
        BHSec.Visible = true; BHDrop.Visible = true; BHUpdate.Visible = true; BHCopy.Visible = true; BHTP.Visible = true
    elseif v == "Dandy's World" then
        DandySec.Visible = true; DandyDrop.Visible = true; DandyUpdate.Visible = true; DandyCopy.Visible = true; DandyStam.Visible = true
    end
end)
HideAllHubs() -- Start with universal

-- MAIN LOOPS
RunService.RenderStepped:Connect(function()
    -- Aimbot Logic
    if _G.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(_G.Aimbot.Key) then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(_G.Aimbot.TargetPart) then
            local PartPos = Target.Character[_G.Aimbot.TargetPart].Position
            local TargetCFrame = CFrame.new(Camera.CFrame.Position, PartPos)
            Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, 1 / _G.Aimbot.Smoothness)
        end
    end

    -- Local Stats Logic
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local h = LocalPlayer.Character.Humanoid
        h.WalkSpeed = _G.LocalPlayer.WalkSpeed; h.JumpPower = _G.LocalPlayer.JumpPower
        workspace.Gravity = _G.LocalPlayer.Gravity; Camera.FieldOfView = _G.LocalPlayer.FOV
        if _G.LocalPlayer.NoClip then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    end
end)

-- FINISH
SaveManager:SetLibrary(Fluent); InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("Synthesis"); SaveManager:SetFolder("Synthesis/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings); SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({Title = "Synthesis MEGA", Content = "Manual Hub Active. Select your game in 'Game Hub'.", Duration = 5})
SaveManager:LoadAutoloadConfig()
