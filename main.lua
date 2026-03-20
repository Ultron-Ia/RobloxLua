if not game:IsLoaded() then game.Loaded:Wait() end
local playersExist, _ = pcall(function() return game:GetService("\080\108\097\121\101\114\115") end)
if not playersExist then return end
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local success, err = pcall(function()
 local Window = WindUI:CreateWindow({
 Title = "\069\084\069\082\078\065\076",
 Icon = "\115\104\105\101\108\100",
 Author = "\069\116\101\114\110\097\108\032\084\101\097\109",
 Folder = "\069\116\101\114\110\097\108\072\117\098",
 Size = UDim2.fromOffset(580, 460),
 Transparent = true,
 Theme = "\068\097\114\107",
 Keybind = Enum.KeyCode.Insert,
 ToggleKey = Enum.KeyCode.Insert
 })
 local Players = game:GetService("\080\108\097\121\101\114\115")
 local RunService = game:GetService("\082\117\110\083\101\114\118\105\099\101")
 local UserInputService = game:GetService("\085\115\101\114\073\110\112\117\116\083\101\114\118\105\099\101")
 local ReplicatedStorage = game:GetService("\082\101\112\108\105\099\097\116\101\100\083\116\111\114\097\103\101")
 local LocalPlayer = Players.LocalPlayer
 local Camera = workspace.CurrentCamera
 _G.EternalState = {
 AimEnabled = false,
 SilentAim = false,
 AimPart = "\072\101\097\100",
 AimFOV = 100,
 AimSmooth = 3,
 BoxESP = false,
 NameESP = false,
 DistESP = false,
 SkeletonESP = false,
 SkeletonColor = Color3.fromRGB(255, 255, 255),
 ProjESP = false,
 Chams = false,
 ChamsMat = "\078\101\111\110",
 ChamsColor = Color3.fromRGB(180, 100, 255),
 WalkSpeed = 16,
 JumpPower = 50,
 NoClip = false,
 Spinbot = false,
 SpinSpeed = 50,
 TargetPlayer = "\078\111\110\101"
 }
 local Tabs = {
 Main = Window:Tab({ Title = "\076\111\097\100\101\114", Icon = "\103\097\109\101\112\097\100\045\050" }),
 Aimbot = Window:Tab({ Title = "\065\105\109\098\111\116", Icon = "\099\114\111\115\115\104\097\105\114" }),
 Visuals = Window:Tab({ Title = "\086\105\115\117\097\108\115", Icon = "\101\121\101" }),
 Local = Window:Tab({ Title = "\076\111\099\097\108", Icon = "\117\115\101\114" }),
 Settings = Window:Tab({ Title = "\083\101\116\116\105\110\103\115", Icon = "\115\101\116\116\105\110\103\115" })
 }
 local BuiltHubs = {}
 local function GetPlayers()
 local list = {}
 for _, v in pairs(Players:GetPlayers()) do 
 if v ~= LocalPlayer then table.insert(list, v.Name) end 
 end
 if #list == 0 then table.insert(list, "\078\111\110\101") end
 return list
 end
 local function ElephantScare(emoji, r, g, b, screamText, duration)
 pcall(function()
 local sg = Instance.new("\083\099\114\101\101\110\071\117\105")
 sg.Name = "\069\116\101\114\110\097\108\074\117\109\112\115\099\097\114\101"
 sg.IgnoreGuiInset = true
 sg.ResetOnSpawn = false
 sg.Parent = LocalPlayer.PlayerGui
 local bg = Instance.new("\070\114\097\109\101", sg)
 bg.Size = UDim2.fromScale(1, 1)
 bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
 bg.ZIndex = 10
 local lbl = Instance.new("\084\101\120\116\076\097\098\101\108", bg)
 lbl.Size = UDim2.fromScale(1, 1)
 lbl.BackgroundTransparency = 1
 lbl.Text = emoji
 lbl.TextScaled = true
 lbl.TextColor3 = Color3.fromRGB(r, g, b)
 lbl.Font = Enum.Font.GothamBold
 lbl.ZIndex = 11
 local scream = Instance.new("\084\101\120\116\076\097\098\101\108", bg)
 scream.Size = UDim2.new(1, 0, 0.2, 0)
 scream.Position = UDim2.new(0, 0, 0.8, 0)
 scream.BackgroundTransparency = 1
 scream.Text = screamText
 scream.TextScaled = true
 scream.TextColor3 = Color3.fromRGB(255, 50, 50)
 scream.Font = Enum.Font.GothamBold
 scream.ZIndex = 12
 for i = 1, 8 do
 bg.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(r/2, g/2, b/2) or Color3.fromRGB(0, 0, 0)
 task.wait(0.07)
 end
 task.wait(duration)
 sg:Destroy()
 end)
 end
 Tabs.Main:Section({ Title = "\071\097\109\101\032\083\101\108\101\099\116\105\111\110" })
 Tabs.Main:Paragraph({ Title = "\077\097\110\117\097\108\032\076\111\097\100\105\110\103", Content = "\083\101\108\101\099\105\111\110\101\032\111\032\106\111\103\111\032\097\098\097\105\120\111\032\112\097\114\097\032\099\097\114\114\101\103\097\114\032\097\115\032\102\117\110\231\245\101\115\032\101\115\112\101\099\237\102\105\099\097\115\046" })
 local GameSelector = Tabs.Main:Dropdown({ 
 Title = "\083\101\108\101\099\116\032\071\097\109\101\032\077\111\100\117\108\101", 
 Values = {"\046\046\046", "\082\105\118\097\108\115", "\066\114\111\111\107\104\097\118\101\110", "\068\097\110\100\121\039\115\032\087\111\114\108\100", "\083\111\099\105\097\108\047\084\097\108\107\105\110\103\032\072\117\098", "\091\076\085\067\075\089\032\067\079\087\065\082\068\093\032\083\104\101\110\097\110\105\103\097\110\115\032\100\101\032\074\117\106\117\116\115\117", "\080\101\231\097\032\100\101\032\083\097\105\108\111\114"}, 
 Default = "\046\046\046",
 Callback = function(v)
 if v == "\082\105\118\097\108\115" and not BuiltHubs["\082\105\118\097\108\115"] then
 BuiltHubs["\082\105\118\097\108\115"] = true
 local RTab = Window:Tab({ Title = "\082\105\118\097\108\115\032\072\117\098", Icon = "\115\119\111\114\100\115" })
 RTab:Toggle({Title = "\065\117\116\111\032\080\097\114\114\121", Default = false})
 RTab:Button({Title = "\085\110\108\111\099\107\032\065\108\108\032\083\107\105\110\115\032\038\032\087\101\097\112\111\110\115", Callback = function()
 WindUI:Notify({Title="\082\105\118\097\108\115", Content="\076\105\098\101\114\097\110\100\111\032\105\110\118\101\110\116\225\114\105\111\046\046\046", Duration=3, Icon = "\112\097\099\107\097\103\101"})
 pcall(function()
 for _, m in pairs(ReplicatedStorage:GetDescendants()) do
 if m:IsA("\077\111\100\117\108\101\083\099\114\105\112\116") and (m.Name:find("\073\116\101\109") or m.Name:find("\083\107\105\110")) then
 local d = require(m)
 if type(d) == "\116\097\098\108\101" then for _, i in pairs(d) do if type(i) == "\116\097\098\108\101" then i.Owned = true; i.Unlocked = true end end end
 end
 end
 end)
 end})
 elseif v == "\066\114\111\111\107\104\097\118\101\110" and not BuiltHubs["\066\114\111\111\107\104\097\118\101\110"] then
 BuiltHubs["\066\114\111\111\107\104\097\118\101\110"] = true
 local BTab = Window:Tab({ Title = "\066\114\111\111\107\104\097\118\101\110\032\072\117\098", Icon = "\104\111\109\101" })
 local BPD = BTab:Dropdown({Title = "\084\097\114\103\101\116\032\080\108\097\121\101\114", Values = GetPlayers(), Default = 1, Callback = function(val) _G.EternalState.TargetPlayer = val end})
 BTab:Button({Title = "\082\101\102\114\101\115\104\032\080\108\097\121\101\114\032\076\105\115\116", Callback = function() BPD:Refresh(GetPlayers(), true) end})
 BTab:Section({ Title = "\084\097\114\103\101\116\032\065\099\116\105\111\110\115" })
 BTab:Button({Title = "\084\101\108\101\112\111\114\116\032\084\111\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") and LocalPlayer.Character then
 LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
 end
 end})
 BTab:Button({Title = "\067\111\112\121\032\079\117\116\102\105\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and LocalPlayer.Character then
 for _, i in pairs(LocalPlayer.Character:GetChildren()) do 
 if i:IsA("\083\104\105\114\116") or i:IsA("\080\097\110\116\115") or i:IsA("\065\099\099\101\115\115\111\114\121") or i:IsA("\072\097\116") or i:IsA("\083\104\105\114\116\071\114\097\112\104\105\099") or i:IsA("\066\111\100\121\067\111\108\111\114\115") or i:IsA("\067\104\097\114\097\099\116\101\114\077\101\115\104") then i:Destroy() end 
 end
 if LocalPlayer.Character:FindFirstChild("\072\101\097\100") then
 for _, v in pairs(LocalPlayer.Character.Head:GetChildren()) do if v:IsA("\068\101\099\097\108") or v:IsA("\083\112\101\099\105\097\108\077\101\115\104") then v:Destroy() end end
 end
 for _, i in pairs(t.Character:GetChildren()) do 
 if i:IsA("\083\104\105\114\116") or i:IsA("\080\097\110\116\115") or i:IsA("\066\111\100\121\067\111\108\111\114\115") or i:IsA("\067\104\097\114\097\099\116\101\114\077\101\115\104") or i:IsA("\083\104\105\114\116\071\114\097\112\104\105\099") then 
 local clone = i:Clone()
 if clone then clone.Parent = LocalPlayer.Character end
 elseif i:IsA("\065\099\099\101\115\115\111\114\121") or i:IsA("\072\097\116") then
 local clone = i:Clone()
 if clone then
 clone.Parent = LocalPlayer.Character
 local targetHead = t.Character:FindFirstChild("\072\101\097\100")
 if targetHead then
 local offset = targetHead.CFrame:ToObjectSpace(originalHandle.CFrame)
 handle.CFrame = head.CFrame * offset
 local weld = Instance.new("\087\101\108\100\067\111\110\115\116\114\097\105\110\116")
 weld.Part0 = head
 weld.Part1 = handle
 weld.Parent = handle
 end
 end
 end
 end
 end 
 end
 if t.Character:FindFirstChild("\072\101\097\100") and LocalPlayer.Character:FindFirstChild("\072\101\097\100") then
 for _, v in pairs(t.Character.Head:GetChildren()) do 
 if v:IsA("\068\101\099\097\108") or v:IsA("\083\112\101\099\105\097\108\077\101\115\104") then 
 local clone = v:Clone()
 if clone then clone.Parent = LocalPlayer.Character.Head end
 end 
 end
 end
 for _, part in pairs(t.Character:GetChildren()) do
 if part:IsA("\077\101\115\104\080\097\114\116") then
 local myPart = LocalPlayer.Character:FindFirstChild(part.Name)
 if myPart and myPart:IsA("\077\101\115\104\080\097\114\116") then
 pcall(function()
 myPart.MeshId = part.MeshId
 myPart.TextureID = part.TextureID
 myPart.Size = part.Size
 myPart.Color = part.Color
 end)
 end
 end
 end
 local tHum = t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
 local lHum = LocalPlayer.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
 if tHum and lHum then
 local scales = {"\066\111\100\121\068\101\112\116\104\083\099\097\108\101", "\066\111\100\121\072\101\105\103\104\116\083\099\097\108\101", "\066\111\100\121\087\105\100\116\104\083\099\097\108\101", "\066\111\100\121\080\114\111\112\111\114\116\105\111\110\083\099\097\108\101", "\066\111\100\121\084\121\112\101\083\099\097\108\101", "\072\101\097\100\083\099\097\108\101"}
 for _, scaleName in pairs(scales) do
 local tScale = tHum:FindFirstChild(scaleName)
 if tScale and tScale:IsA("\078\117\109\098\101\114\086\097\108\117\101") then
 local lScale = lHum:FindFirstChild(scaleName)
 if lScale and lScale:IsA("\078\117\109\098\101\114\086\097\108\117\101") then
 lScale.Value = tScale.Value
 else
 local cloneScale = tScale:Clone()
 cloneScale.Parent = lHum
 end
 end
 end
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
 BTab:Section({ Title = "\084\114\111\108\108\032\038\032\085\116\105\108\105\116\105\101\115" })
 local controlClone = nil
 BTab:Toggle({Title = "\067\111\110\116\114\111\108\032\080\108\097\121\101\114\032\040\087\101\108\100\032\066\117\103\041", Default = false, Callback = function(v)
 if v then
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and LocalPlayer.Character then
 local lHead = LocalPlayer.Character:FindFirstChild("\072\101\097\100")
 if lHead then
 for _, acc in pairs(t.Character:GetChildren()) do
 if acc:IsA("\065\099\099\101\115\115\111\114\121") or acc:IsA("\072\097\116") then
 local clone = acc:Clone()
 if clone then
 clone.Parent = LocalPlayer.Character
 controlClone = clone 
 local handle = clone:FindFirstChild("\072\097\110\100\108\101")
 if handle then
 BTab:Button({Title = "\9888\65039\032\075\105\099\107\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t then
 pcall(function()
 for _, r in pairs(ReplicatedStorage:GetDescendants()) do
 if r:IsA("\082\101\109\111\116\101\069\118\101\110\116") and (r.Name:lower():find("\107\105\099\107") or r.Name:lower():find("\098\097\110")) then
 r:FireServer(t)
 end
 end
 t:Kick("\089\111\117\032\104\097\118\101\032\098\101\101\110\032\114\101\109\111\118\101\100\032\098\121\032\097\110\032\097\100\109\105\110\046")
 end)
 WindUI:Notify({Title="\9888\65039\032\075\105\099\107", Content="\065\116\116\101\109\112\116\101\100\032\116\111\032\107\105\099\107\032" .. _G.EternalState.TargetPlayer, Duration=4, Icon = "\097\108\101\114\116\045\116\114\105\097\110\103\108\101"})
 end
 end})
 BTab:Button({Title = "\9762\65039\032\069\120\112\108\111\100\101\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local hrp = t.Character.HumanoidRootPart
 local exp = Instance.new("\069\120\112\108\111\115\105\111\110")
 exp.Position = hrp.Position
 exp.BlastRadius = 20
 exp.BlastPressure = 5000000
 exp.DestroyJointRadiusPercent = 0
 exp.Parent = workspace
 pcall(function()
 local bf = Instance.new("\066\111\100\121\070\111\114\099\101")
 bf.Force = Vector3.new(0, 9999999, 0)
 bf.Parent = hrp
 task.delay(0.2, function() bf:Destroy() end)
 end)
 WindUI:Notify({Title="\9762\65039\032\069\120\112\108\111\100\101", Content="\069\120\112\108\111\100\101\100\032" .. _G.EternalState.TargetPlayer, Duration=3, Icon = "\098\111\109\098"})
 end
 end})
 BTab:Button({Title = "\9762\65039\032\082\097\103\100\111\108\108\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character then
 for _, v in pairs(t.Character:GetDescendants()) do
 if v:IsA("\077\111\116\111\114\054\068") then
 pcall(function()
 local a0 = Instance.new("\065\116\116\097\099\104\109\101\110\116", v.Part0)
 local a1 = Instance.new("\065\116\116\097\099\104\109\101\110\116", v.Part1)
 local bs = Instance.new("\066\097\108\108\083\111\099\107\101\116\067\111\110\115\116\114\097\105\110\116")
 bs.Attachment0 = a0
 bs.Attachment1 = a1
 bs.Parent = v.Part0
 v.Enabled = false
 end)
 end
 end
 if t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 t.Character.Humanoid.Health = 0
 end
 WindUI:Notify({Title="\9762\65039\032\082\097\103\100\111\108\108", Content="\082\097\103\100\111\108\108\101\100\032" .. _G.EternalState.TargetPlayer, Duration=3, Icon = "\097\099\116\105\118\105\116\121"})
 end
 end})
 BTab:Button({Title = "\129522\032\070\108\105\110\103\032\084\097\114\103\101\116\032\040\075\105\108\108\032\118\105\097\032\072\101\105\103\104\116\041", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local hrp = t.Character.HumanoidRootPart
 pcall(function()
 local bv = Instance.new("\066\111\100\121\086\101\108\111\099\105\116\121")
 bv.Velocity = Vector3.new(math.random(-300,300), 9999, math.random(-300,300))
 bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
 bv.Parent = hrp
 task.delay(0.5, function() bv:Destroy() end)
 end)
 WindUI:Notify({Title="\129522\032\070\108\105\110\103", Content="\070\108\117\110\103\032" .. _G.EternalState.TargetPlayer, Duration=3, Icon = "\119\105\110\100"})
 end
 end})
 local floatLoop = nil
 BTab:Toggle({Title = "\129522\032\070\108\111\097\116\032\084\097\114\103\101\116\032\040\076\111\111\112\041", Default = false, Callback = function(v)
 if v then
 floatLoop = RunService.Heartbeat:Connect(function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
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
 end
 })
 BTab:Button({Title = "\127993\032\076\097\117\110\099\104\032\084\097\114\103\101\116\032\040\073\110\116\111\032\083\112\097\099\101\041", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local hrp = t.Character.HumanoidRootPart
 pcall(function()
 local bv = Instance.new("\066\111\100\121\086\101\108\111\099\105\116\121")
 bv.Velocity = Vector3.new(0, 99999, 0)
 bv.MaxForce = Vector3.new(0, math.huge, 0)
 bv.Parent = hrp
 task.delay(1, function() bv:Destroy() end)
 end)
 WindUI:Notify({Title="\127993\032\076\097\117\110\099\104", Content="\076\097\117\110\099\104\101\100\032" .. _G.EternalState.TargetPlayer .. "\032\105\110\116\111\032\111\114\098\105\116\033", Duration=3, Icon = "\114\111\099\107\101\116"})
 end
 end})
 BTab:Button({Title = "\127993\032\065\110\103\101\108\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local hrp = t.Character.HumanoidRootPart
 pcall(function()
 local hl = t.Character:FindFirstChild("\065\110\103\101\108\072\076") or Instance.new("\072\105\103\104\108\105\103\104\116", t.Character)
 hl.Name = "\065\110\103\101\108\072\076"
 hl.FillColor = Color3.fromRGB(255, 255, 255)
 hl.OutlineColor = Color3.fromRGB(200, 200, 255)
 hl.FillTransparency = 0.3
 end)
 pcall(function()
 hrp.CFrame = hrp.CFrame + Vector3.new(0, 200, 0)
 hrp.Anchored = true
 task.delay(8, function()
 pcall(function() hrp.Anchored = false end)
 end)
 end)
 if t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 t.Character.Humanoid.Health = 0
 end
 WindUI:Notify({Title="\127993\032\065\110\103\101\108", Content=_G.EternalState.TargetPlayer .. "\032\104\097\115\032\098\101\099\111\109\101\032\097\110\032\097\110\103\101\108\033", Duration=4, Icon = "\115\117\110"})
 end
 end})
 BTab:Button({Title = "\128128\032\075\105\108\108\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 t.Character.Humanoid.Health = 0
 WindUI:Notify({Title="\128128\032\075\105\108\108", Content="\075\105\108\108\101\100\032" .. _G.EternalState.TargetPlayer, Duration=3, Icon = "\115\107\117\108\108"})
 end
 end})
 BTab:Button({Title = "\128128\032\075\105\108\108\080\108\117\115\032\040\069\120\112\108\111\115\105\111\110\032\069\102\102\101\099\116\041", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local hrp = t.Character.HumanoidRootPart
 local exp = Instance.new("\069\120\112\108\111\115\105\111\110")
 exp.Position = hrp.Position
 exp.BlastRadius = 10
 exp.BlastPressure = 1000000
 exp.DestroyJointRadiusPercent = 0
 exp.Parent = workspace
 if t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 t.Character.Humanoid.Health = 0
 end
 WindUI:Notify({Title="\128128\032\075\105\108\108\080\108\117\115", Content=_G.EternalState.TargetPlayer .. "\032\101\108\105\109\105\110\097\116\101\100\033", Duration=3, Icon = "\098\111\109\098"})
 end
 end})
 BTab:Button({Title = "\128274\032\074\097\105\108\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local pos = t.Character.HumanoidRootPart.Position
 local walls = {
 {CFrame.new(pos + Vector3.new(4, 2, 0)), Vector3.new(0.5, 6, 8)},
 {CFrame.new(pos + Vector3.new(-4, 2, 0)), Vector3.new(0.5, 6, 8)},
 {CFrame.new(pos + Vector3.new(0, 2, 4)), Vector3.new(8, 6, 0.5)},
 {CFrame.new(pos + Vector3.new(0, 2, -4)), Vector3.new(8, 6, 0.5)},
 {CFrame.new(pos + Vector3.new(0, 5, 0)), Vector3.new(8, 0.5, 8)},
 }
 for _, wallData in pairs(walls) do
 local part = Instance.new("\080\097\114\116")
 part.Anchored = true
 part.CanCollide = true
 part.Size = wallData[2]
 part.CFrame = wallData[1]
 part.BrickColor = BrickColor.new("\068\097\114\107\032\111\114\097\110\103\101")
 part.Material = Enum.Material.SmoothPlastic
 part.Transparency = 0.4
 part.Name = "\069\116\101\114\110\097\108\074\097\105\108\087\097\108\108"
 part.Parent = workspace
 game:GetService("\068\101\098\114\105\115"):AddItem(part, 30)
 end
 WindUI:Notify({Title="\128274\032\074\097\105\108", Content=_G.EternalState.TargetPlayer .. "\032\104\097\115\032\098\101\101\110\032\106\097\105\108\101\100\033", Duration=4, Icon = "\108\111\099\107"})
 end
 end})
 local freezeLoop = nil
 BTab:Toggle({Title = "\128274\032\070\114\101\101\122\101\032\084\097\114\103\101\116\032\040\076\111\111\112\041", Default = false, Callback = function(v)
 if v then
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local frozenCFrame = t.Character.HumanoidRootPart.CFrame
 freezeLoop = RunService.Heartbeat:Connect(function()
 local target = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if target and target.Character and target.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 pcall(function()
 target.Character.HumanoidRootPart.CFrame = frozenCFrame
 target.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
 end)
 if target.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 target.Character.Humanoid.WalkSpeed = 0
 target.Character.Humanoid.JumpPower = 0
 end
 end
 end)
 end
 else
 if freezeLoop then freezeLoop:Disconnect(); freezeLoop = nil end
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 t.Character.Humanoid.WalkSpeed = 16
 t.Character.Humanoid.JumpPower = 50
 end
 end
 end
 })
 local loopKillConn = nil
 BTab:Toggle({Title = "\128257\032\076\111\111\112\032\075\105\108\108\032\084\097\114\103\101\116", Default = false, Callback = function(v)
 if v then
 loopKillConn = RunService.Heartbeat:Connect(function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 t.Character.Humanoid.Health = 0
 end
 end)
 else
 if loopKillConn then loopKillConn:Disconnect(); loopKillConn = nil end
 end
 end
 })
 local bLoopSit2 = nil
 BTab:Toggle({Title = "\128257\032\076\111\111\112\032\083\105\116\032\111\110\032\084\097\114\103\101\116\032\040\065\110\110\111\121\041", Default = false, Callback = function(v)
 if v then
 bLoopSit2 = RunService.Heartbeat:Connect(function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\101\097\100") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame * CFrame.new(0, 1.5, 0)
 if LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then
 LocalPlayer.Character.Humanoid.Sit = true
 end
 end
 end)
 else
 if bLoopSit2 then bLoopSit2:Disconnect(); bLoopSit2 = nil end
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then
 LocalPlayer.Character.Humanoid.Sit = false
 end
 end
 end
 })
 BTab:Section({ Title = "\127875\032\072\111\114\114\111\114\032\067\111\109\109\097\110\100\115" })
 BTab:Button({Title = "\129668\032\084\104\101\032\066\097\099\107\114\111\111\109\115\032\040\066\097\110\105\115\104\041", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 pcall(function()
 t.Character.HumanoidRootPart.CFrame = CFrame.new(99999, 100, 99999)
 end)
 pcall(function()
 local lighting = game:GetService("\076\105\103\104\116\105\110\103")
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
 WindUI:Notify({Title="\129668\032\066\097\099\107\114\111\111\109\115", Content=_G.EternalState.TargetPlayer .. "\032\104\097\115\032\098\101\101\110\032\098\097\110\105\115\104\101\100\032\116\111\032\084\104\101\032\066\097\099\107\114\111\111\109\115\046\046\046", Duration=5, Icon = "\103\104\111\115\116"})
 end
 end})
 BTab:Button({Title = "\129503\032\074\117\109\112\115\099\097\114\101\058\032\069\121\101\115", Callback = function()
 pcall(function()
 local sg = Instance.new("\083\099\114\101\101\110\071\117\105")
 sg.Name = "\069\116\101\114\110\097\108\074\117\109\112\115\099\097\114\101"
 sg.IgnoreGuiInset = true
 sg.ResetOnSpawn = false
 sg.Parent = LocalPlayer.PlayerGui
 local bg = Instance.new("\070\114\097\109\101", sg)
 bg.Size = UDim2.fromScale(1, 1)
 bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
 bg.BackgroundTransparency = 0
 bg.ZIndex = 10
 local eyes = Instance.new("\084\101\120\116\076\097\098\101\108", bg)
 eyes.Size = UDim2.fromScale(1, 1)
 eyes.Position = UDim2.fromScale(0, 0)
 eyes.BackgroundTransparency = 1
 eyes.Text = "👀"
 eyes.TextScaled = true
 eyes.TextColor3 = Color3.fromRGB(255, 0, 0)
 eyes.Font = Enum.Font.GothamBold
 eyes.ZIndex = 11
 for i = 1, 6 do
 bg.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 0)
 task.wait(0.08)
 end
 task.wait(0.5)
 sg:Destroy()
 end)
 WindUI:Notify({Title="\129503\032\074\117\109\112\115\099\097\114\101", Content="\069\089\069\083\032\106\117\109\112\115\099\097\114\101\032\116\114\105\103\103\101\114\101\100\033", Duration=2, Icon = "\101\121\101"})
 end})
 BTab:Button({Title = "\129503\032\074\117\109\112\115\099\097\114\101\058\032\090\111\109\098\105\101", Callback = function() ElephantScare("🧟", 50, 180, 0, "\066\082\065\065\073\073\073\078\083\046\046\046", 0.8) WindUI:Notify({Title="\129503\032\074\117\109\112\115\099\097\114\101", Content="\090\079\077\066\073\069\032\106\117\109\112\115\099\097\114\101\032\116\114\105\103\103\101\114\101\100\033", Duration=2, Icon = "\115\107\117\108\108"}) end})
 BTab:Button({Title = "\129503\032\074\117\109\112\115\099\097\114\101\058\032\071\104\111\115\116", Callback = function() ElephantScare("👻", 200, 200, 255, "\066\079\079\033", 0.6) WindUI:Notify({Title="\129503\032\074\117\109\112\115\099\097\114\101", Content="\071\072\079\083\084\032\106\117\109\112\115\099\097\114\101\032\116\114\105\103\103\101\114\101\100\033", Duration=2, Icon = "\103\104\111\115\116"}) end})
 BTab:Button({Title = "\129503\032\074\117\109\112\115\099\097\114\101\058\032\066\097\099\107\114\111\111\109\115", Callback = function() ElephantScare("🟨", 210, 190, 130, "\076\101\118\101\108\032\048\032\8212\032\084\104\101\032\066\097\099\107\114\111\111\109\115", 1.5) WindUI:Notify({Title="\127875\032\074\117\109\112\115\099\097\114\101", Content="\066\065\067\075\082\079\079\077\083\032\106\117\109\112\115\099\097\114\101\032\116\114\105\103\103\101\114\101\100\033", Duration=2, Icon = "\103\104\111\115\116"}) end})
 elseif v == "\080\101\231\097\032\100\101\032\083\097\105\108\111\114" and not BuiltHubs["\080\101\099\097\068\101\083\097\105\108\111\114"] then
 BuiltHubs["\080\101\099\097\068\101\083\097\105\108\111\114"] = true
 local STab = Window:Tab({ Title = "\083\097\105\108\111\114\032\072\117\098", Icon = "\115\116\097\114" })
 local SPD = STab:Dropdown({Title = "\084\097\114\103\101\116\032\080\108\097\121\101\114", Values = GetPlayers(), Value = 1, Callback = function(val) _G.EternalState.TargetPlayer = val end})
 STab:Button({Title = "\128260\032\082\101\102\114\101\115\104\032\080\108\097\121\101\114\032\076\105\115\116", Callback = function() SPD:Refresh(GetPlayers(), true) end})
 STab:Section({ Title = "\127968\032\080\108\097\121\101\114\032\065\099\116\105\111\110\115" })
 STab:Button({Title = "\9889\032\084\101\108\101\112\111\114\116\032\084\111\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") and LocalPlayer.Character then
 LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
 end
 end})
 STab:Button({Title = "\128087\032\067\111\112\121\032\079\117\116\102\105\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and LocalPlayer.Character then
 for _, i in pairs(LocalPlayer.Character:GetChildren()) do
 if i:IsA("\083\104\105\114\116") or i:IsA("\080\097\110\116\115") or i:IsA("\065\099\099\101\115\115\111\114\121") or i:IsA("\072\097\116") or i:IsA("\083\104\105\114\116\071\114\097\112\104\105\099") or i:IsA("\066\111\100\121\067\111\108\111\114\115") or i:IsA("\067\104\097\114\097\099\116\101\114\077\101\115\104") then i:Destroy() end
 end
 for _, i in pairs(t.Character:GetChildren()) do
 if i:IsA("\083\104\105\114\116") or i:IsA("\080\097\110\116\115") or i:IsA("\066\111\100\121\067\111\108\111\114\115") or i:IsA("\067\104\097\114\097\099\116\101\114\077\101\115\104") or i:IsA("\083\104\105\114\116\071\114\097\112\104\105\099") then
 local clone = i:Clone(); if clone then clone.Parent = LocalPlayer.Character end
 elseif i:IsA("\065\099\099\101\115\115\111\114\121") or i:IsA("\072\097\116") then
 local clone = i:Clone()
 if clone then
 clone.Parent = LocalPlayer.Character
 local handle = clone:FindFirstChild("\072\097\110\100\108\101")
 local head = LocalPlayer.Character:FindFirstChild("\072\101\097\100")
 if handle and head then
 for _, v2 in pairs(handle:GetChildren()) do
 if v2:IsA("\087\101\108\100") or v2:IsA("\087\101\108\100\067\111\110\115\116\114\097\105\110\116") or v2:IsA("\077\111\116\111\114\054\068") then v2:Destroy() end
 end
 handle.CanCollide = false; handle.Massless = true
 local oh = i:FindFirstChild("\072\097\110\100\108\101")
 local th = t.Character:FindFirstChild("\072\101\097\100")
 if oh and th then
 local offset = th.CFrame:ToObjectSpace(oh.CFrame)
 handle.CFrame = head.CFrame * offset
 local wc = Instance.new("\087\101\108\100\067\111\110\115\116\114\097\105\110\116")
 wc.Part0 = head; wc.Part1 = handle; wc.Parent = handle
 end
 end
 end
 end
 end
 WindUI:Notify({Title="\128087\032\079\117\116\102\105\116", Content="\079\117\116\102\105\116\032\099\111\112\105\097\100\111\032\100\101\032" .. _G.EternalState.TargetPlayer, Duration=3, Icon = "\115\104\105\114\116"})
 end
 end})
 local sailorAttachLoop = nil
 STab:Toggle({Title = "\128204\032\065\116\116\097\099\104\032\116\111\032\080\108\097\121\101\114\032\040\076\111\111\112\032\084\080\041", Value = false, Callback = function(v)
 if v then
 sailorAttachLoop = RunService.Heartbeat:Connect(function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
 end
 end)
 else
 if sailorAttachLoop then sailorAttachLoop:Disconnect(); sailorAttachLoop = nil end
 end
 end})
 local sailorSitLoop = nil
 STab:Toggle({Title = "\129681\032\083\105\116\032\111\110\032\084\097\114\103\101\116\039\115\032\072\101\097\100", Value = false, Callback = function(v)
 if v then
 sailorSitLoop = RunService.Heartbeat:Connect(function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\101\097\100") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame * CFrame.new(0, 1.5, 0)
 if LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then LocalPlayer.Character.Humanoid.Sit = true end
 end
 end)
 else
 if sailorSitLoop then sailorSitLoop:Disconnect(); sailorSitLoop = nil end
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then LocalPlayer.Character.Humanoid.Sit = false end
 end
 end})
 STab:Section({ Title = "\127775\032\076\111\099\097\108\032\083\097\105\108\111\114" })
 local sailorRGBLoop = nil
 STab:Toggle({Title = "\127752\032\082\097\105\110\098\111\119\047\082\071\066\032\067\104\097\114\097\099\116\101\114", Value = false, Callback = function(v)
 if v then
 sailorRGBLoop = RunService.RenderStepped:Connect(function()
 if LocalPlayer.Character then
 local hue = tick() % 1
 local color = Color3.fromHSV(hue, 1, 1)
 for _, part in pairs(LocalPlayer.Character:GetChildren()) do
 if part:IsA("\066\097\115\101\080\097\114\116") then part.Color = color end
 end
 end
 end)
 else
 if sailorRGBLoop then sailorRGBLoop:Disconnect(); sailorRGBLoop = nil end
 end
 end})
 STab:Button({Title = "\127769\032\083\097\105\108\111\114\032\077\111\111\110\032\065\117\114\097\032\040\083\101\108\102\041", Callback = function()
 if LocalPlayer.Character then
 local existing = LocalPlayer.Character:FindFirstChild("\083\097\105\108\111\114\065\117\114\097")
 if existing then existing:Destroy(); return end
 local hl = Instance.new("\072\105\103\104\108\105\103\104\116", LocalPlayer.Character)
 hl.Name = "\083\097\105\108\111\114\065\117\114\097"
 hl.FillColor = Color3.fromRGB(255, 100, 200)
 hl.OutlineColor = Color3.fromRGB(255, 255, 100)
 hl.FillTransparency = 0.3
 WindUI:Notify({Title="\127769\032\065\117\114\097", Content="\083\097\105\108\111\114\032\077\111\111\110\032\065\117\114\097\032\097\116\105\118\097\100\097\033\032\067\108\105\113\117\101\032\110\111\118\097\109\101\110\116\101\032\112\097\114\097\032\114\101\109\111\118\101\114\046", Duration=3, Icon = "\115\112\097\114\107\108\101\115"})
 end
 end})
 STab:Button({Title = "\128465\65039\032\082\101\109\111\118\101\032\078\097\109\101\032\084\097\103\032\040\065\110\111\110\041", Callback = function()
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\101\097\100") then
 for _, child in pairs(LocalPlayer.Character.Head:GetChildren()) do
 if child:IsA("\066\105\108\108\098\111\097\114\100\071\117\105") or child.Name:lower():match("\110\097\109\101") then child:Destroy() end
 end
 end
 WindUI:Notify({Title="\128465\65039\032\065\110\111\110", Content="\078\097\109\101\032\116\097\103\032\114\101\109\111\118\105\100\111\033", Duration=2, Icon = "\117\115\101\114\045\109\105\110\117\115"})
 end})
 STab:Button({Title = "\128176\032\086\105\115\117\097\108\032\073\110\102\105\110\105\116\101\032\077\111\110\101\121", Callback = function()
 pcall(function()
 for _, gui in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
 if gui:IsA("\084\101\120\116\076\097\098\101\108") and (gui.Text:find("%$") or gui.Text:find("\067\111\105\110\115") or gui.Text:find("\071\111\108\100") or gui.Text:find("\077\111\110\101\121")) then
 gui.Text = "\036\057\044\057\057\057\044\057\057\057"
 end
 end
 end)
 WindUI:Notify({Title="\128176\032\077\111\110\101\121", Content="\086\105\115\117\097\108\032\109\111\110\101\121\032\109\111\100\105\102\105\099\097\100\111\033", Duration=2, Icon = "\100\111\108\108\097\114\045\115\105\103\110"})
 end})
 STab:Section({ Title = "\9888\65039\032\065\100\109\105\110\032\067\111\109\109\097\110\100\115" })
 STab:Button({Title = "\128221\032\086\101\114\105\102\121\032\040\076\105\115\116\032\080\108\097\121\101\114\115\041", Callback = function()
 local msg = "\080\108\097\121\101\114\115\058\092\110"
 for _, p in pairs(Players:GetPlayers()) do
 msg = msg .. "• " .. p.Name .. "\032\040\073\068\058\032" .. p.UserId .. "\041\092\110"
 end
 WindUI:Notify({Title="\128221\032\086\101\114\105\102\121", Content=msg, Duration=10, Icon = "\116\101\114\109\105\110\097\108"})
 end})
 STab:Button({Title = "\128128\032\075\105\108\108\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 t.Character.Humanoid.Health = 0
 WindUI:Notify({Title="\128128\032\075\105\108\108", Content="\075\105\108\108\101\100\032" .. _G.EternalState.TargetPlayer, Duration=3, Icon = "\115\107\117\108\108"})
 end
 end})
 STab:Button({Title = "\128128\032\075\105\108\108\080\108\117\115\032\040\069\120\112\108\111\115\105\111\110\041", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local exp = Instance.new("\069\120\112\108\111\115\105\111\110")
 exp.Position = t.Character.HumanoidRootPart.Position
 exp.BlastRadius = 10; exp.BlastPressure = 1000000
 exp.DestroyJointRadiusPercent = 0; exp.Parent = workspace
 if t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then t.Character.Humanoid.Health = 0 end
 WindUI:Notify({Title="\128128\032\075\105\108\108\080\108\117\115", Content=_G.EternalState.TargetPlayer .. "\032\101\108\105\109\105\110\097\116\101\100\033", Duration=3, Icon = "\098\111\109\098"})
 end
 end})
 STab:Button({Title = "\129522\032\070\108\105\110\103\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 pcall(function()
 local bv = Instance.new("\066\111\100\121\086\101\108\111\099\105\116\121")
 bv.Velocity = Vector3.new(math.random(-300,300), 9999, math.random(-300,300))
 bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
 bv.Parent = t.Character.HumanoidRootPart
 task.delay(0.5, function() bv:Destroy() end)
 end)
 WindUI:Notify({Title="\129522\032\070\108\105\110\103", Content="\070\108\117\110\103\032" .. _G.EternalState.TargetPlayer, Duration=3, Icon = "\097\114\114\111\119\045\117\112"})
 end
 end})
 STab:Button({Title = "\9762\65039\032\069\120\112\108\111\100\101\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local exp = Instance.new("\069\120\112\108\111\115\105\111\110")
 exp.Position = t.Character.HumanoidRootPart.Position
 exp.BlastRadius = 20; exp.BlastPressure = 5000000
 exp.DestroyJointRadiusPercent = 0; exp.Parent = workspace
 WindUI:Notify({Title="\9762\65039\032\069\120\112\108\111\100\101", Content="\069\120\112\108\111\100\101\100\032" .. _G.EternalState.TargetPlayer, Duration=3, Icon = "\102\108\097\109\101"})
 end
 end})
 local sailorFreezeLoop = nil
 STab:Toggle({Title = "\128274\032\070\114\101\101\122\101\032\084\097\114\103\101\116\032\040\076\111\111\112\041", Value = false, Callback = function(v)
 if v then
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local frozenCF = t.Character.HumanoidRootPart.CFrame
 sailorFreezeLoop = RunService.Heartbeat:Connect(function()
 local tgt = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if tgt and tgt.Character and tgt.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 pcall(function()
 tgt.Character.HumanoidRootPart.CFrame = frozenCF
 tgt.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
 end)
 if tgt.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 tgt.Character.Humanoid.WalkSpeed = 0
 tgt.Character.Humanoid.JumpPower = 0
 end
 end
 end)
 end
 else
 if sailorFreezeLoop then sailorFreezeLoop:Disconnect(); sailorFreezeLoop = nil end
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 t.Character.Humanoid.WalkSpeed = 16
 t.Character.Humanoid.JumpPower = 50
 end
 end
 end})
 local sailorLoopKill = nil
 STab:Toggle({Title = "\128257\032\076\111\111\112\032\075\105\108\108\032\084\097\114\103\101\116", Value = false, Callback = function(v)
 if v then
 sailorLoopKill = RunService.Heartbeat:Connect(function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 t.Character.Humanoid.Health = 0
 end
 end)
 else
 if sailorLoopKill then sailorLoopKill:Disconnect(); sailorLoopKill = nil end
 end
 end})
 STab:Button({Title = "\128274\032\074\097\105\108\032\084\097\114\103\101\116", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local pos = t.Character.HumanoidRootPart.Position
 local walls = {
 {CFrame.new(pos + Vector3.new(4, 2, 0)), Vector3.new(0.5, 6, 8)},
 {CFrame.new(pos + Vector3.new(-4, 2, 0)), Vector3.new(0.5, 6, 8)},
 {CFrame.new(pos + Vector3.new(0, 2, 4)), Vector3.new(8, 6, 0.5)},
 {CFrame.new(pos + Vector3.new(0, 2, -4)), Vector3.new(8, 6, 0.5)},
 {CFrame.new(pos + Vector3.new(0, 5, 0)), Vector3.new(8, 0.5, 8)},
 }
 for _, wd in pairs(walls) do
 local part = Instance.new("\080\097\114\116")
 part.Anchored = true; part.CanCollide = true
 part.Size = wd[2]; part.CFrame = wd[1]
 part.BrickColor = BrickColor.new("\072\111\116\032\112\105\110\107")
 part.Material = Enum.Material.Neon
 part.Transparency = 0.4; part.Name = "\083\097\105\108\111\114\074\097\105\108"
 part.Parent = workspace
 game:GetService("\068\101\098\114\105\115"):AddItem(part, 30)
 end
 WindUI:Notify({Title="\128274\032\074\097\105\108", Content=_G.EternalState.TargetPlayer .. "\032\106\097\105\108\101\100\033", Duration=4, Icon = "\108\111\099\107"})
 end
 end})
 STab:Section({ Title = "\127875\032\072\111\114\114\111\114\032\067\111\109\109\097\110\100\115" })
 STab:Button({Title = "\129668\032\066\097\099\107\114\111\111\109\115\032\040\066\097\110\105\115\104\041", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 pcall(function() t.Character.HumanoidRootPart.CFrame = CFrame.new(99999, 100, 99999) end)
 pcall(function()
 local lighting = game:GetService("\076\105\103\104\116\105\110\103")
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
 WindUI:Notify({Title="\129668\032\066\097\099\107\114\111\111\109\115", Content=_G.EternalState.TargetPlayer .. "\032\098\097\110\105\115\104\101\100\033", Duration=5, Icon = "\103\104\111\115\116"})
 end
 end})
 local function SailorJumpscare(icon, flashR, flashG, flashB, text, delay_)
 ElephantScare(icon, flashR, flashG, flashB, text, delay_)
 end
 STab:Button({Title = "\129503\032\074\117\109\112\115\099\097\114\101\058\032\069\121\101\115", Callback = function() SailorJumpscare("👀", 255, 0, 0, "\079\076\072\065\078\068\079\032\080\065\082\065\032\086\079\067\202\046\046\046", 0.5) WindUI:Notify({Title="\129503\032\083\099\097\114\101", Content="\069\121\101\115\033", Duration=2, Icon = "\101\121\101"}) end})
 STab:Button({Title = "\129503\032\074\117\109\112\115\099\097\114\101\058\032\090\111\109\098\105\101", Callback = function() SailorJumpscare("🧟", 50, 180, 0, "\066\082\065\065\073\073\073\078\083\046\046\046", 0.8) WindUI:Notify({Title="\129503\032\083\099\097\114\101", Content="\090\111\109\098\105\101\033", Duration=2, Icon = "\115\107\117\108\108"}) end})
 STab:Button({Title = "\129503\032\074\117\109\112\115\099\097\114\101\058\032\071\104\111\115\116", Callback = function() SailorJumpscare("👻", 200, 200, 255,"\066\079\079\033", 0.6) WindUI:Notify({Title="\129503\032\083\099\097\114\101", Content="\071\104\111\115\116\033", Duration=2, Icon = "\103\104\111\115\116"}) end})
 STab:Button({Title = "\129503\032\074\117\109\112\115\099\097\114\101\058\032\066\097\099\107\114\111\111\109\115", Callback = function() SailorJumpscare("🟨", 210, 190, 130,"\076\101\118\101\108\032\048\032\8212\032\066\097\099\107\114\111\111\109\115", 1.5) WindUI:Notify({Title="\129503\032\083\099\097\114\101", Content="\066\097\099\107\114\111\111\109\115\033", Duration=2, Icon = "\103\104\111\115\116"}) end})
 elseif v == "\068\097\110\100\121\039\115\032\087\111\114\108\100" and not BuiltHubs["\068\097\110\100\121\115"] then
 BuiltHubs["\068\097\110\100\121\115"] = true
 local DTab = Window:Tab({ Title = "\068\097\110\100\121\032\072\117\098", Icon = "\102\108\111\119\101\114" })
 local DPD = DTab:Dropdown({Title = "\084\097\114\103\101\116\032\080\108\097\121\101\114", Values = GetPlayers(), Value = 1, Callback = function(val) _G.EternalState.TargetPlayer = val end})
 DTab:Button({Title = "\082\101\102\114\101\115\104\032\076\105\115\116", Callback = function() DPD:Refresh(GetPlayers(), true) end})
 DTab:Button({Title = "\067\111\112\121\032\083\107\105\110\032\040\076\111\099\097\108\032\077\111\100\101\108\041", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and LocalPlayer.Character then
 for _, i in pairs(LocalPlayer.Character:GetChildren()) do if i:IsA("\083\104\105\114\116") or i:IsA("\080\097\110\116\115") or i:IsA("\065\099\099\101\115\115\111\114\121") then i:Destroy() end end
 for _, i in pairs(t.Character:GetChildren()) do if i:IsA("\083\104\105\114\116") or i:IsA("\080\097\110\116\115") or i:IsA("\065\099\099\101\115\115\111\114\121") then i:Clone().Parent = LocalPlayer.Character end end
 end
 end})
 DTab:Button({Title = "\082\101\115\116\111\114\101\032\077\097\120\032\083\116\097\109\105\110\097\032\040\066\069\084\065\041", Callback = function()
 pcall(function()
 local c = LocalPlayer.Character
 if c then
 if c:GetAttribute("\083\116\097\109\105\110\097") then c:SetAttribute("\083\116\097\109\105\110\097", 100) end
 local sv = c:FindFirstChild("\083\116\097\109\105\110\097") or c:FindFirstChild("\115\116\097\109\105\110\097")
 if sv and (sv:IsA("\073\110\116\086\097\108\117\101") or sv:IsA("\078\117\109\098\101\114\086\097\108\117\101")) then sv.Value = 100 end
 end
 if LocalPlayer:GetAttribute("\083\116\097\109\105\110\097") then LocalPlayer:SetAttribute("\083\116\097\109\105\110\097", 100) end
 end)
 WindUI:Notify({Title="\068\097\110\100\121\039\115\032\087\111\114\108\100", Content="\083\116\097\109\105\110\097\032\114\101\115\116\111\114\101\032\097\116\116\101\109\112\116\101\100\033", Duration=3, Icon = "\122\097\112"})
 end})
 DTab:Section({ Title = "\087\111\114\108\100\032\086\105\115\117\097\108\115" })
 DTab:Toggle({Title = "\077\111\110\115\116\101\114\047\069\110\116\105\116\121\032\069\083\080", Value = false, Callback = function(v) _G.EternalState.DandyESP = v end})
 DTab:Toggle({Title = "\073\116\101\109\047\076\111\111\116\032\069\083\080", Value = false, Callback = function(v) _G.EternalState.DandyItemESP = v end})
 task.spawn(function()
 while task.wait(1) do
 if _G.EternalState.DandyESP then
 for _, obj in pairs(workspace:GetDescendants()) do
 if obj:IsA("\077\111\100\101\108") and obj:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") and not Players:GetPlayerFromCharacter(obj) then
 if not obj:FindFirstChild("\069\116\101\114\110\097\108\069\110\116\105\116\121\069\083\080") then
 local hl = Instance.new("\072\105\103\104\108\105\103\104\116", obj)
 hl.Name = "\069\116\101\114\110\097\108\069\110\116\105\116\121\069\083\080"; hl.FillColor = Color3.fromRGB(255, 0, 0)
 end
 end
 end
 else
 for _, obj in pairs(workspace:GetDescendants()) do
 if obj:IsA("\077\111\100\101\108") and obj:FindFirstChild("\069\116\101\114\110\097\108\069\110\116\105\116\121\069\083\080") then obj.EternalEntityESP:Destroy() end
 end
 end
 if _G.EternalState.DandyItemESP then
 for _, obj in pairs(workspace:GetDescendants()) do
 if (obj:IsA("\080\114\111\120\105\109\105\116\121\080\114\111\109\112\116") and obj.Parent and obj.Parent:IsA("\066\097\115\101\080\097\114\116")) or (obj:IsA("\084\111\111\108") and obj:FindFirstChild("\072\097\110\100\108\101")) then
 local target = obj:IsA("\080\114\111\120\105\109\105\116\121\080\114\111\109\112\116") and obj.Parent or obj
 if not target:FindFirstChild("\069\116\101\114\110\097\108\073\116\101\109\069\083\080") then
 local hl = Instance.new("\072\105\103\104\108\105\103\104\116", target)
 hl.Name = "\069\116\101\114\110\097\108\073\116\101\109\069\083\080"; hl.FillColor = Color3.fromRGB(0, 255, 100)
 end
 end
 end
 else
 for _, obj in pairs(workspace:GetDescendants()) do
 if obj:FindFirstChild("\069\116\101\114\110\097\108\073\116\101\109\069\083\080") then obj.EternalItemESP:Destroy() end
 end
 end
 end
 end)
 elseif v == "\083\111\099\105\097\108\047\084\097\108\107\105\110\103\032\072\117\098" and not BuiltHubs["\083\111\099\105\097\108"] then
 BuiltHubs["\083\111\099\105\097\108"] = true
 local STab = Window:Tab({ Title = "\083\111\099\105\097\108\032\072\117\098", Icon = "\117\115\101\114\115" })
 local SPD = STab:Dropdown({Title = "\084\097\114\103\101\116\032\080\108\097\121\101\114", Values = GetPlayers(), Value = 1, Callback = function(val) _G.EternalState.TargetPlayer = val end})
 STab:Button({Title = "\082\101\102\114\101\115\104\032\076\105\115\116", Callback = function() SPD:Refresh(GetPlayers(), true) end})
 STab:Section({ Title = "\073\110\116\101\114\097\099\116\105\111\110\115" })
 STab:Button({Title = "\084\101\108\101\112\111\114\116\032\084\111\032\080\108\097\121\101\114", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") and LocalPlayer.Character then
 LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
 end
 end})
 STab:Button({Title = "\067\111\112\121\032\079\117\116\102\105\116\032\040\070\117\108\108\032\067\108\111\110\101\041", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and LocalPlayer.Character then
 for _, i in pairs(LocalPlayer.Character:GetChildren()) do 
 if i:IsA("\083\104\105\114\116") or i:IsA("\080\097\110\116\115") or i:IsA("\065\099\099\101\115\115\111\114\121") or i:IsA("\072\097\116") or i:IsA("\083\104\105\114\116\071\114\097\112\104\105\099") or i:IsA("\066\111\100\121\067\111\108\111\114\115") or i:IsA("\067\104\097\114\097\099\116\101\114\077\101\115\104") then i:Destroy() end 
 end
 if LocalPlayer.Character:FindFirstChild("\072\101\097\100") then
 for _, v in pairs(LocalPlayer.Character.Head:GetChildren()) do if v:IsA("\068\101\099\097\108") or v:IsA("\083\112\101\099\105\097\108\077\101\115\104") then v:Destroy() end end
 end
 for _, i in pairs(t.Character:GetChildren()) do 
 if i:IsA("\083\104\105\114\116") or i:IsA("\080\097\110\116\115") or i:IsA("\066\111\100\121\067\111\108\111\114\115") or i:IsA("\067\104\097\114\097\099\116\101\114\077\101\115\104") or i:IsA("\083\104\105\114\116\071\114\097\112\104\105\099") then 
 local clone = i:Clone()
 if clone then clone.Parent = LocalPlayer.Character end
 elseif i:IsA("\065\099\099\101\115\115\111\114\121") or i:IsA("\072\097\116") then
 local clone = i:Clone()
 if clone then
 clone.Parent = LocalPlayer.Character
 local handle = clone:FindFirstChild("\072\097\110\100\108\101")
 local head = LocalPlayer.Character:FindFirstChild("\072\101\097\100")
 if handle and head then
 for _, v in pairs(handle:GetChildren()) do
 if v:IsA("\087\101\108\100") or v:IsA("\087\101\108\100\067\111\110\115\116\114\097\105\110\116") or v:IsA("\077\111\116\111\114\054\068") or v:IsA("\066\111\100\121\077\111\118\101\114") or v:IsA("\066\111\100\121\071\121\114\111") or v:IsA("\065\110\103\117\108\097\114\086\101\108\111\099\105\116\121") then
 v:Destroy()
 end
 end
 handle.CanCollide = false
 handle.Massless = true
 local originalHandle = i:FindFirstChild("\072\097\110\100\108\101")
 if originalHandle then
 local targetHead = t.Character:FindFirstChild("\072\101\097\100")
 if targetHead then
 local offset = targetHead.CFrame:ToObjectSpace(originalHandle.CFrame)
 handle.CFrame = head.CFrame * offset
 local weld = Instance.new("\087\101\108\100\067\111\110\115\116\114\097\105\110\116")
 weld.Part0 = head
 weld.Part1 = handle
 weld.Parent = handle
 end
 end
 end
 end
 end 
 end
 if t.Character:FindFirstChild("\072\101\097\100") and LocalPlayer.Character:FindFirstChild("\072\101\097\100") then
 for _, v in pairs(t.Character.Head:GetChildren()) do 
 if v:IsA("\068\101\099\097\108") or v:IsA("\083\112\101\099\105\097\108\077\101\115\104") then 
 local clone = v:Clone()
 if clone then clone.Parent = LocalPlayer.Character.Head end
 end 
 end
 end
 for _, part in pairs(t.Character:GetChildren()) do
 if part:IsA("\077\101\115\104\080\097\114\116") then
 local myPart = LocalPlayer.Character:FindFirstChild(part.Name)
 if myPart and myPart:IsA("\077\101\115\104\080\097\114\116") then
 pcall(function()
 myPart.MeshId = part.MeshId
 myPart.TextureID = part.TextureID
 myPart.Size = part.Size
 myPart.Color = part.Color
 end)
 end
 end
 end
 local tHum = t.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
 local lHum = LocalPlayer.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100")
 if tHum and lHum then
 local scales = {"\066\111\100\121\068\101\112\116\104\083\099\097\108\101", "\066\111\100\121\072\101\105\103\104\116\083\099\097\108\101", "\066\111\100\121\087\105\100\116\104\083\099\097\108\101", "\066\111\100\121\080\114\111\112\111\114\116\105\111\110\083\099\097\108\101", "\066\111\100\121\084\121\112\101\083\099\097\108\101", "\072\101\097\100\083\099\097\108\101"}
 for _, scaleName in pairs(scales) do
 local tScale = tHum:FindFirstChild(scaleName)
 if tScale and tScale:IsA("\078\117\109\098\101\114\086\097\108\117\101") then
 local lScale = lHum:FindFirstChild(scaleName)
 if lScale and lScale:IsA("\078\117\109\098\101\114\086\097\108\117\101") then
 lScale.Value = tScale.Value
 else
 local cloneScale = tScale:Clone()
 cloneScale.Parent = lHum
 end
 end
 end
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
 STab:Toggle({Title = "\067\111\110\116\114\111\108\032\080\108\097\121\101\114\032\040\087\101\108\100\032\066\117\103\041", Value = false, Callback = function(v)
 if v then
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and LocalPlayer.Character then
 local lHead = LocalPlayer.Character:FindFirstChild("\072\101\097\100")
 if lHead then
 for _, acc in pairs(t.Character:GetChildren()) do
 if acc:IsA("\065\099\099\101\115\115\111\114\121") or acc:IsA("\072\097\116") then
 local clone = acc:Clone()
 if clone then
 clone.Parent = LocalPlayer.Character
 socialControlClone = clone 
 local handle = clone:FindFirstChild("\072\097\110\100\108\101")
 if handle then
 handle.CanCollide = false
 handle.Massless = true
 local weld = Instance.new("\087\101\108\100\067\111\110\115\116\114\097\105\110\116")
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
 end
 })
 STab:Button({Title = "\066\114\105\110\103\032\065\108\108\032\087\111\114\107\115\112\097\099\101\032\084\111\111\108\115\047\073\116\101\109\115", Callback = function()
 pcall(function()
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then
 for _, obj in pairs(workspace:GetDescendants()) do
 if obj:IsA("\084\111\111\108") and obj:FindFirstChild("\072\097\110\100\108\101") then
 LocalPlayer.Character.Humanoid:EquipTool(obj)
 end
 end
 end
 end)
 end})
 STab:Button({Title = "\084\114\111\108\108\032\070\108\105\110\103\032\040\075\105\108\108\041", Callback = function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local hrp = LocalPlayer.Character.HumanoidRootPart
 local thrust = Instance.new("\066\111\100\121\065\110\103\117\108\097\114\086\101\108\111\099\105\116\121")
 thrust.AngularVelocity = Vector3.new(9000, 9000, 9000)
 thrust.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
 thrust.Parent = hrp
 local startTime = tick()
 local c; c = RunService.Heartbeat:Connect(function()
 if hrp and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") and tick() - startTime < 3.5 then
 hrp.CFrame = t.Character.HumanoidRootPart.CFrame
 else
 if thrust then thrust:Destroy() end
 c:Disconnect()
 end
 end)
 end
 end})
 local socialAttachLoop = nil
 STab:Toggle({Title = "\065\116\116\097\099\104\032\116\111\032\080\108\097\121\101\114\032\040\076\111\111\112\032\084\080\041", Value = false, Callback = function(v)
 if v then
 socialAttachLoop = RunService.Heartbeat:Connect(function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
 end
 end)
 else
 if socialAttachLoop then socialAttachLoop:Disconnect(); socialAttachLoop = nil end
 end
 end
 })
 local spinSitLoop = nil
 local spinSitAngle = 0
 STab:Toggle({Title = "\083\112\105\110\032\111\110\032\084\097\114\103\101\116\039\115\032\072\101\097\100\032\040\065\110\110\111\121\041", Value = false, Callback = function(v)
 if v then
 spinSitLoop = RunService.Heartbeat:Connect(function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\101\097\100") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 spinSitAngle = spinSitAngle + math.rad(40)
 LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame * CFrame.new(0, 2, 0) * CFrame.Angles(0, spinSitAngle, 0)
 if LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then LocalPlayer.Character.Humanoid.Sit = true end
 end
 end)
 else
 if spinSitLoop then spinSitLoop:Disconnect(); spinSitLoop = nil end
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then LocalPlayer.Character.Humanoid.Sit = false end
 end
 end
 })
 STab:Button({Title = "\065\111\069\032\070\108\105\110\103\032\065\108\108\032\040\075\105\108\108\032\083\101\114\118\101\114\041", Callback = function()
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local hrp = LocalPlayer.Character.HumanoidRootPart
 local thrust = Instance.new("\066\111\100\121\065\110\103\117\108\097\114\086\101\108\111\099\105\116\121")
 thrust.AngularVelocity = Vector3.new(9000, 9000, 9000)
 thrust.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
 thrust.Parent = hrp
 local startTime = tick()
 local c; c = RunService.Heartbeat:Connect(function()
 if hrp and tick() - startTime < 8 then
 local target = nil
 for _, p in pairs(Players:GetPlayers()) do
 if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
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
 STab:Button({Title = "\078\097\107\101\100\032\077\111\100\101\032\040\082\101\109\111\118\101\032\067\108\111\116\104\101\115\032\076\111\099\097\108\041", Callback = function()
 if LocalPlayer.Character then
 for _, i in pairs(LocalPlayer.Character:GetChildren()) do 
 if i:IsA("\083\104\105\114\116") or i:IsA("\080\097\110\116\115") or i:IsA("\065\099\099\101\115\115\111\114\121") or i:IsA("\072\097\116") or i:IsA("\083\104\105\114\116\071\114\097\112\104\105\099") then 
 i:Destroy() 
 end 
 end
 end
 end})
 local socialSitLoop = nil
 STab:Toggle({Title = "\083\105\116\032\111\110\032\084\097\114\103\101\116\039\115\032\083\104\111\117\108\100\101\114\115", Value = false, Callback = function(v)
 if v then
 socialSitLoop = RunService.Heartbeat:Connect(function()
 local t = Players:FindFirstChild(_G.EternalState.TargetPlayer)
 if t and t.Character and t.Character:FindFirstChild("\072\101\097\100") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame * CFrame.new(0, 1.5, 0)
 if LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then LocalPlayer.Character.Humanoid.Sit = true end
 end
 end)
 else
 if socialSitLoop then socialSitLoop:Disconnect(); socialSitLoop = nil end
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then LocalPlayer.Character.Humanoid.Sit = false end
 end
 end
 })
 local flying = false
 local flyLoop = nil
 local bv = nil
 local bg = nil
 STab:Toggle({Title = "\070\108\121\032\083\121\115\116\101\109\032\040\072\111\108\100\032\076\101\102\116\032\067\108\105\099\107\041", Value = false, Callback = function(v)
 flying = v
 if flying then
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local hrp = LocalPlayer.Character.HumanoidRootPart
 bv = Instance.new("\066\111\100\121\086\101\108\111\099\105\116\121")
 bv.Velocity = Vector3.new(0,0,0)
 bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
 bv.Parent = hrp
 bg = Instance.new("\066\111\100\121\071\121\114\111")
 bg.P = 9e4
 bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
 bg.CFrame = hrp.CFrame
 bg.Parent = hrp
 flyLoop = RunService.RenderStepped:Connect(function()
 if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then return end
 if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
 bv.Velocity = Camera.CFrame.LookVector * 100 
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
 end
 })
 STab:Section({ Title = "\127875\032\072\111\114\114\111\114\032\067\111\109\109\097\110\100\115" })
 STab:Button({Title = "\127993\032\065\110\103\101\108\032\065\108\108\032\080\108\097\121\101\114\115\032\040\075\105\108\108\032\083\101\114\118\101\114\041", Callback = function()
 local count = 0
 for _, p in pairs(Players:GetPlayers()) do
 if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local hrp = p.Character.HumanoidRootPart
 pcall(function()
 local hl = p.Character:FindFirstChild("\065\110\103\101\108\072\076") or Instance.new("\072\105\103\104\108\105\103\104\116", p.Character)
 hl.Name = "\065\110\103\101\108\072\076"
 hl.FillColor = Color3.fromRGB(255, 255, 255)
 hl.OutlineColor = Color3.fromRGB(200, 200, 255)
 hl.FillTransparency = 0.3
 end)
 pcall(function()
 hrp.CFrame = hrp.CFrame + Vector3.new(0, 200, 0)
 hrp.Anchored = true
 task.delay(8, function()
 pcall(function() hrp.Anchored = false end)
 end)
 end)
 if p.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 p.Character.Humanoid.Health = 0
 end
 count = count + 1
 end
 end
 WindUI:Notify({Title="\127993\032\065\110\103\101\108\032\065\108\108", Content=count.."\032\112\108\097\121\101\114\115\032\104\097\118\101\032\098\101\099\111\109\101\032\097\110\103\101\108\115\033", Duration=4, Icon = "\115\117\110"})
 end})
 STab:Section({ Title = "\127918\032\082\111\045\086\105\098\101\115\032\083\112\101\099\105\102\105\099" })
 STab:Paragraph({ Title = "\077\097\115\115\032\066\097\110\105\115\104\032\040\070\108\105\110\103\041", Content = "\082\101\109\111\118\101\032\112\101\114\109\097\110\101\110\116\101\109\101\110\116\101\032\116\111\100\111\115\032\111\115\032\106\111\103\097\100\111\114\101\115\032\100\097\032\225\114\101\097\032\100\111\032\112\097\108\099\111\032\117\115\097\110\100\111\032\111\032\101\120\112\108\111\105\116\032\100\101\032\099\111\108\105\115\227\111\032\102\237\115\105\099\097\032\040\070\108\105\110\103\041\046" })
 STab:Button({Title = "\128293\032\083\116\097\103\101\032\067\108\101\097\110\032\040\066\097\110\105\115\104\032\065\108\108\041", Callback = function()
 local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
 if hrp then
 local thrust = Instance.new("\066\111\100\121\065\110\103\117\108\097\114\086\101\108\111\099\105\116\121")
 thrust.AngularVelocity = Vector3.new(9000, 9000, 9000)
 thrust.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
 thrust.Parent = hrp
 local startTime = tick()
 local c; c = RunService.Heartbeat:Connect(function()
 if hrp and tick() - startTime < 10 then
 for _, p in pairs(Players:GetPlayers()) do
 if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 hrp.CFrame = p.Character.HumanoidRootPart.CFrame
 task.wait(0.1)
 end
 end
 else
 if thrust then thrust:Destroy() end
 c:Disconnect()
 end
 end)
 end
 end})
 STab:Section({ Title = "\127918\032\083\097\108\227\111\032\100\101\032\070\101\115\116\097\115\032\083\112\101\099\105\102\105\099" })
 STab:Paragraph({ Title = "\086\111\105\100\032\066\097\110\105\115\104", Content = "\076\105\109\112\097\032\111\032\115\097\108\227\111\032\100\101\032\102\101\115\116\097\115\032\101\110\118\105\097\110\100\111\032\116\111\100\111\115\032\111\115\032\106\111\103\097\100\111\114\101\115\032\112\114\101\115\101\110\116\101\115\032\112\097\114\097\032\111\032\086\225\099\117\111\032\040\086\111\105\100\041\046" })
 STab:Button({Title = "\127756\032\086\111\105\100\032\083\101\114\118\101\114\032\040\067\108\101\097\114\032\065\108\108\041", Callback = function()
 local count = 0
 for _, p in pairs(Players:GetPlayers()) do
 if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 pcall(function()
 local pRoot = p.Character.HumanoidRootPart
 pRoot.Velocity = Vector3.new(0, -1000, 0)
 pRoot.CFrame = pRoot.CFrame * CFrame.new(0, -100, 0)
 end)
 count = count + 1
 end
 end
 WindUI:Notify({Title="\127756\032\086\111\105\100", Content="\065\116\116\101\109\112\116\101\100\032\116\111\032\098\097\110\105\115\104\032" .. count .. "\032\112\108\097\121\101\114\115\046", Duration=3, Icon = "\122\097\112"})
 end})
 elseif v == "\091\076\085\067\075\089\032\067\079\087\065\082\068\093\032\083\104\101\110\097\110\105\103\097\110\115\032\100\101\032\074\117\106\117\116\115\117" and not BuiltHubs["\083\104\101\110\097\110\105\103\097\110\115"] then
 BuiltHubs["\083\104\101\110\097\110\105\103\097\110\115"] = true
 local JTab = Window:Tab({ Title = "\074\117\106\117\116\115\117\032\072\117\098", Icon = "\115\104\105\101\108\100" })
 JTab:Section({ Title = "\073\110\118\105\110\099\105\098\105\108\105\116\121\032\038\032\071\111\100\032\077\111\100\101" })
 local godLoop = nil
 JTab:Toggle({Title = "\066\097\115\105\099\032\071\111\100\032\077\111\100\101\032\040\077\097\120\032\072\101\097\108\116\104\041", Value = false, Callback = function(v)
 if v then
 godLoop = RunService.Heartbeat:Connect(function()
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then
 local hum = LocalPlayer.Character.Humanoid
 if hum.Health > 0 then
 hum.MaxHealth = math.huge
 hum.Health = math.huge
 end
 end
 end)
 else
 if godLoop then godLoop:Disconnect(); godLoop = nil end
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then
 LocalPlayer.Character.Humanoid.MaxHealth = 100
 end
 end
 end
 })
 local hitboxLoop = nil
 JTab:Toggle({Title = "\068\101\108\101\116\101\032\069\110\101\109\121\032\072\105\116\098\111\120\101\115\032\040\065\110\116\105\045\068\097\109\097\103\101\041", Value = false, Callback = function(v)
 if v then
 hitboxLoop = RunService.RenderStepped:Connect(function()
 for _, obj in pairs(workspace:GetDescendants()) do
 if obj:IsA("\066\097\115\101\080\097\114\116") then
 local name = obj.Name:lower()
 if name:match("\104\105\116\098\111\120") or name:match("\100\097\109\097\103\101") or name:match("\097\116\116\097\099\107") then
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
 end
 })
 local dodgeLoop = nil
 JTab:Toggle({Title = "\065\117\116\111\032\068\111\100\103\101\032\040\080\114\111\120\105\109\105\116\121\032\084\080\041", Value = false, Callback = function(v)
 if v then
 dodgeLoop = RunService.Heartbeat:Connect(function()
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local myPos = LocalPlayer.Character.HumanoidRootPart.Position
 for _, p in pairs(Players:GetPlayers()) do
 if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
 if dist < 12 and p.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100").Health > 0 then
 LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
 end
 end
 end
 end
 end)
 else
 if dodgeLoop then dodgeLoop:Disconnect(); dodgeLoop = nil end
 end
 end
 })
 local antiStunLoop = nil
 JTab:Toggle({Title = "\065\110\116\105\045\083\116\117\110\032\047\032\065\117\116\111\045\083\112\114\105\110\116", Value = false, Callback = function(v)
 if v then
 antiStunLoop = RunService.RenderStepped:Connect(function()
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100") then
 if LocalPlayer.Character.Humanoid.WalkSpeed < 16 then
 LocalPlayer.Character.Humanoid.WalkSpeed = 16
 end
 local hrp = LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")
 if hrp and hrp.Anchored then hrp.Anchored = false end
 end
 end)
 else
 if antiStunLoop then antiStunLoop:Disconnect(); antiStunLoop = nil end
 end
 end
 })
 end
 end})
 Tabs.Aimbot:Section({ Title = "\065\105\109\098\111\116\032\067\111\114\101" })
 Tabs.Aimbot:Toggle({Title = "\069\110\097\098\108\101\032\067\097\109\101\114\097\032\065\105\109\098\111\116", Value = false, Callback = function(v) _G.EternalState.AimEnabled = v end})
 Tabs.Aimbot:Toggle({Title = "\083\105\108\101\110\116\032\065\105\109\032\040\077\097\103\105\099\032\066\117\108\108\101\116\041", Value = false, Callback = function(v) _G.EternalState.SilentAim = v end})
 Tabs.Aimbot:Dropdown({Title = "\084\097\114\103\101\116\032\080\097\114\116", Values = {"\072\101\097\100", "\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116"}, Value = 1, Callback = function(v) _G.EternalState.AimPart = v end})
 Tabs.Aimbot:Section({ Title = "\065\105\109\098\111\116\032\083\101\116\116\105\110\103\115" })
 Tabs.Aimbot:Slider({Title = "\070\079\086\032\083\105\122\101", Value = {Default = 100, Min = 10, Max = 800}, Step = 1, Callback = function(v) _G.EternalState.AimFOV = v end})
 Tabs.Aimbot:Slider({Title = "\083\109\111\111\116\104\110\101\115\115\032\040\067\097\109\041", Value = {Default = 3, Min = 1, Max = 20}, Step = 0.1, Callback = function(v) _G.EternalState.AimSmooth = v end})
 Tabs.Visuals:Section({ Title = "\050\068\032\069\083\080" })
 Tabs.Visuals:Toggle({Title = "\066\111\120\101\115", Value = false, Callback = function(v) _G.EternalState.BoxESP = v end})
 Tabs.Visuals:Toggle({Title = "\078\097\109\101\115", Value = false, Callback = function(v) _G.EternalState.NameESP = v end})
 Tabs.Visuals:Toggle({Title = "\068\105\115\116\097\110\099\101", Value = false, Callback = function(v) _G.EternalState.DistESP = v end})
 Tabs.Visuals:Toggle({Title = "\083\107\101\108\101\116\111\110\032\069\115\112", Value = false, Callback = function(v) _G.EternalState.SkeletonESP = v end})
 Tabs.Visuals:Colorpicker({Title = "\083\107\101\108\101\116\111\110\032\067\111\108\111\114", Default = Color3.new(1,1,1), Callback = function(v) _G.EternalState.SkeletonColor = v end})
 Tabs.Visuals:Section({ Title = "\051\068\032\069\083\080\032\038\032\087\111\114\108\100" })
 Tabs.Visuals:Toggle({Title = "\069\110\097\098\108\101\032\067\104\097\109\115", Value = false, Callback = function(v) _G.EternalState.Chams = v end})
 Tabs.Visuals:Dropdown({Title = "\067\104\097\109\115\032\077\097\116\101\114\105\097\108", Values = {"\078\101\111\110", "\070\111\114\099\101\070\105\101\108\100", "\071\108\097\115\115", "\080\108\097\115\116\105\099"}, Value = 1, Callback = function(v) _G.EternalState.ChamsMat = v end})
 Tabs.Visuals:Colorpicker({Title = "\067\104\097\109\115\032\067\111\108\111\114", Default = Color3.fromRGB(180, 100, 255), Callback = function(v) _G.EternalState.ChamsColor = v end})
 Tabs.Visuals:Toggle({Title = "\080\114\111\106\101\099\116\105\108\101\032\069\083\080\032\040\071\114\101\110\097\100\101\115\041", Value = false, Callback = function(v) _G.EternalState.ProjESP = v end})
 Tabs.Local:Section({ Title = "\077\111\118\101\109\101\110\116" })
 Tabs.Local:Slider({Title = "\087\097\108\107\083\112\101\101\100", Value = {Default = 16, Min = 16, Max = 300}, Step = 1, Callback = function(v) _G.EternalState.WalkSpeed = v end})
 Tabs.Local:Slider({Title = "\074\117\109\112\080\111\119\101\114", Value = {Default = 50, Min = 50, Max = 500}, Step = 1, Callback = function(v) _G.EternalState.JumpPower = v end})
 Tabs.Local:Toggle({Title = "\078\111\067\108\105\112", Value = false, Callback = function(v) _G.EternalState.NoClip = v end})
 Tabs.Local:Section({ Title = "\065\110\116\105\045\072\105\116\032\040\067\083\058\071\079\032\083\116\121\108\101\041" })
 Tabs.Local:Toggle({Title = "\083\112\105\110\098\111\116\032\040\051\054\048\041", Value = false, Callback = function(v) _G.EternalState.Spinbot = v end})
 Tabs.Local:Slider({Title = "\083\112\105\110\032\083\112\101\101\100", Value = {Default = 50, Min = 10, Max = 200}, Step = 1, Callback = function(v) _G.EternalState.SpinSpeed = v end})
 WindUI:Notify({Title="\069\116\101\114\110\097\108", Content="\067\111\110\102\105\103\117\114\097\231\245\101\115\032\099\097\114\114\101\103\097\100\097\115\033", Duration=3, Icon = "\115\101\116\116\105\110\103\115"})
 local function GetClosestTarget()
 local best = _G.EternalState.AimFOV
 local targetPos = nil
 local targetPlayer = nil
 for _, p in pairs(Players:GetPlayers()) do
 if p ~= LocalPlayer then
 local char = p.Character or workspace:FindFirstChild(p.Name)
 if char and char:FindFirstChild(_G.EternalState.AimPart) and char:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") and char:FindFirstChildOfClass("\072\117\109\097\110\111\105\100").Health > 0 then
 local pos, vis = Camera:WorldToViewportPoint(char[_G.EternalState.AimPart].Position)
 if vis then
 local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
 if mag < best then best = mag; targetPos = char[_G.EternalState.AimPart].Position; targetPlayer = p end
 end
 end
 end
 end
 return targetPos, targetPlayer
 end
 pcall(function()
 if not hookmetamethod or not getnamecallmethod then return end
 local oldNamecall
 oldNamecall = hookmetamethod(game, "\095\095\110\097\109\101\099\097\108\108", function(self, ...)
 local method = getnamecallmethod()
 local args = {...}
 if _G.EternalState.SilentAim then
 local isScript = false
 pcall(function() isScript = checkcaller() end)
 if not isScript then
 if method == "\082\097\121\099\097\115\116" or method == "\070\105\110\100\080\097\114\116\079\110\082\097\121" or method == "\070\105\110\100\080\097\114\116\079\110\082\097\121\087\105\116\104\073\103\110\111\114\101\076\105\115\116" or method == "\070\105\110\100\080\097\114\116\079\110\082\097\121\087\105\116\104\087\104\105\116\101\108\105\115\116" or method == "\070\105\114\101\083\101\114\118\101\114" then
 local targetPos, targetPlayer = GetClosestTarget()
 if targetPos then
 if method == "\070\105\114\101\083\101\114\118\101\114" and self.Name:lower():find("\115\104\111\111\116") or self.Name:lower():find("\102\105\114\101") or self.Name:lower():find("\104\105\116") then
 elseif method == "\082\097\121\099\097\115\116" then
 local origin = args[1]
 args[2] = (targetPos - origin).Unit * 1000 
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
 task.spawn(function()
 local spinAngle = 0
 RunService.RenderStepped:Connect(function()
 if _G.EternalState.AimEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
 local targetPos, targetPlayer = GetClosestTarget()
 if targetPos then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), 1/_G.EternalState.AimSmooth) end
 end
 if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") then
 local hum = LocalPlayer.Character.Humanoid
 hum.WalkSpeed = _G.EternalState.WalkSpeed
 hum.JumpPower = _G.EternalState.JumpPower
 if _G.EternalState.NoClip then 
 for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("\066\097\115\101\080\097\114\116") then v.CanCollide = false end end 
 end
 if _G.EternalState.Spinbot and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") then
 spinAngle = spinAngle + math.rad(_G.EternalState.SpinSpeed)
 local hrp = LocalPlayer.Character.HumanoidRootPart
 hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
 end
 end
 end)
 end)
 task.spawn(function()
 local DrawPool = {}
 local function GetLine()
 local l = Drawing.new("\076\105\110\101"); l.Visible = false; l.Thickness = 1.5; return l
 end
 local function BuildESP(p)
 local Box = Drawing.new("\083\113\117\097\114\101"); Box.Visible = false; Box.Color = Color3.new(1,0,0); Box.Thickness = 1; Box.Filled = false
 local Name = Drawing.new("\084\101\120\116"); Name.Visible = false; Name.Color = Color3.new(1,1,1); Name.Size = 14; Name.Center = true; Name.Outline = true
 local Dist = Drawing.new("\084\101\120\116"); Dist.Visible = false; Dist.Color = Color3.new(0.8,0.8,0.8); Dist.Size = 13; Dist.Center = true; Dist.Outline = true
 local Bones = { Head = GetLine(), Spine = GetLine(), LArm = GetLine(), RArm = GetLine(), LLeg = GetLine(), RLeg = GetLine() }
 local function cleanup() 
 Box:Remove(); Name:Remove(); Dist:Remove()
 for _, l in pairs(Bones) do l:Remove() end
 end
 local conn; conn = RunService.RenderStepped:Connect(function()
 if not p then cleanup(); conn:Disconnect(); return end
 local char = p.Character or workspace:FindFirstChild(p.Name)
 if char and char:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116") and char:FindFirstChildOfClass("\072\117\109\097\110\111\105\100") and char:FindFirstChildOfClass("\072\117\109\097\110\111\105\100").Health > 0 then
 local root = char.HumanoidRootPart
 local head = char:FindFirstChild("\072\101\097\100")
 local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
 if onScreen and pos.Z > 0 then
 local rootTop = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
 local rootBottom = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
 local sizeY = math.abs(rootBottom.Y - rootTop.Y)
 local sizeX = sizeY * 0.6
 Box.Size = Vector2.new(sizeX, sizeY); Box.Position = Vector2.new(pos.X - sizeX / 2, rootTop.Y); Box.Visible = _G.EternalState.BoxESP
 Name.Position = Vector2.new(pos.X, rootTop.Y - 16); Name.Text = p.Name; Name.Visible = _G.EternalState.NameESP
 local localPos = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116")) and LocalPlayer.Character.HumanoidRootPart.Position or Camera.CFrame.Position
 Dist.Position = Vector2.new(pos.X, rootBottom.Y + 2); Dist.Text = "[" .. math.floor((localPos - root.Position).Magnitude) .. "m]"; Dist.Visible = _G.EternalState.DistESP
 if _G.EternalState.Chams then
 for _, part in pairs(char:GetDescendants()) do
 if part:IsA("\066\097\115\101\080\097\114\116") and part.Name ~= "\072\117\109\097\110\111\105\100\082\111\111\116\080\097\114\116" then
 pcall(function() 
 part.Material = Enum.Material[_G.EternalState.ChamsMat]
 part.Color = _G.EternalState.ChamsColor
 end)
 end
 end
 end
 if _G.EternalState.SkeletonESP and head then
 local neckP, nV = Camera:WorldToViewportPoint(head.Position - Vector3.new(0, 0.5, 0))
 local pelvisP, pV = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 1, 0))
 if nV and pV then
 Bones.Spine.From = Vector2.new(pos.X, rootTop.Y); Bones.Spine.To = Vector2.new(pelvisP.X, pelvisP.Y); Bones.Spine.Visible = _G.EternalState.SkeletonESP; Bones.Spine.Color = _G.EternalState.SkeletonColor
 Bones.Head.From = Vector2.new(neckP.X, neckP.Y); Bones.Head.To = Vector2.new(pos.X, rootTop.Y); Bones.Head.Visible = _G.EternalState.SkeletonESP; Bones.Head.Color = _G.EternalState.SkeletonColor
 else
 Bones.Spine.Visible = false; Bones.Head.Visible = false
 end
 local rArm = char:FindFirstChild("\082\105\103\104\116\032\065\114\109") or char:FindFirstChild("\082\105\103\104\116\072\097\110\100")
 local lArm = char:FindFirstChild("\076\101\102\116\032\065\114\109") or char:FindFirstChild("\076\101\102\116\072\097\110\100")
 if rArm then local rap, rv = Camera:WorldToViewportPoint(rArm.Position); if rv then Bones.RArm.From = Vector2.new(pos.X, rootTop.Y); Bones.RArm.To = Vector2.new(rap.X, rap.Y); Bones.RArm.Visible = _G.EternalState.SkeletonESP; Bones.RArm.Color = _G.EternalState.SkeletonColor else Bones.RArm.Visible = false end else Bones.RArm.Visible = false end
 if lArm then local lap, lv = Camera:WorldToViewportPoint(lArm.Position); if lv then Bones.LArm.From = Vector2.new(pos.X, rootTop.Y); Bones.LArm.To = Vector2.new(lap.X, lap.Y); Bones.LArm.Visible = _G.EternalState.SkeletonESP; Bones.LArm.Color = _G.EternalState.SkeletonColor else Bones.LArm.Visible = false end else Bones.LArm.Visible = false end
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
 local ProjContainer = workspace:FindFirstChild("\080\114\111\106\101\099\116\105\108\101\115") or workspace:FindFirstChild("\068\101\098\114\105\115") or workspace
 RunService.RenderStepped:Connect(function()
 if _G.EternalState.ProjESP then
 for _, obj in pairs(ProjContainer:GetDescendants()) do
 if obj:IsA("\080\097\114\116") and (obj.Name:lower():find("\103\114\101\110\097\100\101") or obj.Name:lower():find("\114\111\099\107\101\116") or obj.Name:lower():find("\098\117\108\108\101\116")) then
 if not obj:FindFirstChild("\080\114\111\106\072\076") then
 local hl = Instance.new("\072\105\103\104\108\105\103\104\116")
 hl.Name = "\080\114\111\106\072\076"; hl.Parent = obj; hl.FillColor = Color3.fromRGB(255, 50, 50)
 local tag = Drawing.new("\084\101\120\116")
 tag.Text = "\091\071\114\101\110\097\100\101\047\080\114\111\106\093"; tag.Size = 12; tag.Color = Color3.fromRGB(255,50,50); tag.Center = true
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
 UserInputService.InputBegan:Connect(function(input, gameProcessed)
 if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
 pcall(function()
 if Window.Toggle then
 Window:Toggle()
 end
 end)
 end
 end)
 Window:SelectTab(1)
 WindUI:Notify({Title = "\069\116\101\114\110\097\108\032\069\088\084\082\069\077\069", Content = "\065\100\118\097\110\099\101\100\032\069\110\103\105\110\101\032\076\111\097\100\101\100\046\032\083\105\108\101\110\116\032\065\105\109\032\038\032\083\112\105\110\098\111\116\032\114\101\097\100\121\046", Duration = 7, Icon = "\122\097\112"})
end)
if not success then
 game:GetService("\083\116\097\114\116\101\114\071\117\105"):SetCore("\083\101\110\100\078\111\116\105\102\105\099\097\116\105\111\110", {Title = "\070\097\116\097\108\032\069\114\114\111\114", Text = tostring(err), Duration = 20})
end