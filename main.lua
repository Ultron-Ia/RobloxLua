-- SYNTHESIS MEGA - ULTRA STABLE VERSION
local success, result = pcall(function()
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
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- Global State
    getgenv().Toggles = {
        AimEnabled = false,
        SilentAim = false,
        ShowFOV = false,
        BoxESP = false,
        NameESP = false,
        Chams = false,
        InfJump = false,
        NoClip = false,
        AutoParry = false
    }
    getgenv().Values = {
        AimPart = "Head",
        AimSmooth = 3,
        AimFOV = 100,
        WalkSpeed = 16,
        JumpPower = 50,
        TargetPlayer = nil
    }

    -- Tabs
    local Tabs = {
        Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
        Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
        Local = Window:AddTab({ Title = "Local", Icon = "user" }),
        GameHub = Window:AddTab({ Title = "Game Hub", Icon = "gamepad" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- Helpers
    local function GetPlayers()
        local n = {}
        for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then table.insert(n, v.Name) end end
        return n
    end

    -- POPULATE AIMBOT
    Tabs.Aimbot:AddToggle("AimTab_Enable", {Title = "Enable Aimbot", Default = false, Callback = function(v) getgenv().Toggles.AimEnabled = v end})
    Tabs.Aimbot:AddDropdown("AimTab_Part", {Title = "Target Part", Values = {"Head", "HumanoidRootPart"}, Default = "Head", Callback = function(v) getgenv().Values.AimPart = v end})
    Tabs.Aimbot:AddSlider("AimTab_FOV", {Title = "FOV Size", Default = 100, Min = 10, Max = 800, Rounding = 0, Callback = function(v) getgenv().Values.AimFOV = v end})
    Tabs.Aimbot:AddSlider("AimTab_Smooth", {Title = "Smoothness", Default = 3, Min = 1, Max = 20, Rounding = 1, Callback = function(v) getgenv().Values.AimSmooth = v end})

    -- POPULATE VISUALS
    Tabs.Visuals:AddToggle("VisTab_Box", {Title = "Boxes", Default = false, Callback = function(v) getgenv().Toggles.BoxESP = v end})
    Tabs.Visuals:AddToggle("VisTab_Name", {Title = "Names", Default = false, Callback = function(v) getgenv().Toggles.NameESP = v end})
    Tabs.Visuals:AddToggle("VisTab_Chams", {Title = "Chams", Default = false, Callback = function(v) getgenv().Toggles.Chams = v end})

    -- POPULATE LOCAL
    Tabs.Local:AddSlider("LocTab_WS", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 0, Callback = function(v) getgenv().Values.WalkSpeed = v end})
    Tabs.Local:AddSlider("LocTab_JP", {Title = "JumpPower", Default = 50, Min = 50, Max = 500, Rounding = 0, Callback = function(v) getgenv().Values.JumpPower = v end})
    Tabs.Local:AddToggle("LocTab_NC", {Title = "NoClip", Default = false, Callback = function(v) getgenv().Toggles.NoClip = v end})

    -- POPULATE GAME HUB
    Tabs.GameHub:AddSection("General")
    local TargetDrop = Tabs.GameHub:AddDropdown("Hub_Target", {Title = "Select Player", Values = GetPlayers(), Default = nil})
    TargetDrop:OnChanged(function(v) getgenv().Values.TargetPlayer = v end)
    Tabs.GameHub:AddButton({Title = "Refresh Players", Callback = function() TargetDrop:SetValues(GetPlayers()) end})
    
    Tabs.GameHub:AddSection("Brookhaven / Dandy's")
    Tabs.GameHub:AddButton({Title = "Copy Player Skin", Callback = function()
        local target = Players:FindFirstChild(getgenv().Values.TargetPlayer)
        if target and target.Character and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") then v:Destroy() end end
            for _, v in pairs(target.Character:GetChildren()) do if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") then v:Clone().Parent = LocalPlayer.Character end end
        end
    end})
    Tabs.GameHub:AddButton({Title = "Dandy: Max Stamina", Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Stamina = 100 end
    end})

    Tabs.GameHub:AddSection("Rivals")
    Tabs.GameHub:AddToggle("Hub_Parry", {Title = "Auto Parry", Default = false, Callback = function(v) getgenv().Toggles.AutoParry = v end})
    Tabs.GameHub:AddButton({Title = "Unlock All Items", Callback = function()
        pcall(function()
            for _, m in pairs(ReplicatedStorage:GetDescendants()) do
                if m:IsA("ModuleScript") and (m.Name:find("Item") or m.Name:find("Skin")) then
                    local d = require(m)
                    if type(d) == "table" then for _, i in pairs(d) do if type(i) == "table" then i.Owned = true; i.Unlocked = true end end end
                end
            end
        end)
    end})

    -- SETTINGS
    SaveManager:SetLibrary(Fluent); InterfaceManager:SetLibrary(Fluent)
    InterfaceManager:SetFolder("Synthesis"); SaveManager:SetFolder("Synthesis/configs")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings); SaveManager:BuildConfigSection(Tabs.Settings)

    -- CHEAT ENGINES (Non-blocking)
    task.spawn(function()
        RunService.RenderStepped:Connect(function()
            -- Aimbot
            if getgenv().Toggles.AimEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local best = getgenv().Values.AimFOV
                local target = nil
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(getgenv().Values.AimPart) then
                        local pos, vis = Camera:WorldToViewportPoint(p.Character[getgenv().Values.AimPart].Position)
                        if vis then
                            local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                            if mag < best then best = mag; target = p end
                        end
                    end
                end
                if target then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character[getgenv().Values.AimPart].Position), 1/getgenv().Values.AimSmooth)
                end
            end
            -- Local
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().Values.WalkSpeed
                LocalPlayer.Character.Humanoid.JumpPower = getgenv().Values.JumpPower
                if getgenv().Toggles.NoClip then for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
            end
        end)
    end)

    -- ESP Engine
    task.spawn(function()
        local function AddESP(p)
            local h = Instance.new("Highlight")
            h.Name = "SyntESP"; h.Parent = p.Character
            RunService.RenderStepped:Connect(function()
                if p.Character and h then
                    h.Enabled = getgenv().Toggles.Chams
                    h.FillColor = Color3.fromRGB(180, 100, 255)
                end
            end)
        end
        Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() AddESP(p) end) end)
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then AddESP(p) end end
    end)

    Window:SelectTab(1)
    Fluent:Notify({Title = "Synthesis MEGA", Content = "Stability version loaded. Default Theme: Amethyst", Duration = 5})
end)

if not success then
    warn("Synthesis MEGA Error: " .. tostring(result))
    game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Synthesis Error", Text = "UI Failed to load. Check console.", Duration = 10 })
end
