import re, sys

with open('main.lua', encoding='utf-8') as f:
    lines = f.readlines()

out = []
# Track current section variable per tab
# section_var maps to the string to use for element calls
current_section = {}   # tab_var -> section_var_name
section_idx = [0]      # mutable counter

def next_sec_var():
    section_idx[0] += 1
    return f"_Sec{section_idx[0]}"

# Pass 1: replace loader, window, tab creation, notify, selecttab
i = 0
while i < len(lines):
    line = lines[i]

    # 1. Fix loader: remove Fluent, SaveManager, InterfaceManager loader lines  
    if 'dawid-scripts/Fluent' in line and 'loadstring' in line and 'SaveManager' not in line and 'InterfaceManager' not in line:
        line = line.replace(
            'https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua',
            'https://github.com/Footagesus/WindUI/releases/latest/download/main.lua'
        ).replace('local Fluent =', 'local WindUI =')
        out.append(line)
        i += 1
        continue

    # 2. Remove SaveManager/InterfaceManager lines
    if ('SaveManager' in line or 'InterfaceManager' in line) and (
        'loadstring' in line or 'SetLibrary' in line or 'IgnoreTheme' in line or
        'SetIgnore' in line or 'SetFolder' in line or 'BuildInterface' in line or
        'BuildConfig' in line
    ):
        i += 1
        continue

    # 3. Fix window creation block (Fluent params -> WindUI params)
    if 'Fluent:CreateWindow' in line:
        # Find end of this block (closing })
        block = []
        depth = 0
        j = i
        while j < len(lines):
            block.append(lines[j])
            for c in lines[j]:
                if c == '{': depth += 1
                elif c == '}': depth -= 1
            if depth == 0 and j > i:
                break
            j += 1
        indent = re.match(r'^(\s*)', line).group(1)
        out.append(f'{indent}local Window = WindUI:CreateWindow({{\n')
        out.append(f'{indent}    Title = "SYNTHESIS MEGA",\n')
        out.append(f'{indent}    Icon = "shield",\n')
        out.append(f'{indent}    Author = "by Antigravity",\n')
        out.append(f'{indent}    Folder = "SynthesisMega",\n')
        out.append(f'{indent}    Size = UDim2.fromOffset(580, 460),\n')
        out.append(f'{indent}    Transparent = true,\n')
        out.append(f'{indent}    Theme = "Dark",\n')
        out.append(f'{indent}    SideBarWidth = 160,\n')
        out.append(f'{indent}}})\n')
        i = j + 1
        continue

    # 4. AddTab -> Tab
    line = re.sub(r':AddTab\(', ':Tab(', line)

    # 5. Fluent:Notify -> WindUI:Notify
    line = re.sub(r'\bFluent:Notify\(', 'WindUI:Notify(', line)
    
    # 6. Window:SelectTab(1) -> Tabs.Main:Select()
    line = line.replace('Window:SelectTab(1)', 'Tabs.Main:Select()')

    # 7. Handle AddSection: convert to WindUI Section objects
    # Pattern: someTab:AddSection("Section Name")
    m = re.match(r'^(\s*)([\w.]+):AddSection\("([^"]*)"\)\s*$', line)
    if m:
        indent, tab_var, sec_title = m.group(1), m.group(2), m.group(3)
        sv = next_sec_var()
        current_section[tab_var] = sv
        out.append(f'{indent}local {sv} = {tab_var}:Section({{Title = "{sec_title}"}})\n')
        i += 1
        continue

    # 8. Convert Tab-level element calls -> Section-level calls
    # Pattern: someTab:AddButton/AddToggle/AddSlider/AddDropdown/AddColorpicker
    m = re.match(r'^(\s*)([\w.]+):(Add(Button|Toggle|Slider|Dropdown|Colorpicker))\((.*)', line, re.DOTALL)
    if m:
        indent, tab_var, method, elem_type = m.group(1), m.group(2), m.group(3), m.group(4)
        rest = m.group(5)
        
        # Get or create section for this tab
        if tab_var not in current_section:
            sv = next_sec_var()
            current_section[tab_var] = sv
            out.append(f'{indent}local {sv} = {tab_var}:Section({{Title = "General"}})\n')
        sv = current_section[tab_var]
        
        # Now we need to handle multi-line element blocks
        # Collect the full element call (until balanced parens)
        full_call = line
        paren_depth = 0
        for c in line:
            if c == '(': paren_depth += 1
            elif c == ')': paren_depth -= 1
        
        j = i + 1
        while paren_depth > 0 and j < len(lines):
            full_call += lines[j]
            for c in lines[j]:
                if c == '(': paren_depth += 1
                elif c == ')': paren_depth -= 1
            j += 1
        
        # full_call now has the complete AddXXX(...) expression
        # Check if there's a chained :OnChanged(function(v) ... end) after it
        on_changed_callback = None
        
        # Strip trailing newline for processing
        full_call_stripped = full_call.rstrip()
        
        # Check if the next lines have :OnChanged
        after_call = j
        while after_call < len(lines) and lines[after_call].strip() == '':
            after_call += 1
        
        if after_call < len(lines) and ':OnChanged(' in lines[after_call]:
            # Collect the OnChanged block
            oc_line = lines[after_call]
            oc_full = oc_line
            paren_depth2 = 0
            for c in oc_line:
                if c == '(': paren_depth2 += 1
                elif c == ')': paren_depth2 -= 1
            k = after_call + 1
            while paren_depth2 > 0 and k < len(lines):
                oc_full += lines[k]
                for c in lines[k]:
                    if c == '(': paren_depth2 += 1
                    elif c == ')': paren_depth2 -= 1
                k += 1
            
            # Extract callback body from OnChanged(function(v) ... end)
            om = re.search(r':OnChanged\(function\(([^)]*)\)(.*?)end\)', oc_full, re.DOTALL)
            if om:
                cb_args = om.group(1)
                cb_body = om.group(2)
                on_changed_callback = (cb_args, cb_body)
            j = k
        
        # Now convert the method call
        # Remove the "Flag" string argument for Fluent-style AddXXX("Flag", {...})
        # Pattern: AddXXX("flagname", {opts}) or AddXXX({opts})
        rest_stripped = rest
        
        # Convert based on element type
        new_elem_type = elem_type  # Button, Toggle, Slider, Dropdown, Colorpicker
        
        # Extract the options table from the call
        # rest is everything after AddXXX(
        # It might start with "flagname", { or just {
        rest2 = rest_stripped.lstrip()
        
        # Try to find and remove string flag arg: starts with " and has a comma after
        flag_match = re.match(r'^"[^"]*",\s*', rest2)
        if flag_match:
            rest2 = rest2[flag_match.end():]
        
        # Now rest2 starts with the options table {
        # We need to collect the full table and remaining
        # But full_call already has everything - let's just reconstruct
        
        # Simpler approach: rebuild the call from full_call
        # Remove the tab_var:AddXXX("flag", ...) wrapper and convert
        
        # Get the inner table content
        full_inner = re.sub(r'^\s*[\w.]+:Add(?:Button|Toggle|Slider|Dropdown|Colorpicker)\(["\w]*,?\s*', '', full_call_stripped, flags=re.MULTILINE)
        # full_inner now starts with { and ends with })
        # Remove trailing })
        if full_inner.rstrip().endswith('})'):
            full_inner = full_inner.rstrip()[:-2] + '}'
        elif full_inner.rstrip().endswith(')'):
            # No outer table, might just be options inline
            full_inner = full_inner.rstrip()[:-1]
        
        # Convert Fluent options to WindUI options
        # Fluent: Default = X  ->  WindUI: Value = X (for Toggle, Colorpicker, Dropdown)
        # Fluent: Default = X, Min, Max, Rounding  ->  WindUI: Step, Value = {Min, Max, Default}
        # Also integrate OnChanged callback as Callback = function...
        
        def convert_options(table_str, elem, callback_info):
            # For Sliders: convert Default/Min/Max/Rounding to WindUI format
            if elem == 'Slider':
                # Extract individual fields
                default_m = re.search(r'Default\s*=\s*([\d.]+)', table_str)
                min_m = re.search(r'Min\s*=\s*([\d.]+)', table_str)
                max_m = re.search(r'Max\s*=\s*([\d.]+)', table_str)
                rounding_m = re.search(r'Rounding\s*=\s*([\d.]+)', table_str)
                title_m = re.search(r'Title\s*=\s*"([^"]*)"', table_str)
                
                default_v = default_m.group(1) if default_m else '0'
                min_v = min_m.group(1) if min_m else '0'
                max_v = max_m.group(1) if max_m else '100'
                rounding_v = rounding_m.group(1) if rounding_m else '0'
                step = float(rounding_v) if float(rounding_v) > 0 else 1
                if step < 1: step = 0.1
                title_v = title_m.group(1) if title_m else 'Slider'
                
                result = f'{{Title = "{title_v}", Step = {step}, Value = {{Min = {min_v}, Max = {max_v}, Default = {default_v}}}'
                if callback_info:
                    args, body = callback_info
                    result += f', Callback = function({args}){body}end'
                result += '}'
                return result
            
            # For others: replace Default with Value where appropriate
            if elem in ('Toggle',):
                table_str = re.sub(r'\bDefault\s*=\s*', 'Value = ', table_str)
            elif elem == 'Dropdown':
                # Fluent: Default = 1 (index)  ->  WindUI: Value = "FirstValue"
                # We can't easily convert index -> value, just remove Default
                table_str = re.sub(r',?\s*Default\s*=\s*\d+', '', table_str)
            
            # Add Callback if we have OnChanged
            if callback_info:
                args, body = callback_info
                # Remove trailing } and add Callback
                t = table_str.rstrip()
                if t.endswith('}'):
                    t = t[:-1]
                t = t.rstrip().rstrip(',')
                t += f', Callback = function({args}){body}end}}'
                return t
            return table_str
        
        converted_opts = convert_options(full_inner, elem_type, on_changed_callback)
        
        out.append(f'{indent}{sv}:{new_elem_type}({converted_opts})\n')
        i = j
        continue

    # 9. Adapt plain Tabs setup lines
    # Tabs.X:AddSection -> already handled above
    
    # Default: keep line
    out.append(line)
    i += 1

with open('main.lua', 'w', encoding='utf-8', newline='\n') as f:
    f.writelines(out)

print(f"Done! Processed {len(lines)} lines -> {len(out)} lines")
