--[[
    ETERNAL HUB - PREMIUM LOADER
    Design: Modern Dark / Neon Blue
]]

local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local KeyFileName = "EternalHub_Key.txt"
local ServiceID   = "eternalhub" 
local DiscordLink = "https://discord.gg/s7DGf8VGUp" 
local ScriptURL   = "https://raw.githubusercontent.com/Ultron-Ia/RobloxLua/main/main.lua"

-- UTILIDADES DE UI ---------------------------------------------------------------------------
local function Create(className, props)
    local inst = Instance.new(className)
    local parent = props.Parent
    props.Parent = nil
    for k, v in pairs(props) do
        pcall(function() inst[k] = v end)
    end
    inst.Parent = parent
    return inst
end

local function ApplyGradient(parent, colors)
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new(colors),
        Rotation = 45,
        Parent = parent
    })
    return gradient
end

local function ButtonEffects(button)
    local originalSize = button.Size
    local hoverSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset + 4, originalSize.Y.Scale, originalSize.Y.Offset + 2)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = hoverSize, BackgroundTransparency = 0.1}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = originalSize, BackgroundTransparency = 0}):Play()
    end)
end

-- LÓGICA PRINCIPAL ---------------------------------------------------------------------------
local function TrimKey(key) return (tostring(key):gsub("^[%s\n\r\t]+", ""):gsub("[%s\n\r\t]+$", "")) end
local function GetHWID()
    local ok, hwid = pcall(gethwid)
    if ok and hwid and hwid ~= "" then return hwid end
    return tostring(game:GetService("RbxAnalyticsService"):GetClientId()):gsub("-", "")
end

local function GetRequestFunc()
    local candidates = {function() return request end, function() return http_request end}
    for _, getter in ipairs(candidates) do
        local ok, fn = pcall(getter)
        if ok and type(fn) == "function" then return fn end
    end
    return nil
end

local function ValidateKey(key)
    key = TrimKey(key)
    local reqFn = GetRequestFunc()
    if not reqFn then return false, "Executor incompatible" end

    local body = HttpService:JSONEncode({ServiceID = ServiceID, HWID = GetHWID(), Key = key})
    local ok, response = pcall(reqFn, {
        Url = "https://new.pandadevelopment.net/api/v1/keys/validate",
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = body
    })

    if not ok or not response then return false, "Network Error" end
    local data = HttpService:JSONDecode(response.Body)
    return (data.Authenticated_Status == "Success"), data.Note or ""
end

-- UI CONSTRUCTOR -----------------------------------------------------------------------------
local function BuildKeyGUI()
    local existing = (gethui and gethui():FindFirstChild("EternalHubLoader")) or CoreGui:FindFirstChild("EternalHubLoader")
    if existing then existing:Destroy() end

    local gui = Create("ScreenGui", {
        Name = "EternalHubLoader",
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = (gethui and gethui()) or CoreGui
    })

    -- Background Overlay
    local bg = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Parent = gui
    })
    TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 0.4}):Play()

    -- Glow Effect
    local glow = Create("ImageLabel", {
        Name = "Glow",
        Position = UDim2.new(0.5, -250, 0.5, -220),
        Size = UDim2.new(0, 500, 0, 440),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217", -- Shadow/Glow Texture
        ImageColor3 = Color3.fromRGB(0, 120, 255),
        ImageTransparency = 0.8,
        ZIndex = 1,
        Parent = gui
    })

    -- Main Card
    local main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 400, 0, 340),
        Position = UDim2.new(0.5, -200, 0.6, -170), -- Starts lower for animation
        BackgroundColor3 = Color3.fromRGB(10, 10, 15),
        BorderSizePixel = 0,
        ZIndex = 2,
        ClipsDescendants = true,
        Parent = gui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = main})
    Create("UIStroke", {Color = Color3.fromRGB(0, 150, 255), Thickness = 1.5, Transparency = 0.3, Parent = main})
    
    -- Animação de entrada
    TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -200, 0.5, -170)}):Play()

    -- Title Area
    local title = Create("TextLabel", {
        Text = "ETERNAL HUB",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBlack,
        TextSize = 22,
        ZIndex = 5,
        Parent = main
    })
    local subTitle = Create("TextLabel", {
        Text = "PREMIUM EXECUTION",
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(0, 150, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextTransparency = 0.5,
        ZIndex = 5,
        Parent = main
    })

    -- Input Field
    local inputFrame = Create("Frame", {
        Size = UDim2.new(0.85, 0, 0, 45),
        Position = UDim2.new(0.075, 0, 0, 100),
        BackgroundColor3 = Color3.fromRGB(15, 15, 22),
        ZIndex = 5,
        Parent = main
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = inputFrame})
    Create("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.9, Parent = inputFrame})

    local keyBox = Create("TextBox", {
        Text = "",
        PlaceholderText = "Enter Panda Key here...",
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderColor3 = Color3.fromRGB(100, 100, 110),
        TextXAlignment = "Left",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        ZIndex = 6,
        Parent = inputFrame
    })

    local pasteBtn = Create("TextButton", {
        Text = "PASTE",
        Size = UDim2.new(0, 70, 0, 28),
        Position = UDim2.new(1, -78, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        ZIndex = 7,
        Parent = inputFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = pasteBtn})
    ButtonEffects(pasteBtn)

    -- Buttons
    local getKeyBtn = Create("TextButton", {
        Text = "GET ACCESS KEY",
        Size = UDim2.new(0.85, 0, 0, 45),
        Position = UDim2.new(0.075, 0, 0, 160),
        BackgroundColor3 = Color3.fromRGB(20, 20, 28),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        ZIndex = 5,
        Parent = main
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = getKeyBtn})
    ButtonEffects(getKeyBtn)

    local verifyBtn = Create("TextButton", {
        Text = "VERIFY & LAUNCH",
        Size = UDim2.new(0.85, 0, 0, 50),
        Position = UDim2.new(0.075, 0, 0, 220),
        BackgroundColor3 = Color3.fromRGB(0, 120, 255),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBlack,
        TextSize = 16,
        ZIndex = 5,
        AutoButtonColor = false,
        Parent = main
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = verifyBtn})
    ApplyGradient(verifyBtn, {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 80, 200))
    })
    ButtonEffects(verifyBtn)

    local status = Create("TextLabel", {
        Text = "Waiting for key...",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -40),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(120, 120, 130),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ZIndex = 5,
        Parent = main
    })

    -- Draggable
    local dragging, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            glow.Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset - 50, main.Position.Y.Scale, main.Position.Y.Offset - 50)
        end
    end)

    -- Actions
    pasteBtn.MouseButton1Click:Connect(function()
        local ok, clip = pcall(getclipboard)
        if ok and clip ~= "" then keyBox.Text = clip; status.Text = "Key pasted from clipboard!" end
    end)

    getKeyBtn.MouseButton1Click:Connect(function()
        local link = "https://new.pandadevelopment.net/getkey/" .. ServiceID .. "?hwid=" .. GetHWID()
        if pcall(setclipboard, link) then status.Text = "Link copied! Paste it in your browser." end
    end)

    verifyBtn.MouseButton1Click:Connect(function()
        local key = TrimKey(keyBox.Text)
        if key == "" then status.Text = "Please enter a key first."; return end
        
        verifyBtn.Text = "AUTHENTICATING..."
        task.spawn(function()
            local ok, msg = ValidateKey(key)
            if ok then
                pcall(writefile, KeyFileName, key)
                status.Text = "Access Granted! Loading..."
                TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -200, 1.5, 0), Size = UDim2.new(0, 300, 0, 200)}):Play()
                task.wait(0.6)
                gui:Destroy()
                loadstring(game:HttpGet(ScriptURL))()
            else
                status.Text = "Error: " .. tostring(msg)
                verifyBtn.Text = "VERIFY & LAUNCH"
                TweenService:Create(main, TweenInfo.new(0.1), {Position = main.Position + UDim2.new(0, 5, 0, 0)}):Play()
                task.wait(0.05)
                TweenService:Create(main, TweenInfo.new(0.1), {Position = main.Position - UDim2.new(0, 5, 0, 0)}):Play()
            end
        end)
    end)
end

-- INICIALIZAÇÃO -------------------------------------------------------------------------------
task.spawn(function()
    local saved = ""
    pcall(function() if isfile(KeyFileName) then saved = readfile(KeyFileName) end end)
    
    if saved ~= "" then
        local ok, _ = ValidateKey(saved)
        if ok then 
            loadstring(game:HttpGet(ScriptURL))()
        else 
            BuildKeyGUI() 
        end
    else
        BuildKeyGUI()
    end
end)
