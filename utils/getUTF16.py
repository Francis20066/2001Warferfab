
text = ""
parses:list[str] = []
result:list[str] = []

with open("utils/input.txt","r",encoding="utf-8") as f:
    text = f.read()

parses = text.split('\n')
    
for s in parses:
    o = ','.join(f"0{ord(ch):04X}h" for ch in s)+",0000h"
    result.append(o)

output = '\n'.join(result)

with open("utils/output.txt",mode='w',encoding="utf-8") as f:
    f.write(output)