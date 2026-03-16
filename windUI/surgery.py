import re

filepath = r'c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\windUI\main.lua'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for i, line in enumerate(lines, 1):
    # Fix the broken OnChanged + Callback patterns
    # Pattern: ...:OnChanged(function(v) ... end, Callback = function(v) ... end})
    if ':OnChanged(' in line:
        # Extract the first callback body
        cb1_match = re.search(r'function\((\w+)\)\s*(.*?)\s*end', line)
        if cb1_match:
            arg = cb1_match.group(1)
            body = cb1_match.group(2)
            
            # Find the element method and options
            # element({opts}):OnChanged
            prefix_match = re.search(r'(_Sec\d+):(\w+)\(\{(.*?)\}\):OnChanged', line)
            if prefix_match:
                sec = prefix_match.group(1)
                method = prefix_match.group(2)
                opts = prefix_match.group(3)
                
                # Check for second callback (merged by mistake previously)
                cb2_match = re.search(r'Callback\s*=\s*function\(\w+\)\s*(.*?)\s*end', line)
                if cb2_match:
                    body += " " + cb2_match.group(1)
                
                # Clean up opts (remove any existing Callback if it was partially added)
                opts = re.sub(r',\s*Callback\s*=\s*.*', '', opts)
                
                new_line = f'    {sec}:{method}({{{opts}, Callback = function({arg}) {body} end}})\n'
                new_lines.append(new_line)
                continue
        
    new_lines.append(line)

content = "".join(new_lines)

# Fix GameSelector end
content = content.replace('    WindUI:Notify({Title = "Synthesis EXTREME", Content = "Advanced Engine Loaded. Silent Aim & Spinbot ready.", Duration = 7})\nend)', '    WindUI:Notify({Title = "Synthesis EXTREME", Content = "Advanced Engine Loaded. Silent Aim & Spinbot ready.", Duration = 7})\nend})')

with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print("Surgery complete.")
print("Remaining OnChanged:", content.count(':OnChanged'))
print("Brace Check ( success count ):", content.count('{'), "vs", content.count('}'))
