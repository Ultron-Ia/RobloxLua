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
        SilentAim = false,
        AimPart = "Head",
        AimFOV = 100,
        AimSmooth = 3,
        
        BoxESP = false,
        NameESP = false,
        DistESP = false,
        SkeletonESP = false,
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        ProjESP = false,
        
        Chams = false,
        ChamsMat = "Neon",
        ChamsColor = Color3.fromRGB(180, 100, 255),
        
        WalkSpeed = 16,
        JumpPower = 50,
        NoClip = false,
        Spinbot = false,
        SpinSpeed = 50,
        
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
    Tabs.Main:AddParagraph({ Title = "Manual Loading", Content = "Selecione o jogo abaixo para carregar as funções específicas." })
    
    local GameSelector = Tabs.Main:AddDropdown("GameSelect", { Title = "Select Game Module", Values = {"...", "Rivals", "Brookhaven", "Dandy's World", "Social/Talking Hub"}, Default = 1 })

    GameSelector:OnChanged(function(v)
        if v == "Rivals" and not BuiltHubs["Rivals"] then
            BuiltHubs["Rivals"] = true
            local RTab = Window:AddTab({ Title = "Rivals Hub", Icon = "swords" })
            RTab:AddToggle("RParry", {Title = "Auto Parry", Default = false})
            RTab:AddButton({Title = "Unlock All Skins & Weapons", Callback = function()
                Fluent:Notify({Title="Rivals", Content="Liberando inventário...", Duration=3})
                pcall(function()
                    for _, m in pairs(ReplicatedStorage:GetDescendants()) do
                        if m:IsA("ModuleScript") and (m.Name:find("Item") or m.Name:find("Skin")) then
                            local d = require(m)
                            if type(d) == "table" then for _, i in pairs(d) do if type(i) == "table" then i.Owned = true; i.Unlocked = true end end end
                        end
                    end
                end)
            end})

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
                    -- Clean current outfit
                    for _, i in pairs(LocalPlayer.Character:GetChildren()) do 
                        if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") or i:IsA("Hat") or i:IsA("ShirtGraphic") or i:IsA("BodyColors") or i:IsA("CharacterMesh") then i:Destroy() end 
                    end
                    if LocalPlayer.Character:FindFirstChild("Head") then
                        for _, v in pairs(LocalPlayer.Character.Head:GetChildren()) do if v:IsA("Decal") or v:IsA("SpecialMesh") then v:Destroy() end end
                    end
                    
                    -- Clone target outfit
                    for _, i in pairs(t.Character:GetChildren()) do 
                        if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("BodyColors") or i:IsA("CharacterMesh") or i:IsA("ShirtGraphic") then 
                            local clone = i:Clone()
                            if clone then clone.Parent = LocalPlayer.Character end
                        elseif i:IsA("Accessory") or i:IsA("Hat") then
                            local clone = i:Clone()
                            if clone then
                                clone.Parent = LocalPlayer.Character
                                -- Manual Weld fallback for Brookhaven's local accessory blocks
                                local handle = clone:FindFirstChild("Handle")
                                local head = LocalPlayer.Character:FindFirstChild("Head")
                                if handle and head then
                                    -- Purge old physics links that connect to the other player
                                    for _, v in pairs(handle:GetChildren()) do
                                        if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") or v:IsA("BodyMover") or v:IsA("BodyGyro") or v:IsA("AngularVelocity") then
                                            v:Destroy()
                                        end
                                    end
                                    handle.CanCollide = false
                                    handle.Massless = true
                                    
                                    local originalHandle = i:FindFirstChild("Handle")
                                    if originalHandle then
                                        -- Find relative offset from target's head
                                        local targetHead = t.Character:FindFirstChild("Head")
                                        if targetHead then
                                            local offset = targetHead.CFrame:ToObjectSpace(originalHandle.CFrame)
                                            handle.CFrame = head.CFrame * offset
                                            local weld = Instance.new("WeldConstraint")
                                            weld.Part0 = head
                                            weld.Part1 = handle
                                            weld.Parent = handle
                                        end
                                    end
                                end
                            end
                        end  
                    end
                    if t.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("Head") then
                        for _, v in pairs(t.Character.Head:GetChildren()) do 
                            if v:IsA("Decal") or v:IsA("SpecialMesh") then 
                                local clone = v:Clone()
                                if clone then clone.Parent = LocalPlayer.Character.Head end
                            end 
                        end
                    end
                    
                    -- Copy MeshPart data for morph bundles (R15 limbs etc)
                    for _, part in pairs(t.Character:GetChildren()) do
                        if part:IsA("MeshPart") then
                            local myPart = LocalPlayer.Character:FindFirstChild(part.Name)
                            if myPart and myPart:IsA("MeshPart") then
                                pcall(function()
                                    myPart.MeshId = part.MeshId
                                    myPart.TextureID = part.TextureID
                                    myPart.Size = part.Size
                                    myPart.Color = part.Color
                                end)
                            end
                        end
                    end
                    
                    -- Copy Body Scales (Height, Width, Depth, Head)
                    local tHum = t.Character:FindFirstChildOfClass("Humanoid")
                    local lHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if tHum and lHum then
                        local scales = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "BodyProportionScale", "BodyTypeScale", "HeadScale"}
                        for _, scaleName in pairs(scales) do
                            local tScale = tHum:FindFirstChild(scaleName)
                            local lScale = lHum:FindFirstChild(scaleName)
                            if tScale and tScale:IsA("NumberValue") and lScale and lScale:IsA("NumberValue") then
                                lScale.Value = tScale.Value
                            end
                        end
                    end
                end
            end})

            BTab:AddSection("Troll & Utilities")
            
            -- Keep track of loops
            local attachLoop = nil
            local sitLoop = nil
            
            BTab:AddToggle("BAttach", {Title = "Attach to Player (Loop TP)", Default = false}):OnChanged(function(v)
                if v then
                    attachLoop = RunService.Heartbeat:Connect(function()
                        local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
                        end
                    end)
                else
                    if attachLoop then attachLoop:Disconnect(); attachLoop = nil end
                end
            end)

            BTab:AddToggle("BSit", {Title = "Sit on Player's Shoulders", Default = false}):OnChanged(function(v)
                if v then
                    sitLoop = RunService.Heartbeat:Connect(function()
                        local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                        if t and t.Character and t.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame * CFrame.new(0, 1.5, 0)
                            if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = true end
                        end
                    end)
                else
                    if sitLoop then sitLoop:Disconnect(); sitLoop = nil end
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
                end
            end)

            BTab:AddButton({Title = "Bring Spawned Cars", Callback = function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myPos = LocalPlayer.Character.HumanoidRootPart.CFrame
                    -- Scan workspace for generic vehicles
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("VehicleSeat") and obj.Parent then
                            local model = obj.Parent
                            if model:IsA("Model") and model.PrimaryPart then
                                model:SetPrimaryPartCFrame(myPos * CFrame.new(0, 5, -10))
                            elseif obj:IsA("BasePart") then
                                obj.CFrame = myPos * CFrame.new(0, 5, -10)
                            end
                        end
                    end
                end
            end})

            BTab:AddButton({Title = "Reset Character (Suicide)", Callback = function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.Health = 0
                end
            end})

            BTab:AddButton({Title = "Fling Target (Kill)", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local thrust = Instance.new("BodyAngularVelocity")
                    thrust.AngularVelocity = Vector3.new(9000, 9000, 9000)
                    thrust.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    thrust.Parent = hrp
                    
                    local startTime = tick()
                    local c; c = RunService.Heartbeat:Connect(function()
                        if hrp and t.Character:FindFirstChild("HumanoidRootPart") and tick() - startTime < 3.5 then
                            hrp.CFrame = t.Character.HumanoidRootPart.CFrame
                        else
                            if thrust then thrust:Destroy() end
                            c:Disconnect()
                        end
                    end)
                end
            end})
            BTab:AddButton({Title = "Delete Bank/Vault Doors (Local)", Callback = function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():match("door") or obj.Name:lower():match("glass") or obj.Name:lower():match("window")) then
                        obj:Destroy()
                    end
                end
            end})

            BTab:AddSection("Local Spoof")
            
            local rgbLoop = nil
            BTab:AddToggle("BRGBSkin", {Title = "RGB / Strobe Skin (Local)", Default = false}):OnChanged(function(v)
                if v then
                    rgbLoop = RunService.RenderStepped:Connect(function()
                        if LocalPlayer.Character then
                            local hue = tick() % 1 / 1
                            local color = Color3.fromHSV(hue, 1, 1)
                            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.Color = color
                                end
                            end
                        end
                    end)
                else
                    if rgbLoop then rgbLoop:Disconnect(); rgbLoop = nil end
                end
            end)

            BTab:AddButton({Title = "Hide Name/Id (Visual Anonymous Mode)", Callback = function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                    for _, child in pairs(LocalPlayer.Character.Head:GetChildren()) do
                        if child:IsA("BillboardGui") or child.Name:lower():match("name") then
                            child:Destroy()
                        end
                    end
                end
            end})

            BTab:AddButton({Title = "Get Infinite Money (Visual)", Callback = function()
                pcall(function()
                    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                        if gui.Name:find("Main") or gui.Name:find("Gui") then
                            for _, txt in pairs(gui:GetDescendants()) do
                                if txt:IsA("TextLabel") and txt.Text:find("%$") then txt.Text = "$999,999,999" end
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
            
            DTab:AddButton({Title = "Copy Skin (Local Model)", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and LocalPlayer.Character then
                    -- Fallback for custom rigs: try to copy obvious visual meshes/accessories
                    for _, i in pairs(LocalPlayer.Character:GetChildren()) do if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") then i:Destroy() end end
                    for _, i in pairs(t.Character:GetChildren()) do if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") then i:Clone().Parent = LocalPlayer.Character end end
                end
            end})
            DTab:AddButton({Title = "Restore Max Stamina (BETA)", Callback = function()
                pcall(function()
                    -- Custom games don't use Humanoid.Stamina. Scan for Attributes or ValueBases
                    local c = LocalPlayer.Character
                    if c then
                        if c:GetAttribute("Stamina") then c:SetAttribute("Stamina", 100) end
                        local sv = c:FindFirstChild("Stamina") or c:FindFirstChild("stamina")
                        if sv and (sv:IsA("IntValue") or sv:IsA("NumberValue")) then sv.Value = 100 end
                    end
                    if LocalPlayer:GetAttribute("Stamina") then LocalPlayer:SetAttribute("Stamina", 100) end
                end)
                Fluent:Notify({Title="Dandy's World", Content="Stamina restore attempted via Value/Attributes.", Duration=3})
            end})
            
            DTab:AddSection("World Visuals")
            DTab:AddToggle("DandyESP", {Title = "Monster/Entity ESP", Default = false}):OnChanged(function(v)
                _G.SynthState.DandyESP = v
            end)
            DTab:AddToggle("DandyItemESP", {Title = "Item/Loot ESP", Default = false}):OnChanged(function(v)
                _G.SynthState.DandyItemESP = v
            end)
            
            -- Simple Entity Tracker
            task.spawn(function()
                while task.wait(1) do
                    -- ENTITIES
                    if _G.SynthState.DandyESP then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                                if not obj:FindFirstChild("SynthEntityESP") then
                                    local hl = Instance.new("Highlight", obj)
                                    hl.Name = "SynthEntityESP"; hl.FillColor = Color3.fromRGB(255, 0, 0)
                                end
                            end
                        end
                    else
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("Model") and obj:FindFirstChild("SynthEntityESP") then obj.SynthEntityESP:Destroy() end
                        end
                    end
                    
                    -- ITEMS (Generic Proximity/Tool Search)
                    if _G.SynthState.DandyItemESP then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if (obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent:IsA("BasePart")) or (obj:IsA("Tool") and obj:FindFirstChild("Handle")) then
                                local target = obj:IsA("ProximityPrompt") and obj.Parent or obj
                                if not target:FindFirstChild("SynthItemESP") then
                                    local hl = Instance.new("Highlight", target)
                                    hl.Name = "SynthItemESP"; hl.FillColor = Color3.fromRGB(0, 255, 100)
                                end
                            end
                        end
                    else
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:FindFirstChild("SynthItemESP") then obj.SynthItemESP:Destroy() end
                        end
                    end
                end
            end)

        elseif v == "Social/Talking Hub" and not BuiltHubs["Social"] then
            BuiltHubs["Social"] = true
            local STab = Window:AddTab({ Title = "Social Hub", Icon = "users" })
            local SPD = STab:AddDropdown("STPlayer", {Title = "Target Player", Values = GetPlayers(), Default = 1})
            SPD:OnChanged(function(val) _G.SynthState.TargetPlayer = val end)
            STab:AddButton({Title = "Refresh List", Callback = function() SPD:SetValues(GetPlayers()) end})
            
            STab:AddSection("Interactions")
            STab:AddButton({Title = "Teleport To Player", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                end
            end})
            STab:AddButton({Title = "Copy Outfit (Full Clone)", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and LocalPlayer.Character then
                    -- Clean current outfit
                    for _, i in pairs(LocalPlayer.Character:GetChildren()) do 
                        if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") or i:IsA("Hat") or i:IsA("ShirtGraphic") or i:IsA("BodyColors") or i:IsA("CharacterMesh") then i:Destroy() end 
                    end
                    if LocalPlayer.Character:FindFirstChild("Head") then
                        for _, v in pairs(LocalPlayer.Character.Head:GetChildren()) do if v:IsA("Decal") or v:IsA("SpecialMesh") then v:Destroy() end end
                    end
                    
                    -- Clone target outfit
                    for _, i in pairs(t.Character:GetChildren()) do 
                        if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("BodyColors") or i:IsA("CharacterMesh") or i:IsA("ShirtGraphic") then 
                            local clone = i:Clone()
                            if clone then clone.Parent = LocalPlayer.Character end
                        elseif i:IsA("Accessory") or i:IsA("Hat") then
                            local clone = i:Clone()
                            if clone then
                                clone.Parent = LocalPlayer.Character
                                -- Manual Weld fallback for games that block local AddAccessory
                                local handle = clone:FindFirstChild("Handle")
                                local head = LocalPlayer.Character:FindFirstChild("Head")
                                if handle and head then
                                    for _, v in pairs(handle:GetChildren()) do
                                        if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") or v:IsA("BodyMover") or v:IsA("BodyGyro") or v:IsA("AngularVelocity") then
                                            v:Destroy()
                                        end
                                    end
                                    handle.CanCollide = false
                                    handle.Massless = true
                                    
                                    local originalHandle = i:FindFirstChild("Handle")
                                    if originalHandle then
                                        local targetHead = t.Character:FindFirstChild("Head")
                                        if targetHead then
                                            local offset = targetHead.CFrame:ToObjectSpace(originalHandle.CFrame)
                                            handle.CFrame = head.CFrame * offset
                                            local weld = Instance.new("WeldConstraint")
                                            weld.Part0 = head
                                            weld.Part1 = handle
                                            weld.Parent = handle
                                        end
                                    end
                                end
                            end
                        end  
                    end
                    if t.Character:FindFirstChild("Head") and LocalPlayer.Character:FindFirstChild("Head") then
                        for _, v in pairs(t.Character.Head:GetChildren()) do 
                            if v:IsA("Decal") or v:IsA("SpecialMesh") then 
                                local clone = v:Clone()
                                if clone then clone.Parent = LocalPlayer.Character.Head end
                            end 
                        end
                    end
                    
                    -- Copy MeshPart data (R15 limbs etc)
                    for _, part in pairs(t.Character:GetChildren()) do
                        if part:IsA("MeshPart") then
                            local myPart = LocalPlayer.Character:FindFirstChild(part.Name)
                            if myPart and myPart:IsA("MeshPart") then
                                pcall(function()
                                    myPart.MeshId = part.MeshId
                                    myPart.TextureID = part.TextureID
                                    myPart.Size = part.Size
                                    myPart.Color = part.Color
                                end)
                            end
                        end
                    end
                    
                    -- Copy Body Scales
                    local tHum = t.Character:FindFirstChildOfClass("Humanoid")
                    local lHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if tHum and lHum then
                        local scales = {"BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "BodyProportionScale", "BodyTypeScale", "HeadScale"}
                        for _, scaleName in pairs(scales) do
                            local tScale = tHum:FindFirstChild(scaleName)
                            local lScale = lHum:FindFirstChild(scaleName)
                            if tScale and tScale:IsA("NumberValue") and lScale and lScale:IsA("NumberValue") then
                                lScale.Value = tScale.Value
                            end
                        end
                    end
                end
            end})
            STab:AddButton({Title = "Bring All Workspace Tools/Items", Callback = function()
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                                LocalPlayer.Character.Humanoid:EquipTool(obj)
                            end
                        end
                    end
                end)
            end})
            STab:AddButton({Title = "Troll Fling (Kill)", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local thrust = Instance.new("BodyAngularVelocity")
                    thrust.AngularVelocity = Vector3.new(9000, 9000, 9000)
                    thrust.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    thrust.Parent = hrp
                    
                    local startTime = tick()
                    local c; c = RunService.Heartbeat:Connect(function()
                        if hrp and t.Character:FindFirstChild("HumanoidRootPart") and tick() - startTime < 3.5 then
                            hrp.CFrame = t.Character.HumanoidRootPart.CFrame
                        else
                            if thrust then thrust:Destroy() end
                            c:Disconnect()
                        end
                    end)
                end
            end})

            local socialSitLoop = nil
            STab:AddToggle("SSit", {Title = "Sit on Target's Shoulders", Default = false}):OnChanged(function(v)
                if v then
                    socialSitLoop = RunService.Heartbeat:Connect(function()
                        local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                        if t and t.Character and t.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame * CFrame.new(0, 1.5, 0)
                            if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = true end
                        end
                    end)
                else
                    if socialSitLoop then socialSitLoop:Disconnect(); socialSitLoop = nil end
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
                end
            end)

            local flying = false
            local flyLoop = nil
            local bv = nil
            local bg = nil
            STab:AddToggle("SFly", {Title = "Fly System (Hold Left Click)", Default = false}):OnChanged(function(v)
                flying = v
                if flying then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = LocalPlayer.Character.HumanoidRootPart
                        bv = Instance.new("BodyVelocity")
                        bv.Velocity = Vector3.new(0,0,0)
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Parent = hrp
                        bg = Instance.new("BodyGyro")
                        bg.P = 9e4
                        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                        bg.CFrame = hrp.CFrame
                        bg.Parent = hrp
                        
                        flyLoop = RunService.RenderStepped:Connect(function()
                            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                bv.Velocity = Camera.CFrame.LookVector * 100 -- Flight speed
                            else
                                bv.Velocity = Vector3.new(0,0,0)
                            end
                            bg.CFrame = Camera.CFrame
                        end)
                    end
                else
                    if flyLoop then flyLoop:Disconnect(); flyLoop = nil end
                    if bv then bv:Destroy() end
                    if bg then bg:Destroy() end
                end
            end)

        end
    end)


    -- POPULATE AIMBOT
    Tabs.Aimbot:AddSection("Aimbot Core")
    Tabs.Aimbot:AddToggle("AimToggle", {Title = "Enable Camera Aimbot", Default = false}):OnChanged(function(v) _G.SynthState.AimEnabled = v end)
    Tabs.Aimbot:AddToggle("SilentToggle", {Title = "Silent Aim (Magic Bullet)", Default = false}):OnChanged(function(v) _G.SynthState.SilentAim = v end)
    Tabs.Aimbot:AddDropdown("AimPart", {Title = "Target Part", Values = {"Head", "HumanoidRootPart"}, Default = 1}):OnChanged(function(v) _G.SynthState.AimPart = v end)
    Tabs.Aimbot:AddSection("Aimbot Settings")
    Tabs.Aimbot:AddSlider("AimFOV", {Title = "FOV Size", Default = 100, Min = 10, Max = 800, Rounding = 0}):OnChanged(function(v) _G.SynthState.AimFOV = v end)
    Tabs.Aimbot:AddSlider("AimSmooth", {Title = "Smoothness (Cam)", Default = 3, Min = 1, Max = 20, Rounding = 1}):OnChanged(function(v) _G.SynthState.AimSmooth = v end)

    -- POPULATE VISUALS
    Tabs.Visuals:AddSection("2D ESP")
    Tabs.Visuals:AddToggle("BoxToggle", {Title = "Boxes", Default = false}):OnChanged(function(v) _G.SynthState.BoxESP = v end)
    Tabs.Visuals:AddToggle("NameToggle", {Title = "Names", Default = false}):OnChanged(function(v) _G.SynthState.NameESP = v end)
    Tabs.Visuals:AddToggle("DistToggle", {Title = "Distance", Default = false}):OnChanged(function(v) _G.SynthState.DistESP = v end)
    Tabs.Visuals:AddToggle("SkelToggle", {Title = "Skeleton Esp", Default = false}):OnChanged(function(v) _G.SynthState.SkeletonESP = v end)
    Tabs.Visuals:AddColorpicker("SkelColor", {Title = "Skeleton Color", Default = Color3.new(1,1,1)}):OnChanged(function(v) _G.SynthState.SkeletonColor = v end)
    
    Tabs.Visuals:AddSection("3D ESP & World")
    Tabs.Visuals:AddToggle("ChamsToggle", {Title = "Enable Chams", Default = false}):OnChanged(function(v) _G.SynthState.Chams = v end)
    Tabs.Visuals:AddDropdown("ChamsMat", {Title = "Chams Material", Values = {"Neon", "ForceField", "Glass", "Plastic"}, Default = 1}):OnChanged(function(v) _G.SynthState.ChamsMat = v end)
    Tabs.Visuals:AddColorpicker("ChamsColor", {Title = "Chams Color", Default = Color3.fromRGB(180, 100, 255)}):OnChanged(function(v) _G.SynthState.ChamsColor = v end)
    Tabs.Visuals:AddToggle("ProjToggle", {Title = "Projectile ESP (Grenades)", Default = false}):OnChanged(function(v) _G.SynthState.ProjESP = v end)

    -- POPULATE LOCAL
    Tabs.Local:AddSection("Movement")
    Tabs.Local:AddSlider("WSSlider", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 0}):OnChanged(function(v) _G.SynthState.WalkSpeed = v end)
    Tabs.Local:AddSlider("JPSlider", {Title = "JumpPower", Default = 50, Min = 50, Max = 500, Rounding = 0}):OnChanged(function(v) _G.SynthState.JumpPower = v end)
    Tabs.Local:AddToggle("NCToggle", {Title = "NoClip", Default = false}):OnChanged(function(v) _G.SynthState.NoClip = v end)
    
    Tabs.Local:AddSection("Anti-Hit (CS:GO Style)")
    Tabs.Local:AddToggle("SpinToggle", {Title = "Spinbot (360)", Default = false}):OnChanged(function(v) _G.SynthState.Spinbot = v end)
    Tabs.Local:AddSlider("SpinSpeed", {Title = "Spin Speed", Default = 50, Min = 10, Max = 200, Rounding = 0}):OnChanged(function(v) _G.SynthState.SpinSpeed = v end)

    -- SETTINGS
    SaveManager:SetLibrary(Fluent); InterfaceManager:SetLibrary(Fluent)
    SaveManager:IgnoreThemeSettings(); SaveManager:SetIgnoreIndexes({})
    InterfaceManager:SetFolder("Synthesis"); SaveManager:SetFolder("Synthesis/configs")
    InterfaceManager:BuildInterfaceSection(Tabs.Settings); SaveManager:BuildConfigSection(Tabs.Settings)

    -- CHEAT CORE ==========================================

    local function GetClosestTarget()
        local best = _G.SynthState.AimFOV
        local targetPos = nil
        local targetPlayer = nil
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                -- Support for games like Rivals where characters might be in workspace root or heavily modified
                local char = p.Character or workspace:FindFirstChild(p.Name)
                if char and char:FindFirstChild(_G.SynthState.AimPart) and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local pos, vis = Camera:WorldToViewportPoint(char[_G.SynthState.AimPart].Position)
                    if vis then
                        local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if mag < best then best = mag; targetPos = char[_G.SynthState.AimPart].Position; targetPlayer = p end
                    end
                end
            end
        end
        return targetPos, targetPlayer
    end

    -- SILENT AIM HOOK (Namecall intercept for Raycasting/Bullets)
    pcall(function()
        if not hookmetamethod or not getnamecallmethod then return end
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if _G.SynthState.SilentAim then
                -- Safely handle checkcaller
                local isScript = false
                pcall(function() isScript = checkcaller() end)
                
                if not isScript then
                    if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" or method == "FireServer" then
                        local targetPos, targetPlayer = GetClosestTarget()
                        if targetPos then
                            if method == "FireServer" and self.Name:lower():find("shoot") or self.Name:lower():find("fire") or self.Name:lower():find("hit") then
                                -- Highly game specific, but common pattern injection
                            elseif method == "Raycast" then
                                local origin = args[1]
                                args[2] = (targetPos - origin).Unit * 1000 -- Redefine direction
                                local unp = unpack or table.unpack
                                return oldNamecall(self, unp(args))
                            end
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end)


    -- MAIN LOOP (Camera Aimbot, Spinbot, Local)
    task.spawn(function()
        local spinAngle = 0
        RunService.RenderStepped:Connect(function()
            -- Camera Aimbot
            if _G.SynthState.AimEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                local targetPos, targetPlayer = GetClosestTarget()
                if targetPos then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), 1/_G.SynthState.AimSmooth) end
            end
            
            -- Local Features
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                local hum = LocalPlayer.Character.Humanoid
                hum.WalkSpeed = _G.SynthState.WalkSpeed
                hum.JumpPower = _G.SynthState.JumpPower
                if _G.SynthState.NoClip then 
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end 
                end
                
                -- Spinbot
                if _G.SynthState.Spinbot and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    spinAngle = spinAngle + math.rad(_G.SynthState.SpinSpeed)
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    -- Spin keeping position
                    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
                end
            end
        end)
    end)

    -- FULL ESP SYSTEM (2D Drawing + Advanced Chams + Skeleton)
    task.spawn(function()
        local DrawPool = {}
        
        local function GetLine()
            local l = Drawing.new("Line"); l.Visible = false; l.Thickness = 1.5; return l
        end

        local function BuildESP(p)
            local Box = Drawing.new("Square"); Box.Visible = false; Box.Color = Color3.new(1,0,0); Box.Thickness = 1; Box.Filled = false
            local Name = Drawing.new("Text"); Name.Visible = false; Name.Color = Color3.new(1,1,1); Name.Size = 14; Name.Center = true; Name.Outline = true
            local Dist = Drawing.new("Text"); Dist.Visible = false; Dist.Color = Color3.new(0.8,0.8,0.8); Dist.Size = 13; Dist.Center = true; Dist.Outline = true
            
            -- Skeleton lines
            local Bones = { Head = GetLine(), Spine = GetLine(), LArm = GetLine(), RArm = GetLine(), LLeg = GetLine(), RLeg = GetLine() }
            
            local function cleanup() 
                Box:Remove(); Name:Remove(); Dist:Remove()
                for _, l in pairs(Bones) do l:Remove() end
            end

            local conn; conn = RunService.RenderStepped:Connect(function()
                if not p then cleanup(); conn:Disconnect(); return end
                
                local char = p.Character or workspace:FindFirstChild(p.Name)
                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local root = char.HumanoidRootPart
                    local head = char:FindFirstChild("Head")
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    
                    if onScreen and pos.Z > 0 then
                        -- Boxes & Text
                        local rootTop = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                        local rootBottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
                        local sizeY = math.abs(rootBottom.Y - rootTop.Y)
                        local sizeX = sizeY * 0.6
                        
                        Box.Size = Vector2.new(sizeX, sizeY); Box.Position = Vector2.new(pos.X - sizeX / 2, rootTop.Y); Box.Visible = _G.SynthState.BoxESP
                        Name.Position = Vector2.new(pos.X, rootTop.Y - 16); Name.Text = p.Name; Name.Visible = _G.SynthState.NameESP
                        
                        local localPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and LocalPlayer.Character.HumanoidRootPart.Position or Camera.CFrame.Position
                        Dist.Position = Vector2.new(pos.X, rootBottom.Y + 2); Dist.Text = "[" .. math.floor((localPos - root.Position).Magnitude) .. "m]"; Dist.Visible = _G.SynthState.DistESP
                        
                        -- Advanced Chams (Material Override)
                        if _G.SynthState.Chams then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                                    pcall(function() 
                                        part.Material = Enum.Material[_G.SynthState.ChamsMat]
                                        part.Color = _G.SynthState.ChamsColor
                                    end)
                                end
                            end
                        end

                        -- Skeleton ESP
                        if _G.SynthState.SkeletonESP and head then
                            local neckP, nV = Camera:WorldToViewportPoint(head.Position - Vector3.new(0, 0.5, 0))
                            local pelvisP, pV = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 1, 0))
                            if nV and pV then
                                Bones.Spine.From = Vector2.new(pos.X, rootTop.Y); Bones.Spine.To = Vector2.new(pelvisP.X, pelvisP.Y); Bones.Spine.Visible = _G.SynthState.SkeletonESP; Bones.Spine.Color = _G.SynthState.SkeletonColor
                                Bones.Head.From = Vector2.new(neckP.X, neckP.Y); Bones.Head.To = Vector2.new(pos.X, rootTop.Y); Bones.Head.Visible = _G.SynthState.SkeletonESP; Bones.Head.Color = _G.SynthState.SkeletonColor
                            else
                                Bones.Spine.Visible = false; Bones.Head.Visible = false
                            end
                            -- Arms/Legs conceptual (simplified R6 for speed)
                            local rArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightHand")
                            local lArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftHand")
                            if rArm then local rap, rv = Camera:WorldToViewportPoint(rArm.Position); if rv then Bones.RArm.From = Vector2.new(pos.X, rootTop.Y); Bones.RArm.To = Vector2.new(rap.X, rap.Y); Bones.RArm.Visible = _G.SynthState.SkeletonESP; Bones.RArm.Color = _G.SynthState.SkeletonColor else Bones.RArm.Visible = false end else Bones.RArm.Visible = false end
                            if lArm then local lap, lv = Camera:WorldToViewportPoint(lArm.Position); if lv then Bones.LArm.From = Vector2.new(pos.X, rootTop.Y); Bones.LArm.To = Vector2.new(lap.X, lap.Y); Bones.LArm.Visible = _G.SynthState.SkeletonESP; Bones.LArm.Color = _G.SynthState.SkeletonColor else Bones.LArm.Visible = false end else Bones.LArm.Visible = false end
                        else
                            for _, l in pairs(Bones) do l.Visible = false end
                        end

                    else
                        Box.Visible = false; Name.Visible = false; Dist.Visible = false
                        for _, l in pairs(Bones) do l.Visible = false end
                    end
                else
                    Box.Visible = false; Name.Visible = false; Dist.Visible = false
                    for _, l in pairs(Bones) do l.Visible = false end
                end
            end)
        end
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then BuildESP(p) end end
        Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then BuildESP(p) end end)
        
        -- PROJECTILE ESP (Looking for common physical projectiles)
        local ProjContainer = workspace:FindFirstChild("Projectiles") or workspace:FindFirstChild("Debris") or workspace
        RunService.RenderStepped:Connect(function()
            if _G.SynthState.ProjESP then
                for _, obj in pairs(ProjContainer:GetDescendants()) do
                    if obj:IsA("Part") and (obj.Name:lower():find("grenade") or obj.Name:lower():find("rocket") or obj.Name:lower():find("bullet")) then
                        if not obj:FindFirstChild("ProjHL") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "ProjHL"; hl.Parent = obj; hl.FillColor = Color3.fromRGB(255, 50, 50)
                            local tag = Drawing.new("Text")
                            tag.Text = "[Grenade/Proj]"; tag.Size = 12; tag.Color = Color3.fromRGB(255,50,50); tag.Center = true
                            
                            local c; c = RunService.RenderStepped:Connect(function()
                                if obj and obj.Parent then
                                    local p, v = Camera:WorldToViewportPoint(obj.Position)
                                    if v then tag.Position = Vector2.new(p.X, p.Y - 15); tag.Visible = true else tag.Visible = false end
                                else
                                    tag:Remove(); c:Disconnect()
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end)

    Window:SelectTab(1)
    Fluent:Notify({Title = "Synthesis EXTREME", Content = "Advanced Engine Loaded. Silent Aim & Spinbot ready.", Duration = 7})
end)

if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Fatal Error", Text = tostring(err), Duration = 20})
end
