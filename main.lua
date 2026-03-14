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
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Game Detection
local PlaceId = game.PlaceId
local Games = {
    Rivals = 17625359962,
    Brookhaven = 4924144171,
    Brainrot = 16672338573,
    DandysWorld = 16116270224, -- Updated ID for Dandy's World [ALPHA]
    AdoptMe = 920587237,
    NoitesFloresta = 18606277051,
    PegueO_Peixe = 18237077673,
    Tsunami = 17698379261,
    Forsaken = 18131346083
}

-- Tabs
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Local = Window:AddTab({ Title = "Local", Icon = "user" }),
}

-- Game Specific Tab Creation with fallback detection
local CurrentGame = "Universal"
if PlaceId == Games.Rivals then
    Tabs.Game = Window:AddTab({ Title = "Rivals", Icon = "swords" })
    CurrentGame = "Rivals"
elseif PlaceId == Games.Brookhaven then
    Tabs.Game = Window:AddTab({ Title = "Brookhaven", Icon = "home" })
    CurrentGame = "Brookhaven"
elseif PlaceId == Games.DandysWorld or game.GameId == 5387498703 then -- Added GameId check
    Tabs.Game = Window:AddTab({ Title = "Dandy's World", Icon = "skull" })
    CurrentGame = "Dandy's World"
elseif PlaceId == Games.AdoptMe then
    Tabs.Game = Window:AddTab({ Title = "Adopt Me!", Icon = "dog" })
    CurrentGame = "Adopt Me!"
elseif PlaceId == Games.NoitesFloresta or PlaceId == Games.Forsaken then
    Tabs.Game = Window:AddTab({ Title = "Survival", Icon = "tent" })
    CurrentGame = "Survival"
end

Tabs.Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
Tabs.Settings = Window:AddTab({ Title = "Settings", Icon = "config" })

-- State
local _G = getgenv()
_G.Aimbot = { Enabled = false, Key = Enum.UserInputType.MouseButton2, Smoothness = 1, FieldOfView = 100, ShowFOV = false, Prediction = false, PredictionAmount = 0.165, TargetPart = "Head", SilentAim = false }
_G.Visuals = { Box = false, BoxColor = Color3.fromRGB(180, 100, 255), NameLabel = false, DistanceLabel = false, Chams = false, ChamsFillColor = Color3.fromRGB(180, 100, 255), ChamsOutlineColor = Color3.fromRGB(255, 255, 255) }
_G.LocalPlayer = { WalkSpeed = 16, JumpPower = 50, Gravity = 196.2, FOV = 70, InfiniteJump = false, NoClip = false }
_G.GameFeatures = {
    SelectedPlayer = nil,
    TrollMode = false,
    MonsterESP = false,
    ItemESP = false
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
            local clone = v:Clone()
            clone.Parent = char
        end
    end
    Fluent:Notify({Title="Outfit Copied", Content="Successfully cloned " .. targetPlayerName .. "'s outfit!", Duration=3})
end

-- Aimbot Logic
local function GetClosestPlayer()
    local BestDist = _G.Aimbot.FieldOfView
    local Target = nil
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(_G.Aimbot.TargetPart) then
            local Pos, OnScreen = Camera:WorldToViewportPoint(player.Character[_G.Aimbot.TargetPart].Position)
            if OnScreen then
                local MousePos = UserInputService:GetMouseLocation()
                local Dist = (Vector2.new(Pos.X, Pos.Y) - MousePos).Magnitude
                if Dist < BestDist then BestDist = Dist; Target = player end
            end
        end
    end
    return Target
end

-- ESP System
local function CreateESP(player)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    local Distance = Drawing.new("Text")
    local function RemoveESP() Box:Remove(); Name:Remove(); Distance:Remove() end
    local Updater = RunService.RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local RootPart = player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            if OnScreen then
                local Size = (Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y)
                local BoxSize = Vector2.new(Size * 1.5, Size)
                local BoxPos = Vector2.new(Pos.X - BoxSize.X / 2, Pos.Y - BoxSize.Y / 2)
                Box.Visible = _G.Visuals.Box; Box.Size = BoxSize; Box.Position = BoxPos; Box.Color = _G.Visuals.BoxColor; Box.Thickness = 1.5
                Name.Visible = _G.Visuals.NameLabel; Name.Text = player.Name; Name.Size = 14; Name.Center = true; Name.Outline = true; Name.Position = Vector2.new(Pos.X, BoxPos.Y - 16); Name.Color = Color3.fromRGB(255, 255, 255)
                Distance.Visible = _G.Visuals.DistanceLabel; Distance.Text = "[" .. math.floor((LocalPlayer.Character.HumanoidRootPart.Position - RootPart.Position).Magnitude) .. "m]"; Distance.Size = 13; Distance.Center = true; Distance.Outline = true; Distance.Position = Vector2.new(Pos.X, BoxPos.Y + BoxSize.Y + 2); Distance.Color = Color3.fromRGB(200, 200, 200)
                local Highlight = player.Character:FindFirstChild("SynthesisHighlight")
                if _G.Visuals.Chams then
                    if not Highlight then Highlight = Instance.new("Highlight"); Highlight.Name = "SynthesisHighlight"; Highlight.Parent = player.Character end
                    Highlight.FillColor = _G.Visuals.ChamsFillColor; Highlight.FillTransparency = 0.5; Highlight.Enabled = true
                elseif Highlight then Highlight.Enabled = false end
            else Box.Visible = false; Name.Visible = false; Distance.Visible = false; if player.Character:FindFirstChild("SynthesisHighlight") then player.Character.SynthesisHighlight.Enabled = false end end
        else RemoveESP() end
    end)
    player.CharacterRemoving:Connect(function() RemoveESP(); Updater:Disconnect() end)
end

for _, player in pairs(Players:GetPlayers()) do if player ~= LocalPlayer then CreateESP(player) end end
Players.PlayerAdded:Connect(function(player) if player ~= LocalPlayer then CreateESP(player) end end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        Humanoid.WalkSpeed = _G.LocalPlayer.WalkSpeed; Humanoid.JumpPower = _G.LocalPlayer.JumpPower
        workspace.Gravity = _G.LocalPlayer.Gravity; Camera.FieldOfView = _G.LocalPlayer.FOV
        if _G.LocalPlayer.NoClip then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    end
end)

-- UI
do
    Tabs.Aimbot:AddToggle("AimEnabled", {Title = "Enable Aimbot", Default = false}):OnChanged(function(Value) _G.Aimbot.Enabled = Value end)
    Tabs.Aimbot:AddToggle("SilentAim", {Title = "Silent Aim", Default = false}):OnChanged(function(Value) _G.Aimbot.SilentAim = Value end)
    Tabs.Aimbot:AddSlider("FOV", {Title = "FOV Radius", Default = 100, Min = 10, Max = 800}):OnChanged(function(Value) _G.Aimbot.FieldOfView = Value end)

    Tabs.Visuals:AddToggle("BoxESP", {Title = "Boxes", Default = false}):OnChanged(function(Value) _G.Visuals.Box = Value end)
    Tabs.Visuals:AddToggle("NameESP", {Title = "Names", Default = false}):OnChanged(function(Value) _G.Visuals.NameLabel = Value end)
    Tabs.Visuals:AddToggle("Chams", {Title = "Chams", Default = false}):OnChanged(function(Value) _G.Visuals.Chams = Value end)

    Tabs.Local:AddSlider("Speed", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 300}):OnChanged(function(Value) _G.LocalPlayer.WalkSpeed = Value end)
    Tabs.Local:AddToggle("InfJump", {Title = "Infinite Jump", Default = false}):OnChanged(function(Value) _G.LocalPlayer.InfiniteJump = Value end)
    Tabs.Local:AddToggle("Noclip", {Title = "NoClip", Default = false}):OnChanged(function(Value) _G.LocalPlayer.NoClip = Value end)

    if CurrentGame == "Brookhaven" then
        local PlayerDropdown = Tabs.Game:AddDropdown("PlayerSelect", { Title = "Select Target Player", Values = GetPlayerList(), Default = nil })
        PlayerDropdown:OnChanged(function(Value) _G.GameFeatures.SelectedPlayer = Value end)
        Tabs.Game:AddButton({ Title = "Teleport to Target", Callback = function()
            if _G.GameFeatures.SelectedPlayer then local target = Players:FindFirstChild(_G.GameFeatures.SelectedPlayer); if target and target.Character then LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame end end
        end })
        Tabs.Game:AddButton({ Title = "Copy Outfit (Clothes)", Callback = function() if _G.GameFeatures.SelectedPlayer then CopyOutfit(_G.GameFeatures.SelectedPlayer) end end })
    elseif CurrentGame == "Dandy's World" then
        Tabs.Game:AddToggle("MonstESP", {Title = "Monster ESP", Default = false}):OnChanged(function(Value) _G.GameFeatures.MonsterESP = Value end)
        Tabs.Game:AddToggle("ItmESP", {Title = "Item ESP", Default = false}):OnChanged(function(Value) _G.GameFeatures.ItemESP = Value end)
        Tabs.Game:AddButton({Title = "Restore Stamina", Callback = function() if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Stamina = 100 end end})
    end
end

SaveManager:SetLibrary(Fluent); InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("Synthesis"); SaveManager:SetFolder("Synthesis/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings); SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({ Title = "Synthesis MEGA", Content = "Loaded for: " .. CurrentGame .. "\nPlace ID: " .. PlaceId, Duration = 6 })
SaveManager:LoadAutoloadConfig()
