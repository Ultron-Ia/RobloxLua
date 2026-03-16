import re

filepath = r'c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\windUI\main.lua'

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for i, line in enumerate(lines, 1):
    # Pattern: any line that is just "            end)" or "                end)"...
    # basically whitespace followed by end)
    # AND we are in the hub section (between 75 and 1682)
    
    if 75 <= i <= 1681:
        if re.match(r'^\s+end\)\s*$', line):
            # Check if previous lines suggest this is an element closure
            # Actually, most end) in the hubs should be end}) except for Connect()
            
            # Let's check the line itself
            indent = len(line) - len(line.lstrip())
            new_lines.append(line.replace("end)", "end})"))
            continue
        
        # Also fix some specific malformed ones
        if 'end  end' in line:
            new_lines.append(line.replace('end  end', 'end end'))
            continue

    new_lines.append(line)

# Global replacements for common artifacts of previous failed fixes
content = "".join(new_lines)
content = content.replace("end end})", "end\n            end})")
content = content.replace("end})})", "end})") # Fix double closures if they occur

with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print("Mega Fix complete.")
