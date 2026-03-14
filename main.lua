local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "SYNTHESIS INTERNAL",
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

-- Tabs
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Local = Window:AddTab({ Title = "Local", Icon = "user" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "config" })
}

local Options = Fluent.Options

-- State Variables
local _G = getgenv()
_G.Aimbot = {
    Enabled = false,
    Key = Enum.UserInputType.MouseButton2,
    VisibleCheck = true,
    Smoothness = 1,
    FieldOfView = 100,
    ShowFOV = false,
    Prediction = false,
    PredictionAmount = 0.165,
    TargetPart = "Head"
}

_G.Visuals = {
    Box = false,
    BoxOutline = false,
    BoxColor = Color3.fromRGB(180, 100, 255),
    HealthLabel = false,
    NameLabel = false,
    DistanceLabel = false,
    Skeletons = false,
    Chams = false,
    ChamsFillColor = Color3.fromRGB(180, 100, 255),
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255)
}

_G.LocalPlayer = {
    WalkSpeed = 16,
    JumpPower = 50,
    Gravity = 196.2,
    FOV = 70,
    InfiniteJump = false,
    NoClip = false
}

-- Drawing FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 60
FOVCircle.Radius = _G.Aimbot.FieldOfView
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

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
                if Dist < BestDist then
                    BestDist = Dist
                    Target = player
                end
            end
        end
    end
    return Target
end

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if _G.LocalPlayer.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- ESP System
local function CreateESP(player)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    local Distance = Drawing.new("Text")
    local Health = Drawing.new("Text")

    local function RemoveESP()
        Box:Remove()
        Name:Remove()
        Distance:Remove()
        Health:Remove()
    end

    local Updater = RunService.RenderStepped:Connect(function()
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
            local RootPart = player.Character.HumanoidRootPart
            local Humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local Pos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)

            if OnScreen then
                local Size = (Camera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y)
                local BoxSize = Vector2.new(Size * 1.5, Size)
                local BoxPos = Vector2.new(Pos.X - BoxSize.X / 2, Pos.Y - BoxSize.Y / 2)

                Box.Visible = _G.Visuals.Box
                Box.Size = BoxSize
                Box.Position = BoxPos
                Box.Color = _G.Visuals.BoxColor
                Box.Thickness = 1.5

                Name.Visible = _G.Visuals.NameLabel
                Name.Text = player.Name
                Name.Size = 14
                Name.Center = true
                Name.Outline = true
                Name.Position = Vector2.new(Pos.X, BoxPos.Y - 16)
                Name.Color = Color3.fromRGB(255, 255, 255)

                Distance.Visible = _G.Visuals.DistanceLabel
                Distance.Text = "[" .. math.floor((LocalPlayer.Character.HumanoidRootPart.Position - RootPart.Position).Magnitude) .. "m]"
                Distance.Size = 13
                Distance.Center = true
                Distance.Outline = true
                Distance.Position = Vector2.new(Pos.X, BoxPos.Y + BoxSize.Y + 2)
                Distance.Color = Color3.fromRGB(200, 200, 200)

                -- Chams
                local Highlight = player.Character:FindFirstChild("SynthesisHighlight")
                if _G.Visuals.Chams then
                    if not Highlight then
                        Highlight = Instance.new("Highlight")
                        Highlight.Name = "SynthesisHighlight"
                        Highlight.Parent = player.Character
                    end
                    Highlight.FillColor = _G.Visuals.ChamsFillColor
                    Highlight.OutlineColor = _G.Visuals.ChamsOutlineColor
                    Highlight.FillTransparency = 0.5
                    Highlight.Enabled = true
                elseif Highlight then
                    Highlight.Enabled = false
                end
            else
                Box.Visible = false
                Name.Visible = false
                Distance.Visible = false
                if player.Character:FindFirstChild("SynthesisHighlight") then player.Character.SynthesisHighlight.Enabled = false end
            end
        else
            RemoveESP()
        end
    end)

    player.CharacterRemoving:Connect(function() RemoveESP() Updater:Disconnect() end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESP(player) end
end
Players.PlayerAdded:Connect(function(player) if player ~= LocalPlayer then CreateESP(player) end end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    if _G.Aimbot.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = _G.Aimbot.FieldOfView
        FOVCircle.Position = UserInputService:GetMouseLocation()
    else
        FOVCircle.Visible = false
    end

    if _G.Aimbot.Enabled and _G.Aimbot.SilentAim then
        local Target = GetClosestPlayer()
        if Target then
            local TargetPart = Target.Character[_G.Aimbot.TargetPart]
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)

            mt.__namecall = newcclosure(function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                if method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
                    return old(self, Ray.new(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 1000), unpack(args))
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end
    end

    if _G.Aimbot.Enabled and UserInputService:IsUserInputPressed(_G.Aimbot.Key) and not _G.Aimbot.SilentAim then
        local Target = GetClosestPlayer()
        if Target then
            local TargetPos = Target.Character[_G.Aimbot.TargetPart].Position
            if _G.Aimbot.Prediction then
                TargetPos = TargetPos + (Target.Character[_G.Aimbot.TargetPart].Velocity * _G.Aimbot.PredictionAmount)
            end
            
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPos)
            if OnScreen then
                local MousePos = UserInputService:GetMouseLocation()
                mousemoverel((ScreenPos.X - MousePos.X) / _G.Aimbot.Smoothness, (ScreenPos.Y - MousePos.Y) / _G.Aimbot.Smoothness)
            end
        end
    end

    -- Local Player Mods
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        Humanoid.WalkSpeed = _G.LocalPlayer.WalkSpeed
        Humanoid.JumpPower = _G.LocalPlayer.JumpPower
        workspace.Gravity = _G.LocalPlayer.Gravity
        Camera.FieldOfView = _G.LocalPlayer.FOV
        
        if _G.LocalPlayer.NoClip then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)

-- UI Setup
do
    Tabs.Aimbot:AddToggle("AimEnabled", {Title = "Enable Aimbot", Default = false}):OnChanged(function(Value) _G.Aimbot.Enabled = Value end)
    Tabs.Aimbot:AddToggle("SilentAim", {Title = "Silent Aim", Default = false}):OnChanged(function(Value) _G.Aimbot.SilentAim = Value end)
    Tabs.Aimbot:AddToggle("Prediction", {Title = "Bullet Prediction", Default = false}):OnChanged(function(Value) _G.Aimbot.Prediction = Value end)
    Tabs.Aimbot:AddSlider("PredAmt", {Title = "Prediction Amount", Default = 0.165, Min = 0.01, Max = 0.5, Rounding = 3}):OnChanged(function(Value) _G.Aimbot.PredictionAmount = Value end)
    Tabs.Aimbot:AddToggle("ShowFOV", {Title = "Show FOV Circle", Default = false}):OnChanged(function(Value) _G.Aimbot.ShowFOV = Value end)
    Tabs.Aimbot:AddSlider("FOV", {Title = "FOV Radius", Default = 100, Min = 10, Max = 800, Rounding = 0}):OnChanged(function(Value) _G.Aimbot.FieldOfView = Value end)
    Tabs.Aimbot:AddSlider("Smooth", {Title = "Smoothness", Default = 1, Min = 1, Max = 20, Rounding = 1}):OnChanged(function(Value) _G.Aimbot.Smoothness = Value end)
    Tabs.Aimbot:AddKeybind("AimKey", {Title = "Aimbot Key", Default = "MouseButton2", Mode = "Hold"}):OnChanged(function(Value) _G.Aimbot.Key = Value end)
    Tabs.Aimbot:AddDropdown("TargetPart", {Title = "Target Part", Values = {"Head", "HumanoidRootPart"}, Default = "Head"}):OnChanged(function(Value) _G.Aimbot.TargetPart = Value end)
    
    Tabs.Visuals:AddToggle("BoxESP", {Title = "Boxes", Default = false}):OnChanged(function(Value) _G.Visuals.Box = Value end)
    Tabs.Visuals:AddToggle("NameESP", {Title = "Names", Default = false}):OnChanged(function(Value) _G.Visuals.NameLabel = Value end)
    Tabs.Visuals:AddToggle("DistESP", {Title = "Distance", Default = false}):OnChanged(function(Value) _G.Visuals.DistanceLabel = Value end)
    Tabs.Visuals:AddToggle("Chams", {Title = "Chams", Default = false}):OnChanged(function(Value) _G.Visuals.Chams = Value end)
    Tabs.Visuals:AddColorpicker("BoxCol", {Title = "Box Color", Default = Color3.fromRGB(180, 100, 255)}):OnChanged(function(Value) _G.Visuals.BoxColor = Value end)
    Tabs.Visuals:AddColorpicker("ChamFill", {Title = "Chams Fill Color", Default = Color3.fromRGB(180, 100, 255)}):OnChanged(function(Value) _G.Visuals.ChamsFillColor = Value end)

    Tabs.Local:AddSlider("Speed", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 0}):OnChanged(function(Value) _G.LocalPlayer.WalkSpeed = Value end)
    Tabs.Local:AddSlider("Jump", {Title = "JumpPower", Default = 50, Min = 50, Max = 500, Rounding = 0}):OnChanged(function(Value) _G.LocalPlayer.JumpPower = Value end)
    Tabs.Local:AddSlider("Grav", {Title = "Gravity", Default = 196.2, Min = 0, Max = 1000, Rounding = 1}):OnChanged(function(Value) _G.LocalPlayer.Gravity = Value end)
    Tabs.Local:AddToggle("InfJump", {Title = "Infinite Jump", Default = false}):OnChanged(function(Value) _G.LocalPlayer.InfiniteJump = Value end)
    Tabs.Local:AddToggle("Noclip", {Title = "NoClip", Default = false}):OnChanged(function(Value) _G.LocalPlayer.NoClip = Value end)
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("Synthesis")
SaveManager:SetFolder("Synthesis/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({
    Title = "Synthesis",
    Content = "Script loaded successfully!",
    Duration = 5
})

SaveManager:LoadAutoloadConfig()
