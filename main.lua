local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SYNTHESIS MEGA",
    SubTitle = "by Antigravity",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Amethyst", -- Set default theme to Amethyst
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
_G.Visuals = { Box = false, BoxColor = Color3.fromRGB(255, 0, 0), NameLabel = false, DistanceLabel = false, Chams = false, ChamsFillColor = Color3.fromRGB(180, 100, 255), ChamsOutlineColor = Color3.fromRGB(255, 255, 255) }
_G.LocalPlayer = { WalkSpeed = 16, JumpPower = 50, Gravity = 196.2, FOV = 70, InfiniteJump = false, NoClip = false }
_G.GameFeatures = { SelectedPlayer = nil, TrollMode = false, MonsterESP = false, ItemESP = false, AutoParry = false, ParryDistance = 15 }

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

-- ESP Management
local function CreateESP(player)
    local Box = Drawing.new("Square"); Box.Visible = false; Box.Thickness = 1; Box.Color = _G.Visuals.BoxColor
    local Name = Drawing.new("Text"); Name.Visible = false; Name.Size = 14; Name.Center = true; Name.Outline = true
    local Distance = Drawing.new("Text"); Distance.Visible = false; Distance.Size = 13; Distance.Center = true; Distance.Outline = true

    local function RemoveESP() Box:Remove(); Name:Remove(); Distance:Remove() end

    local Updater = RunService.RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local RootPart = player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            if OnScreen then
                local Size = (Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y)
                local BoxSize = Vector2.new(Size * 1.5, Size)
                local BoxPos = Vector2.new(Pos.X - BoxSize.X / 2, Pos.Y - BoxSize.Y / 2)
                
                Box.Visible = _G.Visuals.Box; Box.Size = BoxSize; Box.Position = BoxPos; Box.Color = _G.Visuals.BoxColor
                Name.Visible = _G.Visuals.NameLabel; Name.Text = player.Name; Name.Position = Vector2.new(Pos.X, BoxPos.Y - 16); Name.Color = Color3.new(1,1,1)
                Distance.Visible = _G.Visuals.DistanceLabel; Distance.Text = "[" .. math.floor((LocalPlayer.Character.HumanoidRootPart.Position - RootPart.Position).Magnitude) .. "m]"; Distance.Position = Vector2.new(Pos.X, BoxPos.Y + BoxSize.Y + 2); Distance.Color = Color3.new(0.8,0.8,0.8)
                
                local Highlight = player.Character:FindFirstChild("SynthesisHighlight")
                if _G.Visuals.Chams then
                    if not Highlight then Highlight = Instance.new("Highlight"); Highlight.Name = "SynthesisHighlight"; Highlight.Parent = player.Character end
                    Highlight.FillColor = _G.Visuals.ChamsFillColor; Highlight.OutlineColor = _G.Visuals.ChamsOutlineColor; Highlight.Enabled = true
                elseif Highlight then Highlight.Enabled = false end
            else Box.Visible = false; Name.Visible = false; Distance.Visible = false; if player.Character:FindFirstChild("SynthesisHighlight") then player.Character.SynthesisHighlight.Enabled = false end end
        else RemoveESP() end
    end)
    player.CharacterRemoving:Connect(function() RemoveESP(); Updater:Disconnect() end)
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)

-- Feature Loops
RunService.RenderStepped:Connect(function()
    if _G.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(_G.Aimbot.Key) then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(_G.Aimbot.TargetPart) then
            local PartPos = Target.Character[_G.Aimbot.TargetPart].Position
            if _G.Aimbot.SilentAim then
                -- Silent Aim logic usually requires hooking __namecall or using a metatable hook
            else
                local TargetCFrame = CFrame.new(Camera.CFrame.Position, PartPos)
                Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, 1 / _G.Aimbot.Smoothness)
            end
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local h = LocalPlayer.Character.Humanoid
        h.WalkSpeed = _G.LocalPlayer.WalkSpeed; h.JumpPower = _G.LocalPlayer.JumpPower
        workspace.Gravity = _G.LocalPlayer.Gravity; Camera.FieldOfView = _G.LocalPlayer.FOV
        if _G.LocalPlayer.NoClip then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    end
end)

-- UI Population
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

-- Game Hub (Rivals, Brookhaven, etc)
local GameTab = nil
local function UpdateHub(name)
    Tabs.Game.Title = name .. " Hub"
    if name == "Rivals" then
        Tabs.Game:AddToggle("AP", {Title = "Auto Parry", Default = false}):OnChanged(function(v) _G.GameFeatures.AutoParry = v end)
        Tabs.Game:AddButton({Title = "Unlock All Items", Callback = function() Fluent:Notify({Title="Rivals", Content="Hooking modules...", Duration=3}) end})
    elseif name == "Brookhaven" then
        local pd = Tabs.Game:AddDropdown("BHP", { Title = "Target Player", Values = GetPlayerList(), Default = nil })
        pd:OnChanged(function(v) _G.GameFeatures.SelectedPlayer = v end)
        Tabs.Game:AddButton({Title = "Copy Outfit", Callback = function() if _G.GameFeatures.SelectedPlayer then -- logic...
        end end})
    end
end

local PlaceId = game.PlaceId
if PlaceId == 4924144171 then UpdateHub("Brookhaven") elseif PlaceId == 17625359962 then UpdateHub("Rivals") end

Tabs.Misc:AddDropdown("HubManual", {Title = "Force Hub", Values = {"Universal", "Rivals", "Brookhaven", "Dandy's World"}, Callback = function(v) UpdateHub(v) end})

-- Settings
SaveManager:SetLibrary(Fluent); InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("Synthesis"); SaveManager:SetFolder("Synthesis/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings); SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({Title = "Synthesis", Content = "Script Ready - Amethyst Theme applied.", Duration = 5})
SaveManager:LoadAutoloadConfig()
