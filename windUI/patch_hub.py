import re

filepath = r'c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\windUI\main.lua'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip_next = False

for i in range(len(lines)):
    if skip_next:
        skip_next = False
        continue
        
    line = lines[i]
    
    # 1. Fix GameSelector (Line 75-77)
    if 'local GameSelector = Tabs.Main:Dropdown' in line or 'local GameSelector = Tabs.Main:AddDropdown' in line:
        if i + 1 < len(lines) and 'GameSelector:OnChanged(function(v)' in lines[i+1]:
            new_lines.append('    local GameSelector = _Sec1:Dropdown({Title = "Select Game Module", Values = {"...", "Rivals", "Brookhaven", "Dandy\'s World", "Social/Talking Hub", "[LUCKY COWARD] Shenanigans de Jujutsu", "Peça de Sailor"}, Value = "...", Callback = function(v)\n')
            skip_next = True
            continue

    # 2. Fix variable-based OnChanged (BPD, SPD, etc.)
    match = re.search(r'local (\w+PD) = ([\w.]+):Dropdown\(\{(.*)\}\)', line)
    if match and i + 1 < len(lines):
        var_name = match.group(1)
        tab_name = match.group(2)
        opts = match.group(3)
        if f'{var_name}:OnChanged(function' in lines[i+1]:
            cb_match = re.search(r'OnChanged\(function\((\w+)\)\s*(.*?)\s*end\)', lines[i+1])
            if cb_match:
                cb_arg = cb_match.group(1)
                cb_body = cb_match.group(2)
                new_lines.append(f'            local {var_name} = {tab_name}:Dropdown({{{opts}, Callback = function({cb_arg}) {cb_body} end}})\n')
                skip_next = True
                continue

    # 3. Fix chained OnChanged
    if '):OnChanged(function(' in line:
        line = re.sub(r'\):OnChanged\(function\((\w+)\)\s*(.*?)\s*end\)', r', Callback = function(\1) \2 end})', line)
    
    new_lines.append(line)

content = ''.join(new_lines)

# 4. Fix specific large OnChanged closure
# The OnChanged(function(v) ... end) for GameSelector ends with end)
# We changed it to a Dropdown({...}) so it needs end})
# It's usually followed by the Aimbot section.
content = content.replace('    end)\n\n\n    -- POPULATE AIMBOT', '    end})\n\n\n    -- POPULATE AIMBOT')

# 5. Fix any other remaining end) that look like OnChanged closures
content = re.sub(r'(\s+)end\)\s*\n\s*-- POPULATE', r'\1end})\n\n    -- POPULATE', content)

with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print("Patch applied.")
