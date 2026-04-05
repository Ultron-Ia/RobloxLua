const fs = require('fs');
const code = fs.readFileSync('main.lua', 'utf8');

const lines = code.split('\n');
let openCount = 0;
let closeCount = 0;

for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    
    // Ignore lines that begin with comments
    if (line.trim().startsWith("--")) continue; 

    // Openers
    const funcs = (line.match(/\bfunction\b/g) || []).length;
    const ifs = (line.match(/\bif\b/g) || []).length;
    const fors = (line.match(/\bfor\b/g) || []).length;
    const whiles = (line.match(/\bwhile\b/g) || []).length;
    const dos = (line.match(/\bdo\b/g) || []).length;
    
    // In Lua, `for` and `while` ALWAYS have a `do` block immediately with them or following them.
    // So if a line has `for i=1,10 do`, there's 1 for, 1 do. We should only count 'do' unless it's a standalone block? 
    // Wait, no. A block in lua is either created by `if`, `function`, `do`, `repeat`...
    // So counting `function`, `if`, and `do` is enough for openers!
    // Since `for` and `while` use `do`, counting `do` will cover them.

    const ends = (line.match(/\bend\b/g) || []).length;

    openCount += funcs + ifs + dos;
    closeCount += ends;

    // if (i > 2600) console.log(`[Line ${i+1}] Open=${openCount} Close=${closeCount} Delta=${openCount - closeCount}`);
}

console.log(`Total Open: ${openCount}, Total Close: ${closeCount}`);
if (openCount > closeCount) console.log("Missing " + (openCount - closeCount) + " ends!");
if (closeCount > openCount) console.log("Extra " + (closeCount - openCount) + " ends!");
