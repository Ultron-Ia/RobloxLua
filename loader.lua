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
    local ok, inst = pcall(Instance.new, className)
    if not ok then return nil end
    
    local parent = props.Parent
    props.Parent = nil
    
    for k, v in pairs(props) do
        pcall(function() inst[k] = v end)
    end
    
    inst.Parent = parent
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
    if not reqFn then return false, "HTTP not supported" end

    local body
    local encOk, encResult = pcall(HttpService.JSONEncode, HttpService, {
        ServiceID = ServiceID,
        HWID      = GetHWID(),
        Key       = key,
    })
    if not encOk then return false, "JSON Error" end
    body = encResult

    local reqOk, response = pcall(reqFn, {
        Url     = "https://new.pandadevelopment.net/api/v1/keys/validate",
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = body,
    })

    if not reqOk then return false, "Network Error" end
    if not response or type(response) ~= "table" then return false, "No response" end
    
    local decOk, data = pcall(HttpService.JSONDecode, HttpService, response.Body or "")
    if not decOk or type(data) ~= "table" then return false, "Decode Error" end

    local isValid = (data.Authenticated_Status == "Success")
    return isValid, tostring(data.Note or "")
end

-- UI HELPERS ---------------------------------------------------------------------------------
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function ButtonAnimation(button, normalColor, hoverColor)
    if not button then return end
    local nc = normalColor or button.BackgroundColor3
    button.MouseEnter:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = hoverColor or Color3.fromRGB(40,40,60) }):Play() end)
    button.MouseLeave:Connect(function() TweenService:Create(button, TweenInfo.new(0.2), { BackgroundColor3 = nc }):Play() end)
end

local function BuildBackground(gui)
    local bg = Create("Frame", { Name = "BG", Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.fromRGB(5,5,10), ZIndex = 0, Parent = gui })
    return bg
end

local function BuildCard(gui, w, h)
    local main = Create("Frame", { Name = "Main", Size = UDim2.new(0,w,0,h), Position = UDim2.new(0.5,-w/2,0.5,-h/2), BackgroundColor3 = Color3.fromRGB(12,12,18), BorderSizePixel = 0, ZIndex = 2, Parent = gui })
    Create("UICorner", { CornerRadius = UDim.new(0, 15), Parent = main })
    local stroke = Create("UIStroke", { Color = Color3.fromRGB(0, 150, 255), Thickness = 1.5, Parent = main })
    return main
end

-- MAIN LOAD LOGIC ----------------------------------------------------------------------------
local function ShowInitializingScreen()
    local existing = CoreGui:FindFirstChild("EternalHubKeySystem")
    if existing then existing:Destroy() end

    local gui = Create("ScreenGui", { Name = "EternalHubKeySystem", IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = (gethui and gethui()) or CoreGui })
    local bg = BuildBackground(gui)
    local main = BuildCard(gui, 380, 200)

    local lbl = Create("TextLabel", { Text = "ETERNAL HUB: Initializing...", Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBold, TextSize = 18, ZIndex = 5, Parent = main })
    
    task.spawn(function()
        task.wait(1)
        local ok, result = pcall(function()
            local code = game:HttpGet(ScriptURL)
            loadstring(code)()
        end)
        if not ok then lbl.Text = "Load Error: See Console"; warn(result) end
        task.wait(1)
        gui:Destroy()
    end)
end

local function BuildKeyGUI()
    local existing = CoreGui:FindFirstChild("EternalHubKeySystem")
    if existing then existing:Destroy() end

    local gui = Create("ScreenGui", { Name = "EternalHubKeySystem", IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = (gethui and gethui()) or CoreGui })
    local bg = BuildBackground(gui)
    local main = BuildCard(gui, 420, 360)
    MakeDraggable(main)

    local title = Create("TextLabel", { Text = "⬡ ETERNAL HUB", Size = UDim2.new(1,0,0,50), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255), Font = Enum.Font.GothamBlack, TextSize = 20, ZIndex = 5, Parent = main })

    local inputFrame = Create("Frame", { Size = UDim2.new(0.85,0,0,45), Position = UDim2.new(0.075,0,0,100), BackgroundColor3 = Color3.fromRGB(18,18,25), ZIndex = 5, Parent = main })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = inputFrame })

    local keyBox = Create("TextBox", { Text = "", PlaceholderText = "Enter Panda Key...", Size = UDim2.new(1,-100,1,0), Position = UDim2.new(0,10,0,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255,255,255), TextXAlignment = "Left", ZIndex = 6, Parent = inputFrame })

    local pasteBtn = Create("TextButton", { Text = "Paste", Size = UDim2.new(0,80,0,30), Position = UDim2.new(1,-85,0.5,-15), BackgroundColor3 = Color3.fromRGB(30,30,45), TextColor3 = Color3.fromRGB(200,200,250), Font = "GothamBold", ZIndex = 7, Parent = inputFrame })
    Create("UICorner", { CornerRadius = UDim.new(0, 6), Parent = pasteBtn })

    local getKeyBtn = Create("TextButton", { Text = "GET KEY (Panda System)", Size = UDim2.new(0.85,0,0,50), Position = UDim2.new(0.075,0,0,170), BackgroundColor3 = Color3.fromRGB(25,25,35), TextColor3 = Color3.fromRGB(255,255,255), Font = "GothamBold", ZIndex = 5, Parent = main })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = getKeyBtn })
    ButtonAnimation(getKeyBtn, Color3.fromRGB(25,25,35), Color3.fromRGB(35,35,50))

    local checkBtn = Create("TextButton", { Text = "VERIFY & LAUNCH", Size = UDim2.new(0.85,0,0,50), Position = UDim2.new(0.075,0,0,235), BackgroundColor3 = Color3.fromRGB(0,120,255), TextColor3 = Color3.fromRGB(255,255,255), Font = "GothamBlack", TextSize = 16, ZIndex = 5, Parent = main })
    Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = checkBtn })
    ButtonAnimation(checkBtn, Color3.fromRGB(0,120,255), Color3.fromRGB(30,150,255))

    local status = Create("TextLabel", { Text = "Awaiting input...", Size = UDim2.new(1,0,0,30), Position = UDim2.new(0,0,1,-40), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150,150,160), Font = "Gotham", TextSize = 12, ZIndex = 5, Parent = main })

    pasteBtn.MouseButton1Click:Connect(function()
        local ok, clip = pcall(getclipboard)
        if ok and clip ~= "" then keyBox.Text = clip; status.Text = "Key pasted!" end
    end)

    getKeyBtn.MouseButton1Click:Connect(function()
        local link = "https://new.pandadevelopment.net/getkey/" .. ServiceID .. "?hwid=" .. GetHWID()
        if pcall(setclipboard, link) then status.Text = "Link copied! Paste in browser." end
    end)

    checkBtn.MouseButton1Click:Connect(function()
        local key = TrimKey(keyBox.Text)
        if key == "" then return end
        checkBtn.Text = "Verifying..."
        task.spawn(function()
            local ok, msg = ValidateKey(key)
            if ok then
                pcall(writefile, KeyFileName, key)
                status.Text = "Success!"
                task.wait(0.5)
                ShowInitializingScreen()
            else
                status.Text = "Invalid: " .. tostring(msg)
                checkBtn.Text = "VERIFY & LAUNCH"
            end
        end)
    end)
end

-- INIT ---------------------------------------------------------------------------------------
task.spawn(function()
    local saved = ""
    pcall(function() if isfile(KeyFileName) then saved = readfile(KeyFileName) end end)
    
    if saved ~= "" then
        local ok, _ = ValidateKey(saved)
        if ok then ShowInitializingScreen() else BuildKeyGUI() end
    else
        BuildKeyGUI()
    end
end)
