local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")

local KeyFileName = "EternalHub_Key.txt"
local ServiceID   = "eternalhub" 
local DiscordLink = "https://discord.gg/eternalhub" 
local ScriptURL   = "https://raw.githubusercontent.com/Ultron-Ia/RobloxLua/main/main.lua"

local function Create(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function TrimKey(key)
    return (tostring(key):gsub("^[%s\n\r\t]+", ""):gsub("[%s\n\r\t]+$", ""))
end

local function GetHWID()
    local ok, hwid = pcall(gethwid)
    if ok and hwid and hwid ~= "" then return hwid end
    return tostring(game:GetService("RbxAnalyticsService"):GetClientId()):gsub("-", "")
end

local function GetRequestFunc()
    local candidates = {
        function() return request end,
        function() return http_request end,
        function() return http and http.request end,
        function() return syn and syn.request end,
        function() return fluxus and fluxus.request end,
        function() return (getgenv or function() return {} end)().request end,
    }
    for _, getter in ipairs(candidates) do
        local ok, fn = pcall(getter or function() end)
        if ok and type(fn) == "function" then return fn end
    end
    return nil
end

local function ValidateKey(key)
    key = TrimKey(key)
    if key == "" then return false, "Key is empty" end

    local reqFn = GetRequestFunc()
    if not reqFn then return false, "HTTP not supported by this executor" end

    local body
    local encOk, encResult = pcall(HttpService.JSONEncode, HttpService, {
        ServiceID = ServiceID,
        HWID      = GetHWID(),
        Key       = key,
    })
    if not encOk then return false, "Failed to encode request" end
    body = encResult

    local reqOk, response = pcall(reqFn, {
        Url     = "https://new.pandadevelopment.net/api/v1/keys/validate",
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = body,
    })

    if not reqOk then return false, "Network request failed" end
    if not response or type(response) ~= "table" then return false, "No response received" end
    if not response.Body or response.Body == "" then return false, "Empty server response" end

    local decOk, data = pcall(HttpService.JSONDecode, HttpService, response.Body)
    if not decOk or type(data) ~= "table" then return false, "Could not parse server response" end

    local isValid = (data.Authenticated_Status == "Success")
    local note    = tostring(data.Note or (isValid and "Authenticated" or "Invalid key"))
    return isValid, note
end

-- UI HELPER FUNCTIONS ------------------------------------------------------------------------
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.06, Enum.EasingStyle.Sine), {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end)
end

local function CreateAmbientOrbs(parent)
    task.spawn(function()
        while parent and parent.Parent do
            local orb = Create("Frame", {
                Size              = UDim2.new(0, math.random(2, 5), 0, math.random(18, 45)),
                Position          = UDim2.new(math.random(), 0, -0.05, 0),
                BackgroundColor3  = math.random(2) == 1
                                    and Color3.fromRGB(80, 200, 255)
                                    or  Color3.fromRGB(160, 100, 255),
                BackgroundTransparency = math.random(5, 8) / 10,
                Rotation          = math.random(20, 50),
                BorderSizePixel   = 0,
                ZIndex            = 1,
                Parent            = parent,
            })
            Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = orb })
            local t = TweenService:Create(orb,
                TweenInfo.new(math.random(25, 50) / 10, Enum.EasingStyle.Linear), {
                    Position             = UDim2.new(orb.Position.X.Scale - 0.35, 0, 1.15, 0),
                    BackgroundTransparency = 1,
                })
            t:Play()
            t.Completed:Connect(function() orb:Destroy() end)
            task.wait(math.random(8, 18) / 100)
        end
    end)
end

local function CreateScanline(parent)
    local scan = Create("Frame", {
        Size                   = UDim2.new(1, 0, 0, 1),
        Position               = UDim2.new(0, 0, 0, 0),
        BackgroundColor3       = Color3.fromRGB(120, 220, 255),
        BackgroundTransparency = 0.82,
        BorderSizePixel        = 0,
        ZIndex                 = 10,
        Parent                 = parent,
    })
    task.spawn(function()
        while scan and scan.Parent do
            scan.Position = UDim2.new(0, 0, 0, 0)
            TweenService:Create(scan, TweenInfo.new(2.8, Enum.EasingStyle.Linear), {
                Position = UDim2.new(0, 0, 1, 0)
            }):Play()
            task.wait(2.9)
        end
    end)
end

local function ButtonAnimation(button, normalColor, hoverColor)
    local nc = normalColor or button.BackgroundColor3
    local hc = hoverColor or Color3.fromRGB(
        math.clamp(math.floor(nc.R * 255) + 20, 0, 255),
        math.clamp(math.floor(nc.G * 255) + 20, 0, 255),
        math.clamp(math.floor(nc.B * 255) + 20, 0, 255)
    )
    local origSize = button.Size
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { BackgroundColor3 = hc }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { BackgroundColor3 = nc }):Play()
    end)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            origSize = button.Size
            TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(origSize.X.Scale, origSize.X.Offset - 3,
                                 origSize.Y.Scale, origSize.Y.Offset - 3)
            }):Play()
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(origSize.X.Scale, origSize.X.Offset,
                                 origSize.Y.Scale, origSize.Y.Offset)
            }):Play()
        end
    end)
end

local function PulsatingGlow(gui)
    local glow = Create("Frame", {
        Size                   = UDim2.new(0, 440, 0, 380),
        Position               = UDim2.new(0.5, -220, 0.5, -190),
        BackgroundColor3       = Color3.fromRGB(0, 120, 255),
        BackgroundTransparency = 0.88,
        BorderSizePixel        = 0,
        ZIndex                 = 1,
        Parent                 = gui,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 22), Parent = glow })
    task.spawn(function()
        while glow and glow.Parent do
            TweenService:Create(glow, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundTransparency = 0.93 }):Play()
            task.wait(2.2)
            if not (glow and glow.Parent) then break end
            TweenService:Create(glow, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                { BackgroundTransparency = 0.86 }):Play()
            task.wait(2.2)
        end
    end)
    return glow
end

local function BuildBackground(gui)
    local bg = Create("Frame", {
        Name                   = "Background",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundColor3       = Color3.fromRGB(4, 4, 8),
        BackgroundTransparency = 0.55,
        BorderSizePixel        = 0,
        ZIndex                 = 0,
        Parent                 = gui,
    })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(6,  4, 14)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(3,  8, 18)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,  4, 12)),
        },
        Rotation = 135,
        Parent   = bg,
    })
    CreateAmbientOrbs(bg)
    return bg
end

local function BuildCard(gui, w, h)
    local main = Create("Frame", {
        Name             = "Main",
        Size             = UDim2.new(0, w, 0, h),
        Position         = UDim2.new(0.5, -w/2, 0.5, -h/2),
        BackgroundColor3 = Color3.fromRGB(10, 10, 16),
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = gui,
    })
    Create("UICorner",  { CornerRadius = UDim.new(0, 18), Parent = main })
    Create("UIStroke",  { Color = Color3.fromRGB(0, 150, 255), Transparency = 0.35, Thickness = 1.5, Parent = main })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(18, 18, 26)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(12, 12, 18)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(8,  8,  14)),
        },
        Rotation = 150,
        Parent = main,
    })
    CreateScanline(main)
    return main
end

-- LOADING LOGIC ------------------------------------------------------------------------------
local function ShowInitializingScreen(validKey)
    local existing = CoreGui:FindFirstChild("EternalHubKeySystem")
    if existing then existing:Destroy() end

    local gui = Create("ScreenGui", {
        Name           = "EternalHubKeySystem",
        IgnoreGuiInset = true,
        ResetOnSpawn   = false,
    })
    gui.Parent = (gethui and gethui()) or CoreGui

    local bg       = BuildBackground(gui)
    local glowFrm  = PulsatingGlow(gui)
    local main     = BuildCard(gui, 380, 220)

    main.BackgroundTransparency = 1
    main.Position = UDim2.new(0.5, -190, 0.58, -110)
    TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -190, 0.5, -110),
    }):Play()

    local logoLbl = Create("TextLabel", {
        Text                = "⬡  ETERNAL HUB",
        Size                = UDim2.new(1, 0, 0, 46),
        Position            = UDim2.new(0, 0, 0, 10),
        BackgroundTransparency = 1,
        TextColor3          = Color3.fromRGB(255, 255, 255),
        Font                = Enum.Font.GothamBlack,
        TextSize            = 22,
        ZIndex              = 4,
        Parent              = main,
    })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 210, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 100, 255)),
        },
        Parent = logoLbl,
    })

    local spinBG = Create("Frame", {
        Size                   = UDim2.new(0, 54, 0, 54),
        Position               = UDim2.new(0.5, -27, 0, 62),
        BackgroundColor3       = Color3.fromRGB(18, 18, 28),
        BackgroundTransparency = 0,
        BorderSizePixel        = 0,
        ZIndex                 = 4,
        Parent                 = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = spinBG })
    Create("UIStroke", { Color = Color3.fromRGB(30, 30, 50), Transparency = 0, Thickness = 2, Parent = spinBG })

    local spinArc = Create("Frame", {
        Size                   = UDim2.new(0, 54, 0, 54),
        Position               = UDim2.new(0.5, -27, 0, 62),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ZIndex                 = 5,
        Parent                 = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = spinArc })
    Create("UIStroke", { Color = Color3.fromRGB(0, 180, 255), Transparency = 0, Thickness = 3, Parent = spinArc })

    task.spawn(function()
        local rot = 0
        while spinArc and spinArc.Parent do
            rot = (rot + 6) % 360
            spinArc.Rotation = rot
            task.wait(0.016)
        end
    end)

    local initLabel = Create("TextLabel", {
        Text                   = "Initializing Script",
        Size                   = UDim2.new(1, 0, 0, 28),
        Position               = UDim2.new(0, 0, 0, 126),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(200, 200, 220),
        Font                   = Enum.Font.GothamBold,
        TextSize               = 15,
        ZIndex                 = 4,
        Parent                 = main,
    })

    local progBG = Create("Frame", {
        Size             = UDim2.new(0.8, 0, 0, 3),
        Position         = UDim2.new(0.1, 0, 0, 164),
        BackgroundColor3 = Color3.fromRGB(18, 18, 28),
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progBG })

    local progFill = Create("Frame", {
        Size             = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 180, 255),
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = progBG,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progFill })

    task.spawn(function()
        while progFill and progFill.Parent do
            TweenService:Create(progFill, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.65, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.wait(0.65)
            TweenService:Create(progFill, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(0.05, 0, 1, 0), Position = UDim2.new(0.95, 0, 0, 0)
            }):Play()
            task.wait(0.55)
            progFill.Position = UDim2.new(0, 0, 0, 0)
            progFill.Size     = UDim2.new(0, 0, 1, 0)
            task.wait(0.05)
        end
    end)

    task.spawn(function()
        local dots = {"", ".", "..", "..."}
        local i = 1
        while initLabel and initLabel.Parent do
            initLabel.Text = "Loading Hub" .. dots[i]
            i = (i % #dots) + 1
            task.wait(0.45)
        end
    end)

    task.spawn(function()
        task.wait(0.8) 
        -- FETCH AND EXECUTE THE MAIN SCRIPT --------------------------------------------------
        local ok, result = pcall(function()
            local rawCode = game:HttpGet(ScriptURL)
            local fn, err = loadstring(rawCode)
            if not fn then error(err) end
            fn()
        end)

        if not ok then
            if initLabel and initLabel.Parent then
                initLabel.Text      = "⚠ Load Error"
                initLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            end
            warn("Eternal Hub Load Error: " .. tostring(result))
            task.wait(5)
        end

        if gui and gui.Parent then
            TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, -190, 0.44, -110),
            }):Play()
            TweenService:Create(bg,       TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(glowFrm,  TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
            task.wait(0.55)
            gui:Destroy()
        end
    end)
end

local function BuildKeyGUI()
    local existing = CoreGui:FindFirstChild("EternalHubKeySystem")
    if existing then existing:Destroy() end

    local gui = Create("ScreenGui", {
        Name           = "EternalHubKeySystem",
        IgnoreGuiInset = true,
        ResetOnSpawn   = false,
    })
    gui.Parent = (gethui and gethui()) or CoreGui

    local bg      = BuildBackground(gui)
    local glowFrm = PulsatingGlow(gui)
    local main    = BuildCard(gui, 420, 370)
    MakeDraggable(main)

    local topBar = Create("Frame", {
        Size                   = UDim2.new(1, 0, 0, 52),
        BackgroundColor3       = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.55,
        BorderSizePixel        = 0,
        ZIndex                 = 3,
        Parent                 = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 18), Parent = topBar })

    local logoLbl = Create("TextLabel", {
        Text                   = "⬡  ETERNAL HUB",
        Size                   = UDim2.new(0, 200, 0, 52),
        Position               = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(255, 255, 255),
        Font                   = Enum.Font.GothamBlack,
        TextSize               = 20,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 5,
        Parent                 = topBar,
    })

    local discordBtn = Create("TextButton", {
        Text             = "💬  Discord",
        Size             = UDim2.new(0, 108, 0, 32),
        Position         = UDim2.new(1, -120, 0.5, -16),
        BackgroundColor3 = Color3.fromRGB(88, 101, 242),
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        ZIndex           = 6,
        Parent           = topBar,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = discordBtn })
    ButtonAnimation(discordBtn, Color3.fromRGB(88, 101, 242), Color3.fromRGB(110, 125, 255))

    discordBtn.MouseButton1Click:Connect(function()
        if pcall(setclipboard, DiscordLink) then discordBtn.Text = "✓ Copied!" task.delay(2, function() discordBtn.Text = "💬 Discord" end) end
    end)

    local badgeFrame = Create("Frame", {
        Size                   = UDim2.new(0, 210, 0, 26),
        Position               = UDim2.new(0.5, -105, 0, 62),
        BackgroundColor3       = Color3.fromRGB(0, 140, 255),
        BackgroundTransparency = 0.82,
        BorderSizePixel        = 0,
        ZIndex                 = 4,
        Parent                 = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = badgeFrame })
    Create("UIStroke",  { Color = Color3.fromRGB(0, 160, 255), Transparency = 0.5, Thickness = 1, Parent = badgeFrame })
    Create("TextLabel", {
        Text                   = "🔐  Eternal Authentication",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(100, 200, 255),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = 12,
        ZIndex                 = 5,
        Parent                 = badgeFrame,
    })

    local inputContainer = Create("Frame", {
        Size             = UDim2.new(0.88, 0, 0, 48),
        Position         = UDim2.new(0.06, 0, 0, 128),
        BackgroundColor3 = Color3.fromRGB(6, 6, 10),
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = inputContainer })
    local inputStroke = Create("UIStroke", { Color = Color3.fromRGB(35, 35, 55), Thickness = 1.5, Parent = inputContainer })

    local keyBox = Create("TextBox", {
        Text                   = "",
        Size                   = UDim2.new(0, 232, 1, 0),
        Position               = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(240, 240, 255),
        PlaceholderText        = "Enter your Panda key...",
        PlaceholderColor3      = Color3.fromRGB(75, 75, 100),
        Font                   = Enum.Font.Gotham,
        TextSize               = 13,
        TextXAlignment         = Enum.TextXAlignment.Left,
        ClearTextOnFocus       = false,
        ZIndex                 = 5,
        Parent                 = inputContainer,
    })

    local pasteBtn = Create("TextButton", {
        Text             = "⎘ Paste",
        Size             = UDim2.new(0, 70, 0, 32),
        Position         = UDim2.new(1, -78, 0.5, -16),
        BackgroundColor3 = Color3.fromRGB(20, 25, 42),
        TextColor3       = Color3.fromRGB(140, 190, 255),
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        ZIndex           = 6,
        Parent           = inputContainer,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 7), Parent = pasteBtn })
    ButtonAnimation(pasteBtn, Color3.fromRGB(20, 25, 42), Color3.fromRGB(30, 38, 65))

    local getKeyBtn = Create("TextButton", {
        RichText         = true,
        Text             = "<b>🔗  GET KEY (Panda System)</b>\n<font size='11' color='rgb(130,130,155)'>Acesso de 24 Horas</font>",
        Size             = UDim2.new(0.88, 0, 0, 52),
        Position         = UDim2.new(0.06, 0, 0, 190),
        BackgroundColor3 = Color3.fromRGB(14, 14, 22),
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Font             = Enum.Font.GothamBold,
        TextSize         = 14,
        ZIndex           = 4,
        Parent           = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = getKeyBtn })
    Create("UIStroke",  { Color = Color3.fromRGB(50, 60, 90), Transparency = 0.2, Thickness = 1.2, Parent = getKeyBtn })
    ButtonAnimation(getKeyBtn, Color3.fromRGB(14, 14, 22), Color3.fromRGB(20, 22, 36))

    local checkBtn = Create("TextButton", {
        Text             = "⚡  Verify & Launch",
        Size             = UDim2.new(0.88, 0, 0, 50),
        Position         = UDim2.new(0.06, 0, 0, 256),
        BackgroundColor3 = Color3.fromRGB(0, 130, 255),
        TextColor3       = Color3.fromRGB(255, 255, 255),
        Font             = Enum.Font.GothamBlack,
        TextSize         = 16,
        ZIndex           = 4,
        Parent           = main,
    })
    Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = checkBtn })
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,  160, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 60, 255)),
        },
        Rotation = 90,
        Parent   = checkBtn,
    })
    ButtonAnimation(checkBtn, Color3.fromRGB(0, 130, 255), Color3.fromRGB(30, 160, 255))

    local status = Create("TextLabel", {
        Text                   = "Awaiting key input...",
        Size                   = UDim2.new(1, 0, 0, 22),
        Position               = UDim2.new(0, 0, 0, 330),
        BackgroundTransparency = 1,
        TextColor3             = Color3.fromRGB(80, 80, 110),
        Font                   = Enum.Font.GothamMedium,
        TextSize               = 11,
        ZIndex                 = 4,
        Parent                 = main,
    })

    main.BackgroundTransparency = 1
    main.Position = UDim2.new(0.5, -210, 0.6, -185)
    TweenService:Create(main, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -210, 0.5, -185),
    }):Play()

    pasteBtn.MouseButton1Click:Connect(function()
        local ok, clip = pcall(getclipboard)
        if ok and type(clip) == "string" and clip ~= "" then
            keyBox.Text        = clip
            status.Text        = "Chave colada com sucesso!"
            status.TextColor3  = Color3.fromRGB(100, 200, 255)
        end
    end)

    getKeyBtn.MouseButton1Click:Connect(function()
        local link = "https://new.pandadevelopment.net/getkey/" .. ServiceID .. "?hwid=" .. GetHWID()
        if pcall(setclipboard, link) then
            status.Text       = "🔗 Link copiado! Abra no navegador."
            status.TextColor3 = Color3.fromRGB(0, 200, 255)
            task.delay(4, function()
                if status and status.Parent then
                    status.Text       = "Awaiting key input..."
                    status.TextColor3 = Color3.fromRGB(80, 80, 110)
                end
            end)
        end
    end)

    checkBtn.MouseButton1Click:Connect(function()
        local key = TrimKey(keyBox.Text)
        if key == "" then return end
        checkBtn.Text = "Authenticating..."
        task.spawn(function()
            local success, msg = ValidateKey(key)
            if success then
                pcall(writefile, KeyFileName, key)
                status.Text = "✅ Authenticated!"
                task.wait(0.5)
                ShowInitializingScreen(key)
            else
                status.Text = "❌ Error: " .. tostring(msg)
                checkBtn.Text = "⚡ Verify & Launch"
            end
        end)
    end)
end

-- LOADER INITIALIZATION ----------------------------------------------------------------------
task.spawn(function()
    local hasSaved = false
    local savedKey = ""
    pcall(function()
        if isfile and isfile(KeyFileName) then
            savedKey = readfile(KeyFileName)
            if TrimKey(savedKey) ~= "" then hasSaved = true end
        end
    end)

    if hasSaved then
        local valid, _ = ValidateKey(savedKey)
        if valid then
            ShowInitializingScreen(savedKey)
        else
            BuildKeyGUI()
        end
    else
        BuildKeyGUI()
    end
end)
