import re

filepath = r'c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\windUI\main.lua'

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fix Connect(function() ... end}) -> end)
# We look for Connect(function() and then the nearest end})
# (This is a bit risky with regex, but let's try specific ones first or a non-greedy match)

# Pattern: Connect(function() [content] end})
# We want to change the end}) to end)
content = re.sub(r'(Connect\(function\(\).*?)end\}\)', r'\1end)', content, flags=re.DOTALL)

# 2. Fix pcall(function() ... end}) -> end)
content = re.sub(r'(pcall\(function\(\).*?)end\}\)', r'\1end)', content, flags=re.DOTALL)

# 3. Specifically fix the one on 607 (if regex missed it or it was slightly different)
content = content.replace('Velocity = Vector3.new(0,0,0) end})', 'Velocity = Vector3.new(0,0,0)\n                                end)')

# 4. Check for double end}) and clean up
# Often we have end\n end})
# If we have end})\n\n end}), the first one is likely extra.
# But let's trust the analyzer.

with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print("Fix Braces V4 complete.")
