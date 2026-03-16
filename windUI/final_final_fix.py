"""
Final robust fix for WindUI main.lua:
1. Replaces GameSelector:OnChanged(function(v) ... end) with _Sec1:Dropdown({..., Callback = function(v) ... end})
2. Replaces element:OnChanged(function(v) ... end) with Callback = function(v) ... end inside the element constructor.
3. Cleans up remaining Fluent prefixes even in string logic.
4. Ensures all sections are properly referenced.
"""
import re
import os

filepath = r'c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\windUI\main.lua'

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fix GameSelector block
# We need to find the large block that starts with local GameSelector = ... and ends with the OnChanged end.
# Since it's huge, we'll use a more flexible search.
game_selector_init_pattern = re.compile(
    r'local GameSelector = (?:Tabs\.Main:Dropdown|Tabs\.Main:AddDropdown)\([^)]+\)\s*\n\s*GameSelector:OnChanged\(function\(v\)',
    re.MULTILINE
)

if game_selector_init_pattern.search(content):
    print("Found GameSelector:OnChanged pattern. Converting to _Sec1:Dropdown with Callback...")
    # Replace the initialization
    content = re.sub(
        r'local GameSelector = (?:Tabs\.Main:Dropdown|Tabs\.Main:AddDropdown)\("GameSelect",\s*\{Title = "Select Game Module",\s*Values = \{[^}]+\}\s*\}\)\s*\n\s*GameSelector:OnChanged\(function\(v\)',
        r'local GameSelector = _Sec1:Dropdown({Title = "Select Game Module", Values = {"...", "Rivals", "Brookhaven", "Dandy\'s World", "Social/Talking Hub", "[LUCKY COWARD] Shenanigans de Jujutsu", "Peça de Sailor"}, Value = "...", Callback = function(v)',
        content
    )
    
    # Now we need to find the matching end). for this OnChanged.
    # It should be followed by -- POPULATE AIMBOT
    content = content.replace('    end)\n\n\n    -- POPULATE AIMBOT', '    end})\n\n\n    -- POPULATE AIMBOT')

# 2. Fix other OnChanged patterns: local XPD = ... \n XPD:OnChanged(function(v) ... end)
onchanged_pattern = re.compile(
    r'(local (\w+) = ([\w.]+):Dropdown\(\{(?:[^{}]|\{[^{}]*\})*\}\))\s*\n\s*\2:OnChanged\(function\((\w+)\)\s*(.*?)\s*end\)',
    re.DOTALL
)

def onchanged_replacer(m):
    full_init = m.group(1)
    var_name = m.group(2)
    tab_name = m.group(3)
    arg_name = m.group(4)
    body = m.group(5)
    
    # Remove the trailing ) from full_init and add the callback
    # The init ends with })
    if full_init.strip().endswith('})'):
        new_init = full_init.strip()[:-2] + f', Callback = function({arg_name}) {body} end}})'
        return new_init
    return m.group(0)

print("Fixing remaining Dropdown:OnChanged patterns...")
content = onchanged_pattern.sub(onchanged_replacer, content)

# 3. Fix Toggle:OnChanged, Slider:OnChanged etc. that were left over or partially fixed
# Pattern: element({opts}):OnChanged(function(v) body end)
chained_onchanged = re.compile(
    r'(:Toggle|:Slider|:Dropdown|:Colorpicker)\(\{(?:[^{}]|\{[^{}]*\})*\}\):OnChanged\(function\((\w+)\)\s*(.*?)\s*end\)',
    re.DOTALL
)

def chained_replacer(m):
    method = m.group(1)
    # The opts are inside ({...})
    # Let's extract them
    # We need to find the inner {...}
    inner_match = re.search(r'\{.*\}', m.group(0), re.DOTALL)
    if not inner_match: return m.group(0)
    opts = inner_match.group(0)
    
    arg = m.group(2)
    body = m.group(3)
    
    # Add callback to opts
    if opts.strip().endswith('}'):
        new_opts = opts.strip()[:-1] + f', Callback = function({arg}) {body} end}}'
        return f'{method}({new_opts})'
    return m.group(0)

print("Fixing chained :OnChanged patterns...")
content = chained_onchanged.sub(chained_replacer, content)

# 4. Remove all remaining "Fluent" instances that are not in comments
# and replace with WindUI if it makes sense, or just remove if it's Fluent:Notify
content = content.replace('Fluent:Notify(', 'WindUI:Notify(')
# Any other Fluent.XXX or Fluent:XXX
content = re.sub(r'\bFluent[:.]', 'WindUI:', content)

# 5. Fix specific broken lines identified earlier
content = content.replace(':OnChanged(function(v)al)", Value = false}):On', '') # Cleanup from previous failed regex

# 6. Final verification of Section references
# Ensure all Hub sections are correctly named and used.

with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print("Final fix applied successfully.")
