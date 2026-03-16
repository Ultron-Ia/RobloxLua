import re

filepath = r'c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\windUI\main.lua'

with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
i = 0
while i < len(lines):
    line = lines[i]
    
    # Track the start of a Toggle/Dropdown with an IF V THEN block
    if ':Toggle({' in line or ':Dropdown({' in line:
        if 'Callback = function(v) if v then' in line or 'Callback = function(val) if val then' in line:
            # We found a block that likely needs specialized fixing
            pass

    # Specific known fixes based on manual inspection
    
    # 1. Close Toggle at line 255 (should be 255 in current file)
    if 'controlClone = nil' in line and i + 2 < len(lines) and 'end' == lines[i+1].strip() and 'local attachLoop' in lines[i+3]:
        # This is the end of the Control Player toggle
        new_lines.append(line)
        new_lines.append('                end\n')
        new_lines.append('            end})\n')
        i += 2
        continue

    # 2. Fix the "end" that should be "end)" for Connect
    if 'LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)' in line:
        new_lines.append(line)
        # Look for the end of this connect
        j = i + 1
        if j < len(lines) and 'end' == lines[j].strip() and 'else' in lines[j+1]:
             new_lines.append('                    end)\n')
             i += 2
             continue

    # 3. Add missing }) to Toggle callbacks that end with just end
    if 'if sitLoop then sitLoop:Disconnect(); sitLoop = nil end' in line:
         new_lines.append(line)
         if i + 1 < len(lines) and 'end' == lines[i+1].strip() and 'end' not in lines[i+1]:
             # Check if next line is a new section or element
             pass

    new_lines.append(line)
    i += 1

# Actually, the most reliable way is to just use a sequence of specific string replacements
# for the known broken blocks.

content = "".join(lines)

# Fix Control Player hubs (Brookhaven and Social)
content = content.replace(
    '                        controlClone = nil\n                    end\n                end\n',
    '                        controlClone = nil\n                    end\n                end\n            end})\n'
)

# Fix Attach Loop closures
content = content.replace(
    '                            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)\n                        end\n                else',
    '                            LocalPlayer.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)\n                        end)\n                else'
)

# Fix Sit Loop closures
content = content.replace(
    '                            if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = true end\n                        end\n            end\n                else',
    '                            if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Sit = true end\n                        end)\n            end\n                else'
)

# Fix God Mode closures
content = content.replace(
    '                                hum.Health = math.huge\n                            end\n                        end\n            end\n                else',
    '                                hum.Health = math.huge\n                            end\n                        end)\n                else'
)

# Fix Dandy Item ESP closure (already fixed? let's ensure)
content = content.replace(
    '                                    hl.Name = "SynthItemESP"; hl.FillColor = Color3.fromRGB(0, 255, 100)\n                                end\n                            end\n                        end\n                    else',
    '                                    hl.Name = "SynthItemESP"; hl.FillColor = Color3.fromRGB(0, 255, 100)\n                                end\n                            end\n                        end\n                    end)\n                else'
)

# Fix missing end}) on toggles that have end\n            end)
# (Actually end) should be end}) for WindUI elements)
content = content.replace('                end\n            end)\n', '                end\n            end})\n')

# Specific Fix for "end end})" found by analyzer
content = content.replace('end end})', 'end\n            end})')

with open(filepath, 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)

print("Fix Braces V3 complete.")
