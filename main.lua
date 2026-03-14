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
        DistESP = false,
        Chams = false,
        WalkSpeed = 16,
        JumpPower = 50,
        NoClip = false,
        TargetPlayer = "None"
    }

    -- Tabs
    local Tabs = {
        Main = Window:AddTab({ Title = "Loader", Icon = "gamepad" }),
        Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "target" }),
        Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
        Local = Window:AddTab({ Title = "Local", Icon = "user" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    local BuiltHubs = {}

    local function GetPlayers()
        local list = {}
        for _, v in pairs(Players:GetPlayers()) do 
            if v ~= LocalPlayer then table.insert(list, v.Name) end 
        end
        if #list == 0 then table.insert(list, "None") end
        return list
    end

    -- POPULATE LOADER (Game Selection)
    Tabs.Main:AddSection("Game Selection")
    Tabs.Main:AddParagraph({
        Title = "Manual Loading",
        Content = "Selecione o jogo abaixo para carregar as funções específicas. Uma nova aba será criada para ele."
    })
    
    local GameSelector = Tabs.Main:AddDropdown("GameSelect", {
        Title = "Select Game Module",
        Values = {"...", "Rivals", "Brookhaven", "Dandy's World"},
        Default = 1
    })

    GameSelector:OnChanged(function(v)
        if v == "Rivals" and not BuiltHubs["Rivals"] then
            BuiltHubs["Rivals"] = true
            local RTab = Window:AddTab({ Title = "Rivals Hub", Icon = "swords" })
            RTab:AddToggle("RParry", {Title = "Auto Parry", Default = false})
            RTab:AddButton({Title = "Unlock All Skins & Weapons", Callback = function()
                Fluent:Notify({Title="Rivals", Content="Liberando inventário (Local)...", Duration=3})
                pcall(function()
                    for _, m in pairs(ReplicatedStorage:GetDescendants()) do
                        if m:IsA("ModuleScript") and (m.Name:find("Item") or m.Name:find("Skin")) then
                            local d = require(m)
                            if type(d) == "table" then for _, i in pairs(d) do if type(i) == "table" then i.Owned = true; i.Unlocked = true end end end
                        end
                    end
                end)
            end})
            -- Window:SelectTab(5) -- Optional jump

        elseif v == "Brookhaven" and not BuiltHubs["Brookhaven"] then
            BuiltHubs["Brookhaven"] = true
            local BTab = Window:AddTab({ Title = "Brookhaven Hub", Icon = "home" })
            local BPD = BTab:AddDropdown("BHPlayer", {Title = "Target Player", Values = GetPlayers(), Default = 1})
            BPD:OnChanged(function(val) _G.SynthState.TargetPlayer = val end)
            BTab:AddButton({Title = "Refresh Player List", Callback = function() BPD:SetValues(GetPlayers()) end})
            
            BTab:AddSection("Target Actions")
            BTab:AddButton({Title = "Teleport To Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                end
            end})
            BTab:AddButton({Title = "Copy Outfit", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and LocalPlayer.Character then
                    for _, i in pairs(LocalPlayer.Character:GetChildren()) do if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") then i:Destroy() end end
                    for _, i in pairs(t.Character:GetChildren()) do if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") then i:Clone().Parent = LocalPlayer.Character end end
                end
            end})

            BTab:AddSection("Local Spoof")
            BTab:AddButton({Title = "Get Infinite Money (Visual)", Callback = function()
                pcall(function()
                    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                        if gui.Name:find("Main") or gui.Name:find("Gui") then
                            for _, txt in pairs(gui:GetDescendants()) do
                                if txt:IsA("TextLabel") and txt.Text:find("%$") then
                                    txt.Text = "$999,999,999"
                                end
                            end
                        end
                    end
                end)
            end})

        elseif v == "Dandy's World" and not BuiltHubs["Dandys"] then
            BuiltHubs["Dandys"] = true
            local DTab = Window:AddTab({ Title = "Dandy Hub", Icon = "skull" })
            local DPD = DTab:AddDropdown("DPlayer", {Title = "Target Player", Values = GetPlayers(), Default = 1})
            DPD:OnChanged(function(val) _G.SynthState.TargetPlayer = val end)
            DTab:AddButton({Title = "Refresh List", Callback = function() DPD:SetValues(GetPlayers()) end})
            
            DTab:AddButton({Title = "Copy Skin", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and LocalPlayer.Character then
                    for _, i in pairs(LocalPlayer.Character:GetChildren()) do if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") then i:Destroy() end end
                    for _, i in pairs(t.Character:GetChildren()) do if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") then i:Clone().Parent = LocalPlayer.Character end end
                end
            end})
            DTab:AddButton({Title = "Restore Max Stamina", Callback = function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Stamina = 100 end
            end})
        end
    end)


    -- POPULATE AIMBOT
    Tabs.Aimbot:AddToggle("AimToggle", {Title = "Enable Aimbot", Default = false}):OnChanged(function(v) _G.SynthState.AimEnabled = v end)
    Tabs.Aimbot:AddDropdown("AimPart", {Title = "Target Part", Values = {"Head", "HumanoidRootPart"}, Default = 1}):OnChanged(function(v) _G.SynthState.AimPart = v end)
    Tabs.Aimbot:AddSlider("AimFOV", {Title = "FOV Size", Default = 100, Min = 10, Max = 800, Rounding = 0}):OnChanged(function(v) _G.SynthState.AimFOV = v end)
    Tabs.Aimbot:AddSlider("AimSmooth", {Title = "Smoothness", Default = 3, Min = 1, Max = 20, Rounding = 1}):OnChanged(function(v) _G.SynthState.AimSmooth = v end)

    -- POPULATE VISUALS
    Tabs.Visuals:AddToggle("BoxToggle", {Title = "Boxes", Default = false}):OnChanged(function(v) _G.SynthState.BoxESP = v end)
    Tabs.Visuals:AddToggle("NameToggle", {Title = "Names", Default = false}):OnChanged(function(v) _G.SynthState.NameESP = v end)
    Tabs.Visuals:AddToggle("DistToggle", {Title = "Distance", Default = false}):OnChanged(function(v) _G.SynthState.DistESP = v end)
    Tabs.Visuals:AddToggle("ChamsToggle", {Title = "Chams", Default = false}):OnChanged(function(v) _G.SynthState.Chams = v end)

    -- POPULATE LOCAL
    Tabs.Local:AddSlider("WSSlider", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 0}):OnChanged(function(v) _G.SynthState.WalkSpeed = v end)
    Tabs.Local:AddSlider("JPSlider", {Title = "JumpPower", Default = 50, Min = 50, Max = 500, Rounding = 0}):OnChanged(function(v) _G.SynthState.JumpPower = v end)
    Tabs.Local:AddToggle("NCToggle", {Title = "NoClip", Default = false}):OnChanged(function(v) _G.SynthState.NoClip = v end)

    -- SETTINGS
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("Synthesis")
    SaveManager:SetFolder("Synthesis/configs")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    -- LOOPS (Aimbot & Visuals)
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
                if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character[_G.SynthState.AimPart].Position), 1/_G.SynthState.AimSmooth) end
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

    -- FULL ESP SYSTEM (Drawing API + Highlights)
    task.spawn(function()
        local function BuildESP(p)
            local Box = Drawing.new("Square"); Box.Visible = false; Box.Color = Color3.new(1,0,0); Box.Thickness = 1; Box.Filled = false
            local Name = Drawing.new("Text"); Name.Visible = false; Name.Color = Color3.new(1,1,1); Name.Size = 14; Name.Center = true; Name.Outline = true
            local Dist = Drawing.new("Text"); Dist.Visible = false; Dist.Color = Color3.new(0.8,0.8,0.8); Dist.Size = 13; Dist.Center = true; Dist.Outline = true
            local HL = Instance.new("Highlight"); HL.Name = "SynthHL"; HL.FillColor = Color3.fromRGB(180, 100, 255); HL.Enabled = false
            
            local function cleanup() Box:Remove(); Name:Remove(); Dist:Remove(); if HL then HL:Destroy() end end
            
            p.CharacterAdded:Connect(function(char) HL.Parent = char end)
            if p.Character then HL.Parent = p.Character end

            local conn; conn = RunService.RenderStepped:Connect(function()
                if not p or not p.Parent then cleanup(); conn:Disconnect(); return end
                
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local root = p.Character.HumanoidRootPart
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    
                    if onScreen then
                        local rootTop = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                        local rootBottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
                        local sizeY = math.abs(rootBottom.Y - rootTop.Y)
                        local sizeX = sizeY * 0.6
                        
                        Box.Size = Vector2.new(sizeX, sizeY)
                        Box.Position = Vector2.new(pos.X - sizeX / 2, rootTop.Y)
                        Box.Visible = _G.SynthState.BoxESP
                        
                        Name.Position = Vector2.new(pos.X, rootTop.Y - 16)
                        Name.Text = p.Name
                        Name.Visible = _G.SynthState.NameESP
                        
                        Dist.Position = Vector2.new(pos.X, rootBottom.Y + 2)
                        Dist.Text = "[" .. math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) .. "m]"
                        Dist.Visible = _G.SynthState.DistESP
                        
                        if HL then HL.Enabled = _G.SynthState.Chams end
                    else
                        Box.Visible = false; Name.Visible = false; Dist.Visible = false; if HL then HL.Enabled = false end
                    end
                else
                    Box.Visible = false; Name.Visible = false; Dist.Visible = false; if HL then HL.Enabled = false end
                end
            end)
        end
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then BuildESP(p) end end
        Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then BuildESP(p) end end)
    end)

    Window:SelectTab(1)
    Fluent:Notify({Title = "Synthesis MEGA", Content = "Fully Loaded! Selections and ESP Restored.", Duration = 5})
end)

if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Synthesis Error", Text = tostring(err), Duration = 20})
end
