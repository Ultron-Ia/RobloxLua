import re

filepath = r'c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\windUI\main.lua'

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for i, line in enumerate(lines, 1):
    # 1. Fix Connect(function() missing )
    # Often happens at the end of a block like: end\n else
    if 'Connect(function()' in line:
        # Check if the matching end is found before else
        pass 

    # 2. Fix Toggle/Dropdown missing })
    # We'll do this by specific line replacement based on the analyzer's findings
    
    # Line 1086 cluster (Loop Kill)
    if i == 1092 and '            end' in line and 'end)' not in line:
        new_lines.append('            end)\n')
        continue
    if i == 1096 and '            end)' in line and 'end})' not in line:
        new_lines.append('            end})\n')
        continue

    # Line 1373 cluster (Control Player)
    if i == 1406 and '            end' in line and 'end})' not in line:
        new_lines.append('            end})\n') # Needs }) to close Toggle call
        continue

    # Line 1441 cluster (Attach)
    if i == 1447 and '            end' in line and 'end)' not in line:
        new_lines.append('            end)\n')
        continue
    if i == 1451 and '            end)' in line and 'end})' not in line:
        new_lines.append('            end})\n')
        continue

    # Line 1455 cluster (Spin on Head)
    if i == 1464 and '            end' in line and 'end)' not in line:
        # I need to see 1464 first. Let's assume it follows the pattern.
        pass

    # Line 1511 cluster (Sit on Shoulders)
    if i == 1518 and '            end' in line and 'end)' not in line:
        new_lines.append('            end)\n')
        continue
    if i == 1523 and '            end)' in line and 'end})' not in line:
        new_lines.append('            end})\n')
        continue

    # Line 1601 cluster (God Mode)
    if i == 1610 and '            end' in line and 'end)' not in line:
        new_lines.append('            end)\n')
        continue
    if i == 1617 and '            end)' in line and 'end})' not in line:
        new_lines.append('            end})\n')
        continue

    # Line 1639 cluster (Auto Dodge)
    if i == 1657 and '            end)' in line and 'end})' not in line:
        new_lines.append('            end})\n')
        continue

    new_lines.append(line)

content = "".join(new_lines)

# Also fix the end of GameSelector if needed.
# It was line 1661: end})
# Actually let's check if 1661 is correct.

with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print("Surgery V2 complete.")
