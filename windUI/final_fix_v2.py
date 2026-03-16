import re

filepath = r'c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\windUI\main.lua'
with open(filepath, 'r', encoding='utf-8') as f:
    txt = f.read()

# 1. Fix remaining AddParagraph on Tabs (WindUI doesn't support them on tabs)
txt = re.sub(r'Tabs\.(\w+):AddParagraph\(\{ Title = "([^"]+)", Content = "([^"]+)" \}\)', r'_Sec_Inline:Paragraph({ Title = "\2", Desc = "\3" })', txt)

# 2. Fix variable:OnChanged patterns
# Example: BPD:OnChanged(function(val) ... end)
# This is tricky because the variable was defined on the previous line.
# Let's fix common ones like BPD, SPD, etc.
def fix_var_onchanged(text, var_prefix):
    # Match: local BPD = Tab:AddDropdown(...) \n BPD:OnChanged(f)
    pattern = re.compile(
        r'local (' + var_prefix + r'\d*|[A-Z]+PD) = ([\w.]+):AddDropdown\("([^"]+)",\s*(\{.*?\})\)\s*\n\s*\1:OnChanged\(function\((\w+)\)\s*(.*?)\s*end\)',
        re.DOTALL
    )
    def replacer(m):
        var_name = m.group(1)
        tab_name = m.group(2)
        opts = m.group(4)
        arg = m.group(5)
        body = m.group(6)
        # Convert opts to WindUI (remove Default, add Callback)
        opts = re.sub(r',\s*Default\s*=\s*\d+', '', opts)
        if opts.endswith('}'):
            opts = opts[:-1] + f', Callback = function({arg}) {body} end}}'
        return f'local {var_name} = {tab_name}:Dropdown({opts})'
    return pattern.sub(replacer, text)

txt = fix_var_onchanged(txt, 'B') # Brookhaven
txt = fix_var_onchanged(txt, 'S') # Sailor / Social
txt = fix_var_onchanged(txt, 'D') # Dandy
txt = fix_var_onchanged(txt, 'J') # Jujutsu

# 3. Fix chained OnChanged: element(...):OnChanged(f)
txt = re.sub(r'(\w+):\w+\(\{(.*?)\}\):OnChanged\(function\((\w+)\)\s*(.*?)\s*end\)', r'\1:Dropdown({\2, Callback = function(\3) \4 end})', txt)
# Specifically fix the Toggle/Slider ones too
txt = re.sub(r'(\w+):(Toggle|Slider|Colorpicker|Dropdown)\(\{(.*?)\}\):OnChanged\(function\((\w+)\)\s*(.*?)\s*end\)', r'\1:\2({\3, Callback = function(\4) \5 end})', txt)

# 4. Fix remaining Fluent:Notify
txt = txt.replace('Fluent:Notify(', 'WindUI:Notify(')

# 5. Fix SetValues -> Refresh  
txt = txt.replace(':SetValues(GetPlayers())', ':Refresh(GetPlayers(), true)')

# 6. Fix the GameSelector block closure
# It's at the end of the script, before the Projektile ESP or Aimbot/Visuals populate starts
# Wait, look at the view_file results.
# Line 1938 is the end of the pcall wrap? No, pcall ends on 1942.
# GameSelector callback wrap ends on 1938.
txt = txt.replace('    end)\n\n    Tabs.Main:Select()', '    end})\n\n    Tabs.Main:Select()')

# 7. Fix standalone AddDropdown -> Dropdown
txt = re.sub(r':AddDropdown\("([^"]+)",\s*', ':Dropdown(', txt)

with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
    f.write(txt)

# Verify
print("Remaining OnChanged:", txt.count(':OnChanged'))
print("Remaining Fluent:", txt.count('Fluent'))
print("Remaining AddDropdown:", txt.count('AddDropdown'))
