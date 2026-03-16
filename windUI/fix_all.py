"""
Fix all remaining Fluent/conversion bugs in WindUI main.lua:
1. Remove AddParagraph (Fluent only)
2. Convert AddDropdown("flag", {Default=N}) -> Dropdown({Value="..."})
3. Convert var:OnChanged(function(v)...) into inline Callback pattern
4. Fix :Toggle():OnChanged() chaining -> Toggle({Callback=...})
5. Fix :Dropdown():OnChanged() chaining -> Dropdown({Callback=...})
"""
import re

with open('main.lua', encoding='utf-8') as f:
    txt = f.read()

# ─── 1. Remove AddParagraph lines entirely ────────────────────────────────────
txt = re.sub(r'[ \t]*\w+:AddParagraph\([^\n]*\)\n', '', txt)

# ─── 2. Convert remaining AddDropdown("flag", {opts Default=N}) ───────────────
# Pattern: :AddDropdown("flag", {opts})
txt = re.sub(r':AddDropdown\("[^"]*",\s*\{', ':Dropdown({', txt)
# Remove Default = N (Fluent-style index) from Dropdowns
# but keep other Default = values (for colorpickers etc.)
# Only remove when preceded by Values table context
txt = re.sub(r'(Values\s*=\s*\{[^}]*\}[^}]*),\s*Default\s*=\s*\d+', r'\1', txt)

# ─── 3. Fix standalone var:OnChanged(function(v) simpleStatement end) ────────
# These are like: BPD:OnChanged(function(val) _G.SynthState.TargetPlayer = val end)
# Convert them to be added as Callback on the PREVIOUS line
# Actually simplest: just convert to a RenderStepped-style by wrapping in a local function
# For player dropdowns: convert BPD:OnChanged -> just keep it but make it safe
# WindUI Section Dropdown DOES return an object that can receive method calls
# Let's check by leaving them but making them safe with pcall

# ─── 4. Fix :Toggle():OnChanged() chaining ───────────────────────────────────
# Pattern: _SecX:Toggle({...}):OnChanged(function(v) CODE end)
# Convert to: _SecX:Toggle({..., Callback = function(v) CODE end})

def fix_element_onchanged(txt, method):
    pattern = re.compile(
        r'(_Sec\d+|[\w.]+):(' + method + r')\(\{([^}]*)\}\):OnChanged\(function\((\w*)\)\s*(.*?)\s*end\)',
        re.DOTALL
    )
    def replacer(m):
        sec = m.group(1); meth = m.group(2)
        opts = m.group(3).rstrip()
        arg = m.group(4); body = m.group(5)
        # Remove trailing comma from opts if present
        opts = re.sub(r',\s*$', '', opts)
        return f'{sec}:{meth}({{{opts}, Callback = function({arg}) {body} end}})'
    return pattern.sub(replacer, txt)

# Also fix the malformed lines like:
# _Sec19:Toggle({...}):OnChanged(function(v) A end, Callback = function(v) B end})
# which is completely broken syntax - fix to just use the FIRST function's body
def fix_malformed_chained(txt):
    pattern = re.compile(
        r'(_Sec\d+):(\w+)\(\{([^}]*)\}\):OnChanged\(function\((\w*)\)\s*(.*?)\s*end,\s*Callback\s*=\s*function\((\w*)\)\s*(.*?)\s*end\}\)',
        re.DOTALL
    )
    def replacer(m):
        sec = m.group(1); meth = m.group(2)
        opts = m.group(3).rstrip(); arg1 = m.group(4); body1 = m.group(5)
        arg2 = m.group(6); body2 = m.group(7)
        opts = re.sub(r',\s*$', '', opts)
        # Use both callbacks combined
        combined_body = body1.strip()
        if body2.strip():
            combined_body += '\n        ' + body2.strip()
        return f'{sec}:{meth}({{{opts}, Callback = function({arg1}) {combined_body} end}})'
    return pattern.sub(replacer, txt)

txt = fix_malformed_chained(txt)
txt = fix_element_onchanged(txt, 'Toggle')
txt = fix_element_onchanged(txt, 'Dropdown')
txt = fix_element_onchanged(txt, 'Slider')
txt = fix_element_onchanged(txt, 'Colorpicker')

# ─── 5. Fix the GameSelector block ───────────────────────────────────────────
# Line 75-77 pattern:
# local GameSelector = Tabs.Main:AddDropdown(...) / Tabs.Main:Dropdown(...)
# GameSelector:OnChanged(function(v)
#    ... huge block ...
# end)
#
# Convert to: _Sec1:Dropdown({..., Callback = function(v) ... end})

# Find and fix the GameSelector OnChanged
gs_pattern = re.compile(
    r'local GameSelector = (?:Tabs\.Main:(?:AddDropdown|Dropdown))\([^\n]*\)\s*\n\s*GameSelector:OnChanged\(function\(v\)',
    re.DOTALL
)
if gs_pattern.search(txt):
    # Replace the two-part pattern with a single Dropdown call
    txt = re.sub(
        r'local GameSelector = (?:Tabs\.Main:(?:AddDropdown|Dropdown))\(([^\n]*)\)\s*\n\s*GameSelector:OnChanged\(function\(v\)',
        lambda m: 'local GameSelector = _Sec1:Dropdown({Title = "Select Game Module", Values = {"...", "Rivals", "Brookhaven", "Dandy\'s World", "Social/Talking Hub", "[LUCKY COWARD] Shenanigans de Jujutsu", "Peça de Sailor"}, Value = "...", Callback = function(v)',
        txt
    )
    # Fix closing: the "end)" of OnChanged now closes both function and Dropdown call
    # Find the last "end)" that closes GameSelector:OnChanged
    # It's: "    end)\n\n    -- POPULATE AIMBOT"
    txt = txt.replace(
        '    end)\n\n\n    -- POPULATE AIMBOT',
        '    end})\n\n\n    -- POPULATE AIMBOT'
    )
else:
    print("WARNING: GameSelector pattern not found!")

# ─── 6. Fix BPD, SPD, DPD, etc. player dropdowns ────────────────────────────
# Pattern: local XPD = SOMETAB:Dropdown({...})  followed by  XPD:OnChanged(function(val) ... end)
def fix_player_dropdown(txt):
    pattern = re.compile(
        r'(local (\w+PD) = [\w.]+:Dropdown\(\{[^}]+\})\)\s*\n(\s*)\2:OnChanged\(function\((\w+)\)\s*(.*?)\s*end\)',
        re.DOTALL
    )
    def replacer(m):
        decl = m.group(1)  # "local BPD = BTab:Dropdown({Title=..., Values=...}"
        var = m.group(2)
        indent = m.group(3)
        arg = m.group(4); body = m.group(5)
        return f'{decl}, Callback = function({arg}) {body} end}})'
    return pattern.sub(replacer, txt)

txt = fix_player_dropdown(txt)

# ─── 7. Fix SetValues remaining ──────────────────────────────────────────────  
txt = txt.replace(':SetValues(GetPlayers())', ':Refresh(GetPlayers(), true)')

# ─── 8. Fix Aimbot sliders - they got merged incorrectly ─────────────────────
# The convert.py merged two slider callbacks into one. Find and fix.
# AimFOV was merged with AimSmooth callback, causing wrong data
# Look for the aimbot section and fix
old_aim = """    _Sec20:Slider({Title = "FOV Size", Step = 1, Value = {Min = 10, Max = 800, Default = 100}, Callback = function(v) _G.SynthState.AimSmooth = v end})"""
new_aim = """    _Sec20:Slider({Title = "FOV Size", Step = 1, Value = {Min = 10, Max = 800, Default = 100}, Callback = function(v) _G.SynthState.AimFOV = v end})
    _Sec20:Slider({Title = "Smoothness (Cam)", Step = 0.1, Value = {Min = 1, Max = 20, Default = 3}, Callback = function(v) _G.SynthState.AimSmooth = v end})"""
if old_aim in txt:
    txt = txt.replace(old_aim, new_aim)

# ─── 9. Fix Visuals toggles similarly ────────────────────────────────────────
# The _Sec21 block might have merged callbacks - fix if pattern exists
old_vis = """    _Sec21:Toggle({Title = "Boxes", Value = false}):OnChanged(function(v) _G.SynthState.BoxESP = v end, Callback = function(v) _G.SynthState.NameESP = v end})"""
new_vis = """    _Sec21:Toggle({Title = "Boxes", Value = false, Callback = function(v) _G.SynthState.BoxESP = v end})
    _Sec21:Toggle({Title = "Names", Value = false, Callback = function(v) _G.SynthState.NameESP = v end})
    _Sec21:Toggle({Title = "Distance", Value = false, Callback = function(v) _G.SynthState.DistESP = v end})
    _Sec21:Toggle({Title = "Skeleton ESP", Value = false, Callback = function(v) _G.SynthState.SkeletonESP = v end})
    _Sec21:Colorpicker({Title = "Skeleton Color", Default = Color3.new(1,1,1), Callback = function(v) _G.SynthState.SkeletonColor = v end})"""
if old_vis in txt:
    txt = txt.replace(old_vis, new_vis)

# ─── 10. Fix the Toggle without Title="Enable Camera Aimbot" being wrong ─────
old_aim_toggle = """    _Sec19:Toggle({Title = "Enable Camera Aimbot", Value = false}):OnChanged(function(v) _G.SynthState.AimEnabled = v end, Callback = function(v) _G.SynthState.SilentAim = v end})
    _Sec19:Dropdown({Title = "Target Part", Values = {"Head", "HumanoidRootPart"}}):OnChanged(function(v) _G.SynthState.AimPart = v end)"""
if old_aim_toggle in txt:
    txt = txt.replace(old_aim_toggle, """    _Sec19:Toggle({Title = "Enable Camera Aimbot", Value = false, Callback = function(v) _G.SynthState.AimEnabled = v end})
    _Sec19:Toggle({Title = "Silent Aim (Magic Bullet)", Value = false, Callback = function(v) _G.SynthState.SilentAim = v end})
    _Sec19:Dropdown({Title = "Target Part", Values = {"Head", "HumanoidRootPart"}, Value = "Head", Callback = function(v) _G.SynthState.AimPart = v end})""")

with open('main.lua', 'w', encoding='utf-8', newline='\n') as f:
    f.write(txt)

# Report remaining issues
print("Done!")
print("Remaining 'AddDropdown':", txt.count('AddDropdown'))
print("Remaining 'AddParagraph':", txt.count('AddParagraph'))
print("Remaining ':OnChanged':", txt.count(':OnChanged'))
print("Remaining 'Fluent':", txt.count('Fluent'))
print("Total lines:", txt.count('\n'))
