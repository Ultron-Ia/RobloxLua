import re

with open('main.lua', encoding='utf-8') as f:
    txt = f.read()

# Fix Fluent:Notify -> WindUI:Notify
txt = txt.replace('Fluent:Notify(', 'WindUI:Notify(')

# Fix AddDropdown with string flag: :AddDropdown("flag", {opts}) -> :Dropdown({opts})
txt = re.sub(r':AddDropdown\("[^"]+",\s*', ':Dropdown(', txt)

# Fix AddParagraph on Tabs.Main -> use _Sec1:Paragraph
txt = txt.replace('Tabs.Main:AddParagraph(', '_Sec1:Paragraph(')
# Convert Content = to Desc = in Paragraphs
txt = re.sub(r'(Paragraph\([^)]*?)Content\s*=\s*', r'\1Desc = ', txt)

# Fix SetValues/Refresh
txt = txt.replace(':SetValues(GetPlayers())', ':Refresh(GetPlayers(), true)')

# Fix Window:SelectTab(1) -> Tabs.Main:Select()
txt = txt.replace('Window:SelectTab(1)', 'Tabs.Main:Select()')

# Fix settings block
settings_block = '''    -- SETTINGS
    local _SettSec = Tabs.Settings:Section({Title = "Configuration", Icon = "settings"})
    local _CM = Window.ConfigManager
    local _cfg = _CM:CreateConfig("SynthesisMega")
    _SettSec:Button({Title = "Save Config", Callback = function() _cfg:Save() end})
    _SettSec:Button({Title = "Load Config", Callback = function() _cfg:Load() end})
    local _ThemeSec = Tabs.Settings:Section({Title = "Theme", Icon = "palette"})
    _ThemeSec:Dropdown({Title = "Select Theme", Values = {"Dark", "Light", "Abyss", "Aqua"}, Value = "Dark", Callback = function(v) WindUI:SetTheme(v) end})

    -- CHEAT CORE'''

if '-- SETTINGS' in txt and 'SaveManager' not in txt:
    # Check if it still has a proper settings block
    if 'BuildConfigSection' in txt or 'InterfaceManager' in txt:
        txt = re.sub(r'-- SETTINGS.*?-- CHEAT CORE', settings_block, txt, flags=re.DOTALL)
    elif '-- SETTINGS' in txt and '-- CHEAT CORE' in txt and '_SettSec' not in txt:
        txt = re.sub(r'-- SETTINGS.*?-- CHEAT CORE', settings_block, txt, flags=re.DOTALL)
else:
    # No settings section yet, insert before CHEAT CORE
    txt = txt.replace('    -- CHEAT CORE', settings_block.replace('    -- SETTINGS\n', '') + '\n\n    -- CHEAT CORE', 1)

# Fix Rivals toggle without Callback
txt = txt.replace(
    '_Sec2:Toggle({Title = "Auto Parry", Value = false})',
    '_Sec2:Toggle({Title = "Auto Parry", Value = false, Callback = function(v) end})'
)

# Fix DandyESP toggles - they used to have end) not end})
# These are already converted to _SecXX:Toggle pattern, should be fine

# Error handler - make it show errors
txt = txt.replace(
    'game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Fatal Error", Text = tostring(err), Duration = 20})',
    'print("[SYNTHESIS ERROR]: " .. tostring(err))\n    warn(tostring(err))\n    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "ERRO", Text = tostring(err):sub(1,200), Duration = 30})'
)

with open('main.lua', 'w', encoding='utf-8', newline='\n') as f:
    f.write(txt)

remaining_fluent = txt.count('Fluent')
remaining_adddd = txt.count('AddDropdown')
remaining_setvals = txt.count('SetValues')
print(f"Done!")
print(f"Remaining 'Fluent' refs: {remaining_fluent}")
print(f"Remaining 'AddDropdown' refs: {remaining_adddd}")
print(f"Remaining 'SetValues' refs: {remaining_setvals}")
print(f"Total lines: {txt.count(chr(10))}")
