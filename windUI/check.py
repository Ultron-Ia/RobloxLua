lines=open(r'windUI\main.lua',encoding='utf-8').readlines()
for i,l in enumerate(lines,1):
    if ':OnChanged' in l or ('Fluent' in l and l.lstrip()[:2] != '--'):
        print(f'{i}: {l.rstrip()[:130]}')
