import re

filepath = r'c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\windUI\main.lua'

extra_brace_lines = [
    212, 215, 324, 380, 412, 435, 460, 476, 493, 509, 530, 531, 537, 
    623, 687, 688, 691, 727, 770, 814, 859, 944, 998, 1043, 1083, 
    1097, 1143, 1146, 1169, 1204, 1368, 1371, 1419, 1439, 1453, 
    1471, 1501, 1526, 1585, 1586, 1595, 1621, 1640, 1661, 1682, 1778
]

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for i, line in enumerate(lines, 1):
    if i in extra_brace_lines:
        # Turn end}) into end) but preserve whitespace and other content
        if 'end})' in line:
            new_lines.append(line.replace('end})', 'end)'))
        else:
            new_lines.append(line)
    else:
        new_lines.append(line)

with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
    f.write("".join(new_lines))

print("Surgical Brace Fix complete.")
