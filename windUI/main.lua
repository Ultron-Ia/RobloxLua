local success, err = pcall(function()
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

    local Window = WindUI:CreateWindow({
        Title = "SYNTHESIS MEGA",
        Icon = "shield",
        Author = "by Antigravity",
        Folder = "SynthesisMega",
        Size = UDim2.fromOffset(580, 460),
        Transparent = true,
        Theme = "Dark",
        SideBarWidth = 160,
        HasCloseButton = true
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
        Main = Window:Tab({ Title = "Loader", Icon = "gamepad-2" }),
        Aimbot = Window:Tab({ Title = "Aimbot", Icon = "crosshair" }),
        Visuals = Window:Tab({ Title = "Visuals", Icon = "eye" }),
        Local = Window:Tab({ Title = "Local", Icon = "user" }),
        Settings = Window:Tab({ Title = "Settings", Icon = "settings" })
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
    local MainSection = Tabs.Main:Section({ Title = "Game Selection", Icon = "gamepad-2" })
    MainSection:Paragraph({ Title = "Manual Loading", Desc = "Selecione o jogo abaixo para carregar as funções específicas." })
    
    local GameSelector = MainSection:Dropdown({ Title = "Select Game Module", Values = {"...", "Rivals", "Brookhaven", "Dandy's World", "Social/Talking Hub", "[LUCKY COWARD] Shenanigans de Jujutsu", "Peça de Sailor"}, Value = "...", Callback = function(v)
        if v == "Rivals" and not BuiltHubs["Rivals"] then
            BuiltHubs["Rivals"] = true
            local RTab = Window:Tab({ Title = "Rivals Hub", Icon = "swords" })
            RTab:Toggle({Title = "Auto Parry", Value = false})
            RTab:Button({Title = "Unlock All Skins & Weapons", Callback = function()
                WindUI:Notify({Title="Rivals", Content="Liberando inventário...", Duration=3, Icon="unlock"})
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
            local BTab = Window:Tab({ Title = "Brookhaven Hub", Icon = "home" })
            local BPD = BTab:Dropdown({Title = "Target Player", Values = GetPlayers(), Value = "None", Callback = function(val) _G.SynthState.TargetPlayer = val end})
            BTab:Button({Title = "Refresh Player List", Callback = function() BPD:Refresh(GetPlayers(), true) end})
            
            local BTargetSection = BTab:Section({ Title = "Target Actions", Icon = "target" })
            BTargetSection:Button({Title = "Teleport To Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                end
            end})
            BTargetSection:Button({Title = "Copy Outfit", Callback = function()
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
                            if tScale and tScale:IsA("NumberValue") then
                                local lScale = lHum:FindFirstChild(scaleName)
                                if lScale and lScale:IsA("NumberValue") then
                                    lScale.Value = tScale.Value
                                else
                                    local cloneScale = tScale:Clone()
                                    cloneScale.Parent = lHum
                                end
                            end
                        end
                        
                        -- Force engine to recalculate sizes using Description
                        pcall(function()
                            local tDesc = tHum:GetAppliedDescription()
                            local lDesc = lHum:GetAppliedDescription()
                            if tDesc and lDesc then
                                lDesc.HeightScale = tDesc.HeightScale
                                lDesc.WidthScale = tDesc.WidthScale
                                lDesc.DepthScale = tDesc.DepthScale
                                lDesc.HeadScale = tDesc.HeadScale
                                lDesc.ProportionScale = tDesc.ProportionScale
                                lDesc.BodyTypeScale = tDesc.BodyTypeScale
                                lHum:ApplyDescription(lDesc)
                            end
                        end)
                    end
                end
            end})

            local BTrollSection = BTab:Section({ Title = "Troll & Utilities", Icon = "sparkles" })
            
            local controlClone = nil
            BTrollSection:Toggle({Title = "Control Player (Weld Bug)", Value = false, Callback = function(v)
                if v then
                    local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                    if t and t.Character and LocalPlayer.Character then
                        local lHead = LocalPlayer.Character:FindFirstChild("Head")
                        if lHead then
                            -- Find an accessory on the target
                            for _, acc in pairs(t.Character:GetChildren()) do
                                if acc:IsA("Accessory") or acc:IsA("Hat") then
                                    local clone = acc:Clone()
                                    if clone then
                                        clone.Parent = LocalPlayer.Character
                                        controlClone = clone -- Save reference to delete later
                                        local handle = clone:FindFirstChild("Handle")
                                        if handle then
                                            -- Crucial step: Do NOT destroy the original constraints inside the handle.
                                            -- This keeps the physics link to the target's original head alive on the server physics engine.
                                            handle.CanCollide = false
                                            handle.Massless = true
                                            local weld = Instance.new("WeldConstraint")
                                            weld.Part0 = lHead
                                            weld.Part1 = handle
                                            weld.Parent = handle
                                            break -- Only need one accessory to link the physics bodies
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    if controlClone then
                        controlClone:Destroy()
                        controlClone = nil
                    end
                end
            end)
            
            local attachLoop = nil
            local sitLoop = nil
            
            BTrollSection:Toggle({Title = "Attach to Player (Loop TP)", Value = false, Callback = function(v)
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

            BTrollSection:Toggle({Title = "Sit on Player's Shoulders", Value = false, Callback = function(v)
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

            BTrollSection:Button({Title = "Bring Spawned Cars", Callback = function()
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

            BTrollSection:Button({Title = "Reset Character (Suicide)", Callback = function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.Health = 0
                end
            end})

            BTrollSection:Button({Title = "Fling Target (Kill)", Callback = function()
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

            BTrollSection:Button({Title = "Bypass Houses & Bank (Anti-Ban/Unlock)", Callback = function()
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local n = obj.Name:lower()
                        if n:match("ban") or n == "houseban" then
                            obj:Destroy()
                        elseif n:match("door") or n:match("glass") or n:match("window") then
                            obj.CanCollide = false
                            obj.Transparency = 0.5
                        end
                    end
                end
            end})

            local BSpoofSection = BTab:Section({ Title = "Local Spoof", Icon = "user" })
            
            local rgbLoop = nil
            BSpoofSection:Toggle({Title = "RGB / Strobe Skin (Local)", Value = false, Callback = function(v)
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

            BSpoofSection:Button({Title = "Hide Name/Id (Visual Anonymous Mode)", Callback = function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                    for _, child in pairs(LocalPlayer.Character.Head:GetChildren()) do
                        if child:IsA("BillboardGui") or child.Name:lower():match("name") then
                            child:Destroy()
                        end
                    end
                end
            end})

            BSpoofSection:Button({Title = "Get Infinite Money (Visual)", Callback = function()
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

            -- ============================================
            -- ADMIN COMMANDS
            -- ============================================
            local BAdminSection = BTab:Section({ Title = "Admin Commands", Icon = "shield-alert" })

            -- Verify: list all players in the server
            BAdminSection:Button({Title = "📝 Verify (List Server Players)", Callback = function()
                local msg = "Players in server:\n"
                for _, p in pairs(Players:GetPlayers()) do
                    msg = msg .. "• " .. p.Name .. " (ID: " .. p.UserId .. ")\n"
                end
                WindUI:Notify({Title = "📝 Server Verify", Content = msg, Duration = 10, Icon = "file-text"})
            end})

            -- Kick target (exploiting Brookhaven's remote or local kick workaround)
            BAdminSection:Button({Title = "⚠️ Kick Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t then
                    pcall(function()
                        -- Try any kick remote in ReplicatedStorage
                        for _, r in pairs(ReplicatedStorage:GetDescendants()) do
                            if r:IsA("RemoteEvent") and (r.Name:lower():find("kick") or r.Name:lower():find("ban")) then
                                r:FireServer(t)
                            end
                        end
                        -- Fallback: force them to load a bad character
                        t:Kick("You have been removed by an admin.")
                    end)
                    WindUI:Notify({Title="⚠️ Kick", Content="Attempted to kick " .. _G.SynthState.TargetPlayer, Duration=4, Icon="user-x"})
                end
            end})

            -- Explode target (nuclear bomb effect via BodyForce)
            BAdminSection:Button({Title = "☢️ Explode Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = t.Character.HumanoidRootPart
                    -- Visual: create explosion instance near them
                    local exp = Instance.new("Explosion")
                    exp.Position = hrp.Position
                    exp.BlastRadius = 20
                    exp.BlastPressure = 5000000
                    exp.DestroyJointRadiusPercent = 0
                    exp.Parent = workspace
                    -- Also fling them for effect
                    pcall(function()
                        local bf = Instance.new("BodyForce")
                        bf.Force = Vector3.new(0, 9999999, 0)
                        bf.Parent = hrp
                        task.delay(0.2, function() bf:Destroy() end)
                    end)
                    WindUI:Notify({Title="☢️ Explode", Content="Exploded " .. _G.SynthState.TargetPlayer, Duration=3, Icon="bomb"})
                end
            end})

            -- Ragdoll target (disable motor joints)
            BAdminSection:Button({Title = "Ragdoll Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character then
                    for _, v in pairs(t.Character:GetDescendants()) do
                        if v:IsA("Motor6D") then
                            pcall(function()
                                local a0 = Instance.new("Attachment", v.Part0)
                                local a1 = Instance.new("Attachment", v.Part1)
                                local bs = Instance.new("BallSocketConstraint")
                                bs.Attachment0 = a0
                                bs.Attachment1 = a1
                                bs.Parent = v.Part0
                                v.Enabled = false
                            end)
                        end
                    end
                    -- Kill the humanoid so the ragdoll persists
                    if t.Character:FindFirstChildOfClass("Humanoid") then
                        t.Character.Humanoid.Health = 0
                    end
                    WindUI:Notify({Title="Ragdoll", Content="Ragdolled " .. _G.SynthState.TargetPlayer, Duration=3, Icon="accessibility"})
                end
            end})

            -- Fling target upward (kill via height)
            BAdminSection:Button({Title = "Fling Target (Kill via Height)", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = t.Character.HumanoidRootPart
                    pcall(function()
                        local bv = Instance.new("BodyVelocity")
                        bv.Velocity = Vector3.new(math.random(-300,300), 9999, math.random(-300,300))
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Parent = hrp
                        task.delay(0.5, function() bv:Destroy() end)
                    end)
                    Fluent:Notify({Title="🧲 Fling", Content="Flung " .. _G.SynthState.TargetPlayer, Duration=3})
                end
            end})

            -- Float target (trap them floating in the air)
            local floatLoop = nil
            BAdminSection:Toggle({Title = "Float Target (Loop)", Value = false, Callback = function(v)
                if v then
                    floatLoop = RunService.Heartbeat:Connect(function()
                        local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                            local hrp = t.Character.HumanoidRootPart
                            pcall(function()
                                hrp.Velocity = Vector3.new(hrp.Velocity.X, 50, hrp.Velocity.Z)
                                hrp.CFrame = hrp.CFrame + Vector3.new(0, 0.5, 0)
                            end)
                        end
                    end)
                else
                    if floatLoop then floatLoop:Disconnect(); floatLoop = nil end
                end
            end)

            -- Launch: force constant directional movement on target
            BAdminSection:Button({Title = "Launch Target (Into Space)", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = t.Character.HumanoidRootPart
                    pcall(function()
                        local bv = Instance.new("BodyVelocity")
                        bv.Velocity = Vector3.new(0, 99999, 0)
                        bv.MaxForce = Vector3.new(0, math.huge, 0)
                        bv.Parent = hrp
                        task.delay(1, function() bv:Destroy() end)
                    end)
                    WindUI:Notify({Title="Launch", Content="Launched " .. _G.SynthState.TargetPlayer .. " into orbit!", Duration=3, Icon="rocket"})
                end
            end})

            -- Angel: turn target into an "angel" (white highlight + freeze in sky)
            BAdminSection:Button({Title = "Angel Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = t.Character.HumanoidRootPart
                    -- White glow
                    pcall(function()
                        local hl = t.Character:FindFirstChild("AngelHL") or Instance.new("Highlight", t.Character)
                        hl.Name = "AngelHL"
                        hl.FillColor = Color3.fromRGB(255, 255, 255)
                        hl.OutlineColor = Color3.fromRGB(200, 200, 255)
                        hl.FillTransparency = 0.3
                    end)
                    -- Lift up high and anchor
                    pcall(function()
                        hrp.CFrame = hrp.CFrame + Vector3.new(0, 200, 0)
                        hrp.Anchored = true
                        task.delay(8, function()
                            pcall(function() hrp.Anchored = false end)
                        end)
                    end)
                    if t.Character:FindFirstChildOfClass("Humanoid") then
                        t.Character.Humanoid.Health = 0
                    end
                    WindUI:Notify({Title="Angel", Content=_G.SynthState.TargetPlayer .. " has become an angel!", Duration=4, Icon="cloud-lightning"})
                end
            end})

            -- Kill target
            BAdminSection:Button({Title = "Kill Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
                    t.Character.Humanoid.Health = 0
                    Fluent:Notify({Title="💀 Kill", Content="Killed " .. _G.SynthState.TargetPlayer, Duration=3})
                end
            end})

            -- KillPlus: kill with red explosion visual
            BAdminSection:Button({Title = "KillPlus (Explosion Effect)", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = t.Character.HumanoidRootPart
                    local exp = Instance.new("Explosion")
                    exp.Position = hrp.Position
                    exp.BlastRadius = 10
                    exp.BlastPressure = 1000000
                    exp.DestroyJointRadiusPercent = 0
                    exp.Parent = workspace
                    if t.Character:FindFirstChildOfClass("Humanoid") then
                        t.Character.Humanoid.Health = 0
                    end
                    WindUI:Notify({Title="KillPlus", Content=_G.SynthState.TargetPlayer .. " eliminated!", Duration=3, Icon="zap-off"})
                end
            end})

            -- Jail: create a brick cage around the target
            BAdminSection:Button({Title = "Jail Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = t.Character.HumanoidRootPart.Position
                    local walls = {
                        {CFrame.new(pos + Vector3.new(4, 2, 0)),  Vector3.new(0.5, 6, 8)},
                        {CFrame.new(pos + Vector3.new(-4, 2, 0)), Vector3.new(0.5, 6, 8)},
                        {CFrame.new(pos + Vector3.new(0, 2, 4)),  Vector3.new(8, 6, 0.5)},
                        {CFrame.new(pos + Vector3.new(0, 2, -4)), Vector3.new(8, 6, 0.5)},
                        {CFrame.new(pos + Vector3.new(0, 5, 0)),  Vector3.new(8, 0.5, 8)},
                    }
                    for _, wallData in pairs(walls) do
                        local part = Instance.new("Part")
                        part.Anchored = true
                        part.CanCollide = true
                        part.Size = wallData[2]
                        part.CFrame = wallData[1]
                        part.BrickColor = BrickColor.new("Dark orange")
                        part.Material = Enum.Material.SmoothPlastic
                        part.Transparency = 0.4
                        part.Name = "SynthJailWall"
                        part.Parent = workspace
                        -- Auto-remove after 30s
                        game:GetService("Debris"):AddItem(part, 30)
                    end
                    WindUI:Notify({Title="Jail", Content=_G.SynthState.TargetPlayer .. " has been jailed!", Duration=4, Icon="lock"})
                end
            end})

            -- Freeze target (anchor their HRP)
            local freezeLoop = nil
            BAdminSection:Toggle({Title = "Freeze Target (Loop)", Value = false, Callback = function(v)
                if v then
                    local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                        local frozenCFrame = t.Character.HumanoidRootPart.CFrame
                        freezeLoop = RunService.Heartbeat:Connect(function()
                            local target = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                pcall(function()
                                    target.Character.HumanoidRootPart.CFrame = frozenCFrame
                                    target.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                                end)
                                if target.Character:FindFirstChildOfClass("Humanoid") then
                                    target.Character.Humanoid.WalkSpeed = 0
                                    target.Character.Humanoid.JumpPower = 0
                                end
                            end
                        end)
                    end
                else
                    if freezeLoop then freezeLoop:Disconnect(); freezeLoop = nil end
                    local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                    if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
                        t.Character.Humanoid.WalkSpeed = 16
                        t.Character.Humanoid.JumpPower = 50
                    end
                end
            end)

            -- Loop Kill
            local loopKillConn = nil
            BAdminSection:Toggle({Title = "Loop Kill Target", Value = false, Callback = function(v)
                if v then
                    loopKillConn = RunService.Heartbeat:Connect(function()
                        local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                        if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
                            t.Character.Humanoid.Health = 0
                        end
                    end)
                else
                    if loopKillConn then loopKillConn:Disconnect(); loopKillConn = nil end
                end
            end)

            -- Loop Sit on Target
            local bLoopSit2 = nil
            BAdminSection:Toggle({Title = "Loop Sit on Target (Annoy)", Value = false, Callback = function(v)
                if v then
                    bLoopSit2 = RunService.Heartbeat:Connect(function()
                        local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                        if t and t.Character and t.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame * CFrame.new(0, 1.5, 0)
                            if LocalPlayer.Character:FindFirstChild("Humanoid") then
                                LocalPlayer.Character.Humanoid.Sit = true
                            end
                        end
                    end)
                else
                    if bLoopSit2 then bLoopSit2:Disconnect(); bLoopSit2 = nil end
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.Sit = false
                    end
                end
            end)

            -- ============================================
            -- HORROR COMMANDS
            -- ============================================
            local BHorrorSection = BTab:Section({ Title = "Horror Commands", Icon = "ghost" })

            -- The Backrooms: teleport target to a desolate empty corner
            BHorrorSection:Button({Title = "🪄 The Backrooms (Banish)", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    -- Teleport to a far, empty liminal space position
                    pcall(function()
                        t.Character.HumanoidRootPart.CFrame = CFrame.new(99999, 100, 99999)
                    end)
                    -- Also dim world for local player (visual effect)
                    pcall(function()
                        local lighting = game:GetService("Lighting")
                        local origBrightness = lighting.Brightness
                        local origAmbient = lighting.Ambient
                        lighting.Brightness = 0.05
                        lighting.Ambient = Color3.fromRGB(20, 15, 10)
                        lighting.FogColor = Color3.fromRGB(210, 200, 170)
                        lighting.FogEnd = 60
                        lighting.FogStart = 5
                        task.delay(8, function()
                            lighting.Brightness = origBrightness
                            lighting.Ambient = origAmbient
                            lighting.FogEnd = 100000
                            lighting.FogStart = 0
                        end)
                    end)
                    WindUI:Notify({Title="Backrooms", Content=_G.SynthState.TargetPlayer .. " has been banished to The Backrooms...", Duration=5, Icon="map"})
                end
            end})

            -- Jumpscare: Eyes
            BHorrorSection:Button({Title = "🧟 Jumpscare: Eyes", Callback = function()
                pcall(function()
                    local sg = Instance.new("ScreenGui")
                    sg.Name = "SynthJumpscare"
                    sg.IgnoreGuiInset = true
                    sg.ResetOnSpawn = false
                    sg.Parent = LocalPlayer.PlayerGui

                    local bg = Instance.new("Frame", sg)
                    bg.Size = UDim2.fromScale(1, 1)
                    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    bg.BackgroundTransparency = 0
                    bg.ZIndex = 10

                    local eyes = Instance.new("TextLabel", bg)
                    eyes.Size = UDim2.fromScale(1, 1)
                    eyes.Position = UDim2.fromScale(0, 0)
                    eyes.BackgroundTransparency = 1
                    eyes.Text = "👀"
                    eyes.TextScaled = true
                    eyes.TextColor3 = Color3.fromRGB(255, 0, 0)
                    eyes.Font = Enum.Font.GothamBold
                    eyes.ZIndex = 11

                    -- Flash effect
                    for i = 1, 6 do
                        bg.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 0)
                        task.wait(0.08)
                    end
                    task.wait(0.5)
                    sg:Destroy()
                end)
                WindUI:Notify({Title="Jumpscare", Content="EYES jumpscare triggered!", Duration=2, Icon="eye"})
            end})

            -- Jumpscare: Zombie
            BHorrorSection:Button({Title = "Zombie Jumpscare", Callback = function()
                pcall(function()
                    local sg = Instance.new("ScreenGui")
                    sg.Name = "SynthJumpscare"
                    sg.IgnoreGuiInset = true
                    sg.ResetOnSpawn = false
                    sg.Parent = LocalPlayer.PlayerGui

                    local bg = Instance.new("Frame", sg)
                    bg.Size = UDim2.fromScale(1, 1)
                    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    bg.ZIndex = 10

                    local lbl = Instance.new("TextLabel", bg)
                    lbl.Size = UDim2.fromScale(1, 1)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = "🧟"
                    lbl.TextScaled = true
                    lbl.TextColor3 = Color3.fromRGB(80, 200, 80)
                    lbl.Font = Enum.Font.GothamBold
                    lbl.ZIndex = 11

                    local scream = Instance.new("TextLabel", bg)
                    scream.Size = UDim2.new(1, 0, 0.2, 0)
                    scream.Position = UDim2.new(0, 0, 0.8, 0)
                    scream.BackgroundTransparency = 1
                    scream.Text = "BRAAIIINS..."
                    scream.TextScaled = true
                    scream.TextColor3 = Color3.fromRGB(255, 50, 50)
                    scream.Font = Enum.Font.GothamBold
                    scream.ZIndex = 12

                    for i = 1, 8 do
                        bg.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(50, 120, 0) or Color3.fromRGB(0, 0, 0)
                        task.wait(0.07)
                    end
                    task.wait(0.8)
                    sg:Destroy()
                end)
                WindUI:Notify({Title="Jumpscare", Content="ZOMBIE jumpscare triggered!", Duration=2, Icon="skull"})
            end})

            -- Jumpscare: Ghost
            BHorrorSection:Button({Title = "Ghost Jumpscare", Callback = function()
                pcall(function()
                    local sg = Instance.new("ScreenGui")
                    sg.Name = "SynthJumpscare"
                    sg.IgnoreGuiInset = true
                    sg.ResetOnSpawn = false
                    sg.Parent = LocalPlayer.PlayerGui

                    local bg = Instance.new("Frame", sg)
                    bg.Size = UDim2.fromScale(1, 1)
                    bg.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
                    bg.BackgroundTransparency = 0.1
                    bg.ZIndex = 10

                    local lbl = Instance.new("TextLabel", bg)
                    lbl.Size = UDim2.fromScale(1, 1)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = "👻"
                    lbl.TextScaled = true
                    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    lbl.Font = Enum.Font.GothamBold
                    lbl.ZIndex = 11

                    local scream = Instance.new("TextLabel", bg)
                    scream.Size = UDim2.new(1, 0, 0.15, 0)
                    scream.Position = UDim2.new(0, 0, 0.82, 0)
                    scream.BackgroundTransparency = 1
                    scream.Text = "BOO!"
                    scream.TextScaled = true
                    scream.TextColor3 = Color3.fromRGB(0, 0, 0)
                    scream.Font = Enum.Font.GothamBold
                    scream.ZIndex = 12

                    for i = 1, 6 do
                        bg.BackgroundTransparency = (i % 2 == 0) and 0 or 0.9
                        task.wait(0.1)
                    end
                    task.wait(0.6)
                    sg:Destroy()
                end)
                WindUI:Notify({Title="Jumpscare", Content="GHOST jumpscare triggered!", Duration=2, Icon="ghost"})
            end})

            -- Jumpscare: Backrooms
            BHorrorSection:Button({Title = "Backrooms Jumpscare", Callback = function()
                pcall(function()
                    local sg = Instance.new("ScreenGui")
                    sg.Name = "SynthJumpscare"
                    sg.IgnoreGuiInset = true
                    sg.ResetOnSpawn = false
                    sg.Parent = LocalPlayer.PlayerGui

                    local bg = Instance.new("Frame", sg)
                    bg.Size = UDim2.fromScale(1, 1)
                    bg.BackgroundColor3 = Color3.fromRGB(210, 190, 130)
                    bg.ZIndex = 10

                    local lbl = Instance.new("TextLabel", bg)
                    lbl.Size = UDim2.fromScale(1, 0.7)
                    lbl.Position = UDim2.fromScale(0, 0.05)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = "You shouldn't be here."
                    lbl.TextScaled = true
                    lbl.TextColor3 = Color3.fromRGB(30, 20, 0)
                    lbl.Font = Enum.Font.Gotham
                    lbl.ZIndex = 11

                    local sub = Instance.new("TextLabel", bg)
                    sub.Size = UDim2.new(1, 0, 0.15, 0)
                    sub.Position = UDim2.new(0, 0, 0.78, 0)
                    sub.BackgroundTransparency = 1
                    sub.Text = "Level 0 — The Backrooms"
                    sub.TextScaled = true
                    sub.TextColor3 = Color3.fromRGB(80, 60, 0)
                    sub.Font = Enum.Font.GothamLight
                    sub.ZIndex = 12

                    -- Flicker lights
                    for i = 1, 10 do
                        bg.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(210, 190, 130) or Color3.fromRGB(40, 35, 10)
                        task.wait(0.06)
                    end
                    task.wait(1.5)
                    sg:Destroy()
                end)
                WindUI:Notify({Title="Jumpscare", Content="BACKROOMS jumpscare triggered!", Duration=2, Icon="map-pin"})
            end})

        elseif v == "Peça de Sailor" and not BuiltHubs["PecaDeSailor"] then
            BuiltHubs["PecaDeSailor"] = true
            local STab = Window:Tab({ Title = "Sailor Hub", Icon = "star" })

            local SPD = STab:Dropdown({Title = "Target Player", Values = GetPlayers(), Value = "None", Callback = function(val) _G.SynthState.TargetPlayer = val end})
            STab:Button({Title = "Refresh Player List", Callback = function() SPD:Refresh(GetPlayers(), true) end})

            local SActionSection = STab:Section({ Title = "Player Actions", Icon = "user" })
            SActionSection:Button({Title = "Teleport To Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end})

            SActionSection:Button({Title = "Copy Outfit", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and LocalPlayer.Character then
                    for _, i in pairs(LocalPlayer.Character:GetChildren()) do
                        if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") or i:IsA("Hat") or i:IsA("ShirtGraphic") or i:IsA("BodyColors") or i:IsA("CharacterMesh") then i:Destroy() end
                    end
                    for _, i in pairs(t.Character:GetChildren()) do
                        if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("BodyColors") or i:IsA("CharacterMesh") or i:IsA("ShirtGraphic") then
                            local clone = i:Clone(); if clone then clone.Parent = LocalPlayer.Character end
                        elseif i:IsA("Accessory") or i:IsA("Hat") then
                            local clone = i:Clone()
                            if clone then
                                clone.Parent = LocalPlayer.Character
                                local handle = clone:FindFirstChild("Handle")
                                local head = LocalPlayer.Character:FindFirstChild("Head")
                                if handle and head then
                                    for _, v2 in pairs(handle:GetChildren()) do
                                        if v2:IsA("Weld") or v2:IsA("WeldConstraint") or v2:IsA("Motor6D") then v2:Destroy() end
                                    end
                                    handle.CanCollide = false; handle.Massless = true
                                    local oh = i:FindFirstChild("Handle")
                                    local th = t.Character:FindFirstChild("Head")
                                    if oh and th then
                                        local offset = th.CFrame:ToObjectSpace(oh.CFrame)
                                        handle.CFrame = head.CFrame * offset
                                        local wc = Instance.new("WeldConstraint")
                                        wc.Part0 = head; wc.Part1 = handle; wc.Parent = handle
                                    end
                                end
                            end
                        end
                    end
                    WindUI:Notify({Title="Outfit", Content="Outfit copiado de " .. _G.SynthState.TargetPlayer, Duration=3, Icon="shirt"})
                end
            end})

            -- Attach loop
            local sailorAttachLoop = nil
            SActionSection:Toggle({Title = "Attach to Player (Loop TP)", Value = false, Callback = function(v)
                if v then
                    sailorAttachLoop = RunService.Heartbeat:Connect(function()
                        local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
                        end
                    end)
                else
                    if sailorAttachLoop then sailorAttachLoop:Disconnect(); sailorAttachLoop = nil end
                end
            end)

            -- Sit on head loop
            local sailorSitLoop = nil
            SActionSection:Toggle({Title = "Sit on Target's Head", Value = false, Callback = function(v)
                if v then
                    sailorSitLoop = RunService.Heartbeat:Connect(function()
                        local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                        if t and t.Character and t.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame * CFrame.new(0, 1.5, 0)
                            if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = true end
                        end
                    end)
                else
                    if sailorSitLoop then sailorSitLoop:Disconnect(); sailorSitLoop = nil end
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
                end
            end)

            -- ── Local ────────────────────────────────────────
            local SLocalSection = STab:Section({ Title = "Local Sailor", Icon = "star" })

            -- RGB skin
            local sailorRGBLoop = nil
            SLocalSection:Toggle({Title = "Rainbow/RGB Character", Value = false, Callback = function(v)
                if v then
                    sailorRGBLoop = RunService.RenderStepped:Connect(function()
                        if LocalPlayer.Character then
                            local hue = tick() % 1
                            local color = Color3.fromHSV(hue, 1, 1)
                            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                                if part:IsA("BasePart") then part.Color = color end
                            end
                        end
                    end)
                else
                    if sailorRGBLoop then sailorRGBLoop:Disconnect(); sailorRGBLoop = nil end
                end
            end)

            -- Sailor Moon aura: neon pink highlight on self
            SLocalSection:Button({Title = "Sailor Moon Aura (Self)", Callback = function()
                if LocalPlayer.Character then
                    local existing = LocalPlayer.Character:FindFirstChild("SailorAura")
                    if existing then existing:Destroy(); return end
                    local hl = Instance.new("Highlight", LocalPlayer.Character)
                    hl.Name = "SailorAura"
                    hl.FillColor = Color3.fromRGB(255, 100, 200)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 100)
                    hl.FillTransparency = 0.3
                    WindUI:Notify({Title="🌙 Aura", Content="Sailor Moon Aura ativada! Clique novamente para remover.", Duration=3, Icon="sun"})
                end
            end})

            SLocalSection:Button({Title = "Remove Name Tag (Anon)", Callback = function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
                    for _, child in pairs(LocalPlayer.Character.Head:GetChildren()) do
                        if child:IsA("BillboardGui") or child.Name:lower():match("name") then child:Destroy() end
                    end
                end
                WindUI:Notify({Title="Anon", Content="Name tag removido!", Duration=2, Icon="user-minus"})
            end})

            SLocalSection:Button({Title = "Visual Infinite Money", Callback = function()
                pcall(function()
                    for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if gui:IsA("TextLabel") and (gui.Text:find("%$") or gui.Text:find("Coins") or gui.Text:find("Gold") or gui.Text:find("Money")) then
                            gui.Text = "$9,999,999"
                        end
                    end
                end)
                WindUI:Notify({Title="Money", Content="Visual money modificado!", Duration=2, Icon="coins"})
            end})

            -- ── Admin Commands ────────────────────────────────
            local SAdminSection = STab:Section({ Title = "Admin Commands", Icon = "shield-alert" })

            SAdminSection:Button({Title = "Verify (List Players)", Callback = function()
                local msg = "Players:\n"
                for _, p in pairs(Players:GetPlayers()) do
                    msg = msg .. "• " .. p.Name .. " (ID: " .. p.UserId .. ")\n"
                end
                WindUI:Notify({Title="Verify", Content=msg, Duration=10, Icon="list"})
            end})

            SAdminSection:Button({Title = "Kill Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
                    t.Character.Humanoid.Health = 0
                    Fluent:Notify({Title="💀 Kill", Content="Killed " .. _G.SynthState.TargetPlayer, Duration=3})
                end
            end})

            SAdminSection:Button({Title = "KillPlus (Explosion)", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    local exp = Instance.new("Explosion")
                    exp.Position = t.Character.HumanoidRootPart.Position
                    exp.BlastRadius = 10; exp.BlastPressure = 1000000
                    exp.DestroyJointRadiusPercent = 0; exp.Parent = workspace
                    if t.Character:FindFirstChildOfClass("Humanoid") then t.Character.Humanoid.Health = 0 end
                    WindUI:Notify({Title="KillPlus", Content=_G.SynthState.TargetPlayer .. " eliminated!", Duration=3, Icon="zap-off"})
                end
            end})

            SAdminSection:Button({Title = "Fling Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        local bv = Instance.new("BodyVelocity")
                        bv.Velocity = Vector3.new(math.random(-300,300), 9999, math.random(-300,300))
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Parent = t.Character.HumanoidRootPart
                        task.delay(0.5, function() bv:Destroy() end)
                    end)
                    Fluent:Notify({Title="🧲 Fling", Content="Flung " .. _G.SynthState.TargetPlayer, Duration=3})
                end
            end})

            SAdminSection:Button({Title = "Explode Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    local exp = Instance.new("Explosion")
                    exp.Position = t.Character.HumanoidRootPart.Position
                    exp.BlastRadius = 20; exp.BlastPressure = 5000000
                    exp.DestroyJointRadiusPercent = 0; exp.Parent = workspace
                    WindUI:Notify({Title="Explode", Content="Exploded " .. _G.SynthState.TargetPlayer, Duration=3, Icon="bomb"})
                end
            end})

            -- Freeze
            local sailorFreezeLoop = nil
            SAdminSection:Toggle({Title = "Freeze Target (Loop)", Value = false, Callback = function(v)
                if v then
                    local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                        local frozenCF = t.Character.HumanoidRootPart.CFrame
                        sailorFreezeLoop = RunService.Heartbeat:Connect(function()
                            local tgt = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                            if tgt and tgt.Character and tgt.Character:FindFirstChild("HumanoidRootPart") then
                                pcall(function()
                                    tgt.Character.HumanoidRootPart.CFrame = frozenCF
                                    tgt.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                                end)
                                if tgt.Character:FindFirstChildOfClass("Humanoid") then
                                    tgt.Character.Humanoid.WalkSpeed = 0
                                    tgt.Character.Humanoid.JumpPower = 0
                                end
                            end
                        end)
                    end
                else
                    if sailorFreezeLoop then sailorFreezeLoop:Disconnect(); sailorFreezeLoop = nil end
                    local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                    if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
                        t.Character.Humanoid.WalkSpeed = 16
                        t.Character.Humanoid.JumpPower = 50
                    end
                end
            end)

            -- Loop Kill
            local sailorLoopKill = nil
            SAdminSection:Toggle({Title = "Loop Kill Target", Value = false, Callback = function(v)
                if v then
                    sailorLoopKill = RunService.Heartbeat:Connect(function()
                        local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                        if t and t.Character and t.Character:FindFirstChildOfClass("Humanoid") then
                            t.Character.Humanoid.Health = 0
                        end
                    end)
                else
                    if sailorLoopKill then sailorLoopKill:Disconnect(); sailorLoopKill = nil end
                end
            end)

            -- Jail
            SAdminSection:Button({Title = "Jail Target", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    local pos = t.Character.HumanoidRootPart.Position
                    local walls = {
                        {CFrame.new(pos + Vector3.new(4, 2, 0)),  Vector3.new(0.5, 6, 8)},
                        {CFrame.new(pos + Vector3.new(-4, 2, 0)), Vector3.new(0.5, 6, 8)},
                        {CFrame.new(pos + Vector3.new(0, 2, 4)),  Vector3.new(8, 6, 0.5)},
                        {CFrame.new(pos + Vector3.new(0, 2, -4)), Vector3.new(8, 6, 0.5)},
                        {CFrame.new(pos + Vector3.new(0, 5, 0)),  Vector3.new(8, 0.5, 8)},
                    }
                    for _, wd in pairs(walls) do
                        local part = Instance.new("Part")
                        part.Anchored = true; part.CanCollide = true
                        part.Size = wd[2]; part.CFrame = wd[1]
                        part.BrickColor = BrickColor.new("Hot pink")
                        part.Material = Enum.Material.Neon
                        part.Transparency = 0.4; part.Name = "SailorJail"
                        part.Parent = workspace
                        game:GetService("Debris"):AddItem(part, 30)
                    end
                    WindUI:Notify({Title="Jail", Content=_G.SynthState.TargetPlayer .. " jailed!", Duration=4, Icon="lock"})
                end
            end})

            -- ── Horror Commands ───────────────────────────────
            STab:AddSection("🎃 Horror Commands")

            SHorrorSection:Button({Title = "Backrooms (Banish)", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function() t.Character.HumanoidRootPart.CFrame = CFrame.new(99999, 100, 99999) end)
                    pcall(function()
                        local lighting = game:GetService("Lighting")
                        local ob, oa = lighting.Brightness, lighting.Ambient
                        lighting.Brightness = 0.05
                        lighting.Ambient = Color3.fromRGB(20, 15, 10)
                        lighting.FogColor = Color3.fromRGB(210, 200, 170)
                        lighting.FogEnd = 60; lighting.FogStart = 5
                        task.delay(8, function()
                            lighting.Brightness = ob; lighting.Ambient = oa
                            lighting.FogEnd = 100000; lighting.FogStart = 0
                        end)
                    end)
                    WindUI:Notify({Title="Backrooms", Content=_G.SynthState.TargetPlayer .. " banished!", Duration=5, Icon="map"})
                end
            end})

            local function SailorJumpscare(icon, flashR, flashG, flashB, text, delay_)
                pcall(function()
                    local sg = Instance.new("ScreenGui")
                    sg.Name = "SailorScare"; sg.IgnoreGuiInset = true
                    sg.ResetOnSpawn = false; sg.Parent = LocalPlayer.PlayerGui
                    local bg = Instance.new("Frame", sg)
                    bg.Size = UDim2.fromScale(1,1); bg.BackgroundColor3 = Color3.fromRGB(0,0,0); bg.ZIndex = 10
                    local ico = Instance.new("TextLabel", bg)
                    ico.Size = UDim2.fromScale(1,1); ico.BackgroundTransparency = 1
                    ico.Text = icon; ico.TextScaled = true
                    ico.TextColor3 = Color3.fromRGB(255,255,255); ico.Font = Enum.Font.GothamBold; ico.ZIndex = 11
                    local lbl = Instance.new("TextLabel", bg)
                    lbl.Size = UDim2.new(1,0,0.15,0); lbl.Position = UDim2.new(0,0,0.82,0)
                    lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextScaled = true
                    lbl.TextColor3 = Color3.fromRGB(flashR, flashG, flashB); lbl.Font = Enum.Font.GothamBold; lbl.ZIndex = 12
                    for i = 1, 8 do
                        bg.BackgroundColor3 = (i%2==0) and Color3.fromRGB(flashR,flashG,flashB) or Color3.fromRGB(0,0,0)
                        task.wait(0.07)
                    end
                    task.wait(delay_ or 0.5)
                    sg:Destroy()
                end)
            end

            SHorrorSection:Button({Title = "Jumpscare: Eyes",      Callback = function() SailorJumpscare("👀", 255, 0, 0,   "OLHANDO PARA VOCÊ...", 0.5) WindUI:Notify({Title="Scare", Content="Eyes!", Duration=2, Icon="eye"}) end})
            SHorrorSection:Button({Title = "Jumpscare: Zombie",    Callback = function() SailorJumpscare("🧟", 50, 180, 0,  "BRAAIIINS...",         0.8) WindUI:Notify({Title="Scare", Content="Zombie!", Duration=2, Icon="skull"}) end})
            SHorrorSection:Button({Title = "Jumpscare: Ghost",     Callback = function() SailorJumpscare("👻", 200, 200, 255,"BOO!",                 0.6) WindUI:Notify({Title="Scare", Content="Ghost!", Duration=2, Icon="ghost"}) end})
            SHorrorSection:Button({Title = "Jumpscare: Backrooms", Callback = function() SailorJumpscare("🟨", 210, 190, 130,"Level 0 — Backrooms",  1.5) WindUI:Notify({Title="Scare", Content="Backrooms!", Duration=2, Icon="map-pin"}) end})

        elseif v == "Dandy's World" and not BuiltHubs["Dandys"] then
            BuiltHubs["Dandys"] = true
            local DTab = Window:Tab({ Title = "Dandy Hub", Icon = "skull" })
            local DPD = DTab:Dropdown({Title = "Target Player", Values = GetPlayers(), Value = "None", Callback = function(val) _G.SynthState.TargetPlayer = val end})
            DTab:Button({Title = "Refresh List", Callback = function() DPD:Refresh(GetPlayers(), true) end})
            
            DTab:Button({Title = "Copy Skin (Local Model)", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and LocalPlayer.Character then
                    -- Fallback for custom rigs: try to copy obvious visual meshes/accessories
                    for _, i in pairs(LocalPlayer.Character:GetChildren()) do if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") then i:Destroy() end end
                    for _, i in pairs(t.Character:GetChildren()) do if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") then i:Clone().Parent = LocalPlayer.Character end end
                end
            end})
            DTab:Button({Title = "Restore Max Stamina (BETA)", Callback = function()
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
                WindUI:Notify({Title="Dandy's World", Content="Stamina restore attempted via Value/Attributes.", Duration=3, Icon="battery-full"})
            end})
            
            local DWorldSection = DTab:Section({ Title = "World Visuals", Icon = "globe" })
            DWorldSection:Toggle({Title = "Monster/Entity ESP", Value = false, Callback = function(v)
                _G.SynthState.DandyESP = v
            end})
            DWorldSection:Toggle({Title = "Item/Loot ESP", Value = false, Callback = function(v)
                _G.SynthState.DandyItemESP = v
            end})
            
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
            local STab = Window:Tab({ Title = "Social Hub", Icon = "users" })
            local SPD = STab:Dropdown({Title = "Target Player", Values = GetPlayers(), Value = "None", Callback = function(val) _G.SynthState.TargetPlayer = val end})
            STab:Button({Title = "Refresh List", Callback = function() SPD:Refresh(GetPlayers(), true) end})
            
            local SInteractSection = STab:Section({ Title = "Interactions", Icon = "message-circle" })
            SInteractSection:Button({Title = "Teleport To Player", Callback = function()
                local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                end
            end})
            SInteractSection:Button({Title = "Copy Outfit (Full Clone)", Callback = function()
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
                            if tScale and tScale:IsA("NumberValue") then
                                local lScale = lHum:FindFirstChild(scaleName)
                                if lScale and lScale:IsA("NumberValue") then
                                    lScale.Value = tScale.Value
                                else
                                    local cloneScale = tScale:Clone()
                                    cloneScale.Parent = lHum
                                end
                            end
                        end
                        
                        -- Force engine to recalculate sizes using Description
                        pcall(function()
                            local tDesc = tHum:GetAppliedDescription()
                            local lDesc = lHum:GetAppliedDescription()
                            if tDesc and lDesc then
                                lDesc.HeightScale = tDesc.HeightScale
                                lDesc.WidthScale = tDesc.WidthScale
                                lDesc.DepthScale = tDesc.DepthScale
                                lDesc.HeadScale = tDesc.HeadScale
                                lDesc.ProportionScale = tDesc.ProportionScale
                                lDesc.BodyTypeScale = tDesc.BodyTypeScale
                                lHum:ApplyDescription(lDesc)
                            end
                        end)
                    end
                end
            end})
            
            local socialControlClone = nil
            SInteractSection:Toggle({Title = "Control Player (Weld Bug)", Value = false, Callback = function(v)
                if v then
                    local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                    if t and t.Character and LocalPlayer.Character then
                        local lHead = LocalPlayer.Character:FindFirstChild("Head")
                        if lHead then
                            -- Find an accessory on the target
                            for _, acc in pairs(t.Character:GetChildren()) do
                                if acc:IsA("Accessory") or acc:IsA("Hat") then
                                    local clone = acc:Clone()
                                    if clone then
                                        clone.Parent = LocalPlayer.Character
                                        socialControlClone = clone -- Save reference to delete later
                                        local handle = clone:FindFirstChild("Handle")
                                        if handle then
                                            handle.CanCollide = false
                                            handle.Massless = true
                                            local weld = Instance.new("WeldConstraint")
                                            weld.Part0 = lHead
                                            weld.Part1 = handle
                                            weld.Parent = handle
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    if socialControlClone then
                        socialControlClone:Destroy()
                        socialControlClone = nil
                    end
                end
            end)
            
            SInteractSection:Button({Title = "Bring All Workspace Tools/Items", Callback = function()
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
            SInteractSection:Button({Title = "Troll Fling (Kill)", Callback = function()
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

            local socialAttachLoop = nil
            SInteractSection:Toggle({Title = "Attach to Player (Loop TP)", Value = false, Callback = function(v)
                if v then
                    socialAttachLoop = RunService.Heartbeat:Connect(function()
                        local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
                        end
                    end)
                else
                    if socialAttachLoop then socialAttachLoop:Disconnect(); socialAttachLoop = nil end
                end
            end)

            local spinSitLoop = nil
            local spinSitAngle = 0
            SInteractSection:Toggle({Title = "Spin on Target's Head (Annoy)", Value = false, Callback = function(v)
                if v then
                    spinSitLoop = RunService.Heartbeat:Connect(function()
                        local t = Players:FindFirstChild(_G.SynthState.TargetPlayer)
                        if t and t.Character and t.Character:FindFirstChild("Head") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            spinSitAngle = spinSitAngle + math.rad(40)
                            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame * CFrame.new(0, 2, 0) * CFrame.Angles(0, spinSitAngle, 0)
                            if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = true end
                        end
                    end)
                else
                    if spinSitLoop then spinSitLoop:Disconnect(); spinSitLoop = nil end
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = false end
                end
            end)

            SInteractSection:Button({Title = "AoE Fling All (Kill Server)", Callback = function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = LocalPlayer.Character.HumanoidRootPart
                    local thrust = Instance.new("BodyAngularVelocity")
                    thrust.AngularVelocity = Vector3.new(9000, 9000, 9000)
                    thrust.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    thrust.Parent = hrp
                    
                    local startTime = tick()
                    local c; c = RunService.Heartbeat:Connect(function()
                        if hrp and tick() - startTime < 8 then
                            local target = nil
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                    local root = p.Character.HumanoidRootPart
                                    if root.Velocity.Magnitude < 100 then
                                        target = root.CFrame
                                        break
                                    end
                                end
                            end
                            if target then hrp.CFrame = target end
                        else
                            if thrust then thrust:Destroy() end
                            c:Disconnect()
                        end
                    end)
                end
            end})

            SInteractSection:Button({Title = "Naked Mode (Remove Clothes Local)", Callback = function()
                if LocalPlayer.Character then
                    for _, i in pairs(LocalPlayer.Character:GetChildren()) do 
                        if i:IsA("Shirt") or i:IsA("Pants") or i:IsA("Accessory") or i:IsA("Hat") or i:IsA("ShirtGraphic") then 
                            i:Destroy() 
                        end 
                    end
                end
            end})

            local socialSitLoop = nil
            SInteractSection:Toggle({Title = "Sit on Target's Shoulders", Value = false, Callback = function(v)
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
            SInteractSection:Toggle({Title = "Fly System (Hold Left Click)", Value = false, Callback = function(v)
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
            -- ============================================
            -- HORROR COMMANDS
            -- ============================================
            local SHorrorSection = STab:Section({ Title = "Horror Commands", Icon = "ghost" })
            
            SHorrorSection:Button({Title = "🏹 Angel All Players (Kill Server)", Callback = function()
                local count = 0
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = p.Character.HumanoidRootPart
                        -- White glow
                        pcall(function()
                            local hl = p.Character:FindFirstChild("AngelHL") or Instance.new("Highlight", p.Character)
                            hl.Name = "AngelHL"
                            hl.FillColor = Color3.fromRGB(255, 255, 255)
                            hl.OutlineColor = Color3.fromRGB(200, 200, 255)
                            hl.FillTransparency = 0.3
                        end)
                        -- Lift up high and anchor
                        pcall(function()
                            hrp.CFrame = hrp.CFrame + Vector3.new(0, 200, 0)
                            hrp.Anchored = true
                            task.delay(8, function()
                                pcall(function() hrp.Anchored = false end)
                            end)
                        end)
                        
                        if p.Character:FindFirstChildOfClass("Humanoid") then
                            p.Character.Humanoid.Health = 0
                        end
                        count = count + 1
                    end
                end
                WindUI:Notify({Title="Angel All", Content=count.." players have become angels!", Duration=4, Icon="sun"})
            end})

        elseif v == "[LUCKY COWARD] Shenanigans de Jujutsu" and not BuiltHubs["Shenanigans"] then
            BuiltHubs["Shenanigans"] = true
            local JTab = Window:Tab({ Title = "Jujutsu Hub", Icon = "shield" })
            
            local JGodSection = JTab:Section({ Title = "Invincibility & God Mode", Icon = "shield-check" })
            
            local godLoop = nil
            JGodSection:Toggle({Title = "Basic God Mode (Max Health)", Value = false, Callback = function(v)
                if v then
                    godLoop = RunService.Heartbeat:Connect(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            local hum = LocalPlayer.Character.Humanoid
                            if hum.Health > 0 then
                                hum.MaxHealth = math.huge
                                hum.Health = math.huge
                            end
                        end
                    end)
                else
                    if godLoop then godLoop:Disconnect(); godLoop = nil end
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        LocalPlayer.Character.Humanoid.MaxHealth = 100
                    end
                end
            end)

            local hitboxLoop = nil
            JGodSection:Toggle({Title = "Delete Enemy Hitboxes (Anti-Damage)", Value = false, Callback = function(v)
                if v then
                    hitboxLoop = RunService.RenderStepped:Connect(function()
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                local name = obj.Name:lower()
                                if name:match("hitbox") or name:match("damage") or name:match("attack") then
                                    if not obj:IsDescendantOf(LocalPlayer.Character) then
                                        pcall(function() obj:Destroy() end)
                                    end
                                end
                            end
                        end
                    end)
                else
                    if hitboxLoop then hitboxLoop:Disconnect(); hitboxLoop = nil end
                end
            end)

            local dodgeLoop = nil
            JGodSection:Toggle({Title = "Auto Dodge (Proximity TP)", Value = false, Callback = function(v)
                if v then
                    dodgeLoop = RunService.Heartbeat:Connect(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                    local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                                    if dist < 12 and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                                        -- Teleport slightly behind them to avoid frontal attacks
                                        LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                                    end
                                end
                            end
                        end
                    end)
                else
                    if dodgeLoop then dodgeLoop:Disconnect(); dodgeLoop = nil end
                end
            end)
            
            local antiStunLoop = nil
            JGodSection:Toggle({Title = "Anti-Stun / Auto-Sprint", Value = false, Callback = function(v)
                if v then
                    antiStunLoop = RunService.RenderStepped:Connect(function()
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            -- Constant walkspeed enforcement to bypass stuns
                            if LocalPlayer.Character.Humanoid.WalkSpeed < 16 then
                                LocalPlayer.Character.Humanoid.WalkSpeed = 16
                            end
                            -- Destroying freeze/anchor effects if they exist
                            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and hrp.Anchored then hrp.Anchored = false end
                        end
                    end)
                else
                    if antiStunLoop then antiStunLoop:Disconnect(); antiStunLoop = nil end
                end
            end)

        end
    end)


    -- POPULATE AIMBOT
    local AimCoreSection = Tabs.Aimbot:Section({Title = "Aimbot Core", Icon = "target"})
    AimCoreSection:Toggle({Title = "Enable Camera Aimbot", Value = false, Callback = function(v) _G.SynthState.AimEnabled = v end})
    AimCoreSection:Toggle({Title = "Silent Aim (Magic Bullet)", Value = false, Callback = function(v) _G.SynthState.SilentAim = v end})
    AimCoreSection:Dropdown({Title = "Target Part", Values = {"Head", "HumanoidRootPart"}, Value = "Head", Callback = function(v) _G.SynthState.AimPart = v end})
    
    local AimSettingsSection = Tabs.Aimbot:Section({Title = "Aimbot Settings", Icon = "settings-2"})
    AimSettingsSection:Slider({Title = "FOV Size", Value = 100, Min = 10, Max = 800, Step = 1, Callback = function(v) _G.SynthState.AimFOV = v end})
    AimSettingsSection:Slider({Title = "Smoothness (Cam)", Value = 3, Min = 1, Max = 20, Step = 0.1, Callback = function(v) _G.SynthState.AimSmooth = v end})

    -- POPULATE VISUALS
    local ESP2DSection = Tabs.Visuals:Section({Title = "2D ESP", Icon = "layout"})
    ESP2DSection:Toggle({Title = "Boxes", Value = false, Callback = function(v) _G.SynthState.BoxESP = v end})
    ESP2DSection:Toggle({Title = "Names", Value = false, Callback = function(v) _G.SynthState.NameESP = v end})
    ESP2DSection:Toggle({Title = "Distance", Value = false, Callback = function(v) _G.SynthState.DistESP = v end})
    ESP2DSection:Toggle({Title = "Skeleton Esp", Value = false, Callback = function(v) _G.SynthState.SkeletonESP = v end})
    ESP2DSection:Colorpicker({Title = "Skeleton Color", Default = Color3.new(1,1,1), Callback = function(v) _G.SynthState.SkeletonColor = v end})
    
    local ESP3DSection = Tabs.Visuals:Section({Title = "3D ESP & World", Icon = "box"})
    ESP3DSection:Toggle({Title = "Enable Chams", Value = false, Callback = function(v) _G.SynthState.Chams = v end})
    ESP3DSection:Dropdown({Title = "Chams Material", Values = {"Neon", "ForceField", "Glass", "Plastic"}, Value = "Neon", Callback = function(v) _G.SynthState.ChamsMat = v end})
    ESP3DSection:Colorpicker({Title = "Chams Color", Default = Color3.fromRGB(180, 100, 255), Callback = function(v) _G.SynthState.ChamsColor = v end})
    ESP3DSection:Toggle({Title = "Projectile ESP (Grenades)", Value = false, Callback = function(v) _G.SynthState.ProjESP = v end})

    -- POPULATE LOCAL
    local MoveSection = Tabs.Local:Section({Title = "Movement", Icon = "zap"})
    MoveSection:Slider({Title = "WalkSpeed", Value = 16, Min = 16, Max = 300, Step = 1, Callback = function(v) _G.SynthState.WalkSpeed = v end})
    MoveSection:Slider({Title = "JumpPower", Value = 50, Min = 50, Max = 500, Step = 1, Callback = function(v) _G.SynthState.JumpPower = v end})
    MoveSection:Toggle({Title = "NoClip", Value = false, Callback = function(v) _G.SynthState.NoClip = v end})
    
    local AntiHitSection = Tabs.Local:Section({Title = "Anti-Hit (CS:GO Style)", Icon = "shield-off"})
    AntiHitSection:Toggle({Title = "Spinbot (360)", Value = false, Callback = function(v) _G.SynthState.Spinbot = v end})
    AntiHitSection:Slider({Title = "Spin Speed", Value = 50, Min = 10, Max = 200, Step = 1, Callback = function(v) _G.SynthState.SpinSpeed = v end})

    -- SETTINGS
    local ConfigSection = Tabs.Settings:Section({Title = "Configuration", Icon = "file-text"})
    ConfigSection:Button({Title = "Save Config", Callback = function() Window.ConfigManager:CreateConfig() end})
    ConfigSection:Button({Title = "Load Config", Callback = function() Window.ConfigManager:LoadConfig() end})
    
    local ThemeSection = Tabs.Settings:Section({Title = "Theme", Icon = "palette"})
    ThemeSection:Dropdown({Title = "Select Theme", Values = {"Dark", "Light", "Abyss", "Aqua"}, Value = "Dark", Callback = function(v) Window:SetTheme(v) end})

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
    WindUI:Notify({Title = "Synthesis MEGA", Content = "Advanced Engine Loaded. Silent Aim & Spinbot ready.", Duration = 7, Icon = "check-circle"})
end)

if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Fatal Error", Text = tostring(err), Duration = 20})
end
