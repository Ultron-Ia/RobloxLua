import re

with open('main.lua', encoding='utf-8') as f:
    content = f.read()

# 1. Fix remaining Fluent:Notify -> WindUI:Notify
content = re.sub(r'\bFluent:Notify\(', 'WindUI:Notify(', content)

# 2. Fix AddParagraph -> use _Sec1:Paragraph
content = re.sub(
    r'Tabs\.Main:AddParagraph\(\{ Title = "([^"]*)", Content = "([^"]*)"\s*\}\)',
    r'_Sec1:Paragraph({Title = "\1", Desc = "\2"})',
    content
)

# 3. Fix all remaining AddDropdown("flag", {...}) -> Section:Dropdown({...})
# These are inline Dropdowns within hub callbacks that weren't matched by convert.py
def fix_add_dropdown(m):
    indent = m.group(1)
    var_assign = m.group(2)  # e.g. "local BPD = " or ""
    tab_var = m.group(3)     # e.g. "BTab"/"STab" etc.
    flag = m.group(4)        # flag string
    opts = m.group(5)        # the options table content
    
    # Try to detect current section for this tab - fallback: create inline section
    # For player dropdowns (BHPlayer, SailorPlayer, etc.) we put them right on the existing section
    # Actually, these are fine to leave on the tab if we create a minimal section first
    # Best approach: just convert to Section:Dropdown pattern using _Sec variable if available
    # For now, replace AddDropdown with a proper WindUI Dropdown call
    # Remove Default = N, replace with Value = first item
    opts_fixed = re.sub(r',?\s*Default\s*=\s*\d+', '', opts)
    return f'{indent}{var_assign}_Sec_DD{abs(hash(flag)) % 1000} = nil; {var_assign}Section_DD:Dropdown({{Title = "Target Player", Values = GetPlayers(), Value = "None", Callback = function(val) _G.SynthState.TargetPlayer = val end}})'

# Simpler: just replace AddDropdown("xxx", {opts}) -> direct Dropdown call
# We'll handle the OnChanged separately
def convert_dropdown(m):
    full = m.group(0)
    indent = re.match(r'^(\s*)', full, re.MULTILINE).group(1)
    
    # Find var assignment and call
    vm = re.match(r'(\s*)(local \w+\s*=\s*)?(\w+):AddDropdown\("([^"]*)",\s*(\{.*)', full, re.DOTALL)
    if not vm:
        return full
    
    indent2, var_part, tab_v, flag, opts_rest = vm.groups()
    var_part = var_part or ''
    
    # Remove Default = N from opts_rest
    opts_fixed = re.sub(r',?\s*Default\s*=\s*\d+', '', opts_rest)
    
    # Look for trailing :OnChanged in the match - we included it
    # The opts_fixed ends with } or })
    
    return f'{indent2}{var_part}{tab_v}:Dropdown({opts_fixed}'

# Actually, simplest approach: targeted replacements for the specific patterns we see
# Pattern 1: local XPD = Tab:AddDropdown("flag", {Title=..., Values=..., Default=1})
# -> local XPD = Section:Dropdown({Title=..., Values=..., Value="None", Callback=function(v) end})
# And the XPD:OnChanged(function(val)...) becomes the Callback

# Let's do it with a smarter regex that captures the full block including OnChanged
pattern = re.compile(
    r'(\s*)(local \w+\s*=\s*)(\w+):AddDropdown\("([^"]*)",\s*(\{[^}]+\})\)\s*\n(\s*\w+):OnChanged\(function\((\w+)\)\s*(.*?)\s*end\)',
    re.DOTALL
)

def replace_dropdown_with_onchanged(m):
    indent = m.group(1)
    var_assign = m.group(2).strip()  # e.g. "local BPD ="
    tab_var = m.group(3)
    flag = m.group(4)
    opts = m.group(5)
    var_name = m.group(6)  # the variable name used in OnChanged
    cb_arg = m.group(7)
    cb_body = m.group(8)
    
    # Remove Default = N from opts
    opts_fixed = re.sub(r',?\s*Default\s*=\s*\d+', '', opts)
    if opts_fixed.strip().endswith('}'):
        opts_fixed = opts_fixed.strip()[:-1]  # remove trailing }
    
    # Add Callback
    opts_final = f'{opts_fixed}, Callback = function({cb_arg}) {cb_body} end}}'
    
    return f'{indent}{var_assign} {tab_v}:Dropdown({opts_final})'

content = pattern.sub(replace_dropdown_with_onchanged, content)

# Pattern 2: standalone AddDropdown without var assignment
pattern2 = re.compile(
    r'(\s*)(\w+):AddDropdown\("([^"]*)",\s*(\{[^}]+\})\)',
    re.DOTALL
)

def replace_standalone_dropdown(m):
    indent = m.group(1)
    tab_var = m.group(2)
    flag = m.group(3)
    opts = m.group(4)
    opts_fixed = re.sub(r',?\s*Default\s*=\s*\d+', '', opts)
    return f'{indent}{tab_var}:Dropdown({opts_fixed})'

content = pattern2.sub(replace_standalone_dropdown, content)

# 4. Fix SetValues -> use SetValues (WindUI might support this, or just refresh)
# Actually WindUI Dropdown has :Refresh() method similar to Fluent
# Keep SetValues as is but note it may not work - use a workaround
content = re.sub(r':SetValues\(GetPlayers\(\)\)', ':Refresh(GetPlayers(), true)', content)

# 5. Fix Tabs.Main:AddParagraph remaining
content = re.sub(
    r'(\w+):AddParagraph\(\{[^}]*\}\)',
    lambda m: m.group(0).replace('AddParagraph', 'Paragraph').replace(m.group(1) + ':', '_Sec1:'),
    content
)

# 6. Fix Window:SelectTab(1) -> Tabs.Main:Select()
content = content.replace('Window:SelectTab(1)', 'Tabs.Main:Select()')

# 7. Fix Settings section - add WindUI config
old_settings = re.search(r'-- SETTINGS\s*\n.*?-- CHEAT CORE', content, re.DOTALL)
if old_settings:
    print("Found settings section, applying WindUI ConfigManager...")
    settings_block = '''    -- SETTINGS
    local SettingsSection = Tabs.Settings:Section({Title = "Configuration", Icon = "settings"})
    local _CM = Window.ConfigManager
    local _synthConfig = _CM:CreateConfig("SynthesisMega")
    SettingsSection:Button({Title = "Save Config", Callback = function() _synthConfig:Save() end})
    SettingsSection:Button({Title = "Load Config", Callback = function() _synthConfig:Load() end})
    local ThemeSection = Tabs.Settings:Section({Title = "Theme", Icon = "palette"})
    ThemeSection:Dropdown({Title = "Select Theme", Values = {"Dark", "Light", "Abyss", "Aqua"}, Value = "Dark", Callback = function(v) WindUI:SetTheme(v) end})

    -- CHEAT CORE'''
    content = re.sub(
        r'-- SETTINGS.*?-- CHEAT CORE',
        settings_block,
        content,
        flags=re.DOTALL
    )

# 8. Fix Rivals toggle (no callback - needs Callback = function(v) end)
content = content.replace(
    '_Sec2:Toggle({Title = "Auto Parry", Value = false})',
    '_Sec2:Toggle({Title = "Auto Parry", Value = false, Callback = function(v) end})'
)

# 9. Fix Notify - remove trailing comma issues
content = re.sub(r'(WindUI:Notify\(\{[^}]*)\bDuration=(\d+)\})', r'\1Duration=\2})', content)

with open('main.lua', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print("Fix script done!")
