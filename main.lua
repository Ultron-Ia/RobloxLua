local success, err = pcall(function()
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
    _G.SynthState = {
        AimEnabled = false,
        AimPart = "Head",
        AimFOV = 100,
        AimSmooth = 3,
        BoxESP = false,
        NameESP = false,
        Chams = false,
        WalkSpeed = 16,
        JumpPower = 50,
        NoClip = false,
        TargetPlayer = "None"
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
        local list = {}
        for _, v in pairs(Players:GetPlayers()) do 
            if v ~= LocalPlayer then table.insert(list, v.Name) end 
        end
        if #list == 0 then table.insert(list, "None") end
        return list
    end

    -- POPULATE AIMBOT
    Tabs.Aimbot:AddToggle("AimToggle", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) _G.SynthState.AimEnabled = v end)
    Tabs.Aimbot:AddDropdown("AimPart", {Title = "Target Part", Values = {"Head", "HumanoidRootPart"}, Default = 1}):OnChanged(function(v) _G.SynthState.AimPart = v end)
    Tabs.Aimbot:AddSlider("AimFOV", {Title = "FOV Size", Default = 100, Min = 10, Max = 800, Rounding = 0}):OnChanged(function(v) _G.SynthState.AimFOV = v end)
    Tabs.Aimbot:AddSlider("AimSmooth", {Title = "Smoothness", Default = 3, Min = 1, Max = 20, Rounding = 1}):OnChanged(function(v) _G.SynthState.AimSmooth = v end)

    -- POPULATE VISUALS
    Tabs.Visuals:AddToggle("BoxToggle", {Title = "Boxes", Default = false}):OnChanged(function(v) _G.SynthState.BoxESP = v end)
    Tabs.Visuals:AddToggle("NameToggle", {Title = "Names", Default = false}):OnChanged(function(v) _G.SynthState.NameESP = v end)
    Tabs.Visuals:AddToggle("ChamsToggle", {Title = "Chams", Default = false}):OnChanged(function(v) _G.SynthState.Chams = v end)

    -- POPULATE LOCAL
    Tabs.Local:AddSlider("WSSlider", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 0}):OnChanged(function(v) _G.SynthState.WalkSpeed = v end)
    Tabs.Local:AddSlider("JPSlider", {Title = "JumpPower", Default = 50, Min = 50, Max = 500, Rounding = 0}):OnChanged(function(v) _G.SynthState.JumpPower = v end)
    Tabs.Local:AddToggle("NCToggle", {Title = "NoClip", Default = false}):OnChanged(function(v) _G.SynthState.NoClip = v end)

    -- POPULATE GAME HUB
    Tabs.GameHub:AddSection("Target Selection")
    local TargetDrop = Tabs.GameHub:AddDropdown("HubTarget", {Title = "Select Player", Values = GetPlayers(), Multi = false, Default = 1})
    TargetDrop:OnChanged(function(v) _G.SynthState.TargetPlayer = v end)
    Tabs.GameHub:AddButton({Title = "Refresh Player List", Callback = function() TargetDrop:SetValues(GetPlayers()) end})

    Tabs.GameHub:AddSection("Brookhaven & Dandy's World")
    Tabs.GameHub:AddButton({Title = "Copy Target's Skin/Outfit", Callback = function()
        local tpName = _G.SynthState.TargetPlayer
        if tpName == "None" then return end
        local target = Players:FindFirstChild(tpName)
        if target and target.Character and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetChildren()) do if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") then v:Destroy() end end
            for _, v in pairs(target.Character:GetChildren()) do if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("Accessory") then v:Clone().Parent = LocalPlayer.Character end end
        end
    end})
    Tabs.GameHub:AddButton({Title = "Dandy's World: Max Stamina", Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Stamina = 100 end
    end})

    Tabs.GameHub:AddSection("Rivals")
    Tabs.GameHub:AddButton({Title = "Unlock All Skins (Local)", Callback = function()
        pcall(function()
            for _, m in pairs(ReplicatedStorage:GetDescendants()) do
                if m:IsA("ModuleScript") and (m.Name:find("Item") or m.Name:find("Skin")) then
                    local d = require(m)
                    if type(d) == "table" then for _, i in pairs(d) do if type(i) == "table" then i.Owned = true; i.Unlocked = true end end end
                end
            end
        end)
    end})

    -- SETTINGS (Fluent Required)
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("Synthesis")
    SaveManager:SetFolder("Synthesis/configs")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    -- LOOPS (Isolated)
    task.spawn(function()
        RunService.RenderStepped:Connect(function()
            -- Aimbot
            if _G.SynthState.AimEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local best = _G.SynthState.AimFOV
                local target = nil
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.SynthState.AimPart) then
                        local pos, vis = Camera:WorldToViewportPoint(p.Character[_G.SynthState.AimPart].Position)
                        if vis then
                            local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                            if mag < best then best = mag; target = p end
                        end
                    end
                end
                if target then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character[_G.SynthState.AimPart].Position), 1/_G.SynthState.AimSmooth)
                end
            end
            
            -- Local
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = _G.SynthState.WalkSpeed
                LocalPlayer.Character.Humanoid.JumpPower = _G.SynthState.JumpPower
                if _G.SynthState.NoClip then 
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end 
                end
            end
        end)
    end)

    task.spawn(function()
        local function AddESP(p)
            local h = Instance.new("Highlight")
            h.Name = "SynthHighlight"; h.Parent = p.Character
            RunService.RenderStepped:Connect(function()
                if p.Character and h then
                    h.Enabled = _G.SynthState.Chams
                    h.FillColor = Color3.fromRGB(180, 100, 255)
                end
            end)
        end
        Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() AddESP(p) end) end)
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then AddESP(p) end end
    end)

    Window:SelectTab(1)
    Fluent:Notify({Title = "Synthesis MEGA", Content = "Loaded! Default Theme: Amethyst", Duration = 5})
end)

if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Synthesis MEGA", Text = "Error loading UI: \n" .. tostring(err), Duration = 20})
end
