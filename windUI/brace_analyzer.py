def analyze_braces(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    level = 0
    stack = []
    
    for i, line in enumerate(lines, 1):
        # Very simple comment removal
        clean_line = line.split('--')[0]
        
        for char in clean_line:
            if char == '{':
                level += 1
                stack.append(i)
            elif char == '}':
                level -= 1
                if level < 0:
                    print(f"ERROR: Extra '}}' on line {i}: {line.strip()}")
                    level = 0
                else:
                    stack.pop()
                    
    if level > 0:
        print(f"ERROR: Unclosed '{{' starting on lines: {stack}")
    elif level == 0:
        print("Braces are balanced (nesting-wise).")

analyze_braces(r'c:\Users\hoff\OneDrive\Documentos\bot\RobloxLua\windUI\main.lua')
