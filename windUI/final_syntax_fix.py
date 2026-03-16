import re

filepath = r'c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\windUI\main.lua'

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fix missing } in closures for WindUI elements (Button, Toggle, Dropdown, Slider, Paragraph, Input, Colorpicker)
# The pattern is usually: Callback = function(...) ... end)
# We need it to be: Callback = function(...) ... end})
# But ONLY if it's the closure of the table passed to the UI element.

element_types = ["Button", "Toggle", "Dropdown", "Slider", "Paragraph", "Input", "Colorpicker"]

for etype in element_types:
    # Pattern: :etype({ ... Callback = function(...) ... end)
    # This is tricky because of nesting. Let's try to fix the most obvious ones first.
    
    # Simple one-line replacements for common patterns found in the file
    content = content.replace("Callback = function(v) end)", "Callback = function(v) end})")
    content = content.replace("Callback = function() end)", "Callback = function() end})")

# 2. Fix the "if v then" missing "end" in Toggles
# Pattern: Callback = function(v) if v then ... end})
# Should be: Callback = function(v) if v then ... end end})
# (Note: This assumes there is no 'else')

# Find all blocks that look like a Toggle with an 'if v then' that ends with just one 'end})'
# We'll use a regex for this.
def fix_toggle_callback(match):
    full_block = match.group(0)
    # If it has an 'else', it already has the if-end and function-end? 
    # Let's count 'if' vs 'end'
    ifs = full_block.count('if ')
    ends = full_block.count('end')
    
    # We expect: 
    # 1 end for the inner function (Connect etc) 
    # 1 end for the 'if v then'
    # 1 end for the 'Callback = function(v)'
    
    # Wait, simple heuristic: if it has 'if v then' and only 2 ends before the }), it needs one more.
    # Actually, let's just look for 'else' first.
    if 'else' not in full_block:
        if full_block.count('end') == 2: # One for Connect/pcall, one for function? 
             # No, if it has Connect, it has 3 blocks (function-if-connect).
             pass

    return full_block

# Actually, let's just do targeted fixes for the known broken HUBs.

# 3. Specifically fix Rivals (lines 80-91)
content = content.replace(
    '_Sec2:Toggle({Title = "Auto Parry", Value = false, Callback = function(v) end)',
    '_Sec2:Toggle({Title = "Auto Parry", Value = false, Callback = function(v) end})'
)
content = content.replace(
    '                end)\n            end)\n\n        elseif v == "Brookhaven" and not BuiltHubs["Brookhaven"] then',
    '                end)\n            end})\n\n        elseif v == "Brookhaven" and not BuiltHubs["Brookhaven"] then'
)

# 4. Fix Brookhaven hub end (approx line 860)
# I need to see where it ends.
# I'll use a more general replacement.

# 5. Fix the pattern of 'end)' at the end of a section element
# This is usually before a new 'local _Sec' or 'elseif v ==' or 'end})' (if it's the last one)
content = re.sub(r'(\s+Callback = function\(.*?\).*?end)\)\n(\s+(?:local _Sec|elseif v ==|--))', r'\1})\n\2', content, flags=re.DOTALL)

# 6. Fix the "end end})" found earlier
content = content.replace("end end})", "end\n            end})")

# 7. Final fix for the GameSelector callback closure
# It should be 'end})' but sometimes it's double.
# Let's ensure line 1682 is clean.
content = content.replace('    end})\n\n\n    -- POPULATE AIMBOT', '    end})\n\n    -- POPULATE AIMBOT')

with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print("Final Syntax Fix complete.")
