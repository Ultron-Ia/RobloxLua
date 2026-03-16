-- DEBUG TEST SCRIPT - Run this first to find the error
-- If there's an error in the main script, this will show it clearly.

local function debugNotify(title, msg)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = msg,
        Duration = 30
    })
    print("[SYNTHESIS DEBUG] " .. title .. ": " .. msg)
end

debugNotify("Step 1", "Carregando WindUI...")

local ok1, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not ok1 then debugNotify("ERRO Step 1", tostring(WindUI)); return end
debugNotify("Step 1", "WindUI carregado OK!")

local ok2, Window = pcall(function()
    return WindUI:CreateWindow({
        Title = "SYNTHESIS DEBUG",
        Icon = "shield",
        Author = "by Antigravity",
        Folder = "SynthesisMegaDebug",
        Size = UDim2.fromOffset(580, 460),
        Transparent = true,
        Theme = "Dark",
        SideBarWidth = 160,
    })
end)
if not ok2 then debugNotify("ERRO Step 2", tostring(Window)); return end
debugNotify("Step 2", "Window criada OK!")

local ok3, Tab = pcall(function()
    return Window:Tab({ Title = "Teste", Icon = "check" })
end)
if not ok3 then debugNotify("ERRO Step 3", tostring(Tab)); return end
debugNotify("Step 3", "Tab criada OK!")

local ok4, Sec = pcall(function()
    return Tab:Section({ Title = "Seção de Teste" })
end)
if not ok4 then debugNotify("ERRO Step 4", tostring(Sec)); return end
debugNotify("Step 4", "Section criada OK!")

local ok5 = pcall(function()
    Sec:Button({ Title = "Botão Teste", Callback = function() print("clicou!") end })
end)
if not ok5 then debugNotify("ERRO Step 5 Button", "Button falhou"); return end

local ok6 = pcall(function()
    Sec:Toggle({ Title = "Toggle Teste", Value = false, Callback = function(v) print(v) end })
end)
if not ok6 then debugNotify("ERRO Step 6 Toggle", "Toggle falhou"); return end

local ok7 = pcall(function()
    Sec:Slider({ Title = "Slider Teste", Step = 1, Value = { Min = 1, Max = 100, Default = 50 }, Callback = function(v) print(v) end })
end)
if not ok7 then debugNotify("ERRO Step 7 Slider", "Slider falhou"); return end

local ok8 = pcall(function()
    Sec:Dropdown({ Title = "Dropdown Teste", Values = {"A", "B"}, Value = "A", Callback = function(v) print(v) end })
end)
if not ok8 then debugNotify("ERRO Step 8 Dropdown", "Dropdown falhou"); return end

debugNotify("SUCESSO", "Todos os elementos carregaram corretamente!")
